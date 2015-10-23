proc ::ixia::ixL47SIPCLIENTscenarios { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble
    if {[info exists sz_audio_file] && $sz_audio_file != "\<_none\>" } {
        # check to see if handle is a valid handle
        if {![info exists ixload_handles_array($sz_audio_file)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -sz_audio_file $sz_audio_file is not a valid handle."
            return $returnList
        }

        set retCode [::ixia::ixL47HandlesArrayCommand     \
                -mode     get_value                        \
                -handle   $sz_audio_file                          \
                -key      [list ixload_handle type target parent_handle ixload_index \
                ]]

        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget retCode log]"
            return $returnList
        }
        set af_ixLoadHandler      [lindex [keylget retCode value] 0]
        set af_ixLoadHandlerIndex [lindex [keylget retCode value] 4]
        set af_handleType         [lindex [keylget retCode value] 1]
        set af_target         [lindex [keylget retCode value] 2]
        set af_parentHandle             [lindex [keylget retCode value] 3]

        # check to see if handle is a valid audioClipsTable handle
        if {$af_handleType != "audioClipsTable"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -sz_audio_file $sz_audio_file is not a valid audioClipsTable handle."
            return $returnList
        }

        # check to see if target is a valid client handle
        if {$af_target != "client"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -sz_audio_file $sz_audio_file is not a valid client\
                    handle."
            return $returnList
        }

        set af_command audioClipsTable($af_ixLoadHandlerIndex)


        set af_command mediaSettings.${af_command}


        set retCode [::ixia::ixL47HandlesArrayCommand     \
                -mode     get_value                        \
                -handle   $af_parentHandle                          \
                -key      [list ixload_handle type target parent_handle ixload_index \
                ]]

        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget retCode log]"
            return $returnList
        }
        set af_ixLoadHandler      [lindex [keylget retCode value] 0]
        set af_ixLoadHandlerIndex [lindex [keylget retCode value] 4]
        set af_handleType         [lindex [keylget retCode value] 1]
        set af_target         [lindex [keylget retCode value] 2]
        set af_parentHandle             [lindex [keylget retCode value] 3]

        # check to see if handle is a valid agent handle
        if {$af_handleType != "agent"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -sz_audio_file $sz_audio_file is not a valid agent handle."
            return $returnList
        }

        # check to see if target is a valid client handle
        if {$af_target != "client"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -sz_audio_file $sz_audio_file is not a valid client parentHandle\
                    handle."
            return $returnList
        }

        set af_command "agentList($af_ixLoadHandlerIndex).pm.${af_command}"

        if {$af_command != ""} {
            set af_cmd [format "%s" "$af_ixLoadHandler                 \
                    $af_command.cget -szWaveName" ]
            debug $af_cmd
            if {[catch {eval $af_cmd} af_handler]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $af_handler."
                return $returnList
            }
        }
        
        set sz_audio_file $af_handler
    }


    array set valuesHltToIxLoad {
        11    "11"
        VOICESESSION    "VOICESESSION"
        10    "10"
        14    "14"
        REDIRECTION    "REDIRECTION"
        DETECTDTMF    "DETECTDTMF"
        8    "8"
        9    "9"
        THINK    "THINK"
        12    "12"
        MEDIASESSION    "MEDIASESSION"
        17    "17"
        0    "0"
        1    "1"
        2    "2"
        3    "3"
        4    "4"
        5    "5"
        6    "6"
        7    "7"
        15    "15"
        REGISTRATION    "REGISTRATION"
        ORIGINATECALL    "ORIGINATECALL"
        GENERATEDTMF    "GENERATEDTMF"
        13    "13"
        GENERATETONE    "GENERATETONE"
        ENDCALL    "ENDCALL"
        _1    "-1"
        GENERATEMF    "GENERATEMF"
        16    "16"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        n_think_min    nThinkMin
        n_total_time    nTotalTime
        n_amplitude2    nAmplitude2
        sz_total_time    szTotalTime
        redirection_sz_destination    szDestination
        n_on_time    nOnTime
        n_dtmf_count    nDtmfCount
        b_use_dest    bUseDest
        n_amplitude1    nAmplitude1
        sz_mf_seq    szMfSeq
        sz_codec_name    szCodecName
        n_tone_name    nToneName
        ms_n_play_mode    nPlayMode
        n_wav_duration    nWavDuration
        sz_dtmf_seq    szDtmfSeq
        vs_sz_dtmf_seq    szDtmfSeq
        n_repeat_count    nRepeatCount
        synth_video    synthVideo
        sz_codec_details    szCodecDetails
        n_first_dtmftimeout    nFirstDTMFTimeout
        vs_n_play_mode    nPlayMode
        n_play_time    nPlayTime
        n_detect_time    nDetectTime
        n_inter_dtmfinterval    nInterDTMFInterval
        n_dtmf_amplitude    nDtmfAmplitude
        n_detect_time_unit    nDetectTimeUnit
        n_mf_duration    nMfDuration
        n_frequency2    nFrequency2
        n_inter_mf_interval    nInterMfInterval
        sz_destination    szDestination
        n_tone_duration    nToneDuration
        n_tone_type    nToneType
        n_session_type    nSessionType
        n_off_time    nOffTime
        sym_destination    symDestination
        n_dtmf_interdigits    nDtmfInterdigits
        scenarios_id    id
        n_time_unit    nTimeUnit
        n_play_mode    nPlayMode
        sz_audio_file    szAudioFile
        n_repetition_count    nRepetitionCount
        n_dtmfdetection_mode    nDTMFDetectionMode
        n_dtmf_duration    nDtmfDuration
        n_frequency1    nFrequency1
        n_think_max    nThinkMax
        n_mf_amplitude    nMfAmplitude
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        REGISTRATION    {sz_destination scenarios_id b_use_dest }
        GENERATEMF    {n_total_time n_inter_mf_interval n_mf_amplitude n_mf_duration sz_codec_name n_time_unit sz_total_time n_repeat_count n_play_mode n_play_time scenarios_id sz_codec_details sz_mf_seq }
        ORIGINATECALL    {sym_destination scenarios_id }
        DETECTDTMF    {n_detect_time n_inter_dtmfinterval n_dtmfdetection_mode n_dtmf_count n_detect_time_unit sz_dtmf_seq scenarios_id n_first_dtmftimeout }
        VOICESESSION    {vs_sz_dtmf_seq n_time_unit sz_total_time n_total_time sz_audio_file n_session_type scenarios_id vs_n_play_mode n_repeat_count n_play_time n_wav_duration }
        THINK    {n_think_min n_think_max scenarios_id }
        REDIRECTION    {redirection_sz_destination scenarios_id }
        GENERATETONE    {sz_total_time n_off_time n_tone_name n_tone_type n_frequency1 sz_codec_details n_total_time n_amplitude1 n_tone_duration n_repeat_count n_amplitude2 sz_codec_name scenarios_id n_play_time n_play_mode n_repetition_count n_time_unit n_frequency2 n_on_time }
        MEDIASESSION    {n_wav_duration n_play_time sz_audio_file n_time_unit ms_n_play_mode scenarios_id synth_video n_repeat_count n_total_time sz_total_time }
        GENERATEDTMF    {n_dtmf_interdigits sz_dtmf_seq n_total_time sz_total_time sz_codec_details n_repeat_count n_dtmf_duration n_play_mode n_dtmf_amplitude n_play_time n_time_unit scenarios_id sz_codec_name }
        ENDCALL    {scenarios_id }
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



            if {![info exists scenarios_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -scenarios_id must be provided."
                return $returnList
            }


            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    scenarios                        ]
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

            if {[info exists sym_destination] && $sym_destination != "none" && $scenarios_id == "ORIGINATECALL"} {
                    set match1 [isIpAddressValid [lindex [split $sym_destination :] 0]]
                    set match2 [::ipv6::isValidAddress $sym_destination]
                    set match3 [info exists ixload_handles_array($sym_destination)]
                    if {$match3} {
                        set retCode [::ixia::ixL47HandlesArrayCommand     \
                                -mode     get_value                        \
                                -handle   $sym_destination                     \
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
                        
                        # check to see if sym_destination is a valid agent handle
                        if {$destHandleType != "agent"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Argument\
                                    -sym_destination $sym_destination is not a valid agent\
                                    handle."
                            return $returnList
                        }
                        # check to see if sym_destination is a valid server agent handle
                        if {$destTarget != "server"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Argument\
                                    -sym_destination $sym_destination is not a valid server\
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
                                agentList($destAgentIndex).pm.generalSettings.cget -szTransport"
                        
                        debug $_dest_cmd
                        if {[catch {eval $_dest_cmd} sipTransport]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $sipTransport."
                            return $returnList
                        }
                        
                        switch -- $sipTransport {
                            "TCP" -
                            "Only TCP" {
                                set _dest_cmd "$ixLoadDestHandler       \
                                    agentList($destAgentIndex).pm.generalSettings.cget -nTcpPort"
                            }
                            "UDP" -
                            "Only UDP" {
                                set _dest_cmd "$ixLoadDestHandler       \
                                    agentList($destAgentIndex).pm.generalSettings.cget -nUdpPort"
                            }
                            default {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        $_dest_cmd returned unexpected value $sipTransport."
                                return $returnList
                            }
                        }
                        
                        debug $_dest_cmd
                        if {[catch {eval $_dest_cmd} sipPort]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $sipPort."
                            return $returnList
                        }
                        
                        set destination ${destination}:$sipPort
                        
                        # get the traffic name
                        set _dest_cmd "$ixLoadDestHandler cget -name"
                        debug $_dest_cmd
                        if {[catch {eval $_dest_cmd} _trafficName]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $_trafficName."
                            return $returnList
                        }
                        
                        set sym_destination ${_trafficName}_${destination}
                    }
                    if {$match2} {
                        set retCode [::ixia::ixL47HandlesArrayCommand      \
                                -mode     get_value                        \
                                -handle   $handle                          \
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
                        
                        set _dest_cmd "$ixLoadDestHandler       \
                                agentList($destAgentIndex).pm.generalSettings.cget -szTransport"
                        
                        debug $_dest_cmd
                        if {[catch {eval $_dest_cmd} sipTransport]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $sipTransport."
                            return $returnList
                        }
                        
                        switch -- $sipTransport {
                            "TCP" -
                            "Only TCP" {
                                set _dest_cmd "$ixLoadDestHandler       \
                                    agentList($destAgentIndex).pm.generalSettings.cget -nTcpPort"
                            }
                            "UDP" -
                            "Only UDP" {
                                set _dest_cmd "$ixLoadDestHandler       \
                                    agentList($destAgentIndex).pm.generalSettings.cget -nUdpPort"
                            }
                            default {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        sipTransport has unexpected value $sipTransport."
                                return $returnList
                            }
                        }
                        
                        debug $_dest_cmd
                        if {[catch {eval $_dest_cmd} sym_destination_port]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $sym_destination_port."
                            return $returnList
                        }
                        
                        set tmp $sym_destination
                        set sym_destination {\[}
                        append sym_destination $tmp
                        append sym_destination {\]}
                        append sym_destination :$sym_destination_port
                    }
                    if {$match1} {
                        set retCode [::ixia::ixL47HandlesArrayCommand      \
                                -mode     get_value                        \
                                -handle   $handle                          \
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
                        
                        set _dest_cmd "$ixLoadDestHandler       \
                                agentList($destAgentIndex).pm.generalSettings.cget -szTransport"
                        
                        debug $_dest_cmd
                        if {[catch {eval $_dest_cmd} sipTransport]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $sipTransport."
                            return $returnList
                        }
                        
                        switch -- $sipTransport {
                            "TCP" -
                            "Only TCP" {
                                set _dest_cmd "$ixLoadDestHandler       \
                                    agentList($destAgentIndex).pm.generalSettings.cget -nTcpPort"
                            }
                            "UDP" -
                            "Only UDP" {
                                set _dest_cmd "$ixLoadDestHandler       \
                                    agentList($destAgentIndex).pm.generalSettings.cget -nUdpPort"
                            }
                            default {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        sipTransport has unexpected value $sipTransport."
                                return $returnList
                            }
                        }
                        
                        debug $_dest_cmd
                        if {[catch {eval $_dest_cmd} sym_destination_port]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $sym_destination_port."
                            return $returnList
                        }
                        
                        if {[llength [split $sym_destination :]] == 2} {
                            if {[info exists sym_destination_port] && \
                                    $sym_destination_port != \
                                    [lindex [split $sym_destination :] 1]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: Ambiguous\
                                        destination port. -sym_destination $sym_destination\
                                        destination_port $sym_destination_port."
                                return $returnList
                            }
                        } else {
                            if {![info exists sym_destination_port]} {
                                set sym_destination_port 5060
                            }
                            set sym_destination $sym_destination:$sym_destination_port
                        }
                    }
                    if {(!$match1) && (!$match2) && (!$match3)} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -sym_destination $sym_destination is not valid."
                        return $returnList
                    }
                }


            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    $command.scenarios.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name $scenarios_id
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
                        $command.scenarios.appendItem \
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
                    -type            scenarios                \
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
            keylset returnList scenarios_handle $newObject_name
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

            # check to see if handle is a valid scenarios handle
            if {$handleType != "scenarios"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid scenarios handle."
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

            set command "scenarios.deleteItem $ixLoadHandlerIndex"


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

            # check to see if handle is a valid scenarios handle
            if {$handleType != "scenarios"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid scenarios handle."
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

            set command scenarios($ixLoadHandlerIndex)


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

            if {[info exists sym_destination] && $sym_destination != "none" && $scenarios_id == "ORIGINATECALL"} {
                    set match1 [isIpAddressValid [lindex [split $sym_destination :] 0]]
                    set match2 [::ipv6::isValidAddress $sym_destination]
                    set match3 [info exists ixload_handles_array($sym_destination)]
                    if {$match3} {
                        set retCode [::ixia::ixL47HandlesArrayCommand     \
                                -mode     get_value                        \
                                -handle   $sym_destination                     \
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
                        
                        # check to see if sym_destination is a valid agent handle
                        if {$destHandleType != "agent"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Argument\
                                    -sym_destination $sym_destination is not a valid agent\
                                    handle."
                            return $returnList
                        }
                        # check to see if sym_destination is a valid server agent handle
                        if {$destTarget != "server"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Argument\
                                    -sym_destination $sym_destination is not a valid server\
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
                                agentList($destAgentIndex).pm.generalSettings.cget -szTransport"
                        
                        debug $_dest_cmd
                        if {[catch {eval $_dest_cmd} sipTransport]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $sipTransport."
                            return $returnList
                        }
                        
                        switch -- $sipTransport {
                            "TCP" -
                            "Only TCP" {
                                set _dest_cmd "$ixLoadDestHandler       \
                                    agentList($destAgentIndex).pm.generalSettings.cget -nTcpPort"
                            }
                            "UDP" -
                            "Only UDP" {
                                set _dest_cmd "$ixLoadDestHandler       \
                                    agentList($destAgentIndex).pm.generalSettings.cget -nUdpPort"
                            }
                            default {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        $_dest_cmd returned unexpected value $sipTransport."
                                return $returnList
                            }
                        }
                        
                        debug $_dest_cmd
                        if {[catch {eval $_dest_cmd} sipPort]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $sipPort."
                            return $returnList
                        }
                        
                        set destination ${destination}:$sipPort
                        
                        # get the traffic name
                        set _dest_cmd "$ixLoadDestHandler cget -name"
                        debug $_dest_cmd
                        if {[catch {eval $_dest_cmd} _trafficName]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $_trafficName."
                            return $returnList
                        }
                        
                        set sym_destination ${_trafficName}_${destination}
                    }
                    if {(!$match1) && (!$match2) && (!$match3)} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -sym_destination $sym_destination is not valid."
                        return $returnList
                    }
                }


            set _command ""
            set command_name $scenarios_id
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


proc ::ixia::ixL47SIPCLIENTaudioClipsTable { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        sz_data_format    szDataFormat
        n_resolution    nResolution
        n_sample_rate    nSampleRate
        sz_raw_wave_name    szRawWaveName
        sz_wave_name    szWaveName
        n_duration    nDuration
        n_size    nSize
        n_channels    nChannels
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        audioClipsTable    {sz_data_format sz_raw_wave_name n_channels n_size n_resolution sz_wave_name n_sample_rate n_duration }
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
                    -type    audioClipsTable                        ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set newObject_name [keylget retCode handle]

    # Custom Code Bookmark:AddGetNewHandle



            set command mediaSettings


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
                    $command.audioClipsTable.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name audioClipsTable
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
                        $command.audioClipsTable.appendItem \
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
                    -type            audioClipsTable                \
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
            keylset returnList audioClipsTable_handle $newObject_name
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

            # check to see if handle is a valid audioClipsTable handle
            if {$handleType != "audioClipsTable"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid audioClipsTable handle."
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

            set command "audioClipsTable.deleteItem $ixLoadHandlerIndex"


            set command "mediaSettings.${command}"


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

            # check to see if handle is a valid audioClipsTable handle
            if {$handleType != "audioClipsTable"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid audioClipsTable handle."
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

            set command audioClipsTable($ixLoadHandlerIndex)


            set command mediaSettings.${command}


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
            set command_name audioClipsTable
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


proc ::ixia::ixL47SIPCLIENTrulesTable { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
        register    "REGISTER"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        sz_value    szValue
        sz_action    szAction
        sz_message    szMessage
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        rulesTable    {sz_value sz_action sz_message }
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
                    -type    rulesTable                        ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set newObject_name [keylget retCode handle]

    # Custom Code Bookmark:AddGetNewHandle



            set command contentOfMessages


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
                    $command.rulesTable.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name rulesTable
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
                        $command.rulesTable.appendItem \
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
                    -type            rulesTable                \
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
            keylset returnList rulesTable_handle $newObject_name
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

            # check to see if handle is a valid rulesTable handle
            if {$handleType != "rulesTable"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid rulesTable handle."
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

            set command "rulesTable.deleteItem $ixLoadHandlerIndex"


            set command "contentOfMessages.${command}"


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

            # check to see if handle is a valid rulesTable handle
            if {$handleType != "rulesTable"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid rulesTable handle."
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

            set command rulesTable($ixLoadHandlerIndex)


            set command contentOfMessages.${command}


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
            set command_name rulesTable
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


proc ::ixia::ixL47SIPCLIENTagent { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
        only_tcp    "Only TCP"
        udp    "UDP"
        g726    "G726"
        g729a    "G729A"
        pl_20    "PL_20"
        0    "0"
        1    "1"
        pl_30    "PL_30"
        g729b    "G729B"
        i_lbc    "iLBC"
        amr    "AMR"
        tcp    "TCP"
        only_udp    "Only UDP"
        g723_1    "G723_1"
        g711ulaw    "G711ULaw"
        g711alaw    "G711ALaw"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set hltIxLoadParameterNames {
        n_comp_max_dropped    nCompMaxDropped
        bytes_per_frame_buffer    bytesPerFrameBuffer
        n_re_reg_duration    nReRegDuration
        sz_from    szFROM
        n_tcp_port    nTcpPort
        ipv6form    ipv6Form
        sz_peer_codec_name    szPeerCodecName
        sz_power_level    szPowerLevel
        sz_bit_rate    szBitRate
        n_mos_interval    nMosInterval
        sz_auth_username    szAuthUsername
        group_box__mos1    groupBox_MOS1
        ip_preference    ipPreference
        use_dhcp    useDhcp
        video_bitrate_limit    videoBitrateLimit
        n_timers_td    nTimersTD
        n_timers_t2    nTimersT2
        sz_registrar    szRegistrar
        n_pref_qop    nPrefQop
        n_comp_jitter_ms    nCompJitterMs
        sz_codec_descr    szCodecDescr
        b_mos_on_max    bMosOnMax
        _gb_dhcp_server_port    _gbDhcpServerPort
        n_jitter_buffer    nJitterBuffer
        n_timers_t1    nTimersT1
        ms_n_dtmf_interdigits    nDtmfInterdigits
        n_udp_max_size    nUdpMaxSize
        n_timers_tc    nTimersTC
        b_advisable    bAdvisable
        implicit_loop_check    implicitLoopCheck
        b_silence_mode    bSilenceMode
        compress_zeros    compressZeros
        b_compact    bCompact
        sz_contact    szCONTACT
        b_use_silence    bUseSilence
        sz_silence_file    szSilenceFile
        sz_codec_details    szCodecDetails
        n_jitter_ms    nJitterMs
        n_peer_dtmf_interdigits    nPeerDtmfInterdigits
        type_of_service_for_sip    type_of_service_for_sip
        b_remove_credent    bRemoveCredent
        n_comp_jitter_buffer    nCompJitterBuffer
        vlan_priority_sip    vlan_priority_sip
        ms_n_session_type    nSessionType
        n_dtmf_streams    nDtmfStreams
        enable_tos_rtp    enableTosRTP
        b_comp_ms    bCompMs
        ms_n_dtmf_duration    nDtmfDuration
        sz_peer_codec_details    szPeerCodecDetails
        _gb_ip_preference    _gbIpPreference
        b_reg_before    bRegBefore
        b_route    bRoute
        b_rtp_start_collector    bRtpStartCollector
        mediaSettings    mediaSettings
        b_next_on_fail    bNextOnFail
        sz_peer_dtmf_seq    szPeerDtmfSeq
        enable_vlan_priority_for_sip    enableVlanPriority_for_sip
        b_jit_ms    bJitMs
        sz_requesturi    szREQUESTURI
        n_timers_t4    nTimersT4
        sz_auth_domain    szAuthDomain
        contentOfMessages    contentOfMessages
        b_limit_dtmf    bLimitDtmf
        n_timeout    nTimeout
        type_of_service_for_rtp    type_of_service_for_rtp
        b_use_timer    bUseTimer
        enable_tos_sip    enableTosSIP
        b_use_jitter    bUseJitter
        b_modify_power_level    bModifyPowerLevel
        b_best_performance    bBestPerformance
        packet_time_buffer    packetTimeBuffer
        videoSettings    videoSettings
        group_box__jb1    groupBox_JB1
        ms_sz_codec_name    szCodecName
        b_scattered    bScattered
        n_mos_max_streams    nMosMaxStreams
        video_bitrate    videoBitrate
        sz_auth_password    szAuthPassword
        n_udp_port    nUdpPort
        b_recv5xx    bRecv5xx
        stateMachine    stateMachine
        n_peer_dtmf_duration    nPeerDtmfDuration
        b_optional    bOptional
        sz_transport    szTransport
        n_audio_pool_time    nAudioPoolTime
        sz_route    szRoute
        sz_dtmf_seq    szDtmfSeq
        n_pc_interval    nPcInterval
        b_use_compensation    bUseCompensation
        dhcp_server_port    dhcpServerPort
        b_use_mos    bUseMOS
        generalSettings    generalSettings
        sz_to    szTO
        b_folding    bFolding
    }
    set stateMachine_list [list \
        b_recv5xx    \
        n_timeout    \
        b_next_on_fail    \
        n_timers_t4    \
        n_timers_t2    \
        n_timers_tc    \
        b_use_timer    \
        n_timers_t1    \
        n_timers_td    \
        n_re_reg_duration    \
    ]
    set mediaSettings_list [list \
        b_comp_ms    \
        ms_n_session_type    \
        n_audio_pool_time    \
        b_use_silence    \
        sz_power_level    \
        b_use_mos    \
        b_use_compensation    \
        group_box__mos1    \
        b_rtp_start_collector    \
        n_comp_jitter_ms    \
        n_comp_jitter_buffer    \
        n_pc_interval    \
        n_peer_dtmf_duration    \
        sz_peer_codec_name    \
        sz_codec_descr    \
        sz_silence_file    \
        sz_bit_rate    \
        bytes_per_frame_buffer    \
        n_jitter_ms    \
        n_peer_dtmf_interdigits    \
        n_jitter_buffer    \
        sz_dtmf_seq    \
        ms_n_dtmf_interdigits    \
        sz_codec_details    \
        n_dtmf_streams    \
        ms_n_dtmf_duration    \
        b_silence_mode    \
        n_mos_max_streams    \
        n_mos_interval    \
        sz_peer_codec_details    \
        sz_peer_dtmf_seq    \
        b_limit_dtmf    \
        b_jit_ms    \
        group_box__jb1    \
        b_use_jitter    \
        ms_sz_codec_name    \
        n_comp_max_dropped    \
        b_mos_on_max    \
        packet_time_buffer    \
        b_modify_power_level    \
    ]
    set generalSettings_list [list \
        sz_auth_password    \
        enable_tos_rtp    \
        enable_vlan_priority_for_sip    \
        n_udp_port    \
        ip_preference    \
        use_dhcp    \
        sz_auth_username    \
        sz_registrar    \
        sz_transport    \
        type_of_service_for_rtp    \
        dhcp_server_port    \
        _gb_dhcp_server_port    \
        b_reg_before    \
        n_udp_max_size    \
        compress_zeros    \
        _gb_ip_preference    \
        n_tcp_port    \
        sz_auth_domain    \
        enable_tos_sip    \
        b_remove_credent    \
        n_pref_qop    \
        type_of_service_for_sip    \
        ipv6form    \
        implicit_loop_check    \
        vlan_priority_sip    \
    ]
    set contentOfMessages_list [list \
        b_optional    \
        b_route    \
        sz_from    \
        b_best_performance    \
        sz_contact    \
        b_compact    \
        b_advisable    \
        sz_to    \
        b_scattered    \
        sz_requesturi    \
        sz_route    \
        b_folding    \
    ]
    set videoSettings_list [list \
        video_bitrate    \
        video_bitrate_limit    \
    ]
    set classNames [list \
        stateMachine    \
        mediaSettings    \
        generalSettings    \
        contentOfMessages    \
        videoSettings    \
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
                    -protocol     SIP       \
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
            # Get audioClipsTable Objects
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($index).pm.mediaSettings.audioClipsTable.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} act_index_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $act_index_count."
                return $returnList
            }
            
            set act_handles_list ""
            for {set i 0} {$i < $act_index_count} {incr i} {
                
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode get_handle \
                        -type audioClipsTable       ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                
                set act_name [keylget retCode handle]
            
                set retCode [::ixia::ixL47HandlesArrayCommand  \
                        -mode            save                  \
                        -handle          $act_name             \
                        -type            audioClipsTable       \
                        -target          $target               \
                        -ixload_handle   $ixLoadHandler        \
                        -ixload_index    $i                    \
                        -parent_handle   $agent_name           ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                
                lappend act_handles_list $act_name
            }
            
            if {$act_handles_list != ""} {
                keylset returnList audioClipsTable_handles $act_handles_list
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


proc ::ixia::ixL47SIPSERVERscenarios { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble
    if {[info exists sz_audio_file] && $sz_audio_file != "\<_none\>" } {
        # check to see if handle is a valid handle
        if {![info exists ixload_handles_array($sz_audio_file)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -sz_audio_file $sz_audio_file is not a valid handle."
            return $returnList
        }

        set retCode [::ixia::ixL47HandlesArrayCommand     \
                -mode     get_value                        \
                -handle   $sz_audio_file                          \
                -key      [list ixload_handle type target parent_handle ixload_index \
                ]]

        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget retCode log]"
            return $returnList
        }
        set af_ixLoadHandler      [lindex [keylget retCode value] 0]
        set af_ixLoadHandlerIndex [lindex [keylget retCode value] 4]
        set af_handleType         [lindex [keylget retCode value] 1]
        set af_target         [lindex [keylget retCode value] 2]
        set af_parentHandle             [lindex [keylget retCode value] 3]

        # check to see if handle is a valid audioClipsTable handle
        if {$af_handleType != "audioClipsTable"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -sz_audio_file $sz_audio_file is not a valid audioClipsTable handle."
            return $returnList
        }

        # check to see if target is a valid client handle
        if {$af_target != "server"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -sz_audio_file $sz_audio_file is not a valid server\
                    handle."
            return $returnList
        }

        set af_command audioClipsTable($af_ixLoadHandlerIndex)


        set af_command mediaSettings.${af_command}


        set retCode [::ixia::ixL47HandlesArrayCommand     \
                -mode     get_value                        \
                -handle   $af_parentHandle                          \
                -key      [list ixload_handle type target parent_handle ixload_index \
                ]]

        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget retCode log]"
            return $returnList
        }
        set af_ixLoadHandler      [lindex [keylget retCode value] 0]
        set af_ixLoadHandlerIndex [lindex [keylget retCode value] 4]
        set af_handleType         [lindex [keylget retCode value] 1]
        set af_target         [lindex [keylget retCode value] 2]
        set af_parentHandle             [lindex [keylget retCode value] 3]

        # check to see if handle is a valid agent handle
        if {$af_handleType != "agent"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -sz_audio_file $sz_audio_file is not a valid agent handle."
            return $returnList
        }

        # check to see if target is a valid server handle
        if {$af_target != "server"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -sz_audio_file $sz_audio_file is not a valid server parentHandle\
                    handle."
            return $returnList
        }

        set af_command "agentList($af_ixLoadHandlerIndex).pm.${af_command}"

        if {$af_command != ""} {
            set af_cmd [format "%s" "$af_ixLoadHandler                 \
                    $af_command.cget -szWaveName" ]
            debug $af_cmd
            if {[catch {eval $af_cmd} af_handler]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $af_handler."
                return $returnList
            }
        }
        
        set sz_audio_file $af_handler
    }


    array set valuesHltToIxLoad {
        RECEIVEUSING180    "RECEIVEUSING180"
        0    "0"
        1    "1"
        2    "2"
        3    "3"
        SEND6XX    "SEND6XX"
        RECEIVEUSING100AND180    "RECEIVEUSING100AND180"
        VOICESESSION    "VOICESESSION"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        n_time_unit    nTimeUnit
        n_repeat_count    nRepeatCount
        n_play_time    nPlayTime
        scenarios_id    id
        n_session_type    nSessionType
        sz_audio_file    szAudioFile
        sz_total_time    szTotalTime
        n_total_time    nTotalTime
        n_wav_duration    nWavDuration
        vs_n_play_mode    nPlayMode
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        VOICESESSION    {scenarios_id n_session_type n_repeat_count n_play_time n_total_time n_wav_duration n_time_unit vs_n_play_mode sz_total_time sz_audio_file }
        RECEIVEUSING180    {scenarios_id }
        SEND6XX    {scenarios_id }
        RECEIVEUSING100AND180    {scenarios_id }
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



            if {![info exists scenarios_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -scenarios_id must be provided."
                return $returnList
            }


            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    scenarios                        ]
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

            # check to see if target is a valid server handle
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server handle\
                        handle."
                return $returnList
            }

            set command agentList($ixLoadHandlerIndex).pm

    # Custom Code Bookmark:AddVerifyHandle




            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    $command.scenarios.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name $scenarios_id
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
                        $command.scenarios.appendItem \
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
                    -type            scenarios                \
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
            keylset returnList scenarios_handle $newObject_name
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

            # check to see if handle is a valid scenarios handle
            if {$handleType != "scenarios"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid scenarios handle."
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

            set command "scenarios.deleteItem $ixLoadHandlerIndex"


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

            # check to see if handle is a valid scenarios handle
            if {$handleType != "scenarios"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid scenarios handle."
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

            set command scenarios($ixLoadHandlerIndex)


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
            set command_name $scenarios_id
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


proc ::ixia::ixL47SIPSERVERaudioClipsTable { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        sz_data_format    szDataFormat
        n_resolution    nResolution
        n_sample_rate    nSampleRate
        sz_raw_wave_name    szRawWaveName
        sz_wave_name    szWaveName
        n_duration    nDuration
        n_size    nSize
        n_channels    nChannels
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        audioClipsTable    {sz_data_format sz_raw_wave_name n_channels n_size n_resolution sz_wave_name n_sample_rate n_duration }
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
                    -type    audioClipsTable                        ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set newObject_name [keylget retCode handle]

    # Custom Code Bookmark:AddGetNewHandle



            set command mediaSettings


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
                    $command.audioClipsTable.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name audioClipsTable
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
                        $command.audioClipsTable.appendItem \
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
                    -type            audioClipsTable                \
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
            keylset returnList audioClipsTable_handle $newObject_name
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

            # check to see if handle is a valid audioClipsTable handle
            if {$handleType != "audioClipsTable"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid audioClipsTable handle."
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

            set command "audioClipsTable.deleteItem $ixLoadHandlerIndex"


            set command "mediaSettings.${command}"


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

            # check to see if handle is a valid audioClipsTable handle
            if {$handleType != "audioClipsTable"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid audioClipsTable handle."
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

            set command audioClipsTable($ixLoadHandlerIndex)


            set command mediaSettings.${command}


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
            set command_name audioClipsTable
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


proc ::ixia::ixL47SIPSERVERrulesTable { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
        register    "REGISTER"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set client_command_args {
        sz_value    szValue
        sz_action    szAction
        sz_message    szMessage
    }
    # Custom Code Bookmark:ObjectArgs



    array set groupCommandWithArgs {
        rulesTable    {sz_value sz_action sz_message }
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
                    -type    rulesTable                        ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set newObject_name [keylget retCode handle]

    # Custom Code Bookmark:AddGetNewHandle



            set command contentOfMessages


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
                    $command.rulesTable.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }

    # Custom Code Bookmark:AddGetIndex



            set _command ""
            set command_name rulesTable
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
                        $command.rulesTable.appendItem \
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
                    -type            rulesTable                \
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
            keylset returnList rulesTable_handle $newObject_name
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

            # check to see if handle is a valid rulesTable handle
            if {$handleType != "rulesTable"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid rulesTable handle."
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

            set command "rulesTable.deleteItem $ixLoadHandlerIndex"


            set command "contentOfMessages.${command}"


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

            # check to see if handle is a valid rulesTable handle
            if {$handleType != "rulesTable"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid rulesTable handle."
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

            set command rulesTable($ixLoadHandlerIndex)


            set command contentOfMessages.${command}


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
            set command_name rulesTable
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


proc ::ixia::ixL47SIPSERVERagent { args } {
    variable ixload_handles_array
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    # Custom Code Bookmark:ProcedurePreamble



    array set valuesHltToIxLoad {
        g729a    "G729A"
        amr    "AMR"
        g729b    "G729B"
        only_udp    "Only UDP"
        tcp    "TCP"
        pl_20    "PL_20"
        g711ulaw    "G711ULaw"
        i_lbc    "iLBC"
        g723_1    "G723_1"
        udp    "UDP"
        0    "0"
        1    "1"
        2    "2"
        3    "3"
        4    "4"
        only_tcp    "Only TCP"
        g726    "G726"
        pl_30    "PL_30"
        g711alaw    "G711ALaw"
    }
    # Custom Code Bookmark:ValuesHltToIxLoadList



    array set hltIxLoadParameterNames {
        n_comp_max_dropped    nCompMaxDropped
        bytes_per_frame_buffer    bytesPerFrameBuffer
        sz_from    szFROM
        n_tcp_port    nTcpPort
        ipv6form    ipv6Form
        sz_peer_codec_name    szPeerCodecName
        sz_power_level    szPowerLevel
        sz_bit_rate    szBitRate
        n_mos_interval    nMosInterval
        sz_auth_username    szAuthUsername
        group_box__mos1    groupBox_MOS1
        ip_preference    ipPreference
        use_dhcp    useDhcp
        video_bitrate_limit    videoBitrateLimit
        n_timers_td    nTimersTD
        n_timers_t2    nTimersT2
        n_active_timeout_value    nActiveTimeoutValue
        sz_registrar    szRegistrar
        n_pref_qop    nPrefQop
        ms_n_session_type    nSessionType
        n_comp_jitter_ms    nCompJitterMs
        sz_codec_descr    szCodecDescr
        b_mos_on_max    bMosOnMax
        _gb_dhcp_server_port    _gbDhcpServerPort
        n_jitter_buffer    nJitterBuffer
        enable_tos_sip    enableTosSIP
        ms_n_dtmf_interdigits    nDtmfInterdigits
        n_active_timeout_tu    nActiveTimeoutTU
        n_udp_max_size    nUdpMaxSize
        n_timers_tc    nTimersTC
        b_advisable    bAdvisable
        b_silence_mode    bSilenceMode
        compress_zeros    compressZeros
        b_compact    bCompact
        sz_contact    szCONTACT
        b_use_silence    bUseSilence
        sz_silence_file    szSilenceFile
        sz_codec_details    szCodecDetails
        n_jitter_ms    nJitterMs
        n_peer_dtmf_interdigits    nPeerDtmfInterdigits
        type_of_service_for_sip    type_of_service_for_sip
        b_remove_credent    bRemoveCredent
        n_comp_jitter_buffer    nCompJitterBuffer
        vlan_priority_sip    vlan_priority_sip
        sz_transport    szTransport
        n_dtmf_streams    nDtmfStreams
        enable_tos_rtp    enableTosRTP
        b_comp_ms    bCompMs
        ms_n_dtmf_duration    nDtmfDuration
        sz_peer_codec_details    szPeerCodecDetails
        _gb_ip_preference    _gbIpPreference
        b_reg_before    bRegBefore
        b_uas_stateless    bUasStateless
        b_rtp_start_collector    bRtpStartCollector
        mediaSettings    mediaSettings
        n_timers_t1    nTimersT1
        sz_peer_dtmf_seq    szPeerDtmfSeq
        n_active_timeout    nActiveTimeout
        enable_vlan_priority_for_sip    enableVlanPriority_for_sip
        b_jit_ms    bJitMs
        sz_requesturi    szREQUESTURI
        n_timers_t4    nTimersT4
        sz_auth_domain    szAuthDomain
        contentOfMessages    contentOfMessages
        b_limit_dtmf    bLimitDtmf
        type_of_service_for_rtp    type_of_service_for_rtp
        b_use_jitter    bUseJitter
        b_modify_power_level    bModifyPowerLevel
        reg_interval    regInterval
        b_best_performance    bBestPerformance
        packet_time_buffer    packetTimeBuffer
        videoSettings    videoSettings
        group_box__jb1    groupBox_JB1
        ms_sz_codec_name    szCodecName
        b_scattered    bScattered
        ms_sz_dtmf_seq    szDtmfSeq
        n_mos_max_streams    nMosMaxStreams
        video_bitrate    videoBitrate
        sz_auth_password    szAuthPassword
        n_udp_port    nUdpPort
        stateMachine    stateMachine
        n_peer_dtmf_duration    nPeerDtmfDuration
        b_optional    bOptional
        n_audio_pool_time    nAudioPoolTime
        n_pc_interval    nPcInterval
        b_use_compensation    bUseCompensation
        dhcp_server_port    dhcpServerPort
        b_use_mos    bUseMOS
        generalSettings    generalSettings
        sz_to    szTO
        b_folding    bFolding
    }
    set stateMachine_list [list \
        n_active_timeout_tu    \
        n_timers_t4    \
        n_timers_tc    \
        n_timers_t1    \
        b_uas_stateless    \
        n_active_timeout    \
        n_timers_td    \
        n_timers_t2    \
        n_active_timeout_value    \
    ]
    set mediaSettings_list [list \
        b_comp_ms    \
        ms_n_session_type    \
        n_audio_pool_time    \
        sz_peer_codec_name    \
        sz_power_level    \
        b_use_mos    \
        n_comp_jitter_ms    \
        b_use_compensation    \
        group_box__mos1    \
        b_rtp_start_collector    \
        ms_sz_dtmf_seq    \
        b_use_silence    \
        n_comp_jitter_buffer    \
        n_jitter_buffer    \
        sz_peer_dtmf_seq    \
        n_peer_dtmf_duration    \
        sz_codec_descr    \
        sz_bit_rate    \
        bytes_per_frame_buffer    \
        n_jitter_ms    \
        n_pc_interval    \
        n_peer_dtmf_interdigits    \
        sz_silence_file    \
        ms_n_dtmf_interdigits    \
        sz_codec_details    \
        n_dtmf_streams    \
        ms_n_dtmf_duration    \
        b_use_jitter    \
        b_silence_mode    \
        n_mos_max_streams    \
        n_mos_interval    \
        sz_peer_codec_details    \
        b_limit_dtmf    \
        b_jit_ms    \
        group_box__jb1    \
        ms_sz_codec_name    \
        n_comp_max_dropped    \
        b_mos_on_max    \
        packet_time_buffer    \
        b_modify_power_level    \
    ]
    set generalSettings_list [list \
        sz_auth_password    \
        b_remove_credent    \
        enable_vlan_priority_for_sip    \
        n_udp_port    \
        ip_preference    \
        use_dhcp    \
        sz_auth_username    \
        sz_registrar    \
        type_of_service_for_rtp    \
        sz_transport    \
        dhcp_server_port    \
        reg_interval    \
        _gb_dhcp_server_port    \
        b_reg_before    \
        n_udp_max_size    \
        enable_tos_rtp    \
        compress_zeros    \
        n_tcp_port    \
        sz_auth_domain    \
        enable_tos_sip    \
        n_pref_qop    \
        _gb_ip_preference    \
        type_of_service_for_sip    \
        ipv6form    \
        vlan_priority_sip    \
    ]
    set contentOfMessages_list [list \
        b_optional    \
        sz_from    \
        b_best_performance    \
        sz_contact    \
        b_compact    \
        b_scattered    \
        b_advisable    \
        sz_to    \
        sz_requesturi    \
        b_folding    \
    ]
    set videoSettings_list [list \
        video_bitrate    \
        video_bitrate_limit    \
    ]
    set classNames [list \
        stateMachine    \
        mediaSettings    \
        generalSettings    \
        contentOfMessages    \
        videoSettings    \
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
                    -protocol     SIP       \
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
            # Get audioClipsTable Objects
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($index).pm.mediaSettings.audioClipsTable.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} act_index_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $act_index_count."
                return $returnList
            }
            
            set act_handles_list ""
            for {set i 0} {$i < $act_index_count} {incr i} {
                
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode get_handle \
                        -type audioClipsTable       ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                
                set act_name [keylget retCode handle]
            
                set retCode [::ixia::ixL47HandlesArrayCommand  \
                        -mode            save                  \
                        -handle          $act_name             \
                        -type            audioClipsTable       \
                        -target          $target               \
                        -ixload_handle   $ixLoadHandler        \
                        -ixload_index    $i                    \
                        -parent_handle   $agent_name           ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                
                lappend act_handles_list $act_name
            }
            
            if {$act_handles_list != ""} {
                keylset returnList audioClipsTable_handles $act_handles_list
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
