proc ::ixia::ixnetwork_bfd_config { args opt_args } {
    variable objectMaxCount
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
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    # Check is -mode parameter dependencies are provided
    set retCode [checkBfdRouterModeDependencies]
    if {[keylget retCode status] == $::FAILURE } {
        return $retCode
    }
    
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }
    
    array set bfdProtocolOptionsArray {
        packetsPerInterval pkts_per_control_interval
        intervalValue      control_interval
    }
    
    array set bfdRouterOptionsArray {
        enabled     router_enabled
        routerId    router_id
    }
    
    array set enabledValue {
        create     true
        enable     true
        disable    false
    }
    array set bfdInterfaceOptionsArray {
        echoInterval                echo_rx_interval
        echoTimeout                 echo_timeout
        echoTxInterval              echo_tx_interval
        enableCtrlPlaneIndependent  enable_ctrl_plane_independent
        enableDemandMode            enable_demand_mode
        enabled                     interface_enabled
        flapTxInterval              flap_tx_interval
        minRxInterval               min_rx_interval
        multiplier                  multiplier
        pollInterval                poll_interval
        txInterval                  tx_interval
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
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {$mode == "create"} {
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
        set protocol_objref [keylget retCode vport_objref]/protocols/bfd
        
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
        set bfd_protocol_args "-enabled true"
        foreach {ixnOpt hltOpt}  [array get bfdProtocolOptionsArray] {
            if {[info exists $hltOpt]} {
                lappend bfd_protocol_args -$ixnOpt [set $hltOpt]
            }
        }
        set retCode [ixNetworkNodeSetAttr $protocol_objref $bfd_protocol_args -commit]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
        
        # Set count options
        if {$loopback_count == 0} {
            set intf_loopback_count 1
        } else {
            set intf_loopback_count $loopback_count
        }
        if {$gre_count == 0} {
            set intf_gre_count 1
        } else {
            set intf_gre_count $gre_count
        }
        
        
        # Configure the protocol interfaces
        if {[info exists interface_handle] && ([llength $interface_handle] != \
                [expr $count * $intf_count * $intf_loopback_count * $intf_gre_count])} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -interface_handle list should have\
                    [expr $count * $intf_count * $intf_loopback_count * \
                    $intf_gre_count] elements. Currently it has\
                    [llength $interface_handle] elements."
            return $returnList
        } elseif {[info exists interface_handle]} {
            set intf_list [list]
            foreach intf $interface_handle {
                lappend intf_list $intf
            }
        } else {
            set connected_count [expr $intf_count * $count]
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
                -count                       connected_count
                -gre_count                   gre_count
                -gre_ipv4_address            gre_ip_addr
                -gre_ipv4_prefix_length      gre_ip_prefix_length
                -gre_ipv4_address_step       gre_ip_addr_step
                -gre_ipv4_address_outside_connected_step      gre_ip_addr_cstep
                -gre_ipv4_address_outside_loopback_step       gre_ip_addr_lstep
                -gre_ipv6_address            gre_ipv6_addr
                -gre_ipv6_prefix_length      gre_ipv6_prefix_length
                -gre_ipv6_address_step       gre_ipv6_addr_step
                -gre_ipv6_address_outside_connected_step      gre_ipv6_addr_cstep
                -gre_ipv6_address_outside_loopback_step       gre_ipv6_addr_lstep
                -gre_dst_ip_address          gre_dst_ip_addr
                -gre_dst_ip_address_step     gre_dst_ip_addr_step
                -gre_dst_ip_address_outside_connected_step    gre_dst_ip_addr_cstep
                -gre_dst_ip_address_outside_loopback_step     gre_dst_ip_addr_lstep
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
                -loopback_count              loopback_count
                -loopback_ipv4_address       loopback_ip_addr
                -loopback_ipv4_prefix_length loopback_ip_prefix_length
                -loopback_ipv4_address_step  loopback_ip_addr_step
                -loopback_ipv4_address_outside_step           loopback_ip_addr_cstep
                -loopback_ipv6_address       loopback_ipv6_addr
                -loopback_ipv6_prefix_length loopback_ipv6_prefix_length
                -loopback_ipv6_address_step  loopback_ipv6_addr_step
                -loopback_ipv6_address_outside_step           loopback_ipv6_addr_cstep
                -mac_address                 mac_address_init
                -mac_address_step            mac_address_step
                -mtu                         mtu
                -override_existence_check    override_existence_check
                -override_tracking           override_tracking
                -port_handle                 port_handle
            }
            
            lappend protocol_intf_options \
                    -vlan_enabled                vlan               \
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
            set intf_list [eval ixNetworkProtocolIntfCfg \
                    $protocol_intf_args]
            if {[keylget intf_list status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to create the\
                        protocol interfaces. [keylget intf_list log]"
                return $returnList
            }
            
            if {($gre_count > 0) && \
                    ([info exists gre_ip_addr] || [info exists gre_ipv6_addr]) && \
                    [info exists gre_dst_ip_addr]} {
                set intf_list [keylget intf_list gre_interfaces]
            } elseif {($loopback_count > 0) && \
                    ([info exists loopback_ip_addr] || [info exists loopback_ipv6_addr])} {
                set intf_list [keylget intf_list routed_interfaces]
            } else {
                set intf_list [keylget intf_list connected_interfaces]
            }
            
            if {[llength $intf_list] != [expr $count * $intf_count * $intf_loopback_count * $intf_gre_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Not all protocol interfaces have been\
                        created. Please check the parameters provided for\
                        creating interfaces."
                return $returnList
            }
        }
        
        # Compose list of router interface options
        set bfd_intf_args ""
        foreach {ixnOpt hltOpt}  [array get bfdInterfaceOptionsArray] {
            if {[info exists $hltOpt]} {
                lappend bfd_intf_args -$ixnOpt [set $hltOpt]
            }
        }
        
        set intfListIndex 0
        set intfCount [expr $intf_count * $intf_loopback_count * $intf_gre_count]
        
        set bfd_router_list ""
        set bfd_router_interface_list ""
        set bfd_router_protocol_interface_list ""
        set objectCount     0
        for {set routerId 0} {$routerId < $count} {incr routerId} {
            # Compose list of router options
            set bfd_router_args ""
            foreach {ixnOpt hltOpt}  [array get bfdRouterOptionsArray] {
                if {[info exists $hltOpt]} {
                    lappend bfd_router_args -$ixnOpt [set $hltOpt]
                }
            }
            
            # Create router
            set retCode [ixNetworkNodeAdd $protocol_objref router \
                    $bfd_router_args]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to add BFD router.\
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
            lappend bfd_router_list $router_objref
            
            for {set intfIndex $intfListIndex} {$intfIndex < [expr $intfListIndex + $intfCount]} {incr intfIndex} {
                set intf_objref [lindex $intf_list $intfIndex]
                
                set bfd_intf_final_args "$bfd_intf_args \
                        -interfaceId $intf_objref"
                
                set retCode [ixNetworkNodeAdd $router_objref interface \
                        $bfd_intf_final_args]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to add BFD router interface.
                            [keylget retCode log]."
                    return $returnList
                }
                set router_intf_objref [keylget retCode node_objref]
                if {$router_intf_objref == [ixNet getNull]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to add BFD router interface\
                            to the $router_objref router object reference"
                    return $returnList
                }
                incr objectCount
                if {$objectCount == $objectMaxCount} {
                    debug "ixNet commit"
                    ixNet commit
                    set objectCount 0
                }
                
                lappend bfd_router_interface_list          $router_intf_objref
                lappend bfd_router_protocol_interface_list $intf_objref
            }
            set intfListIndex [expr $intfListIndex + $intfCount]
            set router_id [::ixia::incr_ipv4_addr $router_id $router_id_step]
        }
        
        if {$objectCount > 0} {
            debug "ixNet commit"
            ixNet commit
            set objectCount 0
        }
        if {$bfd_router_list != ""} {
            debug "ixNet remapIds {$bfd_router_list}"
            set bfd_router_list [ixNet remapIds $bfd_router_list]
        }
        if {$bfd_router_interface_list != ""} {
            debug "ixNet remapIds {$bfd_router_interface_list}"
            set bfd_router_interface_list [ixNet remapIds $bfd_router_interface_list]
        }
        
        keylset returnList status         $::SUCCESS
        keylset returnList router_handles $bfd_router_list
        set intfIndex 0
        foreach {router} $bfd_router_list {
            keylset returnList router_interface_handles.$router \
                    [lrange $bfd_router_interface_list \
                    $intfIndex [expr $intfIndex + $intfCount - 1]]
            
            keylset returnList interface_handles.$router \
                    [lrange $bfd_router_protocol_interface_list \
                    $intfIndex [expr $intfIndex + $intfCount - 1]]
            
            incr intfIndex $intfCount
        }
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
        # Compose list of protocol options
        set bfd_protocol_args ""
        foreach {ixnOpt hltOpt}  [array get bfdProtocolOptionsArray] {
            if {[info exists $hltOpt]} {
                set length [llength [set $hltOpt]]
                if {$length == [llength $handle]} {
                    lappend bfd_protocol_args -$ixnOpt \
                            "\[lindex [set $hltOpt] \$handleIndex\]"
                } elseif {$length == 1} {
                    lappend bfd_protocol_args -$ixnOpt [set $hltOpt]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid number of values\
                            for -$hltOpt. The number of values\
                            should be 1 or [llength $handle]."
                    return $returnList
                }
            }
        }
        # Compose list of router options
        set bfd_router_args ""
        foreach {ixnOpt hltOpt}  [array get bfdRouterOptionsArray] {
            if {[info exists $hltOpt]} {
                set length [llength [set $hltOpt]]
                if {$length == [llength $handle]} {
                    lappend bfd_router_args -$ixnOpt \
                            "\[lindex [set $hltOpt] \$handleIndex\]"
                } elseif {$length == 1} {
                    lappend bfd_router_args -$ixnOpt [set $hltOpt]
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
        set bfd_intf_args ""
        foreach {ixnOpt hltOpt}  [array get bfdInterfaceOptionsArray] {
            if {[info exists $hltOpt]} {
                set length [llength [set $hltOpt]]
                if {$length == [llength $handle]} {
                    lappend bfd_intf_args -$ixnOpt \
                            "\[lindex [set $hltOpt] \$handleIndex\]"
                } elseif {$length == 1} {
                    lappend bfd_intf_args -$ixnOpt [set $hltOpt]
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
                unconnected_intf_options unconnected
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
            if {[regexp {router:\d*$} $rHandle]} {
                set router_objref  $rHandle
                set retCode [ixNetworkGetPortFromObj $rHandle]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
                set port_handle  [keylget retCode port_handle]
                set vport_objref [keylget retCode vport_objref]
                set protocol_objref [keylget retCode vport_objref]/protocols/bfd
                
                set router_intf_objrefs [ixNet getList $router_objref interface]
            } elseif {[regexp {router:\d*/interface:\d*$} $rHandle]} {
                set router_intf_objrefs $rHandle
                set router_objref       [ixNet getParent $rHandle]
                set retCode [ixNetworkGetPortFromObj $rHandle]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
                set port_handle     [keylget retCode port_handle]
                set vport_objref    [keylget retCode vport_objref]
                set protocol_objref [keylget retCode vport_objref]/protocols/bfd
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid BFD handle $rHandle. Parameter\
                        -handle must provide with a list of BFD routers or\
                        BFD router interfaces."
                return $returnList
            }
            # Setting protocol options
            if {$bfd_protocol_args != ""} {
                set retCode [ixNetworkNodeSetAttr $protocol_objref \
                        [subst $bfd_protocol_args]]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
            }            
            # Setting router arguments
            if {$bfd_router_args != ""} {
                set retCode [ixNetworkNodeSetAttr $router_objref \
                        [subst $bfd_router_args]]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
            }
            foreach {router_intf_objref} $router_intf_objrefs {
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
                if {$bfd_intf_args != ""} {
                    set retCode [ixNetworkNodeSetAttr $router_intf_objref \
                            [subst $bfd_intf_args]]
                    if {[keylget retCode status] == $::FAILURE} {
                        return $retCode
                    }
                }
            }
            incr handleIndex
        }
        
        ixNet commit
        debug "ixNet commit"
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
}

proc ::ixia::ixnetwork_bfd_session_config {args opt_args} {
    variable objectMaxCount
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    # Check is -mode parameter dependencies are provided
    set retCode [checkBfdSessionModeDependencies]
    if {[keylget retCode status] == $::FAILURE } {
        return $retCode
    }
    
    array set session_enable {
        enable  true
        disable false
        create  true
    }
    
    array set translate_ip_version {
        4             ipv4
        6             ipv6
    }
    array set translate_session_type {
        multi_hop     multipleHops
        single_hop    singleHop
    }
    
    set bfdSessionOptionsList [list                             \
        myDisc                       local_disc                  \
        bfdSessionType               session_type                \
        ipType                       ip_version                  \
        remoteBfdAddress             remote_ip_addr              \
        remoteDiscLearned            enable_learned_remote_disc  \
        enabledAutoChooseSource      enable_auto_choose_source   \
        localBfdAddress              local_ip_addr               \
        enabled                      session_enable($mode)       \
        remoteDisc                   remote_disc                 \
    ]
    
    
    if {$mode == "delete"} {
        foreach {sHandle} $session_handle {
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
            keylset returnList log "Failed to remove -session_handle\
                    $session_handle."
            return $returnList
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }

    if {($mode == "enable") || ($mode == "disable")} {
        foreach {sHandle} $session_handle {
            set retCode [ixNetworkNodeSetAttr $sHandle [list -enabled $session_enable($mode)]]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
        debug "ixNet commit"
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to $mode -session_handle\
                    $session_handle."
            return $returnList
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
    if {$mode == "create"} {
        set rinterface_handles ""
        foreach {_handle} $handle {
            if {[regexp {router:\d*$} $_handle]} {
                append rinterface_handles  " [ixNet getList $_handle interface]"
            } elseif {[regexp {interface:\d*$} $_handle]} {
                append rinterface_handles  " $_handle"
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid element in -handle: $_handle.\
                        This parameter should be a router handle or a router\
                        interface handle."
                return $returnList
            }
        }
                
        # Set default values for parameters depending on IP version
        switch -- $ip_version {
            4 {
                if {![isIpAddressValid $remote_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When -ip_version is ${ip_version},\
                            parameter -remote_ip_addr must be an\
                            IPv${ip_version} address."
                    return $returnList
                }
                if {[info exists local_ip_addr] && ![isIpAddressValid $local_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When -ip_version is ${ip_version},\
                            parameter -local_ip_addr must be an\
                            IPv${ip_version} address."
                    return $returnList
                }
                if {![info exists remote_ip_addr_step]} {
                    set remote_ip_addr_step 0.0.0.1
                }
                if {![info exists local_ip_addr_step]} {
                    set local_ip_addr_step  0.0.0.1
                }
            }
            6 {
                if {[isIpAddressValid $remote_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When -ip_version is ${ip_version},\
                            parameter -remote_ip_addr must be an\
                            IPv${ip_version} address."
                    return $returnList
                }
                if {[info exists local_ip_addr] && [isIpAddressValid $local_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When -ip_version is ${ip_version},\
                            parameter -local_ip_addr must be an\
                            IPv${ip_version} address."
                    return $returnList
                }
                set remote_ip_addr    [::ixia::expand_ipv6_addr $remote_ip_addr]
                if {[info exists local_ip_addr]} {
                    set local_ip_addr [::ixia::expand_ipv6_addr $local_ip_addr]
                }
                
                if {![info exists remote_ip_addr_step]} {
                    set remote_ip_addr_step \
                            0000:0000:0000:0000:0000:0000:0000:0001
                } else {
                    set remote_ip_addr_step [::ixia::expand_ipv6_addr \
                            $remote_ip_addr_step]
                }
                if {![info exists local_ip_addr_step]} {
                    set local_ip_addr_step  \
                            0000:0000:0000:0000:0000:0000:0000:0001
                } else {
                    set local_ip_addr_step  [::ixia::expand_ipv6_addr \
                            $local_ip_addr_step]
                }
            }
            default {}
        }
        
        set bfd_session_list ""
        set objectCount      0
        foreach {rinterface_handle} $rinterface_handles {
            for {set sessionId 0} {$sessionId < $count} {incr sessionId} {
                # Compose list of session options
                set bfd_session_args ""
                foreach {ixnOpt hltOpt}  $bfdSessionOptionsList {
                    if {[info exists $hltOpt]} {
                        if {[info exists translate_${hltOpt}([set $hltOpt])]} {
                            lappend bfd_session_args -$ixnOpt \
                                    [set translate_${hltOpt}([set $hltOpt])]
                        } else {
                            lappend bfd_session_args -$ixnOpt [set $hltOpt]
                        }
                    }
                }
                
                # Create session
                set retCode [ixNetworkNodeAdd $rinterface_handle session \
                        $bfd_session_args]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to add BFD session.\
                            [keylget retCode log]."
                    return $returnList
                }
                set session_objref [keylget retCode node_objref]
                incr objectCount
                if {$objectCount == $objectMaxCount} {
                    debug "ixNet commit"
                    ixNet commit
                    set objectCount 0
                }
                
                lappend bfd_session_list $session_objref
                
                switch -- $ip_version {
                    4 {
                        set remote_ip_addr [::ixia::incr_ipv4_addr \
                                $remote_ip_addr $remote_ip_addr_step]
                        if {[info exists local_ip_addr]} {
                            set local_ip_addr  [::ixia::incr_ipv4_addr \
                                $local_ip_addr $local_ip_addr_step]
                        }
                    }
                    6 {
                        set remote_ip_addr [::ixia::incr_ipv6_addr \
                                $remote_ip_addr $remote_ip_addr_step]
                        if {[info exists local_ip_addr]} {
                            set local_ip_addr  [::ixia::incr_ipv6_addr \
                                    $local_ip_addr $local_ip_addr_step]
                        }
                    }
                    default {}
                }
                incr local_disc  $local_disc_step
                incr remote_disc $remote_disc_step
            }
        }
        
        if {$objectCount > 0} {
            debug "ixNet commit"
            ixNet commit
            set objectCount 0
        }
        if {$bfd_session_list != ""} {
            debug "ixNet remapIds {$bfd_session_list}"
            set bfd_session_list [ixNet remapIds $bfd_session_list]
        }
        
        keylset returnList status $::SUCCESS
        keylset returnList session_handles $bfd_session_list
        return $returnList
    }
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
        
        # Compose list of session options
        set bfd_session_args ""
        foreach {ixnOpt hltOpt}  $bfdSessionOptionsList {
            if {[info exists $hltOpt]} {
                if {[info exists translate_${hltOpt}([set $hltOpt])]} {
                    lappend bfd_session_args -$ixnOpt \
                            [set translate_${hltOpt}([set $hltOpt])]
                } else {
                    lappend bfd_session_args -$ixnOpt [set $hltOpt]
                }
            }
        }
        set objectCount 0
        foreach {sHandle} $session_handle {
            set retCode [ixNetworkNodeSetAttr $sHandle $bfd_session_args]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to modify BFD session $sHandle.\
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

proc ::ixia::ixnetwork_bfd_control {args man_args opt_args} {
    
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
            lappend protocol_objref_list $protocol_objref/protocols/bfd
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
            set retCode [ixNetworkGetProtocolObjref $_handle bfd]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set protocol_objref [keylget retCode objref]
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
            keylset returnList log "Failed to $mode BFD on the $vport_objref\
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
            debug "ixNet exec $operation $protocol_objref"
            if {[catch {ixNetworkExec [list $operation $protocol_objref]} retCode] || \
                    ([string first "::ixNet::OK" $retCode] == -1)} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $operation BFD on the\
                        $vport_objref port. Error code: $retCode."
                return $returnList
            }
        }
        after 1000
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_bfd_info { args man_args opt_args } {
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
            set protocol_objref $vport_objref/protocols/bfd
            set router_objref [ixNet getList $protocol_objref router]
            append router_handles " $router_objref"
            append port_handles [string repeat " $port" [llength $router_objref]]
        }
        if {$router_handles == "" } {
            keylset returnList status $::FAILURE
            keylset returnList log "There are no BFD router on the ports\
                    provided through -port_handle."
            return $returnList
        }
    }
    if {[info exists handle]} {
        set port_handles   ""
        set port_objrefs   ""
        foreach {_handle} $handle {
            if {![regexp {^(.*)/protocols/bfd/router:\d$} $_handle {} port_objref]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The handle $handle is not a valid\
                        BFD router handle."
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
            desMinTxInterval     desired_min_tx_interval
            myDisc               local_disc
            myIpAddress          local_ip_addr
            peerDisc             remote_disc
            peerFlags            remote_flags
            peerIpAddress        remote_ip_addr
            peerState            remote_state
            peerUpTime           remote_up_time
            protocolUsingSession protocol_using_session
            reqMinEchoInterval   req_min_echo_interval
            reqMinRxInterval     req_min_rx_interval
            sessionState         session_state
            sessionType          session_type
        }
        
        foreach {router} $router_handles {port} $port_handles {
            debug "ixNet exec refreshLearnedInfo $router"
            set retCode [ixNet exec refreshLearnedInfo $router]
            if {[string first "::ixNet::OK" $retCode] == -1 } {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to refresh learned info for\
                        BFD router $router."
                return $returnList
            }
            set retries 10
            while {[ixNet getAttribute $router -isLearnedInfoRefreshed] != "true"} {
                after 50
                incr retries -1
                if {$retries < 0} {
                    keylset returnList status $::SUCCESS
                    keylset returnList log "Refreshing learned info for\
                            BFD router $router has timed out. Please try again later."
                    
                    set session 1
                    foreach {ixnOpt hltOpt} $stats_list {
                        keylset returnList $port.$router.session.$session.$hltOpt \
                                "NA"
                    }
                    
                    return $returnList
                }
            }
            set learnedInfoList [ixNet getList $router learnedInfo]
            set session 1
            foreach {learnedInfo} $learnedInfoList {
                foreach {ixnOpt hltOpt} $stats_list {
                    keylset returnList $port.$router.session.$session.$hltOpt \
                            [ixNet getAttribute $learnedInfo -$ixnOpt]
                }
                incr session
            }
        }
        
        return $returnList
    }
    
    if {$mode == "aggregate_stats"} {
        #set port_objrefs [lsort -unique $port_objrefs]
        
        array set stats_array_aggregate {
			"Port Name"
            port_name
            "Routers Configured"
            routers_configured
            "Routers Running"
            routers_running
            "Control Tx"
            control_pkts_tx
            "Control Rx"
            control_pkts_tx
            "Echo Self Tx"
            echo_self_pkts_tx
            "Echo Self Rx"
            echo_self_pkts_rx
            "Echo DUT Loop Back"
            echo_dut_pkts_tx
            "Echo DUT Received"
            echo_dut_pkts_rx
            "Sessions Configured"
            sessions_configured
            "Sessions Auto-Created"
            sessions_auto_created
            "Configured UP-Sessions"
            sessions_configured_up
            "Auto-Created UP-Sessions"
            sessions_auto_created_up
        }
                
        set statistic_types {
            aggregate "BFD Aggregated Statistics"
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

                if {[lsearch $port_handles "$chassis_no/$card_no/$port_no"] != -1} {
                    set found true
                    set port "$chassis_no/$card_no/$port_no"
                    foreach stat [array names stats_array] {
                        if {[info exists rows_array($i,$stat)] && \
                                $rows_array($i,$stat) != ""} {
                            keylset returnList ${port}.${stat_type}.$stats_array($stat) \
                                    $rows_array($i,$stat)
                        } else {
                            keylset returnList ${port}.${stat_type}.$stats_array($stat) "N/A"
                        }
                    }
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
    }
    
    return $returnList
}
