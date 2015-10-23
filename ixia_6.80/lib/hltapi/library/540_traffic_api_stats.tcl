# Returns the available field offsets that can be enabled for egress tracking
# in the traffic item $traffic_item_objref
proc ::ixia::540trafficGetEgressTrackingFieldOffsets {traffic_item_objref} {
    set fieldList [list]; #the list of all available fields

    # get all configured egressTracking items
    set egressItems [ixia::ixNetworkGetList $traffic_item_objref egressTracking]

    if {[llength $egressItems]} {
        set firstItem [lindex $egressItems 0]
        set item ${firstItem}/fieldOffset
        set stackItems [ixia::ixNetworkGetList $item stack]

        # get each object of type fieldOffset/stack/field
        foreach stack $stackItems {
            set fields [ixia::ixNetworkGetList $stack field]
            foreach field $fields {
                regsub "$firstItem/" $field {} trimmedField
                lappend fieldList $trimmedField
            }
        }
    }
    
    return $fieldList
}


proc ::ixia::540trafficStats { args opt_args } {
    variable ixnetwork_port_handles_array
    set keyed_array_index 0
    variable traffic_stats_num_calls
    set keyed_array_name traffic_stats_returned_keyed_array_$traffic_stats_num_calls
    mpincr traffic_stats_num_calls
    variable $keyed_array_name
    catch {array unset $keyed_array_name}
    array set $keyed_array_name ""
    variable traffic_stats_max_list_length
    variable csv_path
    
    # Array which stores for each statistic key how many times it was added
    # in order to calculate it's average.
    array set avg_calculator_array ""
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    keylset returnList status $::SUCCESS
    
    if {![info exists mode]} {
        set mode "aggregate"
    }
    
    if {[regexp "^application_" $mode]} {
        # Legacy Application feature was removed from IxNetwork
        keylset returnList status $::FAILURE
        keylset returnList log "Legacy Application Traffic was deprecated. Please use L4-7 AppLibrary Traffic attributes for -mode parameter."
        return $returnList
    }
    
    if {![info exists csv_path]} {
        set ::ixia::csv_path $csv_path
    }
    
    if {$::ixia::snapshot_stats == 0 && $return_method == "csv"} {
        set return_method "keyed_list"
    }
    
    set retCode [540IxNetInit]
    if {[keylget retCode status] != $::SUCCESS} {
        return $retCode
    }

    # set the measure mode for stats
    # //statistics/measurementMode
    if {[info exists measure_mode]} {
        set instantEnabled [ixNetworkGetAttr "::ixNet::OBJ-/traffic" -enableInstantaneousStatsSupport]
        if {$measure_mode != "mixed" && !$instantEnabled} {
            keylset returnList status $::FAILURE
            keylset returnList log "Traffic settings don't have instantaneous stats mode enabled. \
                    Run ixia::traffic_config and enable the instantaneous stats mode."
            return $returnList
        }
        ixNetworkSetAttr "::ixNet::OBJ-/statistics/measurementMode" -measurementMode "${measure_mode}Mode"
        ixNetworkCommit
    }
    set measure_mode [ixNetworkGetAttr "::ixNet::OBJ-/statistics/measurementMode" -measurementMode]
    keylset returnList measure_mode [string range $measure_mode 0 end-4]
    
    # If we receive a handle parameter which is a traffic item name, we should replace it with
    # the traffic item object reference
    
    set streamNames ""
    set streamObjects ""
    if {[info exists stream] || [info exists streams]} {
        
        if {[info exists stream]} {
            set streamObjects $stream
        } elseif {[info exists streams]} {
            set streamObjects $streams
        }
        
        
        set new_stream_obj_list ""

        foreach str_obj $streamObjects {
            if {![regexp {^::ixNet::OBJ-/traffic} $str_obj]} {
                # It's probably a traffic item name returned by stream_id key on mode create.
                # Get the actual traffic item object reference.
                set stream_id_tmp [540getTrafficItemByName $str_obj]
                if {$stream_id_tmp == "_none"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for -streams '$str_obj'. A traffic item with this\
                            name could not be found. Parameter -streams must be a handle\
                            returned by ::ixia::traffic_config procedure with the 'stream_id' key."
                    return $returnList
                }
                if {[lsearch $new_stream_obj_list $stream_id_tmp] == -1} {
                    lappend new_stream_obj_list $stream_id_tmp
                }
                if {[lsearch $streamNames $str_obj] == -1} {
                    lappend streamNames $str_obj
                }
                catch {unset stream_id_tmp}
                
            } else {
                set tmp_ti [ixNetworkGetParentObjref $str_obj "trafficItem"]
                if {$tmp_ti != [ixNet getNull]} {
                    if {[lsearch $streamNames [ixNet getA $tmp_ti -name]] == -1} {
                        lappend streamNames [ixNet getA $tmp_ti -name]
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for -streams '$str_obj'. A traffic item with this\
                            name could not be found. Parameter -streams must be a handle\
                            returned by ::ixia::traffic_config procedure with the 'stream_id' key."
                    return $returnList
                }
                if {[lsearch $new_stream_obj_list $tmp_ti] == -1} {
                    lappend new_stream_obj_list $tmp_ti
                }
                catch {unset tmp_ti}
                
            }
        }
        
        if {[info exists stream]} {
            set stream $new_stream_obj_list
        } elseif {[info exists streams]} {
            set streams $new_stream_obj_list
        }
        
        set streamObjects $new_stream_obj_list
    } else {
        set streamObjects [ixNet getList [ixNet getRoot]traffic trafficItem]
        foreach str_obj $streamObjects {
            lappend streamNames [ixNet getA $str_obj -name]
        }
        
        # For egress statistics, when port_handle is provided return stats only for the
        #       traffic items that have the ports from port_handle as RX ports (BUG565964)
        if {$mode == "egress_by_port" || $mode == "egress_by_flow" || $mode == "all"} {
            
            if {![info exists port_handle]} {
                set port_handle [array names ixnetwork_port_handles_array]
            }
            set ret_code [540trafficGetTiWithRxPort $port_handle]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set streamObjectsEgress [keylget ret_code handle_list]
        }
    }
    
    # Check the traffic state
    ::ixia::set_waiting_for_stats_key $mode
    
    if {$mode == "aggregate" || $mode == "all"} {
        
        array set portStatsArray {
            "AAL5 Frames Rx."             {
                                           {hltName     {rx.rx_aal5_frames_count                rx.rx_aal5_frames_count.min             rx.rx_aal5_frames_count.max             rx.rx_aal5_frames_count.avg             rx.rx_aal5_frames_count.sum             rx.rx_aal5_frames_count.count           }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "AAL5 Frames Rx. Rate"        {
                                           {hltName     {rx.rx_aal5_frames_rate                 rx.rx_aal5_frames_rate.min              rx.rx_aal5_frames_rate.max              rx.rx_aal5_frames_rate.avg              rx.rx_aal5_frames_rate.sum              rx.rx_aal5_frames_rate.count            }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "AAL5 Frames Tx."             {
                                           {hltName     {tx.tx_aal5_frames_count                tx.tx_aal5_frames_count.min             tx.tx_aal5_frames_count.max             tx.tx_aal5_frames_count.avg             tx.tx_aal5_frames_count.sum             tx.tx_aal5_frames_count.count           }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "AAL5 Frames Tx. Rate"        {
                                           {hltName     {tx.tx_aal5_frames_rate                 tx.tx_aal5_frames_rate.min              tx.tx_aal5_frames_rate.max              tx.tx_aal5_frames_rate.avg              tx.tx_aal5_frames_rate.sum              tx.tx_aal5_frames_rate.count            }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "AAL5 Payload Bytes Tx."      {
                                           {hltName     {tx.tx_aal5_bytes_count                 tx.tx_aal5_bytes_count.min              tx.tx_aal5_bytes_count.max              tx.tx_aal5_bytes_count.avg              tx.tx_aal5_bytes_count.sum              tx.tx_aal5_bytes_count.count            }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "AAL5 Payload Bytes Tx. Rate" {
                                           {hltName     {tx.tx_aal5_bytes_rate                  tx.tx_aal5_bytes_rate.min               tx.tx_aal5_bytes_rate.max               tx.tx_aal5_bytes_rate.avg               tx.tx_aal5_bytes_rate.sum               tx.tx_aal5_bytes_rate.count             }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "ATM Cells Rx."               {
                                           {hltName     {rx.rx_atm_cells_count                  rx.rx_atm_cells_count.min               rx.rx_atm_cells_count.max               rx.rx_atm_cells_count.avg               rx.rx_atm_cells_count.sum               rx.rx_atm_cells_count.count             }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "ATM Cells Rx. Rate"          {
                                           {hltName     {rx.rx_atm_cells_rate                   rx.rx_atm_cells_rate.min                rx.rx_atm_cells_rate.max                rx.rx_atm_cells_rate.avg                rx.rx_atm_cells_rate.sum                rx.rx_atm_cells_rate.count              }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "ATM Cells Tx."               {
                                           {hltName     {tx.tx_atm_cells_count                  tx.tx_atm_cells_count.min               tx.tx_atm_cells_count.max               tx.tx_atm_cells_count.avg               tx.tx_atm_cells_count.sum               tx.tx_atm_cells_count.count             }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "ATM Cells Tx. Rate"          {
                                           {hltName     {tx.tx_atm_cells_rate                   tx.tx_atm_cells_rate.min                tx.tx_atm_cells_rate.max                tx.tx_atm_cells_rate.avg                tx.tx_atm_cells_rate.sum                tx.tx_atm_cells_rate.count              }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Bytes Rx."                   {
                                           {hltName     {rx.pkt_byte_count                      rx.pkt_byte_count.min                   rx.pkt_byte_count.max                   rx.pkt_byte_count.avg                   rx.pkt_byte_count.sum                   rx.pkt_byte_count.count                 }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Bytes Rx. Rate"              {
                                           {hltName     {rx.pkt_byte_rate                       rx.pkt_byte_rate.min                    rx.pkt_byte_rate.max                    rx.pkt_byte_rate.avg                    rx.pkt_byte_rate.sum                    rx.pkt_byte_rate.count                  }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Bytes Tx."                   {
                                           {hltName     {tx.pkt_byte_count                      tx.pkt_byte_count.min                   tx.pkt_byte_count.max                   tx.pkt_byte_count.avg                   tx.pkt_byte_count.sum                   tx.pkt_byte_count.count                 }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Bytes Tx. Rate"              {
                                           {hltName     {tx.pkt_byte_rate                       tx.pkt_byte_rate.min                    tx.pkt_byte_rate.max                    tx.pkt_byte_rate.avg                    tx.pkt_byte_rate.sum                    tx.pkt_byte_rate.count                  }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Collisions"                  {
                                           {hltName     {rx.collisions_count                    rx.collisions_count.min                 rx.collisions_count.max                 rx.collisions_count.avg                 rx.collisions_count.sum                 rx.collisions_count.count               }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Control Frames Rx"           {
                                           {hltName     {rx.control_frames                      rx.control_frames.min                   rx.control_frames.max                   rx.control_frames.avg                   rx.control_frames.sum                   rx.control_frames.count                 }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Control Frames Tx"           {
                                           {hltName     {tx.control_frames                      tx.control_frames.min                   tx.control_frames.max                   tx.control_frames.avg                   tx.control_frames.sum                   tx.control_frames.count                 }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Data Integrity Errors"       {
                                           {hltName     {rx.data_int_errors_count               rx.data_int_errors_count.min            rx.data_int_errors_count.max            rx.data_int_errors_count.avg            rx.data_int_errors_count.sum            rx.data_int_errors_count.count          }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Data Integrity Frames Rx."   {
                                           {hltName     {rx.data_int_frames_count               rx.data_int_frames_count.min            rx.data_int_frames_count.max            rx.data_int_frames_count.avg            rx.data_int_frames_count.sum            rx.data_int_frames_count.count          }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Port Name"                   {
                                           {hltName     {port_name                              port_name.count                         }}
                                           {statType    {none                                   count                                   }}
                                           {ixnNameType {strict                                 strict                                  }}
                                           {prefixKey   {_default                               aggregate                               }}
                                          }
            "Duplex Mode"                 {
                                           {hltName     {duplex_mode                            duplex_mode.count                       }}
                                           {statType    {none                                   count                                   }}
                                           {ixnNameType {strict                                 strict                                  }}
                                           {prefixKey   {_default                               aggregate                               }}
                                          }
            "Frames Tx."                  {
                                           {hltName     {tx.raw_pkt_count                       tx.raw_pkt_count.min                    tx.raw_pkt_count.max                    tx.raw_pkt_count.avg                    tx.raw_pkt_count.sum                    tx.raw_pkt_count.count                  tx.total_pkts                           tx.total_pkts.min                       tx.total_pkts.max                       tx.total_pkts.avg                       tx.total_pkts.sum                       tx.total_pkts.count                     }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               _default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Frames Tx. Rate"             {
                                           {hltName     {tx.total_pkt_rate                       tx.total_pkt_rate.min                   tx.total_pkt_rate.max                   tx.total_pkt_rate.avg                   tx.total_pkt_rate.sum                   tx.total_pkt_rate.count                 }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Line Speed"                  {
                                           {hltName     {tx.line_speed                          tx.line_speed.count                     }}
                                           {statType    {none                                   count                                   }}
                                           {ixnNameType {strict                                 strict                                  }}
                                           {prefixKey   {_default                               aggregate                               }}
                                          }
            "Rx. Rate (Kbps)"             {
                                           {hltName     {rx.pkt_kbit_rate                       rx.pkt_kbit_rate.min                    rx.pkt_kbit_rate.max                    rx.pkt_kbit_rate.avg                    rx.pkt_kbit_rate.sum                    rx.pkt_kbit_rate.count                  }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Rx. Rate (Mbps)"             {
                                           {hltName     {rx.pkt_mbit_rate                       rx.pkt_mbit_rate.min                    rx.pkt_mbit_rate.max                    rx.pkt_mbit_rate.avg                    rx.pkt_mbit_rate.sum                    rx.pkt_mbit_rate.count                  }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Rx. Rate (bps)"              {
                                           {hltName     {rx.pkt_bit_rate                        rx.pkt_bit_rate.min                     rx.pkt_bit_rate.max                     rx.pkt_bit_rate.avg                     rx.pkt_bit_rate.sum                     rx.pkt_bit_rate.count                   }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Scheduled Cells Tx."         {
                                           {hltName     {tx.tx_aal5_scheduled_cells_count       tx.tx_aal5_scheduled_cells_count.min    tx.tx_aal5_scheduled_cells_count.max    tx.tx_aal5_scheduled_cells_count.avg    tx.tx_aal5_scheduled_cells_count.sum    tx.tx_aal5_scheduled_cells_count.count  }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Scheduled Cells Tx. Rate"    {
                                           {hltName     {tx.tx_aal5_scheduled_cells_rate        tx.tx_aal5_scheduled_cells_rate.min     tx.tx_aal5_scheduled_cells_rate.max     tx.tx_aal5_scheduled_cells_rate.avg     tx.tx_aal5_scheduled_cells_rate.sum     tx.tx_aal5_scheduled_cells_rate.count   }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Scheduled Frames Tx."        {
                                           {hltName     {tx.scheduled_pkt_count                 tx.scheduled_pkt_count.min              tx.scheduled_pkt_count.max              tx.scheduled_pkt_count.avg              tx.scheduled_pkt_count.sum              tx.scheduled_pkt_count.count            tx.tx_aal5_scheduled_frames_count       tx.tx_aal5_scheduled_frames_count.min   tx.tx_aal5_scheduled_frames_count.max   tx.tx_aal5_scheduled_frames_count.avg   tx.tx_aal5_scheduled_frames_count.sum   tx.tx_aal5_scheduled_frames_count.count }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               _default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Scheduled Frames Tx. Rate"   {
                                           {hltName     {tx.scheduled_pkt_rate                  tx.scheduled_pkt_rate.min               tx.scheduled_pkt_rate.max               tx.scheduled_pkt_rate.avg               tx.scheduled_pkt_rate.sum               tx.scheduled_pkt_rate.count             tx.tx_aal5_scheduled_frames_rate        tx.tx_aal5_scheduled_frames_rate.min    tx.tx_aal5_scheduled_frames_rate.max    tx.tx_aal5_scheduled_frames_rate.avg    tx.tx_aal5_scheduled_frames_rate.sum    tx.tx_aal5_scheduled_frames_rate.count  }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               _default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Transmit Duration(Cleared on Start Tx)" {
                                           {hltName     {tx.elapsed_time                        tx.elapsed_time.min                     tx.elapsed_time.max                     tx.elapsed_time.avg                     tx.elapsed_time.sum                     tx.elapsed_time.count                   }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Tx. Rate (Kbps)"             {
                                           {hltName     {tx.pkt_kbit_rate                       tx.pkt_kbit_rate.min                    tx.pkt_kbit_rate.max                    tx.pkt_kbit_rate.avg                    tx.pkt_kbit_rate.sum                    tx.pkt_kbit_rate.count                  }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Tx. Rate (Mbps)"             {
                                           {hltName     {tx.pkt_mbit_rate                       tx.pkt_mbit_rate.min                    tx.pkt_mbit_rate.max                    tx.pkt_mbit_rate.avg                    tx.pkt_mbit_rate.sum                    tx.pkt_mbit_rate.count                  }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Tx. Rate (bps)"              {
                                           {hltName     {tx.pkt_bit_rate                        tx.pkt_bit_rate.min                     tx.pkt_bit_rate.max                     tx.pkt_bit_rate.avg                     tx.pkt_bit_rate.sum                     tx.pkt_bit_rate.count                   }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Valid Frames Rx."            {
                                           {hltName     {rx.raw_pkt_count                       rx.raw_pkt_count.min                    rx.raw_pkt_count.max                    rx.raw_pkt_count.avg                    rx.raw_pkt_count.sum                    rx.raw_pkt_count.count                  rx.total_pkts                          rx.total_pkts.min                       rx.total_pkts.max                       rx.total_pkts.avg                       rx.total_pkts.sum                       rx.total_pkts.count                     }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               _default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Valid Frames Rx. Rate"       {
                                           {hltName     {rx.raw_pkt_rate                        rx.raw_pkt_rate.min                     rx.raw_pkt_rate.max                     rx.raw_pkt_rate.avg                     rx.raw_pkt_rate.sum                     rx.raw_pkt_rate.count                   }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 1"         {
                                           {hltName     {rx.uds1_frame_count                     rx.uds1_frame_count.min                 rx.uds1_frame_count.max                 rx.uds1_frame_count.avg                 rx.pkt_rate.sum                         rx.uds1_frame_count.count               }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 1 Rate"    {
                                           {hltName     {rx.uds1_frame_rate                      rx.uds1_frame_rate.min                  rx.uds1_frame_rate.max                  rx.uds1_frame_rate.avg                  rx.uds1_frame_rate.sum                  rx.uds1_frame_rate.count                }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 2"         {
                                           {hltName     {rx.uds2_frame_count                     rx.uds2_frame_count.min                 rx.uds2_frame_count.max                 rx.uds2_frame_count.avg                 rx.pkt_rate.sum                         rx.uds2_frame_count.count               }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 2 Rate"    {
                                           {hltName     {rx.uds2_frame_rate                      rx.uds2_frame_rate.min                  rx.uds2_frame_rate.max                  rx.uds2_frame_rate.avg                  rx.uds2_frame_rate.sum                  rx.uds2_frame_rate.count                }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 3"         {
                                           {hltName     {rx.uds3_frame_count                     rx.uds3_frame_count.min                 rx.uds3_frame_count.max                 rx.uds3_frame_count.avg                 rx.pkt_rate.sum                         rx.uds3_frame_count.count               }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 3 Rate"    {
                                           {hltName     {rx.uds3_frame_rate                      rx.uds3_frame_rate.min                  rx.uds3_frame_rate.max                  rx.uds3_frame_rate.avg                  rx.uds3_frame_rate.sum                  rx.uds3_frame_rate.count                }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 4"         {
                                           {hltName     {rx.uds4_frame_count                     rx.uds4_frame_count.min                 rx.uds4_frame_count.max                 rx.uds4_frame_count.avg                 rx.pkt_rate.sum                         rx.uds4_frame_count.count               }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 4 Rate"    {
                                           {hltName     {rx.uds4_frame_rate                      rx.uds4_frame_rate.min                  rx.uds4_frame_rate.max                  rx.uds4_frame_rate.avg                  rx.uds4_frame_rate.sum                  rx.uds4_frame_rate.count                }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 5"         {
                                           {hltName     {rx.uds5_frame_count                     rx.uds5_frame_count.min                 rx.uds5_frame_count.max                 rx.uds5_frame_count.avg                 rx.pkt_rate.sum                         rx.uds5_frame_count.count               }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 5 Rate"    {
                                           {hltName     {rx.uds5_frame_rate                      rx.uds5_frame_rate.min                  rx.uds5_frame_rate.max                  rx.uds5_frame_rate.avg                  rx.uds5_frame_rate.sum                  rx.uds5_frame_rate.count                }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 6"         {
                                           {hltName     {rx.uds6_frame_count                     rx.uds6_frame_count.min                 rx.uds6_frame_count.max                 rx.uds6_frame_count.avg                 rx.pkt_rate.sum                         rx.uds6_frame_count.count               }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "User Defined Stat 6 Rate"    {
                                           {hltName     {rx.uds6_frame_rate                      rx.uds6_frame_rate.min                  rx.uds6_frame_rate.max                  rx.uds6_frame_rate.avg                  rx.uds6_frame_rate.sum                  rx.uds6_frame_rate.count                }}
                                           {statType    {none                                    min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                  strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                                aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
        }
        
        array set portStatsArrayDataPlane {
            "Rx Frames"                   {
                                           {hltName     {rx.pkt_count                           rx.pkt_count.min                        rx.pkt_count.max                        rx.pkt_count.avg                        rx.pkt_count.sum                        rx.pkt_count.count                      }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Rx Frame Rate"              {
                                           {hltName     {rx.pkt_rate                            rx.pkt_rate.min                         rx.pkt_rate.max                         rx.pkt_rate.avg                         rx.pkt_rate.sum                         rx.pkt_rate.count                       }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Tx Frames"                   {
                                           {hltName     {tx.pkt_count                           tx.pkt_count.min                        tx.pkt_count.max                        tx.pkt_count.avg                        tx.pkt_count.sum                        tx.pkt_count.count                      }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
            "Tx Frame Rate"              {
                                           {hltName     {tx.pkt_rate                            tx.pkt_rate.min                         tx.pkt_rate.max                         tx.pkt_rate.avg                         tx.pkt_rate.sum                         tx.pkt_rate.count                       }}
                                           {statType    {none                                   min                                     max                                     avg                                     sum                                     count                                   }}
                                           {ixnNameType {strict                                 strict                                  strict                                  strict                                  strict                                  strict                                  }}
                                           {prefixKey   {_default                               aggregate                               aggregate                               aggregate                               aggregate                               aggregate                               }}
                                          }
        }
        
        if {![info exists port_handle]} {
            set port_handle [array names ixnetwork_port_handles_array]
        }
        
        ################################
        # Create the Port statistic view
        ################################
        set create_ret_code [540CreateProtocolPortView -port_handle $port_handle]
        if {[keylget create_ret_code status] != $::SUCCESS} {
            return $create_ret_code
        }
        set protocol_port_view      [keylget create_ret_code protocol_port_view]
        set protocol_port_view_name [ixNetworkGetAttr $protocol_port_view -caption]
        
        # Extract data plane tx/rx packets when possible...
        if {$::ixia::snapshot_stats} {
            set data_plane_port_view_name "Data Plane Port Statistics"
            set data_plane_view_found 0
            foreach tmp_view [ixNet getList [ixNet getRoot]statistics view] {
                if {[ixNet getA $tmp_view -caption] == $data_plane_port_view_name} {
                    set data_plane_view_found 1
                    break
                }
            }
            
            
            set stat_view_list $protocol_port_view_name
            if {$data_plane_view_found} {
                lappend stat_view_list $data_plane_port_view_name
            }
            set retCode [540GetMultipleStatViewSnapshot $stat_view_list $mode]
            
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get snapshot with $stat_view_list, while\
                        retrieving aggregate statistics. [keylget retCode log]"
                return $returnList
            }
            
            set csvList         [keylget retCode csv_file_list]
            set maxTrkCountList [keylget retCode max_trk_count_list]
            if {$return_method == "csv"} {
                foreach csv_elem $csvList {
                    set ::ixia::clear_csv_stats($csv_elem) $csv_elem
                }
                keylset returnList status $::SUCCESS
                keylset returnList csv_file $csvList
                return $returnList
            }
            
            set portStatsCode [540ParseCsvFromSnapshot [lindex $csvList 0] [lindex $maxTrkCountList 0] $protocol_port_view_name]
            if {$data_plane_view_found} {
                set dataPlaneCode [540ParseCsvFromSnapshot [lindex $csvList 1] [lindex $maxTrkCountList 1] $data_plane_port_view_name]
            } else {
                keylset dataPlaneCode status $::FAILURE
            }
            
        } else {
            set dataPlaneCode [540GetStatView "Data Plane Port Statistics" $mode]
        }
        
        if {[keylget dataPlaneCode status] == $::FAILURE} {
            set dataPlaneFlag 0
        } else {
            set dataPlanePageCount          [keylget dataPlaneCode page]
            set dataPlaneRowCount           [keylget dataPlaneCode row]
            array set dataPlaneRowsArray    [keylget dataPlaneCode rows]
            set dataPlaneFlag 1
            
            # Data plane port page row array
            catch {unset dataPlanePortPrArray}
            array set dataPlanePortPrArray ""
            
            # Create an array indexed by port handle. The keys will be the page,row value
            for {set i 1} {$i < $dataPlanePageCount} {incr i} {
                for {set j 1} {$j < $dataPlaneRowCount} {incr j} {
                    if {![info exists dataPlaneRowsArray($i,$j)]} { continue }
                    set dataPlaneRowName $dataPlaneRowsArray($i,$j)
                    
                    set rx_port_status [ixNetworkGetVportByName $dataPlaneRowName]
                    if {[keylget rx_port_status status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to get 'Data Plane Port Statistics' while\
                                retrieving aggregate statistics, because the virtual port with the\
                                '$dataPlaneRowName' name could not be found. [keylget rx_port_status log]"
                        return $returnList
                    }
                    set dataPlaneRowName [keylget rx_port_status port_handle]
                    
                    set dpmatched [regexp {([0-9]+)/([0-9]+)/([0-9]+)} \
                            $dataPlaneRowName matched_str dpch dpcd dppt]
                    
                    if {!$dpmatched} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to get 'Data Plane Port Statistics' while\
                                retrieving aggregate statistics,\
                                because port number could not be identified. $dataPlaneRowName did not\
                                match the HLT port format chassis/card/port. This can occur if\
                                the test was not configured with HLT."
                        return $returnList
                    }
                    
                    if { [string length $dpch] > 1 } {
                        set dpch [string trimleft $dpch 0]
                    } else {
                        set dpch [string trimleft $dpch]
                    }
                    if { [string length $dpcd] > 1 } {
                        set dpcd [string trimleft $dpcd 0]
                    } else {
                        set dpcd [string trimleft $dpcd]
                    }
                    set dppt [string trimleft $dppt 0]
                    
                    set dpStatPort $dpch/$dpcd/$dppt
                    set dataPlanePortPrArray($dpStatPort) [list $i $j]
                }
            }
        }
        
        if {$::ixia::snapshot_stats} {
            #
        } else {
            set portStatsCode [540GetStatView $protocol_port_view_name $mode]
        }
        if {[keylget portStatsCode status] == $::FAILURE} {
            return $portStatsCode
        }
        set pageCount [keylget portStatsCode page]
        set rowCount  [keylget portStatsCode row]
        array set rowsArray [keylget portStatsCode rows]
        set remaining_ports $port_handle
        for {set i 1} {$i < $pageCount} {incr i} {
            for {set j 1} {$j < $rowCount} {incr j} {
                if {![info exists rowsArray($i,$j)]} { continue }
                set rowName $rowsArray($i,$j)
                
                set matched [regexp {(.+)/Card([0-9]{2})/Port([0-9]{2})} \
                        $rowName matched_str hostname cd pt]
                if {$matched && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                    set ch_ip $hostname
                }
                
                if {!$matched} {
                    set rx_port_status [ixNetworkGetVportByName $rowName]
                    if {[keylget rx_port_status status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to get 'Port Statistics' while\
                                retrieving aggregate statistics, because the virtual port with the\
                                '$rowName' name could not be found. [keylget rx_port_status log]"
                        return $returnList
                    }
                    set rowName [keylget rx_port_status port_handle]
                    
                    set matched [regexp {([0-9]+)/([0-9]+)/([0-9]+)} \
                            $rowName matched_str ch cd pt]
                }
                
                if {!$matched} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get 'Port Statistics',\
                            because port number could not be identified. $rowName did not\
                            match the HLT port format ChassisIP/card/port. This can occur if\
                            the test was not configured with HLT."
                    return $returnList
                }
                
                if {$matched && ($matched_str == $rowName) && \
                        [info exists ch_ip] && [info exists cd] && \
                        [info exists pt] } {
                    set ch [ixNetworkGetChassisId $ch_ip]
                }
                set cd [string trimleft $cd 0]
                set pt [string trimleft $pt 0]

                set statPort $ch/$cd/$pt
                set [subst $keyed_array_name](${statPort}.aggregate.rx.pkt_bit_count) "N/A"
                set [subst $keyed_array_name](${statPort}.aggregate.tx.pkt_bit_count) "N/A"

                if {[lsearch $port_handle $statPort] != -1} {
                    set pos [lsearch $remaining_ports $statPort]
                    if {$pos != -1} {
                        set remaining_ports [lreplace $remaining_ports $pos $pos]
                    }
                    foreach statName [array names portStatsArray] {
                        if {![info exists portStatsArray($statName)]  } {continue}
                        
                        set portStatsArrayValue $portStatsArray($statName)
                        
                        set retStatNameList [keylget portStatsArrayValue hltName]
                        set statTypeList    [keylget portStatsArrayValue statType]
                        set ixnNameTypeList [keylget portStatsArrayValue ixnNameType]
                        set prefixKeyList   [keylget portStatsArrayValue prefixKey]
                        
                        #foreach retStatName $portStatsArray($statName) {
                            #set [subst $keyed_array_name]($statPort.$retStatName) $rowsArray($i,$j,$statName)
                            #incr keyed_array_index
                        #}
                        
                        foreach retStatName $retStatNameList statType $statTypeList ixnNameType $ixnNameTypeList prefixKey $prefixKeyList {

                            switch $prefixKey {
                                "_default" {
                                    set current_key "${statPort}.aggregate.${retStatName}"
                                }
                                default {
                                    set current_key "${prefixKey}.${retStatName}"
                                }
                            }
                            
                            if {![info exists rowsArray($i,$j,$statName)] } {
                                set [subst $keyed_array_name]($current_key) "N/A"
                                continue
                            }
                            
                            if {$ixnNameType == "regex"} {
                                set names [array names rowsArray -regexp (1,1,(\[^,\]*)[regsub { } $statName {\\ }])]
#                                    puts "names == $names"
                                if {[llength $names] == 0} {
                                    # Do nothing. Stat name will not be found
                                } else {
                                    set statName [lindex [split [lindex $names 0] ,] end]
                                }
                            }
                            
                            if {![info exists rowsArray($i,$j,$statName)] } {
                                
                                if {![catch {set [subst $keyed_array_name]($current_key)} overlap_key_val]} {
                                    
                                    # Leave the value as it it
                                    # This is used for the various latency keys which map to the same subset of hlt keys
                                    # If the Cut-Through key was found we don't want to overwrite it with N/A
                                    
                                    continue
                                } else {
                                    set [subst $keyed_array_name]($current_key) "N/A"
                                    incr keyed_array_index
                                    continue
                                }
                            }


#                               puts "string first \"tx.\" $retStatName"
                            if {[catch {set [subst $keyed_array_name]($current_key)} oldValue]} {
                                if {$statType == "count"} {
                                    set [subst $keyed_array_name]($current_key) 1
                                } else {
                                    set [subst $keyed_array_name]($current_key) $rowsArray($i,$j,$statName)
                                }
                                if {$statType == "avg"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A"} {
                                        set avg_calculator_array([subst $keyed_array_name],$current_key) 1
                                    } else {
                                        set avg_calculator_array([subst $keyed_array_name],$current_key) 0
                                    }
                                }
                                
                                incr keyed_array_index
                            } else {
                                if {$statType == "sum"} {
#                                             puts "oldValue == $oldValue"
                                    set [subst $keyed_array_name]($current_key) [math_incr $rowsArray($i,$j,$statName) $oldValue]
                                    incr keyed_array_index

                                } elseif {$statType == "avg"} {
#                                             puts "oldValue == $oldValue"
                                    set [subst $keyed_array_name]($current_key) [math_incr $rowsArray($i,$j,$statName) $oldValue]
                                    if {$rowsArray($i,$j,$statName) != "N/A"} {
                                        incr avg_calculator_array([subst $keyed_array_name],$current_key)
                                    }
                                    incr keyed_array_index
                                
                                } elseif {$statType == "max"} {
                                    set [subst $keyed_array_name]($current_key) [math_max $oldValue $rowsArray($i,$j,$statName)]
                                    incr keyed_array_index
                                } elseif {$statType == "min"} {
                                    set [subst $keyed_array_name]($current_key) [math_min $oldValue $rowsArray($i,$j,$statName)]
                                    incr keyed_array_index
                                } elseif {$statType == "count"} {
                                    set [subst $keyed_array_name]($current_key) [math_incr $oldValue 1]
                                    incr keyed_array_index
                                } else {
                                    set [subst $keyed_array_name]($current_key) $rowsArray($i,$j,$statName)
                                    incr keyed_array_index
                                }
                            }
                        }
                        
                    }
                    
                    # Add data plane stats - Begin
                    foreach statName [array names portStatsArrayDataPlane] {
                        set not_avail_flag_dp 0
                        if {$dataPlaneFlag} {
                            if {![info exists dataPlanePortPrArray($statPort)]} {
                                debug "Data Plane stats not available for $statPort"
                                debug "dataPlanePortPrArray == [array get dataPlanePortPrArray]"
                                debug "dataPlaneRowsArray == [array get dataPlaneRowsArray]"
                                set not_avail_flag_dp 1
                            } else {
                                foreach {dpI dpJ} $dataPlanePortPrArray($statPort) {}
                                
                                if {![info exists dataPlaneRowsArray($dpI,$dpJ,$statName)]} {
                                    debug "Data Plane stats not available for stat $statName on port $statPort"
                                    debug "dataPlanePortPrArray == [array get dataPlanePortPrArray]"
                                    debug "dataPlaneRowsArray == [array get dataPlaneRowsArray]"
                                    set not_avail_flag_dp 1
                                }
                            }
                        } else {
                            set not_avail_flag_dp 1
                        }
                        
                        if {$not_avail_flag_dp} {
                            set currentDpStatValue 0
                        } else {
                            set currentDpStatValue $dataPlaneRowsArray($dpI,$dpJ,$statName)
                        }
                        
                        set portStatsArrayDataPlaneValue $portStatsArrayDataPlane($statName)
                        
                        set retStatNameList [keylget portStatsArrayDataPlaneValue hltName]
                        set statTypeList    [keylget portStatsArrayDataPlaneValue statType]
                        set ixnNameTypeList [keylget portStatsArrayDataPlaneValue ixnNameType]
                        set prefixKeyList   [keylget portStatsArrayDataPlaneValue prefixKey]
                        
                        foreach retStatName $retStatNameList statType $statTypeList ixnNameType $ixnNameTypeList prefixKey $prefixKeyList {

                            switch $prefixKey {
                                "_default" {
                                    set current_key "${statPort}.aggregate.${retStatName}"
                                }
                                default {
                                    set current_key "${prefixKey}.${retStatName}"
                                }
                            }
                            
                            if {$ixnNameType == "regex"} {
                                set names [array names dataPlaneRowsArray -regexp (1,1,(\[^,\]*)[regsub { } $statName {\\ }])]
#                                    puts "names == $names"
                                if {[llength $names] == 0} {
                                    # Do nothing. Stat name will not be found
                                } else {
                                    set statName [lindex [split [lindex $names 0] ,] end]
                                }
                            }
                            
#                               puts "string first \"tx.\" $retStatName"
                            if {[catch {set [subst $keyed_array_name]($current_key)} oldValue]} {
                                if {$statType == "count"} {
                                    set [subst $keyed_array_name]($current_key) 1
                                } else {
                                    set [subst $keyed_array_name]($current_key) $currentDpStatValue
                                }
                                if {$statType == "avg"} {
                                    if {$currentDpStatValue != "N/A"} {
                                        set avg_calculator_array([subst $keyed_array_name],$current_key) 1
                                    } else {
                                        set avg_calculator_array([subst $keyed_array_name],$current_key) 0
                                    }
                                }
                                
                                incr keyed_array_index
                            } else {
                                if {$statType == "sum"} {
#                                             puts "oldValue == $oldValue"
                                    set [subst $keyed_array_name]($current_key) [math_incr $currentDpStatValue $oldValue]
                                    incr keyed_array_index

                                } elseif {$statType == "avg"} {
#                                             puts "oldValue == $oldValue"
                                    set [subst $keyed_array_name]($current_key) [math_incr $currentDpStatValue $oldValue]
                                    if {$currentDpStatValue != "N/A"} {
                                        incr avg_calculator_array([subst $keyed_array_name],$current_key)
                                    }
                                    incr keyed_array_index
                                
                                } elseif {$statType == "max"} {
                                    set [subst $keyed_array_name]($current_key) [math_max $oldValue $currentDpStatValue]
                                    incr keyed_array_index
                                } elseif {$statType == "min"} {
                                    set [subst $keyed_array_name]($current_key) [math_min $oldValue $currentDpStatValue]
                                    incr keyed_array_index
                                } elseif {$statType == "count"} {
                                    set [subst $keyed_array_name]($current_key) [math_incr $oldValue 1]
                                    incr keyed_array_index
                                } else {
                                    set [subst $keyed_array_name]($current_key) $currentDpStatValue
                                    incr keyed_array_index
                                }
                            }
                        }
                    }
                    # Add data plane stats - End
                }
            }
        }
        

        
        if {$remaining_ports != ""} {
            foreach port_item $remaining_ports {
                foreach statsArrayName {portStatsArray portStatsArrayDataPlane} {
                    foreach statName [array names $statsArrayName] {
                        set psValue [set [set statsArrayName]($statName)]
                            
                        set retStatNameList [keylget psValue hltName]
                        set statTypeList    [keylget psValue statType]
                        set ixnNameTypeList [keylget psValue ixnNameType]
                        set prefixKeyList   [keylget psValue prefixKey]
                        
                        foreach retStatName $retStatNameList statType $statTypeList ixnNameType $ixnNameTypeList prefixKey $prefixKeyList {

                            switch $prefixKey {
                                "_default" {
                                    set current_key "${port_item}.aggregate.${retStatName}"
                                }
                                default {
                                    set current_key "${prefixKey}.${retStatName}"
                                }
                            }
                            set [subst $keyed_array_name]($current_key) "N/A"
                        }
                    }
                }
            }
        }
    }
    
    if {$mode == "stream" || $mode == "streams"  || $mode == "all"} {
        # This array has the following meaning
        # index: IxN stat name
        # value: a keyed list with the following keys 
        # - hltName  - the name of the HLT stat to be returned
        # - statType - the type of the stat: sum, avg, or none
        
        catch { array unset trafficStatsArray }
        array set trafficStatsArray {
            "Tx Frames"                 {{hltName tx.total_pkts}               {statType sum}   {ixnNameType strict}}
            "Rx Frames"                 {{hltName rx.total_pkts}               {statType sum}   {ixnNameType strict}}
            "Rx Expected Frames"        {{hltName rx.expected_pkts}            {statType sum}   {ixnNameType strict}}
            "Frames Delta"              {{hltName rx.loss_pkts}                {statType sum}   {ixnNameType strict}}
            "Rx Frame Rate"             {{hltName rx.total_pkt_rate}           {statType avg}   {ixnNameType strict}}
            "Tx Frame Rate"             {{hltName tx.total_pkt_rate}           {statType avg}   {ixnNameType strict}}
            "Loss %"                    {{hltName rx.loss_percent}             {statType sum}   {ixnNameType strict}}
            "Packet Loss Duration (ms)" {{hltName rx.pkt_loss_duration}        {statType avg}   {ixnNameType strict}}
            "Rx Bytes"                  {{hltName {rx.total_pkts_bytes rx.total_pkt_bytes}} {statType {sum sum}}   {ixnNameType {strict strict}}}
            "Rx Rate (Bps)"             {{hltName rx.total_pkt_byte_rate}      {statType avg}   {ixnNameType strict}}
            "Rx Rate (bps)"             {{hltName rx.total_pkt_bit_rate}       {statType avg}   {ixnNameType strict}}
            "Rx Rate (Kbps)"            {{hltName rx.total_pkt_kbit_rate}      {statType avg}   {ixnNameType strict}}
            "Rx Rate (Mbps)"            {{hltName rx.total_pkt_mbit_rate}      {statType avg}   {ixnNameType strict}}
            "First TimeStamp"           {{hltName rx.first_tstamp}             {statType none}  {ixnNameType strict}}
            "Last TimeStamp"            {{hltName rx.last_tstamp}              {statType none}  {ixnNameType strict}}
            "Small Error"               {{hltName rx.small_error}              {statType sum}   {ixnNameType strict}}
            "Big Error"                 {{hltName rx.big_error}                {statType sum}   {ixnNameType strict}}
            "Reverse Error"             {{hltName rx.reverse_error}            {statType sum}   {ixnNameType strict}}
        }
        
        set latency_stat_prefix_name [ixNetworkGetLatencyNamePrefix]
        
        set trafficStatsArray($latency_stat_prefix_name\ Avg\ Latency\ \(ns\))\
                {{hltName rx.avg_delay}                {statType avg}   {ixnNameType strict }}
                
        set trafficStatsArray($latency_stat_prefix_name\ Min\ Latency\ \(ns\))\
                {{hltName rx.min_delay}                {statType avg}   {ixnNameType strict }}
                
        set trafficStatsArray($latency_stat_prefix_name\ Max\ Latency\ \(ns\))\
                {{hltName rx.max_delay}                {statType avg}   {ixnNameType strict }}
        
        set latency_bins_view ""
        array set view_ti_map ""
        lappend latency_bins_view "Flow Statistics"
        foreach stream_obj $streamObjects {
            
            set ti_handle $stream_obj
            
            # Build latency view for this traffic item
            set ret_code [540CreateLatencyStatsView -traffic_item $ti_handle]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set latency_view_tmp [keylget ret_code latency_view]
            
            if {[llength $latency_view_tmp] > 0} {
                lappend latency_bins_view [ixNet getA $latency_view_tmp -caption]
                set view_ti_map([ixNet getA $latency_view_tmp -caption]) $ti_handle
            }
        }
        
        # First collect all stats from all views to reduce differences in stat values
        catch {array unset all_views_stats_array}
        array set all_views_stats_array ""
        set view_index 0
        set is_latency_view 0
        foreach view_name $latency_bins_view {
            if {$view_index > 0} {
                set is_latency_view 1
            }
            if {$::ixia::snapshot_stats} {
                if {$return_method == "csv"} {
                    set retCode [540GetStatViewSnapshot $view_name $mode $is_latency_view "" 1]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to get snapshot $view_name, while\
                                retrieving stream statistics. [keylget retCode log]"
                        return $returnList
                    }
                    set csvList         [keylget retCode csv_file]
                    set ::ixia::clear_csv_stats($csvList) $csvList
                    return $retCode
                } else {
                    set retCode [540GetStatViewSnapshot $view_name $mode $is_latency_view]
                }
            } else {
                set retCode [540GetStatView $view_name $mode $is_latency_view]
            }
            set all_views_stats_array($view_name) $retCode
            incr view_index
        }
        
        set view_index 0
        set is_latency_view 0
        foreach view_name $latency_bins_view {
            
            if {$view_index > 0} {
                set is_latency_view 1
                set ti_for_view $view_ti_map($view_name)
                
                if {[ixNet getA $ti_for_view/tracking/latencyBin -enabled] != "true"} {
                    continue
                }
                
                # Get list of latency bins
                set bin_limits [ixNet getA $ti_for_view/tracking/latencyBin -binLimits]
                catch {array unset trafficStatsArray}
                array set trafficStatsArray ""
                set bin_idx 1
                foreach single_bin $bin_limits {
                    if {[regexp {(\.)(0+$)} $single_bin]} {
                        # number is integer
                        set single_bin_formatted [format %.0f $single_bin]
                    } else {
                        # number if float
#                         puts "set single_bin_formatted \[string trimright $single_bin 0\] --> [string trimright $single_bin 0]"
                        set single_bin_formatted [string trimright $single_bin 0]
                    }
                    
                    if {$bin_idx == 1} {
                        set ixn_bin_string "0us - ${single_bin_formatted}us"
                    } elseif {[lindex $bin_limits end] == $single_bin} {
                        set prev_bin [lindex $bin_limits [expr $bin_idx - 2]]
                        if {[regexp {(\.)(0+$)} $prev_bin]} {
                            # number is integer
                            set prev_bin [format %.0f $prev_bin]
                        } else {
                            # number if float
                            set prev_bin [string trimright $prev_bin 0]
                        }
                        set ixn_bin_string "${prev_bin}us - maxus"
                    } else {
                        set prev_bin [lindex $bin_limits [expr $bin_idx - 2]]
                        if {[regexp {(\.)(0+$)} $prev_bin]} {
                            # number is integer
                            set prev_bin [format %.0f $prev_bin]
                        } else {
                            # number if float
#                             puts "set prev_bin \[string trimright $prev_bin 0\] --> [string trimright $prev_bin 0]"
                            set prev_bin [string trimright $prev_bin 0]
                        }
                        set ixn_bin_string "${prev_bin}us - ${single_bin_formatted}us"
                    }

                    set trafficStatsArray(Rx\ Frames\ per\ Bin\ :\ $ixn_bin_string)             [list [list hltName rx.latency_bin.$bin_idx.total_pkts]     [list statType sum]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Frame\ Rate\ per\ Bin\ :\ $ixn_bin_string)        [list [list hltName rx.latency_bin.$bin_idx.pkt_frame_rate] [list statType avg]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Bytes\ per\ Bin\ :\ $ixn_bin_string)              [list [list hltName rx.latency_bin.$bin_idx.total_bytes]    [list statType sum]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Rate\ \(Bps\)\ per\ Bin\ :\ $ixn_bin_string)      [list [list hltName rx.latency_bin.$bin_idx.pkt_byte_rate]  [list statType avg]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Rate\ \(bps\)\ per\ Bin\ :\ $ixn_bin_string)      [list [list hltName rx.latency_bin.$bin_idx.pkt_bit_rate]   [list statType avg]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Rate\ \(Kbps\)\ per\ Bin\ :\ $ixn_bin_string)     [list [list hltName rx.latency_bin.$bin_idx.pkt_kbit_rate]  [list statType avg]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Rate\ \(Mbps\)\ per\ Bin\ :\ $ixn_bin_string)     [list [list hltName rx.latency_bin.$bin_idx.pkt_mbit_rate]  [list statType avg]  [list ixnNameType strict]]
                    set trafficStatsArray($latency_stat_prefix_name\ Avg\ Latency\ \(ns\)\ per\ Bin\ :\ $ixn_bin_string)   [list [list hltName rx.latency_bin.$bin_idx.avg]            [list statType avg]  [list ixnNameType strict ]]
                    set trafficStatsArray($latency_stat_prefix_name\ Min\ Latency\ \(ns\)\ per\ Bin\ :\ $ixn_bin_string)   [list [list hltName rx.latency_bin.$bin_idx.min]            [list statType avg]  [list ixnNameType strict ]]
                    set trafficStatsArray($latency_stat_prefix_name\ Max\ Latency\ \(ns\)\ per\ Bin\ :\ $ixn_bin_string)   [list [list hltName rx.latency_bin.$bin_idx.max]            [list statType avg]  [list ixnNameType strict ]]
                    set trafficStatsArray(First\ TimeStamp\ per\ Bin\ :\ $ixn_bin_string)       [list [list hltName rx.latency_bin.$bin_idx.first_tstamp]   [list statType none] [list ixnNameType strict]]
                    set trafficStatsArray(Last\ TimeStamp\ per\ Bin\ :\ $ixn_bin_string)        [list [list hltName rx.latency_bin.$bin_idx.last_tstamp]    [list statType none] [list ixnNameType strict]]
                    
                    incr bin_idx
                }
            }
            
            set retCode $all_views_stats_array($view_name)
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            
            set pageCount [keylget retCode page]
            set rowCount  [keylget retCode row]
            catch {array unset rowsArray}
            array set rowsArray [keylget retCode rows]
            set resetPortList ""
            for {set i 1} {$i < $pageCount} {incr i} {
                for {set j 1} {$j < $rowCount} {incr j} {
                    if {![info exists rowsArray($i,$j)]} { continue }
    #                 puts "-->ixNetworkParseRowName $rowsArray($i,$j)"
                    if {$is_latency_view && [info exists ti_for_view]} {
                        set rowInfo [ixNet getA $ti_for_view -name]
                    } else {
                        set rowInfo     $rowsArray($i,$j)
                    }
                    
                    if {[llength $rowInfo] > 1} {
                        # The row info is composed from rxport ti_name tracking_f1 tracking_f2 ...
                        set rowInfo [lindex $rowInfo 1]
                    }
                    
                    if {!$is_latency_view} {
                        set txPort      $rowsArray($i,$j,Tx Port)
                    }
                    set rxPort      $rowsArray($i,$j,Rx Port)
                    set trafficName $rowInfo

                    if {$txPort == "" && !$is_latency_view}      {continue}
                    if {$rxPort == "" }      {continue}
                    if {$trafficName == "" } {continue}
                    set streamId $trafficName
                    if {$streamNames != ""} {
                        if {[lsearch $streamNames $trafficName] != -1} {
                            foreach statName [array names trafficStatsArray] {
                                set trafficStatArrayValue $trafficStatsArray($statName)
                                

                                set retStatNameList [keylget trafficStatArrayValue hltName]
                                set statTypeList    [keylget trafficStatArrayValue statType]
                                set ixnNameType     [keylget trafficStatArrayValue ixnNameType]
                                
                                foreach retStatName $retStatNameList statType $statTypeList {

                                    if {$ixnNameType == "regex"} {
                                        set names [array names rowsArray -regexp ($i,$j,(\[^,\]*)[regsub { } $statName {\\ }])]
                                        if {[llength $names] == 0} {
                                            # Do nothing. Stat name will not be found
                                        } else {
                                            set statName [lindex [split [lindex $names 0] ,] end]
                                        }
                                    }
                                    
                                    if {![info exists rowsArray($i,$j,$statName)] } {
                                        if {[string first "tx." $retStatName] != -1} {
                                            set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) "N/A"
                                            incr keyed_array_index
                                        }
                                        if {[string first "rx." $retStatName] != -1} {
                                            set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) "N/A"
                                            incr keyed_array_index
                                        }
                                        continue
                                    }
                                    if {[string first "tx." $retStatName] != -1} {
                                        if {[catch {set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName)} oldValue]} {
                                            set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                            if {$statType == "avg"} {
                                                if {$rowsArray($i,$j,$statName) != "N/A"} {
                                                    set avg_calculator_array([subst $keyed_array_name],$txPort.stream.$trafficName.$retStatName) 1
                                                } else {
                                                    set avg_calculator_array([subst $keyed_array_name],$txPort.stream.$trafficName.$retStatName) 0
                                                }
                                            }
                                            incr keyed_array_index
                                        } else {
                                            if {$statType == "sum"} {
                                                if {$rowsArray($i,$j,$statName) != "N/A" && $oldValue != "" && $oldValue != "N/A"} {
                                                    set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                                    incr keyed_array_index
                                                }
                                            } elseif {$statType == "avg"} {
                                                if {$rowsArray($i,$j,$statName) != "N/A" && $oldValue != "" && $oldValue != "N/A"} {
                                                    set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                                    incr avg_calculator_array([subst $keyed_array_name],$txPort.stream.$trafficName.$retStatName)
                                                    incr keyed_array_index
                                                }
                                            } else {
                                                set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                                incr keyed_array_index
                                            }
                                            
                                        }
                                        
                                    }
                                    if {[string first "rx." $retStatName] != -1} {
                                        if {[catch {set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName)} oldValue]} {
                                            set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                            if {$statType == "avg"} {
                                                if {$rowsArray($i,$j,$statName) != "N/A"} {
                                                    set avg_calculator_array([subst $keyed_array_name],$rxPort.stream.$trafficName.$retStatName) 1
                                                } else {
                                                    set avg_calculator_array([subst $keyed_array_name],$rxPort.stream.$trafficName.$retStatName) 0
                                                }
                                            }
                                            incr keyed_array_index
                                        } else {
                                            if {$statType == "sum"} {
                                                if {$rowsArray($i,$j,$statName) != "N/A" && $oldValue != "" && $oldValue != "N/A"} {
                                                    set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                                    incr keyed_array_index
                                                }
                                            } elseif {$statType == "avg"} {
                                                if {$rowsArray($i,$j,$statName) != "N/A" && $oldValue != "" && $oldValue != "N/A"} {
                                                    set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                                    incr avg_calculator_array([subst $keyed_array_name],$rxPort.stream.$trafficName.$retStatName)
                                                    incr keyed_array_index
                                                }
                                            } else {
                                                set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                                incr keyed_array_index
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            incr view_index
        }
    }
    
    if {$mode == "per_port_flows" || $mode == "all"} {
        # This array has the following meaning
        # index: IxN stat name
        # value: a keyed list with the following keys 
        # - hltName  - the name of the HLT stat to be returned
        # - statType - the type of the stat: sum, avg, or none
        catch { array unset trafficStatsArray }
        array set trafficStatsArray {
            "Tx Frames"                 {{hltName tx.total_pkts}               {statType sum}}
            "Rx Frames"                 {{hltName rx.total_pkts}               {statType sum}}
            "Rx Expected Frames"        {{hltName rx.expected_pkts}            {statType sum}}
            "Frames Delta"              {{hltName rx.loss_pkts}                {statType sum}}
            "Rx Frame Rate"             {{hltName rx.total_pkt_rate}           {statType avg}}
            "Tx Frame Rate"             {{hltName tx.total_pkt_rate}           {statType avg}}
            "Loss %"                    {{hltName rx.loss_percent}             {statType sum}}
            "Packet Loss Duration (ms)" {{hltName rx.pkt_loss_duration}        {statType avg}}
            "Rx Bytes"                  {{hltName {rx.total_pkts_bytes rx.total_pkt_bytes} } {statType {sum sum}}}
            "Rx Rate (Bps)"             {{hltName rx.total_pkt_byte_rate}      {statType avg}}
            "Rx Rate (bps)"             {{hltName rx.total_pkt_bit_rate}       {statType avg}}
            "Rx Rate (Kbps)"            {{hltName rx.total_pkt_kbit_rate}      {statType avg}}
            "Rx Rate (Mbps)"            {{hltName rx.total_pkt_mbit_rate}      {statType avg}}
            "Avg Latency (ns)"          {{hltName rx.avg_delay}                {statType avg}}
            "Min Latency (ns)"          {{hltName rx.min_delay}                {statType avg}}
            "Max Latency (ns)"          {{hltName rx.max_delay}                {statType avg}}
            "First TimeStamp"           {{hltName rx.first_tstamp}             {statType none}}
            "Last TimeStamp"            {{hltName rx.last_tstamp}              {statType none}}
            "Small Error"               {{hltName rx.small_error}              {statType sum}}
            "Big Error"                 {{hltName rx.big_error}                {statType sum}}
            "Reverse Error"             {{hltName rx.reverse_error}            {statType sum}}
        }
        set flowNames ""
        if {$::ixia::snapshot_stats} {
            if {$return_method == "csv"} {
                set retCode [540GetStatViewSnapshot "Flow Statistics" $mode "0" "" 1]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get Flow Statistics snapshot, while\
                            retrieving stream statistics. [keylget retCode log]"
                    return $returnList
                }
                set csvList         [keylget retCode csv_file]
                set ::ixia::clear_csv_stats($csvList) $csvList
                return $retCode
            } else {
                set retCode [540GetStatViewSnapshot "Flow Statistics" $mode]
            }
        } else {
            set retCode [540GetStatView "Flow Statistics" $mode]
        }
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        
        set pageCount [keylget retCode page]
        set rowCount  [keylget retCode row]
        array set rowsArray [keylget retCode rows]
        set resetPortList ""
        set flow 0
        for {set i 1} {$i < $pageCount} {incr i} {
            for {set j 1} {$j < $rowCount} {incr j} {
                if {![info exists rowsArray($i,$j)]} { continue }    
                set rowInfo     $rowsArray($i,$j)
                set txPort      $rowsArray($i,$j,Tx Port)
                set rxPort      $rowsArray($i,$j,Rx Port)
                set trafficName $rowInfo
                set flow_name   $rowInfo
                
                set pgid        "N/A"
                
                if {$txPort == "" }      {continue}
                if {$rxPort == "" }      {continue}
                if {$flow_name  == "" }  {continue}
                set flow_name ${flow_name}
                
                mpincr flow
                set [subst $keyed_array_name]($txPort.flow.$flow.tx.flow_name)  $flow_name
                incr keyed_array_index
                
                set [subst $keyed_array_name]($txPort.flow.$flow.tx.pgid_value) $pgid
                incr keyed_array_index
                
                set [subst $keyed_array_name]($rxPort.flow.$flow.rx.flow_name)  $flow_name
                incr keyed_array_index
                
                set [subst $keyed_array_name]($rxPort.flow.$flow.rx.pgid_value) $pgid
                incr keyed_array_index
                
                foreach statName [array names trafficStatsArray] {
                    set trafficStatArrayValue $trafficStatsArray($statName)
                    set retStatNameList [keylget trafficStatArrayValue hltName]
                    set statTypeList    [keylget trafficStatArrayValue statType]
                    foreach retStatName $retStatNameList statType $statTypeList {
                        if {![info exists rowsArray($i,$j,$statName)] } {
                            set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) "N/A"
                            incr keyed_array_index
                            set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) "N/A"
                            incr keyed_array_index
                            continue
                        }
                        if {[string first "tx." $retStatName] != -1} {
                            if {[catch {set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName)} oldValue]} {
                                set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                if {$statType == "avg"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A"} {
                                        set avg_calculator_array([subst $keyed_array_name],$txPort.flow.$flow.$retStatName) 1
                                    } else {
                                        set avg_calculator_array([subst $keyed_array_name],$txPort.flow.$flow.$retStatName) 0
                                    }
                                }
                                incr keyed_array_index
                            } else {
                                if {$statType == "sum"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A" && $oldValue != "" && $oldValue != "N/A"} {
                                        set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                        incr keyed_array_index
                                    }
                                    
                                } elseif {$statType == "avg"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A" && $oldValue != "" && $oldValue != "N/A"} {
                                        set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                        incr avg_calculator_array([subst $keyed_array_name],$txPort.flow.$flow.$retStatName)
                                        incr keyed_array_index
                                
                                    }
                                } else {
                                    set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                    incr keyed_array_index
                                }
                            }
                            if {[catch {set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName)} oldValue]} {
                                set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) 0
                                incr keyed_array_index
                            }
                        }
                        if {[string first "rx." $retStatName] != -1} {
                            if {[catch {set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName)} oldValue] } {
                                set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                if {$statType == "avg"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A"} {
                                        set avg_calculator_array([subst $keyed_array_name],$rxPort.flow.$flow.$retStatName) 1
                                    } else {
                                        set avg_calculator_array([subst $keyed_array_name],$rxPort.flow.$flow.$retStatName) 0
                                    }
                                }
                                incr keyed_array_index
                            } else {
                                if {$statType == "sum"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A" && $oldValue != "" && $oldValue != "N/A"} {
                                        set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                        incr keyed_array_index
                                    }
                                } elseif {$statType == "avg"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A" && $oldValue != "" && $oldValue != "N/A"} {
                                        set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                        incr avg_calculator_array([subst $keyed_array_name],$rxPort.flow.$flow.$retStatName)
                                        incr keyed_array_index
                                    }
                                } else {
                                    set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                    incr keyed_array_index
                                }
                            }
                            if {[catch {set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName)} oldValue] } {
                                set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) 0
                                incr keyed_array_index
                            }
                        }
                    }
                }
            }
        }
    }
    
    if {$mode == "flow" || $mode == "all"} {
        # This array has the following meaning
        # index: IxN stat name
        # value: a keyed list with the following keys 
        # - hltName  - the name of the HLT stat to be returned
        # - statType - the type of the stat: sum, avg, or none
        
        catch { array unset registered_flows  }
        array set registered_flows ""
        
        catch { array unset trafficStatsArray }
        array set trafficStatsArray {
            "Tx Frames"                 {{hltName tx.total_pkts}               {statType sum}   {ixnNameType strict}}
            "Rx Frames"                 {{hltName rx.total_pkts}               {statType sum}   {ixnNameType strict}}
            "Rx Expected Frames"        {{hltName rx.expected_pkts}            {statType sum}   {ixnNameType strict}}
            "Frames Delta"              {{hltName rx.loss_pkts}                {statType sum}   {ixnNameType strict}}
            "Rx Frame Rate"             {{hltName rx.total_pkt_rate}           {statType avg}   {ixnNameType strict}}
            "Tx Frame Rate"             {{hltName tx.total_pkt_rate}           {statType avg}   {ixnNameType strict}}
            "Loss %"                    {{hltName rx.loss_percent}             {statType sum}   {ixnNameType strict}}
            "Packet Loss Duration (ms)" {{hltName rx.pkt_loss_duration}        {statType avg}   {ixnNameType strict}}
            "Rx Bytes"                  {{hltName {rx.total_pkts_bytes rx.total_pkt_bytes}} {statType {sum sum}}   {ixnNameType {strict strict}}}
            "Rx Rate (Bps)"             {{hltName rx.total_pkt_byte_rate}      {statType avg}   {ixnNameType strict}}
            "Rx Rate (bps)"             {{hltName rx.total_pkt_bit_rate}       {statType avg}   {ixnNameType strict}}
            "Rx Rate (Kbps)"            {{hltName rx.total_pkt_kbit_rate}      {statType avg}   {ixnNameType strict}}
            "Rx Rate (Mbps)"            {{hltName rx.total_pkt_mbit_rate}      {statType avg}   {ixnNameType strict}}
            "First TimeStamp"           {{hltName rx.first_tstamp}             {statType none}  {ixnNameType strict}}
            "Last TimeStamp"            {{hltName rx.last_tstamp}              {statType none}  {ixnNameType strict}}
            "Small Error"               {{hltName rx.small_error}              {statType sum}   {ixnNameType strict}}
            "Big Error"                 {{hltName rx.big_error}                {statType sum}   {ixnNameType strict}}
            "Reverse Error"             {{hltName rx.reverse_error}            {statType sum}   {ixnNameType strict}}
            "Tx L1 Rate (bps)"          {{hltName tx.l1_bit_rate}              {statType sum}   {ixnNameType strict}}
            "Rx L1 Rate (bps)"          {{hltName rx.l1_bit_rate}              {statType sum}   {ixnNameType strict}}
            "Tx Rate (Bps)"             {{hltName tx.total_pkt_byte_rate}      {statType sum}   {ixnNameType strict}}
            "Tx Rate (bps)"             {{hltName tx.total_pkt_bit_rate}       {statType sum}   {ixnNameType strict}}
            "Tx Rate (Kbps)"            {{hltName tx.total_pkt_kbit_rate}      {statType sum}   {ixnNameType strict}}
            "Tx Rate (Mbps)"            {{hltName tx.total_pkt_mbit_rate}      {statType sum}   {ixnNameType strict}}
            "Store-Forward Avg Latency (ns)"    {{hltName rx.avg_latency}      {statType sum}   {ixnNameType strict}}
            "Store-Forward Min Latency (ns)"    {{hltName rx.min_latency}      {statType sum}   {ixnNameType strict}}
            "Store-Forward Max Latency (ns)"    {{hltName rx.max_latency}      {statType sum}   {ixnNameType strict}}
        }
        
        set latency_stat_prefix_name [ixNetworkGetLatencyNamePrefix]
        
        set trafficStatsArray($latency_stat_prefix_name\ Avg\ Latency\ \(ns\))\
                {{hltName rx.avg_delay}                {statType avg}   {ixnNameType strict }}
                
        set trafficStatsArray($latency_stat_prefix_name\ Min\ Latency\ \(ns\))\
                {{hltName rx.min_delay}                {statType avg}   {ixnNameType strict }}
                
        set trafficStatsArray($latency_stat_prefix_name\ Max\ Latency\ \(ns\))\
                {{hltName rx.max_delay}                {statType avg}   {ixnNameType strict }}
        
        set latency_bins_view ""
        array set view_ti_map ""
        lappend latency_bins_view "Flow Statistics"
#         puts "streamObjects == $streamObjects"
        foreach stream_obj $streamObjects {
            
            set ti_handle $stream_obj
            
            # Build latency view for this traffic item
            set ret_code [540CreateLatencyStatsView -traffic_item $ti_handle]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set latency_view_tmp [keylget ret_code latency_view]
            
            if {[llength $latency_view_tmp] > 0} {
                lappend latency_bins_view [ixNet getA $latency_view_tmp -caption]
                set view_ti_map([ixNet getA $latency_view_tmp -caption]) $ti_handle
            }
        }
        
        # First collect all stats from all views to reduce differences in stat values
        catch {array unset all_views_stats_array}
        array set all_views_stats_array ""
        set view_index 0
        set is_latency_view 0
        foreach view_name $latency_bins_view {
            if {$view_index > 0} {
                set is_latency_view 1
            }
            if {$::ixia::snapshot_stats} {
                if {$return_method == "csv"} {
                    set retCode [540GetStatViewSnapshot $view_name $mode $is_latency_view "" 1]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to get snapshot $view_name, while\
                                retrieving stream statistics. [keylget retCode log]"
                        return $returnList
                    }
                    set csvList         [keylget retCode csv_file]
                    set ::ixia::clear_csv_stats($csvList) $csvList
                    
                    keylset returnList status $::SUCCESS
                    keylset returnList csv_file $csvList
                    return $returnList
                } else {
                    set retCode [540GetStatViewSnapshot $view_name $mode $is_latency_view]
                }
            } else {
                set retCode [540GetStatView $view_name $mode $is_latency_view]
            }
            
            set all_views_stats_array($view_name) $retCode
            incr view_index
        }
        
        set flow 0
        set view_index 0
        set is_latency_view 0
        foreach view_name $latency_bins_view {
            
            if {$view_index > 0} {
                set is_latency_view 1
                set ti_for_view $view_ti_map($view_name)
                
                if {[ixNet getA $ti_for_view/tracking/latencyBin -enabled] != "true"} {
                    continue
                }
                
                # Get list of latency bins
                set bin_limits [ixNet getA $ti_for_view/tracking/latencyBin -binLimits]
                catch {array unset trafficStatsArray}
                array set trafficStatsArray ""
                set bin_idx 1
                foreach single_bin $bin_limits {
                    if {[regexp {(\.)(0+$)} $single_bin]} {
                        # number is integer
                        set single_bin_formatted [format %.0f $single_bin]
                    } else {
                        # number if float
                        set single_bin_formatted [string trimright $single_bin 0]
                    }
                    
                    if {$bin_idx == 1} {
                        set ixn_bin_string "0us - ${single_bin_formatted}us"
                    } elseif {[lindex $bin_limits end] == $single_bin} {
                        set prev_bin [lindex $bin_limits [expr $bin_idx - 2]]
                        if {[regexp {(\.)(0+$)} $prev_bin]} {
                            # number is integer
                            set prev_bin [format %.0f $prev_bin]
                        } else {
                            # number if float
                            set prev_bin [string trimright $prev_bin 0]
                        }
                        set ixn_bin_string "${prev_bin}us - maxus"
                    } else {
                        set prev_bin [lindex $bin_limits [expr $bin_idx - 2]]
                        if {[regexp {(\.)(0+$)} $prev_bin]} {
                            # number is integer
                            set prev_bin [format %.0f $prev_bin]
                        } else {
                            # number if float
                            set prev_bin [string trimright $prev_bin 0]
                        }
                        set ixn_bin_string "${prev_bin}us - ${single_bin_formatted}us"
                    }

                    set trafficStatsArray(Rx\ Frames\ per\ Bin\ :\ $ixn_bin_string)             [list [list hltName rx.latency_bin.$bin_idx.total_pkts]     [list statType sum]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Frame\ Rate\ per\ Bin\ :\ $ixn_bin_string)        [list [list hltName rx.latency_bin.$bin_idx.pkt_frame_rate] [list statType avg]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Bytes\ per\ Bin\ :\ $ixn_bin_string)              [list [list hltName rx.latency_bin.$bin_idx.total_bytes]    [list statType sum]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Rate\ \(Bps\)\ per\ Bin\ :\ $ixn_bin_string)      [list [list hltName rx.latency_bin.$bin_idx.pkt_byte_rate]  [list statType avg]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Rate\ \(bps\)\ per\ Bin\ :\ $ixn_bin_string)      [list [list hltName rx.latency_bin.$bin_idx.pkt_bit_rate]   [list statType avg]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Rate\ \(Kbps\)\ per\ Bin\ :\ $ixn_bin_string)     [list [list hltName rx.latency_bin.$bin_idx.pkt_kbit_rate]  [list statType avg]  [list ixnNameType strict]]
                    set trafficStatsArray(Rx\ Rate\ \(Mbps\)\ per\ Bin\ :\ $ixn_bin_string)     [list [list hltName rx.latency_bin.$bin_idx.pkt_mbit_rate]  [list statType avg]  [list ixnNameType strict]]
                    set trafficStatsArray($latency_stat_prefix_name\ Avg\ Latency\ \(ns\)\ per\ Bin\ :\ $ixn_bin_string)   [list [list hltName rx.latency_bin.$bin_idx.avg]            [list statType avg]  [list ixnNameType strict ]]
                    set trafficStatsArray($latency_stat_prefix_name\ Min\ Latency\ \(ns\)\ per\ Bin\ :\ $ixn_bin_string)   [list [list hltName rx.latency_bin.$bin_idx.min]            [list statType avg]  [list ixnNameType strict ]]
                    set trafficStatsArray($latency_stat_prefix_name\ Max\ Latency\ \(ns\)\ per\ Bin\ :\ $ixn_bin_string)   [list [list hltName rx.latency_bin.$bin_idx.max]            [list statType avg]  [list ixnNameType strict ]]
                    set trafficStatsArray(First\ TimeStamp\ per\ Bin\ :\ $ixn_bin_string)       [list [list hltName rx.latency_bin.$bin_idx.first_tstamp]   [list statType none] [list ixnNameType strict]]
                    set trafficStatsArray(Last\ TimeStamp\ per\ Bin\ :\ $ixn_bin_string)        [list [list hltName rx.latency_bin.$bin_idx.last_tstamp]    [list statType none] [list ixnNameType strict]]
                    
                    incr bin_idx
                }
            }
            
            
            
            set retCode $all_views_stats_array($view_name)
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            
            set pageCount [keylget retCode page]
            set rowCount  [keylget retCode row]
            catch {array unset rowsArray}
            array set rowsArray [keylget retCode rows]
            
            set resetPortList ""

            for {set i 1} {$i < $pageCount} {incr i} {
                for {set j 1} {$j < $rowCount} {incr j} {
                    if {![info exists rowsArray($i,$j)]} { continue }

            
                    set rowInfo     $rowsArray($i,$j)
                    
                    if {!$is_latency_view} {
                        set txPort      $rowsArray($i,$j,Tx Port)
                        if {[info exists streamNames] && [lsearch $streamNames $rowsArray($i,$j,Traffic Item)] == -1} {
                            continue
                        }
                    }
                    
                    set rxPort      $rowsArray($i,$j,Rx Port)
                    set flow_name   $rowInfo
                    set pgid        "N/A"
                    
                    if {$txPort == "" && !$is_latency_view}      {continue}
                    if {$rxPort == "" }      {continue}
                    if {$flow_name == "" }   {continue}
                    
                    set found 0
                    if {[info exists registered_flows($flow_name)]} {
                        set flow_bak $flow
                        set flow     $registered_flows($flow_name)
                        set found 1
                    }
                    
                    if {!$found} {
                        mpincr flow
                    }
                    
                    set registered_flows($flow_name)                     $flow
                    set [subst $keyed_array_name](flow.$flow.flow_name)  $flow_name
                    incr keyed_array_index
                    set [subst $keyed_array_name](flow.$flow.pgid_value) $pgid
                    incr keyed_array_index
                    set [subst $keyed_array_name](flow.$flow.rx.port)    $rxPort
                    incr keyed_array_index

                    if {[info exists rowsArray(columnCaptions)] && [info exists rowsArray(max_trk_count)]} {
                        for {set index 2} {$index < $rowsArray(max_trk_count)} {incr index} {
                            set tracking_index [expr $index - 1]
                            set caption [regsub -all "\"" [lindex $rowsArray(columnCaptions) $index] ""]
                            set [subst $keyed_array_name](flow.$flow.tracking.$tracking_index.tracking_name) $caption
                            set [subst $keyed_array_name](flow.$flow.tracking.$tracking_index.tracking_value) $rowsArray($i,$j,$caption)
                            set [subst $keyed_array_name](flow.$flow.tracking.count) [expr $rowsArray(max_trk_count) - 2]
                        }
                    }
                    
                    if {!$is_latency_view} {
                        set [subst $keyed_array_name](flow.$flow.tx.port)    $txPort
                        incr keyed_array_index
                    }
                    
                    foreach statName [array names trafficStatsArray] {
                        set trafficStatArrayValue $trafficStatsArray($statName)
                        
                        set retStatNameList [keylget trafficStatArrayValue hltName]
                        set statTypeList    [keylget trafficStatArrayValue statType]
                        set ixnNameType     [keylget trafficStatArrayValue ixnNameType]
                        
                        foreach retStatName $retStatNameList statType $statTypeList {
                            if {$ixnNameType == "regex"} {
                                set names [array names rowsArray -regexp (1,1,(\[^,\]*)[regsub { } $statName {\\ }])]
                                if {[llength $names] == 0} {
                                    # Do nothing. Stat name will not be found
                                } else {
                                    set statName [lindex [split [lindex $names 0] ,] end]
                                }
                            }
                            
                            if {![info exists rowsArray($i,$j,$statName)] } {
                                set [subst $keyed_array_name](flow.$flow.$retStatName) "N/A"
                                incr keyed_array_index
                                continue
                            }
                            
                            if {[catch {set [subst $keyed_array_name](flow.$flow.$retStatName)} oldValue]} {
                                set [subst $keyed_array_name](flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                if {$statType == "avg"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A"} {
                                        set avg_calculator_array([subst $keyed_array_name],flow.$flow.$retStatName) 1
                                    } else {
                                        set avg_calculator_array([subst $keyed_array_name],flow.$flow.$retStatName) 0
                                    }
                                }
                                incr keyed_array_index
                            } else {
                                if {$statType == "sum"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A" && $oldValue != "" && $oldValue != "N/A"} {
                                        set [subst $keyed_array_name](flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                        incr keyed_array_index
                                    }
                                    
                                } elseif {$statType == "avg"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A" && $oldValue != "" && $oldValue != "N/A"} {
                                        set [subst $keyed_array_name](flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                        incr avg_calculator_array([subst $keyed_array_name],flow.$flow.$retStatName)
                                        incr keyed_array_index
                                    }
                                } else {
                                    set [subst $keyed_array_name](flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                    incr keyed_array_index
                                }
                            }
                        }
                    }
                    
                    if {$found && [info exists flow_bak]} {
                        set flow $flow_bak
                    }
                }
            }
            incr view_index
        }
    }
    
    if {$mode == "egress_by_port" || $mode == "egress_by_flow" || $mode == "all"} {
        
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Parameter port_handle is mandatory when mode is $mode."
            return $returnList
        }
        
        catch { array unset registered_flows  }
        array set registered_flows ""
        
        catch { array unset trafficStatsArray }
        array set trafficStatsArray {
            "Tx Frames"                     {{hltName tx.total_pkts}               {statType sum}}
            "Rx Frames"                     {{hltName rx.total_pkts}               {statType sum}}
            "Frames Delta"                  {{hltName rx.frames_delta}             {statType sum}}
            "Loss %"                        {{hltName rx.loss_percent}             {statType sum}}
            "Tx Frame Rate"                 {{hltName tx.total_pkt_rate}           {statType avg}}
            "Rx Frame Rate"                 {{hltName rx.total_pkt_rate}           {statType avg}}
            "Rx Bytes"                      {{hltName rx.total_pkts_bytes}         {statType sum}}
            "Rx Rate (Bps)"                 {{hltName rx.total_pkt_byte_rate}      {statType avg}}
            "Tx Rate (Bps)"                 {{hltName tx.total_pkt_byte_rate}      {statType avg}}
            "Rx Rate (bps)"                 {{hltName rx.total_pkt_bit_rate}       {statType avg}}
            "Tx Rate (bps)"                 {{hltName tx.total_pkt_bit_rate}       {statType avg}}
            "Rx Rate (Kbps)"                {{hltName rx.total_pkt_kbit_rate}      {statType avg}}
            "Tx Rate (Kbps)"                {{hltName tx.total_pkt_kbit_rate}      {statType avg}}
            "Rx Rate (Mbps)"                {{hltName rx.total_pkt_mbit_rate}      {statType avg}}
            "Tx Rate (Mbps)"                {{hltName tx.total_pkt_mbit_rate}      {statType avg}}
            "Cut-Through Avg Latency (ns)"  {{hltName rx.avg_delay}                {statType avg}}
            "Cut-Through Min Latency (ns)"  {{hltName rx.min_delay}                {statType avg}}
            "Cut-Through Max Latency (ns)"  {{hltName rx.max_delay}                {statType avg}}
            "First Timestamp"               {{hltName rx.first_tstamp}             {statType none}}
            "Last Timestamp"                {{hltName rx.last_tstamp}              {statType none}}
            "Small Error"                   {{hltName rx.small_error}              {statType sum}}
            "Big Error"                     {{hltName rx.big_error}                {statType sum}}
            "Reverse Error"                 {{hltName rx.reverse_error}            {statType sum}}
        }
        
        if {[info exists streamObjectsEgress]} {
            set all_traffic_items $streamObjectsEgress
        } else {
            set all_traffic_items $streamObjects
        }
        
        array set egress_views_list ""
        # if custom egress statistics
        if {![info exists egress_stats_list]} {
            set egress_stats_list all
        }
        # Attempt to create a view for each traffic item with port filter $port_handle
        if {![info exists egress_mode] || $egress_mode == "conditional"} {
            set ret_code [540CreateEgressStatsViewMultipleTi -traffic_items $all_traffic_items -port_handles [list $port_handle] -egress_stats_list $egress_stats_list -egress_mode conditional]
            if {[keylget ret_code status] != $::SUCCESS} {
                if {[string first "not valid port filter" [keylget ret_code log]] == -1 &&
                        [string first "egress tracking is not enabled" [keylget ret_code log]] == -1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to gather egress statistics. [keylget ret_code log]"
                    return $returnList
                }
            } else {
                set egress_views_list([keylget ret_code egress_view]) $all_traffic_items
            }
        } else {
            set ret_code [540CreateEgressStatsViewMultipleTi -traffic_items $all_traffic_items -port_handles [list $port_handle] -egress_stats_list $egress_stats_list -egress_mode paged]
            if {[keylget ret_code status] != $::SUCCESS} {
                if {[string first "not valid port filter" [keylget ret_code log]] == -1 &&
                        [string first "egress tracking is not enabled" [keylget ret_code log]] == -1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to gather egress statistics. [keylget ret_code log]"
                    return $returnList
                }
            }
            set egress_views_list([keylget ret_code egress_view]) $all_traffic_items
        }
        
        
        if {[array size egress_views_list] < 1} {
                puts "\nWARNING: No egress stats are available for port $port_handle.\n"
        } else {
            # Take snapshot and return the csv file
            if {$return_method == "csv"} {
                set csvList ""
                foreach item [array names egress_views_list] {
                    regexp {::ixNet::-OBJ-/statistics/view:\\?"(\d+)\\?"} $item {} no
                    if {[regexp {\\?"(\w+)\\?"} $item view_name_with_quote view_name_without_quote]} {
                        
                        set retCode [540GetStatViewSnapshot $view_name_without_quote $mode 0 "" 1]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to get snapshot with $view_name_without_quote, while\
                                    retrieving $mode statistics. [keylget retCode log]"
                            return $returnList
                        }
                        
                        lappend csvList [keylget retCode csv_file]
                        set ::ixia::clear_csv_stats([keylget retCode csv_file]) "[keylget retCode csv_file]"
                    }
                }
                
                keylset returnList status $::SUCCESS
                keylset returnList csv_file $csvList
                return $returnList
            }
            
            # if -mode is not "csv", retrieve statistics from SDM
            # First collect all stats from all views to reduce differences in stat values
            catch {array unset all_views_stats_array}
            array set all_views_stats_array ""
            foreach egress_stats_view [array names egress_views_list] {
                
                set availableTrackingFilter [ixNet getList $egress_stats_view availableTrackingFilter]
                set availableColumnHeaders  [ixNet getA $egress_stats_view/page -columnCaptions]
                set firstStatisticColumnHeader  [lsearch $availableColumnHeaders "Tx Frames"]
                set availableColumnHeaders  [lrange $availableColumnHeaders 0 [expr $firstStatisticColumnHeader - 1]]
                
                if {[llength $availableTrackingFilter] > 0} {
                    set filter_index 1
                    set available_filters_key ""
                    foreach availableHeader $availableColumnHeaders {
                        keylset returnList available_tracking_filters.filter${filter_index} $availableHeader
                        set trafficStatsArray($availableHeader) "{hltName filter$filter_index} {statType none}"
                        incr filter_index
                    }
                }
                set ret_code [ixNetworkEvalCmd [list ixNet getA $egress_stats_view -caption]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                set egress_stats_view_name [keylget ret_code ret_val]
                
                if {![info exists egress_mode] || $egress_mode == "conditional"} {
                    set retCode [540GetEgressStatViewConditional $egress_stats_view_name $mode $egress_stats_list]
                } else {
                    set retCode [540GetEgressStatViewMultipleTi $egress_stats_view_name $mode $egress_stats_list]
                }
                
                set all_views_stats_array($egress_stats_view) $retCode
                
            }
            
            # Gather statistics for all egress views from egress_views_list
            set flow 0
            foreach egress_stats_view [array names egress_views_list] {

                set retCode $all_views_stats_array($egress_stats_view)

                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
                
                set pageCount [keylget retCode page]
                set rowCount  [keylget retCode row]

                array set rowsArray [keylget retCode rows]

                set egress_tracking_col_name [keylget retCode egress_tracking_col]
                
                # Set aggregated statistics
                set statNameList [array names trafficStatsArray] ;# all statistics that need to be displayed
                array set aggregate [keylget retCode aggregate]
                
                # Create the keylist corresponding to the aggregated statistics
                set aggregateIds $aggregate(ids) ;# the entire list of aggregate ids
                foreach id $aggregateIds {
                    foreach statName [array names trafficStatsArray] {
                        set trafficStatArrayValue $trafficStatsArray($statName)
                        set retStatNameList [keylget trafficStatArrayValue hltName]

                        foreach retStatName $retStatNameList {
                            set rx_port $aggregate($id,rx_port)
                            if {![info exists aggregate($id,$statName)] } {
                                set [subst $keyed_array_name]($rx_port.egress.aggregate.$id.$retStatName) "N/A"
                            } else {
                                set [subst $keyed_array_name]($rx_port.egress.aggregate.$id.$retStatName) $aggregate($id,$statName)
                            }
                        }
                    }
                }
                
                # The flow variable is not incremented at every step which leads to missing flows
                set index 0
                for {set i 1} {$i < $pageCount} {incr i} {
                    for {set j 1} {$j < $rowCount} {incr j} {
                    mpincr index
                        if {![info exists rowsArray($i,$j)]} { continue }
                        
                        set flow_name     $rowsArray($i,$j,$egress_tracking_col_name)
                        set rx_port       $rowsArray($i,$j,Rx Port)
                                             
                        if {$mode == "egress_by_flow"} {
                            
                            set trafficItemRowName $rowsArray($i,$j)
                            mpincr flow
                            
                        } else {
                        
                            set trafficItemRowName "IGNORE"
                            
                            set found 0
                            if {[info exists registered_flows($flow_name)]} {
                                set flow_bak $flow
                                set flow     $registered_flows($flow_name)
                                set found 1
                            }
                            
                            if {!$found} {
                                mpincr flow
                            }
                        }
                        
                        set registered_flows($flow_name)                                  $flow
                        set [subst $keyed_array_name]($rx_port.egress.${index}.flow_name)  $flow_name
                        if {$trafficItemRowName != "IGNORE"} {
                            set [subst $keyed_array_name]($rx_port.egress.$index.flow_print)  $trafficItemRowName
                        } else {
                            set [subst $keyed_array_name]($rx_port.egress.$index.flow_print)  "N/A"
                        }
                        incr keyed_array_index

                        if {[info exists rowsArray($i,$j,aggregateId)]} {
                            set [subst $keyed_array_name]($rx_port.egress.$index.aggregate_id) $rowsArray($i,$j,aggregateId)
                        }
                        
                        foreach statName [array names trafficStatsArray] {
                            set trafficStatArrayValue $trafficStatsArray($statName)
                            set retStatNameList [keylget trafficStatArrayValue hltName]
                            set statTypeList    [keylget trafficStatArrayValue statType]
                            foreach retStatName $retStatNameList statType $statTypeList {
                                if {![info exists rowsArray($i,$j,$statName)] } {
                                    set [subst $keyed_array_name]($rx_port.egress.$index.$retStatName) "N/A"
                                    incr keyed_array_index
                                    continue
                                }
                                if {[catch {set [subst $keyed_array_name]($rx_port.egress.$index.$retStatName)} oldValue]} {
                                    set [subst $keyed_array_name]($rx_port.egress.$index.$retStatName) $rowsArray($i,$j,$statName)
                                    if {$statType == "avg"} {
                                        if {$rowsArray($i,$j,$statName) != "N/A"} {
                                            set avg_calculator_array([subst $keyed_array_name],$rx_port.egress.$index.$retStatName) 1
                                        } else {
                                            set avg_calculator_array([subst $keyed_array_name],$rx_port.egress.$index.$retStatName) 0
                                        }
                                    }
                                    incr keyed_array_index
                                } else {
                                    if {$statType == "sum"} {
                                        if {$oldValue != ""} {
                                            set [subst $keyed_array_name]($rx_port.egress.$index.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                            incr keyed_array_index
                                        }
                                        
                                    } elseif {$statType == "avg"} {
                                        if {$oldValue != ""} {
                                            set [subst $keyed_array_name]($rx_port.egress.$index.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                            if {$rowsArray($i,$j,$statName) != "N/A"} {
                                                incr avg_calculator_array([subst $keyed_array_name],$rx_port.egress.$index.$retStatName)
                                            }
                                            incr keyed_array_index
                                    
                                        }
                                    } else {
                                        set [subst $keyed_array_name]($rx_port.egress.$index.$retStatName) $rowsArray($i,$j,$statName)
                                        incr keyed_array_index
                                    }
                                }
                            }
                        }
                        if {[info exists found] && $found && [info exists flow_bak]} {
                            set flow $flow_bak
                        }
                    }
                }

            }
        }
    }
    
    if {$mode == "data_plane_port" || $mode == "all"} {
        
        array set portStatsArray {
            "FD Min Latency (ns)"                data_plane_port.rx.min_latency
            "FD Max Latency (ns)"                data_plane_port.rx.max_latency
            "FD Avg Latency (ns)"                data_plane_port.rx.avg_latency
            "MEF Min Latency (ns)"               data_plane_port.rx.min_latency
            "MEF Max Latency (ns)"               data_plane_port.rx.max_latency
            "MEF Avg Latency (ns)"               data_plane_port.rx.avg_latency
            "Store-Forward Min Latency (ns)"     data_plane_port.rx.min_latency
            "Store-Forward Max Latency (ns)"     data_plane_port.rx.max_latency
            "Store-Forward Avg Latency (ns)"     data_plane_port.rx.avg_latency
            "Cut-Through Min Latency (ns)"       data_plane_port.rx.min_latency
            "Cut-Through Max Latency (ns)"       data_plane_port.rx.max_latency
            "Cut-Through Avg Latency (ns)"       data_plane_port.rx.avg_latency
            "Tx L1 Load %"                       data_plane_port.tx.l1_load_percent
            "Rx L1 Load %"                       data_plane_port.rx.l1_load_percent
            "Rx Frames"                          data_plane_port.rx.pkt_count
            "Rx Frame Rate"                      data_plane_port.rx.pkt_rate
            "First TimeStamp"                    data_plane_port.first_timestamp
            "Last TimeStamp"                     data_plane_port.last_timestamp
            "Tx Frames"                          data_plane_port.tx.pkt_count
            "Tx Frame Rate"                      data_plane_port.tx.pkt_rate
            "Rx Bytes"                           data_plane_port.rx.pkt_byte_count
            "Rx Rate (Bps)"                      data_plane_port.rx.pkt_byte_rate
            "Rx Rate (bps)"                      data_plane_port.rx.pkt_bit_rate
            "Rx Rate (Kbps)"                     data_plane_port.rx.pkt_kbit_rate 
            "Rx Rate (Mbps)"                     data_plane_port.rx.pkt_mbit_rate
            "Tx L1 Rate (bps)"                   data_plane_port.tx.l1_bit_rate
            "Rx L1 Rate (bps)"                   data_plane_port.rx.l1_bit_rate
            "Tx Rate (Bps)"                      data_plane_port.tx.pkt_byte_rate
            "Tx Rate (bps)"                      data_plane_port.tx.pkt_bit_rate
            "Tx Rate (Kbps)"                     data_plane_port.tx.pkt_kbit_rate
            "Tx Rate (Mbps)"                     data_plane_port.tx.pkt_mbit_rate
            "Small Error"                        data_plane_port.rx.small_error
            "Big Error"                          data_plane_port.rx.big_error
            "Reverse Error"                      data_plane_port.rx.reverse_error
        }
        if {![info exists port_handle]} {
            set port_handle [array names ixnetwork_port_handles_array]
        }
        
        if {$::ixia::snapshot_stats} {
            if {$return_method == "csv"} {
                set retCode [540GetStatViewSnapshot "Data Plane Port Statistics" $mode "0" "" 1]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to get Data Plane Port Statistics snapshot, while\
                                retrieving stream statistics. [keylget retCode log]"
                        return $returnList
                    }
                    set csvList         [keylget retCode csv_file]
                    set ::ixia::clear_csv_stats($csvList) $csvList
                    return $retCode
            } else {
                set retCode [540GetStatViewSnapshot "Data Plane Port Statistics" $mode]
            }
        } else {
            set retCode [540GetStatView "Data Plane Port Statistics" $mode]
        }
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        
        set pageCount [keylget retCode page]
        set rowCount  [keylget retCode row]
        array set rowsArray [keylget retCode rows]
        for {set i 1} {$i < $pageCount} {incr i} {
            for {set j 1} {$j < $rowCount} {incr j} {
                if {![info exists rowsArray($i,$j)]} { continue }
                set rowName $rowsArray($i,$j)
                
                set matched [regexp {(.+)/Card([0-9]{2})/Port([0-9]{2})} \
                        $rowName matched_str hostname cd pt]
                if {$matched && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                    set ch_ip $hostname
                }
                
                if {!$matched} {
                    set rx_port_status [ixNetworkGetVportByName $rowName]
                    if {[keylget rx_port_status status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to get 'Port Statistics' while\
                                retrieving aggregate statistics, because the virtual port with the\
                                '$rowName' name could not be found. [keylget rx_port_status log]"
                        return $returnList
                    }
                    set rowName [keylget rx_port_status port_handle]
                    
                    set matched [regexp {([0-9]+)/([0-9]+)/([0-9]+)} \
                            $rowName matched_str ch cd pt]
                }
                
                if {!$matched} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get 'Port Statistics',\
                            because port number could not be identified. $rowName did not\
                            match the HLT port format ChassisIP/card/port. This can occur if\
                            the test was not configured with HLT."
                    return $returnList
                }
                
                if {$matched && ($matched_str == $rowName) && \
                        [info exists ch_ip] && [info exists cd] && \
                        [info exists pt] } {
                    set ch [ixNetworkGetChassisId $ch_ip]
                }
                set cd [string trimleft $cd 0]
                set pt [string trimleft $pt 0]
                
                set statPort $ch/$cd/$pt
                if {[lsearch $port_handle $statPort] != -1} {
                    foreach statName [array names portStatsArray] {
                        if {![info exists rowsArray($i,$j,$statName)] } {continue}
                        if {![info exists portStatsArray($statName)]  } {continue}
                        foreach retStatName $portStatsArray($statName) {
                            set [subst $keyed_array_name]($statPort.$retStatName) $rowsArray($i,$j,$statName)
                            incr keyed_array_index
                        }
                    }
                }
            }
        }
    }
    
    if {$mode == "l23_test_summary" || $mode == "all"} {
        
        if { [regexp -inline {^\d+.\d+} $::ixia::ixnetworkVersion]< 7.1 } {
            #   IxNetwork <7.10 detected. 7.10 is requred for this mode.
            #   If -mode is "all" then we will silently ignore (only fail is user
            #   explicitly used mode "l23_test_summary"
            if {$mode == "l23_test_summary"} {
                keylset returnList status $::FAILURE
                keylset returnList log "IxNetwork 7.10 EA or newer version is required\
                        for \"l23_test_summary\" mode."
                return $returnList
            }
        } else {
            #   IxNetwork 7.10 or newer version.
            set latency_stat_prefix_name [ixNetworkGetLatencyNamePrefix]
            array set l23_test_summary_array "\"$latency_stat_prefix_name\
                    Min Latency (ns)\" l23_test_summary.rx.min_latency"
            array set l23_test_summary_array "\"$latency_stat_prefix_name\
                    Max Latency (ns)\" l23_test_summary.rx.max_latency"
            array set l23_test_summary_array "\"$latency_stat_prefix_name\
                    Avg Latency (ns)\" l23_test_summary.rx.avg_latency"
            array set l23_test_summary_array {
                "Rx Frames Count"                     l23_test_summary.rx.pkt_count
                "Tx Frames Count"                     l23_test_summary.tx.pkt_count
                "Rx Frame Rate"                       l23_test_summary.rx.pkt_rate
                "Tx Frame Rate"                       l23_test_summary.tx.pkt_rate
                "Rx L2 Throughput (Bps)"                 l23_test_summary.rx.pkt_byte_rate
                "Tx L2 Throughput (Bps)"                 l23_test_summary.tx.pkt_byte_rate
                "Rx L2 Throughput (bps)"                 l23_test_summary.rx.pkt_bit_rate
                "Tx L2 Throughput (bps)"                 l23_test_summary.tx.pkt_bit_rate
                "Rx L2 Throughput (Kbps)"                l23_test_summary.rx.pkt_kbit_rate 
                "Tx L2 Throughput (Kbps)"                l23_test_summary.tx.pkt_kbit_rate 
                "Rx L2 Throughput (Mbps)"                l23_test_summary.rx.pkt_mbit_rate
                "Tx L2 Throughput (Mbps)"                l23_test_summary.tx.pkt_mbit_rate
            }
            if {$::ixia::snapshot_stats} {
                if {$return_method == "csv"} {
                    set retCode [540GetStatViewSnapshot "L2-L3 Test Summary Statistics" $mode "0" "" 1]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to get L2-L3 Test Summary\
                                    Statistics snapshot. [keylget retCode log]"
                            return $returnList
                        }
                        set csvList         [keylget retCode csv_file]
                        set ::ixia::clear_csv_stats($csvList) $csvList
                        return $retCode
                } else {
                    set retCode [540GetStatViewSnapshot "L2-L3 Test Summary Statistics" $mode]
                }
            } else {
                set retCode [540GetStatView "L2-L3 Test Summary Statistics" $mode]
            }
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set pageCount [keylget retCode page]
            set rowCount  [keylget retCode row]
            array set rowsArray [keylget retCode rows]
            
            for {set i 1} {$i < $pageCount} {incr i} {
                for {set j 1} {$j < $rowCount} {incr j} {
                    if {![info exists rowsArray($i,$j)]} { continue }
                    set rowName $rowsArray($i,$j)
                    foreach statName [array names l23_test_summary_array] {
                        if {![info exists rowsArray($i,$j,$statName)] } {
                            debug "::ixia::540trafficStats -mode l23_test_summary:\
                                    Missing $statName from SV. Setting key to N/A\
                                    value!"
                            set rowsArray($i,$j,$statName) "N/A"
                        }
                        foreach retStatName $l23_test_summary_array($statName) {
                            set [subst $keyed_array_name]($retStatName) $rowsArray($i,$j,$statName)
                            incr keyed_array_index
                        }
                    }
                }
            }
            array unset l23_test_summary_array
        }
    }
    
    if {$mode == "traffic_item" || $mode == "all"} {
        # This array has the following meaning
        # index: IxN stat name
        # value: a keyed list with the following keys 
        # - hltName  - the name of the HLT stat to be returned
        # - statType - the type of the stat: sum, avg, or none
        catch { array unset trafficStatsArray }
        array set trafficStatsArray {
            "Tx Frames"             {
                                     {hltName     {tx.total_pkts            tx.total_pkts.min           tx.total_pkts.max           tx.total_pkts.avg           tx.total_pkts.sum           tx.total_pkts.count}}
                                     {statType    {sum                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Rx Frames"             {
                                     {hltName     {rx.total_pkts            rx.total_pkts.min           rx.total_pkts.max           rx.total_pkts.avg           rx.total_pkts.sum           rx.total_pkts.count}}
                                     {statType    {sum                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Rx Expected Frames"    {
                                     {hltName     {rx.expected_pkts         rx.expected_pkts.min        rx.expected_pkts.max        rx.expected_pkts.avg        rx.expected_pkts.sum        rx.expected_pkts.count}}
                                     {statType    {sum                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Frames Delta"          {
                                     {hltName     {rx.loss_pkts             rx.loss_pkts.min            rx.loss_pkts.max            rx.loss_pkts.avg            rx.loss_pkts.sum            rx.loss_pkts.count}}
                                     {statType    {sum                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Rx Frame Rate"         {
                                     {hltName     {rx.total_pkt_rate        rx.total_pkt_rate.min       rx.total_pkt_rate.max       rx.total_pkt_rate.avg       rx.total_pkt_rate.sum       rx.total_pkt_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Tx Frame Rate"         {
                                     {hltName     {tx.total_pkt_rate        tx.total_pkt_rate.min       tx.total_pkt_rate.max       tx.total_pkt_rate.avg       tx.total_pkt_rate.sum       tx.total_pkt_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Loss %"                {
                                     {hltName     {rx.loss_percent          rx.loss_percent.min         rx.loss_percent.max         rx.loss_percent.avg         rx.loss_percent.sum         rx.loss_percent.count}}
                                     {statType    {sum                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Packet Loss Duration (ms)" {
                                     {hltName     {rx.pkt_loss_duration     rx.pkt_loss_duration.min    rx.pkt_loss_duration.max    rx.pkt_loss_duration.avg    rx.pkt_loss_duration.sum    rx.pkt_loss_duration.count}}
                                     {statType    {sum                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Rx Bytes"              {
                                     {hltName     {rx.total_pkts_bytes      rx.total_pkts_bytes.min     rx.total_pkts_bytes.max     rx.total_pkts_bytes.avg     rx.total_pkts_bytes.sum     rx.total_pkts_bytes.count
                                                   rx.total_pkt_bytes       rx.total_pkt_bytes.min      rx.total_pkt_bytes.max      rx.total_pkt_bytes.avg      rx.total_pkt_bytes.sum      rx.total_pkt_bytes.count}
                                                  }
                                     {statType    {sum                      min                         max                         avg                         sum                         count
                                                   sum                      min                         max                         avg                         sum                         count}
                                                  }
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict
                                                   strict                   strict                      strict                      strict                      strict                      strict}
                                                  }
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate
                                                   _default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}
                                                  }
                                    }
            "Rx Rate (Bps)"         {
                                     {hltName     {rx.total_pkt_byte_rate   rx.total_pkt_byte_rate.min  rx.total_pkt_byte_rate.max  rx.total_pkt_byte_rate.avg  rx.total_pkt_byte_rate.sum  rx.total_pkt_byte_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Rx Rate (bps)"         {
                                     {hltName     {rx.total_pkt_bit_rate    rx.total_pkt_bit_rate.min   rx.total_pkt_bit_rate.max   rx.total_pkt_bit_rate.avg   rx.total_pkt_bit_rate.sum   rx.total_pkt_bit_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Rx Rate (Kbps)"        {
                                     {hltName     {rx.total_pkt_kbit_rate   rx.total_pkt_kbit_rate.min  rx.total_pkt_kbit_rate.max  rx.total_pkt_kbit_rate.avg  rx.total_pkt_kbit_rate.sum  rx.total_pkt_kbit_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Rx Rate (Mbps)"        {
                                     {hltName     {rx.total_pkt_mbit_rate   rx.total_pkt_mbit_rate.min  rx.total_pkt_mbit_rate.max  rx.total_pkt_mbit_rate.avg  rx.total_pkt_mbit_rate.sum  rx.total_pkt_mbit_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Tx L1 Rate (bps)"      {
                                     {hltName     {tx.l1_bit_rate           tx.l1_bit_rate.min          tx.l1_bit_rate.max          tx.l1_bit_rate.avg          tx.l1_bit_rate.sum          tx.l1_bit_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Rx L1 Rate (bps)"      {
                                     {hltName     {rx.l1_bit_rate           rx.l1_bit_rate.min          rx.l1_bit_rate.max          rx.l1_bit_rate.avg          rx.l1_bit_rate.sum          rx.l1_bit_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Tx Rate (Bps)"         {
                                     {hltName     {tx.total_pkt_byte_rate   tx.total_pkt_byte_rate.min  tx.total_pkt_byte_rate.max  tx.total_pkt_byte_rate.avg  tx.total_pkt_byte_rate.sum  tx.total_pkt_byte_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Tx Rate (bps)"         {
                                     {hltName     {tx.total_pkt_bit_rate    tx.total_pkt_bit_rate.min   tx.total_pkt_bit_rate.max   tx.total_pkt_bit_rate.avg   tx.total_pkt_bit_rate.sum   tx.total_pkt_bit_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Tx Rate (Kbps)"        {
                                     {hltName     {tx.total_pkt_kbit_rate   tx.total_pkt_kbit_rate.min  tx.total_pkt_kbit_rate.max  tx.total_pkt_kbit_rate.avg  tx.total_pkt_kbit_rate.sum  tx.total_pkt_kbit_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Tx Rate (Mbps)"        {
                                     {hltName     {tx.total_pkt_mbit_rate   tx.total_pkt_mbit_rate.min  tx.total_pkt_mbit_rate.max  tx.total_pkt_mbit_rate.avg  tx.total_pkt_mbit_rate.sum  tx.total_pkt_mbit_rate.count}}
                                     {statType    {avg                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "First TimeStamp"       {
                                     {hltName     {rx.first_tstamp          rx.first_tstamp.count}}
                                     {statType    {none                     count}}
                                     {ixnNameType {strict                   strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate}}
                                    }
            "Last TimeStamp"        {
                                     {hltName     {rx.last_tstamp           rx.last_tstamp.count}}
                                     {statType    {none                     count}}
                                     {ixnNameType {strict                   strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate}}
                                    }
            "Small Error"           {
                                     {hltName     {rx.small_error           rx.small_error.min          rx.small_error.max          rx.small_error.avg          rx.small_error.sum          rx.small_error.count}}
                                     {statType    {sum                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Big Error"             {
                                     {hltName     {rx.big_error             rx.big_error.min            rx.big_error.max            rx.big_error.avg            rx.big_error.sum            rx.big_error.count}}
                                     {statType    {sum                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
            "Reverse Error"         {
                                     {hltName     {rx.reverse_error         rx.reverse_error.min        rx.reverse_error.max        rx.reverse_error.avg        rx.reverse_error.sum        rx.reverse_error.count}}
                                     {statType    {sum                      min                         max                         avg                         sum                         count}}
                                     {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                                     {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                                    }
        }
        
        set latency_stat_prefix_name [ixNetworkGetLatencyNamePrefix]
        
        set trafficStatsArray($latency_stat_prefix_name\ Avg\ Latency\ \(ns\))\
                {
                 {hltName     {rx.avg_delay             rx.avg_delay.min            rx.avg_delay.max            rx.avg_delay.avg            rx.avg_delay.sum            rx.avg_delay.count}}
                 {statType    {avg                      min                         max                         avg                         sum                         count}}
                 {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                 {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                }
                
        set trafficStatsArray($latency_stat_prefix_name\ Min\ Latency\ \(ns\))\
                {
                 {hltName     {rx.min_delay             rx.min_delay.min            rx.min_delay.max            rx.min_delay.avg            rx.min_delay.sum            rx.min_delay.count}}
                 {statType    {avg                      min                         max                         avg                         sum                         count}}
                 {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                 {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                }
                
        set trafficStatsArray($latency_stat_prefix_name\ Max\ Latency\ \(ns\))\
                {
                 {hltName     {rx.max_delay             rx.max_delay.min            rx.max_delay.max            rx.max_delay.avg            rx.max_delay.sum            rx.max_delay.count}}
                 {statType    {avg                      min                         max                         avg                         sum                         count}}
                 {ixnNameType {strict                   strict                      strict                      strict                      strict                      strict}}
                 {prefixKey   {_default                 traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate      traffic_item.aggregate}}
                }
        
        if {$::ixia::snapshot_stats} {
            if {$return_method == "csv"} {
                set retCode [540GetStatViewSnapshot "Traffic Item Statistics" $mode "0" "" 1]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to get Traffic Item Statistics snapshot, while\
                                retrieving stream statistics. [keylget retCode log]"
                        return $returnList
                    }
                    set csvList         [keylget retCode csv_file]
                    set ::ixia::clear_csv_stats($csvList) $csvList
                    return $retCode
            } else {
                set retCode [540GetStatViewSnapshot "Traffic Item Statistics" $mode]
            }
        } else {
            set retCode [540GetStatView "Traffic Item Statistics" $mode]            
        }
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        
        set pageCount [keylget retCode page]
        set rowCount  [keylget retCode row]
        array set rowsArray [keylget retCode rows]
        
        set resetPortList ""
        for {set i 1} {$i < $pageCount} {incr i} {
            for {set j 1} {$j < $rowCount} {incr j} {
                if {![info exists rowsArray($i,$j)]} { continue }
#                 puts "-->ixNetworkParseRowName $rowsArray($i,$j)"
                set rowInfo     $rowsArray($i,$j)
                set trafficName $rowInfo

                if {$trafficName == "" } {continue}

                set streamId $trafficName

                if {[lsearch $streamNames $trafficName] != -1} {
                    foreach statName [array names trafficStatsArray] {
#                             puts "--> statName == $statName"
                        set trafficStatArrayValue $trafficStatsArray($statName)
                        
#                             puts "--> set trafficStatArrayValue $trafficStatsArray($statName)"
                        set retStatNameList [keylget trafficStatArrayValue hltName]
                        set statTypeList    [keylget trafficStatArrayValue statType]
                        set ixnNameTypeList [keylget trafficStatArrayValue ixnNameType]
                        set prefixKeyList   [keylget trafficStatArrayValue prefixKey]
                        foreach retStatName $retStatNameList statType $statTypeList ixnNameType $ixnNameTypeList prefixKey $prefixKeyList {

#                                 puts "--> $retStatName --> $statType"
#                                 puts "--> info exists rowsArray($i,$j,$statName)"

                            switch $prefixKey {
                                "_default" {
                                    set current_key "traffic_item.${trafficName}.${retStatName}"
                                }
                                default {
                                    set current_key "${prefixKey}.${retStatName}"
                                }
                            }
                            
                            if {$ixnNameType == "regex"} {
                                set names [array names rowsArray -regexp (1,1,(\[^,\]*)[regsub { } $statName {\\ }])]
#                                    puts "names == $names"
                                if {[llength $names] == 0} {
                                    # Do nothing. Stat name will not be found
                                } else {
                                    set statName [lindex [split [lindex $names 0] ,] end]
                                }
                            }
                            
                            if {![info exists rowsArray($i,$j,$statName)] } {
                                
                                if {![catch {set [subst $keyed_array_name]($current_key)} overlap_key_val]} {
                                    
                                    # Leave the value as it it
                                    # This is used for the various latency keys which map to the same subset of hlt keys
                                    # If the Cut-Through key was found we don't want to overwrite it with N/A
                                    
                                    continue
                                } else {
                                    set [subst $keyed_array_name]($current_key) "N/A"
                                    incr keyed_array_index
                                    continue
                                }
                            }


#                               puts "string first \"tx.\" $retStatName"
                            if {[catch {set [subst $keyed_array_name]($current_key)} oldValue]} {
                                if {$statType == "count"} {
                                    set [subst $keyed_array_name]($current_key) 1
                                } else {
                                    set [subst $keyed_array_name]($current_key) $rowsArray($i,$j,$statName)
                                }
                                if {$statType == "avg"} {
                                    if {$rowsArray($i,$j,$statName) != "N/A"} {
                                        set avg_calculator_array([subst $keyed_array_name],$current_key) 1
                                    } else {
                                        set avg_calculator_array([subst $keyed_array_name],$current_key) 0
                                    }
                                }
                                
                                incr keyed_array_index
                            } else {
                                if {$statType == "sum"} {
#                                             puts "oldValue == $oldValue"
                                    set [subst $keyed_array_name]($current_key) [math_incr $rowsArray($i,$j,$statName) $oldValue]
                                    incr keyed_array_index

                                } elseif {$statType == "avg"} {
#                                             puts "oldValue == $oldValue"
                                    set [subst $keyed_array_name]($current_key) [math_incr $rowsArray($i,$j,$statName) $oldValue]
                                    if {$rowsArray($i,$j,$statName) != "N/A"} {
                                        incr avg_calculator_array([subst $keyed_array_name],$current_key)
                                    }
                                    incr keyed_array_index
                                
                                } elseif {$statType == "max"} {
                                    set [subst $keyed_array_name]($current_key) [math_max $oldValue $rowsArray($i,$j,$statName)]
                                    incr keyed_array_index
                                } elseif {$statType == "min"} {
                                    set [subst $keyed_array_name]($current_key) [math_min $oldValue $rowsArray($i,$j,$statName)]
                                    incr keyed_array_index
                                } elseif {$statType == "count"} {
                                    set [subst $keyed_array_name]($current_key) [math_incr $oldValue 1]
                                    incr keyed_array_index
                                } else {
                                    set [subst $keyed_array_name]($current_key) $rowsArray($i,$j,$statName)
                                    incr keyed_array_index
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if {$mode == "L47_traffic_item" || $mode == "L47_flow_initiator" || $mode == "L47_flow_responder" || \
        $mode == "L47_traffic_item_tcp" || $mode == "L47_flow_initiator_tcp" || $mode == "L47_listening_port_tcp" } {
        switch -- $mode {
            "L47_traffic_item" {
                set statViewNameList [list {Application Traffic Item Statistics}]
            }
            "L47_flow_initiator" {
                set statViewNameList [list {Application Flow Initiator Statistics}]
            }
             "L47_flow_responder" {
                set statViewNameList [list {Application Flow Responder Statistics}]
            }
            "L47_traffic_item_tcp" {
                set statViewNameList [list {Application Traffic Item TCP Statistics}]
            }
            "L47_flow_initiator_tcp" {
                set statViewNameList [list {Application Flow Initiator TCP Statistics}]
            }
             "L47_listening_port_tcp" {
                set statViewNameList [list {Listening Port TCP Statistics}]
            }
        }
        
        ##
        #intialize filter values list for drill down
        set filter_list [list]
        
        if {$drill_down_type != "none"} {
            #
            #validate drill down type for the given mode
        
            array set valid_mode_drill_down_map     [list   L47_traffic_item        {per_ips per_ports per_initiator_flows per_responder_flows per_ports_per_initiator_flows \
                                                                                    per_ports_per_responder_flows per_ports_per_initiator_ips per_ports_per_responder_ips per_initiator_flows_per_initiator_ports \
                                                                                    per_responder_flows_per_responder_ports per_initiator_flows_per_initiator_ips per_responder_flows_per_responder_ips \
                                                                                    per_ports_per_initiator_flows_per_initiator_ips per_ports_per_responder_flows_per_responder_ips \
                                                                                    per_initiator_flows_per_initiator_ports_per_initiator_ips \
                                                                                    per_responder_flows_per_responder_ports_per_responder_ips}   \
                                                            L47_flow_initiator      {per_initiator_ports per_initiator_ips per_initiator_ports_per_initiator_ips}                     \
                                                            L47_flow_responder      {per_responder_ports per_responder_ips per_responder_ports_per_responder_ips}                \
                                                            L47_traffic_item_tcp    {per_ports per_initiator_flows per_initiator_ips per_listening_ports            \
                                                                                    per_listening_ports_per_responder_port     \
                                                                                    per_ports_per_initiator_ips per_ports_per_initiator_flows per_ports_per_responder_ips  \
                                                                                    per_initiator_flows_per_initiator_ips per_initiator_flows_per_initiator_ports   \
                                                                                    per_initiator_flows_per_initiator_ports_per_initiator_ips                       \
                                                                                    per_ports_per_initiator_flows_per_initiator_ips}                                \
                                                            L47_flow_initiator_tcp  {per_initiator_ports per_initiator_ips per_initiator_ports_per_initiator_ips}   \
                                                            L47_listening_port_tcp  {per_responder_port}     ]
                                                    
            if {[lsearch $valid_mode_drill_down_map(${mode}) $drill_down_type] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "$drill_down_type is not available for $mode.\
                        Please use correct mode."
                return $returnList
            }

            if {[info exists drill_down_traffic_item]} {
                if {[regexp {/traffic/trafficItem:[0-9]+} $drill_down_traffic_item traffic_item]} {
                    set ret_val [regsub -all ^ $traffic_item {::ixNet::OBJ-} traffic_handle]
                    set ti_handle_name [ixNet getA $traffic_handle -name]
                    lappend filter_list drill_down_traffic_item $ti_handle_name                
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "drill_down_traffic_item value is not a valid traffic item"
                    return $returnList
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "drill_down_traffic_item value is necessary for retrieving\
                        $drill_down_type stats"
                return $returnList
            }
            
            #collect AppLibFlow names configured in the traffic
            if {[ixNet getA $traffic_handle -trafficItemType] != "applicationLibrary"} {
                keylset returnList status $::FAILURE
                keylset returnList log "drill_down_traffic_item value is not a valid L47 Application Library traffic item.\
                        Please provide L47 Application Library traffic item value"
                return $returnList            
            }
            set app_lib_profile [ixNet getList $traffic_handle appLibProfile]
            set app_lib_flows [ixNet getList $app_lib_profile appLibFlow]
            set app_lib_flow_list ""
            foreach app_lib_flow $app_lib_flows {
                lappend app_lib_flow_list [string map {" - " _ - _ "." "" ( "" ) "" " " _} [ixNet getA $app_lib_flow -name]]
            }

            #check for Per IP Stats enable/disable for *_ips drill_down_type
            if {[regexp {(_ips)$} $drill_down_type match]} {
                set enablePerIPStats [ixNet getA $app_lib_profile -enablePerIPStats]
                if {$enablePerIPStats == "false"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Per IP Stats should be enabled in the traffic $ti_handle_name for retrieving\
                            $drill_down_type stats"
                    return $returnList
                }
            }

            switch -- $drill_down_type {
                "per_responder_port" -
                "per_listening_ports_per_responder_port" {
                    if {[info exists drill_down_listening_port]} {
                        lappend filter_list drill_down_listening_port $drill_down_listening_port
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "drill_down_listening_port value is necessary for retrieving\
                                $drill_down_type stats"
                        return $returnList
                    }
                }
                "per_initiator_ports" -
                "per_responder_ports" -
                "per_initiator_ips" -
                "per_responder_ips" -
                "per_initiator_flows_per_initiator_ports" -
                "per_responder_flows_per_responder_ports" -
                "per_initiator_flows_per_initiator_ips" -
                "per_responder_flows_per_responder_ips" {
                    if {[info exists drill_down_flow]} {
                        set ret_val [regsub -all {[\.\s]} $drill_down_flow "_" application_flow_name]
                        if {[lsearch $app_lib_flow_list $application_flow_name] != "-1"} {
                            lappend filter_list drill_down_flow $application_flow_name
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "$drill_down_flow is not configured on the given $drill_down_traffic_item"
                            return $returnList
                        }
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "drill_down_flow value is necessary for retrieving\
                                $drill_down_type stats"
                        return $returnList
                    }
                    if {[info exists drill_down_port]} {
                        puts "\nWARNING: drill_down_port parameter is not required for the given -drill_down_type. Hence ignored."
                    }
                }
                "per_ports_per_initiator_flows" -
                "per_ports_per_responder_flows" -
                "per_ports_per_initiator_ips" -
                "per_ports_per_responder_ips" {
                    if {[info exists drill_down_port]} {
                        if {[::ixia::check_port_for_applib_traffic $traffic_handle $drill_down_port $drill_down_type]} {
                            lappend filter_list drill_down_port $drill_down_port
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "drill_down_port given is not present in the $ti_handle_name for retrieving\
                                    $drill_down_type stats. Please check the value."
                            return $returnList
                        }
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "drill_down_port value is necessary for retrieving\
                                $drill_down_type stats"
                        return $returnList
                    }
                    if {[info exists drill_down_flow]} {
                        puts "\nWARNING: drill_down_flow parameter is not required for the given -drill_down_type. Hence ignored."
                    }
                }
                "per_initiator_ports_per_initiator_ips" -
                "per_responder_ports_per_responder_ips" -
                "per_ports_per_initiator_flows_per_initiator_ips" -
                "per_ports_per_responder_flows_per_responder_ips" -
                "per_initiator_flows_per_initiator_ports_per_initiator_ips" -
                "per_responder_flows_per_responder_ports_per_responder_ips" {
                    if {[info exists drill_down_port]} {
                        if {[::ixia::check_port_for_applib_traffic $traffic_handle $drill_down_port $drill_down_type]} {
                            lappend filter_list drill_down_port $drill_down_port
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "drill_down_port given is not present in the $ti_handle_name for retrieving\
                                    $drill_down_type stats. Please check the value."
                            return $returnList
                        }
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "drill_down_port value is necessary for retrieving\
                                $drill_down_type stats"
                        return $returnList
                    }
                    
                    if {[info exists drill_down_flow]} {
                        set ret_val [regsub -all {[\.\s]} $drill_down_flow "_" application_flow_name]
                        if {[lsearch $app_lib_flow_list $application_flow_name] != "-1"} {
                            lappend filter_list drill_down_flow $application_flow_name
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "$drill_down_flow is not configured on the given $drill_down_traffic_item"
                            return $returnList
                        }
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "drill_down_flow value is necessary for retrieving\
                                $drill_down_type stats"
                        return $returnList
                    }
                }
                default {
                    if {[info exists drill_down_port]} {
                        puts "\nWARNING: drill_down_port parameter is not required for the given -drill_down_type. Hence ignored."
                    }
                    if {[info exists drill_down_flow]} {
                        puts "\nWARNING: drill_down_flow parameter is not required for the given -drill_down_type. Hence ignored."
                    }
                }
            }
        }
 
        if {$return_method == "csv"} {
            set retCode [540GetMultipleStatViewSnapshot $statViewNameList $mode]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get $mode Statistics snapshot, Error while\
                    retrieving statistics. [keylget retCode log]"
                return $returnList
            }
            set csvList         [keylget retCode csv_file_list]
            set ::ixia::clear_csv_stats($csvList) $csvList
            keylset returnList csv_file_list [keylget retCode csv_file_list]
            return $returnList
        } else {
            set retCode [540GetAppLibTrafficViewStats $statViewNameList $mode $drill_down_type $filter_list $keyed_array_name]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }        
            incr keyed_array_index [keylget retCode stat_count]
        }
    }

    # Calculate average values
    foreach {avg_array_entry} [array names avg_calculator_array] {
        foreach {avg_array_name avg_array_key} [split $avg_array_entry ,] {}
        if {$avg_calculator_array($avg_array_entry) > 1 &&\
                [info exists [subst $avg_array_name]($avg_array_key)]} {
            #puts "mpexpr [set [subst $avg_array_name]($avg_array_key)] / $avg_calculator_array($avg_array_entry)"
            if {[string is double [set [subst $avg_array_name]($avg_array_key)]]} {
                set [subst $avg_array_name]($avg_array_key) [mpexpr [set [subst $avg_array_name]($avg_array_key)] / $avg_calculator_array($avg_array_entry)]
            } else {
                set [subst $avg_array_name]($avg_array_key) [set [subst $avg_array_name]($avg_array_key)]
            }
        }
    }

    
    # For egress stats. Make a new set of keys from the first port but without <port_handle> key
    if {[info exists port_handle]} {
        foreach single_port $port_handle {

            set eval_cmd "array names $keyed_array_name -regexp \{($single_port\\\.)(egress\\\.)\}"
            set egress_names [eval $eval_cmd]
            if {[llength $egress_names] < 1} {
                continue
            }

            
            foreach egress_key $egress_names {

                set tmp_val [set [subst $keyed_array_name]($egress_key)]
                set eval_cmd "regsub \{$single_port\\\.\} $egress_key \{\} egress_key"
                if {![eval $eval_cmd]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error on '$eval_cmd'."
                    return $returnList
                }

                set [subst $keyed_array_name]($egress_key) $tmp_val
                incr keyed_array_index

            }
            break
        }
    }
    switch -- $return_method {
        "keyed_list" {
            set [subst $keyed_array_name](status) $::SUCCESS
            set retTemp [array get $keyed_array_name]
            eval "keylset returnList $retTemp"
            # Unset the current array
            ::ixia::cleanupTrafficStatsArrays $keyed_array_name
        }
        "keyed_list_or_array" {
            if {$keyed_array_index < $traffic_stats_max_list_length} {
                set [subst $keyed_array_name](status) $::SUCCESS
                set retTemp [array get $keyed_array_name]
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
        }
        "csv" {
            # treated earlier in code
        }
    }

    return $returnList
}


proc ::ixia::540trafficGlobalStatsConfig {args man_args opt_args} {
    
    keylset returnList status $::SUCCESS
    
    variable ixnetwork_port_handles_array
    variable truth
    variable 540IxNetTrafficState
    
    array set reversed_truth {
        true        1
        false       0
    }
    array set translate_dpj {
        0           0
        1.3         1310720
        2.6         2621440
        5.2         5242880
        10          10483760
        21          20971520
        42          41943040
        84          83886080
        168         167772160
        336         335544320
        671         671088640
    }
    array set translate_array {
        cut_through                              cutThrough
        store_and_forward                        storeForward
        mef_frame_delay                          mef
        forwarding_delay                         forwardingDelay
        rx_delay_variation_avg                   rxDelayVariationAverage
        rx_delay_variation_err_and_rate          rxDelayVariationErrorsAndRate
        rx_delay_variation_min_max_and_rate      rxDelayVariationMinMaxAndRate
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
            
    if {$action != "reset" && [is_default_param_value "latency_control" $args]} {
        unset latency_control
    }
    
    # Do basic verifications
    set init_args_540_ports ""
    if {[info exists port_handle]} {
        lappend init_args_540_ports $port_handle
    }
    if {[info exists port_handle2]} {
        lappend init_args_540_ports $port_handle2
    }
    
    if {[llength $init_args_540_ports] > 0} {
        set retCode [540IxNetInit $init_args_540_ports]
    } else {
        set retCode [540IxNetInit]
    }
    if {[keylget retCode status] != $::SUCCESS} {
        return $retCode
    }
    
    set ixNetTraffic [ixNet getRoot]traffic
    
    set ret_code [ixNetworkEvalCmd [list ixNet getL [ixNet getRoot]traffic statistics]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    set statistics_global_obj [keylget ret_code ret_val]
    
    set init_objects {
        sequence_global_obj             sequenceChecking
        cpdp_global_obj                 cpdpConvergence
        delay_variation_global_obj      delayVariation
        jitter_global_obj               interArrivalTimeRate
        latency_global_obj              latency
        l1_rate_stats_global_obj        l1Rates
        packet_loss_global_obj          packetLossDuration
    }
    
    foreach {hlt_obj_name ixn_obj_name} $init_objects {
        set ret_code [ixNetworkEvalCmd [list ixNet getL $statistics_global_obj $ixn_obj_name]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        set $hlt_obj_name [keylget ret_code ret_val]
    }
    
    # Determine what is enabled and what is going to get enabled
    # Then verify if it's a valid combination
    set ret_code [ixNetworkEvalCmd [list ixNet getA $sequence_global_obj -enabled]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    set sequence_enabled $reversed_truth([keylget ret_code ret_val])
    
    if {![info exists disable_latency_bins] && ![info exists disable_jitter_bins]} {
        if {[info exists latency_bins] && ($latency_bins == "enabled") } {
            set jitter_to_enable  0
            set latency_to_enable 1 
        } elseif {[info exists latency_bins] && [info exists latency_values]} {
            set jitter_to_enable  0
            set latency_to_enable 1 
        } elseif {[info exists jitter_bins] && ($jitter_bins == "enabled")} {
            set jitter_to_enable  1
            set latency_to_enable 0
        } elseif {[info exists jitter_bins] && [info exists jitter_values]} {
            set jitter_to_enable  1
            set latency_to_enable 0
        } elseif {[info exists latency_enable] && [info exists latency_enable]} {
            set jitter_to_enable  0
            set latency_to_enable $latency_enable
        } else {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $latency_global_obj -enabled]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set latency_to_enable $reversed_truth([keylget ret_code ret_val])
            
            set ret_code [ixNetworkEvalCmd [list ixNet getA $jitter_global_obj -enabled]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set jitter_to_enable $reversed_truth([keylget ret_code ret_val])
        }
    } else {
        if {[info exists disable_latency_bins]} {
            set latency_to_enable 0
        } elseif {[info exists latency_bins] && ($latency_bins == "enabled")} {
            set latency_to_enable  1
        } elseif {[info exists latency_bins] && [info exists latency_values]} {
            set latency_to_enable  1
        } else {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $latency_global_obj -enabled]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set latency_to_enable $reversed_truth([keylget ret_code ret_val])
        }
    
        if {[info exists disable_jitter_bins]} {
            set jitter_to_enable 0
        } elseif {[info exists jitter_bins] && ($jitter_bins == "enabled") } {
            set jitter_to_enable  1
        } elseif {[info exists jitter_bins] && [info exists jitter_values]} {
            set jitter_to_enable  1
        } else {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $jitter_global_obj -enabled]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set jitter_to_enable $reversed_truth([keylget ret_code ret_val])
        }
    }
    
    if {[info exists delay_variation_enable]} {
        if {$delay_variation_enable == 1} {
            set delay_variation_to_enable 1
        } else {
            set delay_variation_to_enable 0
        }
    } else {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $delay_variation_global_obj -enabled]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        set delay_variation_to_enable $reversed_truth([keylget ret_code ret_val])
    }
    
    if {[info exists packet_loss_duration_enable]} {
        if {$packet_loss_duration_enable == 1} {
            set packet_loss_to_enable 1
        } else {
            set packet_loss_to_enable 0
        }
    } else {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $packet_loss_global_obj -enabled]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        set packet_loss_to_enable $reversed_truth([keylget ret_code ret_val])
    }
    
    if {[info exists cpdp_convergence_enable]} {
        if {$cpdp_convergence_enable == 1} {
            set cpdp_to_enable 1
        } else {
            set cpdp_to_enable 0
        }
    } else {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $cpdp_global_obj -enabled]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        set cpdp_to_enable $reversed_truth([keylget ret_code ret_val])
    }
    
    set validity_vars [list                     \
            cpdp_to_enable                      \
            delay_variation_to_enable           \
            jitter_to_enable                    \
            latency_to_enable                   \
            packet_loss_to_enable               \
            sequence_enabled                    \
        ]
    foreach validity_var $validity_vars {
        append validity_number [set $validity_var]
    }
    
    set invalid_config 0
    set validity_number [format %x [convert_bits_to_int $validity_number]]
    if {[expr 0x$validity_number | 0x2b] == 63} {
        # Latency and delay_variation
        set invalid_config 1
        set log_msg "Invalid configuration. Latency and Delay variation measurement cannot be enabled\
                at the same time."
    } elseif {[expr 0x$validity_number | 0x33] == 63} {
        # Latency and jitter
        set invalid_config 1
        set log_msg "Invalid configuration. Latency and Jitter cannot be enabled\
                at the same time."
    } elseif {[expr 0x$validity_number | 0x27] == 63} {
        # Delay and  jitter
        set invalid_config 1
        set log_msg "Invalid configuration. Delay variation measurement and Jitter cannot be enabled\
                at the same time."
    } elseif {[expr 0x$validity_number | 0x2e] == 63} {
        # Delay and  sequence checking
        set invalid_config 1
        set log_msg "Invalid configuration. Delay variation measurement and Sequence checking cannot be enabled\
                at the same time."
    } elseif {[expr 0x$validity_number | 0x36] == 63} {
        # Jitter and Sequence checking
        set invalid_config 1
        set log_msg "Invalid configuration. Jitter and Sequence checking cannot be enabled\
                at the same time."
    }
    
    if {$invalid_config} {
        keylset returnList status $::FAILURE
        keylset returnList log $log_msg
        return $returnList
    }
    
    # Configure global stuff
    set param_map ""
    
    if {[info exists cpdp_to_enable]} {
        lappend param_map    cpdp_to_enable                                 enabled                             truth           cpdp_global_obj
        lappend param_map    cpdp_ctrl_plane_events_enable                  enableControlPlaneEvents            truth           cpdp_global_obj
        lappend param_map    cpdp_data_plane_events_rate_monitor_enable     enableDataPlaneEventsRateMonitor    truth           cpdp_global_obj
        lappend param_map    cpdp_data_plane_threshold                      dataPlaneThreshold                  value           cpdp_global_obj
        lappend param_map    cpdp_data_plane_jitter                         dataPlaneJitterWindow               translate_dpj   cpdp_global_obj
    }
    
    if {[info exists delay_variation_to_enable]} {
        lappend param_map    delay_variation_to_enable                      enabled                             truth           delay_variation_global_obj
        lappend param_map    latency_control                                latencyMode                         translate       delay_variation_global_obj
        lappend param_map    large_seq_number_err_threshold                 largeSequenceNumberErrorThreshold   value           delay_variation_global_obj
        lappend param_map    stats_mode                                     statisticsMode                      translate       delay_variation_global_obj
    }

    if {[info exists l1_rate_stats_enable]} {
        if { $action == "run" || $action == "sync_run" || $action == "stop" || $action == "reset"  } {
            lappend param_map    l1_rate_stats_enable                           enabled                             truth           l1_rate_stats_global_obj
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "-l1_rate_stats_enable parameter is not valid for action $action.\
                    l1_rate_stats_enable parameter is valid for the following actions: run , sync_run,\
                    stop or reset"
            return $returnList
        }
    }
    
    if {[info exists latency_enable]} {
        if {$latency_enable == 0} {
            if { ![info exists latency_values] && ![info exists latency_bins] } {
                set latency_to_enable 0
            }
        } else {
            if { ![info exists disable_latency_bins] &&\
                 !([info exists delay_variation_enable] && $delay_variation_enable == 1) &&\
                 !([info exists cpdp_convergence_enable] && $cpdp_convergence_enable == 1) &&\
                 !([info exists cpdp_data_plane_events_rate_monitor_enable] && $cpdp_data_plane_events_rate_monitor_enable == 1) &&\
                 ![info exists jitter_bins] && !$sequence_enabled} {
                 # enable latency statistics
                 set latency_to_enable 1
            }
        }
    }
    
    if {[info exists jitter_to_enable]} {
        lappend param_map    jitter_to_enable                               enabled                             truth           jitter_global_obj
    }
    
    if {[info exists latency_to_enable]} {
        lappend param_map    latency_to_enable                              enabled                             truth           latency_global_obj
        lappend param_map    latency_control                                mode                                translate       latency_global_obj
    }
    
    if {[info exists packet_loss_to_enable]} {
        lappend param_map    packet_loss_to_enable                          enabled                             truth           packet_loss_global_obj
    }
    
    foreach {global_obj placeholder} $init_objects {
        set ixn_args_${global_obj} ""
    }
    
    foreach {hlt_p ixn_p p_type p_obj_name} $param_map {
        if {[info exists $hlt_p]} {
            set hlt_p_val [set $hlt_p]
            switch -- $p_type {
                "value" {
                    set ixn_p_val $hlt_p_val
                }
                "truth" {
                    set ixn_p_val $truth($hlt_p_val)
                }
                "translate" {
                    if {![info exists translate_array($hlt_p_val)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Unexpected parameter value\
                                '$hlt_p_val' for parameter $hlt_p. Error occured in\
                                internal array 'translate_array' while configuring global statistic options."
                        return $returnList
                    }
                    set ixn_p_val $translate_array($hlt_p_val)
                }
                "translate_dpj" {
                    if {[info exists translate_dpj($hlt_p_val)]} {
                        set ixn_p_val $translate_dpj($hlt_p_val)
                    } else {
                        set ixn_p_val $hlt_p_val
                    }
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error. Unexpected parameter type '$p_type'\
                            for parameter '$hlt_p' having '$hlt_p_val' value. Error occured in\
                            internal array 'param_map' while configuring global statistic options."
                    return $returnList
                }
            }
            
            lappend ixn_args_${p_obj_name} -$ixn_p $ixn_p_val
        }
    }
    
    
    set commit_needed 0
    foreach {global_obj placeholder} $init_objects {
        set tmp_list_content [set ixn_args_${global_obj}]
        if {$tmp_list_content != ""} {
            set commit_needed 1
            set retCode [ixNetworkNodeSetAttr   \
                    [set $global_obj]           \
                    $tmp_list_content           ]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
    }
    
    if {$commit_needed} {
        set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
    }
    
    # Globals are configured
    # Configure latency bins on all traffic items that have RX port -port_handle
    if {([info exists latency_bins] && [info exists latency_values]) ||\
            ([info exists jitter_bins] && [info exists jitter_values])} {
        
        if {$latency_to_enable || $jitter_to_enable || $delay_variation_to_enable} {
        
            if {![info exists port_handle]} {
                set port_handle ""
            }
            
            set ret_code [540trafficGetTiWithRxPort $port_handle]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set ti_list [keylget ret_code handle_list]
            
            if {[llength $ti_list] != 0} {
                
                if {[info exists latency_bins] && [info exists latency_values]} {
                    set config_bins   $latency_bins
                    set config_values $latency_values
                } else {
                    set config_bins   $jitter_bins
                    set config_values $jitter_values
                }
                
                foreach traffic_item $ti_list {
                    # Verify if latency bins are configured on this traffic item
                    # If they are it means that they were configured with traffic_config
                    # and we shouldn't change them
                    
                    set ret_code [ixNetworkEvalCmd [list ixNet getL $traffic_item tracking]]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    set tracking_obj [keylget ret_code ret_val]
                    
                    set ret_code [ixNetworkEvalCmd [list ixNet getL $tracking_obj latencyBin]]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    set latency_bin_obj [keylget ret_code ret_val]
                    
                    set ret_code [ixNetworkEvalCmd [list ixNet getA $latency_bin_obj -enabled]]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    set tmp_enabled $reversed_truth([keylget ret_code ret_val])
                    if {$tmp_enabled} {
                        continue
                    }
                    
                    # Latency bins are not configured. Configure them
                    set ret_code [540trafficConfigureLatencyBins $traffic_item $config_bins $config_values]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                }
            }
        }
    }

    # note: there is already a regeneration part in ixia::ixnetwork_traffic_control
    # that part should be moved here in order to trigger the regeneration just once -ae
    set instantaneous_stats_ixn [ixNetworkGetAttr $ixNetTraffic -enableInstantaneousStatsSupport]
    if {[info exists instantaneous_stats_enable] &&                              \
        $instantaneous_stats_enable != $reversed_truth($instantaneous_stats_ixn) \
    } {
        # set and regenerate
        puts "WARNING: Instantaneous Statistics Support change detected - This will cause all traffic items to be regenerated!"
        ixNetworkSetAttr $ixNetTraffic -enableInstantaneousStatsSupport $truth($instantaneous_stats_enable)
        ixNetworkCommit
        set ret_code [::ixia::ixnetwork_traffic_control [list -action stop -max_wait_timer 30] $man_args $opt_args]
        if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
        }
        set ret_code [::ixia::ixnetwork_traffic_control [list -action regenerate] $man_args $opt_args]
        if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
        }
    }

    set 540IxNetTrafficState "unapplied"
    return $returnList
}

proc ::ixia::540userDefinedStats { args opt_args} {
    variable ixnetwork_port_handles_array
    variable ixnetwork_port_handles_array
    set keyed_array_index 0
    variable traffic_stats_num_calls
    set keyed_array_name traffic_stats_returned_keyed_array_$traffic_stats_num_calls
    mpincr traffic_stats_num_calls
    variable $keyed_array_name
    catch {array unset $keyed_array_name}
    array set $keyed_array_name ""
    variable traffic_stats_max_list_length
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    variable ${uds_type}_replace_stat_names_array
    
    keylset returnList status $::SUCCESS
    
    set retCode [540IxNetInit]
    if {[keylget retCode status] != $::SUCCESS} {
        return $retCode
    }
    
    array set uds_map {
        l23_protocol_port,ixnType           layer23ProtocolPort 
        l23_protocol_port,ixnAFilter        availablePortFilter
        l23_protocol_port,ixnAPFilter       availablePortFilter
        l23_protocol_port,ixnAPSFilter      availableProtocolStackFilter
        l23_protocol_port,ixnATIFilter      availableTrafficItemFilter
        l23_protocol_port,ixnATFilter       availableTrackingFilter
        l23_protocol_port,ixnASFilter       availableStatisticFilter
        l23_protocol_port,ixnVFilter        layer23ProtocolPortFilter
        l23_protocol_port,ixnVFilterParam   portFilterIds
        l23_protocol_port,uds_port_filter,ixnVFilter        layer23ProtocolPortFilter
        l23_protocol_port,uds_port_filter,ixnVFilterParam   portFilterIds
        
        l23_protocol_stack,ixnType           layer23ProtocolStack
        l23_protocol_stack,ixnAFilter        availableProtocolStackFilter
        l23_protocol_stack,ixnAPFilter       availablePortFilter
        l23_protocol_stack,ixnAPSFilter      availableProtocolStackFilter
        l23_protocol_stack,ixnATIFilter      availableTrafficItemFilter
        l23_protocol_stack,ixnATFilter       availableTrackingFilter
        l23_protocol_stack,ixnASFilter       availableStatisticFilter
        l23_protocol_stack,ixnVFilter        layer23ProtocolStackFilter
        l23_protocol_stack,ixnVFilterParam   protocolStackFilterId
        l23_protocol_stack,uds_protocol_stack_filter,ixnVFilter        layer23ProtocolStackFilter
        l23_protocol_stack,uds_protocol_stack_filter,ixnVFilterParam   protocolStackFilterId
        
        l23_traffic_flow,ixnType           layer23TrafficFlow
        l23_traffic_flow,ixnFilter         availableTrafficItemFilter
        l23_traffic_flow,ixnAPFilter       availablePortFilter
        l23_traffic_flow,ixnAPSFilter      availableProtocolStackFilter
        l23_traffic_flow,ixnATIFilter      availableTrafficItemFilter
        l23_traffic_flow,ixnATFilter       availableTrackingFilter
        l23_traffic_flow,ixnASFilter       availableStatisticFilter
        l23_traffic_flow,ixnVFilter        layer23TrafficFlowFilter
        l23_traffic_flow,ixnVFilterParam   trafficItemFilterId
        l23_traffic_flow,uds_traffic_item_filter,ixnVFilter        layer23TrafficFlowFilter
        l23_traffic_flow,uds_traffic_item_filter,ixnVFilterParam   trafficItemFilterId
        l23_traffic_flow,uds_port_filter,ixnVFilter        layer23TrafficFlowFilter
        l23_traffic_flow,uds_port_filter,ixnVFilterParam   portFilterIds
        
        l23_traffic_flow_detective,ixnType           layer23TrafficFlowDetective
        l23_traffic_flow_detective,ixnAFilter        availableTrafficItemFilter
        l23_traffic_flow_detective,ixnAPFilter       availablePortFilter
        l23_traffic_flow_detective,ixnAPSFilter      availableProtocolStackFilter
        l23_traffic_flow_detective,ixnATIFilter      availableTrafficItemFilter
        l23_traffic_flow_detective,ixnATFilter       availableTrackingFilter
        l23_traffic_flow_detective,ixnASFilter       availableStatisticFilter
        l23_traffic_flow_detective,ixnVFilter        layer23TrafficFlowDetectiveFilter
        l23_traffic_flow_detective,ixnVFilterParam   trafficItemFilterId
        l23_traffic_flow_detective,uds_traffic_item_filter,ixnVFilter        layer23TrafficFlowDetectiveFilter
        l23_traffic_flow_detective,uds_traffic_item_filter,ixnVFilterParam   trafficItemFilterId
        l23_traffic_flow_detective,uds_port_filter,ixnVFilter        layer23TrafficFlowDetectiveFilter
        l23_traffic_flow_detective,uds_port_filter,ixnVFilterParam   portFilterIds
        
        
        l23_traffic_item,ixnType           layer23TrafficItem
        l23_traffic_item,ixnAFilter        availableTrafficItemFilter
        l23_traffic_item,ixnAPFilter       availablePortFilter
        l23_traffic_item,ixnAPSFilter      availableProtocolStackFilter
        l23_traffic_item,ixnATIFilter      availableTrafficItemFilter
        l23_traffic_item,ixnATFilter       availableTrackingFilter
        l23_traffic_item,ixnASFilter       availableStatisticFilter
        l23_traffic_item,ixnVFilter        layer23TrafficItemFilter
        l23_traffic_item,ixnVFilterParam   trafficItemFilterIds
        l23_traffic_item,uds_traffic_item_filter,ixnVFilter        layer23TrafficItemFilter
        l23_traffic_item,uds_traffic_item_filter,ixnVFilterParam   trafficItemFilterIds
                
        
        l23_traffic_port,ixnType           layer23TrafficPort
        l23_traffic_port,ixnAFilter        availableTrafficPortFilter
        l23_traffic_port,ixnAPFilter       availablePortFilter
        l23_traffic_port,ixnAPSFilter      availableProtocolStackFilter
        l23_traffic_port,ixnATIFilter      availableTrafficItemFilter
        l23_traffic_port,ixnATFilter       availableTrackingFilter
        l23_traffic_port,ixnASFilter       availableStatisticFilter
        l23_traffic_port,ixnVFilter        layer23TrafficPortFilter
        l23_traffic_port,ixnVFilterParam   portFilterIds
        l23_traffic_port,uds_port_filter,ixnVFilter        layer23TrafficPortFilter
        l23_traffic_port,uds_port_filter,ixnVFilterParam   portFilterIds
        
        
        uds_port_filter,ixnAFilter                    availablePortFilter
        uds_protocol_stack_filter,ixnAFilter          availableProtocolStackFilter
        uds_traffic_item_filter,ixnAFilter            availableTrafficItemFilter
        uds_tracking_filter,ixnAFilter                availableTrackingFilter
        uds_statistic_filter,ixnAFilter               availableStatisticFilter
    }
    #l23_protocol_stack
    array set l23_protocol_stack_translate {
        per_session     perSession
        per_range       perRange
        ascending       true
        descending      false
    }
    
    set l23_protocol_stack_map {
        sortingStatistic        uds_l23ps_sorting_statistic     value
        sortAscending           uds_l23ps_sorting_type          translate
        numberOfResults         uds_l23ps_num_results           value
        drilldownType           uds_l23ps_drilldown             translate
    }
    #l23_traffic_flow
    array set l23_traffic_flow_translate {
        0                       false
        1                       true
        none                    none
        show_egress_flat_view   showEgressFlatView
        show_egress_rows        showEgressRows
        show_latency_bin_stats  showLatencyBinStats
    }
    
    set l23_traffic_flow_map {
        aggregatedAcrossPorts           uds_l23tf_aggregated_across_ports       translate
        egressLatencyBinDisplayOption   uds_l23tf_egress_latency_bin_display    translate
    }
    
    
    #l23_traffic_flow_detective
    array set l23_traffic_flow_detective_translate {
        0                       false
        1                       true
        all_flows               allFlows
        dead_flows              deadFlows
        live_flows              liveFlows
        ascending               ascending
        descending              descending
        worst_performers        worstPerformers
        best_performers         bestPerformers
    }
    
    set l23_traffic_flow_detective_map {
        deadFlowsThreshold           uds_l23tfd_dead_flows_treshold       value
        flowFilterType               uds_l23tfd_flow_type                 translate
        showEgressFlows              uds_l23tfd_show_egress_flows         translate
    }
    
    array set general_translate {
        is_any_of           isAnyOf
        is_different        isDifferent 
        is_equal            isEqual 
        is_equal_or_greater isEqualOrGreater 
        is_equal_or_smaller isEqualOrSmaller 
        is_greater          isGreater 
        is_in_any_range     isInAnyRange
        is_none_of          isNoneOf
        is_smaller          isSmaller
    }
    
    if {![info exists uds_action] || ![info exists uds_type]} {
        keylset returnList status $::FAILURE
        keylset returnList log "When -mode is $mode, parameters -uds_action and uds_type must be provided."
        return $returnList
    }
    
    # Check the traffic state
    ::ixia::set_waiting_for_stats_key
    
    switch -- $uds_action {
        get_available_port_filters -
        get_available_protocol_stack_filters -
        get_available_traffic_item_filters {
            if {$uds_action == "get_available_port_filters"} {
                set ixnFilter ixnAPFilter
            }
            if {$uds_action == "get_available_protocol_stack_filters"} {
                set ixnFilter ixnAPSFilter
            }
            if {$uds_action == "get_available_traffic_item_filters"} {
                set ixnFilter ixnATIFilter
            }
            # Create view if not already created
            set retCode [540CreateUserDefinedView $uds_type $uds_map($uds_type,ixnType) "create"]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            set view    [keylget retCode view]
            # Retrieve filters
            set [subst $keyed_array_name](filters) ""
            set filters [ixNet getList $view $uds_map($uds_type,$ixnFilter)]
            foreach filter $filters {
                regexp "::ixNet::OBJ-/statistics/view:\\\"${uds_type}\\\"/$uds_map($uds_type,$ixnFilter):\\\"(.+)\\\"" \
                        $filter filter_ignore filter_match
                if {[info exists filter_match]} {
                    lappend [subst $keyed_array_name](filters) $filter_match
                }
                catch {unset filter_match}
            }
        }
        get_available_tracking_filters -
        get_available_statistic_filters {
            # Create view if not already created
            set retCode [540CreateUserDefinedView $uds_type $uds_map($uds_type,ixnType) "create"]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            set view    [keylget retCode view]
            
            set commit 0
            # Apply port, protocol stack, traffic item filters
            set uds_filters {
                uds_port_filter
                uds_protocol_stack_filter
                uds_traffic_item_filter
            }
            foreach uds_filter $uds_filters {
                if {![info exists $uds_filter]} {
                    if {[info exists uds_map($uds_type,$uds_filter,ixnVFilterParam)] && \
                            [ixNet getAttribute ${view}/$uds_map($uds_type,ixnVFilter) \
                            -$uds_map($uds_type,$uds_filter,ixnVFilterParam)] == ""} {
                        set $uds_filter [ixNet getList $view $uds_map($uds_filter,ixnAFilter)]
                    }
                } else {
                    set uds_filters_temp [set $uds_filter]
                    set $uds_filter      ""
                    foreach uds_filter_temp $uds_filters_temp {
                        lappend $uds_filter ::ixNet::OBJ-/statistics/view:\"$uds_type\"/$uds_map($uds_filter,ixnAFilter):\"$uds_filter_temp\"
                    }
                }
                if {[info exists $uds_filter]} {
                    if {[set $uds_filter] == ""} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "There are no available filters for $view."
                        return $returnList
                    }
                    if {[info exists uds_map($uds_type,$uds_filter,ixnVFilterParam)]} {
                        if {[ixNet getAttribute ${view}/$uds_map($uds_type,$uds_filter,ixnVFilter) \
                                -$uds_map($uds_type,$uds_filter,ixnVFilterParam)] != "[set $uds_filter]"} {
                            ixNet setAttribute ${view}/$uds_map($uds_type,$uds_filter,ixnVFilter) \
                                    -$uds_map($uds_type,$uds_filter,ixnVFilterParam) [set $uds_filter]
                            ixNet setAttribute $view -enabled     false
                            ixNet setAttribute $view -visible     true
                            ixNet setAttribute $view -autoRefresh true
                            
                            set commit 1
                        }
                    }
                }
            }
            if {$commit} {
                if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to apply view settings: $retCode."
                    return $returnList
                }
            }
            if {$uds_action == "get_available_tracking_filters"} {
                set ixnATorSFilter ixnATFilter
            }
            if {$uds_action == "get_available_statistic_filters"} {
                set ixnATorSFilter ixnASFilter
            }
            # Retrieve filters
            set [subst $keyed_array_name](filters) ""
            set filters [ixNet getList $view $uds_map($uds_type,$ixnATorSFilter)]
            foreach filter $filters {
                regexp "::ixNet::OBJ-/statistics/view:\\\"${uds_type}\\\"/$uds_map($uds_type,$ixnATorSFilter):\\\"(.+)\\\"" \
                        $filter filter_ignore filter_match
                if {[info exists filter_match]} {
                    lappend [subst $keyed_array_name](filters) $filter_match
                }
                catch {unset filter_match}
            }
        }
        get_available_stats {
            # Get available stats
            set retCode [540GetStatViewStatistic $uds_type create $uds_type]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set [subst $keyed_array_name](statistics) [keylget retCode statistics]
        }
        get_stats {
            # Create view if not already created
            set retCode [540CreateUserDefinedView $uds_type $uds_map($uds_type,ixnType) "create"]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            set view    [keylget retCode view]
            set commit 0
            # Apply filters
            set uds_filters {
                uds_port_filter
                uds_protocol_stack_filter
                uds_traffic_item_filter
            }
            foreach uds_filter $uds_filters {
                if {![info exists $uds_filter]} {
                    if {[info exists uds_map($uds_type,$uds_filter,ixnVFilterParam)] && \
                            [ixNet getAttribute ${view}/$uds_map($uds_type,ixnVFilter) \
                            -$uds_map($uds_type,$uds_filter,ixnVFilterParam)] == ""} {
                        set $uds_filter [ixNet getList $view $uds_map($uds_filter,ixnAFilter)]
                    }
                } else {
                     if {$uds_filter == "uds_traffic_item_filter"} {; # the traffic name must be checked
                        if {[llength [set $uds_filter]] == 1} {;#
                            set uds_filters_temp [set $uds_filter]
                        } else {
                            # If the length of the uds_traffic_item_filter is greater the 1
                            # it could be a single traffic item that contains spaces(ex: "New Traffic Item")
                            # or it could be multiple traffic items(ex: "New Traffic Item" SecondTrafficItem)
                            set trafficItems [ixNet getList [ixNet getRoot]traffic trafficItem]
                            set trafficExists false
                            
                            # Check to see if there is a traffic item that has the same name with the
                            # uds_traffic_item_filter_parameter
                            foreach item $trafficItems {
                                if {[set $uds_filter] == [ixNet getAttribute $item -name]} {
                                    set trafficExists true
                                    break
                                }
                            }
                            
                            if {$trafficExists == true} {;# there is a single traffic item
                                set uds_filters_temp {}
                                lappend uds_filters_temp [set $uds_filter]
                            } else {;# the parameter represents multiple traffic items
                                set uds_filters_temp [set $uds_filter]
                            }
                        }
                    } else {
                        set uds_filters_temp [set $uds_filter]
                    }
                    
                    set $uds_filter      ""
                    foreach uds_filter_temp $uds_filters_temp {
                        if {[info exists ${uds_filter}_count] && ([set ${uds_filter}_count] == 1) } {
                            set uds_filter_temp $uds_filters_temp
                        }
                        lappend $uds_filter ::ixNet::OBJ-/statistics/view:\"$uds_type\"/$uds_map($uds_filter,ixnAFilter):\"$uds_filter_temp\"
                        
                        if {[info exists ${uds_filter}_count] && ([set ${uds_filter}_count] == 1) } {
                            break;
                        }
                    }
                }
                if {[info exists $uds_filter]} {
                    set ixnVFilter true
                    if {[set $uds_filter] == ""} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "There are no available filters for $view."
                        return $returnList
                    }
                    if {![info exists uds_map($uds_type,$uds_filter,ixnVFilterParam)]} {continue}
                    
                    if {[ixNet getAttribute ${view}/$uds_map($uds_type,ixnVFilter) \
                            -$uds_map($uds_type,$uds_filter,ixnVFilterParam)] != "[set $uds_filter]"} {
                        
                        if {$uds_map($uds_type,$uds_filter,ixnVFilterParam) == "trafficItemFilterId"} {
                            # If there are more than one traffic items to be set
                            if {[llength [set $uds_filter]] > 1} {
                                # ixPuts "Warning: Multiple available traffic item filters detected.\
                                        # Only one traffic item filter can be applied. Setting the\
                                        # traffic item filter to the first available filter."
                                #set $uds_filter [lindex [set $uds_filter] 0]
                                
                                # Set the trafficItemFiltersIds instead of trafficItemFiltersId
                                set ixnVFilter false
                                ixNet setAttribute ${view}/$uds_map($uds_type,ixnVFilter) \
                                    -trafficItemFilterIds [set $uds_filter]
                            }
                        }
                        
                        if {([llength [set $uds_filter]] == 1) && ([llength [lindex [set $uds_filter] 0]] != 1)} {
                            set $uds_filter "\{[lindex [set $uds_filter] 0]\}"
                        }
                        
                        if {$ixnVFilter == true} {
                            ixNet setAttribute ${view}/$uds_map($uds_type,ixnVFilter) \
                                    -$uds_map($uds_type,$uds_filter,ixnVFilterParam) [set $uds_filter]
                        }
                        ixNet setAttribute $view -enabled     false
                        ixNet setAttribute $view -visible     true
                        ixNet setAttribute $view -autoRefresh true
                        
                        set commit 1
                    }
                }
            }
            
            # l23_protocol_stack - Apply statistics sorting
            if {$uds_type == "l23_protocol_stack" && [info exists uds_l23ps_sorting_statistic]} {
                set uds_l23ps_sorting_statistic_temp ""
                foreach statistic $uds_l23ps_sorting_statistic {
                    if {[info exists ${uds_type}_replace_stat_names_array($statistic)]} {
                        lappend uds_l23ps_sorting_statistic_temp "::ixNet::OBJ-/statistics/view:\"${uds_type}\"/statistic:\"[set ${uds_type}_replace_stat_names_array($statistic)]\""
                    }
                }
            }
            
            # l23_traffic_flow - Add enumeration filters and tracking filters
            if {$uds_type == "l23_traffic_flow" } {
                if {[info exists uds_tracking_filter] && [info exists uds_l23tf_filter_type]} {
                    # Set parameters to the same length
                    if {[info exists uds_tracking_filter_count]} {
                        if {[llength $uds_tracking_filter] != $uds_tracking_filter_count} {
                            if {$uds_tracking_filter_count == 1} {
                                set tempUdsTf "{"
                                append tempUdsTf $uds_tracking_filter
                                append tempUdsTf "}"
                                set uds_tracking_filter $tempUdsTf
                            }
                        }
                    }
                    if {[llength $uds_tracking_filter] > [llength $uds_l23tf_filter_type]} {
                        while {[llength $uds_tracking_filter] > [llength $uds_l23tf_filter_type]} {
                            lappend uds_l23tf_filter_type [lindex $uds_l23tf_filter_type end]
                        }
                    } else {
                        set uds_l23tf_filter_type [lrange $uds_l23tf_filter_type 0 [expr [llength $uds_tracking_filter] - 1] ]
                    }
                    set index 0
                    foreach uds_l23tf_filter_elem $uds_tracking_filter uds_l23tf_filter_type_elem $uds_l23tf_filter_type {
                        set uds_l23tf_filter_elem ::ixNet::OBJ-/statistics/view:"$uds_type"/$uds_map($uds_type,ixnATFilter):"$uds_l23tf_filter_elem"
                        
                        set enumerationFilterList [ixNet getList ${view}/$uds_map($uds_type,ixnVFilter) enumerationFilter]
                        set enumerationFilter "null"
                        
                        # if a filter with the same trackingFilterId already exists overwrite it
                        foreach eFilter $enumerationFilterList {
                            if {[ixNet getAttribute $eFilter -trackingFilterId] == $uds_l23tf_filter_elem} {
                                set enumerationFilter $eFilter
                                break
                            }
                        }
                        
                        if {$uds_l23tf_filter_type_elem == "enumeration"} {
                            if {$enumerationFilter == "null"} { ;# if it doesn't exist create a new filter
                                set enumerationFilter [ixNet add ${view}/$uds_map($uds_type,ixnVFilter) enumerationFilter]
                                ixNet setAttribute $enumerationFilter -trackingFilterId $uds_l23tf_filter_elem
                            }
                            
                            if {[info exists uds_l23tf_enumeration_sorting_type]} {
                                set uds_l23tf_enumeration_sorting_type_elem \
                                        [lindex $uds_l23tf_enumeration_sorting_type $index]
                                if {$uds_l23tf_enumeration_sorting_type_elem != "null"} {
                                    ixNet setAttribute $enumerationFilter -sortDirection \
                                            $uds_l23tf_enumeration_sorting_type_elem
                                }
                            }
                        }
                        if {$uds_l23tf_filter_type_elem == "tracking"} {
                            if {$enumerationFilter == "null"} { ;# if it doesn't exist create a new filter
                                set enumerationFilter [ixNet add ${view}/$uds_map($uds_type,ixnVFilter) enumerationFilter]
                                ixNet setAttribute $enumerationFilter -trackingFilterId $uds_l23tf_filter_elem
                                
                                if {[info exists uds_l23tf_enumeration_sorting_type]} {
                                    set uds_l23tf_enumeration_sorting_type_elem \
                                            [lindex $uds_l23tf_enumeration_sorting_type $index]
                                    if {$uds_l23tf_enumeration_sorting_type_elem != "null"} {
                                        ixNet setAttribute $enumerationFilter -sortDirection \
                                                $uds_l23tf_enumeration_sorting_type_elem
                                    }
                                }
                            }
                        
                            set trackingFilter [ixNet add ${view}/$uds_map($uds_type,ixnVFilter) trackingFilter]
                            ixNet setAttribute $trackingFilter -trackingFilterId $uds_l23tf_filter_elem
                            
                            # Operator
                            if {[info exists uds_l23tf_tracking_operator]} {
                                set uds_l23tf_tracking_operator_elem \
                                        [lindex $uds_l23tf_tracking_operator $index]
                                if {$uds_l23tf_tracking_operator_elem != "null" && \
                                        [info exists general_translate($uds_l23tf_tracking_operator_elem)]} {
                                    ixNet setAttribute $trackingFilter -operator \
                                            $general_translate($uds_l23tf_tracking_operator_elem)
                                }
                            }
                            # Value
                            if {[info exists uds_l23tf_tracking_value]} {
                                set uds_l23tf_tracking_value_elem \
                                        [lindex $uds_l23tf_tracking_value $index]
                                if {$uds_l23tf_tracking_value_elem != "null"} {
                                    
                                    if {[isValidIPAddress $uds_l23tf_tracking_value_elem]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Invalid uds_l23tf_tracking_value '$uds_l23tf_tracking_value_elem'.\
                                                Valid format is <IP Address>/<Numeric Mask>."
                                        return $returnList
                                    } elseif {[isValidIPv4AddressAndPrefix $uds_l23tf_tracking_value_elem]} {
                                        foreach {tmp_ip tmp_mask} [split $uds_l23tf_tracking_value_elem /] {}
                                        
                                        set tmp_mask [getIpV4MaskFromWidth $tmp_mask]
                                        
                                        set ixn_val $tmp_ip/$tmp_mask
                                        
                                        catch {unset tmp_ip}
                                        catch {unset tmp_mask}
                                    } elseif {[isValidIPv6AddressAndPrefix $uds_l23tf_tracking_value_elem]} {
                                        foreach {tmp_ip tmp_mask} [split $uds_l23tf_tracking_value_elem /] {}
                                        
                                        set ret_code [getIpV6NetMaskFromPrefixLen $tmp_mask]
                                        if {[keylget ret_code status] != $::SUCCESS} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "Error occured while configuring\
                                                -uds_l23tfd_statistic_value '$uds_l23tf_tracking_value_elem'.\
                                                Failed to transform IPv6 mask width to IPv6 mask. [keylget ret_code log]"
                                            return $returnList
                                        }
                                        
                                        set tmp_mask [keylget ret_code hexNetAddr]
                                        
                                        set ixn_val $tmp_ip/$tmp_mask
                                        
                                        catch {unset tmp_ip}
                                        catch {unset tmp_mask}
                                    } else {
                                        set ixn_val $uds_l23tf_tracking_value_elem
                                    }
                                    
                                    ixNet setAttribute $trackingFilter -value \
                                            $ixn_val
                                    
                                }
                            }
                        }
                        incr index
                        
                        # Commit changes in order to save the current enumeration filters
                        if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to apply view settings: $retCode."
                            return $returnList
                        }
                    }
                }
            }
                
            # l23_traffic_flow_detective - Add statistic filters and tracking filters
            if {$uds_type == "l23_traffic_flow_detective" } {
                if {[info exists uds_tracking_filter]} {
                    set index 0
                    foreach uds_l23tfd_filter_elem $uds_tracking_filter {
                        if {[info exists uds_tracking_filter_count] && ($uds_tracking_filter_count == 1) } {
                            set uds_l23tfd_filter_elem $uds_tracking_filter
                        }
                        set uds_l23tfd_filter_elem ::ixNet::OBJ-/statistics/view:"$uds_type"/$uds_map($uds_type,ixnATFilter):"$uds_l23tfd_filter_elem"
                        
                        set trackingFilter [ixNet add ${view}/$uds_map($uds_type,ixnVFilter) trackingFilter]
                        ixNet setAttribute $trackingFilter -trackingFilterId $uds_l23tfd_filter_elem
                        
                        # Operator
                        if {[info exists uds_l23tfd_tracking_operator]} {
                            set uds_l23tfd_tracking_operator_elem \
                                    [lindex $uds_l23tfd_tracking_operator $index]
                            if {$uds_l23tfd_tracking_operator_elem != "null" && \
                                        [info exists general_translate($uds_l23tfd_tracking_operator_elem)]} {
                                ixNet setAttribute $trackingFilter -operator \
                                        $general_translate($uds_l23tfd_tracking_operator_elem)
                            }
                        }
                        # Value
                        if {[info exists uds_l23tfd_tracking_value]} {
                            set uds_l23tfd_tracking_value_elem \
                                    [lindex $uds_l23tfd_tracking_value $index]
                            if {$uds_l23tfd_tracking_value_elem != "null"} {
                                ixNet setAttribute $trackingFilter -value \
                                        $uds_l23tfd_tracking_value_elem
                            }
                        }
                        incr index
                        if {[info exists uds_tracking_filter_count] && ($uds_tracking_filter_count == 1) } {
                            break;
                        }
                    }
                }
                if {[info exists uds_statistic_filter]} {
                    set index 0
                    foreach uds_l23tfd_filter_elem $uds_statistic_filter {
                        if {[info exists uds_statistic_filter_count] && ($uds_statistic_filter_count == 1) } {
                            set uds_l23tfd_filter_elem $uds_statistic_filter
                        }
                        set uds_l23tfd_filter_elem ::ixNet::OBJ-/statistics/view:"$uds_type"/$uds_map($uds_type,ixnASFilter):"$uds_l23tfd_filter_elem"
                        
                        set statisticFilter [ixNet add ${view}/$uds_map($uds_type,ixnVFilter) statisticFilter]
                        ixNet setAttribute $statisticFilter -statisticFilterId $uds_l23tfd_filter_elem
                        
                        # Operator
                        if {[info exists uds_l23tfd_statistic_operator]} {
                            set uds_l23tfd_statistic_operator_elem \
                                    [lindex $uds_l23tfd_statistic_operator $index]
                            if {$uds_l23tfd_statistic_operator_elem != "null" && \
                                        [info exists general_translate($uds_l23tfd_statistic_operator_elem)]} {
                                ixNet setAttribute $statisticFilter -operator \
                                        $general_translate($uds_l23tfd_statistic_operator_elem)
                            }
                        }
                        # Value
                        if {[info exists uds_l23tfd_statistic_value]} {
                            set uds_l23tfd_statistic_value_elem \
                                    [lindex $uds_l23tfd_statistic_value $index]
                            if {$uds_l23tfd_statistic_value_elem != "null"} {
                                
                                if {[isValidIPAddress $uds_l23tfd_statistic_value_elem]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid uds_l23tfd_statistic_value '$uds_l23tfd_statistic_value_elem'.\
                                            Valid format is <IP Address>/<Numeric Mask>."
                                    return $returnList
                                } elseif {[isValidIPv4AddressAndPrefix $uds_l23tfd_statistic_value_elem]} {
                                    foreach {tmp_ip tmp_mask} [split $uds_l23tfd_statistic_value_elem /] {}
                                    
                                    set tmp_mask [getIpV4MaskFromWidth $tmp_mask]
                                    
                                    set ixn_val $tmp_ip/$tmp_mask
                                    
                                    catch {unset tmp_ip}
                                    catch {unset tmp_mask}
                                } elseif {[isValidIPv6AddressAndPrefix $uds_l23tfd_statistic_value_elem]} {
                                    foreach {tmp_ip tmp_mask} [split $uds_l23tfd_statistic_value_elem /] {}
                                    
                                    set ret_code [getIpV6NetMaskFromPrefixLen $tmp_mask]
                                    if {[keylget ret_code status] != $::SUCCESS} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Error occured while configuring\
                                                -uds_l23tfd_statistic_value '$uds_l23tfd_statistic_value_elem'.\
                                                Failed to transform IPv6 mask width to IPv6 mask. [keylget ret_code log]"
                                        return $returnList
                                    }
                                    
                                    set tmp_mask [keylget ret_code hexNetAddr]
                                    
                                    set ixn_val $tmp_ip/$tmp_mask
                                    
                                    catch {unset tmp_ip}
                                    catch {unset tmp_mask}
                                } else {
                                    set ixn_val $uds_l23tfd_statistic_value_elem
                                }
                                
                                ixNet setAttribute $statisticFilter -value \
                                        $ixn_val
                            }
                        }
                        incr index
                        if {[info exists uds_statistic_filter_count] && ($uds_statistic_filter_count == 1) } {
                            break;
                        }
                    }
                    array set flows_list {
                        all     allFlowsFilter
                        dead    deadFlowsFilter
                        live    liveFlowsFilter
                    }
                    foreach fft [array names flows_list] {
                        if {[info exists uds_l23tfd_statistic_${fft}_flows_sort_by]} {
                            ixNet setAttribute ${view}/$uds_map($uds_type,ixnVFilter)/$flows_list($fft) \
                                    -sortByStatisticId \
                                    ::ixNet::OBJ-/statistics/view:"$uds_type"/$uds_map($uds_type,ixnASFilter):"[set uds_l23tfd_statistic_${fft}_flows_sort_by]"
                            if {[info exists uds_l23tfd_statistic_${fft}_flows_sorting_type] && \
                                    [set uds_l23tfd_statistic_${fft}_flows_sorting_type] != "null"} {
                                ixNet setAttribute ${view}/$uds_map($uds_type,ixnVFilter)/$flows_list($fft) \
                                        -sortingCondition \
                                        $l23_traffic_flow_detective_translate([set uds_l23tfd_statistic_${fft}_flows_sorting_type])
                            }
                            if {[info exists uds_l23tfd_statistic_${fft}_flows_num_results]} {
                                ixNet setAttribute ${view}/$uds_map($uds_type,ixnVFilter)/$flows_list($fft) \
                                        -numberOfResults \
                                        [set uds_l23tfd_statistic_${fft}_flows_num_results]
                            }
                        }
                    }
                }
            }
            
            # Set other parameters, except filters
            if {[info exists ${uds_type}_map]} {
                foreach {ixnParam hltParam paramType} [set ${uds_type}_map] {
                    if {[info exists $hltParam]} {
                        switch $paramType {
                            value {
                                if {[ixNet getAttribute ${view}/$uds_map($uds_type,ixnVFilter) \
                                        -$ixnParam] != [set $hltParam]} {
                                    ixNet setAttribute ${view}/$uds_map($uds_type,ixnVFilter) \
                                            -$ixnParam [set $hltParam]
                                    set commit 1
                                }
                            }
                            translate {
                                if {[info exists ${uds_type}_translate([set $hltParam])]} {
                                    if {[ixNet getAttribute ${view}/$uds_map($uds_type,ixnVFilter) \
                                            -$ixnParam] != [set ${uds_type}_translate([set $hltParam])]} {
                                        ixNet setAttribute ${view}/$uds_map($uds_type,ixnVFilter) \
                                                -$ixnParam \
                                                [set ${uds_type}_translate([set $hltParam])]
                                        set commit 1
                                    }
                                }
                            }
                            default {}
                        }
                    }
                }
            }
            
            if {$commit} {
                if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to apply view settings: $retCode."
                    return $returnList
                }
            }
            # Get stats
            
            set retCode [540GetStatView $uds_type create 0 $uds_type]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            if {[catch {540ReturnUserDefinedViewValues} retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to retrieve stat values for $view: $retCode."
                return $returnList
            }
        }
        default {}
    }
    
    if {$return_method == "csv" && $uds_action != "get_stats"} {
        # the csv file will be created only for get_stats action.
        set return_method keyed_list
    }
    
    switch -- $return_method {
        "keyed_list" {
            set [subst $keyed_array_name](status) $::SUCCESS
            set retTemp [array get $keyed_array_name]
            eval "keylset returnList $retTemp"
        }
        "keyed_list_or_array" {
            if {$keyed_array_index < $traffic_stats_max_list_length} {
                set [subst $keyed_array_name](status) $::SUCCESS
                set retTemp [array get $keyed_array_name]
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
        }
        "csv" {
            if {[info exists view] && $view != ""} {
                # Take snapshot and return the csv file
                set csvList ""
                if {[regexp {"(\w+)"} $view view_name_without_quote view_name_without_quote]} {
                    set retCode [540GetStatViewSnapshot $view_name_without_quote $mode 0 "" 1]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to get snapshot with $view_name_without_quote, while\
                                retrieving $mode statistics. [keylget retCode log]"
                        return $returnList
                    }
                    
                    lappend csvList [keylget retCode csv_file]
                    set ::ixia::clear_csv_stats([keylget retCode csv_file]) "[keylget retCode csv_file]"
                }
                keylset returnList csv_file $csvList
            }
            
            keylset returnList status $::SUCCESS
        }
    }
    
    return $returnList
}

# Check the traffic state and sets the waiting_for_stats key accordingly
proc ::ixia::set_waiting_for_stats_key {{mode ""}} {
    uplevel {
        set warning_message {\nWarning: Traffic statistics are not fully available yet. Current traffic\
                            state is $trafficState. For accurate results call the procedure once more\
                            and check the 'waiting_for_stats' returned key (0 indicates that traffic\
                            statistics are ready)\n}
                            
        if {$mode == "L47_traffic_item" || $mode == "L47_flow_initiator" || $mode == "L47_flow_responder" || \
            $mode == "L47_traffic_item_tcp" || $mode == "L47_flow_initiator_tcp" || $mode == "L47_listening_port_tcp"} {
            ;# Treat the L47 AppLib traffic item
            set trafficItems [ixNet getL [ixNet getRoot]traffic trafficItem]
            set waiting_for_stats 1
            foreach trafficItem $trafficItems {
                if {[ixNet getA $trafficItem -trafficItemType] != "applicationLibrary"} {
                    continue
                }
                set trafficState [ixNet getA [ixNet getL $trafficItem appLibProfile] -trafficState]
                switch $trafficState {
                    Configured -
                    Running {
                        set waiting_for_stats 0
                        break
                    }
                }
            }
            keylset returnList waiting_for_stats $waiting_for_stats
            if {$waiting_for_stats} {
                puts [subst $warning_message]
            }
                            
        } elseif {![regexp "^application_" $mode]} {;# Treat the L23 traffic item
            if {[catch {set trafficState [ixNet getAttribute [ixNet getRoot]traffic -state]}]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error while reading traffic state."
                return $returnList
            }
            
            switch $trafficState {
                started -
                stopped {
                    keylset returnList waiting_for_stats 0
                }
                default {
                    keylset returnList waiting_for_stats 1
                    puts [subst $warning_message]
                }
            }
        } else {;# Treat the L47 traffic item
            if {[catch {set trafficState [ixNet getAttribute [ixNet getRoot]traffic -applicationState]}]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error while reading traffic state."
                return $returnList
            }
            
            switch $trafficState {
                testRunning -
                testUnconfigured {
                    keylset returnList waiting_for_stats 0
                }
                default {
                    keylset returnList waiting_for_stats 1
                    puts [subst $warning_message]
                }
            }
        }
    }
}
proc ::ixia::check_port_for_applib_traffic {traffic_handle port drill_down_type} {

    #get the endpoint set
    set endpointset_list [ixNet getList $traffic_handle endpointSet]
    
    set port_found 0
    
    foreach endpointset $endpointset_list {    
        switch -- $drill_down_type {
            "per_initiator_ports_per_initiator_ips" -
            "per_initiator_flows_per_initiator_ports_per_initiator_ips" {
                set src_topology [ixNet getA $endpointset -sources] 
                if {[::ixia::check_ports_for_topology $src_topology $port]} {
                    set port_found 1
                    break
                }
            }
            "per_responder_ports_per_responder_ips" -
            "per_responder_flows_per_responder_ports_per_responder_ips" {
                set dst_topology [ixNet getA $endpointset -destinations]
                if {[::ixia::check_ports_for_topology $dst_topology $port]} {
                    set port_found 1
                    break
                }
            }
            default {
                set src_topology [ixNet getA $endpointset -sources] 
                if {[::ixia::check_ports_for_topology $src_topology $port]} {
                    set port_found 1
                    break
                }
                set dst_topology [ixNet getA $endpointset -destinations]
                if {[::ixia::check_ports_for_topology $dst_topology $port]} {
                    set port_found 1
                    break
                }
            }
        }
    }
    
    return $port_found
}

proc ::ixia::check_ports_for_topology {topologyList port} {

    set root [ixNet getRoot]
    set vport_list ""    
  
    # get vports for the topology
    foreach topology $topologyList {   
        lappend vport_list [ixNet getA $topology -vports]
    }
    
    set port_found 0
    
    foreach vport $vport_list {
        if {$port == [ixNet getA $vport -name]} {
            set port_found 1
            break
        }
    }
    
    return $port_found
}