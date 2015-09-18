proc ::ixia::ixprotocol_lacp_link_config { args opt_args } {
    variable internal_lacp_link_index
    variable internal_lacp_lag_index
    variable internal_lacp_lag_settings_array
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    # Check is -mode parameter dependencies are provided
    if {($mode == "create")} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    parameter -port_handle must be provided."
            return $returnList
        }
    } else {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    parameter -handle must be provided."
            return $returnList
        }
        if {$handle == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid parameter -handle {$handle}."
            return $returnList
        }
    }
    
    # Remove default values for -mode modify
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }
       
    array set lacpLinkOptionsArray {
        link_enabled                      enabled
        actor_key                         actorKey
        actor_port_num                    actorPortNumber
        actor_port_pri                    actorPortPriority
        actor_system_id                   actorSystemId
        actor_system_pri                  actorSystemPriority
        aggregation_flag                  aggregationFlagState
        auto_pick_port_mac                autoPickPortMac
        collecting_flag                   collectingFlag
        collector_max_delay               collectorMaxDelay
        distributing_flag                 distributingFlag
        lacp_activity                     lacpActivity
        lacp_timeout                      lacpTimeout
        lacpdu_periodic_time_interval     lacpduPeriodicTimeInterval
        marker_req_mode                   markerRequestMode
        marker_res_wait_time              markerResponseWaitTime
        port_mac                          portMac
        send_marker_req_on_lag_change     sendMarkerRequestOnLagChange
        send_periodic_marker_req          sendPeriodicMarkerRequest
        support_responding_to_marker      supportRespondingToMarker
        sync_flag                         syncFlag
    }
    
    array set lacpLinkValuesArray {
        aggregationFlagState,auto       1
        aggregationFlagState,disable    0
        syncFlag,auto                   1
        syncFlag,disable                0
    }
    
    array set enabledValue {
        create     1
        enable     1
        disable    0
    }
    if {[info exists enabledValue($mode)]} {
        set link_enabled    $enabledValue($mode)
    }   
    
    if {$mode == "delete"} {
        foreach {linkHandle} $handle {
            if {![regexp {^lacpLink([0-9]+)/([0-9]+)/([0-9]+)/([0-9]+)$} \
                    $linkHandle linkIgnore chassis card port link]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid LACP\
                        handle $linkHandle."
                return $returnList
            }
            debug "lacpServer select $chassis $card $port"
            if {[set retCode [lacpServer select $chassis $card $port]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Call to lacpServer\
                        select $chassis $card $port failed.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            debug "lacpServer getLink $linkHandle"
            if {[set retCode [lacpServer getLink $linkHandle]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get\
                        LACP link $linkHandle configuration on port\
                        $chassis/$card/$port.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            set existing_asid  [convertToIxiaMac [lacpLink cget -$lacpLinkOptionsArray(actor_system_id)]]
            set existing_aspri [lacpLink cget -$lacpLinkOptionsArray(actor_system_pri)]
            set existing_ak    [lacpLink cget -$lacpLinkOptionsArray(actor_key)]
            if {![info exists internal_lacp_lag_settings_array($existing_asid,$existing_aspri,$existing_ak,id)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Cannot find LAG associated with\
                        actor_system_id {$existing_asid},\
                        actor_system_pri $existing_aspri,\
                        actor_key $existing_ak, for LACP link $linkHandle\
                        on port $chassis/$card/$port."
                return $returnList
            }
            set existing_lag   $internal_lacp_lag_settings_array($existing_asid,$existing_aspri,$existing_ak,id)
            debug "lacpServer delLink $linkHandle"
            if {[set retCode [lacpServer delLink $linkHandle]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to delete\
                        LACP link $linkHandle on port $chassis/$card/$port.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            set retCode [removeLacpLinkFromLag $existing_lag $linkHandle]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            ::ixia::addPortToWrite $chassis/$card/$port
        }
        if {![info exists no_write]} {
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to write\
                        configuration on ports.\
                        [keylget retCode log]"
                return $returnList
            }
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }

    if {($mode == "enable") || ($mode == "disable")} {
        foreach {linkHandle} $handle {
            if {![regexp {^lacpLink([0-9]+)/([0-9]+)/([0-9]+)/([0-9]+)$} \
                    $linkHandle linkIgnore chassis card port link]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid LACP\
                        handle $linkHandle."
                return $returnList
            }
            debug "lacpServer select $chassis $card $port"
            if {[set retCode [lacpServer select $chassis $card $port]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Call to lacpServer\
                        select $chassis $card $port failed.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            debug "lacpServer getLink $linkHandle"
            if {[set retCode [lacpServer getLink $linkHandle]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get\
                        LACP link $linkHandle configuration\
                        on port $chassis/$card/$port.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            debug "lacpLink config -enabled $link_enabled"
            lacpLink config -enabled $link_enabled
            set existing_asid  [convertToIxiaMac [lacpLink cget -$lacpLinkOptionsArray(actor_system_id)]]
            set existing_aspri [lacpLink cget -$lacpLinkOptionsArray(actor_system_pri)]
            set existing_ak    [lacpLink cget -$lacpLinkOptionsArray(actor_key)]
            if {![info exists internal_lacp_lag_settings_array($existing_asid,$existing_aspri,$existing_ak,id)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Cannot find LAG associated with\
                        actor_system_id {$existing_asid},\
                        actor_system_pri $existing_aspri,\
                        actor_key $existing_ak, for LACP link $linkHandle\
                        on port $chassis/$card/$port."
                return $returnList
            }
            set existing_lag   $internal_lacp_lag_settings_array($existing_asid,$existing_aspri,$existing_ak,id)
            debug "lacpServer setLink $linkHandle"
            if {[set retCode [lacpServer setLink $linkHandle]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set\
                        LACP link $linkHandle configuration\
                        on port $chassis/$card/$port.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            
            set internal_lacp_lag_settings_array($existing_lag,$chassis/$card/$port,active_link) $linkHandle
            
            ::ixia::addPortToWrite $chassis/$card/$port
        }
        if {![info exists no_write]} {
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to write\
                        configuration on ports.\
                        [keylget retCode log]"
                return $returnList
            }
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {$mode == "create"} {
        set default_param_values {
            actor_system_id         0000.0000.0001
            actor_system_id_step    0000.0000.0001
            lag_count               1
            port_mac                0000.0000.0001
            port_mac_step           0000.0000.0001
        }
        
        foreach {default_param default_value} $default_param_values {
            if {[info exists $default_param]} {continue}
            set $default_param $default_value
        }
        set lag_index_list                 ""
        set lacp_link_list                 ""
        set lag_i                          0
        set step_params {
            actor_key           integer,0-65535
            actor_port_num      integer,0-65535
            actor_port_pri      integer,0-65535
            actor_system_id     mac
            actor_system_pri    integer,0-65535
            port_mac            mac
        }
        foreach {step_param param_type} $step_params {
            if {[info exists $step_param]} {
                if {$param_type == "mac"} {
                    set ${step_param}      [convertToIxiaMac [set ${step_param}]]
                    if {[info exists ${step_param}_step]} {
                        set ${step_param}_step [convertToIxiaMac [set ${step_param}_step]]
                    }
                }
                set ${step_param}_start [set $step_param]
            }
        }
        foreach port_handle_i $port_handle {
            foreach {chassis card port} [split $port_handle_i /] {}
            
            debug "lacpServer select $chassis $card $port"
            if {[set retCode [lacpServer select $chassis $card $port]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Call to lacpServer\
                        select $chassis $card $port failed.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            
            # Reset LACP configuration if needed
            if {[info exists reset]} {
                debug "lacpServer clearAllLinks"
                lacpServer clearAllLinks
                updateLacpHandleArray reset $chassis/$card/$port
            }
            
            # Create link
            set lacpLinkName "lacpLink${chassis}/${card}/${port}/${internal_lacp_link_index}"
            debug "lacpLink setDefault"
            lacpLink setDefault
            set lacp_link_args ""
            foreach {hltOpt ixpOpt}  [array get lacpLinkOptionsArray] {
                if {[info exists $hltOpt]} {
                    if {[info exists lacpLinkValuesArray($ixpOpt,[set $hltOpt])]} {
                        set $hltOpt $lacpLinkValuesArray($ixpOpt,[set $hltOpt])
                    }
                    debug "lacpLink config -$ixpOpt [set $hltOpt]"
                    lacpLink config -$ixpOpt [set $hltOpt]
                }
            }
            debug "lacpServer addLink $lacpLinkName"
            if {[set retCode [lacpServer addLink $lacpLinkName]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to add LACP link.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            
            if {[info exists internal_lacp_lag_settings_array($actor_system_id,$actor_system_pri,$actor_key,id)]} {
                set tmp_lag_index $internal_lacp_lag_settings_array($actor_system_id,$actor_system_pri,$actor_key,id)
            } else {
                set tmp_lag_index $internal_lacp_lag_index
                incr internal_lacp_lag_index
            }
            
            set retCode [addLacpLinkToLag \
                    $tmp_lag_index        \
                    $lacpLinkName         \
                    $actor_system_id      \
                    $actor_system_pri     \
                    $actor_key            ]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            
            lappend lacp_link_list $lacpLinkName
            lappend lag_index_list $tmp_lag_index
            incr lag_i
            incr internal_lacp_link_index
            
            # Increment params with steps
            foreach {step_param param_type} $step_params {
                if {[info exists ${step_param}] && [info exists ${step_param}_step]} {
                    switch -- [lindex [split $param_type ,] 0] {
                        integer {
                            set param_range [lindex [split $param_type ,] 1]
                            set param_start [lindex [split $param_range -] 0]
                            set param_end   [lindex [split $param_range -] 1]
                            incr ${step_param} [set ${step_param}_step]
                            if {[set ${step_param}] > $param_end} {
                                set ${step_param} $param_start
                            }
                        }
                        mac {
                            set ${step_param}_temp      [join [convertToIxiaMac [set ${step_param}]] :]
                            set ${step_param}_step_temp [join [convertToIxiaMac [set ${step_param}_step]] :]
                            set ${step_param} [split [incr_mac_addr   \
                                    [join [set ${step_param}] :]      \
                                    [join [set ${step_param}_step] :] \
                                    ] :]
                        }
                    }
                }
            }
            if {$lag_i == $lag_count} {
                set lag_i 0
                # Reset params with steps
                foreach {step_param param_type} $step_params {
                    if {[info exists ${step_param}_start]} {
                        set ${step_param} [set ${step_param}_start]
                    }
                }
            }
                    
            # Enable LACP Service on the interface
            debug "protocolServer get $chassis $card $port"
            if {[set retCode [protocolServer get $chassis $card $port]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Call to protocolServer\
                        get $chassis $card $port failed.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            debug "protocolServer config -enableLacpService true"
            protocolServer config -enableLacpService true
            debug "protocolServer set $chassis $card $port"
            
            if {[set retCode [protocolServer set $chassis $card $port]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Call to protocolServer\
                        set $chassis $card $port failed.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            debug "stat config -enableLacpStats true"
            stat config -enableLacpStats true
            debug "stat set $chassis $card $port"
            
            if {[set retCode [stat set $chassis $card $port]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Call to stat set\
                        $chassis $card $port failed.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            
            ::ixia::addPortToWrite $chassis/$card/$port
        }
        if {![info exists no_write]} {
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to write\
                        configuration on ports.\
                        [keylget retCode log]"
                return $returnList
            }
        }
        
        keylset returnList status $::SUCCESS
        keylset returnList handle $lacp_link_list
        return $returnList
    }
    
    if {$mode == "modify"} {
        # Compose list of link options
        set lacp_link_cmds ""
        foreach {hltOpt ixpOpt}  [array get lacpLinkOptionsArray] {
            if {[info exists $hltOpt]} {
                set length [llength [set $hltOpt]]
                if {$length == [llength $handle]} {
                    if {[info exists lacpLinkValuesArray($ixpOpt,[set $hltOpt])]} {
                        append lacp_link_cmds " lacpLink config -$ixpOpt \
                                \"\[lindex $lacpLinkValuesArray($ixpOpt,[set $hltOpt]) \$handleIndex\]\"\n"
                    } else {
                        append lacp_link_cmds " lacpLink config -$ixpOpt \
                                \"\[lindex [set $hltOpt] \$handleIndex\]\"\n"
                    }
                } elseif {$length == 1} {
                    if {[info exists lacpLinkValuesArray($ixpOpt,[set $hltOpt])]} {
                        append lacp_link_cmds " lacpLink config -$ixpOpt \
                                $lacpLinkValuesArray($ixpOpt,[set $hltOpt])\n"
                    } else {
                        append lacp_link_cmds " lacpLink config -$ixpOpt \
                                [set $hltOpt]\n"
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid number of values\
                            for -$hltOpt. The number of values\
                            should be 1 or [llength $handle]."
                    return $returnList
                }
            }
        }
        set handleIndex 0
        foreach {linkHandle} $handle {
            if {![regexp {^lacpLink([0-9]+)/([0-9]+)/([0-9]+)/([0-9]+)$} \
                    $linkHandle linkIgnore chassis card port link]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid LACP\
                        handle $linkHandle."
                return $returnList
            }
            debug "lacpServer select $chassis $card $port"
            if {[set retCode [lacpServer select $chassis $card $port]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Call to lacpServer\
                        select $chassis $card $port failed.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            debug "lacpServer getLink $linkHandle"
            if {[set retCode [lacpServer getLink $linkHandle]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get\
                        LACP link $linkHandle configuration\
                        on port $chassis/$card/$port.\
                        Return code was $retCode. $::ixErrorInfo"
                return $returnList
            }
            set existing_asid  [convertToIxiaMac [lacpLink cget -$lacpLinkOptionsArray(actor_system_id)]]
            set existing_aspri [lacpLink cget -$lacpLinkOptionsArray(actor_system_pri)]
            set existing_ak    [lacpLink cget -$lacpLinkOptionsArray(actor_key)]
            if {![info exists internal_lacp_lag_settings_array($existing_asid,$existing_aspri,$existing_ak,id)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Cannot find LAG associated with\
                        actor_system_id {$existing_asid},\
                        actor_system_pri $existing_aspri,\
                        actor_key $existing_ak, for LACP link $linkHandle\
                        on port $chassis/$card/$port."
                return $returnList
            }
            set existing_lag   $internal_lacp_lag_settings_array($existing_asid,$existing_aspri,$existing_ak,id)
            if {[info exists actor_system_id]} {
                set new_asid $actor_system_id
            } else {
                set new_asid $existing_asid
            }
            if {[info exists actor_system_pri]} {
                set new_aspri $actor_system_pri
            } else {
                set new_aspri $existing_aspri
            }
            if {[info exists actor_key]} {
                set new_ak $actor_key
            } else {
                set new_ak $existing_ak
            }
            
            if {[info exists internal_lacp_lag_settings_array($new_asid,$new_aspri,$new_ak,id)]} {
                set new_lag $internal_lacp_lag_settings_array($new_asid,$new_aspri,$new_ak,id)
                if { $new_lag != $existing_lag} {
                    set retCode [removeLacpLinkFromLag $existing_lag $linkHandle]
                    if {[keylget retCode status] == $::FAILURE} {
                        return $retCode
                    }
                    set retCode [addLacpLinkToLag \
                            $new_lag              \
                            $linkHandle           \
                            $new_asid             \
                            $new_aspri            \
                            $new_ak               ]
                    if {[keylget retCode status] == $::FAILURE} {
                        return $retCode
                    }
                }
            }
            # Setting link arguments
            if {$lacp_link_cmds != ""} {
                debug "[subst $lacp_link_cmds]"
                set retCode [eval [subst $lacp_link_cmds]]
                debug "lacpServer setLink $linkHandle"
                if {[set retCode [lacpServer setLink $linkHandle]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to set\
                            LACP link $linkHandle configuration\
                            on port $chassis/$card/$port.\
                            Return code was $retCode. $::ixErrorInfo"
                    return $returnList
                }
                ::ixia::addPortToWrite $chassis/$card/$port
            }
            
            incr handleIndex
        }
        if {![info exists no_write]} {
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to write\
                        configuration on ports.\
                        [keylget retCode log]"
                return $returnList
            }
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
}


proc ::ixia::ixprotocol_lacp_control {args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args \
            -mandatory_args $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "When -mode is $mode, parameter -port_handle or\
                parameter -handle must be provided."
        return $returnList
    }
    if {[info exists handle]} {
        if {![info exists port_handle]} {
            set port_handle ""
        }
        foreach {_handle} $handle {
           if {[regexp {^linkHandle([0-9]+)/([0-9]+)/([0-9]+)/([0-9]+)$} \
                    $_handle all_handle chassis card port link]} {
                lappend port_handle $chassis/$card/$port
            }
        }
    }
    set port_handle [lsort -unique $port_handle]
    set port_list   [format_space_port_list $port_handle]
    
    switch -- $mode {
        restart {
            debug "ixStopLacp $port_list"
            if {[ixStopLacp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not stop\
                        LACP on ports: $port_handle"
                return $returnList
            }
            debug "ixStartLacp $port_list"
            if {[ixStartLacp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not start\
                        LACP on ports: $port_handle"
                return $returnList
            }
        }
        send_marker_req {
            foreach port_h $port_handle {
                foreach {chassis card port} [split $port_h /] {}
                debug "lacpServer select $chassis $card $port"
                if {[lacpServer select $chassis $card $port]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "LACP\
                            protocol has not been installed on port or\
                            is not supported on port: \
                            $chassis/$card/$port."
                    return $returnList
                }
                debug "lacpServer sendMarkerRequest"
                if {[set retCode [lacpServer sendMarkerRequest]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to\
                            send LACP Marker Request on port $chassis/$card/$port. \
                            Return code was $retCode."
                    return $returnList
                }
            }
        }
        start {
            debug "ixStartLacp $port_list"
            if {[ixStartLacp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not start\
                        LACP on ports: $port_handle"
                return $returnList
            }
        }
        start_pdu {
            foreach port_h $port_handle {
                foreach {chassis card port} [split $port_h /] {}
                debug "lacpServer select $chassis $card $port"
                if {[lacpServer select $chassis $card $port]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "LACP\
                            protocol has not been installed on port or\
                            is not supported on port: \
                            $chassis/$card/$port."
                    return $returnList
                }
                debug "lacpServer startPDU"
                if {[set retCode [lacpServer startPDU]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to\
                            start PDU on port $chassis/$card/$port. \
                            Return code was $retCode."
                    return $returnList
                }
            }
        }
        stop {
            debug "ixStopLacp $port_list"
            if {[ixStopLacp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not stop\
                        LACP on ports: $port_handle"
                return $returnList
            }
        }
        stop_pdu {
            foreach port_h $port_handle {
                foreach {chassis card port} [split $port_h /] {}
                debug "lacpServer select $chassis $card $port"
                if {[lacpServer select $chassis $card $port]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "LACP\
                            protocol has not been installed on port or\
                            is not supported on port: \
                            $chassis/$card/$port."
                    return $returnList
                }
                debug "lacpServer stopPDU"
                if {[set retCode [lacpServer stopPDU]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to\
                            stop PDU on port $chassis/$card/$port. \
                            Return code was $retCode."
                    return $returnList
                }
            }
        }
        update_link {
            foreach port_h $port_handle {
                foreach {chassis card port} [split $port_h /] {}
                debug "lacpServer select $chassis $card $port"
                if {[lacpServer select $chassis $card $port]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "LACP\
                            protocol has not been installed on port or\
                            is not supported on port: \
                            $chassis/$card/$port."
                    return $returnList
                }
                debug "lacpServer sendUpdate"
                if {[set retCode [lacpServer sendUpdate]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to\
                            send update on port $chassis/$card/$port. \
                            Return code was $retCode."
                    return $returnList
                }
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixprotocol_lacp_info { args man_args opt_args } {
    variable internal_lacp_lag_settings_array
    variable internal_lacp_lag_index
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -mandatory_args $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {![info exists port_handle] && ![info exists handle] && ($mode != "configuration")} {
        keylset returnList status $::FAILURE
        keylset returnList log "When -mode is $mode, parameter -port_handle or\
                parameter -handle must be provided."
        return $returnList
    }
    if {[info exists handle]} {
        if {![info exists port_handle]} {
            set port_handle ""
        }
        foreach {_handle} $handle {
           if {[regexp {^linkHandle([0-9]+)/([0-9]+)/([0-9]+)/([0-9]+)$} \
                    $_handle all_handle chassis card port link]} {
                lappend port_handle $chassis/$card/$port
            }
        }
    }
    if {[info exists port_handle]} {
        set port_handle [lsort -unique $port_handle]
        set port_list   [format_space_port_list $port_handle]
    }
    
    if {$mode == "clear_stats"} {
        # Reseting all the stats for the selected ports
        if {[ixClearStats port_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to\
                    clear statistics for ports $port_list."
            return $returnList
        }
    }
    
    if {$mode == "configuration"} {
        for {set i 1} {$i <= $internal_lacp_lag_index} {incr i} {
            if {![info exists internal_lacp_lag_settings_array($i)] || \
                    $internal_lacp_lag_settings_array($i) == 0} { continue }
            
            if {![info exists internal_lacp_lag_settings_array($i,ports)] || \
                    ($internal_lacp_lag_settings_array($i,ports) == "")} { continue }
            
            keylset returnList lag.$i.ports \
                        $internal_lacp_lag_settings_array($i,ports)
            
            keylset returnList lag.$i.actor_system_id \
                        $internal_lacp_lag_settings_array($i,actor_system_id)
            
            keylset returnList lag.$i.actor_system_pri \
                        $internal_lacp_lag_settings_array($i,actor_system_pri)
                        
            keylset returnList lag.$i.actor_key \
                        $internal_lacp_lag_settings_array($i,actor_key)
            
            foreach lag_port $internal_lacp_lag_settings_array($i,ports) {
                if {![info exists internal_lacp_lag_settings_array($i,$lag_port,links)] || \
                        ($internal_lacp_lag_settings_array($i,$lag_port,links) == "")} { continue }
                keylset returnList lag.$i.$lag_port.active_link \
                        $internal_lacp_lag_settings_array($i,$lag_port,active_link)
                keylset returnList lag.$i.$lag_port.links       \
                        $internal_lacp_lag_settings_array($i,$lag_port,links)
            }
        }
    }
    
    if {$mode == "learned_info"} {
        set stats_list {
            actorCollectingFlag             actor_collecting_flag
            actorDefaultedFlag              actor_defaulted_flag
            actorDistributingFlag           actor_distributing_flag
            actorExpiredFlag                actor_expired_flag
            actorLacpActivity               actor_lacp_activity
            actorLacpTimeout                actor_lacp_timeout
            actorLinkAggregationStatus      actor_link_aggregation_status
            actorOperationalKey             actor_op_key
            actorPortNumber                 actor_port_num
            actorPortPriority               actor_port_pri
            actorSyncFlag                   actor_sync_flag
            actorSystemId                   actor_system_id
            actorSystemPriority             actor_system_pri
            enabledAggregation              actor_aggregation
            partnerCollectingFlag           partner_collecting_flag
            partnerCollectorMaxDelay        partner_collectors_max_delay
            partnerDefaultedFlag            partner_defaulted_flag
            partnerDistributingFlag         partner_distributing_flag
            partnerExpiredFlag              partner_expired_flag
            partnerLacpActivity             partner_lacp_activity
            partnerLacpTimeout              partner_lacp_timeout
            partnerLinkAggregationStatus    partner_aggregation
            partnerOperationalKey           partner_op_key
            partnerPortNumber               partner_port_num
            partnerPortPriority             partner_port_pri
            partnerSyncFlag                 partner_sync_flag
            partnerSystemId                 partner_system_id
            partnerSystemPriority           partner_system_pri
        }
        
        foreach {port_h} $port_handle {
            foreach {chassis card port} [split $port_h /] {}
            
            if {[lacpServer select $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "LACP\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chassis/$card/$port."
                return $returnList
            }
            set retries 20
            while {[set retCode [lacpServer requestLacpLearnedInfo]] && $retries} {
                after 1000
                incr retries -1
            }
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to\
                        request LACP learned info on port $chassis/$card/$port. \
                        Return code was $retCode."
                return $returnList
            }
            set retries 20
            while {[set retCode [lacpServer getLacpLearnedInfo]] && $retries} {
                after 1000
                incr retries -1
            }
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to\
                        get LACP learned info on port $chassis/$card/$port. \
                        Return code was $retCode."
                return $returnList
            }
            
            foreach {ixpOpt hltOpt} $stats_list {
                keylset returnList $port_h.$hltOpt [lacpLearnedInfo cget -$ixpOpt]
            }
        }
    }
    
    if {$mode == "aggregate_stats"} {
        
        array set stats_array_aggregate {
            lacpSessionState
            link_state
            lacpFramesReceived
            lacpdu_rx
            lacpFramesSent
            lacpdu_tx
            lacpMalformedFramesReceived
            lacpu_malformed_rx
            lacpMarkerFramesReceived
            marker_pdu_rx
            lacpMarkerFramesSent
            marker_pdu_tx
            lacpMarkerResponseReceived
            marker_res_pdu_rx
            lacpMarkerResponseSent
            marker_res_pdu_tx
            lacpMarkerResponseTimeoutCount
            marker_res_timeout_count
            lacpFramesTxRateViolationCount
            lacpdu_tx_rate_violation_count
            lacpMarkerTxRateViolationCount
            marker_pdu_tx_rate_violation_count
        }
        
        foreach {port_h} $port_handle {
            foreach {chassis card port} [split $port_h /] {}
            
            statGroup setDefault
            statGroup add $chassis $card $port
            if {[statGroup get]} {
                keylset returnList log "Failed to\
                        statGroup get $chassis $card $port."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
        foreach {port_h} $port_handle {
            foreach {chassis card port} [split $port_h /] {}
            
            statList setDefault
            if {[statList get $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to\
                        stat get allStats $chassis $card $port."
                return $returnList
            }
            
            foreach {lacpStat lacpKey} [array get stats_array_aggregate] {
                if {[catch {statList cget -$ldpStat} retValue] } {
                    keylset returnList ${port_h}.aggregate.$lacpKey "N/A"
                } else  {
                    keylset returnList ${port_h}.aggregate.$lacpKey $retValue
                }
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}
