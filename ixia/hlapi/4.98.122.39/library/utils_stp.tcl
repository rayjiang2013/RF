proc ::ixia::stpBridgeDependencies {} {
    uplevel {
        # Global parameters check
        if {$mode == "create" && ![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, parameter -port_handle\
                    must be provided."
            return $returnList
        }
        if {($mode == "modify" || $mode == "delete" || $mode == "enable" || \
                $mode == "disable") && ![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, parameter -handle\
                    must be provided."
            return $returnList
        }
        if {$vlan} {
            # Regexp parameters check
            foreach vlan_list_it {vlan_id vlan_id_intf_step vlan_id_bridge_step \
                    vlan_user_priority vlan_user_priority_intf_step \
                    vlan_user_priority_bridge_step} {
                set vlan_count [llength [split $vlan_id ,]]
                if {[llength [split [set $vlan_list_it] ,]] != $vlan_count &&\
                        [llength [split [set $vlan_list_it] ,]] != 1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The length of the list $vlan_list_it\
                            should be equal with vlan_id list length."
                    return $returnList
                }
            }
            foreach vlan_list_it {vlan_id vlan_id_intf_step vlan_id_bridge_step} {
                foreach vlan_it [split [set $vlan_list_it] ,] {
                    if {$vlan_it < 0 || $vlan_it > 4095} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The value provided to \
                            ${vlan_list_it}($vlan_it) is out of range. Please provide\
                            values in the range 1-4095. Also you should chcek if 0\
                            is accepted as a value for the vlan_id."
                        return $returnList
                    }
                }
            }
        } else {
            catch {
                unset vlan_id
                unset vlan_id_intf_step
                unset vlan_id_bridge_step
                unset vlan_user_priority
                unset vlan_user_priority_bridge_step
                unset vlan_user_priority_intf_step
            }
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
}

proc ::ixia::stpMstiDependencies {} {
    uplevel {
        if {$mode == "create"} {
            if {![info exists bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode,\
                        parameter -bridge_handle must be provided."
                return $returnList
            }
            if {[catch {
                set bridge_mode [ixNet getAttr $bridge_handle -mode]
            } errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log $errorMsg
                return $returnList
            }
            if {$bridge_mode != "mstp"} {
                keylset returnList status $::FAILURE
                keylset returnList log "stp bridge type should be only\
                        mstp."
                return $returnList
            }
        }
        if {($mode == "modify" || $mode == "delete" || $mode == "enable" || \
                $mode == "disable") && ![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, parameter -handle\
                    must be provided."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
}

proc ::ixia::stpVlanDependencies {} {
    uplevel {
        if {$mode == "create"} {
            if {![info exists bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode,\
                        parameter -bridge_handle must be provided."
                return $returnList
            }
            if {[catch {
                set bridge_mode [ixNet getAttr $bridge_handle -mode]
            } errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log $errorMsg
                return $returnList
            }
            if {$bridge_mode != "pvst" && $bridge_mode != "rpvst" && $bridge_mode != "pvstp"} {
                keylset returnList status $::FAILURE
                keylset returnList log "stp bridge type should be only\
                        pvst, rpvst and pvstp."
                return $returnList
            }
        }
        if {($mode == "modify" || $mode == "delete" || $mode == "enable" || \
                $mode == "disable") && ![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, parameter -handle\
                    must be provided."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
}

proc ::ixia::stpLanDependencies {} {
    uplevel {
        if {$mode == "create" && ![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    parameter -port_handle must be provided."
            return $returnList
        } elseif {$mode != "create" && ![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, parameter -handle\
                    must be provided."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
}

proc ::ixia::stpControlDependencies {} {
    uplevel {
        if {![info exists port_handle] && ![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "-port_handle or -handle parameter should be\
                    specified."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
}
