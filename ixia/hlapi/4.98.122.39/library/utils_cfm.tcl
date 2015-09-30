proc ::ixia::cfm_tlv_formatter {tlv_value tlv_length tlv_value_step counter} {
    
    keylset returnList status $::SUCCESS
    
    # Load the variables
    set upvar_list [list tlv_value tlv_length tlv_value_step counter]
    
    foreach var $upvar_list {
        upvar [set $var] upvar_$var
    }
    
    # check hex values
    if {![isValidHex $upvar_tlv_value $upvar_tlv_length]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Parameter -$tlv_value $upvar_tlv_value is not a\
                valid HEX number of $upvar_tlv_length octets."
        return $returnList
    }
    
    if {![isValidHex $upvar_tlv_value_step $upvar_tlv_length]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Parameter -$tlv_value_step $upvar_tlv_value_step is not a\
                valid HEX number of $upvar_tlv_length octets."
        return $returnList
    }
    
    # transform from any hex format to list format {00 11 22}
    set upvar_tlv_value [::ixia::hex2list $upvar_tlv_value]
    
    # transform from list format to 0x001122 format
    set upvar_tlv_value "0x[regsub -all { } $upvar_tlv_value {}]"
    
    # transform from any hex format to list format {00 11 22}
    set upvar_tlv_value_step [::ixia::hex2list $upvar_tlv_value_step]
    
    # transform from list format to 0x001122 format
    set upvar_tlv_value_step "0x[regsub -all { } $upvar_tlv_value_step {}]"
    
    if {$upvar_counter > 0} {
        set incr_ammount [mpexpr $upvar_tlv_value_step * $upvar_counter]
        set ixn_param_value [mpexpr $upvar_tlv_value + $incr_ammount]
        set ixn_param_value [mpformat %x $ixn_param_value]
        set ixn_param_value \{[format_hex $ixn_param_value [mpexpr $upvar_tlv_length * 8] ]\}
    } else {
        set ixn_param_value \{[format_hex $upvar_tlv_value [mpexpr $upvar_tlv_length * 8] ]\}
    }
    
    keylset returnList ixn_param_value $ixn_param_value
    return $returnList
}

proc ::ixia::cfm_mac_incr {mac_address mac_address_step counter} {
    
    keylset returnList status $::SUCCESS
    
    # Load the variables
    set upvar_list [list mac_address mac_address_step counter]
    
    foreach var $upvar_list {
        upvar [set $var] upvar_$var
    }
    
    if {![isValidMacAddress $upvar_mac_address]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid mac address value $upvar_mac_address for\
                $mac_address parameter."
        return $returnList
    }
    
    set upvar_mac_address [convertToIxiaMac $upvar_mac_address]
    
    if {![isValidMacAddress $upvar_mac_address_step]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid mac address value $upvar_mac_address_step for\
                $mac_address_step parameter."
        return $returnList
    }
    
    set upvar_mac_address_step [convertToIxiaMac $upvar_mac_address_step]
    
    set ixn_param_value $upvar_mac_address
    for {set i 0} {$i < $upvar_counter} {incr i} {
        set ixn_param_value [incrementMacAdd $ixn_param_value $upvar_mac_address_step]
    }
    
    set ixn_param_value [ixNetworkFormatMac $ixn_param_value]
    
    keylset returnList ixn_param_value $ixn_param_value
    return $returnList
}

proc ::ixia::cfm_incr_field {field field_step counter} {
    
    keylset returnList status $::SUCCESS
    
    # Load the variables
    set upvar_list [list field field_step counter]
    
    foreach var $upvar_list {
        upvar [set $var] upvar_$var
    }
    
    set incr_amount [mpexpr $upvar_field_step * $upvar_counter]
    
    set ixn_param_value [mpexpr $upvar_field + $incr_amount]
    
    keylset returnList ixn_param_value $ixn_param_value
    return $returnList
}

proc ::ixia::cfm_short_ma_name_check {short_ma_name short_ma_name_format} {
    
    keylset returnList status $::SUCCESS
    
    # Load the variables
    set upvar_list [list short_ma_name short_ma_name_format]
    
    foreach var $upvar_list {
        upvar [set $var] upvar_$var
    }
    
    set ixn_param_value $upvar_short_ma_name
    
    switch -- $upvar_short_ma_name_format {
        "primary_vid" -
        "primaryVid" {
            if {![string is integer $ixn_param_value]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $short_ma_name $ixn_param_value. When\
                        $short_ma_name_format is $upvar_short_ma_name_format $short_ma_name\
                        must be a number from 0 to 4095."
                return $returnList
            }
            
            if {$ixn_param_value < 0 || $ixn_param_value > 4095} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $short_ma_name $ixn_param_value. When\
                        $short_ma_name_format is $upvar_short_ma_name_format $short_ma_name\
                        must be a number from 0 to 4095."
                return $returnList
            }
        }
        "char_string" -
        "characterString" {
            # anything goes
        }
        "2_octet_integer" -
        "2octetInteger" {
            if {![string is integer $ixn_param_value]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $short_ma_name $ixn_param_value. When\
                        $short_ma_name_format is $upvar_short_ma_name_format $short_ma_name\
                        must be a number from 0 to 65535."
                return $returnList
            }
            
            if {$ixn_param_value < 0 || $ixn_param_value > 65535} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $short_ma_name $ixn_param_value. When\
                        $short_ma_name_format is $upvar_short_ma_name_format $short_ma_name\
                        must be a number from 0 to 65535."
                return $returnList
            }
        }
        "rfc_2685_vpn_id" -
        "rfc2685VpnId" {
            if {![regexp {(\d+)(\-)(\d+)$} $ixn_param_value trash number1 dash number2]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $short_ma_name $ixn_param_value. When\
                        $short_ma_name_format is $upvar_short_ma_name_format $short_ma_name\
                        must be formatted <number1>-<number2> where <number1> is from\
                        0 to 16777215 and <number2> is from 0 to 4292967295."
                return $returnList
            }
            
            if {$number1 < 0 || $number1 > 16777215 ||\
                    $number2 < 0 || $number2 > 4292967295} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $short_ma_name $ixn_param_value. When\
                        $short_ma_name_format is $upvar_short_ma_name_format $short_ma_name\
                        must be formatted <number1>-<number2> where <number1> is from\
                        0 to 16777215 and <number2> is from 0 to 4292967295."
                return $returnList
            }
        }
    }
    
    keylset returnList ixn_param_value $ixn_param_value
    return $returnList
}

proc ::ixia::cfm_inner_handle_setter {handle_list handle_distribution handle_repeat_count counter} {
    
    keylset returnList status $::SUCCESS
    
    # Load the variables
    set upvar_list [list handle_list handle_distribution handle_repeat_count counter]
    
    foreach var $upvar_list {
        upvar [set $var] upvar_$var
    }
    
    set handle_length [llength $upvar_handle_list]
    if {$handle_length == 0} {
        set ixn_param_value ""
        keylset returnList ixn_param_value $ixn_param_value
        return $returnList 
    }
    
    if {$upvar_handle_distribution == "round_robin"} {
        if {[mpexpr $upvar_counter + 1] <= $handle_length} {
            set ixn_param_value [lindex $upvar_handle_list $upvar_counter]
        } else {
            set idx [mpexpr $upvar_counter % $handle_length]
            set ixn_param_value [lindex $upvar_handle_list $idx]
        }
    } else {
        set idx [mpexpr $upvar_counter / $upvar_handle_repeat_count]
        if {[mpexpr $idx + 1] > $handle_length} {
            set idx [mpexpr $idx % $handle_length]
        }
        
        set ixn_param_value [lindex $upvar_handle_list $idx]
    }
    
    keylset returnList ixn_param_value $ixn_param_value
    return $returnList
}

proc ::ixia::get_cfm_learned_info {     \
        stat_keys                       \
        bridge_handle                   \
        exec_call                       \
        done_flag                       \
        info_obj_name                   \
        ret_list_name                   \
        {inner_stat_keys     {_ignore}} \
        {inner_info_obj_name {_ignore}} \
        {inner_key_field     {_ignore}} \
    } {
    
    keylset returnList status $::SUCCESS
    
    # init lists of keys
    foreach {hlt_key ixn_key} $stat_keys {
        set $hlt_key ""
    }
    
    if {$inner_stat_keys != "_ignore" && $inner_info_obj_name != "_ignore" &&\
            $inner_key_field != "_ignore"} {
        set use_inner_keys 1
    } else {
        set use_inner_keys 0
    }
    
    # refresh loopback info
    if {[catch {ixNet exec $exec_call $bridge_handle} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to $exec_call. $err"
        return $returnList
    }
    
    # check if info was learnt
    set retry_count 100
    for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
        set msg [ixNet getAttribute $bridge_handle -$done_flag]
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
    
    upvar $ret_list_name return_list
    
    set info_obj_list [ixNet getList $bridge_handle $info_obj_name]
    foreach info_obj $info_obj_list {
        foreach {hlt_key ixn_key} $stat_keys {
            
            set ixn_key_value [ixNet getAttribute $info_obj -$ixn_key]
            
            lappend $hlt_key  $ixn_key_value
            
        }
        
        if {$use_inner_keys} {
            
            # init lists of keys
            foreach {inner_hlt_key inner_ixn_key} $inner_stat_keys {
                set $inner_hlt_key ""
            }
            
            if {$inner_key_field == "_use_index"} {
                set ixn_key_value [lsearch $info_obj_list $info_obj]
            } else {
                set ixn_key_value [ixNet getAttribute $info_obj -$inner_key_field]
            }
            
            foreach inner_info_obj [ixNet getList $info_obj $inner_info_obj_name] {
                foreach {inner_hlt_key inner_ixn_key} $inner_stat_keys {
                
                    set ixn_inner_key_value [ixNet getAttribute $inner_info_obj -$inner_ixn_key]
                    
                    lappend $inner_hlt_key $ixn_inner_key_value
                    
                }
            }
            
            foreach {inner_hlt_key inner_ixn_key} $inner_stat_keys {
                if {[set $inner_hlt_key] == ""} {
                    set $inner_hlt_key NA
                }
                
                foreach {key_1 key_2 key_3} [split $inner_hlt_key .] {}
                
                keylset return_list $key_1.$key_2.$ixn_key_value.$key_3 [set $inner_hlt_key]
            }
        }
    }
    
    
    
    foreach {hlt_key ixn_key} $stat_keys {
        if {[set $hlt_key] == ""} {
            set $hlt_key NA
        }
        
        keylset return_list $hlt_key [set $hlt_key]
    }
    
    return $returnList
}