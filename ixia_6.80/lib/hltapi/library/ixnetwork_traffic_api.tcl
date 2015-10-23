proc ::ixia::ixnetwork_traffic_config { args } {
    variable truth
    variable current_streamid
    variable ixnetwork_stream_ids
    
    set args [lindex $args 0]

    set man_args {
        -mode                       CHOICES create modify remove reset
                                    CHOICES enable disable
    }

    set opt_args {
        -allow_self_destined        CHOICES 0 1
                                    DEFAULT 0
        -app_profile_type
        -atm_header_encapsulation   CHOICES llc_bridged_eth_fcs
                                    CHOICES llc_bridged_eth_no_fcs
                                    CHOICES llc_ppp
                                    CHOICES llc_routed_snap
                                    CHOICES vcc_mux_bridged_eth_fcs
                                    CHOICES vcc_mux_bridged_eth_no_fcs
                                    CHOICES vcc_mux_ppp
                                    CHOICES vcc_mux_routed
        -atm_range_count            NUMERIC
        -bidirectional              CHOICES 0 1
                                    DEFAULT 0
        -burst_loop_count           NUMERIC
        -circuit_endpoint_type      CHOICES atm
                                    CHOICES ethernet_vlan
                                    CHOICES ethernet_vlan_arp
                                    CHOICES frame_relay
                                    CHOICES hdlc
                                    CHOICES ipv4
                                    CHOICES ipv4_arp
                                    CHOICES ipv4_application_traffic
                                    CHOICES ipv6
                                    CHOICES ipv6_application_traffic
                                    CHOICES ppp
                                    CHOICES fc
                                    DEFAULT ipv4
        -circuit_type               CHOICES none
                                    CHOICES l2vpn
                                    CHOICES l3vpn
                                    CHOICES mpls
                                    CHOICES 6pe
                                    CHOICES 6vpe
                                    CHOICES raw
                                    CHOICES vpls
                                    CHOICES stp
                                    CHOICES mac_in_mac
                                    DEFAULT none
        -custom_offset              NUMERIC
        -data_pattern               HEX
        -data_pattern_mode          CHOICES decr_byte decr_word
                                    CHOICES incr_byte incr_word
                                    CHOICES repeating fixed
                                    DEFAULT repeating
        -dlci_count_mode            CHOICES fixed increment
        -dlci_repeat_count          RANGE 0-4294967295
        -dlci_repeat_count_step     NUMERIC
        -dlci_value                 RANGE 0-4294967295
        -dlci_value_step            NUMERIC
        -emulation_dst_handle
        -emulation_src_handle
        -enable_ce_to_pe_traffic    CHOICES 0 1
                                    DEFAULT 0
        -enable_override_value      CHOICES 0 1
                                    DEFAULT 0
        -enable_test_objective      CHOICES 0 1
                                    DEFAULT 0
        -enforce_min_gap            NUMERIC
        -fr_range_count             NUMERIC
        -fcs                        CHOICES 0 1
        -fcs_type                   CHOICES bad_CRC no_CRC
        -frame_size                 NUMERIC
        -frame_size_distribution    CHOICES cisco imix quadmodal tolly trimodal
                                    DEFAULT cisco
        -frame_size_gauss           REGEXP ^([0-9]+:[0-9]+(\.[0-9])*:[0-9]+ ){0,3}[0-9]+:[0-9]+(\.[0-9])*:[0-9]+$
        -frame_size_imix            REGEXP ^([0-9]+:[0-9]+ )*[0-9]+:[0-9]+$
        -frame_size_max             NUMERIC
        -frame_size_min             NUMERIC
        -frame_size_step            NUMERIC
        -hosts_per_net              NUMERIC
        -indirect                   FLAG
        -inter_burst_gap            NUMERIC
        -inter_frame_gap            NUMERIC
        -inter_stream_gap           NUMERIC
        -intf_handle
        -ip_dst_addr                IP
        -ip_dst_count               RANGE 1-4294967295
        -ip_dst_count_step          NUMERIC
        -ip_dst_increment           RANGE 1-4294967295
        -ip_dst_increment_step      NUMERIC
        -ip_dst_prefix_len          RANGE 0-128
        -ip_dst_prefix_len_step     NUMERIC
        -ip_dst_range_step          IP
        -ip_range_count             NUMERIC
        -l3_protocol                CHOICES ipv4 ipv6
        -lan_range_count            NUMERIC
        -length_mode                CHOICES fixed increment distribution
                                    CHOICES quad gaussian random imix
                                    DEFAULT fixed
        -loop_count                 NUMERIC
        -mac_dst
        -mac_dst_count              RANGE 1-4294967295
        -mac_dst_count_step         NUMERIC
        -mac_dst_mode               CHOICES fixed increment
        -mac_dst_step               NUMERIC
        -name
        -num_dst_ports              NUMERIC
        -override_value_list
        -pkts_per_burst             NUMERIC
        -port_handle                REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -pvc_count                  RANGE 0-4294967295
        -pvc_count_step             NUMERIC
        -qos_type_ixn               CHOICES custom dscp tos ipv6
        -qos_value_ixn              ANY
        -ramp_up_percentage         NUMERIC
        -range_per_spoke            NUMERIC
                                    DEFAULT 1
        -rate_bps                   NUMERIC
        -rate_percent               DECIMAL
        -rate_pps                   DECIMAL
        -route_mesh                 CHOICES fully one_to_one
                                    DEFAULT fully
        -site_id                    RANGE 0-4294967295
        -site_id_enable             FLAG
        -site_id_step               NUMERIC
        -src_dest_mesh              CHOICES fully one_to_one none
                                    DEFAULT fully
        -stream_id
        -stream_packing             CHOICES merge_destination_ranges
                                    CHOICES one_stream_per_endpoint_pair
                                    CHOICES optimal_packing
                                    DEFAULT optimal_packing
        -test_objective_value       NUMERIC
        -track_by                   ANY
        -traffic_generator          CHOICES ixos ixnetwork ixaccess
        -transmit_mode              CHOICES continuous return_to_id_for_count
                                    DEFAULT continuous
        -tx_delay                   NUMERIC
        -use_all_ip_subnets         CHOICES 0 1
                                    DEFAULT 0
        -vci                        RANGE 0-4294967295
        -vci_increment              RANGE 0-4294967295
        -vci_increment_step         NUMERIC
        -vci_step                   NUMERIC
        -vlan_enable                FLAG
        -vlan_id                    RANGE 0-4095
        -vlan_id_mode               CHOICES fixed increment
        -vlan_id_step               NUMERIC
        -vpi                        RANGE 0-4294967295
        -vpi_increment              RANGE 0-4294967295
        -vpi_increment_step         NUMERIC
        -vpi_step                   NUMERIC
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    set retCode [checkIxNetwork "5.30"]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    if {[info exists emulation_src_handle] && [regexp {^^(/range:HLAPI)|(/topology:)} $emulation_src_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "The ngpf argument -emulation_src_handle $emulation_src_handle\
                is not valid when -traffic_generator is ixnetwork. Please try with -traffic generator ixnetwork_540"
        return $returnList
    }
    if {[info exists emulation_dst_handle] && [regexp {^^(/range:HLAPI)|(/topology:)} $emulation_dst_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "The ngpf argument -emulation_dst_handle $emulation_dst_handle\
                is not valid when -traffic_generator is ixnetwork. Please try with -traffic generator ixnetwork_540"
        return $returnList
    }
    
    if {$mode == "create"} {
        if {![info exists emulation_src_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -emulation_src_handle\
                    argument must be specified when the -mode argument\
                    is set to '$mode'."
            return $returnList
        }
        set stream_id [list]
        set rollback_list [list]
    }
    if {$mode == "reset"} {
        foreach name [array names ixnetwork_stream_ids] {
            ixNet remove $ixnetwork_stream_ids($name)
            unset ixnetwork_stream_ids($name)
        }
        if {[info exists port_handle]} {
            set result [ixNetworkGetPortObjref $port_handle]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port object\
                        reference associated to the $port_handle port\
                        handle while trying to reset the static\
                        endpoints - [keylget result log]."
                return $returnList
            } else {
                set protocol_objref \
                        [keylget result vport_objref]/protocols/static
            }
            foreach endpoint_type {atm fr ip lan} {
                set endpoint_list \
                        [ixNet getList $protocol_objref $endpoint_type]
                foreach endpoint $endpoint_list {
                    ixNet remove $endpoint
                }
            }
        }
        debug "ixNet commit"
        ixNet commit
        set current_streamid 0
        keylset returnList status $::SUCCESS
        return $returnList
    }
    if {$mode != "create" && $mode != "reset"} {
        if {![info exists stream_id]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -stream_id argument must be\
                    specified when the -mode argument is set to '$mode'."
            return $returnList
        }
        
        # If stream_id is a port handle ch/ca/po than this is tclHal EFM Script being run
        # with ixNetwork. For Backwards compatibility we will not return error but ignore the
        # call and print a warning
        if {[regexp -all {^[0-9]+/[0-9]+/[0-9]+$} $stream_id]} {
            puts "\nWARNING: If ::ixia::traffic_config -mode $mode was called with a -stream_id\
                        handle of an EFM stream returned by ::ixia::emulation_efm_config\
                        the call will be ignored. This is possible only with\
                        the IxTclHal implementation. This call will be ignored for backwards compatibility.\n"
            keylset returnList status $::SUCCESS
            return $returnList
        }
        
        switch -- $mode {
            "enable" {
                set retCode [ixNetworkNodeSetAttr $ixnetwork_stream_ids($stream_id) \
                        [list -enabled true] -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
                keylset returnList status $::SUCCESS
                return $returnList
            }
            "disable" {
                set retCode [ixNetworkNodeSetAttr $ixnetwork_stream_ids($stream_id) \
                        [list -enabled false] -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
                keylset returnList status $::SUCCESS
                return $returnList
            }
            "remove" {
                if {[info exists ixnetwork_stream_ids($stream_id)] == 1 && \
                        ([ixNet exists $ixnetwork_stream_ids($stream_id)] == "true" || [ixNet exists $ixnetwork_stream_ids($stream_id)] == 1)} {
                    ixNet remove $ixnetwork_stream_ids($stream_id)
                    unset ixnetwork_stream_ids($stream_id)
                    ixNet commit
                    keylset returnList status $::SUCCESS
                    return $returnList
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The '$stream_id'\
                            stream id does not exist."
                    return $returnList
                }
            }
        }
    }

    array set translate_transmit_mode [list                 \
        continuous                  continuous              \
        return_to_id_for_count      fixed                   \
    ]

    array set translate_src_dest_mesh [list                 \
        fully                       fullMesh                \
        one_to_one                  oneToOne                \
        none                        none                    \
    ]

    array set translate_route_mesh [list                    \
        fully                       fullMesh                \
        one_to_one                  oneToOne                \
    ]

    array set translate_circuit_type [list                  \
        none                        nonMpls                 \
        l2vpn                       l2vpn                   \
        l3vpn                       l3vpn                   \
        mpls                        mpls                    \
        6pe                         6pe                     \
        6vpe                        6vpe                    \
        raw                         raw                     \
        vpls                        bgpVpls                 \
        stp                         nonMpls                 \
        mac_in_mac                  macInMac                \
    ]

    array set translate_circuit_endpoint_type [list         \
        atm                         atm                     \
        ethernet_vlan               ethernetVlan            \
        frame_realy                 frameRelay              \
        hdlc                        hdlc                    \
        ipv4                        ipv4                    \
        ipv4_application_traffic    ipv4ApplicationTraffic  \
        ipv6                        ipv6                    \
        ipv6_application_traffic    ipv6ApplicationTraffic  \
        ppp                         ppp                     \
    ]

    array set translate_track_by {
        assured_forwarding_phb      assuredForwardingPhb
        class_selector_phb          classSelectorPhb
        default_phb                 defaultPhb
        expedited_forwarding_phb    expeditedForwardingPhb
        tos                         tos
        raw_priority                rawPriority
        endpoint_pair               endpointPair
        dest_ip                     destIp
        source_ip                   sourceIp
        ipv6_flow_label             ipv6FlowLabel
        mpls_label                  mplsLabel
        dlci                        dlci
        src_mac                     srcMac
        dest_mac                    destMac
        inner_vlan                  innerVlan
        custom_8bit                 custom8bit
        custom_16bit                custom16bit
        custom_24bit                custom24bit
        custom_32bit                custom32bit
        none                        none
        b_src_mac                   bSrcMac
        b_dest_mac                  bDestMac
        b_vlan                      bVlan
        i_tag_isid                  iTagIsid
        c_src_mac                   cSrcMac
        c_dest_mac                  cDestMac
        s_vlan                      sVlan
        c_vlan                      cVlan
    }
    
    

    # Set global traffic arguments
    set traffic_args {
        -enableMinFrameSize            true
        -refreshLearnedInfoBeforeApply true
    }
    if {[info exists transmit_mode]} {
        lappend traffic_args -globalIterationMode \
                $translate_transmit_mode($transmit_mode)
    }
    if {[info exists loop_count]} {
        lappend traffic_args -globalIterationCount \
                $loop_count
    }
    
    set retCode [ixNetworkNodeSetAttr [ixNet getRoot]traffic $traffic_args]
    if {[keylget retCode status] != $::SUCCESS} {
        return $retCode
    }

    if {$mode == "create"} {
        # Add static endpints, if necessary
        if {![info exists emulation_dst_handle]} {
            # Check the destination port handle
            set result [ixNetworkGetPortObjref $port_handle]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port object\
                        reference associated to the $port_handle port\
                        handle while trying to create the static\
                        endpoints - [keylget result log]."
                return $returnList
            } else {
                set port_objref [keylget result vport_objref]
            }

            # Check the destination enpoint parameters
            set endpoint_params [list atm_range_count vpi_step                  \
                    vpi_increment_step vci_step vci_increment_step              \
                    pvc_count_step vci vci_increment vpi vpi_increment          \
                    pvc_count atm_header_encapsulation fr_range_count           \
                    dlci_value_step dlci_repeat_count_step dlci_value           \
                    dlci_count_mode dlci_repeat_count ip_range_count            \
                    ip_dst_range_step ip_dst_prefix_len_step                    \
                    ip_dst_increment_step ip_dst_count_step intf_handle         \
                    l3_protocol ip_dst_addr ip_dst_prefix_len ip_dst_increment  \
                    ip_dst_count lan_range_count indirect range_per_spoke       \
                    mac_dst_step mac_dst_count_step vlan_id_step site_id_step   \
                    mac_dst mac_dst_mode mac_dst_count vlan_enable vlan_id      \
                    vlan_id_mode site_id_enable site_id                         \
                    ]

            set endpoint_creation_args "-port_objref $port_objref"
            foreach endpoint_param $endpoint_params {
                if {[info exists $endpoint_param]} {
                    append endpoint_creation_args \
                            " -$endpoint_param [set $endpoint_param]"
                }
            }

            if {$endpoint_creation_args != {}} {
                # Create the endpoint(s)
                set result [eval ixNetworkStaticEndpointCfg \
                        $endpoint_creation_args]
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "No endpoint arguments have been\
                        specified and the destination handle is missing. No\
                        traffic can be configured unless valid destination\
                        enpoint arguments or one or more valid destination\
                        handles are specified."
                return $returnList
            }

            # Process the result
            if {![catch {keylget result atm_endpoints}]} {
                set atm_endpoints [keylget result atm_endpoints]
            } else {
                set atm_endpoints [list]
            }
            if {![catch {keylget result fr_endpoints}]} {
                set fr_endpoints [keylget result fr_endpoints]
            } else {
                set fr_endpoints [list]
            }
            if {![catch {keylget result ip_endpoints}]} {
                set ip_endpoints [keylget result ip_endpoints]
            } else {
                set ip_endpoints [list]
            }
            if {![catch {keylget result lan_endpoints}]} {
                set lan_endpoints [keylget result lan_endpoints]
            } else {
                set lan_endpoints [list]
            }
            set emulation_dst_handle [concat $atm_endpoints $fr_endpoints \
                    $ip_endpoints $lan_endpoints]
#             set emulation_dst_handle [list $emulation_dst_handle]
        }

        if {[llength $emulation_src_handle] == 1} {
            set emulation_src_handle [list $emulation_src_handle]
        }
        if {[llength $emulation_dst_handle] == 1} {
            set emulation_dst_handle [list $emulation_dst_handle]
        }
        if {[info exists bidirectional] && $bidirectional == 1} {
            set pair_list [list                                 \
                    $emulation_src_handle $emulation_dst_handle \
                    $emulation_dst_handle $emulation_src_handle \
            ]
        } else {
            set pair_list [list                                 \
                    $emulation_src_handle $emulation_dst_handle \
            ]
        }
    } else {
        # For -mode set to 'modify'
        set pair_list [list dummy_src dummy_dst]
    }
        
    foreach {emulation_src_handle emulation_dst_handle} $pair_list {
        # Begin configuring traffic item circuit.
        if {$mode == "create"} {
            # Create traffic item argument list.
            if {![info exists name]} {
                set updated_name "TI$current_streamid-HLTAPI_TRAFFICITEM"
            } else {
                set updated_name "TI$current_streamid-$name"
            }
            incr current_streamid
            set traffic_item_args [list -enabled true -name $updated_name]
            if {[info exists src_dest_mesh]} {
                lappend traffic_item_args -srcDestMesh \
                        $translate_src_dest_mesh($src_dest_mesh)
            }
            if {[info exists route_mesh]} {
                lappend traffic_item_args -routeMesh \
                        $translate_route_mesh($route_mesh)
            }
            if {[info exists circuit_type]} {
                lappend traffic_item_args -encapsulationType \
                        $translate_circuit_type($circuit_type)
            }
            if {[info exists circuit_endpoint_type]} {
                lappend traffic_item_args -endpointType \
                        $translate_circuit_endpoint_type($circuit_endpoint_type)
            }
            set result [ixNetworkNodeAdd [ixNet getRoot]traffic \
                    trafficItem $traffic_item_args -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add a new traffic item -\
                        [keylget result log]."
                return $returnList
            } else {
                set traffic_item_objref [keylget result node_objref]
            }
            lappend stream_id $updated_name
            set ixnetwork_stream_ids($updated_name) $traffic_item_objref
            lappend rollback_list $updated_name

            # Transform real port handles to vport handles for raw traffic
            foreach src_item $emulation_src_handle {
                set src_item_idx [lsearch $emulation_src_handle $src_item]
                if {[regexp -all {^([0-9]+)/([0-9]+)/([0-9]+)} $src_item]} {
                    set result [::ixia::ixNetworkGetPortObjref $src_item]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The -emulation_src_handle\
                                argument contains the following values which\
                                are not valid traffic endpoints $src_item:\
                                [keylget result log]"
                        ixNetworkTrafficRollback $rollback_list
                        return $returnList
                    }
                    set emulation_src_handle [lreplace $emulation_src_handle \
                        $src_item_idx $src_item_idx [keylget result vport_objref]/protocols]
                } elseif {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/vlans:\d+/macRanges:\d+$} $src_item]} {
                    
                    regsub {vlans}     $src_item {vlan} src_item
                    regsub {macRanges} $src_item {mac}  src_item
                    
                    set emulation_src_handle [lreplace $emulation_src_handle \
                        $src_item_idx $src_item_idx $src_item]
                } elseif {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/trunk:\d+$} $src_item]} {
                    catch {unset trunk_mr_list}
                    if {[catch {ixNet getList $src_item macRanges} trunk_mr_list]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error when attempting to \
                                'ixNet getList $src_item macRanges'. $trunk_mr_list"
                        ixNetworkTrafficRollback $rollback_list
                        return $returnList
                    } elseif {[llength $trunk_mr_list] < 1} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not create traffic because PBB-TE\
                                trunk traffic source '$src_item' must have at least one\
                                Mac Range configured to use as source endpoint."
                        ixNetworkTrafficRollback $rollback_list
                        return $returnList
                    }
                    
                    set trunk_mr_idx 0
                    foreach single_trunk_mr $trunk_mr_list {
                        if {$trunk_mr_idx == 0} {
                            set emulation_src_handle [lreplace $emulation_src_handle \
                                    $src_item_idx $src_item_idx $single_trunk_mr]
                        } else {
                            lappend emulation_src_handle $single_trunk_mr
                        }
                        incr trunk_mr_idx
                    }
                }
            }

            foreach dst_item $emulation_dst_handle {
                set dst_item_idx [lsearch $emulation_dst_handle $dst_item]
                if {[regexp -all {^([0-9]+)/([0-9]+)/([0-9]+)} $dst_item]} {
                    set result [::ixia::ixNetworkGetPortObjref $dst_item]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The -emulation_dst_handle\
                                argument contains the following values which\
                                are not valid traffic endpoints $dst_item:\
                                [keylget result log]"
                        ixNetworkTrafficRollback $rollback_list
                        return $returnList
                    }
                    set emulation_dst_handle [lreplace $emulation_dst_handle \
                        $dst_item_idx $dst_item_idx [keylget result vport_objref]/protocols]
                } elseif {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/vlans:\d+/macRanges:\d+$} $dst_item]} {
                    
                    regsub {vlans}     $dst_item {vlan} dst_item
                    regsub {macRanges} $dst_item {mac}  dst_item

                    set emulation_dst_handle [lreplace $emulation_dst_handle \
                        $dst_item_idx $dst_item_idx $dst_item]
                } elseif {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/trunk:\d+$} $dst_item]} {
                    catch {unset trunk_mr_list}
                    if {[catch {ixNet getList $dst_item macRanges} trunk_mr_list]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error when attempting to \
                                'ixNet getList $dst_item macRanges'. $trunk_mr_list"
                        ixNetworkTrafficRollback $rollback_list
                        return $returnList
                    } elseif {[llength $trunk_mr_list] < 1} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not create traffic because PBB-TE\
                                trunk traffic destination '$dst_item' must have at least one\
                                Mac Range configured to use as destination endpoint."
                        ixNetworkTrafficRollback $rollback_list
                        return $returnList
                    }
                    
                    set trunk_mr_idx 0
                    foreach single_trunk_mr $trunk_mr_list {
                        if {$trunk_mr_idx == 0} {
                            set emulation_dst_handle [lreplace $emulation_dst_handle \
                                    $dst_item_idx $dst_item_idx $single_trunk_mr]
                        } else {
                            lappend emulation_dst_handle $single_trunk_mr
                        }
                        incr trunk_mr_idx
                    }
                }
            }

            # Create traffic item pair.
            # Check for invalid source endpoints.
            set result [ixNetworkCheckEndpoint $emulation_src_handle "src" \
                    $circuit_type $circuit_endpoint_type]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "The -emulation_src_handle\
                        argument contains the following list of values which\
                        are not valid traffic endpoints for the selected\
                        circuit type and circuit endpoint type:\
                        [keylget result log]"
                ixNetworkTrafficRollback $rollback_list
                return $returnList
            }
            
            # Adjust RSVP handles
            foreach src_item $emulation_src_handle {
                set src_item_idx [lsearch $emulation_src_handle $src_item]
                if {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+} $src_item]} {
                    # It is an RSVP handle. We must transform it to a valid RSVP traffic handle
                    set result [::ixia::ixnetwork_rsvp_get_valid_traffic_endpoint $src_item]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log [keylget result log]
                        ixNetworkTrafficRollback $rollback_list
                        return $returnList
                    }

                    set emulation_src_handle [lreplace $emulation_src_handle \
                        $src_item_idx $src_item_idx [keylget result endpointRef]]
                }
            }
            
            # Check for invalid destination endpoints.
            set result [ixNetworkCheckEndpoint $emulation_dst_handle "dst" \
                    $circuit_type $circuit_endpoint_type]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "The -emulation_dst_handle\
                        argument contains the following list of values which\
                        are not valid traffic endpoints for the selected\
                        circuit type and circuit endpoint type:\
                        [keylget result log]"
                ixNetworkTrafficRollback $rollback_list
                return $returnList
            }
            
            # Adjust RSVP handles
            foreach dst_item $emulation_dst_handle {
            if {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+} $dst_item]} {
                    # It is an RSVP handle. We must transform it to a valid RSVP traffic handle
                    set result [::ixia::ixnetwork_rsvp_get_valid_traffic_endpoint $dst_item]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log [keylget result log]
                        ixNetworkTrafficRollback $rollback_list
                        return $returnList
                    }

                    set emulation_dst_handle [lreplace $emulation_dst_handle \
                        $dst_item_idx $dst_item_idx [keylget result endpointRef]]
                }
            }

            # Adjust the BGP handles
            set l3site_regex {::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:.+}
            set src_handle [list]
            foreach handle $emulation_src_handle {
                if {[regexp $l3site_regex $handle]} {
                    debug "ixNet adjustIndexes $handle ::ixNet::OBJ-/vport/protocols/bgp/neighborRange.0"
                    lappend src_handle [ixNet adjustIndexes $handle ::ixNet::OBJ-/vport/protocols/bgp/neighborRange.0]
                } else {
                    lappend src_handle $handle
                }
            }
            set dst_handle [list]
            foreach handle $emulation_dst_handle {
                if {[regexp $l3site_regex $handle]} {
                    debug "ixNet adjustIndexes $handle ::ixNet::OBJ-/vport/protocols/bgp/neighborRange.0"
                    lappend dst_handle [ixNet adjustIndexes $handle ::ixNet::OBJ-/vport/protocols/bgp/neighborRange.0]
                } else {
                    lappend dst_handle $handle
                }
            }
            # Add the traffic item pair
            set result [ixNetworkNodeAdd $traffic_item_objref pair [list \
                    -sources $src_handle -destinations $dst_handle] -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add a new traffic item pair\
                        to the $traffic_item_objref traffic item -\
                        [keylget result log]."
                return $returnList
            }
        } elseif {$mode == "modify"} {
            set traffic_item_objref $ixnetwork_stream_ids($stream_id)
        }
        # Finished configuring traffic item circuit.

        # Begin configuring traffic item options.
        # check input parameters
        # check rate parameters
        set rate_options {rate_bps rate_pps  rate_percent inter_frame_gap}
        set rate_modes {bitRate packetsPerSecond lineRate packetGap}
        set clear_option false
        foreach rate_option $rate_options \
                rate_mode_item $rate_modes {
            if {[info exists $rate_option]} {
                if {$clear_option == true} {
                    unset $rate_option
                } else {
                    set clear_option true
                    set rate_mode $rate_mode_item
                }
            }
        }

        # options which should NOT be allowed
        array set frame_options {
            fixed {frame_size_max frame_size_min frame_size_step \
                    frame_size_distribution quad_gauss \
                    quad_gauss_max quad_gauss_min weight_pairs}
            increment {frame_size frame_size_distribution quad_gauss \
                    quad_gauss_max quad_gauss_min weight_pairs}
            distribution {frame_size frame_size_max frame_size_min \
                    frame_size_step quad_gauss quad_gauss_max quad_gauss_min \
                    weight_pairs}
            quad {frame_size frame_size_step \
                    frame_size_distribution weight_pairs}
            gaussian {frame_size frame_size_step \
                    frame_size_distribution weight_pairs}
            random {frame_size frame_size_step frame_size_distribution 
                    quad_gauss quad_gauss_max quad_gauss_min weight_pairs}
            imix {frame_size frame_size_max frame_size_min frame_size_step \
                    frame_size_distribution quad_gauss \
                    quad_gauss_max quad_gauss_min}
        }

        foreach frame_option $frame_options($length_mode) {
            if {[info exists $frame_option]} {
                unset $frame_option
            }
        }

        # set the frame length mode
        array set frameSizeModeArray {
                fixed           fixed \
                increment       increment \
                distribution    predefinedDistribution \
                gaussian        quadGaussian \
                quad            quadGaussian \
                random          random \
                imix            weightPairs \
        }
        
        set retCode [ixNetworkNodeSetAttr $traffic_item_objref/frameOptions \
                [list -frameSizeMode $frameSizeModeArray($length_mode)] -commit]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }

        # frame_size_max and frame_size min should initialize different
        # attributes based on length_mode value 
        set frameOpt N/A
        set frameSizeMax N/A
        set frameSizeMin N/A
        switch -- $length_mode {
            increment {
                set frameOpt increment
                set frameSizeMax incrementMax
                set frameSizeMin incrementMin
            }
            gaussian {
                set frameOpt quadGaussian
                set frameSizeMax quadGaussianMax
                set frameSizeMin quadGaussianMin
            }
            quad {
                set frameOpt quadGaussian
                set frameSizeMax quadGaussianMax
                set frameSizeMin quadGaussianMin
            }
            random {
                set frameOpt random
                set frameSizeMax randomMax
                set frameSizeMin randomMin
            }
        }

        # qos_value should have a valid value based on the qos_type_ixn
        catch {ixNet getAttribute $traffic_item_objref -endpointType} epType
        set type_string "qosValueTosArray"
        if {($epType == "ipv4" || $epType == "ipv6") && \
                ([info exists qos_type_ixn] || [info exists qos_value_ixn])} {
            if {[catch {ixNet getAttribute $traffic_item_objref/packetOptions -qosType}]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to configure the QoS type or\
                            value. This feature is not present in this IxNetwork release."
                    ixNetworkTrafficRollback $rollback_list
                    return $returnList
            }
            array set validateEpTypeQosType {
                ipv4            "custom dscp tos"
                ipv4,default    "tos"
                ipv6            "ipv6"
                ipv6,default    "ipv6"
            }
            if {![info exists qos_type_ixn]} {
                set qos_type_ixn $validateEpTypeQosType(${epType},default)
            } else {
                # if qos_value does not have a valid value for the coresponding endpointType
                # return an error
                if {[lsearch $validateEpTypeQosType($epType) $qos_type_ixn] == -1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Parameter '-qos_type_ixn $qos_type_ixn' is\
                            not valid for '-endpoint_type ${epType}'. Valid choices are:\
                            $validateEpTypeQosType($epType)"
                    ixNetworkTrafficRollback $rollback_list
                    return $returnList
                }
            }
            
            # if qos_value does not exist set it to default
            if {![info exists qos_value_ixn]} {
                switch -- $qos_type_ixn {
                    "custom" -
                    "ipv6" {
                        set qos_value_ixn 0
                    }
                    "dscp" {
                        set qos_value_ixn "dscp_default"
                    }
                    "tos" {
                        set qos_value_ixn 0
                    }
                }
            }
            
            array set qosTypeArray {
                custom          Custom
                dscp            DSCP
                tos             TOS
                ipv6            IPv6
            }
            
            array set qosValueDscpArray {
                dscp_default                    Default
                af_class1_low_precedence        AF11
                af_class1_medium_precedence     AF12
                af_class1_high_precedence       AF13
                af_class2_low_precedence        AF21
                af_class2_medium_precedence     AF22
                af_class2_high_precedence       AF23
                af_class3_low_precedence        AF31
                af_class3_medium_precedence     AF32
                af_class3_high_precedence       AF33
                af_class4_low_precedence        AF41
                af_class4_medium_precedence     AF42
                af_class4_high_precedence       AF43
                ef                              EF
                cs_precedence1                  C1
                cs_precedence2                  C2
                cs_precedence3                  C3
                cs_precedence4                  C4
                cs_precedence5                  C5
                cs_precedence6                  C6
                cs_precedence7                  C7
            }
            
            array set qosValueTosArray {
                0                               "\"000 Routine\""
                1                               "\"001 Priority\""
                2                               "\"010 Immediate\""
                3                               "\"011 Flash\""
                4                               "\"100 Flash Override\""
                5                               "\"101 CRITIC/ECP\""
                6                               "\"110 Internetwork Control\""
                7                               "\"111 Network Control\""
            }
            
            # Check if qos_value has a value from the choices provided
            # This is done because an error should be returned if the value doesn't corespond to
            # any of the qos_type_ixn values or it should be set to default if the value is
            # for another qos_type_ixn value then the one configured here
            if {![string is integer $qos_value_ixn] || $qos_value_ixn < 0 || $qos_value_ixn > 255} {
               # It's not an integer
                    if {[lsearch [array names qosValueDscpArray] $qos_value_ixn] == -1} {
                    # It's not a DSCP choice
                    if {[lsearch [array names qosValueTosArray] $qos_value_ixn] == -1} {
                        # It's not a TOS choice either -> return error
                        keylset returnList status $::FAILURE
                        keylset returnList log "Parameter '-qos_value_ixn $qos_value_ixn' is\
                                not valid. Valid choices are: a number in the \[0-255\] range\
                                or one of [array names qosValueDscpArray]"
                        ixNetworkTrafficRollback $rollback_list
                        return $returnList
                    }
               }
            }
            
            # Validate qos_value_ixn and set to default if invalid
            switch -- $qos_type_ixn {
                "custom" -
                "ipv6" {
                    if {![string is integer $qos_value_ixn] || $qos_value_ixn < 0 || $qos_value_ixn > 255} {
                        set qos_value_ixn 0
                    }
                    set type_string array
                }
                "dscp" {
                    if {[lsearch [array names qosValueDscpArray] $qos_value_ixn] == -1} {
                        set qos_value_ixn "dscp_default"
                    }
                    set type_string "qosValueDscpArray"
                }
                "tos" {
                    if {[lsearch [array names qosValueTosArray] $qos_value_ixn] == -1} {
                        set qos_value_ixn 0
                    }
                    set type_string "qosValueTosArray"
                }
            }
        }
        

        # setting parameter to objref
        #       hlt_api_option          ixnetwork_attribute      
        #       ixnetwork_object                       type
        set stream_options " \
                hosts_per_net           hostsPerNetwork                     \
                /                                      numeric              \
                allow_self_destined     allowSelfDestined                   \
                /                                      flag                 \
                stream_packing          streamPackingMode                   \
                /                                      streamPackingArray   \
                data_pattern_mode       payloadType                         \
                /                                      payloadTypeArray     \
                data_pattern            payloadData                         \
                /                                      stringHex            \
                fcs_type                forceError                          \
                /                                      forceErrorArray      \
                frame_size              fixedFrameSize                      \
                /frameOptions/fixed                    numeric              \
                frame_size_max          $frameSizeMax                       \
                /frameOptions/$frameOpt                numeric              \
                frame_size_min          $frameSizeMin                       \
                /frameOptions/$frameOpt                numeric              \
                frame_size_step         incrementStep                       \
                /frameOptions/increment                numeric              \
                frame_size_distribution predefinedDistribution              \
                /frameOptions/predefinedDistribution   frameSizeDistArray   \
                frame_size_gauss        quadGaussianDistributions           \
                /frameOptions/quadGaussian             array                \
                frame_size_imix         weightPairs                         \
                /frameOptions/weightPairs              array                \
                qos_type_ixn            qosType                             \
                /packetOptions                         qosTypeArray         \
                qos_value_ixn           qosValue                            \
                /packetOptions                         $type_string         \
                pkts_per_burst          packetsPerBurst                     \
                /rateOptions                           numeric              \
                burst_loop_count        burstsPerStream                     \
                /rateOptions                           numeric              \
                rate_pps                packetsPerSecond                    \
                /rateOptions                           numeric              \
                rate_bps                bitRate                             \
                /rateOptions                           numeric              \
                rate_percent            lineRate                            \
                /rateOptions                           numeric              \
                inter_frame_gap         packetGap                           \
                /rateOptions                           numeric              \
                enforce_min_gap         enforceMinGap                       \
                /rateOptions                           numeric              \
                tx_delay                txDelay                             \
                /rateOptions                           numeric              \
                inter_burst_gap         interBurstGap                       \
                /rateOptions                           numeric              \
                inter_stream_gap        interStreamGap                      \
                /rateOptions                           numeric              \
                inter_burst_gap         enableInterBurstGap                 \
                /rateOptions                           pseudoFlag           \
                inter_stream_gap        enableInterStreamGap                \
                /rateOptions                           pseudoFlag           \
                pkts_per_burst_type     packetCountType                     \
                /rateOptions                           enum                 \
                rate_mode               rateMode                            \
                /rateOptions                           enum                 \
        "

        # setting choices
        if {[info exists pkts_per_burst] && (![info exists transmit_mode] || [is_default_param_value "transmit_mode" $args] || $transmit_mode != "continuous")} {
            set pkts_per_burst_type fixed
        }

        # arrays used for convert HLT parameters to ixNetwork TCL parameters
        array set streamPackingArray {
                merge_destination_ranges        mergeDestinationRanges      \
                one_stream_per_endpoint_pair    oneStreamPerEndpointPair    \
                optimal_packing                 optimalPacking              \
        }

        array set payloadTypeArray {
                decr_byte                       decByte                     \
                decr_word                       decWord                     \
                incr_byte                       incByte                     \
                incr_word                       incWord                     \
                repeating                       repeat                      \
                fixed                           fixed
        }

        array set frameSizeDistArray {
                cisco                       cisco                           \
                imix                        imix                            \
                quadmodal                   quadmodal                       \
                tolly                       tolly                           \
                trimodal                    trimodal                        \
        }

        if {[info exists fcs] && $fcs} {
            array set forceErrorArray {
                    bad_CRC                 badCrc                          \
                    no_CRC                  noCrc                           \
                    no_error                noError                         \
            }
        } else {
            array set forceErrorArray {
                    bad_CRC                 noError                         \
                    no_CRC                  noError                         \
                    no_error                noError                         \
            }
        }

        # prepare values for arrays
        if {[info exists frame_size_gauss] && \
            [llength $frame_size_gauss] > 0} {
            set tmp_frame_size_gauss {}
            foreach frame_gauss_item $frame_size_gauss {
                if {[regexp "^(\[0-9\]+)\[: \]{1}(\[0-9\]+(\.\[0-9\])*)\[: \]{1}(\[0-9\]+)$" \
                    $frame_gauss_item all nr1 nr2 nr3 nr4] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid parameter\
                            frame_size_gauss. The valid format is represented\
                            through the following regular expression:\
                            ^(\[0-9\]+):(\[0-9\]+(\.\[0-9\])*):(\[0-9\]+)$"
                    ixNetworkTrafficRollback $rollback_list
                    return $returnList
                }
                lappend tmp_frame_size_gauss [list $nr1 $nr4 $nr2]
            }
            if {[lindex $tmp_frame_size_gauss 0] == [lindex \
                    $tmp_frame_size_gauss 0 0]} {
                set frame_size_gauss [list $tmp_frame_size_gauss]
            } else {
                set frame_size_gauss $tmp_frame_size_gauss
            }
        }

        if {[info exists frame_size_imix] && [llength $frame_size_imix] > 0} {
            set tmp_frame_size_imix {}
            foreach frame_size_item $frame_size_imix {
                if {[regexp -- "^(\[0-9\]+)\[: \]{1}(\[0-9\]+)$" $frame_size_item all \
                        nr1 nr2] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid parameter\
                            frame_size_imix. The valid format is represented\
                            through the following regular expression:\
                            ^(\[0-9\]+):(\[0-9\]+)$"
                    ixNetworkTrafficRollback $rollback_list
                    return $returnList
                }
                lappend tmp_frame_size_imix [list $nr1 $nr2]
            }
            if {[lindex $tmp_frame_size_imix 0] == [lindex \
                    $tmp_frame_size_imix 0 0]} {
                set frame_size_imix [list $tmp_frame_size_imix]
            } else {
                set frame_size_imix $tmp_frame_size_imix
            }
        }

        # setting attributes for current objRef
        foreach {param cmd addr type} $stream_options {
            # if position is direct in objref we do not need to append anything
            if {$addr == "/"} {set addr ""}
            if {[info exists $param]} {
                switch -regexp -- $type {
                    {(.*)Array$} {
                        # we need to translate parameter from HLT to ixNet TCL V
                        set setAttrCmd "ixNet setAttr $traffic_item_objref$addr"
                        append setAttrCmd " -$cmd [set ${type}([set $param])]" 
                    }
                    {array} {
                        set setAttrCmd "ixNet setAttr $traffic_item_objref$addr"
                        append setAttrCmd " -$cmd \"[set $param]\""
                    }
                    {(numeric)|(enum)} {
                        set setAttrCmd "ixNet setAttr $traffic_item_objref$addr"
                        append setAttrCmd " -$cmd [set $param]"
                    }
                    {flag} {
                        set setAttrCmd "ixNet setAttr $traffic_item_objref$addr"
                        append setAttrCmd " -$cmd $truth([set $param])"
                    }
                    {stringHex} {
                        # converting to hex bytes
                        set retCode [::ixia::format_field_hex [set $param]]
                        if {[keylget retCode status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Unable to set the -$param.\
                                [keylget retCode log]"
                            ixNetworkTrafficRollback $rollback_list
                            return $retCode
                        }
                        set $param [string toupper [keylget retCode hexNumber]]
                        
                        set setAttrCmd  "ixNet setAttr    \
                                $traffic_item_objref$addr \
                                -$cmd \"[set $param]\""
                    }
                    {pseudoFlag} {
                        set setAttrCmd "ixNet setAttr $traffic_item_objref$addr"
                        append setAttrCmd " -$cmd true"
                    }
                }
                debug "$setAttrCmd"
                if [catch {eval $setAttrCmd} ret_val] {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to set the -$param\
                            attribute - received '$ret_val' when running\
                            $setAttrCmd."
                    ixNetworkTrafficRollback $rollback_list
                    return $returnList
                }
            }
        }
        #
        puts "WARNING: IxNetwork 5.30 traffic configuration detected! Executing traffic apply in order for the changes to be visible in IxNetwork."
        catch {ixNet exec apply [ixNet getRoot]/traffic} msg
        if {$msg != "::ixNet::OK"} {
            puts "\tTraffic Apply Result: $msg"
        }
        
        ixNet commit
        # Finished configuring traffic item options.

        # Begin configuring traffic item tracking.
        if {[info exists track_by] && $track_by != "none"} {
            # Invalid combination warnings.
            if {![regexp {custom_} $track_by] && \
                    [info exists custom_offset]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The -custom_offset argument has\
                        an effect only when used in conjunction with the\
                        'custom_8bit', 'custom_16bit', 'custom_24bit' or\
                        'custom_32bit' choices of the -track_by argument."
                ixNetworkTrafficRollback $rollback_list
                return $returnList
            }
            if {![regexp {(_phb|tos|raw_priority|inner_vlan|custom_)} \
                    $track_by] && [info exists enable_override_value] && \
                    $enable_override_value} {
                keylset returnList status $::FAILURE
                keylset returnList log "The -enable_override_value\
                        argument has an effect only when used in conjunction\
                        with the 'assured_forwarding_phb',\
                        'class_selector_phb', 'default_phb',\
                        'expedited_forwarding_phb', 'tos', 'raw_priority' or\
                        'inner_vlan' choices of the -track_by argument. Also,\
                        it is always enabled when using the\
                        'custom_8bit', 'custom_16bit', 'custom_24bit' or\
                        'custom_32bit' choices of the -track_by argument."
                ixNetworkTrafficRollback $rollback_list
                return $returnList
            }
            if {![regexp {(_phb|tos|raw_priority|inner_vlan|custom_)} \
                    $track_by] && [info exists override_value_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The -override_value_list\
                        argument has an effect only when used in conjunction\
                        with the 'assured_forwarding_phb',\
                        'class_selector_phb', 'default_phb',\
                        'expedited_forwarding_phb', 'tos', 'raw_priority',\
                        'inner_vlan', 'custom_8bit', 'custom_16bit',\
                        'custom_24bit' or 'custom_32bit' choices of the\
                        -track_by argument."
                ixNetworkTrafficRollback $rollback_list
                return $returnList
            }

            # Configure tracking mode.
            set available_tracking [ixNet getAttribute \
                    ${traffic_item_objref}/tracking -availableTrackBy]
            
            if {[lsearch $available_tracking \
                    $translate_track_by($track_by)] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "The -track_by argument does not\
                        contain a valid value for the configured traffic\
                        circuit."
                ixNetworkTrafficRollback $rollback_list
                return $returnList
            } else {
                set retCode [ixNetworkNodeSetAttr ${traffic_item_objref}/tracking \
                        [list -selectedTrackBy $translate_track_by($track_by)] \
                        -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
            }

            # Configure tracking parameters.
            set traffic_tracking_args [list]
            if {[regexp {custom_} $track_by]} {
                set enable_override_value 1
                if {[info exists custom_offset]} {
                    lappend traffic_tracking_args -customOffset $custom_offset
                }
            }
            if {[regexp {(_phb|tos|inner_vlan|raw_priority|custom_)} $track_by]\
                    && [info exists enable_override_value] && $enable_override_value} {
                lappend traffic_tracking_args -enableOverrideValue \
                        $truth($enable_override_value)
                if {[info exists override_value_list]} {
                    set result [ixNetworkCheckValueList $override_value_list \
                            $track_by]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The -override_value_list\
                                argument contains a list of values that is\
                                invalid for the '$track_by' choice of the\
                                -track_by argument. [keylget result log]"
                        ixNetworkTrafficRollback $rollback_list
                        return $returnList
                    }
                    lappend traffic_tracking_args -overrideValueList \
                            [keylget result override_value_list]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The -enable_override_value\
                            argument has been set to 1 but the\
                            -override_value_list argument was not used."
                    ixNetworkTrafficRollback $rollback_list
                    return $returnList
                }
            }

            # Commit the traffic setup.
            set retCode [ixNetworkNodeSetAttr ${traffic_item_objref}/tracking \
                    $traffic_tracking_args -commit]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
        # Finished configuring traffic item tracking.
    }

    keylset returnList status $::SUCCESS
    keylset returnList stream_id $stream_id
    return $returnList
}

proc ::ixia::ixnetwork_traffic_control {args man_args opt_args} {
    variable ixnetwork_port_handles_array
    variable current_streamid
    variable ixnetwork_stream_ids
    
    set procName [lindex [info level [info level]] 0]
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
			
	# keep backwards compatibility		
    switch -- $traffic_generator {
        "ixnetwork_540" {
            # next gen traffic used
        }
        "ixnetwork" {
            if {[string first "P2NO" $::ixia::ixnetworkVersion] > 0 && \
                    [info exists ::ixia::forceNextGenTraffic] &&\
                    $::ixia::forceNextGenTraffic == 1} {
                
                set traffic_generator "ixnetwork_540"
            }
        }
        default {
            set traffic_type "ixos"
            if {[is_default_param_value "traffic_generator" $args]} {
                if {[string first "NO" $::ixia::ixnetworkVersion] > 0} {
                    set traffic_generator "ixnetwork_540"
                }
            }
        }            
    }
	
    if {$traffic_generator == "ixnetwork"} {
        # Split PGID settings were moved from interface config to traffic control
        # because the default traffic generator was changed to Next Gen Traffic
        # Unless we don't have explicit Legacy traffic generator we shouldn't 
        # configure Split PGID
        set ret_status [ixNetworkSplitPgidConfig]
        if {[keylget ret_status status] != $::SUCCESS} {
            return $ret_status
        }
    }
    
	
	 switch -- $action {
        sync_run -
        run {            
            # Start sending EFM Event tlvs for backwards compatibility with IxTclHal implementation.
            if {[info exists port_handle]} {
                
                set efm_found 0
                
                foreach port_h $port_handle {
                    set tmp_status [check_efm_port $port_h]
                    if {[keylget tmp_status status] == $::SUCCESS} {
                        set efm_found 1
                        
                        # Send Event TLVS
                        puts "\nAn EFM configuration exists on the $port_h port.\
                                $procName -action $action will perform the same function as\
                                ::ixia::emulation_efm_control -action start_event."
                        
                        
                        set run_status [emulation_efm_control -port_handle $port_h -action start_event]
                        if {[keylget run_status status] != $::SUCCESS} {
                            keylset run_status log "ERROR in ${procName}: [keylget run_status log]"
                            return $run_status
                        }
                        
                    } else {
                        # EFM Not configured on this port
                    }
                }
            }
        }
        stop {
        
            # Stop sending EFM Event tlvs for backwards compatibility with IxTclHal implementation.
            if {[info exists port_handle]} {
            
                set efm_found 0
                foreach port_h $port_handle {
                    set tmp_status [check_efm_port $port_h]
                    if {[keylget tmp_status status] == $::SUCCESS} {
                        set efm_found 1
                        
                        # Send Event TLVS
                        puts "\nAn EFM configuration exists on the $port_h port.\
                                $procName -action $action will perform the same function as\
                                ::ixia::emulation_efm_control -action stop_event."
                        
                        set run_status [emulation_efm_control -port_handle $port_h -action stop_event]
                        if {[keylget run_status status] != $::SUCCESS} {
                            keylset run_status log "ERROR in ${procName}: [keylget run_status log]"
                            return $run_status
                        }
                    } else {
                        # EFM Not configured on this port
                    }
                }
                
                if {[ixNet getList [ixNet getRoot]traffic trafficItem] == ""} {
                    keylset returnList status $::SUCCESS
                    return $returnList
                }
            }
        }
	}
	
	set index [lsearch $args -traffic_generator]
	if {$index>=0} {
		set index [expr $index+1]
		set command_generator [lindex $args $index]
		if {$command_generator != $traffic_generator} {	
			set args [lreplace $args $index $index $traffic_generator]
		}
	} else {
		lappend args -traffic_generator $traffic_generator
	}
	
	# call ngpf traffic_control command
	set returnList [eval ::ixiangpf::ixnetwork_traffic_control $args]
	
    return $returnList
	
}


proc ::ixia::ixnetwork_traffic_stats { args opt_args} {
    variable ixnetwork_port_handles_array
    variable ixnetwork_stream_ids
    set keyed_array_index 0
    variable traffic_stats_num_calls
    set keyed_array_name traffic_stats_returned_keyed_array_$traffic_stats_num_calls
    mpincr traffic_stats_num_calls
    variable $keyed_array_name
    catch {array unset $keyed_array_name}
    array set $keyed_array_name ""
    variable traffic_stats_max_list_length
    
    # Array which stores for each statistic key how many times it was added
    # in order to calculate it's average.
    array set avg_calculator_array ""
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    set retCode [checkIxNetwork "5.30"]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    if {![info exists mode]} {
        set mode "aggregate"
    }
    
    if {$mode == "aggregate" || $mode == "all"} {
        array set portStatsArray {
            "Scheduled Frames Tx."         {aggregate.tx.scheduled_pkt_count aggregate.tx.tx_aal5_scheduled_frames_count}
            "Scheduled Frames Tx. Rate"    {aggregate.tx.scheduled_pkt_rate aggregate.tx.tx_aal5_scheduled_frames_rate}
            "Line Speed"                   aggregate.tx.line_speed
            "Frames Tx."                   {aggregate.tx.pkt_count  aggregate.tx.total_pkts}
            "Frames Tx. Rate"              {aggregate.tx.pkt_rate   aggregate.tx.total_pkt_rate}
            "Bytes Tx."                    aggregate.tx.pkt_byte_count
            "Bytes Tx. Rate"               aggregate.tx.pkt_byte_rate
            "Tx. Rate (bps)"               aggregate.tx.pkt_bit_rate
            "Tx. Rate (Kbps)"              aggregate.tx.pkt_kbit_rate
            "Tx. Rate (Mbps)"              aggregate.tx.pkt_mbit_rate
            "Bytes Rx."                    aggregate.rx.pkt_byte_count
            "Bytes Rx. Rate"               aggregate.rx.pkt_byte_rate
            "Rx. Rate (bps)"               aggregate.rx.pkt_bit_rate
            "Rx. Rate (Kbps)"              aggregate.rx.pkt_kbit_rate
            "Rx. Rate (Mbps)"              aggregate.rx.pkt_mbit_rate
            "Data Integrity Frames Rx."    aggregate.rx.data_int_frames_count
            "Data Integrity Errors"        aggregate.rx.data_int_errors_count
            "Collisions"                   aggregate.rx.collisions_count
            "Valid Frames Rx."             aggregate.rx.pkt_count
            "Valid Frames Rx. Rate"        aggregate.rx.pkt_rate
            "AAL5 Frames Rx."              aggregate.rx.rx_aal5_frames_count
            "ATM Cells Rx."                aggregate.rx.rx_atm_cells_count
            "AAL5 Payload Bytes Tx."       aggregate.tx.tx_aal5_bytes_count
            "AAL5 Frames Tx."              aggregate.tx.tx_aal5_frames_count
            "Scheduled Cells Tx."          aggregate.tx.tx_aal5_scheduled_cells_count
            "ATM Cells Tx."                aggregate.tx.tx_atm_cells_count
            "AAL5 Frames Rx. Rate"         aggregate.rx.rx_aal5_frames_rate
            "ATM Cells Rx. Rate"           aggregate.rx.rx_atm_cells_rate
            "AAL5 Payload Bytes Tx. Rate"  aggregate.tx.tx_aal5_bytes_rate              
            "AAL5 Frames Tx. Rate"         aggregate.tx.tx_aal5_frames_rate
            "Scheduled Cells Tx. Rate"     aggregate.tx.tx_aal5_scheduled_cells_rate
            "ATM Cells Tx. Rate"           aggregate.tx.tx_atm_cells_rate
        }
        if {![info exists port_handle]} {
            set port_handle [array names ixnetwork_port_handles_array]
        }
        set retCode [ixNetworkGetBrowserStats "statViewBrowser" "Port Statistics"]
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        set pageCount [keylget retCode page]
        set rowCount  [keylget retCode row]
        array set rowsArray [keylget retCode rows]
        for {set i 1} {$i < $pageCount} {incr i} {
            for {set j 1} {$j < $rowCount} {incr j} {
                if {![info exists rowsArray($i,$j)]} { continue }
                set rowName $rowsArray($i,$j)
                set matched [regexp {(.+)/Card([0-9]{2})/Port([0-9]{2})} \
                        $rowName matched_str hostname cd pt]
                if {$matched && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                    set ch_ip $hostname
                }
                
                if {$matched && ($matched_str == $rowName) && \
                        [info exists ch_ip] && [info exists cd] && \
                        [info exists pt] } {
                    set ch [ixNetworkGetChassisId $ch_ip]
                }
                set cd [string trimleft $cd 0]
                set pt [string trimleft $pt 0]
                set statPort $ch/$cd/$pt
                if {[lsearch $port_handle $statPort] != -1} {
                    foreach statName [array names portStatsArray] {
                        if {![info exists rowsArray($i,$j,$statName)] } {continue}
                        if {![info exists portStatsArray($statName)]  } {continue}
                        foreach retStatName $portStatsArray($statName) {
                            set [subst $keyed_array_name]($statPort.$retStatName) $rowsArray($i,$j,$statName)
                            incr keyed_array_index
                        }
                    }
                }
            }
        }
    }
    if {$mode == "stream" || $mode == "streams"  || $mode == "all"} {
        # This array has the following meaning
        # index: IxN stat name
        # value: a keyed list with the following keys 
        # - hltName  - the name of the HLT stat to be returned
        # - statType - the type of the stat: sum, avg, or none
        array set trafficStatsArray {
            "Tx Frames"             {{hltName tx.total_pkts}               {statType sum}}
            "Rx Frames"             {{hltName rx.total_pkts}               {statType sum}}
            "Frames Delta"          {{hltName rx.loss_pkts}                {statType sum}}
            "Rx Frame Rate"         {{hltName rx.total_pkt_rate}           {statType avg}}
            "Tx Frame Rate"         {{hltName tx.total_pkt_rate}           {statType avg}}
            "Loss %"                {{hltName rx.loss_percent}             {statType sum}}
            "Rx Bytes"              {{hltName {rx.total_pkts_bytes rx.total_pkt_bytes}} {statType {sum sum}}}
            "Rx Rate (Bps)"         {{hltName rx.total_pkt_byte_rate}      {statType avg}}
            "Rx Rate (bps)"         {{hltName rx.total_pkt_bit_rate}       {statType avg}}
            "Rx Rate (Kbps)"        {{hltName rx.total_pkt_kbit_rate}      {statType avg}}
            "Rx Rate (Mbps)"        {{hltName rx.total_pkt_mbit_rate}      {statType avg}}
            "Avg Latency (ns)"      {{hltName rx.avg_delay}                {statType avg}}
            "Min Latency (ns)"      {{hltName rx.min_delay}                {statType avg}}
            "Max Latency (ns)"      {{hltName rx.max_delay}                {statType avg}}
            "First TimeStamp"       {{hltName rx.first_tstamp}             {statType none}}
            "Last TimeStamp"        {{hltName rx.last_tstamp}              {statType none}}
        }
        set streamNames ""
        if {[info exists stream]} {
            set streamNames $stream
        } elseif {[info exists streams]} {
            set streamNames $streams
        }
        set retCode [ixNetworkGetBrowserStats "trafficStatViewBrowser" "Traffic Statistics"]
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        
        set pageCount [keylget retCode page]
        set rowCount  [keylget retCode row]
        array set rowsArray [keylget retCode rows]
        set resetPortList ""
        for {set i 1} {$i < $pageCount} {incr i} {
            for {set j 1} {$j < $rowCount} {incr j} {
                if {![info exists rowsArray($i,$j)]} { continue }    
                set rowInfo     [ixNetworkParseRowName $rowsArray($i,$j)]
                set txPort      [keylget rowInfo tx_port]
                set rxPort      [keylget rowInfo rx_port]
                set trafficName [keylget rowInfo stream_name]
                if {$txPort == "" }      {continue}
                if {$rxPort == "" }      {continue}
                if {$trafficName == "" } {continue}
                if {![info exists ixnetwork_stream_ids($trafficName)] } {continue}
                set streamId $ixnetwork_stream_ids($trafficName)
                if {$streamNames != ""} {
                    if {[lsearch $streamNames $trafficName] != -1} {
                        foreach statName [array names trafficStatsArray] {
                            set trafficStatArrayValue $trafficStatsArray($statName)
                            set retStatNameList [keylget trafficStatArrayValue hltName]
                            set statTypeList    [keylget trafficStatArrayValue statType]
                            foreach retStatName $retStatNameList statType $statTypeList {
                                if {![info exists rowsArray($i,$j,$statName)] } {
                                    if {[string first "tx." $retStatName] != -1} {
                                        set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) "N/A"
                                        incr keyed_array_index
                                    }
                                    if {[string first "rx." $retStatName] != -1} {
                                        set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) "N/A"
                                        incr keyed_array_index
                                    }
                                    continue
                                }
                                if {[string first "tx." $retStatName] != -1} {
                                    if {[catch {set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName)} oldValue]} {
                                        set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                        if {$statType == "avg"} {
                                            set avg_calculator_array([subst $keyed_array_name],$txPort.stream.$trafficName.$retStatName) 1
                                        }
                                        incr keyed_array_index
                                    } else {
                                        if {$statType == "sum"} {
                                            if {$oldValue != ""} {
                                                set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                                incr keyed_array_index
                                            }
                                        } elseif {$statType == "avg"} {
                                            if {$oldValue != ""} {
                                                set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                                incr avg_calculator_array([subst $keyed_array_name],$txPort.stream.$trafficName.$retStatName)
                                                incr keyed_array_index
                                            }
                                        } else {
                                            set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                            incr keyed_array_index
                                        }
                                        
                                    }
                                    
                                }
                                if {[string first "rx." $retStatName] != -1} {
                                    if {[catch {set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName)} oldValue]} {
                                        set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                        if {$statType == "avg"} {
                                            set avg_calculator_array([subst $keyed_array_name],$rxPort.stream.$trafficName.$retStatName) 1
                                        }
                                        incr keyed_array_index
                                    } else {
                                        if {$statType == "sum"} {
                                            if {$oldValue != ""} {
                                                set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                                incr keyed_array_index
                                            }
                                        } elseif {$statType == "avg"} {
                                            if {$oldValue != ""} {
                                                set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                                incr avg_calculator_array([subst $keyed_array_name],$rxPort.stream.$trafficName.$retStatName)
                                                incr keyed_array_index
                                            }
                                        } else {
                                            set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                            incr keyed_array_index
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    foreach statName [array names trafficStatsArray] {
                        set trafficStatArrayValue $trafficStatsArray($statName)
                        set retStatNameList [keylget trafficStatArrayValue hltName]
                        set statTypeList    [keylget trafficStatArrayValue statType]
                        foreach retStatName $retStatNameList statType $statTypeList {
                            if {![info exists rowsArray($i,$j,$statName)] } {
                                if {[string first "tx." $retStatName] != -1} {
                                    set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) "N/A"
                                    incr keyed_array_index
                                }
                                if {[string first "rx." $retStatName] != -1} {
                                    set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) "N/A"
                                    incr keyed_array_index
                                }
                                continue
                            }
                            if {[string first "tx." $retStatName] != -1} {
                                if {[catch {set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName)} oldValue]} {
                                    set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                    if {$statType == "avg"} {
                                        set avg_calculator_array([subst $keyed_array_name],$txPort.stream.$trafficName.$retStatName) 1
                                    }
                                    incr keyed_array_index
                                } else {
                                    if {$statType == "sum"} {
                                        if {$oldValue != ""} {
                                            set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                            incr keyed_array_index
                                        }
                                    } elseif {$statType == "avg"} {
                                        if {$oldValue != ""} {
                                            set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                            incr avg_calculator_array([subst $keyed_array_name],$txPort.stream.$trafficName.$retStatName)
                                            incr keyed_array_index
                                        }
                                    } else {
                                        set [subst $keyed_array_name]($txPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                        incr keyed_array_index
                                    }
                                }
                            }
                            if {[string first "rx." $retStatName] != -1} {
                                if {[catch {set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName)} oldValue] } {
                                    set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                    if {$statType == "avg"} {
                                        set avg_calculator_array([subst $keyed_array_name],$rxPort.stream.$trafficName.$retStatName) 1
                                    }
                                    incr keyed_array_index
                                } else {
                                    if {$statType == "sum"} {
                                        if {$oldValue != ""} {
                                            set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                            incr keyed_array_index
                                        }
                                    } elseif {$statType == "avg"} {
                                        if {$oldValue != ""} {
                                            set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                            incr avg_calculator_array([subst $keyed_array_name],$rxPort.stream.$trafficName.$retStatName)
                                            incr keyed_array_index
                                        }
                                    } else {
                                        set [subst $keyed_array_name]($rxPort.stream.$trafficName.$retStatName) $rowsArray($i,$j,$statName)
                                        incr keyed_array_index
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if {$mode == "per_port_flows" || $mode == "all"} {
        # This array has the following meaning
        # index: IxN stat name
        # value: a keyed list with the following keys 
        # - hltName  - the name of the HLT stat to be returned
        # - statType - the type of the stat: sum, avg, or none
        array set trafficStatsArray {
            "Tx Frames"             {{hltName tx.total_pkts}               {statType sum}}
            "Rx Frames"             {{hltName rx.total_pkts}               {statType sum}}
            "Frames Delta"          {{hltName rx.loss_pkts}                {statType sum}}
            "Rx Frame Rate"         {{hltName rx.total_pkt_rate}           {statType avg}}
            "Tx Frame Rate"         {{hltName tx.total_pkt_rate}           {statType avg}}
            "Loss %"                {{hltName rx.loss_percent}             {statType sum}}
            "Rx Bytes"              {{hltName {rx.total_pkts_bytes rx.total_pkt_bytes} } {statType {sum sum}}}
            "Rx Rate (Bps)"         {{hltName rx.total_pkt_byte_rate}      {statType avg}}
            "Rx Rate (bps)"         {{hltName rx.total_pkt_bit_rate}       {statType avg}}
            "Rx Rate (Kbps)"        {{hltName rx.total_pkt_kbit_rate}      {statType avg}}
            "Rx Rate (Mbps)"        {{hltName rx.total_pkt_mbit_rate}      {statType avg}}
            "Avg Latency (ns)"      {{hltName rx.avg_delay}                {statType avg}}
            "Min Latency (ns)"      {{hltName rx.min_delay}                {statType avg}}
            "Max Latency (ns)"      {{hltName rx.max_delay}                {statType avg}}
            "First TimeStamp"       {{hltName rx.first_tstamp}             {statType none}}
            "Last TimeStamp"        {{hltName rx.last_tstamp}              {statType none}}
        }
        set flowNames ""
        set retCode [ixNetworkGetBrowserStats "trafficStatViewBrowser" "Traffic Statistics"]
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        
        set pageCount [keylget retCode page]
        set rowCount  [keylget retCode row]
        array set rowsArray [keylget retCode rows]
        set resetPortList ""
        set flow 0
        for {set i 1} {$i < $pageCount} {incr i} {
            for {set j 1} {$j < $rowCount} {incr j} {
                if {![info exists rowsArray($i,$j)]} { continue }    
                set rowInfo     [ixNetworkParseRowName $rowsArray($i,$j)]
                set txPort      [keylget rowInfo tx_port]
                set rxPort      [keylget rowInfo rx_port]
                set flow_name   [keylget rowInfo flow]
                regsub -all {\.} $flow_name {:} flow_name
                set pgid        [keylget rowInfo pgid]
                if {$txPort == "" }      {continue}
                if {$rxPort == "" }      {continue}
                if {$flow_name  == "" }  {continue}
                set flow_name ${flow_name}_${pgid}
                
                mpincr flow
                set [subst $keyed_array_name]($txPort.flow.$flow.tx.flow_name)  $flow_name
                incr keyed_array_index
                
                set [subst $keyed_array_name]($txPort.flow.$flow.tx.pgid_value) $pgid
                incr keyed_array_index
                
                set [subst $keyed_array_name]($rxPort.flow.$flow.rx.flow_name)  $flow_name
                incr keyed_array_index
                
                set [subst $keyed_array_name]($rxPort.flow.$flow.rx.pgid_value) $pgid
                incr keyed_array_index
                
                foreach statName [array names trafficStatsArray] {
                    set trafficStatArrayValue $trafficStatsArray($statName)
                    set retStatNameList [keylget trafficStatArrayValue hltName]
                    set statTypeList    [keylget trafficStatArrayValue statType]
                    foreach retStatName $retStatNameList statType $statTypeList {
                        if {![info exists rowsArray($i,$j,$statName)] } {
                            set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) "N/A"
                            incr keyed_array_index
                            set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) "N/A"
                            incr keyed_array_index
                            continue
                        }
                        if {[string first "tx." $retStatName] != -1} {
                            if {[catch {set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName)} oldValue]} {
                                set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                if {$statType == "avg"} {
                                    set avg_calculator_array([subst $keyed_array_name],$txPort.flow.$flow.$retStatName) 1
                                }
                                incr keyed_array_index
                            } else {
                                if {$statType == "sum"} {
                                    if {$oldValue != ""} {
                                        set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                        incr keyed_array_index
                                    }
                                    
                                } elseif {$statType == "avg"} {
                                    if {$oldValue != ""} {
                                        set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                        incr avg_calculator_array([subst $keyed_array_name],$txPort.flow.$flow.$retStatName)
                                        incr keyed_array_index
                                
                                    }
                                } else {
                                    set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                    incr keyed_array_index
                                }
                            }
                            if {[catch {set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName)} oldValue]} {
                                set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) 0
                                incr keyed_array_index
                            }
                        }
                        if {[string first "rx." $retStatName] != -1} {
                            if {[catch {set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName)} oldValue] } {
                                set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                if {$statType == "avg"} {
                                    set avg_calculator_array([subst $keyed_array_name],$rxPort.flow.$flow.$retStatName) 1
                                }
                                incr keyed_array_index
                            } else {
                                if {$statType == "sum"} {
                                    if {$oldValue != ""} {
                                        set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                        incr keyed_array_index
                                    }
                                } elseif {$statType == "avg"} {
                                    if {$oldValue != ""} {
                                        set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                        incr avg_calculator_array([subst $keyed_array_name],$rxPort.flow.$flow.$retStatName)
                                        incr keyed_array_index
                                    }
                                } else {
                                    set [subst $keyed_array_name]($rxPort.flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                    incr keyed_array_index
                                }
                            }
                            if {[catch {set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName)} oldValue] } {
                                set [subst $keyed_array_name]($txPort.flow.$flow.$retStatName) 0
                                incr keyed_array_index
                            }
                        }
                    }
                }
            }
        }
    }
    if {$mode == "flow" || $mode == "all"} {
        # This array has the following meaning
        # index: IxN stat name
        # value: a keyed list with the following keys 
        # - hltName  - the name of the HLT stat to be returned
        # - statType - the type of the stat: sum, avg, or none
        array set trafficStatsArray {
            "Tx Frames"             {{hltName tx.total_pkts}               {statType sum}}
            "Rx Frames"             {{hltName rx.total_pkts}               {statType sum}}
            "Frames Delta"          {{hltName rx.loss_pkts}                {statType sum}}
            "Rx Frame Rate"         {{hltName rx.total_pkt_rate}           {statType avg}}
            "Tx Frame Rate"         {{hltName tx.total_pkt_rate}           {statType avg}}
            "Loss %"                {{hltName rx.loss_percent}             {statType sum}}
            "Rx Bytes"              {{hltName {rx.total_pkts_bytes rx.total_pkt_bytes}} {statType {sum sum}}}
            "Rx Rate (Bps)"         {{hltName rx.total_pkt_byte_rate}      {statType avg}}
            "Rx Rate (bps)"         {{hltName rx.total_pkt_bit_rate}       {statType avg}}
            "Rx Rate (Kbps)"        {{hltName rx.total_pkt_kbit_rate}      {statType avg}}
            "Rx Rate (Mbps)"        {{hltName rx.total_pkt_mbit_rate}      {statType avg}}
            "Avg Latency (ns)"      {{hltName rx.avg_delay}                {statType avg}}
            "Min Latency (ns)"      {{hltName rx.min_delay}                {statType avg}}
            "Max Latency (ns)"      {{hltName rx.max_delay}                {statType avg}}
            "First TimeStamp"       {{hltName rx.first_tstamp}             {statType none}}
            "Last TimeStamp"        {{hltName rx.last_tstamp}              {statType none}}
        }
        set flowNames ""
        set retCode [ixNetworkGetBrowserStats "trafficStatViewBrowser" "Traffic Statistics"]
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        
        set pageCount [keylget retCode page]
        set rowCount  [keylget retCode row]
        array set rowsArray [keylget retCode rows]
        set resetPortList ""
        set flow 0
        for {set i 1} {$i < $pageCount} {incr i} {
            for {set j 1} {$j < $rowCount} {incr j} {
                if {![info exists rowsArray($i,$j)]} { continue }    
                set rowInfo     [ixNetworkParseRowName $rowsArray($i,$j)]
                set txPort      [keylget rowInfo tx_port]
                set rxPort      [keylget rowInfo rx_port]
                set flow_name   [keylget rowInfo flow]
                regsub -all {\.} $flow {:} flow
                set pgid        [keylget rowInfo pgid]
                if {$txPort == "" }      {continue}
                if {$rxPort == "" }      {continue}
                if {$flow_name == "" }   {continue}
                
                set flow_name ${txPort}_${flow_name}_${pgid}
                
                mpincr flow
                set [subst $keyed_array_name](flow.$flow.flow_name)  $flow_name
                incr keyed_array_index
                set [subst $keyed_array_name](flow.$flow.pgid_value) $pgid
                incr keyed_array_index
                set [subst $keyed_array_name](flow.$flow.tx.port)    $txPort
                incr keyed_array_index
                set [subst $keyed_array_name](flow.$flow.rx.port)    $rxPort
                incr keyed_array_index
                
                foreach statName [array names trafficStatsArray] {
                    set trafficStatArrayValue $trafficStatsArray($statName)
                    set retStatNameList [keylget trafficStatArrayValue hltName]
                    set statTypeList    [keylget trafficStatArrayValue statType]
                    foreach retStatName $retStatNameList statType $statTypeList {
                        if {![info exists rowsArray($i,$j,$statName)] } {
                            set [subst $keyed_array_name](flow.$flow.$retStatName) "N/A"
                            incr keyed_array_index
                            continue
                        }
                        if {[catch {set [subst $keyed_array_name](flow.$flow.$retStatName)} oldValue]} {
                            set [subst $keyed_array_name](flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                            if {$statType == "avg"} {
                                set avg_calculator_array([subst $keyed_array_name],flow.$flow.$retStatName) 1
                            }
                            incr keyed_array_index
                        } else {
                            if {$statType == "sum"} {
                                if {$oldValue != ""} {
                                    set [subst $keyed_array_name](flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                    incr keyed_array_index
                                }
                                
                            } elseif {$statType == "avg"} {
                                if {$oldValue != ""} {
                                    set [subst $keyed_array_name](flow.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                    incr avg_calculator_array([subst $keyed_array_name],flow.$flow.$retStatName)
                                    incr keyed_array_index
                            
                                }
                            } else {
                                set [subst $keyed_array_name](flow.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                incr keyed_array_index
                            }
                        }
                    }
                }
            }
        }
    }
    
    if {$mode == "egress_by_port" || $mode == "egress_by_flow" || $mode == "all"} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Parameter port_handle is mandatory when mode is $mode."
            return $returnList
        }
        
        array set trafficStatsArray {
            "Rx Frames"                     {{hltName rx.total_pkts}               {statType sum}}
            "Rx Frame Rate"                 {{hltName rx.total_pkt_rate}           {statType avg}}
            "Rx Bytes"                      {{hltName rx.total_pkts_bytes}         {statType sum}}
            "Rx Rate (Bps)"                 {{hltName rx.total_pkt_byte_rate}      {statType avg}}
            "Rx Rate (bps)"                 {{hltName rx.total_pkt_bit_rate}       {statType avg}}
            "Rx Rate (Kbps)"                {{hltName rx.total_pkt_kbit_rate}      {statType avg}}
            "Rx Rate (Mbps)"                {{hltName rx.total_pkt_mbit_rate}      {statType avg}}
            "Cut-Through Avg Latency (ns)"  {{hltName rx.avg_delay}                {statType avg}}
            "Cut-Through Min Latency (ns)"  {{hltName rx.min_delay}                {statType avg}}
            "Cut-Through Max Latency (ns)"  {{hltName rx.max_delay}                {statType avg}}
            "First Timestamp"               {{hltName rx.first_tstamp}             {statType none}}
            "Last Timestamp"                {{hltName rx.last_tstamp}              {statType none}}
        }
        set trafficItemsRowNamesList ""
        if {$mode == "egress_by_port" || $mode == "all"} {
            lappend trafficItemsRowNamesList IGNORE
        }
        if {$mode == "egress_by_flow" || $mode == "all"} {
            set retCode [ixNetworkGetBrowserStatRows]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set trafficItemsRowNamesList [keylget retCode names]
        }
        set flow 0
        foreach single_port_h $port_handle {
            foreach trafficItemRowName $trafficItemsRowNamesList {
                set result [ixNetworkGetDrillDownStats $single_port_h $mode $trafficItemRowName]
                if {[keylget result status] != $::SUCCESS} {
                    return $result
                }
                
                set obj_name_list  [keylget result obj_name_list]
                set drilldown_root [keylget result root_obj]
                
                foreach drilldown_view $obj_name_list {
                    set retCode [ixNetworkGetBrowserStats "view" $drilldown_view $drilldown_root]
                    if {[keylget retCode status] == $::FAILURE} {
                        return $retCode
                    }
                    
                    set pageCount [keylget retCode page]
                    set rowCount  [keylget retCode row]
                    array set rowsArray [keylget retCode rows]
                    set resetPortList ""
                    
                    for {set i 1} {$i < $pageCount} {incr i} {
                        for {set j 1} {$j < $rowCount} {incr j} {
                            if {![info exists rowsArray($i,$j)]} { continue }    
    
    #                         set rowInfo     [ixNetworkParseRowName $rowsArray($i,$j)]
    #                         set txPort      [keylget rowInfo tx_port]
    #                         set rxPort      [keylget rowInfo rx_port]
    #                         set flow_name   [keylget rowInfo flow]
    #                         regsub -all {\.} $flow {:} flow
    #                         set pgid        [keylget rowInfo pgid]
    #                         if {$txPort == "" }      {continue}
    #                         if {$rxPort == "" }      {continue}
    #                         if {$flow_name == "" }   {continue}
                            
                            set flow_name     $rowsArray($i,$j)
                                                   
                            mpincr flow
                            set [subst $keyed_array_name](egress.$flow.flow_name)  $flow_name
                            if {$trafficItemRowName != "IGNORE"} {
                                set [subst $keyed_array_name](egress.$flow.flow_print)  $trafficItemRowName
                            } else {
                                set [subst $keyed_array_name](egress.$flow.flow_print)  "N/A"
                            }
                            incr keyed_array_index
    #                         set [subst $keyed_array_name](flow.$flow.pgid_value) $pgid
    #                         incr keyed_array_index
    #                         set [subst $keyed_array_name](flow.$flow.tx.port)    $txPort
    #                         incr keyed_array_index
    #                         set [subst $keyed_array_name](flow.$flow.rx.port)    $rxPort
    #                         incr keyed_array_index
    
                            foreach statName [array names trafficStatsArray] {
                                set trafficStatArrayValue $trafficStatsArray($statName)
                                set retStatNameList [keylget trafficStatArrayValue hltName]
                                set statTypeList    [keylget trafficStatArrayValue statType]
                                foreach retStatName $retStatNameList statType $statTypeList {
                                    if {![info exists rowsArray($i,$j,$statName)] } {
                                        set [subst $keyed_array_name](egress.$flow.$retStatName) "N/A"
                                        incr keyed_array_index
                                        continue
                                    }
                                    if {[catch {set [subst $keyed_array_name](egress.$flow.$retStatName)} oldValue]} {
                                        set [subst $keyed_array_name](egress.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                        if {$statType == "avg"} {
                                            set avg_calculator_array([subst $keyed_array_name],egress.$flow.$retStatName) 1
                                        }
                                        incr keyed_array_index
                                    } else {
                                        if {$statType == "sum"} {
                                            if {$oldValue != ""} {
                                                set [subst $keyed_array_name](egress.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                                incr keyed_array_index
                                            }
                                            
                                        } elseif {$statType == "avg"} {
                                            if {$oldValue != ""} {
                                                set [subst $keyed_array_name](egress.$flow.$retStatName) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                                incr avg_calculator_array([subst $keyed_array_name],egress.$flow.$retStatName)
                                                incr keyed_array_index
                                        
                                            }
                                        } else {
                                            set [subst $keyed_array_name](egress.$flow.$retStatName) $rowsArray($i,$j,$statName)
                                            incr keyed_array_index
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    # Calculate average values
    foreach {avg_array_entry} [array names avg_calculator_array] {
        foreach {avg_array_name avg_array_key} [split $avg_array_entry ,] {}
        if {$avg_calculator_array($avg_array_entry) > 1 &&\
                [info exists [subst $avg_array_name]($avg_array_key)]} {
            # puts "set [subst $avg_array_name]($avg_array_key) \[mpexpr [set [subst $avg_array_name]($avg_array_key)] / $avg_calculator_array($avg_array_entry)\]"
            set [subst $avg_array_name]($avg_array_key) [mpexpr [set [subst $avg_array_name]($avg_array_key)] / $avg_calculator_array($avg_array_entry)]
        }
    }
    
    switch -- $return_method {
        "keyed_list" {
            set [subst $keyed_array_name](status) $::SUCCESS
            set retTemp [array get $keyed_array_name]
            eval "keylset returnList $retTemp"
        }
        "keyed_list_or_array" {
            if {$keyed_array_index < $traffic_stats_max_list_length} {
                set [subst $keyed_array_name](status) $::SUCCESS
                set retTemp [array get $keyed_array_name]
                return $returnList
            } else {
                keylset returnList status $::SUCCESS
                keylset returnList handle ::ixia::[subst $keyed_array_name]
                return $returnList
            }
        }
        "array" {
            keylset returnList status $::SUCCESS
            keylset returnList handle ::ixia::[subst $keyed_array_name]
        }
    }
    return $returnList
}
