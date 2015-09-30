proc ::ixia::get_efm_learned_info_tp {     \
        stat_keys                       \
        obj_handle                      \
        exec_call                       \
        get_call                        \
        info_obj_name                   \
        ret_list_name                   \
    } {
    
    keylset returnList status $::SUCCESS
    
    # init lists of keys
    foreach {hlt_key ixn_key} $stat_keys {
        set $hlt_key ""
    }
    
    # refresh
    set tmpCmd "$obj_handle $exec_call"
    debug $tmpCmd
    if {[eval $tmpCmd]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to $exec_call. $err"
        return $returnList
    }
    
    # check if info was learnt
    set tmpCmd "$obj_handle $get_call"
    
    set retry_count 15
    for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
        debug $tmpCmd
        set msg [eval $tmpCmd]
        if {$msg == 0} {
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
    
    foreach info_obj $info_obj_name {
        
        set na_flag 0
        
        if {$info_obj_name == "linkOamDiscLearnedInfo"} {
            
            # Check new funky flags remoteHeaderRefreshed and remoteTlvRefreshed

            for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
                if {[linkOamDiscLearnedInfo cget -remoteHeaderRefreshed] && \
                        [linkOamDiscLearnedInfo cget -remoteTlvRefreshed]} {

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
                set tmpCmd "$info_obj cget -$ixn_key"
                debug $tmpCmd
                set ixn_key_value [eval $tmpCmd]
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

proc ::ixia::get_efm_aggregate_stats_tp {port_handles ret_list_name} {
    
    keylset returnList status $::SUCCESS
    
    upvar $ret_list_name return_list
    
    set stats_array_aggregate {
        oamInformationPDUsSent                              statistics.oampdu_count.information_tx
        oamInformationPDUsReceived                          statistics.oampdu_count.information_rx
        oamEventNotificationPDUsReceived                    statistics.oampdu_count.event_notification_rx
        oamOrgSpecificPDUsReceived                          statistics.oampdu_count.organization_rx
        oamVariableRequestPDUsReceived                      statistics.oampdu_count.variable_request_rx
        oamVariableResponsePDUsReceived                     statistics.oampdu_count.variable_response_rx
        oamLoopbackControlPDUsReceived                      statistics.oampdu_count.loopback_control_rx
        oamLoopbackControlPDUsSent                          statistics.oampdu_count.loopback_control_tx
        oamEventNotificationPDUsSent                        statistics.oampdu_count.event_notification_tx
        oamLinksConfigured                                  statistics.oampdu_count.links_configured
        oamLinksRunning                                     statistics.oampdu_count.links_running
        oamVariableRequestPDUsSent                          statistics.oampdu_count.variable_request_tx
        oamVariableResponsePDUsSent                         statistics.oampdu_count.variable_response_tx
        oamOrgSpecificPDUsSent                              statistics.oampdu_count.organization_tx
    }
    
    set not_sup_stats {
        statistics.oampdu_count.unsupported_rx
        statistics.oampdu_count.information_tx_unique
        statistics.oampdu_count.information_rx_unique
        statistics.oampdu_count.event_notification_tx_unique
        statistics.oampdu_count.event_notification_rx_unique
        statistics.oampdu_count.loopback_control_enable_rx
        statistics.oampdu_count.loopback_control_disable_rx
        statistics.oampdu_count.loopback_control_enable_tx
        statistics.oampdu_count.loopback_control_disable_tx
        statistics.oampdu_count.remote_link_fault_tx
        statistics.oampdu_count.remote_link_fault_rx
        statistics.oampdu_count.remote_dying_gasp_tx
        statistics.oampdu_count.remote_dying_gasp_rx
        statistics.oampdu_count.remote_critical_event_tx
        statistics.oampdu_count.remote_critical_event_rx
    }

    foreach na_stat $not_sup_stats {
        keylset return_list $na_stat "N/A"
    }
    
    foreach port $port_handles {
        
        foreach {ch ca po} [split $port /] {}
        
        if {[stat get allStats $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to retrieve statistics for port $port."
            return $returnList
        }
        
        if {[stat cget -enableOamStats] != 1} {
            
            puts "\nWARNING: EFM statistics are not enabled on port $ch/$ca/$po.\
                    This can happen if ::ixia::emulation_efm_config was not\
                    called on this port previously. EFM statistics will be\
                    enabled but the values will probably be '0' because the counters\
                    didn't have the time to increment.\n"
            
            debug "stat config -enableOamStats true"
            stat config -enableOamStats true
            
            debug "stat set $ch $ca $po"
            if {[set retCode [stat set $ch $ca $po]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to enable EFM statistics. Call to stat set\
                        $ch $ca $po failed.\
                        Return code was $retCode."
                return $returnList
            }
            
            after 1000
            
            if {[stat get allStats $ch $ca $po]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to retrieve statistics for port $port."
                return $returnList
            }
        }
        
        foreach {stat_name stat_key} $stats_array_aggregate {
            if {[catch {stat cget -$stat_name} val]} {
                debug "EFM statistic key $stat_name does not exist."
                keylset return_list $stat_key "N/A"
            } else {
                if {$val == "" || [regexp {^\s+$} $val]} {
                    keylset return_list $stat_key "N/A"
                } else {
                    keylset return_list $stat_key $val
                }
            }
        }
    }
    
    return $returnList
}