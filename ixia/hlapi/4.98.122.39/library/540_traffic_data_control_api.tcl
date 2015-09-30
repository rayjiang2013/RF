proc ::ixia::540trafficFrameSize { args opt_args } {
    
    debug "args == $args"
    debug "opt_args == $opt_args"
    
#     debug "\n1[ixNet getL ::ixNet::OBJ-/traffic/trafficItem:18/configElement:1 stack]"
    keylset returnList status $::SUCCESS
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    # handle must be a high level stream or a config element
    # high level stream: [ixNet getRoot]traffic/trafficItem:3/highLevelStream:1
    # config element: [ixNet getRoot]traffic/trafficItem:3/configElement:1
    
    # This procedure should be called after the stream is configured (all headers are in place)
    # because it calculates the minimum frame size to accomodate the headers
    if {[regexp {^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+/stack} $handle] || \
            [regexp {^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+/stack} $handle]} {
        # Nothing to set
        return $returnList
    }
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "dynamic_framesize"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    if {[keylget ret_val value] == "traffic_item"} {
        set retrieve [540getConfigElementOrHighLevelStream $handle]
        if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
        set handle [keylget retrieve handle]
    }
    
    set dynamic_framesize 0
    if {[keylget ret_val value] == "dynamic_framesize"} {
        set dynamic_framesize 1
        
        if {[info exists length_mode] && $length_mode != "fixed" && $length_mode != "random"} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is 'dynamic_update', length_mode can only be\
                    'fixed' or 'random'."
            return $returnList
        }
    }
    
    if {[info exists l3_length] && ![info exists frame_size]} {
        set ret_val [540IxNetFrameSizeGetLengthL2 $handle]
        if {[keylget ret_val status] != $::SUCCESS} {
            return $ret_val
        }
        set frame_size [mpexpr [keylget ret_val value] + $l3_length]
        
        if {[info exists l3_length_min]} {
            set frame_size_min  [mpexpr [keylget ret_val value] + $l3_length_min]
        }
        if {[info exists l3_length_max]} {
            set frame_size_max  [mpexpr [keylget ret_val value] + $l3_length_max]
        }
        if {[info exists l3_length_step]} {
            set frame_size_step $l3_length_step
        }
    }
    
    if {!$dynamic_framesize} {
    	if {![info exists skip_frame_size_validation]} {
        	set ret_val [540IxNetFrameSizeGetLengthTotal $handle]
        	if {[keylget ret_val status] != $::SUCCESS} {
           	 return $ret_val
        	}
        	set minimum_frame_size [keylget ret_val value]
    	} else {
        	set minimum_frame_size 64
   	 	}
        set framesize_handle   [ixNet getList $handle frameSize]
        
        if {![info exists frame_size]} {
            set frame_size 64
        }
        if {([info exists frame_size] && $frame_size < $minimum_frame_size)} {
			# BUG573872
            set frame_size $minimum_frame_size
        }
    
        set framesize_handle [ixNet getList $handle frameSize]
    } else {
        set framesize_handle $handle
    }
    
    set hlt_ixn_param_map {
        length_mode                     type                    translate
        frame_size                      fixedSize               value
        frame_size_min,increment        incrementFrom           value_choice_pair
        frame_size_max,increment        incrementTo             value_choice_pair
        frame_size_max,random           randomMax               value_choice_pair
        frame_size_min,random           randomMin               value_choice_pair
        frame_size_step,increment       incrementStep           value_choice_pair
        frame_size_distribution         presetDistribution      translate
        frame_size_gauss                quadGaussian            value
        frame_size_imix                 weightedPairs           value
    }
    
    array set hlt_ixn_choices_map {
        length_mode,fixed                   fixed
        length_mode,increment               increment
        length_mode,random                  random
        length_mode,auto                    auto
        length_mode,imix                    weightedPairs
        length_mode,gaussian                quadGaussian
        length_mode,quad                    quadGaussian
        length_mode,distribution            presetDistribution
        frame_size_distribution,cisco       cisco
        frame_size_distribution,imix        imix
        frame_size_distribution,imix_ipsec  ipSecImix
        frame_size_distribution,imix_ipv6   ipV6Imix
        frame_size_distribution,quadmodal   rprQuar
        frame_size_distribution,trimodal    rprTri
        frame_size_distribution,imix_std    standardImix
        frame_size_distribution,imix_tcp    tcpImix
        frame_size_distribution,tolly       tolly
    }
    
    # Imix can be configured with ixos params (l3_imix<1-4>_<size-ratio>) or with frame_size_imix (ixnetwork specific)
    # frame_size_imix has priority
    if {[info exists length_mode] && $length_mode == "imix"} {
        if {![info exists frame_size_imix] || [llength $frame_size_imix] == 0} {
            set frame_size_imix ""
            for {set imix_idx 1} {$imix_idx <=4} {incr imix_idx} {
                if {![info exists l3_imix${imix_idx}_size]} {
                    break
                }
                
                lappend frame_size_imix [set l3_imix${imix_idx}_size]
                
                if {![info exists l3_imix${imix_idx}_ratio]} {
                    lappend frame_size_imix 100
                } else {
                    lappend frame_size_imix [set l3_imix${imix_idx}_ratio]
                }
            }
        } else {
            set tmp_frame_size_imix {}
            foreach frame_size_item $frame_size_imix {
                if {[regexp -- "^(\[0-9\]+)\[: \]{1}(\[0-9\]+)$" $frame_size_item all \
                        nr1 nr2] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid parameter\
                            frame_size_imix. The valid format is represented\
                            through the following regular expression:\
                            ^(\[0-9\]+):(\[0-9\]+)$"
                    return $returnList
                }
                append tmp_frame_size_imix "$nr2 $nr1 "
            }
            
            set frame_size_imix [string trim $tmp_frame_size_imix]
        }
    } else {
        catch {unset frame_size_imix}
    }
    
    # Quad gaussian can be configured with ixos params (l3_gaus<1-4>_<avg,halfbw,weight>)
    # or with frame_size_gauss (ixnetwork specific)
    # frame_size_gauss has priority
    if {[info exists length_mode] && ($length_mode == "gaussian" || $length_mode == "quad")} {
        if {![info exists frame_size_gauss] || [llength $frame_size_gauss] == 0} {
        
            set frame_size_gauss ""
            
            for {set gaus_idx 1} {$gaus_idx <=4} {incr gaus_idx} {
                
                if {![info exists l3_gaus${gaus_idx}_avg] || ![info exists l3_gaus${gaus_idx}_halfbw] || \
                        ![info exists l3_gaus${gaus_idx}_weight]} {
                    
                    break
                }
                
                
                if {([set l3_gaus${gaus_idx}_halfbw] < 0.01) || ([set l3_gaus${gaus_idx}_halfbw] > 30000.00)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The value for\
                            l3_gaus${gaus_idx}_halfbw, [set l3_gaus${gaus_idx}_halfbw], is out of range.  The valid\
                            range is 0.01 <= x <= 30000.00."
                    return $returnList
                }
                
                lappend frame_size_gauss [set l3_gaus${gaus_idx}_avg]
                lappend frame_size_gauss [set l3_gaus${gaus_idx}_halfbw]
                lappend frame_size_gauss [set l3_gaus${gaus_idx}_weight]                        
            }
        } else {
        
            set tmp_frame_size_gauss {}
            foreach frame_gauss_item $frame_size_gauss {
                if {[regexp {^(\d+(?:\.\d+)?):(\d+(?:\.\d+)?):(\d+)$} \
                            $frame_gauss_item all nr1 nr2 nr3] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid parameter\
                            frame_size_gauss. The valid format is represented\
                            through the following regular expression:\
                            {^(\d+(?:\.\d+)?):(\d+(?:\.\d+)?):(\d+)\$}"
                    return $returnList
                }
                append tmp_frame_size_gauss "$nr1 $nr2 $nr3 "
            }
            
            set frame_size_gauss [string trim $tmp_frame_size_gauss]
        }
    } else {
        catch {unset frame_size_gauss}
    }
    
    set ixn_param_list ""
    foreach {hlt_param ixn_param p_type} $hlt_ixn_param_map {
        catch {unset ixn_param_val}
        switch -- $p_type {
            value {
                if {[info exists $hlt_param] && [set $hlt_param] != ""} {
                    set ixn_param_val [set $hlt_param]
                }
            }
            value_choice_pair {
                catch {unset tmp_hlt_p}
                catch {unset tmp_length_mode}
                
                foreach {tmp_hlt_p tmp_length_mode} [split $hlt_param ,] {}
                
                if {![info exists $tmp_hlt_p] || [set $tmp_hlt_p] == ""} {
                    continue
                }
                
                if {[info exists length_mode] && $length_mode != [set tmp_length_mode]} {
                    continue
                }
                
                set ixn_param_val [set $tmp_hlt_p]
            }
            translate {
                if {[info exists $hlt_param] && [set $hlt_param] != ""} {
                    
                    set hlt_param_val [set $hlt_param]
                    
                    if {![info exists hlt_ixn_choices_map($hlt_param,$hlt_param_val)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Choice $hlt_param_val for\
                                parameter $hlt_param is not recognized."
                        return $returnList
                    }
                    
                    set ixn_param_val $hlt_ixn_choices_map($hlt_param,$hlt_param_val)
                }
            }
        }
        
        if {[info exists ixn_param_val]} {
            if {[llength $ixn_param_val] > 1} {
                append ixn_param_list "-$ixn_param \{$ixn_param_val\} "
            } else {
                append ixn_param_list "-$ixn_param $ixn_param_val "
            }
        }
    }
    
    if {[info exists ixn_param_list] && $ixn_param_list != ""} {
        debug "$ixn_param_list"
        set tmp_status [::ixia::ixNetworkNodeSetAttr  \
                $framesize_handle                     \
                $ixn_param_list                       \
                -commit                               \
            ]
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
    }
    
    return $returnList
}


proc ::ixia::540IxNetFrameSizeGetLengthTotal {handle} {
    
    keylset returnList status $::SUCCESS
    
    set size 0
    foreach stack [ixNet getL $handle stack] {
        foreach field [ixNet getL $stack field] {
            set fieldChoice             [ixNet getA $field -fieldChoice]
            set activeFieldChoice       [ixNet getA $field -activeFieldChoice]
            set optional                [ixNet getA $field -optional]
            set optionalEnabled         [ixNet getA $field -optionalEnabled]
            if {($fieldChoice == "false" && $optional == "false") || \
                    ($fieldChoice == "true"  && $optional == "false" && $activeFieldChoice == "true" ) || \
                    ($fieldChoice == "false" && $optional == "true"  && $optionalEnabled == "true") || \
                    ($fieldChoice == "true"  && $optional == "true"  && $activeFieldChoice == "true" && $optionalEnabled == "true") } {
                incr size [ixNet getA $field -length]
            }
        }
    }
    
    keylset returnList value [mpexpr $size/8]
    return $returnList
}


proc ::ixia::540IxNetFrameSizeGetLengthL2 {handle} {
    
    keylset returnList status $::SUCCESS
    
    set size 0
    foreach stack [ixNet getL $handle stack] {
        
        set ret_val [540IxNetStackGetType $stack]
        debug "==> 540IxNetStackGetType $stack: $ret_val"
        if {[keylget ret_val status] != $::SUCCESS} {
            return $ret_val
        }
        
        set stack_layer [keylget ret_val stack_layer]
        set stack_type  [keylget ret_val stack_type]
        
        if {$stack_layer == "crc" || $stack_layer < 3} {
            foreach field [ixNet getL $stack field] {
            
                set fieldChoice             [ixNet getA $field -fieldChoice]
                set activeFieldChoice       [ixNet getA $field -activeFieldChoice]
                set optional                [ixNet getA $field -optional]
                set optionalEnabled         [ixNet getA $field -optionalEnabled]
                if {($fieldChoice == "false" && $optional == "false") || \
                        ($fieldChoice == "true"  && $optional == "false" && $activeFieldChoice == "true" ) || \
                        ($fieldChoice == "false" && $optional == "true"  && $optionalEnabled == "true") || \
                        ($fieldChoice == "true"  && $optional == "true"  && $activeFieldChoice == "true" && $optionalEnabled == "true") } {
                    incr size [ixNet getA $field -length]
                }
            }
        }
    }
    
    keylset returnList value [mpexpr $size/8]
    return $returnList
}


proc ::ixia::540trafficRateControl {  args opt_args  } {

    debug "args == $args"
    debug "opt_args == $opt_args"
    
    keylset returnList status $::SUCCESS
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "stack_ce" "stack_hls" "dynamic_rate"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    if {[keylget ret_val value] == "stack_ce" || [keylget ret_val value] == "stack_hls"} {
        # Nothing to set
        return $returnList
    }
    
    if {[keylget ret_val value] == "traffic_item"} {
        set retrieve [540getConfigElementOrHighLevelStream $handle]
        if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
        set handle [keylget retrieve handle]
    }
    
    set dynamic_rate 0
    if {[keylget ret_val value] == "dynamic_rate"} {
        set dynamic_rate 1
    }
    
    if {!$dynamic_rate} {
        set traffic_item_obj [ixNetworkGetParentObjref $handle "trafficItem"]
    
        debug "540IxNetTrafficItemGetFirstTxPort $handle"
        set ret_val [540IxNetTrafficItemGetFirstTxPort $handle]
        if {[keylget ret_val status] != $::SUCCESS} {
            return $ret_val
        }
        
        set vport_object [keylget ret_val value]
        set vport_transmit_mode [ixNet getAttribute $vport_object -txMode]

        upvar tx_mode tx_mode
        if {[info exists tx_mode]} {
            switch -- $tx_mode {
                "advanced" {
                    set ti_transmit_mode "interleaved"
                }
                "stream" {
                    set ti_transmit_mode "sequential"
                }
            }
        } else {
            set ti_transmit_mode $vport_transmit_mode
        }

    #                     pause_control_time                      
    #                     inter_frame_gap                         iterationCount
        if {$ti_transmit_mode == "sequential"} {
            set hlt_ixn_param_map {
                    transmit_mode                           type                            translate       none
                    tx_delay_unit                           startDelayUnits                 translate       none
                    tx_delay                                startDelay                      value           none
                    number_of_packets_per_stream            frameCount                      value           none
                    number_of_packets_tx                    frameCount                      value           none
                    burst_loop_count                        repeatBurst                     value           none
                    inter_burst_gap                         interBurstGap                   value           enableInterBurstGap
                    inter_stream_gap                        interStreamGap                  value           enableInterStreamGap
                    pkts_per_burst                          burstPacketCount                value           none
                    min_gap_bytes                           minGapBytes                     value           none
                }

            array set hlt_ixn_choices_map {
                    continuous                   auto
                    random_spaced                auto
                    single_pkt                   custom
                    single_burst                 custom
                    multi_burst                  custom
                    continuous_burst             auto
                    return_to_id                 auto
                    advance                      auto
                    return_to_id_for_count       auto
                    bytes                        bytes
                    ns                           nanoseconds
                }
            
            array set eval_list {
                single_pkt          {{catch {unset pkts_per_burst}} {set pkts_per_burst 1}}
                continuous_burst    {{catch {unset burst_loop_count}} {set burst_loop_count 999}}
                single_burst        {{catch {unset burst_loop_count}} {set burst_loop_count 1}}
            }
            
        } else {
            set hlt_ixn_param_map {
                    transmit_mode                           type                            translate       none
                    tx_delay_unit                           startDelayUnits                 translate       none
                    tx_delay                                startDelay                      value           none
                    pkts_per_burst                          {burstPacketCount frameCount}   value           none
                    number_of_packets_per_stream            frameCount                      value           none
                    number_of_packets_tx                    frameCount                      value           none
                    loop_count                              iterationCount                  value           none
                    burst_loop_count                        iterationCount                  value           none
                    inter_burst_gap                         interBurstGap                   value           enableInterBurstGap
                    inter_stream_gap                        interStreamGap                  value           enableInterStreamGap
                    min_gap_bytes                           minGapBytes                     value           none
                }
            
            array set hlt_ixn_choices_map {
                    continuous                  continuous
                    random_spaced               continuous
                    single_pkt                  fixedFrameCount
                    single_burst                fixedFrameCount
                    multi_burst                 custom
                    continuous_burst            auto
                    return_to_id                continuous
                    advance                     continuous
                    return_to_id_for_count      fixedIterationCount
                    bytes                       bytes
                    ns                          nanoseconds
                }
            
            array set eval_list {
                single_pkt          {{catch {unset pkts_per_burst}} {set pkts_per_burst 1}}
                continuous_burst    {{catch {unset burst_loop_count}} {set burst_loop_count 999}}
                single_burst        {{catch {unset burst_loop_count}} {set burst_loop_count 1}}
            }
        }
    }
    
    if {$dynamic_rate} {
        set rate_object $handle
        set type_arg_name "rateType"
    } else {
        set type_arg_name "type"
        if {[catch {ixNet getList $handle frameRate} rate_object]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error $rate_object. Failed to get frameRate object from $handle."
            return $returnList
        }
    }
    if {[info exists rate_bps]} {
        set rate_args "-$type_arg_name bitsPerSecond -rate $rate_bps -bitRateUnitsType bitsPerSec"
    } elseif {[info exists rate_kbps]} {
        set rate_args "-$type_arg_name bitsPerSecond -rate $rate_kbps -bitRateUnitsType kbitsPerSec"
    } elseif {[info exists rate_mbps]} {
        set rate_args "-$type_arg_name bitsPerSecond -rate $rate_mbps -bitRateUnitsType mbitsPerSec"
    } elseif {[info exists rate_byteps]} {
        set rate_args "-$type_arg_name bitsPerSecond -rate $rate_byteps -bitRateUnitsType bytesPerSec"
    } elseif {[info exists rate_kbyteps]} {
        set rate_args "-$type_arg_name bitsPerSecond -rate $rate_kbyteps -bitRateUnitsType kbytesPerSec"
    } elseif {[info exists rate_mbyteps]} {
        set rate_args "-$type_arg_name bitsPerSecond -rate $rate_mbyteps -bitRateUnitsType mbytesPerSec"
    } elseif {[info exists rate_percent]} {
        set rate_args "-$type_arg_name percentLineRate -rate $rate_percent"
    } elseif {[info exists rate_pps]} {
        set rate_args "-$type_arg_name framesPerSecond -rate $rate_pps"
    } elseif {[info exists inter_frame_gap]} {
        set rate_args "-$type_arg_name interPacketGap -rate $inter_frame_gap"
            if {[info exists inter_frame_gap_unit]} {
                append rate_args " -interPacketGapUnitsType $hlt_ixn_choices_map($inter_frame_gap_unit)"
            }
    }
    
    if {[info exists enforce_min_gap]} {
        append rate_args " -enforceMinimumInterPacketGap $enforce_min_gap"
    }
    
    if {[info exists rate_args] && $rate_args != ""} {
        set tmp_status [::ixia::ixNetworkNodeSetAttr  \
                $rate_object                          \
                $rate_args                            \
                -commit                               \
            ]
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
        
        if {$dynamic_rate} {
            if {[ixNet getA $rate_object -overSubscribed] == "true"} {
                puts "\nWarning: Dynamic rate change for $rate_object caused the transmitting ports to be oversubscribed.\n"
            }
        }
    }
    
    if {!$dynamic_rate} {
        set ixn_args ""
        
        if {[info exists duration]} {
            if {[info exists transmit_mode]} {
                puts "\nWarning: -transmit_mode and -duration arguments were specified.\
                        Argument transmit_mode will be ignored."
                unset transmit_mode
            }
            set ixn_args "-type fixedDuration -duration $duration "
        }
        
        foreach {hlt_p ixn_p p_type enabler} $hlt_ixn_param_map {
            if {[info exists $hlt_p]} {
                
                set hlt_p_val [set $hlt_p]
                
                switch -- $p_type {
                    "translate" {
                        if {![info exists hlt_ixn_choices_map($hlt_p_val)]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error. Parameter choice mapping for\
                                    parameter -$hlt_p '$hlt_p_val' was not found."
                            return $returnList
                        }
                        
                        set ixn_p_val $hlt_ixn_choices_map($hlt_p_val)
                        
                        if {[info exists eval_list($hlt_p_val)]} {
                            foreach eval_cmd $eval_list($hlt_p_val) {
                                if {[catch {eval $eval_cmd} err]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Internal error. Failed to evaluate\
                                            '$eval_cmd' for parameter '$hlt_p' with value '$hlt_p_val'."
                                    return $returnList
                                }
                            }
                        }
                    }
                    "value" {
                        set ixn_p_val $hlt_p_val
                    }
                }
                
                foreach single_ixn_p $ixn_p {
                    append ixn_args "-$single_ixn_p $ixn_p_val "
                }
                if {$enabler != "none"} {
                    append ixn_args "-$enabler true "
                }
            }
        }
        
        if {[info exists ixn_args] && $ixn_args != ""} {
            
            if {[catch {ixNet getList $handle transmissionControl} control_object]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error $control_object. Failed to get transmissionControl object from $handle."
                return $returnList
            }

            set tmp_status [::ixia::ixNetworkNodeSetAttr  \
                    $control_object                       \
                    $ixn_args                             \
                    -commit                               \
                ]
            if {[keylget tmp_status status] != $::SUCCESS} {
                return $tmp_status
            }
        }
        
        # Configure 
        #  -frame_rate_distribution_port       CHOICES apply_to_all split_evenly
        #  -frame_rate_distribution_stream     CHOICES apply_to_all split_evenly
        
        set ret_val [540IxNetValidateObject $handle]
        if {[keylget ret_val status] != $::SUCCESS} {
            return $ret_val
        }
        
        if {[keylget ret_val value] == "config_element"} {
            array set translate_array {
                apply_to_all    applyRateToAll
                split_evenly    splitRateEvenly
            }
            
            if {[info exists mode] && $mode == "create" && ![info exists frame_rate_distribution_port]} {
                set frame_rate_distribution_port split_evenly
            }
            
            set param_map {
                frame_rate_distribution_port        portDistribution
                frame_rate_distribution_stream      streamDistribution
            }
            
            set ixn_args ""
            foreach {hlt_p ixn_p} $param_map {
                if {![info exists $hlt_p]} {
                    continue
                }
                
                lappend ixn_args -$ixn_p $translate_array([set $hlt_p])
            }
            
            if {[llength $ixn_args] > 0} {
                if {[catch {ixNet getList $handle frameRateDistribution} rate_distrib_obj]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error $rate_distrib_obj. Failed to get frameRateDistribution object from $handle."
                    return $returnList
                }
                
                set tmp_status [::ixia::ixNetworkNodeSetAttr  \
                        $rate_distrib_obj                     \
                        $ixn_args                             \
                        -commit                               \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    return $tmp_status
                }
            }
        }
    }
    
    return $returnList
    
}


proc ::ixia::540trafficTracking { args opt_args } {
#     handle - must be a traffic item handle
#     custom_offset
#     custom_values accepts a list of values
#     hosts_per_net
#     track_by
    
    variable egress_tracking_global_array
    
    debug "args == $args"
    debug "opt_args == $opt_args"
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    ## The following will be configured at IP header builder
    # override_value_list
    # enable_override_value
    
    # Array List with track by type hlt-ixn is needed here 
    array set translate_track_by {
            traffic_item                                                                              trackingenabled
            custom_8bit                                                                               customOverride
            custom_16bit                                                                              customOverride
            custom_24bit                                                                              customOverride
            custom_32bit                                                                              customOverride
            trackingenabled                                                                           trackingenabled
            endpoint_pair                                                                             sourceDestEndpointPair
            source_dest_value_pair                                                                    sourceDestValuePair
            source_dest_port_pair                                                                     sourceDestPortPair
            source_endpoint                                                                           sourceEndpoint
            dest_endpoint                                                                             destEndpoint
            source_port                                                                               sourcePort
            dest_port                                                                                 destPort
            traffic_group                                                                             trafficGroup
            dest_mac                                                                                  ethernetIiDestinationaddress
            src_mac                                                                                   ethernetIiSourceaddress
            ethernet_ii_ether_type                                                                    ethernetIiEtherType
            assured_forwarding_phb                                                                    ipv4AssuredForwardingPhb
            ipv4_source_ip                                                                            ipv4SourceIp
            source_ip                                                                                 ipv4SourceIp
            ipv4_dest_ip                                                                              ipv4DestIp
            dest_ip                                                                                   ipv4DestIp
            l2tpv2_data_message_tunnel_id                                                             l2tpv2DataMessageTunnelId
            udp_udp_src_prt                                                                           udpUdpSrcPrt
            udp_udp_dst_prt                                                                           udpUdpDstPrt
            tcp_tcp_src_prt                                                                           tcpTcpSrcPrt
            tcp_tcp_dst_prt                                                                           tcpTcpDstPrt
            ipv6_trafficclass                                                                         ipv6Trafficclass
            class_selector_phb                                                                        ipv6Trafficclass
            ipv6_flowlabel                                                                            ipv6Flowlabel
            ipv6_flow_label                                                                           ipv6Flowlabel
            ipv6_source_ip                                                                            ipv6SourceIp
            ipv6_dest_ip                                                                              ipv6DestIp
            ipv4_precedence                                                                           ipv4Precedence
            mac_in_mac_v42_bdest_address                                                              macInMacV42BDestAddress
            mac_in_mac_v42_bsrc_address                                                               macInMacV42BSrcAddress
            mac_in_mac_v42_btag_pcp                                                                   macInMacV42BtagPcp
            mac_in_mac_v42_vlan_id                                                                    macInMacV42VlanId
            mac_in_mac_v42_priority                                                                   macInMacV42Priority
            mac_in_mac_v42_isid                                                                       macInMacV42ISid
            mac_in_mac_v42_cdest_address                                                              macInMacV42CDestAddress
            mac_in_mac_v42_csrc_address                                                               macInMacV42CSrcAddress
            mac_in_mac_v42_stag_pcp                                                                   macInMacV42STagPcp
            mac_in_mac_v42_stag_vlan_id                                                               macInMacV42STagVlanId
            fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_did                  fipNpivFdiscRequest(enode)FipNpivFdiscDescriptorFibreChannelDId
            fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority      fipNpivFdiscRequest(enode)FipNpivFdiscDescriptorFibreChannelCsCtlPriority
            fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_sid                  fipNpivFdiscRequest(enode)FipNpivFdiscDescriptorFibreChannelSId
            fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_ox_id                fipNpivFdiscRequest(enode)FipNpivFdiscDescriptorFibreChannelOxId
            fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did                     fipNpivFdiscLsRjt(fcf)FipNpivFdiscDescriptorFibreChannelDId
            fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority         fipNpivFdiscLsRjt(fcf)FipNpivFdiscDescriptorFibreChannelCsCtlPriority
            fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid                     fipNpivFdiscLsRjt(fcf)FipNpivFdiscDescriptorFibreChannelSId
            fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id                   fipNpivFdiscLsRjt(fcf)FipNpivFdiscDescriptorFibreChannelOxId
            fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did                     fipNpivFdiscLsAcc(fcf)FipNpivFdiscDescriptorFibreChannelDId
            fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority         fipNpivFdiscLsAcc(fcf)FipNpivFdiscDescriptorFibreChannelCsCtlPriority
            fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid                     fipNpivFdiscLsAcc(fcf)FipNpivFdiscDescriptorFibreChannelSId
            fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id                   fipNpivFdiscLsAcc(fcf)FipNpivFdiscDescriptorFibreChannelOxId
            fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_did                            fipFlogiRequest(enode)FipFlogiDescriptorFibreChannelDId
            fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_cs_ctl_priority                fipFlogiRequest(enode)FipFlogiDescriptorFibreChannelCsCtlPriority
            fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_sid                            fipFlogiRequest(enode)FipFlogiDescriptorFibreChannelSId
            fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_ox_id                          fipFlogiRequest(enode)FipFlogiDescriptorFibreChannelOxId
            fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_did                               fipFlogiLsRjt(fcf)FipFlogiDescriptorFibreChannelDId
            fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority                   fipFlogiLsRjt(fcf)FipFlogiDescriptorFibreChannelCsCtlPriority
            fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_sid                               fipFlogiLsRjt(fcf)FipFlogiDescriptorFibreChannelSId
            fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_ox_id                             fipFlogiLsRjt(fcf)FipFlogiDescriptorFibreChannelOxId
            fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_did                               fipFlogiLsAcc(fcf)FipFlogiDescriptorFibreChannelDId
            fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority                   fipFlogiLsAcc(fcf)FipFlogiDescriptorFibreChannelCsCtlPriority
            fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_sid                               fipFlogiLsAcc(fcf)FipFlogiDescriptorFibreChannelSId
            fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_ox_id                             fipFlogiLsAcc(fcf)FipFlogiDescriptorFibreChannelOxId
            fcoe_dest_id                                                                              fcoeDestId
            fcoe_cs_ctl                                                                               fcoeCsCtl
            fcoe_src_id                                                                               fcoeSrcId
            fcoe_ox_id                                                                                fcoeOxId
            vlan_vlan_user_priority                                                                   vlanVlanUserPriority
            inner_vlan                                                                                vlanVlanId
            pppoe_session_sessionid                                                                   pppoeSessionSessionid
            mpls_label                                                                                mplsMplsLabelValue
            mpls_mpls_exp                                                                             mplsMplsExp
            mpls_flow_descriptor                                                                      mplsFlowDescriptor
            b_dest_mac                                                                                macInMacBDestAddress
            b_src_mac                                                                                 macInMacBSrcAddress
            b_vlan_user_priority                                                                      macInMacVlanUserPriority
            b_vlan                                                                                    macInMacVlanId
            mac_in_mac_priority                                                                       macInMacPriority
            i_tag_isid                                                                                macInMacISid
            mac_in_mac_ether_type_i_tag                                                               macInMacEtherTypeItag
            c_dest_mac                                                                                macInMacCDestAddress
            c_src_mac                                                                                 macInMacCSrcAddress
            s_vlan_user_priority                                                                      macInMacVlanUserPriority1
            s_vlan                                                                                    macInMacVlanId1
            c_vlan_user_priority                                                                      macInMacVlanUserPriority2
            c_vlan                                                                                    macInMacVlanId2
            dlci                                                                                      frameRelayDlciHighOrderBits
            frame_relay_dlci_high_order_bits                                                          frameRelayDlciHighOrderBits
            frame_relay_dlci_low_order_bits                                                           frameRelayDlciLowOrderBits
            ethernet_ii_pfc_queue                                                                     ethernetIiPfcQueue
            cisco_frame_relay_dlci_high_order_bits                                                    ciscoFrameRelayDlciHighOrderBits
            cisco_frame_relay_dlci_low_order_bits                                                     ciscoFrameRelayDlciLowOrderBits
            tos                                                                                       ipv4Precedence
            assured_forwarding_phb                                                                    ipv4AssuredForwardingPhb
            class_selector_phb                                                                        ipv4ClassSelectorPhb
            default_phb                                                                               ipv4DefaultPhb
            expedited_forwarding_phb                                                                  ipv4ExpeditedForwardingPhb
            raw_priority                                                                              ipv4Raw
        }
    
    array set translate_protocol_offset {
            
        }
    
    keylset returnList status $::SUCCESS
    
    set traffic_item_objref [ixNetworkGetParentObjref $handle "trafficItem"]
    
    set ret_val [540IxNetValidateObject $traffic_item_objref [list "traffic_item"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
#     if {[keylget ret_val value] == "stack_ce" || [keylget ret_val value] == "stack_hls"} {
#         set traffic_item_objref [ixNetworkGetParentObjref $handle "trafficItem"]
#     } elseif {[keylget ret_val value] == "config_element" || [keylget ret_val value] == "high_level_stream"} {
#         set traffic_item_objref [ixNetworkGetParentObjref $handle "trafficItem"]
#     } else {
#         set traffic_item_objref $handle
#     }
    
    set track_by_list ""
    
    if {[info exists track_by]} {
    
        lappend track_by_list trackingenabled
    
        # Make sure list of track by is unique
        foreach track_by_tmp $track_by {
            if {[lsearch $track_by_list $track_by_tmp] == -1} {
                lappend track_by_list $track_by_tmp
            }
        }
        set track_by ""
    }
    
    if {[catch {ixNet getAttribute ${traffic_item_objref}/tracking -trackBy} current_tracking]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get current tracking information from traffic item\
                ${traffic_item_objref}. Possible reason is: traffic item does not exist anymore."
        return $returnList
    }
    
    # Configure tracking mode.
    set available_tracking [ixNet getAttribute \
            ${traffic_item_objref}/tracking -availableTrackBy]
    
    set traffic_tracking_args [list]
    # customOverride must be the last item in -trackBy
    set custom_override_flag 0
    set ix [lsearch -exact $current_tracking "customOverride"]
    if {$ix>=0} {
        set current_tracking [lreplace $current_tracking $ix $ix]
        set custom_override_flag 1
    }
    
    foreach track_by $track_by_list {
        if {$track_by == "none"} {
            # Commit the traffic setup.
            set disable_trk 1
            set current_tracking ""
            break
        } else {
            if {[info exists translate_track_by($track_by)]} {
                if {[lsearch $available_tracking \
                        $translate_track_by($track_by)] == -1} {
                    
                    if {[lsearch $available_tracking \
                            "$translate_track_by($track_by)0"] == -1} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The -track_by argument does not\
                                contain a valid value for the configured traffic\
                                circuit."
                        return $returnList
                    } else {
                        # The '0' at the end is not a typo. It's signifies the first header for which this
                        # tracking is valid
                        set ixn_track_by "$translate_track_by($track_by)0"
                    }
                } else {
                    set ixn_track_by $translate_track_by($track_by)
                }
            } elseif {[lsearch $available_tracking $track_by] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "The -track_by argument $track_by \
                        is not a valid value for the configured traffic\
                        circuit."
                return $returnList
            } else {
                set ixn_track_by $track_by
            }
            if {[lsearch $current_tracking $ixn_track_by] == -1} {
                if {($ixn_track_by == "customOverride")} {
                    set custom_override_flag 1
                } else {
                    lappend current_tracking $ixn_track_by
                }
            }
            if {[regexp {custom_} $track_by]} {
                set enable_override_value 1
                
                if {[info exists custom_protocol_offset]} {
                    lappend traffic_tracking_args -protocolOffset $translate_protocol_offset($custom_protocol_offset)
                }
                
                if {[info exists custom_offset]} {
                    lappend traffic_tracking_args -offset $custom_offset
                }
                
                if {[info exists custom_values]} {
                    set custom_vales_hex ""
                    foreach custom_vales_elem $custom_values {
                        lappend custom_vales_hex [format "0x%x" $custom_vales_elem]
                    }
                    lappend traffic_tracking_args -values $custom_vales_hex
                }
                array set custom_override_map {
                    custom_8bit     eightBits
                    custom_16bit    sixteenBits
                    custom_24bit    twentyFourBits
                    custom_32bit    thirtyTwoBits
                }
                if {[info exists custom_override_map($track_by)]} {
                    lappend traffic_tracking_args -fieldWidth $custom_override_map($track_by)
                }
            }
        }
    }

    if {$custom_override_flag && ![info exists disable_trk]} {
        lappend current_tracking "customOverride"
    }
    if {[llength $current_tracking] > 0 || ([info exists disable_trk] && $disable_trk)} {
        # Configure tracking parameters.
        lappend traffic_tracking_args -trackBy $current_tracking
        # Commit the traffic setup.
        set retCode [ixNetworkNodeSetAttr ${traffic_item_objref}/tracking \
                $traffic_tracking_args -commit]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
    }
    
    if {$mode == "create" && ![info exists egress_tracking]} {
        
        set ret_code [540trafficGetRxPortsForTi $traffic_item_objref]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set ti_rx_port_list [keylget ret_code ret_val]
        
        foreach ti_rx_port $ti_rx_port_list {
            if {[info exists egress_tracking_global_array($ti_rx_port)]} {
                set keyed_params $egress_tracking_global_array($ti_rx_port)
                foreach key_param_name [keylkeys keyed_params] {
                    set $key_param_name [keylget keyed_params $key_param_name]
                }
                break
            }
        }
    }
    
    if {[info exists egress_tracking]} {
        set enabled "false"
        set egressTrackingCount 0;# the number of egressTracking elements to be added
        set index 0;# used to select the proper egress_custom_width and egress_custom_offset element
        set egressIndex 0;# used to select the corresponding egressTracking element
        
        # create empty egress_tracking_encap list if it doesn't exist
        if {![info exists egress_tracking_encap]} {
            set egress_tracking_encap [list]
        }
        
        # determine if $egress_tracking contains at least one element different from "none"
        foreach egress_tracking_el $egress_tracking {
            if { $egress_tracking_el != "none" } {
                set enabled "true"
                incr egressTrackingCount
            }
        }
        
        set retCode [ixNetworkNodeSetAttr ${traffic_item_objref}/tracking/egress \
                [list -enabled $enabled] \
                -commit]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
        
        # removing all configured egressTracking elements, except the first one
        set availableEgressItems [ixNetworkGetList ${traffic_item_objref} egressTracking]
        if {[ixNet getAttr $traffic_item_objref -egressEnabled] == "false" && $enabled == "false"} {
            # do nothing, we don't need to change any settings for egress tracking, because it is disabled
        } else {
            foreach egressItem $availableEgressItems {
                set ret_code [ixNetworkEvalCmd [list ixNet remove ${egressItem}] "ok"]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
            }
            
            set ret_code [ixNetworkEvalCmd ixNetworkCommit "ok"]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            # some egressTracking elements may already exist in the traffic_item_objref
            incr egressTrackingCount -[llength [ixNetworkGetList ${traffic_item_objref} egressTracking]]
            
            set egressItems [ixNetworkGetList ${traffic_item_objref} egressTracking]
            
            # get all valid fieldOffsets for egress tracking
            set availableFieldOffsets [540trafficGetEgressTrackingFieldOffsets $traffic_item_objref]
            
            foreach egress_tracking_item $egress_tracking {
                # The first egress tracking item will always exist
                # Currently the maximum allowed is two, so if the script tries to configure
                # more than that it will fail
                if {$egressIndex != 0 && $egress_tracking_item != "none"} {
                    set ret_code [ixNetworkNodeAdd ${traffic_item_objref} egressTracking]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    set new_egress_item [keylget ret_code node_objref]
                    
                    lappend egressItems $new_egress_item

                    set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                }
            
                if  {$egress_tracking_item  != "none"} {
                    # enable the first egress tracking field offset by default
                    set egress_custom_field_offset_item "NA"
                    set egressItem [lindex $egressItems $egressIndex]

                    if {$egress_tracking_item  == "custom" || $egress_tracking_item == "custom_by_field"} {
                        set tracking_encap          "Any: Use Custom Settings"
                        
                        # Get the corresponding element from the custom_offsets
                        if {![info exists egress_custom_offset] || $index >= [llength $egress_custom_offset]} {
                                set egress_custom_offset_item 0
                        } else {
                            set egress_custom_offset_item [lindex $egress_custom_offset $index]
                        }
                        
                        if {![info exists egress_custom_width] || $index >= [llength $egress_custom_width]} {
                            set egress_custom_width_item 0
                        } else {
                            set egress_custom_width_item [lindex $egress_custom_width $index]
                        }
                        
                        array set translate_offset {
                            custom              {Custom}
                            custom_by_field     {CustomByField}
                        }

                        # If egress_tracking_item cannot be found in the translate_offset array, set it to custom
                        if {![info exists translate_offset($egress_tracking_item)]} {
                            set egress_tracking_item "custom"
                        } 
                        
                        set tracking_predef_offset $translate_offset($egress_tracking_item)
                        switch $egress_tracking_item {
                            "custom" {
                                # The custom_offset and custom_width must be numeric
                                if {$egress_custom_offset_item == "NA"} {
                                    set egress_custom_offset_item 0
                                }
                                if {$egress_custom_width_item == "NA"} {
                                    set egress_custom_width_item 0
                                }
                            }
                            "custom_by_field" {
                                # The custom_offset and custom_width will not be used, so set their values to 0
                                set egress_custom_offset_item 0
                                set egress_custom_width_item 
                                
                                if {[info exists egress_custom_field_offset] && $index < [llength $egress_custom_field_offset]} {
                                    set fieldOffset [lindex $egress_custom_field_offset $index]; #the field offset corresponding to the egress element
                                    # the fieldOffset provided could be NA, if the user doesn't want to configure the egress tracking field offset
                                    if {$fieldOffset != "NA"} {
                                        # check if the provided fieldOffset is valid
                                        if {[lsearch $availableFieldOffsets $fieldOffset] == -1} {
                                            keylset ret_val status $::FAILURE
                                            keylset ret_val log "Error: the $egress_custom_field_offset $fieldOffset is not valid for the \
                                                $traffic_item_objref traffic item. Available valid options are $availableFieldOffsets"
                                            return $ret_val
                                        }
                                        
                                        set egress_custom_field_offset_item $fieldOffset
                                    }
                                }
                                
                                if {$egress_custom_field_offset_item == "NA"} {
                                    set egress_custom_field_offset_item [lindex $availableFieldOffsets 0]
                                }
                            }
                        }

                        set egress_trk_pmap0 {
                            tracking_encap                       encapsulation
                        }
                        
                        set egress_trk_pmap1 {
                            tracking_predef_offset               offset
                            egress_custom_offset_item            customOffsetBits
                            egress_custom_width_item             customWidthBits
                        }
                        
                    } else {
                        # Get the traffic item corresponding to the handle variable
                        set tiObjRef [ixNetworkGetParentObjref $handle "trafficItem"]
                        set ret_code [540trafficGetRxPortsForTi $tiObjRef] ;# Get all rx ports
                        
                        if {[keylget ret_code status] != $::SUCCESS} {
                            return $ret_code
                        }
                        
                        # Check if there is at least one rx port for the traffic item
                        if {[llength [keylget ret_code ret_val]] == 0} {
                            puts "WARNING: Cannot determine port mode and encapsulation for $tiObjRef. \
									This can happen if traffic destination is multicast.\
									Assumming Rx port is ethernet type."
							set intf_type ethernet
                        } else {
                        set vport_obj_ref [lindex [keylget ret_code ret_val] 0]
                        set intf_type [ixNet getA $vport_obj_ref -type]
                        }
                        # determine port mode and encapsulation
                        switch -- $intf_type {
                            "atm" {
                                if {$index >= [llength $egress_tracking_encap]} {
                                    set tracking_encap LLCRoutedCLIP
                                } else {
                                    set tracking_encap [lindex $egress_tracking_encap $index]
                                }
                            }
                            "pos" {
                                if {$index >= [llength $egress_tracking_encap]} {
                                    set tracking_encap "pos_hdlc"
                                } else {
                                    set tracking_encap [lindex $egress_tracking_encap $index]
                                }
                            }
                            default {
                                if {$index >= [llength $egress_tracking_encap]} {
                                    set tracking_encap "ethernet"
                                } else {
                                    set tracking_encap [lindex $egress_tracking_encap $index]
                                }
                            }
                        }
                        
                        array set translate_encap {
                            LLCRoutedCLIP               {LLC/Snap Routed Protocol}
                            LLCPPPoA                    {LLC Encapsulated PPP}
                            LLCBridgedEthernetFCS       {LLC Bridged Ethernet/802.3}
                            LLCBridgedEthernetNoFCS     {LLC Bridged Ethernet/802.3 no FCS}
                            VccMuxPPPoA                 {VC Multiplexed PPP}
                            VccMuxIPV4Routed            {VC Mux Routed Protocol}
                            VccMuxBridgedEthernetFCS    {VC Mux Bridged Ethernet/802.3}
                            VccMuxBridgedEthernetNoFCS  {VC Mux Bridged Ethernet/802.3 no FCS}
                            ethernet                    {Ethernet}
                            pos_ppp                     {PPP}
                            pos_hdlc                    {CISCO HDLC}
                            frame_relay1490             {Frame Relay}
                            frame_relay2427             {Frame Relay}
                            frame_relay_cisco           {Cisco Frame Relay}
                        }
                        
                        set tracking_encap $translate_encap($tracking_encap)
                        if {[lsearch [ixNet getA ${traffic_item_objref}/tracking/egress -availableEncapsulations] $tracking_encap] == -1} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to configure Egress tracking with $tracking_encap.\
                                    Traffic item $traffic_item_objref does not support egress tracking using this encapsulation."
                            return $returnList
                        }
                        
                        array set translate_offset {    
                            outer_vlan_priority         {Outer VLAN Priority (3 bits)}
                            outer_vlan_id_4             {Outer VLAN ID (4 bits)}
                            outer_vlan_id_6             {Outer VLAN ID (6 bits)}
                            outer_vlan_id_8             {Outer VLAN ID (8 bits)}
                            outer_vlan_id_10            {Outer VLAN ID (10 bits)}
                            outer_vlan_id_12            {Outer VLAN ID (12 bits)}
                            inner_vlan_priority         {Inner VLAN Priority (3 bits)}
                            inner_vlan_id_4             {Inner VLAN ID (4 bits)}
                            inner_vlan_id_6             {Inner VLAN ID (6 bits)}
                            inner_vlan_id_8             {Inner VLAN ID (8 bits)}
                            inner_vlan_id_10            {Inner VLAN ID (10 bits)}
                            inner_vlan_id_12            {Inner VLAN ID (12 bits)}
                            mplsExp                     {MPLS Exp (3 bits)}
                            tos_precedence              {IPv4 TOS Precedence (3 bits)}
                            dscp                        {IPv4 DSCP (6 bits)}
                            ipv6TC                      {IPv6 Traffic Class (8 bits)}
                            ipv6TC_bits_0_2             {IPv6 Traffic Class Bits 0-2 (3 bits)}
                            ipv6TC_bits_0_5             {IPv6 Traffic Class Bits 0-5 (6 bits) }
                            vnTag_direction_bit         {VNTag Direction Bit (1 bit)}
                            vnTag_pointer_bit           {VNTag Pointer Bit (1 bit)}
                            vnTag_looped_bit            {VNTag Looped Bit (1 bit)}
                        }
                        
                        if {![info exists translate_offset($egress_tracking_item)]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to configure Egress tracking with the \"$egress_tracking_item\" offset.\
                                    Traffic item $traffic_item_objref  does not support this offset for the \"$egress_tracking_encap_item\" encapsulation." 
                            return $returnList
                        }
                        
                        set tracking_predef_offset $translate_offset($egress_tracking_item)
                        if {[lsearch [ixNet getA $egressItem -availableOffsets] $tracking_predef_offset] == -1} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to configure Egress tracking with $tracking_predef_offset.\
                                    Traffic item $traffic_item_objref does not support egress tracking using this predefined offset."
                            return $returnList
                        }
                        
                        set egress_trk_pmap0 {
                            tracking_encap              encapsulation
                        }
                        
                        set egress_trk_pmap1 {
                            tracking_predef_offset      offset
                        }
                    }
               
                    # modify the current egress_tracking_item
                    foreach egress_trk_pmap [list egress_trk_pmap0 egress_trk_pmap1] {
                        foreach {hlt_p ixn_p} [set $egress_trk_pmap] {
                        
                            if {[info exists $hlt_p]} {
                                set hlt_p_val [set $hlt_p]
                                if {$hlt_p == "pgid_split1_offset"} {
                                    set $hlt_p [mpexpr $hlt_p_val * 8]
                                }
                                
                                set retCode [ixNetworkNodeSetAttr $egressItem \
                                        [list -$ixn_p $hlt_p_val] ]
                                if {[keylget retCode status] != $::SUCCESS} {
                                    return $retCode
                                }
                            }
                        }
                    }
                    
                    # enable the egress tracking field offset if available
                    if {$egress_custom_field_offset_item != "NA"} {
                        set retCode [ixNetworkNodeSetAttr $egressItem/$egress_custom_field_offset_item \
                                [list -trackingEnabled "true"] ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            return $retCode
                        }
                    }
                    
                    incr egressIndex
                }; #end if
                incr index
            }; #end foreach

            set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
            
            if {[keylget ret_code status] != $::SUCCESS} {
                # Changing the error message returned by ixNetwork in case of misconfiguring
                # the egress_tracking and egress_tracking_encap parameters
                set errorMessage {Low level call 'ixNet commit' returned: ::ixNet::ERROR-5500-Not supported,Invalid offset. Use availableOffsets attribute in order to get available offsets..}
                set newError "One or multiple egress tracking elements of \"$egress_tracking\" are not available for the given egress tracking encapsulations \"$egress_tracking_encap\". $errorMessage"
                set log [keylget ret_code log] ;# the genuine error
                regsub $errorMessage $log $newError log

                keylset ret_code log $log
                return $ret_code
            }
        }
    }
    
    if {[info exists hosts_per_net]} {
        set retCode [ixNetworkNodeSetAttr ${traffic_item_objref} \
                [list -hostsPerNetwork $hosts_per_net] \
                -commit]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
    }
    
    if {[info exists latency_bins_enable] && $latency_bins_enable == 1} {
        
        if {[info exists latency_values]} { 
            # Configure latency bins
            # Verify if latency, jitter or delay measurement is enabled
            
            set ret_code [ixNetworkEvalCmd [list ixNet getL [ixNet getRoot]traffic statistics]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set statistics_global_obj [keylget ret_code ret_val]
            
            set init_objects {
                delay_variation_global_obj      delayVariation
                jitter_global_obj               interArrivalTimeRate
                latency_global_obj              latency
            }
            
            set found 0
            foreach {hlt_obj_name ixn_obj_name} $init_objects {
                set ret_code [ixNetworkEvalCmd [list ixNet getL $statistics_global_obj $ixn_obj_name]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                set $hlt_obj_name [keylget ret_code ret_val]
                
                set ret_code [ixNetworkEvalCmd [list ixNet getA [set $hlt_obj_name] -enabled]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                if {[keylget ret_code ret_val] == "true"} {
                    set found 1
                    break
                }
            }
            
            if {!$found} {
                puts "\nWARNING: Latency, Jitter or Delay Variation statistics must be enabled using\
                        procedure ::ixia::traffic_control to collect latency bins statistics.\n"
            }
            
            set auto 0
            if {![info exists latency_bins]} {
                set latency_bins 2
                set auto 1
            }
            
            set ret_code [540trafficConfigureLatencyBins $traffic_item_objref $latency_bins $latency_values $auto]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
        }
    } elseif {[info exists latency_bins_enable] && $latency_bins_enable == 0} {
        set retCode [ixNetworkNodeSetAttr ${traffic_item_objref}/tracking/latencyBin \
                [list -enabled "false"] \
                -commit]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
    }
    
    return $returnList    
}


proc ::ixia::540trafficInstrumentation { args opt_args } {

    debug "args == $args"
    debug "opt_args == $opt_args"
    
    keylset returnList status $::SUCCESS
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    # no_CRC, alignment and dribble are not supported
    
#     handle
#     fcs                                 crc
#     fcs_type                            crc
#     frame_sequencing                    enableSequenceChecking
#     frame_sequencing_mode               CHOICES rx_switched_path rx_switched_path_fixed rx_threshold
#     
#     frame_sequencing_offset
#     integrity_signature
#     integrity_signature_offset
# 
#     signature
#     signature_offset
#     
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "stack_ce" "stack_hls"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        keylset ret_val log "Invalid handle $handle. It must be a traffic item\
                handle. [keylget ret_val log]"
        return $ret_val
    }
    
    if {[keylget ret_val value] == "stack_ce" || [keylget ret_val value] == "stack_hls"} {
        # Nothing to set
        return $returnList
    }
    
    if {[keylget ret_val value] == "traffic_item"} {
        set retrieve [540getConfigElementOrHighLevelStream $handle]
        if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
        set handle [keylget retrieve handle]
    }
        
    # Configure payload and payload type - There is no real reason to put this here, but it's a really
    # small piece of code and it fits in here ok
    if {[info exists data_pattern_mode]} {
        switch -- $data_pattern_mode {
            fixed {
                set payload_type "custom"
                set payload_repeat "false"
            }
            incr_byte {
                set payload_type "incrementByte"
            }
            decr_byte {
                set payload_type "decrementByte"
            }
            random {
                set payload_type "random"
            }
            repeating {
                set payload_type "custom"
                set payload_repeat "true"
            }
            incr_word {
                set payload_type "incrementWord"
            }
            decr_word {
                set payload_type "decrementWord"
            }
            default {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error occured while configuring data_pattern_mode.\
                        Unexpected value $data_pattern_mode. Known values are: fixed, incr_byte, decr_byte,\
                        incr_word, decr_word, random, repeating."
                return $returnList
            }
        }
    }
    
    set payload_param_map {
        payload_repeat      customRepeat
        payload_type        type
        data_pattern        customPattern
    }
    
    set ixn_args ""
    foreach {hlt_p ixn_p} $payload_param_map {
        if {[info exists $hlt_p]} {
            lappend ixn_args -$ixn_p [set $hlt_p]
        }
    }
    
    if {[llength $ixn_args] > 0} {
        set result [ixNetworkNodeSetAttr   \
            ${handle}/framePayload         \
            $ixn_args -commit              ]
    }
    
    if {[info exists fcs] && $fcs == 1} {
        if {[info exists fcs_type]} {
            if {$fcs_type == "bad_CRC"} {
                set result [ixNetworkNodeSetAttr                                \
                                ${handle}          \
                                [list -crc badCrc] -commit                     ]
                                
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList log "Failed to configure -fcs_type $fcs_type\
                            - [keylget result log]"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
        } else {
            set result [ixNetworkNodeSetAttr                                \
                            ${handle}          \
                            [list -crc goodCrc]   -commit                      ]
                            
            if {[keylget result status] == $::FAILURE} {
                keylset returnList log "Failed to configure -fcs_type $fcs_type\
                        - [keylget result log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
    }
    
    if {[info exists frame_sequencing]} {
        if {$frame_sequencing == "enable"} {
            set frame_seq_args "-enabled true "
            
            if {[info exists frame_sequencing_mode]} {
                switch -- $frame_sequencing_mode {
                    "rx_switched_path" {
                        append frame_seq_args "-sequenceMode rxSwitchedPath"
                    }
                    "rx_switched_path_fixed" {
                        append frame_seq_args "-sequenceMode rxPacketArrival"
                    }
                    "rx_threshold" {
                        append frame_seq_args "-sequenceMode rxThreshold"
                    }
					"advanced" {
                        append frame_seq_args "-sequenceMode advanced"
                    }
                }
            }
        } else {
            set frame_seq_args "-enabled false"
        }
        
        set result [ixNetworkNodeSetAttr                                \
                        [ixNet getRoot]traffic/statistics/sequenceChecking \
                        $frame_seq_args  -commit                      ]
                        
        if {[keylget result status] == $::FAILURE} {
            keylset returnList log "Failed to configure sequence checking\
                    - [keylget result log]"
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
    return $returnList
}


proc ::ixia::540trafficGlobals { args opt_args } {
    debug "540trafficGlobals"
    debug "args == $args"
    debug "opt_args == $opt_args"
    
    variable truth
    
    keylset returnList status $::SUCCESS
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    array set translate_frame_ordering {
        flow_group_setup    flowGroupSetup
        none                none
        peak_loading        peakLoading
        rfc2889             RFC2889
    }
    
    set param_map {
            global_dest_mac_retry_count               destMacRetryCount                 _none
            global_dest_mac_retry_delay               destMacRetryDelay                 _none
            enable_data_integrity                     enableDataIntegrityCheck          truth
            global_enable_dest_mac_retry              enableDestMacRetry                truth
            global_enable_min_frame_size              enableMinFrameSize                truth
            global_enable_staggered_transmit          enableStaggeredTransmit           truth
            global_enable_stream_ordering             enableStreamOrdering              truth
            global_stream_control                     globalStreamControl               _none
            global_stream_control_iterations          globalStreamControlIterations     _none
            global_large_error_threshhold             largeErrorThreshhold              _none
            global_enable_mac_change_on_fly           macChangeOnFly                    truth
            global_max_traffic_generation_queries     maxTrafficGenerationQueries       _none
            global_mpls_label_learning_timeout        mplsLabelLearningTimeout          _none
            global_refresh_learned_info_before_apply  refreshLearnedInfoBeforeApply     truth
            global_use_tx_rx_sync                     useTxRxSync                       truth
            global_wait_time                          waitTime                          _none
            global_display_mpls_current_label_value   displayMplsCurrentLabelValue      truth
            global_frame_ordering                     frameOrderingMode                 _translate_frame_ordering
        }
    
    set ixn_args ""
    foreach {hlt_p ixn_p p_type} $param_map {
        
        if {![info exists $hlt_p]} {
            continue
        }
        
        set hlt_p_val [set $hlt_p]
        
        switch -- $p_type {
            "_none" {
                set ixn_p_val $hlt_p_val
            }
            "truth" {
                set ixn_p_val $truth($hlt_p_val)
            }
            "_translate_frame_ordering" {
                set ixn_p_val $translate_frame_ordering($hlt_p_val)
            }
            default {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error in 540trafficGlobals. Unexpected\
                    p_type $p_type in internal parameter map array for parameter $hlt_p_val."
                return $returnList
            }
        }
        
        lappend ixn_args -$ixn_p $ixn_p_val
    }
    
    if {[info exists global_frame_ordering] && $global_frame_ordering == "peak_loading" && [info exists global_peak_loading_replication_count]} {
        lappend ixn_args -peakLoadingReplicationCount $global_peak_loading_replication_count
    }
    
    if {[llength $ixn_args] > 0} {
        set ret_code [ixNetworkEvalCmd [list ixNet getL ::ixNet::OBJ-/ traffic]]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset ret_code log "[keylget ret_code log] Possible reasons: IxNetwork\
                    Tcl Server connection is down; IxTclNetwork package was not loaded."
            return $ret_code
        }
        
        set traffic_global_obj [keylget ret_code ret_val]
        
        set retCode [ixNetworkNodeSetAttr   \
                $traffic_global_obj         \
                $ixn_args -commit           ]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
    }
    
    return $returnList
}
