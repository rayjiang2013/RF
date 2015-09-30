proc ::ixia::ancp_handles_array_add {array_idx dsl_profile dsl_resync_profile} {
    
    variable ancp_profile_handles_array
    
    set ancp_profile_handles_array($array_idx) [list $dsl_profile $dsl_resync_profile]
    
    set ancp_profile_handles_array($dsl_profile) $array_idx
    set ancp_profile_handles_array($dsl_resync_profile) $array_idx
}

proc ::ixia::ancp_handles_array_remove_by_idx {array_idx} {
    
    variable ancp_profile_handles_array
    
    foreach dsl_profile $ancp_profile_handles_array($array_idx) {
        if {[catch {unset ancp_profile_handles_array($dsl_profile)} err]} {
            debug "Warning at unset ancp_profile_handles_array($dsl_profile); $err"
        }
    }
    
    if {[catch {unset ancp_profile_handles_array($array_idx)} err]} {
        debug "Warning at unset ancp_profile_handles_array($array_idx); $err"
    }
}

proc ::ixia::ancp_handles_array_remove_by_handle {handle} {
    
    variable ancp_profile_handles_array
    
    set arr_idx $ancp_profile_handles_array($handle)
    
    foreach dsl_profile $ancp_profile_handles_array($array_idx) {
        if {[catch {unset ancp_profile_handles_array($dsl_profile)} err]} {
            debug "Warning at unset ancp_profile_handles_array($dsl_profile); $err"
        }
    }
    
    if {[catch {unset ancp_profile_handles_array($array_idx)} err]} {
        debug "Warning at unset ancp_profile_handles_array($array_idx); $err"
    }
}

proc ::ixia::ancp_handles_array_update {old_arr_idx new_arr_idx} {
    
    variable ancp_profile_handles_array
    
    set dsl_profiles $ancp_profile_handles_array($old_arr_idx)
    
    ancp_handles_array_remove_by_idx $old_arr_idx
    
    ancp_handles_array_add $new_arr_idx [lindex $dsl_profiles 0] [lindex $dsl_profiles 1]
     
}

proc ::ixia::ancp_subscribers_cleanup {ancp_client_handle} {
    
    # Go thru all dsl and dsl resync profiles associated with this client
    # If the profile no longer exists remove it from the association
    # stack manager seems to fail on doing it so we have to clean up the mess
    
    set commit_flag 0
    
    if {[ixNet exists $ancp_client_handle] == "false" || [ixNet exists $ancp_client_handle] == 0} {
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    foreach profile_type [list dslProfileAllocationTable dslResyncProfileAllocationTable] {
        foreach allocation_table [ixNet getList $ancp_client_handle $profile_type] {
            set global_profile_obj_ref [ixNet getA $allocation_table -dslProfile]
            
            if {$global_profile_obj_ref == [ixNet getNull] || [ixNet exists $global_profile_obj_ref] == "false" || [ixNet exists $global_profile_obj_ref] == 0} {
                set commit_flag 1
                # It's a profile that doesn't exist anymore
                # remove the allocation table for it (not the actual global profile because it doesn't exist)
                debug "ixNet remove $allocation_table"
                if {[catch {ixNet remove $allocation_table} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to remove DSL Allocation Table $allocation_table. \
                    This operation is performed because the ancp client range $ancp_client_handle contains\
                    DSL Allocation Tabels that refer inexistent DSL Profiles. $err."
                    return $returnList
                }
            }
        }
    }
    
    if {$commit_flag} {
        debug "ixNet commit"
        if {[catch {ixNet commit} err]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to remove DSL Allocation Tables that point to invalid DSL Profiles. \
                    This operation is performed because the ancp client range $ancp_client_handle contains\
                    DSL Allocation Tabels that refer inexistent DSL Profiles. $err."
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::enable_in_state_evidence {dsl_handle client_handle table_handle} {
    variable handles_state_evidence_array
    set found_flag 0
    foreach complete_key [array names handles_state_evidence_array] {
        set x [lindex [split $complete_key ","] 0]
        set y [lindex [split $complete_key ","] 1]
        regsub -all {"} $dsl_handle {\"} compare_dsl_handle
        
        if { $compare_dsl_handle == $x && $client_handle == $y } {
            set right_percentage [lindex $handles_state_evidence_array($complete_key) 0]
            ixNet setA $table_handle -percentage $right_percentage
            set new_value [list $right_percentage 1]
            set handles_state_evidence_array($complete_key) $new_value
            set found_flag 1
            break
        }
        
    }
    if {!$found_flag} {
        set table_list   [ixNet getL $client_handle dslProfileAllocationTable]
        set percentage_now 100
        foreach senior_table $table_list {
            set pct [ixNet getA $senior_table -percentage]
            set percentage_now [expr $percentage_now - $pct]
        }
        if { $percentage_now < 0 } {
            set percentage_now 0
        }
        set handles_state_evidence_array($dsl_handle,$client_handle,$table_handle) [list $percentage_now 1]
    }
}

proc ::ixia::enable_in_state_evidence_resynch {dsl_handle client_handle table_handle} {
    variable handles_state_evidence_resynch_array
    set found_flag 0
    foreach complete_key [array names handles_state_evidence_resynch_array] {
        set x [lindex [split $complete_key ","] 0]
        set y [lindex [split $complete_key ","] 1]
        regsub -all {"} $dsl_handle {\"} compare_dsl_handle
        
        if { $compare_dsl_handle == $x && $client_handle == $y } {
            set right_percentage [lindex $handles_state_evidence_resynch_array($complete_key) 0]
            ixNet setA $table_handle -percentage $right_percentage
            set new_value [list $right_percentage 1]
            set handles_state_evidence_resynch_array($complete_key) $new_value
            set found_flag 1
            break
        }
        
    }
    if {!$found_flag} {
        set table_list   [ixNet getL $client_handle dslResyncProfileAllocationTable]
        set percentage_now 100
        foreach senior_table $table_list {
            set pct [ixNet getA $senior_table -percentage]
            set percentage_now [expr $percentage_now - $pct]
        }
        if { $percentage_now < 0 } {
            set percentage_now 0
        }
        set handles_state_evidence_resynch_array($dsl_handle,$client_handle,$table_handle) [list $percentage_now 1]
    }
}

proc ::ixia::disable_in_state_evidence {dsl_handle client_handle} {
    variable handles_state_evidence_array
    foreach complete_key [array names handles_state_evidence_array] {
        set x [lindex [split $complete_key ","] 0]
        set y [lindex [split $complete_key ","] 1]
        if { $dsl_handle == $x && $client_handle == $y } {
            set current_state $handles_state_evidence_array($complete_key)
            set current_percent [lindex $current_state 0]
            # delete old entry
            if {[catch {unset handles_state_evidence_array($complete_key)} err]} {
                debug "Failed to unset handles_state_evidence_array($complete_key) -->> $err"
            }
            set new_key "$x,$y,N/A"
            set handles_state_evidence_array($new_key) [list $current_percent 0]
        }    
    }
}

proc ::ixia::disable_in_state_evidence_resynch {dsl_handle client_handle} {
    variable handles_state_evidence_resynch_array
    foreach complete_key [array names handles_state_evidence_resynch_array] {
        set x [lindex [split $complete_key ","] 0]
        set y [lindex [split $complete_key ","] 1]
        if { $dsl_handle == $x && $client_handle == $y } {
            set current_state $handles_state_evidence_resynch_array($complete_key)
            set current_percent [lindex $current_state 0]
            # delete old entry
            if {[catch {unset handles_state_evidence_resynch_array($complete_key)} err]} {
                debug "Failed to unset handles_state_evidence_resynch_array($complete_key) -->> $err"
            }
            set new_key "$x,$y,N/A"
            set handles_state_evidence_resynch_array($new_key) [list $current_percent 0]
        }    
    }
}