proc ::ixia::ixnetwork_pppox_config { args man_args opt_args} {
    variable truth
    keylset returnList status $::SUCCESS
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
                -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    if {$mode == "add"} {
        set man_args2 [list port_handle protocol encap num_sessions]
        foreach man_arg $man_args2 {
            if {![info exists $man_arg]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : \
                        Missing mandatory parameter -$man_arg."
                return $returnList
            }
        }
    }
    
    foreach tmp_param {dhcp6_global_teardown_rate_increment dhcp6_global_setup_rate_increment} {
        if {[info exists $tmp_param]} {
            if {![regexp {^[0-9]*$} [set $tmp_param]] || \
                    ([set $tmp_param] < -10000) || ([set $tmp_param] > 100000)} {
                
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid value '[set $tmp_param]' for parameter\
                        '-$tmp_param'. Accepted values are numeric in the range\
                        (-10000 100000)"
                return $returnList
            }
        }
    }
    
    # Check to see if a connection to the IxNetwork TCL server already exists.
    # If it doesn't, establish it.
    set return_status [checkIxNetwork]
    if {[keylget return_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to \
                IxNetwork [keylget return_status log]"
        return $returnList
    }
    
    if {[catch {set ::ixia::ixnetworkVersion} ixn_version]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get IxNetwork version - $ixn_version.\
                Possible causes: not connected to IxNetwork Tcl Server."
        return $returnList
    }
    
    if {![regexp {(^\d+)(\.)(\d+)} $ixn_version {} ixn_version_major {} ixn_version_minor]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get IxNetwork version major and minor - $ixn_version."
        return $returnList
    }
    
    set ixn_version ${ixn_version_major}.${ixn_version_minor}
    
    # Add port
    if {$mode == "add"} {
        set return_status [ixNetworkPortAdd $port_handle {} force]
        if {[keylget return_status status] != $::SUCCESS} {
            return $return_status
        }

        set result [ixNetworkGetPortObjref $port_handle]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName :Unable to find the port \
                    object reference associated to the $port_handle port handle -\
                    [keylget result log]."
            return $returnList
        } else {
            set port_handle [keylget result vport_objref]/protocolStack
        }
    }
    
    set pppox_range_args [list max_ipcp_req service_name ipv6_pool_prefix_len \
            intermediate_agent domain_group_map ppp_local_ip max_padi_req     \
            echo_req_interval ipv6_pool_prefix                                \
            ipv6_pool_addr_prefix_len password config_req_timeout             \
            ip_cp local_magic padi_include_tag ac_name padr_req_timeout       \
            agent_circuit_id term_req_timeout max_terminate_req ac_select_list\
            agent_remote_id auth_mode ppp_local_iid auth_req_timeout          \
            ppp_peer_iid username redial ipcp_req_timeout service_type        \
            pado_include_tag ppp_peer_ip padi_req_timeout max_padr_req        \
            echo_rsp ppp_local_ip_step padr_include_tag redial_max            \
            ppp_peer_ip_step pads_include_tag echo_req max_auth_req           \
            max_configure_req redial_timeout ac_select_mode                   \
            mode username_wildcard password_wildcard wildcard_pound_end       \
            wildcard_pound_start wildcard_question_start wildcard_question_end\
            handle ac_select_list port_handle num_sessions port_role          \
            enable_server_signal_loop_id enable_client_signal_loop_id         \
            enable_server_signal_loop_char enable_client_signal_loop_char     \
            actual_rate_upstream actual_rate_downstream max_payload           \
            enable_server_signal_iwf enable_client_signal_iwf                 \
            enable_server_signal_loop_encap enable_client_signal_loop_encap   \
            data_link intermediate_agent_encap1 intermediate_agent_encap2     \
            enable_max_payload enable_mru_negotiation desired_mru_rate        \
            ]

    array set mac_options [list                         \
            mac_addr            mac                     \
            mac_addr_step       incrementBy             \
            num_sessions        count
            ]

    set overrideGlobalRateControls true
    array set pppox_options [list                       \
            attempt_rate        setupRateInitial        \
            disconnect_rate     teardownRateInitial     \
            max_outstanding     [list maxOutstandingReleases \
                                maxOutstandingRequests] \
            ]

    array set vlan_range [list                          \
            qinq_incr_mode      idIncrMode              \
            vlan_id             firstId                 \
            vlan_id_count       uniqueCount             \
            vlan_id_step        increment               \
            vlan_id_outer       innerFirstId            \
            vlan_id_outer_count innerUniqueCount        \
            vlan_id_outer_step  innerIncrement          \
            vlan_user_priority  priority                \
            address_per_vlan    incrementStep           \
            ]

    if {[info exists encap] && $encap == "ethernet_ii_qinq"} {
        array set vlan_range [list                          \
            qinq_incr_mode      		idIncrMode              \
            vlan_id_outer       		firstId                 \
            vlan_id_outer_count 		uniqueCount             \
            vlan_id_outer_step  		increment               \
            vlan_id             		innerFirstId            \
            vlan_id_count       		innerUniqueCount        \
            vlan_id_step        		innerIncrement          \
            vlan_user_priority  		innerPriority           \
            vlan_user_priority_outer 	priority 				\
            address_per_vlan    		incrementStep           \
            address_per_svlan   		innerIncrementStep      \
            ]
    }

    array set pvc_range [list                           \
            pvc_incr_mode   incrementMode               \
            vci             vciFirstId                  \
            vci_count       vciUniqueCount              \
            vci_step        vciIncrement                \
            vpi             vpiFirstId                  \
            vpi_count       vpiUniqueCount              \
            vpi_step        vpiIncrement                \
            addr_count_per_vci  vciIncrementStep        \
            addr_count_per_vpi  vpiIncrementStep        \
            ]

    if {$mode == "add"} {
        if {$protocol == "pppoe"} {
            set stack_type ethernet
        } else {
            set stack_type atm
        }
        
        if {[info exists dhcpv6_hosts_enable] && $dhcpv6_hosts_enable} {
            
            if {$ixn_version < "5.50"} {
                keylset returnList status $::FAILURE
                keylset returnList log "The dhcpv6_hosts_enable feature is valid only\
                        when IxNetwork version is 5.50 or higher. Current version is $ixn_version."
                return $returnList
            }
            
            set ret_code [ixNetworkValidateSMPlugins $port_handle $stack_type "pppoxEndpoint"]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            if {[keylget ret_code summary] == 3} {
                # stack_type exists with the plugin specified in plugin_filter
                keylset returnList status $::FAILURE
                keylset returnList log "Existing PPPoX configuration was detected on port $port_handle.\
                        Configurations with -dhcpv6_hosts_enable '1' cannot be done on the same port."
                return $returnList
            }
            
            set pppox_result [::ixia::ixnetwork_dhcpv6_config]
            if {[keylget pppox_result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to add pppox support to the\
                        protocol stack of port - [keylget pppox_result log]."
                return $returnList
            }
        } else {
            
            if {$ixn_version >= "5.50"} {
                
                set ret_code [ixNetworkValidateSMPlugins $port_handle $stack_type "pppox"]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                if {[keylget ret_code summary] == 3} {
                    # stack_type exists with the plugin specified in plugin_filter
                    keylset returnList status $::FAILURE
                    keylset returnList log "Existing 'DHCPv6 Hosts behind PPP-CPE' configuration\
                            was detected on port $port_handle.\
                            Configurations with -dhcpv6_hosts_enable '0' cannot be done on the same port."
                    return $returnList
                }
            }
            
            set result [ixNetworkGetSMPlugin $port_handle $stack_type "pppoxEndpoint"]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
            
            set node_objref [keylget result ret_val]
        }
        
        set result [::ixia::ixNetworkNodeAdd \
                $node_objref     \
                range            \
                {}               \
                -commit          \
                ]
        if {[keylget result status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [keylget result log]"
            ::ixia::ixnetwork_pppox_rollback $node_objref $mode
            return $returnList
        }
        set handle [keylget result node_objref]
        
    } elseif {($mode == "modify") || ($mode == "remove")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : \
                    -handle parameter missing when -mode is $mode."
            return $returnList
        } else {
            if {[ixNet exists $handle] == "false" || [ixNet exists $handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : \
                        invalid or incorect -handle."
                return $returnList
            }
        }
        
        if {$mode == "remove"} {
            if {[regexp {pppoxEndpoint} $handle]} {
                set dhcpv6_hosts_enable 0
            } else {
                set dhcpv6_hosts_enable 1
            }
            
            if {!$dhcpv6_hosts_enable} {
                # Get the "pppoxEndpoint" parent object from the "range" child object
                set pppoxEndpointObj ""
                foreach obj [split $handle /] {
                    append pppoxEndpointObj "$obj"
                    if {[regexp -- {pppoxEndpoint} $obj]} {
                        break
                    }
                    append pppoxEndpointObj "/"
                }
                
                # First remove range object
                debug "ixNet remove $handle"
                if {[catch {ixNet remove $handle} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            failed to remove -handle $handle.\n$err"
                    return $returnList
                }
                
                if {[catch {ixNet commit} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            failed to remove -handle $handle.\n$err"
                    return $returnList
                }
                
                # If there are no more range objects under pppox endpoint object
                # remove pppox endpoint too
                set pppox_endpoint_ranges [::ixia::ixNetworkNodeGetList $pppoxEndpointObj range]
                if {$pppox_endpoint_ranges == [ixNet getNull] ||\
                        $pppox_endpoint_ranges == ""} {
                    debug "ixNet remove $pppoxEndpointObj"
                    if {[catch {ixNet remove $pppoxEndpointObj} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName : \
                                failed to remove pppoxEnpointObj $pppoxEndpointObj.\n$err"
                        return $returnList
                    }
                }
                
                debug "ixNet commit"
                ixNet commit
            } else {
                # Get the "pppoxEndpoint" parent object from the "range" child object
                set pppoxEndpointObj [ixNetworkGetParentObjref $handle "dhcpoPppClientEndpoint"]
                if {$pppoxEndpointObj == "::ixNet::OBJ-null"} {
                    set pppoxEndpointObj [ixNetworkGetParentObjref $handle "dhcpoPppServerEndpoint"]
                }
                       
                # First remove range object
                debug "ixNet remove $handle"
                if {[catch {ixNet remove $handle} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            failed to remove -handle $handle.\n$err"
                    return $returnList
                }
                
                if {[catch {ixNet commit} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            failed to remove -handle $handle.\n$err"
                    return $returnList
                }
                
                # If there are no more range objects under pppox endpoint object
                # remove pppox endpoint too
                set pppox_endpoint_ranges [::ixia::ixNetworkNodeGetList $pppoxEndpointObj range]
                if {$pppox_endpoint_ranges == [ixNet getNull] ||\
                        $pppox_endpoint_ranges == ""} {
                    
                    debug "ixNet remove [ixNetworkGetParentObjref $pppoxEndpointObj]"
                    if {[catch {ixNet remove [ixNetworkGetParentObjref $pppoxEndpointObj]} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName : \
                                failed to remove [ixNetworkGetParentObjref $pppoxEndpointObj].\n$err"
                        return $returnList
                    }
                }
                
                if {[catch {ixNet commit} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            failed to remove -handle $handle.\n$err"
                    return $returnList
                }
            }
            
            keylset returnList handle $handle
            keylset returnList status $::SUCCESS
            return $returnList
        }

        if {$mode == "modify"} {
            # Remove defaults
            removeDefaultOptionVars $opt_args $args
            if {[regexp {atm} $handle]} {
                set protocol pppoa
            } else {
                set protocol pppoe
            }
            
            if {[regexp {pppoxEndpoint} $handle]} {
                set dhcpv6_hosts_enable 0
            } else {
                set dhcpv6_hosts_enable 1
            }
        }
    }

    
    #################################
    #  CONFIGURE THE IXIA INTERFACES
    #################################
    if {![info exists mac_addr] && $mode == "add"} {
        set tmpPortObjRef ""
        foreach obj [split $port_handle /] {
            append tmpPortObjRef "$obj"
            if {[regexp -- {vport} $obj]} {
                break
            }
            append tmpPortObjRef "/"
        }
        foreach {ch ca po} [split [ixNetworkGetRouterPort $tmpPortObjRef] /] {}
        if {[format %s "$ch/$ca/$po"] eq [format %s "0/0/0"]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid port_handle $ch/$ca/$po"
            ::ixia::ixnetwork_pppox_rollback $handle $mode
            return $returnList
        }
        
        variable ixnetwork_emulation_cfg_no
        set _ch [string index $ch  [expr [string length $ch] - 1]]
        set _ca    [string index $ca      [expr [string length $ca] - 1]]
        set _po    [string index $po      [expr [string length $po] - 1]]
        set _cfgNo [string index $ixnetwork_emulation_cfg_no \
                [expr [string length $ixnetwork_emulation_cfg_no] - 1]]
        set mac_addr 00:$_ch$_ch:$_ca$_ca:$_po$_po:$_cfgNo$_cfgNo:01
        incr ixnetwork_emulation_cfg_no
    }

    ##########################
    ## Configure pppoxRange ##
    ##########################
    set pppox_range_params ""
    foreach param $pppox_range_args {
        if {[info exists $param] && [set $param] != ""} {
            lappend pppox_range_params "$param \{[set $param]\}"
        }
    }
    
    set result [::ixia::ixnetwork_pppoxRange_config $pppox_range_params]
    if {[keylget result status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName : \
                [keylget result log]."
        ::ixia::ixnetwork_pppox_rollback $handle $mode
        return $returnList
    }
    array set translate_array {
            duid_en     DUID-EN
            duid_llt    DUID-LLT
            duid_ll     DUID-LL
            0           false
            1           true
            iapd        IAPD
            dhcpv6_pd   dhcpv6
            icmpv6      icmpv6
            ipv4        IPv4
            ipv6        IPv6
        }
    ####################################
    ## Configure pppox global options ##
    ####################################
    
    # Get the "protocolStack" parent object from the "range" child object
    set pppoxOptionsObj [ixNetworkGetParentObjref $handle "protocolStack"]
    
    #configure port_role
    if {[info exists port_role]} {
        switch -- $port_role {
            access {
                set prole "-role client "
            }
            network {
                set prole "-role server "
            }
        }
        
        if {[info exists ipv6_global_address_mode] && [info exists dhcpv6_hosts_enable] && $dhcpv6_hosts_enable} {
            lappend prole -ipv6GlobalAddressMode $translate_array($ipv6_global_address_mode)
        }
        
        if {[ixNet exists $pppoxOptionsObj/pppoxOptions:1] == "false" || [ixNet exists $pppoxOptionsObj/pppoxOptions:1] == 0} {
            set result [::ixia::ixNetworkNodeAdd $pppoxOptionsObj pppoxOptions \
                    $prole -commit]
            if {[keylget result status] != $::SUCCESS} {
                set returnList $result
                ::ixia::ixnetwork_pppox_rollback $handle $mode
                return $returnList
            }
        } else {
            set result [::ixia::ixNetworkNodeSetAttr $pppoxOptionsObj/pppoxOptions:1 \
                    $prole -commit]
            if {[keylget result status] != $::SUCCESS} {
                set returnList $result
                ::ixia::ixnetwork_pppox_rollback $handle $mode
                return $returnList
            }
        }
    }
    
    if {$mode == "modify" && ![info exists port_role]} {
        if {[ixNet exists $pppoxOptionsObj/pppoxOptions:1] == "true" || [ixNet exists $pppoxOptionsObj/pppoxOptions:1] == 1} {
            set ixn_port_role [ixNet getA $pppoxOptionsObj/pppoxOptions:1 -role]
            switch -- $ixn_port_role {
                client {
                    set port_role "access"
                }
                server {
                    set port_role "network"
                }
            }
        }
        
    }
    
    if {[info exists port_role] && $port_role == "access"} {
        set tmpArgs ""
    
        foreach opt [array names pppox_options] {
            if {![info exists $opt]} {
                continue
            }
            if {$opt == "max_outstanding"} {
                foreach tmpOpt $pppox_options($opt) {
                    append tmpArgs "-$tmpOpt [set $opt] "
                }
            } else {
                append tmpArgs "-$pppox_options($opt) [set $opt] "
            }
        }
        
    
        if {[ixNet exists $pppoxOptionsObj/pppoxOptions:1] == "false" || [ixNet exists $pppoxOptionsObj/pppoxOptions:1] == 0} {
            set result [::ixia::ixNetworkNodeAdd $pppoxOptionsObj pppoxOptions \
                    "" -commit]
            if {[keylget result status] != $::SUCCESS} {
                set returnList $result
                ::ixia::ixnetwork_pppox_rollback $handle $mode
                return $returnList
            }
        }
        
        if {[info exists max_outstanding] || [info exists attempt_rate] || [info exists disconnect_rate]} {
            if {[info exists max_outstanding]} {
                set global_max_outstanding_request $max_outstanding
                set global_max_outstanding_release $max_outstanding
            } else {
                set global_max_outstanding_request 0
                set global_max_outstanding_release 0
            }
            
            if {[info exists attempt_rate]} {
                set global_attempt_rate $attempt_rate
            } else {
                set global_attempt_rate 0
            }

            if {[info exists disconnect_rate]} {
                set global_disconnect_rate $disconnect_rate
            } else {
                set global_disconnect_rate 0
            }
            
            ## The sum of per port global maxOutstandingRequests/maxOutstandingReleases
            #  must be <= then the per test global maxOutstandingRequests/maxOutstandingReleases
            set vport_list [ixNet getList [ixNet getRoot] vport]
            if {$vport_list != [ixNet getNull]} {
                foreach configured_vport $vport_list {
                    if {"$configured_vport/protocolStack" == "$port_handle"} {
                        continue
                    }
                    if {[ixNet exists $configured_vport/protocolStack/pppoxOptions:1] == "false" || [ixNet exists $configured_vport/protocolStack/pppoxOptions:1] == 0} {
                        continue
                    }
                    if {[ixNet getA $configured_vport/protocolStack/pppoxOptions:1 -overrideGlobalRateControls] != "true"} {
                        continue
                    }
                    # If it got this far, then it's a port with PPPoX enabled and overrideGlobalRateControls true
                    incr global_max_outstanding_request [ixNet getA $configured_vport/protocolStack/pppoxOptions:1 -maxOutstandingRequests]
                    incr global_max_outstanding_release [ixNet getA $configured_vport/protocolStack/pppoxOptions:1 -maxOutstandingReleases]
                    incr global_attempt_rate            [ixNet getA $configured_vport/protocolStack/pppoxOptions:1 -setupRateInitial      ]
                    incr global_disconnect_rate         [ixNet getA $configured_vport/protocolStack/pppoxOptions:1 -teardownRateInitial   ]
                }
            }
            
            # configure over all global max outstanding values
            if {[ixNet exists [ixNet getRoot]globals/protocolStack/pppoxGlobals:1] == "false" || [ixNet exists [ixNet getRoot]globals/protocolStack/pppoxGlobals:1] == 0} {
                set result [::ixia::ixNetworkNodeAdd [ixNet getRoot]globals/protocolStack pppoxGlobals \
                        "" -commit]
                if {[keylget result status] != $::SUCCESS} {
                    set returnList $result
                    ::ixia::ixnetwork_pppox_rollback $handle $mode
                    return $returnList
                }
            }
            set result [::ixia::ixNetworkNodeSetAttr [ixNet getRoot]globals/protocolStack/pppoxGlobals:1 \
                    [list -maxOutstandingReleases $global_max_outstanding_release \
                          -maxOutstandingRequests $global_max_outstanding_request \
                          -setupRateInitial       $global_attempt_rate            \
                          -teardownRateInitial    $global_disconnect_rate        ]\
                           -commit]
            if {[keylget result status] != $::SUCCESS} {
                set returnList $result
                ::ixia::ixnetwork_pppox_rollback $handle $mode
                return $returnList
            }
        }
        
        set result [::ixia::ixNetworkNodeSetAttr $pppoxOptionsObj/pppoxOptions:1 \
                [list -overrideGlobalRateControls $overrideGlobalRateControls] -commit]
        if {[keylget result status] != $::SUCCESS} {
            set returnList $result
            ::ixia::ixnetwork_pppox_rollback $handle $mode
            return $returnList
        }
        set result [::ixia::ixNetworkNodeSetAttr $pppoxOptionsObj/pppoxOptions:1 \
                $tmpArgs -commit]
        if {[keylget result status] != $::SUCCESS} {
            set returnList $result
            ::ixia::ixnetwork_pppox_rollback $handle $mode
            return $returnList
        }
    }

    if {[info exists dhcpv6_hosts_enable] && $dhcpv6_hosts_enable} {
        set return_val [::ixia::ixnetwork_dhcpv6_range_config]
        if {[keylget return_val status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to add pppox support to the\
                    protocol stack of port - [keylget return_val log]."
            return $returnList
        }
    }
    
    ####################################
    ## Configure macRange options     ##
    ####################################
    set macArgs ""
    foreach opt [array names mac_options] {
        if {![info exists $opt]} {
            continue
        }
        if {$opt == "mac_addr" || $opt == "mac_addr_step"} {
            if {![::ixia::isValidMacAddress [set $opt]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : \
                        Invalid MAC address value for -$opt."
                ::ixia::ixnetwork_pppox_rollback $handle $mode
                return $returnList
            }
            regsub -all { } [::ixia::convertToIxiaMac [set $opt]] {:} $opt
        }
        append macArgs "-$mac_options($opt) [set $opt] "
    }

    ####################################
    ## Configure atm options          ##
    ####################################
    set tmpArgs ""
    if {$protocol == "pppoa" || $protocol == "pppoeoa"} {
        foreach opt [array names pvc_range] {
            if {![info exists $opt]} {
                continue
            }
            set opt_value [set $opt]
            switch -- $opt {
                pvc_incr_mode {
                    switch -- $opt_value {
                        vpi {
                            set tmpVal 1
                        }
                        vci {
                            set tmpVal 0
                        }
                        both {
                            set tmpVal 2
                        }
                    }
                    append tmpArgs "-$pvc_range($opt) $tmpVal "
                }
                vci -
                vci_count -
                vci_step -
                vpi -
                vpi_count -
                addr_count_per_vci -
                addr_count_per_vpi -
                vpi_step {
                    append tmpArgs "-$pvc_range($opt) $opt_value "
                }
            }
        }
        set result [::ixia::ixNetworkNodeSetAttr $handle/pvcRange $tmpArgs -commit]
        if {[keylget result status] != $::SUCCESS} {
            set returnList $result
            ::ixia::ixnetwork_pppox_rollback $handle $mode
            return $returnList
        }

        set tmpVal ""
        array set mac_options [list                     \
            mac_addr            mac                     \
            mac_addr_step       incrementBy             \
            num_sessions        count
            ]
        # Also configure encapsulation
        if {[info exists encap] && $encap != ""} {
            switch -- $encap {
                vc_mux_routed {
                    if {$protocol == "pppoa"} {
                        if {$mode == "add"} {
                            if {![info exists ip_cp] || $ip_cp == "ipv4_cp"} {
                                # encapsulation "VC Mux IPv4 routed"
                                set tmpVal 1
                            } else {
                                # encapsulation "VC Mux IPv6 routed"
                                set tmpVal 4
                            }
                        } elseif {$mode == "modify"} {
                            if {[catch {ixNet getA $handle/pppoxRange -ncpType} \
                                        tmpIpType]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName : \
                                        ixNet getA $handle/pppoxRange -ncpType \
                                        returned $tmpIpType."
                                return $returnList
                            }
                            switch -- tmpIpType {
                                IPv4 {
                                    # encapsulation "VC Mux IPv4 routed"
                                    set tmpVal 1
                                }
                                default {
                                    # encapsulation "VC Mux IPv6 routed"
                                    set tmpVal 4
                                }
                            }
                        }
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName : \
                                Encapsulation $encap available only for pppoa."
                        ::ixia::ixnetwork_pppox_rollback $handle $mode
                        return $returnList
                    }
                }
                vc_mux {
                    if {$protocol == "pppoeoa"} {
                        # encapsulation "VC Mux Bridged Ethernet (FCS)"
                        set tmpVal 2
                    } elseif {$protocol == "pppoa"} {
                        # encapsulation "VC Mux PPP"
                        set tmpVal 10
                    }
                }
                vc_mux_nofcs {
                    if {$protocol == "pppoeoa"} {
                        # encapsulation "VC Mux Bridged Ethernet (no FCS)"
                        set tmpVal 3
                    } elseif {$protocol == "pppoa"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName : \
                                Encapsulation $encap available only for pppoeoa."
                        ::ixia::ixnetwork_pppox_rollback $handle $mode
                        return $returnList
                    }
                }
                llcsnap {
                    if {$protocol == "pppoeoa"} {
                        # encapsulation "LLC Bridged Ethernet(FCS)"
                        set tmpVal 7
                    } elseif {$protocol == "pppoa"} {
                        # encapsulation "LLC Encap PPP"
                        set tmpVal 9
                    }

                }
                llcsnap_nofcs {
                    if {$protocol == "pppoeoa"} {
                        # encapsulation "LLC Bridged Ethernet(no FCS)"
                        set tmpVal 8
                    } elseif {$protocol == "pppoa"} {
                        # encapsulation "LLC Encap PPP"
                        set tmpVal 9
                    }
                }
                llcsnap_routed {
                    if {$protocol == "pppoa"} {
                        # encapsulation "LLC Routed AAL5 Snap"
                        set tmpVal 6
                    } elseif {$protocol == "pppoeoa"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName : \
                                Encapsulation $encap available only for pppoa."
                        ::ixia::ixnetwork_pppox_rollback $handle $mode
                        return $returnList
                    }
                }
            }
            append macArgs " -encapsulation $tmpVal "
        }

        debug "macArgs = $macArgs"
        set result [::ixia::ixNetworkNodeSetAttr $handle/atmRange $macArgs -commit]
        if {[keylget result status] != $::SUCCESS} {
            set returnList $result
            ::ixia::ixnetwork_pppox_rollback $handle $mode
            return $returnList
        }

        # Exit here if protocol is pppoa or pppoeoa
        keylset returnList handle $handle
        return $returnList
    }

    debug "macArgs = $macArgs"
    set result [::ixia::ixNetworkNodeSetAttr $handle/macRange $macArgs -commit]
    if {[keylget result status] != $::SUCCESS} {
        set returnList $result
        ::ixia::ixnetwork_pppox_rollback $handle $mode
        return $returnList
    }

    ####################################
    ## Configure vlanRange options    ##
    ####################################
    set tmpArgs ""
    if {$encap == "ethernet_ii"} {
        append tmpArgs "-enabled false "
        append tmpArgs "-innerEnable false "
    } elseif {$encap == "ethernet_ii_vlan"} {
        append tmpArgs "-enabled true "
        append tmpArgs "-innerEnable false "
    } elseif {$encap == "ethernet_ii_qinq"} {
        append tmpArgs "-enabled true "
        append tmpArgs "-innerEnable true "
    }
    
    foreach opt [array names vlan_range] {
        if {![info exists $opt]} {
            continue
        }
        set opt_value [set $opt]
        switch -- $opt {
            qinq_incr_mode {
                switch -- $opt_value {
                    inner {
                        # 1 is for inner increment.
                        append tmpArgs "-$vlan_range($opt) 1 "
                    }
                    outer {
                        append tmpArgs "-$vlan_range($opt) 0 "
                    }
                    both {
                        append tmpArgs "-$vlan_range($opt) 2 "
                    }
                }
            }
            vlan_id -
            vlan_user_priority -
            vlan_user_priority_outer -
            vlan_id_step -
            vlan_id_count -
            vlan_id_outer -
            vlan_id_outer_step -
            vlan_id_outer_count -
            address_per_vlan -
            address_per_svlan {
                append tmpArgs "-$vlan_range($opt) $opt_value "
            }
        }
    }

    set result [::ixia::ixNetworkNodeSetAttr $handle/vlanRange  $tmpArgs -commit]
    if {[keylget result status] != $::SUCCESS} {
        set returnList $result
        ::ixia::ixnetwork_pppox_rollback $handle $mode
        return $returnList
    }

    keylset returnList handle $handle
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_pppox_control { args } {
    variable truth

    set mandatory_args {
        -action CHOICES abort abort_async connect disconnect reset reset_async
    }
    set opt_args {
        -handle ANY
    }
    

    set args [lindex $args 0]
    ::ixia::parse_dashed_args -args $args -mandatory_args $mandatory_args -optional_args $opt_args


    keylset returnList status $::SUCCESS
    set commit_needed 1
    
    # Check to see if a connection to the IxNetwork TCL server already exists.
    # If it doesn't, establish it.
    set return_status [checkIxNetwork]
    if {[keylget return_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to \
                IxNetwork [keylget return_status log]"
        return $returnList
    }
    
    set sm_type_list    { pppox pppoxEndpoint }
    set stack_type_list { ethernet atm }
    
    set handle_list {}
    # if -handle doesn't exist, populate handle_list with all pppoxEndpoints on all ports
    if {![info exists handle]} {
        set vport_list [ixNet getList [ixNet getRoot] vport]
        foreach vp $vport_list {
            foreach st $stack_type_list {
                foreach smt $sm_type_list {
                    set ret_val [::ixia::ixNetworkValidateSMPlugins $vp $st $smt]
                    if {[keylget ret_val status] == $::SUCCESS && [keylget ret_val summary] == 3} {
                        set handle_list [concat $handle_list [keylget ret_val ret_val]]
                    }
                }
            }
        }
    } else {
        # if -handle is a port_handle, populate handle_list with all pppoxEndpoints on that port
        if {[regexp {^\d+/\d+/\d+$} [lindex $handle 0]]} {
            foreach h $handle {
                set ret_val [::ixia::ixNetworkGetPortObjref $h]
                if {[keylget ret_val status] == $::SUCCESS} {
                    set vport_handle [keylget ret_val vport_objref]
                    foreach st $stack_type_list {
                        foreach smt $sm_type_list {
                            set ret_val [::ixia::ixNetworkValidateSMPlugins $vport_handle $st $smt]
                            if {[keylget ret_val status] == $::SUCCESS && [keylget ret_val summary] == 3} {
                                set handle_list [concat $handle_list [keylget ret_val ret_val]]
                            }
                        }
                    }
                }
            }
        } else {
            set handle_list $handle
        }
    }
    
    if {$action == "reset" || $action == "reset_async"} {
        set returnList [ixnetwork_pppox_reset $handle_list $action]
        return $returnList
    }
    
    array set action_map {
        abort           {   abort   0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+}
                                        }
                        }
        abort_async     {   abort   1   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+}
                                        }
                        }
        connect         {   start   1   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+}
                                        }
                        }
        disconnect      {   stop    1   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+}
                                        }
                        }
    }
    
    set abort_regex_special_case {(^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+)|(^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+)}
    
    foreach handle $handle_list {
        if {[ixNet exists $handle] == "false" || [ixNet exists $handle] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "invalid or incorect -handle: $handle."
            return $returnList
        }
        
        foreach regexp_elem [lindex $action_map($action) 2] {
            if {[regexp $regexp_elem $handle handle_temp]} {
                
                if {($action == "abort" || $action == "abort_async") && [regexp $abort_regex_special_case $handle_temp]} {
                    set handle_temp [ixNetworkGetParentObjref $handle_temp "dhcpoPppClientEndpoint"]
                }
                
                set handle $handle_temp
                break;
            }
        }
        
        
        set ixNetworkExecParamsAsync [list [lindex $action_map($action) 0] $handle]
        set ixNetworkExecParamsSync  [list [lindex $action_map($action) 0] $handle]
        if {[lindex $action_map($action) 1]} {
            lappend ixNetworkExecParamsAsync async
        }
        
        if {[catch {ixNetworkExec $ixNetworkExecParamsAsync} status]} {
            if {[string first "no matching exec found" $status] != -1} {
                if {[catch {ixNetworkExec $ixNetworkExecParamsSync} status] && \
                        ([string first "::ixNet::OK" $status] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action PPP. Returned status: $status"
                    return $returnList
                }
            } else {
                keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action PPP. Returned status: $status"
                return $returnList
            }
        } else {
            if {[string first "::ixNet::OK" $status] == -1} {
                keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action PPP. Returned status: $status"
                return $returnList
            }
        }
    }
    
    return $returnList
}


proc ::ixia::ixnetwork_pppox_stats { args } {
    set args [lindex $args 0]
    variable executeOnTclServer

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::ixnetwork_pppox_stats $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args

    # Arguments
    set man_args {
        -mode         CHOICES aggregate session tunnel aggregate_raw session_dhcpv6pd session_dhcp_hosts session_all
    }
    set opt_args {
        -handle       ANY
        -port_handle  ANY
    }
    
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
    
    # check for pppox enabled on each port handle
    set ph_temp {}
    foreach ph [lsort -unique $port_handle] {
        set result [ixNetworkGetPortObjref $ph]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the port \
                    object reference associated to the $port port handle -\
                    [keylget result log]."
            return $returnList
        }
        set por [keylget result vport_objref]
        if {[catch {ixNet getL $por/protocolStack pppoxOptions} res]} {
            continue
        } elseif {[llength $res] == 0} { continue }
        lappend ph_temp $ph
    }
    if {[llength $ph_temp] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Warning. Unable to find any ports in the given list with pppox configured."
        return $returnList
    }
    set port_handle $ph_temp
    
    if {[catch {set ::ixia::ixnetworkVersion} ixn_version]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get IxNetwork version - $ixn_version.\
                Possible causes: not connected to IxNetwork Tcl Server."
        return $returnList
    }
    
    if {![regexp {(^\d+)(\.)(\d+)} $ixn_version {} ixn_version_major {} ixn_version_minor]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get IxNetwork version major and minor - $ixn_version."
        return $returnList
    }
    
    set ixn_version ${ixn_version_major}.${ixn_version_minor}
    
    set all_session_statistics 0
    if {$mode == "session_all"} {
        # gather all statistics per session
        set all_session_statistics 1
    }
    
    if {$mode == "aggregate"} {
        set portIndex 0
        foreach port $port_handle {
            set result [ixNetworkGetPortObjref $port]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port \
                        object reference associated to the $port port handle -\
                        [keylget result log]."
                return $returnList
            }
            
            set vport_objref [keylget result vport_objref]
            
            set port_h $vport_objref/protocolStack/pppoxOptions:1

            if  [catch {ixNet getAttribute $port_h -role} port_role] {
                keylset returnList status $::FAILURE
                keylset returnList log "ixNet getAttribute $port_h -role returned \
                        $port_role"
                return $returnList
            }

            set tmpName [string totitle $port_role]

            if  [catch {ixNet getAttribute [keylget result vport_objref] -type} port_type] {
                keylset returnList status $::FAILURE
                keylset returnList log "ixNet getAttribute \
                        [keylget result vport_objref] -type returned \
                        $port_type"
                return $returnList
            }
            
            keylset returnList status $::SUCCESS

            # PPPoX CHAP Authentication Statistics
            set stat_list_chap [list                        \
                "CHAP Challenge Tx"                         \
                "CHAP Challenge Rx"                         \
                "CHAP Response Tx"                          \
                "CHAP Response Rx"                          \
                "CHAP Success Tx"                           \
                "CHAP Success Rx"                           \
                "CHAP Failure Tx"                           \
                "CHAP Failure Rx"                           \
                ]
            array set stats_array_chap [list                \
                "CHAP Challenge Tx"                         \
                    "chap_auth_chal_tx"                     \
                "CHAP Challenge Rx"                         \
                    "chap_auth_chal_rx"                     \
                "CHAP Response Tx"                          \
                    "chap_auth_rsp_tx"                      \
                "CHAP Response Rx"                          \
                    "chap_auth_rsp_rx"                      \
                "CHAP Success Tx"                           \
                    "chap_auth_succ_tx"                     \
                "CHAP Success Rx"                           \
                    "chap_auth_succ_rx"                     \
                "CHAP Failure Tx"                           \
                    "chap_auth_fail_tx"                     \
                "CHAP Failure Rx"                           \
                    "chap_auth_fail_rx"                     \
                ]


            # PPPoX Latency Statistics
            set stat_list_latency [list                           \
                "$tmpName Session Minimum Latency"                \
                "$tmpName Session Average Latency"                \
                "$tmpName Session Maximum Latency"                \
                "LCP Minimum Latency"                             \
                "LCP Average Latency"                             \
                "LCP Maximum Latency"                             \
                "NCP Minimum Latency"                             \
                "NCP Average Latency"                             \
                "NCP Maximum Latency"                             \
                "PPPoE Minimum Latency"                           \
                "PPPoE Average Latency"                           \
                "PPPoE Maximum Latency"                           \
                ]
            array set stats_array_latency [list                  \
                "$tmpName Session Minimum Latency"               \
                    "min_setup_time"                             \
                "$tmpName Session Average Latency"               \
                    "avg_setup_time"                             \
                "$tmpName Session Maximum Latency"               \
                    "max_setup_time"                             \
                "LCP Minimum Latency"                            \
                    "lcp_min_latency"                            \
                "LCP Average Latency"                            \
                    "lcp_avg_latency"                            \
                "LCP Maximum Latency"                            \
                    "lcp_max_latency"                            \
                "NCP Minimum Latency"                            \
                    "ncp_min_latency"                            \
                "NCP Average Latency"                            \
                    "ncp_avg_latency"                            \
                "NCP Maximum Latency"                            \
                    "ncp_max_latency"                            \
                "PPPoE Minimum Latency"                          \
                    "pppoe_min_latency"                          \
                "PPPoE Average Latency"                          \
                    "pppoe_avg_latency"                          \
                "PPPoE Maximum Latency"                          \
                    "pppoe_max_latency"                          \
                ]


            # PPPoX PAP Authentication Statistics
            set stat_list_pap [list                                     \
                "PAP Authentication Req Tx"                             \
                "PAP Authentication Req Rx"                             \
                "PAP Authentication ACK Tx"                             \
                "PAP Authentication ACK Rx"                             \
                "PAP Authentication NAK Tx"                             \
                "PAP Authentication NAK Rx"                             \
                ]
            array set stats_array_pap [list                   \
                "PAP Authentication Req Tx"                   \
                    "pap_auth_req_tx"                         \
                "PAP Authentication Req Rx"                   \
                    "pap_auth_req_rx"                         \
                "PAP Authentication ACK Tx"                   \
                    "pap_auth_ack_tx"                         \
                "PAP Authentication ACK Rx"                   \
                    "pap_auth_ack_rx"                         \
                "PAP Authentication NAK Tx"                   \
                    "pap_auth_nak_tx"                         \
                "PAP Authentication NAK Rx"                   \
                    "pap_auth_nak_rx"                         \
                ]


            # PPPoX LCP Link Maintenance Statistics
            set stat_list_lcp [list                           \
                "LCP Echo Request Tx"                         \
                "LCP Echo Request Rx"                         \
                "LCP Echo Response Tx"                        \
                "LCP Echo Response Rx"                        \
                "LCP Code Reject Tx"                          \
                "LCP Code Reject Rx"                          \
                ]
            array set stats_array_lcp [list                   \
                "LCP Echo Request Tx"                         \
                    "echo_req_tx"                             \
                "LCP Echo Request Rx"                         \
                    "echo_req_rx"                             \
                "LCP Echo Response Tx"                        \
                    "echo_rsp_tx"                             \
                "LCP Echo Response Rx"                        \
                    "echo_rsp_rx"                             \
                "LCP Code Reject Tx"                          \
                    "code_rej_tx"                             \
                "LCP Code Reject Rx"                          \
                    "code_rej_rx"                             \
                ]


            # PPPoX NCP IPCP Statistics
            set stat_list_ncp [list                              \
                "IPCP Config Request Tx"                         \
                "IPCP Config Request Rx"                         \
                "IPCP Config ACK Tx"                             \
                "IPCP Config ACK Rx"                             \
                "IPCP Config NAK Tx"                             \
                "IPCP Config NAK Rx"                             \
                "IPCP Config Reject Tx"                          \
                "IPCP Config Reject Rx"                          \
                ]
            array set stats_array_ncp [list                      \
                "IPCP Config Request Tx"                         \
                    "ipcp_cfg_req_tx"                            \
                "IPCP Config Request Rx"                         \
                    "ipcp_cfg_req_rx"                            \
                "IPCP Config ACK Tx"                             \
                    "ipcp_cfg_ack_tx"                            \
                "IPCP Config ACK Rx"                             \
                    "ipcp_cfg_ack_rx"                            \
                "IPCP Config NAK Tx"                             \
                    "ipcp_cfg_nak_tx"                            \
                "IPCP Config NAK Rx"                             \
                    "ipcp_cfg_nak_rx"                            \
                "IPCP Config Reject Tx"                          \
                    "ipcp_cfg_rej_tx"                            \
                "IPCP Config Reject Rx"                          \
                    "ipcp_cfg_rej_rx"                            \
                ]
            
            
            # PPPoX NCP IPv6CP Statistics
            set stat_list_ncpv6 [list                            \
                "IPv6CP Config Request Tx"                       \
                "IPv6CP Config Request Rx"                       \
                "IPv6CP Config ACK Tx"                           \
                "IPv6CP Config ACK Rx"                           \
                "IPv6CP Config NAK Tx"                           \
                "IPv6CP Config NAK Rx"                           \
                "IPv6CP Config Reject Tx"                        \
                "IPv6CP Config Reject Rx"                        \
                ]
            array set stats_array_ncpv6 [list                    \
                "IPv6CP Config Request Tx"                       \
                    "ipv6cp_cfg_req_tx"                          \
                "IPv6CP Config Request Rx"                       \
                    "ipv6cp_cfg_req_rx"                          \
                "IPv6CP Config ACK Tx"                           \
                    "ipv6cp_cfg_ack_tx"                          \
                "IPv6CP Config ACK Rx"                           \
                    "ipv6cp_cfg_ack_rx"                          \
                "IPv6CP Config NAK Tx"                           \
                    "ipv6cp_cfg_nak_tx"                          \
                "IPv6CP Config NAK Rx"                           \
                    "ipv6cp_cfg_nak_rx"                          \
                "IPv6CP Config Reject Tx"                        \
                    "ipv6cp_cfg_rej_tx"                          \
                "IPv6CP Config Reject Rx"                        \
                    "ipv6cp_cfg_rej_rx"                          \
                ]

            # PPPoX General Statistics
            set stat_list_gen [list                            \
                "$tmpName Interfaces Up"                       \
                "$tmpName Interfaces Setup Rate"               \
                "Interfaces Teardown Rate"                     \
                "$tmpName Interfaces in PPP Negotiation"       \
                "Interfaces in PPPoE/L2TP Negotiation"         \
                "Port Name"                                    \
                "Sessions Initiated"                           \
                "Sessions Failed"                              \
                "LCP Total Messages Tx"                        \
                "LCP Total Messages Rx"                        \
                "Authentication Total Tx"                      \
                "Authentication Total Rx"                      \
                "NCP Total Messages Tx"                        \
                "NCP Total Messages Rx"                        \
                "PPP Total Bytes Tx"                           \
                "PPP Total Bytes Rx"                           \
                "Malformed PPP Frames Used"                    \
                "Malformed PPP Frames Rejected"                \
                "PPPoE Total Bytes Tx"                         \
                "PPPoE Total Bytes Rx"                         \
                "Max Teardown Rate"                            \
                ]
            array set stats_array_gen [list                             \
                "$tmpName Interfaces Up"                                \
                    "sessions_up"                                       \
                "$tmpName Interfaces Setup Rate"                        \
                    "success_setup_rate"                                \
                "Interfaces Teardown Rate"                              \
                    "interfaces_teardown_rate"                          \
                "$tmpName Interfaces in PPP Negotiation"                \
                    "interfaces_in_ppp_negotiation"                     \
                "Interfaces in PPPoE/L2TP Negotiation"                  \
                    "interfaces_in_pppoe_l2tp_negotiation"              \
                "Port Name"                                             \
                    "port_name"                                         \
                "Sessions Initiated"                                    \
                    "sessions_initiated"                                \
                "Sessions Failed"                                       \
                    "sessions_failed"                                   \
                "LCP Total Messages Tx"                                 \
                    "lcp_total_msg_tx"                                  \
                "LCP Total Messages Rx"                                 \
                    "lcp_total_msg_rx"                                  \
                "Authentication Total Tx"                               \
                    "auth_total_tx"                                     \
                "Authentication Total Rx"                               \
                    "auth_total_rx"                                     \
                "NCP Total Messages Tx"                                 \
                    "ncp_total_msg_tx"                                  \
                "NCP Total Messages Rx"                                 \
                    "ncp_total_msg_rx"                                  \
                "PPP Total Bytes Tx"                                    \
                    "ppp_total_bytes_tx"                                \
                "PPP Total Bytes Rx"                                    \
                    "ppp_total_bytes_rx"                                \
                "Malformed PPP Frames Used"                             \
                    "malformed_ppp_frames_used"                         \
                "Malformed PPP Frames Rejected"                         \
                    "malformed_ppp_frames_rejected"                     \
                "PPPoE Total Bytes Tx"                                  \
                    "pppoe_total_bytes_tx"                              \
                "PPPoE Total Bytes Rx"                                  \
                    "pppoe_total_bytes_rx"                              \
                "Max Teardown Rate"                                     \
                    "teardown_rate"                                     \
                ]

            if {$port_role == "client"} {
                set stats_array_gen(Client\ Max\ Setup\ Rate) \
                    client_max_setup_rate
                append stat_list_gen " {Client Max Setup Rate}"
            }

            # PPPoX LCP Link Termination Statistics
            set stat_list_lcp_term [list                       \
                "LCP Terminate Tx"                             \
                "LCP Terminate Rx"                             \
                "LCP Terminate ACK Tx"                         \
                "LCP Terminate ACK Rx"                         \
                ]
            array set stats_array_lcp_term [list               \
                "LCP Terminate Tx"                             \
                    "term_req_tx"                              \
                "LCP Terminate Rx"                             \
                    "term_req_rx"                              \
                "LCP Terminate ACK Tx"                         \
                    "term_ack_tx"                              \
                "LCP Terminate ACK Rx"                         \
                    "term_ack_rx"                              \
                ]

            # PPPoX LCP Link Establishment Phase Statistics
            set stat_list_lcp_est [list                         \
                "LCP Config Request Tx"                         \
                "LCP Config Request Rx"                         \
                "LCP Config ACK Tx"                             \
                "LCP Config ACK Rx"                             \
                "LCP Config NAK Tx"                             \
                "LCP Config NAK Rx"                             \
                "LCP Config Reject Tx"                          \
                "LCP Config Reject Rx"                          \
                ]
            array set stats_array_lcp_est [list                 \
                "LCP Config Request Tx"                         \
                    "lcp_cfg_req_tx"                            \
                "LCP Config Request Rx"                         \
                    "lcp_cfg_req_rx"                            \
                "LCP Config ACK Tx"                             \
                    "lcp_cfg_ack_tx"                            \
                "LCP Config ACK Rx"                             \
                    "lcp_cfg_ack_rx"                            \
                "LCP Config NAK Tx"                             \
                    "lcp_cfg_nak_tx"                            \
                "LCP Config NAK Rx"                             \
                    "lcp_cfg_nak_rx"                            \
                "LCP Config Reject Tx"                          \
                    "lcp_cfg_rej_tx"                            \
                "LCP Config Reject Rx"                          \
                    "lcp_cfg_rej_rx"                            \
                ]

            # PPPoE Discovery Statistics
            set stat_list_disc [list\
                "PADI Tx"           \
                "PADI Rx"           \
                "PADI Timeouts"     \
                "PADO Tx"           \
                "PADO Rx"           \
                "PADR Tx"           \
                "PADR Rx"           \
                "PADR Timeouts"     \
                "PADS Tx"           \
                "PADS Rx"           \
                ]
            array set stats_array_disc [list    \
                "PADI Tx"                       \
                    "padi_tx"                   \
                "PADI Rx"                       \
                    "padi_rx"                   \
                "PADI Timeouts"                 \
                    "padi_timeout"              \
                "PADO Tx"                       \
                    "pado_tx"                   \
                "PADO Rx"                       \
                    "pado_rx"                   \
                "PADR Tx"                       \
                    "padr_tx"                   \
                "PADR Rx"                       \
                    "padr_rx"                   \
                "PADR Timeouts"                 \
                    "padr_timeout"              \
                "PADS Tx"                       \
                    "pads_tx"                   \
                "PADS Rx"                       \
                    "pads_rx"                   \
                ]


            # PPPoE Termination Statistics
            set stat_list_term [list        \
                "PADT Tx"                   \
                "PADT Rx"                   \
                ]
            array set stats_array_term [list    \
                "PADT Tx"                       \
                    "padt_tx"                   \
                "PADT Rx"                       \
                    "padt_rx"                   \
                ]
            
            # DHCPv6PD Client Statistics
            set stat_list_dhcpv6pd_client [list \
                "Addresses Discovered"          \
                "Advertisements Ignored"        \
                "Advertisements Received"       \
                "Enabled Interfaces"            \
                "Rebinds Sent"                  \
                "Releases Sent"                 \
                "Renews Sent"                   \
                "Replies Received"              \
                "Requests Sent"                 \
                "Sessions Failed"               \
                "Sessions Initiated"            \
                "Port Name"                     \
                "Sessions Succeeded"            \
                "Setup Success Rate"            \
                "Solicits Sent"                 \
                "Teardown Fail"                 \
                "Teardown Initiated"            \
                "Teardown Success"              \
                "Information Requests Sent"     \
                "Min Establishment Time"        \
                "Avg Establishment Time"        \
                "Max Establishment Time"        \
                ]

            array set stats_array_dhcpv6pd_client [list     \
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
                "Port Name"                                 \
                    port_name                               \
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
            
            
            # DHCP Hosts Statistics
            set stat_list_dhcp_hosts [list  \
                "Sessions Failed"           \
                "Sessions Initiated"        \
                "Sessions Succeeded"        \
                ]
            
            array set stats_array_dhcp_hosts [list     \
                "Sessions Failed"                      \
                    dhcp_hosts_sessions_failed         \
                "Sessions Initiated"                   \
                    dhcp_hosts_sessions_initiated      \
                "Sessions Succeeded"                   \
                    dhcp_hosts_sessions_succeeded      \
                ]
            
            # DHCPv6PD Server Statistics
            set stat_list_dhcpv6pd_server [list \
                "Port Name"                     \
                "Solicits Received"             \
                "Advertisements Sent"           \
                "Requests Received"             \
                "Confirms Received"             \
                "Renewals Received"             \
                "Rebinds Received"              \
                "Replies Sent"                  \
                "Releases Received"             \
                "Declines Received"             \
                "Information-Requests Received" \
                "Total Prefixes Allocated"      \
                "Total Prefixes Renewed"        \
                "Current Prefixes Allocated"    \
                ]
                
            array set stats_array_dhcpv6pd_server [list     \
                "Port Name"                                 \
                    port_name                               \
                "Sessions Initiated"                        \
                    dhcpv6pd_sessions_initiated             \
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
            
            set statistic_types [list                                       \
                chap        "PPP CHAP Authentication Statistics"            \
                latency     "PPP Latency Statistics"                        \
                pap         "PPP PAP Authentication Statistics"             \
                lcp         "PPP LCP Link Maintenance Statistics"           \
                ncp         "PPP NCP IPCP Statistics"                       \
                ncpv6       "PPP NCP IPv6CP Statistics"                     \
                gen         "PPP General Statistics"                        \
                lcp_term    "PPP LCP Link Termination Statistics"           \
                lcp_est     "PPP LCP Link Establishment Phase Statistics"   \
                disc        "PPPoE Discovery Statistics"                    \
                term        "PPPoE Termination Statistics"                  ]
            
            set eth_obj [ixNet getL $vport_objref/protocolStack ethernet]
            if {[llength $eth_obj]==0 || $eth_obj == [ixNet getNull]} {
                set eth_obj [ixNet getL $vport_objref/protocolStack atm]
            }
            if {[llength $eth_obj] > 0 && $eth_obj != [ixNet getNull]} {
                # get first ethernet that might have pppox, fallback on first eth_obj
                set eth_tmp [lindex $eth_obj 0]
                foreach eth_elem $eth_obj {
                    set pppox_obj [ixNet getL $eth_elem pppox]
                    
                    if {[info exists pppox_obj] && [llength $pppox_obj] > 0 &&\
                            $pppox_obj != [ixNet getNull]} {
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
                    
                    set pppox_obj [ixNet getL $eth_obj pppox]
                    if {[llength $pppox_obj] > 0 && $pppox_obj != [ixNet getNull]} {
                        # Append the DHCP* stats for DHCPv6 hosts behind PPP CPE feature
                        if {$dhcpv6pd_view_name != "DHCPv6PD"} {
                            if {$port_role eq "client"} {
                                lappend statistic_types dhcpv6pd_client "DHCPv6Client" \
                                                        dhcp_hosts "DHCP Hosts"
                            } else {
                                lappend statistic_types dhcpv6pd_server "DHCPv6Server"
                            }
                        } else {
                            lappend statistic_types dhcpv6pd_client $dhcpv6pd_view_name dhcp_hosts "DHCP Hosts"
                        }
                    }
                }
            }
            
            array set statViewBrowserNamesArray $statistic_types
            foreach stat_type [array names statViewBrowserNamesArray] {
                lappend statViewBrowserNamesList\
                        $statViewBrowserNamesArray($stat_type)
            }
            
            set num_sessions_status [ixNetworkGetNumSessions $vport_objref]
            if {[keylget num_sessions_status status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to retrieve sum of all PPPoX sessions\
                        from port $port. [keylget num_sessions_status log]"
                return $returnList
            }
            set num_sessions [keylget num_sessions_status num_sessions]
            keylset returnList ${port}.aggregate.num_sessions $num_sessions
            if {$portIndex == 0 && ![info exists handle]} {
                keylset returnList aggregate.num_sessions $num_sessions
            }
            
            set enableStatus [enableStatViewList $statViewBrowserNamesList]
            if {[keylget enableStatus status] == $::FAILURE} {
                if {[string first "Unable to get stat views" [keylget enableStatus log]] != -1} {
                    foreach {stat_type stat_name} $statistic_types {
                        set stats_list_name stat_list_${stat_type}
                        set stats_list [set $stats_list_name]
                        set stats_array_name stats_array_${stat_type}
                        array set stats_array [array get $stats_array_name]
                        foreach stat $stats_list {
                            if {$portIndex == 0 && ![info exists handle]} {
                                keylset returnList aggregate.$stats_array($stat) 0
                            }
                            keylset returnList ${port}.aggregate.$stats_array($stat) 0
                        }
                        if {$stat_type == "gen"} {
                            if {$portIndex == 0 && ![info exists handle]} {
                                keylset returnList aggregate.connected       0
                                keylset returnList aggregate.connect_success 0
                                keylset returnList aggregate.idle            0
                                keylset returnList aggregate.connecting      "N/A"
                            }
                            keylset returnList ${port}.aggregate.connected       0
                            keylset returnList ${port}.aggregate.connect_success 0
                            keylset returnList ${port}.aggregate.idle            0
                            keylset returnList ${port}.aggregate.connecting      "N/A"
                        }
                    }
                    continue
                } else {
                    return $enableStatus
                }
            }
            after 2000
            
            foreach {stat_type stat_name} $statistic_types {
                set stats_list_name stat_list_${stat_type}
                set stats_list [set $stats_list_name]
                set stats_array_name stats_array_${stat_type}
                array set stats_array [array get $stats_array_name]

                set returned_stats_list [ixNetworkGetStats \
                        $stat_name $stats_list]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                      continue
                }

                debug "\nixNetworkGetStats $stat_name $stats_list returned: $returned_stats_list"

                set found false
                set row_count [keylget returned_stats_list row_count]
                array set rows_array [keylget returned_stats_list statistics]
                debug "rows_array == [array get rows_array]"
                for {set i 1} {$i <= $row_count} {incr i} {
                    set row_name $rows_array($i)
                    debug "\tset row_name $rows_array($i)"
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
                    debug "\tmatch_name == $match_name"
                    debug "\tchassis_ip == $chassis_ip"
                    debug "\tcard_no == $card_no"
                    debug "\tport_no == $port_no"
                    regsub {^0} $card_no "" card_no
                    debug "\tAfter regexp: card_no == $card_no"
                    regsub {^0} $port_no "" port_no
                    debug "\tAfter regexp: port_no == $port_no"
                    debug "\t\"$port\" eq \"$chassis_no/$card_no/$port_no\""
                    if {"$port" eq "$chassis_no/$card_no/$port_no"} {
                        set found true
                        foreach stat $stats_list {
                            if {[info exists rows_array($i,$stat)] && \
                                    $rows_array($i,$stat) != ""} {
                                if {$portIndex == 0 && ![info exists handle]} {
                                    keylset returnList aggregate.$stats_array($stat) \
                                            $rows_array($i,$stat)
                                }
                                keylset returnList ${port}.aggregate.$stats_array($stat) \
                                        $rows_array($i,$stat)
                            } else {
                                if {$portIndex == 0 && ![info exists handle]} {
                                    keylset returnList aggregate.$stats_array($stat) "N/A"
                                }
                                keylset returnList ${port}.aggregate.$stats_array($stat) "N/A"
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
                
                if {$stat_type == "gen"} {
                    if {$portIndex == 0 && ![info exists handle]} {
                        keylset returnList aggregate.connected \
                            [keylget returnList aggregate.sessions_up]
                        
                        keylset returnList aggregate.connect_success \
                                [keylget returnList aggregate.sessions_up]
    
                        if {[catch {keylset returnList aggregate.idle \
                                [expr [keylget returnList aggregate.num_sessions] - \
                                [keylget returnList aggregate.interfaces_in_pppoe_l2tp_negotiation] - \
                                [keylget returnList aggregate.interfaces_in_ppp_negotiation] - \
                                [keylget returnList aggregate.sessions_up]]} retCode]} {
                            if {[string first N/A $retCode]} {
                                keylset returnList aggregate.idle N/A
                            } else {
                                keylset returnList status $FAILURE
                                keylset returnList log $retCode
                                return $returnList
                            }
                        }
    
                        if {[catch {keylset returnList aggregate.connecting [expr \
                                [keylget returnList aggregate.interfaces_in_pppoe_l2tp_negotiation] + \
                                [keylget returnList aggregate.interfaces_in_ppp_negotiation]]} retCode]} {
                            if {[string first N/A $retCode]} {
                                keylset returnList aggregate.connecting N/A
                            } else {
                                keylset returnList status $FAILURE
                                keylset returnList log $retCode
                                return $returnList
                            }
                        }
                    }
                    keylset returnList ${port}.aggregate.connected \
                            [keylget returnList ${port}.aggregate.sessions_up]
                    
                    keylset returnList ${port}.aggregate.connect_success \
                            [keylget returnList ${port}.aggregate.sessions_up]

                    if {[catch {keylset returnList ${port}.aggregate.idle \
                            [expr [keylget returnList ${port}.aggregate.num_sessions] - \
                            [keylget returnList ${port}.aggregate.interfaces_in_pppoe_l2tp_negotiation] - \
                            [keylget returnList ${port}.aggregate.interfaces_in_ppp_negotiation] - \
                            [keylget returnList ${port}.aggregate.sessions_up]]} retCode]} {
                        if {[string first N/A $retCode]} {
                            keylset returnList aggregate.idle N/A
                        } else {
                            keylset returnList status $FAILURE
                            keylset returnList log $retCode
                            return $returnList
                        }
                    }

                    if {[catch {keylset returnList ${port}.aggregate.connecting [expr \
                            [keylget returnList ${port}.aggregate.interfaces_in_pppoe_l2tp_negotiation] + \
                            [keylget returnList ${port}.aggregate.interfaces_in_ppp_negotiation]]} retCode]} {
                        if {[string first N/A $retCode]} {
                            keylset returnList aggregate.connecting N/A
                        } else {
                            keylset returnList status $FAILURE
                            keylset returnList log $retCode
                            return $returnList
                        }
                    }
                }
            }
            incr portIndex
        }
        
        # Get per range stats
        if {[info exists handle]} {
            array set stats_array_per_range_ixn [list                                    \
                sessions_failed                       "Interfaces Failed"                \
                connected                             "Interfaces Up"                    \
                connect_success                       "Interfaces Up"                    \
                sessions_up                           "Interfaces Up"                    \
                interfaces_in_chap_negotiation        "Interfaces in CHAP Negotiation"   \
                interfaces_in_discovery               "Interfaces in Discovery"          \
                interfaces_in_ipcp_negotiation        "Interfaces in IPCP Negotiation"   \
                interfaces_in_ipv6cp_negotiation      "Interfaces in IPv6CP Negotiation" \
                interfaces_in_lcp_negotiation         "Interfaces in LCP Negotiation"    \
                interfaces_in_pap_negotiation         "Interfaces in PAP Negotiation"    \
                interfaces_in_ppp_negotiation         "Interfaces in PPP Negotiation"    \
                sessions_initiated                    "Number of Interfaces"             \
                client_max_setup_rate                 _placeholder                       \
                chap_auth_chal_tx                     _placeholder                       \
                chap_auth_chal_rx                     _placeholder                       \
                chap_auth_rsp_tx                      _placeholder                       \
                chap_auth_rsp_rx                      _placeholder                       \
                chap_auth_succ_tx                     _placeholder                       \
                chap_auth_succ_rx                     _placeholder                       \
                chap_auth_fail_tx                     _placeholder                       \
                chap_auth_fail_rx                     _placeholder                       \
                min_setup_time                        _placeholder                       \
                avg_setup_time                        _placeholder                       \
                max_setup_time                        _placeholder                       \
                lcp_min_latency                       _placeholder                       \
                lcp_avg_latency                       _placeholder                       \
                lcp_max_latency                       _placeholder                       \
                ncp_min_latency                       _placeholder                       \
                ncp_avg_latency                       _placeholder                       \
                ncp_max_latency                       _placeholder                       \
                pppoe_min_latency                     _placeholder                       \
                pppoe_avg_latency                     _placeholder                       \
                pppoe_max_latency                     _placeholder                       \
                pap_auth_req_tx                       _placeholder                       \
                pap_auth_req_rx                       _placeholder                       \
                pap_auth_ack_tx                       _placeholder                       \
                pap_auth_ack_rx                       _placeholder                       \
                pap_auth_nak_tx                       _placeholder                       \
                pap_auth_nak_rx                       _placeholder                       \
                echo_req_tx                           _placeholder                       \
                echo_req_rx                           _placeholder                       \
                echo_rsp_tx                           _placeholder                       \
                echo_rsp_rx                           _placeholder                       \
                code_rej_tx                           _placeholder                       \
                code_rej_rx                           _placeholder                       \
                ipcp_cfg_req_tx                       _placeholder                       \
                ipcp_cfg_req_rx                       _placeholder                       \
                ipcp_cfg_ack_tx                       _placeholder                       \
                ipcp_cfg_ack_rx                       _placeholder                       \
                ipcp_cfg_nak_tx                       _placeholder                       \
                ipcp_cfg_nak_rx                       _placeholder                       \
                ipcp_cfg_rej_tx                       _placeholder                       \
                ipcp_cfg_rej_rx                       _placeholder                       \
                ipv6cp_cfg_req_tx                     _placeholder                       \
                ipv6cp_cfg_req_rx                     _placeholder                       \
                ipv6cp_cfg_ack_tx                     _placeholder                       \
                ipv6cp_cfg_ack_rx                     _placeholder                       \
                ipv6cp_cfg_nak_tx                     _placeholder                       \
                ipv6cp_cfg_nak_rx                     _placeholder                       \
                ipv6cp_cfg_rej_tx                     _placeholder                       \
                ipv6cp_cfg_rej_rx                     _placeholder                       \
                success_setup_rate                    _placeholder                       \
                interfaces_teardown_rate              _placeholder                       \
                interfaces_in_pppoe_l2tp_negotiation  _placeholder                       \
                lcp_total_msg_tx                      _placeholder                       \
                lcp_total_msg_rx                      _placeholder                       \
                auth_total_tx                         _placeholder                       \
                auth_total_rx                         _placeholder                       \
                ncp_total_msg_tx                      _placeholder                       \
                ncp_total_msg_rx                      _placeholder                       \
                ppp_total_bytes_tx                    _placeholder                       \
                ppp_total_bytes_rx                    _placeholder                       \
                malformed_ppp_frames_used             _placeholder                       \
                malformed_ppp_frames_rejected         _placeholder                       \
                pppoe_total_bytes_tx                  _placeholder                       \
                pppoe_total_bytes_rx                  _placeholder                       \
                teardown_rate                         _placeholder                       \
                term_req_tx                           _placeholder                       \
                term_req_rx                           _placeholder                       \
                term_ack_tx                           _placeholder                       \
                term_ack_rx                           _placeholder                       \
                lcp_cfg_req_tx                        _placeholder                       \
                lcp_cfg_req_rx                        _placeholder                       \
                lcp_cfg_ack_tx                        _placeholder                       \
                lcp_cfg_ack_rx                        _placeholder                       \
                lcp_cfg_nak_tx                        _placeholder                       \
                lcp_cfg_nak_rx                        _placeholder                       \
                lcp_cfg_rej_tx                        _placeholder                       \
                lcp_cfg_rej_rx                        _placeholder                       \
                padi_tx                               _placeholder                       \
                padi_rx                               _placeholder                       \
                padi_timeout                          _placeholder                       \
                pado_tx                               _placeholder                       \
                pado_rx                               _placeholder                       \
                padr_tx                               _placeholder                       \
                padr_rx                               _placeholder                       \
                padr_timeout                          _placeholder                       \
                pads_tx                               _placeholder                       \
                pads_rx                               _placeholder                       \
                padt_tx                               _placeholder                       \
                padt_rx                               _placeholder                       \
            ]
            
            set stat_view_idx 0
            foreach small_handle $handle {
                lappend build_name "SessionView-[string trim [string range $small_handle [expr [string first "/range:" $small_handle] + 7] end] "\"\\"]"
                
                foreach {stat type} [array get stats_array_per_range_ixn] {
                    if {$type == "_placeholder"} {
                        set ret_code N/A
                    } else {
                        set ret_code 0
                    }
                    if {$stat_view_idx == 0} {
                        keylset returnList aggregate.$stat              $ret_code
                    }
                    keylset returnList ${small_handle}.aggregate.$stat  $ret_code
                }
                
                set num_sessions_status [ixNetworkGetNumSessions $small_handle]
                if {[keylget num_sessions_status status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to retrieve sum of all PPPoX sessions\
                            from range $small_handle. [keylget num_sessions_status log]"
                    return $returnList
                }
                set num_sessions [keylget num_sessions_status num_sessions]
                
                keylset returnList ${small_handle}.aggregate.num_sessions   $num_sessions
                keylset returnList ${small_handle}.aggregate.connected       0
                keylset returnList ${small_handle}.aggregate.connect_success 0
                keylset returnList ${small_handle}.aggregate.idle            0
                keylset returnList ${small_handle}.aggregate.connecting      "N/A"

                    
                if {$stat_view_idx == 0} {
                    keylset returnList aggregate.num_sessions   $num_sessions
                    keylset returnList aggregate.connected       0
                    keylset returnList aggregate.connect_success 0
                    keylset returnList aggregate.idle            0
                    keylset returnList aggregate.connecting      "N/A"
                }
                incr stat_view_idx
            }
            set drill_result [::ixia::CreateAndDrilldownViews $handle "handle_pr" $build_name "pppox"]
            
            if {[keylget drill_result drilldown_status] == 0} {
                return $returnList
            }
            if {[keylget drill_result status] == $::FAILURE} {
                return $drill_result
            }
            
            set stat_view_idx 0
            foreach stats_view_name $build_name small_handle $handle {
                set returned_stats_list [::ixia::540GetStatView $stats_view_name ""]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    debug "::ixia::540GetStatView $stats_view_name returned: [keylget returned_stats_list log]"
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to get '${stats_view_name}' stat view. Check if protocol is properly negotiated."
                    return $returnList
                }
                
                set pageCount [keylget returned_stats_list page]
                set rowCount  [keylget returned_stats_list row]
                catch {array unset rowsArray}
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
                        
                        foreach stat [array names stats_array_per_range_ixn] {
                            set ixn_stat $stats_array_per_range_ixn($stat)
                            if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                if {$stat_view_idx == 0} {
                                    keylset returnList aggregate.$stat $rowsArray($i,$j,$ixn_stat)
                                }
                                keylset returnList $small_handle.aggregate.$stat $rowsArray($i,$j,$ixn_stat)
                            } else {
                                if {[catch {keylget returnList aggregate.$stat}]} {
                                    if {$stat_view_idx == 0} {
                                        keylset returnList aggregate.$stat           "N/A"
                                    }
                                    keylset returnList $small_handle.aggregate.$stat "N/A"
                                }
                            }
                        }
                    }
                }
                
                if {[catch {keylset returnList $small_handle.aggregate.idle \
                        [expr [keylget returnList $small_handle.aggregate.num_sessions] - \
                        [keylget returnList $small_handle.aggregate.interfaces_in_ppp_negotiation] - \
                        [keylget returnList $small_handle.aggregate.sessions_up]]} retCode]} {
                    if {[string first N/A $retCode]} {
                        keylset returnList aggregate.idle N/A
                    } else {
                        keylset returnList status $FAILURE
                        keylset returnList log $retCode
                        return $returnList
                    }
                } elseif {$stat_view_idx == 0} {
                    keylset returnList aggregate.idle [keylget returnList $small_handle.aggregate.idle]
                }
    
                if {[catch {keylset returnList $small_handle.aggregate.connecting \
                        [keylget returnList $small_handle.aggregate.interfaces_in_ppp_negotiation]} retCode]} {
                    if {[string first N/A $retCode]} {
                        keylset returnList aggregate.connecting N/A
                    } else {
                        keylset returnList status $FAILURE
                        keylset returnList log $retCode
                        return $returnList
                    }
                } elseif {$stat_view_idx == 0} {
                    keylset returnList aggregate.connecting [keylget returnList $small_handle.aggregate.connecting]
                }
                
                incr stat_view_idx
            }
        }
        
    } elseif {$mode == "session" || $all_session_statistics == 1} {
        # Per session stats ----------------------------------------------------
        set stat_list_per_session [list                     \
            "Interface Identifier"                          \
            "Range Identifier"                              \
            "PPP State"                                     \
            "PPP Close Mode"                                \
            ]
        array set stats_array_per_session [list  \
            "Interface Identifier"          \
                "interface_id"              \
            "Range Identifier"              \
                "range_id"                  \
            "PPP State"                     \
                "pppoe_state"               \
            "PPP Close Mode"                \
                "close_mode"                \
            ]
        array set stats_array_per_session_ixn [list                                 \
            "port_name"                         "Port Name"                         \
            "ac_name"                           "AC Name"                           \
            "ac_offer_rx"                       "AC Offers Rx"                      \
            "auth_id"                           "Authentication ID"                 \
            "auth_password"                     "Authentication Password"           \
            "auth_protocol_rx"                  "Authentication Protocol Rx"        \
            "auth_protocol_tx"                  "Authentication Protocol Tx"        \
            "auth_total_rx"                     "Authentication Total Rx"           \
            "auth_total_tx"                     "Authentication Total Tx"           \
            "chap_auth_chal_rx"                 "CHAP Challenge Rx"                 \
            "chap_auth_chal_tx"                 "CHAP Challenge Tx"                 \
            "chap_auth_fail_rx"                 "CHAP Failure Rx"                   \
            "chap_auth_fail_tx"                 "CHAP Failure Tx"                   \
            "chap_auth_rsp_rx"                  "CHAP Response Rx"                  \
            "chap_auth_rsp_tx"                  "CHAP Response Tx"                  \
            "chap_auth_succ_rx"                 "CHAP Success Rx"                   \
            "chap_auth_succ_tx"                 "CHAP Success Tx"                   \
            "close_mode"                        "PPP Close Mode"                    \
            "code_rej_rx"                       "LCP Code Reject Rx"                \
            "code_rej_tx"                       "LCP Code Reject Tx"                \
            "echo_req_rx"                       "LCP Echo Request Rx"               \
            "echo_req_tx"                       "LCP Echo Request Tx"               \
            "echo_rsp_rx"                       "LCP Echo Response Rx"              \
            "echo_rsp_tx"                       "LCP Echo Response Tx"              \
            "ipcp_cfg_ack_rx"                   "IPCP Config ACK Rx"                \
            "ipcp_cfg_ack_tx"                   "IPCP Config ACK Tx"                \
            "ipcp_cfg_nak_rx"                   "IPCP Config NAK Rx"                \
            "ipcp_cfg_nak_tx"                   "IPCP Config NAK Tx"                \
            "ipcp_cfg_rej_rx"                   "IPCP Config Reject Rx"             \
            "ipcp_cfg_rej_tx"                   "IPCP Config Reject Tx"             \
            "ipcp_cfg_req_rx"                   "IPCP Config Request Rx"            \
            "ipcp_cfg_req_tx"                   "IPCP Config Request Tx"            \
            "ipcp_state"                        "IPCP State"                        \
            "ipv6cp_cfg_ack_rx"                 "IPv6CP Config ACK Rx"              \
            "ipv6cp_cfg_ack_tx"                 "IPv6CP Config ACK Tx"              \
            "ipv6cp_cfg_nak_rx"                 "IPv6CP Config NAK Rx"              \
            "ipv6cp_cfg_nak_tx"                 "IPv6CP Config NAK Tx"              \
            "ipv6cp_cfg_rej_rx"                 "IPv6CP Config Reject Rx"           \
            "ipv6cp_cfg_rej_tx"                 "IPv6CP Config Reject Tx"           \
            "ipv6cp_cfg_req_rx"                 "IPv6CP Config Request Rx"          \
            "ipv6cp_cfg_req_tx"                 "IPv6CP Config Request Tx"          \
            "ipv6cp_state"                      "IPv6CP State"                      \
            "lcp_cfg_ack_rx"                    "LCP Config ACK Rx"                 \
            "lcp_cfg_ack_tx"                    "LCP Config ACK Tx"                 \
            "lcp_cfg_nak_rx"                    "LCP Config NAK Rx"                 \
            "lcp_cfg_nak_tx"                    "LCP Config NAK Tx"                 \
            "lcp_cfg_rej_rx"                    "LCP Config Reject Rx"              \
            "lcp_cfg_rej_tx"                    "LCP Config Reject Tx"              \
            "lcp_cfg_req_rx"                    "LCP Config Request Rx"             \
            "lcp_cfg_req_tx"                    "LCP Config Request Tx"             \
            "term_ack_rx"                       "LCP Terminate ACK Rx"              \
            "term_ack_tx"                       "LCP Terminate ACK Tx"              \
            "term_req_rx"                       "LCP Terminate Request Rx"          \
            "term_req_tx"                       "LCP Terminate Request Tx"          \
            "lcp_total_msg_rx"                  "LCP Total Rx"                      \
            "lcp_total_msg_tx"                  "LCP Total Tx"                      \
            "malformed_ppp_frames_rejected"     "Malformed PPP Frames Rejected"     \
            "malformed_ppp_frames_used"         "Malformed PPP Frames Used"         \
            "ncp_total_msg_rx"                  "NCP Total Rx"                      \
            "ncp_total_msg_tx"                  "NCP Total Tx"                      \
            "padi_rx"                           "PADI Rx"                           \
            "padi_tx"                           "PADI Tx"                           \
            "padi_timeout"                      "PADI Timeouts"                     \
            "pado_rx"                           "PADO Rx"                           \
            "pado_tx"                           "PADO Tx"                           \
            "padr_rx"                           "PADR Rx"                           \
            "padr_tx"                           "PADR Tx"                           \
            "padr_timeout"                      "PADR Timeouts"                     \
            "pads_rx"                           "PADS Rx"                           \
            "pads_tx"                           "PADS Tx"                           \
            "padt_rx"                           "PADT Rx"                           \
            "padt_tx"                           "PADT Tx"                           \
            "pap_auth_ack_rx"                   "PAP Authentication ACK Rx"         \
            "pap_auth_ack_tx"                   "PAP Authentication ACK Tx"         \
            "pap_auth_nak_rx"                   "PAP Authentication NAK Rx"         \
            "pap_auth_nak_tx"                   "PAP Authentication NAK Tx"         \
            "pap_auth_req_rx"                   "PAP Authentication Request Rx"     \
            "pap_auth_req_tx"                   "PAP Authentication Request Tx"     \
            "pppoe_state"                       "PPPoE State"                       \
            "ppp_total_bytes_rx"                "PPP Total Bytes Rx"                \
            "ppp_total_bytes_tx"                "PPP Total Bytes Tx"                \
            "service_name"                      "Service Name"                      \
            "ac_cookie"                         "AC Cookie"                         \
            "ac_system_error"                   "AC System Error Occured"           \
            "ac_generic_error"                  "AC Generic Error Occured"          \
            "ac_cookie_tag_rx"                  "AC Cookie Tag Rx"                  \
            "ac_mac_addr"                       "AC MAC Address"                    \
            "ac_system_error_tag_rx"            "AC System Error Tag Rx"            \
            "chap_auth_role"                    "CHAP Authentication Role"          \
            "dns_server_list"                   "DNS Server List"                   \
            "discovery_start"                   "Discovery Start Time"              \
            "discovery_end"                     "Discovery End Time"                \
            "generic_error_tag_tx"              "Generic Error Tag Tx"              \
            "host_mac_addr"                     "Host MAC Address"                  \
            "ipv6_prefix_len"                   "IPv6 Prefix Length"                \
            "ipv6_addr"                         "IPv6 Address"                      \
            "ipv6cp_router_adv_rx"              "IPv6CP Router Advertisement Rx"    \
            "ipv6cp_router_adv_tx"              "IPv6CP Router Advertisement Tx"    \
            "interface_id"                      "Interface Identifier"              \
            "local_ip_addr"                     "Local IP Address"                  \
            "local_ipv6_iid"                    "Local IPv6 IID"                    \
            "lcp_protocol_rej_rx"               "LCP Protocol Reject Rx"            \
            "lcp_protocol_rej_tx"               "LCP Protocol Reject Tx"            \
            "loopback_detected"                 "Loopback Detected"                 \
            "mru"                               "MRU"                               \
            "mtu"                               "MTU"                               \
            "magic_no_negotiated"               "Magic Number Negotiated"           \
            "magic_no_rx"                       "Magic Number Rx"                   \
            "magic_no_tx"                       "Magic Number Tx"                   \
            "malformed_pppoe_frames_used"       "Malformed PPPoE Frames Used"       \
            "malformed_pppoe_frames_rejected"   "Malformed PPPoE Frames Rejected"   \
            "negotiation_start_ms"              "Negotiation Start Time \[ms\]"     \
            "negotiation_end_ms"                "Negotiation End Time \[ms\]"       \
            "peer_ipv6_iid"                     "Peer IPv6 IID"                     \
            "pppoe_total_bytes_rx"              "PPPoE Total Bytes Rx"              \
            "pppoe_total_bytes_tx"              "PPPoE Total Bytes Tx"              \
            "pppoe_state"                       "PPP state"                         \
            "range_id"                          "Range Identifier"                  \
            "remote_ip_addr"                    "Remote IP Address"                 \
            "relay_session_id_tag_rx"           "Relay Session ID Tag Rx"           \
            "service_name_error_tag_rx"         "Service Name Error Tag Rx"         \
            "session_id"                        "Session ID"                        \
            "vendor_specific_tag_rx"            "Vendor Specific Tag Rx"            \
            ]
        set latest [::ixia::540IsLatestVersion]
        if {$latest} {
            
            set ppp_stat_view_list [list]
            if {[info exists handle]} {
                foreach range_handle $handle {
                    set build_name "SessionView-[string trim [string range $range_handle [expr [string first "/range:" $range_handle] + 7] end] "\"\\"]"
                    # set proto_regex - this matches the protocol stack filter 
                    # for the custom view we are about to create
                    set proto_regex [ixNet getA $range_handle/pppoxRange -name]
                    set drill_result [::ixia::CreateAndDrilldownViews $range_handle handle $build_name "pppox" $proto_regex]
                    if {[keylget drill_result status] == $::FAILURE} {
                        return $drill_result
                    }
                    lappend ppp_stat_view_list $build_name
                }
            } else {
                foreach port $port_handle {
                    set build_name "SessionView-[regsub -all "/" $port "_"]"
                    set drill_result [::ixia::CreateAndDrilldownViews $port_handle port_handle $build_name "pppox"]
                    if {[keylget drill_result status] == $::FAILURE} {
                        return $drill_result
                    }
                    lappend ppp_stat_view_list $build_name
                }
            }
            
            foreach build_name $ppp_stat_view_list {
                set returned_stats_list [::ixia::540GetStatView $build_name $stat_list_per_session]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to get '${build_name}' stat view."
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
            set stats_view_name "PPPoX Per Session"
            set returned_stats_list [ixNetworkGetStats $stats_view_name $stat_list_per_session]
            if {[keylget returned_stats_list status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to get '${stats_view_name}' stat view."
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
                                keylset returnList session.$chassis_no/$card_no/$port_no/${session_no}.$stats_array_per_session($stat) \
                                        $rows_array($i,$stat)
                            } else {
                                keylset returnList session.$chassis_no/$card_no/$port_no/${session_no}.$stats_array_per_session($stat) "N/A"
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
            } ;# foreach ends
        } ;# NOT latest ends
    }
    
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
                # check if the port is client or server
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
                set ppp_port_role ""
                if {[llength $eth_obj] > 0 && $eth_obj != [ixNet getNull]} {
                    foreach eth_elem $eth_obj {
                        set pppox_obj [ixNet getL $eth_elem pppox]
                        if {[info exists pppox_obj] && [llength $pppox_obj] > 0 &&\
                                $pppox_obj != [ixNet getNull]} {
                            set l2tp_elem [ixNet getL $pppox_obj dhcpv6Client]
                            set ppp_port_role client
                            if {[llength $l2tp_elem]>0 && $l2tp_elem!=[ixNet getNull]} {
                                set ppp_port_role client
                                break
                            } else {
                                set l2tp_elem [ixNet getL $pppox_obj dhcpv6Server]
                                if {[llength $l2tp_elem]>0 && $l2tp_elem!=[ixNet getNull]} {
                                    set ppp_port_role server
                                    break
                                }
                            }
                        }
                    }
                }
                if {$ppp_port_role == "client"} {
                    if {$mode == "session_dhcpv6pd"} {
                        set drill_down_view_type "dhcpv6PdClient"
                    } else {
                        set drill_down_view_type "dhcpHosts"
                    }
                } elseif {$ppp_port_role == "server"} {
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
                if {$ppp_port_role == "client"} {
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
                    if {$ppp_port_role == "client"} {
                        set drill_down_view_type "dhcpv6PdClient"
                        set session_key_type [string tolower [regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]]
                        set build_name "SessionView-[regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]-[regsub -all "/" $port "_"]"
                        set drill_result [::ixia::CreateAndDrilldownViews $port port_handle $build_name $drill_down_view_type]
                        if {[keylget drill_result status] == $::FAILURE} {
                            return $drill_result
                        }
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
                set ppp_port_role ""
                if {[llength $eth_obj] > 0 && $eth_obj != [ixNet getNull]} {
                    foreach eth_elem $eth_obj {
                        set pppox_obj [ixNet getL $eth_elem pppox]
                        if {[info exists pppox_obj] && [llength $pppox_obj] > 0 &&\
                                $pppox_obj != [ixNet getNull]} {
                            set l2tp_elem [ixNet getL $pppox_obj dhcpv6Client]
                            set ppp_port_role client
                            if {[llength $l2tp_elem]>0 && $l2tp_elem!=[ixNet getNull]} {
                                set ppp_port_role client
                                break
                            } else {
                                set l2tp_elem [ixNet getL $pppox_obj dhcpv6Server]
                                if {[llength $l2tp_elem]>0 && $l2tp_elem!=[ixNet getNull]} {
                                    set ppp_port_role server
                                    break
                                }
                            }
                        }
                    }
                }
                if {$ppp_port_role == "client"} {
                    if {$mode == "session_dhcpv6pd"} {
                        set drill_down_view_type "dhcpv6PdClient"
                    } else {
                        set drill_down_view_type "dhcpHosts"
                    }
                } elseif {$ppp_port_role == "server"} {
                    if {$mode == "session_dhcp_hosts"} {
                        # host statistics are available only on client port
                        continue
                    }
                    set drill_down_view_type "dhcpv6Server"
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$port has no dhcpv6Pd configured."
                    return $returnList
                }
                set proto_regex [ixNet getA $small_handle/${drill_down_view_type}Range:1 -name]
                set build_name "SessionView-[regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]-[string trim [string range $small_handle [expr [string first "/range:" $small_handle] + 7] end] "\"\\"]"
                set drill_result [::ixia::CreateAndDrilldownViews $small_handle handle $build_name $drill_down_view_type $proto_regex]
                if {[keylget drill_result status] == $::FAILURE} {
                    return $drill_result
                }
                if {$ppp_port_role == "client"} {
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
                    if {$ppp_port_role == "client"} {
                        set drill_down_view_type "dhcpv6PdClient"
                        set session_key_type [string tolower [regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]]
                        set build_name "SessionView-[regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]-[regsub -all "/" $port "_"]"
                        set proto_regex [ixNet getA $small_handle/${drill_down_view_type}Range:1 -name]
                        set drill_result [::ixia::CreateAndDrilldownViews $small_handle handle $build_name $drill_down_view_type $proto_regex]
                        if {[keylget drill_result status] == $::FAILURE} {
                            return $drill_result
                        }
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

################################################################################

proc ::ixia::ixnetwork_pppoxRange_config {args} {
    set args [lindex $args 0]
    variable truth

    foreach pair $args {
        set [lindex $pair 0] [lindex $pair 1]
    }

    # In ixNetwork local is always client and peer is always server
    # We must switch these values because in HLT local is the port you are
    # configuring and peer is the other port.

    if {![info exists port_role] || $port_role == "access"} {
        set tmpRoleLocal "client"
        set tmpRolePeer "server"
    } else {
        set tmpRoleLocal "server"
        set tmpRolePeer "client"
    }

    array set pppox_range [list                                 \
            ac_select_mode      acOptions                       \
            auth_mode           authType                        \
            auth_req_timeout    authTimeout                     \
            config_req_timeout  lcpTimeout                      \
            echo_req            enableEchoReq                   \
            echo_req_interval   echoReqInterval                 \
            echo_rsp            enableEchoRsp                   \
            ip_cp               ncpType                         \
            ipcp_req_timeout    ncpTimeout                      \
            local_magic         useMagic                        \
            max_auth_req        authRetries                     \
            max_configure_req   lcpRetries                      \
            max_ipcp_req        ncpRetries                      \
            max_padi_req        padiRetries                     \
            max_padr_req        padrRetries                     \
            max_terminate_req   lcpTermRetries                  \
            padi_req_timeout    padiTimeout                     \
            padr_req_timeout    padrTimeout                     \
            password            {papPassword chapSecret}        \
            term_req_timeout    lcpTermTimeout                  \
            username            {papUser chapName}              \
            ac_name             acName                          \
            agent_circuit_id    agentCircuitId                  \
            agent_remote_id     agentRemoteId                   \
            domain_group_map    enableDomainGroups              \
            intermediate_agent  enableIntermediateAgentTags     \
            ipv6_pool_addr_prefix_len   ipv6AddrPrefixLen       \
            ipv6_pool_prefix    ipv6PoolPrefix                  \
            ipv6_pool_prefix_len    ipv6PoolPrefixLen           \
            padi_include_tag    enableIncludeTagInPadi          \
            pado_include_tag    enableIncludeTagInPado          \
            padr_include_tag    enableIncludeTagInPadr          \
            pads_include_tag    enableIncludeTagInPads          \
            ppp_local_ip        ${tmpRoleLocal}BaseIp           \
            ppp_local_ip_step   ${tmpRoleLocal}IpIncr           \
            ppp_local_iid       ${tmpRoleLocal}BaseIid          \
            ppp_peer_ip         ${tmpRolePeer}BaseIp            \
            ppp_peer_ip_step    ${tmpRolePeer}IpIncr            \
            ppp_peer_iid        ${tmpRolePeer}BaseIid           \
            redial              enableRedial                    \
            redial_max          redialMax                       \
            redial_timeout      redialTimeout                   \
            service_name        serviceName                     \
            service_type        serviceOptions                  \
            ac_select_list      ac_select_list                  \
            num_sessions        numSessions                     \
            enable_server_signal_loop_id     serverSignalLoopId \
            enable_client_signal_loop_id     clientSignalLoopId \
            enable_server_signal_loop_char   serverSignalLoopChar\
            enable_client_signal_loop_char   clientSignalLoopChar\
            actual_rate_upstream             actualRateUpstream \
            actual_rate_downstream           actualRateDownstream\
            enable_server_signal_iwf         serverSignalIwf    \
            enable_client_signal_iwf         clientSignalIwf    \
            enable_server_signal_loop_encap  serverSignalLoopEncapsulation\
            enable_client_signal_loop_encap  clientSignalLoopEncapsulation\
            data_link                        dataLink           \
            intermediate_agent_encap1        encaps1            \
            intermediate_agent_encap2        encaps2            \
            desired_mru_rate                 mtu                \
            enable_mru_negotiation           enableMru          \
            enable_max_payload               enableMaxPayload   \
            max_payload                      maxPayload         \
            ]

    set pppox_range_args [list max_ipcp_req service_name ipv6_pool_prefix_len \
            intermediate_agent domain_group_map ppp_local_ip max_padi_req     \
            echo_req_interval ipv6_pool_prefix                                \
            ipv6_pool_addr_prefix_len password config_req_timeout             \
            ip_cp local_magic padi_include_tag ac_name padr_req_timeout       \
            agent_circuit_id term_req_timeout max_terminate_req ac_select_list\
            agent_remote_id auth_mode ppp_local_iid auth_req_timeout          \
            ppp_peer_iid username redial ipcp_req_timeout service_type        \
            pado_include_tag ppp_peer_ip padi_req_timeout max_padr_req        \
            echo_rsp ppp_local_ip_step padr_include_tag redial_max            \
            ppp_peer_ip_step pads_include_tag echo_req max_auth_req           \
            max_configure_req redial_timeout ac_select_mode num_sessions      \
            enable_server_signal_loop_id enable_client_signal_loop_id         \
            enable_server_signal_loop_char enable_client_signal_loop_char     \
            actual_rate_upstream actual_rate_downstream max_payload           \
            enable_server_signal_iwf enable_client_signal_iwf                 \
            enable_server_signal_loop_encap enable_client_signal_loop_encap   \
            data_link intermediate_agent_encap1 intermediate_agent_encap2     \
            enable_max_payload enable_mru_negotiation desired_mru_rate        \
            ]


    set wildcard_params [list wildcard_pound_start \
                              wildcard_pound_end   \
                              wildcard_question_start \
                              wildcard_question_end   ]

    if {$mode == "add"} {
        foreach wcTmp $wildcard_params {
            if {![info exists $wcTmp]} {
                set $wcTmp 0
            }
        }

    }

    if {[info exists wildcard_pound_start] && [info exists wildcard_pound_end]} {
        set wildcard_pound_modulo [expr $wildcard_pound_end - \
                $wildcard_pound_start + 1]
        if {$mode == "modify"} {
            set username_wildcard 1
            set password_wildcard 1
        }
    }
    if {[info exists wildcard_question_start] && [info exists wildcard_question_end]} {
        set wildcard_question_modulo [expr $wildcard_question_end - \
                $wildcard_question_start + 1]
        if {$mode == "modify"} {
            set username_wildcard 1
            set password_wildcard 1
        }
    }

    if { [info exists username_wildcard] && [info exists username] && \
                $username_wildcard } {
        if {[info exists wildcard_pound_start] && [info exists wildcard_pound_end]} {
            set startValue [format "%i" $wildcard_pound_start]
            regsub -all "\#" $username "\%$startValue:$wildcard_pound_modulo:1i" \
                    username
        }
        if {[info exists wildcard_question_start] && [info exists wildcard_question_end]} {
            set startValue [format "%i" $wildcard_question_start]
            regsub -all {\?} $username "\%$startValue:$wildcard_question_modulo:1i" \
                    username
        }
    }
    if { [info exists password_wildcard] && [info exists password] \
            && $password_wildcard } {
        if {[info exists wildcard_pound_start] && [info exists wildcard_pound_end]} {
            set startValue [format "%i" $wildcard_pound_start]
            regsub -all "\#" $password "\%$startValue:$wildcard_pound_modulo:1i" \
                    password
        }
        if {[info exists wildcard_question_start] && [info exists wildcard_question_end]} {
            set startValue [format "%i" $wildcard_question_start]
            regsub -all {\?} $password "\%$startValue:$wildcard_question_modulo:1i" \
                    password
        }
    }

    set pppoxRangeAttr ""
    foreach pppox_range_opt $pppox_range_args {
        if {![info exists $pppox_range_opt] || [set $pppox_range_opt] == ""} {
            continue
        }
        set pppox_range_value [set $pppox_range_opt]
        switch -- $pppox_range_opt {
            intermediate_agent {
                append pppoxRangeAttr \
                        "-$pppox_range($pppox_range_opt) $pppox_range_value "
            }
            ac_select_mode {
                switch -- $pppox_range_value {
                    first_responding {
                        set tmpVal useFirstResponder
                    }
                    service_name {
                        set tmpVal matchServiceName
                    }
                    ac_name {
                        set tmpVal matchAcName
                    }
                    ac_mac {
                        set tmpVal matchAcMac
                    }
                }
                append pppoxRangeAttr \
                        "-$pppox_range($pppox_range_opt) $tmpVal "
            }
            auth_mode {
                switch -- $pppox_range_value {
                    none {
                        set tmpVal none
                    }
                    pap {
                        set tmpVal pap
                    }
                    chap {
                        set tmpVal chap
                    }
                    pap_or_chap {
                        set tmpVal papOrChap
                    }
                }
                append pppoxRangeAttr \
                        "-$pppox_range($pppox_range_opt) $tmpVal "
            }
            echo_req_interval {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $pppox_range_value "
            }
            echo_rsp {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $truth($pppox_range_value) "
            }
            ip_cp {
                switch -- $pppox_range_value {
                    ipv4_cp {
                        set tmpVal IPv4
                    }
                    ipv6_cp {
                        set tmpVal IPv6
                    }
                    dual_stack {
                        set tmpVal DualStack
                    }
                }
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $tmpVal "
            }
            username -
            password {
                set tmpVal $auth_mode
                switch -- $tmpVal {
                    none {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to configure \
                                -$pppox_range_opt when -auth_type is none."
                        return $returnList
                    }
                    pap {
                        append pppoxRangeAttr "-[lindex $pppox_range($pppox_range_opt) 0] \
                                $pppox_range_value "
                    }
                    chap {
                        append pppoxRangeAttr "-[lindex $pppox_range($pppox_range_opt) 1] \
                                $pppox_range_value "
                    }
                    pap_or_chap -
                    papOrChap {
                        append pppoxRangeAttr "-[lindex $pppox_range($pppox_range_opt) 0] \
                                $pppox_range_value "
                        append pppoxRangeAttr "-[lindex $pppox_range($pppox_range_opt) 1] \
                                $pppox_range_value "
                    }
                }
            }
            ac_name {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        \{$pppox_range_value\} "
            }
            ppp_peer_iid {
                regsub -all { } $pppox_range_value {:} pppox_range_value
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        \{$pppox_range_value\} "
            }
            agent_remote_id -
            agent_circuit_id -
            actual_rate_upstream -
            actual_rate_downstream {
                if {($mode == "add") && (![info exists intermediate_agent] || \
                        $intermediate_agent == 0)} {
                    continue
                }
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $pppox_range_value "
            }
            padi_include_tag -
            pado_include_tag -
            padr_include_tag -
            pads_include_tag -
            redial -
            echo_req -
            local_magic {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $truth($pppox_range_value) "
            }
            enable_server_signal_loop_id -
            enable_client_signal_loop_id -
            enable_server_signal_loop_char -
            enable_client_signal_loop_char -
            enable_server_signal_iwf -
            enable_client_signal_iwf -
            enable_server_signal_loop_encap -
            enable_client_signal_loop_encap {
                if {($mode == "add") && (![info exists intermediate_agent] || \
                        $intermediate_agent == 0)} {
                    continue
                }
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $truth($pppox_range_value) "
            }
            data_link {
                if {($mode == "add") && (![info exists intermediate_agent] || \
                        $intermediate_agent == 0)} {
                    continue
                }
                switch -- $pppox_range_value {
                    atm_aal5 {
                        set tmpVal "atmAal5"
                    }
                    ethernet {
                        set tmpVal "ethernet"
                    }
                }
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $tmpVal "
            }
            intermediate_agent_encap1 {
                if {($mode == "add") && (![info exists intermediate_agent] || \
                        $intermediate_agent == 0)} {
                    continue
                }
                switch -- $pppox_range_value {
                    na {
                        set tmpVal "na"
                    }
                    untagged_eth {
                        set tmpVal "untaggedEthernet"
                    }
                    single_tagged_eth {
                        set tmpVal "singleTaggedEthernet"
                    }
                }
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $tmpVal "
                
            }
            intermediate_agent_encap2 {
                if {($mode == "add") && (![info exists intermediate_agent] || \
                        $intermediate_agent == 0)} {
                    continue
                }
                switch -- $pppox_range_value {
                    na {
                        set tmpVal "na"
                    }
                    pppoa_llc {
                        set tmpVal "pppoaLlc"
                    }
                    pppoa_null {
                        set tmpVal "pppoaNull"
                    }
                    ipoa_llc {
                        set tmpVal "ipoaLlc"
                    }
                    ipoa_null {
                        set tmpVal "ipoaNull"
                    }
                    eth_aal5_llc_fcs {
                        set tmpVal "ethernetOverAal5LlcwFcs"
                    }
                    eth_aal5_llc_no_fcs {
                        set tmpVal "ethernetOverAal5LlcwoFcs"
                    }
                    eth_aal5_null_fcs {
                        set tmpVal "ethernetOverAal5NullwFcs"
                    }
                    eth_aal5_null_no_fcs {
                        set tmpVal "ethernetOverAal5NullwoFcs"
                    }
                }
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $tmpVal "
            }
            domain_group_map {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        \"true\" "
            }
            ipv6_pool_addr_prefix_len -
            ipv6_pool_prefix -
            ipv6_pool_prefix_len {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $pppox_range_value "
            }
            ppp_local_iid {
                regsub -all { } $pppox_range_value {:} pppox_range_value
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        \{$pppox_range_value\} "
            }
            redial_max -
            redial_timeout {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $pppox_range_value "
            }
            service_type {
                switch -- $pppox_range_value {
                    any {
                        set tmpVal anyService
                    }
                    name {
                        set tmpVal serviceName
                    }
                }
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $tmpVal "
            }
            service_name {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $pppox_range_value "
            }
            ipcp_req_timeout -
            auth_req_timeout -
            max_auth_req -
            config_req_timeout -
            max_configure_req -
            max_ipcp_req -
            max_padi_req -
            max_padr_req -
            max_terminate_req -
            padi_req_timeout -
            padr_req_timeout -
            term_req_timeout -
            mac_addr -
            ppp_peer_ip -
            ppp_peer_ip_step -
            ppp_local_ip -
            ppp_local_ip_step -
            mac_addr_step -
            num_sessions {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $pppox_range_value "
            }
            desired_mru_rate {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $pppox_range_value "
            }
            enable_mru_negotiation {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $truth($pppox_range_value) "
            }
            enable_max_payload {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $truth($pppox_range_value) "
            }
            max_payload {
                append pppoxRangeAttr "-$pppox_range($pppox_range_opt) \
                        $pppox_range_value "
            }
        }
    }


    if {[info exists ac_select_list] && $ac_select_list != ""} {
        if {$mode == "modify"} {
            debug "ixNet getAttribute $handle/pppoxRange -acOptions"
            if {[catch {ixNet getAttribute $handle/pppoxRange -acOptions} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ixNet getAttribute $handle/pppoxRange \
                        -acOptions returned $err."
                return $returnList
            }
            set ac_select_mode $err
        }
        switch -- $ac_select_mode {
            matchAcName -
            ac_name {
                set ac_name_args ""
                foreach acEntry [lindex $ac_select_list 0] {
                    regexp {[\s]*([^|]+)\|([0-9]+)} $acEntry dummy acName \
                            acPercentage
                    set tmp_args ""
                    append tmp_args "-acName $acName "
                    append tmp_args "-percentage $acPercentage "
                    append tmp_args "-select true"
                    lappend ac_name_args $tmp_args
                }
                if {$mode == "modify"} {
                    set result [ixNetworkNodeRemoveList $handle/pppoxRange \
                            { {child remove acName} {} } -commit]

                    if {[keylget result status] == $::FAILURE} {
                        return $result
                    }
                }
            }
            matchAcMac -
            ac_mac {
                set ac_mac_args ""
                foreach acEntry [lindex $ac_select_list 0] {
                    regexp {[\s]*([^|]+)\|([0-9]+)} $acEntry dummy acMac \
                            acPercentage
                    set tmp_args ""
                    append tmp_args "-acMac $acMac "
                    append tmp_args "-percentage $acPercentage "
                    append tmp_args "-select true"
                    lappend ac_mac_args $tmp_args
                }
                if {$mode == "modify"} {
                    set result [ixNetworkNodeRemoveList $handle/pppoxRange \
                            { {child remove acMac} {} } -commit]

                    if {[keylget result status] == $::FAILURE} {
                        return $result
                    }
                }
            }
            default {
                keylset returnList status $::FAILURE
                keylset returnList log "Argument -ac_select_mode must be \
                        \"ac_name\" or \"ac_mac\" in order to use -ac_select_list."
                return $returnList
            }
        }
    }

    # Domain setting if required
    if {[info exists domain_group_map]} {
        if {$mode == "modify"} {
            set result [ixNetworkNodeRemoveList $handle/pppoxRange \
                    { {child remove domainGroup} {} } -commit]

            if {[keylget result status] == $::FAILURE} {
                return $result
            }
        }
        set domain_group_args ""
        if {[llength [lindex $domain_group_map 0]] > 2} {
            set domain_group_map [list $domain_group_map]
        }
        foreach domain $domain_group_map {
            set tmp_args ""
            set domainName [lindex $domain 0]
            set ipAddresses  [lindex $domain 1]
            set baseName            [lindex [split [lindex $domainName 0] %] 0]
            set trailingName        [lindex [split [lindex $domainName 0] %] 1]
            set autoIncrement       [lindex $domainName 1]
            set startWidth          [lindex $domainName 2]
            set endWidth            [lindex $domainName 3]
            set incrementRepeat     [lindex $domainName 4]

            if {$startWidth == ""} {
                set startWidth 0
            }
            if {$endWidth == ""} {
                set endWidth 0
            }
            set incrementCount [expr $endWidth - $startWidth + 1]

            set domainConfigList [list baseName autoIncrement ipAddresses\
                    startWidth incrementCount incrementRepeat trailingName]

            foreach {domainConfig} $domainConfigList {
                if {[set $domainConfig] != ""} {
                    if {$domainConfig == "ipAddresses"} {
                        append tmp_args "-$domainConfig \{[set $domainConfig]\} "
                    } else {
                append tmp_args "-$domainConfig [set $domainConfig] "
            }
                }
            }

            lappend domain_group_args $tmp_args
        }
    }

    set result [::ixia::ixNetworkNodeSetAttr $handle/pppoxRange $pppoxRangeAttr \
            -commit]

    if {[keylget result status] != $::SUCCESS} {
        return $result
    }

    if {[info exists ac_name_args]} {
        foreach tmpAcName $ac_name_args {

            set result [::ixia::ixNetworkNodeAdd \
                    $handle/pppoxRange\
                    acName           \
                    $tmpAcName       \
                    -commit          \
                    ]

            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget result log]"
                return $returnList
            }
        }
    }

    if {[info exists ac_mac_args]} {
        foreach tmpAcMac $ac_mac_args {
            set result [::ixia::ixNetworkNodeAdd \
                    $handle/pppoxRange\
                    acMac            \
                    $tmpAcMac        \
                    -commit          \
                    ]

            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget result log]"
                return $returnList
            }
        }
    }

    if {[info exists domain_group_args]} {
        foreach tmpDomain $domain_group_args {
            set result [::ixia::ixNetworkNodeAdd \
                    $handle/pppoxRange\
                    domainGroup      \
                    $tmpDomain       \
                    -commit          \
                    ]

            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget result log]"
                return $returnList
            }
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_pppox_rollback {handle mode} {
    if {$mode == "add"} {
        upvar returnList retList
        set log [keylget retList log]
        
        set rmv_handle [ixNetworkGetParentObjref $handle range]
        
        if {$rmv_handle != [ixNet getNull]} {
        
            debug "ixNet remove $rmv_handle"
            if {[catch {ixNet remove $rmv_handle} err]} {
                append log ". Failed to remove object $rmv_handle - $err"
            } else {
                debug "ixNet commit"
                if {[catch {ixNet commit} err]} {
                    append log ". Failed to commit object $rmv_handle - $err"
                }
            }
            
            keylset retList log $log
        }
    }
}


proc ::ixia::ixnetwork_pppox_reset {handle_list {action "reset"}} {
    
    # action can be reset or reset_async
    
    keylset returnList status $::SUCCESS
    
    set commit_needed 0
    set aborted_handle_list ""
    foreach handle $handle_list {
        if {[string first "pppoxEndpoint" $handle] != -1} {
            
            # It's pppoxEndpoint object or one of it's child objects
            
            set abort_handle [ixNetworkGetParentObjref $handle "pppoxEndpoint"]
            if {$abort_handle == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to reset PPP. Invalid handle $handle"
                return $returnList
            }
        } else {
            
            # Get vport object ref
            
            set vport_handle [ixNetworkGetParentObjref $handle "vport"]
            if {$vport_handle == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to reset PPP. Invalid handle $handle"
                return $returnList
            }
            
            # Get pppoxEndpoint object handle
            set follow_objects [list protocolStack ethernet pppoxEndpoint]
            set parent_object $vport_handle
            set found 1
            foreach follow_obj $follow_objects {
                set ret_code [ixNetworkEvalCmd [list ixNet getList $parent_object $follow_obj]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to reset PPP on $handle. [keylget ret_code log]"
                    return $returnList
                }
                
                set child_object_list [keylget ret_code ret_val]
                if {[llength $child_object_list] == 0} {
                    set found 0
                    break
                }
                
                set parent_object [lindex $child_object_list 0]
                set abort_handle $parent_object
            }
            
            if {!$found} {
                # pppox not configured on this port
                continue
            }
        }
        
        # Do not replace this with lsearch. It won't work
        if {[string first $abort_handle $aborted_handle_list] != -1} {
            # handle was already aborted
            continue
        }

        lappend aborted_handle_list $abort_handle

        set cmd_abort [list ixNet exec abort $abort_handle]
        if {$action == "reset_async"} {
            lappend cmd_abort "async"
        }

        debug "$cmd_abort"
        if {[catch {eval $cmd_abort} status]} {
            if {[string first "no matching exec found" $status] != -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to reset PPP on $handle. Returned status: $status"
                return $returnList
            }
        } else {
            if {[string first "::ixNet::OK" $status] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to reset PPP on $handle. Returned status: $status"
                return $returnList
            }
        }

        # Remove handle
        debug "ixNet remove $abort_handle"
        if {[catch {ixNet remove $abort_handle} status]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to $action PPP. Could not\
                    remove object $abort_handle: $status"
            return $returnList
        }
        set commit_needed 1
    }
    
    if {$commit_needed} {
        debug "ixNet commit"
        set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to reset PPPoX handles.\
                    Commit returned error. [keylget $ret_code log]"
            return $returnList
        }
    }
    
    return $returnList
}


proc ::ixia::ixNetworkGetNumSessions {objref} {
    keylset returnList status $::SUCCESS
    
    if {[catch {set ::ixia::ixnetworkVersion} ixn_version]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get IxNetwork version - $ixn_version.\
                Possible causes: not connected to IxNetwork Tcl Server."
        return $returnList
    }
    
    if {![regexp {(^\d+)(\.)(\d+)} $ixn_version {} ixn_version_major {} ixn_version_minor]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get IxNetwork version major and minor - $ixn_version."
        return $returnList
    }
    
    set ixn_version ${ixn_version_major}.${ixn_version_minor}
    
    set num_sessions 0
    
    if {![regexp {^::ixNet::OBJ-/vport:\d+$} $objref]} {
        
        set range $objref
        
        set pppox_range [ixNet getList $range pppoxRange]
        if {$pppox_range != [ixNet getNull] && [llength $pppox_range] > 0} {
            set num_sessions [ixNet getAttribute $pppox_range -numSessions]
        }
        
    } else {
        set vport_objref $objref
        set eth_obj [ixNet getL $vport_objref/protocolStack ethernet]
        if {[llength $eth_obj] > 0 && $eth_obj != [ixNet getNull]} {
        
            # get first ethernet that might have pppox, fallback on first eth_obj
            set eth_tmp [lindex $eth_obj 0]
            foreach eth_elem $eth_obj {
                set pppox_obj [ixNet getL $eth_elem pppox]
                
                if {[info exists pppox_obj] && [llength $pppox_obj] > 0 &&\
                        $pppox_obj != [ixNet getNull]} {
                    set eth_tmp $eth_elem
                    break
                }
            }
            set eth_obj $eth_tmp
            
            if {$ixn_version >= "5.50"} {
                set pppox_obj [ixNet getL $eth_obj pppox]
                
                if {[info exists pppox_obj] && [llength $pppox_obj] > 0 &&\
                    $pppox_obj != [ixNet getNull]} {
                    
                    set dopppox_obj [ixNet getList $pppox_obj dhcpoPppClientEndpoint]
                    
                    if {[llength $dopppox_obj] == 0 || $dopppox_obj == [ixNet getNull]} {
                        set dopppox_obj [ixNet getList $pppox_obj dhcpoPppServerEndpoint]
                    }
                    
                    set pppox_obj $dopppox_obj
                }
            }
            
            if {![info exists pppox_obj] || [llength $pppox_obj] == 0 ||\
                    $pppox_obj == [ixNet getNull]} {
                
                set pppox_obj [ixNet getL $eth_obj pppoxEndpoint]
            }
        }
        
        if {![info exists pppox_obj] || [llength $pppox_obj] == 0 ||\
                $pppox_obj == [ixNet getNull]} {
                    
            set atm_obj [ixNet getL $vport_objref/protocolStack atm]
            if {[llength $atm_obj] > 0 && $atm_obj != [ixNet getNull]} {
            
                # get first atm that might have pppox, fallback on first atm_obj
                set atm_tmp [lindex $atm_obj 0]
                foreach atm_elem $atm_obj {
                    set pppox_obj [ixNet getL $atm_elem pppox]
                    
                    if {[info exists pppox_obj] && [llength $pppox_obj] > 0 &&\
                            $pppox_obj != [ixNet getNull]} {
                        set atm_tmp $atm_elem
                        break
                    }
                }
                set atm_obj $atm_tmp
                
                if {$ixn_version >= "5.60"} {
                    set pppox_obj [ixNet getL $atm_obj pppox]
                    
                    if {[info exists pppox_obj] && [llength $pppox_obj] > 0 &&\
                            $pppox_obj != [ixNet getNull]} {
                        
                        set dopppox_obj [ixNet getList $pppox_obj dhcpoPppClientEndpoint]
                        
                        if {[llength $dopppox_obj] == 0 || $dopppox_obj == [ixNet getNull]} {
                            set dopppox_obj [ixNet getList $pppox_obj dhcpoPppServerEndpoint]
                        }
                        
                        set pppox_obj $dopppox_obj
                    }
                }
                
                if {![info exists pppox_obj] || [llength $pppox_obj] == 0 ||\
                    $pppox_obj == [ixNet getNull]} {
                    
                    set pppox_obj [ixNet getL $atm_obj pppoxEndpoint]
                }
            }
        }
        
        if {[info exists pppox_obj] && [llength $pppox_obj] > 0 &&\
                $pppox_obj != [ixNet getNull]} {
            
            set range_list [ixNet getList $pppox_obj range]
            foreach range $range_list {
                set pppox_range [ixNet getList $range pppoxRange]
                if {$pppox_range != [ixNet getNull] && [llength $pppox_range] > 0} {
                    incr num_sessions [ixNet getAttribute $pppox_range -numSessions]
                }
            }
        }
    }
    
    keylset returnList num_sessions $num_sessions
    return $returnList
}
