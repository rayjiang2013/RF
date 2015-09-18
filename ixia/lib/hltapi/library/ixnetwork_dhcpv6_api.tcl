proc ::ixia::ixnetwork_dhcpv6_config {} {
    uplevel {
        # create vport/protocolStack/ethernet/pppox
        if {[info exists dhcpv6pd_type] && $dhcpv6_hosts_enable==1} {
            set result [ixNetworkGetSMPlugin $port_handle $stack_type "pppox"]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
            set node_objref [keylget result ret_val]
        } elseif {[info exists mode] && ($mode == "lac" || $mode == "lns")} {
            set l2tp_obj_ref [ixNet getL $ip_objref l2tp]
            if {$l2tp_obj_ref == [ixNet getNull] || $l2tp_obj_ref == ""} {
                set result [ixNetworkNodeAdd $ip_objref l2tp {} -commit]
                if {[keylget result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : [keylget result log]"
                    return $returnList
                }
                set node_objref [keylget result node_objref]
            } else {
                set node_objref $l2tp_obj_ref
            }
        }
        # pppox element
        if {![info exists dhcpv6pd_type]} {
            set dhcp_obj_type dhcpv6Client
        } elseif {$dhcpv6pd_type == "client"} {
            set dhcp_obj_type dhcpv6Client
        } else {
            set dhcp_obj_type dhcpv6Server
        }
        # l2tp element
        if {[info exists mode] && ($mode == "lac")} {
            set dhcp_obj_type dhcpv6Client
        } elseif {[info exists mode] && ($mode == "lns")} {
            set dhcp_obj_type dhcpv6Server
        }
        set dhcp_host_options_var [::ixia::ixNetworkNodeGetList [ixNetworkGetParentObjref $node_objref "protocolStack"] dhcpHostsOptions]
        if {($dhcp_host_options_var == [ixNet getNull] || $dhcp_host_options_var == "")\
                && ($dhcp_obj_type == "dhcpv6Client")} {
            set result [::ixia::ixNetworkNodeAdd \
                    [ixNetworkGetParentObjref $node_objref "protocolStack"]     \
                    dhcpHostsOptions            \
                    {}     \
                    -commit          \
                    ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
        }
        set dhcpv6_obj_handles [::ixia::ixNetworkNodeGetList $node_objref $dhcp_obj_type]
        if {$dhcpv6_obj_handles == [ixNet getNull] || $dhcpv6_obj_handles == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $node_objref     \
                    $dhcp_obj_type    \
                    {}     \
                    -commit          \
                    ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget result log]"
                return $returnList
            }
        }
        # pppox element
        if {![info exists dhcpv6pd_type] || $dhcpv6pd_type == "client"} {
            set dhcp_obj_type dhcpoPppClientEndpoint
        } else {
            set dhcp_obj_type dhcpoPppServerEndpoint
        }
        # l2tp element
        if {[info exists mode] && ($mode == "lac")} {
            set dhcp_obj_type dhcpoLacEndpoint
        } elseif {[info exists mode] && ($mode == "lns")} {
            set dhcp_obj_type dhcpoLnsEndpoint
        }
        set dhcpv6_obj_handles [::ixia::ixNetworkNodeGetList $node_objref $dhcp_obj_type]
        if {$dhcpv6_obj_handles == [ixNet getNull] || $dhcpv6_obj_handles == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $node_objref     \
                    $dhcp_obj_type    \
                    {}     \
                    -commit          \
                    ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget result log]"
                return $returnList
            }
            set node_objref [keylget result node_objref]
        } else {
                set node_objref [::ixia::ixNetworkNodeGetList $node_objref $dhcp_obj_type]
        }
        keylset returnList node_objref $node_objref
        keylset returnList status $::SUCCESS
        return $returnList
    }
}



proc ::ixia::ixnetwork_dhcpv6_range_config {} {
    uplevel {
        #####################################
        ## Configure dhcpv6PdClientRange   ##
        #####################################
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
        
        # the fourth column represents the dhcp object type - client or server
        # we use this column to prevent the usage of server parameters on client
        # objects, and viceversa
        set dhcpv6_pd_cr_param_map {
            dhcp6DuidEnterpriseId       dhcp6_pd_client_range_duid_enterprise_id       value                dhcpv6PdClientRange
            dhcp6DuidType               dhcp6_pd_client_range_duid_type                translate            dhcpv6PdClientRange
            dhcp6DuidVendorId           dhcp6_pd_client_range_duid_vendor_id           value                dhcpv6PdClientRange
            dhcp6DuidVendorIdIncrement  dhcp6_pd_client_range_duid_vendor_id_increment value                dhcpv6PdClientRange
            dhcp6IaId                   dhcp6_pd_client_range_ia_id                    value                dhcpv6PdClientRange
            dhcp6IaIdIncrement          dhcp6_pd_client_range_ia_id_increment          value                dhcpv6PdClientRange
            dhcp6IaT1                   dhcp6_pd_client_range_ia_t1                    value                dhcpv6PdClientRange
            dhcp6IaT2                   dhcp6_pd_client_range_ia_t2                    value                dhcpv6PdClientRange
            dhcp6IaType                 dhcp6_pd_client_range_ia_type                  translate            dhcpv6PdClientRange
            dhcp6ParamRequestList       dhcp6_pd_client_range_param_request_list       semicolon_list       dhcpv6PdClientRange
            renewTimer                  dhcp6_pd_client_range_renew_timer              value                dhcpv6PdClientRange
            useVendorClassId            dhcp6_pd_client_range_use_vendor_class_id      translate            dhcpv6PdClientRange
            vendorClassId               dhcp6_pd_client_range_vendor_class_id          value                dhcpv6PdClientRange
            ipAddress                   dhcp6_pd_server_range_start_pool_address       value                dhcpv6ServerRange
            ipPrefix                    dhcp6_pd_server_range_subnet_prefix            value                dhcpv6ServerRange
            ipDns1                      dhcp6_pd_server_range_first_dns_server         value                dhcpv6ServerRange
            ipDns2                      dhcp6_pd_server_range_second_dns_server        value                dhcpv6ServerRange
            dnsDomain                   dhcp6_pd_server_range_dns_domain_search_list   value                dhcpv6ServerRange
        }
        
        if {![info exists dhcpv6pd_type]} {
            set dhcp_obj_type dhcpv6PdClientRange
        } elseif {$dhcpv6pd_type == "client"} {
            set dhcp_obj_type dhcpv6PdClientRange
        } else {
            set dhcp_obj_type dhcpv6ServerRange
        }
        
        if {[info exists mode] && ($mode == "lac")} {
            set dhcp_obj_type dhcpv6PdClientRange
        } elseif {[info exists mode] && ($mode == "lns")} {
            set dhcp_obj_type dhcpv6ServerRange
        }
        
        set ixn_args ""
        foreach {ixn_p hlt_p p_type o_type} $dhcpv6_pd_cr_param_map {
            if {[info exists $hlt_p] && ($o_type == $dhcp_obj_type)} {
                
                set hlt_p_val [set $hlt_p]
                switch -- $p_type {
                    value {
                        set ixn_p_val $hlt_p_val
                    }
                    translate {
                        if {[info exists translate_array($hlt_p_val)]} {
                            set ixn_p_val $translate_array($hlt_p_val)
                        } else {
                            set ixn_p_val $hlt_p_val
                        }
                    }
                    semicolon_list {
                        regsub -all { } $hlt_p_val {; } ixn_p_val
                    }
                    default {
                        set ixn_p_val $hlt_p_val
                    }
                }
                
                lappend ixn_args -$ixn_p $ixn_p_val
            }
        }
        set dhcpv6_obj_handles [::ixia::ixNetworkNodeGetList $handle $dhcp_obj_type]
        if {$dhcpv6_obj_handles == [ixNet getNull] || $dhcpv6_obj_handles == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $handle     \
                    $dhcp_obj_type    \
                    $ixn_args     \
                    -commit          \
                    ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
            
        } else {
            if {[llength $ixn_args] > 0} {
                set result [::ixia::ixNetworkNodeSetAttr \
                        [::ixia::ixNetworkNodeGetList $handle $dhcp_obj_type] \
                        $ixn_args        \
                        -commit          \
                    ]
                    
                if {[keylget result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : [keylget result log]"
                    return $returnList
                }
            }
        }
        
        #####################################
        ## Configure dhcpHostsRange        ##
        #####################################
        
        set dhcp_hr_param_map {
            count                  hosts_range_count             value                both
            euiIncrement           hosts_range_eui_increment     eui_transform        both
            firstEui               hosts_range_first_eui         eui_transform        both
            ipPrefix               hosts_range_ip_prefix         value                both
            subnetCount            hosts_range_subnet_count      value                both
            ipPrefixAddr           hosts_range_ip_prefix_addr    value                staticHostsRange
            ipPrefixPrefix         hosts_range_ip_outer_prefix   value                staticHostsRange
        }
        # pppox element
        if {![info exists dhcpv6pd_type]} {
            set dhcp_obj_type dhcpHostsRange
        } elseif {$dhcpv6pd_type == "client"} {
            set dhcp_obj_type dhcpHostsRange
        } else {
            set dhcp_obj_type staticHostsRange
        }
        # l2tp element
        if {[info exists mode] && ($mode == "lac")} {
            set dhcp_obj_type dhcpHostsRange
        } elseif {[info exists mode] && ($mode == "lns")} {
            set dhcp_obj_type staticHostsRange
        }
        set ixn_args ""
        set valid_eui_regexp {^([A-Fa-f0-9]{2,2}[ .:]){7,7}([A-Fa-f0-9]{2,2})$}
        foreach {ixn_p hlt_p p_type o_type} $dhcp_hr_param_map {
            if {[info exists $hlt_p] && ($o_type == $dhcp_obj_type || $o_type == "both")} {
                
                set hlt_p_val [set $hlt_p]
                
                switch -- $p_type {
                    value {
                        set ixn_p_val $hlt_p_val
                    }
                    eui_transform {
                        # for staticHostsRange instead of EUI64 IxNetwork expects
                        # an IPV6 address. Parsedashedargs alreay validated for 
                        # IPV6 or EUI64 format. If the $dhcp_obj_type is different
                        # then staticHostsRange then we need do validate here for 
                        # EUI64 value.
                            regsub -all {[ :.]} $hlt_p_val : ixn_p_val
                            debug "$dhcp_obj_type EUI64 -> $ixn_p_val"
                        if { $dhcp_obj_type != "staticHostsRange" } {
                            if {![regexp $valid_eui_regexp $hlt_p_val]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName : \
                                        $hlt_p_val is not a valid EUI value. Please\
                                        see documentation for expected format."
                                return $returnList
                            }
                        }
                    }
                    default {
                        set ixn_p_val $hlt_p_val
                    }
                }
                
                lappend ixn_args -$ixn_p $ixn_p_val
            }
        }
        set dhcpv6_obj_handles [::ixia::ixNetworkNodeGetList $handle $dhcp_obj_type]
        if {$dhcpv6_obj_handles == [ixNet getNull] || $dhcpv6_obj_handles == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $handle     \
                    $dhcp_obj_type    \
                    $ixn_args     \
                    -commit          \
                    ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
            
        } else {
            if {[llength $ixn_args] > 0} {
                set result [::ixia::ixNetworkNodeSetAttr \
                        [::ixia::ixNetworkNodeGetList $handle $dhcp_obj_type] \
                        $ixn_args        \
                        -commit          \
                    ]
                    
                if {[keylget result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : [keylget result log]"
                    return $returnList
                }
            }
        }
        
        ###########################################
        ## Configure dhcpv6PDClientOptions ##
        ###########################################
        
        set dhcpv6_pgd_param_map {
            maxOutstandingReleases     dhcp6_pgdata_max_outstanding_releases            value
            maxOutstandingRequests     dhcp6_pgdata_max_outstanding_requests            value
            overrideGlobalSetupRate    dhcp6_pgdata_override_global_setup_rate          translate
            overrideGlobalTeardownRate dhcp6_pgdata_override_global_teardown_rate       translate
            setupRateIncrement         dhcp6_pgdata_setup_rate_increment                value
            setupRateInitial           dhcp6_pgdata_setup_rate_initial                  value
            setupRateMax               dhcp6_pgdata_setup_rate_max                      value
            teardownRateIncrement      dhcp6_pgdata_teardown_rate_increment             value
            teardownRateInitial        dhcp6_pgdata_teardown_rate_initial               value
            teardownRateMax            dhcp6_pgdata_teardown_rate_max                   value
        }
        
        set ixn_args ""
        foreach {ixn_p hlt_p p_type} $dhcpv6_pgd_param_map {
            if {[info exists $hlt_p]} {
                
                set hlt_p_val [set $hlt_p]
                
                switch -- $p_type {
                    value {
                        set ixn_p_val $hlt_p_val
                    }
                    translate {
                        if {[info exists translate_array($hlt_p_val)]} {
                            set ixn_p_val $translate_array($hlt_p_val)
                        } else {
                            set ixn_p_val $hlt_p_val
                        }
                    }
                    default {
                        set ixn_p_val $hlt_p_val
                    }
                }
                
                lappend ixn_args -$ixn_p $ixn_p_val
            }
        }
        set pg_handle [ixNetworkGetParentObjref $handle "protocolStack"]
        
        # pppox element
        if {![info exists dhcpv6pd_type]} {
            set dhcp_obj_type PdClient
        } elseif {$dhcpv6pd_type == "client"} {
            set dhcp_obj_type PdClient
        } else {
            set dhcp_obj_type Server
        }
        # l2tp element
        if {[info exists mode] && ($mode == "lac")} {
            set dhcp_obj_type PdClient
        } elseif {[info exists mode] && ($mode == "lns")} {
            set dhcp_obj_type Server
        }
        set dhcpv6_options_handles [::ixia::ixNetworkNodeGetList $pg_handle dhcpv6${dhcp_obj_type}Options]
        if {$dhcpv6_options_handles == [ixNet getNull] || $dhcpv6_options_handles == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $pg_handle     \
                    dhcpv6${dhcp_obj_type}Options    \
                    $ixn_args     \
                    -commit          \
                    ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
            
        } else {
            if {[llength $ixn_args] > 0} {
                set result [::ixia::ixNetworkNodeSetAttr \
                        [::ixia::ixNetworkNodeGetList $pg_handle dhcpv6${dhcp_obj_type}Options] \
                        $ixn_args        \
                        -commit          \
                    ]
                if {[keylget result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : [keylget result log]"
                    return $returnList
                }
            }
        }
        #####################################
        ## Configure dhcpv6PDClientGlobals ##
        #####################################
        
        if {$dhcp_obj_type == "PdClient"} {
            set dhcpv6_glbl_param_map {
                dhcp6EchoIaInfo         dhcp6_global_echo_ia_info                 translate
                maxOutstandingReleases  dhcp6_global_max_outstanding_releases     value
                maxOutstandingRequests  dhcp6_global_max_outstanding_requests     value
                dhcp6RebMaxRt           dhcp6_global_reb_max_rt                   value
                dhcp6RebTimeout         dhcp6_global_reb_timeout                  value
                dhcp6RelMaxRc           dhcp6_global_rel_max_rc                   value
                dhcp6RelTimeout         dhcp6_global_rel_timeout                  value
                dhcp6RenMaxRt           dhcp6_global_ren_max_rt                   value
                dhcp6RenTimeout         dhcp6_global_ren_timeout                  value
                dhcp6ReqMaxRc           dhcp6_global_req_max_rc                   value
                dhcp6ReqMaxRt           dhcp6_global_req_max_rt                   value
                dhcp6ReqTimeout         dhcp6_global_req_timeout                  value
                dhcp6SolMaxRc           dhcp6_global_sol_max_rc                   value
                dhcp6SolMaxRt           dhcp6_global_sol_max_rt                   value
                dhcp6SolTimeout         dhcp6_global_sol_timeout                  value
                setupRateIncrement      dhcp6_global_setup_rate_increment         value
                setupRateInitial        dhcp6_global_setup_rate_initial           value
                setupRateMax            dhcp6_global_setup_rate_max               value
                teardownRateIncrement   dhcp6_global_teardown_rate_increment      value
                teardownRateInitial     dhcp6_global_teardown_rate_initial        value
                teardownRateMax         dhcp6_global_teardown_rate_max            value
                waitForCompletion       dhcp6_global_wait_for_completion          translate
            }
        } else {
            set dhcpv6_glbl_param_map {
                defaultLeaseTime        lease_time                                value
                maxLeaseTime            lease_time_max                            value
            }
        }
        
        set ixn_args ""
        foreach {ixn_p hlt_p p_type} $dhcpv6_glbl_param_map {
            if {[info exists $hlt_p]} {
                
                set hlt_p_val [set $hlt_p]
                
                switch -- $p_type {
                    value {
                        set ixn_p_val $hlt_p_val
                    }
                    translate {
                        if {[info exists translate_array($hlt_p_val)]} {
                            set ixn_p_val $translate_array($hlt_p_val)
                        } else {
                            set ixn_p_val $hlt_p_val
                        }
                    }
                    default {
                        set ixn_p_val $hlt_p_val
                    }
                }
                
                lappend ixn_args -$ixn_p $ixn_p_val
            }
        }
        
        set glbl_handle "::ixNet::OBJ-/globals/protocolStack"
        set dhcpv6_obj_handles [::ixia::ixNetworkNodeGetList $glbl_handle dhcpv6${dhcp_obj_type}Globals]
        if {$dhcpv6_obj_handles == [ixNet getNull] || $dhcpv6_obj_handles == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $glbl_handle        \
                    dhcpv6${dhcp_obj_type}Globals    \
                    $ixn_args           \
                    -commit             \
                ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
            
        } else {
            if {[llength $ixn_args] > 0} {
                set result [::ixia::ixNetworkNodeSetAttr \
                        [::ixia::ixNetworkNodeGetList $glbl_handle dhcpv6${dhcp_obj_type}Globals] \
                        $ixn_args        \
                        -commit          \
                    ]
                    
                if {[keylget result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : [keylget result log]"
                    return $returnList
                }
            }
        }
        
        ################################
        ## Configure dhcpHostsGlobals ##
        ################################
        set dhcp_hosts_globals_handles [::ixia::ixNetworkNodeGetList $glbl_handle dhcpHostsGlobals]
        if {($dhcp_obj_type == "PdClient") && ($dhcp_hosts_globals_handles == [ixNet getNull] ||\
                $dhcp_hosts_globals_handles == "")} {
            set result [::ixia::ixNetworkNodeAdd \
                    $glbl_handle        \
                    dhcpHostsGlobals    \
                    {}                  \
                    -commit             \
                ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
            
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}



















## Internal Procedure Header
# Name:
#    ::ixia::dhcpv6_config
#
# Description:
#    Configures DHCPV6oPPPClient / DHCPV6oPPPserver or DHCPV6oLAC / DHCPV6oLNS
#
# Synopsis:
#    ::ixia::l2tp_config
#        -handle                        handle
#        -mode                          CHOICES     lac lns ppp_client ppp_server
#x       [-dhcpv6_hosts_enable                            CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-dhcp6_pd_client_range_duid_enterprise_id       RANGE   1-2147483647
#x                                                        DEFAULT 10]
#x       [-dhcp6_pd_client_range_duid_type                CHOICES duid_en duid_llt duid_ll
#x                                                        DEFAULT duid_llt]
#x       [-dhcp6_pd_client_range_duid_vendor_id           RANGE   1-2147483647
#x                                                        DEFAULT 10]
#x       [-dhcp6_pd_client_range_duid_vendor_id_increment RANGE   1-2147483647
#x                                                        DEFAULT 1]
#x       [-dhcp6_pd_client_range_ia_id                    RANGE   1-2147483647
#x                                                        DEFAULT 10]
#x       [-dhcp6_pd_client_range_ia_id_increment          RANGE   1-2147483647
#x                                                        DEFAULT 1]
#x       [-dhcp6_pd_client_range_ia_t1                    RANGE   0-2147483647
#x                                                        DEFAULT 302400]
#x       [-dhcp6_pd_client_range_ia_t2                    RANGE   0-2147483647
#x                                                        DEFAULT 483840]
#x       [-dhcp6_pd_client_range_ia_type                  CHOICES iapd
#x                                                        DEFAULT iapd]
#x       [-dhcp6_pd_client_range_param_request_list       NUMERIC
#x                                                        DEFAULT {2 7 23 24}]
#x       [-dhcp6_pd_client_range_renew_timer              RANGE   0-1000000000
#x                                                        DEFAULT 0]
#x       [-dhcp6_pd_client_range_use_vendor_class_id      CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-dhcp6_pd_client_range_vendor_class_id          ANY
#x                                                        DEFAULT "Ixia DHCP Client"]
#x       [-dhcp6_pgdata_max_outstanding_releases          RANGE   1-100000
#x                                                        DEFAULT 500]
#x       [-dhcp6_pgdata_max_outstanding_requests          RANGE   1-100000
#x                                                        DEFAULT 20]
#x       [-dhcp6_pgdata_override_global_setup_rate        CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-dhcp6_pgdata_override_global_teardown_rate     CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-dhcp6_pgdata_setup_rate_increment              RANGE   0-100000
#x                                                        DEFAULT 0]
#x       [-dhcp6_pgdata_setup_rate_initial                RANGE   1-100000
#x                                                        DEFAULT 10]
#x       [-dhcp6_pgdata_setup_rate_max                    RANGE   1-100000
#x                                                        DEFAULT 10]
#x       [-dhcp6_pgdata_teardown_rate_increment           RANGE   0-100000
#x                                                        DEFAULT 50]
#x       [-dhcp6_pgdata_teardown_rate_initial             RANGE   1-100000
#x                                                        DEFAULT 50]
#x       [-dhcp6_pgdata_teardown_rate_max                 RANGE   1-100000
#x                                                        DEFAULT 500]
#x       [-dhcp6_global_echo_ia_info                      CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-dhcp6_global_max_outstanding_releases          RANGE   1-100000
#x                                                        DEFAULT 500]
#x       [-dhcp6_global_max_outstanding_requests          RANGE   1-100000
#x                                                        DEFAULT 20]
#x       [-dhcp6_global_reb_max_rt                        RANGE   1-10000
#x                                                        DEFAULT 500]
#x       [-dhcp6_global_reb_timeout                       RANGE   1-100
#x                                                        DEFAULT 10]
#x       [-dhcp6_global_rel_max_rc                        RANGE   1-100
#x                                                        DEFAULT 5]
#x       [-dhcp6_global_rel_timeout                       RANGE   1-100
#x                                                        DEFAULT 1]
#x       [-dhcp6_global_ren_max_rt                        RANGE   1-10000
#x                                                        DEFAULT 600]
#x       [-dhcp6_global_ren_timeout                       RANGE   1-100
#x                                                        DEFAULT 10]
#x       [-dhcp6_global_req_max_rc                        RANGE   1-100
#x                                                        DEFAULT 10]
#x       [-dhcp6_global_req_max_rt                        RANGE   1-10000
#x                                                        DEFAULT 30]
#x       [-dhcp6_global_req_timeout                       RANGE   1-100
#x                                                        DEFAULT 1]
#x       [-dhcp6_global_setup_rate_increment              RANGE   -10000-100000
#x                                                        DEFAULT 0]
#x       [-dhcp6_global_setup_rate_initial                RANGE   1-100000
#x                                                        DEFAULT 10]
#x       [-dhcp6_global_setup_rate_max                    RANGE   1-100000
#x                                                        DEFAULT 10]
#x       [-dhcp6_global_sol_max_rc                        RANGE   1-100
#x                                                        DEFAULT 3]
#x       [-dhcp6_global_sol_max_rt                        RANGE   1-10000
#x                                                        DEFAULT 120]
#x       [-dhcp6_global_sol_timeout                       RANGE   1-100
#x                                                        DEFAULT 4]
#x       [-dhcp6_global_teardown_rate_increment           RANGE   -10000-100000
#x                                                        DEFAULT 50]
#x       [-dhcp6_global_teardown_rate_initial             RANGE   1-100000
#x                                                        DEFAULT 50]
#x       [-dhcp6_global_teardown_rate_max                 RANGE   1-100000
#x                                                        DEFAULT 500]
#x       [-dhcp6_global_wait_for_completion               CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-hosts_range_count                              RANGE   1-1000000
#x                                                        DEFAULT 1]
#x       [-hosts_range_eui_increment                      REGEXP  ^([A-Fa-f0-9]{2,2}[ .:]){7,7}([A-Fa-f0-9]{2,2})$
#x                                                        DEFAULT {00 00 00 00 00 00 00 01}]
#x       [-hosts_range_first_eui                          REGEXP  ^([A-Fa-f0-9]{2,2}[ .:]){7,7}([A-Fa-f0-9]{2,2})$
#x                                                        DEFAULT {00 00 00 00 00 00 11 11}]
#x       [-hosts_range_ip_prefix                          RANGE   64-128
#x                                                        DEFAULT 64]
#x       [-hosts_range_subnet_count                       RANGE   1-32]
#x       [-dhcp6_pd_server_range_dns_domain_search_list   ANY]
#x       [-dhcp6_pd_server_range_first_dns_server         IP]
#x       [-hosts_range_ip_outer_prefix                    NUMERIC
#x                                                        DEFAULT 64]
#x       [-hosts_range_ip_prefix_addr                     IP]
#x       [-dhcp6_pd_server_range_second_dns_server        IP]
#x       [-dhcp6_pd_server_range_subnet_prefix            NUMERIC]
#x       [-dhcp6_pd_server_range_start_pool_address       IP]
#x                                      DEFAULT 0]
#x       [-lease_time_max               RANGE   300-30000000
#x                                      DEFAULT 864000]
#x       [-lease_time                   RANGE   300-30000000
#x                                      DEFAULT 864000]
#
# Arguments:
#x   -dhcpv6_hosts_enable
#x       Valid choices are:
#x       0 – Configure standard PPPoE 
#x       1 – Enable using DHCPv6 hosts behind PPP CPE feature.
#x       (DEFAULT = 0)
#x   -dhcp6_global_echo_ia_info
#x       If 1 the DHCPv6 client will request the exact address as advertised by the server. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’. 
#x       Valid choices are:
#x          0 - (DEFAULT) Disabled
#x          1 - Enabled
#x   -dhcp6_global_max_outstanding_releases
#x       The maximum number of requests to be sent by all DHCP clients during session 
#x       teardown. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 500)
#x   -dhcp6_global_max_outstanding_requests
#x       The maximum number of requests to be sent by all DHCP clients during session 
#x       startup. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 20)
#x   -dhcp6_global_reb_max_rt
#x       RFC 3315 max rebind timeout value in seconds. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.  
#x       (DEFAULT = 500)
#x   -dhcp6_global_reb_timeout
#x       RFC 3315 initial rebind timeout value in seconds. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’. 
#x       (DEFAULT = 10)
#x   -dhcp6_global_rel_max_rc
#x       RFC 3315 release attempts. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’. 
#x       (DEFAULT = 5)
#x   -dhcp6_global_rel_timeout
#x       RFC 3315 initial release timeout in seconds. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 1)
#x   -dhcp6_global_ren_max_rt
#x       RFC 3315 max renew timeout in secons. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 600)
#x   -dhcp6_global_ren_timeout
#x       RFC 3315 initial renew timeout in secons. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 10)
#x   -dhcp6_global_req_max_rc
#x       RFC 3315 max request retry attempts. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 10)
#x   -dhcp6_global_req_max_rt
#x       RFC 3315 max request timeout value in secons. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 30)
#x   -dhcp6_global_req_timeout
#x       RFC 3315 initial request timeout value in secons. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 1)
#x   -dhcp6_global_setup_rate_increment
#x       This value represents the increment value for setup rate. This value is applied 
#x       every second and can be negative. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 0)
#x   -dhcp6_global_setup_rate_initial
#x       Setup rate is the number of clients to start in each second. This value 
#x       represents the initial value for setup rate. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 10)
#x   -dhcp6_global_setup_rate_max
#x       This value represents the final value for setup rate. The setup rate will 
#x       not change after this value is reached. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 10)
#x   -dhcp6_global_sol_max_rc
#x       RFC 3315 max solicit retry attempts. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 3)
#x   -dhcp6_global_sol_max_rt
#x       RFC 3315 max solicit timeout value in seconds. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 120)
#x   -dhcp6_global_sol_timeout
#x       RFC 3315 initial solicit timeout value in seconds. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 4)
#x   -dhcp6_global_teardown_rate_increment
#x       This value represents the increment value for teardown rate. This value is applied 
#x       every second and can be negative. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 50)
#x   -dhcp6_global_teardown_rate_initial
#x       Setup rate is the number of clients to stop in each second. This value 
#x       represents the initial value for teardown rate. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 50)
#x   -dhcp6_global_teardown_rate_max
#x       This value represents the final value for teardown rate. The teardown rate will 
#x       not change after this value is reached. 
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x       (DEFAULT = 500)
#x   -dhcp6_global_wait_for_completion
#x       This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’. 
#x       Valid choices are:
#x          0 - (DEFAULT) Disabled
#x          1 - Enabled
#x   -dhcp6_pd_client_range_duid_enterprise_id
#x       Define the vendor’s registered Private Enterprise Number as maintained by IANA. 
#x       Available starting with HLT API 3.90. Valid when port_role is ‘access’; 
#x       dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’; 
#x       dhcp6_pd_client_range_duid_type is ‘duid_en’.
#x       (DEFAULT = 10)
#x   -dhcp6_pd_client_range_duid_type
#x       Define the DHCP unique identifier type. 
#x       Valid choices are: 
#x          duid_en - duid_en
#x          duid_llt - (DEFAULT) duid_llt
#x          duid_ll - duid_ll
#x       Available starting with HLT API 3.90. Valid when port_role is ‘access’; 
#x       dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x   -dhcp6_pd_client_range_duid_vendor_id
#x       Define the vendor-assigned unique ID for this range. This ID is incremented 
#x       automatically for each DHCP client.
#x       (DEFAULT = 10)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or 
#x       ‘dual_stack’; dhcp6_pd_client_range_duid_type is ‘duid_en’.
#x   -dhcp6_pd_client_range_duid_vendor_id_increment
#x       Define the step to increment the vendor ID for each DHCP client. 
#x       (DEFAULT = 1)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’; 
#x       dhcp6_pd_client_range_duid_type is ‘duid_en’.
#x   -dhcp6_pd_client_range_ia_id
#x       Define the identity association unique ID for this range. This ID is incremented 
#x       automatically for each DHCP client.
#x       (DEFAULT = 10)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is ‘
#x       access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x   -dhcp6_pd_client_range_ia_id_increment
#x       Define the step used to increment dhcp6_pd_client_range_ia_id for each 
#x       DHCP client.
#x       (DEFAULT = 1)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x   -dhcp6_pd_client_range_ia_t1
#x       Define the suggested time at which the client contacts the server from which 
#x       the addresses were obtained to extend the lifetimes of the addresses assigned.
#x       (DEFAULT = 302400)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x   -dhcp6_pd_client_range_ia_t2
#x       Define the suggested time at which the client contacts any available 
#x       server to extend the lifetimes of the addresses assigned.
#x       (DEFAULT = 483840)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x   -dhcp6_pd_client_range_ia_type
#x       Define Identity Association Type.
#x       Valid choices are:  IAPD
#x       (DEFAULT = IAPD)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is 
#x       ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x   -dhcp6_pd_client_range_param_request_list
#x       Accepts list of values. Define the list of options in a message between a 
#x       client and a server. 
#x       (DEFAULT = {2 7 23 24})
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x   -dhcp6_pd_client_range_renew_timer
#x       Define the user-defined lease renewal timer. The value is estimated in seconds 
#x       and will override the lease renewal timer if it is not zero and is smaller than the server-defined value.
#x       (DEFAULT = 0)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is 
#x       'access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x   -dhcp6_pd_client_range_use_vendor_class_id
#x       Enable using vendor class id.
#x       Valid choices are:
#x          0 - disable
#x          1 - enable
#x       (DEFAULT = 0)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is 
#x       ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’
#x   -dhcp6_pd_client_range_vendor_class_id
#x       This option is used by a client to identify the vendor that manufactured the 
#x       hardware on which the client is running. 
#x       (DEFAULT = ‘Ixia DHCP Client’)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is 
#x       ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’; 
#x       dhcp6_pd_client_range_use_vendor_class_id is 1
#x   -dhcp6_pgdata_max_outstanding_releases
#x       The maximum number of requests to be sent by all DHCP clients during session 
#x       teardown. This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or 
#x       ‘dual_stack’.
#x       (DEFAULT = 500)
#x   -dhcp6_pgdata_max_outstanding_requests
#x       The maximum number of requests to be sent by all DHCP clients during session 
#x       startup. This parameter applies globally for all the ports in the configuration. 
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or 
#x       ‘dual_stack’.
#x       (DEFAULT = 20)
#x   -dhcp6_pgdata_override_global_setup_rate
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter 
#x       applies at the port level.
#x       (DEFAULT = 0)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is 
#x       ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x   -dhcp6_pgdata_override_global_teardown_rate
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter 
#x       applies at the port level.
#x       (DEFAULT = 0)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’
#x   -dhcp6_pgdata_setup_rate_increment
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter 
#x       applies at the port level. 
#x       (DEFAULT = 0)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’. 
#x       Parameter dhcp6_pgdata_override_global_setup_rate is ‘1’.
#x   -dhcp6_pgdata_setup_rate_initial
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter 
#x       applies at the port level. 
#x       (DEFAULT = 10)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’. 
#x       Parameter dhcp6_pgdata_override_global_setup_rate is ‘1’
#x   -dhcp6_pgdata_setup_rate_max
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter 
#x       applies at the port level. 
#x       (DEFAULT = 10)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or 
#x       ‘dual_stack’. Parameter dhcp6_pgdata_override_global_setup_rate is ‘1’
#x   -dhcp6_pgdata_teardown_rate_increment
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter 
#x       applies at the port level. 
#x       (DEFAULT = 50)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’. 
#x       Parameter dhcp6_pgdata_override_global_teardown_rate is ‘1’
#x   -dhcp6_pgdata_teardown_rate_initial
#x       Description This parameter refers to the DHCPv6 Client Port Group Data. 
#x       This parameter applies at the port level. 
#x       (DEFAULT = 50)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’. 
#x       Parameter dhcp6_pgdata_override_global_teardown_rate is ‘1’
#x   -dhcp6_pgdata_teardown_rate_max
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter 
#x       applies at the port level. 
#x       (DEFAULT = 500)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is 
#x       'access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’. Parameter 
#x       dhcp6_pgdata_override_global_teardown_rate is ‘1’
#x   -hosts_range_count
#x       Configures the DHCP Hosts Range count property. 
#x       (DEFAULT = 1)
#x       Dependencies: Available starting with HLT API 3.90. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable 
#x       is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’
#x   -hosts_range_eui_increment
#x       This parameter configures the EUI step to 
#x       increment ‘hosts_range_first_eui ‘ from the DHCP Hosts Range. 
#x       (DEFAULT = 00:00:00:00:00:00:00:01)
#x       Dependencies: Available starting with HLT API 3.90. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable 
#x       is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’. Parameter 
#x       hosts_range_count greater than 1
#x   -hosts_range_first_eui
#x       Configures the first EUI value of the DHCP Hosts Range. 
#x       (DEFAULT = 00:00:00:00:00:00:11:11)
#x       Dependencies: Available starting with HLT API 3.90. 
#x       Valid when port_role is ‘access’; dhcpv6_hosts_enable 
#x       is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’
#x   -hosts_range_ip_prefix
#x       Defines the network prefix length associated with the 
#x       address pool for the DHCP Hosts Range. 
#x       (DEFAULT = 96)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’
#x   -hosts_range_subnet_count
#x       It defines the number of subnets for the DHCP Hosts Range. 
#x       (DEFAULT = 1)
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role 
#x       is ‘access’; dhcpv6_hosts_enable is 1; ip_cp is ‘ipv6_cp’ or ‘dual_stack’.
#x   -dhcp6_pd_server_range_dns_domain_search_list
#x       Specifies the domain that the client will use when resolving host names with DNS.
#x   -dhcp6_pd_server_range_first_dns_server
#x       The first DNS server associated with this address pool. This is the first DNS 
#x       address that will be assigned to any client that is allocated an IP address from this 
#x       pool.
#x   -hosts_range_ip_outer_prefix
#x       This parameter represents the address prefix allocated to the hosts in all of the subnets 
#x       behind the CPE interface. The default prefix is 64, the minimum is 0, and the maximum is 128.
#x   -hosts_range_ip_prefix_addr
#x       The IPv6 prefix to be used for the static host addresses. The default prefix is 3001.
#x   -dhcp6_pd_server_range_second_dns_server
#x       The second DNS server associated with this address pool. This is the second (of 
#x       two) DNS addresses that will be assigned to any client that is allocated an IP 
#x       address from this pool.
#x   -dhcp6_pd_server_range_subnet_prefix
#x       The prefix value used to subnet the addresses specified in the address pool. This
#x       is the subnet prefix length advertised in DHCPv6PD Offer and Reply messages.
#x   -dhcp6_pd_server_range_start_pool_address
#x       The starting IPv6 address for this DHCPv6 address pool.
#x   -lease_time_max
#x       The maximum lease duration, in seconds. The default value is 86,400; the 
#x       minimum is 300; and the maximum is 30,000,000.
#x   -lease_time
#x        The duration of an address lease, in seconds, if the client requesting the lease 
#x        does not ask for a specific expiration time. The default value is 3600; the 
#x        minimum is 300; and the maximum is 30,000,000.
#
# Return Values:
#    A keyed list
#    key:status     value:$::SUCCESS | $::FAILURE
#    key:handles    value:<l2tp handles>
#    key:log        value:When status is failure, contains more information
#
# Examples:
#    See files in the Samples/IxNetwork/L2TP subdirectory.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) Coded versus functional specification.
#    2) Sessions might not be distributed as expected over tunnels and the number of 
#       tunnels might be different from the what was requested when -mode "lac" 
#       in the following particular case:
#           * -tun_distribution domain_group_map
#           * -sess_distribution next
#           * -l2tp_dst_step 0.0.0.0
#           * -num_tunnels  > 1
#           * More than 1 domains are configured in -domain_group_map
#       To avoid this use -sess_distribution "fill".
#
# See Also:
#

proc ::ixia::dhcpv6_config { args } {
    variable new_ixnetwork_api
    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::dhcpv6_config $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set man_args {
        -mode          CHOICES lac lns ppp_client ppp_server
        -handle        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$

    }
    
    set ixnetwork_opt_args {
        -addr_count_per_vci                             RANGE       1-65535
                                                        DEFAULT     1
        -addr_count_per_vpi                             RANGE       1-65535
                                                        DEFAULT     1
        -dhcpv6_hosts_enable                            CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_pd_client_range_duid_enterprise_id       RANGE   1-2147483647
                                                        DEFAULT 10
        -dhcp6_pd_client_range_duid_type                CHOICES duid_en duid_llt duid_ll
                                                        DEFAULT duid_llt
        -dhcp6_pd_client_range_duid_vendor_id           RANGE   1-2147483647
                                                        DEFAULT 10
        -dhcp6_pd_client_range_duid_vendor_id_increment RANGE   1-2147483647
                                                        DEFAULT 1
        -dhcp6_pd_client_range_ia_id                    RANGE   1-2147483647
                                                        DEFAULT 10
        -dhcp6_pd_client_range_ia_id_increment          RANGE   1-2147483647
                                                        DEFAULT 1
        -dhcp6_pd_client_range_ia_t1                    RANGE   0-2147483647
                                                        DEFAULT 302400
        -dhcp6_pd_client_range_ia_t2                    RANGE   0-2147483647
                                                        DEFAULT 483840
        -dhcp6_pd_client_range_ia_type                  CHOICES iapd
                                                        DEFAULT iapd
        -dhcp6_pd_client_range_param_request_list       NUMERIC
                                                        DEFAULT {2 7 23 24}
        -dhcp6_pd_client_range_renew_timer              RANGE   0-1000000000
                                                        DEFAULT 0
        -dhcp6_pd_client_range_use_vendor_class_id      CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_pd_client_range_vendor_class_id          ANY
                                                        DEFAULT "Ixia DHCP Client"
        -dhcp6_pgdata_max_outstanding_releases          RANGE   1-100000
                                                        DEFAULT 500
        -dhcp6_pgdata_max_outstanding_requests          RANGE   1-100000
                                                        DEFAULT 20
        -dhcp6_pgdata_override_global_setup_rate        CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_pgdata_override_global_teardown_rate     CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_pgdata_setup_rate_increment              RANGE   0-100000
                                                        DEFAULT 0
        -dhcp6_pgdata_setup_rate_initial                RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_pgdata_setup_rate_max                    RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_pgdata_teardown_rate_increment           RANGE   0-100000
                                                        DEFAULT 50
        -dhcp6_pgdata_teardown_rate_initial             RANGE   1-100000
                                                        DEFAULT 50
        -dhcp6_pgdata_teardown_rate_max                 RANGE   1-100000
                                                        DEFAULT 500
        -dhcp6_global_echo_ia_info                      CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_global_reb_max_rt                        RANGE   1-10000
                                                        DEFAULT 500
        -dhcp6_global_reb_timeout                       RANGE   1-100
                                                        DEFAULT 10
        -dhcp6_global_rel_max_rc                        RANGE   1-100
                                                        DEFAULT 5
        -dhcp6_global_rel_timeout                       RANGE   1-100
                                                        DEFAULT 1
        -dhcp6_global_ren_max_rt                        RANGE   1-10000
                                                        DEFAULT 600
        -dhcp6_global_ren_timeout                       RANGE   1-100
                                                        DEFAULT 10
        -dhcp6_global_req_max_rc                        RANGE   1-100
                                                        DEFAULT 10
        -dhcp6_global_req_max_rt                        RANGE   1-10000
                                                        DEFAULT 30
        -dhcp6_global_req_timeout                       RANGE   1-100
                                                        DEFAULT 1
        -dhcp6_global_sol_max_rc                        RANGE   1-100
                                                        DEFAULT 3
        -dhcp6_global_sol_max_rt                        RANGE   1-10000
                                                        DEFAULT 120
        -dhcp6_global_sol_timeout                       RANGE   1-100
                                                        DEFAULT 4
        -dhcp6_global_max_outstanding_releases          RANGE   1-100000
                                                        DEFAULT 500
        -dhcp6_global_max_outstanding_requests          RANGE   1-100000
                                                        DEFAULT 20
        -dhcp6_global_setup_rate_increment              ANY
                                                        DEFAULT 0
        -dhcp6_global_setup_rate_initial                RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_global_setup_rate_max                    RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_global_teardown_rate_increment           ANY
                                                        DEFAULT 50
        -dhcp6_global_teardown_rate_initial             RANGE   1-100000
                                                        DEFAULT 50
        -dhcp6_global_teardown_rate_max                 RANGE   1-100000
                                                        DEFAULT 500
        -dhcp6_global_wait_for_completion               CHOICES 0 1
                                                        DEFAULT 0
        -hosts_range_ip_outer_prefix                    NUMERIC
                                                        DEFAULT 64
        -hosts_range_ip_prefix_addr                     IP
        -hosts_range_count                              RANGE   1-1000000
                                                        DEFAULT 1
        -hosts_range_eui_increment                      VCMD ::ixia::validate_eui64_or_ipv6
                                                        DEFAULT {00 00 00 00 00 00 00 01}
        -hosts_range_first_eui                          VCMD ::ixia::validate_eui64_or_ipv6
                                                        DEFAULT {00 00 00 00 00 00 11 11}
        -hosts_range_ip_prefix                          RANGE   64-128
                                                        DEFAULT 64
        -hosts_range_subnet_count                       RANGE   1-32
        -dhcp6_pd_server_range_dns_domain_search_list   ANY
        -dhcp6_pd_server_range_first_dns_server         IP
        -dhcp6_pd_server_range_second_dns_server        IP
        -dhcp6_pd_server_range_subnet_prefix            NUMERIC
        -dhcp6_pd_server_range_start_pool_address       IP
        -lease_time_max                                 RANGE   300-30000000
                                                        DEFAULT 864000
        -lease_time                                     RANGE   300-30000000
                                                        DEFAULT 864000
    }
    
}