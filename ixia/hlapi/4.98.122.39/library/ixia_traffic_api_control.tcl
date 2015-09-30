proc ::ixia::traffic_control { args } {
    variable executeOnTclServer
    variable ignoreLinkState

    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::traffic_control $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable new_ixnetwork_api
    variable emulation_handles_array
    variable l2tpv3_cc_handles_array
    variable atmStatsConfig
    variable ixnetwork_rp2vp_handles_array

    ::ixia::utrackerLog $procName $args

    set man_args {
        -action      CHOICES sync_run run manual_trigger stop poll reset destroy clear_stats regenerate apply
    }

    set opt_args_all_but_540 {
        -port_handle       REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -latency_bins      NUMERIC
        -latency_values
        -latency_enable    CHOICES 0 1
        -latency_control   CHOICES cut_through store_and_forward store_and_forward_preamble
                           DEFAULT cut_through
        -jitter_bins       NUMERIC
        -jitter_values

        -duration          NUMERIC
        -tx_ports_list
        -rx_ports_list
        -type              CHOICES l23 l47
                           DEFAULT l23
        -traffic_generator CHOICES ixos ixnetwork ixaccess ixnetwork_540
                           DEFAULT ixos
        -max_wait_timer    NUMERIC
                           DEFAULT 0
        -handle            ANY
    }
    
    set opt_args_ixn_540 {
        -port_handle                                REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -disable_latency_bins                       FLAG
        -disable_jitter_bins                        FLAG                                
        -latency_bins                               VCMD ::ixia::validate_latency_and_jitter_bins
        -latency_values                                                                                             
        -latency_enable                             CHOICES 0 1
        -latency_control                            CHOICES cut_through store_and_forward
                                                    CHOICES mef_frame_delay forwarding_delay
                                                    DEFAULT cut_through                                             
        -jitter_bins                                VCMD ::ixia::validate_latency_and_jitter_bins
        -jitter_values
        -delay_variation_enable                     CHOICES 0 1
        -large_seq_number_err_threshold             NUMERIC
        -stats_mode                                 CHOICES rx_delay_variation_avg rx_delay_variation_err_and_rate
                                                    CHOICES rx_delay_variation_min_max_and_rate
        -packet_loss_duration_enable                CHOICES 0 1
        -cpdp_convergence_enable                    CHOICES 0 1
        -cpdp_ctrl_plane_events_enable              CHOICES 0 1
        -cpdp_data_plane_events_rate_monitor_enable CHOICES 0 1
        -cpdp_data_plane_threshold                  NUMERIC
        -cpdp_data_plane_jitter                     DECIMAL
        -duration                                   NUMERIC
        -handle                                     ANY
        -instantaneous_stats_enable                 CHOICES 0 1
        -l1_rate_stats_enable                       CHOICES 0 1
        -tx_ports_list
        -rx_ports_list
        -type                                       CHOICES l23 l47                              
                                                    DEFAULT l23                                  
        -traffic_generator                          CHOICES ixos ixnetwork ixaccess ixnetwork_540
                                                    DEFAULT ixos                                 
        -max_wait_timer                             NUMERIC
                                                    DEFAULT 0
	    -misdirected_per_flow                       CHOICES 0 1
    }
    
    set opt_args $opt_args_all_but_540
    
    # If the hltset is P2NO and the ixia::connect used the ixnetwork_tcl_server
    # parameter than the traffic_generator will fallback to nextGen
    if {[regexp "NO" $::ixia::ixnetworkVersion]  && \
        [info exists ::ixia::forceNextGenTraffic] &&\
        $::ixia::forceNextGenTraffic == 1 && \
        [info exists new_ixnetwork_api] && $new_ixnetwork_api} {
            set opt_args $opt_args_ixn_540
    } else {
        if {[string first ixnetwork_540 $args] != -1} {
            set opt_args $opt_args_ixn_540
        } else {
            set opt_args $opt_args_all_but_540
        }
    }
    
    set retValueClicks [clock clicks]
    set retValueSeconds [clock seconds]

    keylset returnList clicks [format "%u" $retValueClicks]
    keylset returnList seconds [format "%u" $retValueSeconds]

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
    
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

            # This procedure will connect to traffic version 5.40 if needed
            set ret_code [::ixia::540trafficGlobalStatsConfig $args $man_args $opt_args_ixn_540]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: [keylget ret_code log]"
                return $returnList
            }
        } elseif {$traffic_type == "legacy"} {
            # The current traffic version could be 5.40, so we should switch it
            set retCode [checkIxNetwork "5.30"]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                        [keylget retCode log]"
                return $returnList
            }
        }
        
        if {$traffic_type == "nextGen" || $traffic_type == "legacy"} {
            set returnList [::ixia::ixnetwork_traffic_control $args $man_args $opt_args]
            return $returnList
        }
    }
    
    if {![info exists port_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Parameter,\
                -port_handle is mandatory if not using IxTclNetwork 5.30 or greater."
        return $returnList
    }
    
    if {[info exists ixnetwork_rp2vp_handles_array($port_handle)]} {
        set port_handle $ixnetwork_rp2vp_handles_array($port_handle)
    }
    
    # Determine if any pppox/l2tp/l2tpv3 port is present
    set l2tpv3Ports ""
    set otherPorts ""
    set tempOtherPorts ""
    set handlePortPairList [array get l2tpv3_cc_handles_array *,port]

    foreach port $port_handle {
        set portFound 0
        foreach {handle l2tpv3Port} $handlePortPairList {
            if {$l2tpv3Port == $port} {
                lappend l2tpv3Ports $port
                set portFound 1
                break
            }
        }

        if {$portFound == 0} {
            lappend tempOtherPorts $port
        }
    }

    set handlePortPairList [string map {, /} \
            [array names emulation_handles_array]]

    foreach port $tempOtherPorts {
        set portFound 0
        foreach {l2tpv3Port} $handlePortPairList {
            if {$l2tpv3Port == $port} {
                lappend l2tpv3Ports $port
                set portFound 1
                break
            }
        }

        if {$portFound == 0} {
            lappend otherPorts $port
        }
    }

    # When pppox/l2tp/l2tpv3 ports are found call the aprropriate procedure
    if {[llength $l2tpv3Ports] > 0} {
        if {[info exists tx_ports_list]} {
            set returnList [::ixia::ixaccess_traffic_control \
                    -port_handle $l2tpv3Ports                \
                    -action $action                          \
                    -tx_ports_list $tx_ports_list            \
                    -rx_ports_list $rx_ports_list            ]
        } else {
            set returnList [::ixia::ixaccess_traffic_control \
                    -port_handle $l2tpv3Ports                \
                    -action $action                          ]
        }

        if {[keylget returnList status] == $::FAILURE} {
            return $returnList
        }
    }

    # If there are ports which are not pppox/l2tp/l2tpv3 continue
    if {[llength $otherPorts] > 0} {
        set port_handle $otherPorts
    } else  {
        return $returnList
    }

    set port_list [format_space_port_list $port_handle]

    debug "PORT LIST from TRAFFIC_CONTROL = $port_list"
    set log ""
    set status  $::SUCCESS
    set stopped 1

    # Handle the latency bins first
    array set latency_control_enum_list [list                  \
            cut_through                cutThrough              \
            store_and_forward          storeAndForward         \
            store_and_forward_preamble storeAndForwardPreamble ]

    if {[info exists latency_bins] && [info exists latency_values]} {
        set stat_bins latency
    } elseif {[info exists jitter_bins] && [info exists jitter_values]} {
        set stat_bins jitter
    }

    if {[info exists stat_bins]} {
        foreach item $port_list {
            foreach {chassis card port} $item {}
            if {[port isValidFeature $chassis $card $port \
                    portFeatureRxWidePacketGroups]} {

                port get $chassis $card $port

                port config -receiveMode portRxModeWidePacketGroup
                if {[port set $chassis $card $port]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: the port,\
                            $chassis $card $port, does not support a receive\
                            mode of wide packet groups.  Latency bin setup is\
                            not a valid option."
                    return $returnList
                }

                if {[port isValidFeature $chassis $card $port \
                        portFeatureRxLatencyBin]} {

                    packetGroup getRx $chassis $card $port
                    packetGroup config -enableLatencyBins $::true
                    packetGroup config -latencyBinList [set ${stat_bins}_values]

                    if {$stat_bins == "latency"} {
                        catch {packetGroup config -latencyControl \
                                    $latency_control_enum_list($latency_control)}
                    } elseif {$stat_bins == "jitter"} {
                        catch {packetGroup config -latencyControl \
                                    interArrivalJitter}
                    }

                    if {[packetGroup setRx $chassis $card $port]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: failure on\
                                packetGroup setRx $chassis $card $port call."
                        return $returnList
                    }

                    set pL [list [list $chassis $card $port]]
                    ixWriteConfigToHardware pL

                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: the port,\
                            $chassis $card $port, does not support the latency\
                            bin feature."
                    return $returnList
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: the port, $chassis\
                        $card $port, does not support a receive mode of wide\
                        packet groups.  Latency bin setup is not a valid option."
                return $returnList
            }
        }
    }

    # not in some IxOS versions that HLTAPI is meant to work with
    set portFeatureCapture 143

    if {[info exists action]} {
        foreach item $action {
            switch -- $item {
                sync_run {
                    if {[ixClearTimeStamp port_list]} {
                        set status $::FAILURE
                        set log "ERROR in $procName: Clearing time stamps on\
                                ports $port_list failed."
                        break
                    }
                    # only start on those that are enabled for this feature
                    set capture_list     [list]
                    set packetgroup_list [list]
                    set wide_packetgroup_list [list]

                    if {[ixClearStats port_list]} {
                        set status $::FAILURE
                        set log "ERROR in $procName: Clearing stats on ports\
                                $port_list failed."
                        break
                    }
                    foreach port $port_list {
                        scan $port "%d %d %d" c l p
                        if {[port isActiveFeature $c $l $p \
                                $portFeatureCapture]} {
                            lappend capture_list [list $c $l $p]
                        }

                        if {[port isActiveFeature $c $l $p \
                                $::portFeatureRxPacketGroups]} {
                            lappend packetgroup_list [list $c $l $p]
                        }

                        if {[port isActiveFeature $c $l $p \
                                $::portFeatureRxWidePacketGroups]} {
                            lappend wide_packetgroup_list [list $c $l $p]
                        }

                    }
                    if {[llength $capture_list] > 0 && \
                            [ixStartCapture capture_list]} {
                        set status $::FAILURE
                        set log "ERROR in $procName: Start capture failed on\
                                port(s): $capture_list"
                        break
                    }
                    debug "ixStartPacketGroups  $packetgroup_list"
                    if {[llength $packetgroup_list] > 0 && [ixStartPacketGroups \
                            packetgroup_list]} {
                        set status $::FAILURE
                        set log "ERROR in $procName: Start packet group stats\
                                failed on port(s): $port_list"
                        break
                    }
                    debug "ixStartPacketGroups  $wide_packetgroup_list"
                    if {[llength $wide_packetgroup_list] > 0 && [ixStartPacketGroups \
                            wide_packetgroup_list]} {
                        set status $::FAILURE
                        set log "ERROR in $procName: Start packet group stats\
                                failed on port(s): $port_list"
                        break
                    }

                    set port_check_list [list]
                    foreach port_item $port_list {
                        if {(![info exists ignoreLinkState($port_item)]) || \
                                ($ignoreLinkState($port_item) == 0)} {
                            lappend port_check_list $port_item
                        }
                    }
                    if {[llength $port_check_list] > 0} {
                        set retries 0
                        
                        ### CheckLinkState start
                        set ::ixia::ixCheckLinkStateTracerVar ""
                        trace add execution puts enter ::ixia::ixCheckLinkStateTracer
                        set retCode [ixCheckLinkState port_check_list]
                        trace remove execution puts enter ::ixia::ixCheckLinkStateTracer
                        ### CheckLinkState end
                        
                        while {$retCode && ($retries < 10)} {
                            ### CheckLinkState start
                            set ::ixia::ixCheckLinkStateTracerVar ""
                            trace add execution puts enter ::ixia::ixCheckLinkStateTracer
                            set retCode [ixCheckLinkState port_check_list]
                            trace remove execution puts enter ::ixia::ixCheckLinkStateTracer
                            ### CheckLinkState end
                        
                            incr retries
                        }
    
                        if {$retCode} {
                            set status $::FAILURE
                            
                            set retString ""
                            foreach retElem $::ixia::ixCheckLinkStateTracerVar { append retString "$retElem "}
                            
                            set log "ERROR in $procName: $retString"
                            break
                        }
                    }

                    if {![info exists duration]} {
                        set duration 0
                    }
                    set startStatus [::ixia::startTraffic port_list $duration]
                    if {[keylget startStatus status] == $::FAILURE} {
                        set status $::FAILURE
                        set log "ERROR in $procName: [keylget startStatus log]"
                    }

                    set stopped 0
                }
                run {
                    set port_check_list [list]
                    foreach port_item $port_list {
                        if {(![info exists ignoreLinkState($port_item)]) || \
                                ($ignoreLinkState($port_item) == 0)} {
                            lappend port_check_list $port_item
                        }
                    }
                    if {[llength $port_check_list] > 0} {
                        set retries 0
                        
                        ### CheckLinkState start
                        set ::ixia::ixCheckLinkStateTracerVar ""
                        trace add execution puts enter ::ixia::ixCheckLinkStateTracer
                        set retCode [ixCheckLinkState port_check_list]
                        trace remove execution puts enter ::ixia::ixCheckLinkStateTracer
                        ### CheckLinkState end
                        
                        while {$retCode && ($retries < 3)} {
                            ### CheckLinkState start
                            set ::ixia::ixCheckLinkStateTracerVar ""
                            trace add execution puts enter ::ixia::ixCheckLinkStateTracer
                            set retCode [ixCheckLinkState port_check_list]
                            trace remove execution puts enter ::ixia::ixCheckLinkStateTracer
                            ### CheckLinkState end
                            
                            incr retries
                        }
                        
                        if {$retCode} {
                            set status $::FAILURE
                            set retString ""
                            foreach retElem $::ixia::ixCheckLinkStateTracerVar { append retString "$retElem "}
                            
                            set log "ERROR in $procName: $retString"
                            break
                        }
                    }

                    if {![info exists duration]} {
                        set duration 0
                    }
                    set startStatus [::ixia::startTraffic port_list \
                            $duration]
                    if {[keylget startStatus status] == $::FAILURE} {
                        set status $::FAILURE
                        set log "ERROR in $procName: [keylget startStatus log]"
                    }
                    
                    if {![info exists ::ixia::no_efm_event_trigger] || $::ixia::no_efm_event_trigger == 0} {
                        set tmp_status [emulation_efm_control -api_used ixprotocol -action start_event -port_handle $port_handle]
                        debug "emulation_efm_control -api_used ixprotocol -action start_event -port_handle $port_handle returned $tmp_status"
                    }
                    
                    set stopped 0
                }
                stop {
                    if {[ixStopTransmit port_list]} {
                        set status $::FAILURE
                        set log "ERROR in $procName: Could not stop traffic\
                                on port(s): $port_list"
                        break
                    } else {
                        set stopped 1
                    }
                    
                    if {![info exists ::ixia::no_efm_event_trigger] || $::ixia::no_efm_event_trigger == 0} {
                        set tmp_status [emulation_efm_control -api_used ixprotocol -action stop_event -port_handle $port_handle]
                        debug "emulation_efm_control -api_used ixprotocol -action stop_event -port_handle $port_handle returned $tmp_status"
                    }
                                        
                    # Wait for residual frames
                    ixia_sleep 500
                    set stopped 1
                }
                manual_trigger {}
                poll {
                    if {[::ixia::are_ports_transmitting $port_list]} {
                        set stopped 0
                    } else {
                        set stopped 1
                    }
                }
                reset -
                destroy {
                    foreach port $port_list {
                        scan $port "%d %d %d" chassis card port
                        set retCode [updatePatternMismatchFilter [list "$chassis $card $port"] "reset"]
                        if {[keylget retCode status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    [keylget retCode log]"
                            return $returnList
                        }
                        set rstStatus [::ixia::ixaccess_reset_traffic $chassis $card $port]
                        if {[keylget rstStatus status] != $::SUCCESS} {
                            return $rstStatus
                        }
                        if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                            array unset atmStatsConfig
                            streamQueueList select $chassis $card $port
                            streamQueueList clear
                        } else  {
                            set retCode [port reset $chassis $card $port]
                            if {$retCode} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: Unable to\
                                        reset port: $chassis $card $port"
                                return $returnList
                            }
                        }
                        foreach item [array names ::ixia::pgid_to_stream] {
                            foreach {chassis_num card_num port_num stream_num} \
                                    [split $::ixia::pgid_to_stream($item) ,] {}
                            if {($chassis == $chassis_num) && ($card == $card_num) && \
                                    ($port == $port_num)} {
                                catch {array unset ::ixia::pgid_to_stream $item}
                            }
                        }
            
                        set port_list [list [list $chassis $card $port]]
                    }
                    if {[array names ::ixia::pgid_to_stream] == -1} {
                        set ::ixia::current_streamid 0
                    }
                }
                clear_stats {
                    if {[ixClearStats port_list]} {
                        set status $::FAILURE
                        set log "ERROR in $procName: Clearing stats on ports\
                                $port_list failed."
                        break
                    }
                    if {[::ixia::are_ports_transmitting $port_list]} {
                        set stopped 0
                    } else {
                        set stopped 1
                    }
                    if {[ixClearTimeStamp port_list]} {
                        set status $::FAILURE
                        set log "ERROR in $procName: Clearing time stamps on ports\
                                $port_list failed."
                        break
                    }
                    if {[ixStartCapture port_list]} {
                        set status $::FAILURE
                        set log "ERROR in $procName: Start capture failed\
                                on port(s): $port_list"
                        break
                    }
                    debug "ixStartPacketGroups $port_list"
                    if {[catch {ixStartPacketGroups port_list} errMsg]} {
                        ixPuts "Warning on $procName : Could not \
                                start PGID retrieval on ports $port_list. \
                                $errMsg"
                    }  
                }
                default {
                    set status $::FAILURE
                    set log "ERROR in $procName: Invalid option passed - $item."
                    break
                }
            }
        }
    }

    keylset returnList status  $status
    if {$status == $::FAILURE} {
        keylset returnList log $log
    }
    keylset returnList stopped $stopped

    return $returnList
}

