proc ::ixia::ixLoadFtpAgent { args } {
    variable ixload_handles_array
    
#    debug "\nixLoadFtpAgent: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set client_agent_args {
        esm_enable    enableEsm
        esm           esm
        tos_enable    enableTos
        tos           tos
        ftp_mode      mode
        ip_preference ipPreference
    }
    array set server_agent_args {
        esm_enable enableEsm
        esm        esm
        tos_enable    enableTos
        tos           tos
        ftp_port   ftpPort
    }
    
    if {[info exists ftp_mode]} {
        switch -- $ftp_mode {
            active {
                set ftp_mode $::FTP_Client(kModeActive)
            }
            passive {
                set ftp_mode $::FTP_Client(kModePassive)
            }
        }
    }
#    debug "MODE = $mode"
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
                        -handle $handle is not a valid traffic handle."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    agent                         ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agent_name [keylget retCode handle]
#            debug "new FTP agent handler = $agent_name"
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set target        [lindex [keylget retCode value] 2]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "traffic"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid traffic handle."
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
#            debug "ixLoad INDEX=$index"
            set _target [expr {($target == "client") ? "Client" : "Server"}]
            set _cmd [format "%s" "$ixLoadHandler agentList.appendItem \
                    -name         $agent_name  \
                    -protocol     FTP          \
                    -type         $_target     \
                    -enable 1"                 ]
            
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $error."
                return $returnList
            }
            
            set command ""
            switch -- $target {
                client {
                    foreach item [array names client_agent_args] {
                        if {[info exists $item]} {
                            set _param $client_agent_args($item)
                            append command "-$_param [set $item] "
                        }
                    }
                }
                server {
                    foreach item [array names server_agent_args] {
                        if {[info exists $item]} {
                            set _param $server_agent_args($item)
                            append command "-$_param [set $item] "
                        }
                    }
                }
            }
            if {$command != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($index).config $command"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            keylset returnList handles $agent_name
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            set _cmd "$ixLoadHandler agentList.deleteItem $index"
            debug $_cmd
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        agent.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            set command ""
            switch -- $target {
                client {
                    foreach item [array names client_agent_args] {
                        if {[info exists $item]} {
                            set _param $client_agent_args($item)
                            append command "-$_param [set $item] "
                        }
                    }
                }
                server {
                    foreach item [array names server_agent_args] {
                        if {[info exists $item]} {
                            set _param $server_agent_args($item)
                            append command "-$_param [set $item] "
                        }
                    }
                }
            }
            if {$command != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($index).config $command"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            set _cmd "$ixLoadHandler agentList($index).config -enable $flag"
            debug $_cmd
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


proc ::ixia::ixLoadFtpAction { args } {
    variable ixload_handles_array
    
#    debug "ixLoadFtpAction: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    regsub {\-arguments[ ]+ANY} $opt_args {-arguments SHIFT} opt_args
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set action_args {
        arguments   arguments
        command     command
        destination destination
        user_name   userName
        password    password
    }
    
    array set valuesHltToIxLoad {
        none       $::HttpAction(kAbortNone)
        before     $::HttpAction(kAbortBeforeRequest)
        after      $::HttpAction(kAbortAfterRequest)
        cd         "CD"
        delete     "DELETE"
        get        "GET"
        get_ssl    "GET(SSL)"
        head       "HEAD"
        head_ssl   "HEAD(SSL)"
        login      "LOGIN"
        loop_begin "{LoopBegin}"
        loop_end   "{LoopEnd}"
        quit       "QUIT"
        post       "POST"
        post_ssl   "POST(SSL)"
        put        "{Put}"
        put_ssl    "PUT(SSL)"
        retrieve   "RETRIEVE"
        store      "STORE"
        think      "{Think}"
    }
    
#    debug "MODE = $mode"
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
                        -handle $handle is not a valid traffic handle."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    action                        ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set action_name [keylget retCode handle]
#            debug "new FTP action handler = $action_name"
            
            set retCode [::ixia::ixLoadHandlesArrayCommand                  \
                    -mode     get_value                                     \
                    -handle   $handle                                       \
                    -key      [list ixload_handle type ixload_index target] ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set handleType    [lindex [keylget retCode value] 1]
            set pIndex        [lindex [keylget retCode value] 2]
            set target        [lindex [keylget retCode value] 3]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            # check to see if this agent is a client agent. Server agents
            # does not have actions
            if {$target == "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is a server agent handle. Server \
                        agents does NOT have actions."
                return $returnList
            }
            
            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($pIndex).actionList.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            
            #check to see if IP address
            if {[info exists destination]} {
                if {[isIpAddressValid [lindex [split $destination :] 0]] || \
                            [::ipv6::isValidAddress $destination]} {
#                    debug "it is an IP address"
                } else  {
#                    debug "IT is NOT an IP address, so it's a handle"
                    if {![info exists ixload_handles_array($destination)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                -destination is not a valid agent handler."
                        return $returnList
                    }
                    set retCode [::ixia::ixLoadHandlesArrayCommand           \
                            -mode     get_value                              \
                            -handle   $destination                           \
                            -key      [list ixload_handle ixload_index]      ]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set dIxLoadHandler [lindex [keylget retCode value] 0]
                    set dIndex         [lindex [keylget retCode value] 1]
                    
                    set _cmd [format "%s" "$dIxLoadHandler \
                            agentList($dindex).cget -name "]
                    debug $_cmd
                    if {[catch {eval $_cmd} agentName]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $agentName."
                        return $returnList
                    }
                    set destination $agentName
                }
            }
            
            set _command ""
            foreach item [array names action_args] {
                if {[info exists $item]} {
                    set _param $action_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($pIndex).actionList.appendItem $_command"]
                
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            save                  \
                    -handle          $action_name          \
                    -type            action                \
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
            keylset returnList handles $action_name
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list type ixload_handle ixload_index \
                    parent_handle] ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set handleType    [lindex [keylget retCode value] 0]
            set ixLoadHandler [lindex [keylget retCode value] 1]
            set index         [lindex [keylget retCode value] 2]
            set parentHandle  [lindex [keylget retCode value] 3]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "action"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid action handle."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $parentHandle                \
                    -key      ixload_index                 ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set pIndex [keylget retCode value]
            
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($pIndex).actionList.deleteItem $index"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        agent.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list type ixload_handle ixload_index \
                    parent_handle] ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set handleType    [lindex [keylget retCode value] 0]
            set ixLoadHandler [lindex [keylget retCode value] 1]
            set index         [lindex [keylget retCode value] 2]
            set parentHandle  [lindex [keylget retCode value] 3]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "action"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid action handle."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $parentHandle                \
                    -key      ixload_index                 ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set pIndex [keylget retCode value]
            
            #check to see if IP address
            if {[info exists destination]} {
                if {[isIpAddressValid [lindex [split $destination :] 0]] || \
                            [::ipv6::isValidAddress $destination]} {
#                    debug "it is an IP address"
                } else  {
#                    debug "IT is NOT an IP address, so it's a handle"
                    if {![info exists ixload_handles_array($destination)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                -destination is not a valid agent handler."
                        return $returnList
                    }
                    set retCode [::ixia::ixLoadHandlesArrayCommand           \
                            -mode     get_value                              \
                            -handle   $destination                           \
                            -key      [list ixload_handle ixload_index]      ]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set dIxLoadHandler [lindex [keylget retCode value] 0]
                    set dIndex         [lindex [keylget retCode value] 1]
                    
                    set _cmd [format "%s" "$dIxLoadHandler \
                            agentList($dindex).cget -name "]
                    debug $_cmd
                    if {[catch {eval $_cmd} agentName]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $agentName."
                        return $returnList
                    }
                    set destination $agentName
                }
            }
            
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($pIndex).actionList.appendItem "]
            
            set _command ""
            foreach item [array names action_args] {
                if {[info exists $item]} {
                    set _param $action_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($pIndex).actionList($index).config $_command"]
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

            keylset returnList status  $::SUCCESS
            keylset returnList handles $handle
            return $returnList
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: A command can't be \
                    enabled or disabled."
            return $returnList
        }
    }
}
