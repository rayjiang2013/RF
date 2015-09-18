proc ::ixia::ixnetwork_eigrp_config { args opt_args } {
    variable objectMaxCount
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {$mode == "create" && ![info exists intf_ip_addr]} {
        catch {unset intf_gw_ip_addr}
    }
        
    if {$mode == "create" && ![info exists intf_ipv6_addr]} {
        catch {unset intf_gw_ipv6_addr}
    }
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    # Check is -mode parameter dependencies are provided
    set retCode [checkEigrpRouterModeDependencies]
    if {[keylget retCode status] == $::FAILURE } {
        return $retCode
    }
    
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }
    array set eigrpOptionsMappingArray {
        ip_version,4 ipv4
        ip_version,6 ipv6
    }
    array set eigrpRouterOptionsArray {
        routerId                router_id
        activeTime              active_time
        asNumber                as_number
        discardLearnedRoutes    discard_learned_routes
        eigrpAddressFamily      ip_version
        eigrpMajorVersion       eigrp_major_version
        eigrpMinorVersion       eigrp_minor_version
        enablePiggyBack         enable_piggyback
        enabled                 router_enabled
        iosMajorVersion         ios_major_version
        iosMinorVersion         ios_minor_version
        k1                      k1
        k2                      k2
        k3                      k3
        k4                      k4
        k5                      k5
        routerId                router_id
    }
    
    array set enabledValue {
        create     true
        enable     true
        disable    false
    }
    array set eigrpInterfaceOptionsArray {
        bandwidth               bandwidth
        delay                   delay
        enableBfdRegistration   bfd_registration
        enabled                 interface_enabled
        helloInterval           hello_interval
        holdTime                hold_time
        load                    load
        maxTlvPerPacket         max_tlv_per_pkt
        mtu                     mtu
        reliability             reliability
        splitHorizon            split_horizon
    }
    if {[info exists enabledValue($mode)]} {
        set router_enabled    $enabledValue($mode)
    }
    set interface_enabled true
    
    
    if {$mode == "delete"} {
        foreach {rHandle} $handle {
            debug "ixNet remove $rHandle"
            if {[ixNet remove $rHandle] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to remove handle $rHandle."
                return $returnList
            }
        }
        
        debug "ixNet commit"
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to remove -handle $handle."
            return $returnList
        }
        
        keylset returnList router_handles $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }

    if {($mode == "enable") || ($mode == "disable")} {
        foreach {rHandle} $handle {
            set retCode [ixNetworkNodeSetAttr $rHandle [list -enabled $router_enabled]]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
        debug "ixNet commit"
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to $mode -handle $handle."
            return $returnList
        }
        
        keylset returnList router_handles $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {$mode == "create"} {
        if {[info exists ip_version]} {
            if {$ip_version == "4"} {
                if {![info exists interface_handle] && ![info exists intf_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When -ip_version is '4', -intf_ip_addr parameter\
                            must be specified."
                    return $returnList
                }
            } else {
                if {![info exists interface_handle] && ![info exists intf_ipv6_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When -ip_version is '6', -intf_ipv6_addr parameter\
                            must be specified."
                    return $returnList
                }
            }
        }
        
        # Add port after connecting to IxNetwork TCL Server
        set retCode [ixNetworkPortAdd $port_handle {} force]
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        set retCode [ixNetworkGetPortObjref $port_handle]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the port object reference \
                    associated to the $port_handle port handle -\
                    [keylget retCode log]."
            return $returnList
        }
        set vport_objref    [keylget retCode vport_objref]
        set protocol_objref [keylget retCode vport_objref]/protocols/eigrp
        
        # Check if protocols are supported
        set retCode [checkProtocols $vport_objref]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Port $port_handle does not support protocol\
                    configuration."
            return $returnList
        }
        
        if {[info exists reset]} {
            set result [ixNetworkNodeRemoveList $protocol_objref \
                    { {child remove router} {} } -commit]
            if {[keylget result status] == $::FAILURE} {
                return $returnList
            }
        }
        
        # Compose list of protocol options
        set eigrp_protocol_args "-enabled true"
        set retCode [ixNetworkNodeSetAttr $protocol_objref $eigrp_protocol_args -commit]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
               
        # Configure the protocol interfaces
        if {[info exists interface_handle] && \
                ([llength $interface_handle] != $count)} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -interface_handle list should have\
                    $count elements. Currently it has\
                    [llength $interface_handle] elements."
            return $returnList
        } elseif {[info exists interface_handle]} {
            set intf_list [list]
            foreach intf $interface_handle {
                lappend intf_list $intf
            }
            keylset returnList interface_handles \
                    $interface_handle
        } else {
            if {([info exists gre_ip_addr] || [info exists gre_ipv6_addr]) && \
                    [info exists gre_dst_ip_addr]} {
                set loopback_count       0
                set gre_count            1
                set gre_src_ip_addr_mode connected
            } else {
                set loopback_count       0
                set gre_count            0
            }
            if {[info exists vlan_id_step] && ($vlan_id_step > 0)} {
                set vlan_id_mode increment
            } else {
                set vlan_id_mode fixed
            }
            if {![info exists gre_dst_ip_addr_step] && [info exists gre_dst_ip_addr]} {
                if {[isIpAddressValid $gre_dst_ip_addr]} {
                    set gre_dst_ip_addr_step 0.0.0.1
                } else {
                    set gre_dst_ip_addr_step [::ixia::expand_ipv6_addr 0::1]
                }
            }
            set protocol_intf_options {
                -atm_encapsulation           atm_encapsulation
                -atm_vci                     vci
                -atm_vci_step                vci_step
                -atm_vpi                     vpi
                -atm_vpi_step                vpi_step
                -count                       count
                -gre_count                   gre_count
                -gre_ipv4_address            gre_ip_addr
                -gre_ipv4_prefix_length      gre_ip_prefix_length
                -gre_ipv4_address_step       gre_ip_addr_step
                -gre_ipv6_address            gre_ipv6_addr
                -gre_ipv6_prefix_length      gre_ipv6_prefix_length
                -gre_ipv6_address_step       gre_ipv6_addr_step
                -gre_dst_ip_address          gre_dst_ip_addr
                -gre_dst_ip_address_step     gre_dst_ip_addr_step
                -gre_src_ip_address          gre_src_ip_addr_mode
                -gre_checksum_enable         gre_checksum_enable
                -gre_seq_enable              gre_seq_enable
                -gre_key_enable              gre_key_enable
                -gre_key_in                  gre_key_in
                -gre_key_in_step             gre_key_in_step
                -gre_key_out                 gre_key_out
                -gre_key_out_step            gre_key_out_step
                -ipv4_address                intf_ip_addr
                -ipv4_prefix_length          intf_ip_prefix_length
                -ipv4_address_step           intf_ip_addr_step
                -ipv6_address                intf_ipv6_addr
                -ipv6_prefix_length          intf_ipv6_prefix_length
                -ipv6_address_step           intf_ipv6_addr_step
                -gateway_address             intf_gw_ip_addr
                -gateway_address_step        intf_gw_ip_addr_step
                -ipv6_gateway                intf_gw_ipv6_addr
                -ipv6_gateway_step           intf_gw_ipv6_addr_step
                -loopback_count              loopback_count
                -mac_address                 mac_address_init
                -mac_address_step            mac_address_step
                -mtu                         mtu
                -override_existence_check    override_existence_check
                -override_tracking           override_tracking
                -port_handle                 port_handle
            }

            lappend protocol_intf_options \
                    -vlan_enabled                vlan                \
                    -vlan_id                     vlan_id            \
                    -vlan_id_mode                vlan_id_mode       \
                    -vlan_id_step                vlan_id_step       \
                    -vlan_user_priority          vlan_user_priority

            
            set protocol_intf_args ""
            foreach {option value_name} $protocol_intf_options {
                if {[info exists $value_name]} {
                    append protocol_intf_args " $option [set $value_name]"
                }
            }
    
            # Create the necessary interfaces
            set cfg_intf_list [eval ixNetworkProtocolIntfCfg \
                    $protocol_intf_args]
            if {[keylget cfg_intf_list status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to create the\
                        protocol interfaces. [keylget cfg_intf_list log]"
                return $returnList
            }
            
            if {($gre_count > 0) && \
                    ([info exists gre_ip_addr] || [info exists gre_ipv6_addr]) && \
                    [info exists gre_dst_ip_addr]} {
                set intf_list [keylget cfg_intf_list gre_interfaces]
            } else {
                set intf_list [keylget cfg_intf_list connected_interfaces]
            }
            keylset returnList interface_handles $intf_list
        }
        
        # Compose list of router interface options
        set eigrp_intf_args ""
        foreach {ixnOpt hltOpt}  [array get eigrpInterfaceOptionsArray] {
            if {[info exists $hltOpt]} {
                if {[info exists eigrpOptionsMappingArray($hltOpt,[set $hltOpt])]} {
                    lappend eigrp_intf_args -$ixnOpt $eigrpOptionsMappingArray($hltOpt,[set $hltOpt])
                } else {
                    lappend eigrp_intf_args -$ixnOpt [set $hltOpt]
                }
            }
        }
                
        set eigrp_router_list ""
        set eigrp_router_interface_list ""
        set eigrp_router_protocol_interface_list ""
        set objectCount     0
        for {set routerId 0} {$routerId < $count} {incr routerId} {
            # Compose list of router options
            set eigrp_router_args ""
            foreach {ixnOpt hltOpt}  [array get eigrpRouterOptionsArray] {
                if {[info exists $hltOpt]} {
                    if {[info exists eigrpOptionsMappingArray($hltOpt,[set $hltOpt])]} {
                        lappend eigrp_router_args -$ixnOpt $eigrpOptionsMappingArray($hltOpt,[set $hltOpt])
                    } else {
                        lappend eigrp_router_args -$ixnOpt [set $hltOpt]
                    }
                }
            }
            
            # Create router
            set retCode [ixNetworkNodeAdd $protocol_objref router \
                    $eigrp_router_args]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to add EIGRP router.\
                        [keylget retCode log]."
                return $returnList
            }
            set router_objref [keylget retCode node_objref]
            if {$router_objref == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to add router to the \
                        $protocol_objref protocol object reference."
                return $returnList
            }
            incr objectCount
            if {$objectCount == $objectMaxCount} {
                debug "ixNet commit"
                ixNet commit
                set objectCount 0
            }
            lappend eigrp_router_list $router_objref
            
            # Create router interface
            
            set intf_objref [lindex $intf_list $routerId]
            set eigrp_intf_final_args "$eigrp_intf_args \
                    -interfaceId $intf_objref"
            
            set retCode [ixNetworkNodeAdd $router_objref interface \
                    $eigrp_intf_final_args]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to add EIGRP router interface.
                        [keylget retCode log]."
                return $returnList
            }
            set router_intf_objref [keylget retCode node_objref]
            if {$router_intf_objref == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to add EIGRP router interface\
                        to the $router_objref router object reference"
                return $returnList
            }
            incr objectCount
            if {$objectCount == $objectMaxCount} {
                debug "ixNet commit"
                ixNet commit
                set objectCount 0
            }
            
            lappend eigrp_router_interface_list          $router_intf_objref
            lappend eigrp_router_protocol_interface_list $intf_objref
            set router_id [::ixia::incr_ipv4_addr $router_id $router_id_step]
            set as_number [mpexpr $as_number + $as_number_step]
        }
        
        if {$objectCount > 0} {
            debug "ixNet commit"
            ixNet commit
            set objectCount 0
        }
        if {$eigrp_router_list != ""} {
            debug "ixNet remapIds {$eigrp_router_list}"
            set eigrp_router_list [ixNet remapIds $eigrp_router_list]
        }
        if {$eigrp_router_interface_list != ""} {
            debug "ixNet remapIds {$eigrp_router_interface_list}"
            set eigrp_router_interface_list [ixNet remapIds $eigrp_router_interface_list]
        }
        
        keylset returnList status         $::SUCCESS
        keylset returnList router_handles $eigrp_router_list
        return $returnList
    }
    
    if {$mode == "modify"} {
        
        array set translate_intf_type {
            default connected
            routed  unconnected
            gre     gre
        }
        set connected_intf_options {
            -atm_encapsulation           atm_encapsulation
            -atm_vci                     vci
            -atm_vpi                     vpi
            -ipv4_address                intf_ip_addr
            -ipv4_prefix_length          intf_ip_prefix_length
            -ipv6_address                intf_ipv6_addr
            -ipv6_prefix_length          intf_ipv6_prefix_length
            -gateway_address             intf_gw_ip_addr
            -ipv6_gateway                intf_gw_ipv6_addr
            -mac_address                 mac_address_init
            -mtu                         mtu
            -vlan_enabled                vlan
            -vlan_id                     vlan_id
            -vlan_user_priority          vlan_user_priority
        }
        set unconnected_intf_options {
            -loopback_ipv4_address       loopback_ip_addr
            -loopback_ipv4_prefix_length loopback_ip_prefix_length
            -loopback_ipv6_address       loopback_ipv6_addr
            -loopback_ipv6_prefix_length loopback_ipv6_prefix_length
        }
        set gre_intf_options {
            -gre_ipv4_address            gre_ip_addr
            -gre_ipv4_prefix_length      gre_ip_prefix_length
            -gre_ipv6_address            gre_ipv6_addr
            -gre_ipv6_prefix_length      gre_ipv6_prefix_length
            -gre_dst_ip_address          gre_dst_ip_addr
            -gre_dst_ip_address_step     gre_dst_ip_addr_step
            -gre_src_ip_address          gre_src_ip_addr_mode
            -gre_checksum_enable         gre_checksum_enable
            -gre_seq_enable              gre_seq_enable
            -gre_key_enable              gre_key_enable
            -gre_key_in                  gre_key_in
            -gre_key_out                 gre_key_out
        }
        
        # Compose list of router options
        set eigrp_router_args ""
        foreach {ixnOpt hltOpt}  [array get eigrpRouterOptionsArray] {
            if {[info exists $hltOpt]} {
                set length [llength [set $hltOpt]]
                if {$length == [llength $handle]} {
                    lappend eigrp_router_args -$ixnOpt \
                            "\[lindex [set $hltOpt] \$handleIndex\]"
                } elseif {$length == 1} {
                    lappend eigrp_router_args -$ixnOpt [set $hltOpt]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid number of values\
                            for -$hltOpt. The number of values\
                            should be 1 or [llength $handle]."
                    return $returnList
                }
            }
        }
        # Compose list of router interface options
        set eigrp_intf_args ""
        foreach {ixnOpt hltOpt}  [array get eigrpInterfaceOptionsArray] {
            if {[info exists $hltOpt]} {
                set length [llength [set $hltOpt]]
                if {$length == [llength $handle]} {
                    lappend eigrp_intf_args -$ixnOpt \
                            "\[lindex [set $hltOpt] \$handleIndex\]"
                } elseif {$length == 1} {
                    lappend eigrp_intf_args -$ixnOpt [set $hltOpt]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid number of values\
                            for -$hltOpt. The number of values\
                            should be 1 or [llength $handle]."
                    return $returnList
                }
            }
        }
        # Compose list of protocol interface options
        foreach {prot_intf_options prot_intf_type} {
                connected_intf_options   connected
                gre_intf_options         gre} {
            
            set ${prot_intf_type}_modify_intf_args ""
            foreach {hltParam hltVarName} [set $prot_intf_options] {
                if {[info exists $hltVarName]} {
                    set length [llength [set $hltVarName]]
                    if { $length == [llength $handle]} {
                        set hltValue "\[lindex [set $hltVarName] \$handleIndex\]"
                    } elseif {$length == 1} {
                        set hltValue [set $hltVarName]
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid number of values\
                                for -$hltVarName. The number of values\
                                should be 1 or [llength $handle]."
                        return $returnList
                    }
                    append ${prot_intf_type}_modify_intf_args " $hltParam $hltValue"
                }
            }
        }
        set handleIndex 0
        foreach {rHandle} $handle {
            set router_objref  $rHandle
            set retCode [ixNetworkGetPortFromObj $rHandle]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set port_handle  [keylget retCode port_handle]
            set vport_objref [keylget retCode vport_objref]
            set protocol_objref [keylget retCode vport_objref]/protocols/eigrp
            set router_intf_objref [ixNet getList $router_objref interface]
                      
            # Setting router arguments
            if {$eigrp_router_args != ""} {
                set retCode [ixNetworkNodeSetAttr $router_objref \
                        [subst $eigrp_router_args]]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
            }
            # Setting protocol interface arguments
            set intf_objref [ixNet getAttr $router_intf_objref -interfaceId]
            set intf_type   [ixNet getAttr $intf_objref        -type]
            
            if {[set $translate_intf_type($intf_type)_modify_intf_args] != ""} {
                set modify_intf_args " \
                        -prot_intf_objref $intf_objref \
                        -port_handle      $port_handle \
                        [set $translate_intf_type($intf_type)_modify_intf_args]"
                
                set retCode [eval ixNetwork[string totitle       \
                        $translate_intf_type($intf_type)]IntfCfg \
                        [subst $modify_intf_args]]
                
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
            }
            
            # Setting router interface options
            if {$eigrp_intf_args != ""} {
                set retCode [ixNetworkNodeSetAttr $router_intf_objref \
                        [subst $eigrp_intf_args]]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
            }
            incr handleIndex
        }
        
        ixNet commit
        debug "ixNet commit"
        
        keylset returnList router_handles $handle
        keylset returnList status         $::SUCCESS
        return $returnList
    }
}

proc ::ixia::ixnetwork_eigrp_route_config {args opt_args} {
    variable objectMaxCount
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    # Check is -mode parameter dependencies are provided
    set retCode [checkEigrpRouteModeDependencies]
    if {[keylget retCode status] == $::FAILURE } {
        return $retCode
    }
    
    array set translate_mode {
        enable  true
        disable false
        create  true
    }
    if {[info exists translate_mode($mode)]} {
        set routeEnabled [set translate_mode($mode)]
    }
    
    array set translate_ext_flag {
        candidate_default  candidateDefault
        external_route     externalRoute
    }
    
    array set translate_ext_protocol {
        bgp           bgp
        connected     connected
        egp           egp
        eigrp         enhancedIgrp
        hello         hello
        idrp          idrp
        igrp          igrp
        isis          isis
        ospf          ospf
        rip           rip
        static        static
    }
    
    array set translate_type {
        internal  internal
        external  external
    }
    
    array set eigrpRouteOptionsArray {
        bandwidth       bandwidth
        delay           delay
        destCount       dst_count
        enablePacking   enable_packing
        enabled         routeEnabled
        firstRoute      prefix_start
        flag            ext_flag
        hopCount        hop_count
        load            load
        mask            prefix_length
        metric          ext_metric
        mtu             mtu
        nextHop         next_hop
        nomberOfRoutes  num_prefixes
        originatingAs   ext_originating_as
        protocolId      ext_protocol
        reliability     reliability
        routeTag        ext_route_tag
        source          ext_source
        type            type
    }
    
    set eigrpRouteDefaultValues {
        ext_source             { 0.0.0.0 0::0 }
        next_hop               { 0.0.0.0 0::0 }
        next_hop_inside_step   { 0.0.0.0 0::0 }
        next_hop_outside_step  { 0.0.0.0 0::0 }
        prefix_inside_step     { 0.1.0.0 0:0:0:1::0 }
        prefix_length          { 24      64}
        prefix_outside_step    { 1.0.0.0 0:0:1:0::0 }
    }
    if {$mode == "delete"} {
        foreach {sHandle} $route_handle {
            debug "ixNet remove $sHandle"
            if {[ixNet remove $sHandle] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to remove handle $sHandle."
                return $returnList
            }
        }
        
        debug "ixNet commit"
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to remove -route_handle\
                    $route_handle."
            return $returnList
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }

    if {($mode == "enable") || ($mode == "disable")} {
        foreach {sHandle} $route_handle {
            set retCode [ixNetworkNodeSetAttr $sHandle [list -enabled $translate_mode($mode)]]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
        debug "ixNet commit"
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to $mode -route_handle\
                    $route_handle."
            return $returnList
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
    if {$mode == "create"} {
        if {[isIpAddressValid $prefix_start]} {
            set route_ip_version ipv4
        } else {
            set route_ip_version ipv6
        }
        foreach {eigrpRouteP eigrpRouteV} $eigrpRouteDefaultValues {
            if {![info exists $eigrpRouteP]} {
                switch $route_ip_version {
                    ipv4 {
                        set $eigrpRouteP [lindex $eigrpRouteV 0]
                    }
                    ipv6 {
                        set $eigrpRouteP [lindex $eigrpRouteV 1]
                    }
                }
            }
        }
            
        set eigrp_route_list ""
        set objectCount      0
        foreach {router_handle} $handle {
            if {[info exists reset]} {
                foreach existingRoute [ixNet getList $router_handle routeRange] {
                    if {[catch {ixNet remove $existingRoute} retError]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to remove EIGRP route range.\
                                $retError."
                        return $returnList
                    }
                    incr objectCount
                    if {$objectCount == $objectMaxCount} {
                        debug "ixNet commit"
                        ixNet commit
                        set objectCount 0
                    }
                }
            }
            set router_ip_version [ixNet getAttribute $router_handle -eigrpAddressFamily]
            set prefix_start_value $prefix_start
            set next_hop_value     $next_hop
            if {$router_ip_version != $route_ip_version} {
                keylset returnList status $::FAILURE
                keylset returnList log "The EIGRP router is type\
                        $router_ip_version and the EIGRP prefix provided is\
                        $route_ip_version. The router and routes should have the same IP type."
                return $returnList
            }
            for {set routeId 0} {$routeId < $count} {incr routeId} {
                # Compose list of route options
                set eigrp_route_args ""
                foreach {ixnOpt hltOpt}  [array get eigrpRouteOptionsArray] {
                    if {[info exists $hltOpt]} {
                        if {[info exists translate_${hltOpt}([set $hltOpt])]} {
                            lappend eigrp_route_args -$ixnOpt \
                                    [set translate_${hltOpt}([set $hltOpt])]
                        } else {
                            lappend eigrp_route_args -$ixnOpt [set $hltOpt]
                        }
                    }
                }
                
                # Create route
                set retCode [ixNetworkNodeAdd $router_handle routeRange \
                        $eigrp_route_args]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to add EIGRP route range.\
                            [keylget retCode log]."
                    return $returnList
                }
                set route_objref [keylget retCode node_objref]
                incr objectCount
                if {$objectCount == $objectMaxCount} {
                    debug "ixNet commit"
                    ixNet commit
                    set objectCount 0
                }
                
                lappend eigrp_route_list $route_objref
                
                if {![isIpAddressValid $prefix_start]} {
                    set prefix_start [::ixia::incr_ipv6_addr               \
                            [::ixia::expand_ipv6_addr $prefix_start]       \
                            [::ixia::expand_ipv6_addr $prefix_inside_step] \
                            ]
                } else {
                    set prefix_start [::ixia::incr_ipv4_addr \
                            $prefix_start $prefix_inside_step]
                }
                
                if {![isIpAddressValid $next_hop]} {
                    set next_hop [::ixia::incr_ipv6_addr                     \
                            [::ixia::expand_ipv6_addr $next_hop]             \
                            [::ixia::expand_ipv6_addr $next_hop_inside_step] \
                            ]
                } else {
                    set next_hop [::ixia::incr_ipv4_addr   \
                            $next_hop $next_hop_inside_step]
                }
            }
            set prefix_start $prefix_start_value
            if {![isIpAddressValid $prefix_start]} {
                set prefix_start [::ixia::incr_ipv6_addr                \
                        [::ixia::expand_ipv6_addr $prefix_start]        \
                        [::ixia::expand_ipv6_addr $prefix_outside_step] \
                        ]
            } else {
                set prefix_start [::ixia::incr_ipv4_addr  \
                        $prefix_start $prefix_outside_step]
            }
            set next_hop $next_hop_value
            if {![isIpAddressValid $next_hop]} {
                set next_hop [::ixia::incr_ipv6_addr                      \
                        [::ixia::expand_ipv6_addr $next_hop]              \
                        [::ixia::expand_ipv6_addr $next_hop_outside_step] \
                        ]
            } else {
                set next_hop [::ixia::incr_ipv4_addr    \
                        $next_hop $next_hop_outside_step]
            }
        }
        
        if {$objectCount > 0} {
            debug "ixNet commit"
            ixNet commit
            set objectCount 0
        }
        if {$eigrp_route_list != ""} {
            debug "ixNet remapIds {$eigrp_route_list}"
            set eigrp_route_list [ixNet remapIds $eigrp_route_list]
        }
        
        keylset returnList status $::SUCCESS
        keylset returnList route_handles $eigrp_route_list
        return $returnList
    }
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
        
        # Compose list of route options
        set eigrp_route_args ""
        foreach {ixnOpt hltOpt}  [array get eigrpRouteOptionsArray] {
            if {[info exists $hltOpt]} {
                if {[info exists translate_${hltOpt}([set $hltOpt])]} {
                    lappend eigrp_route_args -$ixnOpt \
                            [set translate_${hltOpt}([set $hltOpt])]
                } else {
                    lappend eigrp_route_args -$ixnOpt [set $hltOpt]
                }
            }
        }
        set objectCount 0
        foreach {sHandle} $route_handle {
            set retCode [ixNetworkNodeSetAttr $sHandle $eigrp_route_args]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to modify EIGRP route $sHandle.\
                        [keylget retCode log]."
                return $returnList
            }
            incr objectCount
            if {$objectCount == $objectMaxCount} {
                debug "ixNet commit"
                ixNet commit
                set objectCount 0
            }
        }
        if {$objectCount > 0} {
            debug "ixNet commit"
            ixNet commit
            set objectCount 0
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
}

proc ::ixia::ixnetwork_eigrp_control {args man_args opt_args} {
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "When -mode is $mode, parameter -port_handle or\
                parameter -handle must be provided."
        return $returnList
    }
    if {[info exists port_handle]} {
        set _handles $port_handle
        set protocol_objref_list ""
        foreach {_handle} $_handles {
            set retCode [ixNetworkGetPortObjref $_handle]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set protocol_objref [keylget retCode vport_objref]
            lappend protocol_objref_list $protocol_objref/protocols/eigrp
        }
        if {$protocol_objref_list == "" } {
            keylset returnList status $::FAILURE
            keylset returnList log "All handles provided through -port_handle\
                    parameter are invalid."
            return $returnList
        }
    }
    if {[info exists handle]} {
        set _handles $handle
        set protocol_objref_list ""
        foreach {_handle} $_handles {
            set protocol_objref [ixNetworkGetProtocolObjref $_handle eigrp]
            if {$protocol_objref != [ixNet getRoot]} {
                lappend protocol_objref_list $protocol_objref
            }
        }
        if {$protocol_objref_list == "" } {
            keylset returnList status $::FAILURE
            keylset returnList log "All handles provided through -handle\
                    parameter are invalid."
            return $returnList
        }
    }
    
    # Check link state
    foreach protocol_objref $protocol_objref_list {
        regexp {(::ixNet::OBJ-/vport:\d).*} $protocol_objref {} vport_objref
        set retries 60
        set portState  [ixNet getAttribute $vport_objref -state]
        set portStateD [ixNet getAttribute $vport_objref -stateDetail]
        while {($retries > 0) && ( \
                ($portStateD != "idle") || ($portState  == "busy"))} {
            debug "Port state: $portState, $portStateD ..."
            after 1000
            set portState  [ixNet getAttribute $vport_objref -state]
            set portStateD [ixNet getAttribute $vport_objref -stateDetail]
            incr retries -1
        }
        debug "Port state: $portState, $portStateD ..."
        if {($portStateD != "idle") || ($portState == "busy")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to $mode EIGRP on the $vport_objref\
                    port. Port state is $portState, $portStateD."
            return $returnList
        }
    }
    
    if {$mode == "restart"} {
        set operations [list stop start]
    } else {
        set operations $mode
    }
    foreach operation $operations {
        foreach protocol_objref $protocol_objref_list {
            debug "ixNetworkExec [list $operation $protocol_objref]"
            if {[catch {ixNetworkExec [list $operation $protocol_objref]} retCode] || \
                    ([string first "::ixNet::OK" $retCode] == -1)} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $operation EIGRP on the\
                        $vport_objref port. Error code: $retCode."
                return $returnList
            }
        }
        after 1000
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_eigrp_info { args man_args opt_args } {
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {[info exists port_handle]} {
        set router_handles ""
        set port_handles   ""
        set port_objrefs   ""
        foreach {port} $port_handle {
            set retCode [ixNetworkGetPortObjref $port]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set vport_objref [keylget retCode vport_objref]
            lappend port_objrefs $vport_objref
            set protocol_objref $vport_objref/protocols/eigrp
            set router_objref [ixNet getList $protocol_objref router]
            append router_handles " $router_objref"
            append port_handles [string repeat " $port" [llength $router_objref]]
        }
        if {$router_handles == "" } {
            keylset returnList status $::FAILURE
            keylset returnList log "There are no EIGRP router on the ports\
                    provided through -port_handle."
            return $returnList
        }
    }
    if {[info exists handle]} {
        set port_handles   ""
        set port_objrefs   ""
        foreach {_handle} $handle {
            if {![regexp {^(.*)/protocols/eigrp/router:\d$} $_handle {} port_objref]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The handle $handle is not a valid\
                        EIGRP router handle."
                return $returnList
            }
            set retCode [ixNetworkGetPortFromObj $_handle]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            lappend port_handles  [keylget retCode port_handle]
            lappend port_objrefs  [keylget retCode vport_objref]
        }
        set router_handles $handle
    }
    
    keylset returnList status $::SUCCESS
    
    if {$mode == "clear_stats"} {
        foreach {port} $port_handles {
            debug "ixNet exec clearStats"
            if {[set retCode [catch {ixNet exec clearStats} retCode]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to clear statistics."
                return $returnList
            }
        }
    }
    
    if {$mode == "learned_info"} {
        set stats_list {
            destination    prefix
            prefix         prefix_length
            type           type
            fd             FD
            neighbor       neighbor
            rd             RD
            hopCount       hop_count
            nextHop        next_hop
        }
        
        foreach {router} $router_handles {port} $port_handles {
            debug "ixNet exec refreshLearnedInfo $router"
            set retCode [ixNet exec refreshLearnedInfo $router]
            if {[string first "::ixNet::OK" $retCode] == -1 } {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to refresh learned info for\
                        EIGRP router $router."
                return $returnList
            }
            set retries 10
            while {[ixNet getAttribute $router -isRefreshComplete] != "true"} {
                after 500
                incr retries -1
                if {$retries < 0} {
                    keylset returnList status $::SUCCESS
                    keylset returnList log "Refreshing learned info for\
                            EIGRP router $router has timed out. Please try again later."
                    
                    set route 1
                    foreach {ixnOpt hltOpt} $stats_list {
                        keylset returnList $port.$router.route.$route.$hltOpt \
                                "NA"
                    }
                    
                    return $returnList
                }
            }
            set learnedInfoList [ixNet getList $router learnedRoute]
            set route 1
            foreach {learnedInfo} $learnedInfoList {
                foreach {ixnOpt hltOpt} $stats_list {
                    keylset returnList $port.$router.route.$route.$hltOpt \
                            [ixNet getAttribute $learnedInfo -$ixnOpt]
                }
                incr route
            }
        }
        
        return $returnList
    }
    
    if {$mode == "aggregate_stats"} {
        array set stats_array_aggregate {
			"Port Name"
            port_name
            "IPv4 Routers Configured"
            ipv4_routers_configured
            "IPv4 Routers Running"
            ipv4_routers_running
            "IPv6 Routers Configured"
            ipv6_routers_configured
            "IPv6 Routers Running"
            ipv6_routers_running
            "IPv4 Neighbors Learned"
            ipv4_neighbors_learned
            "IPv4 Neighbors Deleted"
            ipv4_neighbors_deleted
            "IPv6 Neighbors Learned"
            ipv6_neighbors_learned
            "IPv6 Neighbors Deleted"
            ipv6_neighbors_deleted
            "IPv4 Routes Tx"
            ipv4_routes_advertised_tx
            "IPv4 Routes Rx"
            ipv4_routes_advertised_rx
            "IPv4 Routes Withdrawn"
            ipv4_routes_withdrawn_tx
            "IPv4 Route Withdraws Rx"
            ipv4_routes_withdraws_rx
            "IPv6 Routes Tx"
            ipv6_routes_advertised_tx
            "IPv6 Routes Rx"
            ipv6_routes_advertised_rx
            "IPv6 Routes Withdrawn"
            ipv6_routes_withdrawn_tx
            "IPv6 Route Withdraws Rx"
            ipv6_routes_withdraws_rx
            "IPv4 Routes Learned"
            ipv4_routes_learned
            "IPv6 Routes Learned"
            ipv6_routes_learned
            "Hellos Tx"
            hellos_tx
            "Hellos Rx"
            hellos_rx
            "Updates Tx"
            updates_tx
            "Updates Rx"
            updates_rx
            "Queries Tx"
            queries_tx
            "Queries Rx"
            queries_rx
            "Replies Tx"
            replies_tx
            "Replies Rx"
            replies_rx
            "ACKs Tx"
            acks_tx
            "ACKs Rx"
            acks_rx
            "Packets Tx"
            pkts_tx
            "Packets Rx"
            pkts_rx
            "Retransmission Count"
            retransmission_count
        }
        
        set statistic_types {
            aggregate "EIGRP Aggregated Statistics"
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
                            keylset returnList ${port_key}.${stat_type}.$stats_array($stat) \
                                    $rows_array($i,$stat)
                        } else {
                            keylset returnList ${port_key}.${stat_type}.$stats_array($stat) "N/A"
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
    }
    
    return $returnList
}
