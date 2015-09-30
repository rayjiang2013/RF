
#-------------------------------------------------------------------------------
# Utility procedure - Increments random length MAC-like values
#-------------------------------------------------------------------------------
proc ::ixia::incr_random_mac_like_addr {mac_addr mac_addr_step} {
    set addr_words [split $mac_addr :]
    set step_words [split $mac_addr_step :]
    set lastx [expr [llength $addr_words] - 1]
    if { $lastx < 0 } { set lastx 0 }
    set index $lastx
    set result [list]
    set carry 0
    while {$index >= 0} {
        scan [lindex $addr_words $index] "%x" addr_word
        scan [lindex $step_words $index] "%x" step_word
        set value [expr $addr_word + $step_word + $carry]
        set carry [expr $value / 0x100]
        set value [expr $value % 0x100]
        lappend result $value
        incr index -1
    }
    set new_addr [format "%02x" [lindex $result $lastx]]
    for {set i [expr $lastx - 1]} {$i >= 0} {incr i -1} {
        append new_addr ":[format "%02x" [lindex $result $i]]"
    }
    return $new_addr
}
#-------------------------------------------------------------------------------
proc ::ixia::get_pbb_learned_info {bridge_handle keyed_array_name stat_keys_to_use command chk_attr child {inner_stat_keys {_ignore}} {inner_info_obj_name {_ignore}} {inner_key_field {_ignore}} } {

    variable $keyed_array_name
    set      keyed_array_index  0
    
    if {$inner_stat_keys != "_ignore" && $inner_info_obj_name != "_ignore" &&\
            $inner_key_field != "_ignore"} {
        set use_inner_keys 1
    } else {
        set use_inner_keys 0
    }
    
    # refresh loopback info
    debug "ixNet exec $command $bridge_handle"
    if {[catch {ixNet exec $command $bridge_handle} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to $command. $err"
        return $returnList
    }
    
    if {[llength $chk_attr] > 1} {
        set bak_chk $chk_attr
        set chk_attr [lindex $bak_chk 0]
        set chk_sent [lindex $bak_chk 1]
        set chk_err  [lindex $bak_chk 2]
        
        set retry_count 100
        for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
            debug "ixNet getA $bridge_handle -$chk_sent"
            set msg [ixNet getA $bridge_handle -$chk_sent]
            if {$msg == "true"} {
                break
            }
            
            after 500
        }
        
        if {$iteration >= $retry_count} {
            debug "ixNet getA $bridge_handle -$chk_err"
            set err_string [ixNet getA $bridge_handle -$chk_err]

            keylset returnList status $::FAILURE
            keylset returnList log "Failed to $command. Verify that all filter\
                    parameters were configured properly. $err_string."
            return $returnList
        }
    }
    
    # check if info was learnt
    set retry_count 100
    for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
        debug "ixNet getAttribute $bridge_handle -${chk_attr}"
        set msg [ixNet getAttribute $bridge_handle -${chk_attr}]
        if {$msg == "true"} {
            break
        }
        
        after 500
    }
    
    if {$iteration >= $retry_count} {
        keylset returnList status $::FAILURE
        keylset returnList log "Statistics are not available."
        return $returnList
    }
    
    after 1000
    
    debug "ixNet getList $bridge_handle $child"
    set info_obj_list [ixNet getList $bridge_handle $child]
    foreach info_obj $info_obj_list {
        
        foreach {hlt_key ixn_key} $stat_keys_to_use {
            debug "ixNet getAttribute $info_obj -$ixn_key"
            set ixn_key_value [ixNet getAttribute $info_obj -$ixn_key]
            
            if {[regexp {vlan} $hlt_key]} {
                if {$ixn_key_value == "None" || $ixn_key_value == "VLANID 0 TPID 0x0 Priority 0"} {
                    set ixn_key_value ""
                } else {
                    regexp {(VLANID )(\d+)( )(.*)$} $ixn_key_value {} {} ixn_key_value {} {}
                }
            }
            
            regsub -all { } $ixn_key_value _ ixn_key_value
            
            if {$ixn_key_value == ""} {
                lappend $hlt_key "N/A"
            } else {
                lappend $hlt_key $ixn_key_value
            }
            
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
                    set $inner_hlt_key "N/A"
                }
                
                foreach {key_1 key_2 key_3} [split $inner_hlt_key .] {}
                
                set [subst $keyed_array_name]($key_1.$key_2.$ixn_key_value.$key_3) [set $inner_hlt_key]
                incr keyed_array_index
            }
        }
        
        foreach {hlt_key ixn_key} $stat_keys_to_use {
            if {[set $hlt_key] == ""} {
                set $hlt_key "N/A"
            }
            
            set [subst $keyed_array_name]($hlt_key) [set $hlt_key]
            incr keyed_array_index
        }
        
    }
    
    keylset ret_list stat_count $keyed_array_index
    keylset ret_list status $::SUCCESS
    return $ret_list
}
#-------------------------------------------------------------------------------
