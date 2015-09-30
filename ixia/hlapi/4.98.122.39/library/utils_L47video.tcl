proc ::ixia::ixL47VIDEOCLIENTprofile_table { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        num_profiles    num_profiles
        duration_min    duration_min
        channel_switch_delay_max    channel_switch_delay_max
        channel_switch_delay_min    channel_switch_delay_min
        percentage    percentage
        duration_max    duration_max
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        profile_table    {channel_switch_delay_min percentage channel_switch_delay_max duration_max num_profiles duration_min }
    }
    # Custom Code Bookmark:GroupCommandsWithArgsList



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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:AddStart



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    profile_table                        ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set newObject_name [keylget retCode handle]

    # Custom Code Bookmark:AddGetNewHandle



            set command signalling


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command agentList($ixLoadHandlerIndex).pm.${command}

    # Custom Code Bookmark:AddVerifyHandle




            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    $command.profile_table.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name profile_table
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
                        $command.profile_table.appendItem \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:AddAssembleCommand



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $newObject_name       \
                    -type            profile_table                \
                    -target          client               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               \

                ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
    # Custom Code Bookmark:AddSaveHandle

            keylset returnList status  $::SUCCESS
            keylset returnList profile_table_handle $newObject_name
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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:RemoveStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid profile_table handle
            if {$handleType != "profile_table"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid profile_table handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command "profile_table.deleteItem $ixLoadHandlerIndex"


            set command "signalling.${command}"


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _cmd [format "%s" "$ixLoadHandler $command"]
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

    # Custom Code Bookmark:RemoveAssembleCommand


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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:ModifyStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid profile_table handle
            if {$handleType != "profile_table"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid profile_table handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command profile_table($ixLoadHandlerIndex)


            set command signalling.${command}


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _command ""
            set command_name profile_table
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
                set _cmd [format "%s" "$ixLoadHandler                 \
                        $command.config \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:ModifyAssembleCommand

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


proc ::ixia::ixL47VIDEOCLIENTrule { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
        mpeg4ldaac    "MPEG4LDAAC"
        mpeg4aac    "MPEG4AAC"
        ts    "TS"
        mpeg4    "MPEG4"
        vc1    "VC1"
        h264    "H264"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        rule_value    value
        clock_rate    clock_rate
        rtp_pt    rtp_pt
        codec    codec
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        rule    {rtp_pt codec clock_rate rule_value }
    }
    # Custom Code Bookmark:GroupCommandsWithArgsList



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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:AddStart



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    rule                        ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set newObject_name [keylget retCode handle]

    # Custom Code Bookmark:AddGetNewHandle



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid commands handle
            if {$handleType != "commands"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid commands handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command commands($ixLoadHandlerIndex)


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command agentList($ixLoadHandlerIndex).pm.${command}

    # Custom Code Bookmark:AddVerifyHandle




            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    $command.rule.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name rule
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
                        $command.rule.appendItem \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:AddAssembleCommand



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $newObject_name       \
                    -type            rule                \
                    -target          client               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               \

                ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
    # Custom Code Bookmark:AddSaveHandle

            keylset returnList status  $::SUCCESS
            keylset returnList rule_handle $newObject_name
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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:RemoveStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid rule handle
            if {$handleType != "rule"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid rule handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command "rule.deleteItem $ixLoadHandlerIndex"


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid commands handle
            if {$handleType != "commands"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid commands handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command "commands($ixLoadHandlerIndex).${command}"


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _cmd [format "%s" "$ixLoadHandler $command"]
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

    # Custom Code Bookmark:RemoveAssembleCommand


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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:ModifyStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid rule handle
            if {$handleType != "rule"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid rule handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command rule($ixLoadHandlerIndex)


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid commands handle
            if {$handleType != "commands"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid commands handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command commands($ixLoadHandlerIndex).${command}


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _command ""
            set command_name rule
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
                set _cmd [format "%s" "$ixLoadHandler                 \
                        $command.config \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:ModifyAssembleCommand

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


proc ::ixia::ixL47VIDEOCLIENTcommands { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
        ICCCommand    "ICCCommand"
        PlayStaticCommand    "PlayStaticCommand"
        unique    "Unique"
        StopCommand    "StopCommand"
        ResumeCommand    "ResumeCommand"
        custom    "Custom"
        random    "Random"
        RTSPSetParamCommand    "RTSPSetParamCommand"
        normal    "Normal"
        concurrent    "Concurrent"
        sequential    "Sequential"
        SeekCommand    "SeekCommand"
        LoopEndCommand    "LoopEndCommand"
        PlayMediaCommand    "PlayMediaCommand"
        0    "0"
        1    "1"
        RTSPGetParamCommand    "RTSPGetParamCommand"
        RTSPSetupCommand    "RTSPSetupCommand"
        RTSPTeardownCommand    "RTSPTeardownCommand"
        RTSPPlayCommand    "RTSPPlayCommand"
        JoinCommand    "JoinCommand"
        LoopBeginCommand    "LoopBeginCommand"
        ThinkCommand    "ThinkCommand"
        DescribeCommand    "DescribeCommand"
        PauseCommand    "PauseCommand"
        KeepAliveCommand    "KeepAliveCommand"
        PlayCommand    "PlayCommand"
        poisson    "Poisson"
        RTSPPauseCommand    "RTSPPauseCommand"
        PassiveCommand    "PassiveCommand"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        da_switchover_delay    da_switchover_delay
        media    media
        content    content
        destination_server_activity    destination_server_activity
        start_group_address_sym    start_group_address_sym
        jc_channel_switch_delay_min    channel_switch_delay_min
        rc_duration    duration
        urls    urls
        jc_channel_switch_delay_max    channel_switch_delay_max
        icc_channel_switch_delay_max    channel_switch_delay_max
        max_freq    max_freq
        source_address    source_address
        concurrent_channels    concurrent_channels
        psc_duration    duration
        sigma    sigma
        content_type    contentType
        commands_id    id
        server_ip    serverIP
        start_group_address    start_group_address
        channel_switch_mode    channel_switch_mode
        sym_server_ip    symServerIP
        min_freq    min_freq
        duration    duration
        mu    mu
        maximum_interval    maximumInterval
        enable_unicast    enableUnicast
        count    count
        jc_concurrent_channels    concurrent_channels
        minimum_interval    minimumInterval
        icc_duration_max    duration_max
        duration_min    duration_min
        duration_max    duration_max
        icc_duration_min    duration_min
        group_address_count    group_address_count
        pc_duration    duration
        loop_count    LoopCount
        icc_channel_switch_delay_min    channel_switch_delay_min
        rtsp_duration    duration
        watch_count    watch_count
        var_lambda    varLambda
        group_address_step    group_address_step
        jc_channel_switch_mode    channel_switch_mode
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        ICCCommand    {urls concurrent_channels destination_server_activity commands_id icc_channel_switch_delay_max group_address_step start_group_address sigma channel_switch_mode watch_count var_lambda source_address mu icc_duration_min icc_channel_switch_delay_min group_address_count server_ip icc_duration_max start_group_address_sym da_switchover_delay }
        PlayStaticCommand    {destination_server_activity media commands_id psc_duration server_ip }
        StopCommand    {commands_id }
        ResumeCommand    {rc_duration commands_id }
        RTSPSetParamCommand    {commands_id content_type content }
        PlayCommand    {media commands_id pc_duration destination_server_activity server_ip }
        ThinkCommand    {maximum_interval commands_id minimum_interval }
        LoopEndCommand    {commands_id }
        PlayMediaCommand    {media commands_id sym_server_ip }
        SeekCommand    {duration commands_id }
        RTSPGetParamCommand    {commands_id content content_type }
        RTSPSetupCommand    {commands_id }
        RTSPTeardownCommand    {commands_id }
        JoinCommand    {sigma jc_concurrent_channels group_address_step mu start_group_address commands_id jc_channel_switch_delay_max watch_count var_lambda group_address_count duration_min jc_channel_switch_delay_min destination_server_activity source_address duration_max jc_channel_switch_mode }
        LoopBeginCommand    {commands_id loop_count }
        DescribeCommand    {server_ip media commands_id destination_server_activity }
        PauseCommand    {commands_id }
        KeepAliveCommand    {min_freq count commands_id max_freq }
        RTSPPlayCommand    {commands_id rtsp_duration }
        RTSPPauseCommand    {commands_id }
        PassiveCommand    {enable_unicast commands_id }
    }
    # Custom Code Bookmark:GroupCommandsWithArgsList
    if {[info exists commands_id]} {
        switch -- $commands_id {
            "PlayCommand" -
            "PlayStaticCommand" -
            "DescribeCommand" {
                set destination_parameter "server_ip"
                set destination_media     "media"
            }
            "ICCCommand" {
                set destination_parameter "server_ip"
                set destination_media     "urls"
            }
            "JoinCommand" {
                set destination_parameter "destination_server_activity"
            }
            "PlayMediaCommand" {
                set destination_parameter "sym_server_ip"
                set destination_media     "media"
            }
        }
    }
    
    if {[info exists destination_parameter] && [info exists $destination_parameter]} {
        set destination_parameter_value [set $destination_parameter]
        if {[info exists ixload_handles_array($destination_parameter_value)]} {
            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $destination_parameter_value     \
                    -key      [list ixload_handle ixload_index \
                                type target]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget retCode log]"
                return $returnList
            }
            set ixLoadDestHandler [lindex [keylget retCode value] 0]
            set destAgentIndex    [lindex [keylget retCode value] 1]
            set destHandleType    [lindex [keylget retCode value] 2]
            set destTarget        [lindex [keylget retCode value] 3]
            
            # check to see if sym_destination is a valid agent handle
            if {$destHandleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Argument\
                        -$destination_parameter $destination_parameter_value\
                        is not a valid agent handle."
                return $returnList
            }
            # check to see if sym_destination is a valid server agent handle
            if {$destTarget != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Argument\
                        -$destination_parameter $destination_parameter_value\
                        is not a valid server agent handle."
                return $returnList
            }
            
            set _dest_cmd "$ixLoadDestHandler       \
                    agentList($destAgentIndex).cget \
                    -name"
            
            debug $_dest_cmd
            if {[catch {eval $_dest_cmd} destination]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$destination."
                return $returnList
            }
            
            set _dest_cmd "$ixLoadDestHandler       \
                    agentList($destAgentIndex).pm.advancedOptions.cget -listen_port"
                        
            debug $_dest_cmd
            if {[catch {eval $_dest_cmd} videoPort]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$videoPort."
                return $returnList
            }
            
            set destination ${destination}:$videoPort
#             set destination ${destination}:0
            
            # get the traffic name
            set _dest_cmd "$ixLoadDestHandler cget -name"
            debug $_dest_cmd
            if {[catch {eval $_dest_cmd} _trafficName]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$_trafficName."
                return $returnList
            }
            
            set $destination_parameter ${_trafficName}_${destination}
        }
    }
    
    if {[info exists destination_media] && [info exists $destination_media]} {
        set destination_media_value [set $destination_media]
        if {[info exists ixload_handles_array($destination_media_value)]} {
            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $destination_media_value     \
                    -key      [list ixload_handle ixload_index \
                                type target parent_handle]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget retCode log]"
                return $returnList
            }
            set ixLoadDestHandler [lindex [keylget retCode value] 0]
            set destStreamIndex    [lindex [keylget retCode value] 1]
            set destHandleType    [lindex [keylget retCode value] 2]
            set destTarget        [lindex [keylget retCode value] 3]
            set destParent        [lindex [keylget retCode value] 4]
            
            # check to see if sym_destination is a valid agent handle
            if {$destHandleType != "stream" && $destHandleType != "videoList"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Argument\
                        -$destination_media $destination_media_value\
                        is not a valid agent handle."
                return $returnList
            }
            
            switch -- $destHandleType {
                "stream" {
                    set _dest_cmd "videoProp.stream(${destStreamIndex}).cget -name"
                }
                "videoList" {
                    set _dest_cmd "videoConfig.videoList(${destStreamIndex}).cget -name"
                }
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand      \
                    -mode     get_value                        \
                    -handle   $destParent                      \
                    -key      [list ixload_handle type target ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget retCode log]"
                return $returnList
            }
            set ixDstLoadHandler      [lindex [keylget retCode value] 0]
            set ixDstLoadHandlerIndex [lindex [keylget retCode value] 3]
            set DsthandleType         [lindex [keylget retCode value] 1]
            set Dsttarget         [lindex [keylget retCode value] 2]

            # check to see if handle is a valid agent handle
            if {$DsthandleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Argument\
                        -$destination_media $destination_media_value is not from\
                        a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$Dsttarget != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Argument\
                        -$destination_media $destination_media_value is not from\
                        a valid server handle."
                return $returnList
            }

            set _dest_cmd "$ixDstLoadHandler agentList($ixDstLoadHandlerIndex).pm.${_dest_cmd}"
            
            debug $_dest_cmd
            if {[catch {eval $_dest_cmd} destination]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        $destination."
                return $returnList
            }
            
            set $destination_media $destination
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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:AddStart



            if {![info exists commands_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -commands_id must be provided."
                return $returnList
            }


            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    commands                        ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set newObject_name [keylget retCode handle]

    # Custom Code Bookmark:AddGetNewHandle



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command agentList($ixLoadHandlerIndex).pm

    # Custom Code Bookmark:AddVerifyHandle




            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    $command.commands.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name $commands_id
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
                        $command.commands.appendItem \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:AddAssembleCommand



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $newObject_name       \
                    -type            commands                \
                    -target          client               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               \

                ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
    # Custom Code Bookmark:AddSaveHandle

            keylset returnList status  $::SUCCESS
            keylset returnList commands_handle $newObject_name
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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:RemoveStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid commands handle
            if {$handleType != "commands"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid commands handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command "commands.deleteItem $ixLoadHandlerIndex"


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _cmd [format "%s" "$ixLoadHandler $command"]
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

    # Custom Code Bookmark:RemoveAssembleCommand


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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:ModifyStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid commands handle
            if {$handleType != "commands"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid commands handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command commands($ixLoadHandlerIndex)


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _command ""
            set command_name $commands_id
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
                set _cmd [format "%s" "$ixLoadHandler                 \
                        $command.config \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:ModifyAssembleCommand

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


proc ::ixia::ixL47VIDEOCLIENTchannelviewTable { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        view_sequence    view_sequence
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        channelviewTable    {view_sequence }
    }
    # Custom Code Bookmark:GroupCommandsWithArgsList



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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:AddStart



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    channelviewTable                        ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set newObject_name [keylget retCode handle]

    # Custom Code Bookmark:AddGetNewHandle



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid commands handle
            if {$handleType != "commands"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid commands handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command commands($ixLoadHandlerIndex)


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command agentList($ixLoadHandlerIndex).pm.${command}

    # Custom Code Bookmark:AddVerifyHandle




            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    $command.channelviewTable.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name channelviewTable
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
                        $command.channelviewTable.appendItem \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:AddAssembleCommand



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $newObject_name       \
                    -type            channelviewTable                \
                    -target          client               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               \

                ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
    # Custom Code Bookmark:AddSaveHandle

            keylset returnList status  $::SUCCESS
            keylset returnList channelviewTable_handle $newObject_name
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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:RemoveStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid channelviewTable handle
            if {$handleType != "channelviewTable"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid channelviewTable handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command "channelviewTable.deleteItem $ixLoadHandlerIndex"


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid commands handle
            if {$handleType != "commands"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid commands handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command "commands($ixLoadHandlerIndex).${command}"


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _cmd [format "%s" "$ixLoadHandler $command"]
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

    # Custom Code Bookmark:RemoveAssembleCommand


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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:ModifyStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid channelviewTable handle
            if {$handleType != "channelviewTable"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid channelviewTable handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client handle\
                        handle."
                return $returnList
            }

            set command channelviewTable($ixLoadHandlerIndex)


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid commands handle
            if {$handleType != "commands"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid commands handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command commands($ixLoadHandlerIndex).${command}


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid client handle
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _command ""
            set command_name channelviewTable
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
                set _cmd [format "%s" "$ixLoadHandler                 \
                        $command.config \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:ModifyAssembleCommand

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


proc ::ixia::ixL47VIDEOCLIENTagent { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
        ipv6    "IPv6"
        custom    "Custom"
        windows_media_player    "Windows Media Player"
        igmpv2    "IGMP v2"
        ipv4    "IPv4"
        0    "0"
        1    "1"
        2    "2"
        v1    "MLD v1"
        quick_time    "Quick Time"
        igmpv3    "IGMP v3"
        real_player    "Real Player"
        v2    "MLD v2"
        igmpv1    "IGMP v1"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set hltIxLoadParameterNames {
        router_alert    router_alert
        unsolicited_response_mode    unsolicited_response_mode
        rtsp_header    rtsp_header
        update_interval    updateInterval
        enable_esm    enableEsm
        ip_version    ip_version
        enable_custom    enable_custom
        enable_vuser_monitor    enableVuserMonitor
        client_mode    client_mode
        implicit_loop_check    implicitLoopCheck
        signalling    signalling
        stats    stats
        iptv_options    iptv_options
        vlan_priority    vlan_priority
        enable_vqmon_stats    enableVQmonStats
        jbemode    JBEMode
        enable_custom_setup    enableCustomSetup
        enable_frame_stats    enableFrameStats
        rtsp_proxy_ip    rtspProxyIp
        rtsp_proxy_enable    rtspProxyEnable
        follow_rtsp_redirect    followRtspRedirect
        ignore_loss    IgnoreLoss
        users_allowed    users_allowed
        esm    esm
        transport    transport
        total_limit    totalLimit
        min_delay    MinDelay
        frame_limit    frameLimit
        igmp_version    igmp_version
        general_query_response_mode    general_query_response_mode
        group_specific_query_response_mode    group_specific_query_response_mode
        mld_version    mld_version
        quality_limit    qualityLimit
        report_frequency    report_frequency
        type_of_service_for_rtsp    type_of_service_for_rtsp
        enable_vlan_priority    enableVlanPriority
        custom_setup    CustomSetup
        iptv_switch_mode    iptv_switch_mode
        suppress_reports    suppress_reports
        enable_tos_rtsp    enableTosRTSP
        nom_delay    NomDelay
        max_delay    MaxDelay
        iptv_switch_delay    iptv_switch_delay
        rtsp_proxy_port    rtspProxyPort
        bitrate_limit    bitrateLimit
        vuser_id    vuserId
        immediate_response    immediate_response
        advanced    advanced
    }
    set iptv_options_list [list \
        iptv_switch_delay    \
        iptv_switch_mode    \
    ]
    set stats_list [list \
        update_interval    \
        min_delay    \
        bitrate_limit    \
        total_limit    \
        nom_delay    \
        quality_limit    \
        enable_vuser_monitor    \
        vuser_id    \
        enable_vqmon_stats    \
        max_delay    \
        ignore_loss    \
        frame_limit    \
        jbemode    \
        enable_frame_stats    \
    ]
    set signalling_list [list \
        router_alert    \
        mld_version    \
        unsolicited_response_mode    \
        ip_version    \
        enable_custom    \
        general_query_response_mode    \
        report_frequency    \
        suppress_reports    \
        igmp_version    \
        group_specific_query_response_mode    \
        immediate_response    \
        client_mode    \
    ]
    set advanced_list [list \
        enable_custom_setup    \
        vlan_priority    \
        custom_setup    \
        rtsp_header    \
        rtsp_proxy_port    \
        enable_tos_rtsp    \
        follow_rtsp_redirect    \
        users_allowed    \
        esm    \
        type_of_service_for_rtsp    \
        transport    \
        enable_esm    \
        rtsp_proxy_enable    \
        rtsp_proxy_ip    \
        implicit_loop_check    \
        enable_vlan_priority    \
    ]
    set classNames [list \
        iptv_options    \
        stats    \
        signalling    \
        advanced    \
    ]
    # Custom Code Bookmark:ObjectArgs

    if {$property == "client"} {
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

    # Custom Code Bookmark:GroupCommandsWithArgsList

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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:AddStart

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

    # Custom Code Bookmark:AddGetNewHandle

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

    # Custom Code Bookmark:AddVerifyHandle

            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler agentList.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
    # Custom Code Bookmark:AddGetIndex

            set _target "client"
            set _target [string totitle $_target] 
            set _cmd [format "%s" "$ixLoadHandler agentList.appendItem \
                    -name         $agent_name  \
                    -protocol     Video       \
                    -type         $_target     \
                    -enable 1"                 ]

            debug "$_cmd"
            if {[catch {eval $_cmd} handler]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $handler."
                return $returnList
            }

            foreach {arg_type} $classNames {
                set command_${arg_type} ""
                foreach item [set ${arg_type}_list] {
                    if {[info exists $item]} {
                        set _param $hltIxLoadParameterNames($item)
                        if {[info exists valuesHltToIxLoad([set $item])]} {
                            set $item $valuesHltToIxLoad([set $item])
                        }
                        append command_${arg_type} " -$_param \{[set $item]\} "
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

    # Custom Code Bookmark:AddAssembleCommand

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

    # Custom Code Bookmark:AddSaveHandle

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
    # Custom Code Bookmark:RemoveStart

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

    # Custom Code Bookmark:RemoveVerifyHandle

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
    # Custom Code Bookmark:RemoveAssembleCommand

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

    # Custom Code Bookmark:ModifyStart

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
    # Custom Code Bookmark:ModifyVerifyHandle

            foreach {arg_type} $classNames {                set command_${arg_type} ""
                foreach item [set ${arg_type}_list] {
                    if {[info exists $item]} {
                        set _param $hltIxLoadParameterNames($item)
                        if {[info exists valuesHltToIxLoad([set $item])]} {
                            set $item $valuesHltToIxLoad([set $item])
                        }
                        append command_${arg_type} " -$_param \{[set $item]\} "
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
    # Custom Code Bookmark:ModifyAssembleCommand

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

proc ::ixia::ixL47VIDEOSERVERstream { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
        0    "0"
        1    "1"
        2    "2"
        3    "3"
        4    "4"
        5    "5"
        6    "6"
        7    "7"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        d_server_tos_or_dscp    d_server_tos_or_dscp
        content    content
        enable_d_server_tos    enable_d_server_tos
        duration    duration
        transport    transport
        dest_port_incr    dest_port_incr
        starting_multicast_group_addr    starting_multicast_group_addr
        name    name
        filename    filename
        ip_bit_rate    ip_bit_rate
        addr_incr    addr_incr
        d_server_bit_rate    d_server_bit_rate
        mpeg_type    mpeg_type
        stream_count    stream_count
        starting_dest_port    starting_dest_port
        type    type
        tsperudp    tsperudp
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        stream    {stream_count duration tsperudp transport dest_port_incr mpeg_type d_server_bit_rate addr_incr d_server_tos_or_dscp enable_d_server_tos starting_dest_port filename ip_bit_rate name content type starting_multicast_group_addr }
    }
    # Custom Code Bookmark:GroupCommandsWithArgsList
    if {[info exists content]} {
        switch -- $content {
            "synthetic_payload" {
                set content "Synthetic Payload"
            }
            "real_payload" {
                set content "Real Payload"
            }
            default {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid value '$content' for parameter\
                        -content. Valid choices are 'synthetic_payload' and \
                        'real_payload'"
                return $returnList
            }
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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:AddStart



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    stream                        ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set newObject_name [keylget retCode handle]

    # Custom Code Bookmark:AddGetNewHandle



            set command videoProp


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server handle\
                        handle."
                return $returnList
            }

            set command agentList($ixLoadHandlerIndex).pm.${command}

    # Custom Code Bookmark:AddVerifyHandle




            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    $command.stream.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name stream
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
                        $command.stream.appendItem \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:AddAssembleCommand



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $newObject_name       \
                    -type            stream                \
                    -target          server               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               \

                ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
    # Custom Code Bookmark:AddSaveHandle

            keylset returnList status  $::SUCCESS
            keylset returnList stream_handle $newObject_name
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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:RemoveStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid stream handle
            if {$handleType != "stream"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid stream handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server handle\
                        handle."
                return $returnList
            }

            set command "stream.deleteItem $ixLoadHandlerIndex"


            set command "videoProp.${command}"


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _cmd [format "%s" "$ixLoadHandler $command"]
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

    # Custom Code Bookmark:RemoveAssembleCommand


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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:ModifyStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid stream handle
            if {$handleType != "stream"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid stream handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server handle\
                        handle."
                return $returnList
            }

            set command stream($ixLoadHandlerIndex)


            set command videoProp.${command}


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _command ""
            set command_name stream
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
                set _cmd [format "%s" "$ixLoadHandler                 \
                        $command.config \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:ModifyAssembleCommand

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


proc ::ixia::ixL47VIDEOSERVERagent { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
        0    "0"
        1    "1"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set hltIxLoadParameterNames {
        enable_vlan_priority_for_rtsp    enableVlanPriority_for_rtsp
        enable_esm    enableEsm
        advancedOptions    advancedOptions
        videoConfig    videoConfig
        server_mode    serverMode
        vlan_priority_rtsp    vlan_priority_rtsp
        type_of_service_for_rtsp    type_of_service_for_rtsp
        listen_port    listen_port
        iptv_multiport_enable    iptv_multiport_enable
        enable_tos_data    enableTosData
        type_of_service_for_data    type_of_service_for_data
        esm    esm
        a_server_ip    a_server_ip
        enable_tos_rtsp    enableTosRTSP
        link_speed    link_speed
    }
    set advancedOptions_list [list \
        enable_vlan_priority_for_rtsp    \
        enable_tos_rtsp    \
        enable_tos_data    \
        type_of_service_for_rtsp    \
        esm    \
        listen_port    \
        vlan_priority_rtsp    \
        link_speed    \
        type_of_service_for_data    \
        enable_esm    \
    ]
    set videoConfig_list [list \
        server_mode    \
        a_server_ip    \
        iptv_multiport_enable    \
    ]
    set classNames [list \
        advancedOptions    \
        videoConfig    \
    ]
    # Custom Code Bookmark:ObjectArgs

    if {$property == "server"} {
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

    # Custom Code Bookmark:GroupCommandsWithArgsList

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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:AddStart

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

    # Custom Code Bookmark:AddGetNewHandle

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

    # Custom Code Bookmark:AddVerifyHandle

            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler agentList.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
    # Custom Code Bookmark:AddGetIndex

            set _target "server"
            set _target [string totitle $_target] 
            set _cmd [format "%s" "$ixLoadHandler agentList.appendItem \
                    -name         $agent_name  \
                    -protocol     Video       \
                    -type         $_target     \
                    -enable 1"                 ]

            debug "$_cmd"
            if {[catch {eval $_cmd} handler]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $handler."
                return $returnList
            }

            foreach {arg_type} $classNames {
                set command_${arg_type} ""
                foreach item [set ${arg_type}_list] {
                    if {[info exists $item]} {
                        set _param $hltIxLoadParameterNames($item)
                        if {[info exists valuesHltToIxLoad([set $item])]} {
                            set $item $valuesHltToIxLoad([set $item])
                        }
                        append command_${arg_type} " -$_param \{[set $item]\} "
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

    # Custom Code Bookmark:AddAssembleCommand
            
            # clear videoList table
            set _cmd [format "%s" "$ixLoadHandler agentList($index).pm.videoConfig.videoList.clear"]
            debug "$_cmd"
            if {[catch {eval $_cmd} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $err."
                return $returnList
            }
            
            # clear stream table
            set _cmd [format "%s" "$ixLoadHandler agentList($index).pm.videoProp.stream.clear"]
            debug "$_cmd"
            if {[catch {eval $_cmd} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $err."
                return $returnList
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

    # Custom Code Bookmark:AddSaveHandle

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
    # Custom Code Bookmark:RemoveStart

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

    # Custom Code Bookmark:RemoveVerifyHandle

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
    # Custom Code Bookmark:RemoveAssembleCommand

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

    # Custom Code Bookmark:ModifyStart

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
    # Custom Code Bookmark:ModifyVerifyHandle

            foreach {arg_type} $classNames {                set command_${arg_type} ""
                foreach item [set ${arg_type}_list] {
                    if {[info exists $item]} {
                        set _param $hltIxLoadParameterNames($item)
                        if {[info exists valuesHltToIxLoad([set $item])]} {
                            set $item $valuesHltToIxLoad([set $item])
                        }
                        append command_${arg_type} " -$_param \{[set $item]\} "
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
    # Custom Code Bookmark:ModifyAssembleCommand

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

proc ::ixia::ixL47VIDEOSERVERvideoList { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        stream_count    stream_count
        addr_incr    addr_incr
        dest_port_incr    dest_port_incr
        starting_multicast_group_addr    starting_multicast_group_addr
        type    type
        name    name
        starting_dest_port    starting_dest_port
        duration    duration
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        videoList    {starting_multicast_group_addr stream_count type starting_dest_port duration dest_port_incr name addr_incr }
    }
    # Custom Code Bookmark:GroupCommandsWithArgsList



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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:AddStart



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    videoList                        ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set newObject_name [keylget retCode handle]

    # Custom Code Bookmark:AddGetNewHandle



            set command videoConfig


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server handle\
                        handle."
                return $returnList
            }

            set command agentList($ixLoadHandlerIndex).pm.${command}

    # Custom Code Bookmark:AddVerifyHandle




            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    $command.videoList.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name videoList
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
                        $command.videoList.appendItem \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:AddAssembleCommand



            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $newObject_name       \
                    -type            videoList                \
                    -target          server               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               \

                ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
    # Custom Code Bookmark:AddSaveHandle

            keylset returnList status  $::SUCCESS
            keylset returnList videoList_handle $newObject_name
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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:RemoveStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid videoList handle
            if {$handleType != "videoList"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid videoList handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server handle\
                        handle."
                return $returnList
            }

            set command "videoList.deleteItem $ixLoadHandlerIndex"


            set command "videoConfig.${command}"


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _cmd [format "%s" "$ixLoadHandler $command"]
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

    # Custom Code Bookmark:RemoveAssembleCommand


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
                        -handle $handle is not a valid handle."
                return $returnList
            }

    # Custom Code Bookmark:ModifyStart



            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid videoList handle
            if {$handleType != "videoList"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid videoList handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server handle\
                        handle."
                return $returnList
            }

            set command videoList($ixLoadHandlerIndex)


            set command videoConfig.${command}


            set retCode [::ixia::ixL47HandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $parentHandle                          \
                    -key      [list ixload_handle type target parent_handle ixload_index \
                    ]]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler      [lindex [keylget retCode value] 0]
            set ixLoadHandlerIndex [lindex [keylget retCode value] 4]
            set handleType         [lindex [keylget retCode value] 1]
            set target         [lindex [keylget retCode value] 2]
            set parentHandle             [lindex [keylget retCode value] 3]

            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server parentHandle\
                        handle."
                return $returnList
            }

            set command "agentList($ixLoadHandlerIndex).pm.${command}"

    # Custom Code Bookmark:RemoveVerifyHandle




            set _command ""
            set command_name videoList
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
                set _cmd [format "%s" "$ixLoadHandler                 \
                        $command.config \
                        $_command"]
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }

    # Custom Code Bookmark:ModifyAssembleCommand

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
