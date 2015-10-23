proc ::ixia::oam_short_ma_name_check {short_ma_name short_ma_name_format short_ma_name_length} {
    
    keylset returnList status $::SUCCESS
    
    switch -- $short_ma_name_format {
        "primary_vid" {
            if {![string is integer $short_ma_name]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid -short_ma_name_value $short_ma_name. When\
                        -short_ma_name_format is $short_ma_name_format, -short_ma_name_value\
                        must be a number from 0 to 4095."
                return $returnList
            }
            
            if {$ixn_param_value < 0 || $ixn_param_value > 4095} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid -short_ma_name_value $short_ma_name. When\
                        -short_ma_name_format is $short_ma_name_format, -short_ma_name_value\
                        must be a number from 0 to 4095."
                return $returnList
            }
        }
        "char_str" {
            # Check if string has the right length
            if {[string length $short_ma_name] > $short_ma_name_length} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid -short_ma_name_value $short_ma_name. When\
                        -short_ma_name_format is $short_ma_name_format, -short_ma_name_value\
                        must have a maximum length of -short_ma_name_length $short_ma_name_length."
                return $returnList
            }
        }
        "integer" {
            if {![string is integer $short_ma_name]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid -short_ma_name_value $short_ma_name. When\
                        -short_ma_name_format is $short_ma_name_format, -short_ma_name_value\
                        must be a number from 0 to 65535."
                return $returnList
            }
            
            if {$short_ma_name < 0 || $short_ma_name > 65535} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid -short_ma_name_value $short_ma_name. When\
                        -short_ma_name_format is $short_ma_name_format, -short_ma_name_value\
                        must be a number from 0 to 65535."
                return $returnList
            }
        }
        "rfc_2685_vpn_id" {
            if {![regexp {(\d+)(\-)(\d+)$} $short_ma_name trash number1 dash number2]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid -short_ma_name_value $short_ma_name. When\
                        -short_ma_name_format is $short_ma_name_format, $short_ma_name\
                        must be formatted <number1>-<number2> where <number1> is from\
                        0 to 16777215 and <number2> is from 0 to 4292967295."
                return $returnList
            }
            
            if {$number1 < 0 || $number1 > 16777215 ||\
                    $number2 < 0 || $number2 > 4292967295} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid -short_ma_name_value $short_ma_name. When\
                        -short_ma_name_format is $short_ma_name_format, $short_ma_name\
                        must be formatted <number1>-<number2> where <number1> is from\
                        0 to 16777215 and <number2> is from 0 to 4292967295."
                return $returnList
            }
        }
    }

    return $returnList
}

proc ::ixia::oam_create_level {parent_handle level_idx levels_total mip_count mep_count bridge_handle} {
    if {$level_idx <= $levels_total} {
        for {set i 0} {$i < $mip_count} {incr i} {
            set mip_handle [oam_pop_next_mip]
            
            if {$mip_handle == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to create topology. Number of MIP\
                         handles create can not cannot accomodate the topology."
                return $returnList
            }
            
            if {$i == 0 && $parent_handle != [ixNet getNull]} {
                set tmp_status [oam_create_link $bridge_handle $parent_handle $mip_handle $level_idx 1]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    return $tmp_status
                }
            } else {
                set tmp_status [oam_create_link $bridge_handle $parent_handle $mip_handle $level_idx]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    return $tmp_status
                }
            }
            set parent_handle $mip_handle
        }
        
        set tmp_mep_handle_list ""
        for {set i 0} {$i < $mep_count} {incr i} {
            set mep_handle [oam_pop_next_mep]
            
            if {$mep_handle == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to create topology. Number of Mep\
                         handles create can not cannot accomodate the topology."
                return $returnList
            }
            
            lappend local_mep_handle_list $mep_handle
            
            if {$mip_count == 0 && $level_idx != 0} {
                set tmp_status [oam_create_link $bridge_handle $parent_handle $mep_handle $level_idx 1]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    return $tmp_status
                }
            } else {
                set tmp_status [oam_create_link $bridge_handle $parent_handle $mep_handle $level_idx]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    return $tmp_status
                }
            }
            
            set tmp_status [oam_push_mep_arr_entry $mep_handle]
            if {[keylget tmp_status status] != $::SUCCESS} {
                return $tmp_status
            }
        }
        
        incr level_idx
        
        foreach mep_handle $local_mep_handle_list {
            set tmp_status [::ixia::oam_create_level $mep_handle $level_idx $levels_total $mip_count $mep_count $bridge_handle]
            if {[keylget tmp_status status] != $::SUCCESS} {
                return $tmp_status
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::oam_pop_next_mip {} {
    variable mip_handles
    
    # Pop a value from mip_handles
    set ret_value [lindex $mip_handles 0]
    set mip_handles [lreplace $mip_handles 0 0]
    return $ret_value
}

proc ::ixia::oam_pop_next_mep {} {
    variable mep_handles
    
    # Pop a value from mep_handles
    set ret_value [lindex $mep_handles 0]
    set mep_handles [lreplace $mep_handles 0 0]
    return $ret_value
}

proc ::ixia::oam_create_link {bridge_handle mp_towards_ixia mp_outwards_ixia level_idx {change_level {0} } } {
    variable md_level_handles
    
    # Ged mdLevel objRef at idx 
    set md_level_outwards [lindex $md_level_handles $level_idx]
    
    if {$change_level} {
        set md_level_towards [lindex $md_level_handles [expr $level_idx - 1]]
    } else {
        set md_level_towards $md_level_outwards
    }
    
    if {$mp_towards_ixia != [ixNet getNull]} {
        set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                $mp_towards_ixia                                            \
                [list -mdLevel $md_level_towards]                           \
                -commit                                                     \
            ]
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
    }
    
    set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
            $mp_outwards_ixia                                           \
            [list -mdLevel $md_level_outwards]                          \
            -commit                                                     \
        ]
    if {[keylget tmp_status status] != $::SUCCESS} {
        return $tmp_status
    }
    
    set tmp_status [::ixia::ixNetworkNodeAdd                            \
            $bridge_handle                                              \
            "link"                                                      \
            [list -enabled true -mpTowardsIxia $mp_towards_ixia         \
                    -mpOutwardsIxia $mp_outwards_ixia]                  \
            -commit                                                     \
        ]
    
    if {[keylget tmp_status status] != $::SUCCESS} {
        return $tmp_status
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::oam_push_mep_arr_entry {mep_item} {

    variable mep_handles_array
    variable cfm_topology_current_id
    
    set arr_mac [ixNet getAttribute $mep_item -macAddress]
    
    set arr_vlan_obj [ixNet getAttribute $mep_item -vlan]
    
    if {$arr_vlan_obj != "" && $arr_vlan_obj != [ixNet getNull]} {
        set arr_vlan_id [ixNet getAttribute $arr_vlan_obj -sVlanId]
        if {[ixNet getAttribute $arr_vlan_obj -type] == "stackedVlan"} {
            set arr_svlan_id [ixNet getAttribute $arr_vlan_obj -cVlanId]
        } else {
            set arr_svlan_id "na"
        }
    } else {
        set arr_vlan_id "na"
        set arr_svlan_id "na"
    }
    
    set arr_md_handle [ixNet getAttribute $mep_item -mdLevel]
    if {$arr_md_handle != [ixNet getNull]} {
        set arr_md_level_id [ixNet getAttribute $arr_md_handle -mdLevelId]
    } else {
        set arr_md_level_id "na"
    }
    
    set bridge_handle [::ixia::ixNetworkGetParentObjref $mep_item "bridge"]
    if {$bridge_handle != [ixNet getNull]} {
        set arr_op_mode [ixNet getAttribute $bridge_handle -operationMode]
        if {$arr_op_mode == "cfm"} {
            set arr_op_mode "ieee_802.1ag"
            set arr_mep_id [ixNet getAttribute $mep_item -mepId]
        } else {
            set arr_op_mode "itu-t_y1731"
            set arr_mep_id [ixNet getAttribute $mep_item -megId]
        }
        
        set arr_bridge_id [ixNet getAttribute $bridge_handle -bridgeId]
    } else {
        set arr_op_mode "na"
    }
    
    set arr_short_ma_name_format [ixNet getAttribute $mep_item -shortMaNameFormat]
    set arr_short_ma_name [ixNet getAttribute $mep_item -shortMaName]
    
    set tmp_status [::ixia::ixNetworkGetPortFromObj $mep_item]
    if {[keylget tmp_status status] != $::SUCCESS} {
        return $tmp_status
    }
    
    set port_handle [keylget tmp_status port_handle]
    
    set comma_idx "$port_handle,$arr_bridge_id,$arr_mep_id,$arr_op_mode,$arr_md_level_id,$arr_mac,$arr_vlan_id,$arr_svlan_id,$arr_short_ma_name_format,$arr_short_ma_name"
    
    if {![info exists mep_handles_array($comma_idx)]} {
        set mep_handles_array($comma_idx) "$mep_item,$cfm_topology_current_id"
        set mep_handles_array($mep_item,$cfm_topology_current_id) "$comma_idx"
    } else {
        set tmp_mep_list $mep_handles_array($comma_idx)
        lappend tmp_mep_list "$mep_item,$cfm_topology_current_id"
        set mep_handles_array($comma_idx) "$tmp_mep_list"
        
        foreach single_mep_h $tmp_mep_list {
            set mep_handles_array($single_mep_h,$cfm_topology_current_id) "$comma_idx"
        }
    }
    
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::oam_pop_mep_arr_entry {mep_item} {

    variable mep_handles_array

    keylset returnList status $::SUCCESS

    if {[regexp -- {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/mp:\d+} $mep_item]} {
    
        if {[llength [split $mep_item ,]] == 1} {
            set match_list [array names mep_handles_array -regexp ($mep_item,*)]
        } else {
            set match_list $mep_item
        }
        
        foreach mep_item $match_list {
            # The handle is a mep handle
            if {![info exists mep_handles_array($mep_item)]} {
                # Handle does not exist, nothing to remove
                return $returnList
            }
            
            # Get the port_handle,arr.... index for this item
            set comma_index $mep_handles_array($mep_item)
            
            if {[info exists mep_handles_array($comma_index)]} {
                
                set mep_list $mep_handles_array($comma_index)
                
                set our_mep_idx [lsearch $mep_list $mep_item]
                if {$our_mep_idx != -1} {
                    set mep_list [lreplace $mep_list $our_mep_idx $our_mep_idx]
                }
                
                if {[llength $mep_list] > 0} {
                    set mep_handles_array($comma_index) $mep_list
                } else {
                    catch {unset mep_handles_array($comma_index)}
                }
            }
            
            catch {unset mep_handles_array($mep_item)}
        }
        
    } else {
        # The handle is a  $port_handle,$arr_bridge_id,$arr_mep_id,$arr_op_mode,$arr_md_level_id,$arr_mac,$arr_vlan_id,$arr_svlan_id,$short_ma_name_format,$short_ma_name
        set comma_index $mep_item
        if {![info exists mep_handles_array($comma_index)]} {
            return $returnList
        }
        
        set mep_list $mep_handles_array($comma_index)
        
        foreach mep_single_handle $mep_list {
            catch {unset mep_handles_array($mep_single_handle)}
        }
        
        catch {unset mep_handles_array($comma_index)}
    }
    
    return $returnList
}


proc ::ixia::get_oam_learned_info {bridge_handle keyed_array_name {message_handles_to_poll {}}} {
    
    variable $keyed_array_name
    set      keyed_array_index  0
    
    if {$message_handles_to_poll == ""} {
        
        set tmp_status [::ixia::oam_refresh_messages $bridge_handle "linkTrace"]
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
        
        set stat_keys_periodic_lt {
                linktrace.transmit_ltm_count      ltmSentCount
                linktrace.receive_ltr_count       completeReplyCount
                linktrace.average_hop_count       averageHopCount
                linktrace.vlan_id_outer           cVlan
                linktrace.dst_mac_address         dstMacAddress
                linktrace.md_level                mdLevel
                linktrace.no_reply_count          noReplyCount
                linktrace.partial_reply_count     partialReplyCount
                linktrace.recent_hop_count        recentHopCount
                linktrace.recent_hops             recentHops
                linktrace.vlan_id                 sVlan
                linktrace.src_mac_address         srcMacAddress
            }
        
        debug "ixNet getList $bridge_handle periodicOamLtLearnedInfo"
        set lt_obj_list [ixNet getList $bridge_handle periodicOamLtLearnedInfo]
        
        set linktrace.state_waiting     0
        set linktrace.state_received    0
        set linktrace.state_failed      0
        
        set linktrace.transmit_ltm_count_total 0
        set linktrace.receive_ltr_count_total  0
        set linktrace.no_reply_count_total     0
        
        foreach linktrace_object $lt_obj_list {
            
            debug "ixNet getAttribute $linktrace_object -recentReplyStatus"
            set lt_item_state [ixNet getAttribute $linktrace_object -recentReplyStatus]
    
            switch -- $lt_item_state {  
                "Partial Reply" {
                    incr linktrace.state_waiting
                }
                "Complete Reply" {
                    incr linktrace.state_received
                }
                default {
                    incr linktrace.state_failed
                }
            }
            
            foreach {hlt_key ixn_key} $stat_keys_periodic_lt {
                
                debug "ixNet getAttribute $linktrace_object -$ixn_key"
                set tmp_val [ixNet getAttribute $linktrace_object -$ixn_key]
                
                switch -- $ixn_key {
                    recentHops {
                        if {$tmp_val != ""} {
                            set new_val ""
                            foreach {h1 h2 h3 h4 h5 h6} $tmp_val {
                                set hop $h1:$h2:$h3:$h4:$h5:$h6
                                lappend new_val $hop
                            }
                            set tmp_val $new_val
                        }
                    }
                    sVlan -
                    cVlan {
                        if {$tmp_val != "None"} {
                            regexp {(VLANID )(\d+)( )(.*)$} $tmp_val dummy0 dummy1 tmp_val dummy2 dummy3
                        }
                    }
                    ltmSentCount {
                        incr linktrace.transmit_ltm_count_total $tmp_val
                    }
                    completeReplyCount {
                        incr linktrace.receive_ltr_count_total  $tmp_val
                    }
                    noReplyCount {
                        incr linktrace.no_reply_count_total     $tmp_val
                    }
                }
                
                
                lappend $hlt_key $tmp_val
                
                catch {unset tmp_val}
            }
        }
        
        foreach {hlt_key ixn_key} $stat_keys_periodic_lt {
            if {![info exists $hlt_key] || $hlt_key == ""} {
                set [subst $keyed_array_name]($hlt_key) "N/A"
                incr keyed_array_index
            } else {
                set [subst $keyed_array_name]($hlt_key) [set $hlt_key]
                incr keyed_array_index
            }
        }
        
        set [subst $keyed_array_name](linktrace.state_waiting) ${linktrace.state_waiting}
        incr keyed_array_index
        
        set [subst $keyed_array_name](linktrace.state_received) ${linktrace.state_received}
        incr keyed_array_index
        
        set [subst $keyed_array_name](linktrace.state_failed) ${linktrace.state_failed}
        incr keyed_array_index
        
        set [subst $keyed_array_name](linktrace.transmit_ltm_count_total) ${linktrace.transmit_ltm_count_total}
        incr keyed_array_index
        
        set [subst $keyed_array_name](linktrace.receive_ltr_count_total) ${linktrace.receive_ltr_count_total}
        incr keyed_array_index
        
        set [subst $keyed_array_name](linktrace.no_reply_count_total) ${linktrace.no_reply_count_total}
        incr keyed_array_index
    
        debug "ixNet getList $bridge_handle periodicOamLbLearnedInfo"
        set lb_obj_list [ixNet getList $bridge_handle periodicOamLbLearnedInfo]
        
        set tmp_status [::ixia::oam_refresh_messages $bridge_handle "loopback"]
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
        
        set stat_keys_periodic_lb {
                loopback.avg_response_time       averageRtt
                loopback.transmit_lbm_count      lbmSentCount
                loopback.no_reply_count          noReplyCount
                loopback.vlan_id_outer           cVlan
                loopback.dst_mac_address         dstMacAddress
                loopback.md_level                mdLevel
                loopback.recent_reachability     recentReachability
                loopback.recent_rtt              recentRtt
                loopback.vlan_id                 sVlan
                loopback.src_mac_address         srcMacAddress
            }
        
        set loopback.transmit_lbm_count_total 0
        set loopback.receive_lbr_count_total  0
        set loopback.no_reply_count_total     0
        
        foreach loopback_object $lb_obj_list {
            foreach {hlt_key ixn_key} $stat_keys_periodic_lb {

                debug "ixNet getAttribute $loopback_object -$ixn_key"
                set tmp_val [ixNet getAttribute $loopback_object -$ixn_key]
                
                switch -- $ixn_key {
                    sVlan -
                    cVlan {
                        if {$tmp_val != "None"} {
                            regexp {(VLANID )(\d+)( )(.*)$} $tmp_val dummy0 dummy1 tmp_val dummy2 dummy3
                        }
                    }
                    lbmSentCount {
                        incr loopback.transmit_lbm_count_total $tmp_val
                    }
                    noReplyCount {
                        incr loopback.no_reply_count_total $tmp_val
                    }
                }
                
                lappend $hlt_key $tmp_val
                
                catch {unset tmp_val}
            }
        }
        
        foreach {hlt_key ixn_key} $stat_keys_periodic_lb {
            if {![info exists $hlt_key] || $hlt_key == ""} {
                set [subst $keyed_array_name]($hlt_key) "N/A"
                incr keyed_array_index
            } else {
                set [subst $keyed_array_name]($hlt_key) [set $hlt_key]
                incr keyed_array_index
            }
        }
        
        for {set lb_idx 0} {$lb_idx < [llength [set [subst $keyed_array_name](loopback.transmit_lbm_count)]]} {incr lb_idx} {
            if {[string is double [lindex [set [subst $keyed_array_name](loopback.transmit_lbm_count)] $lb_idx]] && \
                    [string is double [lindex [set [subst $keyed_array_name](loopback.no_reply_count)] $lb_idx]]} {
                
                lappend [subst $keyed_array_name](loopback.receive_lbr_count) [mpexpr \
                        [lindex [set [subst $keyed_array_name](loopback.transmit_lbm_count)] $lb_idx] - \
                        [lindex [set [subst $keyed_array_name](loopback.no_reply_count)] $lb_idx]]
                
            } else {

                lappend [subst $keyed_array_name](loopback.receive_lbr_count) "N/A"

            }
        }
        
        incr keyed_array_index
        
        set [subst $keyed_array_name](loopback.transmit_lbm_count_total) ${loopback.transmit_lbm_count_total}
        incr keyed_array_index
        
        set [subst $keyed_array_name](loopback.no_reply_count_total) ${loopback.no_reply_count_total}
        incr keyed_array_index
        
        set [subst $keyed_array_name](loopback.receive_lbr_count_total) [mpexpr \
                [set [subst $keyed_array_name](loopback.transmit_lbm_count_total)] - \
                [set [subst $keyed_array_name](loopback.no_reply_count_total)]]
                
        incr keyed_array_index

    } else {
        
        set tmp_status [::ixia::oam_refresh_messages $bridge_handle "linkTrace"]
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
        
        set match_message_handles ""
        
        set stat_keys_periodic_lt {
                linktrace.transmit_ltm_count      ltmSentCount
                linktrace.receive_ltr_count       completeReplyCount
                linktrace.average_hop_count       averageHopCount
                linktrace.vlan_id_outer           cVlan
                linktrace.dst_mac_address         dstMacAddress
                linktrace.md_level                mdLevel
                linktrace.no_reply_count          noReplyCount
                linktrace.partial_reply_count     partialReplyCount
                linktrace.recent_hop_count        recentHopCount
                linktrace.recent_hops             recentHops
                linktrace.vlan_id                 sVlan
                linktrace.src_mac_address         srcMacAddress
            }
        
        debug "ixNet getList $bridge_handle periodicOamLtLearnedInfo"
        set lt_obj_list [ixNet getList $bridge_handle periodicOamLtLearnedInfo]
        
        foreach tmp_msg_h $message_handles_to_poll {
            set $tmp_msg_h.linktrace.state_waiting     0
            set $tmp_msg_h.linktrace.state_received    0
            set $tmp_msg_h.linktrace.state_failed      0
            
            set $tmp_msg_h.linktrace.transmit_ltm_count_total 0
            set $tmp_msg_h.linktrace.receive_ltr_count_total  0
            set $tmp_msg_h.linktrace.no_reply_count_total     0
        }
        
        foreach linktrace_object $lt_obj_list {
            debug "\nInspecting Linktrace message $linktrace_object"
            set msg_h [oam_validate_message "linktrace" $linktrace_object $message_handles_to_poll]
            if {$msg_h == -1} {
                # Linktrace message not required for polling
                debug "\nLinktrace message $linktrace_object not required for polling\n"
                continue
            }
            
            if {[lsearch $match_message_handles $msg_h] == -1} {
                lappend match_message_handles $msg_h
            }
            
            debug "ixNet getAttribute $linktrace_object -recentReplyStatus"
            set lt_item_state [ixNet getAttribute $linktrace_object -recentReplyStatus]
    
            switch -- $lt_item_state {
                "Partial Reply" {
                    incr $msg_h.linktrace.state_waiting
                }
                "Complete Reply" {
                    incr $msg_h.linktrace.state_received
                }
                default {
                    incr $msg_h.linktrace.state_failed
                }
            }
            
            foreach {hlt_key ixn_key} $stat_keys_periodic_lt {
                debug "$msg_h ixNet getAttribute $linktrace_object -$ixn_key"
                
                set tmp_val [ixNet getAttribute $linktrace_object -$ixn_key]
                
                switch -- $ixn_key {
                    recentHops {
                        if {$tmp_val != ""} {
                            set new_val ""
                            foreach {h1 h2 h3 h4 h5 h6} $tmp_val {
                                set hop $h1:$h2:$h3:$h4:$h5:$h6
                                lappend new_val $hop
                            }
                            set tmp_val $new_val
                        }
                    }
                    sVlan -
                    cVlan {
                        if {$tmp_val != "None"} {
                            regexp {(VLANID )(\d+)( )(.*)$} $tmp_val dummy0 dummy1 tmp_val dummy2 dummy3
                        }
                    }
                    ltmSentCount {
                        incr $msg_h.linktrace.transmit_ltm_count_total $tmp_val
                    }
                    completeReplyCount {
                        incr $msg_h.linktrace.receive_ltr_count_total  $tmp_val
                    }
                    noReplyCount {
                        incr $msg_h.linktrace.no_reply_count_total     $tmp_val
                    }
                }
                
                lappend $msg_h.$hlt_key $tmp_val
                catch {unset tmp_val}
            }
        }
        
        foreach msg_h $match_message_handles {
            foreach {hlt_key ixn_key} $stat_keys_periodic_lt {
                if {![info exists $msg_h.$hlt_key] || [set $msg_h.$hlt_key] == ""} {
                    set [subst $keyed_array_name]($msg_h.$hlt_key) "N/A"
                    incr keyed_array_index
                } else {
                    set [subst $keyed_array_name]($msg_h.$hlt_key) [set $msg_h.$hlt_key]
                    incr keyed_array_index
                }
            }
            
            set [subst $keyed_array_name]($msg_h.linktrace.state_waiting) [set $msg_h.linktrace.state_waiting]
            incr keyed_array_index
            
            set [subst $keyed_array_name]($msg_h.linktrace.state_received) [set $msg_h.linktrace.state_received]
            incr keyed_array_index
            
            set [subst $keyed_array_name]($msg_h.linktrace.state_failed) [set $msg_h.linktrace.state_failed]
            incr keyed_array_index
            
            set [subst $keyed_array_name]($msg_h.linktrace.transmit_ltm_count_total) [set $msg_h.linktrace.transmit_ltm_count_total]
            incr keyed_array_index
            
            set [subst $keyed_array_name]($msg_h.linktrace.receive_ltr_count_total) [set $msg_h.linktrace.receive_ltr_count_total]
            incr keyed_array_index
            
            set [subst $keyed_array_name]($msg_h.linktrace.no_reply_count_total) [set $msg_h.linktrace.no_reply_count_total]
            incr keyed_array_index
            
        }
        
        set tmp_status [::ixia::oam_refresh_messages $bridge_handle "loopback"]
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
        
        set match_message_handles ""
    
        debug "ixNet getList $bridge_handle periodicOamLbLearnedInfo"
        set lb_obj_list [ixNet getList $bridge_handle periodicOamLbLearnedInfo]
        
        set stat_keys_periodic_lb {
                loopback.avg_response_time       averageRtt
                loopback.transmit_lbm_count      lbmSentCount
                loopback.no_reply_count          noReplyCount
                loopback.vlan_id_outer           cVlan
                loopback.dst_mac_address         dstMacAddress
                loopback.md_level                mdLevel
                loopback.recent_reachability     recentReachability
                loopback.recent_rtt              recentRtt
                loopback.vlan_id                 sVlan
                loopback.src_mac_address         srcMacAddress
            }
        
        foreach tmp_msg_h $message_handles_to_poll {

            set $tmp_msg_h.loopback.transmit_lbm_count_total  0
            set $tmp_msg_h.loopback.receive_lbr_count_total   0
            set $tmp_msg_h.loopback.no_reply_count_total      0

        }
        
        foreach loopback_object $lb_obj_list {
            
            set msg_h [oam_validate_message "loopback" $loopback_object $message_handles_to_poll]
            if {$msg_h == -1} {
                # Loopback message not required for polling
                debug "\Loopback message $loopback_object not required for polling\n"
                continue
            }
            
            if {[lsearch $match_message_handles $msg_h] == -1} {
                lappend match_message_handles $msg_h
            }
            
            foreach {hlt_key ixn_key} $stat_keys_periodic_lb {
                debug "$msg_h - ixNet getAttribute $loopback_object -$ixn_key"
                set tmp_val [ixNet getAttribute $loopback_object -$ixn_key ]
                
                switch -- $ixn_key {
                    sVlan -
                    cVlan {
                        if {$tmp_val != "None"} {
                            regexp {(VLANID )(\d+)( )(.*)$} $tmp_val dummy0 dummy1 tmp_val dummy2 dummy3
                        }
                    }
                    lbmSentCount {
                        incr $msg_h.loopback.transmit_lbm_count_total $tmp_val
                    }
                    noReplyCount {
                        incr $msg_h.loopback.no_reply_count_total $tmp_val
                    }
                }
                
                lappend $msg_h.$hlt_key $tmp_val
                
                catch {unset tmp_val}
            }
        }
        
        foreach msg_h $match_message_handles {
            foreach {hlt_key ixn_key} $stat_keys_periodic_lb {
                if {![info exists $msg_h.$hlt_key] || [set $msg_h.$hlt_key] == ""} {
                    
                    set [subst $keyed_array_name]($msg_h.$hlt_key) "N/A"
                    incr keyed_array_index

                } else {
                    
                    set [subst $keyed_array_name]($msg_h.$hlt_key) [set $msg_h.$hlt_key]
                    incr keyed_array_index
                }
            }
            
            
            for {set lb_idx 0} {$lb_idx < [llength [set [subst $keyed_array_name]($msg_h.loopback.transmit_lbm_count)]]} {incr lb_idx} {
                if {[string is double [lindex [set [subst $keyed_array_name]($msg_h.loopback.transmit_lbm_count)] $lb_idx]] && \
                        [string is double [lindex [set [subst $keyed_array_name]($msg_h.loopback.no_reply_count)] $lb_idx]]} {
                    
                    lappend [subst $keyed_array_name]($msg_h.loopback.receive_lbr_count) [mpexpr \
                            [lindex [set [subst $keyed_array_name]($msg_h.loopback.transmit_lbm_count)] $lb_idx] - \
                            [lindex [set [subst $keyed_array_name]($msg_h.loopback.no_reply_count)] $lb_idx]]
                    
                } else {
                
                    lappend [subst $keyed_array_name]($msg_h.loopback.receive_lbr_count) "N/A"
                    
                }
            }

            incr keyed_array_index
            
            set [subst $keyed_array_name]($msg_h.loopback.transmit_lbm_count_total)    [set $msg_h.loopback.transmit_lbm_count_total]
            incr keyed_array_index
            
            set [subst $keyed_array_name]($msg_h.loopback.no_reply_count_total)        [set $msg_h.loopback.no_reply_count_total]
            incr keyed_array_index
            
            set [subst $keyed_array_name]($msg_h.loopback.receive_lbr_count_total) [mpexpr \
                    [set [subst $keyed_array_name]($msg_h.loopback.transmit_lbm_count_total)] - \
                    [set [subst $keyed_array_name]($msg_h.loopback.no_reply_count_total)]]
            incr keyed_array_index
            
        }
    }
    keylset ret_list stat_count $keyed_array_index
    keylset ret_list status $::SUCCESS
    return $ret_list
}

proc ::ixia::get_oam_ccdb_learned_info {bridge_handle keyed_array_name} {

    variable $keyed_array_name
    set      keyed_array_index  0

    set stat_keys {
              md_name                   mdName
              mep_id                    mepId
              short_ma_name             shortMaName
              remote_failure_indicator  someRmepDefect
              ccm_interval              cciInterval
              short_maname_format       shortMaNameFormat
              all_rmep_dead             allRmepDead
              err_ccm_defect            errCcmDefect
              md_name_format            mdNameFormat
              out_ofsequence_ccm_count  outOfSequenceCcmCount
              received_ais              receivedAis
              received_iface_tlv_defect receivedIfaceTlvDefect
              received_port_tlv_defect  receivedPortTlvDefect
              received_rdi              receivedRdi
              rmep_ccm_defect           rmepCcmDefect
        }
    
    
    
    
    # refresh loopback info
    debug "ixNet exec refreshCcmLearnedInfo $bridge_handle"
    if {[catch {ixNet exec refreshCcmLearnedInfo $bridge_handle} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to $exec_call. $err"
        return $returnList
    }
    
    # check if info was learnt
    set retry_count 100
    for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
        debug "ixNet getAttribute $bridge_handle -isCcmLearnedInfoRefreshed"
        set msg [ixNet getAttribute $bridge_handle -isCcmLearnedInfoRefreshed]
        if {$msg == "true"} {
            break
        }
        
        after 500
    }
    
    if {$iteration >= 15} {
        keylset returnList status $::FAILURE
        keylset returnList log "Statistics are not available."
        return $returnList
    }
    
    after 1000
    
    debug "ixNet getList $bridge_handle ccmLearnedInfo"
    set info_obj_list [ixNet getList $bridge_handle ccmLearnedInfo]
    foreach info_obj $info_obj_list {
        
        set vlan_outer [ixNet getAttribute $info_obj -cVlan]
        if {$vlan_outer == "None" || $vlan_outer == "VLANID 0 TPID 0x0 Priority 0"} {
            set vlan_outer "na"
        } else {
            regexp {(VLANID )(\d+)( )(.*)$} $vlan_outer dummy0 dummy1 vlan_outer dummy2 dummy3
        }

        set vlan       [ixNet getAttribute $info_obj -sVlan]
        if {$vlan == "None" || $vlan =="VLANID 0 TPID 0x0 Priority 0"} {
            set vlan "na"
        } else {
            regexp {(VLANID )(\d+)( )(.*)$} $vlan dummy0 dummy1 vlan dummy2 dummy3
        }
        
        debug "ixNet getAttribute $info_obj -mdLevel"
        set md_level [ixNet getAttribute $info_obj -mdLevel]
        
        debug "ixNet getAttribute $info_obj -mepMacAddress"
        set mac      [ixNet getAttribute $info_obj -mepMacAddress]
        
        set mac [ixNetworkFormatMac $mac]
        
        set local_key md_level.$md_level.mac.$mac
        
        foreach {hlt_key ixn_key} $stat_keys {
            debug "ixNet getAttribute $info_obj -$ixn_key"
            set ixn_key_value [ixNet getAttribute $info_obj -$ixn_key]
            
            if {$ixn_key_value == ""} {
                set [subst $keyed_array_name]($local_key.$hlt_key) "N/A"
                incr keyed_array_index
            } else {
                set [subst $keyed_array_name]($local_key.$hlt_key) $ixn_key_value
                incr keyed_array_index
            }
            
        }
        
        set [subst $keyed_array_name]($local_key.vlan) $vlan
        incr keyed_array_index
        
        set [subst $keyed_array_name]($local_key.vlan_outer) $vlan_outer
        incr keyed_array_index
    }
    
    keylset ret_list stat_count $keyed_array_index
    keylset ret_list status $::SUCCESS
    return $ret_list
}


proc ::ixia::get_oam_aggregate_stats {port_handles action ret_list_name} {
    
    keylset returnList status $::SUCCESS
    
    upvar $ret_list_name return_list
    
    if {$action == "get_topology_stats"} {

        array set stats_array_aggregate {
            "Port Name"                               aggregate.topology_stats.port_name
            "MEPs Configured"                         aggregate.topology_stats.total_maintenance_points
            "MEPs Running"                            aggregate.topology_stats.operational_maintenance_points
            "Bridges Configured"                      aggregate.topology_stats.total_entries
            "Bridges Running"                         aggregate.topology_stats.start_entries
            "RMEP Ok"                                 aggregate.topology_stats.ok_entries
            "RMEP Error Defect"                       aggregate.topology_stats.fail_entries
            "MAs Configured"                          aggregate.topology_stats.ma_configured
            "MAs Running"                             aggregate.topology_stats.ma_running
            "Remote MEPs"                             aggregate.topology_stats.remote_meps
            "Defective RMEPS"                         aggregate.topology_stats.rmeps_defective
            "RMEP Error NoDefect"                     aggregate.topology_stats.rmep_error_no_defect
            "MEP FNG Reset"                           aggregate.topology_stats.mep_fng_reset
            "MEP FNG Defect"                          aggregate.topology_stats.mep_fng_defect
            "MEP FNG DefectReported"                  aggregate.topology_stats.mep_fng_defect_reported
            "MEP FNG DefectClearing"                  aggregate.topology_stats.mep_fng_defect_clearing
        }
        
    } else {
        array set stats_array_aggregate {
            "Packet Rx"            aggregate.rx.fm_pkts
            "LBM Rx"               aggregate.rx.lbm_pkts
            "LTM Rx"               aggregate.rx.ltm_pkts
            "CCM Rx"               aggregate.rx.ccm_pkts
            "AIS Rx"               aggregate.rx.ais_pkts
            "Packet Tx"            aggregate.tx.fm_pkts
            "LBM Tx"               aggregate.tx.lbm_pkts
            "LTM Tx"               aggregate.tx.ltm_pkts
            "CCM Tx"               aggregate.tx.ccm_pkts
            "AIS Tx"               aggregate.tx.ais_pkts
            "Invalid LBM Rx"       aggregate.error.lbm_pkts
            "Invalid LBR Rx"       aggregate.error.lbr_pkts
            "Invalid LTM Rx"       aggregate.error.ltm_pkts
            "Invalid CCM Rx"       aggregate.error.ccm_pkts
            "CCM Unexpected Period" aggregate.detected_failure_stats.unexpected_cc_period
            "LTR Rx"               aggregate.rx.ltr_pkts
            "LTR Tx"               aggregate.tx.ltr_pkts
            "LBR Tx"               aggregate.tx.lbr_pkts
            "LBR Rx"               aggregate.rx.lbr_pkts
            "Invalid LBM Rx"       aggregate.error.lbm_rx_invalid
            "Invalid LTR Rx"       aggregate.error.ltr_rx_invalid
            "Out of Sequence CCM Rx"   aggregate.rx.ccm_out_of_sequence
        }
        
    }
    
    set statistic_types {
        aggregate "CFM Aggregated Statistics"
    }
    
    foreach {stat_type stat_name} $statistic_types {
        set stats_array_name stats_array_${stat_type}
        array set stats_array [array get $stats_array_name]
    
        set returned_stats_list [ixNetworkGetStats \
                $stat_name [array names stats_array]]
        if {[keylget returned_stats_list status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to read\
                    $stat_name from stat view browser.\
                    [keylget returned_stats_list log]"
            return $returnList
        }
        
        set found_ports ""
        set row_count [keylget returned_stats_list row_count]
        array set rows_array [keylget returned_stats_list statistics]
        
        for {set i 1} {$i <= $row_count} {incr i} {
            set row_name $rows_array($i)
            set match [regexp {(.+)/Card([0-9]{2})/Port([0-9]{2})} \
                    $row_name match_name hostname card_no port_no]
            if {$match && [catch {set chassis_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                set chassis_ip $hostname
            }
            if {$match && ($match_name == $row_name) && \
                    [info exists chassis_ip] && [info exists card_no] && \
                    [info exists port_no] } {
                set chassis_no [ixNetworkGetChassisId $chassis_ip]
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to interpret the '$row_name'\
                        row name."
                return $returnList
            }
            regsub {^0} $card_no "" card_no
            regsub {^0} $port_no "" port_no
            if {[lsearch $port_handles "$chassis_no/$card_no/$port_no"] != -1} {
                set port_key $chassis_no/$card_no/$port_no
                lappend found_ports $port_key
                foreach stat [array names stats_array] {
                    if {[info exists rows_array($i,$stat)] && \
                            $rows_array($i,$stat) != ""} {
                        keylset return_list $stats_array($stat) \
                                $rows_array($i,$stat)
                    } else {
                        keylset return_list $stats_array($stat) "N/A"
                    }
                }
            }
        }
        if {[llength [lsort -unique $found_ports]] != \
                [llength [lsort -unique $port_handles]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Retrieved statistics only for the\
                    following ports: $found_ports."
            return $returnList
        }
    }
    
    return $returnList
}

proc ::ixia::oam_add_vlan_node {
    macRangeAddr
    parentObjRef
    child
    {attributeList {}}
    {commit -no_commit}
    } {
    
    variable cfm_vlan_handles_array
    
    foreach {p_name p_value} $attributeList {
        regexp -all {(^\-)(\w+)(.*)$} $p_name dummy0 dummy1 p_name
        set $p_name [string trim $p_value]
    }
    
    set hlt_port_handle [ixNetworkGetPortFromObj $parentObjRef]
    if {[keylget hlt_port_handle status] != $::SUCCESS} {
        return $hlt_port_handle
    }
    
    set hlt_port_handle [keylget hlt_port_handle port_handle]

    # port_handle,bridge_handle,type,sVlanId,sVlanTpId,cVlanId,cVlanTpId
    set search_string "$hlt_port_handle,$parentObjRef,$type,"
    
    if {[info exists sVlanId]} {
        append search_string "$sVlanId,"
    } else {
        append search_string "na,"
    }
    
    if {[info exists sVlanTpId]} {
        append search_string "$sVlanTpId,"
    } else {
        append search_string "na,"
    }
    
    if {[info exists cVlanId]} {
        append search_string "$cVlanId,"
    } else {
        append search_string "na,"
    }
    
    if {[info exists cVlanTpId]} {
        append search_string "$cVlanTpId"
    } else {
        append search_string "na"
    }
    
    if {[info exists cfm_vlan_handles_array($search_string)]} {
        
        set vlan_handle $cfm_vlan_handles_array($search_string)
        keylset returnList node_objref $vlan_handle
        keylset returnList status $::SUCCESS
    
    } else {
        
        set tmp_status [::ixia::ixNetworkNodeAdd                            \
                $parentObjRef                                               \
                $child                                                      \
                $attributeList                                              \
                -commit                                                     \
            ]
        if {[keylget tmp_status status] != $::SUCCESS} {
            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
            return $tmp_status
        }
        
        set vlan_handle [keylget tmp_status node_objref]
        
        set cfm_vlan_handles_array($search_string) $vlan_handle
        
        set returnList $tmp_status
    }
    
    # Verify if a macRange with $macRangeAddr already exists on this vlan handle
    # Create it if not
    set mr_found 0
    foreach macRange [ixNet getList $vlan_handle macRanges] {
        if {[ixNet getAttribute $macRange -macAddress] == $macRangeAddr} {
            set mr_found $macRange
            break
        }
    }
    
    if {$mr_found != 0} {
        keylset returnList mac_handle $mr_found
    } else {
        # Create it
        set tmp_status [::ixia::ixNetworkNodeAdd                            \
                $vlan_handle                                                \
                "macRanges"                                                 \
                [list -enabled true -macAddress [ixNetworkFormatMac $macRangeAddr]]\
                -commit                                                     \
            ]
        if {[keylget tmp_status status] != $::SUCCESS} {
            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
            return $tmp_status
        }
        
        set mac_handle [keylget tmp_status node_objref]
        keylset returnList mac_handle $mac_handle
    }

    return $returnList
}


proc ::ixia::oam_add_md_level_node {
    parentObjRef
    child
    {attributeList {}}
    {commit -no_commit}
    } {
    
    variable cfm_mdlevel_handles_array
    
    foreach {p_name p_value} $attributeList {
        regexp -all {(^\-)(\w+)(.*)$} $p_name dummy0 dummy1 p_name
        set $p_name [string trim $p_value]
    }
    
    set hlt_port_handle [ixNetworkGetPortFromObj $parentObjRef]
    if {[keylget hlt_port_handle status] != $::SUCCESS} {
        return $hlt_port_handle
    }
    
    set hlt_port_handle [keylget hlt_port_handle port_handle]

    # port_handle,bridge_handle,mdLevelId,mdNameFormat,mdName
    set search_string "$hlt_port_handle,$parentObjRef,"
    
    if {[info exists mdLevelId]} {
        append search_string "$mdLevelId,"
    } else {
        append search_string "na,"
    }
    
    if {[info exists mdNameFormat]} {
        append search_string "$mdNameFormat,"
    } else {
        append search_string "na,"
    }
    
    if {[info exists mdName]} {
        append search_string "$mdName"
    } else {
        append search_string "na"
    }
    
    if {[info exists cfm_mdlevel_handles_array($search_string)]} {
        
        set mdLevel_handle $cfm_mdlevel_handles_array($search_string)
        keylset returnList node_objref $mdLevel_handle
        keylset returnList status $::SUCCESS
        return $returnList
    
    } else {
        
        set tmp_status [::ixia::ixNetworkNodeAdd                            \
                $parentObjRef                                               \
                $child                                                      \
                $attributeList                                              \
                -commit                                                     \
            ]
        if {[keylget tmp_status status] != $::SUCCESS} {
            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
            return $tmp_status
        }
        
        set mdLevel_handle [keylget tmp_status node_objref]
        
        set cfm_mdlevel_handles_array($search_string) $mdLevel_handle
        
        return $tmp_status
    }
}


proc ::ixia::oam_print_mep_details {search_string} {
    set config_prop_names [list Port "Bridge ID" "Mep ID" "OAM Standard"\
    "MD Level" "Maintenance Point MAC Address" "Vlan ID" "QinQ Vlan ID"]
    set idx 0
    
    regsub -all {\(\[\^,\]\*\)} $search_string "Any" search_string
    
    foreach cfg_entry [split $search_string ,] {
        if {$cfg_entry == "na"} {
            set cfg_entry "None"
        } elseif {$cfg_entry == "(\[^,\]*)"} {
            set cfg_entry "Any"
        }
        
        puts [format {%-8s%-35s%-s} "" [lindex $config_prop_names $idx] $cfg_entry]
        
        incr idx
        
        if {[expr $idx + 1] > [llength $config_prop_names]} {
            break
        }
    }
    catch {unset idx}
}


proc ::ixia::oam_get_bridge_handles_from_messages {list_of_msg_handles} {
    variable cfm_message_handles_array
    variable mep_handles_array
    
    set search_id [array startsearch cfm_message_handles_array]
    
    set queried_pairs           ""
    set return_bridge_handles   ""
    
    debug "\nProcessing bridge handles to poll based on message handles"
    
    while {[array anymore cfm_message_handles_array $search_id]} {
        set current_item [array nextelement cfm_message_handles_array $search_id]
        
        if {[lsearch $list_of_msg_handles $cfm_message_handles_array($current_item)] == -1} {
            continue
        }
        
        debug "\tMessage handle $cfm_message_handles_array($current_item) found in internal array."

        foreach {port_id bridge_id mp_id oam_standard md_level mp_mac vlan svlan short_ma_name_format short_ma_name msg_type msg_dst} [split $current_item ,] {}

        if {[lsearch $queried_pairs "$port_id,$bridge_id"] != -1} {
            continue
        }
        
        set mep_search_string "$port_id,$bridge_id,$mp_id,$oam_standard,$md_level,$mp_mac,$vlan,$svlan,$short_ma_name_format,$short_ma_name"
        
        if {![info exists mep_handles_array($mep_search_string)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. The following MEP could not be found in\
                    internal array: $mep_search_string"
            
            return $returnList
        }
        
        set mp_handle [lindex [split $mep_handles_array($mep_search_string) ,] 0]
        
        lappend return_bridge_handles [ixNetworkGetParentObjref $mp_handle]
        
        lappend queried_pairs "$port_id,$bridge_id"
        debug "\tPort,bridge pair for message is '$port_id,$bridge_id'"
    }
    
    array donesearch cfm_message_handles_array $search_id
    
    keylset returnList status $::SUCCESS
    keylset returnList bridge_handles $return_bridge_handles
    return  $returnList
}


proc ::ixia::oam_validate_message {msg_type msg_info_obj msg_handles} {
    
    variable cfm_message_handles_array
    
    set search_string ""
    
#   $port_id,$bridge_id,$mp_id,$oam_standard,$md_level,$mp_mac,$vlan,$svlan,$msg_type,$dst_mac

    set tmp_status [::ixia::ixNetworkGetPortFromObj $msg_info_obj]
    if {[keylget tmp_status status] != $::SUCCESS} {
        return -1
    }
    
    set port_handle  [keylget tmp_status port_handle]
    set vport_handle [keylget tmp_status vport_objref]
    
    append search_string "$port_handle"
    
    set bridge_handle [ixNetworkGetParentObjref $msg_info_obj]
    set bridge_id [ixNet getAttribute $bridge_handle -bridgeId]
    
    append search_string ",$bridge_id,(\[^,\]*),(\[^,\]*)"
    
    set md_level [ixNet getA $msg_info_obj -mdLevel]
    append search_string ",$md_level"
    
    set mp_mac [ixNet getA $msg_info_obj -srcMacAddress]
    append search_string ",$mp_mac"
    
    set vlan_string [ixNet getA $msg_info_obj -sVlan]
    if {$vlan_string == "None" || $vlan_string == "VLANID 0 TPID 0x0 Priority 0"} {
        append search_string ",na"
    } else {
        
        if {![regexp {(VLANID )(\d+)( )(.*)$} $vlan_string dummy0 dummy1 vlan_id dummy2 dummy3]} {
            debug "ERROR when parsing vlan string $vlan_string regexp {(VLAN )(\d+)( )(.*)$} $vlan_string"
            return -1
        }
        
        if {![string is integer $vlan_id]} {
            debug "ERROR when parsing vlan string $vlan_string regexp {(VLAN )(\d+)( )(.*)$} $vlan_string.\
                    vlan_id $vlan_id is not numeric"
            return -1
        }
        
        append search_string ",$vlan_id"
    }
    
    set vlan_string [ixNet getA $msg_info_obj -cVlan]
    if {$vlan_string == "None" || $vlan_string == "VLANID 0 TPID 0x0 Priority 0"} {
        append search_string ",na"
    } else {
        
        if {![regexp {(VLANID )(\d+)( )(.*)$} $vlan_string dummy0 dummy1 vlan_id dummy2 dummy3]} {
            debug "ERROR when parsing vlan string $vlan_string regexp {(VLAN )(\d+)( )(.*)$} $vlan_string"
            return -1
        }
        
        if {![string is integer $vlan_id]} {
            debug "ERROR when parsing vlan string $vlan_string regexp {(VLAN )(\d+)( )(.*)$} $vlan_string.\
                    vlan_id $vlan_id is not numeric"
            return -1
        }
        
        append search_string ",$vlan_id"
    }
    
    append search_string ",(\[^,\]*),(\[^,\]*),$msg_type,(\[^,\]*)"
    
    set dst_mac_info [ixNet getAttribute $msg_info_obj -dstMacAddress]
    
    debug "\nValidate message --> search_string == $search_string"
    
    foreach match_msg_handle [array names cfm_message_handles_array -regexp ($search_string)] {
        debug "\tProcessing handle $search_string"
        set dst_mac_msg [lindex [split $match_msg_handle ,] end]

        if {$dst_mac_msg == "all" || $dst_mac_msg == $dst_mac_info} {
            set msg_handle $cfm_message_handles_array($match_msg_handle)
            debug "\tFound message handle $msg_handle"
            if {[lsearch $msg_handles $msg_handle] != -1} {
                debug "\tMessage handle $msg_handle matched requested handle list"
                return $msg_handle
            } else {
                debug "\tMessage handle $msg_handle was not requested. Not returning it."
                catch {unset msg_handle}
            }
        }
    }
    
    return -1
}


proc ::ixia::oam_refresh_messages {bridge_handle message_type} {

    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
            $bridge_handle                                          \
            [list -userPeriodicOamType $message_type]               \
            -commit                                                 \
        ]
        
    if {[keylget tmp_status status] != $::SUCCESS} {
        return $tmp_status
    }
    
    # refresh linktrace info
    debug "ixNet exec updatePeriodicOamLearnedInfo $bridge_handle"
    if {[catch {ixNet exec updatePeriodicOamLearnedInfo $bridge_handle} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to $exec_call. $err"
        return $returnList
    }
    
    # check if info was learnt
    set retry_count 100
    for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
        debug "ixNet getAttribute $bridge_handle -isPeriodicOamLearnedInfoRefreshed"
        set msg [ixNet getAttribute $bridge_handle -isPeriodicOamLearnedInfoRefreshed]
        if {$msg == "true"} {
            break
        }
        
        after 500
    }
    
    if {$iteration >= 15} {
        keylset returnList status $::FAILURE
        keylset returnList log "Statistics session messages stats are not available."
        return $returnList
    }
    
    after 1000
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::get_oam_ccdb_learned_info_per_topo {bridge_handle keyed_array_name topology_handles} {
    
    variable mep_handles_array
    
    variable $keyed_array_name
    set      keyed_array_index  0

    set stat_keys {
              md_name                   mdName
              mep_id                    mepId
              short_ma_name             shortMaName
              remote_failure_indicator  someRmepDefect
              ccm_interval              cciInterval
              short_maname_format       shortMaNameFormat
              all_rmep_dead             allRmepDead
              err_ccm_defect            errCcmDefect
              md_name_format            mdNameFormat
              out_ofsequence_ccm_count  outOfSequenceCcmCount
              received_ais              receivedAis
              received_iface_tlv_defect receivedIfaceTlvDefect
              received_port_tlv_defect  receivedPortTlvDefect
              received_rdi              receivedRdi
              rmep_ccm_defect           rmepCcmDefect
        }
    
    
    
    
    # refresh loopback info
    debug "ixNet exec refreshCcmLearnedInfo $bridge_handle"
    if {[catch {ixNet exec refreshCcmLearnedInfo $bridge_handle} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to $exec_call. $err"
        return $returnList
    }
    
    # check if info was learnt
    set retry_count 100
    for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
        debug "ixNet getAttribute $bridge_handle -isCcmLearnedInfoRefreshed"
        set msg [ixNet getAttribute $bridge_handle -isCcmLearnedInfoRefreshed]
        if {$msg == "true"} {
            break
        }
        
        after 500
    }
    
    if {$iteration >= 15} {
        keylset returnList status $::FAILURE
        keylset returnList log "Statistics are not available."
        return $returnList
    }
    
    after 1000
    
    # We should build the array index found in mep_handles_array and match it
    # against our handles
    # "$port_handle,$arr_bridge_id,$arr_mep_id,$arr_op_mode,$arr_md_level_id,$arr_mac,$arr_vlan_id,$arr_svlan_id,$short_ma_name_format,$short_ma_name
    set bridge_id [ixNet getAttribute $bridge_handle -bridgeId]
    set bridge_id [ixNetworkFormatMac $bridge_id]
    
    set p_h_status [::ixia::ixNetworkGetPortFromObj $bridge_handle]
    if {[keylget p_h_status status] != $::SUCCESS} {
        return $p_h_status
    }
    set real_port [keylget p_h_status port_handle]
    
    
    debug "ixNet getList $bridge_handle ccmLearnedInfo"
    set info_obj_list [ixNet getList $bridge_handle ccmLearnedInfo]
    foreach info_obj $info_obj_list {
        debug "ixNet getAttribute $info_obj -mdLevel"
        set md_level [ixNet getAttribute $info_obj -mdLevel]
        
        set vlan_outer [ixNet getAttribute $info_obj -cVlan]
        
        if {$vlan_outer == "None" || $vlan_outer == "VLANID 0 TPID 0x0 Priority 0"} {
            set vlan_outer "na"
        } else {
            regexp {(VLANID )(\d+)( )(.*)$} $vlan_outer dummy0 dummy1 vlan_outer dummy2 dummy3
        }

        set vlan       [ixNet getAttribute $info_obj -sVlan]
        if {$vlan == "None" || $vlan == "VLANID 0 TPID 0x0 Priority 0"} {
            set vlan "na"
        } else {
            regexp {(VLANID )(\d+)( )(.*)$} $vlan dummy0 dummy1 vlan dummy2 dummy3
        }
        
        set topology_handle -1
        
        debug "array names mep_handles_array -regexp \
                ($real_port,$bridge_id,(\[^,\]*),(\[^,\]*),$md_level,(\[^,\]*),$vlan,$vlan_outer,(\[^,\]*),(\[^,\]*))"
        
        foreach array_entry [array names mep_handles_array -regexp \
                ($real_port,$bridge_id,(\[^,\]*),(\[^,\]*),$md_level,(\[^,\]*),$vlan,$vlan_outer,(\[^,\]*),(\[^,\]*))] {
            
            debug "array_entry == $array_entry"
            
            set array_mp_handle [lindex [split $mep_handles_array($array_entry) ,] 0]
            set array_topo_unique_id [lindex [split $mep_handles_array($array_entry) ,] 1]
            
            set array_mp_handle [ixNetworkGetParentObjref $array_mp_handle]
            
            if {[lsearch $topology_handles "$array_mp_handle,$array_topo_unique_id"] != -1} {
                set topology_handle $array_mp_handle,$array_topo_unique_id
                break
            }
        }
        
        if {$topology_handle == -1} {
            continue
        }
        
        debug "ixNet getAttribute $info_obj -mepMacAddress"
        set mac [ixNet getAttribute $info_obj -mepMacAddress]
        
        set mac [ixNetworkFormatMac $mac]
        
        set local_key $topology_handle.md_level.$md_level.mac.$mac
        
        foreach {hlt_key ixn_key} $stat_keys {
            debug "ixNet getAttribute $info_obj -$ixn_key"
            set ixn_key_value [ixNet getAttribute $info_obj -$ixn_key]
            
            if {$ixn_key_value == ""} {

                set [subst $keyed_array_name]($local_key.$hlt_key) "N/A"
                incr keyed_array_index

            } else {

                set [subst $keyed_array_name]($local_key.$hlt_key) $ixn_key_value
                incr keyed_array_index
            }
            
        }
        
        set [subst $keyed_array_name]($local_key.vlan) $vlan
        incr keyed_array_index
        
        set [subst $keyed_array_name]($local_key.vlan_outer) $vlan_outer
        incr keyed_array_index
    }
    
    keylset ret_list stat_count $keyed_array_index
    keylset ret_list status $::SUCCESS
    return $ret_list
}
