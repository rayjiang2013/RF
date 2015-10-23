proc ::ixia::dhcpServerMacRange {} {
    uplevel {
        if {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/ethernet} $dhcp_range_objref]} {
            set dhcpMacRangeList [ixNet getList $range_objref macRange]
            if {$dhcpMacRangeList == ""} {
                set retCode [ixNetworkNodeAdd \
                        $range_objref         \
                        macRange              \
                        {-enabled true}       \
                        -commit               \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
                set dhcp_mac_range_objref [keylget retCode node_objref]
            } else {
                set dhcp_mac_range_objref [lindex $dhcpMacRangeList 0]
            }
            set dhcp_mac_range_options ""
            foreach {hltParam ixnParam paramType translateType} $dhcpMacRangeParamsMap {
                if {![info exists $hltParam]} {continue}
                switch $paramType {
                    mac {
                        lappend dhcp_mac_range_options -$ixnParam [convertToIxiaMac [set $hltParam] :]
                    }
                    math {
                        lappend dhcp_mac_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                    }
                    var_identity {
                        lappend dhcp_mac_range_options -$ixnParam [set $hltParam]
                    }
                    identity {
                        lappend dhcp_mac_range_options -$ixnParam [set $hltParam]
                    }
                    bool {
                        lappend dhcp_mac_range_options -$ixnParam $truth([set $hltParam])
                    }
                    translate {
                        if {![info exists [set translateType]([set $hltParam])]} { continue; }
                        lappend dhcp_mac_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                    }
                    default {
                        lappend dhcp_mac_range_options -$ixnParam [set $hltParam]
                    }
                }
            }
            if {$dhcp_mac_range_options != ""} {
                lappend dhcp_mac_range_options -enabled true
                set retCode [ixNetworkNodeSetAttr \
                        $dhcp_mac_range_objref    \
                        $dhcp_mac_range_options   \
                        -commit                   \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
            }
        } else {
            set dhcpAtmRangeList [ixNet getList $range_objref atmRange]
            if {$dhcpAtmRangeList == ""} {
                set retCode [ixNetworkNodeAdd \
                        $range_objref         \
                        atmRange              \
                        {-enabled true}       \
                        -commit               \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
                set dhcp_atm_range_objref [keylget retCode node_objref]
            } else {
                set dhcp_atm_range_objref [lindex $dhcpAtmRangeList 0]
            }
            set dhcp_atm_range_options ""
            foreach {hltParam ixnParam paramType translateType} $dhcpAtmRangeParamsMap {
                if {![info exists $hltParam]} {continue}
                switch $paramType {
                    mac {
                        lappend dhcp_atm_range_options -$ixnParam [convertToIxiaMac [set $hltParam] :]
                    }
                    math {
                        lappend dhcp_atm_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                    }
                    var_identity {
                        lappend dhcp_atm_range_options -$ixnParam [set $hltParam]
                    }
                    identity {
                        lappend dhcp_atm_range_options -$ixnParam [set $hltParam]
                    }
                    bool {
                        lappend dhcp_atm_range_options -$ixnParam $truth([set $hltParam])
                    }
                    translate {
                        if {![info exists [set translateType]([set $hltParam])]} { continue; }
                        lappend dhcp_atm_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                    }
                    default {
                        lappend dhcp_atm_range_options -$ixnParam [set $hltParam]
                    }
                }
            }
            if {$dhcp_atm_range_options != ""} {
                lappend dhcp_atm_range_options -atmEncapsulation llcRoutedSnap
                lappend dhcp_atm_range_options -enabled true
                set retCode [ixNetworkNodeSetAttr \
                        $dhcp_atm_range_objref    \
                        $dhcp_atm_range_options   \
                        -commit                   \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
            }
        }
    }
}

proc ::ixia::dhcpServerVlanRange {} {
    uplevel {
        set dhcpVlanRangeList [ixNet getList $range_objref vlanRange]
        if {$dhcpVlanRangeList == ""} {
            set retCode [ixNetworkNodeAdd \
                    $range_objref         \
                    vlanRange             \
                    {-enabled true}       \
                    -commit               \
                    ]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log " [keylget retCode log]"
                return $returnList
            }
            set dhcp_vlan_range_objref [keylget retCode node_objref]
            # If we add the Vlan Range on mode modify then we need to enable vlans if needed
            if {$mode == "modify"} {
                set vlan true
                if {[info exists vlan_id_inner]} {
                    set vlan_inner true
                }
            }
            
        } else {
            set dhcp_vlan_range_objref [lindex $dhcpVlanRangeList 0]
        }
        set dhcp_vlan_range_options ""
        foreach {hltParam ixnParam paramType translateType} $dhcpVlanRangeParamsMap {
            if {![info exists $hltParam]} {continue}
            switch $paramType {
                math {
                    lappend dhcp_vlan_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                }
                var_identity {
                    lappend dhcp_vlan_range_options -$ixnParam [set $hltParam]
                }
                identity {
                    lappend dhcp_vlan_range_options -$ixnParam [set $hltParam]
                }
                bool {
                    lappend dhcp_vlan_range_options -$ixnParam $truth([set $hltParam])
                }
                translate {
                    if {![info exists [set translateType]([set $hltParam])]} { continue; }
                    lappend dhcp_vlan_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                }
                default {
                    lappend dhcp_vlan_range_options -$ixnParam [set $hltParam]
                }
            }
        }
        if {$dhcp_vlan_range_options != ""} {
            lappend dhcp_vlan_range_options -enabled true
            set retCode [ixNetworkNodeSetAttr  \
                    $dhcp_vlan_range_objref    \
                    $dhcp_vlan_range_options   \
                    -commit                    \
                    ]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log " [keylget retCode log]"
                return $returnList
            }
        }
    }
}

proc ::ixia::dhcpServerPvcRange {} {
    uplevel {
        if {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/atm} $dhcp_range_objref]} {
            set dhcpPvcRangeList [ixNet getList $range_objref pvcRange]
            if {$dhcpPvcRangeList == ""} {
                set retCode [ixNetworkNodeAdd \
                        $range_objref         \
                        pvcRange              \
                        {-enabled true}       \
                        -commit               \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
                set dhcp_pvc_range_objref [keylget retCode node_objref]
            } else {
                set dhcp_pvc_range_objref [lindex $dhcpPvcRangeList 0]
            }
            set dhcp_pvc_range_options ""
            foreach {hltParam ixnParam paramType translateType} $dhcpPvcRangeParamsMap {
                if {![info exists $hltParam]} {continue}
                switch $paramType {
                    math {
                        lappend dhcp_pvc_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                    }
                    var_identity {
                        lappend dhcp_pvc_range_options -$ixnParam [set $hltParam]
                    }
                    identity {
                        lappend dhcp_pvc_range_options -$ixnParam [set $hltParam]
                    }
                    bool {
                        lappend dhcp_pvc_range_options -$ixnParam $truth([set $hltParam])
                    }
                    translate {
                        if {![info exists [set translateType]([set $hltParam])]} { continue; }
                        lappend dhcp_pvc_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                    }
                    default {
                        lappend dhcp_pvc_range_options -$ixnParam [set $hltParam]
                    }
                }
            }
            if {$dhcp_pvc_range_options != ""} {
                lappend dhcp_pvc_range_options -enabled true
                set retCode [ixNetworkNodeSetAttr  \
                        $dhcp_pvc_range_objref     \
                        $dhcp_pvc_range_options    \
                        -commit                    \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
            }
        }
    }
}
proc ::ixia::dhcpServerServerRange {} {
    uplevel {
        set dhcp_range_options ""
        foreach {hltParam ixnParam paramType translateType} $dhcpRangeParamsMap {
            if {![info exists $hltParam]} {continue}
            switch $paramType {
                math {
                    lappend dhcp_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                }
                var_identity {
                    lappend dhcp_range_options -$ixnParam [set $hltParam]
                }
                identity {
                    lappend dhcp_range_options -$ixnParam [set $hltParam]
                }
                bool {
                    lappend dhcp_range_options -$ixnParam $truth([set $hltParam])
                }
                translate {
                    if {![info exists [set translateType]([set $hltParam])]} { continue; }
                    lappend dhcp_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                }
                default {
                    lappend dhcp_range_options -$ixnParam [set $hltParam]
                }
            }
        }
        if {$dhcp_range_options != ""} {
            lappend dhcp_range_options -enabled true
            set retCode [ixNetworkNodeSetAttr \
                    $dhcp_range_objref        \
                    $dhcp_range_options       \
                    -commit                   \
                    ]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log " [keylget retCode log]"
                return $returnList
            }
        }
    }
}
