proc ::ixia::efm_increment_hex_field {start_value step_value counter {max_value {_no_limit} } {mode {round_robin} } } {
    
    # Parameters start_value step_value max_value must be HEX
    # Return value will be HEX 
    
    set width [string length $start_value]
#     set width [mpexpr $width * 8]
    
    if {$counter == 0} {
        return $start_value
    } else {
        set counter [mpformat %x $counter]
        
        set incr_amount [mpexpr $step_value * $counter]
        
        set ixn_param_value [mpexpr $start_value + $incr_amount]
        
        set ixn_param_value [mpformat %x $ixn_param_value]
        
        if {$max_value != "_no_limit"} {
            if {[mpexpr $width > [string length $max_value]]} {
                set width [string length $max_value]
            }
            set ixn_param_value [mpexpr $ixn_param_value % $max_value]
            set ixn_param_value [mpformat %x $ixn_param_value]
        }
        
        if {[mpexpr $width > [string length $ixn_param_value]]} {
            set width [mpexpr ($width - 2) * 4]
            set ixn_param_value [::ixia::format_hex $ixn_param_value $width]
            set ixn_param_value 0x[regsub -all { } $ixn_param_value {}]
        }
    }
    
    return $ixn_param_value
}

proc ::ixia::efm_increment_dec_field {start_value step_value counter {max_value {_no_limit} } {mode {round_robin} } } {
    
    # All parameters must be in decimal format
    # Return value is numeric
    
    if {$counter == 0} {
        return $start_value
    } else {
        set incr_amount [mpexpr $step_value * $counter]
        
        set ixn_param_value [mpexpr $start_value + $incr_amount]
        
        if {$max_value != "_no_limit"} {
            set ixn_param_value [mpexpr $ixn_param_value % $max_value]
        }
    }
    
    return $ixn_param_value
}


proc ::ixia::check_efm_port {port_handle} {
    # Verify if efm was configured on port $port_handle
    keylset returnList status $::SUCCESS
    
    set retCode [ixNetworkGetPortObjref $port_handle]
    if {[keylget retCode status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to find the port object reference \
                associated to the $port_handle port handle. Make sure you configured\
                an Oam Link object with ::ixia::emulation_efm_config procedure call\
                before calling this procedure. - [keylget retCode log]."
        return $returnList
    }
    set vport_objref    [keylget retCode vport_objref]
    set protocol_objref [keylget retCode vport_objref]/protocols/linkOam
    
    # Make sure an oam link object is configured on this port before adding chid objects
    set link_obj_list [ixNet getList $protocol_objref link]
    
    if {$link_obj_list == ""} {
        
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to find an Oam Link object reference \
                on the $port_handle port handle. Make sure you configured\
                an Oam Link object with ::ixia::emulation_efm_config procedure call\
                before calling this procedure."
        return $returnList
        
    } elseif {[llength $link_obj_list] > 1} {
        
        puts "\nWARNING: Multiple OAM Link objects exit on the current port $port_handle.\
                This cannot be configured from HLTAPI and might cause the implementation \
                to misbehave .\n The first link object will be used."
        
        set link_obj [lindex $link_obj_list 0]
        
    } else {
    
        set link_obj $link_obj_list
        
    }
    
    keylset returnList link_handle      $link_obj
    keylset returnList vport_handle     $vport_objref
    keylset returnList protocol_handle  $protocol_objref
    
    return $returnList
}


proc ::ixia::get_efm_learned_info {     \
        stat_keys                       \
        obj_handle                      \
        exec_call                       \
        done_flag                       \
        info_obj_name                   \
        ret_list_name                   \
    } {
    
    keylset returnList status $::SUCCESS
    
    # init lists of keys
    foreach {hlt_key ixn_key} $stat_keys {
        set $hlt_key ""
    }
    
    # refresh loopback info
    if {[catch {ixNet exec $exec_call $obj_handle} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to $exec_call. $err"
        return $returnList
    }
    
    # check if info was learnt
    set retry_count 15
    for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
        set msg [ixNet getAttribute $obj_handle -$done_flag]
        if {$msg == "true"} {
            break
        }
        
        after 500
    }
    
    if {$iteration >= $retry_count} {
        keylset returnList status $::FAILURE
        keylset returnList log "Statistics are not available."
        return $returnList
    }
    
    after 1000
    
    upvar $ret_list_name return_list
    
    set info_obj_list [ixNet getList $obj_handle $info_obj_name]
    foreach info_obj $info_obj_list {
        
        set na_flag 0
        
        if {$info_obj_name == "discoveredLearnedInfo"} {
            
            # Check new funky flags remoteHeaderRefreshed and remoteTlvRefreshed

            for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
                if {[ixNet getAttribute $info_obj -remoteHeaderRefreshed] == "true" && \
                        [ixNet getAttribute $info_obj -remoteTlvRefreshed] == "true"} {

                    break
                }
                
                after 500
            }
            
            if {$iteration >= $retry_count} {
                set na_flag 1
            }
            
        }
    
        foreach {hlt_key ixn_key} $stat_keys {
            if {$na_flag} {
                set ixn_key_value "N/A"
            } else {
                set ixn_key_value [ixNet getAttribute $info_obj -$ixn_key]
                regsub -all { } $ixn_key_value ":"
            }
            
            lappend $hlt_key  $ixn_key_value
        }
    }
    
    
    
    foreach {hlt_key ixn_key} $stat_keys {
        if {[set $hlt_key] == ""} {
            set $hlt_key "N/A"
        }
        
        keylset return_list $hlt_key [set $hlt_key]
    }
    
    return $returnList
}

proc ::ixia::get_efm_aggregate_stats {port_handles ret_list_name} {
    
    keylset returnList status $::SUCCESS
    
    upvar $ret_list_name return_list
    
    array set stats_array_aggregate {
        "Port Name"                                         statistics.port_name
        "Information PDU Tx"                                statistics.oampdu_count.information_tx
        "Information PDU Rx"                                statistics.oampdu_count.information_rx
        "Event Notification PDU Rx"                         statistics.oampdu_count.event_notification_rx
        "Organization Specific PDU Rx"                      statistics.oampdu_count.organization_rx
        "Variable Request PDU Rx"                           statistics.oampdu_count.variable_request_rx
        "Variable Response PDU Rx"                          statistics.oampdu_count.variable_response_rx
        "Unsupported PDU Rx"                                statistics.oampdu_count.unsupported_rx
        "Errored Symbol Period Event Running Total Rx"      statistics.alarms.errored_symbol_period_events
        "Errored Frame Event Running Total Rx"              statistics.alarms.errored_frame_events
        "Errored Frame Period Event Running Total Rx"       statistics.alarms.errored_frame_period_events
        "Errored Frame SS Event Running Total Rx"           statistics.alarms.errored_frame_seconds_summary_events
        "Event Notification PDU Tx"                         statistics.oampdu_count.event_notification_tx
        "Loopback Enable Control PDU Rx"                    statistics.oampdu_count.loopback_control_enable_rx
        "Loopback Disable Control PDU Rx"                   statistics.oampdu_count.loopback_control_disable_rx
        "Links Configured"                                  statistics.oampdu_count.links_configured
        "Links Running"                                     statistics.oampdu_count.links_running
        "Local Discovery State"                             statistics.oampdu_count.local_discovery_status
        "Unique Information PDU Tx"                         statistics.oampdu_count.information_tx_unique
        "Unique Information PDU Rx"                         statistics.oampdu_count.information_rx_unique
        "Unique Event Notification PDU Tx"                  statistics.oampdu_count.event_notification_tx_unique
        "Unique Event Notification PDU Rx"                  statistics.oampdu_count.event_notification_rx_unique
        "Variable Request PDU Tx"                           statistics.oampdu_count.variable_request_tx
        "Variable Response PDU Tx"                          statistics.oampdu_count.variable_response_tx
        "Loopback Enable Control PDU Tx"                    statistics.oampdu_count.loopback_control_enable_tx
        "Loopback Disable Control PDU Tx"                   statistics.oampdu_count.loopback_control_disable_tx
        "Errored Symbol Period Event Running Total Tx"      statistics.alarms.errored_symbol_period_events_tx
        "Errored Symbol Period Error Running Total Tx"      statistics.alarms.errored_symbol_period_errors_tx
        "Errored Symbol Period Error Running Total Rx"      statistics.alarms.errored_symbol_period_errors
        "Errored Frame Event Running Total Tx"              statistics.alarms.errored_frame_events_tx
        "Errored Frame Error Running Total Tx"              statistics.alarms.errored_frame_errors_tx
        "Errored Frame Error Running Total Rx"              statistics.alarms.errored_frame_errors
        "Errored Frame Period Event Running Total Tx"       statistics.alarms.errored_frame_period_events_tx
        "Errored Frame Period Error Running Total Tx"       statistics.alarms.errored_frame_period_errors_tx
        "Errored Frame Period Error Running Total Rx"       statistics.alarms.errored_frame_period_errors
        "Errored Frame SS Event Running Total Tx"           statistics.alarms.errored_frame_seconds_summary_events_tx
        "Errored Frame SS Error Running Total Tx"           statistics.alarms.errored_frame_seconds_summary_errors_tx
        "Errored Frame SS Error Running Total Rx"           statistics.alarms.errored_frame_seconds_summary_errors
        "Organization Specific PDU Tx"                      statistics.oampdu_count.organization_tx
        "Link Fault Tx"                                     statistics.oampdu_count.remote_link_fault_tx
        "Link Fault Rx"                                     statistics.oampdu_count.remote_link_fault_rx
        "Dying Gasp Tx"                                     statistics.oampdu_count.remote_dying_gasp_tx
        "Dying Gasp Rx"                                     statistics.oampdu_count.remote_dying_gasp_rx
        "Critical Event Tx"                                 statistics.oampdu_count.remote_critical_event_tx
        "Critical Event Rx"                                 statistics.oampdu_count.remote_critical_event_rx
    }
    
    set statistic_types {
        aggregate "OAM Aggregated Statistics"
    }
    
    foreach {stat_type stat_name} $statistic_types {
        set stats_array_name stats_array_${stat_type}
        array set stats_array [array get $stats_array_name]
    
        set returned_stats_list [ixNetworkGetStats \
                $stat_name [array names stats_array]]
        if {[keylget returned_stats_list status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to read\
                    $stat_name from stat view browser.\
                    [keylget returned_stats_list log]"
            return $returnList
        }
    
        set found_ports ""
        set row_count [keylget returned_stats_list row_count]
        array set rows_array [keylget returned_stats_list statistics]
        
        for {set i 1} {$i <= $row_count} {incr i} {
            set row_name $rows_array($i)
            set match [regexp {(.+)/Card([0-9]{2})/Port([0-9]{2})} \
                    $row_name match_name hostname card_no port_no]
            if {$match && [catch {set chassis_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                set chassis_ip $hostname
            }
            if {$match && ($match_name == $row_name) && \
                    [info exists chassis_ip] && [info exists card_no] && \
                    [info exists port_no] } {
                set chassis_no [ixNetworkGetChassisId $chassis_ip]
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to interpret the '$row_name'\
                        row name."
                return $returnList
            }
            regsub {^0} $card_no "" card_no
            regsub {^0} $port_no "" port_no
            if {[lsearch $port_handles "$chassis_no/$card_no/$port_no"] != -1} {
                set port_key $chassis_no/$card_no/$port_no
                lappend found_ports $port_key
                foreach stat [array names stats_array] {
                    if {[info exists rows_array($i,$stat)] && \
                            $rows_array($i,$stat) != ""} {
                        keylset return_list $stats_array($stat) \
                                $rows_array($i,$stat)
                    } else {
                        keylset return_list $stats_array($stat) "N/A"
                    }
                }
            }
        }
        if {[llength [lsort -unique $found_ports]] != \
                [llength [lsort -unique $port_handles]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Retrieved statistics only for the\
                    following ports: $found_ports."
            return $returnList
        }
    }
    
    if {![catch {keylget return_list statistics.oampdu_count.loopback_control_enable_rx} tmpVal1]} {
        if {![catch {keylget return_list statistics.oampdu_count.loopback_control_disable_rx} tmpVal2]} {
            
            if {[string is digit $tmpVal1] && [string is digit $tmpVal2]} {
                keylset return_list statistics.oampdu_count.loopback_control_rx [mpexpr            \
                        [keylget return_list statistics.oampdu_count.loopback_control_enable_rx] + \
                        [keylget return_list statistics.oampdu_count.loopback_control_disable_rx]  ]
            } else {
                keylset return_list statistics.oampdu_count.loopback_control_rx "N/A"
            }

        } else {
            keylset return_list statistics.oampdu_count.loopback_control_rx "N/A" 
        }
    } else {
        keylset return_list statistics.oampdu_count.loopback_control_rx "N/A" 
    }
    
    
    return $returnList
}
