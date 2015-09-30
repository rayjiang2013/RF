#===============================================================================

proc ::ixia::540quickFlowsConfig {args opt_args} {
    keylset returnList status $::FAILURE
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args } errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    array set truth_array {false 0 true 1}

    array set mode_convertor {
        counter         counter
        random          random
        value_list      valueList
        range_list      rangeList
        nested          nestedCounter
        ipv4            ipv4
    }

    array set ixn_value_depend_array {
        counter,counter_init_value                      startValue
        counter,counter_repeat_count                    count
        counter,counter_step                            stepValue
        counter,counter_type                            width
        counter,inner_repeat_count                      innerLoopLoopCount
        counter,inner_repeat_value                      innerLoopRepeatValue
        counter,inner_step                              stepValue
        nested,counter_init_value                       startValue
        nested,counter_repeat_count                     outerLoopLoopCount
        nested,counter_step                             outerLoopIncrementBy
        nested,counter_type                             width
        nested,inner_repeat_count                       innerLoopLoopCount
        nested,inner_repeat_value                       innerLoopRepeatValue
        nested,inner_step                               innerLoopIncrementBy
        value_list,counter_init_value                   innerLoopRepeatValue
        value_list,counter_repeat_count                 width
        value_list,counter_step                         width
        value_list,counter_type                         width
        value_list,inner_repeat_count                   width
        value_list,inner_repeat_value                   innerLoopRepeatValue
        value_list,inner_step                           width
        range_list,counter_init_value                   startValueCountStepList
        range_list,counter_repeat_count                 width
        range_list,counter_step                         width
        range_list,counter_type                         width
        range_list,inner_repeat_count                   width
        range_list,inner_repeat_value                   innerLoopRepeatValue
        range_list,inner_step                           width
        random,counter_init_value                       innerLoopRepeatValue
        random,counter_repeat_count                     width
        random,counter_step                             width
        random,counter_type                             width
        random,inner_repeat_count                       width
        random,inner_repeat_value                       innerLoopRepeatValue
        random,inner_step                               width
        ipv4,counter_init_value                         startValue
        ipv4,counter_repeat_count                       outerLoopLoopCount
        ipv4,counter_step                               innerLoopIncrementBy
        ipv4,counter_type                               width
        ipv4,inner_repeat_count                         innerLoopLoopCount
        ipv4,inner_repeat_value                         innerLoopLoopCount
        ipv4,inner_step                                 innerLoopIncrementBy
    }

    array set sub_depend_array {
        counter             counter
        nested              nestedCounter
        random              random
        value_list          valueList
        range_list          rangeList
        ipv4                ipv4
    }
    
    array set conversions {
        increment           increment
        decrement           decrement
        up                  increment
        down                decrement
    }
    
    #   hlt_value                      ixn_value              ixn_depend    udf      sub_object       sub_depend      marker    hex_convert
    set field_values_list {
        enable_udf1                    enabled                none           1       none             none            force     0
        enable_udf2                    enabled                none           2       none             none            force     0
        enable_udf3                    enabled                none           3       none             none            force     0
        enable_udf4                    enabled                none           4       none             none            force     0
        enable_udf5                    enabled                none           5       none             none            force     0
        udf1_cascade_type              none                   none           1       none             none            no        0
        udf1_chain_from                chainedFromUdf         none           1       none             none            no        0
        udf1_counter_init_value        REPLACE                udf1_mode      1       REPLACE          udf1_mode       no        1
        udf1_counter_mode              none                   none           1       none             none            no        0
        udf1_counter_repeat_count      REPLACE                udf1_mode      1       REPLACE          udf1_mode       no        0
        udf1_counter_step              REPLACE                udf1_mode      1       REPLACE          udf1_mode       no        0
        udf1_counter_type              REPLACE                udf1_mode      1       REPLACE          udf1_mode       force     0
        udf1_counter_up_down           direction              none           1       counter          none            convert   0
        udf1_enable_cascade            none                   none           1       none             none            no        0
        udf1_inner_repeat_count        REPLACE                udf1_mode      1       nestedCounter    none            no        0
        udf1_inner_repeat_value        REPLACE                udf1_mode      1       REPLACE          udf1_mode       no        0
        udf1_inner_step                REPLACE                udf1_mode      1       REPLACE          udf1_mode       no        0
        udf1_mask_select               MASK                   none           1       random           none            no        0
        udf1_mask_val                  MASK                   none           1       random           none            no        0
        udf1_mode                      type                   none           1       none             none            mode      0
        udf1_offset                    byteOffset             none           1       none             none            force     0
        udf1_skip_mask_bits            bitmaskCount           none           1       ipv4             none            no        0
        udf1_skip_zeros_and_ones       skipValues             none           1       ipv4             none            no        0
        udf1_value_list                startValueList         none           1       REPLACE          udf1_mode       no        1
        udf2_cascade_type              none                   none           2       none             none            no        0
        udf2_chain_from                chainedFromUdf         none           2       none             none            no        0
        udf2_counter_init_value        REPLACE                udf2_mode      2       REPLACE          udf2_mode       no        1
        udf2_counter_mode              none                   none           2       none             none            no        0
        udf2_counter_repeat_count      REPLACE                udf2_mode      2       REPLACE          udf2_mode       no        0
        udf2_counter_step              REPLACE                udf2_mode      2       REPLACE          udf2_mode       no        0
        udf2_counter_type              REPLACE                udf2_mode      2       REPLACE          udf2_mode       force     0
        udf2_counter_up_down           direction              none           2       counter          none            convert   0
        udf2_enable_cascade            none                   none           2       none             none            no        0
        udf2_inner_repeat_count        REPLACE                udf2_mode      2       nestedCounter    none            no        0
        udf2_inner_repeat_value        REPLACE                udf2_mode      2       REPLACE          udf2_mode       no        0
        udf2_inner_step                REPLACE                udf2_mode      2       REPLACE          udf2_mode       no        0
        udf2_mask_select               MASK                   none           2       random           none            no        0
        udf2_mask_val                  MASK                   none           2       random           none            no        0
        udf2_mode                      type                   none           2       none             none            mode      0
        udf2_offset                    byteOffset             none           2       none             none            force     0
        udf2_skip_mask_bits            bitmaskCount           none           2       ipv4             none            no        0
        udf2_skip_zeros_and_ones       skipValues             none           2       ipv4             none            no        0
        udf2_value_list                startValueList         none           2       REPLACE          udf2_mode       no        1
        udf3_cascade_type              none                   none           3       none             none            no        0
        udf3_chain_from                chainedFromUdf         none           3       none             none            no        0
        udf3_counter_init_value        REPLACE                udf3_mode      3       REPLACE          udf3_mode       no        1
        udf3_counter_mode              none                   none           3       none             none            no        0
        udf3_counter_repeat_count      REPLACE                udf3_mode      3       REPLACE          udf3_mode       no        0
        udf3_counter_step              REPLACE                udf3_mode      3       REPLACE          udf3_mode       no        0
        udf3_counter_type              REPLACE                udf3_mode      3       REPLACE          udf3_mode       force     0
        udf3_counter_up_down           direction              none           3       counter          none            convert   0
        udf3_enable_cascade            none                   none           3       none             none            no        0
        udf3_inner_repeat_count        REPLACE                udf3_mode      3       nestedCounter    none            no        0
        udf3_inner_repeat_value        REPLACE                udf3_mode      3       REPLACE          udf3_mode       no        0
        udf3_inner_step                REPLACE                udf3_mode      3       REPLACE          udf3_mode       no        0
        udf3_mask_select               MASK                   none           3       random           none            no        0
        udf3_mask_val                  MASK                   none           3       random           none            no        0
        udf3_mode                      type                   none           3       none             none            mode      0
        udf3_offset                    byteOffset             none           3       none             none            force     0
        udf3_skip_mask_bits            bitmaskCount           none           3       ipv4             none            no        0
        udf3_skip_zeros_and_ones       skipValues             none           3       ipv4             none            no        0
        udf3_value_list                startValueList         none           3       REPLACE          udf3_mode       no        1
        udf4_cascade_type              none                   none           4       none             none            no        0
        udf4_chain_from                chainedFromUdf         none           4       none             none            no        0
        udf4_counter_init_value        REPLACE                udf4_mode      4       REPLACE          udf4_mode       no        1
        udf4_counter_mode              none                   none           4       none             none            no        0
        udf4_counter_repeat_count      REPLACE                udf4_mode      4       REPLACE          udf4_mode       no        0
        udf4_counter_step              REPLACE                udf4_mode      4       REPLACE          udf4_mode       no        0
        udf4_counter_type              REPLACE                udf4_mode      4       REPLACE          udf4_mode       force     0
        udf4_counter_up_down           direction              none           4       counter          none            convert   0
        udf4_enable_cascade            none                   none           4       none             none            no        0
        udf4_inner_repeat_count        REPLACE                udf4_mode      4       nestedCounter    none            no        0
        udf4_inner_repeat_value        REPLACE                udf4_mode      4       REPLACE          udf4_mode       no        0
        udf4_inner_step                REPLACE                udf4_mode      4       REPLACE          udf4_mode       no        0
        udf4_mask_select               MASK                   none           4       random           none            no        0
        udf4_mask_val                  MASK                   none           4       random           none            no        0
        udf4_mode                      type                   none           4       none             none            mode      0
        udf4_offset                    byteOffset             none           4       none             none            force     0
        udf4_skip_mask_bits            bitmaskCount           none           4       ipv4             none            no        0
        udf4_skip_zeros_and_ones       skipValues             none           4       ipv4             none            no        0
        udf4_value_list                startValueList         none           4       REPLACE          udf4_mode       no        1
        udf5_cascade_type              none                   none           5       none             none            no        0
        udf5_chain_from                chainedFromUdf         none           5       none             none            no        0
        udf5_counter_init_value        REPLACE                udf5_mode      5       REPLACE          udf5_mode       no        1
        udf5_counter_mode              none                   none           5       none             none            no        0
        udf5_counter_repeat_count      REPLACE                udf5_mode      5       REPLACE          udf5_mode       no        0
        udf5_counter_step              REPLACE                udf5_mode      5       REPLACE          udf5_mode       no        0
        udf5_counter_type              REPLACE                udf5_mode      5       REPLACE          udf5_mode       force     0
        udf5_counter_up_down           direction              none           5       counter          none            convert   0
        udf5_enable_cascade            none                   none           5       none             none            no        0
        udf5_inner_repeat_count        REPLACE                udf5_mode      5       nestedCounter    none            no        0
        udf5_inner_repeat_value        REPLACE                udf5_mode      5       REPLACE          udf5_mode       no        0
        udf5_inner_step                REPLACE                udf5_mode      5       REPLACE          udf5_mode       no        0
        udf5_mask_select               MASK                   none           5       random           none            no        0
        udf5_mask_val                  MASK                   none           5       random           none            no        0
        udf5_mode                      type                   none           5       none             none            mode      0
        udf5_offset                    byteOffset             none           5       none             none            force     0
        udf5_skip_mask_bits            bitmaskCount           none           5       ipv4             none            no        0
        udf5_skip_zeros_and_ones       skipValues             none           5       ipv4             none            no        0
        udf5_value_list                startValueList         none           5       REPLACE          udf5_mode       no        1
    }
    
    if {![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "No handle provided -> ::ixia::540quickFlowsConfig"
        return $returnList
    }
        
    if { $mode == "create" || $mode == "modify"} {
        
        # Configure modes...
        set anything_changed 0
        foreach {hlt_parameter ixn_parameter ixn_depend udf_index sub_object sub_depend marker hex_convert} $field_values_list {
            if {[info exists $hlt_parameter] && $marker == "mode"} {
                set target_udf_object "${handle}/udf:${udf_index}"
                set all_good [ixNet setAttribute $target_udf_object -${ixn_parameter} $mode_convertor([set $hlt_parameter])]
                set anything_changed 1
                if { $all_good != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error setting attribute $hlt_parameter on $target_udf_object"
                    return $returnList
                }
                if {[set $hlt_parameter] == "range_list"} {
                    set range_flag_${udf_index} 1
                }
            } 
        }
        if { $anything_changed } {
            set all_good [ixNet commit]
            if { $all_good != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error commiting changes -> ::ixia::540quickFlowsConfig"
                return $returnList
            }
        }
        
        # Configure other parameters...
        set anything_changed 0
        foreach {hlt_parameter ixn_parameter ixn_depend udf_index sub_object sub_depend marker hex_convert} $field_values_list {
            if {[info exists $hlt_parameter] && $ixn_parameter != "none" && $marker != "mode"} {
                set ixn_target $ixn_parameter
                if { $udf_index > 0 } {
                    
                    if {$sub_depend != "none"} {
                        set target_udf_object "${handle}/udf:${udf_index}/$sub_depend_array([set $sub_depend])"
                    } else {
                        if {$sub_object == "none"} {
                            set target_udf_object "${handle}/udf:${udf_index}"
                        } else {
                            set target_udf_object "${handle}/udf:${udf_index}/${sub_object}"
                        }
                    }
                    
                    if {$ixn_depend != "none"} {
                        set dependancy_key "[set $ixn_depend],[string range $hlt_parameter 5 end]"
                        if {[info exists ixn_value_depend_array($dependancy_key)]} {
                            set ixn_target $ixn_value_depend_array($dependancy_key)
                        }
                    }
                    
                    if {$hex_convert} {
                        set $hlt_parameter [turnThisListFromHexToInt [set $hlt_parameter]]
                    }

                    if {$ixn_parameter == "MASK"} {
                        if {[info exists done_mask_${udf_index}]} {
                            continue
                        } else {
                            set done_mask_${udf_index} 1
                        }
                        set mask_select_name        "udf${udf_index}_mask_select"
                        set mask_value_name         "udf${udf_index}_mask_val"
                        if {![info exists $mask_select_name]}   { continue }
                        if {![info exists $mask_value_name]}    { continue }
                        set mask_select     [set $mask_select_name]
                        set mask_value      [set $mask_value_name]
                        set ixn_target      mask
                        
                        set tmp_mask_select [::ixia::convert_string_to_hex $mask_select]
                        binary scan [binary format H* $tmp_mask_select] B* tmp_mask_select
                        set final_mask $tmp_mask_select
                        for {set ms 0} {$ms < [string length $tmp_mask_select]} {incr ms} {
                            if {[string index $tmp_mask_select $ms] == "1"} {
                                set final_mask [string replace $final_mask $ms $ms 0]
                            } else {
                                set final_mask [string replace $final_mask $ms $ms "X"]
                            }
                        }
                        set final_length [string length $final_mask]
                        set tmp_mask_value  [::ixia::convert_string_to_hex $mask_value]
                        binary scan [binary format H* $tmp_mask_value] B* tmp_mask_value
                        for {set mv 0} {$mv < [string length $tmp_mask_value]} {incr mv} {
                            if {[string index $tmp_mask_value $mv] == "1"} {
                                if {[string index $final_mask $mv] != "X"} {
                                    set final_mask [string replace $final_mask $mv $mv 1]
                                }
                            }
                        }
                        set $hlt_parameter $final_mask
                    }
                    
                    if {$marker == "convert" && [info exists conversions([set $hlt_parameter])]} {
                        set $hlt_parameter $conversions([set $hlt_parameter])
                    }
                    
                    # Range list special case...
                    if {$marker == "force"} {
                        # carry on...
                    } else {
                        if {[info exists done_${udf_index}]} {
                            continue
                        } else {
                            if {[info exists range_flag_${udf_index}]} {
                                set target_udf_object "${handle}/udf:${udf_index}/rangeList"
        
                                if {[info exists udf${udf_index}_counter_init_value]} {
                                    set range_value     [set udf${udf_index}_counter_init_value]
                                    set range_length    [llength [split $range_value " "]]
                                } else {
                                    continue
                                }
                                
                                if {[info exists udf${udf_index}_counter_repeat_count]} {
                                    set range_count [set udf${udf_index}_counter_repeat_count]
                                } else {
                                    set range_count [string trim [string repeat "1 " $range_length]]
                                }
                                
                                if {[info exists udf${udf_index}_counter_step]} {
                                    set range_step [set udf${udf_index}_counter_step]
                                } else {
                                    set range_step [string trim [string repeat "1 " $range_length]]
                                }
                                
                                # Build start values list...
                                set range_list_effective [list]
                                for {set i 0} {$i < $range_length} {incr i} {
                                    lappend range_list_effective [lindex $range_value $i]
                                    lappend range_list_effective [lindex $range_count $i]
                                    lappend range_list_effective [lindex $range_step  $i]
                                }
                                set hlt_parameter   range_list_effective
                                set ixn_target      startValueCountStepList
                                
                                set done_${udf_index} 1
                            }
                        }
                    }
                    
                } else {
                    set target_udf_object "${handle}/tableUdf"
                }

                set all_good [ixNet setAttribute $target_udf_object -${ixn_target} [set $hlt_parameter]]
                set anything_changed 1
                if { $all_good != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error setting attribute $hlt_parameter (mapped to $ixn_target) on $target_udf_object"
                    return $returnList
                }
            }
        }
        if { $anything_changed } {
            set all_good [ixNet commit]
            if { $all_good != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error commiting changes -> ::ixia::540quickFlowsConfig"
                return $returnList
            }
        }

        # Table UDF
        set table_udf_params [list      \
                table_udf_column_type   \
                table_udf_column_size   \
                table_udf_column_offset \
                table_udf_rows          ]

        set table_udf_config_options "\
                -high_level_stream $handle "

        foreach {table_udf_param} $table_udf_params {
            if {[info exists $table_udf_param]} {
                append table_udf_config_options \
                        " -$table_udf_param {[set $table_udf_param]}"
            }
        }
        
        set table_udf_result [eval ::ixia::540setTableUdf \
                $table_udf_config_options]
        if {[keylget table_udf_result status] == $::FAILURE} {
            return $table_udf_result
        }
        
        keylset returnList status $::SUCCESS
        keylset returnList handle $handle
    
    }

    return $returnList
}

#===============================================================================

proc ::ixia::isThisAQuickFlowItem { item2test } {
    set ret_val [540IxNetValidateObject $item2test [list traffic_item high_level_stream stack_hls]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return 0
    }
    set traffic_item_extracted [ixNetworkGetParentObjref $item2test "trafficItem"]
    set lightning [ixNet getAttribute $traffic_item_extracted -trafficItemType]
    if { $lightning == "quick"} {
        return 1
    }
    return 0
}

#===============================================================================

proc ::ixia::getMeHighLevelStreamFrom { nothing } {
    set ret_val [540IxNetValidateObject $nothing [list traffic_item high_level_stream stack_hls]]
    if {[keylget ret_val status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Object type not valid. $nothing should be traffic item, high level stream or stack over hls."
        return $returnList
    }
    if {[keylget ret_val value] == "traffic_item"} {
        set hls_list [ixNet getList $nothing highLevelStream]
        if {[llength $hls_list] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "NO high level streams found under this traffic item: $nothing"
        } elseif {[llength $hls_list] == 1} {
            keylset returnList status $::SUCCESS
            keylset returnList handle [lindex $hls_list 0]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "More than one high level stream found under this traffic item. Please provide a high level stream handle."
        }
    } elseif {[keylget ret_val value] == "high_level_stream"} {
        keylset returnList status $::SUCCESS
        keylset returnList handle $nothing
    } elseif {[keylget ret_val value] == "stack_hls"} {
        keylset returnList status $::SUCCESS
        keylset returnList handle [ixNetworkGetParentObjref $nothing highLevelStream]
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "Unknown object type."
    }
    return $returnList
}

#===============================================================================

proc ::ixia::addQuickHlsOverExistingTrafficItem { tritem_list eps_argument_list hls_argument_list } {
    set no_candidate_found 1
    # Select a quick traffic item...
    foreach quick_candidate $tritem_list {
        if { [ixNet getA $quick_candidate -trafficItemType] == "quick" } {
            set existing_node $quick_candidate
            set no_candidate_found 0
            break
        }
    }
    if {$no_candidate_found} {
        keylset returnList status         $::SUCCESS
        keylset returnList traffic_handle "none"
        keylset returnList hls_handle     "none"
        keylset returnList no_candidate   1
        return $returnList
    }
    # Add HLS over the existing traffic item...
    set result [ixNetworkNodeAdd $existing_node endpointSet $eps_argument_list -commit]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not add a new endpoint set - [keylget result log]."
        return $returnList
    }
    set operational_eps [keylget result node_objref]
    
    # The endpoint set should have added a high level stream. Find it. Update it.
    set new_hls_list [ixNet getList $existing_node highLevelStream]
    set operational_hls [lindex $new_hls_list end]
    set result [ixNetworkNodeSetAttr $operational_hls $hls_argument_list -commit]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not set high level stream attributes - [keylget result log]."
        return $returnList
    }
    keylset returnList status         $::SUCCESS
    keylset returnList traffic_handle $existing_node
    keylset returnList hls_handle     $operational_hls
    keylset returnList no_candidate   0
    return $returnList
}

#===============================================================================

proc ::ixia::turnThisListFromHexToInt { hexolist } {
    set new_values_list [list]
    if {[llength $hexolist] == 1} {
        set inhibit 1
    } else {
        set inhibit 0
    }
    foreach old_value $hexolist {
        if {[string first "x" [string tolower $old_value]] != -1} {
            lappend new_values_list   [format %u $old_value]
        } else {
            if {$inhibit} {
                lappend new_values_list   $old_value
            } else {
                lappend new_values_list   [format %u "0x${old_value}"]
            }
        }
    }
    return $new_values_list
}

#===============================================================================

proc ::ixia::540setTableUdf {args} {

    set mandatory_args {
        -high_level_stream
    }

    set opt_args {
        -table_udf_column_type
        -table_udf_column_offset
        -table_udf_column_size
        -table_udf_rows
    }

    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args          \
            -mandatory_args $mandatory_args} parseError]} {

        keylset returnList status $::FAILURE
        keylset returnList log $parseError
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getList $high_level_stream tableUdf]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    set table_udf_obj [keylget ret_code ret_val]
    
    # Table UDF
    set table_udf_params [list      \
            table_udf_column_type   \
            table_udf_column_size   \
            table_udf_column_offset \
            table_udf_rows          ]

    set table_udf_num_cols   0
    set table_udf_num_params 0

    # Check if all -table_udf options are provided
    foreach {table_param} $table_udf_params {
        if {[info exists $table_param]} {
            incr table_udf_num_params
            if {$table_param != "table_udf_rows" && $table_param != "table_udf_column_name"} {
                if {$table_udf_num_cols == 0} {
                    set table_udf_num_cols [llength [set $table_param]]
                } else {
                    if {$table_udf_num_cols != [llength [set $table_param]]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Table udf arguments\
                                -table_udf_column_name,\
                                -table_udf_column_type,\
                                -table_udf_column_size,\
                                -table_udf_column_offset\
                                must have the same length on port: $chassis\
                                $card $port to be used."
                        return $returnList
                    }
                }
            } elseif {$table_param == "table_udf_rows"} {
                if {[llength table_udf_rows] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "-table_udf_rows must have at least\
                            one element on port: $chassis $card $port to be\
                            able to be used."
                    return $returnList
                }
            }
        }
    }
    
    set parameter_map {
        table_udf_column_offset        offset   byte2bit
        table_udf_column_size          size     _none
        table_udf_column_type          format   config_values
    }
    
    array set tableUdfColumnTypes [list \
            hex      hex        \
            ascii    ascii      \
            mac      mac        \
            binary   binary     \
            ipv4     ipv4       \
            ipv6     ipv6       \
            decimal  decimal    \
            custom   custom     ]

    # Configure table udf if all -table_udf options were provided
    if {$table_udf_num_params == [llength $table_udf_params]} {
        
        set ret_code [ixNetworkEvalCmd [list ixNet getList $table_udf_obj column]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set tmp_columns [keylget ret_code ret_val]
        set commit_needed 0
        # The columns need to be deleted in the reverse order of creation
        for {set i [expr {[llength $tmp_columns]-1}]} {$i >= 0} {incr i -1} {
            set tUdfColumn [lindex $tmp_columns $i]
            set ret_code [ixNetworkEvalCmd [list ixNet remove $tUdfColumn] "ok"]
            if {[keylget ret_code status] != $::SUCCESS} {
                 return $ret_code
            }
            set commit_needed 1
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet setA $table_udf_obj -enabled true] "ok"]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        if {$commit_needed} {
            set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
        }
        
        catch {unset commit_needed}
        catch {unset tmp_columns}
        
        # If only one row is provided then the provided list must be
        # set as a keyed list
        if {([llength [lindex $table_udf_rows 0]] != 2) && \
                ([llength $table_udf_rows] == 2)} {

            set table_udf_temp $table_udf_rows
            unset table_udf_rows
            keylset table_udf_rows [lindex $table_udf_temp 0] \
                    [lindex $table_udf_temp 1]
        }

        # Add rows
        set tableRows [lsort -dictionary [keylkeys table_udf_rows]]
        
        foreach rowItem $tableRows {
            set rowValue [keylget table_udf_rows $rowItem]
            
            set column_index 0
            foreach row_cell $rowValue {
                lappend column_${column_index} $row_cell
                incr column_index
            }
        }
        
        
        array set column_commands ""

        # Add columns
        for {set i 0} {$i < $table_udf_num_cols} {incr i} {
            
            set ret_code [ixNetworkEvalCmd [list ixNet add $table_udf_obj column]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set ret_commit [ixNetworkEvalCmd [list ixNet commit] "ok"]
            if {[keylget ret_commit status] != $::SUCCESS} {
                keylset ret_commit log "Failed to add tableUdf column $i. [keylget ret_commit log]"
                return $ret_commit
            }
            set column_obj_ref [keylget ret_code ret_val]
            set column_obj_ref [ixNet remapIds $column_obj_ref]
            
            foreach {hlt_p ixn_p p_type} $parameter_map {
                if {[info exists $hlt_p]} {
                    
                    set hlt_p_val [lindex [set $hlt_p] $i]
                    
                    switch -- $p_type {
                        config_values {
                            if {[info exists column_$i]} {
                                set tmp_column ""
                                foreach column_cell [set column_$i] {
                                    switch -- $hlt_p_val {
                                        mac -
                                        hex {
                                            lappend tmp_column [convert_string_to_hex $column_cell]
                                        }
                                        ascii {
                                            lappend tmp_column [convert_string_to_ascii_hex $column_cell]
                                        }
                                        binary {
                                            set tmp_val [convert_bits_to_int $column_cell]
                                            lappend tmp_column [format %x $tmp_val]
                                        }
                                        ipv6 {
                                            set tmp_val [expand_ipv6_addr $column_cell]
                                            lappend tmp_column $tmp_val
                                        }
                                        ipv4 -
                                        decimal {
                                            lappend tmp_column $column_cell
                                        }
                                        default {
                                            lappend tmp_column $column_cell
                                        }
                                    }
                                    
                                    catch {unset tmp_val}
                                }
                                set column_commands($column_obj_ref) $tmp_column
#                                 set ret_code [ixNetworkEvalCmd [list ixNet setA $column_obj_ref -values $tmp_column] "ok"]
#                                 if {[keylget ret_code status] != $::SUCCESS} {
#                                     return $ret_code
#                                 }
                            }
                            
                            set ixn_p_val $hlt_p_val
                        }
                        byte2bit {
                            set ixn_p_val [mpexpr $hlt_p_val * 8]
                        }
                        default {
                            set ixn_p_val $hlt_p_val
                        }
                    }
                    
                    set ret_code [ixNetworkEvalCmd [list ixNet setA $column_obj_ref -$ixn_p $ixn_p_val] "ok"]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                }
            }
            
            set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset ret_code log "Failed to configure tableUdf column $i. [keylget ret_code log]"
                return $ret_code
            }
        }
        
        set commit_needed 0
        foreach tudf_column [array names column_commands] {
            set ret_code [ixNetworkEvalCmd [list ixNet setA $tudf_column -values $column_commands($tudf_column)] "ok"]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set commit_needed 1
        }
        
        if {$commit_needed} {
            set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset ret_code log "Failed to configure tableUdf. [keylget ret_code log]"
                return $ret_code
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

#===============================================================================