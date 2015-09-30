proc ::ixia::ixnetwork_dhcp_client_extension_config { args man_args opt_args } {
    variable truth
    set procName [lindex [info level [info level]] 0]
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    # Check to see if a connection to the IxNetwork TCL server already exists. 
    # If it doesn't, establish it.
    set return_status [checkIxNetwork]
    if {[keylget return_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget return_status log]"
        return $returnList
    }
    
    if {$mode == "remove"} {
        foreach handle_item $handle {
            set retCode [ixNetworkNodeRemoveList [ixNet getParent $handle_item] dhcpv6ClientRange] 
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to remove $handle_item."
                return $returnList
            }
            set retCode [ixNetworkNodeRemoveList [ixnet getParent [ixNet getParent $handle_item]] dhcp2v6Client] 
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to remove $handle_item."
                return $returnList
            }
        }
        if {[catch {ixNet commit} errorInfo]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to remove handles: $handle. $errorInfo."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    array set truth {
        enable  true
        disable false
    }
    if {$mode == "enable" || $mode == "disable"} {
        foreach handle_item $handle {
            if {[catch {ixNet setAttribute $handle_item -enabled $truth($mode)} errorInfo]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to $mode $handle_item. $errorInfo."
                return $returnList
            }
        }
        
        if {[catch {ixNet commit} errorInfo]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to $mode handles: $handle. $errorInfo."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    #####################################
    ## Configure dhcpv6ClientRange   ##
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
    set dhcpv6_cr_param_map {
        dhcp6DuidEnterpriseId       dhcp6_client_range_duid_enterprise_id       value                dhcpv6ClientRange
        dhcp6DuidType               dhcp6_client_range_duid_type                translate            dhcpv6ClientRange
        dhcp6DuidVendorId           dhcp6_client_range_duid_vendor_id           value                dhcpv6ClientRange
        dhcp6DuidVendorIdIncrement  dhcp6_client_range_duid_vendor_id_increment value                dhcpv6ClientRange
        dhcp6ParamRequestList       dhcp6_client_range_param_request_list       semicolon_list       dhcpv6ClientRange
        useVendorClassId            dhcp6_client_range_use_vendor_class_id      translate            dhcpv6ClientRange
        vendorClassId               dhcp6_client_range_vendor_class_id          value                dhcpv6ClientRange
    }
    

    set dhcp_obj_type             dhcpv6ClientRange

    set ixn_args ""
    foreach {ixn_p hlt_p p_type o_type} $dhcpv6_cr_param_map {
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
                ia_transform {
                    regsub -all {[ :.]} $hlt_p_val : ixn_p_val
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
    
    if {[set dhcp_obj [::ixia::ixNetworkNodeGetList $handle $dhcp_obj_type]] == [ixNet getNull] ||\
            [set dhcp_obj [::ixia::ixNetworkNodeGetList $handle $dhcp_obj_type]] == ""} {
        set result [::ixia::ixNetworkNodeAdd \
                $handle           \
                $dhcp_obj_type    \
                $ixn_args         \
                -commit           \
                ]
        if {[keylget result status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [keylget result log]"
            return $returnList
        }
        set dhcp_obj [keylget result node_objref]
    } else {
        if {[llength $ixn_args] > 0} {
            set result [::ixia::ixNetworkNodeSetAttr \
                    [set dhcp_obj [::ixia::ixNetworkNodeGetList $handle $dhcp_obj_type]] \
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
    ## Configure dhcpv6ClientOptions ##
    ###########################################
    
    set dhcpv6_pgd_param_map {
        maxOutstandingRequests     dhcp6_pgdata_max_outstanding_requests            value
        overrideGlobalSetupRate    dhcp6_pgdata_override_global_setup_rate          translate
        setupRateIncrement         dhcp6_pgdata_setup_rate_increment                value
        setupRateInitial           dhcp6_pgdata_setup_rate_initial                  value
        setupRateMax               dhcp6_pgdata_setup_rate_max                      value
        associates                 dhcp6_pgdata_associates                          value
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
    set dhcp_obj_type Client
    
    if {[::ixia::ixNetworkNodeGetList $pg_handle dhcpv6${dhcp_obj_type}Options] == [ixNet getNull] ||\
            [::ixia::ixNetworkNodeGetList $pg_handle dhcpv6${dhcp_obj_type}Options] == ""} {
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
    ## Configure dhcpv6ClientGlobals   ##
    #####################################
    
    set dhcpv6_glbl_param_map {
        maxOutstandingRequests  dhcp6_global_max_outstanding_requests     value
        dhcp6InfMaxRt           dhcp6_global_reb_max_rt                   value
        dhcp6InfTimeout         dhcp6_global_reb_timeout                  value
        dhcp6InfMaxRc           dhcp6_global_rel_max_rc                   value
        setupRateIncrement      dhcp6_global_setup_rate_increment         value
        setupRateInitial        dhcp6_global_setup_rate_initial           value
        setupRateMax            dhcp6_global_setup_rate_max               value
        teardownRateMax         dhcp6_global_teardown_rate_max            value
        waitForCompletion       dhcp6_global_wait_for_completion          translate
    }
    
    set ixn_args ""
    foreach {ixn_p hlt_p p_type} $dhcpv6_glbl_param_map {
        if {[info exists $hlt_p] && ![is_default_param_value $hlt_p $args]} {
            
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
        
    if {[::ixia::ixNetworkNodeGetList $glbl_handle dhcpv6${dhcp_obj_type}Globals] == [ixNet getNull] ||\
            [::ixia::ixNetworkNodeGetList $glbl_handle dhcpv6${dhcp_obj_type}Globals] == ""} {
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
        
    keylset returnList status $::SUCCESS
    keylset returnList handle $dhcp_obj
    return $returnList
}



proc ::ixia::ixnetwork_dhcp_extension_stats { args man_args opt_args} {
    variable ixNetworkNodeDfsSearchNodeTypeVisited
    variable ixNetworkNodeDfsSearchNodeTypeFound
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
    
    if {$mode == "aggregate"} {
        # Define the statistics to be gathered from the tables in the
        # stat view browser
        set stat_views_list [list]
        set stat_view_stats_list [list]
        set stat_view_arrays_list [list]
        
        # DHCPv6 Server Statistics
        set stats_list_dhcpv6_server [list          \
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
        set stats_array_dhcpv6_server [list               \
                "Solicits Received"                         \
                    dhcpv6_solicits_received              \
                "Advertisements Sent"                       \
                    dhcpv6_advertisements_sent            \
                "Requests Received"                         \
                    dhcpv6_requests_received              \
                "Confirms Received"                         \
                    dhcpv6_confirms_received              \
                "Renewals Received"                         \
                    dhcpv6_renewals_received              \
                "Rebinds Received"                          \
                    dhcpv6_rebinds_received               \
                "Replies Sent"                              \
                    dhcpv6_replies_sent                   \
                "Releases Received"                         \
                    dhcpv6_releases_received              \
                "Declines Received"                         \
                    dhcpv6_declines_received              \
                "Information-Requests Received"             \
                    dhcpv6_information_requests_received  \
                "Total Prefixes Allocated"                  \
                    dhcpv6_total_prefixes_allocated       \
                "Total Prefixes Renewed"                    \
                    dhcpv6_total_prefixes_renewed         \
                "Current Prefixes Allocated"                \
                    dhcpv6_current_prefixes_allocated     \
                ]
        # DHCPv6 Client Statistics
        set stats_list_dhcpv6_client [list          \
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
        set stats_array_dhcpv6_client [list               \
                "Addresses Discovered"                      \
                    dhcpv6_addresses_discovered           \
                "Advertisements Ignored"                    \
                    dhcpv6_advertisements_ignored         \
                "Advertisements Received"                   \
                    dhcpv6_advertisements_received        \
                "Enabled Interfaces"                        \
                    dhcpv6_enabled_interfaces             \
                "Rebinds Sent"                              \
                    dhcpv6_rebinds_sent                   \
                "Releases Sent"                             \
                    dhcpv6_releases_sent                  \
                "Renews Sent"                               \
                    dhcpv6_renews_sent                    \
                "Replies Received"                          \
                    dhcpv6_replies_received               \
                "Requests Sent"                             \
                    dhcpv6_requests_sent                  \
                "Sessions Failed"                           \
                    dhcpv6_sessions_failed                \
                "Sessions Initiated"                        \
                    dhcpv6_sessions_initiated             \
                "Sessions Succeeded"                        \
                    dhcpv6_sessions_succeeded             \
                "Setup Success Rate"                        \
                    dhcpv6_setup_success_rate             \
                "Solicits Sent"                             \
                    dhcpv6_solicits_sent                  \
                "Teardown Fail"                             \
                    dhcpv6_teardown_fail                  \
                "Teardown Initiated"                        \
                    dhcpv6_teardown_initiated             \
                "Teardown Success"                          \
                    dhcpv6_teardown_success               \
                "Information Requests Sent"                 \
                    dhcpv6_information_requests_sent      \
                "Min Establishment Time"                    \
                    dhcpv6_min_establishment_time         \
                "Avg Establishment Time"                    \
                    dhcpv6_avg_establishment_time         \
                "Max Establishment Time"                    \
                    dhcpv6_max_establishment_time         \
                ]
        
        set original_stat_view_array_list $stat_view_arrays_list
        set original_stat_view_stats_list $stat_view_stats_list
        set original_stat_view_list $stat_views_list
        foreach port $port_handle {
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
            set eth_obj_list [ixNet getL $vport_objref/protocolStack ethernet]
            if {[llength $eth_obj_list]==0 || $eth_obj_list == [ixNet getNull]} {
                set eth_obj_list [ixNet getL $vport_objref/protocolStack atm]
            }
            foreach eth_obj $eth_obj_list {
                array set ixNetworkNodeDfsSearchNodeTypeVisited ""
                array unset ixNetworkNodeDfsSearchNodeTypeVisited
                array set ixNetworkNodeDfsSearchNodeTypeFound   ""
                array unset ixNetworkNodeDfsSearchNodeTypeFound
                set clientRange [ixNetworkNodeDfsSearchNodeType $eth_obj dhcpv6ClientRange]
                if {$clientRange != ""} {
                    lappend stat_views_list "DHCPv6Client"
                    lappend stat_view_stats_list $stats_list_dhcpv6_client
                    lappend stat_view_arrays_list $stats_array_dhcpv6_client
                }
                array set ixNetworkNodeDfsSearchNodeTypeVisited ""
                array unset ixNetworkNodeDfsSearchNodeTypeVisited
                array set ixNetworkNodeDfsSearchNodeTypeFound   ""
                array unset ixNetworkNodeDfsSearchNodeTypeFound
                set serverRange [ixNetworkNodeDfsSearchNodeType $eth_obj dhcpv6ServerRange]
                if {$serverRange != ""} {
                    lappend stat_views_list "DHCPv6Server"
                    lappend stat_view_stats_list $stats_list_dhcpv6_server
                    lappend stat_view_arrays_list $stats_array_dhcpv6_server
                }
            }
            
            if {$stat_views_list == ""} {
                puts "Warning: The port $port doesn't have DHCPv6 Extension configured."
                update idletasks
                continue
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
                    
                    keylset returnList status $::SUCCESS
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
    }

    if {$mode == "session"} {
        array set dhcpv6_server_per_session_array [list                                 \
            "Lease Name"                        dhcpv6_lease_name                     \
            "Offer Count"                       dhcpv6_offer_count                    \
            "Bind Count"                        dhcpv6_bind_count                     \
            "Bind Rapid Commit Count"           dhcpv6_bind_rapid_commit_count        \
            "Renew Count"                       dhcpv6_renew_count                    \
            "Release Count"                     dhcpv6_release_count                  \
            "Information-Requests Received"     dhcpv6_information_request_received   \
            "Replies Sent"                      dhcpv6_replies_sent                   \
            "Lease State"                       dhcpv6_lease_state                    \
            "Lease Address"                     dhcpv6_lease_address                  \
            "Valid Time"                        dhcpv6_valid_time                     \
            "Prefered Time"                     dhcpv6_prefered_time                  \
            "Renew Time"                        dhcpv6_renew_time                     \
            "Rebind Time"                       dhcpv6_rebind_time                    \
            "Client ID"                         dhcpv6_client_id                      \
            "Remote ID"                         dhcpv6_remote_id                      \
            ]
            
        array set dhcpv6_client_per_session_array [list                               \
            "Session Name"                      dhcpv6_session_name                   \
            "Solicits Sent"                     dhcpv6_solicits_sent                  \
            "Advertisements Received"           dhcpv6_advertisements_received        \
            "Advertisements Ignored"            dhcpv6_advertisements_ignored         \
            "Requests Sent"                     dhcpv6_requests_sent                  \
            "Replies Received"                  dhcpv6_replies_received               \
            "Renews Sent"                       dhcpv6_renews_sent                    \
            "Rebinds Sent"                      dhcpv6_rebinds_sent                   \
            "Releases Sent"                     dhcpv6_releases_sent                  \
            "IP Prefix"                         dhcpv6_ip_prefix                      \
            "Gateway Address"                   dhcpv6_gateway_address                \
            "DNS Server List"                   dhcpv6_dns_server_list                \
            "Prefix Lease Time"                 dhcpv6_prefix_lease_time              \
            "Information Requests Sent"         dhcpv6_onformation_requests_sent      \
            "DNS Search List"                   dhcpv6_dns_search_list                \
            "Solicits w/ Rapid Commit Sent"     dhcpv6_solicits_rapid_commit_sent     \
            "Replies w/ Rapid Commit Received"  dhcpv6_replies_rapid_commit_received  \
            "Lease w/ Rapid Commit"             dhcpv6_lease_rapid_commit             \
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
                

                array set ixNetworkNodeDfsSearchNodeTypeVisited ""
                array unset ixNetworkNodeDfsSearchNodeTypeVisited
                array set ixNetworkNodeDfsSearchNodeTypeFound   ""
                array unset ixNetworkNodeDfsSearchNodeTypeFound
                set clientRange [ixNetworkNodeDfsSearchNodeType $eth_obj dhcpv6ClientRange]
                if {$clientRange != ""} {
                    set drill_down_view_type "dhcpv6PdClient"
                }
                array set ixNetworkNodeDfsSearchNodeTypeVisited ""
                array unset ixNetworkNodeDfsSearchNodeTypeVisited
                array set ixNetworkNodeDfsSearchNodeTypeFound   ""
                array unset ixNetworkNodeDfsSearchNodeTypeFound
                set serverRange [ixNetworkNodeDfsSearchNodeType $eth_obj dhcpv6ServerRange]
                if {$serverRange != ""} {
                    set drill_down_view_type "dhcpv6Server"
                }

                if {($clientRange == "") && ($serverRange == "")} {
                    puts "Warning: The port $port doesn't have DHCPv6 Extension configured."
                    update idletasks
                    continue
                }
                set build_name "SessionView-[regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]-[regsub -all "/" $port "_"]"
                set drill_result [::ixia::CreateAndDrilldownViews $port port_handle $build_name $drill_down_view_type]
                if {[keylget drill_result status] == $::FAILURE} {
                    return $drill_result
                }
                # Get the session statistics for this port
                if {$clientRange != ""} {
                    set returned_stats_list [::ixia::540GetStatView $build_name [array names dhcpv6_client_per_session_array]]
                    set stats_array_per_session_dhcp dhcpv6_client_per_session_array
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
                #set eth_obj [ixNet getL $vport_objref/protocolStack ethernet]
                
                if {[regexp {dhcpv6ClientRange:[0-9]+$} $small_handle]} {
                    set clientRange $small_handle
                } else {
                    array set ixNetworkNodeDfsSearchNodeTypeVisited ""
                    array unset ixNetworkNodeDfsSearchNodeTypeVisited
                    array set ixNetworkNodeDfsSearchNodeTypeFound   ""
                    array unset ixNetworkNodeDfsSearchNodeTypeFound
                    set clientRange [ixNetworkNodeDfsSearchNodeType $small_handle dhcpv6ClientRange]
                }
                if {$clientRange != ""} {
                    set drill_down_view_type "dhcpv6Client"
                }
                if {[regexp {dhcpv6ServerRange:[0-9]+$} $small_handle]} {
                    set serverRange $small_handle
                } else {
                    array set ixNetworkNodeDfsSearchNodeTypeVisited ""
                    array unset ixNetworkNodeDfsSearchNodeTypeVisited
                    array set ixNetworkNodeDfsSearchNodeTypeFound   ""
                    array unset ixNetworkNodeDfsSearchNodeTypeFound
                    set serverRange [ixNetworkNodeDfsSearchNodeType $small_handle dhcpv6ServerRange]
                }
                if {$serverRange != ""} {
                    set drill_down_view_type "dhcpv6Server"
                }

                if {($clientRange == "") && ($serverRange == "")} {
                    puts "Warning: The handle $small_handle doesn't have DHCPv6 Extension configured."
                    update idletasks
                    continue
                }
                
                set proto_regex [ixNet getA $small_handle -name]
                set range_handle [ixNet getParent $small_handle]
                set build_name "SessionView-[regsub -all (dhcpv6Pd)|(dhcpv6)|(dhcp) $drill_down_view_type ""]-[string trim [string range $range_handle [expr [string first "/range:" $small_handle] + 7] end] "\"\\"]"
                
                set drill_result [::ixia::CreateAndDrilldownViews $range_handle handle $build_name $drill_down_view_type $proto_regex]
                if {[keylget drill_result status] == $::FAILURE} {
                    return $drill_result
                }
                if {$clientRange != ""} {
                    set returned_stats_list [::ixia::540GetStatView $build_name [array names dhcpv6_client_per_session_array]]
                    set stats_array_per_session_dhcp dhcpv6_client_per_session_array
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
            }
        } ;# End handle
    }

    keylset returnList status $::SUCCESS
    return $returnList
}



proc ::ixia::ixnetwork_dhcp_server_extension_config { args man_args opt_args } {
    variable truth
    set procName [lindex [info level [info level]] 0]
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    # Check to see if a connection to the IxNetwork TCL server already exists. 
    # If it doesn't, establish it.
    set return_status [checkIxNetwork]
    if {[keylget return_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget return_status log]"
        return $returnList
    }
    
    if {$mode == "remove"} {
        foreach handle_item $handle {
            set retCode [ixNetworkNodeRemoveList [ixNet getParent [ixNet getParent $handle_item]] {{child remove dhcpv6Server} {}}] 
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to remove $handle_item."
                return $returnList
            }
        }
        if {[catch {ixNet commit} errorInfo]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to remove handles: $handle. $errorInfo."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    array set truth {
        enable  true
        disable false
    }
    if {$mode == "enable" || $mode == "disable"} {
        foreach handle_item $handle {
            if {[catch {ixNet setAttribute $handle_item -enabled $truth($mode)} errorInfo]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to $mode $handle_item. $errorInfo."
                return $returnList
            }
        }
        
        if {[catch {ixNet commit} errorInfo]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to $mode handles: $handle. $errorInfo."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    #####################################
    ## Configure dhcpv6ServerRange   ##
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
    set dhcpv6_cr_param_map {
            ipAddress                   dhcp6_server_range_start_pool_address       value                dhcpv6ServerRange
            ipPrefix                    dhcp6_server_range_subnet_prefix            value                dhcpv6ServerRange
            ipDns1                      dhcp6_server_range_first_dns_server         value                dhcpv6ServerRange
            ipDns2                      dhcp6_server_range_second_dns_server        value                dhcpv6ServerRange
            dnsDomain                   dhcp6_server_range_dns_domain_search_list   value                dhcpv6ServerRange
    }
    

    set dhcp_obj_type             dhcpv6ServerRange

    set ixn_args ""
    foreach {ixn_p hlt_p p_type o_type} $dhcpv6_cr_param_map {
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
                ia_transform {
                    regsub -all {[ :.]} $hlt_p_val : ixn_p_val
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
    
    if {[set dhcp_obj [::ixia::ixNetworkNodeGetList $handle $dhcp_obj_type]] == [ixNet getNull] ||\
            [set dhcp_obj [::ixia::ixNetworkNodeGetList $handle $dhcp_obj_type]] == ""} {
        set result [::ixia::ixNetworkNodeAdd \
                $handle           \
                $dhcp_obj_type    \
                $ixn_args         \
                -commit           \
                ]
        if {[keylget result status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [keylget result log]"
            return $returnList
        }
        set dhcp_obj [keylget result node_objref]
    } else {
        if {[llength $ixn_args] > 0} {
            set result [::ixia::ixNetworkNodeSetAttr \
                    [set dhcp_obj [::ixia::ixNetworkNodeGetList $handle $dhcp_obj_type]] \
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
    ## Configure dhcpv6ServerOptions ##
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
    set dhcp_obj_type Server
    
    if {[::ixia::ixNetworkNodeGetList $pg_handle dhcpv6${dhcp_obj_type}Options] == [ixNet getNull] ||\
            [::ixia::ixNetworkNodeGetList $pg_handle dhcpv6${dhcp_obj_type}Options] == ""} {
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
            
    keylset returnList status $::SUCCESS
    keylset returnList handle $dhcp_obj
    return $returnList
}

proc ::ixia::ixNetworkNodeGetChildTypes {obj} {
    set str_err [catch {ixNet getList $obj XYZ} str]
    if {[regexp {(.*)\(possible options are: (.*) \)} $str one two three]} {
        if {[info exists three]} {
            return $three
        }
    }
    return {}
}

proc ::ixia::ixNetworkNodeDfsSearchNodeType {root searchNodeType} {
    variable ixNetworkNodeDfsSearchNodeTypeVisited
    variable ixNetworkNodeDfsSearchNodeTypeFound

    set excludeChildTypes {availableHardware globals impairment reporter statistics eventScheduler traffic topology testConfiguration quickTest }
    set ixNetworkNodeDfsSearchNodeTypeVisited($root) 1
    foreach nodeType [ixNetworkNodeGetChildTypes $root] {
        set nodeList [ixNet getList $root $nodeType]
        foreach node $nodeList {
            if {[lsearch $node $excludeChildTypes] != -1} {
                continue
            }
            if {[lsearch $searchNodeType $nodeType] != -1} {
                foreach foundNode $nodeList {
                    set ixNetworkNodeDfsSearchNodeTypeFound($foundNode) 1
                }
            }
            if {![info exists ixNetworkNodeDfsSearchNodeTypeVisited($node)]} {
                ixNetworkNodeDfsSearchNodeType $node $searchNodeType
            }
        }
    }
    set retList [array names ixNetworkNodeDfsSearchNodeTypeFound]
    return $retList
}

