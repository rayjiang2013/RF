proc ::ixia::ixnetwork_dhcp_server_config { args opt_args} {
    variable objectMaxCount
    variable ixnetwork_port_handles_array
    variable dhcp_handles_array
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {$mode == "create"} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode parameter -port_handle must be provided."
            return $returnList
        }
        if {[llength $port_handle] > 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode parameter -port_handle must be provided with a single port handle."
            return $returnList
        }
        set port_handles $port_handle
        
        # Add port after connecting to IxNetwork TCL Server
        set retCode [ixNetworkPortAdd $port_handle {} force]
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        
        set retCode [ixNetworkGetPortObjref $port_handle]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the port\
                    object reference associated to the $port_handle port handle -\
                    [keylget retCode log]"
            return $returnList
        }
        set port_objrefs [keylget retCode vport_objref]
        if {![info exists encapsulation]} {
            set current_type [ixNet getAttribute ${port_objrefs}/l1Config -currentType]
            if {[string first "atm" $current_type] == 0} {
                set encapsulation SNAP
            } else {
                set encapsulation ETHERNET_II
            }
        } else {
            if {[string toupper $encapsulation] == "ETHERNET_II_VLAN" && ![info exists vlan_id]} {
                puts "Warning: Encapsulation is changed to ETHERNET_II because \
                            the vlan_id parameter is missing."
                update idletasks
            }
            if {[string toupper $encapsulation] == "ETHERNET_II_QINQ"} {
                if {[info exists vlan_id] && ![info exists vlan_id_inner]} {
                    puts "Warning: Encapsulation is changed to ETHERNET_II_VLAN because \
                            the vlan_id_inner parameter is missing."
                    update idletasks
                }
                if {![info exists vlan_id]} {
                    puts "Warning: Encapsulation is changed to ETHERNET_II because \
                            the vlan_id parameter is missing."
                    update idletasks
                }
            }
        }
        
    } elseif {$mode == "modify" || $mode == "reset"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode parameter -handle\
                    must be provided."
            return $returnList
        }
        if {![regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\"[a-zA-Z0-9\-]+\"/dhcpServerEndpoint:\"[a-zA-Z0-9\-]+\"/range:\"[a-zA-Z0-9\-]+\"/dhcpServerRange(:\"[a-zA-Z0-9\-]+\"){0,1}$} $handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid -handle provided. The -handle parameter must contain a DHCP Server endpoint range."
            return $returnList
        }
        if {$mode == "modify"} {
            removeDefaultOptionVars $opt_args $args
            foreach handleElem $handle {
                set retCode [ixNetworkGetPortFromObj $handleElem]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
                lappend port_handles        [keylget retCode port_handle]
                lappend port_objrefs        [keylget retCode vport_objref]
                lappend range_objrefs       [ixNetworkGetParentObjref $handleElem]
                lappend dhcp_range_objrefs $handle
            }
        }
    }
    
    array set truth {
        1           true
        0           false
        true        1
        false       0
    }
    
    
    if {![info exists functional_specification]} {
        if {$ip_version == 4} {
            set functional_specification v4_compatible
        } else {
            set functional_specification v4_v6_compatible
        }
    }
    
    if {$functional_specification == "v4_v6_compatible" } {
        set ipdefaultsList {
            ip_address                          10.10.0.1   1000::1
            ip_dns1_step                        0.1.0.0     0:0:0:0:0:0:0:0100
            ip_dns2_step                        0.1.0.0     0:0:0:0:0:0:0:0100
            ip_gateway                          NA          NA
            ip_gateway_step                     0.1.0.0     0:0:0:0:0:0:0:0100
            ipv6_gateway                        NA          NA
            ipv6_gateway_step                   NA          0:0:0:0:0:0:0:0100
            ip_prefix_length                    16          120
            ipaddress_pool                      10.10.1.1   ::A0A:101
            ip_inside_step                      0.1.0.0     0:0:0:0:0:0:0:0100
            ip_gateway_inside_step              0.0.0.1     0:0:0:0:0:0:0:1
            ipv6_gateway_inside_step            NA          0:0:0:0:0:0:0:0100
            dhcp_offer_router_address_step      0.0.0.0     NA
        }
    } else {
        set ipdefaultsList {
            ip_address                          10.10.0.1   NA
            ip_dns1_step                        0.1.0.0     NA
            ip_dns2_step                        0.1.0.0     NA
            ip_gateway                          10.10.0.2   NA
            ip_gateway_step                     0.1.0.0     NA
            ipv6_gateway                        NA          NA
            ipv6_gateway_step                   NA          NA
            ip_prefix_length                    16          NA
            ipaddress_pool                      10.10.1.1   NA
            ip_inside_step                      0.0.0.1     NA
            ip_gateway_inside_step              0.0.0.1     NA
            ipv6_gateway_inside_step            NA          NA
        }
    }
    if {$mode == "create" && [info exists ip_version]} {
        foreach {x_parameter x4_default x6_default} $ipdefaultsList {
            if {![info exists $x_parameter] && ([set x${ip_version}_default] != "NA")} {
                # Insert with default...
                set $x_parameter [set x${ip_version}_default]
            }
        }
        # Setting the default value for ipaddress_pool_step
        if {![info exists ipaddress_pool_step] && ![info exists ipaddress_pool_prefix_step]} {
            if {$functional_specification == "v4_v6_compatible"} {
                if {$ip_version == 4} {
                    set ipaddress_pool_step "0.1.0.0"
                } else {
                    set ipaddress_pool_step "0:0:0:0:0:0:0:0100"
                }
            } else {
                if {$ip_version == 4} {
                    set ipaddress_pool_step "0.1.0.0"
                }
            }
        }
        # Setting the default value for ipaddress_pool_prefix_step
        if {![info exists ipaddress_pool_prefix_step]} {
            if {$functional_specification == "v4_v6_compatible"} {
                set ipaddress_pool_prefix_step "1"
            } else {
                if {$ip_version == 4} {
                    set ipaddress_pool_prefix_step "1"
                }
            }
        }
        
        # Setting the default value for ip_step
        if {![info exists ip_step] && ![info exists ip_prefix_step]} {
            if {$functional_specification == "v4_v6_compatible"} {
                if {$ip_version == 4} {
                    set ip_step 0.0.0.1
                } else {
                    set ip_step 0:0:0:0:0:0:0:0001
                }
            } else {
                if {$ip_version == 4} {
                    set ip_step 0.1.0.0
                }
            }
        }
        
        # Setting the default value for ip_prefix_step
        if {![info exists ip_prefix_step]} {
            if {$functional_specification == "v4_v6_compatible"} {
                set ip_prefix_step 1
            } else {
                if {$ip_version == 4} {
                    set ip_prefix_step 1
                }
            }
        }
    }
    if {[info exists dhcp_offer_options] && $dhcp_offer_options == 0} {
        catch {unset dhcp_offer_router_address}
    }
    
    if {$mode == "reset"} {
        foreach handleElem $handle {
             set rangeElem [ixNetworkGetParentObjref $handleElem range]
             debug "deleting $rangeElem..."
             ixNet remove $rangeElem
             catch {unset dhcp_handles_array($rangeElem)}
        }
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to $mode DHCP handles $handle."
            return $returnList
        } else {
            keylset returnList status $::SUCCESS
            return $returnList
        }
    }
    
    
    set var_true  true
    set var_false false
    
    array set translate_general {
        SNAP                                   6
        ETHERNET_II                            5
        every_subnet                           perSubnet
        every_interface                        perInterface
    }
    
    array set translate_encapsulation_map {
        vc_mux_ipv4_routed  {atm "VC Mux IPv4 Routed"               1               }
        vc_mux_fcs          {atm "VC Mux Bridged Ethernet (FCS)"    2               }
        vc_mux              {atm "VC Mux Bridged Ethernet (no FCS)" 3               }
        vc_mux_ipv6_routed  {atm "VC Mux IPv6 Routed"               4               }
        SNAP                {atm "LLC Routed AAL5 Snap"             6               }
        llcsnap_routed      {atm "LLC Routed AAL5 Snap"             6               }
        llcsnap_fcs         {atm "LLC Bridged Ethernet (FCS)"       7               }
        llcsnap             {atm "LLC Bridged Ethernet (no FCS)"    8               }
        llcsnap_ppp         {atm "LLC Encap PPP"                    9               }
        vc_mux_ppp          {atm "VC Mux PPP"                       10              }
        ETHERNET_II         {eth NA                                 NA}
        ethernet_ii         {eth NA                                 NA}
        ethernet_ii_vlan    {eth NA                                 NA}
        ethernet_ii_qinq    {eth NA                                 NA}
    }

    array set translate_encapsulation {
        SNAP                6
        vc_mux_ipv4_routed  1
        vc_mux_fcs          2
        vc_mux              3
        vc_mux_ipv6_routed  4
        llcsnap_routed      6
        llcsnap_fcs         7
        llcsnap             8
        llcsnap_ppp         9
        vc_mux_ppp          10
    }
    
    array set translate_qinq_incr_mode {
        outer 0
        inner 1
        both  2
    }
    
    array set translate_pvc_incr_mode {
        vpi   1
        vci   0
        both  2
    }

    array set translate_ip_version {
        4   IPv4
        6   IPv6
    }

    array set translate_ia_type {
        iana        IANA
        iata        IATA
        iapd        IAPD
        iana_iapd   IANA+IAPD
    }
      
    set dhcpGlobalsParamsMap {
        lease_time                  defaultLeaseTime        identity          none
        lease_time_max              maxLeaseTime            identity          none
        ping_check                  pingCheck               bool              none
        ping_timeout                pingTimeout             identity          none
        single_address_pool         sharedNetwork           bool              none
    }
        
    set dhcpMacRangeParamsMap {
        local_mac                   mac                     mac               none
        local_mac_step              incrementBy             mac               none
        local_mtu                   mtu                     identity          none
    }
    
    set dhcpAtmRangeParamsMap {
        local_mac                   mac                     mac               none
        local_mac_step              incrementBy             mac               none
        local_mtu                   mtu                     identity          none
        encapsulation               atmEncapsulation        translate         translate_encapsulation
    }
    
    set dhcpVlanRangeParamsMap {
        vlan                        enabled                 bool              none
        vlan_inner                  innerEnable             bool              none
        vlan_id                     firstId                 identity          none
        vlan_id_count               uniqueCount             identity          none
        vlan_id_repeat              incrementStep           identity          none
        vlan_id_step                increment               identity          none
        vlan_user_priority          priority                identity          none
        vlan_id_inner               innerFirstId            identity          none
        vlan_id_count_inner         innerUniqueCount        identity          none
        vlan_id_repeat_inner        innerIncrementStep      identity          none
        vlan_id_step_inner          innerIncrement          identity          none
        vlan_user_priority_inner    innerPriority           identity          none
        qinq_incr_mode              idIncrMode              translate         translate_qinq_incr_mode
    }
    
    set dhcpPvcRangeParamsMap {
        pvc_incr_mode               incrementMode           translate         translate_pvc_incr_mode
        vci                         vciFirstId              identity          none
        vci_count                   vciUniqueCount          identity          none
        vci_repeat                  vciIncrementStep        identity          none
        vci_step                    vciIncrement            identity          none
        vpi                         vpiFirstId              identity          none
        vpi_count                   vpiUniqueCount          identity          none
        vpi_repeat                  vpiIncrementStep        identity          none
        vpi_step                    vpiIncrement            identity          none
    }
    # This parameter supports both IP and numeric format
    if {[info exists ip_prefix_step] && [info exists ip_prefix_length]} {
        if {![regexp {^[0-9]+$} $ip_prefix_step]} {
            set ip_prefix_step [::ixia::ip_addr_to_num $ip_prefix_step]
            set ip_prefix_step [mpexpr $ip_prefix_step >> $ip_prefix_length]
        }
    }
    if {[info exists ipaddress_pool_prefix_step] && [info exists ipaddress_pool_prefix_length]} {
        if {![regexp {^[0-9]+$} $ipaddress_pool_prefix_step]} {
            set ipaddress_pool_prefix_step [::ixia::ip_addr_to_num $ipaddress_pool_prefix_step]
            set ipaddress_pool_prefix_step [mpexpr $ipaddress_pool_prefix_step >> $ipaddress_pool_prefix_length]
        }
    }
    if {$functional_specification == "v4_v6_compatible" } {
        set dhcpRangeParamsMap {
            ip_version                              ipType                  translate   translate_ip_version
            ipaddress_count                         count                   identity    none
            ipaddress_pool                          ipAddress               identity    none
            ip_dns1                                 ipDns1                  identity    none
            ip_dns2                                 ipDns2                  identity    none
            dhcp_offer_router_address               ipGateway               identity    none
            ipaddress_pool_prefix_length            ipPrefix                identity    none
            ip_address                              serverAddress           identity    none
            ip_prefix_length                        serverPrefix            identity    none
            ip_gateway                              serverGateway           identity    none
            dhcp6_ia_type                           dhcp6IaType             translate   translate_ia_type
            ip_count                                serverCount             identity    none
            ip_inside_step                          serverAddressIncrement  identity    none
            ip_gateway_inside_step                  serverGatewayIncrement  identity    none
            dhcp_offer_router_address_inside_step   ipGatewayIncrement      identity    none
        }
    } else {
        # BUG1109447 - The serverPrefix and serverGateway are overwritten with the values configured
        # in the previous dhcp range. Setting default values for -functional_specification v4_compatible.
        set server_prefix_length 16
        set server_gateway {}
        
        set dhcpRangeParamsMap {
            ipaddress_count                         count                   identity    none
            ipaddress_pool                          ipAddress               identity    none
            ip_dns1                                 ipDns1                  identity    none
            ip_dns2                                 ipDns2                  identity    none
            ip_gateway                              ipGateway               identity    none
            ip_prefix_length                        ipPrefix                identity    none
            ip_address                              serverAddress           identity    none
            server_prefix_length                    serverPrefix            identity    none
            server_gateway                          serverGateway           identity    none
            ip_count                                serverCount             identity    none
            ip_inside_step                          serverAddressIncrement  identity    none
            ip_gateway_inside_step                  ipGatewayIncrement      identity    none
        }
        set ip_version 4
    }
    # Create and/or modify from here
    if {$mode == "create" || $mode == "modify"} {
        if {[info exists ip_version] && $ip_version == 6} {
            if {[info exists ipv6_gateway]} {
                if {[info exists ip_gateway]} {
                    puts "Warning: You have provided both ip_gateway and\
                            ipv6_gateway, ipv6_gateway will take precedence over ip_gateway."
                    update idletasks
                }
                set ip_gateway $ipv6_gateway
            }
            
            if {[info exists ipv6_gateway_step]} {
                # check against default
                if {[info exists ip_gateway_step] && $ip_gateway_step != "0:0:0:0:0:0:0:0100"} {
                    puts "Warning: You have provided both ip_gateway_step and\
                            ipv6_gateway_step, ipv6_gateway_step will take precedence over ip_gateway_step."
                    update idletasks
                }
                set ip_gateway_step $ipv6_gateway_step
            }
            
            if {[info exists ipv6_gateway_inside_step]} {
                if {[info exist ip_gateway_inside_step]} {
                    puts "Warning: You have provided both ip_gateway_inside_step and\
                            ipv6_gateway_inside_step, ipv6_gateway_inside_step will take precedence over ip_gateway_step."
                    update idletasks
                }
                set ip_gateway_inside_step $ipv6_gateway_inside_step
            }
        }
        
        # Verify if there are other DHCP Server Ranges created
        set _existingRangeList ""
        foreach port_objref $port_objrefs {
            set _l2List1 [ixNet getList $port_objref/protocolStack ethernet]
            set _l2List2 [ixNet getList $port_objref/protocolStack atm]
            set _l2List  [concat $_l2List1 $_l2List2]
            foreach _l2Elem $_l2List {
                set _dhcpList  [ixNet getList $_l2Elem dhcpServerEndpoint]
                foreach _dhcpElem $_dhcpList {
                    lappend _existingRangeList [ixNet getList $_dhcpElem range]
                }
            }
        }
        
        # Set DHCP Globals
        set dhcp_global_options ""
        foreach {hltParam ixnParam paramType translateType} $dhcpGlobalsParamsMap {
            if {![info exists $hltParam]} {continue}
            # If DHCP Globals are already set, do not override them with defaults
            if {[is_default_param_value $hltParam $args] && ($_existingRangeList != "")} {
                continue
            }
            switch $paramType {
                identity {
                    lappend dhcp_global_options -$ixnParam [set $hltParam]
                }
                bool {
                    lappend dhcp_global_options -$ixnParam $truth([set $hltParam])
                }
                translate {
                    if {![info exists [set translateType]([set $hltParam])]} { continue; }
                    lappend dhcp_global_options -$ixnParam [set [set translateType]([set $hltParam])]
                }
                default {
                    lappend dhcp_global_options -$ixnParam [set $hltParam]
                }
            }
        }
        if {$dhcp_global_options != ""} {
            set dhcp_globals_objref [lindex \
                    [ixNet getList [ixNet getRoot]globals/protocolStack dhcpServerGlobals] 0]
            if {$dhcp_globals_objref == ""} {
                set retCode [ixNetworkNodeAdd \
                        [ixNet getRoot]globals/protocolStack \
                        dhcpServerGlobals     \
                        {}                    \
                        -commit               \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
                set dhcp_globals_objref [keylget retCode node_objref]
            }
            
            set retCode [ixNetworkNodeSetAttr                        \
                    $dhcp_globals_objref                             \
                    $dhcp_global_options                             \
                    -commit                                          \
                    ]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
    }
    if {$mode == "create"} {
        set index 1
        for {set i 0} {$i < $count} {incr i} {
            if {[lindex $translate_encapsulation_map($encapsulation) 0] == "eth"} {
                set l2List [ixNet getList $port_objrefs/protocolStack ethernet]
                set l2Type ethernet
            } else {
                set l2List [ixNet getList $port_objrefs/protocolStack atm]
                set l2Type atm
            }
            if {$l2List == ""} {
                set l2List    [ixNet add $port_objrefs/protocolStack $l2Type]
                set dhcpList  [ixNet add [lindex $l2List   0] dhcpServerEndpoint]
                set rangeList [ixNet add [lindex $dhcpList 0] range]
                ixNet commit
                set l2List    [ixNet remapIds $l2List]
                set dhcpList  [ixNet remapIds $dhcpList]
                set rangeList [ixNet remapIds $rangeList]
            } else {
                set dhcpList  [ixNet getList [lindex $l2List   0] dhcpServerEndpoint]
                if {$dhcpList == ""} {
                    set dhcpList  [ixNet add [lindex $l2List   0] dhcpServerEndpoint]
                    set rangeList [ixNet add [lindex $dhcpList 0] range]
                    ixNet commit
                    set dhcpList  [ixNet remapIds $dhcpList]
                    set rangeList [ixNet remapIds $rangeList]
                } else {
                    set rangeList [ixNet add [lindex $dhcpList 0] range]
                    ixNet commit
                    set rangeList [ixNet remapIds $rangeList]
                }
            }
            set range_objref [lindex $rangeList 0]
            # Set DHCP Range
            set dhcpRangeList [ixNet getList $range_objref dhcpServerRange]
            if {$dhcpRangeList == ""} {
                set retCode [ixNetworkNodeAdd \
                        $range_objref         \
                        dhcpServerRange       \
                        {-enabled true}       \
                        -commit               \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
                set dhcp_range_objref [keylget retCode node_objref]
            } else {
                set dhcp_range_objref [lindex $dhcpRangeList 0]
            }
            lappend returnDhcpRangeList $dhcp_range_objref
            lappend dhcp_range_objrefs  $dhcp_range_objref
            
            # Set DHCP Server Range
            dhcpServerServerRange
            
            # Set DHCP ATM/MAC Range
            dhcpServerMacRange
            
            # Set VLAN Range
            if {[info exists vlan_id]} {
                set vlan true
                if {[info exists vlan_id_inner]} {
                    set vlan_inner true
                }
                dhcpServerVlanRange
            }
            
            # Set PVC Range
            dhcpServerPvcRange
            
            # Increment params that need to be incremented
            set incrementList {
                ipaddress_pool               ipaddress_pool_step                ipv4_6  ipaddress_pool_increment_by
                ip_address                   ip_step                            ipv4_6  ip_increment_by
                ip_gateway                   ip_gateway_step                    ipv4_6  ip_increment_by
                ip_dns1                      ip_dns1_step                       ipv4_6  ip_increment_by
                ip_dns2                      ip_dns2_step                       ipv4_6  ip_increment_by
                local_mac                    local_mac_outer_step               mac     NA
                vlan_id                      vlan_id_inter_device_step          integer NA
                vlan_id_inner                vlan_id_inner_inter_device_step    integer NA
				dhcp_offer_router_address    dhcp_offer_router_address_step     ipv4_6  ip_increment_by
            }
            
            if {($index % $ip_repeat) == 0} {
                if {[info exists ip_step] || (![info exists ip_step] && ![info exists ip_prefix_step])} {
                    if {![info exists ip_step]} {
                        # Set default for IP step
                        if {$ip_version == 4} {
                            set ip_step 0.1.0.0
                        } else {
                            set ip_step 0000:0000:0000:0000:0000:0000:0000:0100
                        }
                    }
                    set ip_increment_by step
                } else {
                    incr ip_prefix_length $ip_prefix_step
                    set ip_increment_by prefix
                }
                
                if {[info exists ipaddress_pool_step] || (![info exists ipaddress_pool_step] && ![info exists ipaddress_pool_prefix_step])} {
                    if {![info exists ip_step]} {
                        # Set default for IP step
                        if {$ip_version == 4} {
                            set ipaddress_pool_step 0.1.0.0
                        } else {
                            set ipaddress_pool_step 0000:0000:0000:0000:0000:0000:0000:0100
                        }
                    }
                    set ipaddress_pool_increment_by step
                } else {
                    incr ipaddress_pool_prefix_length $ipaddress_pool_prefix_step
                    set ipaddress_pool_increment_by prefix
                }
                
                foreach {base increment type depends_on} $incrementList {
                    if {[string first ip $type] != -1 && [info exists $depends_on] && \
                            [set $depends_on] == "prefix"} {continue}
                    if {[info exists $base] && [info exists $increment]} {
                        switch $type {
                            ipv4 {
                                set $base [increment_ipv4_address_hltapi [set $base] [set $increment]]
                            }
                            ipv6 {
                                set $base [increment_ipv6_address_hltapi [set $base] [set $increment]]
                            }
                            ipv4_6 {
                                set $base [increment_ipv${ip_version}_address_hltapi [set $base] [set $increment]]
                            }
                            integer {
                                set $base [incr $base [set $increment]]
                            }
                            mac {
                                set $base [incr_mac_addr [convertToIxiaMac [set $base] ":"] [convertToIxiaMac [set $increment]  ":"]]
                            }
                        }
                    }
                }
            }
            incr index
        }
    } 
    
    if {$mode == "modify"} {
        set returnDhcpRangeList $dhcp_range_objrefs
        foreach dhcp_range_objref $dhcp_range_objrefs range_objref $range_objrefs {
            # Set DHCP Server Range
            dhcpServerServerRange
            
            # Set DHCP ATM/MAC Range
            dhcpServerMacRange
            
            # Set VLAN Range
            dhcpServerVlanRange
            
            # Set PVC Range
            dhcpServerPvcRange
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList handle.dhcp_handle $returnDhcpRangeList
    keylset returnList handle.port_handle $port_objrefs
    return $returnList
}

proc ::ixia::ixnetwork_dhcp_server_control { args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    set handle_list {}
    if {![info exists port_handle] && ![info exists dhcp_handle]} {
        set stack_type_list { ethernet atm }
        set vport_list [ixNet getList [ixNet getRoot] vport]
        set handle_list {}
        foreach vp $vport_list {
            foreach st $stack_type_list {
                set ret_val [::ixia::ixNetworkValidateSMPlugins $vp $st "dhcpServerEndpoint"]
                if {[keylget ret_val status] == $::SUCCESS && [keylget ret_val summary] == 3} {
                    set handle_list [concat $handle_list [keylget ret_val ret_val]]
                }
            }
        }
        if {$handle_list == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "There are no DHCP Server emulations on port(s)"
            return $returnList
        }
    } elseif {[info exists dhcp_handle]} {
        foreach dhcp_server_handle $dhcp_handle {
            catch {unset dhcp_endpoint_handle}
            regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\"[a-zA-Z0-9\-]+\"/dhcpServerEndpoint:\"[a-zA-Z0-9\-]+\"} \
                    $dhcp_server_handle dhcp_endpoint_handle
            if {[info exists dhcp_endpoint_handle]} {
                lappend handle_list $dhcp_endpoint_handle
            }
        }
        if {$handle_list == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "DHCP handle(s) provided to -dhcp_handle\
                    option are not valid DHCP Server handles.\
                    Parameter -dhcp_handle must be provided with a DHCP Server\
                    handle returned by emulation_dhcp_server_config in the key handle.dhcp_handle."
            return $returnList
        }
    } elseif {[info exists port_handle]} {
        foreach port $port_handle {
            set result [ixNetworkGetPortObjref $port]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port\
                        object reference associated to the $port port handle -\
                        [keylget result log]."
                return $returnList
            }
            set port_objref [keylget result vport_objref]
            set _l2List1 [ixNet getList $port_objref/protocolStack ethernet]
            set _l2List2 [ixNet getList $port_objref/protocolStack atm]
            set _l2List  [concat $_l2List1 $_l2List2]
            foreach _l2Elem $_l2List {
                set _dhcpList  [ixNet getList $_l2Elem dhcpServerEndpoint]
                set handle_list [concat $handle_list $_dhcpList]
            }
        }
        if {$handle_list == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "Port handle(s) provided to -port_handle option do not have any DHCP Server emulations configured."
            return $returnList
        }
    }
    
    array set action_map {
        abort           {   abort          0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/dhcpServerEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/dhcpServerEndpoint:[^/]+}
                                        }
                        }
        abort_async     {   abort          1   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/dhcpServerEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/dhcpServerEndpoint:[^/]+}
                                        }
                        }
        collect            {   start          0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/dhcpServerEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/dhcpServerEndpoint:[^/]+/range:[^/]+$}
                                        }
                        }
        reset         {   stop             0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/dhcpServerEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/dhcpServerEndpoint:[^/]+/range:[^/]+$}
                                                }
                        }
        renew           {   {stop start}   0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/dhcpServerEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/dhcpServerEndpoint:[^/]+/range:[^/]+$}
                                        }
                        }
    }
    
    foreach handle $handle_list {
        if {[ixNet exists $handle] == "false" || [ixNet exists $handle] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "invalid or incorect -handle."
            return $returnList
        }
    
        foreach regexp_elem [lindex $action_map($action) 2] {
            if {[regexp $regexp_elem $handle handle_temp]} {
                set handle $handle_temp
                break;
            }
        }
        
        foreach action_elem [lindex $action_map($action) 0] {
            set ixNetworkExecParamsAsync [list $action_elem  $handle]
            set ixNetworkExecParamsSync  [list $action_elem  $handle]
            if {[lindex $action_map($action) 1]} {
                lappend ixNetworkExecParamsAsync async
            }
            
            if {[catch {ixNetworkExec $ixNetworkExecParamsAsync} status]} {
                if {[string first "no matching exec found" $status] != -1} {
                    if {[catch {ixNetworkExec $ixNetworkExecParamsSync} status] && \
                            ([string first "::ixNet::OK" $status] == -1)} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to $action DHCP. Returned status: $status"
                        return $returnList
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action DHCP. Returned status: $status"
                    return $returnList
                }
            } else {
                if {[string first "::ixNet::OK" $status] == -1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action DHCP. Returned status: $status"
                    return $returnList
                }
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_dhcp_server_stats { args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -mandatory_args $man_args     \
            -optional_args  $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {[string compare -nocase $action "clear"] == 0} {
        if {[set retCode [catch {ixNet exec clearStats} retCode]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to clear statistics."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {![info exists port_handle] && ![info exists dhcp_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "One of the parameters\
                -port_handle or -dhcp_handle must be provided."
        return $returnList
    }
    
    if {![info exists port_handle]} {
        set port_handles ""
        foreach handleElem $dhcp_handle {
            set retCode [ixNetworkGetPortFromObj $handleElem]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            lappend port_handles [keylget retCode port_handle]
        }
    } else {
        set port_handles $port_handle
    }
    set portIndex 0
    foreach port_handle $port_handles {
        set result [ixNetworkGetPortObjref $port_handle]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the port\
                    object reference associated to the $port_handle port handle -\
                    [keylget result log]."
            return $returnList
        }
        set port_objref [keylget result vport_objref]
        
        # DHCP Aggregate Statistics
        if {$ip_version == 4} {
            array set stats_array_aggregate {
                "Port Name"
                {port_name        {} }
                "Discovers Received"
                {rx.discover      {} }
                "Offers Sent"
                {tx.offer         {} }
                "Requests Received"
                {rx.request       {} }
                "ACKs Sent"
                {tx.ack           {} }
                "NACKs Sent"
                {tx.nak           {} }
                "Declines Received"
                {rx.decline       {} }
                "Releases Received"
                {rx.release       {} }
                "Informs Received"
                {rx.inform        {} }
                "Total Leases Allocated"
                {total_leases_allocated      {} }
                "Total Leases Renewed"
                {total_leases_renewed        {} }
                "Current Leases Allocated"
                {current_leases_allocated    {} }
            }
        } else {
            array set stats_array_aggregate {
                "Port Name"
                {port_name         {}}
                "Solicits Received"
                {rx.solicit {}}
                "Advertisements Sent"
                {tx.advertisement  {}}
                "Requests Received"
                {rx.request        {}}
                "Confirms Received"
                {rx.confirm  {}}
                "Renewals Received"
                {rx.renew  {}}
                "Rebinds Received"
                {rx.rebind  {}}
                "Replies Sent"
                {tx.reply {}}
                "Releases Received"
                {rx.release  {}}
                "Declines Received"
                {rx.decline {}}
                "Informs Received"
                {rx.inform {}}
                "Relay Forwards Received"
                {rx.relay_forward  {}}
                "Relay Replies Sent"
                {rx.relay_reply {}}
                "Total Addresses Allocated"
                {total_addresses_allocated {}}
                "Total Addresses Renewed"
                {total_addresses_renewed {}}
                "Current Addresses Allocated"
                {current_addresses_allocated {}}
                "Total Prefixes Allocated"
                {total_prefixes_allocated {}}
                "Total Prefixes Renewed"
                {total_prefixes_Renewed {}}
                "Current Prefixes Allocated"
                {current_prefixes_allocated {}}
            }
        }
        
        set statistic_types [list \
            aggregate           "DHCPv${ip_version} Server" \
        ]
        
        array set statViewBrowserNamesArray $statistic_types
        foreach stat_type [array names statViewBrowserNamesArray] {
            lappend statViewBrowserNamesList \
                    $statViewBrowserNamesArray($stat_type)
        }
        set enableStatus [enableStatViewList $statViewBrowserNamesList]
        if {[keylget enableStatus status] == $::FAILURE} {
            return $enableStatus
        }
        after 2000

        foreach {stat_type stat_name} $statistic_types {
            # Array
            set stats_array_name  stats_array_${stat_type}
            array set stats_array [array get $stats_array_name]
            
            # List
            set stats_list        [array names stats_array]
            
            set returned_stats_list [ixNetworkGetStats $stat_name $stats_list]
            if {[keylget returned_stats_list status] == $::FAILURE} {
                  continue
            }
            
            set found false
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

                if {"$port_handle" eq "$chassis_no/$card_no/$port_no"} {
                    set found true
                    foreach stat $stats_list {
                        if {[info exists rows_array($i,$stat)] && \
                                $rows_array($i,$stat) != ""} {
                            keylset returnList ${stat_type}.${port_handle}.[lindex $stats_array($stat) 0] \
                                    $rows_array($i,$stat)
                        } else {
                            keylset returnList ${stat_type}.${port_handle}.[lindex $stats_array($stat) 0] "N/A"
                        }
                    }
                    break
                }
            }
            if {!$found} {
                keylset returnList status $::FAILURE
                keylset returnList log "The '$port' port couldn't be\
                        found among the ports from which statistics were\
                        gathered."
                return $returnList
            }
        }
        
        incr portIndex
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


