proc ::ixia::540IxNetValidateObject {obj_ref {obj_type_list {_none} } {check_exists {1}}} {
    
    keylset returnList status $::SUCCESS
    
    if {$check_exists} {
        if {$obj_ref == "::ixNet::OBJ-null" || [ixNet exists $obj_ref] == "false"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Object $obj_ref does not exist."
            return $returnList
        }
    }
    
    array set object_type_regexp {
        {^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+$}             config_element
        {^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+$}           high_level_stream
        {^::ixNet::OBJ-/traffic/trafficItem:\d+$}                               traffic_item
        {^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+/stack}      stack_hls
        {^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+/stack}        stack_ce
        {^::ixNet::OBJ-/traffic/dynamicRate}                                    dynamic_rate
        {^::ixNet::OBJ-/traffic/dynamicFrameSize}                               dynamic_framesize
        {^::ixNet::OBJ-/traffic/trafficItem:\d+/applicationProfile:\d+$}        application_profile
    }
    
    if {$obj_type_list == "_none"} {

        foreach regexp_expr [array names object_type_regexp] {
            if {[regexp $regexp_expr $obj_ref]} {
                keylset returnList value $object_type_regexp($regexp_expr)
                return $returnList
            }
        }

    } else {
        array set object_type_regexp_reversed ""
        
        foreach regexp_expr [array names object_type_regexp] {
            set object_type_regexp_reversed($object_type_regexp($regexp_expr)) $regexp_expr
        }
        
        foreach obj_type_request $obj_type_list {
            if {[regexp $object_type_regexp_reversed($obj_type_request) $obj_ref]} {
                keylset returnList value $obj_type_request
                return $returnList
            }
        }
    }
    
    keylset returnList status $::FAILURE
    keylset returnList log "Unknown object type $obj_ref."
    return $returnList
}


proc ::ixia::540IxNetStackGetType {obj_ref} {
    
    array set display_name_2_layer_mapping {
        "ATM Cell"                              2
        "AAL5"                                  2
        "Atm Aal5 Frame"                        2
        "Ethernet ARP"                          2
        "Cisco HDLC"                            2
        "Cisco ISL"                             2
        "Cisco Frame Relay"                     2
        "Ethernet II"                           2
        "Ethernet II without FCS"               2
        "Frame Relay"                           2
        "PPP IPCP"                              2
        "PPP IPV6CP"                            2
        "LACP"                                  2
        "LLC-PPP"                               2
        "Connectivity Fault Management (CFM)"   2
        "Link OAM"                              2
        "LLC Bridged Ethernet 802.3"            2
        "LLC"                                   2
        "L2VPN ATM Cell CW"                     2
        "L2VPN ATM CW Frame"                    2
        "L2VPN Ethernet Frame"                  2
        "L2VPN FR CW"                           2
        "L2VPN FR-RFC4619 CW"                   2
        "L2VPN FR"                              2
        "L2VPN PPP-HDLC Frame"                  2
        "L2VPN HDLC"                            2
        "L2VPN PPP"                             2
        "L2VPN VC Type IP CW"                   2
        "MAC in MAC"                            2
        "Marker PDU"                            2
        "MPLS"                                  2
        "MSTP BPDU"                             2
        "MPLS-TP Ethernet Frame"                2
        "OAM-Deprecated"                        2
        "PPP"                                   2
        "PPP LCP"                               2
        "PPP PAP/CHAP"                          2
        "PPPoE - Discovery"                     2
        "PPPoE - Session"                       2
        "Ethernet RARP"                         2
        "RSTP BPDU"                             2
        "LLC-SNAP"                              2
        "SNAP"                                  2
        "STP Configuration BPDU"                2
        "STP TCN BPDU"                          2
        "VCMux-PPP"                             2
        "VLAN"                                  2
        "VPLS Ethernet Frame"                   2
        "FCoE"                                  2
        "FIP"                                   2
        "FIP Clear Virtual Links (FCF)"         2
        "FIP Discovery Advertisement (FCF)"     2
        "FIP Discovery Solicitation (FCF)"      2
        "FIP Discovery Solicitation (ENode)"    2
        "FIP ELP Request (FCF)"                 2
        "FIP ELP SW_ACC (FCF)"                  2
        "FIP ELP SW_RJT (FCF)"                  2
        "FIP Fabric LOGO (ENode)"               2
        "FIP Fabric LOGO LS_ACC (FCF)"          2
        "FIP Fabric LOGO LS_RJT (FCF)"          2
        "FIP FLOGI LS_ACC (FCF)"                2
        "FIP FLOGI LS_RJT (FCF)"                2
        "FIP FLOGI Request (ENode)"             2
        "FIP Keep Alive (ENode)"                2
        "FIP NPIV FDISC LS_ACC (FCF)"           2
        "FIP NPIV FDISC LS_RJT (FCF)"           2
        "FIP NPIV FDISC Request (ENode)"        2
        "FIP Vendor Specific"                   2
        "FIP VLAN Notification (FCF)"           2
        "FIP VLAN Request"                      2
        "MAC in MAC v4.2"                       2
        "PFC PAUSE (802.1Qbb)"                  2
        "T-MPLS Ethernet Unicast"               2
        "Virtual Circuit Multiplexed Bridged Ethernet 802.3" 2
        "CGMP"                                  3
        "DDP"                                   3
        "GRE"                                   3
        "IS-IS Level 1 Complete Sequence Number PDU" 3
        "IS-IS Level 1 LAN Hello PDU"           3
        "IS-IS Level 1 Link State PDU"          3
        "IS-IS Level 1 Partial Sequence Numbers PDU" 3
        "IS-IS Level 2 Complete Sequence Number PDU" 3
        "IS-IS Level 2 LAN Hello PDU"           3
        "IS-IS Level 2 Link State PDU"          3
        "IS-IS Level 2 Partial Sequence Numbers PDU" 3
        "IS-IS Point to Point Hello PDU"        3
        "IS-IS Level 1 MCAST Link State PDU"    3
        "IS-IS Level 1 MCAST Partial Sequence Numbers PDU" 3
        "IPv6 Authentication Header"            3
        "IPv6 Encapsulation Header"             3
        "IPv6 Pseudo Header"                    3
        "IPv6 Routing Header"                   3
        "IPv6 Routing Header Type 0"            3
        "IPv6 Routing Header Type 2"            3
        "IPv4"                                  3
        "IPv6"                                  3
        "IPv6 Fragment Header"                  3
        "IPv6 Hop-by-Hop Options Header"        3
        "IPv6 Destination Options Header"       3
        "ICMP Msg Types: 3,4,5,11,12"           3
        "ICMP Msg Types: 0,8,13,14,15,16"       3
        "ICMP Msg Type: 9"                      3
        "IGMPv1"                                3
        "IGMPv2"                                3
        "IGMPv3 Membership Query"               3
        "IGMPv3 Membership Report"              3
        "MLDv1"                                 3
        "MLDv2 Query"                           3
        "MLDv2 Report"                          3
        "Mobile IPv6"                           3
        "L2TPv3 Control Message Over IP"        3
        "L2TPv3 Data Message Over IP"           3
        "IPX"                                   3
        "OSPFv2 Hello Packet"                   3
        "OSPFv2 Database Description Packet"    3
        "OSPFv2 LSA ACK Packet"                 3
        "OSPFv2 LSA Request Packet"             3
        "OSPFv2 LSA Update Packet"              3
        "OSPFv3 Hello"                          3
        "OSPFv3 LSA Acknowledgement Packet"     3
        "OSPFv3 LSA Request Packet"             3
        "OSPFv3 LSA Update Packet"              3
        "PIM-DM Assert Message"                 3
        "PIM-DM Graft/Graft-Ack Message"        3
        "PIM-DM Hello Message"                  3
        "PIM-DM Join/Prune Message"             3
        "PIM-DM State Refresh Message"          3
        "PIM Assert Message"                    3
        "PIM Bootstrap Message"                 3
        "PIM Candidate-RP-Adv Message"          3
        "PIM Hello Message"                     3
        "PIM Join/Prune Message"                3
        "PIM Register Message"                  3
        "PIM Register Stop Message"             3
        "RSVP"                                  3
        "RGMP"                                  3
        "RTMP"                                  3
        "IS-IS Level 1 MCAST Complete Sequence Number PDU" 3
        "ICMPv6"                                3
        "Minimal IP"                            3
        "OSPFv3 Database Description Packet"    3
        "TCP"                                   4
        "UDP"                                   4
        "BFD (Bidirectional Forwarding Detection)" 5
        "DHCP"                                  5
        "DHCPv6 (Client/Server Message)"        5
        "DHCPv6 (Relay Agent/Server Message)"   5
        "LDP Notification Message"              5
        "LDP Hello Message"                     5
        "LDP Initialization Message"            5
        "LDP Keep Alive Message"                5
        "LDP Address Message"                   5
        "LDP Address Withdraw Message"          5
        "LDP Label Mapping Message"             5
        "LDP Label Request Message"             5
        "LDP Label Abort Request Message"       5
        "LDP Label Withdraw Message"            5
        "LDP Label Release Message"             5
        "L2TPv2 Control Message"                5
        "L2TPv2 Data Message"                   5
        "L2TPv3 Control Message Over UDP"       5
        "L2TPv3 Data Message Over UDP"          5
        "Mobile IP"                             5
        "MSDP"                                  5
        "RIP1"                                  5
        "RIP2"                                  5
        "RIPng"                                 5
        "RTP"                                   5
    }
    
    keylset returnList status $::SUCCESS
    
    if {[regexp {(::ixNet::OBJ-/traffic/trafficItem:)(\d+)(/configElement:)(\d+)((/stack:\\"crc-)(\d+)(\\")|(/stack:"crc-)(\d+)("))} $obj_ref]} {
        set display_name "PPP(Trailer)"
    } else {
        set display_name [string trim [ixNet getA $obj_ref -displayName]]
    }
    
    keylset returnList stack_type $display_name
    
    if {[info exists display_name_2_layer_mapping($display_name)]} {
        keylset returnList stack_layer $display_name_2_layer_mapping($display_name)
    } else {
        keylset returnList stack_layer "crc"
    }
    
    return $returnList
}


proc ::ixia::540IxNetTrafficItemGetFirstTxPort {handle} {
    
    set procName [lindex [info level [info level]] 0]
    
    keylset returnList status $::SUCCESS
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "stack_hls" "stack_ce"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set handle_type [keylget ret_val value]
    
    set tiObjRef [ixNetworkGetParentObjref $handle "trafficItem"]
    if {$tiObjRef == [ixNet getNull]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get trafficItem object from '$handle'.\
                Error occured in $procName."
        return $returnList
    }
    
    switch -- $handle_type {
        "traffic_item" {
            set tiObjRef $handle
            set endpoint_set_list [ixNet getList $tiObjRef endpointSet]
            if {[llength $endpoint_set_list] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Traffc Item $tiObjRef does not contain any endpoints.\
                        Could not get the first TX port of this traffic item."
                return $returnList
            }
            
            set source_endpoint [ixNet getAttribute [lindex $endpoint_set_list 0] -sources]
            if {[string trim $source_endpoint] == ""} {
                # Check for a scalable source instead
                set scalable_source_endpoint [ixNet getAttribute [lindex $endpoint_set_list 0] -scalableSources]
                
                if {[string trim $scalable_source_endpoint] == ""} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Source endpoint for endpoint set [lindex $endpoint_set_list 0]\
                            is empty. Could not get the first TX port for traffic item $tiObjRef"
                    return $returnList
                }
                
                set source_endpoint [lindex [lindex $scalable_source_endpoint 0] 0]
            }
            
            set root_index [string first / $source_endpoint]
            set topology_index [string first topology $source_endpoint]
            if { [expr $topology_index - $root_index] == 1} {
                # If I have a CPF source_endpoint get the first port in the topology
                set parent_topology [ixNetworkNgpfGetParentObjref $source_endpoint "topology"]
                set vport_object [lindex [ixNet getAttribute $parent_topology -vports] 0]
            } else {        
                # Otherwise just get the parent vport
                set vport_object [ixNetworkGetParentObjref $source_endpoint "vport"]
            }
        }
        "stack_ce" -
        "stack_hls" -
        "high_level_stream" -
        "config_element" {
            switch -- $handle_type {
                "high_level_stream" -
                "stack_hls" {
                    set hls_handle [ixNetworkGetParentObjref $handle "highLevelStream"]
                    if {$hls_handle == [ixNet getNull]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Failed to get highLevelStream object from '$handle'.\
                                Error occured in $procName."
                        return $returnList
                    }
                }
                "stack_ce" -
                "config_element" {
                    set ceObjRef [ixNetworkGetParentObjref $handle "configElement"]
                    if {$ceObjRef == [ixNet getNull]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Failed to get configElement object from '$handle'.\
                                Error occured in $procName."
                        return $returnList
                    }
                    
                    set ret_code [540trafficGetHLSforCE $ceObjRef]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    
                    set hls_handle   [keylget ret_code handles]
                    set flow_indexes [keylget ret_code indexes]
                    
                    if {[llength $flow_indexes] > 1} {
                        set hls_handle [lindex $hls_handle 0]
                    }
                    
                    if {[llength $hls_handle] == 0} {
                        # No high level stream that matches the config element was found.
                        # Use the last high level stream
                        
                        set ret_code [ixNetworkEvalCmd [list ixNet getList $tiObjRef highLevelStream]]
                        if {[keylget ret_code status] != $::SUCCESS} {
                            return $ret_code
                        }
                        set hls_handle [lindex [keylget ret_code ret_val] end]
                    }
                }
            }
            
            if {[llength $hls_handle] > 0} {
                set ret_code [ixNetworkEvalCmd [list ixNet getA $hls_handle -txPort]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                set tx_port_idx  [keylget ret_code ret_val]
                set vport_object "::ixNet::OBJ-/vport:${tx_port_idx}"
                
            } else {
                # If the traffic endpoints were not negotiated there will be no high level streams
                # In this 'worst case scenario' we should grab the tx port from the endpointSet object
                set ret_code [ixNetworkEvalCmd [list ixNet getL $tiObjRef endpointSet]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set ep_set_list [keylget ret_code ret_val]
                if {[llength $ep_set_list] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Traffic item $tiObjRef does not have any endpoints configured.\
                            Error occured in $procName."
                    return $returnList
                }
                
                set ep_set [lindex $ep_set_list 0]
                
                set ret_code [ixNetworkEvalCmd [list ixNet getA $ep_set -sources]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                set sources_list [keylget ret_code ret_val]
                
                if {[llength $sources_list] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Endpoint set $ep_set does not have any sources configured.\
                            Error occured in $procName."
                    return $returnList
                }
                
                set first_source [lindex $sources_list 0]
                
                set root_index [string first / $first_source]
                set topology_index [string first topology $first_source]
                if { [expr $topology_index - $root_index] == 1} {
                    # If I have a CPF first_source get the first port in the topology
                    set parent_topology [ixNetworkGetParentObjref $first_source "topology"]
                    set vport_object [lindex [ixNet getAttribute $parent_topology -vports] 0]
                } else {            
                    # Otherwise just get the parent vport
                    set vport_object [ixNetworkGetParentObjref $first_source "vport"]
                    if {$vport_object == [ixNet getNull]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Failed to get vport object from '$first_source'.\
                                Error occured in $procName."
                        return $returnList
                    }
                }
            }
        }
    }
    
    keylset returnList value $vport_object
    return $returnList
    
}

proc ::ixia::540IxNetInit {{port_handle {_none}}} {
    
    keylset returnList status $::SUCCESS
    
    # First we connect with version 5.30 because we want to return error if old traffic items exist
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork "latest"]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {[catch {set ::ixia::ixnetworkVersion} ixn_version]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get IxNetwork version - $ixn_version.\
                Possible causes: not connected to IxNetwork Tcl Server."
        return $returnList
    }
    
    set version_idx 0
    foreach version_id [split $ixn_version {.}] {
        regexp {(^\d+)} $version_id version_id
        if {$version_idx == 0} {
            if {$version_id < 5} {
                keylset returnList status $::FAILURE
                keylset returnList log "IxNetwork version used: $ixn_version is not compatible\
                        with -traffic_generator ixnetwork_540. Please use IxNetwork 5.40 or higher."
                return $returnList
            } elseif {$version_id > 5} {
                break
            }
        }
        
        if {$version_idx == 1} {
            if {$version_id < 40} {
                keylset returnList status $::FAILURE
                keylset returnList log "IxNetwork version used: $ixn_version is not compatible\
                        with -traffic_generator ixnetwork_540. Please use IxNetwork 5.40 or higher."
                return $returnList
            }
            
            # Only major and minor are important. stop checking
            break
        }
        
        incr version_idx
    }

    return $returnList
}

proc ::ixia::540IxNetGetFirstInterfaceHandle { port_handle ip_addr } {

    set ret_code [ixNetworkGetPortObjref $port_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get port objref for $port_handle\
                Possible cause: port was not added via ::ixia::connect. [keylget ret_code log]."
        return $returnList
    }
    
    set vport_objref [keylget ret_code vport_objref]
    
    if {[isValidIPv4Address $ip_addr]} {
        set child_obj "ipv4"
    } else {
        set child_obj "ipv6"
        set ip_addr [expand_ipv6_addr $ip_addr]
    }
    
    foreach intf_obj [ixNet getList vport_objref] {
        if {[ixNet getAttribute ${vport_objref}/${child_obj} -ip] == $ip_addr} {
            set ret_obj_ref $intf_obj
            break
        }
    }
    
    if {![info exists ret_obj_ref]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Inteface with ip $ip_addr was not found on port $port_handle."
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList handle $ret_obj_ref
    return $returnList
    
}


proc ::ixia::540IxNetFindStack { handle protocol_template } {
    
    keylset returnList status $::SUCCESS
    
    if {[catch {ixNet getList $handle stack} stack_list]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to retrieve list of headers\
                from object $handle. $stack_list."
        return $returnList
    }
    
    if {[catch {ixNet getAttribute $protocol_template -displayName} template_name]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get protocol template name\
                for $protocol_template. $template_name."
        return $returnList
    }
    
    foreach stack_item $stack_list {
        set stack_name ""
        if {[catch {ixNet getAttribute $stack_item -displayName} stack_name]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to get stack element display name\
                    for $stack_item. $stack_name."
            return $returnList
        }
        
        if {$stack_name == $template_name} {
            set ret_handle $stack_item
            break
        }
        
        set last_stack $stack_item
        debug "==> set last_stack $stack_item"
    }
    
    if {![info exists ret_handle]} {
        debug "==> does not exist"
        if {![info exists last_stack]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Stack list empty for $handle."
            return $returnList
        }
        debug "==> keylset returnList last_handle $last_stack"
        keylset returnList handle "_none"
        keylset returnList last_handle $last_stack
        
    } else {
        debug "==> exists ==> keylset returnList handle $ret_handle"
        keylset returnList handle $ret_handle
    }
    
    return $returnList
}


proc ::ixia::540IxNetFindStacksAll { handle protocol_template_list} {
    
    # Returns keyed list: $protocol_template1 {list of stack handles with the same type as $protocol_template1}
    #                     $protocol_template2 {list of stack handles with the same type as $protocol_template2}
    #                     ...
    # where protocol_template$X is an element from protocol_template_list
    
    keylset finalReturnList status $::SUCCESS
    
    
    if {[catch {ixNet getList $handle stack} stack_list]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to retrieve list of headers\
                from object $handle. $stack_list."
        return $returnList
    }

    foreach protocol_template $protocol_template_list {
        keylset finalReturnList $protocol_template ""
        
        if {[catch {ixNet getAttribute $protocol_template -displayName} template_name]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to get protocol template name\
                    for $protocol_template. $template_name."
            return $returnList
        }
        
        foreach stack_item $stack_list {
            set stack_name ""
            if {[catch {ixNet getAttribute $stack_item -displayName} stack_name]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Failed to get stack element display name\
                        for $stack_item. $stack_name."
                return $returnList
            }
            
            if {$stack_name == $template_name} {
                if {[catch {keylget finalReturnList $protocol_template} tmp_list]} {
                    keylset finalReturnList $protocol_template $stack_item
                } else {
                    if {[lsearch $tmp_list $stack_item]>=0} {
                        continue
                    } else {
                        lappend tmp_list $stack_item
                        keylset finalReturnList $protocol_template $tmp_list
                    }
                }
            }
        }
    }
    
    return $finalReturnList
}


proc ::ixia::540IxNetFindStacksMultipleCE { handle protocol_template_list } {
    
    # Returns keyed list: $protocol_template1 {list of stack handles with the same type as $protocol_template1}
    #                     $protocol_template2 {list of stack handles with the same type as $protocol_template2}
    #                     ...
    # where protocol_template$X is an element from protocol_template_list
    
    keylset finalReturnList status $::SUCCESS
    
    variable ngt_config_elements_array

    if {[info exists ngt_config_elements_array($handle)]} {
        set stack_names $ngt_config_elements_array($handle)
    } else {
        
        set ret_code [ixNetworkEvalCmd [list ixNet getL $handle stack]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set stack_names ""
        foreach tmp_stack [keylget ret_code ret_val] {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_stack -displayName]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            lappend stack_names [keylget ret_code ret_val]
        }
        set ngt_config_elements_array($handle) $stack_names
        
        catch {unset stack_names}
        catch {unset tmp_stack}
    }
    
    foreach protocol_template $protocol_template_list {
        
        keylset finalReturnList $protocol_template ""
        
        if {[catch {ixNet getAttribute $protocol_template -displayName} template_name]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to get protocol template name\
                    for $protocol_template. $template_name."
            return $returnList
        }
        
        foreach stack_item_name $stack_names {
            if {$stack_item_name == $template_name} {
                if {[catch {keylget finalReturnList $protocol_template} tmp_list]} {
                    keylset finalReturnList $protocol_template $stack_item_name
                } else {
                    lappend tmp_list $stack_item_name
                    keylset finalReturnList $protocol_template $stack_item_name
                }
            }
        }
    }
    
    return $finalReturnList
}

proc ::ixia::540IxNetGetConfigElementLastStack {handle} {
    keylset returnList status $::SUCCESS
    keylset returnList last_stack "N/A"
    
    if {[regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+)} $handle base_handle] || \
        [regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+)} $handle base_handle]} {
        set stackList [ixNet getList $base_handle stack]
        if {[llength $stackList] > 0} {
            keylset returnList last_stack [lindex $stackList end]
        }
    }

    return $returnList
}

proc ::ixia::540IxNetGetStackFromIndex {handle index} {
    keylset returnList status $::SUCCESS
    keylset returnList last_stack "N/A"
    
    if {[regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+)} $handle base_handle] || \
        [regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+)} $handle base_handle]} {
        set stackList [ixNet getList $base_handle stack]
        if {[llength $stackList] >= $index} {
            keylset returnList last_stack [lindex $stackList [expr $index - 1]]
        } else {
            keylset returnList last_stack [lindex $stackList end]
        }
    }

    return $returnList
}

proc ::ixia::540IxNetGetParentFromStack {handle} {
    keylset returnList status $::SUCCESS
    keylset returnList parent_elem $handle
    
    if {[regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+)} $handle base_handle] || \
        [regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+)} $handle base_handle]} {
        keylset returnList parent_elem $base_handle
    }

    return $returnList
}


proc ::ixia::540IxNetAppendProtocolTemplate { protocol_template_list prev_stack } {
    
    keylset returnList status $::SUCCESS
    
    set ret_handle_list ""
    
    foreach protocol_template $protocol_template_list {
		if {[string first "fcs-" $prev_stack] > 0} {
			set parent_stack_call [540IxNetGetParentFromStack $prev_stack]
			set parent_stack_handle [keylget parent_stack_call parent_elem]
			set stackList [ixNet getList $parent_stack_handle stack]
			set prev_stack [lindex $stackList end-1]
		}
        if {[catch {ixNet exec append $prev_stack $protocol_template} new_stack]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to append protocol template\
                    $protocol_template to stack $prev_stack. $new_stack."
            return $returnList
        }
        
        if {![regexp {(^::ixNet::OK-)(\{kString,)(.*)(\}$)} $new_stack {} {} {} new_stack_h {}]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to parse string '$new_stack'\
                    to obtain new stack handle."
            return $returnList
        }
        
        lappend ret_handle_list "::ixNet::OBJ-${new_stack_h}"
        
        set prev_stack "::ixNet::OBJ-${new_stack_h}"
    }
    
    keylset returnList handle $ret_handle_list
    
    return $returnList
}


proc ::ixia::540IxNetStackGetLevel { stack_handle } {
    keylset returnList status $::SUCCESS
    
    if {![regexp {(::ixNet::OBJ\-/traffic/trafficItem:\d+/)(configElement|highLevelStream)(:\d+/stack.*)(\-)(\d+)(\"$)} $stack_handle {} {} {} {} {} level {}]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Unexpected stack handle format for '$stack_handle'. Known\
                format is (::ixNet::OBJ\-/traffic/trafficItem:\d+/configElement:\d+/stack)(.*)(\-)(\d+)(\"$)."
        return $returnList
    }
    
    keylset returnList value $level
    
    return $returnList
}

proc ::ixia::540IxNetStackGetNext { stack_handle } {
    keylset returnList status $::SUCCESS
    
    set stack_parent [ixNetworkGetParentObjref $stack_handle]
    if {$stack_parent == [ixNet getNull]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get parent object for '$stack_handle'"
        return $returnList
    }
    
    set ret_code [540IxNetStackGetLevel $stack_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set stack_current_level [keylget ret_code value]
    
    if {[catch {ixNet getList $stack_parent stack} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get list of stack from handle '$stack_parent'. $err"
        return $returnList
    } else {
        set stack_handle_list $err
    }
    
    if {[llength $stack_handle_list] <= $stack_current_level} {
        keylset returnList status $::SUCCESS
        keylset returnList handle [ixNet getNull]
        return $returnList
    }
    
    # stack_current_level is indexed starting with 1. No need to increment to get the next
    # stack handle because tcl lists are indexed starting with 0
    set ret_handle [lindex $stack_handle_list $stack_current_level]
    if {[llength $ret_handle] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error in '540IxNetStackGetNext $stack_handle'. Empty list returned by: 'lindex $stack_handle_list $stack_current_level'."
        return $returnList
    }
    
    keylset returnList handle $ret_handle
    
    return $returnList 
}

proc ::ixia::540IxNetUpdateStackField { stack_handle field field_args } {
    keylset returnList status $::SUCCESS
    
    # Create mapping of field name field object
    
    if {[catch {ixNet getList $stack_handle field} field_obj_list]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to retrieve list of fields\
                for stack handle $stack_handle. $field_obj_list."
        return $returnList
    }
    
    array set field_name_obj_array {}
    foreach field_obj $field_obj_list {
        
        if {[catch {ixNet getAttribute $field_obj -name} field_obj_name]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to retrieve name for field\
                    object $field_obj. $field_obj_name."
            return $returnList
        }
        set field_name_obj_array($field_obj_name) $field_obj
    }
    
    if {![info exists field_name_obj_array($field)]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Could not find a field with name $field\
                in stack object $stack_handle."
        return $returnList
    }
    
    set result [ixNetworkNodeSetAttr            \
            $field_name_obj_array($field)       \
            $field_args                         \
            -commit                             ]
            
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to configure header field $field - [keylget result log]."
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::540IxNetPrependProtocolTemplate { protocol_template_list stack_handle } {
    
    keylset returnList status $::SUCCESS
    
    set ret_handle_list ""
    
    foreach protocol_template $protocol_template_list {
        if {[catch {ixNet exec insert $stack_handle $protocol_template} new_stack]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to prepend protocol template\
                    $protocol_template to stack $stack_handle. $new_stack."
            return $returnList
        }
        
        if {![regexp {(^::ixNet::OK-)(\{kString,)(.*)(\}$)} $new_stack {} {} {} new_stack_h {}]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to parse string '$new_stack'\
                    to obtain new stack handle."
            return $returnList
        }
        
        lappend ret_handle_list "::ixNet::OBJ-${new_stack_h}"
        
        set ret_code [540IxNetIncrementStackHandle $stack_handle]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set stack_handle [keylget ret_code handle]
    }
    
    keylset returnList handle $ret_handle_list
    
    return $returnList
}


proc ::ixia::540IxNetReplaceProtocolTemplate { protocol_template_list stack_handle } {
    
    keylset returnList status $::SUCCESS
    
    set new_stacks ""
    
    # Append then remove
    foreach template $protocol_template_list {

        if {[catch {ixNet exec insert $stack_handle $template} new_stack]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to prepend protocol template\
                $template to stack $stack_handle. $new_stack."
            return $returnList
        }
        
        if {![regexp {(^::ixNet::OK-)(\{kString,)(.*)(\}$)} $new_stack {} {} {} new_stack_h {}]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to parse string '$new_stack'\
                to obtain new stack handle."
            return $returnList
        }
        
        lappend new_stacks "::ixNet::OBJ-${new_stack_h}"
        
        set ret_code [540IxNetIncrementStackHandle $stack_handle]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set stack_handle [keylget ret_code handle]
    }
    
    keylset returnList handle $new_stacks
    
    if {[catch {ixNet exec remove $stack_handle} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to remove stack $stack_handle. $err."
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::540IxNetTrafficGenerate { handle } {
    variable 540IxNetTrafficGenerate
    
    keylset returnList status $::SUCCESS
    
    if {[info exists 540IxNetTrafficGenerate] && ($540IxNetTrafficGenerate == 0)} {
        return $returnList
    }
    
    set ret_val [540IxNetValidateObject $handle [list traffic_item config_element high_level_stream stack_hls stack_ce] 0]
    if {[keylget ret_val status] != $::SUCCESS} {
        keylset ret_val log "Invalid handle $handle. It must be a traffic item\
                handle or a child object of $handle. [keylget ret_val log]"
        return $ret_val
    }
    
    switch -- [keylget ret_val value] {
        high_level_stream -
        stack_hls {
            # Do not regenarate. It will overwrite the high level streams with the config
            # element properties
            return $returnList
        }
        traffic_item {
            set ret_code [ixNetworkEvalCmd [list ixNet getAttribute $handle -trafficItemType]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            if {[keylget ret_code ret_val] == "quick"} {
                # It's a quick flow traffic item. Don't generate traffic
                return $returnList
            }
        }
    }
    
    set ti_obj [ixNetworkGetParentObjref $handle "trafficItem"]
    
    if {$ti_obj == [ixNet getNull]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to extract trafficItem object from $handle."
        return $returnList
    }
    
    if {[catch {ixNet exec generate $ti_obj} err]} {
        keylset returnList status $::FAILURE
        set logMsg ""
        foreach ixnErr [ixNet getA $ti_obj -errors] {
            append logMsg $ixnErr
            append logMsg " "
        }
        debug [ixNet getA $ti_obj -warnings]
        keylset returnList log "Could not generate traffic. $err. $logMsg"
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::540IxNetTrafficL2AddHeaders {handle handle_type protocol_template_list {replace {0}} } {
    
    keylset returnList status $::SUCCESS
    
    # return an ordered list of the stacks that were added (based on the protocol templates)
    set ret_handle_list ""
    
    if {[llength $protocol_template_list] < 1} {
        keylset returnList handle $ret_handle_list
        return $returnList
    }
    
    switch -- $handle_type {
        "traffic_item" {
            
            if {[catch {ixNet getList $handle configElement} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not extract configElement object from traffic item object\
                        $handle. $err"
                return $returnList
            }
            
            set handle $err
        }
        "config_element" -
        "high_level_stream" {
            # handle is exactly what we need
        }
        "stack_ce" -
        "stack_hls" {
            
            set ret_code [ixNetworkGetParentObjref $handle]
            
            if {$ret_code == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not extract parent object for $handle."
                return $returnList
            }
            
            set handle $ret_code
        }
    }
    
    if {[catch {ixNet getList $handle stack} stack_list]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not get list of stacks for object $handle."
        return $returnList
    }
    
    set first_stack [lindex $stack_list 0]
    
    set first_pt [lindex $protocol_template_list 0]
    
    if {[ixNet getAttribute $first_stack -displayName] != [ixNet getAttribute $first_pt -displayName]} {
        debug "==> 540IxNetReplaceProtocolTemplate $first_pt $first_stack"
        set ret_code [540IxNetReplaceProtocolTemplate $first_pt $first_stack]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set prev_handle [keylget ret_code handle]
        debug "==> set prev_handle [keylget ret_code handle]"
        
        lappend ret_handle_list $prev_handle
    } else {
    
        set prev_handle $first_stack
        lappend ret_handle_list $prev_handle
        debug "==> set prev_handle $first_stack"
    }
    
    # Foreach protocol template, verify if there is a stack at the requested level.
    # If there isn't, add it
    
    if {[llength $protocol_template_list] > 1} {
        set current_idx 1
        foreach pt_item [lrange $protocol_template_list 1 end] {
            
            debug "==> pt_item"
            
            if {[catch {ixNet getList $handle stack} stack_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not get list of stacks for object $handle."
                return $returnList
            }
            
            set tmp_stack [lindex $stack_list $current_idx]
            
            debug "==> set tmp_stack [lindex $stack_list $current_idx]"
            
            if {([llength $tmp_stack] == 0)} {
            
    
                debug "==> 540IxNetAppendProtocolTemplate $pt_item $prev_handle"
                
                set ret_code [540IxNetAppendProtocolTemplate $pt_item $prev_handle]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set prev_handle [keylget ret_code handle]
                lappend ret_handle_list $prev_handle
            
            } elseif {[ixNet getA $tmp_stack -displayName] != [ixNet getA $pt_item -displayName]} {
                if {$replace} {
                    
                    debug "==> 540IxNetReplaceProtocolTemplate $pt_item $tmp_stack"
                
                    set ret_code [540IxNetReplaceProtocolTemplate $pt_item $tmp_stack]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    
                    set prev_handle [keylget ret_code handle]
                    lappend ret_handle_list $prev_handle
                    
                } else {
                    debug "==> 540IxNetAppendProtocolTemplate $pt_item $prev_handle"
                
                    set ret_code [540IxNetAppendProtocolTemplate $pt_item $prev_handle]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    
                    set prev_handle [keylget ret_code handle]
                    lappend ret_handle_list $prev_handle
                }
            } else {
                set prev_handle $tmp_stack
                lappend ret_handle_list $prev_handle
            }
            
            catch {unset tmp_stack}
            catch {unset tmp_level}
            incr current_idx
        }
        
    }
    
    keylset returnList handle $ret_handle_list
    return $returnList
}


proc ::ixia::540IxNetTrafficL3AddHeaders {handle handle_type protocol_template_list} {
    
    keylset returnList status $::SUCCESS
    
    # return an ordered list of the stacks that were added (based on the protocol templates)
    set ret_handle_list ""
    
    if {[llength $protocol_template_list] < 1} {
        keylset returnList handle $ret_handle_list
        return $returnList
    }
    
    switch -- $handle_type {
        "traffic_item" {
            
            if {[catch {ixNet getList $handle configElement} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not extract configElement object from traffic item object\
                        $handle. $err"
                return $returnList
            }
            
            set handle $err
        }
        "config_element" -
        "high_level_stream" {
            # handle is exactly what we need
        }
        "stack_ce" -
        "stack_hls" {
            
            set ret_code [ixNetworkGetParentObjref $handle]
            
            if {$ret_code == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not extract parent object for $handle."
                return $returnList
            }
            
            set handle $ret_code
        }
    }
    
    if {[catch {ixNet getList $handle stack} stack_list]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not get list of stacks for object $handle."
        return $returnList
    }
    
    # We'll search the existing stacks list from level 0
    # For the first protocol template from protocol_template_list
    #   If we find a layer2 stack
    #     while next stack is layer2
    #         get next stack
    #       if next stack is crc/fcs
    #           prepend next stack with protocol template
    #       else if next_stack != protocol template
    #           replace next stack with protocol template
    #       else next_stack == protocol template
    #           set stack handle == next stack
    #   If first_stack layer == 3
    #       if first_stack != protocol template
    #           replace first_stack with protocol template
    #       else first_stack == protocol template
    #           set stack handle == first_stack
    #   If first_stack layer > 3
    #       prepend first stack with protocol template
    #
    # For the rest of the protocol templates do as for L2 stacks
    
    set first_stack [lindex $stack_list 0]
    set first_pt [lindex $protocol_template_list 0]
    
    set ret_val [540IxNetStackGetType $first_stack]
    debug "==> 540IxNetStackGetType $first_stack: $ret_val"
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set stack_layer [keylget ret_val stack_layer]
    set stack_type  [keylget ret_val stack_type]
    
    if {$stack_layer == 2} {
        
        set stack_idx 0
        set next_stack $first_stack
        
        while {$stack_layer == 2} {
            
            incr stack_idx
            
            if {[expr $stack_idx + 1] > [llength $stack_list]} {
                break
            }
            set next_stack [lindex $stack_list $stack_idx]
            
            set ret_val [540IxNetStackGetType $next_stack]
            debug "==> 540IxNetStackGetType $next_stack: $ret_val"
            if {[keylget ret_val status] != $::SUCCESS} {
                return $ret_val
            }
            
            set stack_layer [keylget ret_val stack_layer]
            set stack_type  [keylget ret_val stack_type]
        }
        
        if {$stack_layer == 2 || $stack_layer == "crc"} {
            
            if {$stack_layer == "crc"} {
                # Packet has only L2 headers (with crc).
                # The last header is crc so we append the header before it with our 
                # first protocol template
                
                set next_stack [lindex $stack_list [expr $stack_idx - 1]]
            }
            
            # Packet has only one header (without crc) and it's a layer 2 header
            # Append it with our first protocol template
            
            set ret_code [540IxNetAppendProtocolTemplate $first_pt $next_stack]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set prev_handle [keylget ret_code handle]
            lappend ret_handle_list $prev_handle
            
        } elseif {$stack_layer == 3} {
            if {[ixNet getAttribute $next_stack -displayName] == \
                    [ixNet getAttribute $first_pt -displayName]} {
                # It's a layer 3 stack and it is the same with the one we want to add
                # Use the existing one
                
                set prev_handle $next_stack
                lappend ret_handle_list $prev_handle
                
            } else {
                # It's a layer 3 stack but not what we wanted to add
                # Append to it
                
                while {$stack_layer == 3} {
            
                    incr stack_idx
                    
                    if {[expr $stack_idx + 1] > [llength $stack_list]} {
                        break
                    }
                    set next_stack [lindex $stack_list $stack_idx]
                    
                    set ret_val [540IxNetStackGetType $next_stack]
                    debug "==> 540IxNetStackGetType $next_stack: $ret_val"
                    if {[keylget ret_val status] != $::SUCCESS} {
                        return $ret_val
                    }
                    
                    set stack_layer [keylget ret_val stack_layer]
                    set stack_type  [keylget ret_val stack_type]
                }
                
                if {$stack_layer == "crc"} {
                    # Packet has only L2 headers (with crc).
                    # The last header is crc so we append the header before it with our 
                    # first protocol template
                    
                    set next_stack [lindex $stack_list [expr $stack_idx - 1]]
                    
                    set ret_code [540IxNetAppendProtocolTemplate $first_pt $next_stack]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    
                    set prev_handle [keylget ret_code handle]
                    lappend ret_handle_list $prev_handle
                    
                } elseif {$stack_layer == 2 || $stack_layer > 3} {
                    
                    set ret_code [540IxNetPrependProtocolTemplate $first_pt $next_stack]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    
                    set prev_handle [keylget ret_code handle]
                    lappend ret_handle_list $prev_handle
                } else {
                
                    set ret_code [540IxNetAppendProtocolTemplate $first_pt $next_stack]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }

                    set prev_handle [keylget ret_code handle]
                    lappend ret_handle_list $prev_handle
                }
            }
        } else {
            # stack_layer > 3
            # Prepend it with our first protocol template
            
            set ret_code [540IxNetPrependProtocolTemplate $first_pt $next_stack]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set prev_handle [keylget ret_code handle]
            lappend ret_handle_list $prev_handle
        }
    } elseif {$stack_layer == 3} {
        if {[ixNet getAttribute $first_stack -displayName] == \
                [ixNet getAttribute $first_pt -displayName]} {
            # It's a layer 3 stack and it is the same with the one we want to add
            # Use the existing one
            
            set prev_handle $first_stack
            lappend ret_handle_list $prev_handle
            
        } else {
            # It's a layer 3 stack but not what we wanted to add
            # Replace it
            
            while {$stack_layer == 3} {
            
                incr stack_idx
                
                if {[expr $stack_idx + 1] > [llength $stack_list]} {
                    break
                }
                set next_stack [lindex $stack_list $stack_idx]
                
                set ret_val [540IxNetStackGetType $next_stack]
                debug "==> 540IxNetStackGetType $next_stack: $ret_val"
                if {[keylget ret_val status] != $::SUCCESS} {
                    return $ret_val
                }
                
                set stack_layer [keylget ret_val stack_layer]
                set stack_type  [keylget ret_val stack_type]
            }
            
            if {$stack_layer == "crc"} {
                # Packet has only L2 headers (with crc).
                # The last header is crc so we append the header before it with our 
                # first protocol template
                
                set next_stack [lindex $stack_list [expr $stack_idx - 1]]
                
                set ret_code [540IxNetAppendProtocolTemplate $first_pt $next_stack]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set prev_handle [keylget ret_code handle]
                lappend ret_handle_list $prev_handle
                
            } elseif {$stack_layer == 2 || $stack_layer > 3} {
                
                set ret_code [540IxNetPrependProtocolTemplate $first_pt $next_stack]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set prev_handle [keylget ret_code handle]
                lappend ret_handle_list $prev_handle
            } else {
            
                set ret_code [540IxNetAppendProtocolTemplate $first_pt $next_stack]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }

                set prev_handle [keylget ret_code handle]
                lappend ret_handle_list $prev_handle
            }
        }
    } else {
        # stack_layer > 3
        # Prepend it with our first protocol template
        
        set ret_code [540IxNetPrependProtocolTemplate $first_pt $first_stack]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set prev_handle [keylget ret_code handle]
        lappend ret_handle_list $prev_handle
    }
    
    # Foreach protocol template, verify if there is a stack at the requested level.
    # If there isn't, add it
    
    if {[llength $protocol_template_list] > 1} {
        
        # Find the index of prev_handle
        if {[catch {ixNet getList $handle stack} stack_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not get list of stacks for object $handle."
            return $returnList
        }
        
        set current_idx 1
        
        set prev_handle_name [ixNet getAttribute $prev_handle -displayName]
        
        foreach single_stack $stack_list {
            
            if {[ixNet getAttribute $single_stack -displayName] == $prev_handle_name} {
                break
            }
            
            incr current_idx
        }
        
        foreach pt_item [lrange $protocol_template_list 1 end] {
            
            debug "==> pt_item"
            
            if {[catch {ixNet getList $handle stack} stack_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not get list of stacks for object $handle."
                return $returnList
            }
            
            set tmp_stack [lindex $stack_list $current_idx]
            
            debug "==> set tmp_stack [lindex $stack_list $current_idx]"
            
            if {([llength $tmp_stack] == 0) || ([ixNet getA $tmp_stack -displayName] != [ixNet getA $pt_item -displayName])} {
            
    
                debug "==> 540IxNetAppendProtocolTemplate $pt_item $prev_handle"
                
                set ret_code [540IxNetAppendProtocolTemplate $pt_item $prev_handle]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set prev_handle [keylget ret_code handle]
                lappend ret_handle_list $prev_handle
            
            } else {
                set prev_handle $tmp_stack
                lappend ret_handle_list $prev_handle
            }
            
            catch {unset tmp_stack}
            catch {unset tmp_level}
            incr current_idx
        }
        
    }
    
    keylset returnList handle $ret_handle_list
    return $returnList
}


proc ::ixia::540IxNetTrafficL3AddHeadersArp {handle handle_type protocol_template_list} {
    
    keylset returnList status $::SUCCESS
    
    # return an ordered list of the stacks that were added (based on the protocol templates)
    set ret_handle_list ""
    
    if {[llength $protocol_template_list] < 1} {
        keylset returnList handle $ret_handle_list
        return $returnList
    }
    
    switch -- $handle_type {
        "traffic_item" {
            
            if {[catch {ixNet getList $handle configElement} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not extract configElement object from traffic item object\
                        $handle. $err"
                return $returnList
            }
            
            set handle $err
        }
        "config_element" -
        "high_level_stream" {
            # handle is exactly what we need
        }
        "stack_ce" -
        "stack_hls" {
            
            set ret_code [ixNetworkGetParentObjref $handle]
            
            if {$ret_code == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not extract parent object for $handle."
                return $returnList
            }
            
            set handle $ret_code
        }
    }
    
    set previous_handle "_none"
    
    foreach top_level_protocol_template $protocol_template_list {
        
        if {[catch {ixNet getList $handle stack} stack_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not get list of stacks for object $handle."
            return $returnList
        }
        
        if {$previous_handle == "_none"} {
         
            # First see if headers already exists
            set ret_code [540IxNetFindStacksAll $handle $top_level_protocol_template]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set found_stack [keylget ret_code $top_level_protocol_template]
            if {[llength $found_stack] > 0} {
                lappend ret_handle_list [lindex $found_stack 0]
                set previous_handle [lindex $found_stack 0]
                continue
            }
            
            # Attempt to find the first consecutive layer 3 headers
            ## Get the last item from the consecutive L3 header
            # Do the same for Layer 2
            set idx 0
            set first_l3_stack ""
            set first_l2_stack ""
            foreach single_stack $stack_list {
                
                set ret_val [540IxNetStackGetType $single_stack]
                debug "==> 540IxNetStackGetType $single_stack: $ret_val"
                if {[keylget ret_val status] != $::SUCCESS} {
                    return $ret_val
                }
                
                set stack_layer [keylget ret_val stack_layer]
                set stack_type  [keylget ret_val stack_type]
                
                switch -- $stack_layer {
                    2 {
                        if {$first_l2_stack == ""} {
                            set first_l2_stack $single_stack
                            set first_l2_stack_idx $idx
                        }
                    }
                    3 {
                        if {$first_l3_stack == ""} {
                            set first_l3_stack $single_stack
                            set first_l3_stack_idx $idx
                        }
                    }
                }
                
                if {$first_l2_stack != "" && $first_l3_stack != ""} {
                    break
                }
                
                incr idx
            }
            
            if {$first_l3_stack != ""} {
                set last_l3_stack $first_l3_stack
                foreach l3_single_stack [lrange $stack_list $first_l3_stack_idx end] {
                    set ret_val [540IxNetStackGetType $l3_single_stack]
                    debug "==> 540IxNetStackGetType $l3_single_stack: $ret_val"
                    if {[keylget ret_val status] != $::SUCCESS} {
                        return $ret_val
                    }
                    
                    set stack_layer [keylget ret_val stack_layer]
                    set stack_type  [keylget ret_val stack_type]
                    
                    if {$stack_layer == 3} {
                        set last_l3_stack $l3_single_stack
                    } else {
                        break
                    }
                }
                
                set action "540IxNetAppendProtocolTemplate"
                set action_stack $last_l3_stack
                
            } elseif {$first_l2_stack != ""} {
                
                set last_l2_stack $first_l2_stack
                foreach l2_single_stack [lrange $stack_list $first_l2_stack_idx end] {
                    set ret_val [540IxNetStackGetType $l2_single_stack]
                    debug "==> 540IxNetStackGetType $l2_single_stack: $ret_val"
                    if {[keylget ret_val status] != $::SUCCESS} {
                        return $ret_val
                    }
                    
                    set stack_layer [keylget ret_val stack_layer]
                    set stack_type  [keylget ret_val stack_type]
                    
                    if {$stack_layer == 2} {
                        set last_l2_stack $l2_single_stack
                    } else {
                        break
                    }
                }
                
                set action "540IxNetAppendProtocolTemplate"
                set action_stack $last_l2_stack
                
            } else {
                # No L2 or L3 stacks exist
                # The first stack is > L4 or crc
                # Prepend it with our headers
                set action "540IxNetPrependProtocolTemplate"
                set action_stack [lindex $stack_list 0]
            }
            
            set cmd "$action $top_level_protocol_template $action_stack"
            set ret_val [eval $cmd]
            if {[keylget ret_val status] != $::SUCCESS} {
                return $ret_val
            }
            
            set previous_handle [keylget ret_val handle]
            lappend ret_handle_list $previous_handle
            
        } else {
            
            set previous_handle_idx [lsearch $stack_list $previous_handle]
            if {$previous_handle_idx == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Stack previously added '$previous_handle' can not\
                        be found in the current configured stacks '$stack_list'"
                return $returnList
            }
            
            catch {unset tmp_stack}
            set tmp_stack [lindex $stack_list [expr $previous_handle_idx + 1]]
            if {[ixNet getA $tmp_stack -displayName] == [ixNet getA $top_level_protocol_template -displayName]} {
                set previous_handle $tmp_stack
                lappend returnList $tmp_stack
            } else {
                
                set cmd "540IxNetAppendProtocolTemplate $top_level_protocol_template $previous_handle"
                set ret_val [eval $cmd]
                if {[keylget ret_val status] != $::SUCCESS} {
                    return $ret_val
                }
                
                set previous_handle [keylget ret_val handle]
                lappend ret_handle_list $previous_handle
                
            }
        }
    }
    
    
    
    keylset returnList handle $ret_handle_list
    return $returnList
}


proc ::ixia::540IxNetTrafficL4AddHeaders {handle handle_type protocol_template_list} {
    
    keylset returnList status $::SUCCESS
    
    # return an ordered list of the stacks that were added (based on the protocol templates)
    set ret_handle_list ""
    
    if {[llength $protocol_template_list] < 1} {
        keylset returnList handle $ret_handle_list
        return $returnList
    }
    
    switch -- $handle_type {
        "traffic_item" {
            
            if {[catch {ixNet getList $handle configElement} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not extract configElement object from traffic item object\
                        $handle. $err"
                return $returnList
            }
            
            set handle $err
        }
        "config_element" -
        "high_level_stream" {
            # handle is exactly what we need
        }
        "stack_ce" -
        "stack_hls" {
            
            set ret_code [ixNetworkGetParentObjref $handle]
            
            if {$ret_code == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not extract parent object for $handle."
                return $returnList
            }
            
            set handle $ret_code
        }
    }
    
    set previous_handle "_none"
    
    foreach top_level_protocol_template $protocol_template_list {
        
        if {[catch {ixNet getList $handle stack} stack_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not get list of stacks for object $handle."
            return $returnList
        }
        
        set top_level_protocol_template_temp $top_level_protocol_template
        
        if {$previous_handle == "_none"} {
            
            # BUG586315
            if {[regsub -all {([^\\]{1}) } $top_level_protocol_template {\1\\ } top_level_protocol_template_temp]} {
                set top_level_protocol_template_temp [list $top_level_protocol_template]
            } elseif {[regexp { } $top_level_protocol_template]} {
                set top_level_protocol_template_temp [list $top_level_protocol_template]
            }
            
            # First see if headers already exists
            set ret_code [540IxNetFindStacksAll $handle $top_level_protocol_template_temp]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set found_stack [keylget ret_code $top_level_protocol_template]
            if {[llength $found_stack] > 0} {
                lappend ret_handle_list [lindex $found_stack 0]
                set previous_handle [lindex $found_stack 0]
                continue
            }
            
            # Attempt to find the first consecutive layer 3 headers
            ## Get the last item from the consecutive L3 header
            # Do the same for Layer 2
            set idx 0
            set first_l4_stack ""
            set first_l3_stack ""
            set first_l2_stack ""
            foreach single_stack $stack_list {
                
                set ret_val [540IxNetStackGetType $single_stack]
                debug "==> 540IxNetStackGetType $single_stack: $ret_val"
                if {[keylget ret_val status] != $::SUCCESS} {
                    return $ret_val
                }
                
                set stack_layer [keylget ret_val stack_layer]
                set stack_type  [keylget ret_val stack_type]
                
                switch -- $stack_layer {
                    2 {
                        if {$first_l2_stack == ""} {
                            set first_l2_stack $single_stack
                            set first_l2_stack_idx $idx
                        }
                    }
                    3 {
                        if {$first_l3_stack == ""} {
                            set first_l3_stack $single_stack
                            set first_l3_stack_idx $idx
                        }
                    }
                    4 {
                        if {$first_l4_stack == ""} {
                            set first_l4_stack $single_stack
                            set first_l4_stack_idx $idx
                        }
                    }
                }
                
                if {$first_l2_stack != "" && $first_l3_stack != "" && $first_l4_stack != ""} {
                    break
                }
                
                incr idx
            }
            
            if {$first_l4_stack != ""} {
                set last_l4_stack $first_l4_stack
                foreach l4_single_stack [lrange $stack_list $first_l4_stack_idx end] {
                    set ret_val [540IxNetStackGetType $l4_single_stack]
                    debug "==> 540IxNetStackGetType $l4_single_stack: $ret_val"
                    if {[keylget ret_val status] != $::SUCCESS} {
                        return $ret_val
                    }
                    
                    set stack_layer [keylget ret_val stack_layer]
                    set stack_type  [keylget ret_val stack_type]
                    
                    if {$stack_layer == 4} {
                        set last_l4_stack $l4_single_stack
                    } else {
                        break
                    }
                }
                
                set action "540IxNetAppendProtocolTemplate"
                # BUG586315
                set last_l4_stack_temp $last_l4_stack
                if {[regsub -all {([^\\]{1}) } $last_l4_stack {\1\\ } last_l4_stack_temp]} {
                    set last_l4_stack_temp [list $last_l4_stack]
                } elseif {[regexp { } $top_level_protocol_template]} {
                    set last_l4_stack_temp [list $last_l4_stack]
                }
                set action_stack $last_l4_stack_temp
                
            } elseif {$first_l3_stack != ""} {
                set last_l3_stack $first_l3_stack
                foreach l3_single_stack [lrange $stack_list $first_l3_stack_idx end] {
                    set ret_val [540IxNetStackGetType $l3_single_stack]
                    debug "==> 540IxNetStackGetType $l3_single_stack: $ret_val"
                    if {[keylget ret_val status] != $::SUCCESS} {
                        return $ret_val
                    }
                    
                    set stack_layer [keylget ret_val stack_layer]
                    set stack_type  [keylget ret_val stack_type]
                    
                    if {$stack_layer == 3} {
                        set last_l3_stack $l3_single_stack
                    } else {
                        break
                    }
                }
                
                set action "540IxNetAppendProtocolTemplate"
                set action_stack $last_l3_stack
                
            } elseif {$first_l2_stack != ""} {
                
                set last_l2_stack $first_l2_stack
                foreach l2_single_stack [lrange $stack_list $first_l2_stack_idx end] {
                    set ret_val [540IxNetStackGetType $l2_single_stack]
                    
                    if {[keylget ret_val status] != $::SUCCESS} {
                        return $ret_val
                    }
                    
                    set stack_layer [keylget ret_val stack_layer]
                    set stack_type  [keylget ret_val stack_type]
                    
                    if {$stack_layer == 2} {
                        set last_l2_stack $l2_single_stack
                    } else {
                        break
                    }
                }
                
                set action "540IxNetAppendProtocolTemplate"
                set action_stack $last_l2_stack
                
            } else {
                # No L2 or L3 or L4 stacks exist
                # The first stack is > L4 or crc
                # Prepend it with our headers
                set action "540IxNetPrependProtocolTemplate"
                set action_stack [lindex $stack_list 0]
            }
            
            set cmd "$action [list $top_level_protocol_template_temp] $action_stack"
            set ret_val [eval $cmd]
            if {[keylget ret_val status] != $::SUCCESS} {
                return $ret_val
            }
            
            set previous_handle [keylget ret_val handle]
            lappend ret_handle_list $previous_handle
            
        } else {
            
            set previous_handle_idx [lsearch $stack_list $previous_handle]
            if {$previous_handle_idx == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Stack previously added '$previous_handle' can not\
                        be found in the current configured stacks '$stack_list'"
                return $returnList
            }
            
            catch {unset tmp_stack}
            set tmp_stack [lindex $stack_list [expr $previous_handle_idx + 1]]
            if {[ixNet getA $tmp_stack -displayName] == [ixNet getA $top_level_protocol_template_temp -displayName]} {
                set previous_handle $tmp_stack
                lappend returnList $tmp_stack
            } else {
                set cmd "540IxNetAppendProtocolTemplate $top_level_protocol_template_temp $previous_handle"
                set ret_val [eval $cmd]
                if {[keylget ret_val status] != $::SUCCESS} {
                    return $ret_val
                }
                
                set previous_handle [keylget ret_val handle]
                lappend ret_handle_list $previous_handle
                
            }
        }
    }
    
    
    
    keylset returnList handle $ret_handle_list
    return $returnList
}


proc ::ixia::540IxNetIncrementStackHandle { stack_handle } {
    
    keylset returnList status $::SUCCESS
    
    if {![regexp {(.*)(\-)(\d+)("$)} $stack_handle {} handle_part minus_part level end_part]} {
        if {![regexp {(\-)(\d+)(\\"$)} $stack_handle {} handle_part minus_part level end_part]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to determine level for stack handle $stack_handle."
            return $returnList
        }
    }
    
    incr level
    
    set stack_handle ${handle_part}${minus_part}${level}${end_part}
    
    keylset returnList handle $stack_handle
    return $returnList
}


proc ::ixia::540IxNetGetStackObjRef { stack_hlt_handle } {
    return $stack_hlt_handle
}


proc ::ixia::540IxNetStackGetProtocolTemplate { stack_obj_ref } {
    
    keylset returnList status $::SUCCESS
    
    if {[catch {ixNet getAttribute $stack_obj_ref -displayName} err]} {
        set stack_obj_ref_old $stack_obj_ref
        set stack_obj_ref [lindex $stack_obj_ref 0]
        if {[catch {ixNet getAttribute $stack_obj_ref -displayName} err_new]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to execute 'ixNet getAttribute $stack_obj_ref_old -displayName'. $err"
            return $returnList
        }
        set err $err_new
    }
    
    set stack_name [string trim $err]
    
    array set stack_name_pt [list                                                                                                       \
        "AAL5"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"aal5"                         \
        "ATM Cell"                                        ::ixNet::OBJ-/traffic/protocolTemplate:"atmCell"                      \
        "Atm Aal5 Frame"                                  ::ixNet::OBJ-/traffic/protocolTemplate:"atmAAL5Frame"                 \
        "Ethernet ARP"                                    ::ixNet::OBJ-/traffic/protocolTemplate:"ethernetARP"                  \
        "Cisco HDLC"                                      ::ixNet::OBJ-/traffic/protocolTemplate:"ciscoHDLC"                    \
        "Cisco ISL"                                       ::ixNet::OBJ-/traffic/protocolTemplate:"ciscoISL"                     \
        "Cisco Frame Relay"                               ::ixNet::OBJ-/traffic/protocolTemplate:"ciscoFrameRelay"              \
        "Ethernet II"                                     ::ixNet::OBJ-/traffic/protocolTemplate:"ethernet"                     \
        "Ethernet II without FCS"                         ::ixNet::OBJ-/traffic/protocolTemplate:"ethernetNoFCS"                \
        "Frame Relay"                                     ::ixNet::OBJ-/traffic/protocolTemplate:"frameRelay"                   \
        "PPP IPCP"                                        ::ixNet::OBJ-/traffic/protocolTemplate:"pppIPCP"                      \
        "PPP IPV6CP"                                      ::ixNet::OBJ-/traffic/protocolTemplate:"pppIPv6CP"                    \
        "LACP"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"lacp"                         \
        "LLC-PPP"                                         ::ixNet::OBJ-/traffic/protocolTemplate:"llcPPP"                       \
        "CFM"                                             ::ixNet::OBJ-/traffic/protocolTemplate:"cfm"                          \
        "Link-OAM"                                        ::ixNet::OBJ-/traffic/protocolTemplate:"linkOAM"                      \
        "LLC Bridged Ethernet 802.3"                      ::ixNet::OBJ-/traffic/protocolTemplate:"llcBridgedEthernet"           \
        "LLC"                                             ::ixNet::OBJ-/traffic/protocolTemplate:"llc"                          \
        "L2VPN ATM Cell CW"                               ::ixNet::OBJ-/traffic/protocolTemplate:"l2VPNATMCellCW"               \
        "L2VPN ATM CW Frame"                              ::ixNet::OBJ-/traffic/protocolTemplate:"l2VPNATMCWFrame"              \
        "L2VPN Ethernet Frame"                            ::ixNet::OBJ-/traffic/protocolTemplate:"l2VPNEthernetFrame"           \
        "L2VPN FR CW"                                     ::ixNet::OBJ-/traffic/protocolTemplate:"l2VPNFrameRelayCW"            \
        "L2VPN FR-RFC4619 CW"                             ::ixNet::OBJ-/traffic/protocolTemplate:"l2VPNFrameRelayRFC4619CW"     \
        "L2VPN FR"                                        ::ixNet::OBJ-/traffic/protocolTemplate:"l2VPNFrameRelay"              \
        "L2VPN PPP-HDLC Frame"                            ::ixNet::OBJ-/traffic/protocolTemplate:"l2VPNPPPHDLC"                 \
        "L2VPN HDLC"                                      ::ixNet::OBJ-/traffic/protocolTemplate:"l2VPNHDLC"                    \
        "L2VPN PPP"                                       ::ixNet::OBJ-/traffic/protocolTemplate:"l2VPNPPP"                     \
        "L2VPN VC Type IP CW"                             ::ixNet::OBJ-/traffic/protocolTemplate:"l2VPNVCTypeIPCW"              \
        "MAC in MAC"                                      ::ixNet::OBJ-/traffic/protocolTemplate:"macInMAC"                     \
        "Marker"                                          ::ixNet::OBJ-/traffic/protocolTemplate:"markerPDU"                    \
        "MPLS"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"mpls"                         \
        "MSTP BPDU"                                       ::ixNet::OBJ-/traffic/protocolTemplate:"mstpBPDU"                     \
        "MPLS-TP Ethernet Frame"                          ::ixNet::OBJ-/traffic/protocolTemplate:"MPLSTPEthernetFrame"          \
        "OAM-Deprecated"                                  ::ixNet::OBJ-/traffic/protocolTemplate:"oamCCM"                       \
        "L2VPN PPP"                                       ::ixNet::OBJ-/traffic/protocolTemplate:"ppp"                          \
        "PPP LCP"                                         ::ixNet::OBJ-/traffic/protocolTemplate:"pppLCP"                       \
        "PPP PAP/CHAP"                                    ::ixNet::OBJ-/traffic/protocolTemplate:"pppPAPCHAP"                   \
        "PPPoE - Discovery"                               ::ixNet::OBJ-/traffic/protocolTemplate:"pppoEDiscovery"               \
        "PPPoE - Session"                                 ::ixNet::OBJ-/traffic/protocolTemplate:"pppoESession"                 \
        "Ethernet RARP"                                   ::ixNet::OBJ-/traffic/protocolTemplate:"ethernetRARP"                 \
        "RSTP BPDU"                                       ::ixNet::OBJ-/traffic/protocolTemplate:"rstpBPDU"                     \
        "LLC-SNAP"                                        ::ixNet::OBJ-/traffic/protocolTemplate:"llcSNAP"                      \
        "SNAP"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"snap"                         \
        "STP Configuration BPDU"                          ::ixNet::OBJ-/traffic/protocolTemplate:"stpCfgBPDU"                   \
        "STP TCN BPDU"                                    ::ixNet::OBJ-/traffic/protocolTemplate:"stpTCNBPDU"                   \
        "Virtual Circuit Multiplexed Bridged Ethernet 802.3" ::ixNet::OBJ-/traffic/protocolTemplate:"vcMuxBridgedEthernet"      \
        "VCMux-PPP"                                       ::ixNet::OBJ-/traffic/protocolTemplate:"vcMuxPPP"                     \
        "VLAN"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"vlan"                         \
        "VPLS Ethernet Frame"                             ::ixNet::OBJ-/traffic/protocolTemplate:"vplsEthernet"                 \
        "FCoE"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"fcoE"                         \
        "FIP"                                             ::ixNet::OBJ-/traffic/protocolTemplate:"fip"                          \
        "FIP Clear Virtual Links (FCF)"                   ::ixNet::OBJ-/traffic/protocolTemplate:"fipClearVirtualLinksFcf"      \
        "FIP Discovery Advertisement (FCF)"               ::ixNet::OBJ-/traffic/protocolTemplate:"fipDiscoveryAdvertisementFcf" \
        "FIP Discovery Solicitation (FCF)"                ::ixNet::OBJ-/traffic/protocolTemplate:"fipDiscoverySolicitationFcf"  \
        "FIP Discovery Solicitation (ENode)"              ::ixNet::OBJ-/traffic/protocolTemplate:"fipDiscoverySolicitationEnode"\
        "FIP ELP Request (FCF)"                           ::ixNet::OBJ-/traffic/protocolTemplate:"fipElpRequestFcf"             \
        "FIP ELP SW_ACC (FCF)"                            ::ixNet::OBJ-/traffic/protocolTemplate:"fipElpSwAccFcf"               \
        "FIP ELP SW_RJT (FCF)"                            ::ixNet::OBJ-/traffic/protocolTemplate:"fipElpSwRjtFcf"               \
        "FIP Fabric LOGO (ENode)"                         ::ixNet::OBJ-/traffic/protocolTemplate:"fipFabricLogoEnode"           \
        "FIP Fabric LOGO LS_ACC (FCF)"                    ::ixNet::OBJ-/traffic/protocolTemplate:"fipFabricLogoLsAccFcf"        \
        "FIP Fabric LOGO LS_RJT (FCF)"                    ::ixNet::OBJ-/traffic/protocolTemplate:"fipFabricLogoLsRjtFcf"        \
        "FIP FLOGI LS_ACC (FCF)"                          ::ixNet::OBJ-/traffic/protocolTemplate:"fipFlogiLsAccFcf"             \
        "FIP FLOGI LS_RJT (FCF)"                          ::ixNet::OBJ-/traffic/protocolTemplate:"fipFlogiLsRjtFcf"             \
        "FIP FLOGI Request (ENode)"                       ::ixNet::OBJ-/traffic/protocolTemplate:"fipFlogiRequestEnode"         \
        "FIP Keep Alive (ENode)"                          ::ixNet::OBJ-/traffic/protocolTemplate:"fipKeepAliveEnode"            \
        "FIP NPIV FDISC LS_ACC (FCF)"                     ::ixNet::OBJ-/traffic/protocolTemplate:"fipNpivFdicsLsAccFcf"         \
        "FIP NPIV FDISC LS_RJT (FCF)"                     ::ixNet::OBJ-/traffic/protocolTemplate:"fipNpivFdiscLsRjtFcf"         \
        "FIP NPIV FDISC Request (ENode)"                  ::ixNet::OBJ-/traffic/protocolTemplate:"fipNpivFdiscRequestEnode"     \
        "FIP Vendor Specific (ENode or FCF)"              ::ixNet::OBJ-/traffic/protocolTemplate:"fipVendorSpecific"            \
        "FIP VLAN Notification (FCF)"                     ::ixNet::OBJ-/traffic/protocolTemplate:"fipVlanNotificationFcf"       \
        "FIP VLAN Request"                                ::ixNet::OBJ-/traffic/protocolTemplate:"fipVlanRequest"               \
        "MAC in MAC v4.2"                                 ::ixNet::OBJ-/traffic/protocolTemplate:"macInMACv42"                  \
        "PFC PAUSE (802.1Qbb)"                            ::ixNet::OBJ-/traffic/protocolTemplate:"pfcPause"                     \
        "T-MPLS Ethernet Unicast"                         ::ixNet::OBJ-/traffic/protocolTemplate:"tmpls"                        \
        "CGMP"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"cgmp"                         \
        "DDP"                                             ::ixNet::OBJ-/traffic/protocolTemplate:"ddp"                          \
        "GRE"                                             ::ixNet::OBJ-/traffic/protocolTemplate:"gre"                          \
        "IS-IS Level 1 Complete Sequence Number PDU"      ::ixNet::OBJ-/traffic/protocolTemplate:"isisL1CSNPDU"                 \
        "IS-IS Level 1 LAN Hello PDU"                     ::ixNet::OBJ-/traffic/protocolTemplate:"isisLevel1LANHelloPDU"        \
        "IS-IS Level 1 Link State PDU"                    ::ixNet::OBJ-/traffic/protocolTemplate:"isisLevel1LinkStatePDU"       \
        "IS-IS Level 1 Partial Sequence Numbers PDU"      ::ixNet::OBJ-/traffic/protocolTemplate:"isisL1PSNPDU"                 \
        "IS-IS Level 2 Complete Sequence Number PDU"      ::ixNet::OBJ-/traffic/protocolTemplate:"isisL2CSNPDU"                 \
        "IS-IS Level 2 LAN Hello PDU"                     ::ixNet::OBJ-/traffic/protocolTemplate:"isisLevel2LANHelloPDU"        \
        "IS-IS Level 2 Link State PDU"                    ::ixNet::OBJ-/traffic/protocolTemplate:"isisLevel2LinkStatePDU"       \
        "IS-IS Level 2 Partial Sequence Numbers PDU"      ::ixNet::OBJ-/traffic/protocolTemplate:"isisL2PSNPDU"                 \
        "IS-IS Point to Point Hello PDU"                  ::ixNet::OBJ-/traffic/protocolTemplate:"isisPointToPointHelloPDU"     \
        "IS-IS Level 1 MCAST Complete Sequence Number PDU" ::ixNet::OBJ-/traffic/protocolTemplate:"isisL1McastCSNPDU"            \
        "IS-IS Level 1 MCAST Link State PDU"              ::ixNet::OBJ-/traffic/protocolTemplate:"isisL1McastLinkStatePDU"      \
        "IS-IS Level 1 MCAST Partial Sequence Numbers PDU" ::ixNet::OBJ-/traffic/protocolTemplate:"isisL1McastPSNPDU"            \
        "IPv6 Authentication Header"                      ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Authentication"           \
        "IPv6 Encapsulation Header"                       ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Encapsulation"            \
        "IPv6 Pseudo Header"                              ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Pseudo"                   \
        "IPv6 Routing Header"                             ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Routing"                  \
        "IPv6 Routing Header Type 0"                      ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6RoutingType0"             \
        "IPv6 Routing Header Type 2"                      ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6RoutingType2"             \
        "IPv4"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"                         \
        "IPv6"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6"                         \
        "IPv6 Fragment Header"                            ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Fragment"                 \
        "IPv6 Hop-by-Hop Options Header"                  ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6HopByHopOptions"          \
        "IPv6 Destination Options Header"                 ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6DestinationOptions"       \
        "ICMP Msg Types: 3,4,5,11,12"                     ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv1"                       \
        "ICMP Msg Types: 0,8,13,14,15,16"                 ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv2"                       \
        "ICMP Msg Type: 9"                                ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv9"                       \
        "ICMPv6"                                          ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6"                       \
        "IGMPv1"                                         {::ixNet::OBJ-/traffic/protocolTemplate:"igmpv1"}                      \
        "IGMPv2"                                         {::ixNet::OBJ-/traffic/protocolTemplate:"igmpv2"}                      \
        "IGMPv3 Membership Query"                         ::ixNet::OBJ-/traffic/protocolTemplate:"igmpv3MembershipQuery"        \
        "IGMPv3 Membership Report"                        ::ixNet::OBJ-/traffic/protocolTemplate:"igmpv3MembershipReport"       \
        "Minimal IP"                                      ::ixNet::OBJ-/traffic/protocolTemplate:"minimalIP"                    \
        "MLDv1"                                          ::ixNet::OBJ-/traffic/protocolTemplate:"mldv1"                        \
        "MLDv2 Query"                                     ::ixNet::OBJ-/traffic/protocolTemplate:"mldv2Query"                   \
        "MLDv2 Report"                                    ::ixNet::OBJ-/traffic/protocolTemplate:"mldv2Report"                  \
        "Mobile IPv6"                                     ::ixNet::OBJ-/traffic/protocolTemplate:"mobileIPv6"                   \
        "L2TPv3 Control Message Over IP"                  ::ixNet::OBJ-/traffic/protocolTemplate:"l2TPv3ControlIP"              \
        "L2TPv3 Data Message Over IP"                     ::ixNet::OBJ-/traffic/protocolTemplate:"l2TPv3DataIP"                 \
        "IPX"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"ipx"                          \
        "OSPFv2 Hello Packet"                             ::ixNet::OBJ-/traffic/protocolTemplate:"ospfv2Hello"                  \
        "OSPFv2 Database Description Packet"              ::ixNet::OBJ-/traffic/protocolTemplate:"ospfv2DatabaseDescription"    \
        "OSPFv2 LSA ACK Packet"                           ::ixNet::OBJ-/traffic/protocolTemplate:"ospfv2LSAAcknowledgement"     \
        "OSPFv2 LSA Request Packet"                       ::ixNet::OBJ-/traffic/protocolTemplate:"ospfv2LSARequest"             \
        "OSPFv2 LSA Update Packet"                        ::ixNet::OBJ-/traffic/protocolTemplate:"ospfv2LSAUpdate"              \
        "OSPFv3 Hello"                                    ::ixNet::OBJ-/traffic/protocolTemplate:"ospfv3Hello"                  \
        "OSPFv3 Database Description Packet"              ::ixNet::OBJ-/traffic/protocolTemplate:"ospfv3DatabaseDescription"    \
        "OSPFv3 LSA Acknowledgement Packet"               ::ixNet::OBJ-/traffic/protocolTemplate:"ospfv3LSAAcknowledgement"     \
        "OSPFv3 LSA Request Packet"                       ::ixNet::OBJ-/traffic/protocolTemplate:"ospfv3LSARequest"             \
        "OSPFv3 LSA Update Packet"                        ::ixNet::OBJ-/traffic/protocolTemplate:"ospfv3LSAUpdate"              \
        "PIM-DM Assert Message"                           ::ixNet::OBJ-/traffic/protocolTemplate:"pimdmAssertMessage"           \
        "PIM-DM Graft/Graft-Ack Message"                  ::ixNet::OBJ-/traffic/protocolTemplate:"pimdmGraftGraftAckMessage"    \
        "PIM-DM Hello Message"                            ::ixNet::OBJ-/traffic/protocolTemplate:"pimdmHelloMessage"            \
        "PIM-DM Join/Prune Message"                       ::ixNet::OBJ-/traffic/protocolTemplate:"pimdmJoinPruneMessage"        \
        "PIM-DM State Refresh Message"                    ::ixNet::OBJ-/traffic/protocolTemplate:"pimdmStateRefreshMessage"     \
        "PIM Assert Message"                              ::ixNet::OBJ-/traffic/protocolTemplate:"pimAssertMessage"             \
        "PIM Bootstrap Message"                           ::ixNet::OBJ-/traffic/protocolTemplate:"pimBootstrapMessage"          \
        "PIM Candidate-RP-Adv Message"                    ::ixNet::OBJ-/traffic/protocolTemplate:"pimCandidateRPAdvMessage"     \
        "PIM Hello Message"                               ::ixNet::OBJ-/traffic/protocolTemplate:"pimHelloMessage"              \
        "PIM Join/Prune Message"                          ::ixNet::OBJ-/traffic/protocolTemplate:"pimJoinPruneMessage"          \
        "PIM Register Message"                            ::ixNet::OBJ-/traffic/protocolTemplate:"pimRegister"                  \
        "PIM Register Stop Message"                       ::ixNet::OBJ-/traffic/protocolTemplate:"pimRegisterStopMessage"       \
        "RSVP"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"rsvp"                         \
        "RGMP"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"rgmp"                         \
        "RTMP"                                           ::ixNet::OBJ-/traffic/protocolTemplate:"rtmp"                         \
        "VXLAN"                                           ::ixNet::OBJ-/traffic/protocolTemplate:"vxlan"                        \
        "TCP"                                             ::ixNet::OBJ-/traffic/protocolTemplate:"tcp"                          \
        "UDP"                                             ::ixNet::OBJ-/traffic/protocolTemplate:"udp"                          \
        "BFD (Bidirectional Forwarding Detection)"        ::ixNet::OBJ-/traffic/protocolTemplate:"bfd"                          \
        "DHCP"                                           ::ixNet::OBJ-/traffic/protocolTemplate:"dhcp"                         \
        "DHCPv6 (Client/Server Message)"                  ::ixNet::OBJ-/traffic/protocolTemplate:"dhcpv6ClientServer"           \
        "DHCPv6 (Relay Agent/Server Message)"             ::ixNet::OBJ-/traffic/protocolTemplate:"dhcpv6Relay"                  \
        "LDP Notification Message"                        ::ixNet::OBJ-/traffic/protocolTemplate:"ldpNotification"              \
        "LDP Hello Message"                               ::ixNet::OBJ-/traffic/protocolTemplate:"ldpHello"                     \
        "LDP Initialization Message"                      ::ixNet::OBJ-/traffic/protocolTemplate:"ldpInitialization"            \
        "LDP Keep Alive Message"                          ::ixNet::OBJ-/traffic/protocolTemplate:"ldpKeepAlive"                 \
        "LDP Address Message"                             ::ixNet::OBJ-/traffic/protocolTemplate:"ldpAddress"                   \
        "LDP Address Withdraw Message"                    ::ixNet::OBJ-/traffic/protocolTemplate:"ldpAddressWithdraw"           \
        "LDP Label Mapping Message"                       ::ixNet::OBJ-/traffic/protocolTemplate:"ldpLabelMapping"              \
        "LDP Label Request Message"                       ::ixNet::OBJ-/traffic/protocolTemplate:"ldpLabelRequest"              \
        "LDP Label Abort Request Message"                 ::ixNet::OBJ-/traffic/protocolTemplate:"ldpLabelAbortRequest"         \
        "LDP Label Withdraw Message"                      ::ixNet::OBJ-/traffic/protocolTemplate:"ldpLabelWithdraw"             \
        "LDP Label Release Message"                       ::ixNet::OBJ-/traffic/protocolTemplate:"ldpLabelRelease"              \
        "L2TPv2 Control Message"                          ::ixNet::OBJ-/traffic/protocolTemplate:"l2TPv2Control"                \
        "L2TPv2 Data Message"                             ::ixNet::OBJ-/traffic/protocolTemplate:"l2TPv2Data"                   \
        "L2TPv3 Control Message Over UDP"                 ::ixNet::OBJ-/traffic/protocolTemplate:"l2TPv3ControlUDP"             \
        "L2TPv3 Data Message Over UDP"                    ::ixNet::OBJ-/traffic/protocolTemplate:"l2TPv3DataUDP"                \
        "Mobile IP"                                       ::ixNet::OBJ-/traffic/protocolTemplate:"mobileIP"                     \
        "MSDP"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"msdp"                         \
        "RIP1"                                           ::ixNet::OBJ-/traffic/protocolTemplate:"rip1"                         \
        "RIP2"                                           ::ixNet::OBJ-/traffic/protocolTemplate:"rip2"                         \
        "RIPng"                                          ::ixNet::OBJ-/traffic/protocolTemplate:"ripng"                        \
        "RTP"                                            ::ixNet::OBJ-/traffic/protocolTemplate:"rtp"                          \
        "Custom"                                          ::ixNet::OBJ-/traffic/protocolTemplate:"custom"                       \
    ]

    if {[catch {set ret_handle $stack_name_pt($stack_name)} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unknown stack type $stack_obj_ref. Name $stack_name not found in internal array."
        return $returnList
    }
    
    
    keylset returnList pt_handle $ret_handle
    keylset returnList pt_name   [string trim $stack_name]
    return $returnList
}


proc ::ixia::540TrafficStackFieldConfig { args } {
    
    debug "540TrafficStackFieldConfig $args"
    
    variable truth
    
    keylset returnList status $::SUCCESS
    keylset returnList commit_needed 0
    
    set man_args {
        -field_name         ANY
        -stack_handle       ANY
    }
    
    set opt_args {
        -value
        -p_type             CHOICES value_hex value_mac value_truth value_mac_2_hex
                            CHOICES value_translate value value_ipv4 value_int_2_hex
                            CHOICES value_string_to_ascii_hex value_hex_2_int
        -count              NUMERIC
        -mode               CHOICES fixed incr decr list auto rand rpt_rand
        -step               ANY
        -mask               MAC
        -seed               NUMERIC
        -tracking           CHOICES 0 1
        -translate_array    ANY
        -strict_format      CHOICES strict non_strict
                            DEFAULT non_strict
        -field_regex        ANY
        -use_name_instead_of_displayname CHOICES 0 1 2 3
                            DEFAULT 0
        -field_levels_count NUMERIC
        -field_levels_span  ANY
        -field_levels_depth CHOICES 0 1 none
        -field_levels_ro_count_prop ANY
        -commit             CHOICES 0 1
                            DEFAULT 1
    }   
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    if {[info exists translate_array]} {
        array set this_translate_array $translate_array
    }
    
    # Don't do anything if the none of the config params exist
    set exit_flag 1
    foreach tmp_p [list value count mode step tracking] {
        if {[info exists $tmp_p]} {
            set exit_flag 0
            break
        }
    }
    
    if {$exit_flag} {
        return $returnList
    }
    
    catch {unset tmp_p}
    
    set ret_code [540IxNetValidateObject $stack_handle [list stack_ce stack_hls]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }

    switch -- [keylget ret_code value] {
        stack_ce {
            set stack_parent_type "config_element"
        }
        stack_hls {
            set stack_parent_type "high_level_stream"            
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Unexpected value: '$ret_code' returned by\
                    '540IxNetValidateObject $stack_handle [list stack_ce stack_hls]'."
            return $returnList
        }
    }
    
    array set mode_translate_array {
        fixed       singleValue
        incr        increment
        decr        decrement
        list        valueList
        auto        singleValue
        rand        nonRepeatableRandom
        rpt_rand    random
    }
    
    if {[info exists field_levels_span] && [info exists field_levels_ro_count_prop] && [info exists field_levels_depth] && $field_levels_depth > 0} {
        set ret_code [540TrafficAdjustFieldLevelSpan $stack_handle $field_levels_span $field_name $field_levels_ro_count_prop $use_name_instead_of_displayname]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set field_levels_count [keylget ret_code field_levels_count]
    }
    
    # Find field
    set stack_field_handle ""
    if {$use_name_instead_of_displayname == 3} {
        set stack_field_handle "${stack_handle}/field:\"$field_name\""
    } else {
        foreach stack_field [ixNet getList $stack_handle field] {
            if {$use_name_instead_of_displayname} {
                set tmp_ixn_field_name [ixNet getA $stack_field -name]
            } else {
                set tmp_ixn_field_name [ixNet getA $stack_field -displayName]
            }
            
            if {$use_name_instead_of_displayname == 2} {
                if {[regexp $field_name $stack_field]} {
                    lappend stack_field_handle $stack_field
                }
            } elseif {[string trim $tmp_ixn_field_name] == [string trim $field_name]} {
                lappend stack_field_handle $stack_field
            }
            
            catch {unset tmp_ixn_field_name}
        }
    }
    
    if {![info exists stack_field_handle] || [llength $stack_field_handle] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Invalid field name $field_name for\
                stack object $stack_handle."
        return $returnList
    }
    
    if {[info exists field_regex]} {
        set found 0
        foreach st_field $stack_field_handle {
            foreach single_field_regex $field_regex {

                if {[regexp $single_field_regex $st_field]} {
                    set stack_field_handle $st_field
                    set found 1
                    break
                }
            }
        }
        if {!$found} {
            # We shouldn't configure this field because it does not eval the regexp
            return $returnList
        }
    }
    
    # If the field supports multiple levels we must configure each level with a value
    # from the list associated with each parameter.
    # Also we must configure stack_field_handle to the list of levels.
    # Create the levels if they are not already there
    
    if {[info exists field_levels_count]} {
        
        if {$field_levels_count != [llength $stack_field_handle]} {
        
            if {[llength $stack_field_handle] > $field_levels_count} {
            
                set stack_field_handle [lrange $stack_field_handle 0 [mpexpr $field_levels_count - 1]]
                
            } elseif {[llength $stack_field_handle] < $field_levels_count} {
                set last_tmp_handle [lindex $stack_field_handle end]
                if {[ixNet getA $last_tmp_handle -optional] == "true" && [ixNet getA $last_tmp_handle -optionalEnabled] == "false"} {
                    set ret_code [ixNetworkEvalCmd [list ixNet setA $last_tmp_handle -optionalEnabled true]]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    
                    set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                }
                for {set i 0} {$i < [mpexpr $field_levels_count - [llength $stack_field_handle]]} {incr i} {
                    if {[catch {ixNet exec addLevel $last_tmp_handle} err] || $err != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to add multiple levels for $last_tmp_handle. $err"
                        return $returnList 
                    }
                }
            
            
                set stack_field_handle ""
                foreach stack_field [ixNet getList $stack_handle field] {
                    if {$use_name_instead_of_displayname} {
                        set tmp_ixn_field_name [ixNet getA $stack_field -name]
                    } else {
                        set tmp_ixn_field_name [ixNet getA $stack_field -displayName]
                    }
                    
                    if {$use_name_instead_of_displayname == 2} {
                        if {[regexp $field_name $stack_field]} {
                            lappend stack_field_handle $stack_field
                        }
                    } elseif {[string trim $tmp_ixn_field_name] == [string trim $field_name]} {
                        lappend stack_field_handle $stack_field
                    }
            
                    catch {unset tmp_ixn_field_name}
                }
            
                if {![info exists stack_field_handle] || [llength $stack_field_handle] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error. Invalid field name $field_name for\
                            stack object $stack_handle."
                    return $returnList
                }
                
                if {[info exists field_regex]} {
                    set found 0
                    foreach st_field $stack_field_handle {
                        foreach single_field_regex $field_regex {
            
                            if {[regexp $single_field_regex $st_field]} {
                                set stack_field_handle $st_field
                                set found 1
                                break
                            }
                        }
                    }
                    if {!$found} {
                        # We shouldn't configure this field because it does not eval the regexp
                        return $returnList
                    }
                }
                
                # Verify if we have the correct number of levels
                if {[llength $stack_field_handle] != $field_levels_count} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error. The number of levels could not be created for\
                            field $field_name. Requested levels: $field_levels_count, Created levels: [llength $stack_field_handle]."
                    return $returnList
                }
            }
        }
        
    } else {
        if {![regexp { \-} $stack_field_handle]} {
            set stack_field_handle [lindex $stack_field_handle 0]
        }
    }
    
    # Now stack_field_handle contains the objRef of the field we want to configure
    
    set stack_field_handles_list $stack_field_handle
    
    set stack_field_handle_idx 0
    
    foreach stack_field_handle $stack_field_handles_list {
        
        # Initialize params that were not passed (useful when called from modify mode)
        if {![info exists mode]} {
            # Get the type from the field
            if {[info exists value]} {
                set auto_mode 0
            } else {
                set auto_mode [ixNet getAttribute $stack_field_handle -auto]
                if {$auto_mode == "false"} {
                    set auto_mode 0
                } else {
                    set auto_mode 1
                }
            }
            
            set ixn_type [ixNet getAttribute $stack_field_handle -valueType]
            
            switch -- $ixn_type {
                singleValue {
                    set mode "fixed"
                }
                increment {
                    set mode "incr"
                }
                decrement {
                    set mode "decr"
                }
                valueList {
                    set mode "list"
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error. Unexpected value '$ixn_type' returned\
                            by 'ixNet getAttribute $stack_field_handle -valueType'. Known values\
                            are 'singleValue', 'increment', 'decrement', 'valueList'."
                    return $returnList
                }
            }
        
        } else {
            
            if {[info exists field_levels_count]} {
                if {[llength $mode] < [expr $stack_field_handle_idx + 1]} {
                    set tmp_mode [lindex $mode end]
                } else {
                    set tmp_mode [lindex $mode $stack_field_handle_idx]
                }
            } else {
                set tmp_mode $mode
            }
            
            if {$tmp_mode == "auto"} {
                set auto_mode 1
            } else {
                set auto_mode 0
            }
        }
        
        if {[info exists field_levels_count]} {
            if {[llength $mode] < [expr $stack_field_handle_idx + 1]} {
                set tmp_mode [lindex $mode end]
            } else {
                set tmp_mode [lindex $mode $stack_field_handle_idx]
            }
        } else {
            set tmp_mode $mode
        }
        
        set transform_to_int 0
        if {($tmp_mode == "incr" || $tmp_mode == "decr") && $strict_format == "non_strict"} {
            set transform_to_int 1
        }
        
        if {![info exists count]} {
            set count [ixNet getAttribute $stack_field_handle -countValue]
        }
        
        if {![info exists step]} {
            set step [ixNet getAttribute $stack_field_handle -stepValue]
        }
        
        if {![info exists tracking] && $stack_parent_type == "config_element"} {
            set tracking [ixNet getAttribute $stack_field_handle -trackingEnabled]
            switch -- $tracking {
                true {
                    set tracking 1
                }
                false {
                    set tracking 0
                }
            }
        }
        
        # Build map for field parameters
        set param_map_list ""
        
        debug "==> if \{'$stack_parent_type' == 'config_element'\}"
        
        if {$stack_parent_type == "config_element"} {
            # Tracking can be configured only for fields under config element.
            # tracking for fields under high_level_stream is not possible
            
            debug "lappend param_map_list \"tracking\"    \"trackingEnabled\"     \"value_truth\""
            lappend param_map_list "tracking"    "trackingEnabled"     "value_truth"
        }
        
        if {$tmp_mode == "incr" || $tmp_mode == "decr"} {
            
            # No point in configuring count and step if mode is fixed or list
            
            if {[info exists p_type]} {
                
                if {[info exists field_levels_count]} {
                    if {[llength $p_type] < [expr $stack_field_handle_idx + 1]} {
                        set tmp_p_type [lindex $p_type end]
                    } else {
                        set tmp_p_type [lindex $p_type $stack_field_handle_idx]
                    }
                } else {
                    set tmp_p_type $p_type
                }
                
                lappend param_map_list [list                            \
                        count       countValue          value       \
                        step        stepValue           $tmp_p_type     \
                    ]
                
                catch {unset tmp_p_type}
                
            } else {
                lappend param_map_list [list                            \
                        count       countValue          value       \
                        step        stepValue           value       \
                    ]
            }
        }
        if {$tmp_mode == "rpt_rand"} {
            lappend param_map_list [list                    \
                count       countValue          value       \
                seed        seed                value       \
                mask        randomMask          value       \
                value       fixedBits           value       \
            ]
        }
        # If p_type exists value should exist too. Value will not be configured if p_type
        # does not exist because it will not be added to the param_map_list list.
        
        if {[info exists p_type]} {
            
            if {[info exists field_levels_count]} {
                if {[llength $p_type] < [expr $stack_field_handle_idx + 1]} {
                    set tmp_p_type [lindex $p_type end]
                } else {
                    set tmp_p_type [lindex $p_type $stack_field_handle_idx]
                }
            } else {
                set tmp_p_type $p_type
            }
            
            switch -- $tmp_mode {
                fixed {
                    lappend param_map_list "value" "singleValue" $tmp_p_type
                }
                incr -
                decr {
                    lappend param_map_list "value" "startValue"  $tmp_p_type
                }
                list {
                    lappend param_map_list "value" "valueList"  $tmp_p_type
                }
            }
            
            catch {unset tmp_p_type}
        }
        
        lappend param_map_list "mode" "valueType" "translate"
        lappend param_map_list "auto_mode" "auto" "value_truth"
        
        debug "==>  param_map_list == $param_map_list   <=="
        
        # Iterate and configure parameters for this field
        set ixn_param_list ""
        foreach {hlt_p ixn_p param_type} [join $param_map_list] {
            if {[info exists $hlt_p]} {
                
                # Just making sure that there are no variables initialized from prev iterations
                catch {unset ixn_p_val}
                catch {unset hlt_p_val_inner}
                catch {unset ixn_p_val_tmp}
                
                set hlt_p_val [set $hlt_p]
                
                if {[info exists field_levels_count]} {
                    if {[llength $hlt_p_val] < [expr $stack_field_handle_idx + 1]} {
                        set hlt_p_val [lindex $hlt_p_val end]
                    } else {
                        set hlt_p_val [lindex $hlt_p_val $stack_field_handle_idx]
                    }
                }
                
                debug "==> $hlt_p == $hlt_p_val"
                
                switch -- $param_type {
                    value {
                        set ixn_p_val $hlt_p_val
                    }
                    value_hex {
                        # if mode == list is used to prevent cases where param values contain
                        # spaces and we accidentally iterate a single value
                        if {$tmp_mode == "list"} {
                            set ixn_p_val ""
                            foreach hlt_p_val_inner $hlt_p_val {
                                if {![isValidHex $hlt_p_val_inner]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid HEX value '$hlt_p_val_inner'."
                                    return $returnList
                                }
                                
                                set ixn_p_val_tmp 0x[convert_string_to_hex $hlt_p_val_inner]
                                
                                if {$transform_to_int} {
                                    lappend ixn_p_val [mpformat %d $ixn_p_val_tmp]
                                } else {
                                    lappend ixn_p_val $ixn_p_val_tmp
                                }
                            }
                            
                        } else {
                            if {![isValidHex $hlt_p_val]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid HEX value '$hlt_p_val'."
                                return $returnList
                            }
                            
                            set ixn_p_val_tmp 0x[convert_string_to_hex $hlt_p_val]
                            if {$transform_to_int} {
                                set ixn_p_val [mpformat %d $ixn_p_val_tmp]
                            } else {
                                set ixn_p_val $ixn_p_val_tmp
                            }
                        }
                    }
                    value_hex_2_int {
                        # if mode == list is used to prevent cases where param values contain
                        # spaces and we accidentally iterate a single value
                        
                        if {$tmp_mode == "list"} {
                            set ixn_p_val ""
                            foreach hlt_p_val_inner $hlt_p_val {
                                if {![isValidHex $hlt_p_val_inner]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid HEX value '$hlt_p_val_inner'."
                                    return $returnList
                                }
                                
                                set ixn_p_val_tmp 0x[convert_string_to_hex $hlt_p_val_inner]
                                
                                lappend ixn_p_val [mpexpr $ixn_p_val_tmp]
                            }
                            
                        } else {
                            if {![isValidHex $hlt_p_val]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid HEX value '$hlt_p_val'."
                                return $returnList
                            }
                            
                            set ixn_p_val_tmp 0x[convert_string_to_hex $hlt_p_val]
                                
                            set ixn_p_val [mpexpr $ixn_p_val_tmp]
                        }
                    }
                    value_mac {
                        # MAC addresses need to be validated seppartely
                        if {$tmp_mode == "list"} {
                            set ixn_p_val ""
                            foreach hlt_p_val_inner $hlt_p_val {
                                if {![isValidMacAddress $hlt_p_val_inner]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid MAC address '$hlt_p_val_inner'."
                                    return $returnList
                                }
                                
                                set ixn_p_val_tmp [ixNetworkFormatMac $hlt_p_val_inner]
                                
                                if {$transform_to_int} {
                                    lappend ixn_p_val [mpexpr 0x[convert_string_to_hex $ixn_p_val_tmp]]
                                } else {
                                    lappend ixn_p_val $ixn_p_val_tmp
                                }
                            }
                        } else {
                            if {![isValidMacAddress $hlt_p_val]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid MAC address '$hlt_p_val'."
                                return $returnList
                            }
                            
                            set ixn_p_val_tmp [ixNetworkFormatMac $hlt_p_val]
                                
                            if {$transform_to_int} {
                                set ixn_p_val [mpexpr 0x[convert_string_to_hex $ixn_p_val_tmp]]
                            } else {
                                set ixn_p_val $ixn_p_val_tmp
                            }
                        }
                    }
                    value_truth {
                        if {$tmp_mode == "list"} {
                            set ixn_p_val ""
                            foreach hlt_p_val_inner $hlt_p_val {
                                if {$transform_to_int} {
                                    lappend ixn_p_val $hlt_p_val_inner
                                } else {
                                    lappend ixn_p_val $truth($hlt_p_val_inner)
                                }
                            }
                        } else {
                            if {$transform_to_int} {
                                set ixn_p_val $hlt_p_val
                            } else {
                                set ixn_p_val $truth($hlt_p_val)
                            }
                        }
                    }
                    value_mac_2_hex {
                        # MAC addresses need to be validated seppartely
                        
                        if {$tmp_mode == "list"} {
                            set ixn_p_val ""
                            foreach hlt_p_val_inner $hlt_p_val {
                                if {![isValidMacAddress $hlt_p_val_inner]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid MAC address 'hlt_p_val_inner'."
                                    return $returnList
                                }
                                set ixn_p_val_tmp  0x[join [::ixia::convertToIxiaMac $hlt_p_val_inner] ""]
#                                 set ixn_p_val_tmp [ixNetworkFormatMac $hlt_p_val_inner]
    #                             set ixn_p_val_tmp 0x[convert_string_to_hex $ixn_p_val_tmp]
#                                 set ixn_p_val_tmp 0x[string range [convert_string_to_hex $ixn_p_val_tmp] 0 9]
                                
                                if {$transform_to_int} {
                                    lappend ixn_p_val [mpformat %d $ixn_p_val_tmp]
                                } else {
                                    lappend ixn_p_val $ixn_p_val_tmp
                                }
                            }
                        } else {
                            if {![isValidMacAddress $hlt_p_val]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid MAC address 'hlt_p_val'."
                                return $returnList
                            }
                            set ixn_p_val_tmp  0x[join [::ixia::convertToIxiaMac $hlt_p_val] ""]
#                             set ixn_p_val_tmp [ixNetworkFormatMac $hlt_p_val]
    #                         set ixn_p_val_tmp 0x[convert_string_to_hex $ixn_p_val_tmp]
#                             set ixn_p_val_tmp 0x[string range [convert_string_to_hex $ixn_p_val_tmp] 0 9]
                            
                            if {$transform_to_int} {
                                set ixn_p_val [mpformat %d $ixn_p_val_tmp]
                            } else {
                                set ixn_p_val $ixn_p_val_tmp
                            }
                        }
                    }
                    value_translate {
                        if {$tmp_mode == "list"} {
                            set ixn_p_val ""
                            foreach hlt_p_val_inner $hlt_p_val {
                                if {![info exists this_translate_array($hlt_p_val_inner)]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Internal error. Unexpected choice value:\
                                            '$hlt_p_val_inner'. Known choice values are [array names this_translate_array]."
                                    return $returnList
                                }
                                
                                lappend ixn_p_val $this_translate_array($hlt_p_val_inner)
                            }
                        } else {
                            if {![info exists this_translate_array($hlt_p_val)]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Internal error. Unexpected choice value:\
                                        '$hlt_p_val'. Known choice values are [array names this_translate_array]."
                                return $returnList
                            }
                            
                            set ixn_p_val $this_translate_array($hlt_p_val)
                        }
                    }
                    translate {
                        set ixn_p_val $mode_translate_array($hlt_p_val)
                    }
                    translate_value_list {
                        if {[regexp {,} $hlt_p_val]} {
                            set ixn_p_val [split $hlt_p_val {,}]
                        } else {
                            set ixn_p_val $hlt_p_val
                        }
                    }
                    value_ipv4 {
                        # if mode == list is used to prevent cases where param values contain
                        # spaces and we accidentally iterate a single value
                        
                        if {$tmp_mode == "list"} {
                            set ixn_p_val ""
                            foreach hlt_p_val_inner $hlt_p_val {
    
                                set ixn_p_val_tmp $hlt_p_val_inner
                                
                                if {$transform_to_int} {
                                    lappend ixn_p_val [ip_addr_to_num $ixn_p_val_tmp]
                                } else {
                                    lappend ixn_p_val $ixn_p_val_tmp
                                }
                            }
                            
                        } else {
                            set ixn_p_val_tmp $hlt_p_val
                                
                            if {$transform_to_int} {
                                set ixn_p_val [ip_addr_to_num $ixn_p_val_tmp]
                            } else {
                                set ixn_p_val $ixn_p_val_tmp
                            }
                        }
                    }
                    value_int_2_hex {
                        if {$tmp_mode == "list"} {
                            set ixn_p_val ""
                            foreach hlt_p_val_inner $hlt_p_val {
                                
                                set ixn_p_val_tmp 0x[format %x [convert_string_to_hex $hlt_p_val_inner]]
                                
                                if {$transform_to_int} {
                                    lappend ixn_p_val [mpexpr $ixn_p_val_tmp]
                                } else {
                                    lappend ixn_p_val $ixn_p_val_tmp
                                }
                            }
                        } else {
                            set ixn_p_val_tmp 0x[format %x [convert_string_to_hex $hlt_p_val]]
                            
                            if {$transform_to_int} {
                                set ixn_p_val [mpexpr $ixn_p_val_tmp]
                            } else {
                                set ixn_p_val $ixn_p_val_tmp
                            }
                        }
                    }
                    value_string_to_ascii_hex {
                        if {$tmp_mode == "list"} {
                            set ixn_p_val ""
                            foreach hlt_p_val_inner $hlt_p_val {
                                
                                set ixn_p_val_tmp 0x[convert_string_to_ascii_hex $hlt_p_val_inner]
                                
                                if {$transform_to_int} {
                                    lappend ixn_p_val [mpexpr $ixn_p_val_tmp]
                                } else {
                                    lappend ixn_p_val $ixn_p_val_tmp
                                }
                            }
                        } else {
                            if {$hlt_p_val != ""} {
                                set ixn_p_val_tmp 0x[convert_string_to_ascii_hex $hlt_p_val]
                            } else {
                                set ixn_p_val_tmp "0x00"
                            }
                            
                            if {$transform_to_int} {
                                set ixn_p_val [mpexpr $ixn_p_val_tmp]
                            } else {
                                set ixn_p_val $ixn_p_val_tmp
                            }
                        }
                    }
                }
                
                lappend ixn_param_list -$ixn_p $ixn_p_val
            }
        }
        
        if {[llength $ixn_param_list] > 0} {
            lappend ixn_param_list -optionalEnabled true
            # BUG758574:
            # ::ixia::traffic_config -mode append_header -igmp_version 2 and 1 gives error
            # this happens because igmpv2 object has an accidental space at the end "igmpv2 "
            if {[llength $stack_field_handle] != 1} {
                set stack_field_handle [list $stack_field_handle]
            }

            set cmd "::ixia::ixNetworkNodeSetAttr $stack_field_handle [list $ixn_param_list] "
            
            if {$commit} {
                append cmd "commit"
                keylset returnList commit_needed 0
            } else {
                keylset returnList commit_needed 1
            }
            
            set ret_code [eval $cmd]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            
        }
        
        catch {unset tmp_mode}
        
        incr stack_field_handle_idx
    }
    
    return $returnList
}


proc ::ixia::540IxNetStackIPv4ConfigQos {qos_param_list args_qos stack_item} {
    
    debug "540IxNetStackIPv4ConfigQos $qos_param_list $args_qos $stack_item"
    
    keylset returnList status $::SUCCESS
    
    if {[catch {::ixia::parse_dashed_args -args $qos_param_list -optional_args $args_qos \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    if {[llength $stack_item] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error in 540IxNetStackIPv4ConfigQos. Stack handle was\
                not provided with 'stack_item' parameter"
        return $returnList
    }
    
    if {[info exists qos_type_ixn]} {
        
        # Priority done in ixnetwork style
        
        switch -- $qos_type_ixn {
            "custom" {
    
                set priority_type "raw"
        
                # Priority is raw
                # 
                # Parameters used:
                #     qos_type_ixn
                #     qos_value_ixn         0-255
                #     qos_value_ixn_mode
                #     qos_value_ixn_step
                #     qos_value_ixn_count
                #     qos_value_ixn_tracking
                
                array set encapsulation_pt_map {
                    ipv4                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"}
                }
                
                array set hlt_ixn_field_name_map {
                    ipv4_priority_raw                   "Raw priority"
                }
                
                array set protocol_template_field_map [list                                             \
                    ::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"     [list                             \
                                                                       ipv4_priority_raw                \
                                                                      ]                                 \
                ]
                
                #       hlt_param                       param_class               extra
                set ipv4_priority_raw {
                        qos_value_ixn                     value_int_2_hex           _none
                        qos_value_ixn_mode                mode                      _none
                        qos_value_ixn_step                step                      _none
                        qos_value_ixn_count               count                     _none
                        qos_value_ixn_tracking            tracking                  _none
                }
                
            }
            "tos" {
    
                set priority_type "tos"
        
                # Priority is tos
                
                if {[info exists qos_value_ixn]} {
                    # Use qos_value_ixn 0-7 for precedence settings
                    # 
                    # Parameters used:
                    #     qos_value_ixn         0-7
                    #     qos_value_ixn_mode
                    #     qos_value_ixn_step
                    #     qos_value_ixn_count
                    #     qos_value_ixn_tracking
                    
                    #       hlt_param                       param_class               extra
                    set ipv4_priority_tos_precedence_field {
                            qos_value_ixn                     value                     _none
                            qos_value_ixn_mode                mode                      _none
                            qos_value_ixn_step                step                      _none
                            qos_value_ixn_count               count                     _none
                            qos_value_ixn_tracking            tracking                  _none
                    }                                         
                    
                } elseif {[info exists ip_precedence]} {
                    # Use ip_precedence 0-7 for precedence settings
                    # 
                    # Parameters used:
                    #     ip_precedence         0-7
                    #     ip_precedence_mode
                    #     ip_precedence_step
                    #     ip_precedence_count
                    #     ip_precedence_tracking
                    
                    set ipv4_priority_tos_precedence_field {
                            ip_precedence                     value                     _none
                            ip_precedence_mode                mode                      _none
                            ip_precedence_step                step                      _none
                            ip_precedence_count               count                     _none
                            ip_precedence_tracking            tracking                  _none
                    }
                    
                }

                array set encapsulation_pt_map {
                    ipv4                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"}
                }
                
                array set hlt_ixn_field_name_map {
                    ipv4_priority_tos_precedence_field          "Precedence"
                    ipv4_priority_tos_delay_field               "Delay"
                    ipv4_priority_tos_throughput_field          "Throughput"
                    ipv4_priority_tos_reliability_field         "Reliability"
                    ipv4_priority_tos_monetary_field            "Monetary"
                    ipv4_priority_dscp_unused_field             "Unused"
                }
                
                array set protocol_template_field_map [list                                                 \
                    ::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"     [list                                 \
                                                                       ipv4_priority_tos_reliability_field  \
                                                                       ipv4_priority_tos_throughput_field   \
                                                                       ipv4_priority_tos_precedence_field   \
                                                                       ipv4_priority_tos_monetary_field     \
                                                                       ipv4_priority_tos_delay_field        \
                                                                       ipv4_priority_dscp_unused_field      \
                                                                      ]                                     \
                ]
                
                set ipv4_priority_tos_reliability_field {
                        ip_reliability                    value                     _none
                        ip_reliability_mode               mode                      _none
                        ip_reliability_tracking           tracking                  _none
                }
                
                set ipv4_priority_tos_throughput_field {
                        ip_throughput                     value                     _none
                        ip_throughput_mode                mode                      _none
                        ip_throughput_tracking            tracking                  _none
                }
                
                set ipv4_priority_tos_monetary_field {
                        ip_cost                           value                     _none
                        ip_cost_mode                      mode                      _none
                        ip_cost_tracking                  tracking                  _none
                }
                
                set ipv4_priority_tos_delay_field {
                        ip_delay                          value                     _none
                        ip_delay_mode                     mode                      _none
                        ip_delay_tracking                 tracking                  _none
                }
                
                set ipv4_priority_dscp_unused_field {
                    ip_cu                       value_int_2_hex           _none
                    ip_cu_mode                  mode                      _none
                    ip_cu_step                  step                      _none
                    ip_cu_count                 count                     _none
                    ip_cu_tracking              tracking                  _none
                }
                
                # 
                # Parameters used:
                #     qos_type_ixn
                #     ip_delay
                #     ip_delay_mode
                #     ip_delay_tracking
                #     ip_throughput
                #     ip_throughput_mode
                #     ip_throughput_tracking
                #     ip_reliability
                #     ip_reliability_mode
                #     ip_reliability_tracking
                #     ip_cost
                #     ip_cost_mode
                #     ip_cost_tracking
            }
            "dscp" {
                
                # Priority is Differentiated services
                
                if {[info exists qos_value_ixn]} {
                    switch -- [lindex $qos_value_ixn 0] {
                        "dscp_default" -
                        "ef" {
                            if {[lindex $qos_value_ixn 0] == "dscp_default"} {
                                set priority_type "dscp_default"
                            } else {
                                set priority_type "ef"
                            }
        
                            # Priority is Differentiated services - Default PHB or Expedited Forwarding (EF) PHB
                            # 
                            # Parameters used:
                            #     qos_type_ixn
                            #     qos_value_ixn
                            #     ip_dscp       0-63
                            #     ip_dscp_mode
                            #     ip_dscp_step
                            #     ip_dscp_count
                            #     ip_dscp_tracking
                            #     ip_cu         0-3
                            #     ip_cu_mode
                            #     ip_cu_step
                            #     ip_cu_count
                            #     ip_cu_tracking
                            
                            array set encapsulation_pt_map {
                                ipv4                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"}
                            }
                            
                            array set hlt_ixn_field_name_map {
                                ipv4_priority_dscp_default_field          "Default PHB"
                                ipv4_priority_dscp_unused_field           "Unused"
                            }
                            
                            array set protocol_template_field_map [list                                                 \
                                ::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"     [list                                 \
                                                                                   ipv4_priority_dscp_default_field     \
                                                                                   ipv4_priority_dscp_unused_field      \
                                                                                  ]                                     \
                            ]
                            
                            set ipv4_priority_dscp_default_field {
                                    ip_dscp                     value                     _none
                                    ip_dscp_mode                mode                      _none
                                    ip_dscp_step                step                      _none
                                    ip_dscp_count               count                     _none
                                    ip_dscp_tracking            tracking                  _none
                            }
                            
                            
                            set ipv4_priority_dscp_unused_field {
                                    ip_cu                       value_int_2_hex           _none
                                    ip_cu_mode                  mode                      _none
                                    ip_cu_step                  step                      _none
                                    ip_cu_count                 count                     _none
                                    ip_cu_tracking              tracking                  _none
                            }

                        }
                        "af_class1_low_precedence" -
                        "af_class1_medium_precedence" -
                        "af_class1_high_precedence" -
                        "af_class2_low_precedence" -
                        "af_class2_medium_precedence" -
                        "af_class2_high_precedence" -
                        "af_class3_low_precedence" -
                        "af_class3_medium_precedence" -
                        "af_class3_high_precedence" -
                        "af_class4_low_precedence" -
                        "af_class4_medium_precedence" -
                        "af_class4_high_precedence" {
                            
                            set priority_type "af"
                            
                            # Priority is Differentiated services - Assured Forwarding (AF) PHB
                            # 
                            # Parameters used:
                            #     qos_type_ixn
                            #     qos_value_ixn
                            #     qos_value_mode        fixed list
                            #     qos_value_tracking
                            #     ip_cu         0-3
                            #     ip_cu_mode
                            #     ip_cu_step
                            #     ip_cu_count
                            #     ip_cu_tracking
                            
                            if {[info exists qos_value_mode] && $qos_value_mode != "fixed" &&\
                                    $qos_value_mode != "list"} {
                                
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid value '$qos_value_mode'\
                                        for parameter -qos_value_mode. Valid values are:\
                                        'fixed' and 'list' when -qos_type_ixn is '$qos_type_ixn'\
                                        and -qos_value_ixn is '$qos_value_ixn'."
                                return $returnList
                            }
                            
                            array set encapsulation_pt_map {
                                ipv4                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"}
                            }
                            
                            array set hlt_ixn_field_name_map {
                                ipv4_priority_af_af_field               "Assured forwarding PHB"
                                ipv4_priority_af_unused_field           "Unused"
                            }
                            
                            array set protocol_template_field_map [list                                                 \
                                ::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"     [list                                 \
                                                                                   ipv4_priority_af_af_field            \
                                                                                   ipv4_priority_af_unused_field        \
                                                                                  ]                                     \
                            ]
                            
                            set ipv4_priority_af_af_field {
                                    qos_value_ixn               value                     {translate ipv4_priority_af_af_field_translate_arr}
                                    qos_value_ixn_step          step                      _none
                                    qos_value_ixn_count         count                     _none
                                    qos_value_ixn_mode          mode                      _none
                                    qos_value_ixn_tracking      tracking                  _none
                            }
                            
                            array set ipv4_priority_af_af_field_translate_arr {
                                "af_class1_low_precedence"    10
                                "af_class1_medium_precedence" 12
                                "af_class1_high_precedence"   14
                                "af_class2_low_precedence"    18
                                "af_class2_medium_precedence" 20
                                "af_class2_high_precedence"   22
                                "af_class3_low_precedence"    26
                                "af_class3_medium_precedence" 28
                                "af_class3_high_precedence"   30
                                "af_class4_low_precedence"    34
                                "af_class4_medium_precedence" 36
                                "af_class4_high_precedence"   38
                            }  
                            
                            set ipv4_priority_af_unused_field {
                                    ip_cu                       value_int_2_hex           _none
                                    ip_cu_mode                  mode                      _none
                                    ip_cu_step                  step                      _none
                                    ip_cu_count                 count                     _none
                                    ip_cu_tracking              tracking                  _none
                            }
                        }
                        "cs_precedence1" -
                        "cs_precedence2" -
                        "cs_precedence3" -
                        "cs_precedence4" -
                        "cs_precedence5" -
                        "cs_precedence6" -
                        "cs_precedence7" {
                        
                            set priority_type "cs"
                            
                            # Priority is Differentiated services - Class Selector PHB
                            # 
                            # Parameters used:
                            #     qos_type_ixn
                            #     qos_value_ixn
                            #     qos_value_mode        fixed list
                            #     qos_value_tracking
                            #     ip_cu         0-3
                            #     ip_cu_mode
                            #     ip_cu_step
                            #     ip_cu_count
                            #     ip_cu_tracking
                            
                            if {[info exists qos_value_mode] && $qos_value_mode != "fixed" &&\
                                    $qos_value_mode != "list"} {
                                
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid value '$qos_value_mode'\
                                        for parameter -qos_value_mode. Valid values are:\
                                        'fixed' and 'list' when -qos_type_ixn is '$qos_type_ixn'\
                                        and -qos_value_ixn is '$qos_value_ixn'."
                                return $returnList
                            }
                            
                            array set encapsulation_pt_map {
                                ipv4                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"}
                            }
                            
                            array set hlt_ixn_field_name_map {
                                ipv4_priority_cs_cs_field               "Class selector PHB"
                                ipv4_priority_cs_unused_field           "Unused"
                            }
                            
                            array set protocol_template_field_map [list                                                 \
                                ::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"     [list                                 \
                                                                                   ipv4_priority_cs_cs_field            \
                                                                                   ipv4_priority_cs_unused_field        \
                                                                                  ]                                     \
                            ]
                            
                            set ipv4_priority_cs_cs_field {
                                    qos_value_ixn               value                     {translate ipv4_priority_cs_cs_field_translate_arr}
                                    qos_value_ixn_count         count                     _none
                                    qos_value_ixn_step          step                      _none
                                    qos_value_ixn_mode          mode                      _none
                                    qos_value_ixn_tracking      tracking                  _none
                            }
                            
                            
                            set ipv4_priority_cs_unused_field {
                                    ip_cu                       value_int_2_hex           _none
                                    ip_cu_mode                  mode                      _none
                                    ip_cu_step                  step                      _none
                                    ip_cu_count                 count                     _none
                                    ip_cu_tracking              tracking                  _none
                            }
                            
                            array set ipv4_priority_cs_cs_field_translate_arr {
                                "cs_precedence1"    8
                                "cs_precedence2"    16
                                "cs_precedence3"    24
                                "cs_precedence4"    32
                                "cs_precedence5"    40
                                "cs_precedence6"    48
                                "cs_precedence7"    56
                            }

                        }
                        default {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Invalid choice '$qos_value_ixn' for \
                                    parameter -qos_value_ixn. Valid choices are: \
                                    'dscp_default', 'ef', 'af_class1_low_precedence',\
                                    'af_class1_medium_precedence', 'af_class1_high_precedence',\
                                    'af_class2_low_precedence', 'af_class2_medium_precedence',\
                                    'af_class2_high_precedence','af_class3_low_precedence',\
                                    'af_class3_medium_precedence', 'af_class3_high_precedence',\
                                    'af_class4_low_precedence', 'af_class4_medium_precedence',\
                                    'af_class4_high_precedence', 'cs_precedence1', 'cs_precedence2',\
                                    'cs_precedence3', 'cs_precedence4', 'cs_precedence5', 'cs_precedence6'\
                                    'cs_precedence7'."
                            return $returnList
                        }
                    }
                }
            }
            default {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid choice '$qos_type_ixn' for parameter -qos_type_ixn.\
                        Valid choices are: 'custom', 'tos', 'dscp'."
                return $returnList
            }
        }
    } elseif {[info exists data_tos] || [info exists qos_byte]} {
    
        set priority_type "tos"
        
        
        if {[info exists qos_byte]} {
            # Priority configurations in IxAccess style
            # Priority is TOS - Extract precedence and stuff from qos_byte
            # 
            # Parameters used:
            #     qos_byte                      0-127
            #     qos_byte_count
            #     qos_byte_mode
            #     qos_byte_step
            #     qos_byte_tracking
            
            set tos_param "qos_byte"
            
        } elseif {[info exists data_tos]} {
            # Priority configurations in IxAccess IGMPoPPPoX style
            # Priority is TOS - Extract precedence and stuff from data_tos
            # 
            # Parameters used:
            #     data_tos                      RANGE   0-127
            #     data_tos_count
            #     data_tos_mode
            #     data_tos_step
            #     data_tos_tracking
            
             set tos_param "data_tos"
        }
        
        set unset_list {
            ip_precedence
            ip_precedence_mode
            ip_precedence_step
            ip_precedence_count
            ip_precedence_tracking
            ip_delay
            ip_delay_mode
            ip_delay_tracking
            ip_throughput
            ip_throughput_mode
            ip_throughput_tracking
            ip_reliability
            ip_reliability_mode
            ip_reliability_tracking
            ip_cost
            ip_cost_mode
            ip_cost_tracking
        }
        
        foreach unset_p $unset_list {
            catch {unset $unset_p}
        }
        
        if {[info exists ${tos_param}_mode]} {
            set ip_reserved_mode    [set ${tos_param}_mode]
            set ip_cost_mode        [set ${tos_param}_mode]
            set ip_reliability_mode [set ${tos_param}_mode]
            set ip_throughput_mode  [set ${tos_param}_mode]
            set ip_delay_mode       [set ${tos_param}_mode]
            set ip_precedence_mode  [set ${tos_param}_mode]
        }
        
        if {[info exists data_tos_count]} {
            set ip_reserved_count    [set ${tos_param}_count]
            set ip_cost_count        [set ${tos_param}_count]
            set ip_reliability_count [set ${tos_param}_count]
            set ip_throughput_count  [set ${tos_param}_count]
            set ip_delay_count       [set ${tos_param}_count]
            set ip_precedence_count  [set ${tos_param}_count]
        }
        
        if {[info exists data_tos_step]} {
            set ip_reserved_step    [expr [set ${tos_param}_step] & 0x01]
            set ip_cost_step        [expr ([set ${tos_param}_step] >> 1) & 0x01]
            set ip_reliability_step [expr ([set ${tos_param}_step] >> 2) & 0x01]
            set ip_throughput_step  [expr ([set ${tos_param}_step] >> 3) & 0x01]
            set ip_delay_step       [expr ([set ${tos_param}_step] >> 4) & 0x01]
            set ip_precedence_step  [expr ([set ${tos_param}_step] >> 5) & 0x07]
        }
        
        if {[info exists data_tos_tracking]} {
            set ip_reserved_tracking    [set ${tos_param}_tracking]
            set ip_cost_tracking        [set ${tos_param}_tracking]
            set ip_reliability_tracking [set ${tos_param}_tracking]
            set ip_throughput_tracking  [set ${tos_param}_tracking]
            set ip_delay_tracking       [set ${tos_param}_tracking]
            set ip_precedence_tracking  [set ${tos_param}_tracking]
        }
        
        foreach tos_param_single_value [set ${tos_param}] {
            set ip_reserved    [expr $tos_param_single_value & 0x01]
            set ip_cost        [expr ($tos_param_single_value >> 1) & 0x01]
            set ip_reliability [expr ($tos_param_single_value >> 2) & 0x01]
            set ip_throughput  [expr ($tos_param_single_value >> 3) & 0x01]
            set ip_delay       [expr ($tos_param_single_value >> 4) & 0x01]
            set ip_precedence  [expr ($tos_param_single_value >> 5) & 0x07]
        }
        
        
        array set encapsulation_pt_map {
            ipv4                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"}
        }
        
        array set hlt_ixn_field_name_map {
            ipv4_priority_tos_precedence_field          "Precedence"
            ipv4_priority_tos_delay_field               "Delay"
            ipv4_priority_tos_throughput_field          "Throughput"
            ipv4_priority_tos_reliability_field         "Reliability"
            ipv4_priority_tos_monetary_field            "Monetary"
        }
        
        array set protocol_template_field_map [list                                                 \
            ::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"     [list                                 \
                                                               ipv4_priority_tos_reliability_field  \
                                                               ipv4_priority_tos_throughput_field   \
                                                               ipv4_priority_tos_precedence_field   \
                                                               ipv4_priority_tos_monetary_field     \
                                                               ipv4_priority_tos_delay_field        \
                                                              ]                                     \
        ]
        
        set ipv4_priority_tos_precedence_field {
                ip_precedence                     value                     _none
                ip_precedence_mode                mode                      _none
                ip_precedence_step                step                      _none
                ip_precedence_count               count                     _none
                ip_precedence_tracking            tracking                  _none
        }
        
        
        set ipv4_priority_tos_reliability_field {
                ip_reliability                    value                     _none
                ip_reliability_mode               mode                      _none
                ip_reliability_tracking           tracking                  _none
        }
        
        set ipv4_priority_tos_throughput_field {
                ip_throughput                     value                     _none
                ip_throughput_mode                mode                      _none
                ip_throughput_tracking            tracking                  _none
        }
        
        set ipv4_priority_tos_monetary_field {
                ip_cost                           value                     _none
                ip_cost_mode                      mode                      _none
                ip_cost_tracking                  tracking                  _none
        }
        
        set ipv4_priority_tos_delay_field {
                ip_delay                          value                     _none
                ip_delay_mode                     mode                      _none
                ip_delay_tracking                 tracking                  _none
        }
        
        
    } elseif {[info exists ip_dscp]} {
    
        set priority_type "dscp_default"
        
        # Priority in IxOS dscp style
        # Priority is Differentiated services - Default PHB or Expedited Forwarding (EF) PHB
        # 
        # Parameters used:
        #     ip_dscp       0-63
        #     ip_dscp_mode
        #     ip_dscp_step
        #     ip_dscp_count
        #     ip_dscp_tracking
        #     ip_cu         0-3
        #     ip_cu_mode
        #     ip_cu_step
        #     ip_cu_count
        #     ip_cu_tracking
        
        array set encapsulation_pt_map {
            ipv4                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"}
        }
        
        array set hlt_ixn_field_name_map {
            ipv4_priority_dscp_default_field          "Default PHB"
            ipv4_priority_dscp_unused_field           "Unused"
        }
        
        array set protocol_template_field_map [list                                                 \
            ::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"     [list                                 \
                                                               ipv4_priority_dscp_default_field     \
                                                               ipv4_priority_dscp_unused_field      \
                                                              ]                                     \
        ]
        
        set ipv4_priority_dscp_default_field {
                ip_dscp                     value                     _none
                ip_dscp_mode                mode                      _none
                ip_dscp_step                step                      _none
                ip_dscp_count               count                     _none
                ip_dscp_tracking            tracking                  _none
        }
        
        
        set ipv4_priority_dscp_unused_field {
                ip_cu                       value_int_2_hex           _none
                ip_cu_mode                  mode                      _none
                ip_cu_step                  step                      _none
                ip_cu_count                 count                     _none
                ip_cu_tracking              tracking                  _none
        }
        
        
    } else {
        
        set priority_type "tos"
        
        # Priority in IxOS tos style
        # Priority is TOS

#         ip_precedence         0-7
#         ip_precedence_mode
#         ip_precedence_step
#         ip_precedence_count
#         ip_precedence_tracking
#         ip_delay
#         ip_delay_mode
#         ip_delay_tracking
#         ip_throughput
#         ip_throughput_mode
#         ip_throughput_tracking
#         ip_reliability
#         ip_reliability_mode
#         ip_reliability_tracking
#         ip_cost
#         ip_cost_mode
#         ip_cost_tracking
        
        array set encapsulation_pt_map {
            ipv4                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"}
        }
        
        array set hlt_ixn_field_name_map {
            ipv4_priority_tos_precedence_field          "Precedence"
            ipv4_priority_tos_delay_field               "Delay"
            ipv4_priority_tos_throughput_field          "Throughput"
            ipv4_priority_tos_reliability_field         "Reliability"
            ipv4_priority_tos_monetary_field            "Monetary"
        }
        
        array set protocol_template_field_map [list                                                 \
            ::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"     [list                                 \
                                                               ipv4_priority_tos_reliability_field  \
                                                               ipv4_priority_tos_throughput_field   \
                                                               ipv4_priority_tos_precedence_field   \
                                                               ipv4_priority_tos_monetary_field     \
                                                               ipv4_priority_tos_delay_field        \
                                                              ]                                     \
        ]
        
        set ipv4_priority_tos_precedence_field {
                ip_precedence                     value                     _none
                ip_precedence_mode                mode                      _none
                ip_precedence_step                step                      _none
                ip_precedence_count               count                     _none
                ip_precedence_tracking            tracking                  _none
        }
        
        
        set ipv4_priority_tos_reliability_field {
                ip_reliability                    value                     _none
                ip_reliability_mode               mode                      _none
                ip_reliability_tracking           tracking                  _none
        }
        
        set ipv4_priority_tos_throughput_field {
                ip_throughput                     value                     _none
                ip_throughput_mode                mode                      _none
                ip_throughput_tracking            tracking                  _none
        }
        
        set ipv4_priority_tos_monetary_field {
                ip_cost                           value                     _none
                ip_cost_mode                      mode                      _none
                ip_cost_tracking                  tracking                  _none
        }
        
        set ipv4_priority_tos_delay_field {
                ip_delay                          value                     _none
                ip_delay_mode                     mode                      _none
                ip_delay_tracking                 tracking                  _none
        }
    }

    # Configure priority type
    # priority type is one of 'tos', 'dscp_default', 'cs', 'af', 'ef', 'raw'
    set ret_code [540IxNetStackIPv4QosSetType $priority_type $stack_item]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }

    
    #################################################################################
    # This is an overview of how the parameters are configured using the 
    # mapping arrays and lists:
    # 
    # foreach stack $stack_handles {
    #     
    #     stack --> protocol_template (using proc 540IxNetStackGetProtocolTemplate)
    #     
    #     protocol_template --> hlt_field_list (using array protocol_template_field_map)
    #     
    #     foreach field $hlt_field_list {
    #         
    #         field --> list_of_params_for_field (using the lists with the same name as $field)
    #         
    #         foreach {hlt_param hlt_intermediate_param parameter_type} $list_of_params_for_field {
    #             
    #             build arg list for 540TrafficStackFieldConfig
    #             use real field name in 540TrafficStackFieldConfig (real name obtained using hlt_ixn_field_name_map)
    #         }
    #     }
    # }
    ################################################################################

    if {![info exists stack_item]} {
        keylset returnList status $::FAILURE
        keylset returnList log "0Internal error. Variable stack_item is missing."
        return $returnList
    }
    
    set ret_code [540IxNetStackGetProtocolTemplate $stack_item]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set tmp_pt_handle [keylget ret_code pt_handle]
    set tmp_pt_name   [keylget ret_code pt_name]
    
    set hlt_field_list $protocol_template_field_map($tmp_pt_handle)
    
    switch -- $priority_type {
        "raw" {
            set field_regex "priority.raw"
        }
        "tos" {
            set field_regex "priority.tos"
        }
        "dscp_default" {
            set field_regex "priority.ds.phb.defaultPHB"
        }
        "cs" {
            set field_regex "priority.ds.phb.classSelectorPHB"
        }
        "af" {
            set field_regex "priority.ds.phb.assuredForwardingPHB"
        }
        "ef" {
            set field_regex "priority.ds.phb.expeditedForwardingPHB"
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error on '540IxNetStackIPv4ConfigQos.\
                    Unhandled value '$priority_type' for 'priority_type'. Known values are:\
                    'tos', 'dscp_default', 'cs', 'af', 'ef', 'raw'."
            return $returnList
        }
    }
    
    set commit_needed 0
    
    foreach hlt_field $hlt_field_list {
        
        set field_args ""
        
        foreach {hlt_p hlt_intermediate_p extras} [set $hlt_field] {
            
            if {[info exists $hlt_p]} {
                
                set hlt_p_value [set $hlt_p]
                
                if {$extras != "_none"} {
                    switch -- [lindex $extras 0] {
                        array_map {
                            # hlt choices array must be passed as argument to
                            # procedure 540TrafficStackFieldConfig
                            set tmp_param_array [lindex $extras 1]
                        }
                        translate {
                            # hlt choices do not match hlt_intermediate choices
                            array set tmp_local_map [array get [lindex $extras 1]]
                            
                            foreach single_hlt_p_value $hlt_p_value {
                                if {![info exists tmp_local_map($single_hlt_p_value)]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Internal error in array '$tmp_local_map_name': '[array get tmp_local_map]'.\
                                    Array index $single_hlt_p_value does not exist. Error occured when attempting to configure\
                                    parameter $hlt_p."                                    
                                    return $returnList
                                }

                                lappend new_hlt_value $tmp_local_map($single_hlt_p_value)
                            }
                            
                            set hlt_p_value $new_hlt_value
                            
                            catch {unset tmp_local_map}
                            catch {unset new_hlt_value}
                            catch {unset single_hlt_p_value}
                        }
                        p_format {
                            set tmp_strict_format [lindex $extras 1]
                        }
                        auto_if_false {
                            set dependency_param [lindex $extras 1]
                            if {![info exists $dependency_param] || [set $dependency_param] == 0} {
                                set $hlt_p "auto"
                                set hlt_p_value "auto"
                            }
                            catch {unset dependency_param}
                        }
                        default {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error in list $hlt_field.\
                                    Value at index 0 '[lindex $extras 0]' of extras '$extras'\
                                    is not handled. Error occured when attempting to configure\
                                    parameter $hlt_p."
                            return $returnList
                        }
                    }
                }
                
                if {[regexp {^value} $hlt_intermediate_p]} {
                    lappend field_args -p_type $hlt_intermediate_p
                    lappend field_args -value  $hlt_p_value
                } else {
                    lappend field_args -$hlt_intermediate_p $hlt_p_value
                }
            }
            
            if {[info exists tmp_param_array]} {
                lappend field_args -translate_array [array get $tmp_param_array]
            }
            
            if {[info exists tmp_strict_format]} {
                lappend field_args -strict_format $tmp_strict_format
            }
            
            catch {unset tmp_param_array}
            catch {unset tmp_strict_format}
        }
        
        if {[llength $field_args] > 0} {
                
            # call 540TrafficStackFieldConfig
            
            lappend field_args -stack_handle $stack_item
            lappend field_args -field_name   $hlt_ixn_field_name_map($hlt_field)
            if {[info exists field_regex]} {
                lappend field_args -field_regex  $field_regex
            }
            
            lappend field_args -commit 0
            
            set cmd "540TrafficStackFieldConfig $field_args"
            set ret_code [eval $cmd]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not configure stack $stack_item. Field\
                        $hlt_ixn_field_name_map($hlt_field). Call to '$cmd' failed.\
                        [keylget ret_code log]."
                return $returnList
            }
            
            if {[keylget ret_code commit_needed] == 1} {
                set commit_needed 1
            }
        }
    }
    
    if {$commit_needed} {
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to commit changes for fields $hlt_field_list"
            return $returnList
        }
    }
    
    catch {unset tmp_param_array}
    catch {unset tmp_pt_handle}
    catch {unset tmp_pt_name}

    
    return $returnList
}

#     set opt_args {
#         -qos_type_ixn                  ANY
#         -qos_value_ixn                 ANY
#         -qos_value_ixn_mode            CHOICES fixed incr decr list
#                                        DEFAULT fixed
#         -qos_value_ixn_step            NUMERIC
#                                        DEFAULT 1
#         -qos_value_ixn_count           NUMERIC
#                                        DEFAULT 1
#         -qos_value_ixn_tracking        CHOICES 0 1
#                                        DEFAULT 0
#         -ip_precedence                 RANGE   0-7
#         -ip_precedence_count           NUMERIC
#                                        DEFAULT 1
#         -ip_precedence_mode            CHOICES fixed incr decr list
#                                        DEFAULT fixed
#         -ip_precedence_step            RANGE   0-6
#                                        DEFAULT 1
#         -ip_precedence_tracking        CHOICES 0 1
#                                        DEFAULT 0
#         -ip_delay                      CHOICES 0 1
#         -ip_delay_mode                 CHOICES fixed list
#                                        DEFAULT fixed
#         -ip_delay_tracking             CHOICES 0 1
#                                        DEFAULT 0
#         -ip_throughput                 CHOICES 0 1
#         -ip_throughput_mode            CHOICES fixed list
#                                        DEFAULT fixed
#         -ip_throughput_tracking        CHOICES 0 1
#                                        DEFAULT 0
#         -ip_reliability                CHOICES 0 1
#         -ip_reliability_mode           CHOICES fixed list
#                                        DEFAULT fixed
#         -ip_reliability_tracking       CHOICES 0 1
#                                        DEFAULT 0
#         -ip_cost                       CHOICES 0 1
#         -ip_cost_mode                  CHOICES fixed list
#                                        DEFAULT fixed
#         -ip_cost_tracking              CHOICES 0 1
#                                        DEFAULT 0
#         -ip_dscp                       RANGE   0-63
#         -ip_dscp_count                 NUMERIC
#                                        DEFAULT 1
#         -ip_dscp_mode                  CHOICES fixed incr decr list
#                                        DEFAULT fixed
#         -ip_dscp_step                  RANGE   0-62
#                                        DEFAULT 1
#         -ip_dscp_tracking              CHOICES 0 1
#                                        DEFAULT 0
#         -ip_cu                         RANGE   0-3
#         -ip_cu_count                   NUMERIC
#                                        DEFAULT 1
#         -ip_cu_mode                    CHOICES fixed incr decr list
#                                        DEFAULT fixed
#         -ip_cu_step                    RANGE   0-2
#                                        DEFAULT 1
#         -ip_cu_tracking                CHOICES 0 1
#                                        DEFAULT 0
#         -qos_byte                      RANGE   0-127
#         -qos_byte_count                NUMERIC
#                                        DEFAULT 1
#         -qos_byte_mode                 CHOICES fixed incr decr list
#                                        DEFAULT fixed
#         -qos_byte_step                 RANGE   0-126
#                                        DEFAULT 1
#         -qos_byte_tracking             CHOICES 0 1
#                                        DEFAULT 0
#         -data_tos                      RANGE   0-127
#         -data_tos_count                NUMERIC
#                                        DEFAULT 1
#         -data_tos_mode                 CHOICES fixed incr decr list
#                                        DEFAULT fixed
#         -data_tos_step                 RANGE   0-126
#                                        DEFAULT 1
#         -data_tos_tracking             CHOICES 0 1
#                                        DEFAULT 0
#     }


proc ::ixia::540IxNetStackIPv4QosSetType {priority_type stack_item} {
    keylset returnList status $::SUCCESS
    
    if {[catch {ixNet getList $stack_item field} field_list]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error in '540IxNetStackIPv4QosSetType $priority_type $stack_item.\
                Failed to ixNet getList $stack_item field. $field_list"
        return $returnList
    }
    
    set rawf        ""
    set tosf        ""
    set phbdefaultf ""
    set phbclassphb ""
    set phbaf       ""
    set phbef       ""
    
    foreach single_field $field_list {
        
        if {[regexp {ipv4\.header\.priority\.raw} $single_field]} {
            lappend rawf $single_field
        } elseif {[regexp {ipv4\.header\.priority\.tos} $single_field]} {
            lappend tosf $single_field
        } elseif {[regexp {ipv4\.header\.priority\.ds\.phb\.defaultPHB} $single_field]} {
            lappend phbdefaultf $single_field
        } elseif {[regexp {ipv4\.header\.priority\.ds\.phb\.classSelectorPHB} $single_field]} {
            lappend phbclassphb $single_field
        } elseif {[regexp {ipv4\.header\.priority\.ds\.phb\.assuredForwardingPHB} $single_field]} {
            lappend phbaf $single_field
        } elseif {[regexp {ipv4\.header\.priority\.ds\.phb\.expeditedForwardingPHB} $single_field]} {
            lappend phbef $single_field
        }
        
    }
    
    switch -- $priority_type {
        "raw" {
            set enable_item  [list rawf]
            set disable_list [list      tosf phbdefaultf phbclassphb phbaf phbef]
        }
        "tos" {
            set enable_item  [list tosf]
            set disable_list [list rawf      phbdefaultf phbclassphb phbaf phbef]
        }
        "dscp_default" {
            set enable_item  [list phbdefaultf]
            set disable_list [list rawf tosf             phbclassphb phbaf phbef]
        }
        "cs" {
            set enable_item  [list phbclassphb]
            set disable_list [list rawf tosf phbdefaultf             phbaf phbef]
        }
        "af" {
            set enable_item  [list phbaf]
            set disable_list [list rawf tosf phbdefaultf phbclassphb       phbef]
        }
        "ef" {
            set enable_item  [list phbef]
            set disable_list [list rawf tosf phbdefaultf phbclassphb phbaf      ]
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error on '540IxNetStackIPv4QosSetType $priority_type $stack_item.\
                    Unhandled value '$priority_type' for 'priority_type'. Known values are:\
                    'tos', 'dscp_default', 'cs', 'af', 'ef', 'raw'."
            return $returnList
        }
    }
    
    if {![info exists enable_item] || ![info exists disable_list]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error on '540IxNetStackIPv4QosSetType $priority_type $stack_item.\
                One of the following lists are empty: 'enable_item', 'disable_list'."
        return $returnList
    }
    
    foreach priority_type $disable_list {
        foreach priority_field [set $priority_type] {
            debug "ixNet setAttribute $priority_field -activeFieldChoice false"
            set ret [ixNet setAttribute $priority_field -activeFieldChoice false]
        }
    }
    
    foreach priority_field [set $enable_item] {
        debug "ixNet setAttribute $priority_field -activeFieldChoice true"
        set ret [ixNet setAttribute $priority_field -activeFieldChoice true]
    }
    
    if {[ixNet commit] != "::ixNet::OK"} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to change priority type in header $stack_item."
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::540TrafficStackGod { stack_handles } {

    keylset returnList status $::SUCCESS
    
    set caller_proc [lindex [info level -1] 0]
    
    set upvar_arrays [list hlt_ixn_field_name_map protocol_template_field_map \
            headers_multiple_instances]
    
    foreach upvar_array $upvar_arrays {
        upvar $upvar_array $upvar_array
        
        if {![info exists $upvar_array]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Internal array is missing: '$upvar_array' in procedure '$caller_proc'."
            return $returnList
        }
    }
    
    set upvar_opt_lists [list regex_enable_list regex_disable_list use_name_instead_of_displayname\
            multiple_level_fields multiple_level_fields_depth multiple_level_fields_ro_counter]
    foreach upvar_optional $upvar_opt_lists {
        upvar $upvar_optional $upvar_optional
    }
    
    # Run consistency check
    foreach protocol_template [array names protocol_template_field_map] {
        set pt_field_list $protocol_template_field_map($protocol_template)
        foreach pt_field $pt_field_list {
            if {![info exists hlt_ixn_field_name_map($pt_field)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Field '$pt_field' is missing from internal array 'hlt_ixn_field_name_map'."
                return $returnList
            }
            
            upvar $pt_field $pt_field
            
            if {![info exists $pt_field]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Array for '$pt_field' is missing."
                return $returnList
            }
        }
    }
    
    #################################################################################
    #
    # This is an overview of how the parameters are configured using the 
    # mapping arrays and lists:
    # 
    # foreach stack $stack_handles {
    #     
    #     stack --> protocol_template (using proc 540IxNetStackGetProtocolTemplate)
    #     
    #     protocol_template --> hlt_field_list (using array protocol_template_field_map)
    #     
    #     foreach field $hlt_field_list {
    #         
    #         field --> list_of_params_for_field (using the lists with the same name as $field)
    #         
    #         foreach {hlt_param hlt_intermediate_param parameter_type} $list_of_params_for_field {
    #             
    #             build arg list for 540TrafficStackFieldConfig
    #             use real field name in 540TrafficStackFieldConfig (real name obtained using hlt_ixn_field_name_map)
    #         }
    #     }
    # }
    #
    ################################################################################
    
    foreach single_header [array names headers_multiple_instances] {
        set $headers_multiple_instances($single_header) 0
    }
    set commit_needed 0
    foreach stack_item $stack_handles {
        
        set ret_code [540IxNetStackGetProtocolTemplate $stack_item]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set tmp_pt_handle [keylget ret_code pt_handle]
        set tmp_pt_name   [keylget ret_code pt_name]
        
        if {[info exists regex_disable_list] && [info exists regex_disable_list($tmp_pt_handle)]} {
            # set activeFieldChoice to false for all fields that match the regexp
            if {[catch {ixNet getList $stack_item field} stack_field_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed get list of child objects field for\
                        stack $stack_item: 'ixNet getList $stack_item field' returned\
                        '$stack_field_list'."
                return $returnList
            }
            
            foreach stack_field $stack_field_list {
                foreach regex_expr $regex_disable_list($tmp_pt_handle) {
                    if {[regexp $regex_expr $stack_field]} {
                        set ret_code [ixNet setAttribute $stack_field -activeFieldChoice false]
                        if {$ret_code != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to 'ixNet setAttribute $stack_field \
                                    -activeFieldChoice false': $ret_code"
                            return $returnList
                        }
                    }
                }
            }
        }
        
        if {[info exists regex_enable_list] && [info exists regex_enable_list($tmp_pt_handle)]} {
            # set activeFieldChoice to true for all fields that match the regexp
            if {[catch {ixNet getList $stack_item field} stack_field_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed get list of child objects field for\
                        stack $stack_item: 'ixNet getList $stack_item field' returned\
                        '$stack_field_list'."
                return $returnList
            }
            
            foreach stack_field $stack_field_list {
                foreach regex_expr $regex_enable_list($tmp_pt_handle) {
                    if {[regexp $regex_expr $stack_field]} {
                        set ret_code [ixNet setAttribute $stack_field -activeFieldChoice true]
                        if {$ret_code != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to 'ixNet setAttribute $stack_field \
                                    -activeFieldChoice false': $ret_code"
                            return $returnList
                        }
                    }
                }
            }
        }
        
        set hlt_field_list $protocol_template_field_map($tmp_pt_handle)
        
        foreach hlt_field $hlt_field_list {
            
            set field_args ""
            
            foreach {hlt_p hlt_intermediate_p extras} [set $hlt_field] {
                
                upvar $hlt_p $hlt_p
                
                if {[info exists $hlt_p]} {
                    
                    if {[info exists headers_multiple_instances($tmp_pt_handle)]} {
                        
                        # Doing this for headers that appear more than once. Like ipv6 extensions
                        
                        debug "==> hlt_p == $hlt_p"
                        
                        if {[llength [set $hlt_p]] > 1} {
                            
                            set hlt_p_value [lindex [set $hlt_p] [set $headers_multiple_instances($tmp_pt_handle)]]
                            debug "set hlt_p_value \[lindex [set $hlt_p] [set $headers_multiple_instances($tmp_pt_handle)]\]"
                            
                        } else {
                            debug "==> set hlt_p_value [set $hlt_p]"
                            set hlt_p_value [set $hlt_p]
                        }
                        
                    } else {
                        
                        set hlt_p_value [set $hlt_p]
                    }
                    
                    if {[info exists multiple_level_fields($tmp_pt_handle)]} {

                        if {[lsearch $multiple_level_fields($tmp_pt_handle) $hlt_field] != -1} {
                            
                            if {![info exists multiple_level_fields_depth($hlt_field)]} {
                                set multiple_level_fields_depth($hlt_field) "none"
                            }
                            
                            set cmd_status [540IxNetGetLevelsCountAtDepth2 $hlt_p_value]
                            if {[keylget cmd_status status] != $::SUCCESS} {
                                return $cmd_status
                            }
                            
                            set tmp_field_levels_count [keylget cmd_status levels_count]
                            set tmp_field_levels_span  [keylget cmd_status levels_span]
                            set tmp_field_levels_flat  [keylget cmd_status levels_flat]
                            
                            if {![info exists field_levels_count] || $tmp_field_levels_count > $field_levels_count} {
                                set field_levels_count $tmp_field_levels_count
                            }
                            
                            if {![info exists field_levels_span]} {
                                set field_levels_span $tmp_field_levels_span
                            }
                            
                            if {![info exists field_levels_flat]} {
                                set field_levels_flat $tmp_field_levels_flat
                            }
                            
                            if {[info exists multiple_level_fields_ro_counter($hlt_field)]} {
                                set field_levels_ro_count_prop $multiple_level_fields_ro_counter($hlt_field)
                            }
                            
                            set hlt_p_value $tmp_field_levels_flat
                            
                            catch {unset tmp_field_levels_count}
                            catch {unset tmp_field_levels_span}
                        }
                    }
                    
                    if {$extras != "_none"} {
                        
                        if {[lindex $extras 0] == "multiple_cond"} {
                            set extras_list [lrange $extras 1 end]
                        } else {
                            set extras_list [list $extras]
                        }
                        
                        foreach extras $extras_list {

                            switch -- [lindex $extras 0] {
                                array_map {
                                    # hlt choices array must be passed as argument to
                                    # procedure 540TrafficStackFieldConfig
                                    set tmp_param_array [lindex $extras 1]
                                    upvar $tmp_param_array $tmp_param_array
                                }
                                translate {
                                    # hlt choices do not match hlt_intermediate choices
                                    set tmp_local_map_name [lindex $extras 1]
                                    upvar $tmp_local_map_name $tmp_local_map_name
                                    array set tmp_local_map [array get $tmp_local_map_name]
                                    
                                    set new_hlt_value ""
                                    foreach single_hlt_p_value $hlt_p_value {    
                                        
                                        if {![info exists tmp_local_map($single_hlt_p_value)]} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "Internal error in array '$tmp_local_map_name': '[array get tmp_local_map]'.\
                                                    Array index $single_hlt_p_value does not exist. Error occured when attempting to configure\
                                                    parameter $hlt_p."
                                            return $returnList
                                        }
                                        
                                        lappend new_hlt_value $tmp_local_map($single_hlt_p_value)

                                    }
                                    
                                    set hlt_p_value $new_hlt_value

                                    catch {unset tmp_local_map}
                                    catch {unset new_hlt_value}
                                    catch {unset single_hlt_p_value}
                                    
                                }
                                p_format {
                                    set tmp_strict_format [lindex $extras 1]
                                }
                                auto_if_false {
                                    set dependency_param [lindex $extras 1]
                                    upvar $dependency_param $dependency_param
                                    if {![info exists $dependency_param] || [set $dependency_param] == 0} {
                                        set $hlt_p "auto"
                                        set hlt_p_value "auto"
                                    }
                                    catch {unset dependency_param}
                                }
                                auto_if_true {
                                    set dependency_param [lindex $extras 1]
                                    upvar $dependency_param $dependency_param
                                    if {![info exists $dependency_param] || [set $dependency_param] == 1} {
                                        set $hlt_p "auto"
                                        set hlt_p_value "auto"
                                    }
                                    catch {unset dependency_param}
                                }
                                auto_if_ne {
                                    set dependency_param [lindex $extras 1]
                                    upvar $dependency_param $dependency_param
                                    if {![info exists $dependency_param]} {
                                        set $hlt_p "auto"
                                        set hlt_p_value "auto"
                                    }
                                    catch {unset dependency_param}
                                }
                                default {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Internal error in list $hlt_field.\
                                            Value at index 0 '[lindex $extras 0]' of extras '$extras'\
                                            is not handled. Error occured when attempting to configure\
                                            parameter $hlt_p."
                                    return $returnList
                                }
                            }
                        }
                    }
                    
                    if {[regexp {^value} $hlt_intermediate_p]} {
                        lappend field_args -p_type $hlt_intermediate_p
                        lappend field_args -value  $hlt_p_value
                    } else {
                        lappend field_args -$hlt_intermediate_p $hlt_p_value
                    }
                }
                
                if {[info exists tmp_param_array]} {
                    lappend field_args -translate_array [array get $tmp_param_array]
                }
                
                if {[info exists tmp_strict_format]} {
                    lappend field_args -strict_format $tmp_strict_format
                }
                
                catch {unset tmp_param_array}
                catch {unset tmp_strict_format}
            }
            
            if {[llength $field_args] > 0} {
                    
                # call 540TrafficStackFieldConfig
                
                lappend field_args -stack_handle $stack_item
                
                if {[info exists regex_enable_list] && [info exists regex_enable_list($tmp_pt_handle)]} {
                    lappend field_args -field_regex $regex_enable_list($tmp_pt_handle)
                }
                
                if {[info exists use_name_instead_of_displayname]} {
                    switch -exact -- $use_name_instead_of_displayname {
                        0 {
                            lappend field_args -field_name   $hlt_ixn_field_name_map($hlt_field)
                        }
                        1 { 
                            lappend field_args -field_name   $hlt_ixn_field_name_map($hlt_field)
                            lappend field_args -use_name_instead_of_displayname 1 
                        }
                        2 { 
                            lappend field_args -field_name   [lindex $hlt_ixn_field_name_map($hlt_field) 1]
                            lappend field_args -use_name_instead_of_displayname [lindex $hlt_ixn_field_name_map($hlt_field) 0] 
                        }
                        3 {
                            # using the actual field identifier to "build" the field object instead of searching for it
                            lappend field_args -field_name   $hlt_ixn_field_name_map($hlt_field)
                            lappend field_args -use_name_instead_of_displayname 3
                        }
                    }
                } else {
                    lappend field_args -field_name   $hlt_ixn_field_name_map($hlt_field)
                }
                
                if {[info exists field_levels_count]} {
                    lappend field_args -field_levels_count $field_levels_count
                }
                
                if {[info exists field_levels_span]} {
                    lappend field_args -field_levels_span $field_levels_span
                }
                
                if {[info exists multiple_level_fields_depth($hlt_field)]} {
                    lappend field_args -field_levels_depth $multiple_level_fields_depth($hlt_field)
                }
                
                if {[info exists field_levels_ro_count_prop]} {
                    lappend field_args -field_levels_ro_count_prop $field_levels_ro_count_prop
                }
                
                set cmd "540TrafficStackFieldConfig $field_args"
                set ret_code [eval $cmd]
                if {[keylget ret_code status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not configure stack $stack_item. Field\
                            $hlt_ixn_field_name_map($hlt_field). Call to '$cmd' failed.\
                            [keylget ret_code log]."
                    return $returnList
                }
                set commit_needed 1
            }
            
            catch {unset field_levels_count}
            catch {unset field_levels_span}
            catch {unset field_levels_flat}
            catch {unset field_levels_ro_count_prop}
        }
        
        if {[info exists headers_multiple_instances($tmp_pt_handle)]} {
            incr $headers_multiple_instances($tmp_pt_handle)
        }
        
        catch {unset tmp_param_array}
        catch {unset tmp_pt_handle}
        catch {unset tmp_pt_name}
    }
    if {$commit_needed && [catch {ixNet commit} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to set field arguments. 'ixNet commit' failed with: $err"
        return $returnList
    }
    return $returnList
}


proc ::ixia::540TrafficAdjustFieldLevelSpan {stack_handle field_levels_span inner_field_name field_levels_ro_count_prop use_name_instead_of_displayname} {
    
    keylset returnList status $::SUCCESS
    
    # Build a list with the $field_levels_ro_count_prop fields from $stack_handle
    if {[catch {ixNet getList $stack_handle field} field_list]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on 'ixNet getList $stack_handle field'. $field_list"
        return $returnList
    }
    
    foreach field_obj $field_list {
        if {$use_name_instead_of_displayname} {
            set field_name [ixNet getA $field_obj -name]
        } else {
            set field_name [ixNet getA $field_obj -displayName]
        }
        
        if {[string trim $field_name] == [string trim $field_levels_ro_count_prop]} {
            
            if {[info exists inner_field_list]} {
                lappend internal_ro_counter_prop_list $tmp_key1 $inner_field_list
                catch {unset tmp_key1}
                catch {unset inner_field_list}
            }
            
            set tmp_key1 $field_obj
        }
        
        if {[string trim $field_name] == [string trim $inner_field_name]} {
            lappend inner_field_list $field_obj
        }
    }
    
    if {[info exists tmp_key1] && [info exists inner_field_list]} {
        lappend internal_ro_counter_prop_list $tmp_key1 $inner_field_list
        catch {unset tmp_key1}
        catch {unset inner_field_list}
    }
    
    if {![info exists internal_ro_counter_prop_list]} {
        debug "WARNING: '540TrafficAdjustFieldLevelSpan $stack_handle $field_levels_span $inner_field_name $field_levels_ro_count_prop $use_name_instead_of_displayname'\
                produced empty list for 'internal_ro_counter_prop_list'."
        return $returnList
    }
    
    if {[expr [llength $internal_ro_counter_prop_list] / 2] != [llength $field_levels_span]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error: unexpected outer counter for inner multiple level arg\
                '$field_levels_ro_count_prop'; expected: [llength $field_levels_span]; actual [expr [llength $internal_ro_counter_prop_list] / 2]."
        return $returnList
    }
    
    # Adjust list in reversed order because if we modify an element that is lower in the stack
    # will modify all items above and we would have to rebuild the internal_ro_counter_prop_list list
    # after every modification
    for {set i [expr [llength $internal_ro_counter_prop_list] - 2]; set j [expr [llength $field_levels_span] - 1]} {$i >= 0} {incr i -2; incr j -1} {
        set prop_count_obj [lindex $internal_ro_counter_prop_list $i]
        set proc_item_obj_list [lindex $internal_ro_counter_prop_list [expr $i + 1]]
        
        set prop_counter [llength $proc_item_obj_list]
        set span_counter [lindex $field_levels_span $j]
        
        if {$prop_counter < $span_counter} {
            set objects_to_add [expr $span_counter - $prop_counter]
            for {set otd 0} {$otd < $objects_to_add} {incr otd} {
                if {[catch {ixNet exec addLevel [lindex $proc_item_obj_list end]} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to ixNet exec addLevel [lindex $proc_item_obj_list end]. $err."
                    return $returnList
                }
            }
        } elseif {$prop_counter > $span_counter} {
            set objects_to_remove [expr $prop_counter - $span_counter]
            for {set otr 0} {$otr < $objects_to_remove} {incr otr} {
                if {[catch {ixNet exec removeLevel [lindex $proc_item_obj_list end]} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to ixNet exec addLevel [lindex $proc_item_obj_list end]. $err."
                    return $returnList
                }
                
                set proc_item_obj_list [lreplace $proc_item_obj_list end end]
            }
        }
    }
    
    set field_levels_count 0
    foreach span_item $field_levels_span {
        incr field_levels_count $span_item
    }
    
    keylset returnList field_levels_count $field_levels_count
    
    return $returnList
}


proc ::ixia::540IxNetGetLevelsCountAtDepth {hlt_param_value depth} {
    
    # Extract leveled lists that look like keyed lists
    # {val1 {innerval1 innerval2} val2 {innerval3} ...}
    
    # Depth currently supported only with values 0 and 1
    
    if {$depth != "none" && $depth != 1 && $depth != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error on '540IxNetGetLevelsCountAtDepth $hlt_param_value $depth'.\
                Parameter $depth supports only 'none', '0' or '1'."
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    
    if {$depth == "none"} {
        # Simple list distributed on 1 level
        set levels_span [llength $hlt_param_value]
        set levels_flat $hlt_param_value
        set levels_count [llength $hlt_param_value]
    } elseif {$depth == 0} {
        # Imbricated list distributed on 2 levels. Requested outer level
        set new_list ""
        foreach {a b} $hlt_param_value {
            lappend new_list $a
        }
        set levels_span [llength $new_list]
        set levels_flat $new_list
        set levels_count [llength $new_list]
    } else {
        # Imbricated list distributed on 2 levels. Requested inner level
        set levels_count 0
        set new_list ""
        set levels_span ""
        foreach {a b} $hlt_param_value {
            lappend new_list $b
            incr levels_count [llength $b]
            lappend levels_span [llength $b]
        }
        set levels_span $levels_span
        set levels_flat [join $new_list]
        set levels_count $levels_count
    }
    
    keylset returnList levels_count $levels_count
    keylset returnList levels_span  $levels_span
    keylset returnList levels_flat  $levels_flat
    
    return $returnList
}


proc ::ixia::540IxNetGetLevelsCountAtDepth2 {hlt_param_value} {
    
    # Extract leveled lists that arre lists in lists
    # {{innerval1 innerval2} {innerval3} }
    
    # Depth currently supported only with values 0 and 1
    
    keylset returnList status $::SUCCESS
    
    
    # Imbricated list distributed on 2 levels. Requested inner level
    set levels_count 0
    set new_list ""
    set levels_span ""
    foreach inner_list $hlt_param_value {
        lappend new_list $inner_list
        incr levels_count [llength $inner_list]
        lappend levels_span [llength $inner_list]
    }
    set levels_span $levels_span
    set levels_flat [join $new_list]
    set levels_count $levels_count

    
    keylset returnList levels_count $levels_count
    keylset returnList levels_span  $levels_span
    keylset returnList levels_flat  $levels_flat
    
    return $returnList
}


proc ::ixia::540IxNetTrafficReturnHandles {handle_list {l47_traffic_flag 0} {session_resume 0}} {
    
    keylset returnList status $::SUCCESS
    keylset returnList log ""
    
    if {[info exists ::ixia::skip_return_handles] && $::ixia::skip_return_handles} {
        return $returnList
    }
    if {$l47_traffic_flag} {
        puts "WARNING: Legacy ApplicationLib Traffic was removed from IxNetwork."
    }
    foreach handle $handle_list {
        set ret_val [540IxNetValidateObject $handle [list traffic_item config_element high_level_stream stack_hls stack_ce] 0]
        if {[keylget ret_val status] != $::SUCCESS} {
            keylset ret_val log "[keylget returnList log]\nInvalid handle $handle. It must be a traffic item\
                    handle or a child object of $handle. [keylget ret_val log]"
            return $ret_val
        }
        
        set traffic_item_objref [ixNetworkGetParentObjref $handle "trafficItem"]
        set traffic_item_name   [ixNet getAttr $traffic_item_objref -name]
        
        
        if {$traffic_item_objref == [ixNet getNull]} {
            keylset returnList status $::FAILURE
            keylset returnList log "[keylget returnList log]\nInternal error.\
                    Failed to extract trafficItem object from $handle."
            return $returnList
        }
        
        if {[set warningMsg [ixNet getAttribute $traffic_item_objref -warnings]] != ""} {
            puts "$traffic_item_objref - $warningMsg."
            update idletasks
            keylset returnList log "[keylget returnList log]\n$traffic_item_objref - $warningMsg."
        }
        
        if {![catch {keylget returnList stream_id} str_id_list]} {
            if {[lsearch $str_id_list $traffic_item_name] == -1} {
                lappend str_id_list $traffic_item_name
                keylset returnList stream_id $str_id_list
            } else {
                # Traffic item and child objects already added
                continue
            }
        } else {
            keylset returnList stream_id $traffic_item_name
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getList $traffic_item_objref configElement]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set config_elements [keylget ret_code ret_val]
        
        if {[llength $config_elements] == 0} {
            # It could be a quick flow. Use traffic item object
            set config_elements $traffic_item_objref
        }
        
        if {![catch {keylget returnList traffic_item} str_id_list]} {
            set str_id_list ""
            foreach tmp_ce $config_elements {
                if {[lsearch $str_id_list $tmp_ce] == -1} {
                    lappend str_id_list $tmp_ce
                }
            }
            keylset returnList traffic_item $str_id_list
            catch {unset tmp_ce}
        } else {
            keylset returnList traffic_item $config_elements
        }
        
        foreach tmp_ce $config_elements {
            if {$config_elements == $traffic_item_objref} {
                set ret_code [ixNetworkEvalCmd [list ixNet getList $traffic_item_objref highLevelStream]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    keylset ret_code log "[keylget returnList log]\n[keylget ret_code log]"
                    return $ret_code
                }
                
                set ti_streams [keylget ret_code ret_val]
                
            } else {
                set ret_val [540trafficGetHLSforCE $tmp_ce "force"]
                if {[keylget ret_val status] != $::SUCCESS} {
                    keylset ret_val log "[keylget returnList log]\n[keylget ret_val log]"
                    return $ret_val
                }
                
                set ti_streams [keylget ret_val handles]
                set hls_endpoint_set_id [keylget ret_val endpoint_set_id]
                set hls_encapsulation_name [keylget ret_val encapsulation_name]
                
                set ti_stacks_list [ixNet getList $tmp_ce stack]
                if {[llength $ti_stacks_list] > 0} {
                    keylset returnList ${tmp_ce}.headers $ti_stacks_list
                }
            }
            
            if {[llength $ti_streams] > 0} {
                keylset returnList ${tmp_ce}.stream_ids $ti_streams
                foreach hl_stream $ti_streams {
                    set stacks_list [ixNet getList $hl_stream stack]
                    keylset returnList ${tmp_ce}.$hl_stream.headers $stacks_list
                }
                if {[info exists hls_endpoint_set_id]} {
                    keylset returnList ${tmp_ce}.endpoint_set_id $hls_endpoint_set_id
                }
                if {[info exists hls_encapsulation_name]} {
                    keylset returnList ${tmp_ce}.encapsulation_name $hls_encapsulation_name
                }
            } else {
                # Show a warning instead of throwing an error 
                # if the function is called from session resume
                if {$session_resume == 1} {
                    puts "Warning: No high level streams were configured in traffic item \"[ixNet getAttribute $traffic_item_objref -name]\":\
                            [lindex [ixNet getAttribute $traffic_item_objref -warnings] end].\
                            [lindex [ixNet getAttribute $traffic_item_objref -errors] end]." 
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "[keylget returnList log]\
                            Error in traffic item $traffic_item_objref:\
                            no high level streams were configured.\
                            [lindex [ixNet getAttribute $traffic_item_objref -warnings] end].\
                            [lindex [ixNet getAttribute $traffic_item_objref -errors] end]."
                    return $returnList
                }
            }
        }
    }
    
    return $returnList
}


proc ::ixia::540trafficGetDynamicObjects {object_ref object_type} {
    
    set procName [lindex [info level [info level]] 0]
    
    # First build a list with all dynamicRate and dynamicFrameSize objects
    set ti_handle [ixNetworkGetParentObjref $object_ref "trafficItem"]
    set ti_name [ixNet getA $ti_handle -name]
    
    set ti_dyn_rate ""
    foreach dynamic_rate_object [ixNet getList [ixNet getRoot]/traffic dynamicRate] {
        if {[regexp "^::ixNet::OBJ-/traffic/dynamicRate:\"$ti_name\\\-FlowGroup-\\\d+\\\"$" $dynamic_rate_object]} {
            lappend ti_dyn_rate $dynamic_rate_object
        }
    }
    
    set ti_dyn_fs ""
    foreach dynamic_fs_object [ixNet getList [ixNet getRoot]/traffic dynamicFrameSize] {
        if {[regexp "^::ixNet::OBJ-/traffic/dynamicFrameSize:\"$ti_name\\\-FlowGroup-\\\d+\\\"$" $dynamic_fs_object]} {
            lappend ti_dyn_fs $dynamic_fs_object
        }
    }
    
    switch -- $object_type {
        "traffic_item" {
            # Just return all dynamic rate objects
            keylset returnList rate_handle      $ti_dyn_rate
            keylset returnList framesize_handle $ti_dyn_fs
        }
        "config_element" {
            set ce_dyn_rate ""
            set ce_dyn_fs   ""
            
            set ret_code [540trafficGetHLSforCE $object_ref]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set hls_handles  [keylget ret_code handles]
            set flow_indexes [keylget ret_code indexes]
            
            if {[llength flow_indexes] > 0} {
                set flow_concat ""
                foreach flow_idx $flow_indexes {
                    append flow_concat $flow_idx
                }

                foreach dynamic_rate_object $ti_dyn_rate {
                    if {[regexp "^::ixNet::OBJ-/traffic/dynamicRate:\\\"$ti_name\\\-FlowGroup-\[$flow_concat\]\\\"$" $dynamic_rate_object]} {
                        lappend ce_dyn_rate $dynamic_rate_object
                    }
                }
                
                foreach dynamic_fs_object $ti_dyn_fs {
                    if {[regexp "^::ixNet::OBJ-/traffic/dynamicFrameSize:\"$ti_name\\\-FlowGroup-\[$flow_concat\]\\\"$" $dynamic_fs_object]} {
                        lappend ce_dyn_fs $dynamic_fs_object
                    }
                }
            } else {
                # No high level streams were detected for this config element
                # The encapsulations must have changed and we can't tell anymore
                # Return all dynamic objects
                set ce_dyn_rate $ti_dyn_rate
                set ce_dyn_fs $ti_dyn_fs
            }
            
            keylset returnList rate_handle      $ce_dyn_rate
            keylset returnList framesize_handle $ce_dyn_fs
        }
        "high_level_stream" {
            set hls_dyn_rate ""
            set hls_dyn_fs   ""
            
            if {![regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:)(\d+$)} $object_ref {} {} flow_index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error in $procName. Failed to extract flow index from\
                        '$object_ref'."
                return $returnList
            }
            
            foreach dynamic_rate_object $ti_dyn_rate {
                if {[regexp "^::ixNet::OBJ-/traffic/dynamicRate:\"$ti_name\\\-FlowGroup-\[$flow_index\]\\\"$" $dynamic_rate_object]} {
                    lappend hls_dyn_rate $dynamic_rate_object
                }
            }
            
            foreach dynamic_fs_object $ti_dyn_fs {
                if {[regexp "^::ixNet::OBJ-/traffic/dynamicFrameSize:\"$ti_name\\\-FlowGroup-\[$flow_index\]\\\"$" $dynamic_fs_object]} {
                    lappend hls_dyn_fs $dynamic_fs_object
                }
            }
            
            keylset returnList rate_handle      $hls_dyn_rate
            keylset returnList framesize_handle $hls_dyn_fs
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid object type '$object_type'. Valid objects are 'trafficItem',\
                    'configElement', 'highLevelStream'."
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::540trafficGetHLSforCE {config_element_handle {force "noforce"}} {
    
    # This proc returns 2 lists
    # key:handles value:list of high level stream handles (flow groups) that are associated with
    #       config_element_handle
    # key:indexes value:list of flow group numbers (the index of the handles). Can be used to extract the 
    #       dynamic objects associated to a config element. 
    # The 'force' parameter is used when no high level streams associated to a config element was found.
    # The detection is normally done by validating the encapName of the config element with the encapName
    # of the high level stream.
    # Also, the procedure returns the endpoint_set_id and the encapsulation_name of the highLevelStream
    # If no hls were found for the CE, the new criteria for hls to ce map will be endpointSetID
    
    set procName [lindex [info level [info level]] 0]
    
    keylset returnList status $::SUCCESS
    
#     # Must generate traffic because highLevelStream encapsulations might differ from what is on configElements
#     set retCode [540IxNetTrafficGenerate $config_element_handle]
#     if {[keylget retCode status] != $::SUCCESS} {
#         return $retCode
#     }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getA $config_element_handle -encapsulationName]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set ce_encap_name [keylget ret_code ret_val]
    
    if {$force == "force"} {
        set force 1
    } else {
        set force 0
    }
    
    if {$force} {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $config_element_handle -endpointSetId]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set epset_id [keylget ret_code ret_val]
    }
    
    set ti_obj [ixNetworkGetParentObjref $config_element_handle trafficItem]
    
    if {$ti_obj == [ixNet getNull]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to extract trafficItem object from $config_element_handle.\
                Error occured in internal procedure $procName."
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getL $ti_obj highLevelStream]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set hls_list [keylget ret_code ret_val]
    
    set ret_hls_list ""
    set ret_hls_idx_list ""
    set ret_obj_encap_name ""
    set ret_obj_endpoint_id ""
    
    if {$force} {
        set force_ret_hls_list ""
        set force_ret_hls_idx_list ""
        set force_ret_obj_encap_name ""
        set force_ret_obj_endpoint_id ""
    }
    
    foreach hls_obj $hls_list {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $hls_obj -encapsulationName]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set hlt_obj_encap_name [keylget ret_code ret_val]
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $hls_obj -endpointSetId]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set hlt_obj_epset_id [keylget ret_code ret_val]
        
        if {$force==1} {
            if {($hlt_obj_epset_id == $epset_id)} {
            
                if {![regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:)(\d+$)} $hls_obj {} {} force_flow_index]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error in $procName. Failed to extract flow index from\
                            '$hls_obj'."
                    return $returnList
                }
                
                lappend force_ret_hls_list     $hls_obj
                lappend force_ret_hls_idx_list $force_flow_index
                # the same endpointSetId and encapsulationName, when using "force"
                # because all the highLevelStreams should match the same configElement
                set force_ret_obj_encap_name $hlt_obj_encap_name
                set force_ret_obj_endpoint_id $hlt_obj_epset_id
            }
        }
        
        if {($force==0) && ($hlt_obj_encap_name == $ce_encap_name)} {
            
            if {![regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:)(\d+$)} $hls_obj {} {} flow_index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error in $procName. Failed to extract flow index from\
                        '$hls_obj'."
                return $returnList
            }
            
            lappend ret_hls_list     $hls_obj
            lappend ret_hls_idx_list $flow_index
            lappend ret_obj_encap_name $hlt_obj_encap_name
            lappend ret_obj_endpoint_id $hlt_obj_epset_id
            
        }
    }
    
    if {$force} {
        keylset returnList handles $force_ret_hls_list
        keylset returnList indexes $force_ret_hls_idx_list
        keylset returnList endpoint_set_id $force_ret_obj_endpoint_id
        keylset returnList encapsulation_name $force_ret_obj_encap_name
    } else {
        keylset returnList handles $ret_hls_list
        keylset returnList indexes $ret_hls_idx_list
        keylset returnList endpoint_set_id $ret_obj_endpoint_id
        keylset returnList encapsulation_name $ret_obj_encap_name
    }
    
    return $returnList
}


proc ::ixia::540trafficGetTiWithRxPort {port_handle_list} {
    
    keylset returnList status $::SUCCESS
    
    variable ixnetwork_port_handles_array
    variable truth
    
    array set reversed_truth {
        true        1
        false       0
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getL [ixNet getRoot]traffic trafficItem]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    set all_tis [keylget ret_code ret_val]
    
    if {[llength $port_handle_list] == 0} {
        keylset returnList handle_list $all_tis
        return $returnList
    }
    
    set vport_handle_list ""
    foreach port_h $port_handle_list {
        set ret_code [ixNetworkGetPortObjref $port_h]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        lappend vport_handle_list [keylget ret_code vport_objref]
    }
    
    set ret_ti_list ""
    # We must filter the traffic items based on their RX port (and TX port if traffic is bidirectional)
    foreach traffic_item $all_tis {
        
        set valid_ti 0
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $traffic_item -biDirectional]]
            if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set bidir $reversed_truth([keylget ret_code ret_val])
        
        set ti_port_handles ""
        
        set ret_code [ixNetworkEvalCmd [list ixNet getL $traffic_item endpointSet]]
            if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set es_list [keylget ret_code ret_val]
        
        foreach endpoint_set $es_list {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $endpoint_set -destinations]]
                if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set rx_endpoints [keylget ret_code ret_val]
            
            foreach rx_ep $rx_endpoints {
                if {[llength $rx_ep] > 0 && [regexp {^::ixNet::OBJ-/vport:\d+} $rx_ep]} {
                    set tmp_vport [ixNetworkGetParentObjref $rx_ep "vport"]
                    if {[lsearch $vport_handle_list $tmp_vport] != -1} {
                        lappend ret_ti_list $traffic_item
                        set valid_ti 1
                        break
                    }
                }
            }
            
            if {$valid_ti} {
                break
            }
            
        }
        
        if {$valid_ti || !$bidir} {
            continue
        }
        
        # If the code gets here it means that none of the destinations of the traffic item
        # matches the port list
        # Traffic is bidirectinal so try to match against the sources of the traffic item
        foreach endpoint_set $es_list {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $endpoint_set -sources]]
                if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set tx_endpoints [keylget ret_code ret_val]
            
            foreach tx_ep $tx_endpoints {
                if {[llength $tx_ep] > 0 && [regexp {^::ixNet::OBJ-/vport:\d+} $tx_ep]} {
                    set tmp_vport [ixNetworkGetParentObjref $tx_ep "vport"]
                    if {[lsearch $vport_handle_list $tmp_vport] != -1} {
                        lappend ret_ti_list $traffic_item
                        set valid_ti 1
                        break
                    }
                }
            }
            
            if {$valid_ti} {
                break
            }
            
        }
    }
    
    keylset returnList handle_list $ret_ti_list
    return $returnList
}


proc ::ixia::540trafficConfigureLatencyBins {traffic_item config_bins config_values {auto_bins {1}}} {
    
    keylset returnList status $::SUCCESS
    
    if {[llength $config_values] < 1} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid latency/jitter bins configuration. The bins list is empty."
        return $returnList
    }
    
    # previous implementation was automatically adding an element. This was wrong 
    # and is inconsistent with IxN behaiviour. The resulted config was
    # not be the same as the operations was done from GUI. Refactoring to take
    # into accout the the last element is added automatically by IxN 
    # and the the number of bins should be 1+ the actual number of values provided
    # to be consistent with IxN behaiviour.
    set calculated_bins_no [expr 1 + [llength $config_values]]
    
    if {$auto_bins} {
        # Ignoring config_bins param and calculating the number of bins based on config_values
            # we add 1 to the calculated number of values because the last 
            # element is auto added by IxN (MAX value in GUI -> tcl value 2147483647)
            # This is to be consistent with IxNetwork GUI behaiviour.
        set config_bins $calculated_bins_no
    }
    
    if {$config_bins > 16} {
        keylset returnList status $::FAILURE
        keylset returnList log "The number of bins '$config_bins' cannot be greater than 16."
        return $returnList
    }
    
    if {$config_bins > 1} {
        
        if {$config_bins > $calculated_bins_no} {
            puts "\nWARNING: The number of latency/jitter bins requested is '$config_bins'\
                    but the list of bins will result in '$calculated_bins_no' bins.\
                    Modifying the number of bins to '$calculated_bins_no'.\n"
            set config_bins $calculated_bins_no
            
        } elseif {$config_bins < $calculated_bins_no} {
             puts "\nWARNING: The number of latency/jitter bins requested is '$config_bins'\
                    but the list of bins will result in '$calculated_bins_no' bins (this\
                    is larger with 1 than the number of values provided)\
                    Trucating the number of bins to '$config_bins'.\n"
            set config_values [lrange $config_values 0 [expr $config_bins - 2]]
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getL $traffic_item tracking]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        set tracking_obj [keylget ret_code ret_val]
        
        set ret_code [ixNetworkEvalCmd [list ixNet getL $tracking_obj latencyBin]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        set latency_bin_obj [keylget ret_code ret_val]
        
        set retCode [ixNetworkNodeSetAttr        \
                $latency_bin_obj                 \
                [list                            \
                    -enabled      true           \
                    -binLimits    $config_values \
                    -numberOfBins $config_bins  ]\
                -commit                     ]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
    }
    
    return $returnList
}


proc ::ixia::540trafficGetMaxTiTrack {{ti_handle_list ""}} {
    keylset returnList status $::SUCCESS
    
    if {[llength $ti_handle_list] < 1} {
        set ti_handle_list [ixNet getList [ixNet getRoot]traffic trafficItem]
    }
    
    set trk_fields_list ""
    foreach ti_handle $ti_handle_list {
        if {[catch {ixNet getA $ti_handle/tracking -trackBy} out]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed ot get track by fields for traffic item $ti_handle. Possible\
                    reason: traffic_generator is ixnetwork (not ixnetwork_540)."
            return $returnList
        }
        
        foreach trk_name $out {
            if {[regexp {trackingenabled\d+} $trk_name]} {
                continue
            }

            if {[lsearch $trk_fields_list $trk_name] == -1} {
                lappend trk_fields_list $trk_name
            }
        }
    }
    
    keylset returnList ret_val [llength $trk_fields_list]
    return $returnList
}


proc ::ixia::540trafficRollback { rollback_list mode } {
    
    set commit_flag 0
    debug 1
    if {$mode == "create"} {
        debug 2
        foreach ti $rollback_list {
            debug "regexp {^::ixNet::OBJ-/traffic/trafficItem:\d+} $ti"
            
            if {[regexp {^::ixNet::OBJ-/traffic/trafficItem:\d+} $ti]} {
                set tmp_ti [ixNetworkGetParentObjref $ti "trafficItem"]
                debug "set tmp_ti \[ixNetworkGetParentObjref $ti \"traffic_item\"\] --> $tmp_ti"
                if {$tmp_ti != [ixNet getNull]} {
                    catch {ixNet remove $tmp_ti}
                    set commit_flag 1
                }
            }
        }
    }
    if {$commit_flag} {
        debug "ixNet commit"
        catch {ixNet commit}
    }
}

# Takes a traffic item and returns its config element(s).
# When no config elements are found, the high level stream list is returned. 
proc ::ixia::540getConfigElementOrHighLevelStream { trf_item } {
    set valid_status [::ixia::540IxNetValidateObject $trf_item [list "traffic_item" "config_element" "high_level_stream"]]
    if {[keylget valid_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid handle '$trf_item'. It must be a trafficItem, configElement or\
                highLevelStream handle."
        return $returnList
    }
    
    set obj_type [keylget valid_status value]
    
    if {$obj_type == "traffic_item"} {
        set ce_list [ixNet getL $trf_item configElement]
        if {[llength $ce_list] > 0} {
            keylset returnList status $::SUCCESS
            keylset returnList handle $ce_list
            return $returnList
        }
        set hls_list [ixNet getL $trf_item highLevelStream]
        if {[llength $hls_list] > 0} {
            keylset returnList status $::SUCCESS
            keylset returnList handle $hls_list
            return $returnList
        }
    } else {
        keylset returnList status $::SUCCESS
        keylset returnList handle $trf_item
        return $returnList
    }
    
    keylset returnList status $::FAILURE
    keylset returnList log "The current traffic item has no config elements or high level streams configured!"
    return $returnList
}


proc ::ixia::540getTrafficItemByName {ti_name} {

    set ti_handle_list [ixNet getList [ixNet getRoot]traffic trafficItem]
    
    set found 0
    foreach ti_handle $ti_handle_list { 
        set ti_handle_name [ixNet getA $ti_handle -name]
        if {$ti_handle_name == $ti_name} {
            set found 1
            break
        }
    }
    
    if {$found} {
        return $ti_handle
    } else {
        return "_none"
    }
}


proc ::ixia::540trafficGetRxPortsForTi {tiObjRef} {
    
    keylset returnList status $::SUCCESS
    
    variable ixnetwork_port_handles_array
    variable truth
    
    array set reversed_truth {
        true        1
        false       0
    }
    
    set ret_val [540IxNetValidateObject $tiObjRef [list traffic_item]]
    if {[keylget ret_val status] != $::SUCCESS} {
        keylset ret_val log "Invalid handle $tiObjRef. It must be a traffic item\
                handle. [keylget ret_val log]"
        return $ret_val
    }
    
    set vport_handle_list ""

    set ret_code [ixNetworkEvalCmd [list ixNet getA $tiObjRef -biDirectional]]
        if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set bidir $reversed_truth([keylget ret_code ret_val])
    
    set ret_code [ixNetworkEvalCmd [list ixNet getL $tiObjRef endpointSet]]
        if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set es_list [keylget ret_code ret_val]
    
    foreach endpoint_set $es_list {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $endpoint_set -destinations]]
            if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set rx_endpoints [keylget ret_code ret_val]
        
        foreach rx_ep $rx_endpoints {
            if {[llength $rx_ep] > 0 && [regexp {^::ixNet::OBJ-/vport:\d+} $rx_ep]} {
                set tmp_vport [ixNetworkGetParentObjref $rx_ep "vport"]
                if {[lsearch $vport_handle_list $tmp_vport] == -1} {
                    lappend vport_handle_list $tmp_vport
                }
            }
        }
    }
    
    if {$bidir} {
        foreach endpoint_set $es_list {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $endpoint_set -sources]]
                if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set tx_endpoints [keylget ret_code ret_val]
            
            foreach tx_ep $tx_endpoints {
                if {[llength $tx_ep] > 0 && [regexp {^::ixNet::OBJ-/vport:\d+} $tx_ep]} {
                    set tmp_vport [ixNetworkGetParentObjref $tx_ep "vport"]
                    if {[lsearch $vport_handle_list $tmp_vport] == -1} {
                        lappend vport_handle_list $tmp_vport
                    }
                }
            }
        }
    }
    
    keylset returnList ret_val $vport_handle_list
    return $returnList
}


proc ::ixia::540trafficGetTxDistributionObj {ixn_obj} {
    set procName [lindex [info level [info level]] 0]
    keylset returnList status $::SUCCESS
    
    set ret_code [540IxNetValidateObject $ixn_obj [list traffic_item config_element \
            high_level_stream stack_ce stack_hls]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set return_obj_ref ""
    
    set ixn_obj_type [keylget ret_code value]
    switch -- $ixn_obj_type {
        "traffic_item" {
            set ret_code [ixNetworkEvalCmd [list ixNet getList $ixn_obj transmissionDistribution]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set return_obj_ref [keylget ret_code ret_val]
        }
        "stack_ce" -
        "config_element" {
            
            set config_element [ixNetworkGetParentObjref $ixn_obj configElement]
            if {$config_element == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList "Failed to extract configElement object from $ixn_obj. Error occured\
                        in internal procedure $procName."
                return $returnList
            }
            
            set ret_code [ixNetworkEvalCmd [list ixNet getList $config_element transmissionDistribution]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set return_obj_ref [keylget ret_code ret_val]
        }
        "stack_hls" -
        "high_level_stream" {
            
            set hls_obj [ixNetworkGetParentObjref $ixn_obj highLevelStream]
            if {$hls_obj == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList "Failed to extract highLevelStream object from $ixn_obj. Error occured\
                        in internal procedure $procName."
                return $returnList
            }
            
            set ret_code [540trafficGetCEforHLS $hls_obj]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set ce_obj [keylget ret_code handle]
            if {[llength $ce_obj] == 0} {
                
                # The only case when there is no configElement associated with a high level stream
                # is when we are dealing with quick flows. In this case we return transmissionDistribution
                # of the trafficItem
                
                set ti_obj [ixNetworkGetParentObjref $ixn_obj trafficItem]
                if {$ti_obj == [ixNet getNull]} {
                    keylset returnList status $::FAILURE
                    keylset returnList "Failed to extract trafficItem object from $ixn_obj. Error occured\
                            in internal procedure $procName."
                    return $returnList
                }
                
                set ret_code [ixNetworkEvalCmd [list ixNet getList $ti_obj transmissionDistribution]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set return_obj_ref [keylget ret_code ret_val]
                
            } else {
                
                set ret_code [ixNetworkEvalCmd [list ixNet getList $ce_obj transmissionDistribution]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set return_obj_ref [keylget ret_code ret_val]
            }
        }
    }
    
    if {[llength $return_obj_ref] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not find a transmissionDistribution for object $ixn_obj.\
                Error occured in $procName"
        return $returnList
    }
    
    keylset returnList handle $return_obj_ref
    return $returnList
}


proc ::ixia::540trafficGetCEforHLS {high_level_stream_obj} {
    
    keylset returnList status $::SUCCESS
    
    set ret_code [ixNetworkEvalCmd [list ixNet getA $high_level_stream_obj -encapsulationName]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set hls_encap_name [keylget ret_code ret_val]
    
    set ce_return_obj ""
    
    set ti_obj [ixNetworkGetParentObjref $high_level_stream_obj trafficItem]
    if {$ti_obj == [ixNet getNull]} {
        keylset returnList status $::FAILURE
        keylset returnList "Failed to extract trafficItem object from $high_level_stream_obj."
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getList $ti_obj configElement]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set ce_list [keylget ret_code ret_val]
    
    foreach ce_obj_ref $ce_list {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $ce_obj_ref -encapsulationName]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set ce_tmp_name [keylget ret_code ret_val]
        if {$hls_encap_name == $ce_tmp_name} {
            set ce_return_obj $ce_obj_ref
            break
        }
    }
    
    keylset returnList handle $ce_return_obj
    return $returnList
}


proc ::ixia::540trafficAdjustPtList {handle pt_list} {
    
    keylset returnList status $::SUCCESS
    
    set procName [lindex [info level [info level]] 0]
    
    set ret_val [540IxNetValidateObject $handle [list "config_element" "high_level_stream" "stack_hls" "stack_ce"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        keylset ret_val log "Could not adjust protocol template list. [keylget ret_val log]"
        return $ret_val
    }
    
    set handle_type [keylget ret_val value]
    
    switch -- $handle_type {
        "high_level_stream" -
        "stack_hls" {
            set hls_handle [ixNetworkGetParentObjref $handle "highLevelStream"]
            if {$hls_handle == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Failed to get highLevelStream object from '$handle'.\
                        Error occured in $procName."
                return $returnList
            }
            
            set ret_code [540trafficGetCEforHLS $hls_handle]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set ce_obj [keylget ret_code handle]
            if {[llength $ce_obj] == 0} {
                # This is probably a quick stream
                keylset returnList pt_list $pt_list
                return $returnList
            }
        }
        "stack_ce" -
        "config_element" {
            set ce_obj [ixNetworkGetParentObjref $handle "configElement"]
            if {$ce_obj == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Failed to get configElement object from '$handle'.\
                        Error occured in $procName."
                return $returnList
            }
        }
    }
    
    # Now we have a configElement handle --> $ce_obj
    set ti_obj [ixNetworkGetParentObjref $ce_obj "trafficItem"]
    if {$ti_obj == [ixNet getNull]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to get trafficItem object from '$ce_obj'.\
                Error occured in $procName."
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getList $ti_obj configElement]]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Could not adjust protocol template list. [keylget ret_code log]"
        return $ret_code
    }
    
    set config_element_list [keylget ret_code ret_val]
    
    if {[llength $config_element_list] < 2} {
        # There's just 1 configElement. No need to ajust protocol templates
        keylset returnList pt_list $pt_list
        return $returnList 
    }
    
    set tmp_ce_idx [lsearch $config_element_list $ce_obj]
    if {$tmp_ce_idx == -1} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error in $procName. Config element $ce_obj could\
                not be found among traffic item '$ti_obj' config elements."
        return $returnList
    }
    
    # Remove the config element we were given from the list
    set config_element_list [lreplace $config_element_list $tmp_ce_idx $tmp_ce_idx]
    
    set new_pt_list ""
    
    set ret_code [540IxNetFindStacksAll $ce_obj $pt_list]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set search_in_other_ce_s_pt_list ""
    foreach tmp_pt $pt_list {
        
        set tmp_stack_list [keylget ret_code $tmp_pt]
        
        if {[llength $tmp_stack_list] == 0} {
            lappend search_in_other_ce_s_pt_list $tmp_pt
        }
        
        catch {unset tmp_stack_list}
    }
    
    if {[llength $search_in_other_ce_s_pt_list] == 0} {
        # The config element contains all headers that we want to configure
        keylset returnList pt_list $pt_list
        return $returnList 
    }
    
    set config_elements_found_in_other_ces ""
    foreach tmp_ce_handle $config_element_list {
        set ret_code [540IxNetFindStacksMultipleCE $tmp_ce_handle $search_in_other_ce_s_pt_list]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }

        foreach tmp_pt $search_in_other_ce_s_pt_list {
            
            set tmp_stack_list [keylget ret_code $tmp_pt]
            
            if {[llength $tmp_stack_list] > 0} {
                if {[lsearch $config_elements_found_in_other_ces $tmp_pt] == -1} {
                    lappend config_elements_found_in_other_ces $tmp_pt
                }
            }
        }
        
        foreach tmp_pt $config_elements_found_in_other_ces {
            # remove the ones that were found from the search list
            set tmp_idx [lsearch $search_in_other_ce_s_pt_list $tmp_pt]
            if {$tmp_idx != -1} {
                set search_in_other_ce_s_pt_list [lreplace $search_in_other_ce_s_pt_list $tmp_idx $tmp_idx]
            }
        }
        
        if {[llength $search_in_other_ce_s_pt_list] == 0} {
            # All missing protocol templates were found in other config elements
            # Stop searching
            break
        }
    }
    
    # Remove the protocol templates that were found in other config elements from the
    # protocol template list that we want to add to our configElement.
    foreach tmp_pt $config_elements_found_in_other_ces {
        set tmp_idx [lsearch $pt_list $tmp_pt]
        if {$tmp_idx != -1} {
            set pt_list [lreplace $pt_list $tmp_idx $tmp_idx]
        }
    }
    
    keylset returnList pt_list $pt_list     
    return $returnList
}
