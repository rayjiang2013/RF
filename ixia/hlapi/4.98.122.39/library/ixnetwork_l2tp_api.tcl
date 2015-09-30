proc ::ixia::ixnetwork_l2tp_config { args man_args opt_args } {
    variable truth
    set procName [lindex [info level [info level]] 0]
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    array set translate_mode [list                  \
            lac                     {lac}           \
            lns                     {lns}           \
            ]

    array set translate_auth_mode [list             \
            none                    {none}          \
            pap                     {pap}           \
            chap                    {chap}          \
            pap_or_chap             {papOrChap}     \
            ]

    array set translate_pvc_incr_mode [list         \
            vci                     0               \
            vpi                     1               \
            both                    2               \
            ]

    array set translate_sess_distribution [list     \
            next                    {nextTunnel}    \
            fill                    {fillTunnel}    \
            ]

    array set translate_tun_auth [list              \
            0                       {none}          \
            1                       {hostname}      \
            ]

    array set translate_tun_distribution [list      \
            next_tunnelfill_tunnel  {gateway}       \
            domain_group            {domain}        \
            ]

    array set translate_bearer_capability [list     \
            digital                 {1}             \
            analog                  {2}             \
            both                    {3}             \
            ]

    array set translate_bearer_type [list           \
            digital                 {1}             \
            analog                  {2}             \
            ]

    array set translate_framing_capability [list    \
            sync                    {1}             \
            async                   {2}             \
            both                    {_}             \
            ]

    array set translate_ip_cp [list                 \
            ipv4_cp                 {IPv4}          \
            ipv6_cp                 {IPv6}          \
            dual_stack              {DualStack}     \
            ]
    
    array set translate_l2tp_src_gw_incr_mode [list    \
            per_subnet              perSubnet          \
            per_interface           perInterface       \
            ]
    # Check for invalid values
    if {[info exists framing_capability] && $framing_capability == "both"} {
        keylset returnList status $::FAILURE
        keylset returnList log "The '$framing_capability' value is not a valid\
                choice for the -framing_capability attribute in IxNetwork."
        return $returnList
    }

    # Handle flags
    set flags_list [list \
            avp_hide ctrl_chksum data_chksum echo_req echo_rsp enable_magic \
            hello_req length_bit offset_bit redial sequence_bit tun_auth \
            hostname_wc secret_wc username_wc password_wc enable_magic\
            ]

    foreach {flag_elem} $flags_list {
        if {[info exists $flag_elem]} {
            set $flag_elem 1
        } else  {
            set $flag_elem 0
        }
    }

    # Check to see if a connection to the IxNetwork TCL server already exists. 
    # If it doesn't, establish it.
    set return_status [checkIxNetwork]
    if {[keylget return_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget return_status log]"
        return $returnList
    } else {
        # Add port
        set return_status [ixNetworkPortAdd $port_handle {} force]
        if {[keylget return_status status] != $::SUCCESS} {
            return $return_status
        }
    }

    # Get port objref
    set result [ixNetworkGetPortObjref $port_handle]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to find the port object reference \
                associated to the $port_handle port handle -\
                [keylget result log]."
        return $returnList
    } else {
        set port_objref [keylget result vport_objref]
        set port_type [ixNet getAttr $port_objref -type]
    }

    # Prepare arguments

    # Extract the the src_mac_addr, l2tp_src_gw and l2tp_src_prefix_len
    # attributes from the (possibly) existing interface
    set intf_list [ixNet getList $port_objref interface]
    foreach intf $intf_list {
        if {[::isIpAddressValid $l2tp_src_addr]} {
            set got_error [catch {ixNet getAttribute $intf/ipv4 -ip} addr]
            if {!$got_error} {
                if {$addr eq $l2tp_src_addr} {
                    if {![info exists src_mac_addr]} {
                        set src_mac_addr \
                                [ixNet getAttribute $intf/ethernet -macAddress]
                    }
                    if {![info exists l2tp_src_gw]} {
                        set l2tp_src_gw \
                                [ixNet getAttribute $intf/ipv4 -gateway]
                    }
                    if {![info exists l2tp_src_prefix_len]} {
                        set l2tp_src_prefix_len \
                                [ixNet getAttribute $intf/ipv4 -maskWidth]
                    }
                }
            }
        } elseif {[::ipv6::isValidAddress $l2tp_src_addr]} {
            set got_error [catch {ixNet getAttribute $intf/ipv6:1 -ip} addr]
            if {!$got_error} {
                set exp_addr [::ixia::expand_ipv6_addr $addr]
                set exp_l2tp_src_addr [::ixia::expand_ipv6_addr $l2tp_src_addr]
                if {$exp_addr eq $exp_l2tp_src_addr} {
                    if {![info exists src_mac_addr]} {
                        set src_mac_addr \
                                [ixNet getAttribute $intf/ethernet -macAddress]
                    }
                    if {![info exists l2tp_src_prefix_len]} {
                        set l2tp_src_prefix_len \
                                [ixNet getAttribute $intf/ipv6:1 -prefixLength]
                    }
                }
            }
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "'$l2tp_src_addr' is not a valid IP address."
            return $returnList
        }
    }
    
    # Get subport number
    set subport 1
    if {$port_type == "atm"} {
        set l2type_obj_exists [ixNetworkNodeGetList $port_objref/protocolStack atm]
    } elseif {[lsearch $::ixia::ixNetworkEthernetPortTypes $port_type] >= 0} {
        set l2type_obj_exists [ixNetworkNodeGetList $port_objref/protocolStack ethernet]
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "POS ports are not supported for the access\
                features."
        return $returnList
    }
    
    if {$l2type_obj_exists != [ixNet getNull] && $l2type_obj_exists != ""} {
        set ip_obj_exists [ixNetworkNodeGetList $l2type_obj_exists ip]
        if {$ip_obj_exists != [ixNet getNull] && $ip_obj_exists != ""} {
            set l2tp_obj_exists [ixNetworkNodeGetList $ip_obj_exists l2tpEndpoint]
            if {$l2tp_obj_exists != [ixNet getNull] && $l2tp_obj_exists != ""} {
                set l2tp_range_exists [ixNetworkNodeGetList $l2tp_obj_exists range -all]
                if {$l2tp_range_exists != [ixNet getNull] && $l2tp_range_exists != ""} {
                    set subport [mpexpr [llength $l2tp_range_exists] + 1]
                } else {
                    unset l2tp_range_exists
                }
            } else {
                unset l2tp_obj_exists
            }
        } else {
            unset ip_obj_exists
        }
    } else {
        unset l2type_obj_exists
    }
    
    scan $port_handle "%d/%d/%d" chassis card port

    # Last nail in the MAC coffin
    if {![info exists src_mac_addr]} {
        set src_mac_addr 00:[format %02u $chassis]:[format %02u $card]:[format \
                %02u $port]:[format %02u $subport]:01
    }

    # Check the IP version
    # Check the IP and L2TP Basic attributes
    if {![info exists l2tp_src_gw]} {
        set l2tp_src_gw $l2tp_dst_addr
    }
    if {[::isIpAddressValid $l2tp_src_addr] && \
            [::isIpAddressValid $l2tp_src_gw]} {
        set ip_version {IPv4}
        set version 4
    } elseif {[::ipv6::isValidAddress $l2tp_src_addr] && \
            [::ipv6::isValidAddress $l2tp_src_gw]} {
        set ip_version {IPv6}
        set version 6
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "The -l2tp_src_addr, -l2tp_dst_addr and\
                -l2tp_src_gw don't have the same IP version."
        return $returnList
    }

    # Check the L2TP NCP attributes

    # params ppp_client_ip, ppp_client_step, ppp_server_ip need to be all either ipv4 or ipv6
    # for dual_stack they are ipv4, and ppp_*_iid params are used for ipv6
    array set ip_cp_array [list]
    if {![info exists ppp_client_ip]} {
        if {$version == 4} {
            set ppp_client_ip 1.1.1.1
        } else {
            set ppp_client_ip 00:11:11:11:00:00:00:01
        }
    }
    
    if {[info exists ppp_client_ip]} {
        if {[::isIpAddressValid $ppp_client_ip]} {
            set ip_cp_array(ppp_client_ip) 4
        } elseif {[::ipv6::isValidAddress $ppp_client_ip]} {
            set ip_cp_array(ppp_client_ip) 6
        }
    } 
    if {![info exists ppp_client_step]} {
        if {$version == 4} {
            set ppp_client_step 0.0.0.1
        } else {
            set ppp_client_step 0:0:0:0:0:0:0:1
        }
    }
    if {[info exists ppp_client_step]} {
        if {[::isIpAddressValid $ppp_client_step]} {
            set ip_cp_array(ppp_client_step) 4
        } elseif {[::ipv6::isValidAddress $ppp_client_step]} {
            set ip_cp_array(ppp_client_step) 6
        }
    }
    
    if {![info exists ppp_server_ip]} {
        if {$version == 4} {
            set ppp_server_ip 2.2.2.2
        } else {
            set ppp_server_ip 00:11:22:11:00:00:00:01
        }
    }
    
    if {[info exists ppp_server_ip]} {
        if {[::isIpAddressValid $ppp_server_ip]} {
            set ip_cp_array(ppp_server_ip) 4
        } elseif {[::ipv6::isValidAddress $ppp_server_ip]} {
            set ip_cp_array(ppp_server_ip) 6
        }
    }
    set got_version false
    set same_version true
    foreach {key value} [array get ip_cp_array] {
        if {!$got_version} {
            set version $value
        } else {
            if {$value != $version} {
                set same_version false
                break
            }
        }
    }
    if {$same_version} {
        if {$ip_cp != "dual_stack" && [info exists version]} {
            set ip_cp ipv${version}_cp
        } elseif {$ip_cp == "dual_stack"} {
            if {$version != 4} {
                keylset returnList status $::FAILURE
                keylset returnList log "For -ip_cp dual_stack, the \
                    -ppp_client_ip, -ppp_client_step and, -ppp_server_ip must be\
                    ipv4 and -ppp_client_iid, -ppp_client_iid_step and, -ppp_server_iid ipv6"
                return $returnList
            }
        }
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "The -ppp_client_ip, -ppp_client_step and, -ppp_server_ip don't\
                have the same IP version."
        return $returnList
    }

    # Handle wildcards
    set wildcard_pound_modulo [expr $wildcard_pound_end - \
            $wildcard_pound_start + 1]
    set wildcard_question_modulo [expr $wildcard_question_end - \
            $wildcard_question_start + 1]

    if {$username_wc} {
        set startValue [format "%i" $wildcard_pound_start]
        regsub -all "\#" $username "\%$startValue:$wildcard_pound_modulo:1i" \
                username
        set startValue [format "%i" $wildcard_question_start]
        regsub -all {\?} $username "\%$startValue:$wildcard_question_modulo:1i" \
                username
    }

    if {$password_wc} {
        set startValue [format "%i" $wildcard_pound_start]
        regsub -all "\#" $password "\%$startValue:$wildcard_pound_modulo:1i" \
                password
        set startValue [format "%i" $wildcard_question_start]
        regsub -all {\?} $password "\%$startValue:$wildcard_question_modulo:1i" \
                password
    }

    set wildcard_bang_modulo [expr $wildcard_bang_end - \
            $wildcard_bang_start + 1]
    set wildcard_dollar_modulo [expr $wildcard_dollar_end - \
            $wildcard_dollar_start + 1]
    
    if {$hostname_wc} {
        set startValue [format "%i" $wildcard_bang_start]
        regsub -all "\!" $hostname "\%$startValue:$wildcard_bang_modulo:1i" \
                hostname
        set startValue [format "%i" $wildcard_dollar_start]
        regsub -all {\$} $hostname "\%$startValue:$wildcard_dollar_modulo:1i" \
                hostname
    }

    if {$secret_wc} {
        set startValue [format "%i" $wildcard_bang_start]
        regsub -all "\!" $secret "\%$startValue:$wildcard_bang_modulo:1i" \
                secret
        set startValue [format "%i" $wildcard_dollar_start]
        regsub -all {\$} $secret "\%$startValue:$wildcard_dollar_modulo:1i" \
                secret
    }

    # Configure IxNetwork 

    # Check the port type and add the L2 support to the protocol stack
    if {![info exists l2type_obj_exists]} {
        if {$port_type == "atm"} {
            set l2_result [ixNetworkNodeAdd \
                    $port_objref/protocolStack atm {} -commit]
        } elseif {[lsearch $::ixia::ixNetworkEthernetPortTypes $port_type] >= 0} {
            set l2_result [ixNetworkNodeAdd \
                    $port_objref/protocolStack ethernet {} -commit]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "POS ports are not supported for the access\
                    features."
            return $returnList
        }
    } else {
        keylset l2_result status $::SUCCESS
        keylset l2_result node_objref $l2type_obj_exists
    }

    if {[keylget l2_result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to add $port_type support to the\
                protocol stack of port $port_objref - [keylget l2_result log]."
        return $returnList
    } else {
        set l2_objref [keylget l2_result node_objref]
    }
    # Add IP support to the protocol stack
    if {![info exists ip_obj_exists]} {
        set ip_result [ixNetworkNodeAdd $l2_objref ip {} -commit]
        if {[keylget ip_result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to add IP support to the\
                    protocol stack of port $port_objref - [keylget ip_result log]."
            return $returnList
        } else {
            set ip_objref [keylget ip_result node_objref]
        }
    } else {
        set ip_objref $ip_obj_exists
    }

    if {[info exists dhcpv6_hosts_enable] && $dhcpv6_hosts_enable} {
        set l2tp_result [::ixia::ixnetwork_dhcpv6_config]
        if {[keylget l2tp_result status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to add L2TP support to the\
                    protocol stack of port $port_objref - [keylget l2tp_result log]."
            return $returnList
        } else {
            set l2tp_objref [keylget l2tp_result node_objref]
        }
    } else {
        # Add L2TP support to the protocol stack
        if {![info exists l2tp_obj_exists]} {
            set l2tp_result [ixNetworkNodeAdd $ip_objref l2tpEndpoint {} -commit]
            if {[keylget l2tp_result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to add L2TP support to the\
                        protocol stack of port $port_objref - [keylget l2tp_result log]."
                return $returnList
            } else {
                set l2tp_objref [keylget l2tp_result node_objref]
            }
        } else {
            set l2tp_objref $l2tp_obj_exists
        }
    }
    
    # Setting global parameters
    set l2tp_global_obj [ixNet getList [ixNet getRoot]/globals/protocolStack l2tpGlobals]
    if {[llength $l2tp_global_obj] > 0} {
        ixNet setAttr [lindex $l2tp_global_obj 0] -maxOutstandingReleases 10
        ixNet setAttr [lindex $l2tp_global_obj 0] -maxOutstandingRequests 1000
        ixNet setAttr [lindex $l2tp_global_obj 0] -setupRateInitial       1000
        ixNet setAttr [lindex $l2tp_global_obj 0] -teardownRateInitial    1000
    }

    # Add ranges to the protocol stack
    set ranges_result [ixNetworkNodeAdd $l2tp_objref range {} -commit]
    if {[keylget ranges_result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to add ranges to the\
                protocol stack of port $port_objref - [keylget ranges_result log]."
        return $returnList
    } else {
        set ranges_objref [keylget ranges_result node_objref]
    }

    # Configure L2TP port settings
    set port_attributes [list -role $translate_mode($mode) \
            -overrideGlobalRateControls true]
    if {[info exists attempt_rate]} {
        lappend port_attributes -setupRateInitial $attempt_rate
    }
    if {[info exists max_outstanding]} {
        if {$max_outstanding < 1 || $max_outstanding > 1000} {
            keylset returnList status $::FAILURE
            keylset returnList log "max_outstanding value out of range. \
                    It should be between 1 and 1000."
            return $returnList
        }
        lappend port_attributes -maxOutstandingRequests $max_outstanding
    }
    if {[info exists disconnect_rate]} {
        lappend port_attributes -teardownRateInitial $disconnect_rate
    }
    if {[info exists max_terminate_req]} {
        if {$max_terminate_req < 1 || $max_terminate_req > 1000} {
            keylset returnList status $::FAILURE
            keylset returnList log "max_terminate_req value out of range. \
                    It should be between 1 and 1000."
            return $returnList
        }
        lappend port_attributes -maxOutstandingReleases $max_terminate_req
    }
    
    if {[info exists enable_term_req_timeout]} {
        lappend port_attributes -useWaitForCompletionTimeout \
                $truth($enable_term_req_timeout)
    }
    if {[info exists terminate_req_timeout]} {
        lappend port_attributes -waitForCompletionTimeout $terminate_req_timeout
    }
    set role_result [ixNetworkNodeAdd $port_objref/protocolStack l2tpOptions \
            $port_attributes]
    if {[keylget role_result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to set the L2TP port attributes on the \
                protocol stack of port $port_objref - [keylget role_result log]."
        return $returnList
    }

    # Configure L2 ranges
    if {$port_type == "atm"} {
        # ATM range
        set atm_range_attributes [list]
        switch $l2_encap {
            atm_vc_mux {
                if {$ip_version == "IPv4"} {
                    lappend atm_range_attributes -encapsulation {1}
                } else {
                    lappend atm_range_attributes -encapsulation {4}
                }
            }
            atm_vc_mux_ethernet_ii {
                lappend atm_range_attributes -encapsulation {2}
            }
            atm_snap {
                lappend atm_range_attributes -encapsulation {6}
            }
            atm_snap_ethernet_ii {
                lappend atm_range_attributes -encapsulation {7}
            }
            atm_vc_mux_ppp {
                lappend atm_range_attributes -encapsulation {10}
            }
            atm_snap_ppp {
                lappend atm_range_attributes -encapsulation {9}
            }
        }
        if {[info exists src_mac_addr]} {
            regsub -all ":"   $src_mac_addr "" src_mac_addr
            regsub -all " "   $src_mac_addr "" src_mac_addr
            regsub -all "\\." $src_mac_addr "" src_mac_addr
            set src_mac_addr [join [::ixia::format_hex 0x${src_mac_addr} 48] ":"]
            lappend atm_range_attributes -mac $src_mac_addr
        }
        if {[info exists l2tp_src_count]} {
            lappend atm_range_attributes -count $l2tp_src_count
        }
        
        set retCode [ixNetworkNodeSetAttr $ranges_objref/atmRange $atm_range_attributes]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
        # PVC range
        set pvc_range_attributes [list]
        if {[info exists pvc_incr_mode]} {
            lappend pvc_range_attributes -incrementMode \
                    $translate_pvc_incr_mode($pvc_incr_mode)
        }
        if {[info exists vci]} {
            lappend pvc_range_attributes -vciFirstId $vci
        }
        if {[info exists vci_step]} {
            lappend pvc_range_attributes -vciIncrement $vci_step
        }
        if {[info exists addr_count_per_vci]} {
            lappend pvc_range_attributes -vciIncrementStep $addr_count_per_vci
        }
        if {[info exists vci_count]} {
            lappend pvc_range_attributes -vciUniqueCount $vci_count
        }
        if {[info exists vpi]} {
            lappend pvc_range_attributes -vpiFirstId $vpi
        }
        if {[info exists vpi_step]} {
            lappend pvc_range_attributes -vpiIncrement $vpi_step
        }
        if {[info exists addr_count_per_vpi]} {
            lappend pvc_range_attributes -vpiIncrementStep $addr_count_per_vpi
        }
        if {[info exists vpi_count]} {
            lappend pvc_range_attributes -vpiUniqueCount $vpi_count
        }
        
        set retCode [ixNetworkNodeSetAttr $ranges_objref/pvcRange $pvc_range_attributes]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
    } else {
        # MAC range
        set mac_range_attributes [list]
        if {[info exists src_mac_addr]} {
            regsub -all ":"   $src_mac_addr "" src_mac_addr
            regsub -all " "   $src_mac_addr "" src_mac_addr
            regsub -all "\\." $src_mac_addr "" src_mac_addr
            set src_mac_addr [join [::ixia::format_hex 0x${src_mac_addr} 48] ":"]
            lappend mac_range_attributes -mac $src_mac_addr
        }
        if {[info exists l2tp_src_count]} {
            lappend mac_range_attributes -count $l2tp_src_count
        }
        
        set retCode [ixNetworkNodeSetAttr $ranges_objref/macRange $mac_range_attributes]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
        # VLAN range
        if {$l2_encap == "ethernet_ii_vlan"} {
            set vlan_range_attributes [list -enabled true]
            if {[info exists vlan_count]} {
                lappend vlan_range_attributes -uniqueCount $vlan_count
            }
            if {[info exists vlan_id]} {
                lappend vlan_range_attributes -firstId $vlan_id
            }
            if {[info exists vlan_id_step]} {
                lappend vlan_range_attributes -increment $vlan_id_step
            }
            if {[info exists vlan_user_priority]} {
                lappend vlan_range_attributes -priority $vlan_user_priority
            }
            if {[info exists vlan_user_priority]} {
                lappend vlan_range_attributes -priority $vlan_user_priority
            }
            if {[info exists address_per_vlan]} {
                lappend vlan_range_attributes -incrementStep $address_per_vlan
            }
            
            set retCode [ixNetworkNodeSetAttr $ranges_objref/vlanRange $vlan_range_attributes]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
        
        if {$l2_encap == "ethernet_ii_qinq"} {
            set vlan_range_attributes [list -enabled true -innerEnable true]
            if {[info exists vlan_count]} {
                lappend vlan_range_attributes -uniqueCount $vlan_count
            }
            if {[info exists vlan_id]} {
                lappend vlan_range_attributes -firstId $vlan_id
            }
            if {[info exists vlan_id_step]} {
                lappend vlan_range_attributes -increment $vlan_id_step
            }
            if {[info exists vlan_user_priority]} {
                lappend vlan_range_attributes -priority $vlan_user_priority
            }
            
            if {[info exists address_per_vlan]} {
                lappend vlan_range_attributes -incrementStep $address_per_vlan
            }
            
            # Inner
            if {[info exists inner_vlan_count]} {
                lappend vlan_range_attributes -innerUniqueCount $inner_vlan_count
            }
            if {[info exists inner_vlan_id]} {
                lappend vlan_range_attributes -innerFirstId $inner_vlan_id
            }
            if {[info exists inner_vlan_id_step]} {
                lappend vlan_range_attributes -innerIncrement $inner_vlan_id_step
            }
            if {[info exists inner_vlan_user_priority]} {
                lappend vlan_range_attributes -innerPriority $inner_vlan_user_priority
            }
            
            if {[info exists inner_address_per_vlan]} {
                lappend vlan_range_attributes -innerIncrementStep $inner_address_per_vlan
            }
            
            set retCode [ixNetworkNodeSetAttr $ranges_objref/vlanRange $vlan_range_attributes]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
    }
    
    # Configure IP range
    # IP range
    set ip_range_attributes [list -ipType $ip_version]
    
    if {[info exists src_mac_addr_auto]} {
        lappend ip_range_attributes -autoMacGeneration $truth($src_mac_addr_auto)
    }
    if {[info exists l2tp_src_addr]} {
        lappend ip_range_attributes -ipAddress $l2tp_src_addr
    }
    if {[info exists l2tp_src_prefix_len]} {
        if {[isIpAddressValid $l2tp_src_addr] && $l2tp_src_prefix_len > 32} {
            keylset returnList status $::FAILURE
            keylset returnList log "Parameter -l2tp_src_prefix_len \
                    $l2tp_src_prefix_len is out of range. Valid ranges are: \
                    0-32 for IPv4 and 0-128 for IPv6."
            return $returnList
        }
        lappend ip_range_attributes -prefix $l2tp_src_prefix_len
    }
    
    if {![info exists l2tp_src_step]} {
        if {$version == 4} {
            set l2tp_src_step 0.0.0.1
        } else {
            set l2tp_src_step 0:0:0:0:0:0:0:1
        }
    }
    
    if {[info exists l2tp_src_step]} {
        lappend ip_range_attributes -incrementBy $l2tp_src_step
    }
    if {[info exists l2tp_src_count]} {
        lappend ip_range_attributes -count $l2tp_src_count
    }
    if {[info exists l2tp_src_gw]} {
        lappend ip_range_attributes -gatewayAddress $l2tp_src_gw
    }
    
    if {[info exists l2tp_src_gw_step]} {
        lappend ip_range_attributes -gatewayIncrement $l2tp_src_gw_step
    }
    
    if {[info exists l2tp_src_gw_incr_mode]} {
        lappend ip_range_attributes -gatewayIncrementMode $translate_l2tp_src_gw_incr_mode($l2tp_src_gw_incr_mode)
    }
    
    set retCode [ixNetworkNodeSetAttr $ranges_objref/ipRange $ip_range_attributes]
    if {[keylget retCode status] != $::SUCCESS} {
        return $retCode
    }

    # Configure L2TP range
    set l2tp_range_attributes [list -tunnelDestinationIp $l2tp_dst_addr]
    # Basic
    if {[info exists l2tp_dst_step]} {
        lappend l2tp_range_attributes -tunnelIncrementBy $l2tp_dst_step
    }
    if {[info exists sessions_per_tunnel]} {
        lappend l2tp_range_attributes -sessionsPerTunnel $sessions_per_tunnel
        if {[info exists number_of_sessions]} {
            lappend l2tp_range_attributes -numSessions $number_of_sessions
        } else {
            lappend l2tp_range_attributes -numSessions \
                    [expr $num_tunnels * $sessions_per_tunnel]
        }
    }
    if {[info exists rws]} {
        lappend l2tp_range_attributes -receiveWindowSize $rws
    }
    if {[info exists avp_hide]} {
        lappend l2tp_range_attributes -useHiddenAvps $truth($avp_hide)
    }
    if {[info exists tun_auth]} {
        lappend l2tp_range_attributes -tunnelAuthentication \
                $translate_tun_auth($tun_auth)
    }
    if {[info exists hostname]} {
        lappend l2tp_range_attributes -lacHostName $hostname
    }
    if {[info exists secret]} {
        lappend l2tp_range_attributes -lacSecret $secret
    }
    # L2TP Control Plane
    if {[info exists bearer_capability]} {
        lappend l2tp_range_attributes -bearerCapability \
                $translate_bearer_capability($bearer_capability)
    }
    if {[info exists bearer_type]} {
        lappend l2tp_range_attributes -bearerType \
                $translate_bearer_type($bearer_type)
    }
    if {[info exists ctrl_retries]} {
        lappend l2tp_range_attributes -controlMsgsRetryCounter $ctrl_retries
    }
    if {[info exists redial]} {
        lappend l2tp_range_attributes -enableRedial $truth($redial)
    }
    if {[info exists redial_max]} {
        lappend l2tp_range_attributes -maxRedialAttempts $redial_max
    }
    if {[info exists redial_timeout]} {
        lappend l2tp_range_attributes -redialInterval $redial_timeout
    }
    if {[info exists hello_req]} {
        lappend l2tp_range_attributes -enableHelloRequest $truth($hello_req)
    }
    if {[info exists hello_interval]} {
        lappend l2tp_range_attributes -helloRequestInterval $hello_interval
    }
    if {[info exists init_ctrl_timeout]} {
        lappend l2tp_range_attributes -initRetransmitInterval $init_ctrl_timeout
    }
    if {[info exists max_ctrl_timeout]} {
        lappend l2tp_range_attributes -maxRetransmitInterval $max_ctrl_timeout
    }
    if {[info exists no_call_timeout]} {
        lappend l2tp_range_attributes -noCallTimeout $no_call_timeout
    }
    # L2TP Data Plane
    if {[info exists ctrl_chksum]} {
        lappend l2tp_range_attributes -enableControlChecksum \
                $truth($ctrl_chksum)
    }
    if {[info exists data_chksum]} {
        lappend l2tp_range_attributes -enableDataChecksum $truth($data_chksum)
    }
    if {[info exists offset_byte]} {
        lappend l2tp_range_attributes -offsetByte $offset_byte
    }
    if {[info exists offset_len]} {
        lappend l2tp_range_attributes -offsetLength $offset_len
    }
    if {[info exists udp_dst_port]} {
        lappend l2tp_range_attributes -udpDestinationPort $udp_dst_port
    }
    if {[info exists udp_src_port]} {
        lappend l2tp_range_attributes -udpSourcePort $udp_src_port
    }
    if {[info exists length_bit]} {
        lappend l2tp_range_attributes -useLengthBitInPayload $truth($length_bit)
    }
    if {[info exists offset_bit]} {
        lappend l2tp_range_attributes -useOffsetBitInPayload $truth($offset_bit)
    }
    if {[info exists sequence_bit]} {
        lappend l2tp_range_attributes -useSequenceNoInPayload \
                $truth($sequence_bit)
    }
    # L2TP Auth
    # LNS
    # Domain setting if required
    if {[info exists tun_distribution]} {
        lappend l2tp_range_attributes -lacToLnsMapping \
                $translate_tun_distribution($tun_distribution)
        if {$tun_distribution eq "domain_group" && \
                ![info exists domain_group_map]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -domain_group_map attribute must be\
                    specified when -tun_distribution is set to\
                    'domain_group_map'."
            return $returnList
        }
    }
    if {[info exists domain_group_map] && $domain_group_map != ""} {
        lappend l2tp_range_attributes -enableDomainGroups true

        # Get the global IP configuration used in configuring the domain
        # group mapping.
        set lns_count [lindex [lindex $domain_group_map 0] 0]
        if {$lns_count eq "" || ![string is integer $lns_count]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to get the number of LNS IPs\
                    from the -domain_group_map attribute."
            return $returnList
        }
        if {$lns_count < 1 || $lns_count > 65535} {
            keylset returnList status $::FAILURE
            keylset returnList log "The number of LNS IPs from the\
                    -domain_group_map attribute must be an integer\
                    in the \[1,65535\] range."
            return $returnList
        } else {
            lappend l2tp_range_attributes -lnsIpNumber $lns_count
        }
        set first_lns_ip [lindex [lindex $domain_group_map 0] 1]
        if {$first_lns_ip eq ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to get the base LNS IP\
                    from the -domain_group_map attribute."
            return $returnList
        }
        if {![::isIpAddressValid $first_lns_ip]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The base LNS IP read from the\
                    -domain_group_map attribute is not a valid IPv4 address."
            return $returnList
        } else {
            lappend l2tp_range_attributes -baseLnsIp $first_lns_ip
        }
        set incr_step [lindex [lindex $domain_group_map 0] 2]
        if {$incr_step eq "" || ![string is integer $incr_step]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to get the LNS IP increment step\
                    from the -domain_group_map attribute."
            return $returnList
        } elseif {$incr_step == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "LNS IP increment step\
                    from the -domain_group_map attribute should be greater than 0."
            return $returnList
        } else {
            lappend l2tp_range_attributes -incrementBy $incr_step
        }
        set incr_byte [lindex [lindex $domain_group_map 0] 3]
        if {$incr_byte eq "" || ![string is integer $incr_byte]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to get the LNS IP increment byte\
                    from the -domain_group_map attribute."
            return $returnList
        }
        if {$incr_byte < 1 || $incr_byte > 4} {
            keylset returnList status $::FAILURE
            keylset returnList log "The LNS IP increment byte\
                    from the -domain_group_map attribute must be an integer\
                    in the \[1,4\] range."
            return $returnList
        } else {
            lappend l2tp_range_attributes -ipIncrementOctet $incr_byte
        }

        # Create the list of IPs for internal use in this block of code.
        set ip_step [list 0 0 0 0]
        set ip_step [join [lreplace $ip_step [expr $incr_byte - 1] \
                [expr $incr_byte - 1] $incr_step] .]
        set ip_list [list $first_lns_ip]
        set temp_first_lns_ip $first_lns_ip
        for {set i 1} {$i < $lns_count} {incr i} {
            set temp_first_lns_ip [::ixia::incr_ipv4_addr \
                    $temp_first_lns_ip $ip_step]
            lappend ip_list $temp_first_lns_ip
        }                       

        # Remove the global IP configuration in order to get a list
        # containing only the domain group mapping inforamtion.
        set domain_group_maping [lindex $domain_group_map 1]
        foreach {domain_info ip_info} $domain_group_maping {
            set base_name [lindex $domain_info 0]
            set full_name $base_name
            set domain_group_attributes [list -baseName $base_name]
            if {[llength $domain_info] > 1} {
                set wc [lindex $domain_info 1]
            } elseif {[llength $domain_info] == 1} {
                set wc false
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "There is an empty domain group info\
                        block in the domain group mapping structure."
                return $returnList
            }
            if {$wc eq "" || ![string is boolean $wc]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to get the wildcard\
                        substitution status from the -domain_group_map\
                        attribute."
                return $returnList
            } else {
                lappend domain_group_attributes -autoIncrement $wc
            }
            if {$wc} {
                set wc_width [lindex $domain_info 2]
                if {$wc_width eq "" || ![string is double $wc_width]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to get the wildcard\
                            substitution width from the -domain_group_map\
                            attribute."
                    return $returnList
                }
                if {$wc_width < 0 || $wc_width > 65535} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The wildcard substitution width\
                            from the -domain_group_map attribute must be an\
                            integer in the \[0,65535\] range."
                    return $returnList
                } else {
                    lappend domain_group_attributes -startWidth $wc_width
                }
                set wc_incr [lindex $domain_info 3]
                if {$wc_incr eq "" || ![string is integer $wc_incr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to get the wildcard\
                            increment step from the -domain_group_map\
                            attribute."
                    return $returnList
                }
                if {$wc_incr < 1 || $wc_incr > 32000} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The wildcard substitution increment\
                            step from the -domain_group_map attribute must be\
                            an integer in the \[1,32000\] range."
                    return $returnList
                } else {
                    lappend domain_group_attributes -incrementCount $wc_incr
                }
                set wc_repeat [lindex $domain_info 4]
                if {$wc_repeat eq "" || ![string is integer $wc_repeat]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to get the wildcard\
                            increment repeat no. from the -domain_group_map\
                            attribute."
                    return $returnList
                }
                if {$wc_repeat < 1 || $wc_repeat > 32000} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The wildcard substitution increment\
                            repeat no. from the -domain_group_map attribute\
                            must be an integer in the \[1,32000\] range."
                    return $returnList
                } else {
                    lappend domain_group_attributes \
                            -incrementRepeat $wc_repeat
                }
                set trailing_name [lindex $domain_info 5]
                if {$trailing_name eq ""} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to get the domain\
                            trailing name from the -domain_group_map\
                            attribute."
                    return $returnList
                } else {
                    lappend domain_group_attributes \
                            -trailingName $trailing_name
                }
                append full_name \
                        "_${wc_width}_${wc_incr}_${wc_repeat}_${trailing_name}"
            }
            lappend domain_group_attributes \
                    -fullName [list $full_name]

            set selected_ip_list [list]
            foreach index $ip_info {
                lappend selected_ip_list [lindex $ip_list $index]
                set domain_group_result [ixNetworkNodeAdd \
                        $ranges_objref/l2tpRange lnsIp \
                        [list -selected true -address \
                        [list [lindex $ip_list $index]]] -commit]
                if {[keylget domain_group_result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add a LNS IP to the\
                            protocol stack of port $ranges_objref -\
                            [keylget domain_group_result log]."
                    return $returnList
                }
            }

            lappend domain_group_attributes \
                    -ipAddresses $selected_ip_list
            set domain_group_result [ixNetworkNodeAdd \
                    $ranges_objref/l2tpRange domainGroup \
                    $domain_group_attributes -commit]
            if {[keylget domain_group_result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to add a domain group to the\
                        protocol stack of port $ranges_objref -\
                        [keylget domain_group_result log]."
                return $returnList
            }
        }
    }
    # LCP
    if {[info exists echo_req_interval]} {
        lappend l2tp_range_attributes -echoReqInterval $echo_req_interval
    }
    if {[info exists echo_req]} {
        lappend l2tp_range_attributes -enableEchoReq $echo_req
    }
    if {[info exists echo_rsp]} {
        lappend l2tp_range_attributes -enableEchoRsp $echo_rsp
    }
    if {[info exists max_configure_req]} {
        lappend l2tp_range_attributes -lcpRetries $max_configure_req
    }
    if {[info exists config_req_timeout]} {
        lappend l2tp_range_attributes -lcpTimeout $config_req_timeout
    }

    # NCP
    # ipv4_cp and ipv6_cp use the ppp_client_ip, ppp_client_step, ppp_server_ip params
    # dual_stack uses both ppp_client_ip, ppp_client_step, ppp_server_ip params
    # and ppp_client_iid, ppp_client_iid_step, ppp_server_iid
    if {$ip_cp == "ipv6_cp"} {
        set ppp_client_iid $ppp_client_ip
        set ppp_client_iid_step $ppp_client_step
        set ppp_server_iid $ppp_server_ip
    }

    lappend l2tp_range_attributes -ncpType $translate_ip_cp($ip_cp)
    if {$ip_cp == "ipv4_cp" || $ip_cp == "dual_stack"} {
        if {[info exists ppp_client_ip]} {
            lappend l2tp_range_attributes -clientBaseIp $ppp_client_ip
        } else {
            lappend l2tp_range_attributes -clientBaseIp 1.1.1.1
        }
        if {[info exists ppp_client_step]} {
            lappend l2tp_range_attributes -clientIpIncr $ppp_client_step
        } else {
            lappend l2tp_range_attributes -clientIpIncr 0.0.0.1
        }
        if {[info exists ppp_server_ip]} {
            lappend l2tp_range_attributes -serverBaseIp $ppp_server_ip
        } else {
            lappend l2tp_range_attributes -serverBaseIp 2.2.2.2
        }
    } 
    if {$ip_cp == "ipv6_cp" || $ip_cp == "dual_stack"} {
        if {[info exists ppp_client_iid]} {
            set clientBaseIid [::ixia::convert_v6_addr_to_hex $ppp_client_iid]
            set clientBaseIid [lrange $clientBaseIid 8 end]
            set clientBaseIid [regsub -all { } $clientBaseIid :]
            lappend l2tp_range_attributes -clientBaseIid $clientBaseIid
        } else {
            lappend l2tp_range_attributes -clientBaseIid 00:11:11:11:00:00:00:01
        }
        if {[info exists ppp_client_iid_step]} {
            lappend l2tp_range_attributes -clientIidIncr [::ixia::list2Val \
                    [::ixia::convert_v6_addr_to_hex $ppp_client_iid_step]]
        } else {
            lappend l2tp_range_attributes -clientIidIncr 1
        }
        if {[info exists ppp_server_iid]} {
            set serverBaseIid [::ixia::convert_v6_addr_to_hex $ppp_server_iid]
            set serverBaseIid [lrange $serverBaseIid 8 end]
            set serverBaseIid [regsub -all { } $serverBaseIid :]
            lappend l2tp_range_attributes -serverBaseIid $serverBaseIid
        } else {
            lappend l2tp_range_attributes -serverBaseIid 00:11:22:11:00:00:00:01
        }
        if {[info exists ipv6_pool_prefix]} {
            lappend l2tp_range_attributes -ipv6PoolPrefix $ipv6_pool_prefix
        }
        if {[info exists ipv6_pool_prefix_len]} {
            lappend l2tp_range_attributes -ipv6PoolPrefixLen \
                    $ipv6_pool_prefix_len
        }
        if {[info exists ipv6_pool_addr_prefix_len]} {
            lappend l2tp_range_attributes -ipv6AddrPrefixLen \
                    $ipv6_pool_addr_prefix_len
        }
    }
    if {[info exists max_ipcp_req]} {
        lappend l2tp_range_attributes -ncpRetries $max_ipcp_req
    }
    if {[info exists ipcp_req_timeout]} {
        lappend l2tp_range_attributes -ncpTimeout $ipcp_req_timeout
    }
    # PPP Authentication
    if {[info exists max_auth_req]} {
        lappend l2tp_range_attributes -authRetries $max_auth_req
    }
    if {[info exists auth_req_timeout]} {
        lappend l2tp_range_attributes -authTimeout $auth_req_timeout
    }
    if {[info exists auth_mode]} {
        lappend l2tp_range_attributes -authType $translate_auth_mode($auth_mode)
    }
    if {[info exists username]} {
        lappend l2tp_range_attributes -chapName $username
    }
    if {[info exists password]} {
        lappend l2tp_range_attributes -chapSecret $password
    }
    if {[info exists password]} {
        lappend l2tp_range_attributes -papPassword $password
    }
    if {[info exists username]} {
        lappend l2tp_range_attributes -papUser $username
    }
    # Unexposed attributes
    if {[info exists avp_rx_connect_speed]} {
#         lappend l2tp_range_attributes -rxConnectSpeed $avp_rx_connect_speed
    }
    if {[info exists avp_tx_connect_speed]} {
#         lappend l2tp_range_attributes -txConnectSpeed $avp_tx_connect_speed
    }
    if {[info exists enable_magic]} {
        lappend l2tp_range_attributes -useMagic $enable_magic
    }
    if {[info exists sess_distribution]} {
        lappend l2tp_range_attributes -sessionAllocMethod \
                $translate_sess_distribution($sess_distribution)
    }
    if {[info exists session_id_start]} {
#         lappend l2tp_range_attributes -sessionStartId $session_id_start
    }
    if {[info exists tunnel_id_start]} {
#         lappend l2tp_range_attributes -tunnelStartId $tunnel_id_start
    }
    if {[info exists framing_capability]} {
        lappend l2tp_range_attributes -framingCapability \
                $translate_framing_capability($framing_capability)
    }
    if {[info exists proxy]} {
#         lappend l2tp_range_attributes -enableProxy $proxy
    }
    if {[info exists enable_mru_negotiation]} {
        lappend l2tp_range_attributes -enableMru $truth($enable_mru_negotiation)
    }
    if {[info exists desired_mru_rate]} {
        lappend l2tp_range_attributes -mtu $desired_mru_rate
    }
    
    set tmpStatus [ixNetworkNodeSetAttr $ranges_objref/l2tpRange $l2tp_range_attributes] 
    if {[keylget tmpStatus status] != $::SUCCESS} {
        return $tmpStatus
    }

    debug "ixNet commit"
    # Commit changes
    if {[catch {ixNet commit} retMsg] || ($retMsg != "::ixNet::OK")} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on setting attributes for L2TP range.\
                $retMsg"
        return $returnList
    }
    set handle $ranges_objref
    if {[string first l2tpEndpoint $handle] != -1} {
        set dhcpv6_hosts_enable 0
    } else {
        set dhcpv6_hosts_enable 1
    }
    if {[info exists dhcpv6_hosts_enable] && $dhcpv6_hosts_enable} {
        set hosts_result [::ixia::ixnetwork_dhcpv6_range_config]
        if {[keylget hosts_result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to add dhcp support to the\
                    protocol stack of port $port_objref - [keylget hosts_result log]."
            return $returnList
        }
    }

    keylset returnList status $::SUCCESS
    keylset returnList handle $ranges_objref
    return $returnList
}

proc ::ixia::ixnetwork_l2tp_control { args man_args opt_args } {
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    
    set stack_type_list { ethernet atm }

    set l2tp_endpoint_objref_list [list]
    # if -handle doesn't exist, populate l2tp_endpoint_objref_list with all l2tpEndpoints on all ports
    if {![info exists handle]} {
        set vport_list [ixNet getList [ixNet getRoot] vport]
        foreach vp $vport_list {
            foreach st $stack_type_list {
                set ret_val [::ixia::ixNetworkValidateSMPlugins $vp $st "ip"]
                if {[keylget ret_val status] == $::SUCCESS && [keylget ret_val summary] == 3} {
                    foreach ip_range [keylget ret_val ret_val] {
                        set l2tp_objref [ixNet getList $ip_range l2tpEndpoint]
                        set dhcpv6ol2tp_objref [ixNet getList $ip_range l2tp]
                        set l2tp_endpoint_objref_list [concat $l2tp_endpoint_objref_list $l2tp_objref]
                        set l2tp_endpoint_objref_list [concat $l2tp_endpoint_objref_list $dhcpv6ol2tp_objref]
                    }
                }
            }
        }
    } else {
        foreach item $handle {
            set found [regexp {(.*)/range:} $item {} found_l2tp_endpoint_objref]
            if {$found} {
                # -handle is a l2tp range
                lappend l2tp_endpoint_objref_list $found_l2tp_endpoint_objref
            } else {
                set found [regexp {^\d+/\d+/\d+$} $item]
                if {$found} {
                    # if -handle is a port_handle, populate l2tp_endpoint_objref_list with all l2tpEndpoints on that port
                    set ret_val [::ixia::ixNetworkGetPortObjref $item]
                    if {[keylget ret_val status] == $::SUCCESS} {
                        set vport_handle [keylget ret_val vport_objref]
                        foreach st $stack_type_list {
                            set ret_val [::ixia::ixNetworkValidateSMPlugins $vport_handle $st "ip"]
                            if {[keylget ret_val status] == $::SUCCESS && [keylget ret_val summary] == 3} {
                                foreach ip_range [keylget ret_val ret_val] {
                                    set l2tp_objref [ixNet getList $ip_range l2tpEndpoint]
                                    set l2tp_endpoint_objref_list [concat $l2tp_endpoint_objref_list $l2tp_objref]
                                }
                            }
                        }
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get the L2TP endpoint\
                            object reference out of the handle received as input:\
                            $item"
                    return $returnList
                }
            }
        }
    }
    
    array set async_map {
        connect     1
        disconnect  1
        abort       0
        abort_async 1
    }
    
    array set action_map {
        connect     start
        disconnect  stop
        abort       abort
        abort_async abort
    }
    
    foreach l2tp_endpoint_objref $l2tp_endpoint_objref_list {
        set ixNetworkExecParamsAsync [list $action_map($action) $l2tp_endpoint_objref]
        set ixNetworkExecParamsSync [list $action_map($action) $l2tp_endpoint_objref]
        if {$async_map($action)} {
            lappend ixNetworkExecParamsAsync async
        }
        if {[catch {ixNetworkExec $ixNetworkExecParamsAsync} status_1]} {
            if {[string first "no matching exec found" $status_1] != -1 } {
                if {[string compare -nocase $ixNetworkExecParamsAsync $ixNetworkExecParamsSync] != 0 && \
                        [catch {ixNetworkExec $ixNetworkExecParamsSync} status_2] && \
                        ([string first "::ixNet::OK" $status_2] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action L2TP. Returned status: $status_2"
                    return $returnList
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $action L2TP. Returned status: $status_1"
                return $returnList
            }
        } else {
            if {[string first "::ixNet::OK" $status_1] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $action L2TP. Returned status: $status_1"
                return $returnList
            }
        }
    }
    
    return $returnList
}

proc ::ixia::ixnetwork_l2tp_stats { args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "When -mode is $mode, one of the parameters\
                -port_handle or -handle must be provided."
        return $returnList
    }
    
    if {![info exists port_handle]} {
        set port_handle ""
        foreach handleElem $handle {
            set retCode [ixNetworkGetPortFromObj $handleElem]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            lappend port_handle [keylget retCode port_handle]
        }
    }
    if {[catch {set ::ixia::ixnetworkVersion} ixn_version]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get IxNetwork version - $ixn_version.\
                Possible causes: not connected to IxNetwork Tcl Server."
        return $returnList
    }
    set all_session_statistics 0
    if {$mode == "session_all"} {
        # gather all statistics per session
        set all_session_statistics 1
    }
    if {$mode == "aggregate"} {
        # Define the statistics to be gathered from the tables in the
        # stat view browser
        set stat_views_list [list]
        set stat_view_stats_list [list]
        set stat_view_arrays_list [list]

        # L2TP General Statistics
        lappend stat_views_list "L2TP General Statistics"

        set stats_list [list                                    \
                "Port Name"                                     \
                "L2TP Total Bytes Tx"                           \
                "L2TP Total Bytes Rx"                           \
                "Client Tunnels Up"                             \
                "Server Tunnels Up"                             \
                "Client Interfaces Up"                          \
                "Client Interfaces Setup Rate"                  \
                "Server Interfaces Up"                          \
                "Server Interfaces Setup Rate"                  \
                "Interfaces Teardown Rate"                      \
                "Client Interfaces in PPP Negotiation"          \
                "Server Interfaces in PPP Negotiation"          \
                "Interfaces in L2TP Negotiation"                \
                "Sessions Initiated"                            \
                "Sessions Failed"                               \
                "LCP Total Messages Tx"                         \
                "LCP Total Messages Rx"                         \
                "Authentication Total Tx"                       \
                "Authentication Total Rx"                       \
                "NCP Total Messages Tx"                         \
                "NCP Total Messages Rx"                         \
                "PPP Total Bytes Tx"                            \
                "PPP Total Bytes Rx"                            \
                "Malformed PPP Frames Used"                     \
                "Malformed PPP Frames Rejected"                 \
                "Client Max Setup Rate"                         \
                "Max Teardown Rate"                             \
                ]
        regexp {^(\d+.\d+)(P|N|NO|P2NO)?$} $::ixia::ixnetworkVersion {} version product]
        if {$version <= 6.30} {
            set stats_list [lrange $stats_list 1 end]
        }
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "Port Name"                                     \
                        port_name                               \
                "L2TP Total Bytes Tx"                           \
                        total_bytes_tx                          \
                "L2TP Total Bytes Rx"                           \
                        total_bytes_rx                          \
                "Client Tunnels Up"                             \
                        client_tunnels_up                       \
                "Server Tunnels Up"                             \
                        server_tunnels_up                       \
                "Client Interfaces Up"                          \
                        client_interfaces_up                    \
                "Client Interfaces Setup Rate"                  \
                        client_interfaces_setup_rate            \
                "Server Interfaces Up"                          \
                        server_interfaces_up                    \
                "Server Interfaces Setup Rate"                  \
                        server_interfaces_setup_rate            \
                "Interfaces Teardown Rate"                      \
                        interfaces_teardown_rate                \
                "Client Interfaces in PPP Negotiation"          \
                        client_interfaces_in_ppp_negotiation    \
                "Server Interfaces in PPP Negotiation"          \
                        server_interfaces_in_ppp_negotiation    \
                "Interfaces in L2TP Negotiation"                \
                        interfaces_in_pppoe_l2tp_negotiation    \
                "Sessions Initiated"                            \
                        num_sessions                            \
                "Sessions Failed"                               \
                        sessions_failed                         \
                "LCP Total Messages Tx"                         \
                        lcp_total_msg_tx                        \
                "LCP Total Messages Rx"                         \
                        lcp_total_msg_rx                        \
                "Authentication Total Tx"                       \
                        auth_total_tx                           \
                "Authentication Total Rx"                       \
                        auth_total_rx                           \
                "NCP Total Messages Tx"                         \
                        ncp_total_msg_tx                        \
                "NCP Total Messages Rx"                         \
                        ncp_total_msg_rx                        \
                "PPP Total Bytes Tx"                            \
                        ppp_total_bytes_tx                      \
                "PPP Total Bytes Rx"                            \
                        ppp_total_bytes_rx                      \
                "Malformed PPP Frames Used"                     \
                        malformed_ppp_frames_used               \
                "Malformed PPP Frames Rejected"                 \
                        malformed_ppp_frames_rejected           \
                "Client Max Setup Rate"                         \
                        client_max_setup_rate                   \
                "Max Teardown Rate"                             \
                        teardown_rate                           \
                ]
        if {$version <= 6.30} {
            set stats_array [lrange $stats_array 2 end]
        }
        lappend stat_view_arrays_list $stats_array

        # L2TP Control Connection
        lappend stat_views_list "L2TP Control Connection"

        set stats_list [list                                    \
                "SCCRQ Tx"                                      \
                "SCCRQ Rx"                                      \
                "SCCRP Rx"                                      \
                "SCCRP Tx"                                      \
                "SCCCN Tx"                                      \
                "SCCCN Rx"                                      \
                "StopCCN Tx"                                    \
                "StopCCN Rx"                                    \
                "ZLB Tx"                                        \
                "ZLB Rx"                                        \
                "Hello Tx"                                      \
                "Hello Rx"                                      \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "SCCRQ Tx"                                      \
                        sccrq_tx                                \
                "SCCRQ Rx"                                      \
                        sccrq_rx                                \
                "SCCRP Tx"                                      \
                        sccrp_tx                                \
                "SCCRP Rx"                                      \
                        sccrp_rx                                \
                "SCCCN Tx"                                      \
                        scccn_tx                                \
                "SCCCN Rx"                                      \
                        scccn_rx                                \
                "StopCCN Tx"                                    \
                        stopccn_tx                              \
                "StopCCN Rx"                                    \
                        stopccn_rx                              \
                "ZLB Tx"                                        \
                        zlb_tx                                  \
                "ZLB Rx"                                        \
                        zlb_rx                                  \
                "Hello Tx"                                      \
                        hello_tx                                \
                "Hello Rx"                                      \
                        hello_rx                                \
                ]
        lappend stat_view_arrays_list $stats_array

        # L2TP Tunnel
        lappend stat_views_list "L2TP Tunnel"

        set stats_list [list                                    \
                "L2TP Window Messages Tx Attempt While Close"   \
                "L2TP Window Messages Tx Attempt While Open"    \
                "L2TP Window Messages Retransmitted"            \
                "L2TP Window Messages ACKed By Peer"            \
                "L2TP Window Messages Rx Duplicate"             \
                "L2TP Window Messages Rx Out of Window"         \
                "L2TP Window Messages Rx Out of Order"          \
                "L2TP Window Messages Rx in Sequence"           \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "L2TP Window Messages Tx Attempt While Close"   \
                        tun_tx_win_close                        \
                "L2TP Window Messages Tx Attempt While Open"    \
                        tun_tx_win_open                         \
                "L2TP Window Messages Retransmitted"            \
                        retransmits                             \
                "L2TP Window Messages ACKed By Peer"            \
                        tx_pkt_acked                            \
                "L2TP Window Messages Rx Duplicate"             \
                        duplicate_rx                            \
                "L2TP Window Messages Rx Out of Window"         \
                        out_of_win_rx                           \
                "L2TP Window Messages Rx Out of Order"          \
                        out_of_order_rx                         \
                "L2TP Window Messages Rx in Sequence"           \
                        in_order_rx                             \
                ]
        lappend stat_view_arrays_list $stats_array

        # L2TP Tunnel Latency
        lappend stat_views_list "L2TP Tunnel Latency"

        set stats_list [list                                    \
                "L2TP Tunnel Minimum Latency (ms)"            \
                "L2TP Tunnel Average Latency (ms)"            \
                "L2TP Tunnel Maximum Latency (ms)"            \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
               "L2TP Tunnel Minimum Latency (ms)"             \
                        min_setup_time                          \
                "L2TP Tunnel Average Latency (ms)"            \
                        avg_setup_time                          \
                "L2TP Tunnel Maximum Latency (ms)"            \
                        max_setup_time                          \
                ]
        lappend stat_view_arrays_list $stats_array

        # L2TP Call Management
        lappend stat_views_list "L2TP Call Management"

        set stats_list [list                                    \
                "ICRQ Tx"                                       \
                "ICRQ Rx"                                       \
                "ICRP Rx"                                       \
                "ICRP Tx"                                       \
                "ICCN Tx"                                       \
                "ICCN Rx"                                       \
                "CDN Tx"                                        \
                "CDN Rx"                                        \
                "WEN Tx"                                        \
                "WEN Rx"                                        \
                "SLI Tx"                                        \
                "SLI Rx"                                        \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "ICRQ Tx"                                       \
                        icrq_tx                                 \
                "ICRQ Rx"                                       \
                        icrq_rx                                 \
                "ICRP Tx"                                       \
                        icrp_tx                                 \
                "ICRP Rx"                                       \
                        icrp_rx                                 \
                "ICCN Tx"                                       \
                        iccn_tx                                 \
                "ICCN Rx"                                       \
                        iccn_rx                                 \
                "CDN Tx"                                        \
                        cdn_tx                                  \
                "CDN Rx"                                        \
                        cdn_rx                                  \
                "WEN Tx"                                        \
                        wen_tx                                  \
                "WEN Rx"                                        \
                        wen_rx                                  \
                "SLI Tx"                                        \
                        sli_tx                                  \
                "SLI Rx"                                        \
                        sli_rx                                  \
                ]
        lappend stat_view_arrays_list $stats_array

        # LCP Link Establishment Phase Statistics
        lappend stat_views_list "L2TP LCP Link Establishment Phase Statistics"

        set stats_list [list                                    \
                "LCP Config Request Tx"                         \
                "LCP Config Request Rx"                         \
                "LCP Config ACK Tx"                             \
                "LCP Config ACK Rx"                             \
                "LCP Config NAK Tx"                             \
                "LCP Config NAK Rx"                             \
                "LCP Config Reject Tx"                          \
                "LCP Config Reject Rx"                          \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "LCP Config Request Tx"                         \
                        lcp_cfg_req_tx                          \
                "LCP Config Request Rx"                         \
                        lcp_cfg_req_rx                          \
                "LCP Config ACK Tx"                             \
                        lcp_cfg_ack_tx                          \
                "LCP Config ACK Rx"                             \
                        lcp_cfg_ack_rx                          \
                "LCP Config NAK Tx"                             \
                        lcp_cfg_nak_tx                          \
                "LCP Config NAK Rx"                             \
                        lcp_cfg_nak_rx                          \
                "LCP Config Reject Tx"                          \
                        lcp_cfg_rej_tx                          \
                "LCP Config Reject Rx"                          \
                        lcp_cfg_rej_rx                          \
                ]
        lappend stat_view_arrays_list $stats_array

        # LCP Link Maintenance Statistics
        lappend stat_views_list "L2TP LCP Link Maintenance Statistics"

        set stats_list [list                                    \
                "LCP Echo Request Tx"                           \
                "LCP Echo Request Rx"                           \
                "LCP Echo Response Tx"                          \
                "LCP Echo Response Rx"                          \
                "LCP Code Reject Tx"                            \
                "LCP Code Reject Rx"                            \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "LCP Echo Request Tx"                           \
                        echo_req_tx                             \
                "LCP Echo Request Rx"                           \
                        echo_req_rx                             \
                "LCP Echo Response Tx"                          \
                        echo_rsp_tx                             \
                "LCP Echo Response Rx"                          \
                        echo_rsp_rx                             \
                "LCP Code Reject Tx"                            \
                        echo_rej_tx                             \
                "LCP Code Reject Rx"                            \
                        echo_rej_rx                             \
                ]
        lappend stat_view_arrays_list $stats_array

        # LCP Link Termination Statistics
        lappend stat_views_list "L2TP LCP Link Termination Statistics"

        set stats_list [list                                    \
                "LCP Terminate Tx"                              \
                "LCP Terminate Rx"                              \
                "LCP Terminate ACK Tx"                          \
                "LCP Terminate ACK Rx"                          \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "LCP Terminate Tx"                              \
                        term_req_tx                             \
                "LCP Terminate Rx"                              \
                        term_req_rx                             \
                "LCP Terminate ACK Tx"                          \
                        term_ack_tx                             \
                "LCP Terminate ACK Rx"                          \
                        term_ack_rx                             \
                ]
        lappend stat_view_arrays_list $stats_array

        # NCP IPCP Statistics
        lappend stat_views_list "L2TP NCP IPCP Statistics"

        set stats_list [list                                    \
                "IPCP Config Request Tx"                        \
                "IPCP Config Request Rx"                        \
                "IPCP Config ACK Tx"                            \
                "IPCP Config ACK Rx"                            \
                "IPCP Config NAK Tx"                            \
                "IPCP Config NAK Rx"                            \
                "IPCP Config Reject Tx"                         \
                "IPCP Config Reject Rx"                         \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "IPCP Config Request Tx"                        \
                        ipcp_cfg_req_tx                         \
                "IPCP Config Request Rx"                        \
                        ipcp_cfg_req_rx                         \
                "IPCP Config ACK Tx"                            \
                        ipcp_cfg_ack_tx                         \
                "IPCP Config ACK Rx"                            \
                        ipcp_cfg_ack_rx                         \
                "IPCP Config NAK Tx"                            \
                        ipcp_cfg_nak_tx                         \
                "IPCP Config NAK Rx"                            \
                        ipcp_cfg_nak_rx                         \
                "IPCP Config Reject Tx"                         \
                        ipcp_cfg_rej_tx                         \
                "IPCP Config Reject Rx"                         \
                        ipcp_cfg_rej_rx                         \
                ]
        lappend stat_view_arrays_list $stats_array

        # NCP IPv6CP Statistics
        lappend stat_views_list "L2TP NCP IPv6CP Statistics"

        set stats_list [list                                    \
                "IPv6CP Config Request Tx"                      \
                "IPv6CP Config Request Rx"                      \
                "IPv6CP Config ACK Tx"                          \
                "IPv6CP Config ACK Rx"                          \
                "IPv6CP Config NAK Tx"                          \
                "IPv6CP Config NAK Rx"                          \
                "IPv6CP Config Reject Tx"                       \
                "IPv6CP Config Reject Rx"                       \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "IPv6CP Config Request Tx"                      \
                        ipv6cp_cfg_req_tx                       \
                "IPv6CP Config Request Rx"                      \
                        ipv6cp_cfg_req_rx                       \
                "IPv6CP Config ACK Tx"                          \
                        ipv6cp_cfg_ack_tx                       \
                "IPv6CP Config ACK Rx"                          \
                        ipv6cp_cfg_ack_rx                       \
                "IPv6CP Config NAK Tx"                          \
                        ipv6cp_cfg_nak_tx                       \
                "IPv6CP Config NAK Rx"                          \
                        ipv6cp_cfg_nak_rx                       \
                "IPv6CP Config Reject Tx"                       \
                        ipv6cp_cfg_rej_tx                       \
                "IPv6CP Config Reject Rx"                       \
                        ipv6cp_cfg_rej_rx                       \
                ]
        lappend stat_view_arrays_list $stats_array

        # PAP Authentication Statistics
        lappend stat_views_list "L2TP PAP Authentication Statistics"

        set stats_list [list                                    \
                "PAP Authentication Request Tx"                 \
                "PAP Authentication Request Rx"                 \
                "PAP Authentication ACK Tx"                     \
                "PAP Authentication ACK Rx"                     \
                "PAP Authentication NAK Tx"                     \
                "PAP Authentication NAK Rx"                     \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "PAP Authentication Request Tx"                 \
                        pap_auth_req_tx                         \
                "PAP Authentication Request Rx"                 \
                        pap_auth_req_rx                         \
                "PAP Authentication ACK Tx"                     \
                        pap_auth_ack_tx                         \
                "PAP Authentication ACK Rx"                     \
                        pap_auth_ack_rx                         \
                "PAP Authentication NAK Tx"                     \
                        pap_auth_nak_tx                         \
                "PAP Authentication NAK Rx"                     \
                        pap_auth_nak_rx                         \
                ]
        lappend stat_view_arrays_list $stats_array

        # CHAP Authentication Statistics
        lappend stat_views_list "L2TP CHAP Authentication Statistics"

        set stats_list [list                                    \
                "CHAP Challenge Tx"                             \
                "CHAP Challenge Rx"                             \
                "CHAP Response Tx"                              \
                "CHAP Response Rx"                              \
                "CHAP Success Tx"                               \
                "CHAP Success Rx"                               \
                "CHAP Failure Tx"                               \
                "CHAP Failure Rx"                               \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "CHAP Challenge Tx"                             \
                        chap_auth_chal_tx                       \
                "CHAP Challenge Rx"                             \
                        chap_auth_chal_rx                       \
                "CHAP Response Tx"                              \
                        chap_auth_rsp_tx                        \
                "CHAP Response Rx"                              \
                        chap_auth_rsp_rx                        \
                "CHAP Success Tx"                               \
                        chap_auth_succ_tx                       \
                "CHAP Success Rx"                               \
                        chap_auth_succ_rx                       \
                "CHAP Failure Tx"                               \
                        chap_auth_fail_tx                       \
                "CHAP Failure Rx"                               \
                        chap_auth_fail_rx                       \
                ]
        lappend stat_view_arrays_list $stats_array

        # PPP Latency Statistics
        lappend stat_views_list "L2TP PPP Latency Statistics"

        set stats_list [list                                    \
                "Client Session Minimum Latency (ms)"         \
                "Client Session Average Latency (ms)"         \
                "Client Session Maximum Latency (ms)"         \
                "Server Session Minimum Latency (ms)"         \
                "Server Session Average Latency (ms)"         \
                "Server Session Maximum Latency (ms)"         \
                "LCP Minimum Latency (ms)"                    \
                "LCP Average Latency (ms)"                    \
                "LCP Maximum Latency (ms)"                    \
                "NCP Minimum Latency (ms)"                    \
                "NCP Average Latency (ms)"                    \
                "NCP Maximum Latency (ms)"                    \
                ]
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "Client Session Minimum Latency (ms)"         \
                        client_session_min_latency              \
                "Client Session Average Latency (ms)"         \
                        client_session_avg_latency              \
                "Client Session Maximum Latency (ms)"         \
                        client_session_max_latency              \
                "Server Session Minimum Latency (ms)"         \
                        server_session_min_latency              \
                "Server Session Average Latency (ms)"         \
                        server_session_avg_latency              \
                "Server Session Maximum Latency (ms)"         \
                        server_session_max_latency              \
                "LCP Minimum Latency (ms)"                    \
                        lcp_min_latency                         \
                "LCP Average Latency (ms)"                    \
                        lcp_avg_latency                         \
                "LCP Maximum Latency (ms)"                    \
                        lcp_max_latency                         \
                "NCP Minimum Latency (ms)"                    \
                        ncp_min_latency                         \
                "NCP Average Latency (ms)"                    \
                        ncp_avg_latency                         \
                "NCP Maximum Latency (ms)"                    \
                        ncp_max_latency                         \
                ]
        lappend stat_view_arrays_list $stats_array

        # DHCPv6PD Server Statistics
        set stats_list_dhcpv6_server [list          \
                "Port Name"                         \
                "Solicits Received"                 \
                "Advertisements Sent"               \
                "Requests Received"                 \
                "Confirms Received"                 \
                "Renewals Received"                 \
                "Rebinds Received"                  \
                "Replies Sent"                      \
                "Releases Received"                 \
                "Declines Received"                 \
                "Information-Requests Received"     \
                "Total Prefixes Allocated"          \
                "Total Prefixes Renewed"            \
                "Current Prefixes Allocated"        \
                ]
        set stats_array_dhcpv6pd_server [list               \
                "Port Name"                                 \
                    port_name                               \
                "Solicits Received"                         \
                    dhcpv6pd_solicits_received              \
                "Advertisements Sent"                       \
                    dhcpv6pd_advertisements_sent            \
                "Requests Received"                         \
                    dhcpv6pd_requests_received              \
                "Confirms Received"                         \
                    dhcpv6pd_confirms_received              \
                "Renewals Received"                         \
                    dhcpv6pd_renewals_received              \
                "Rebinds Received"                          \
                    dhcpv6pd_rebinds_received               \
                "Replies Sent"                              \
                    dhcpv6pd_replies_sent                   \
                "Releases Received"                         \
                    dhcpv6pd_releases_received              \
                "Declines Received"                         \
                    dhcpv6pd_declines_received              \
                "Information-Requests Received"             \
                    dhcpv6pd_information_requests_received  \
                "Total Prefixes Allocated"                  \
                    dhcpv6pd_total_prefixes_allocated       \
                "Total Prefixes Renewed"                    \
                    dhcpv6pd_total_prefixes_renewed         \
                "Current Prefixes Allocated"                \
                    dhcpv6pd_current_prefixes_allocated     \
                ]
        
        # DHCPv6PD Client Statistics
        set stats_list_dhcpv6_client [list          \
                "Port Name"                         \
                "Solicits Sent"                     \
                "Advertisements Received"           \
                "Advertisements Ignored"            \
                "Requests Sent"                     \
                "Replies Received"                  \
                "Renews Sent"                       \
                "Rebinds Sent"                      \
                "Releases Sent"                     \
                "Enabled Interfaces"                \
                "Addresses Discovered"              \
                "Information Requests Sent"         \
                "Setup Success Rate"                \
                "Teardown Initiated"                \
                "Teardown Success"                  \
                "Teardown Fail"                     \
                "Sessions Initiated"                \
                "Sessions Succeeded"                \
                "Sessions Failed"                   \
                "Min Establishment Time"            \
                "Avg Establishment Time"            \
                "Max Establishment Time"            \
                ]
        set stats_array_dhcpv6pd_client [list               \
                "Port Name"                                 \
                    port_name                               \
                "Addresses Discovered"                      \
                    dhcpv6pd_addresses_discovered           \
                "Advertisements Ignored"                    \
                    dhcpv6pd_advertisements_ignored         \
                "Advertisements Received"                   \
                    dhcpv6pd_advertisements_received        \
                "Enabled Interfaces"                        \
                    dhcpv6pd_enabled_interfaces             \
                "Rebinds Sent"                              \
                    dhcpv6pd_rebinds_sent                   \
                "Releases Sent"                             \
                    dhcpv6pd_releases_sent                  \
                "Renews Sent"                               \
                    dhcpv6pd_renews_sent                    \
                "Replies Received"                          \
                    dhcpv6pd_replies_received               \
                "Requests Sent"                             \
                    dhcpv6pd_requests_sent                  \
                "Sessions Failed"                           \
                    dhcpv6pd_sessions_failed                \
                "Sessions Initiated"                        \
                    dhcpv6pd_sessions_initiated             \
                "Sessions Succeeded"                        \
                    dhcpv6pd_sessions_succeeded             \
                "Setup Success Rate"                        \
                    dhcpv6pd_setup_success_rate             \
                "Solicits Sent"                             \
                    dhcpv6pd_solicits_sent                  \
                "Teardown Fail"                             \
                    dhcpv6pd_teardown_fail                  \
                "Teardown Initiated"                        \
                    dhcpv6pd_teardown_initiated             \
                "Teardown Success"                          \
                    dhcpv6pd_teardown_success               \
                "Information Requests Sent"                 \
                    dhcpv6pd_information_requests_sent      \
                "Min Establishment Time"                    \
                    dhcpv6pd_min_establishment_time         \
                "Avg Establishment Time"                    \
                    dhcpv6pd_avg_establishment_time         \
                "Max Establishment Time"                    \
                    dhcpv6pd_max_establishment_time         \
                ]
        regexp {^(\d+.\d+)(P|N|NO|P2NO)?$} $::ixia::ixnetworkVersion {} version product]
        if {$version <= 6.30} {
            set stats_list_dhcpv6_server [lrange $stats_list_dhcpv6_server 1 end]
            set stats_array_dhcpv6pd_server [lrange $stats_array_dhcpv6pd_server 2 end]
            set stats_list_dhcpv6_client [lrange $stats_list_dhcpv6_client 1 end]
            set stats_array_dhcpv6pd_client [lrange $stats_array_dhcpv6pd_client 2 end]
        }
        # DHCP Hosts Statistics
        set stats_list_dhcp_hosts [list             \
                "Sessions Initiated"                \
                "Sessions Succeeded"                \
                "Sessions Failed"                   \
                ]
        set stats_array_dhcp_hosts [list         \
                "Sessions Failed"                      \
                    dhcp_hosts_sessions_failed         \
                "Sessions Initiated"                   \
                    dhcp_hosts_sessions_initiated      \
                "Sessions Succeeded"                   \
                    dhcp_hosts_sessions_succeeded      \
                ]
        set original_stat_view_array_list $stat_view_arrays_list
        set original_stat_view_stats_list $stat_view_stats_list
        set original_stat_view_list $stat_views_list
        set index 0
        foreach port $port_handle {
        incr index
            # we could have different stats on each port, so we add statistics
            # to original_stat_view_array_list, which is common for every port.
            set stat_view_arrays_list $original_stat_view_array_list
            set stat_view_stats_list $original_stat_view_stats_list
            set stat_views_list $original_stat_view_list
            
            set result [ixNetworkGetPortObjref $port]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port \
                        object reference associated to the $port port handle -\
                        [keylget result log]."
                return $returnList
            }
            set vport_objref [keylget result vport_objref]
            
            set eth_obj [ixNet getL $vport_objref/protocolStack ethernet]
            if {[llength $eth_obj]==0 || $eth_obj == [ixNet getNull]} {
                set eth_obj [ixNet getL $vport_objref/protocolStack atm]
            }
            if {[llength $eth_obj] > 0 && $eth_obj != [ixNet getNull]} {
                # get first ethernet that might have l2tp, fallback on first eth_obj
                set eth_tmp [lindex $eth_obj 0]
                foreach eth_elem $eth_obj {
                    set l2tp_ip_obj [ixNet getL $eth_elem ip]
                    set l2tp_obj [ixNet getL $l2tp_ip_obj l2tp]
                    if {[info exists l2tp_obj] && [llength $l2tp_obj] > 0 &&\
                            $l2tp_obj != [ixNet getNull]} {
                        set eth_tmp $eth_elem
                        break
                    }
                }
                set eth_obj $eth_tmp
                
                if {$ixn_version >= "5.60"} {
                    
                    set dhcpv6pd_view_name "DHCPv6Client"
                    foreach view [ixNet getList [ixNet getRoot]statistics statViewBrowser] {
                        set dhcp_view_name [ixNet getA $view -name]
                        if { $dhcp_view_name == "DHCPv6PD"} {
                            set dhcpv6pd_view_name "DHCPv6PD"
                            break
                        }
                    }
                    
                    set l2tp_ip_obj [ixNet getL $eth_obj ip]
                    set l2tp_obj [ixNet getL $l2tp_ip_obj l2tp]
                    if {[llength $l2tp_obj] > 0 && $l2tp_obj != [ixNet getNull]} {
                        # Append the DHCP* stats for DHCPv6 hosts behind l2tp feature
                        if {$dhcpv6pd_view_name != "DHCPv6PD"} {
                            set role [ixNet getAttribute [lindex [ixNet \
                            getList $vport_objref/protocolStack l2tpOptions] 0] -role]
                            if {$role eq "lac"} {
                                lappend stat_views_list "DHCPv6Client" "DHCP Hosts"
                                lappend stat_view_stats_list $stats_list_dhcpv6_client
                                lappend stat_view_arrays_list $stats_array_dhcpv6pd_client
                                lappend stat_view_stats_list $stats_list_dhcp_hosts
                                lappend stat_view_arrays_list $stats_array_dhcp_hosts
                            } else {
                                lappend stat_views_list "DHCPv6Server"
                                lappend stat_view_stats_list $stats_list_dhcpv6_server
                                lappend stat_view_arrays_list $stats_array_dhcpv6pd_server
                            }
                        } else {
                            lappend stat_views_list "DHCP Hosts" "DHCPv6PD"
                            lappend stat_view_stats_list $stats_list_dhcp_hosts
                            lappend stat_view_arrays_list $stats_array_dhcp_hosts
                        }
                    }
                }
            }
            set enableStatus [enableStatViewList $stat_views_list]
            if {[keylget enableStatus status] == $::FAILURE} {
                if {[string first "Unable to get stat views" [keylget enableStatus log]] != -1} {
                    foreach stat_view_name $stat_views_list \
                            stats_list $stat_view_stats_list \
                            stats_array $stat_view_arrays_list {
                        if {[info exists stats_hash]} {
                            unset stats_hash
                        }
                        
                        array set stats_hash $stats_array
                        
                        foreach stat $stats_list {
                            if {$port == [lindex $port_handle 0]} {
                                keylset returnList aggregate.$stats_hash($stat)    0
                            }
                            keylset returnList $port.aggregate.$stats_hash($stat)  0
                        }
                    }
                    # Get the port's role
                    # Get the port objref
                    set result [ixNetworkGetPortObjref $port]
                    if {[keylget result status] == $::FAILURE} {
                        if {![info exists handle]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Unable to find the port object\
                                    reference associated to the $port port handle -\
                                    [keylget result log]."
                            return $returnList
                        }
                    } else {
                        set port_objref [keylget result vport_objref]
                    }
                    # Get the role
                    set role [ixNet getAttribute [lindex [ixNet \
                            getList $port_objref/protocolStack l2tpOptions] 0] -role]
                    if {$role eq "lac"} {
                        set role "client"
                    } else {
                        set role "server"
                    }
                    if {$port == [lindex $port_handle 0]} {                        
                        keylset returnList aggregate.idle                 0
                        keylset returnList aggregate.connecting           "N/A"
                        keylset returnList aggregate.connect_success      0
                        keylset returnList aggregate.sessions_up          0
                        keylset returnList aggregate.tunnels_up           0
                        keylset returnList aggregate.success_setup_rate   0
                    }        
                    
                    keylset returnList $port.aggregate.idle               0
                    keylset returnList $port.aggregate.connecting         "N/A"
                    keylset returnList $port.aggregate.connect_success    0
                    keylset returnList $port.aggregate.sessions_up        0
                    keylset returnList $port.aggregate.tunnels_up         0
                    keylset returnList $port.aggregate.success_setup_rate 0
                    keylset returnList status $::SUCCESS
                    if {$index < [llength $port_handle]} {
                        continue
                    }
                    return $returnList
                } else {
                    return $enableStatus
                }
            }
            after 2000

            # Gather the statistics from the tables in the stat view browser
            foreach stat_view_name $stat_views_list \
                    stats_list $stat_view_stats_list \
                    stats_array $stat_view_arrays_list {
                array set ports [list]
                
                # An array is used for easily searching for a particular port
                # handle.
                # The value stored for each key has the following meaning:
                #    1 - the port has been found in the gathered stats
                #    0 - the port has not been found (yet) in the gathered stats
                set ports($port) 0
                    
                set returned_stats_list [ixNetworkGetStats \
                        $stat_view_name $stats_list]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to read the\
                            '$stat_view_name' stat view browser -\
                            [keylget returned_stats_list log]"
                    return $returnList
                }

                set found false
                set row_count [keylget returned_stats_list row_count]
                if {[info exists stats_hash]} {
                    unset stats_hash
                }
                array set stats_hash $stats_array
                array set rows_array [keylget returned_stats_list statistics]
                for {set i 1} {$i <= $row_count} {incr i} {
                    set row_name $rows_array($i) 
                    set match [regexp {(.+)/Card([0-9]{2})/Port([0-9]{2})} \
                            $row_name match_name hostname card_no port_no]
                    if {$match && [catch {set chassis_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                        set chassis_ip $hostname
                    }
                    if {$match && ($match_name == $row_name) && \
                            [info exists chassis_ip] && \
                            [info exists card_no] && \
                            [info exists port_no] } {
                        set chassis_no [ixNetworkGetChassisId $chassis_ip]
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to interpret the\
                                '$row_name' row name."
                        return $returnList
                    }
                    regsub {^0} $card_no "" card_no
                    regsub {^0} $port_no "" port_no
                    set handle $chassis_no/$card_no/$port_no
                    if {[info exists ports($handle)]} {
                        set ports($handle) 1
                        foreach stat $stats_list {
                            if {[info exists rows_array($i,$stat)] && \
                                    $rows_array($i,$stat) != ""} {
                                if {$handle == [lindex $port_handle 0]} {
                                    keylset returnList \
                                            aggregate.$stats_hash($stat) \
                                            $rows_array($i,$stat)
                                }
                                keylset returnList \
                                        $handle.aggregate.$stats_hash($stat) \
                                        $rows_array($i,$stat)
                            } else {
                                if {$handle == [lindex $port_handle 0]} {
                                    keylset returnList \
                                            aggregate.$stats_hash($stat) \
                                            "N/A"
                                }
                                keylset returnList \
                                        $handle.aggregate.$stats_hash($stat) \
                                        "N/A"
                            }
                        }
                    }
                }
            }
            # Return an error if any of the ports sent via the -port_handle 
            # attribute to this procedure has not been found.
            set not_found [list]
            foreach port [array names ports] {
                if {$ports($port) == 0} {
                    lappend not_found $port
                }
            }
            if {[llength $not_found] > 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "The '$not_found' port(s) couldn't be\
                        found among the ports from which statistics were\
                        gathered using the '$stat_view_name' stat view browser."
                return $returnList
            }
        }
        # Add composite stats
        foreach port $port_handle {
            # Get the port's role
            # Get the port objref
            set result [ixNetworkGetPortObjref $port]
            if {[keylget result status] == $::FAILURE} {
                if {![info exists handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the port object\
                            reference associated to the $port port handle -\
                            [keylget result log]."
                    return $returnList
                }
            } else {
                set port_objref [keylget result vport_objref]
            }
            # Get the role
            set role [ixNet getAttribute [lindex [ixNet \
                    getList $port_objref/protocolStack l2tpOptions] 0] -role]
            if {$role eq "lac"} {
                set role "client"
            } else {
                set role "server"
            }
            if {$port == [lindex $port_handle 0]} {
                set num_sessions [keylget returnList \
                        aggregate.num_sessions]
                set sessions_up [keylget returnList \
                        aggregate.${role}_interfaces_up]
                set tunnels_up [keylget returnList \
                        aggregate.${role}_tunnels_up]
                set success_setup_rate [keylget returnList \
                        aggregate.${role}_interfaces_setup_rate]
                set interfaces_in_ppp_negotiation [keylget returnList \
                        aggregate.${role}_interfaces_in_ppp_negotiation]
                set interfaces_in_pppoe_l2tp_negotiation [keylget returnList \
                        aggregate.interfaces_in_pppoe_l2tp_negotiation]
    
                if {[string is double $num_sessions] && [string is double $interfaces_in_ppp_negotiation] && \
                        [string is double $interfaces_in_pppoe_l2tp_negotiation] && [string is double $sessions_up]} {
                
                    keylset returnList aggregate.idle [expr \
                            $num_sessions \
                            - $interfaces_in_ppp_negotiation \
                            - $interfaces_in_pppoe_l2tp_negotiation \
                            - $sessions_up]
                } else {
                    keylset returnList aggregate.idle "N/A"
                }
                
                if {[string is double $interfaces_in_ppp_negotiation] && \
                        [string is double $interfaces_in_pppoe_l2tp_negotiation]} {
                 
                    keylset returnList aggregate.connecting [expr \
                            $interfaces_in_ppp_negotiation \
                            + $interfaces_in_pppoe_l2tp_negotiation]
                
                } else {
                     keylset returnList aggregate.connecting "N/A"
                }
                
                keylset returnList aggregate.connect_success $sessions_up
                keylset returnList aggregate.sessions_up $sessions_up
                keylset returnList aggregate.tunnels_up $tunnels_up
                keylset returnList aggregate.success_setup_rate \
                        $success_setup_rate
            }
            set num_sessions [keylget returnList \
                    $port.aggregate.num_sessions]
            set sessions_up [keylget returnList \
                    $port.aggregate.${role}_interfaces_up]
            set tunnels_up [keylget returnList \
                    $port.aggregate.${role}_tunnels_up]
            set success_setup_rate [keylget returnList \
                    $port.aggregate.${role}_interfaces_setup_rate]
            set interfaces_in_ppp_negotiation [keylget returnList \
                    $port.aggregate.${role}_interfaces_in_ppp_negotiation]
            set interfaces_in_pppoe_l2tp_negotiation [keylget returnList \
                    $port.aggregate.interfaces_in_pppoe_l2tp_negotiation]

            if {[string is double $num_sessions] && [string is double $interfaces_in_ppp_negotiation] && \
                        [string is double $interfaces_in_pppoe_l2tp_negotiation] && [string is double $sessions_up]} {

                keylset returnList $port.aggregate.idle [expr \
                        $num_sessions \
                        - $interfaces_in_ppp_negotiation \
                        - $interfaces_in_pppoe_l2tp_negotiation \
                        - $sessions_up]

            } else {
                keylset returnList $port.aggregate.idle "N/A"
            }
            
            if {[string is double $interfaces_in_ppp_negotiation] && \
                        [string is double $interfaces_in_pppoe_l2tp_negotiation]} {
             
                keylset returnList $port.aggregate.connecting [expr \
                        $interfaces_in_ppp_negotiation \
                        + $interfaces_in_pppoe_l2tp_negotiation]
            
            } else {
                keylset returnList $port.aggregate.connecting "N/A"
            }
            
            keylset returnList $port.aggregate.connect_success $sessions_up
            keylset returnList $port.aggregate.sessions_up $sessions_up
            keylset returnList $port.aggregate.tunnels_up $tunnels_up
            keylset returnList $port.aggregate.success_setup_rate \
                    $success_setup_rate
        }
    } elseif {$mode == "session" || $all_session_statistics == 1} {
        # Per session stats
        set stat_list_per_session [list                     \
            "Port Name"                                     \
            "Interface Identifier"                          \
            "Peer Call ID"                                  \
            "Peer Tunnel ID"                                \
            "Data NS"                                       \
            "Destination Port"                              \
            "Source Port"                                   \
            "Destination IP"                                \
            "Source IP"                                     \
            "Gateway IP"                                    \
            "Our Call ID"                                   \
            "Our Peer ID"                                   \
            "Our Cookie Length"                             \
            "Our Cookie"                                    \
            "ICRQ Tx"                                       \
            "ICRP Tx"                                       \
            "ICCN Tx"                                       \
            "CDN Tx"                                        \
            "ICRQ Rx"                                       \
            "ICRP Rx"                                       \
            "ICCN Rx"                                       \
            "CDN Rx"                                        \
            "PPP State"                                     \
            ]
        array set stats_array_per_session [list             \
            "Port Name"                                     \
                port_name                                   \
            "Interface Identifier"                          \
                interface_id                                \
            "Peer Call ID"                                  \
                peer_call_id                                \
            "Peer Tunnel ID"                                \
                tunnel_id                                   \
            "Data NS"                                       \
                data_ns                                     \
            "Destination Port"                              \
                destination_port                            \
            "Source Port"                                   \
                source_port                                 \
            "Destination IP"                                \
                destination_ip                              \
            "Source IP"                                     \
                source_ip                                   \
            "Gateway IP"                                    \
                gateway_ip                                  \
            "Our Call ID"                                   \
                call_id                                     \
            "Our Peer ID"                                   \
                peer_id                                     \
            "Our Cookie Length"                             \
                cookie_len                                  \
            "Our Cookie"                                    \
                cookie                                      \
            "ICRQ Tx"                                       \
                icrq_tx                                     \
            "ICRP Tx"                                       \
                icrp_tx                                     \
            "ICCN Tx"                                       \
                iccn_tx                                     \
            "CDN Tx"                                        \
                cdn_tx                                      \
            "ICRQ Rx"                                       \
                icrq_rx                                     \
            "ICRP Rx"                                       \
                icrp_rx                                     \
            "ICCN Rx"                                       \
                iccn_rx                                     \
            "CDN Rx"                                        \
                cdn_rx                                      \
            "PPP State"                                     \
                pppox_state                                 \
            ]

        array set stats_array_per_session_ixn [list                             \
            port_name                       "Port Name"                         \
            interface_id                    "Interface Identifier"              \
            peer_call_id                    "Peer Call ID"                      \
            tunnel_id                       "Peer Tunnel ID"                    \
            data_ns                         "Data NS"                           \
            destination_port                "Destination Port"                  \
            source_port                     "Source Port"                       \
            destination_ip                  "Destination IP"                    \
            source_ip                       "Source IP"                         \
            gateway_ip                      "Gateway IP"                        \
            call_id                         "Our Call ID"                       \
            peer_id                         "Our Peer ID"                       \
            cookie_len                      "Our Cookie Length"                 \
            cookie                          "Our Cookie"                        \
            icrq_tx                         "ICRQ Tx"                           \
            icrp_tx                         "ICRP Tx"                           \
            iccn_tx                         "ICCN Tx"                           \
            cdn_tx                          "CDN Tx"                            \
            icrq_rx                         "ICRQ Rx"                           \
            icrp_rx                         "ICRP Rx"                           \
            iccn_rx                         "ICCN Rx"                           \
            cdn_rx                          "CDN Rx"                            \
            pppox_state                     "PPP State"                         \
            auth_id                         "Authentication ID"                 \
            auth_password                   "Authentication Password"           \
            auth_protocol_rx                "Authentication Protocol Rx"        \
            auth_protocol_tx                "Authentication Protocol Tx"        \
            auth_total_rx                   "Authentication Total Rx"           \
            auth_total_tx                   "Authentication Total Tx"           \
            call_state                      "Call State"                        \
            chap_auth_role                  "CHAP Authentication Role"          \
            chap_auth_chal_rx               "CHAP Challenge Rx"                 \
            chap_auth_chal_tx               "CHAP Challenge Tx"                 \
            chap_auth_fail_rx               "CHAP Failure Rx"                   \
            chap_auth_fail_tx               "CHAP Failure Tx"                   \
            chap_auth_rsp_rx                "CHAP Response Rx"                  \
            chap_auth_rsp_tx                "CHAP Response Tx"                  \
            chap_auth_succ_rx               "CHAP Success Rx"                   \
            chap_auth_succ_tx               "CHAP Success Tx"                   \
            close_mode                      "PPP Close Mode"                    \
            code_rej_rx                     "LCP Code Reject Rx"                \
            code_rej_tx                     "LCP Code Reject Tx"                \
            echo_req_rx                     "LCP Echo Request Rx"               \
            echo_req_tx                     "LCP Echo Request Tx"               \
            echo_rsp_rx                     "LCP Echo Response Rx"              \
            echo_rsp_tx                     "LCP Echo Response Tx"              \
            dut_test_mode                   "DUT Test Mode"                     \
            ipcp_cfg_ack_rx                 "IPCP Config ACK Rx"                \
            ipcp_cfg_ack_tx                 "IPCP Config ACK Tx"                \
            ipcp_cfg_nak_rx                 "IPCP Config NAK Rx"                \
            ipcp_cfg_nak_tx                 "IPCP Config NAK Tx"                \
            ipcp_cfg_rej_rx                 "IPCP Config Reject Rx"             \
            ipcp_cfg_rej_tx                 "IPCP Config Reject Tx"             \
            ipcp_cfg_req_rx                 "IPCP Config Request Rx"            \
            ipcp_cfg_req_tx                 "IPCP Config Request Tx"            \
            ipcp_state                      "IPCP State"                        \
            ipv6cp_cfg_ack_rx               "IPv6CP Config ACK Rx"              \
            ipv6cp_cfg_ack_tx               "IPv6CP Config ACK Tx"              \
            ipv6cp_cfg_nak_rx               "IPv6CP Config NAK Rx"              \
            ipv6cp_cfg_nak_tx               "IPv6CP Config NAK Tx"              \
            ipv6cp_cfg_rej_rx               "IPv6CP Config Reject Rx"           \
            ipv6cp_cfg_rej_tx               "IPv6CP Config Reject Tx"           \
            ipv6cp_cfg_req_rx               "IPv6CP Config Request Rx"          \
            ipv6cp_cfg_req_tx               "IPv6CP Config Request Tx"          \
            ipv6cp_state                    "IPv6CP State"                      \
            ipv6cp_router_adv_rx            "IPv6CP Router Advertisement Rx"    \
            ipv6cp_router_adv_tx            "IPv6CP Router Advertisement Tx"    \
            ipv6_prefix_len                 "IPv6 Prefix Length"                \
            ipv6_addr                       "IPv6 Address"                      \
            lcp_cfg_ack_rx                  "LCP Config ACK Rx"                 \
            lcp_cfg_ack_tx                  "LCP Config ACK Tx"                 \
            lcp_cfg_nak_rx                  "LCP Config NAK Rx"                 \
            lcp_cfg_nak_tx                  "LCP Config NAK Tx"                 \
            lcp_cfg_rej_rx                  "LCP Config Reject Rx"              \
            lcp_cfg_rej_tx                  "LCP Config Reject Tx"              \
            lcp_cfg_req_rx                  "LCP Config Request Rx"             \
            lcp_cfg_req_tx                  "LCP Config Request Tx"             \
            lcp_protocol_rej_rx             "LCP Protocol Reject Rx"            \
            lcp_protocol_rej_tx             "LCP Protocol Reject Tx"            \
            lcp_total_msg_rx                "LCP Total Rx"                      \
            lcp_total_msg_tx                "LCP Total Tx"                      \
            local_ip_addr                   "Local IP Address"                  \
            local_ipv6_iid                  "Local IPv6 IID"                    \
            malformed_ppp_frames_rejected   "Malformed PPP Frames Rejected"     \
            malformed_ppp_frames_used       "Malformed PPP Frames Used"         \
            mru                             "MRU"                               \
            mtu                             "MTU"                               \
            magic_no_negotiated             "Magic Number Negotiated"           \
            magic_no_rx                     "Magic Number Rx"                   \
            magic_no_tx                     "Magic Number Tx"                   \
            ncp_total_msg_rx                "NCP Total Rx"                      \
            ncp_total_msg_tx                "NCP Total Tx"                      \
            negotiation_start_ms            "Negotiation Start Time \[ms\]"     \
            negotiation_end_ms              "Negotiation End Time \[ms\]"       \
            pap_auth_ack_rx                 "PAP Authentication ACK Rx"         \
            pap_auth_ack_tx                 "PAP Authentication ACK Tx"         \
            pap_auth_nak_rx                 "PAP Authentication NAK Rx"         \
            pap_auth_nak_tx                 "PAP Authentication NAK Tx"         \
            pap_auth_req_rx                 "PAP Authentication Request Rx"     \
            pap_auth_req_tx                 "PAP Authentication Request Tx"     \
            peer_ipv6_iid                   "Peer IPv6 IID"                     \
            ppp_total_bytes_rx              "PPP Total Bytes Rx"                \
            ppp_total_bytes_tx              "PPP Total Bytes Tx"                \
            remote_ip_addr                  "Remote IP Address"                 \
            loopback_detected               "Loopback Detected"                 \
            term_ack_rx                     "LCP Terminate ACK Rx"              \
            term_ack_tx                     "LCP Terminate ACK Tx"              \
            term_req_rx                     "LCP Terminate Request Rx"          \
            term_req_tx                     "LCP Terminate Request Tx"          \
            tunnel_state                    "Tunnel State"                      \
            ]
            
        set latest [::ixia::540IsLatestVersion]
        
        if {$latest} {
            set l2tp_stat_view_list ""
            if {[info exists port_handle]&&![info exists handle]} {
                foreach port $port_handle {
                    set build_name "SessionView-[regsub -all "/" $port "_"]"
                    set drill_result [::ixia::CreateAndDrilldownViews $port port_handle $build_name "l2tp"]
                    if {[keylget drill_result status] == $::FAILURE} {
                        return $drill_result
                    }
                    lappend l2tp_stat_view_list $build_name
                }
            }
            if {[info exists handle]} {
                foreach range_handle $handle {
                    # set proto_regex - this matches the protocol stack filter 
                    # for the custom view we are about to create
                    set proto_regex [ixNet getA $range_handle/l2tpRange -name]
                    set build_name "SessionView-[string trim [string range $range_handle [expr [string first "/range:" $range_handle] + 7] end] "\"\\"]"
                    set drill_result [::ixia::CreateAndDrilldownViews $range_handle handle $build_name "l2tp" $proto_regex]
                    if {[keylget drill_result status] == $::FAILURE} {
                        return $drill_result
                    }
                    lappend l2tp_stat_view_list $build_name
                }
            }
            
            foreach build_name $l2tp_stat_view_list {
                set returned_stats_list [::ixia::540GetStatView $build_name [array names stats_array_per_session]]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to retrieve '$build_name' stat view."
                    return $returnList
                }
                foreach port $port_handle {
                    set found false
                    
                    set pageCount [keylget returned_stats_list page]
                    set rowCount  [keylget returned_stats_list row]
                    array set rowsArray [keylget returned_stats_list rows]
                    
                    # Populate statistics
                    for {set i 1} {$i < $pageCount} {incr i} {
                        for {set j 1} {$j < $rowCount} {incr j} {
                            if {![info exists rowsArray($i,$j)]} { continue }
                            set rowName $rowsArray($i,$j)
                            
                            set matched [regexp {(.+)/Card([0-9]+)/Port([0-9]+) - ([0-9]+)$} $rowName matched_str hostname cd pt session_no]
                            if {$matched && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                                set ch_ip $hostname
                            }
                            
                            if {!$matched} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to get 'Port Statistics',\
                                        because port number could not be identified. $rowName did not\
                                        match the HLT port format ChassisIP/card/port. This can occur if\
                                        the test was not configured with HLT."
                                return $returnList
                            }
                            
                            if {$matched && ([string first $matched_str $rowName] == 0) && \
                                    [info exists ch_ip] && [info exists cd] && [info exists pt] } {
                                set ch [ixNetworkGetChassisId $ch_ip]
                            }
                            set cd [string trimleft $cd 0]
                            set pt [string trimleft $pt 0]
                            set statPort $ch/$cd/$pt
                            
                            if {"$port" eq "$statPort"} {
                                set found true
                                foreach stat [array names stats_array_per_session_ixn] {
                                    set ixn_stat $stats_array_per_session_ixn($stat)
                                    if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                        keylset returnList session.$statPort/${session_no}.$stat $rowsArray($i,$j,$ixn_stat)
                                    } else {
                                        keylset returnList session.$statPort/${session_no}.$stat "N/A"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            set returned_stats_list [ixNetworkGetStats \
                    "L2TP Per Session" $stat_list_per_session]
            if {[keylget returned_stats_list status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to get 'L2TP Per Session' stat view."
                return $returnList
            }
            foreach port $port_handle {
                set found false
                set row_count [keylget returned_stats_list row_count]
                array set rows_array [keylget returned_stats_list statistics]
        
                for {set i 1} {$i <= $row_count} {incr i} {
                    set row_name $rows_array($i)
                    set match [regexp {(.+)/Card(\d+)/Port(\d+) - (\d+)$} \
                            $row_name match_name hostname card_no port_no session_no]
                    if {$match && [catch {set chassis_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                        set chassis_ip $hostname
                    }
                    if {$match && ($match_name == $row_name) && \
                            [info exists chassis_ip] && [info exists card_no] && \
                            [info exists port_no] && [info exists session_no]} {
                        set chassis_no [ixia::ixNetworkGetChassisId $chassis_ip]
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to interpret the '$row_name'\
                                row name."
                        return $returnList
                    }
                    regsub {^0} $card_no "" card_no
                    regsub {^0} $port_no "" port_no
        
                    if {"$port" eq "$chassis_no/$card_no/$port_no"} {
                        set found true
                        foreach stat $stat_list_per_session {
                            if {[info exists rows_array($i,$stat)] && \
                                    $rows_array($i,$stat) != ""} {
                                keylset returnList session.${session_no}.$stats_array_per_session($stat) \
                                        $rows_array($i,$stat)
                            } else {
                                keylset returnList session.${session_no}.$stats_array_per_session($stat) "N/A"
                            }
                        }
                        #break - don't break! We need stats from every session available on this port.
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
    } ;# Session block ends ----------------------------------------------------

    if {$mode == "session_dhcpv6pd" || $mode == "session_dhcp_hosts" || $all_session_statistics == 1} {
        array set dhcpv6_server_per_session_array [list                                 \
            "Port Name"                         port_name                               \
            "Lease Name"                        dhcpv6pd_lease_name                     \
            "Offer Count"                       dhcpv6pd_offer_count                    \
            "Bind Count"                        dhcpv6pd_bind_count                     \
            "Bind Rapid Commit Count"           dhcpv6pd_bind_rapid_commit_count        \
            "Renew Count"                       dhcpv6pd_renew_count                    \
            "Release Count"                     dhcpv6pd_release_count                  \
            "Information-Requests Received"     dhcpv6pd_information_request_received   \
            "Replies Sent"                      dhcpv6pd_replies_sent                   \
            "Lease State"                       dhcpv6pd_lease_state                    \
            "Lease Address"                     dhcpv6pd_lease_address                  \
            "Valid Time"                        dhcpv6pd_valid_time                     \
            "Prefered Time"                     dhcpv6pd_prefered_time                  \
            "Renew Time"                        dhcpv6pd_renew_time                     \
            "Rebind Time"                       dhcpv6pd_rebind_time                    \
            "Client ID"                         dhcpv6pd_client_id                      \
            "Remote ID"                         dhcpv6pd_remote_id                      \
            ]
            
        array set dhcpv6_client_per_session_array [list                                 \
            "Port Name"                         port_name                               \
            "Session Name"                      dhcpv6pd_session_name                   \
            "Solicits Sent"                     dhcpv6pd_solicits_sent                  \
            "Advertisements Received"           dhcpv6pd_advertisements_received        \
            "Advertisements Ignored"            dhcpv6pd_advertisements_ignored         \
            "Requests Sent"                     dhcpv6pd_requests_sent                  \
            "Replies Received"                  dhcpv6pd_replies_received               \
            "Renews Sent"                       dhcpv6pd_renews_sent                    \
            "Rebinds Sent"                      dhcpv6pd_rebinds_sent                   \
            "Releases Sent"                     dhcpv6pd_releases_sent                  \
            "IP Prefix"                         dhcpv6pd_ip_prefix                      \
            "Gateway Address"                   dhcpv6pd_gateway_address                \
            "DNS Server List"                   dhcpv6pd_dns_server_list                \
            "Prefix Lease Time"                 dhcpv6pd_prefix_lease_time              \
            "Information Requests Sent"         dhcpv6pd_onformation_requests_sent      \
            "DNS Search List"                   dhcpv6pd_dns_search_list                \
            "Solicits w/ Rapid Commit Sent"     dhcpv6pd_solicits_rapid_commit_sent     \
            "Replies w/ Rapid Commit Received"  dhcpv6pd_replies_rapid_commit_received  \
            "Lease w/ Rapid Commit"             dhcpv6pd_lease_rapid_commit             \
            ]
        
        array set dhcp_hosts_per_session_array [list                                    \
            "Port Name"                         port_name                               \
            "Interface Identifier"              dhcpv6pd_interface_identifier           \
            "Range Identifier"                  dhcpv6pd_range_identifier               \
            "IPv6 Address"                      dhcpv6pd_ipv6_address                   \
            "Prefix Length"                     dhcpv6pd_prefix_length                  \
            "Status"                            dhcpv6pd_status                         \
            ]
        if {[info exists port_handle]&&![info exists handle]} {
            foreach port $port_handle {
                # check if the port is client(LAC) or server (LNS)
                set result [ixNetworkGetPortObjref $port]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the port \
                            object reference associated to the $port port handle -\
                            [keylget result log]."
                    return $returnList
                }
                set vport_objref [keylget result vport_objref]
                
                set eth_obj [ixNet getL $vport_objref/protocolStack ethernet]
                set l2tp_port_role ""
                if {[llength $eth_obj] > 0 && $eth_obj != [ixNet getNull]} {
                    foreach eth_elem $eth_obj {
                        set l2tp_ip_obj [ixNet getL $eth_elem ip]
                        set l2tp_obj [ixNet getL $l2tp_ip_obj l2tp]
                        if {[info exists l2tp_obj] && [llength $l2tp_obj] > 0 &&\
                                $l2tp_obj != [ixNet getNull]} {
                            set l2tp_elem [ixNet getL $l2tp_obj dhcpv6Client]
                            set l2tp_port_role lac
                            if {[llength $l2tp_elem]>0 && $l2tp_elem!=[ixNet getNull]} {
                                set l2tp_port_role lac
                                break
                            } else {
                                set l2tp_elem [ixNet getL $l2tp_obj dhcpv6Server]
                                if {[llength $l2tp_elem]>0 && $l2tp_elem!=[ixNet getNull]} {
                                    set l2tp_port_role lns
                                    break
                                }
                            }
                        }
                    }
                }
                if {$l2tp_port_role == "lac"} {
                    if {$mode == "session_dhcpv6pd"} {
                        set drill_down_view_type "dhcpv6PdClient"
                    } else {
                        set drill_down_view_type "dhcpHosts"
                    }
                } elseif {$l2tp_port_role == "lns"} {
                    if {$mode == "session_dhcp_hosts"} {
                        # host statistics are available only on client (lac) port
                        continue
                    }
                    set drill_down_view_type "dhcpv6Server"
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Port handle $port has no dhcpv6Pd configured."
                    return $returnList
                }
                set build_name "SessionView-[regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]-[regsub -all "/" $port "_"]"
                set drill_result [::ixia::CreateAndDrilldownViews $port port_handle $build_name $drill_down_view_type]
                if {[keylget drill_result status] == $::FAILURE} {
                    return $drill_result
                }
                # Get the session statistics for this port
                if {$l2tp_port_role == "lac"} {
                    if {$mode == "session_dhcpv6pd"} {
                        set returned_stats_list [::ixia::540GetStatView $build_name [array names dhcpv6_client_per_session_array]]
                        set stats_array_per_session_dhcp dhcpv6_client_per_session_array
                    } else {
                        set returned_stats_list [::ixia::540GetStatView $build_name [array names dhcp_hosts_per_session_array]]
                        set stats_array_per_session_dhcp dhcp_hosts_per_session_array
                    }
                } else {
                    set returned_stats_list [::ixia::540GetStatView $build_name [array names dhcpv6_server_per_session_array]]
                    set stats_array_per_session_dhcp dhcpv6_server_per_session_array
                }
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to retrieve '$build_name' stat view."
                    return $returnList
                }
                
                # Populate keys
                set found false
                set session_key_type [string tolower [regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]]
                set pageCount [keylget returned_stats_list page]
                set rowCount  [keylget returned_stats_list row]
                array set rowsArray [keylget returned_stats_list rows]
                
                # Populate statistics
                for {set i 1} {$i < $pageCount} {incr i} {
                    for {set j 1} {$j < $rowCount} {incr j} {
                        if {![info exists rowsArray($i,$j)]} { continue }
                        set rowName $rowsArray($i,$j)
                        
                        set matched [regexp {(.+)/Card([0-9]+)/Port([0-9]+) - ([0-9]+)$} $rowName matched_str hostname cd pt session_no]
                        if {$matched && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                            set ch_ip $hostname
                        }
                        
                        if {!$matched} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to get 'Port Statistics',\
                                    because port number could not be identified. $rowName did not\
                                    match the HLT port format ChassisIP/card/port. This can occur if\
                                    the test was not configured with HLT."
                            return $returnList
                        }
                        
                        if {$matched && ([string first $matched_str $rowName] == 0) && \
                                [info exists ch_ip] && [info exists cd] && [info exists pt] } {
                            set ch [ixNetworkGetChassisId $ch_ip]
                        }
                        set cd [string trimleft $cd 0]
                        set pt [string trimleft $pt 0]
                        set statPort $ch/$cd/$pt
                        
                        if {"$port" eq "$statPort"} {
                            set found true
                            foreach {stat hlt_val} [array get $stats_array_per_session_dhcp] {
                                set ixn_stat $stat
                                if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                    keylset returnList session.${session_key_type}.$statPort/${session_no}.$hlt_val $rowsArray($i,$j,$ixn_stat)
                                } else {
                                    keylset returnList session.${session_key_type}.$statPort/${session_no}.$hlt_val "N/A"
                                }
                            }
                        }
                    }
                }
                if {$all_session_statistics == 1} {
                    # retrieve all statistics, -mode is session_all
                    # include dhcpv6PdClient if port role is LAC
                    if {$l2tp_port_role == "lac"} {
                        set drill_down_view_type "dhcpv6PdClient"
                        set session_key_type [string tolower [regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]]
                        set build_name "SessionView-[regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]-[regsub -all "/" $port "_"]"
                        set drill_result [::ixia::CreateAndDrilldownViews $port port_handle $build_name $drill_down_view_type]
                        set returned_stats_list [::ixia::540GetStatView $build_name [array names dhcpv6_client_per_session_array]]
                        if {[keylget returned_stats_list status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to retrieve '$build_name' stat view."
                            return $returnList
                        }
                        set stats_array_per_session_dhcp dhcpv6_client_per_session_array
                        set pageCount [keylget returned_stats_list page]
                        set rowCount  [keylget returned_stats_list row]
                        array set rowsArray [keylget returned_stats_list rows]
                        set found false
                        for {set i 1} {$i < $pageCount} {incr i} {
                            for {set j 1} {$j < $rowCount} {incr j} {
                                if {![info exists rowsArray($i,$j)]} { continue }
                                set rowName $rowsArray($i,$j)
                                set matched [regexp {(.+)/Card([0-9]+)/Port([0-9]+) - ([0-9]+)$} $rowName matched_str hostname cd pt session_no]
                                if {$matched && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                                    set ch_ip $hostname
                                }
                                if {!$matched} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to get 'Port Statistics',\
                                            because port number could not be identified. $rowName did not\
                                            match the HLT port format ChassisIP/card/port. This can occur if\
                                            the test was not configured with HLT."
                                    return $returnList
                                }
                                if {$matched && ([string first $matched_str $rowName] == 0) && \
                                        [info exists ch_ip] && [info exists cd] && [info exists pt] } {
                                    set ch [ixNetworkGetChassisId $ch_ip]
                                }
                                set cd [string trimleft $cd 0]
                                set pt [string trimleft $pt 0]
                                set statPort $ch/$cd/$pt
                                if {"$port" eq "$statPort"} {
                                    set found true
                                    foreach {stat hlt_val} [array get $stats_array_per_session_dhcp] {
                                        set ixn_stat $stat
                                        if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                            keylset returnList session.${session_key_type}.$statPort/${session_no}.$hlt_val $rowsArray($i,$j,$ixn_stat)
                                        } else {
                                            keylset returnList session.${session_key_type}.$statPort/${session_no}.$hlt_val "N/A"
                                        }
                                    }
                                }
                            }
                        }
                    }
                } ;# End session_all mode
            } ;# End foreach port
        } ;# End port_handle
        if {[info exists handle]} {
            foreach small_handle $handle {
                set result [regexp {::ixNet::OBJ-/vport:\d+} $small_handle vport_objref ]
                if {$result!=1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the port \
                            object reference associated to the $small_handle handle."
                    return $returnList
                }
                set eth_obj [ixNet getL $vport_objref/protocolStack ethernet]
                set l2tp_port_role ""
                if {[llength $eth_obj] > 0 && $eth_obj != [ixNet getNull]} {
                    foreach eth_elem $eth_obj {
                        set l2tp_ip_obj [ixNet getL $eth_elem ip]
                        set l2tp_obj [ixNet getL $l2tp_ip_obj l2tp]
                        if {([llength $l2tp_obj] == 0) || ($l2tp_obj == [ixNet getNull])} {
                            set l2tp_obj [ixNet getL $l2tp_ip_obj l2tpEndpoint]
                        }
                        if {[info exists l2tp_obj] && [llength $l2tp_obj] > 0 && $l2tp_obj != [ixNet getNull]} {
                            set l2tp_elem [ixNet getL $l2tp_obj dhcpv6Client]
                            set l2tp_port_role lac
                            if {[llength $l2tp_elem]>0 && $l2tp_elem!=[ixNet getNull]} {
                                set l2tp_port_role lac
                                break
                            } else {
                                set l2tp_elem [ixNet getL $l2tp_obj dhcpv6Server]
                                if {[llength $l2tp_elem]>0 && $l2tp_elem!=[ixNet getNull]} {
                                    set l2tp_port_role lns
                                    break
                                }
                            }
                        }
                    }
                }
                if {$l2tp_port_role == "lac"} {
                    if {$mode == "session_dhcpv6pd"} {
                        set drill_down_view_type "dhcpv6PdClient"
                    } else {
                        set drill_down_view_type "dhcpHosts"
                    }
                } elseif {$l2tp_port_role == "lns"} {
                    if {$mode == "session_dhcp_hosts"} {
                        # host statistics are available only on client (lac) port
                        continue
                    }
                    set drill_down_view_type "dhcpv6Server"
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$small_handle has no dhcpv6Pd configured."
                    return $returnList
                }
                set proto_regex [ixNet getA $small_handle/${drill_down_view_type}Range:1 -name]
                set build_name "SessionView-[regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]-[string trim [string range $small_handle [expr [string first "/range:" $small_handle] + 7] end] "\"\\"]"
                set drill_result [::ixia::CreateAndDrilldownViews $small_handle handle $build_name $drill_down_view_type $proto_regex]
                if {[keylget drill_result status] == $::FAILURE} {
                    return $drill_result
                }
                if {$l2tp_port_role == "lac"} {
                    if {$mode == "session_dhcpv6pd"} {
                        set returned_stats_list [::ixia::540GetStatView $build_name [array names dhcpv6_client_per_session_array]]
                        set stats_array_per_session_dhcp dhcpv6_client_per_session_array
                    } else {
                        set returned_stats_list [::ixia::540GetStatView $build_name [array names dhcp_hosts_per_session_array]]
                        set stats_array_per_session_dhcp dhcp_hosts_per_session_array
                    }
                } else {
                    set returned_stats_list [::ixia::540GetStatView $build_name [array names dhcpv6_server_per_session_array]]
                    set stats_array_per_session_dhcp dhcpv6_server_per_session_array
                }
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to retrieve '$build_name' stat view."
                    return $returnList
                }
                
                # Populate keys
                set session_key_type [string tolower [regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]]
                set pageCount [keylget returned_stats_list page]
                set rowCount  [keylget returned_stats_list row]
                array set rowsArray [keylget returned_stats_list rows]
                # Populate statistics
                for {set i 1} {$i < $pageCount} {incr i} {
                    for {set j 1} {$j < $rowCount} {incr j} {
                        if {![info exists rowsArray($i,$j)]} { continue }
                        set rowName $rowsArray($i,$j)
                        
                        set matched [regexp {(.+)/Card([0-9]+)/Port([0-9]+) - ([0-9]+)$} $rowName matched_str hostname cd pt session_no]
                        if {$matched && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                            set ch_ip $hostname
                        }
                        
                        if {!$matched} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to get 'Port Statistics',\
                                    because port number could not be identified. $rowName did not\
                                    match the HLT port format ChassisIP/card/port. This can occur if\
                                    the test was not configured with HLT."
                            return $returnList
                        }
                        
                        if {$matched && ([string first $matched_str $rowName] == 0) && \
                                [info exists ch_ip] && [info exists cd] && [info exists pt] } {
                            set ch [ixNetworkGetChassisId $ch_ip]
                        }
                        set cd [string trimleft $cd 0]
                        set pt [string trimleft $pt 0]
                        set statPort $ch/$cd/$pt
                        
                        foreach {stat hlt_val} [array get $stats_array_per_session_dhcp] {
                            set ixn_stat $stat
                            if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                keylset returnList session.${session_key_type}.$statPort/${session_no}.$hlt_val $rowsArray($i,$j,$ixn_stat)
                            } else {
                                keylset returnList session.${session_key_type}.$statPort/${session_no}.$hlt_val "N/A"
                            }
                        }
                    }
                }
                if {$all_session_statistics == 1} {
                    # retrieve all statistics, -mode is session_all
                    # include dhcpv6PdClient if port role is LAC
                    if {$l2tp_port_role == "lac"} {
                        set drill_down_view_type "dhcpv6PdClient"
                        set session_key_type [string tolower [regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]]
                        set build_name "SessionView-[regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]-[regsub -all "/" $port "_"]"
                        set proto_regex [ixNet getA $small_handle/${drill_down_view_type}Range:1 -name]
                        set drill_result [::ixia::CreateAndDrilldownViews $small_handle handle $build_name $drill_down_view_type $proto_regex]
                        set returned_stats_list [::ixia::540GetStatView $build_name [array names dhcpv6_client_per_session_array]]
                        if {[keylget returned_stats_list status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to retrieve '$build_name' stat view."
                            return $returnList
                        }
                        set stats_array_per_session_dhcp dhcpv6_client_per_session_array
                        set pageCount [keylget returned_stats_list page]
                        set rowCount  [keylget returned_stats_list row]
                        array set rowsArray [keylget returned_stats_list rows]
                        for {set i 1} {$i < $pageCount} {incr i} {
                            for {set j 1} {$j < $rowCount} {incr j} {
                                if {![info exists rowsArray($i,$j)]} { continue }
                                set rowName $rowsArray($i,$j)
                                set matched [regexp {(.+)/Card([0-9]+)/Port([0-9]+) - ([0-9]+)$} $rowName matched_str hostname cd pt session_no]
                                
                                if {$matched && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                                    set ch_ip $hostname
                                }
                                
                                if {!$matched} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to get 'Port Statistics',\
                                            because port number could not be identified. $rowName did not\
                                            match the HLT port format ChassisIP/card/port. This can occur if\
                                            the test was not configured with HLT."
                                    return $returnList
                                }
                                if {$matched && ([string first $matched_str $rowName] == 0) && \
                                        [info exists ch_ip] && [info exists cd] && [info exists pt] } {
                                    set ch [ixNetworkGetChassisId $ch_ip]
                                }
                                set cd [string trimleft $cd 0]
                                set pt [string trimleft $pt 0]
                                set statPort $ch/$cd/$pt
                                foreach {stat hlt_val} [array get $stats_array_per_session_dhcp] {
                                    set ixn_stat $stat
                                    if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                        keylset returnList session.${session_key_type}.$statPort/${session_no}.$hlt_val $rowsArray($i,$j,$ixn_stat)
                                    } else {
                                        keylset returnList session.${session_key_type}.$statPort/${session_no}.$hlt_val "N/A"
                                    }
                                }
                            }
                        }
                    }
                } ;# End session_all mode
            }
        } ;# End handle
    }

    keylset returnList status $::SUCCESS
    return $returnList
}
