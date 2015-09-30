proc  ::ixia::set_trigger_params {} {
    uplevel {
        foreach {hlt_mode ix_mode} $mode_list {
            if {(![info exists $hlt_mode]) || ([set $hlt_mode] == 0)} {
                foreach option $option_list {
                    if {[info exists $hlt_mode$option]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Option $hlt_mode$option \
                                available only when $hlt_mode is enabled."
                        return $returnList
                    }
                }
                if {([info exists $hlt_mode]) && ([set $hlt_mode] == 0)} {
                    if {[catch  {filter config -${ix_mode}Enable \
                                    [set $hlt_mode]} retError]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Error when filter config\
                                -${ix_mode}Enable [set $hlt_mode].\n
                                Possible errors are $::ixErrorInfo"
                        return $returnList
                    }
                }
            } else {
                if {[catch  {filter config -${ix_mode}Enable \
                                [set $hlt_mode]} retError]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error when filter config\
                            -${ix_mode}Enable [set $hlt_mode].\n \
                            Possible errors are $::ixErrorInfo"
                    return $returnList
                }
                
                debug "filter config -${ix_mode}Enable [set $hlt_mode]"
                
                foreach {hlt_option ix_option} $option_list {
                    if {[info exists $hlt_mode$hlt_option]} {
                        if {$hlt_option == "_error"} {
                            set err_name [set $hlt_mode$hlt_option]
                            set err_no [lsearch $error_list $err_name]
                            if {$err_no == -1} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Error type $err_name \
                                        is not supported or invalid error type.\
                                        The port feature \
                                        may not be supported or inactive \
                                        with this port."
                                return $returnList
                            } else {
                                set err_no [set ::$err_name]
                                if {($err_no != 0) && ($err_no != 1) && \
                                            ($err_no != 2) && ($err_no != 3)} {
                                    if {[info exists isAsync]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Error! async \
                                                triggers can not be set when \
                                                error type is other than \
                                                errAnyFrame, errGoodFrame, \
                                                errBadCRC, errBadFrame."
                                        return $returnList
                                    }
                                }
                                if {$err_name == "errGfpErrors"} {
                                    if {![port isValidFeature $chassis $card \
                                        $port $::portFeatureGfp]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Error! Port \
                                            $chassis/$card/$port does not \
                                            support portFeatureGfp."
                                        return $returnList
                                    }
                                }
                                if {[catch  {filter config -$ix_mode$ix_option \
                                                [set $hlt_mode$hlt_option]} retError]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Error when filter config \
                                            -$ix_mode$ix_option \
                                            [set $hlt_mode$hlt_option]\n \
                                            Possible causes are $::ixErrorInfo"
                                    return $returnList
                                }
                                
                                debug "filter config -$ix_mode$ix_option \
                                        [set $hlt_mode$hlt_option]"
                            }
                        } else  {
                            switch --  $hlt_option {
                                _framesize_from {
                                    set temp ${hlt_mode}_framesize
                                    if {(![info exists $temp]) || ([set $temp] == 0)} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "$hlt_mode$hlt_option \
                                                available only when \
                                                $temp is enabled."
                                        return $returnList
                                    } else  {
                                        if {[catch  {filter config -$ix_mode$ix_option \
                                                [set $hlt_mode$hlt_option]} retError]} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "Error when \
                                                    filter config -$ix_mode$ix_option \
                                                    [set $hlt_mode$hlt_option].\n\
                                                    Possible causes are $::ixErrorInfo"
                                            return $returnList
                                        }
                                        set skip 1
                                        debug "filter config -$ix_mode$ix_option \
                                                [set $hlt_mode$hlt_option]"
                                    }
                                }
                                _framesize_to {
                                    set temp ${hlt_mode}_framesize
                                    if {(![info exists $temp]) || ([set $temp] == 0)} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "$hlt_mode$hlt_option \
                                                available only when \
                                                $temp is enabled."
                                        return $returnList
                                    } else  {
                                        if {[catch  {filter config -$ix_mode$ix_option \
                                                        [set $hlt_mode$hlt_option]} retError]} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "Error when \
                                                    filter config -$ix_mode$ix_option \
                                                    [set $hlt_mode$hlt_option].\n\
                                                    Possible causes are $::ixErrorInfo"
                                            return $returnList
                                        }
                                        set skip 1
                                        debug "filter config -$ix_mode$ix_option \
                                                [set $hlt_mode$hlt_option]"
                                    }
                                }
                            }
                            if {![info exists skip]} {
                                set value $value_array([set $hlt_mode$hlt_option])
                                if {[catch  {filter config -$ix_mode$ix_option \
                                                $value} retError]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Error when \
                                            filter config -$ix_mode$ix_option \
                                            $value.\n\
                                            Possible causes are $::ixErrorInfo"
                                    return $returnList
                                }
                                debug "filter config -$ix_mode$ix_option $value"
                            } else  {
                                unset skip
                            }
                        }
                    }
                }
            }
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
}


proc ::ixia::set_frame_keys {port_h start end format filename returnList} {
    
    # Export the capture buffer to a file or set the frame keys
    set filename $filename.$format
    set filename [file normalize $filename]
    if {$format == "none"} {
        debug "Do not export capture."
        keylset returnList status $::SUCCESS
        
    } elseif {$format != "var"} {
        debug "captureBuffer export $filename"
        if {[catch  {captureBuffer export $filename} retError]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error when \"captureBuffer \
                    export $filename \" \n Returned: $retError"
            return $returnList
        }
        
        if {[isUNIX]} {
            set tmp_file [file tail $filename]
            if {![info exists ::ixTclSvrHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Not connected to TclServer."
                return $returnList
            }
            if {[catch {eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \{file delete $tmp_file\}} retError]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to delete file $tmp_file. Permission denied."
                return $returnList                
            }
            
        }   

    } else {
        
        set base_key $port_h.frame
        foreach {chassis card port} [split $port_h /] {}
        
        set frame_keys_list [list                     \
                fir                fir                \
                latency            latency            \
                length             length             \
                time_stamp         timestamp          \
                frame              frame              \
                ]
        
        array set status_array [list                  \
                 0 capNoErrors                        \
                 1 capBadCrcGig                       \
                 2 capSymbolErrorsGig                 \
                 3 capBadCrcAndSymbolGig              \
                 4 capUndersizeGig                    \
                 5 capBadCrcAndUndersizeGig           \
                 7 capBadCrcAndSymbolAndUndersizeGig  \
                 8 capOversizeGig                     \
                41 capBadCrc                          \
                43 capBadCrcAndSymbolError            \
                44 capUndersize                       \
                45 capFragment                        \
                48 capOversize                        \
                49 capOversizeAndBadCrc               \
                50 capDribble                         \
                51 capAlignmentError                  \
                53 capAlignAndSymbolError             \
                C0 capGoodFrame                       \
                C1 capBadCrcAndGoodFrame              \
                FF capErrorFrame                      \
                ]
        
        if {[::ixia::portSupports $chassis $card $port pos] == "oc48"} {
            array set status_array_card [list             \
                    40000000 capOc48Trigger               \
                    80000000 capOc48GoodPacket            \
                    80000001 capOc48TruncatedPacket       \
                    80000008 capOc48IntegritySignatureMatch \
                    80000010 capOc48BadIntegrityCheck     \
                    80000020 capOc48BadTCPUDPChecksum     \
                    80000040 capOc48BadIPChecksum         \
                    80000080 capOc48BadCrc                \
                    ]
        } elseif {[::ixia::portSupports $chassis $card $port atm]} {
            array set status_array_card [list             \
                    40000000 capAtmTrigger                \
                    80000000 capAtmGoodPacket             \
                    80000001 capAtmOversize               \
                    80000002 capAtmTimeout                \
                    80000004 capAtmAal5BadCrc             \
                    80000008 capAtmIntegritySignatureMatch \
                    80000010 capAtmBadIntegrityCheck      \
                    80000020 capAtmBadTCPUDPChecksum      \
                    80000040 capAtmBadIPChecksum          \
                    80000080 capAtmEthernetBadCrc         \
            ]
        } else {
            array set status_array_card [list             \
                    40000000 cap10100DpmTrigger           \
                    80000000 cap10100DpmGoodPacket        \
                    80000001 cap10100DpmOversize          \
                    80000002 cap10100DpmUndersize         \
                    80000008 cap10100DpmIntegritySignatureMatch \
                    80000010 cap10100DpmBadIntegrityCheck \
                    80000020 cap10100DpmBadTCPUDPChecksum \
                    80000040 cap10100DpmBadIPChecksum     \
                    80000080 cap10100DpmBadCrc            \
            ]
        }
        
        for {set id $start} {$id <= $end} {incr id} {
            if {([catch  {captureBuffer getframe $id} retError]) && \
                        ($id != 0)} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error when \"captureBuffer \
                        getFrame $id \" \n Returned: $retError"
                return $returnList
            }
            debug "captureBuffer getFrame $id"
            
            set key $base_key.$id
                        
            set key_value [captureBuffer cget -status]
            if {[info exists key_value]} {
                set temp_value [format "%X" $key_value]
                if {![regexp {^0x} $temp_value]} {
                    set temp_value2 "0x${temp_value}"
                } else {
                    set temp_value2 $temp_value
                }
                
                debug "--> $temp_value2"

                if {$temp_value2 <= 0xFF} {
                    set this_key $status_array($temp_value)
                } else {
                    if {![info exists status_array_card($temp_value)]} {
                        set temp_value [format "%X" \
                            [mpexpr 0x$temp_value - 0x40000000]]
                    }
                    set this_key $status_array_card($temp_value)
                }
                
                keylset returnList $key.status $this_key
                debug "captureBuffer cget -status"
            }
            
            foreach {hlt_key ix_key} $frame_keys_list {
                set frame_key $hlt_key
                set key_value [captureBuffer cget -$ix_key]
                if {[info exists key_value]} {
                    keylset returnList $key.$frame_key $key_value
                    debug "captureBuffer cget -$ix_key"
                }
            }
        }
        keylset returnList status $::SUCCESS
    }
    
    return $returnList
}


proc ::ixia::set_aggregate_keys {} {
    uplevel {
        if {!$empty_buffer} {
            # Bring the capture buffer to local memory
            if {[captureBuffer get $chassis $card $port $start \
                        $end]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error returned by captureBuffer \
                        get $chassis $card $port $start $end\
                        \nPossible errors are: No connection chassis, or \
                        invalid port number provided."
                return $returnList
            }
            
            debug "captureBuffer get $chassis $card $port $start \
                    $end"
            
            # Set constraints if any
            foreach  {hlt_constraint ix_constraint} $constraint_list {
                if {[info exists $hlt_constraint]} {
                    set hlt_value [set $hlt_constraint]
                    if {[catch  {captureBuffer config -$ix_constraint \
                                    $hlt_value} retError]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Error when \"captureBuffer \
                                config -$ix_constraint $hlt_value\" \
                                \n Returned: $retError"
                        return $returnList
                    }
                    set isConstraint 1
                    debug "captureBuffer config -$ix_constraint $hlt_value"
                }
            }
            
            if {[info exists isConstraint]} {
                if {[catch  {captureBuffer setConstraint} retError]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error when \"captureBuffer \
                            setConstraint \" \n Returned: $retError"
                    return $returnList
                }
                unset isConstraint
                debug "captureBuffer setConstraint"
            }
            
            
            # Calculate the statistics with respect to constranints
            if {[catch  {captureBuffer getStatistics} retError]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error when \"captureBuffer \
                        getStatistics\" \n Returned: $retError"
                return $returnList
            }
            debug "captureBuffer getStatistics"
        }
#         puts "[captureBuffer cget -latency]"
        # Set the aggregate keys
        
        foreach {hlt_agg_key ix_agg_key} $aggregate_keys_list {
            set aggregate_key $port_h.aggregate.$hlt_agg_key
            catch {unset key_value}
            if {!$empty_buffer} {
                set key_value [captureBuffer cget -$ix_agg_key]
                debug "captureBuffer cget -$ix_agg_key == $key_value"
            }
            if {[info exists key_value]} {
                switch -- $hlt_agg_key {
                    average_deviation {
                        
                        lappend average_deviation_per_chunk $key_value
                        
                        if {![catch {keylget returnList $aggregate_key} \
                                    tempValue]} {
                            set key_value [mpexpr $tempValue + $key_value]
                            incr average_deviation_counter
                        } else {
                            set average_deviation_counter 1
                        }
                    }
                    average_latency {
                        if {![catch {keylget returnList $aggregate_key} \
                                    tempValue]} {
                            set key_value [mpexpr $tempValue + $key_value]
                            
                            incr average_latency_counter
                        } else {
                            set average_latency_counter 1
                        }
                    }
                    num_frames {
                        if {![catch {keylget returnList $aggregate_key} \
                                    tempValue]} {
                            set key_value [mpexpr $tempValue + $key_value]
                        }
                    }
                    standard_deviation {
                        
                        lappend standard_deviation_per_chunk $key_value
                        
                        if {![catch {keylget returnList $aggregate_key} \
                                    tempValue]} {
                            set key_value [mpexpr $tempValue + $key_value]
                            incr standard_deviation_counter
                        } else {
                            set standard_deviation_counter 1
                        }
                    }
                    max_latency {
                        if {![catch {keylget returnList $aggregate_key} \
                                    tempValue]} {
                            if {$key_value < $tempValue} {
                                set key_value $tempValue
                            }
                        }
                    }
                    min_latency {
                        if {![catch {keylget returnList $aggregate_key} \
                                    tempValue]} {
                            if {$key_value > $tempValue} {
                                set key_value $tempValue
                            }
                        }
                    }
                }
                keylset returnList $aggregate_key $key_value
            } else {
                keylset returnList $aggregate_key "N/A"
            }
        }
        
        debug "returnList == $returnList"
    }
}


proc ::ixia::add_atm_filter {args} {
    variable atm_filters_array
    
    set args [lindex $args 0]
    set mandatory_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    set opt_args {
        -mode                   CHOICES create addAtmFilter
                                DEFAULT create        
        -gfp_bad_fcs_error      CHOICES 0 1
        -gfp_eHec_error         CHOICES 0 1
        -gfp_payload_crc        CHOICES 0 1
        -gfp_tHec_error         CHOICES 0 1
        -DA1                    ANY
        -DA2                    ANY
        -DA_mask1               ANY
        -DA_mask2               ANY
        -gfp_error_condition    CHOICES 0 1
        -match_type1            ANY
        -match_type2            ANY
        -pattern1               HEX
        -pattern2               HEX
        -pattern_atm            HEX
                                DEFAULT {00}
        -pattern_mask1          HEX
        -pattern_mask2          HEX
        -pattern_mask_atm       HEX
                                DEFAULT {FF}
        -pattern_offset1        NUMERIC
        -pattern_offset2        NUMERIC
        -pattern_offset_atm     NUMERIC
                                DEFAULT 0
        -pattern_offset_type1   CHOICES startOfFrame	startOfIp
                                CHOICES startOfProtocol startOfSonet
        -pattern_offset_type2   CHOICES startOfFrame	startOfIp
                                CHOICES startOfProtocol startOfSonet
        -SA1                    ANY
        -SA2                    ANY
        -SA_mask1               ANY
        -SA_mask2               ANY
        -vpi                    RANGE   1-4096
                                DEFAULT 1
        -vpi_count              RANGE   1-4096
                                DEFAULT 1
        -vpi_step               RANGE   1-4096
                                DEFAULT 1
        -vci                    RANGE   1-65535
                                DEFAULT 1
        -vci_count              RANGE   1-65535
                                DEFAULT 1
        -vci_step               RANGE   1-65535
                                DEFAULT 1
        -no_write
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args \
                    $opt_args -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }

    set procName [lindex [info level [info level]] 0]
    
    set comparisonData [list                                \
        00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  \
        00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  \
        00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  \
        00 00 00 00 00 00 00 00 00 00 00 00 00              \
        ]
        
    set comparisonMask [list                                \
        FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  \
        FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  \
        FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  \
        FF FF FF FF FF FF FF FF FF FF FF FF FF              \
        ]
    
    if {[mpexpr [llength $pattern_atm] + $pattern_offset_atm] > [llength \
            $comparisonData]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error in $procName! When pattern_atm starts \
                   at offset $pattern_offset_atm it is longer than [llength \
                   $comparisonData]"
        return $returnList
    }
    
    if {[mpexpr [llength $pattern_mask_atm] + $pattern_offset_atm] > [llength \
            $comparisonData]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error in $procName! When pattern_mask_atm starts \
                   at offset $pattern_offset_atm it is longer than [llength \
                   $comparisonData]"
        return $returnList
    }
    
    set offset $pattern_offset_atm
    foreach byte $pattern_atm {
        set comparisonData [lreplace $comparisonData $offset $offset $byte]
        incr offset
    }
    set offset $pattern_offset_atm
    foreach byte $pattern_mask_atm {
        set comparisonMask [lreplace $comparisonMask $offset $offset $byte]
        incr offset
    } 
    
    if {$vpi_count == 1} {
        set vpi_stop $vpi
    } else {
        set vpi_stop [mpexpr $vpi_count * $vpi_step + $vpi - $vpi_step]
    }
    
    if {$vci_count == 1} {
        set vci_stop $vci
    } else {
        set vci_stop [mpexpr $vci_count * $vci_step + $vci - $vci_step]
    }
    
    set handle_array ""
    foreach port_h $port_handle {
        foreach {chassis card port} [split $port_h /] {}
        if {![port isValidFeature $chassis $card $port portFeatureAtm]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error in $procName! Port $port_h does \
                        not support portFeatureAtm"
            return $returnList
        }
        atmFilter setDefault
        debug "atmFilter setDefault"
        
        atmFilter config -comparisonData $comparisonData
        debug "atmFilter config -comparisonData $comparisonData"
        
        atmFilter config -comparisonMask $comparisonMask
        debug "atmFilter config -comparisonMask $comparisonMask"
        
        for {set vpi_start $vpi} {$vpi_start <= $vpi_stop} {incr vpi_start \
                $vpi_step} {
            for {set vci_start $vci} {$vci_start <= $vci_stop} {incr \
                    vci_start $vci_step} {
                if {[atmFilter set $chassis $card $port $vpi_start $vci_start]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error in $procName when atmFilter \
                        set $chassis $card $port $vpi_start $vci_start"
                    return $returnList
                }
                debug "atmFilter set $chassis $card $port $vpi_start $vci_start"
                set handle atm$chassis$card$port$vpi_start$vci_start
                keylset ::ixia::atm_filters_array($handle) vpi $vpi_start
                keylset ::ixia::atm_filters_array($handle) vci $vci_start
                keylset ::ixia::atm_filters_array($handle) port $port_h
                if {[lsearch $handle_array $handle] == -1} {
                    lappend handle_array $handle
                }
            }
        }
    }
    keylset returnList status $::SUCCESS
    keylset returnList handle $handle_array
    return $returnList
}


proc ::ixia::add_atm_triggers {args} {
    variable atm_filters_array
    
    set procName [lindex [info level [info level]] 0]
    
    set args [lindex $args 0]
    set opt_args {
        -mode                           CHOICES create addAtmTrigger
                                        DEFAULT create
        -port_handle                    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$    
        -handle                         ANY
        -async_trigger1                 CHOICES 0 1
        -async_trigger1_SA              CHOICES any SA1 notSA1 SA2 notSA2
        -async_trigger1_DA              CHOICES any DA1 notDA1 DA2 notDA2
        -async_trigger1_error           ANY
        -async_trigger1_framesize       CHOICES 0 1
        -async_trigger1_framesize_from  NUMERIC
        -async_trigger1_framesize_to    NUMERIC
        -async_trigger1_pattern         CHOICES any pattern1 notPattern1
                                        CHOICES pattern2 notPattern2
                                        CHOICES pattern1and2
        -async_trigger2                 CHOICES 0 1
        -async_trigger2_SA              CHOICES any SA1 notSA1 SA2 notSA2
        -async_trigger2_DA              CHOICES any DA1 notDA1 DA2 notDA2
        -async_trigger2_error           ANY
        -async_trigger2_framesize       CHOICES 0 1
        -async_trigger2_framesize_from  NUMERIC
        -async_trigger2_framesize_to    NUMERIC
        -async_trigger2_pattern         CHOICES any pattern1 notPattern1
                                        CHOICES pattern2 notPattern2
                                        CHOICES pattern1and2
        -capture_filter                 CHOICES 0 1
                                        DEFAULT 0
        -capture_filter_SA              CHOICES any SA1 notSA1 SA2 notSA2
        -capture_filter_DA              CHOICES any DA1 notDA1 DA2 notDA2
        -capture_filter_error           ANY
        -capture_filter_framesize       CHOICES 0 1
        -capture_filter_framesize_from  NUMERIC
        -capture_filter_framesize_to    NUMERIC
        -capture_filter_pattern         CHOICES any pattern1 notPattern1
                                        CHOICES pattern2 notPattern2
                                        CHOICES pattern1and2 patternAtm
        -capture_trigger                CHOICES 0 1
                                        DEFAULT 0
        -capture_trigger_SA             CHOICES any SA1 notSA1 SA2 notSA2
        -capture_trigger_DA             CHOICES any DA1 notDA1 DA2 notDA2
        -capture_trigger_error          ANY
        -capture_trigger_framesize      CHOICES 0 1
        -capture_trigger_framesize_from NUMERIC
        -capture_trigger_framesize_to   NUMERIC
        -capture_trigger_pattern        CHOICES any pattern1 notPattern1
                                        CHOICES pattern2 notPattern2
                                        CHOICES pattern1and2 patternAtm
        -uds1                           CHOICES 0 1
                                        DEFAULT 0
        -uds1_SA                        CHOICES any SA1 notSA1 SA2 notSA2
        -uds1_DA                        CHOICES any DA1 notDA1 DA2 notDA2
        -uds1_error                     ANY
        -uds1_framesize                 CHOICES 0 1
        -uds1_framesize_from            NUMERIC
        -uds1_framesize_to              NUMERIC
        -uds1_pattern                   CHOICES any pattern1 notPattern1
                                        CHOICES pattern2 notPattern2
                                        CHOICES pattern1and2 patternAtm
        -uds2                           CHOICES 0 1
                                        DEFAULT 0        
        -uds2_SA                        CHOICES any SA1 notSA1 SA2 notSA2
        -uds2_DA                        CHOICES any DA1 notDA1 DA2 notDA2
        -uds2_error                     ANY
        -uds2_framesize                 CHOICES 0 1
        -uds2_framesize_from            NUMERIC
        -uds2_framesize_to              NUMERIC
        -uds2_pattern                   CHOICES any pattern1 notPattern1
                                        CHOICES pattern2 notPattern2
                                        CHOICES pattern1and2 patternAtm
        -no_write
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args \
                    $opt_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    set mode_list [list                     \
            enableFilter    capture_filter  \
            enableTrigger   capture_trigger \
            enableUds1      uds1            \
            enableUds2      uds2            \
        ]
    
    set config_list [list enable]
    
    foreach {ix_param hlt_param} $mode_list {
        if {[info exists ${hlt_param}_pattern] && \
                [set ${hlt_param}_pattern] == "patternAtm"} {
            if {[set $hlt_param] == 1} {
                lappend config_list $ix_param
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Error in $procName. Parameter \
                    $hlt_param must be set to 1 when setting \
                    ${hlt_param}_pattern to patternAtm."
                return $returnList
            }
        }   
    }

    foreach atm_handle $handle {
        set vpi [keylget ::ixia::atm_filters_array($atm_handle) vpi]
        set vci [keylget ::ixia::atm_filters_array($atm_handle) vci]
        set port_h [keylget ::ixia::atm_filters_array($atm_handle) port]
        
        foreach {chassis card port} [split $port_h /] {}
        
        if {[atmFilter get $chassis $card $port $vpi $vci]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error in $procName when \
                atmFilter get $chassis $card $port $vpi $vci"
            return $returnList
        }
        debug "atmFilter get $chassis $card $port $vpi $vci"
        
        foreach config $config_list {
            atmFilter config -$config 1
            debug "atmFilter config -$config 1"
        }
        
        if {[atmFilter set $chassis $card $port $vpi $vci]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error in $procName when \
                atmFilter set $chassis $card $port $vpi $vci"
            return $returnList
        }
        debug "atmFilter set $chassis $card $port $vpi $vci"
    }

    keylset returnList status $::SUCCESS
    return $returnList
}
