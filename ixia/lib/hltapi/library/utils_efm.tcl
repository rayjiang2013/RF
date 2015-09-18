proc ::ixia::update_efm_counters {args} {
    variable executeOnTclServer
    variable oampdu_counters

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::update_efm_counters $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    set procName [lindex [info level [info level]] 0]

    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -action      CHOICES increment reset reset_all
    }
    
    set opt_args {
        -counter_type               CHOICES information event_frame event_symbol_period
                                    CHOICES event_frame_period event_frame_summary
                                    DEFAULT information
        -event_counter_target       CHOICES error_total event_total
                                    DEFAULT event_total
        -step                       NUMERIC
                                    DEFAULT 1
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $mandatory_args \
            -optional_args $opt_args} errorMsg]} {
        return "FAIL"
    }
    
    set counter_types [list event_frame        event_symbol_period      \
                            event_frame_period event_frame_summary      ]
    
    if {$action == "increment" || $action == "reset"} {
        if {$counter_type == "information"} {
            if {$action == "increment"} {
                if {[info exists oampdu_counters($port_handle,$counter_type)]} {
                    incr oampdu_counters($port_handle,$counter_type)
                } else {
                    set oampdu_counters($port_handle,$counter_type) 0
                }
            } elseif {$action == "reset"} {
                set oampdu_counters($port_handle,$counter_type) 0
            }
            return $oampdu_counters($port_handle,$counter_type)
        } else {
            if {$action == "increment"} {
                if {[info exists oampdu_counters($port_handle,$counter_type,$event_counter_target)]} {
                    incr oampdu_counters($port_handle,$counter_type,$event_counter_target) $step
                } else {
                    set oampdu_counters($port_handle,$counter_type,$event_counter_target) $step
                }
            } elseif {$action == "reset"} {
                set oampdu_counters($port_handle,$counter_type,$event_counter_target) 0
            }
            return $oampdu_counters($port_handle,$counter_type,$event_counter_target)
        }
    } elseif {$action == "reset_all"} {
        foreach counter_idx [array names oampdu_counters $port_handle,*] {
            set oampdu_counters($counter_idx) 0
        }
        return 0
    }
}
