proc ::ixia::ixL47FtpAgent { args } {
    variable ixload_handles_array
    
    # debug "\nixLoadFtpAgent: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    # These default options are practically hard coded, so if IxLoad API
    # changes default values, then these should be changed also
    
    array set client_agent_args {
        esm_enable    enableEsm
        tos_enable    enableTos
        esm           esm
        ip_preference ipPreference
        loop_enable    loopValue
        access_mode   mode
        password      password
        tos           tos
        user_name     userName
    }
    array set server_agent_args {
        esm_enable enableEsm
        esm        esm
        tos_enable enableTos
        tos        tos
        ftp_port   ftpPort
    }


    if {[info exists access_mode]} {
        switch -- $access_mode {
            active {
                set access_mode $::FTP_Client(kModeActive)
            }
            passive {
                set access_mode $::FTP_Client(kModePassive)
            }
        }
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
        
#   debug "MODE = $mode"
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
#            debug "new FTP agent handler = $agent_name"
            
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
            set target_h      [lindex [keylget retCode value] 2]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "traffic"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid traffic handle."
                return $returnList
            }
            
            if {$target_h != [string tolower $target]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle."
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
            set _cmd [format "%s" "$ixLoadHandler agentList.appendItem \
                    -name         $agent_name  \
                    -protocol     FTP          \
                    -type         $target      \
                    -enable       1            "]
            
            if {[string tolower $target] == "client"} {
                append _cmd "-fileList     {'/#1' '/#4' '/#16' '/#64' '/#256' \
                        '/#1024' '/#4096' '/#16384' '/#65536' '/#262144' '/#1048576'}"
            }
            
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $error."
                return $returnList
            }
            
            set command ""
            switch -- $target_h {
                client {
                    foreach item [array names client_agent_args] {
                        if {[info exists $item]} {
                            set _param $client_agent_args($item)
                            if {$item == "password"} {
                                if {[regexp {[\[\]]} [set $item]]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                        Invalid -password. Valid characters are \
                                        a-z, A-Z, 0-9, @, dot(.),$,(,),-, \
                                        and underscore (_).."
                                    return $returnList
                                } else {
                                    append command "-$_param \{[set $item]\} "
                                }
                            } else {
                                append command "-$_param [set $item] "
                            }
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
                    if {[regexp {Valid characters are} $error]} {
                        set error {"Error: Lib.Common.ixConfig.ixConfigError: \
                            Password  is invalid. Valid \
                            characters are a-z, A-Z, 0-9, @, dot(.),$,(,),-, \
                            and underscore (_)."}
                    }
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $agent_name           \
                    -type            agent                 \
                    -target          $target_h             \
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
            
            set _cmd "$ixLoadHandler agentList.deleteItem $index"
            debug $_cmd
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
            
            set command ""
            switch -- $target {
                client {
                    foreach item [array names client_agent_args] {
                        if {[info exists $item]} {
                            set _param $client_agent_args($item)
                            if {$item == "password"} {
                                if {[regexp {[\[\]]} [set $item]]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                        Invalid -password. Valid characters are \
                                        a-z, A-Z, 0-9, @, dot(.),$,(,),-, \
                                        and underscore (_).."
                                    return $returnList
                                } else {
                                    append command "-$_param \{[set $item]\} "
                                }
                            } else {
                                append command "-$_param [set $item] "
                            }
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
                    if {[regexp {Valid characters are} $error]} {
                        set error {"Error: Lib.Common.ixConfig.ixConfigError: \
                            Password  is invalid. Valid \
                            characters are a-z, A-Z, 0-9, @, dot(.),$,(,),-, \
                            and underscore (_)."}
                    }
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


proc ::ixia::ixL47FtpAction { args } {
    variable ixload_handles_array
    
#    debug "ixLoadFtpAction: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    regsub {\-arguments[ ]+ANY} $opt_args {-arguments SHIFT} opt_args
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set action_args {
        a_arguments   arguments
        a_command     command
        a_destination destination
        a_user_name   userName
        a_password    password
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
        loop_begin "{Loop Begin}"
        loop_end   "{Loop End}"
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
#            debug "new FTP action handler = $action_name"
            
            set retCode [::ixia::ixL47HandlesArrayCommand                  \
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
                        agents do NOT have actions."
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
            
            # check if real_file argument is valid
            if {[info exists a_arguments]} {
                set match1  [regexp {^/#[0-9]+$} $a_arguments match]
                set match2  [info exists ixload_handles_array($a_arguments)]
                if {$match2} {
                    # get ixload handler
                    set retCode [::ixia::ixL47HandlesArrayCommand     \
                            -mode     get_value                        \
                            -handle   $a_arguments                     \
                            -key      [list ixload_handle ixload_index \
                            type target parent_handle]]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set ixLoadPageHandler [lindex [keylget retCode value] 0]
                    set realFileIndex     [lindex [keylget retCode value] 1]
                    set realFileType      [lindex [keylget retCode value] 2]
                    set realFileTarget    [lindex [keylget retCode value] 3]
                    set realFileAgentName [lindex [keylget retCode value] 4]
                    
                    # get agent index
                    set retCode [::ixia::ixL47HandlesArrayCommand  \
                            -mode     get_value                    \
                            -handle   $realFileAgentName           \
                            -key      ixload_index                 ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set realFileAgentIndex  [keylget retCode value]
                    
                    # check to see if a_page_handle is a valid page handle
                    if {$realFileType != "realFile"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -a_arguments $a_arguments is not a valid \
                                real_file_handle."
                        return $returnList
                    }
                    
                    set    _realFile_cmd "$ixLoadPageHandler "
                    append _realFile_cmd "agentList($realFileAgentIndex)."
                    append _realFile_cmd "realFileList($realFileIndex)."
                    append _realFile_cmd "cget -page"
                    
                    debug "$_realFile_cmd"
                    if {[catch {eval $_realFile_cmd} a_arguments]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $a_arguments."
                        return $returnList
                    }
                }
#                 if {(!$match1) && (!$match2)} {
#                     keylset returnList status $::FAILURE
#                     keylset returnList log "ERROR in $procName: Argument\
#                             -a_arguments $a_arguments is not valid."
#                     return $returnList
#                 }
            }
            
            # check if a_destination is valid
            if {[info exists a_destination]} {
                set match1 [isIpAddressValid [lindex [split $a_destination :] 0]]
                set match2 [::ipv6::isValidAddress $a_destination]
                set match3 [info exists ixload_handles_array($a_destination)]
                if {$match3} {
                    set retCode [::ixia::ixL47HandlesArrayCommand     \
                            -mode     get_value                        \
                            -handle   $a_destination                     \
                            -key      [list ixload_handle ixload_index \
                            type target]]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set ixLoadDestHandler [lindex [keylget retCode value] 0]
                    set destAgentIndex    [lindex [keylget retCode value] 1]
                    set destHandleType    [lindex [keylget retCode value] 2]
                    set destTarget        [lindex [keylget retCode value] 3]
                    
                    # check to see if a_destination is a valid agent handle
                    if {$destHandleType != "agent"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -a_destination $a_destination is not a valid agent\
                                handle."
                        return $returnList
                    }
                    # check to see if a_destination is a valid server agent handle
                    if {$destTarget != "server"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -a_destination $a_destination is not a valid server\
                                agent handle."
                        return $returnList
                    }
                    
                    set _dest_cmd "$ixLoadDestHandler       \
                            agentList($destAgentIndex).cget \
                            -name"
                            
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} destination]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $destination."
                        return $returnList
                    }
                    
                    set _dest_cmd "$ixLoadDestHandler       \
                            agentList($destAgentIndex).cget -ftpPort"
                    
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} ftpPort]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $httpPort."
                        return $returnList
                    }
                    
                    set destination ${destination}:$ftpPort
                    
                    # get the traffic name
                    set _dest_cmd "$ixLoadDestHandler cget -name"
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} _trafficName]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $_trafficName."
                        return $returnList
                    }
                    
                    set a_destination ${_trafficName}_${destination}
                }
                if {$match2} {
                    if {![info exists a_destination_port]} {
                        set a_destination_port 21
                    }
                    set tmp $a_destination
                    set a_destination {\[}
                    append a_destination $tmp
                    append a_destination {\]}
                    append a_destination :$a_destination_port
                }
                if {$match1} {
                    if {[llength [split $a_destination :]] == 2} {
                        if {[info exists a_destination_port] && \
                                $a_destination_port != \
                                [lindex [split $a_destination :] 1]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Ambiguous\
                                    destination port. -a_destination $a_destination\
                                    -a_destination_port $a_destination_port."
                            return $returnList
                        }
                    } else {
                        if {![info exists a_destination_port]} {
                            set a_destination_port 21
                        }
                        set a_destination $a_destination:$a_destination_port
                    }
                }
                if {(!$match1) && (!$match2) && (!$match3)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -a_destination $a_destination is not valid."
                    return $returnList
                }
            }
            
            set _command ""
            foreach item [array names action_args] {
                if {[info exists $item]} {
                    set _param $action_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    if {$item == "a_password"} {
                        if {[regexp {[\[\]]} [set $item]]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log {ERROR in $procName:\
                                Invalid -password. Valid characters are \
                                a-z, A-Z, 0-9, @, dot(.),$,(,),-, \
                                and underscore (_)..}
                            return $returnList
                        } else {
                            append _command "-$_param \{\"[set $item]\"\} "
                        }
                    } else {
                        append _command "-$_param \"[set $item]\" "
                    }
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($pIndex).actionList.appendItem $_command"]
                
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    if {[regexp {Valid characters are} $handler]} {
                        set handler "Error: Lib.Common.ixConfig.ixConfigError: \
                            Password  is invalid. Valid \
                            characters are a-z, A-Z, 0-9, @, dot(.),$,(,),-, \
                            and underscore (_)."
                    }
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
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
            keylset returnList action_handle $action_name
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
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
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
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
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
            
            # check if real_file argument is valid
            if {[info exists a_arguments]} {
                set match1  [regexp {^/#[0-9]+$} $a_arguments match]
                set match2  [info exists ixload_handles_array($a_arguments)]
                if {$match2} {
                    # get ixload handler
                    set retCode [::ixia::ixL47HandlesArrayCommand     \
                            -mode     get_value                        \
                            -handle   $a_arguments                     \
                            -key      [list ixload_handle ixload_index \
                            type target parent_handle]]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set ixLoadPageHandler [lindex [keylget retCode value] 0]
                    set realFileIndex     [lindex [keylget retCode value] 1]
                    set realFileType      [lindex [keylget retCode value] 2]
                    set realFileTarget    [lindex [keylget retCode value] 3]
                    set realFileAgentName [lindex [keylget retCode value] 4]
                    
                    # get agent index
                    set retCode [::ixia::ixL47HandlesArrayCommand  \
                            -mode     get_value                    \
                            -handle   $realFileAgentName           \
                            -key      ixload_index                 ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set realFileAgentIndex  [keylget retCode value]
                    
                    # check to see if a_page_handle is a valid page handle
                    if {$realFileType != "realFile"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -a_arguments $a_arguments is not a valid \
                                real_file_handle."
                        return $returnList
                    }
                    
                    set    _realFile_cmd "$ixLoadPageHandler "
                    append _realFile_cmd "agentList($realFileAgentIndex)."
                    append _realFile_cmd "realFileList($realFileIndex)."
                    append _realFile_cmd "cget -page"
                    
                    debug "$_page_cmd"
                    if {[catch {eval $_page_cmd} a_arguments]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $a_arguments."
                        return $returnList
                    }
                }
                if {(!$match1) && (!$match2)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -a_arguments $a_arguments is not valid."
                    return $returnList
                }
            }
            
            # check if a_destination is valid
            if {[info exists a_destination]} {
                set match1 [isIpAddressValid [lindex [split $a_destination :] 0]]
                set match2 [::ipv6::isValidAddress $a_destination]
                set match3 [info exists ixload_handles_array($a_destination)]
                if {$match3} {
                    set retCode [::ixia::ixL47HandlesArrayCommand     \
                            -mode     get_value                        \
                            -handle   $a_destination                     \
                            -key      [list ixload_handle ixload_index \
                            type target]]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set ixLoadDestHandler [lindex [keylget retCode value] 0]
                    set destAgentIndex    [lindex [keylget retCode value] 1]
                    set destHandleType    [lindex [keylget retCode value] 2]
                    set destTarget        [lindex [keylget retCode value] 3]
                    
                    # check to see if a_destination is a valid agent handle
                    if {$destHandleType != "agent"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -a_destination $a_destination is not a valid agent\
                                handle."
                        return $returnList
                    }
                    # check to see if a_destination is a valid server agent handle
                    if {$destTarget != "server"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -a_destination $a_destination is not a valid server\
                                agent handle."
                        return $returnList
                    }
                    
                    set _dest_cmd "$ixLoadDestHandler       \
                            agentList($destAgentIndex).cget \
                            -name"
                            
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} destination]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $destination."
                        return $returnList
                    }
                    
                    set _dest_cmd "$ixLoadDestHandler       \
                            agentList($destAgentIndex).cget -ftpPort"
                    
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} ftpPort]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $httpPort."
                        return $returnList
                    }
                    
                    set destination ${destination}:${ftpPort} 
                    
                    # get the traffic name
                    set _dest_cmd "$ixLoadDestHandler cget -name"
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} _trafficName]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $_trafficName."
                        return $returnList
                    }
                    
                    set a_destination ${_trafficName}_${destination}
                }
                if {(!$match1) && (!$match2) && (!$match3)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -a_destination $a_destination is not valid."
                    return $returnList
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
                    if {$item == "a_password"} {
                        if {[regexp {[\[\]]} [set $item]]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                Invalid -password. Valid characters are \
                                a-z, A-Z, 0-9, @, dot(.),$,(,),-, \
                                and underscore (_).."
                            return $returnList
                        } else {
                            append _command "-$_param \{\"[set $item]\"\} "
                        }
                    } else {
                        append _command "-$_param \"[set $item]\" "
                    }
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($pIndex).actionList($index).config $_command"]
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    if {[regexp {Valid characters are} $handler]} {
                        set handler {"Error: Lib.Common.ixConfig.ixConfigError: \
                            Password  is invalid. Valid \
                            characters are a-z, A-Z, 0-9, @, dot(.),$,(,),-, \
                            and underscore (_)."}
                    }
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
            keylset returnList log "ERROR in $procName: A command can't be \
                    enabled or disabled."
            return $returnList
        }
    }
}


proc ::ixia::ixL47FtpFile {args} {
    variable ixload_handles_array
    
#    debug "\nixLoadHttpPage: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {
    }
    
    array set file_args {
        rf_name           page
        rf_payload_file   payloadFile
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
            # get next handler
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                   \
                    -type    realFile                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set real_file_name [keylget retCode handle]
            
            # get handler properties
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list ixload_handle ixload_index type target]]
            
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
                    agentList($agentIndex).realFileList.indexCount"]
            
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            
            set _command ""
            foreach item [array names file_args] {
                if {[info exists $item]} {
                    set _param $file_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler                 \
                        agentList($agentIndex).realFileList.appendItem \
                        $_command"]
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand  \
                    -mode            save                  \
                    -handle          $real_file_name       \
                    -type            realFile              \
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
            keylset returnList real_file_handle $real_file_name
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
                        -handle $handle is not a valid real_file_handle."
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
            set realFileIndex   [lindex [keylget retCode value] 1]
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
            if {$handleType != "realFile"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid real_file_handle."
                return $returnList
            }
            
            set _cmd [format "%s" "$ixLoadHandler \
                            agentList($agentIndex).realFileList.deleteItem \
                            $realFileIndex"]
            
            debug $_cmd
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        real_file.\n$error."
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
                        -handle $handle is not a valid real_file_handle."
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
            set realFileIndex   [lindex [keylget retCode value] 1]
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
            
            # check to see if handle is a valid agent handle
            if {$handleType != "realFile"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid real_file_handle."
                return $returnList
            }
            
            set _command ""
            foreach item [array names file_args] {
                if {[info exists $item]} {
                    set _param $file_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($agentIndex).realFileList($realFileIndex).config \
                        $_command"]
                
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
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode $mode \
                    is not supported for -property real_file."
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
