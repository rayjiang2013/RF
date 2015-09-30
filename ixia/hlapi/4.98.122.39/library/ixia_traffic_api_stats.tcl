
proc ::ixia::traffic_stats { args } {
    variable executeOnTclServer
    set keyed_array_index 0
    variable traffic_stats_num_calls
    set keyed_array_name traffic_stats_returned_keyed_array_$traffic_stats_num_calls
    mpincr traffic_stats_num_calls
    variable $keyed_array_name
    catch {array unset $keyed_array_name}
    array set $keyed_array_name ""
    variable traffic_stats_max_list_length

    set procName [lindex [info level [info level]] 0]

    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::traffic_stats $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
        } else {
            set retData $retValue
        }
        
        if {![catch {keylget retData handle} keyed_a_name]} {
            if {![info exists ::ixTclSvrHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Not connected to TclServer."
                return $returnList
            }
            array set $keyed_a_name [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{array get $keyed_a_name\}]
        }
        
        return $retData
    }

    variable atmStatsConfig
    variable new_ixnetwork_api
    variable reserved_port_list
    variable ixnetwork_rp2vp_handles_array
    variable clear_csv_stats

    set gotStats 0

    ::ixia::utrackerLog $procName $args
    
    set opt_args {
        -port_handle                    REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -streams                        
        -stream                         
        -qos_stats
        -measure_mode                   CHOICES cumulative instantaneous mixed
        -packet_group_id                REGEXP ^[0-9]{1,8}|([0-9]{1,8}-[0-9]{1,8})$
        -vpi                            RANGE 0-4096
        -vci                            RANGE 0-65535
        -vpi_count                      RANGE 0-4096
        -vci_count                      RANGE 0-65535
        -vpi_step                       RANGE 0-4095
        -vci_step                       RANGE 0-65534
        -atm_counter_vpi_data_item_list ANY
        -atm_counter_vci_data_item_list ANY
        -previous_data                  CHOICES keep reset
                                        DEFAULT keep
        -atm_counter_vpi_mode           CHOICES incr decr
        -atm_counter_vci_mode           CHOICES incr decr
        -atm_counter_vpi_type           CHOICES fixed counter table
        -atm_counter_vci_type           CHOICES fixed counter table
        -atm_reassembly_enable_iptcpudp_checksum CHOICES 0 1
        -atm_reassembly_enable_ip_qos   CHOICES 0 1
        -atm_reassembly_encapsulation   CHOICES vcc_mux_ipv4_routed
                                        CHOICES vcc_mux_bridged_eth_fcs
                                        CHOICES vcc_mux_bridged_eth_no_fcs
                                        CHOICES vcc_mux_ipv6_routed
                                        CHOICES vcc_mux_mpls_routed
                                        CHOICES llc_routed_clip
                                        CHOICES llc_bridged_eth_fcs
                                        CHOICES llc_bridged_eth_no_fcs llc_pppoa
                                        CHOICES vcc_mux_ppoa llc_nlpid_routed
        -csv_path                       SHIFT
        -mode                           CHOICES all
                                        CHOICES add_atm_stats
                                        CHOICES add_atm_stats_tx
                                        CHOICES add_atm_stats_rx
                                        CHOICES aggregate 
                                        CHOICES data_plane_port
                                        CHOICES egress_by_flow 
                                        CHOICES egress_by_port
                                        CHOICES faststream
                                        CHOICES flow 
                                        CHOICES igmp_over_ppp
                                        CHOICES l23_test_summary
                                        CHOICES multicast 
                                        CHOICES out_of_filter
                                        CHOICES per_port_flows 
                                        CHOICES session
                                        CHOICES stream
                                        CHOICES streams
                                        CHOICES traffic_item
                                        CHOICES user_defined_stats
                                        CHOICES application_FTP
                                        CHOICES application_HTTP
                                        CHOICES application_TELNET
                                        CHOICES application_SMTP
                                        CHOICES application_IMAP
                                        CHOICES application_POP3
                                        CHOICES application_TriplePlay
                                        CHOICES application_Video
                                        CHOICES application_RTSP
                                        CHOICES application_SIP
                                        CHOICES L47_traffic_item
                                        CHOICES L47_flow_initiator
                                        CHOICES L47_flow_responder
                                        CHOICES L47_traffic_item_tcp
                                        CHOICES L47_flow_initiator_tcp
                                        CHOICES L47_listening_port_tcp
        -egress_mode                    CHOICES conditional paged
                                        DEFAULT conditional
        -drill_down_type                CHOICES none
                                        CHOICES per_ips
                                        CHOICES per_ports
                                        CHOICES per_initiator_flows
                                        CHOICES per_responder_flows
                                        CHOICES per_initiator_ports
                                        CHOICES per_initiator_ips
                                        CHOICES per_responder_ports
                                        CHOICES per_listening_ports
                                        CHOICES per_responder_port
                                        CHOICES per_responder_ips
                                        CHOICES per_ports_per_initiator_flows
                                        CHOICES per_ports_per_responder_flows
                                        CHOICES per_ports_per_initiator_ips
                                        CHOICES per_ports_per_responder_ips
                                        CHOICES per_initiator_flows_per_initiator_ports
                                        CHOICES per_initiator_flows_per_initiator_ips
                                        CHOICES per_responder_flows_per_responder_ports
                                        CHOICES per_responder_flows_per_responder_ips
                                        CHOICES per_initiator_ports_per_initiator_ips
                                        CHOICES per_responder_ports_per_responder_ips
                                        CHOICES per_listening_ports_per_responder_port
                                        CHOICES per_ports_per_initiator_flows_per_initiator_ips
                                        CHOICES per_ports_per_responder_flows_per_responder_ips
                                        CHOICES per_initiator_flows_per_initiator_ports_per_initiator_ips
                                        CHOICES per_responder_flows_per_responder_ports_per_responder_ips
                                        DEFAULT none
        -drill_down_traffic_item        ANY
        -drill_down_port                ANY
        -drill_down_flow                ANY
        -drill_down_listening_port      NUMERIC
        -uds_action                     CHOICES get_available_port_filters
                                        CHOICES get_available_protocol_stack_filters
                                        CHOICES get_available_traffic_item_filters
                                        CHOICES get_available_tracking_filters
                                        CHOICES get_available_statistic_filters
                                        CHOICES get_available_stats 
                                        CHOICES get_stats 
                                        DEFAULT get_stats
        -uds_type                       CHOICES l23_protocol_port 
                                        CHOICES l23_protocol_stack
                                        CHOICES l23_traffic_flow 
                                        CHOICES l23_traffic_flow_detective
                                        CHOICES l23_traffic_item
                                        CHOICES l23_traffic_port
                                        DEFAULT l23_protocol_port
        -uds_port_filter                ANY
        -uds_protocol_stack_filter      ANY
        -uds_traffic_item_filter        ANY
        -uds_tracking_filter            ANY
        -uds_statistic_filter           ANY
        -uds_port_filter_count                NUMERIC
        -uds_protocol_stack_filter_count      NUMERIC
        -uds_traffic_item_filter_count        NUMERIC
        -uds_tracking_filter_count            NUMERIC
        -uds_statistic_filter_count           NUMERIC
        -uds_l23ps_sorting_statistic    ANY
        -uds_l23ps_sorting_type         CHOICES ascending descending
        -uds_l23ps_num_results          NUMERIC
                                        DEFAULT 50
        -uds_l23ps_drilldown            CHOICES per_session per_range
                                        DEFAULT per_session
        -uds_l23tf_aggregated_across_ports      CHOICES 0 1
        -uds_l23tf_egress_latency_bin_display   CHOICES none show_egress_flat_view show_egress_rows show_latency_bin_stats
        -uds_l23tf_filter_type                  CHOICES enumeration tracking
        -uds_l23tf_enumeration_sorting_type     CHOICES ascending descending null
        -uds_l23tf_tracking_operator            CHOICES is_any_of is_different is_equal is_equal_or_greater is_equal_or_smaller is_greater is_in_any_range is_none_of is_smaller null
        -uds_l23tf_tracking_value               LIST_OF_LISTS_NO_TYPE_CHECK
        -uds_l23tfd_flow_type                   CHOICES all_flows live_flows dead_flows
        -uds_l23tfd_show_egress_flows           CHOICES 0 1
        -uds_l23tfd_dead_flows_treshold         NUMERIC
        -uds_l23tfd_tracking_operator           CHOICES is_different is_equal is_equal_or_greater is_equal_or_smaller is_greater is_smaller null
        -uds_l23tfd_tracking_value              ANY
        -uds_l23tfd_statistic_operator          CHOICES is_different is_equal is_equal_or_greater is_equal_or_smaller is_greater is_smaller null
        -uds_l23tfd_statistic_value             ANY
        -uds_l23tfd_statistic_all_flows_sort_by           ANY
        -uds_l23tfd_statistic_all_flows_sorting_type      CHOICES ascending descending null worst_performers best_performers
        -uds_l23tfd_statistic_all_flows_num_results       NUMERIC
        -uds_l23tfd_statistic_dead_flows_sort_by          ANY
        -uds_l23tfd_statistic_dead_flows_sorting_type     CHOICES ascending descending null worst_performers best_performers
        -uds_l23tfd_statistic_dead_flows_num_results      NUMERIC
        -uds_l23tfd_statistic_live_flows_sort_by          ANY
        -uds_l23tfd_statistic_live_flows_sorting_type     CHOICES ascending descending null worst_performers best_performers
        -uds_l23tfd_statistic_live_flows_num_results      NUMERIC
                                                DEFAULT 50
        -aggregation                    CHOICES framesize qos user
                                        DEFAULT framesize
        -ignore_rate                    CHOICES 0 1
                                        DEFAULT 0
        -return_method                  CHOICES keyed_list keyed_list_or_array array csv
                                        DEFAULT keyed_list
        -multicast_aggregation          CHOICES mc_address mc_group tos
                                        DEFAULT mc_group
        -csv_filename
        -traffic_generator              CHOICES ixos ixnetwork ixaccess ixnetwork_540
                                        DEFAULT ixos
        -egress_stats_list              ANY
    }
    # Variable csv_path should be reset before each call of traffic_stats
    variable csv_path
    set csv_path ""
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    # unset all the arrays used in the traffic_stats procedure
    if {[info exists previous_data] && $previous_data == "reset"} {
        ::ixia::cleanupTrafficStatsArrays
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        
        set traffic_type "nextGen"
        switch -- $traffic_generator {
            "ixnetwork_540" {
                set traffic_type "nextGen"
            }
            "ixnetwork" {
                if {[regexp "NO" $::ixia::ixnetworkVersion]  && \
                        [info exists ::ixia::forceNextGenTraffic] &&\
                        $::ixia::forceNextGenTraffic == 1} {
                    
                    set traffic_type "nextGen"
                } else {
                    set traffic_type "legacy"
                }
            }
            default {
                set traffic_type "ixos"
                if {[is_default_param_value "traffic_generator" $args]} {
                    if {[string first "NO" $::ixia::ixnetworkVersion] > 0} {
                        set traffic_type "nextGen"
                    }
                } else {
                    if { [string first "NO" $::ixia::ixnetworkVersion] > 0 } {
                        # Using IxOS with a Network Only setting...
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                    Cannot use IxOS traffic generator with a 'Network Only' HLT setting. \
                                    Please set traffic_generator parameter to a valid value."
                        return $returnList
                    }
                }
            }
        }
        
        if {$traffic_type == "nextGen"} {

            if {[info exists mode] && $mode == "user_defined_stats"} {
                set retCode [::ixia::540userDefinedStats $args $opt_args]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: [keylget retCode log]"
                    return $returnList
                }
            } else {
                set retCode [::ixia::540trafficStats $args $opt_args]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: [keylget retCode log]"
                    return $returnList
                }
            }
            return $retCode
        } elseif {$traffic_type == "legacy"} {
            set retCode [::ixia::ixnetwork_traffic_stats $args $opt_args]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: [keylget retCode log]"
                return $returnList
            }
            return $retCode
        }
    }
    
    if {![info exists port_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Parameter\
                -port_handle is mandatory. Please supply this value."
        return $returnList
    }
    
    if {[info exists ixnetwork_rp2vp_handles_array($port_handle)]} {
        set port_handle $ixnetwork_rp2vp_handles_array($port_handle)
    }
    
    # Input port list is in the format A/B/C, change it to A B C
    set port_list [format_space_port_list $port_handle]

    if {[info exists mode] && (($mode == "session") || ($mode == "all"))} {
        set cmdParams " -port_handle $port_handle "
        if {[info exists aggregation]} {
            append cmdParams " -aggregation  $aggregation"
        }
        if {[info exists csv_filename]} {
            append cmdParams " -csv_filename $csv_filename"
        }
        set cmdString [format "%s %s" \
                ::ixia::ixaccess_per_session_traffic_stats $cmdParams]
        
        if {![catch {package present IxTclAccess}]} {
            set retCode [eval $cmdString]
            if {$mode == "session"} {
                debug "$cmdString"
                return $retCode
            } else  {
                set returnList $retCode
            }
        }
    }

    if {[info exists mode] && (($mode == "multicast") || ($mode == "all"))} {
        set cmdParams " -port_handle $port_handle "
        if {[info exists multicast_aggregation]} {
            append cmdParams " -multicast_aggregation  $multicast_aggregation"
        }
        if {[info exists csv_filename]} {
            append cmdParams " -csv_filename $csv_filename"
        }
        set cmdString [format "%s %s" ::ixia::ixaccess_multicast_traffic_stats \
                $cmdParams]
        
        if {![catch {package present IxTclAccess}]} {
            set retCode [eval $cmdString]
            if {$mode == "multicast"} {
                debug "$cmdString"
                return $retCode
            } else  {
                set returnList $retCode
            }
        }
    }

    if {[info exists mode] && (($mode == "igmp_over_ppp") || ($mode == "all"))} {
        set cmdParams " -port_handle $port_handle "
        debug "::ixia::ixaccess_igmpOverPpp_traffic_stats \
                $cmdParams"
        set cmdString [format "%s %s" \
                ::ixia::ixaccess_igmpOverPpp_traffic_stats $cmdParams]
        
        if {![catch {package present IxTclAccess}]} {
            set retCode [eval $cmdString]
            if {$mode == "igmp_over_ppp"} {
                debug "$cmdString"
                return $retCode
            } else  {
                set returnList $retCode
            }
        }
    }

    set traffic_stats_count_option_list "elapsed_time aggregate.rx.pkt_count \
            aggregate.rx.fragments_count                                     \
            aggregate.tx.protocol_pkt_count aggregate.rx.protocol_pkt_count  \
            aggregate.tx.pkt_count        aggregate.rx.pkt_byte_count        \
            aggregate.tx.pkt_byte_count   aggregate.rx.uds1_count            \
            aggregate.rx.uds2_count       aggregate.rx.pkt_bit_count         \
            aggregate.tx.pkt_bit_count    aggregate.rx.collisions_count      \
            aggregate.rx.crc_errors_count aggregate.rx.dribble_errors_count  \
            aggregate.rx.oversize_count   aggregate.rx.undersize_count       \
            aggregate.rx.vlan_pkts_count  aggregate.rx.qos0_count            \
            aggregate.rx.qos1_count       aggregate.rx.qos2_count            \
            aggregate.rx.qos3_count       aggregate.rx.qos4_count            \
            aggregate.rx.qos5_count       aggregate.rx.qos6_count            \
            aggregate.rx.qos7_count       aggregate.rx.data_int_frames_count \
            aggregate.rx.data_int_errors_count                               \
            aggregate.rx.sequence_frames_count                               \
            aggregate.rx.sequence_errors_count"

    set traffic_stats_rate_option_list "elapsed_time aggregate.rx.pkt_rate \
            aggregate.rx.fragments_rate                                    \
            aggregate.tx.protocol_pkt_rate aggregate.rx.protocol_pkt_rate  \
            aggregate.tx.pkt_rate        aggregate.rx.pkt_byte_rate        \
            aggregate.tx.pkt_byte_rate   aggregate.rx.uds1_rate            \
            aggregate.rx.uds2_rate       aggregate.rx.pkt_bit_rate         \
            aggregate.tx.pkt_bit_rate    aggregate.rx.collisions_rate      \
            aggregate.rx.crc_errors_rate aggregate.rx.dribble_errors_rate  \
            aggregate.rx.oversize_rate   aggregate.rx.undersize_rate       \
            aggregate.rx.vlan_pkts_rate  aggregate.rx.qos0_rate            \
            aggregate.rx.qos1_rate       aggregate.rx.qos2_rate            \
            aggregate.rx.qos3_rate       aggregate.rx.qos4_rate            \
            aggregate.rx.qos5_rate       aggregate.rx.qos6_rate            \
            aggregate.rx.qos7_rate       aggregate.rx.data_int_frames_rate \
            aggregate.rx.data_int_errors_rate                              \
            aggregate.rx.sequence_frames_rate                              \
            aggregate.rx.sequence_errors_rate"

    set ixia_traffic_stats_option_list "transmitDuration framesReceived \
            fragments  protocolServerTx protocolServerRx                \
            framesSent bytesReceived bytesSent userDefinedStat1         \
            userDefinedStat2 bitsReceived bitsSent collisions fcsErrors \
            dribbleErrors oversize undersize vlanTaggedFramesRx         \
            qualityOfService0 qualityOfService1 qualityOfService2       \
            qualityOfService3 qualityOfService4 qualityOfService5       \
            qualityOfService6 qualityOfService7 dataIntegrityFrames     \
            dataIntegrityErrors sequenceFrames sequenceErrors"

    set traffic_stats_count_qos_option_list "elapsed_time   \
            aggregate.tx.pkt_count  aggregate.rx.pkt_count  \
            aggregate.rx.qos0_count aggregate.rx.qos1_count \
            aggregate.rx.qos2_count aggregate.rx.qos3_count \
            aggregate.rx.qos4_count aggregate.rx.qos5_count \
            aggregate.rx.qos6_count aggregate.rx.qos7_count"

    set traffic_stats_rate_qos_option_list "elapsed_time  \
            aggregate.tx.pkt_rate  aggregate.rx.pkt_rate  \
            aggregate.rx.qos0_rate aggregate.rx.qos1_rate \
            aggregate.rx.qos2_rate aggregate.rx.qos3_rate \
            aggregate.rx.qos4_rate aggregate.rx.qos5_rate \
            aggregate.rx.qos6_rate aggregate.rx.qos7_rate"

    set ixia_traffic_stats_qos_option_list "transmitDuration framesSent \
            framesReceived qualityOfService0 qualityOfService1 \
            qualityOfService2 qualityOfService3 qualityOfService4 \
            qualityOfService5 qualityOfService6 qualityOfService7"

    set traffic_stats_pgid_option_list "pgid.rx.pkt_count pgid.rx.pkt_rate \
            pgid.rx.min_latency pgid.rx.max_latency pgid.rx.avg_latency"
       
    # Start ATM :
    if {[info exists mode] && (($mode == "add_atm_stats") || \
            ($mode == "add_atm_stats_rx") || ($mode == "add_atm_stats_tx"))} {
        # Start ATM parameters validation:
        if {![info exists atm_counter_vci_type] || \
                ![info exists atm_counter_vpi_type]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the \
                    -mode is $mode, -atm_counter_vci_type and \
                    -atm_counter_vpi_type are required. \
                    Please supply these values."
            return $returnList
        }

        if {(($atm_counter_vpi_type == "fixed") || \
                ($atm_counter_vpi_type == "counter")) && \
                ![info exists vpi]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -atm_counter_vpi_type is fixed or counter, \
                    -vpi is required. Please supply this value."
            return $returnList
        }

        if {(($atm_counter_vci_type == "fixed") || \
                ($atm_counter_vci_type == "counter")) && \
                ![info exists vci]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -atm_counter_vci_type is fixed or counter, \
                    -vci is required. Please supply this value."
            return $returnList
        }

        if {$atm_counter_vpi_type == "counter"} {
            if {![info exists atm_counter_vpi_mode] || \
                    ![info exists vpi_step]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vpi_type is counter, \
                        -atm_counter_vpi_mode and vpi_step are \
                        required. Please supply these values."
                return $returnList
            }

            if {(($atm_counter_vpi_mode == "incr") || \
                    ($atm_counter_vpi_mode == "decr")) && \
                    ![info exists vpi_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vpi_type is counter and \
                        atm_counter_vpi_mode is incr or decr, \
                        -vpi_count is required. Please supply \
                        this value."
                return $returnList
            }
        }

        if {$atm_counter_vci_type == "counter"} {
            if {![info exists atm_counter_vci_mode] || \
                    ![info exists vci_step]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vci_type is counter, \
                        -atm_counter_vci_mode and vci_step are \
                        required. Please supply these values."
                return $returnList
            }

            if {(($atm_counter_vci_mode == "incr") || \
                    ($atm_counter_vci_mode == "decr")) && \
                    ![info exists vci_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vci_type is counter and \
                        atm_counter_vci_mode is incr or decr, \
                        -vci_count is required. Please supply \
                        this value."
                return $returnList
            }
        }

        if {$atm_counter_vpi_type == "table"} {
            if {![info exists atm_counter_vpi_data_item_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vpi_type is table, \
                        -atm_counter_vpi_data_item_list is required. \
                        Please supply this value."
                return $returnList
            }
        }

        if {$atm_counter_vci_type == "table"} {
            if {![info exists atm_counter_vci_data_item_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vci_type is table, \
                        -atm_counter_vci_data_item_list is required. \
                        Please supply this value."
                return $returnList
            }
        }

        if {($atm_counter_vpi_type != "fixed") && \
                ($atm_counter_vpi_type != "counter") && \
                [info exists vpi]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the \
                    -atm_counter_vpi_type is not fixed or counter, \
                    -vpi is not required. Do not supply this value."
            return $returnList
        }

        if {($atm_counter_vci_type != "fixed") && \
                ($atm_counter_vci_type != "counter") && \
                [info exists vci]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the \
                    -atm_counter_vci_type is not fixed or counter, \
                    -vci is not required. Do not supply this value."
            return $returnList
        }

        if {$atm_counter_vpi_type != "table"} {
            if {[info exists atm_counter_vpi_data_item_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vpi_type is not table, \
                        -atm_counter_vpi_data_item_list is not \
                        required. Do not supply this value."
                return $returnList
            }
        }

        if {$atm_counter_vci_type != "table"} {
            if {[info exists atm_counter_vci_data_item_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vci_type is not table, \
                        -atm_counter_vci_data_item_list is not \
                        required. Do not supply this value."
                return $returnList
            }
        }

        if {$atm_counter_vpi_type != "counter"} {
            if {[info exists atm_counter_vpi_mode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vpi_type is not counter, \
                        -atm_counter_vpi_mode is not required. \
                        Do not supply this value."
                return $returnList
            }
        }

        if {$atm_counter_vci_type != "counter"} {
            if {[info exists atm_counter_vci_mode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vci_type is not counter, \
                        -atm_counter_vci_mode is not required. \
                        Do not supply this value."
                return $returnList
            }
        }

        if {$atm_counter_vpi_type != "counter"} {
            if {[info exists vpi_step]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vpi_type is not counter, \
                        -vpi_step is not required. \
                        Do not supply this value."
                return $returnList
            }
        }

        if {$atm_counter_vci_type != "counter"} {
            if {[info exists vci_step]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vci_type is not counter, \
                        -vci_step is not required. Do not supply \
                        this value."
                return $returnList
            }
        }

        if {$atm_counter_vpi_type != "counter"} {
            if {[info exists vpi_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vpi_type is not counter, \
                        -vpi_count is not required. Do not supply \
                        this value."
                return $returnList
            }
        } elseif {($atm_counter_vpi_mode != "incr") && \
                ($atm_counter_vpi_mode != "decr")} {
            if {[info exists vpi_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vpi_mode is not incr or \
                        decr, -vpi_count is not required. Do not \
                        supply this value."
                return $returnList
            }
        }

        if {$atm_counter_vci_type != "counter"} {
            if {[info exists vci_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vci_type is not counter, \
                        -vci_count is not required. Do not supply \
                        this value."
                return $returnList
            }
        } elseif {($atm_counter_vci_mode != "incr") && \
                ($atm_counter_vci_mode != "decr")} {
            if {[info exists vci_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        the -atm_counter_vci_mode is not incr or \
                        decr, -vci_count is not required. Do not \
                        supply this value."
                return $returnList
            }
        }

        if {[info exists atm_counter_vpi_data_item_list]} {
            set newItemList {}
            foreach el $atm_counter_vpi_data_item_list {
                if {([catch {mpexpr $el}]) || ([mpexpr $el < 0]) || \
                        ([mpexpr $el > 4095])} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Each element \
                            of -atm_counter_vpi_data_item_list should be an \
                            integer between 0 and 4095."
                    return $returnList
                }
                lappend newItemList [format "%04x" $el]
            }
            set atm_counter_vpi_data_item_list $newItemList
        }

        if {[info exists atm_counter_vci_data_item_list]} {
            set newItemList {}
            foreach el $atm_counter_vci_data_item_list {
                if {([catch {mpexpr $el}]) || ([mpexpr $el <= 0]) || \
                        ([mpexpr $el > 65535])} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Each element \
                            of -atm_counter_vci_data_item_list should be an \
                            integer between 0 and 65535."
                    return $returnList
                }
                lappend newItemList [format "%04x" $el]
            }
            set atm_counter_vci_data_item_list $newItemList
        }
        #End of ATM Validations

        foreach port $port_list {
            scan $port "%d %d %d" ch ca po

            if {[port isActiveFeature $ch $ca $po portFeatureAtm]} {
                ::ixia::addPortToWrite $ch/$ca/$po

                # Set the global array :
                if {[info exists atm_reassembly_encapsulation]} {
                    set atmStatsConfig($port,encap) $atm_reassembly_encapsulation
                } else {
                    set atmStatsConfig($port,encap) "llc_routed_clip"
                }

                set atmStatsConfig($port,vpiType) $atm_counter_vpi_type
                set atmStatsConfig($port,vciType) $atm_counter_vci_type

                if {[info exists vpi]} {
                    set atmStatsConfig($port,vpi) $vpi
                }
                if {[info exists vci]} {
                    set atmStatsConfig($port,vci) $vci
                }
                if {[info exists vpi_step]} {
                    set atmStatsConfig($port,vpi_step) $vpi_step
                }
                if {[info exists vci_step]} {
                    set atmStatsConfig($port,vci_step) $vci_step
                }
                if {[info exists vpi_count]} {
                    set atmStatsConfig($port,vpi_count) $vpi_count
                }
                if {[info exists vci_count]} {
                    set atmStatsConfig($port,vci_count) $vci_count
                }
                if {[info exists atm_counter_vpi_data_item_list]} {
                    set atmStatsConfig($port,atm_counter_vpi_data_item_list) \
                            $atm_counter_vpi_data_item_list
                }
                if {[info exists atm_counter_vci_data_item_list]} {
                    set atmStatsConfig($port,atm_counter_vci_data_item_list) \
                            $atm_counter_vci_data_item_list
                }
                if {[info exists atm_counter_vpi_mode]} {
                    set atmStatsConfig($port,atm_counter_vpi_mode) \
                            $atm_counter_vpi_mode
                }
                if {[info exists atm_counter_vci_mode]} {
                    set atmStatsConfig($port,atm_counter_vci_mode) \
                            $atm_counter_vci_mode
                }

                # Construct vpi/vci lists :
                switch $atm_counter_vpi_type {
                    fixed {
                        set vpiList [list $vpi]
                    }
                    counter {
                        set vpiList {}
                        switch $atm_counter_vpi_mode {
                            incr {
                                set current $vpi
                                for {set i 1} {$i <= $vpi_count} {incr i} {
                                    lappend vpiList $current
                                    incr current $vpi_step
                                }
                            }
                            decr {
                                set current $vpi
                                for {set i 1} {$i <= $vpi_count} {incr i} {
                                    lappend vpiList $current
                                    incr current -$vpi_step
                                    if {$current < 0} {
                                        break
                                    }
                                }
                            }
                        }
                    }
                    table {
                        set vpiList $atm_counter_vpi_data_item_list
                    }
                }

                switch $atm_counter_vci_type {
                    fixed {
                        set vciList [list $vci]
                    }
                    counter {
                        set vciList {}
                        switch $atm_counter_vci_mode {
                            incr {
                                set current $vci
                                for {set i 1} {$i <= $vci_count} {incr i} {
                                    lappend vciList $current
                                    incr current $vci_step
                                }
                            }
                            decr {
                                set current $vci
                                for {set i 1} {$i <= $vci_count} {incr i} {
                                    lappend vciList $current
                                    incr current -$vci_step
                                    if {$current < 0} {
                                        break
                                    }
                                }
                            }
                        }
                    }
                    table {
                        set vciList $atm_counter_vci_data_item_list
                    }
                }

                # Construct Tx, Rx lists :
                if {($mode == "add_atm_stats") || \
                            ($mode == "add_atm_stats_tx")} {
                    atmStat removeAllTx $ch $ca $po
                }
                if {($mode == "add_atm_stats") || \
                            ($mode == "add_atm_stats_rx")} {
                    atmStat removeAllRx $ch $ca $po
                    atmReassembly removeAll $ch $ca $po
                }
                
                
                atmStat setDefault

                foreach vpi $vpiList {
                    foreach vci $vciList {
                        if {($mode == "add_atm_stats") || \
                                    ($mode == "add_atm_stats_rx")} {
                            atmReassembly setDefault
    
                            if {[info exists atm_reassembly_enable_iptcpudp_checksum]} {
                                atmReassembly config -enableIpTcpUdpChecksum \
                                        $atm_reassembly_enable_iptcpudp_checksum
                            }
    
                            if {[info exists atm_reassembly_enable_ip_qos]} {
                                atmReassembly config -enableQos \
                                        $atm_reassembly_enable_ip_qos
                            }
    
                            if {[info exists atm_reassembly_encapsulation]} {
                                array set atmEncapReass {
                                    vcc_mux_ipv4_routed         101
                                    vcc_mux_bridged_eth_fcs     102
                                    vcc_mux_bridged_eth_no_fcs  103
                                    vcc_mux_ipv6_routed         104
                                    vcc_mux_mpls_routed         105
                                    llc_routed_clip             106
                                    llc_bridged_eth_fcs         107
                                    llc_bridged_eth_no_fcs      108
                                    llc_pppoa                   109
                                    vcc_mux_ppoa                110
                                    llc_nlpid_routed            111
                                }
                                if {[info exists atmEncapReass($atm_reassembly_encapsulation)]} {
                                    atmReassembly config -encapsulation \
                                            $atmEncapReass($atm_reassembly_encapsulation)
                                }
                            }
                            
                            if {([port cget -receiveMode] == $::portPacketGroup) && \
                                        ($atmStatsConfig($port,encap) != "llc_routed_clip")} {
                                if {[atmReassembly add $ch $ca $po $vpi $vci]} {
                                    keylset return_val status $::FAILURE
                                    keylset return_val log "ERROR in $procName when: \
                                            atmReassembly add $ch $ca $po $vpi $vci. \
                                            $::ixErrorInfo"
                                    return $return_val
                                }
                            }
                        }
                        if {($mode == "add_atm_stats") || \
                                ($mode == "add_atm_stats_rx")} {
                            if {[atmStat addRx $ch $ca $po $vpi $vci]} {
                                keylset return_val status $::FAILURE
                                keylset return_val log "ERROR in $procName:\
                                        atmStat addRx $ch $ca $po $vpi $vci\
                                        failed.  $::ixErrorInfo"
                                return $return_val
                            }
                        }

                        if {($mode == "add_atm_stats") || \
                                ($mode == "add_atm_stats_tx")} {
                            if {[atmStat addTx $ch $ca $po $vpi $vci]} {
                                keylset return_val status $::FAILURE
                                keylset return_val log "ERROR in $procName:\
                                        atmStat addTx $ch $ca $po $vpi $vci\
                                        failed.  $::ixErrorInfo"
                                return $return_val
                            }
                        }
                    }
                }
            }
        }

        set retCode [::ixia::writePortListConfig]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }

        keylset returnList status $::SUCCESS
        return $returnList

    } else {

        # Collect the stats :
        set atmInd 0
        foreach port $port_list {
            scan $port "%d %d %d" ch ca po

            if {[port isActiveFeature $ch $ca $po portFeatureAtm]} {
                if {!$atmInd} {
                    set atmInd 1
                }
                if {[info exists atmStatsConfig($port,vpiType)]} {
                    set atm_counter_vpi_type $atmStatsConfig($port,vpiType)
                }
                if {[info exists atmStatsConfig($port,vciType)]} {
                    set atm_counter_vci_type $atmStatsConfig($port,vciType)
                }
                if {[info exists atmStatsConfig($port,vpi)]} {
                    set vpi $atmStatsConfig($port,vpi)
                }
                if {[info exists atmStatsConfig($port,vci)]} {
                    set vci $atmStatsConfig($port,vci)
                }
                if {[info exists atmStatsConfig($port,vpi_step)]} {
                    set vpi_step $atmStatsConfig($port,vpi_step)
                }
                if {[info exists atmStatsConfig($port,vci_step)]} {
                    set vci_step $atmStatsConfig($port,vci_step)
                }
                if {[info exists atmStatsConfig($port,vpi_count)]} {
                    set vpi_count $atmStatsConfig($port,vpi_count)
                }
                if {[info exists atmStatsConfig($port,vci_count)]} {
                    set vci_count $atmStatsConfig($port,vci_count)
                }
                if {[info exists \
                        atmStatsConfig($port,atm_counter_vpi_data_item_list)]} {
                    set atm_counter_vpi_data_item_list \
                            $atmStatsConfig($port,atm_counter_vpi_data_item_list)
                }
                if {[info exists \
                        atmStatsConfig($port,atm_counter_vci_data_item_list)]} {
                    set atm_counter_vci_data_item_list \
                            $atmStatsConfig($port,atm_counter_vci_data_item_list)
                }
                if {[info exists atmStatsConfig($port,atm_counter_vpi_mode)]} {
                    set atm_counter_vpi_mode \
                            $atmStatsConfig($port,atm_counter_vpi_mode)
                }
                if {[info exists atmStatsConfig($port,atm_counter_vci_mode)]} {
                    set atm_counter_vci_mode \
                            $atmStatsConfig($port,atm_counter_vci_mode)
                }
                if {![info exists atm_counter_vpi_type]} {
                    continue;
                }

                switch $atm_counter_vpi_type {
                    fixed {
                        set vpiList [list $vpi]
                    }
                    counter {
                        set vpiList {}
                        switch $atm_counter_vpi_mode {
                            incr {
                                set current $vpi
                                for {set i 1} {$i <= $vpi_count} {incr i} {
                                    lappend vpiList $current
                                    incr current $vpi_step
                                }
                            }
                            decr {
                                set current $vpi
                                for {set i 1} {$i <= $vpi_count} {incr i} {
                                    lappend vpiList $current
                                    incr current -$vpi_step
                                    if {$current < 0} {
                                        break
                                    }
                                }
                            }
                        }
                    }
                    table {
                        set vpiList $atm_counter_vpi_data_item_list
                    }
                }

                switch $atm_counter_vci_type {
                    fixed {
                        set vciList [list $vci]
                    }
                    counter {
                        set vciList {}
                        switch $atm_counter_vci_mode {
                            incr {
                                set current $vci
                                for {set i 1} {$i <= $vci_count} {incr i} {
                                    lappend vciList $current
                                    incr current $vci_step
                                }
                            }
                            decr {
                                set current $vci
                                for {set i 1} {$i <= $vci_count} {incr i} {
                                    lappend vciList $current
                                    incr current -$vci_step
                                    if {$current < 0} {
                                        break
                                    }
                                }
                            }
                        }
                    }
                    table {
                        set vciList $atm_counter_vci_data_item_list
                    }
                }

                atmStat setDefault

                if {[isUNIX]} {
                    if {![info exists ::ixTclSvrHandle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Not connected to TclServer."
                        return $returnList
                    }
                    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
                        #avoid using tcl server on IxNetwork side to avoid tcl server hangs
                        set retValueClicks [clock clicks]
                        set retValueSeconds [clock seconds]
                    } else {
                        set retValueClicks [clock clicks]
                        set retValueSeconds [clock seconds] 
                    }
                } else {
                    set retValueClicks [clock clicks]
                    set retValueSeconds [clock seconds]
                }
                set gotStats 1
                if {[atmStat get $ch $ca $po]} {
                    keylset return_val status $::FAILURE
                    keylset return_val log "ERROR in $procName when: \
                            atmStat get $ch $ca $po. $::ixErrorInfo"
                    return $return_val
                }

                foreach vpi $vpiList {
                    foreach vci $vciList {
                        if {[atmStat getStat $ch $ca $po $vpi $vci]} {
                            keylset return_val status $::FAILURE
                            keylset return_val log "ERROR in $procName when: \
                                    atmStat getStat $ch $ca $po $vpi $vci. \
                                    $::ixErrorInfo"
                            return $return_val
                        }
                        set rxKey $ch/$ca/$po.aggregate.rx.$vpi.$vci
                        set txKey $ch/$ca/$po.aggregate.tx.$vpi.$vci
                        
                        set [subst $keyed_array_name]($rxKey.rx_aal5_crc_errors_count) [atmStat cget -rxAal5CrcErrors]
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($rxKey.rx_aal5_frames_count) [atmStat cget -rxAal5Frames]
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($rxKey.rx_aal5_length_errors_count) [atmStat cget -rxAal5LengthErrors]
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($rxKey.rx_aal5_timeout_errors_count) [atmStat cget -rxAal5TimeoutErrors]
                        incr keyed_array_index
                        

                        set [subst $keyed_array_name]($rxKey.rx_atm_cells_count) [atmStat cget -rxAtmCells]
                        incr keyed_array_index

                        set [subst $keyed_array_name]($txKey.tx_aal5_bytes_count) [atmStat cget -txAal5Bytes]
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($txKey.tx_aal5_frames_count) [atmStat cget -txAal5Frames]
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($txKey.tx_aal5_scheduled_cells_count) [atmStat cget -txScheduledCells]
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($txKey.tx_aal5_scheduled_frames_count) [atmStat cget -txScheduledFrames]
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($txKey.tx_atm_cells_count) [atmStat cget -txAtmCells]
                        incr keyed_array_index

                        if {[atmStat getRate $ch $ca $po $vpi $vci]} {
                            keylset return_val status $::FAILURE
                            keylset return_val log "ERROR in $procName when: \
                                    atmStat getRate $ch $ca $po $vpi $vci. \
                                    $::ixErrorInfo"
                            return $return_val
                        }
                        

                        set [subst $keyed_array_name]($rxKey.rx_aal5_crc_errors_rate) [atmStat cget -rxAal5CrcErrors]
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($rxKey.rx_aal5_frames_rate) [atmStat cget -rxAal5Frames]
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($rxKey.rx_aal5_length_errors_rate) [atmStat cget -rxAal5LengthErrors]
                        incr keyed_array_index

                        set [subst $keyed_array_name]($rxKey.rx_aal5_timeout_errors_rate) [atmStat cget -rxAal5TimeoutErrors]
                        incr keyed_array_index

                        set [subst $keyed_array_name]($rxKey.rx_atm_cells_rate) [atmStat cget -rxAtmCells]
                        incr keyed_array_index

                        set [subst $keyed_array_name]($txKey.tx_aal5_bytes_rate) [atmStat cget -txAal5Bytes]
                        incr keyed_array_index

                        set [subst $keyed_array_name]($txKey.tx_aal5_frames_rate) [atmStat cget -txAal5Frames]
                        incr keyed_array_index

                        set [subst $keyed_array_name]($txKey.tx_aal5_scheduled_cells_rate) [atmStat cget -txScheduledCells]
                        incr keyed_array_index

                        set [subst $keyed_array_name]($txKey.tx_aal5_scheduled_frames_rate) [atmStat cget -txScheduledFrames]
                        incr keyed_array_index

                        set [subst $keyed_array_name]($txKey.tx_atm_cells_rate) [atmStat cget -txAtmCells]
                        incr keyed_array_index
                    }
                }
            }
        }
    }
    # End ATM

    if {![info exists mode]} {
        set mode aggregate
    }
    if {[info exists stream]} {
        set streams_argument $stream
    } elseif {[info exists streams]} {
        set streams_argument $streams
    }

    ########################################################
    #  Get elapsed time                                    #
    ########################################################
    # add ports to get stats on
    statGroup setDefault
    foreach port $port_list {
        scan $port "%d %d %d" c l p
        set retCode [statGroup add $c $l $p]
    }

    # get the stats
    if {$gotStats == 0} {
        if {[isUNIX]} {
            if {![info exists ::ixTclSvrHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Not connected to TclServer."
                return $returnList
            }
            if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
                #avoid using tcl server on IxNetwork side to avoid tcl server hangs
                set retValueClicks [clock clicks]
                set retValueSeconds [clock seconds]
            } else {
                set retValueClicks [clock clicks]
                set retValueSeconds [clock seconds]
            }
        } else {
            set retValueClicks [clock clicks]
            set retValueSeconds [clock seconds]
        }
    }
    set [subst $keyed_array_name](clicks) [format "%u" $retValueClicks]
    incr keyed_array_index
    set [subst $keyed_array_name](seconds) [format "%u" $retValueSeconds]
    incr keyed_array_index
    
    if {[statGroup get]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Could not get the statGroup"
        return $returnList
    }

    ########################################################
    #  PGID  STATS                                         #
    ########################################################
    if {[info exists packet_group_id]} {
        set packet_group_id_start 4294967295
        set packet_group_id_end   0
        set packet_group_id_list  ""
        foreach packet_group_id_elem $packet_group_id {
            set temp_packet_group_id [split $packet_group_id_elem "-"]
            if {[llength $temp_packet_group_id] > 1} {
                if {[lindex $temp_packet_group_id 0] <= [lindex $temp_packet_group_id 1]} {
                    if {[lindex $temp_packet_group_id 0] < $packet_group_id_start} {
                        set packet_group_id_start [lindex $temp_packet_group_id 0]
                    }
                    if {[lindex $temp_packet_group_id 1] > $packet_group_id_end} {
                        set packet_group_id_end   [lindex $temp_packet_group_id 1]
                    }
                } else  {
                    if {[lindex $temp_packet_group_id 1] < $packet_group_id_start} {
                        set packet_group_id_start [lindex $temp_packet_group_id 1]
                    }
                    if {[lindex $temp_packet_group_id 0] > $packet_group_id_end} {
                        set packet_group_id_end   [lindex $temp_packet_group_id 0]
                    }
                }
            } else  {
                set packet_group_id_start    0
                set packet_group_id_end      $packet_group_id_elem
                if {[llength $packet_group_id] > 1} {
                    # If the packet_group_id parameter contains more then one element
                    # collect stats for each pgid in the list.
                    # If the packet_group_id parameter contains only one parameter
                    # collect stats from the 0-$packet_group_id range
                    lappend packet_group_id_list $packet_group_id_elem
                }
            }
        }
        if {$packet_group_id_list == ""} {
            for {set k $packet_group_id_start} {$k <= $packet_group_id_end} {incr k} {
                lappend packet_group_id_list $k
            }
        }
        set ports_pgid_stop ""
        set ports_still_transmitting ""
        foreach port $reserved_port_list {
            scan $port "%d %d %d" c l p
            if {[stat getTransmitState $c $l $p] == 0} {
                lappend ports_pgid_stop $port
            } else {
                lappend ports_still_transmitting $port
            }
        }
        if {[llength $ports_pgid_stop] ==  [llength $reserved_port_list]} {
            set start_time [clock clicks -milliseconds]
            if {[ixStopPacketGroups port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to stop collecting\
                        metrics for ports $port_list."
                return $returnList
            }
            debug "ixStopPacketGroups $port_list took [mpexpr [clock clicks -milliseconds] - $start_time]"
        } else {
            ixPuts "WARNING: Ports $ports_still_transmitting have not stopped transmitting. The PGID stats\
                    retrieval may be slow."
        }
        foreach port $port_list {
            scan $port "%d %d %d" c l p
            set start_time [clock clicks -milliseconds]
            if {[packetGroupStats get $c $l $p \
                        $packet_group_id_start \
                        $packet_group_id_end] != $::TCL_OK} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not get the\
                        PGID Stats for range: $packet_group_id_start -\
                        $packet_group_id_end on port: $c $l $p"
                return $returnList
            }
            debug "packetGroupStats get $c $l $p $packet_group_id_start $packet_group_id_end \
                    took [mpexpr [clock clicks -milliseconds] - $start_time]"
            # Sleeping for 1 second to get the correct rate
            ixia_sleep 1000

            # We make this call a 2nd time to get the actual bit rate
            if {[llength $ports_pgid_stop] !=  [llength $reserved_port_list]} {
                set start_time [clock clicks -milliseconds]
                if {[packetGroupStats get $c $l $p \
                        $packet_group_id_start     \
                        $packet_group_id_end] != $::TCL_OK} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Could not get the\
                            PGID Stats for range: $packet_group_id_start -\
                            $packet_group_id_end on port: $c $l $p"
                    return $returnList
                }
                debug "packetGroupStats get $c $l $p 0 $packet_group_id_end \
                        took [mpexpr [clock clicks -milliseconds] - $start_time]"
            }
            # Find out if latency bins are used on this
            set start_time [clock clicks -milliseconds]
            if {![packetGroup getRx $c $l $p]} {
                set latBinsCatch [catch {packetGroup cget \
                        -enableLatencyBins} latBins]
                set latBinsTypeCatch [catch {packetGroup cget \
                        -latencyControl} latBinsType]
                if {$latBinsCatch} {
                    #
                } elseif {$latBins == 0}  {
                    #
                } elseif {$latBinsTypeCatch}  {
                    set statBins latency_bin
                } elseif {(![info exists ::interArrivalJitter]) || \
                        ([info exists ::interArrivalJitter] && \
                        ($latBinsType != $::interArrivalJitter)) }  {
                    set statBins latency_bin
                } else  {
                    set statBins jitter_bin
                }
            }
            debug "packetGroup getRx $c $l $p took [mpexpr [clock clicks -milliseconds] - $start_time]"
            
            foreach pkt_gp_ctr $packet_group_id_list {
                # If there were no stats for a given group, we will just skip
                # setting any values for that value
                set start_time [clock clicks -milliseconds]
                set getPgid [expr $pkt_gp_ctr - $packet_group_id_start]
                set retPgid $pkt_gp_ctr
                if {[packetGroupStats getGroup $getPgid] == $::TCL_OK} {
                    # If latency bins were used, include those stats
                    if {[info exists statBins]} {
                        set numLatencyBins [packetGroupStats cget \
                                -numLatencyBins]
                        for {set thisBin 0} {$thisBin < $numLatencyBins} \
                                {incr thisBin} {

                            set validLatBinStats 1
                            if {$thisBin == 0} {
                                if {[packetGroupStats getFirstLatencyBin]} {
                                    set validLatBinStats 0
                                }
                            } else {
                                if {[packetGroupStats getNextLatencyBin]} {
                                    set validLatBinStats 0
                                }
                            }

                            if {[packetGroupStats getLatencyBin $thisBin]} {
                                set validLatBinStats 0
                            }
                            if {$validLatBinStats} {
                                # We are looping from 0 to number of bins minus
                                # 1.  Output to the user should start and 1, so
                                # always increment for the value to print out
                                set binNum [expr $thisBin + 1]
                                set key_pgid $c/$l/$p.pgid.$retPgid.rx.$statBins.$binNum
                                
                                set [subst $keyed_array_name]($key_pgid.pkt_bit_rate) [latencyBin cget -bitRate]
                                incr keyed_array_index
                                
                                set [subst $keyed_array_name]($key_pgid.pkt_byte_rate) [latencyBin cget -byteRate]
                                incr keyed_array_index

                                set [subst $keyed_array_name]($key_pgid.pkt_frame_rate) [latencyBin cget -frameRate]
                                incr keyed_array_index

                                set [subst $keyed_array_name]($key_pgid.first_tstamp) [latencyBin cget -firstTimeStamp]
                                incr keyed_array_index

                                set [subst $keyed_array_name]($key_pgid.last_tstamp) [latencyBin cget -lastTimeStamp]
                                incr keyed_array_index

                                set [subst $keyed_array_name]($key_pgid.max) [latencyBin cget -maxLatency]
                                incr keyed_array_index

                                set [subst $keyed_array_name]($key_pgid.min) [latencyBin cget -minLatency]
                                incr keyed_array_index

                                set [subst $keyed_array_name]($key_pgid.total_pkts) [latencyBin cget -numFrames]
                                incr keyed_array_index

                                set [subst $keyed_array_name]($key_pgid.start_time) [latencyBin cget -startTime]
                                incr keyed_array_index

                                set [subst $keyed_array_name]($key_pgid.stop_time) [latencyBin cget -stopTime]
                                incr keyed_array_index
                            }
                        }
                    }
                    if {[catch {packetGroupStats cget -firstTimeStamp} _firstTimeStamp]} {
                        set _firstTimeStamp 0
                    }
                    
                    set key_pgid $c/$l/$p.pgid.$retPgid
                    set key_rx_pgid $c/$l/$p.pgid.rx
                    
                    set [subst $keyed_array_name]($key_pgid.first_timestamp) $_firstTimeStamp
                    incr keyed_array_index

                    if {[catch {packetGroupStats cget -lastTimeStamp} _lastTimeStamp]} {
                        set _lastTimeStamp 0
                    }
                    set [subst $keyed_array_name]($key_pgid.last_timestamp) $_lastTimeStamp
                    incr keyed_array_index

                    if {[catch {packetGroupStats cget -totalFrames} _pgStat]} {
                        set _pgStat 0
                    }
                    set [subst $keyed_array_name]($key_rx_pgid.pkt_count.${retPgid}) $_pgStat
                    incr keyed_array_index
                    
                    if {[catch {packetGroupStats cget -bitRate} _pgStat]} {
                        set _pgStat 0
                    }
                    set [subst $keyed_array_name]($key_rx_pgid.bit_rate.${retPgid}) $_pgStat
                    incr keyed_array_index
                                        
                    if {[catch {packetGroupStats cget -frameRate} _pgStat]} {
                        set _pgStat 0
                    }
                    set [subst $keyed_array_name]($key_rx_pgid.frame_rate.${retPgid}) $_pgStat
                    incr keyed_array_index
                    
                    if {[catch {packetGroupStats cget -maxLatency} _pgStat]} {
                        set _pgStat 0
                    }
                    set [subst $keyed_array_name]($key_rx_pgid.max_latency.${retPgid}) $_pgStat
                    incr keyed_array_index
                    
                    if {[catch {packetGroupStats cget -minLatency} _pgStat]} {
                        set _pgStat 0
                    }
                    set [subst $keyed_array_name]($key_rx_pgid.min_latency.${retPgid}) $_pgStat
                    incr keyed_array_index
                    
                    if {[catch {packetGroupStats cget -averageLatency} _pgStat]} {
                        set _pgStat 0
                    }
                    set [subst $keyed_array_name]($key_rx_pgid.avg_latency.${retPgid}) $_pgStat
                    incr keyed_array_index

                } else {
                    set key_pgid    $c/$l/$p.pgid.${retPgid}
                    set key_rx_pgid $c/$l/$p.pgid.rx
                    
                    set [subst $keyed_array_name]($key_rx_pgid.pkt_count.${retPgid}) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($key_rx_pgid.bit_rate.${retPgid}) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($key_rx_pgid.min_latency.${retPgid}) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($key_rx_pgid.max_latency.${retPgid}) 0
                    incr keyed_array_index
        
                    set [subst $keyed_array_name]($key_rx_pgid.avg_latency.${retPgid}) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($key_rx_pgid.frame_rate.${retPgid}) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($key_pgid.first_timestamp) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($key_pgid.last_timestamp) 0
                    incr keyed_array_index
                }
                debug "packetGroupStats getGroup $getPgid took [mpexpr [clock clicks -milliseconds] - $start_time]"
            }
            
        }
    }

    ########################################################
    #  STREAM - GET STATS  - COUNT and RATE                #
    ########################################################
    if {($mode == "stream") || ($mode == "streams") || ($mode == "all")} {

        set ports_pgid_stop ""
        set ports_still_transmitting ""
        foreach port $reserved_port_list {
            scan $port "%d %d %d" c l p
            if {[stat getTransmitState $c $l $p] == 0} {
                lappend ports_pgid_stop $port
            } else {
                lappend ports_still_transmitting $port
            }
        }
        if {[llength $ports_pgid_stop] ==  [llength $reserved_port_list]} {
            set start_time [clock clicks -milliseconds]
            if {[ixStopPacketGroups port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to stop collecting\
                        metrics for ports $port_list."
                return $returnList
            }
            debug "ixStopPacketGroups $port_list took [mpexpr [clock clicks -milliseconds] - $start_time]"
        } else {
            ixPuts "WARNING: Ports $ports_still_transmitting have not stopped transmitting. The per stream stats\
                     retrieval may be slow."
        }
        foreach port $port_list {
            scan $port "%d %d %d" c l p

            # Check if user input the stream number
            if {![info exists streams_argument]} {
                set from_group 1
                if {[catch {package present IxTclHal} versionIxTclHal] || \
                        ($versionIxTclHal < 4.00)} {
                    set to_group   5000
                } else  {
                    set to_group   57344
                }

                set tx_streams_argument_list [::ixia::getHltStreamIds $c/$l/$p]
                set rx_streams_argument_list [array names ::ixia::pgid_to_stream]
                set pos [lsearch $rx_streams_argument_list -1]
                set rx_streams_argument_list [lreplace \
                        $rx_streams_argument_list $pos $pos]

            } else {
                set from_group [lindex [lsort -dictionary \
                        $streams_argument] 0]
                set to_group   [lindex [lsort -dictionary \
                        $streams_argument] end]

                set tx_streams_argument_list $streams_argument
                set rx_streams_argument_list $streams_argument
            }

            # START RETRIEVING RX STATS
            debug  "packetGroupStats get $c $l $p 0 $to_group"
            if {[packetGroupStats get $c $l $p 0 $to_group] != $::TCL_OK} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not get the\
                        stream stats on port: $c $l $p"
                return $returnList
            }

            # Note that we are intermingling the rx and tx stats to utilize
            # only one wait time to get the rates.  This variable will be set
            # to tell if we hit the wait for the tx code.
            set alreadySlept 0

            # RETRIEVE TRANSMIT STATS FROM PORT
            set stream_ids_on_port [::ixia::getIxiaStreamIds $c/$l/$p]
            if {([llength $stream_ids_on_port] > 0) && \
                    [port isActiveFeature $c $l $p portFeaturePerStreamTxStats]} {

                set from_id [lindex [lsort -dictionary $stream_ids_on_port] 0]
                set to_id   [lindex [lsort -dictionary $stream_ids_on_port] end]

                if {[streamTransmitStats get $c $l $p 1 $to_id] \
                        != $::TCL_OK} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            streamTransmitStats get $c $l $p 1 $to_id B"
                    return $returnList
                }

                # Sleeping for a little less than 1 second to get the
                # correct rate
                ixia_sleep 700
                set alreadySlept 1

                # We make this call a 2nd time to get the actual bit rate
                if {[streamTransmitStats get $c $l $p 1 $to_id] \
                        != $::TCL_OK} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            streamTransmitStats get $c $l $p 1 $to_id A"
                    return $returnList
                }

                foreach {hlt_str_id} $tx_streams_argument_list {
                    if {![info exists ::ixia::pgid_to_stream($hlt_str_id)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: The input\
                                stream id of $hlt_str_id does not exist. \
                                Statistics cannot be retrieved."
                        return $returnList
                    }

                    foreach {ch_num c_num p_num str_id} \
                            [split $::ixia::pgid_to_stream($hlt_str_id) ,] {}

                    set keyNameTx $c/$l/$p.stream.$hlt_str_id.tx
                    if {("${c}${l}${p}" == "${ch_num}${c_num}${p_num}") && \
                            ([streamTransmitStats getGroup $str_id] == 0)} {

                        set [subst $keyed_array_name]($keyNameTx.total_pkts) [streamTransmitStats cget -framesSent]
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameTx.total_pkt_rate) [streamTransmitStats cget -frameRate]
                        incr keyed_array_index

                        # GET ELAPSED TIME
                        if {[statList get $c $l $p] != 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Could not get all stats for port: \
                                    $c $l $p - statList get $c $l $p"
                            return $returnList
                        }

                        if {[catch {statList cget -transmitDuration} elapsed_time]} {
                            keylset returnList log "ERROR in $procName:\
                                    transmitDuration not supported on port:\
                                    $c $l $p"
                            set elapsed_time 0
                        }

                        set elapsed_time [string map {" " ""} [format %100.2f \
                                [mpexpr $elapsed_time/double(1000000000)]]]

                        set [subst $keyed_array_name]($keyNameTx.elapsed_time) $elapsed_time
                        incr keyed_array_index
                        
                    } else {
                        set [subst $keyed_array_name]($keyNameTx.total_pkts) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameTx.total_pkt_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameTx.elapsed_time) 0
                        incr keyed_array_index
                    }

                    set keyNameRx $c/$l/$p.stream.$hlt_str_id.rx
                    if {[catch {set [subst $keyed_array_name]($keyNameRx.total_pkts)}]} {
                        set [subst $keyed_array_name]($keyNameRx.total_pkts) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_bit_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_bytes) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkts_bytes) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.min_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.max_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.avg_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.line_rate_percentage) 0
                        incr keyed_array_index
                    }
                }
            } else  {
                foreach {hlt_str_id} $tx_streams_argument_list {
                    set keyNameTx $c/$l/$p.stream.$hlt_str_id.tx
                    
                    set [subst $keyed_array_name]($keyNameTx.total_pkts) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($keyNameTx.total_pkt_rate) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($keyNameTx.elapsed_time) 0
                    incr keyed_array_index

                    set keyNameRx $c/$l/$p.stream.$hlt_str_id.rx
                    if {[catch {set [subst $keyed_array_name]($keyNameRx.total_pkts)}]} {
                        set [subst $keyed_array_name]($keyNameRx.total_pkts) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_bit_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_bytes) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkts_bytes) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.min_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.max_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.avg_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.line_rate_percentage) 0
                        incr keyed_array_index
                    }
                }
            }

            if {!$alreadySlept} {
                # Sleep for a little less than 1 second to get the correct rate.
                # Might have slept above in the tx piece, so do not want to
                # sleep twice.
                ixia_sleep 700
            }

            # We make this call a 2nd time to get the actual bit rate
            if {[packetGroupStats get $c $l $p 0 $to_group] \
                    != $::TCL_OK} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not get the\
                        stream stats on port: $c $l $p"
                return $returnList
            }

            # Find out if latency bins are used on this
            if {![packetGroup getRx $c $l $p]} {
                set latBinsCatch [catch {packetGroup cget \
                        -enableLatencyBins} latBins]
                set latBinsTypeCatch [catch {packetGroup cget \
                        -latencyControl} latBinsType]

                if {$latBinsCatch} {
                    #
                } elseif {$latBins == 0}  {
                    #
                } elseif {$latBinsTypeCatch}  {
                    set statBins latency_bin
                } elseif {(![info exists ::interArrivalJitter]) || \
                        ([info exists ::interArrivalJitter] && \
                        ($latBinsType != $::interArrivalJitter)) }  {
                    set statBins latency_bin
                } else  {
                    set statBins jitter_bin
                }
            }

            # How many groups did we get
            if {[packetGroupStats cget -numGroups] > 1} {
                ####  Bug: the -numGroups in packetGroupStats are incorrect, but
                ####  does not affect the script other than making it go thru
                ####  the for loop few more times.
                set to_group [expr $from_group + \
                        [packetGroupStats cget -numGroups] - 1]
            } else {
                set to_group $from_group
            }

            set rx_streams_argument_list [lsort -dictionary \
                    $rx_streams_argument_list]

            foreach {current_stream} $rx_streams_argument_list {
                if {$current_stream > $to_group} {
                    if {[info exists streams_argument]} {
                        set keyNameRx $c/$l/$p.stream.$current_stream.rx
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkts) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_bit_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_bytes) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkts_bytes) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.min_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.max_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.avg_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.line_rate_percentage) 0
                        incr keyed_array_index
                        

                        set keyNameTx $c/$l/$p.stream.$current_stream.tx
                        
                        if {[catch {set [subst $keyed_array_name]($keyNameTx.total_pkts)}]} {
                            set [subst $keyed_array_name]($keyNameTx.total_pkts) 0
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameTx.total_pkt_rate) 0
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameTx.elapsed_time) 0
                            incr keyed_array_index
                        }
                        continue;
                    } else  {
                        break;
                    }
                }
                if {[packetGroupStats getGroup $current_stream]} {
                    if {[info exists streams_argument]} {
                        set keyNameRx $c/$l/$p.stream.$current_stream.rx
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkts) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_bit_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_bytes) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkts_bytes) 0
                        incr keyed_array_index
                                                
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.min_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.max_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.avg_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.line_rate_percentage) 0
                        incr keyed_array_index

                        set keyNameTx $c/$l/$p.stream.$current_stream.tx
                        if {[catch {set [subst $keyed_array_name]($keyNameTx.total_pkts)}]} {
                            set [subst $keyed_array_name]($keyNameTx.total_pkts) 0
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameTx.total_pkt_rate) 0
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameTx.elapsed_time) 0
                            incr keyed_array_index
                        }
                    }
                    continue;
                }
                if {[packetGroupStats getGroupFrameCount $current_stream] <= 0} {
                    if {[info exists streams_argument]} {
                        set keyNameRx $c/$l/$p.stream.$current_stream.rx
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkts) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_bit_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_bytes) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkts_bytes) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_rate) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.min_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.max_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.avg_delay) 0
                        incr keyed_array_index
                        
                        set [subst $keyed_array_name]($keyNameRx.line_rate_percentage) 0
                        incr keyed_array_index

                        set keyNameTx $c/$l/$p.stream.$current_stream.tx
                        if {[catch {set [subst $keyed_array_name]($keyNameTx.total_pkts)}]} {
                            set [subst $keyed_array_name]($keyNameTx.total_pkts) 0
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameTx.total_pkt_rate) 0
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameTx.elapsed_time) 0
                            incr keyed_array_index
                        }
                    }
                    continue;
                }

                # If latency bins were used, include those stats
                if {[info exists statBins]} {
                    set numLatencyBins [packetGroupStats cget \
                            -numLatencyBins]

                    for {set thisBin 0} {$thisBin < $numLatencyBins} \
                            {incr thisBin} {
                        set validLatBinStats 1
                        if {$thisBin == 0} {
                            if {[packetGroupStats getFirstLatencyBin]} {
                                set validLatBinStats 0
                            }
                        } else {
                            if {[packetGroupStats getNextLatencyBin]} {
                                set validLatBinStats 0
                            }
                        }

                        if {[packetGroupStats getLatencyBin $thisBin]} {
                            set validLatBinStats 0
                        }
                        if {$validLatBinStats} {
                            # We are looping from 0 to number of bins minus
                            # 1.  Output to the user should start and 1, so
                            # always increment for the value to print out
                            set binNum [expr $thisBin + 1]
                            set    keyNameBin $c/$l/$p.stream.$current_stream.
                            append keyNameBin rx.$statBins.$binNum
                            
                            set [subst $keyed_array_name]($keyNameBin.pkt_bit_rate) [latencyBin cget -bitRate]
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameBin.pkt_byte_rate) [latencyBin cget -byteRate]
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameBin.pkt_frame_rate) [latencyBin cget -frameRate]
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameBin.first_tstamp) [latencyBin cget -firstTimeStamp]
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameBin.last_tstamp) [latencyBin cget -lastTimeStamp]
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameBin.max) [latencyBin cget -maxLatency]
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameBin.min) [latencyBin cget -minLatency]
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameBin.total_pkts) [latencyBin cget -numFrames]
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameBin.start_time) [latencyBin cget -startTime]
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($keyNameBin.stop_time) [latencyBin cget -stopTime]
                            incr keyed_array_index
                        }
                    }
                }
                set keyNameRx $c/$l/$p.stream.$current_stream.rx
                
                set [subst $keyed_array_name]($keyNameRx.total_pkts) [packetGroupStats cget -totalFrames]
                incr keyed_array_index
                
                if {[catch {packetGroupStats cget -bitRate} _bitRate]} {
                    set _bitRate 0
                }
                set [subst $keyed_array_name]($keyNameRx.total_pkt_bit_rate) $_bitRate
                incr keyed_array_index
                
                set _noOp 0
                if {[catch {packetGroupStats cget -totalByteCount} _tbCount]} {
                    set _tbCount 0
                    set _noOp 1
                }
                set [subst $keyed_array_name]($keyNameRx.total_pkt_bytes) $_tbCount
                incr keyed_array_index
                set [subst $keyed_array_name]($keyNameRx.total_pkts_bytes) $_tbCount
                incr keyed_array_index
                
                
                if {[catch {packetGroupStats cget -minLatency} _pgStat]} {
                    set _pgStat 0
                }
                set [subst $keyed_array_name]($keyNameRx.min_delay) $_pgStat
                incr keyed_array_index
                
                if {[catch {packetGroupStats cget -maxLatency} _pgStat]} {
                    set _pgStat 0
                }
                set [subst $keyed_array_name]($keyNameRx.max_delay) $_pgStat
                incr keyed_array_index
                
                if {[catch {packetGroupStats cget -averageLatency} _pgStat]} {
                    set _pgStat 0
                }
                set [subst $keyed_array_name]($keyNameRx.avg_delay) $_pgStat
                incr keyed_array_index

                if {$_noOp == 1} {
                    set [subst $keyed_array_name]($keyNameRx.total_pkt_rate) 0
                    incr keyed_array_index

                } else  {
                    if {[packetGroupStats cget -totalByteCount] > 0} {
                        
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_rate) [mpexpr \
                                [packetGroupStats cget -bitRate] * \
                                [packetGroupStats cget -totalFrames] / 8 / \
                                [packetGroupStats cget -totalByteCount]]
                        incr keyed_array_index
                    } else  {
                        set [subst $keyed_array_name]($keyNameRx.total_pkt_rate) 0
                        incr keyed_array_index
                    }
                }

                # GET LINE SPEED
                if {[statList get $c $l $p] != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            Could not get all stats for port: \
                            $c $l $p - statList get $c $l $p"
                    return $returnList
                }

                if {$_noOp == 1} {
                    set [subst $keyed_array_name]($keyNameRx.line_rate_percentage) 0
                    incr keyed_array_index
                } else  {                    
                    set [subst $keyed_array_name]($keyNameRx.line_rate_percentage) [expr \
                            double([packetGroupStats cget -bitRate])/      \
                            [expr double([statList cget -lineSpeed]) * double(1000000)] * 100]
                    incr keyed_array_index
                }

                set keyNameTx $c/$l/$p.stream.$current_stream.tx
                if {[catch {set [subst $keyed_array_name]($keyNameTx.total_pkts)}]} {
                    set [subst $keyed_array_name]($keyNameTx.total_pkts) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($keyNameTx.total_pkt_rate) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($keyNameTx.elapsed_time) 0
                    incr keyed_array_index
                }
            }
        }
        if {$mode != "all"} {
            if {[info exists returnList]} {
                foreach key1 [keylkeys returnList] {
                    catch {unset c}
                    catch {unset l}
                    catch {unset p}
                    if {[regexp {^([0-9]+)/([0-9]+)/([0-9]+)} $key1 key1_match c l p] && \
                            [info exists c] && [info exists l] && [info exists p]} {
                        incr keyed_array_index
                    }
                    set [subst $keyed_array_name](${key1}) [keylget returnList $key1]
                }
            }
            switch -- $return_method {
                "keyed_list" {
                    set [subst $keyed_array_name](status) $::SUCCESS
                    set retTemp [array get $keyed_array_name]
                    eval "keylset returnList $retTemp"
                    # Unset the current array
                    ::ixia::cleanupTrafficStatsArrays $keyed_array_name
                    return $returnList
                }
                "keyed_list_or_array" {
                    if {$keyed_array_index < $traffic_stats_max_list_length} {
                        set [subst $keyed_array_name](status) $::SUCCESS
                        set retTemp [array get $keyed_array_name]
                        eval "keylset returnList $retTemp"
                        # Unset the current array
                        ::ixia::cleanupTrafficStatsArrays $keyed_array_name
                        return $returnList
                    } else {
                        keylset returnList status $::SUCCESS
                        keylset returnList handle ::ixia::[subst $keyed_array_name]
                        return $returnList
                    }
                }
                "array" {
                    keylset returnList status $::SUCCESS
                    keylset returnList handle ::ixia::[subst $keyed_array_name]
                    return $returnList
                }
            }
        }
    }

    ########################################################
    #  AGGREGATE - GET STATS  - COUNT and RATE             #
    ########################################################
    if {$mode == "aggregate" || $mode == "all"} {
        # Check if USER wants QoS or not
        if {![info exists qos_stats]} {
            set real_traffic_stats_count_option_list \
                    $traffic_stats_count_option_list
            set real_traffic_stats_rate_option_list \
                    $traffic_stats_rate_option_list
            set real_ixia_traffic_stats_option_list \
                    $ixia_traffic_stats_option_list
        } else {
            set real_traffic_stats_count_option_list \
                    $traffic_stats_count_qos_option_list
            set real_traffic_stats_rate_option_list \
                    $traffic_stats_rate_qos_option_list
            set real_ixia_traffic_stats_option_list \
                    $ixia_traffic_stats_qos_option_list
        }

        # Get all of the count type statistics
        foreach port $port_list {
            scan $port "%d %d %d" c l p

            # Get COUNT Stats
            if {[statList get $c $l $p]} {
                continue
            }

            # At this point for ATM we need to get different stats
            # for framesSent and framesReceived
            set new_real_ixia_traffic_stats_option_list \
                    $real_ixia_traffic_stats_option_list
            if { [port isActiveFeature $c $l $p portFeatureAtm] } {
                atmPort get $c $l $p
                if { [atmPort cget -packetDecodeMode] == $::atmDecodeFrame } {
                    regsub framesSent $new_real_ixia_traffic_stats_option_list \
                            atmAal5FramesSent \
                            new_real_ixia_traffic_stats_option_list
                    regsub framesReceived \
                            $new_real_ixia_traffic_stats_option_list \
                            atmAal5FramesReceived \
                            new_real_ixia_traffic_stats_option_list
                } else {
                    regsub framesSent $new_real_ixia_traffic_stats_option_list \
                            atmAal5CellsSent \
                            new_real_ixia_traffic_stats_option_list
                    regsub framesReceived \
                            $new_real_ixia_traffic_stats_option_list \
                            atmAal5CellsReceived \
                            new_real_ixia_traffic_stats_option_list
                }
            }

            set stat_index 0

            foreach count_stat $real_traffic_stats_count_option_list {
                set ixia_stat_option \
                        [lindex $new_real_ixia_traffic_stats_option_list \
                        $stat_index]
                if [catch {statList cget -$ixia_stat_option} val] {
                    set [subst $keyed_array_name]($c/$l/$p.$count_stat) "Stat $ixia_stat_option not supported"
                    incr keyed_array_index
                    
                } else {
                    if {$count_stat == "aggregate.tx.pkt_count"} {
                        set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.raw_pkt_count) $val
                        incr keyed_array_index
                    
                        if {[catch {set val [expr $val - [statList cget -protocolServerTx]]}]} {
                            set val 0
                        }
                        if {$val < 0} {
                            set val 0
                        }
                        set [subst $keyed_array_name]($c/$l/$p.$count_stat) $val
                        incr keyed_array_index
                    } elseif {$count_stat == "aggregate.rx.pkt_count"} {
                        set [subst $keyed_array_name]($c/$l/$p.aggregate.rx.raw_pkt_count) $val
                        incr keyed_array_index
                        
                        if {[catch {set val [expr $val - [statList cget -protocolServerRx]]}]} {
                            set val 0
                        }
                        if {$val < 0} {
                            set val 0
                        }
                        set [subst $keyed_array_name]($c/$l/$p.$count_stat) $val
                        incr keyed_array_index
                    } elseif {$count_stat == "elapsed_time"} {
                        set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.$count_stat) [string \
                                map {" " ""} [format %100.2f \
                                [mpexpr $val/double(1000000000)]]]
                        incr keyed_array_index
                    } else {
                        set [subst $keyed_array_name]($c/$l/$p.$count_stat) $val
                        incr keyed_array_index
                    }
                }
                incr stat_index
            }
            
            # Retrieve transmit count stats from port
            set stream_ids_on_port [::ixia::getIxiaStreamIds $c/$l/$p]
            if {[llength $stream_ids_on_port] > 0} {
                set from_id [lindex [lsort -dictionary $stream_ids_on_port] 0]
                set to_id   [lindex [lsort -dictionary $stream_ids_on_port] end]

                if {[port isActiveFeature $c $l $p portFeaturePerStreamTxStats]} {
                    if {[streamTransmitStats get $c $l $p 1 $to_id] \
                                != $::TCL_OK} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to\
                                streamTransmitStats get $c $l $p 1 $to_id B"
                        return $returnList
                    }

                    # How many groups did we get
                    if {[streamTransmitStats cget -numGroups] > 1} {
                        set to_id [expr $from_id + \
                                [streamTransmitStats cget -numGroups] - 1]
                    } else {
                        set to_id $from_id
                    }

                    set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkts) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkt_bytes) 0
                    incr keyed_array_index
                    
                    set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkts_bytes) 0
                    incr keyed_array_index
                    
                    for {set str_id $from_id} {$str_id <= $to_id} {incr str_id} {
                        if {[streamTransmitStats getGroup $str_id] == 0} {
                            set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkts) [expr \
                                    [set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkts)] + \
                                    [streamTransmitStats cget -framesSent] ]
                            incr keyed_array_index
                        }
                    }
                }
            } else {
                set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkts)      0
                incr keyed_array_index
                
                set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkt_bytes) 0
                incr keyed_array_index
                
                set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkts_bytes) 0
                incr keyed_array_index
            }
        }

        if {!$ignore_rate} {
            foreach port $port_list {
                scan $port "%d %d %d" c l p

                # Get RATE Stats
                if {[statList getRate $c $l $p]} {
                    continue
                }

                set stat_index 0

                foreach rate_stat $real_traffic_stats_rate_option_list {
                    set ixia_stat_option \
                            [lindex $new_real_ixia_traffic_stats_option_list \
                            $stat_index]

                    if {[catch {statList cget -$ixia_stat_option } val]} {
                        set [subst $keyed_array_name]($c/$l/$p.$rate_stat) "Stat $ixia_stat_option not supported"
                        incr keyed_array_index
                    } else {
                        if {$rate_stat == "aggregate.tx.pkt_rate"} {
                            set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.raw_pkt_rate) $val
                            incr keyed_array_index
                    
                            set [subst $keyed_array_name]($c/$l/$p.$rate_stat) $val
                            incr keyed_array_index
                        } elseif {$rate_stat == "aggregate.rx.pkt_rate"} {
                            set [subst $keyed_array_name]($c/$l/$p.aggregate.rx.raw_pkt_rate) $val
                            incr keyed_array_index
                            
                            set [subst $keyed_array_name]($c/$l/$p.$rate_stat) $val
                            incr keyed_array_index
                        } elseif {$rate_stat == "elapsed_time"} {
                            # Do nothing.  The elapsed time will be set above
                            # in the total section, not here in the rate section
                        } else {
                            set [subst $keyed_array_name]($c/$l/$p.$rate_stat) $val
                            incr keyed_array_index
                        }
                    }
                    incr stat_index
                }
                # Retrieve transmit rate stats from port
                set stream_ids_on_port [::ixia::getIxiaStreamIds $c/$l/$p]
                if {[llength $stream_ids_on_port] > 0} {
                    set from_id [lindex [lsort -dictionary \
                            $stream_ids_on_port] 0]
                    set to_id   [lindex [lsort -dictionary \
                            $stream_ids_on_port] end]

                    if {[port isActiveFeature $c $l $p \
                            portFeaturePerStreamTxStats]} {
                        if {[streamTransmitStats get $c $l $p 1 $to_id] \
                                != $::TCL_OK} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Failed\
                                    to streamTransmitStats get $c $l $p 1\
                                    $to_id B"
                            return $returnList
                        }
                        # Sleeping for a little less than 1 second to get the
                        # correct rate
                        ixia_sleep 700
                        # We make this call a 2nd time to get the actual bit rate
                        if {[streamTransmitStats get $c $l $p 1 $to_id] \
                                != $::TCL_OK} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Failed\
                                    to streamTransmitStats get $c $l $p 1\
                                    $to_id A"
                            return $returnList
                        }

                        # How many groups did we get
                        if {[streamTransmitStats cget -numGroups] > 1} {
                            set to_id [expr $from_id + \
                                    [streamTransmitStats cget -numGroups] - 1]
                        } else {
                            set to_id $from_id
                        }
                        

                        set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkt_rate) 0
                        incr keyed_array_index

                        for {set str_id $from_id} {$str_id <= $to_id} \
                                {incr str_id} {
                            if {[streamTransmitStats getGroup $str_id] == 0} {
                                set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkt_rate) [expr \
                                        [set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkt_rate)] + \
                                        [streamTransmitStats cget -frameRate] ]
                                incr keyed_array_index
                            }
                        }
                    }
                } else {
                    set [subst $keyed_array_name]($c/$l/$p.aggregate.tx.total_pkt_rate) 0
                    incr keyed_array_index
                }
            }
        }
        
        if {$mode != "all"} {
            if {[info exists returnList]} {
                foreach key1 [keylkeys returnList] {
                    catch {unset c}
                    catch {unset l}
                    catch {unset p}
                    if {[regexp {^([0-9]+)/([0-9]+)/([0-9]+)} $key1 key1_match c l p] && \
                            [info exists c] && [info exists l] && [info exists p]} {
                        incr keyed_array_index
                    }
                    set [subst $keyed_array_name](${key1}) [keylget returnList $key1]
                }
            }
            switch -- $return_method {
                "keyed_list" {
                    set [subst $keyed_array_name](status) $::SUCCESS
                    set retTemp [array get $keyed_array_name]
                    eval "keylset returnList $retTemp"
                    # Unset the current array
                    ::ixia::cleanupTrafficStatsArrays $keyed_array_name
                    return $returnList
                }
                "keyed_list_or_array" {
                    if {$keyed_array_index < $traffic_stats_max_list_length} {
                        set [subst $keyed_array_name](status) $::SUCCESS
                        set retTemp [array get $keyed_array_name]
                        eval "keylset returnList $retTemp"
                        # Unset the current array
                        ::ixia::cleanupTrafficStatsArrays $keyed_array_name
                        return $returnList
                    } else {
                        keylset returnList status $::SUCCESS
                        keylset returnList handle ::ixia::[subst $keyed_array_name]
                        return $returnList
                    }
                }
                "array" {
                    keylset returnList status $::SUCCESS
                    keylset returnList handle ::ixia::[subst $keyed_array_name]
                    return $returnList
                }
            }
        }
    }
    
    if {[info exists returnList]} {
        foreach key1 [keylkeys returnList] {
            catch {unset c}
            catch {unset l}
            catch {unset p}
            if {[regexp {^([0-9]+)/([0-9]+)/([0-9]+)} $key1 key1_match c l p] && \
                    [info exists c] && [info exists l] && [info exists p]} {
                incr keyed_array_index
            }
            set [subst $keyed_array_name](${key1}) [keylget returnList $key1]
        }
    }
    switch -- $return_method {
        "keyed_list" {
            set [subst $keyed_array_name](status) $::SUCCESS
            set retTemp [array get $keyed_array_name]
            eval "keylset returnList $retTemp"
            # Unset the current array
            ::ixia::cleanupTrafficStatsArrays $keyed_array_name
            return $returnList
        }
        "keyed_list_or_array" {
            if {$keyed_array_index < $traffic_stats_max_list_length} {
                set [subst $keyed_array_name](status) $::SUCCESS
                set retTemp [array get $keyed_array_name]
                eval "keylset returnList $retTemp"
                # Unset the current array
                ::ixia::cleanupTrafficStatsArrays $keyed_array_name
                return $returnList
            } else {
                keylset returnList status $::SUCCESS
                keylset returnList handle ::ixia::[subst $keyed_array_name]
                return $returnList
            }
        }
        "array" {
            keylset returnList status $::SUCCESS
            keylset returnList handle ::ixia::[subst $keyed_array_name]
            return $returnList
        }
    }
}
