proc ::ixia::ixnetwork_pim_config { args man_args opt_args } {
    variable objectMaxCount
    variable pimsm_handles_array
    variable ixnetwork_port_handles_array
        
    if {[catch {parse_dashed_args  -args $args -optional_args $opt_args \
            -mandatory_args $man_args} error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$error."
        return $returnList
    }
    
    if {$mode == "create"} {
        if {[lsearch $optional_args "-vlan"] != -1} {
            if {$vlan == 0} {
                catch {unset vlan_id}
            } else {
                if {![info exists vlan_id]} {
                    set vlan_id 100
                }
            }
        }
        
        if {[info exists handle]} {
            # handle is a pim router and the user wants to add interfaces to this router.
            # count must be 1 no more than one handle
            
            if {[llength $handle] > 1 ||\
                    ![regexp {^::ixNet::OBJ-/vport:\d+/protocols/pimsm/router:[0-9a-zA-Z]+$} $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid -handle '$handle'. It must be one pim router\
                        handle. On this handle new interfaces will be added"
                return $returnList
            }
        }
    }
    
    if {[info exists intf_ip_prefix_len]} {
        set intf_ip_prefix_length $intf_ip_prefix_len
    }
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }
    
    set return_interfaces_list [list]
    array set generationIdModeArray [list \
            increment       incremental\
            random          random     \
            constant        constant   \
            ]
    array set addressFamilyArray [list \
            4               ipv4 \
            6               ipv6 \
            ]
    set pimsmInterface [list \
            enabled                         enable                   bool  \
            addressFamily                   ip_version               array \
            interfaceId                     interface_handle         value \
            sendBiDirCapableOption          bidir_capable            bool  \
            helloInterval                   hello_interval           value \
            helloHoldTime                   hello_holdtime           value \
            lanPruneDelay                   prune_delay              value \
            overrideInterval                override_interval        value \
            lanPruneDelayTBit               prune_delay_tbit         bool  \
            sendGenIdOption                 send_generation_id       bool  \
            generationIdMode                generation_id_mode       array \
            upstreamNeighbor                neighbor_intf_ip_addr    addr  \
            sendHelloLanPruneDelayOption    prune_delay_enable       bool  \
            supportUnicastBootstrap         bootstrap_support_unicast bool  \
            bootstrapEnable                 bootstrap_enable         bool  \
            bootstrapHashMaskLen            bootstrap_hash_mask_len  value \
            bootstrapInterval               bootstrap_interval       value \
            bootstrapPriority               bootstrap_priority       value \
            bootstrapTimeout                bootstrap_timeout        value \
            discardLearnedRpInfo            discard_learnt_rp_info   bool  \
            ]
    set pimsmRouter [list \
            enabled                         enable                   bool    \
            drPriority                      dr_priority              value   \
            joinPruneHoldTime               join_prune_holdtime      value   \
            joinPruneInterval               join_prune_interval      value   \
            routerId                        router_id                value   \
            ]
    set listParams {
        interface_handle
        ip_version
        generation_id_mode
        hello_holdtime
        hello_interval
        prune_delay
        prune_delay_tbit
        override_interval
        bidir_capable
        send_generation_id
        prune_delay_enable
        neighbor_intf_ip_addr
        bootstrap_support_unicast
        bootstrap_enable
        bootstrap_hash_mask_len
        bootstrap_interval
        bootstrap_priority
        bootstrap_timeout
        discard_learnt_rp_info
    }
    
    if {[catch {set port_objref $ixnetwork_port_handles_array($port_handle)}]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid port_handle value."
        return $returnList
    }
    # Check if protocols are supported
    set retCode [checkProtocols $port_objref]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Port $port_handle does not support protocol\
                configuration."
        return $returnList
    }
    if {[info exists reset] && $mode == "create"} {
        foreach router_item [ixNetworkGetList $port_objref/protocols/pimsm router] {
            ixNetworkRemove $router_item
            catch {unset ::ixia::pimsm_handles_array($router_item)}
            foreach intf_item [ixNetworkGetList $router_item interface] {
                catch {unset ::ixia::pimsm_handles_array($intf_item)}
            }
        }
        if {![info exists no_write]} {
            ixNetworkCommit
        }
    }
    if { $mode == "create" || $mode == "modify" || $mode == "enable" || \
            $mode == "enable_all"} {
        set enable $::true
    } else {
        set enable $::false
    }
    # Check if the call is for modify or enable/disable
    if {$mode == "modify" || $mode == "enable" || $mode == "disable"} {
        if {![info exists handle]} {
            keylset returnList log "When -mode is $mode, parameter -handle must\
                    be specified."
            keylset returnList status $::FAILURE
            return $returnList
        } elseif {[llength $handle] > 1} {
            keylset returnList log "When -mode is $mode,\
                    -handle may only contain one value."
            keylset returnList status $::FAILURE
            return $returnList
        } else {
            set pimsm_modify_flag 1
        }
        if {![info exists count]} {
            set count 1
        }
        
        if {[regexp {:L\d+} $handle]} {
            set handle [ixNet remapIds $handle]
        }
    }
    # delete section
    if {$mode == "delete"} {
        if {![info exists handle]} {
            set handle [ixNetworkGetList $port_objref/protocols/pimsm router]
        }
        foreach pim_item $handle {
            if {![regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/pimsm/router:\[0-9a-zA-Z\]+$"\
                    $pim_item]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Specified handle \"$pim_item\" is\
                        not valid."
                return $returnList
            }
            
            if {[catch {ixNetworkRemove $pim_item}]} {
                keylset returnList status $::FAILURE
                keylset returnList log "cannot delete $pim_item."
                return $returnList
            }
            catch {unset ::ixia::pimsm_handles_array($pim_item)}
            foreach pim_intf_item [ixNetworkGetList $pim_item interface] {
                catch {unset ::ixia::pimsm_handles_array($pim_intf_item)}
            }
        }
        
        if {![info exists no_write]} {
            if {[catch {ixNetworkCommit} errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$errorMsg."
                return $returnList
            }
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {$mode == "enable_all" || $mode == "disable_all"} {
        array set mode_change {
            enable_all  enable
            disable_all disable
        }
        
        set handle [ixNetworkGetList $port_objref/protocols/pimsm router]
        set mode $mode_change($mode)
        foreach handle_item $handle {
            ixNetworkSetAttr $handle_item -enabled $enable
        }
        
        if {![info exists no_write]} {
            if {[catch {ixNetworkCommit} errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log "error when commit: $errorMsg"
                return $returnList
            }
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {($mode == "enable") || ($mode == "disable")} {
        array set modeArray {
            enable      true
            disable     false
        }        
        
        if {[catch {ixNetworkSetAttr $handle -enabled \
                $modeArray($mode)}]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Cannot $mode $handle."
            return $returnList
        }
        if {![info exists no_write]} {
            if {[catch {ixNetworkCommit} errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$errorMsg."
                return $returnList
            }
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    # Create and modify mode
    # Configure interface parameters list
    
    if {[info exists router_id] && ![isIpAddressValid $router_id]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Parameter -router_id must be ipv4."
        return $returnList
    }

    if {[info exists router_id_step] && ![isIpAddressValid $router_id_step]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Parameter -router_id_step must be ipv4."
        return $returnList
    }

    set enable true
    if {$mode == "create"} {
        if {$ip_version == "4"} {
            set param_value_list {
                intf_ip_addr                0.0.0.0  ip
                intf_ip_addr_step           0.0.1.0  ip
                intf_ip_prefix_length       24       other
                neighbor_intf_ip_addr       0.0.0.0  ip
                gateway_intf_ip_addr        0.0.0.0  ip
                gateway_intf_ip_addr_step   0.0.0.1  ip
                gre_ip_addr_step            0.0.1.0  ip
            }
        } else {
            set param_value_list {
                intf_ip_addr                0::1        ip
                intf_ip_addr_step           0:0:0:1::0  ip
                intf_ip_prefix_length       64          other
                neighbor_intf_ip_addr       0::1        ip
                gateway_intf_ip_addr        0::0        ip
                gateway_intf_ip_addr_step   0::1        ip
                gre_ip_addr_step            0::1:0      ip
            }
        }
        
        if {[info exists count] && $count != 1 && [info exists interface_handle] && [llength $interface_handle] != $count } {
            keylset returnList status $::FAILURE
            keylset returnList log "If the count != 1 and the length of interface_handle list should be <count>"
            return $returnList
        }
        set multiple_intf_flag [expr [info exists count] && $count == 1 && [info exists interface_handle]]

        foreach {param value param_type} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            } elseif {$param_type == "ip"} {
                switch $ip_version {
                    4 {
                        if {![isIpAddressValid [set $param]]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "When -ip_version is $ip_version,\
                                    parameters intf_ip_addr, intf_ip_addr_step,\
                                    neighbor_intf_ip_addr, should be of the same IP version."
                            return $returnList
                        }
                    }
                    6 {
                        if {[isIpAddressValid [set $param]]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "When -ip_version is $ip_version,\
                                    parameters intf_ip_addr, intf_ip_addr_step,\
                                    neighbor_intf_ip_addr, should be of the same IP version."
                            return $returnList
                        }
                    }
                }
            }
        }
        
        if {![info exists router_id]} {
            if {$ip_version == "4"} {
                set router_id      $intf_ip_addr
            } else {
                set router_id      0.0.0.1
            }
        }
        
        if {![info exists router_id_step]} {
            if {$ip_version == "4"} {
                set router_id_step $intf_ip_addr_step
            } else {
                set router_id_step 0.0.0.1
            }
        }

        # create interface
        if {$mvpn_enable || ([info exists gre] && $gre)} {
            if {![info exists mvpn_pe_ip]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Parameter -mvpn_pe_ip must be specified\
                        when -mvpn_enable is 1 or -gre is 1."
                return $returnList
            }
            if {![info exists default_mdt_ip]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Parameter -default_mdt_ip must be\
                        specified when -mvpn_enable is 1 or -gre is 1."
                return $returnList
            }
            if {$ip_version == 4} {
                if {![isIpAddressValid $intf_ip_addr] ||\
                        ![isIpAddressValid $intf_ip_addr_step] ||\
                        $intf_ip_prefix_length > 32} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid IP parameters."
                    return $returnList
                }
                if {![info exists default_mdt_ip_incr]} {
                    set default_mdt_ip_incr 0.0.0.1
                }
                if {![info exists mvpn_pe_ip_incr]} {
                    set mvpn_pe_ip_incr 0.0.0.1
                }
                if {![isIpAddressValid $default_mdt_ip] &&\
                        ![isIpAddressValid $default_mdt_ip_incr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Parameters -default_mdt_ip and\
                            -default_mdt_ip_incr must be valid ipv4 addresses."
                    return $returnList
                }
                if {![isIpAddressValid $mvpn_pe_ip] &&\
                        ![isIpAddressValid $mvpn_pe_ip_incr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Parameters -mvpn_pe_ip and\
                            -mvpn_pe_ip_incr must be valid ipv4 addresses."
                    return $returnList
                }
            } else {
                if {![::ipv6::isValidAddress $intf_ip_addr] ||\
                        ![::ipv6::isValidAddress $intf_ip_addr_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid IP parameters."
                    return $returnList
                }
                if {![info exists default_mdt_ip_incr]} {
                    set default_mdt_ip_incr 0::1
                }
                if {![info exists mvpn_pe_ip_incr]} {
                    set mvpn_pe_ip_incr 0::1
                }
                if {![::ipv6::isValidAddress $default_mdt_ip] &&\
                        ![::ipv6::isValidAddress $default_mdt_ip_incr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Parameters -default_mdt_ip and\
                            -default_mdt_ip_incr must be valid ipv6 addresses."
                    return $returnList
                }
                if {![::ipv6::isValidAddress $mvpn_pe_ip] &&\
                        ![::ipv6::isValidAddress $mvpn_pe_ip_incr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Parameters -mvpn_pe_ip and\
                            -mvpn_pe_ip_incr must be valid ipv6 addresses."
                    return $returnList
                }
            }
            if {![info exists mvrf_count]} {
                set mvrf_count 1
            }
            # create interface
            set gre_key_in_step  0
            set gre_key_out_step 0
            set unconnected_ipv4_mask 32
            set unconnected_ipv6_mask 128
            set gre_connected_via routed
            set intf_config_options {
                    -port_handle              port_handle
                    -count                    count
                    -mac_address              mac_address_init
                    -mac_address_step         mac_address_step
                    -vlan_enabled             vlan
                    -vlan_id                  vlan_id
                    -vlan_id_mode             vlan_id_mode
                    -vlan_id_step             vlan_id_step
                    -vlan_user_priority       vlan_user_priority
                    -gre_dst_ip_address       default_mdt_ip
                    -gre_dst_ip_address_step  default_mdt_ip_incr
                    -loopback_count           mvpn_pe_count
                    -gre_count                mvrf_count
                    -gre_checksum_enable      gre_checksum_enable
                    -gre_seq_enable           gre_seq_enable
                    -gre_key_enable           gre_key_enable
                    -gre_key_in               gre_key_in
                    -gre_key_in_step          gre_key_in_step
                    -gre_key_out              gre_key_out
                    -gre_key_out_step         gre_key_out_step
                    -gre_src_ip_address       gre_connected_via
            }

            if {$ip_version == 4} {
                append intf_config_options {
                    -ipv4_address                   intf_ip_addr
                    -ipv4_address_step              intf_ip_addr_step
                    -ipv4_prefix_length             intf_ip_prefix_length
                    -gateway_address                gateway_intf_ip_addr
                    -gateway_address_step           gateway_intf_ip_addr_step
                    -loopback_ipv4_address          mvpn_pe_ip
                    -gre_ipv4_address               mvpn_pe_ip
                    -gre_ipv4_prefix_length         unconnected_ipv4_mask
                    -loopback_ipv4_prefix_length    unconnected_ipv4_mask
                    -loopback_ipv4_address_step     mvpn_pe_ip_incr
                }
            } elseif {[::ipv6::isValidAddress $intf_ip_addr] && \
                    [::ipv6::isValidAddress $intf_ip_addr_step]} {
                append intf_config_options {
                        -ipv6_address                   intf_ip_addr
                        -ipv6_address_step              intf_ip_addr_step
                        -ipv6_prefix_length             intf_ip_prefix_length
                        -loopback_ipv6_address          mvpn_pe_ip
                        -gre_ipv6_address               mvpn_pe_ip
                        -gre_ipv6_prefix_length         unconnected_ipv6_mask
                        -loopback_ipv6_prefix_length    unconnected_ipv6_mask
                        -loopback_ipv6_address_step     mvpn_pe_ip_incr
                }
            }
        } else {
            # create interface
            set gre_key_in_step  0
            set gre_key_out_step 0
            set unconnected_ipv4_mask 32
            set unconnected_ipv6_mask 128
            
            if {![info exists gre_enable] || $gre_enable == 0} {
                set gre_count 0
            }
            
            set intf_config_options {
                    -port_handle              port_handle
                    -count                    count
                    -mac_address              mac_address_init
                    -mac_address_step         mac_address_step
                    -vlan_enabled             vlan
                    -vlan_id                  vlan_id
                    -vlan_id_mode             vlan_id_mode
                    -vlan_id_step             vlan_id_step
                    -vlan_user_priority       vlan_user_priority
                    -gre_dst_ip_address       gre_dst_ip_addr
                    -gre_dst_ip_address_step  gre_dst_ip_addr_step
                    -gre_dst_ip_address_outside_connected_step gre_dst_ip_addr_cstep
                    -gre_dst_ip_address_outside_loopback_step  gre_dst_ip_addr_lstep
                    -loopback_count           loopback_count
                    -gre_count                gre_count
                    -gre_checksum_enable      gre_checksum_enable
                    -gre_seq_enable           gre_seq_enable
                    -gre_key_enable           gre_key_enable
                    -gre_key_in               gre_key_in
                    -gre_key_in_step          gre_key_in_step
                    -gre_key_out              gre_key_out
                    -gre_key_out_step         gre_key_out_step
                    -gre_src_ip_address       gre_src_ip_addr_mode
            }
            
            if {$ip_version == 4} {
                
                append intf_config_options {
                    -ipv4_address                   intf_ip_addr
                    -ipv4_address_step              intf_ip_addr_step
                    -ipv4_prefix_length             intf_ip_prefix_length
                    -gateway_address                gateway_intf_ip_addr
                    -gateway_address_step           gateway_intf_ip_addr_step
                    -loopback_ipv4_address          loopback_ip_address
                    -loopback_ipv4_prefix_length    unconnected_ipv4_mask
                    -loopback_ipv4_address_step     loopback_ip_address_step
                    -loopback_ipv4_address_outside_step loopback_ip_address_cstep
                    -gre_ipv4_address               gre_ip_addr
                    -gre_ipv4_address_step          gre_ip_addr_step
                    -gre_ipv4_address_outside_connected_step gre_ip_addr_cstep
                    -gre_ipv4_address_outside_loopback_step  gre_ip_addr_lstep
                    -gre_ipv4_prefix_length         gre_ip_prefix_length
                }
            } elseif {[::ipv6::isValidAddress $intf_ip_addr] && \
                    [::ipv6::isValidAddress $intf_ip_addr_step]} {
                
                append intf_config_options {
                    -ipv6_address                   intf_ip_addr
                    -ipv6_address_step              intf_ip_addr_step
                    -ipv6_prefix_length             intf_ip_prefix_length
                    -ipv6_gateway                   gateway_intf_ip_addr
                    -ipv6_gateway_step              gateway_intf_ip_addr_step
                    -loopback_ipv6_address          loopback_ip_address
                    -loopback_ipv6_prefix_length    unconnected_ipv6_mask
                    -loopback_ipv6_address_step     loopback_ip_address_step
                    -loopback_ipv6_address_outside_step loopback_ip_address_cstep
                    -gre_ipv6_address               gre_ip_addr
                    -gre_ipv6_address_step          gre_ip_addr_step
                    -gre_ipv6_address_outside_connected_step gre_ip_addr_cstep
                    -gre_ipv6_address_outside_loopback_step  gre_ip_addr_lstep
                    -gre_ipv6_prefix_length         gre_ip_prefix_length
                }
            }
        }
        
        foreach {ixn hlt} $intf_config_options {
            if {[info exists $hlt]} {
                append intf_params " $ixn [set $hlt]"
            }
        }
        
        if {[info exists interface_handle] && !$mvpn_enable} {
            set con_intf_list ""
            set gre_intf_list ""
            set rout_intf_list ""
            foreach item $interface_handle {
                if {[catch {ixNetworkGetAttr $item -type} errMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid interface handle $item.\
                            $errMsg."
                    return $returnList
                }
                
                switch -- $errMsg {
                    "default" {
                        lappend con_intf_list $item
                    }
                    "gre" {
                        lappend gre_intf_list $item
                    }
                    "routed" {
                        lappend rout_intf_list $item
                    }
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unexpected interface type $errMsg."
                        return $returnList 
                    }
                }
            }
            
            keylset intf_status connected_interfaces $con_intf_list
            
            keylset intf_status gre_interfaces $gre_intf_list
            
            keylset intf_status routed_interfaces $rout_intf_list
            
        } elseif {[info exists intf_params]} {
            set intf_cmnd "::ixia::ixNetworkProtocolIntfCfg $intf_params "
            if {$mvpn_enable == 1 || ([info exists gre] && $gre)} {
                if {$ip_version == 4} {
                    append intf_cmnd "\
                            -gre_ipv4_address_step                     0.0.0.0 \
                            -gre_ipv4_address_outside_connected_step   0.0.0.0 \
                            -gre_dst_ip_address_outside_connected_step 0.0.0.0 \
                            -gre_dst_ip_address_outside_loopback_step  0.0.0.0 \
                            -gre_ipv4_address_outside_connected_reset  0       \
                            -gre_ipv4_address_outside_loopback_step    $mvpn_pe_ip_incr\
                            "
                } else {
                    append intf_cmnd "\
                            -gre_ipv6_address_step                     0::0     \
                            -gre_ipv6_address_outside_connected_step   0::0     \
                            -gre_dst_ip_address_outside_connected_step 0::0     \
                            -gre_dst_ip_address_outside_loopback_step  0::0     \
                            -gre_ipv6_address_outside_connected_reset  0        \
                            -gre_ipv6_address_outside_loopback_step    $mvpn_pe_ip_incr\
                            "
                }
                if {$mvrf_unique == 1} {
                    append intf_cmnd " -gre_dst_ip_address_reset 0 "
                }
            }

            set retCode [catch {set intf_status [eval $intf_cmnd]} errorMsg]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "$errorMsg."
                return $returnList
            }
            if {[keylget intf_status status] == $::FAILURE} {
                return $intf_status
            }
            
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Interface parameters missing in create mode."
            return $returnList
        }
    } else {
        # modify interface
        set connected_intf_list {
            -mac_address              mac_address_init
            -vlan_enabled             vlan
            -vlan_id                  vlan_id
            -vlan_user_priority       vlan_user_priority
            -prot_intf_objref         interface_handle
        }
        set routed_interface_list {
            -prot_intf_objref         interface_handle
        }
        set gre_interface_list {
            -gre_checksum_enable      gre_checksum_enable
            -gre_dst_ip_address       gre_dst_ip_address
            -gre_key_enable           gre_key_enable
            -gre_key_in               gre_key_in
            -gre_key_out              gre_key_out
            -gre_seq_enable           gre_seq_enable
            -gre_key_enable           gre_key_enable
            -prot_intf_objref         prot_intf_objref
        }
        foreach handle_item $handle {
            if {![regexp -- "::ixNet::OBJ-/vport:\\d+/protocols/pimsm/router:\[0-9a-zA-Z\]" $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "invalid handle specified."
                return $returnList
            }
            
            catch {set pim_intf_list [ixNetworkGetList $handle interface]}
            if {![info exists pim_intf_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to retrive interface list for\
                        specified handle."
                return $returnList
            }
            
            set intf_cmnd [list]
            foreach pim_intf $pim_intf_list {
                set intf_config_list [list]
                set intf_obj [ixNetworkGetAttr $pim_intf -interfaceId]
                set ipv4_intf_list [ixNetworkGetList $intf_obj ipv4]
                set ipv6_intf_list [ixNetworkGetList $intf_obj ipv6]
                if {$ipv4_intf_list != ""} {
                    set intf_type "ipv4"
                } elseif {$ipv6_intf_list != ""} {
                    set intf_type "ipv6"
                }
                if {![info exists intf_type]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "interface assigned to specified PIM \
                            emulated route do not have IPv4 or IPv6."
                    return $returnList
                }
                
                switch -- [ixNetworkGetAttr $intf_obj -type] {
                    default {
                        append intf_cmnd "::ixia::ixNetworkConnectedIntfCfg"
                        set intf_config_list $connected_intf_list
                        if {$intf_type == "ipv4"} {
                            append intf_config_list {
                                -ipv4_address              intf_ip_addr
                                -ipv4_prefix_length        intf_ip_prefix_length
                                -gateway_ip_address        gateway_intf_ip_addr
                            }
                        } else {
                            append intf_config_list {
                                -ipv6_address           intf_ip_addr
                                -ipv6_prefix_length     intf_ip_prefix_length
                            }
                        }
                    }
                    gre {
                        append intf_cmnd "::ixia::ixNetworkGreIntfCfg"
                        set intf_config_list $gre_interface_list
                    }
                    routed {
                        append intf_cmnd "::ixia::ixNetworkUnconnectedIntfCfg"
                        set intf_config_list $routed_interface_list
                        if {$intf_type == "ipv4"} {
                            append intf_config_list {
                                -loopback_ipv4_address      mvpn_pe_ip
                            } else {
                                -loopback_ipv6_address      mvpn_pe_ip
                            }
                        }
                    }
                }
                if {$intf_config_list != ""} {
                    if {$intf_type == "ipv4"} {
                        append intf_cmnd " -port_handle $port_handle\
                                -prot_intf_objref $intf_obj"
                    } else {
                        append intf_cmnd " -port_handle $port_handle\
                                -prot_intf_objref $intf_obj"
                    }
                    foreach {ixn hlt} $intf_config_list {
                        if {[info exists $hlt]} {
                            append intf_cmnd " $ixn [set $hlt]"
                        }
                    }
                    append intf_cmnd ";"
                }
            }
            if {[info exists intf_cmnd] && $intf_cmnd != ""} {
                if {[catch {set intf_status [eval $intf_cmnd]} errorMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$errorMsg."
                    return $returnList
                }
            }
            if {[keylget intf_status status] == $::FAILURE} {
                return $intf_status
            }           
        }
        if {![info exists no_write]} {
            ixNetworkCommit
        }
    }
    # End of modify interfaces

    # create router handles
    if {$mode == "create"} {
         if {[info exists mvpn_enable] && $mvpn_enable == 1} {
            
            # getting interface handles and setting counters for them
            set default_intf_count 0
            set routed_intf_count  0
            set gre_intf_count     0
            set pim_intf_default   [keylget intf_status connected_interfaces]
            set pim_intf_routed    [keylget intf_status routed_interfaces]
            set pim_intf_gre       [keylget intf_status gre_interfaces]
        } else {
            if {$multiple_intf_flag} {
                set pim_intf_default $interface_handle
            } else {
                set default_intf_count 0
                set routed_intf_count  0
                set gre_intf_count     0
                set pim_intf_default   [keylget intf_status connected_interfaces]
                set pim_intf_routed    [keylget intf_status routed_interfaces]
                set pim_intf_gre       [keylget intf_status gre_interfaces]
            }
            set create_single_index 0
            set single_list 1
        }
    }
    set objectsToCommit 0
    if {$mode == "create"} {
        ixNetworkSetAttr $port_objref/protocols/pimsm -enabled true
        if {![info exists no_write]} {
            ixNetworkCommit
        }
        
        set handle_list [list]
        if {![info exists handle]} {
            for {set i 0} {$i < $count} {incr i} {
                if {[info exists mvpn_enable] && $mvpn_enable == 1} {
                    lappend handle_list [ixNetworkAdd $port_objref/protocols/pimsm router]
                    
                    if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                        ixNetworkCommit
                        set objectsToCommit 0
                    } else {
                        incr objectsToCommit
                    }
                    set unconn_router_list [list]
                    for {set j 0} {$j < $mvpn_pe_count} {incr j} {
                        lappend unconn_router_list \
                                [ixNetworkAdd $port_objref/protocols/pimsm router]
                        
                        if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                            ixNetworkCommit
                            set objectsToCommit 0
                        } else {
                            incr objectsToCommit
                        }
                    }
                    lappend handle_list $unconn_router_list
                } else {
                    lappend handle_list [ixNetworkAdd $port_objref/protocols/pimsm router]
                        
                    if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                        ixNetworkCommit
                        set objectsToCommit 0
                    } else {
                        incr objectsToCommit
                    }
                    lappend handle_list [list]
                }
            }
            if {$objectsToCommit > 0 && ![info exists no_write]} {
                ixNetworkCommit
                set objectsToCommit 0
            }
        } else {
            lappend handle_list $handle {}
        }
        
        set handle [list]
        if {![info exists no_write]} {
            foreach {con_h uncon_h_list} $handle_list {
                lappend handle [ixNet remapIds $con_h]
                if {[llength $uncon_h_list] > 0} {
                    lappend handle [ixNet remapIds $uncon_h_list]
                } else {
                    lappend handle $uncon_h_list
                }
            }
        } else {
            set handle $handle_list
        }
        
        keylset returnList handle [join $handle]
    }
    if {$mode == "modify"} {
        set mvpn_enable [keylget ::ixia::pimsm_handles_array($handle) mvpn_enable]
        
        keylset returnList handle $handle
    }
    # configure routers parameters
    set nodeId 0 ;# This is the router  actually. It is used to know what are the protocol
                  # interfaces that will be associated with the router 
    set intf_config_command [list]
    foreach {router_item router_uncon} $handle {
        foreach router_handle [concat $router_item $router_uncon] {
            foreach router_objref $router_handle {
                if {[info exists mvrf_unique]} {
                    keylset ::ixia::pimsm_handles_array($router_objref) \
                            mvrf_unique $mvrf_unique
                }
                if {[info exists mvpn_enable] && $mode == "create"} {
                    keylset ::ixia::pimsm_handles_array($router_objref) \
                            mvpn_enable $mvpn_enable
                }                
                foreach {ixn hlt type} $pimsmRouter {
                    if {[info exists $hlt]} {
                        ixNetworkSetAttr $router_objref -$ixn [set $hlt]
                    }
                }
            }
        }
        if {$mvpn_enable == 1 && $mode == "create"} {
            set intf_default [lindex $pim_intf_default $default_intf_count]
            set intf_default [ixNetworkAdd $router_item interface -interfaceId $intf_default]
            lappend return_interfaces_list $intf_default
            keylset ::ixia::pimsm_handles_array($intf_default) default_mdt_ip 0.0.0.0
            
            if {![info exists router_id_step]} {
                if {[info exists mvpn_pe_ip_incr] && [isIpAddressValid $mvpn_pe_ip_incr]} {
                    set router_id_step $mvpn_pe_ip_incr
                } else {
                    set router_id_step 0.0.0.1
                }
            }
            
            if {[info exists router_id]} {
                ixNetworkSetAttr $router_item -routerId $router_id
                set router_id [::ixia::increment_ipv4_address_hltapi\
                            $router_id $router_id_step]
            }
            
            if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                ixNetworkCommit
                set objectsToCommit 0
            } else {
                incr objectsToCommit
            }
            
            incr default_intf_count
            set intf_routed_gre_list [list]
            
            foreach router_it $router_uncon {
                set intf_routed [lindex $pim_intf_routed $routed_intf_count]
                set default_mdt_ip_list ""
                if {![info exists router_id]} {
                    ixNetworkSetAttr $router_it -routerId \
                            [ixNetworkGetAttr $intf_routed/ipv4 -ip]
                } else {
                    ixNetworkSetAttr $router_it -routerId $router_id
                }
                set default_mdt_ip_start $default_mdt_ip
                
                for {set i 0} {$i < $mvrf_count} {incr i} {
                    set intf_gre [lindex $pim_intf_gre $gre_intf_count]
                    set intf_gre [ixNetworkAdd $router_it interface -interfaceId $intf_gre]
                    lappend return_interfaces_list $intf_gre
                    lappend intf_routed_gre_list $intf_gre
                    keylset ::ixia::pimsm_handles_array($intf_gre) default_mdt_ip $default_mdt_ip
                    lappend default_mdt_ip_list $default_mdt_ip
                    if {[isIpAddressValid $default_mdt_ip]} {
                        set default_mdt_ip [::ixia::increment_ipv4_address_hltapi \
                                $default_mdt_ip $default_mdt_ip_incr]
                    } else  {
                        set default_mdt_ip [::ixia::increment_ipv6_address_hltapi \
                                $default_mdt_ip $default_mdt_ip_incr]
                    }
                    
                    if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                        ixNetworkCommit
                        set objectsToCommit 0
                    } else {
                        incr objectsToCommit
                    }
                    
                    incr gre_intf_count
                }
                if {$pim_mode == "sm"} {
                    set intf_routed [lindex $pim_intf_routed $routed_intf_count]
                    set intf_routed [ixNetworkAdd $router_it interface -interfaceId $intf_routed]
                    lappend return_interfaces_list $intf_routed
                    lappend intf_routed_gre_list $intf_routed
                    keylset ::ixia::pimsm_handles_array($intf_routed) default_mdt_ip $default_mdt_ip_list
                    
                    if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                        ixNetworkCommit
                        set objectsToCommit 0
                    } else {
                        incr objectsToCommit
                    }
                    incr routed_intf_count
                }
                if {[info exists router_id]} {
                    set router_id [::ixia::increment_ipv4_address_hltapi\
                            $router_id $router_id_step]
                }
                if {$mvrf_unique == 0} {
                    set default_mdt_ip $default_mdt_ip_start
                }
            }
            set modify_intf_list [join "$intf_default $intf_routed_gre_list"]
        } elseif {$mode == "create"} {
            if {![info exists router_id]} {
                if {[isIpAddressValid $intf_ip_addr]} {
                    ixNetworkSetAttr $router_item -routerId $intf_ip_addr
                } else {
                    ixNetworkSetAttr $router_item -routerId 0.0.0.1
                }
            }
            
            if {[info exists router_id]} {
                set router_id [::ixia::increment_ipv4_address_hltapi\
                        $router_id $router_id_step]
            }
            
            keylset ::ixia::pimsm_handles_array($router_item) mvpn_enable 0
            set modify_intf_list {}
            if {$multiple_intf_flag} {
                # create multiple interfaces on router.
                foreach intf $pim_intf_default {
                    set intf_default [ixNetworkAdd $router_item interface -interfaceId\
                        $intf]
                    lappend return_interfaces_list $intf_default
                    if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                        ixNetworkCommit
                        set objectsToCommit 0
                    } else {
                        incr objectsToCommit
                    }
                    lappend modify_intf_list $intf_default
                }
            } else {
                
                if {[info exists gre] && $gre} {
                    # This is done to make sure we are compatible with a workaround implemented
                    # at the customer site. This takes the first gre interface created on the first
                    # loopback interface from the connected protocol interfaces
                    # The gre interfaces were created with the mvpn parameters
                    
                    # Doing this because i want to determine the index of the first gre interface
                    # from the first loopback interface from this connected interface :)
                    set gre_intf_idx    [expr $nodeId * $mvpn_pe_count * $mvrf_count]
                    set intfDesc        [lindex $pim_intf_gre $gre_intf_idx]
                    set intf_per_router 1
                    
                } else {
                
                    # Before this change we could only create pim behind connected interfaces (on non-mvpn)
                    # Now we can create them behind routed and gre too
                    # Creating the list of protocol interfaces for this router
                    
                    if {[info exists gre_enable] && $gre_enable && $gre_count > 0} {
                        # Use GRE protocol interfaces as pim interfaces
                        
                        if {[info exists gre_src_ip_addr_mode] && $gre_src_ip_addr_mode == "routed"} {
                            # gre type is routed
                            
                            set intfDesc $pim_intf_gre
                            set intf_per_router [expr $loopback_count * $gre_count]
                            
                        } else {
                            # gre type is connected
                            set intfDesc $pim_intf_gre
                            set intf_per_router $gre_count
                        }
                        
                    } elseif {[info exists loopback_count] && $loopback_count > 0} {
                        # Use UNCONNECTED protocol interfaces as pim interfaces
                        set intfDesc $pim_intf_routed
                        set intf_per_router $loopback_count
                        
                    } else {
                        set intfDesc $pim_intf_default
                        set intf_per_router 1
                    }
                    
                    for {set intf_idx 0} {$intf_idx < $intf_per_router} {incr intf_idx} {
                        set intf_default [lindex $intfDesc $create_single_index]
                        
                        set result [ixNetworkNodeAdd $router_item interface \
                                [list -interfaceId $intf_default -enabled true]]
                        if {[keylget result status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Could not add interface '$intf_default' to\
                                    $router_item. [keylget result log]"
                            return $returnList
                        }
                        set intf_default [keylget result node_objref]
                                                
                        lappend return_interfaces_list $intf_default

                        if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                            ixNetworkCommit
                            set objectsToCommit 0
                        } else {
                            incr objectsToCommit
                        }
                        lappend modify_intf_list $intf_default
                        
                        incr create_single_index
                    }
                }
            }
        } else {
            set modify_intf_list [ixNetworkGetList $router_item interface]
        }
        
        if {$objectsToCommit > 0 && ![info exists no_write]} {
            ixNetworkCommit
            set objectsToCommit 0
        }
        
        set intf_ix 0
        foreach modify_item $modify_intf_list {
            set remapped_modify_item [ixNet remapIds $modify_item]
            if {[info exists ::ixia::pimsm_handles_array($modify_item)]} {
                set ::ixia::pimsm_handles_array($remapped_modify_item) \
                        $::ixia::pimsm_handles_array($modify_item)
                unset ::ixia::pimsm_handles_array($modify_item)
            }
            foreach {ixn hlt type} $pimsmInterface {
                if {[info exists $hlt]} {
                    switch -- $type {
                        array {
                            if {[info exists multiple_intf_flag] && $multiple_intf_flag && [lsearch $listParams $hlt] != -1} {
                                if {$intf_ix < [llength [set $hlt]]} {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                        $remapped_modify_item -$ixn [set [subst\
                                        $ixn]Array([lindex [set $hlt] $intf_ix])]"
                                } else {    
                                    lappend intf_config_command "ixNetworkSetAttr\
                                        $remapped_modify_item -$ixn [set [subst\
                                        $ixn]Array([lindex [set $hlt] end])]"
                                }
                            } else {
                                lappend intf_config_command "ixNetworkSetAttr\
                                        $remapped_modify_item -$ixn [set [subst\
                                        $ixn]Array([set $hlt])]"
                            }
                        }
                        bool {
                            if {[llength [set $hlt]] > 1} {
                                set bool_value ""
                                foreach value [set $hlt] {
                                    if {$value == 0} {
                                        lappend bool_value false
                                    } else {
                                        lappend bool_value true
                                    }
                                }
                            } else {
                                if {[set $hlt] == 0} {
                                    set bool_value false
                                } else {
                                    set bool_value true
                                }
                            }
                            if {[info exists multiple_intf_flag] && $multiple_intf_flag && [lsearch $listParams $hlt] != -1} {
                                if {$intf_ix < [llength [set $hlt]]} {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                        $remapped_modify_item -$ixn [lindex $bool_value $intf_ix]"
                                } else {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                        $remapped_modify_item -$ixn [lindex $bool_value end]"
                                }
                            } else {
                                if {[llength [set $hlt]] > 1} {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                            $remapped_modify_item -$ixn \"$bool_value\""
                                } else {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                            $remapped_modify_item -$ixn $bool_value"
                                }
                            }
                        }
                        addr {
                            if {[info exists multiple_intf_flag] && $multiple_intf_flag && [lsearch $listParams $hlt] != -1} {
                                if {$intf_ix < [llength [set $hlt]]} {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                        $remapped_modify_item -$ixn [lindex [set $hlt] $intf_ix]"
                                } else {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                        $remapped_modify_item -$ixn [lindex [set $hlt] end]"
                                }
                            } else {
                                if {[info exists neighbor_intf_ip_addr_step] && [llength [set $hlt]]==1 \
                                        && ($intf_ix > 0 || $nodeId > 0)} {
                                    set $hlt [::ixia::increment_ipv4_address_hltapi \
                                            [set $hlt] $neighbor_intf_ip_addr_step]
                                }
                                set hlt_value [set $hlt]
                                if {[llength [set $hlt]] > 1} {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                            $remapped_modify_item -$ixn \"$hlt_value\""
                                } else {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                            $remapped_modify_item -$ixn $hlt_value"
                                }
                            }
                        }
                        default {
                            if {[info exists multiple_intf_flag] && $multiple_intf_flag && [lsearch $listParams $hlt] != -1} {
                                if {$intf_ix < [llength [set $hlt]]} {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                        $remapped_modify_item -$ixn [lindex [set $hlt] $intf_ix]"
                                } else {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                        $remapped_modify_item -$ixn [lindex [set $hlt] end]"
                                }
                            } else {
                                if {[llength [set $hlt]] > 1} {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                            $remapped_modify_item -$ixn \"[set $hlt]\""
                                } else {
                                    lappend intf_config_command "ixNetworkSetAttr\
                                            $remapped_modify_item -$ixn [set $hlt]"
                                }
                            }
                        }
                    }
                }
            }
            incr intf_ix
        }
        
        incr nodeId
    }
    if {$return_interfaces_list != ""} {
        keylset returnList interfaces [ixNet remapIds $return_interfaces_list]
    }
    foreach intf_command $intf_config_command {
        if {[catch {eval $intf_command} errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log "$errorMsg."
            return $returnList
        }
    }
    
    if {![info exists no_write]} {
        ixNetworkCommit
    }
        
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_pim_group_config { args opt_args } {
    variable ::ixia::objectMaxCount
    variable multicast_group_array
    variable multicast_source_array
    variable pimsm_handles_array
    
    set procName [lindex [info level [info level]] 0]
    
    ::ixia::utrackerLog $procName $args
    
    if {[catch {parse_dashed_args  -args $args -optional_args $opt_args}\
            errorMsg]} {
         keylset returnList status $::FAILURE
         keylset returnList log "$errorMsg."
         return $returnList        
    }
    
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }
    if { $mode == "create" || $mode == "modify" } {
        set enable $::true
    } else {
        set enable $::false
    }
    array set groupMappingModeArray {
            fully_meshed            fullyMeshed
            one_to_one              oneToOne
    }
    
    array set meshingTypeArray {
            fully_meshed            fullyMeshed
            one_to_one              oneToOne
    }
    
    array set priorityTypeArray {
        incremental incremental
        random      random
        same        same
    }
    
    set pimsmServer [list \
        enableRateControl               rate_control                \
        interval                        interval                    \
        registerMessagesPerInterval     register_per_interval       \
        joinPruneMessagesPerInterval    join_prune_per_interval     \
        registerStopMessagesPerInterval register_stop_per_interval  \
    ]
    set pimsmSource {   
        enabled                      enable                         bool
        groupAddress                 group_ip_addr_start            value
        groupCount                   num_groups                     value
        rpAddress                    rp_ip_addr                     value
        sourceAddress                source_ip_addr_start           value
        sourceCount                  num_sources                    value
        groupMappingMode             source_group_mapping           array
        txIterationGap               register_tx_iteration_gap      value
        udpDstPort                   register_udp_destination_port  value
        udpSrcPort                   register_udp_source_port       value
        sendNullRegAtBegin           send_null_register             value
    }
    
    set pimsmJoinPrune {
        enabled                 enable                         bool
        packGroupsEnabled       local_enable_packing           bool
        flapInterval            flap_interval                  value
        flapEnabled             enable_flap                    bool
        groupAddress            group_ip_addr_start            value
        groupCount              num_groups                     value
        groupMaskWidth          group_ip_prefix_len            value
        pruneSourceAddress      source_ip_addr_start           value
        pruneSourceCount        num_sources                    value
        pruneSourceMaskWidth    source_ip_prefix_len           value
        groupRange              local_range_type               value
        numRegToReceivePerSg    register_stop_trigger_count    value
        rpAddress               rp_ip_addr                     value
        sourceAddress           source_ip_addr_start           value
        sourceCount             num_sources                    value
        groupMappingMode        source_group_mapping           array
        sourceMaskWidth         source_ip_prefix_len           value
        sptSwitchoverInterval   switch_over_interval           value
    }
    
    
    set pimsmCrpRange {
        advertisementHoldTime           adv_hold_time               value
        backOffInterval                 back_off_interval           value
        crpAddress                      crp_ip_addr                 value
        enabled                         enable                      bool
        groupAddress                    group_ip_addr_start         value
        groupCount                      num_groups                  value
        groupMaskLen                    group_ip_prefix_len         value
        meshingType                     source_group_mapping        array
        periodicAdvertisementInterval   periodic_adv_interval       value
        priorityChangeInterval          pri_change_interval         value
        priorityType                    pri_type                    value
        priorityValue                   pri_value                   value
        routerCount                     router_count                value
        triggeredCrpMessageCount        trigger_crp_msg_count       value
    }
    
    
    set listParams {
        group_pool_handle
        source_pool_handle 
        source_group_mapping 
        join_prune_aggregation_factor 
        wildcard_group 
        s_g_rpt_group 
        spt_switchover 
        register_stop_trigger_count
        rp_ip_addr 
        switch_over_interval 
        send_null_register 
        register_tx_iteration_gap 
        register_udp_destination_port 
        register_udp_source_port 
    }
    
    if {($mode == "create") || ($mode == "clear_all")} {
        if {![info exists session_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: If mode is $mode,\
                    -session_handle option must be present."
            return $returnList
        }
        if {[catch {set mvpn_enable [keylget pimsm_handles_array($session_handle)\
                mvpn_enable]}]} {
            set mvpn_enable 0
        }
        
        if {[catch {set mvrf_unique [keylget pimsm_handles_array($session_handle)\
                mvrf_unique]}]} {
            set mvrf_unique 0
        }
        
        if {$mode == "clear_all"} {
            if {[catch {
                set intf_list [ixNetworkGetList $session_handle interface]
                foreach intf $intf_list {
                    foreach handle [concat [ixNetworkGetList $intf source]\
                            [ixNetworkGetList $intf joinPrune] [ixNetworkGetList $intf crpRange]] {
                        ixNetworkRemove $handle
                    }
                }
            } errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$errorMsg"
                return $returnList
            }
            
            if {![info exists no_write]} {
                ixNetworkCommit
            }
            
            keylset returnList status $::SUCCESS
            return $returnList
        }
    }

    if {$mode == "modify" || $mode == "delete"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "handle must be specified in mode modify or\
                    delete."
            return $returnList
        }
        if {[regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/pimsm/router:\[0-9a-zA-Z\]+/interface:\[0-9a-zA-Z\]+/source:\[0-9a-zA-Z\]+$"\
                $handle]} {
            set handle_type source
        } else {
            if {[regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/pimsm/router:\[0-9a-zA-Z\]+/interface:\[0-9a-zA-Z\]+/joinPrune:\[0-9a-zA-Z\]+$"\
                    $handle]} {
                set handle_type joinprune
            } elseif {[regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/pimsm/router:\[0-9a-zA-Z\]+/interface:\[0-9a-zA-Z\]+/crpRange:\[0-9a-zA-Z\]+$"\
                    $handle]} {
                set handle_type crp
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "handle error specified."
                return $returnList
            }
        }
        if {$mode == "delete"} {
            ixNetworkRemove $handle
            if {![info exists no_write]} {
                ixNetworkCommit
            }
            
            keylset returnList status $::SUCCESS
            return $returnList
        } else {
            set pim_intf_list [list]
            foreach hnd_item $handle {
                if {[regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/pimsm/router:\[0-9a-zA-Z\]+/interface:\[0-9a-zA-Z\]+" $hnd_item pim_intf]} {
                    lappend pim_intf_list $pim_intf
                }
            }
        }
        foreach p $listParams {
            if {[info exists $p] && [llength [set $p]] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "If mode is modify or delete, no parameter should have a list form"
                return $returnList
            }
        }
    }
    
    if {[info exists group_pool_handle]} {
        if {![multicast_item_exists ${group_pool_handle} "group"]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Invalid\
                   group_pool_handle $group_pool_handle. The group_pool_handle\
                   must be created first with emulation_multicast_group_config"
            return $returnList
        }
        
        set group_ip_addr_start \
                $multicast_group_array([lindex $group_pool_handle 0],ip_addr_start)
        
        set group_ip_addr_pool [list]
        
        # if there are list params, step/count params will be ignored
        if {[llength $group_pool_handle] == 1} {
            set num_groups $multicast_group_array($group_pool_handle,num_groups)
            set group_ip_addr_step \
                    $multicast_group_array($group_pool_handle,ip_addr_step)
            
            set group_ip_prefix_len \
                    $multicast_group_array($group_pool_handle,ip_prefix_len)
                    
            set group_ip_addr $group_ip_addr_start
            if {[isIpAddressValid $group_ip_addr_start]} {
                for {set i 0} {$i < $num_groups} {incr i} {
                    lappend group_ip_addr_pool $group_ip_addr
                    set group_ip_addr [::ixia::increment_ipv4_net \
                            $group_ip_addr $group_ip_prefix_len]
                }
            } else  {
                for {set i 0} {$i < $num_groups} {incr i} {
                    lappend group_ip_addr_pool $group_ip_addr
                    set group_ip_addr [::ixia::ipv6_net_incr \
                            $group_ip_addr $group_ip_prefix_len]
                }
            }
        } else {
            lappend group_ip_addr_pool $group_ip_addr_start
            for {set i 1} {$i < [llength $group_pool_handle]} {incr i} {
                lappend group_ip_addr_pool $multicast_group_array([lindex $group_pool_handle $i],ip_addr_start)
            }
        }
    }
    
    if {[info exists source_pool_handle]} {
        if {$mode == "modify"} {
            set maxRanges 1
        } else {
            set maxRanges [llength $source_pool_handle]
        }
        set local_range_type "sg"
    } else {
        set maxRanges 1
        set local_range_type "g"
    }
    
    if {[info exists group_pool_handle] && [llength $group_pool_handle] > $maxRanges} {
        set maxRanges [llength $group_pool_handle]
    }
    
    if {(![info exists rp_ip_addr_step]) && [info exists rp_ip_addr]} {
        if {[isIpAddressValid $rp_ip_addr]} {
            set rp_ip_addr_step 0.0.0.0
        } else  {
            set rp_ip_addr_step 0::0
        }
    }
    if {$mode == "create"} {
        keylset returnList handle $session_handle
        regexp -- "::ixNet::OBJ-/vport:\\d+/protocols/pimsm" \
                $session_handle prot_obj
    } else {
        regexp -- "::ixNet::OBJ-/vport:\\d+/protocols/pimsm" \
                $handle prot_obj
    }
    if {![info exists prot_obj]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid session_handle value specified."
        return $returnList
    }
    foreach {ixn hlt} $pimsmServer {
        if {[info exists $hlt]} {
            ixNetworkSetAttr $prot_obj -$ixn [set $hlt]
        }
    }
    
    if {![info exists no_write]} {
        ixNetworkCommit
    }
    
    set group_handle_list [list]
    set objectsToCommit 0
    for {set i 0} {$i < $maxRanges} {incr i} {
        if {[info exists source_pool_handle]} {
            if {$i < [llength $source_pool_handle]} {
                set sourceIndex [lindex $source_pool_handle $i]
            } else {
                set sourceIndex [lindex $source_pool_handle end]
            }
            
            if {![multicast_item_exists ${sourceIndex} "source"]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid\
                        source_pool_handle $source_pool_handle. The\
                        source_pool_handle must be created first with\
                        emulation_multicast_source_config"
                return $returnList
            }
            set num_sources $multicast_source_array($sourceIndex,num_sources)
            set source_ip_addr_start \
                    $multicast_source_array($sourceIndex,ip_addr_start)
            set source_ip_prefix_len \
                    $multicast_source_array($sourceIndex,ip_prefix_len)
            set source_ip_addr_step \
                    $multicast_source_array($sourceIndex,ip_addr_step)
        }
        
        if {[info exists group_pool_handle]} {
            if {$i < [llength $group_pool_handle]} {
                set joinIndex [lindex $group_pool_handle $i]
            } else {
                set joinIndex [lindex $group_pool_handle end]
            }
            if {![multicast_item_exists ${joinIndex} "group"]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid\
                       group_pool_handle $group_pool_handle. The group_pool_handle\
                       must be created first with emulation_multicast_group_config"
                return $returnList
            }
            set num_groups $multicast_group_array($joinIndex,num_groups)
            set group_ip_addr_start \
                    $multicast_group_array($joinIndex,ip_addr_start)
            set group_ip_addr_step \
                    $multicast_group_array($joinIndex,ip_addr_step)
            set group_ip_prefix_len \
                    $multicast_group_array($joinIndex,ip_prefix_len)
        }
        
        
        if {[info exists join_prune_aggregation_factor] && \
                $i < [llength $join_prune_aggregation_factor] && \
                [lindex $join_prune_aggregation_factor $i] > 0} {
            set local_enable_packing 1
        } else {
            set local_enable_packing 0
        }
        
        if {[info exists source_pool_handle]} {
            set local_range_type "sg"
        } else {
            set local_range_type "g"
        }
        
        if {[info exists wildcard_group] && \
                $i < [llength $wildcard_group] && \
                [lindex $wildcard_group $i] && \
                (![info exists source_pool_handle])} {
            set local_range_type "rp"
        }
        
        set modeCount  0
        if {[info exists s_g_rpt_group] && \
                $i < [llength $s_g_rpt_group] && \
                [lindex $s_g_rpt_group $i] && \
                [info exists source_pool_handle]} {
            incr modeCount
            set local_range_type "g"
        }
        if {[info exists spt_switchover] && \
                $i < [llength $spt_switchover] && \
                [lindex $spt_switchover $i] && \
                [info exists source_pool_handle]} {
            incr modeCount
            set local_range_type "sptSwitchOver"
        }
        if {[info exists register_triggered_sg] && \
                $register_triggered_sg && \
                [info exists source_pool_handle]} {
            incr modeCount
            set local_range_type "registerTriggeredSg"
        }
        
        if {$modeCount > 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: only one of the following\
                    options can be enabled:  s_g_rpt_group, spt_switchover,\
                    and register_triggered_sg"
            return $returnList
        }
        
        if {$mode == "create"} {
            if {[regexp "::ixNet::OBJ-/vport:\\d+/protocols/pimsm/router:\[0-9A-Za-z\]+/interface:.*\$" $session_handle]} {
                set pim_intf_list $session_handle
            } else {
                if {[catch {set pim_intf_list [ixNetworkGetList $session_handle interface]} errorMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "retrive interface failure - $errorMsg."
                    keylset returnList errorMsg "retrive interface failure - $errorMsg."
                    return $returnList
                }
            }
            regexp -- "::ixNet::OBJ-/vport:\\d+/protocols/pimsm/router:\[0-9A-Za-z\]+" $session_handle tmp_h
            keylset returnList handle $tmp_h
        }
        foreach pim_intf $pim_intf_list {
            set intf          [ixNetworkGetAttr $pim_intf -interfaceId]
            set interfaceType [ixNetworkGetAttr $intf     -type]
            set pim_intf_remapped [ixNet remapIds $pim_intf]
            if {[catch {set default_mdt_ip [keylget ::ixia::pimsm_handles_array($pim_intf_remapped) default_mdt_ip]} retCode]} {
                set default_mdt_ip "0.0.0.0"
            }
            
            if {[info exists group_pool_handle] && $default_mdt_mode != "auto"} {
                # On routed interfaces we can only add the default mdt group address
                if {($interfaceType == "routed")} {
                    set notInList 0
                    foreach pool_ip $group_ip_addr_pool {
                        if {[lsearch $default_mdt_ip $pool_ip] == -1 } {
                            incr notInList
                        }
                    }
                    if {$notInList} {
                        continue
                    }
                }
                # On gre tunnels we cannot add the default mdt group address
                if {($interfaceType == "gre")} {
                    set inList 0
                    foreach pool_ip $group_ip_addr_pool {
                        if {[lsearch $default_mdt_ip $pool_ip] != -1 } {
                            incr inList
                        }
                    }
                    if {$inList} {
                        continue
                    }
                }
            }
          
            if {$mode == "modify"} {
                if {$handle_type == "joinprune"} {
                    set group_pool_mode send
                } elseif {$handle_type == "crp"}  {
                    set group_pool_mode candidate_rp
                } else {
                    set group_pool_mode register
                }
            } else {
                if {![info exists group_pool_mode]} {
                    set group_pool_mode send
                }
                if {$group_pool_mode == "register"} {
                    set handle_type source
                } elseif {$group_pool_mode == "candidate_rp"} {
                    set handle_type crp
                } else {
                    set handle_type joinprune
                }
            }
            switch $group_pool_mode {
                "candidate_rp" {
                    if {[info exists group_pool_handle] && $mode == "create"} {
                        
                        set group_handle [ixNetworkAdd $pim_intf crpRange]
                        if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                            ixNetworkCommit
                            set objectsToCommit 0
                        } else {
                            incr objectsToCommit
                        }
                        foreach {ixn hlt type} $pimsmCrpRange {
                            if {[info exists $hlt]} {
                                if {[lsearch $listParams $hlt] != -1} {
                                    if {$i < [llength [set $hlt]]} {
                                        set value [lindex [set $hlt] $i]
                                    } else {
                                        set value [lindex [set $hlt] end]
                                    }
                                } else {
                                    set value [set $hlt]
                                }
                                if {$type == "array"} {
                                    set value [set [subst $ixn]Array($value)]
                                }
                                ixNetworkSetAttr $group_handle -$ixn $value
                            }
                        }
                        lappend group_handle_list $group_handle
                    }
                    if {$mode == "modify"} {
                        foreach group_handle $handle {
                            foreach {ixn hlt type} $pimsmCrpRange {
                                if {[info exists $hlt]} {
                                    if {$type == "array"} {
                                        set value [set [subst $ixn]Array([set $hlt])]
                                    } else {
                                        set value [set $hlt]
                                    }
                                    ixNetworkSetAttr $group_handle -$ixn $value
                                }
                            }
                        }
                        set objectsToCommit 1
                    }
                }
                "send" {
                    if {[info exists group_pool_handle] && $mode == "create"} {
                        if {[info exists flap_interval]} {
                            set enable_flap true
                        }
                        
                        set group_handle [ixNetworkAdd $pim_intf joinPrune]
                        if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                            ixNetworkCommit
                            set objectsToCommit 0
                        } else {
                            incr objectsToCommit
                        }
                        foreach {ixn hlt type} $pimsmJoinPrune {
                            if {[info exists $hlt]} {
                                if {[lsearch $listParams $hlt] != -1} {
                                    if {$i < [llength [set $hlt]]} {
                                        set value [lindex [set $hlt] $i]
                                    } else {
                                        set value [lindex [set $hlt] end]
                                    }
                                } else {
                                    set value [set $hlt]
                                }
                                if {$type == "array"} {
                                    set value [set [subst $ixn]Array($value)]
                                }
                                ixNetworkSetAttr $group_handle -$ixn $value
                            }
                        }
                        lappend group_handle_list $group_handle
                    }
                    if {$mode == "modify"} {
                        set group_handle_list [ixNetworkGetList $pim_intf joinPrune]
                        foreach group_handle $group_handle_list {
                            foreach {ixn hlt type} $pimsmJoinPrune {
                                if {[info exists $hlt]} {
                                    if {$type == "array"} {
                                        set value [set [subst $ixn]Array([set $hlt])]
                                    } else {
                                        set value [set $hlt]
                                    }
                                    ixNetworkSetAttr $group_handle -$ixn $value
                                }
                            }
                        }
                        set objectsToCommit 1
                    }
                }
                "receive" {
                }
                "register" {
                    if {[info exists source_pool_handle] && $mode == "create"} {
                        if {$objectsToCommit >= $::ixia::objectMaxCount && ![info exists no_write]} {
                            ixNetworkCommit
                            set objectsToCommit 0
                        } else {
                            incr objectsToCommit
                        }
                        set source_handle [ixNetworkAdd $pim_intf source]
                        foreach {ixn hlt type} $pimsmSource {
                            if {[info exists $hlt]} {
                                if {[lsearch $listParams $hlt] != -1} {
                                    if {$i < [llength [set $hlt]]} {
                                        set value [lindex [set $hlt] $i]
                                    } else {
                                        set value [lindex [set $hlt] end]
                                    }
                                } else {
                                    set value [set $hlt]
                                }
                                if {$type == "array"} {
                                    set value [set [subst $ixn]Array($value)]
                                }
                                ixNetworkSetAttr $source_handle -$ixn $value
                            }
                        }
                        lappend group_handle_list $source_handle
                    }
                    if {$mode == "modify"} {
                        set source_handle_list [ixNetworkGetList $pim_intf source]
                        foreach source_handle $source_handle_list {
                            foreach {ixn hlt type} $pimsmSource {
                                if {[info exists $hlt]} {
                                    if {$type == "array"} {
                                        set value [set [subst $ixn]Array([set $hlt])]
                                    } else {
                                        set value [set $hlt]
                                    }
                                    ixNetworkSetAttr $source_handle -$ixn $value
                                }
                            }
                        }
                        set objectsToCommit 1
                    }
                }
            }
            if {$mode == "create"} {
                # increments will be ignored if groups and sources handles are lists
                if {[info exists group_pool_handle] && [llength $group_pool_handle] == 1} {
                    if {[isIpAddressValid $group_ip_addr_start]} {
                        set group_ip_addr_start \
                                [::ixia::increment_ipv4_address_hltapi \
                                $group_ip_addr_start $group_ip_addr_step]
                    } else  {
                        set group_ip_addr_start \
                                [::ixia::increment_ipv6_address_hltapi \
                                $group_ip_addr_start $group_ip_addr_step]
                    }
                }
                if {[info exists source_pool_handle] && [llength $source_pool_handle] == 1} {
                    if {[isIpAddressValid $source_ip_addr_start]} {
                        set source_ip_addr_start \
                                [::ixia::increment_ipv4_address_hltapi \
                                $source_ip_addr_start $source_ip_addr_step]
                    } else  {
                        set source_ip_addr_start \
                                [::ixia::increment_ipv6_address_hltapi \
                                $source_ip_addr_start $source_ip_addr_step]
                    }
                }
            }
            if {[info exists rp_ip_addr] && [llength $rp_ip_addr] == 1} {
                if {[isIpAddressValid $rp_ip_addr]} {
                    set rp_ip_addr [::ixia::increment_ipv4_address_hltapi \
                            $rp_ip_addr $rp_ip_addr_step]
                } else  {
                    set rp_ip_addr [::ixia::increment_ipv6_address_hltapi \
                            $rp_ip_addr $rp_ip_addr_step]
                }
            }
        }
    }
    
    if {$objectsToCommit > 0 && ![info exists no_write]} {
        ixNetworkCommit
        set objectsToCommit 0
    }
    if {$group_handle_list != ""} {
        if {![info exists no_write]} {
            if {$mode == "modify"} {
                keylset returnList handle $handle
            } else {
                keylset returnList handle [ixNet remapIds $group_handle_list]
            }
        } else {
            keylset returnList handle $group_handle_list
        }
    } else {
        keylset returnList handle [list]
    }
    if {[info exists source_pool_handles]} {
        keylset returnList source_pool_handles $source_pool_handle
    }
    if {[info exists group_pool_handle]} {
        keylset returnList group_pool_handle $group_pool_handle
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_pim_control {args man_args opt_args} {
    variable ixnetwork_port_handles_array
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    if {[info exists flap]} {
        set flap_opt_list {
            flapEnabled         flap
            flapInterval        flap_interval
        }
        if {[info exists port_handle]} {
            set pim_objref_list [list]
            foreach port $port_handle {
                if {[catch {set protocol_objref $ixnetwork_port_handles_array($port)/protocols/pimsm}]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Port $port_handle has not been\
                            initialized or the handle provided is invalid."
                    return $returnList
                }
                lappend pim_objref_list $protocol_objref
            }
        } elseif {[info exists handle]} {
            set pim_objref_list $handle
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Parameters -handle or -port_handle must be provided."
            return $returnList
        }
        set pim_objref_list [lsort -unique $pim_objref_list]
        foreach pim_handle $pim_objref_list {
            switch -regexp -- $pim_handle {
                "^::ixNet::OBJ-/vport:\\d+/protocols/pimsm$" {
                    set router_list [ixNet getList $pim_handle router]
                    foreach router_item $router_list {
                        set pim_intf_list [ixNet getList $router_item interface]
                        foreach pim_intf $pim_intf_list {
                            set join_prune_list [ixNet getList $pim_intf joinPrune]
                            foreach join_prune $join_prune_list {
                                foreach {ixn hlt} $flap_opt_list {
                                    if {[info exists $hlt]} {
                                        ixNet setAttr $join_prune -$ixn [set $hlt]
                                    }
                                }
                            }
                        }
                    }
                }
                "^::ixNet::OBJ-/vport:\\d+/protocols/pimsm/router:\\d+$" {
                    set pim_intf_list [ixNet getList $pim_handle interface]
                    foreach pim_intf $pim_intf_list {
                        set join_prune_list [ixNet getList $pim_intf joinPrune]
                        foreach join_prune $join_prune_list {
                            foreach {ixn hlt} $flap_opt_list {
                                if {[info exists $hlt]} {
                                    ixNet setAttr $join_prune -$ixn [set $hlt]
                                }
                            }
                        }
                    }
                }
                "^::ixNet::OBJ-/vport:\\d+/protocols/pimsm/router:\\d+/interface:\\d+/joinPrune:\\d+$" {
                    foreach {ixn hlt} $flap_opt_list {
                        if {[info exists $hlt]} {
                            ixNet setAttr $handle -$ixn [set $hlt]
                        }
                    }
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid PIM handle ($pim_handle)\
                            provided through parameter -handle $handle."
                    return $returnList
                }
            }
        }
        ixNet commit
    }
    set returnList [::ixia::ixNetworkProtocolControl \
                "-protocol pimsm $args"  \
                "-protocol $man_args"    \
                $opt_args                ]
    
    return $returnList
}

proc ::ixia::ixnetwork_pim_info {args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args\
            $man_args -optional_args $opt_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    array set pim_stats_array {
        "Port Name"                             port_name
        "Hellos Tx"                             hello_tx
        "Hellos Rx"                             hello_rx
        "Join(X,G) Tx"                          group_join_tx
        "Join(X,G) Rx"                          group_join_rx
        "Prune(X,G) Tx"                         group_prune_tx
        "Prune(X,G) Rx"                         group_prune_rx
        "Join(S,G) Tx"                          s_g_join_tx
        "Join(S,G) Rx"                          s_g_join_rx
        "Prune(S,G) Tx"                         s_g_prune_tx
        "Prune(S,G) Rx"                         s_g_prune_rx
        "Register Tx"                           reg_tx
        "Register Rx"                           reg_rx
        "RegisterStop Tx"                       reg_stop_tx
        "RegisterStop Rx"                       reg_stop_rx
        "RegisterNull Tx"                       null_reg_tx
        "RegisterNull Rx"                       null_reg_rx
        "Rtrs. Configured"                      num_routers_configured
        "Rtrs. Running"                         num_routers_running
        "Nbrs. Learnt"                          num_neighbors_learnt
        "Join(X,X,RP) Rx"                       rp_join_rx
        "Join(X,X,RP) Tx"                       rp_join_tx
        "Prune(X,X,RP) Rx"                      rp_prune_rx
        "Prune(X,X,RP) Tx"                      rp_prune_tx
        "Join(S,G,RPT) Rx"                      s_g_rpt_join_rx
        "Join(S,G,RPT) Tx"                      s_g_rpt_join_tx
        "Prune(S,G,RPT) Rx"                     s_g_rpt_prune_rx
        "Prune(S,G,RPT) Tx"                     s_g_rpt_prune_tx
        "DataMDT TLV Rx"                        data_mdt_tlv_rx
        "DataMDT TLV Tx"                        data_mdt_tlv_tx
    }

    array set crp_info_array {
        "CRP Address"                             crp_addr
        "expiry timer"                            expiry_timer
        "Group address"                           group_addr
        "Group mask width"                        group_mask_width
        "CRP Priority"                            priority
    }
    
    array set bsr_info_array {
        "BSR Address"                             bsr_addr
        "last BSM Send/Receive"                   last_bsm_send_recv
        "BSR state"                               our_bsr_state
        "BSR Priority"                            priority
    }
    
    foreach handle_item $handle {
        if {![regexp -- "::ixNet::OBJ-/vport:\\d+" $handle_item port_objref]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid handle specified."
            return $returnList
        }
        # used to check if we get statistics for current port
        # - info exists spec_port_array(...)
        set retCode [ixNetworkGetPortFromObj $port_objref]
        set port_handle [keylget retCode port_handle]
        set spec_port_array($port_handle) 1
        if {![info exists first_port]} {
            set first_port $port_handle
        }
    }
        
    if {$mode == "aggregate"} {
        
        set returned_stats_list [ixNetworkGetStats \
                "PIMSM Aggregated Statistics" [array names pim_stats_array]]
        if {[keylget returned_stats_list status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error retrieving statistics -\
                    [keylget returned_stats_list log]"
            return $returnList
        }
        array set rows_list [keylget returned_stats_list statistics]
        set row_count [keylget returned_stats_list row_count]
            
        for {set i 1} {$i <= $row_count} {incr i} {
            set row $rows_list($i)
            set ch_ca_po_list [split $row /]
            set chassis_hostname [lindex $ch_ca_po_list 0]
            scan [lindex $ch_ca_po_list 1] "Card%d" card_no
            scan [lindex $ch_ca_po_list 2] "Port%d" port_no
            if {[catch {keylget ::ixia::hosts_to_ips $chassis_hostname}]} {
                set chassis_ip $chassis_hostname
            } else {
                set chassis_ip [keylget ::ixia::hosts_to_ips $chassis_hostname]
            }
            set chassis_no [ixNetworkGetChassisId $chassis_ip]
            set port "$chassis_no/$card_no/$port_no"
            if {[info exists spec_port_array($port)]} {
                foreach {stat_key hlt_key} [array get pim_stats_array] {
                    if [catch {
                        keylset returnList $port.aggregate.$hlt_key $rows_list($i,$stat_key)
                        if {[string equal $port $first_port]} {
                            keylset returnList $hlt_key $rows_list($i,$stat_key)
                        }
                    } errorMsg] {
                        keylset returnList $port.aggregate.$hlt_key "N/A"
                        if {[string equal $port $first_port]} {
                            keylset returnList $hlt_key $rows_list($i,$stat_key)
                        }
                    }
                }
            }
        }
    }
    
    if {$mode == "learned_crp"} {
        if {[regexp {^(.*)/protocols/pimsm/router:[a-zA-Z0-9]+$} $handle]} {
            set return_learned_info [ixNet getL $handle interface]
        } elseif {[regexp {^(.*)/protocols/pimsm/router:[a-zA-Z0-9]+/interface:[a-zA-Z0-9]+$} $handle]} {
            set return_learned_info $handle
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "The handle '$handle' is not a valid\
                    PIM-SM router handle or interface handle."
            return $returnList
        }
        set return_learned_crp [list]
        set return_learned_bsr [list]
        set learned_crp_list {
            crpAddress          crp_addr
            expiryTimer         expiry_timer
            groupAddress        group_addr
            groupMaskWidth      group_mask_width
            priority            priority
        }
        set learned_bsr_list {
            bsrAddress          bsr_addr
            lastBsmSendRecv     last_bsm_send_recv
            ourBsrState         our_bsm_state
            priority            priority
        }
        foreach interface $return_learned_info {
            set numRetries 5
            while {$numRetries && ![set refreshResult1 [regexp {^::ixNet::OK} \
                    [set refreshResult0 [ixNet exec refreshCrpBsrLearnedInfo $interface]]]]} {
                incr numRetries -1
            }
            if {!$refreshResult1} {
                keylset returnList log "[keylget returnList log].\n\
                        There is no learned information for\
                        interface $interface. The returned error was $refreshResult0."
                continue
            }
            # This delay is added because otherwise we don't receive the updated information
            after 3000
            set return_learned_crp [ixNet getL $interface learnedCrpInfo]
            set return_learned_bsr [ixNet getL $interface learnedBsrInfo]
            
            
            if {$return_learned_crp == "" && $return_learned_bsr == ""} {
                keylset returnList log "[keylget returnList log].\n\
                        There is no learned information for\
                        interface $interface."
                continue
            }
            
            set crp_index 1
            foreach {learned_crp} $return_learned_crp {
                foreach {ixnOpt hltOpt} $learned_crp_list {
                    keylset returnList learned_crp.$interface.$crp_index.$hltOpt \
                            [ixNet getAttribute $learned_crp -$ixnOpt]
                }
                incr crp_index
            }
            set bsr_index 0
            foreach {learned_bsr} $return_learned_bsr {
                foreach {ixnOpt hltOpt} $learned_bsr_list {
                    set bsrOptRes [ixNet getAttribute $learned_bsr -$ixnOpt]
                    keylset returnList learned_bsr.$interface.[expr $bsr_index + 1].$hltOpt \
                            $bsrOptRes
                }
                incr bsr_index
            }
        }
        if {[catch {keylget returnList learned_bsr}] && [catch {keylget returnList learned_crp}]} {
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
    
    keylset returnList status $::SUCCESS
    return $returnList
}
