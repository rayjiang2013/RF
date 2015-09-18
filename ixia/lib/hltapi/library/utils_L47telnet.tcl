proc ::ixia::ixL47TelnetAgent { args } {
    variable ixload_handles_array
    
#    debug "\nixLoadTelnetAgent: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {}
    
    array set client_agent_basic_args {
        command_prompt           commandPrompt
        options_enable           enableOptions
        expect_timeout           expectTimeout
    }
    
    array set client_agent_advanced_args {
        esm_enable   enableEsm
        esm          esm
        loop_enable  implicitLoopCheck
    }
    
    array set server_agent_basic_args {
        close_command     closeCommand
        command_prompt    commandPrompt
        echo_enable       echo
        linemode_enable   linemode
        listen_port       listenPort
        suppress_go_ahead suppressGoAhead
    }
    
    array set server_agent_advanced_args {
        esm_enable   enableEsm
        esm          esm
    }
    
    if {$property == [string tolower $target]} {
        set traffic_option_list  [list procName mode handle target]
        set traffic_args [list]

        foreach item $traffic_option_list {
            if {[info exists $item]} {
                lappend traffic_args "-$item"
                lappend traffic_args "[set $item]"
            }
        }
 
        set retList [eval [format "%s %s" ::ixia::ixL47Traffic \
                $traffic_args]]

        if {[keylget retList status] != $::SUCCESS} {
                return $retList
        }
        
        if {$mode == "add"} {
            set handle [keylget retList ${property}_handle]
            keylset returnList ${property}_handle $handle
        }

        if {$mode == "remove"} {
            return $retList
        }
    }
    
    switch -- $mode {
        add {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle."
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    agent                         ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agent_name [keylget retCode handle]
            # debug "new agent handler = $agent_name"
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list ixload_handle type target] ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set handleType    [lindex [keylget retCode value] 1]
            set _target       [lindex [keylget retCode value] 2]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "traffic"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid $target handle."
                return $returnList
            }
            
            if {$target != [string tolower $_target]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: -handle is not a \
                        valid $target handle."
                return $returnList
            }
            
            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler agentList.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
            set _target [expr {($target == "client") ? "Client" : "Server"}]
            set _cmd [format "%s" "$ixLoadHandler agentList.appendItem \
                    -name         $agent_name  \
                    -protocol     Telnet       \
                    -type         $_target     \
                    -enable 1"                 ]
            
            debug "$_cmd"
            if {[catch {eval $_cmd} handler]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $handler."
                return $returnList
            }
            
            set arg_types [list basic advanced]
            
            foreach {arg_type} $arg_types {
                set command_${arg_type} ""
                foreach item [array names ${target}_agent_${arg_type}_args] {
                    if {[info exists $item]} {
                        set _param [set ${target}_agent_${arg_type}_args($item)]
                        if {[info exists valuesHltToIxLoad([set $item])]} {
                            set $item $valuesHltToIxLoad([set $item])
                        }
                        append command_${arg_type} " -$_param \"[set $item]\" "
                    }
                }
                if {[set command_${arg_type}] != ""} {
                    set _cmd [format "%s" "$ixLoadHandler \
                            agentList($index).pm.${arg_type}.config \
                            [set command_${arg_type}]"]
                    debug $_cmd
                    if {[catch {eval $_cmd} error]} {
                        catch {::IxLoad delete $handler}
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: $error."
                        return $returnList
                    }
                }
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $agent_name           \
                    -type            agent                 \
                    -target          $target               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList agent_handle $agent_name
            return $returnList
        }
        remove {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            # get handle properties
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list type ixload_handle ixload_index] ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set handleType    [lindex [keylget retCode value] 0]
            set ixLoadHandler [lindex [keylget retCode value] 1]
            set index         [lindex [keylget retCode value] 2]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            set _cmd [format "%s" "$ixLoadHandler agentList.deleteItem $index"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        agent.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            # get handle properties
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list type ixload_handle ixload_index target] ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set handleType    [lindex [keylget retCode value] 0]
            set ixLoadHandler [lindex [keylget retCode value] 1]
            set index         [lindex [keylget retCode value] 2]
            set target        [lindex [keylget retCode value] 3]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            set arg_types [list basic advanced]
            
            foreach {arg_type} $arg_types {
                set command_${arg_type} ""
                foreach item [array names ${target}_agent_${arg_type}_args] {
                    if {[info exists $item]} {
                        set _param [set ${target}_agent_${arg_type}_args($item)]
                        if {[info exists valuesHltToIxLoad([set $item])]} {
                            set $item $valuesHltToIxLoad([set $item])
                        }
                        append command_${arg_type} " -$_param \"[set $item]\" "
                    }
                }
                if {[set command_${arg_type}] != ""} {
                    set _cmd [format "%s" "$ixLoadHandler \
                            agentList($index).pm.${arg_type}.config \
                            [set command_${arg_type}]"]
                    debug $_cmd
                    if {[catch {eval $_cmd} error]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: $error."
                        return $returnList
                    }
                }
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            set flag [expr {( $mode == "disable" ) ? 0 : 1}]
            
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            # get handle properties
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list type ixload_handle ixload_index] ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set handleType    [lindex [keylget retCode value] 0]
            set ixLoadHandler [lindex [keylget retCode value] 1]
            set index         [lindex [keylget retCode value] 2]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            set _cmd [format "%s" "$ixLoadHandler agentList($index).config \
                    -enable $flag"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Couldn't $mode \
                        this agent.\n$error"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixL47TelnetCommand { args } {
    variable ixload_handles_array
    
#    debug "\nixLoadTelnetAction: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {
        open        OpenCommand
        login       LoginCommand
        password    PasswordCommand
        send        SendCommand
        think       ThinkCommand
        exit        ExitCommand
        loop_begin  "{LoopBegin}"
        loop_end    "{LoopEnd}"
    }
    
    array set client_command_args {
        c_id               id
        c_expect           expect
        c_server_ip        serverIP
        c_send             send
        c_max_interval     maximumInterval
        c_min_interval     minimumInterval
    }
    
    array set groupCommandWithArgs {
        open     {c_id c_expect       c_server_ip}
        login    {c_id c_send         c_expect}
        password {c_id c_send         c_expect}
        send     {c_id c_send         c_expect}
        think    {c_id c_max_interval c_min_interval}
        exit     {c_id c_send}
    }
    switch -- $mode {
        add {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            if {![info exists c_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -c_id must be provided."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    action                        ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set action_name [keylget retCode handle]
#            debug "new command handler = $action_name"
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list ixload_handle  ixload_index type target]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set agentIndex    [lindex [keylget retCode value] 1]
            set handleType    [lindex [keylget retCode value] 2]
            set target        [lindex [keylget retCode value] 3]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($agentIndex).pm.commands.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            
            set _command ""
            set command_name $c_id
            foreach item [array names client_command_args] {
                if {[info exists $item]} {
                    set _param $client_command_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    if {[lsearch $groupCommandWithArgs($command_name) \
                                $item] != -1} {
                        append _command " -$_param \"[set $item]\" "
                        
                    }
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler                 \
                        agentList($agentIndex).pm.commands.appendItem \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $action_name          \
                    -type            action                \
                    -target          $target               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               \
                    -command_type    $command_name         ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList command_handle $action_name
            return $returnList
        }
        remove {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid command handle."
                return $returnList
            }
            # get handler properties
            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set actionIndex     [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set agentName       [lindex [keylget retCode value] 4]
            
            # get agent properties
            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $agentName                       \
                    -key      ixload_index                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid action handle
            if {$handleType != "action"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid command handle."
                return $returnList
            }
            
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($agentIndex).pm.commands.deleteItem \
                    $actionIndex"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        command.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid command handle."
                return $returnList
            }
            # get handler properties
            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target command_type parent_handle]    ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set actionIndex     [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set command         [lindex [keylget retCode value] 4]
            set agentName       [lindex [keylget retCode value] 5]
            
            # get agent properties
            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $agentName                       \
                    -key      ixload_index                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid action handle
            if {$handleType != "action"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid command handle."
                return $returnList
            }
            
            set _command ""
            set command_name $command
            foreach item [array names client_command_args] {
                if {[info exists $item]} {
                    set _param $client_command_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    if {([lsearch $groupCommandWithArgs($command_name) \
                                $item] != -1) && ($_param != "id")} {
                        append _command " -$_param \"[set $item]\" "
                        
                    }
                }
            }
            if {$_command != ""} {
                set _cmd "$ixLoadHandler "
                append _cmd "agentList($agentIndex).pm."
                append _cmd "commands($actionIndex)."
                append _cmd "config $_command"
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode $mode \
                    is not supported for -property command."
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}
