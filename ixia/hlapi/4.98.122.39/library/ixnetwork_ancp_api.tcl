proc ::ixia::ixnetwork_ancp_config { args opt_args} {
    variable objectMaxCount
    variable ixnetwork_port_handles_array
    variable ancp_handles_array
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    set supported_handle_types {
        ipEndpoint
        pppoxEndpoint
        dhcpEndpoint
        pppox/dhcpoPppClientEndpoint
        pppox/dhcpoPppServerEndpoint
        ip/l2tp/dhcpoLacEndpoint
        ip/l2tp/dhcpoLnsEndpoint
        ip/l2tpEndpoint
    }
    
    set endpoint_validation_regexp     {(^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\"[a-zA-Z0-9\-]+\"/(ip|dhcp|pppox)Endpoint:\"[a-zA-Z0-9\-]+\"/range:\"[a-zA-Z0-9\-]+\"$)}
    append endpoint_validation_regexp {|(^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\\\"[a-zA-Z0-9\-]+\\\"/(ip|dhcp|pppox)Endpoint:\\\"[a-zA-Z0-9\-]+\\\"/range:\\\"[a-zA-Z0-9\-]+\\\"$)}
    append endpoint_validation_regexp {|(^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\"[a-zA-Z0-9\-]+\"/pppox:\"[a-zA-Z0-9\-]+\"/(dhcpoPppClient|dhcpoPppServer)Endpoint:\"[a-zA-Z0-9\-]+\"/range:\"[a-zA-Z0-9\-]+\"$)}
    append endpoint_validation_regexp {|(^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\\\"[a-zA-Z0-9\-]+\\\"/pppox:\\\"[a-zA-Z0-9\-]+\\\"/(dhcpoPppClient|dhcpoPppServer)Endpoint:\\\"[a-zA-Z0-9\-]+\\\"/range:\\\"[a-zA-Z0-9\-]+\\\"$)}
    append endpoint_validation_regexp {|(^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\"[a-zA-Z0-9\-]+\"/ip:\"[a-zA-Z0-9\-]+\"/l2tp:\"[a-zA-Z0-9\-]+\"/(dhcpoLac|dhcpoLns)Endpoint:\"[a-zA-Z0-9\-]+\"/range:\"[a-zA-Z0-9\-]+\"$)}
    append endpoint_validation_regexp {|(^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\\\"[a-zA-Z0-9\-]+\\\"/ip:\\\"[a-zA-Z0-9\-]+\\\"/l2tp:\\\"[a-zA-Z0-9\-]+\\\"/(dhcpoLac|dhcpoLns)Endpoint:\\\"[a-zA-Z0-9\-]+\\\"/range:\\\"[a-zA-Z0-9\-]+\\\"$)}
    append endpoint_validation_regexp {|(^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\"[a-zA-Z0-9\-]+\"/ip:\"[a-zA-Z0-9\-]+\"/l2tpEndpoint:\"[a-zA-Z0-9\-]+\"/range:\"[a-zA-Z0-9\-]+\"$)}
    append endpoint_validation_regexp {|(^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\\\"[a-zA-Z0-9\-]+\\\"/ip:\\\"[a-zA-Z0-9\-]+\\\"/l2tpEndpoint:\\\"[a-zA-Z0-9\-]+\\\"/range:\\\"[a-zA-Z0-9\-]+\\\"$)}
    append endpoint_validation_regexp {|(^::ixNet::OBJ-/vport:[0-9]+/protocolStack/(ethernet|atm):\"[a-zA-Z0-9\-]+\"/(ip|dhcp|pppox)Endpoint:\"[a-zA-Z0-9\-]+\"/range:\"[a-zA-Z0-9\-]+\"/ancpRange:[0-9]+$)}

    set supported_protocols_msg "ANCP/IP/PPP/DHCP/L2TP/DHCPoPPP/DHCPoL2TP"
    
    if {$mode == "create"} {
        if {![info exists port_handle] && ![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode parameter -port_handle\
                    or parameter -handle must be provided."
            return $returnList
        }
        set invalid_handle 0
        if {[info exists handle]} {
            if {![regexp $endpoint_validation_regexp $handle]} {
                set invalid_handle 1
            } else {
                set retCode [ixNetworkGetPortFromObj $handle]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $reCode
                }
                set port_handles  [keylget retCode port_handle]
                set port_objrefs  [keylget retCode vport_objref]
                set range_objrefs $handle
            }
        } 
        if {[info exists port_handle] && (![info exists handle] || $invalid_handle) } {
            set port_handles $port_handle
            set retCode [ixNetworkGetPortObjref $port_handle]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port \
                        object reference associated to the $port_handle port handle -\
                        [keylget retCode log]."
                return $returnList
            }
            set port_objrefs [keylget retCode vport_objref]
            set l2List [ixNet getList $port_objrefs/protocolStack atm]
            set l2List [concat $l2List [ixNet getList $port_objrefs/protocolStack ethernet]]
            if {$l2List == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "There is no $supported_protocols_msg emulation \
                        created on port $port_handle. Please configure one of\
                        these emulations and then call again ANCP configuration."
                return $returnList
            }
            
            set childList ""
            set rangeList ""
            set rangeElemFound ""
            foreach l2Elem $l2List {
                foreach supported_handle_type $supported_handle_types {
                    set childElems [split $supported_handle_type /]
                    set startElem  $l2Elem
                    foreach childElem $childElems {
                        set startElem [lindex [ixNet getList $startElem $childElem] 0]
                    }
                    
                    if {$startElem != $l2Elem && $startElem != ""} {
                        set childList $startElem
                        set rangeList [ixNet getList $startElem range]
                        
                        if {$childList != "" && $rangeList != ""} {
                            foreach rangeElem $rangeList {
                                if {[info exists ancp_handles_array($rangeElem)] && \
                                        $ancp_handles_array($rangeElem)} {
                                    continue;
                                }
                                set rangeElemFound $rangeElem
                                break;
                            }
                            if {$rangeElemFound != ""} {
                                break;
                            }
                        }
                    }
                }
                if {$rangeElemFound != ""} {
                    break;
                }
            }
            
            if {$rangeElemFound == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "There is no $supported_protocols_msg emulation\
                        created on port $port_handle. Please configure one of\
                        these emulations and then call again ANCP configuration."
                return $returnList
            }
            set range_objrefs $rangeElemFound
        }
        
        if {[regexp "atm" $range_objrefs] && $encap_type == "ETHERNETII"} {
            set encap_type SNAP
        }
    } elseif {$mode == "modify" || $mode == "delete" || $mode == "enable" || $mode == "disable"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode parameter -handle\
                    must be provided."
            return $returnList
        }
        if {![regexp $endpoint_validation_regexp $handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid -handle provided. The -handle\
                    parameter must contain an $supported_protocols_msg endpoint range."
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
                lappend ancp_range_objrefs $handle
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
    array set truth {
        1           true
        0           false
        true        1
        false       0
        enable      true
        disable     false
        enable_all  true
        disable_all false
    }
    
    if {$mode == "enable" || $mode == "disable"} {
        foreach handleElem $handle {
            ixNet setAttribute $handleElem -enabled $truth($mode)
        }
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to $mode ANCP handles $handle."
            return $returnList
        }
    }
    if {$mode == "delete"} {
        foreach handleElem $handle {
            ixNet remove $handleElem
            set rangeElem [ixNetworkGetParentObjref $handleElem range]
            catch {unset ancp_handles_array($rangeElem)}
        }
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to $mode ANCP handles $handle."
            return $returnList
        }
    }
    if {$mode == "enable_all" || $mode == "disable_all"} {
        foreach port [array names ixnetwork_port_handles_array] {
            set l2EthList [ixNet getList $ixnetwork_port_handles_array($port)/protocolStack ethernet]
            set l2AtmList [ixNet getList $ixnetwork_port_handles_array($port)/protocolStack atm]
            set l2List [concat $l2EthList $l2AtmList]
            foreach l2Elem $l2List {
                foreach supported_handle_type $supported_handle_types {
                    set childElems [split $supported_handle_type /]
                    set startElem  $l2Elem
                    foreach childElem $childElems {
                        set startElem [lindex [ixNet getList $startElem $childElem] 0]
                    }
                
                    set supported_handle_type_List [ixNet getList $startElem $supported_handle_type]
                    foreach supported_handle_type_Elem $supported_handle_type_List {
                        set supported_handle_type_RangeList [ixNet getList $supported_handle_type_Elem range]
                        foreach supported_handle_type_RangeElem $supported_handle_type_RangeList {
                            set supported_handle_type_AncpRangeList [ixNet getList $supported_handle_type_RangeElem ancpRange]
                            foreach supported_handle_type_AncpRangeElem $supported_handle_type_AncpRangeList {
                                ixNet setAttribute $supported_handle_type_AncpRangeElem -enabled $truth($mode)
                            }
                        }
                    }
                }
            }
        }
    }
    
    set var_true  true
    set var_false false
    
    array set translate_general {
        VccMuxIPV4Routed                       1
        VccMuxBridgedEthernetFCS               2
        VccMuxBridgedEthernetNoFCS             3
        VccMuxIPV6Routed                       4
        SNAP                                   6
        LLCBridgedEthernetFCS                  7
        LLCBridgedEthernetNoFCS                8
        LLCPPPoA                               9
        VccMuxPPPoA                            10
        ETHERNETII                             ethernet
        every_subnet                           perSubnet
        every_interface                        perInterface
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
    
    array set translate_access_aggregation_dsl_type {
        actual_dsl_subscriber_vlan   true
        custom                       false
    }
    
    set ancpGlobalsParamsMap {
        global_port_down_rate       portDownRate            identity          none
        global_port_up_rate         portUpRate              identity          none
        global_resync_rate          resyncRate              identity          none
    }
    
    set ancpOptionsParamsMap1 {
        port_override_globals       overrideGlobalRate      bool              none
        port_down_rate              portDownRate            identity          none
        port_up_rate                portUpRate              identity          none
        port_resync_rate            resyncRate              identity          none
    }
    
    set ancpOptionsParamsMap2 {
        var_true                    overrideGlobalRate      var_identity      none
        events_per_interval         portDownRate            var_identity      none
        events_per_interval         portUpRate              var_identity      none
        events_per_interval         resyncRate              var_identity      none
    }
    
    set ancpMacRangeParamsMap {
        local_mac_addr              mac                     mac               none
        local_mac_step              incrementBy             mac               none
        local_mtu                   mtu                     identity          none
        device_count                count                   identity          none
    }
    
    set ancpAtmRangeParamsMap {
        local_mac_addr              mac                     mac               none
        local_mac_step              incrementBy             mac               none
        local_mtu                   mtu                     identity          none
        encap_type                  encapsulation           translate         translate_general
    }
    
    set ancpVlanRangeParamsMap {
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
    
    set ancpPvcRangeParamsMap {
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
    
    set ancpIpRangeParamsMap {
        local_mac_addr_auto         autoMacGeneration       bool              none
        gateway_incr_mode           gatewayIncrementMode    translate         translate_general
        gateway_ip_addr             gatewayAddress          identity          none
        gateway_ip_step             gatewayIncrement        identity          none
        intf_ip_addr                ipAddress               identity          none
        intf_ip_step                incrementBy             identity          none
        intf_ip_prefix_len          prefix                  identity          none
        mss                         mss                     identity          none
        device_count                count                   identity          none
    }
    
    set ancpRangeParamsMap {
        keep_alive                              nasKeepAliveTimeout            math        "/ 1000"
        sut_ip_addr                             nasIpAddress                   identity    none
        circuit_id                              circuitId                      identity    none
        distribution_alg_percentage             distributionAlgorithmPercent   identity    none
        access_aggregation                      enableAccessAggregation        bool        none
        sut_service_port                        nasAncpServicePort             identity    none
        keep_alive_retries                      nasKeepAliveRetries            identity    none
    }
    
    if {[string first {nasIPAddressIncr} [ixNet h ::ixNet::OBJ-/vport/protocolStack/ethernet/pppoxEndpoint/range/ancpRange]] != -1} {
        lappend ancpRangeParamsMap sut_ip_step nasIPAddressIncr identity none
    }
    
    # Create and/or modify from here
    if {$mode == "create" || $mode == "modify"} {
        # Set ANCP Options
        if {![info exists events_per_interval]} {
            set ancpMapListName ancpOptionsParamsMap1
        } else {
            set ancpMapListName ancpOptionsParamsMap2
        }
        
        foreach port_objref $port_objrefs {
            set ancp_options_objref [ixNet getList $port_objref/protocolStack ancpOptions]
            if {$ancp_options_objref == ""} {
                set retCode [ixNetworkNodeAdd      \
                        $port_objref/protocolStack \
                        ancpOptions                \
                        {}                         \
                        -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
                set ancp_options_objref [keylget retCode node_objref]
            }
            set ancp_options ""
            foreach {aParam bParam paramType translateType} [set $ancpMapListName] {
                if {![info exists $aParam]} {continue}
                switch $paramType {
                    math {
                        lappend ancp_options -$bParam [expr "[set $aParam] $translateType"]
                    }
                    var_identity {
                        lappend ancp_options -$bParam [set $aParam]
                    }
                    identity {
                        lappend ancp_options -$bParam [set $aParam]
                    }
                    bool {
                        lappend ancp_options -$bParam $truth([set $aParam])
                    }
                    translate {
                        if {![info exists [set translateType]([set $aParam])]} { continue; }
                        lappend ancp_options -$bParam [set [set translateType]([set $aParam])]
                    }
                    default {
                        lappend ancp_options -$bParam [set $aParam]
                    }
                }
            }
            if {$ancp_options != ""} {
                set retCode [ixNetworkNodeSetAttr \
                        $ancp_options_objref      \
                        $ancp_options             \
                        -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
            }
        }
    }
    if {$mode == "create"} {
        # Set ANCP Range
        foreach range_objref $range_objrefs {
            set ancpRangeList [ixNet getList $range_objref ancpRange]
            if {$ancpRangeList == ""} {
                set retCode [ixNetworkNodeAdd \
                        $range_objref         \
                        ancpRange             \
                        {-enabled true}       \
                        -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
                set ancp_range_objref [keylget retCode node_objref]
            } else {
                set ancp_range_objref [lindex $ancpRangeList 0]
            }
            lappend returnAncpRangeList $ancp_range_objref
            lappend ancp_range_objrefs  $ancp_range_objref
            set ancp_handles_array($range_objref) 1
            
            set ancpRangeParamsMapTmp $ancpRangeParamsMap
            
            if {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/ethernet:} $ancp_range_objref]} {
                append ancpRangeParamsMapTmp {
                    access_aggregation_dsl_inner_vlan       innerVlanId                    identity    none
                    access_aggregation_dsl_outer_vlan       outerVlanId                    identity    none
                    access_aggregation_dsl_inner_vlan_type  useDslInnerVlan                translate   translate_access_aggregation_dsl_type
                    access_aggregation_dsl_outer_vlan_type  useDslOuterVlan                translate   translate_access_aggregation_dsl_type
                }
            } else {
                append ancpRangeParamsMapTmp {
                    access_aggregation_dsl_vci              atmVci                         identity    none
                    access_aggregation_dsl_vpi              atmVpi                         identity    none
                    access_aggregation_dsl_vci_type         useDslInnerVlan                translate   translate_access_aggregation_dsl_type
                    access_aggregation_dsl_vpi_type         useDslOuterVlan                translate   translate_access_aggregation_dsl_type
                }
            }
            
            set ancp_range_options ""
            foreach {hltParam ixnParam paramType translateType} $ancpRangeParamsMapTmp {
                if {![info exists $hltParam]} {continue}
                switch $paramType {
                    math {
                        lappend ancp_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                    }
                    var_identity {
                        lappend ancp_range_options -$ixnParam [set $hltParam]
                    }
                    identity {
                        lappend ancp_range_options -$ixnParam [set $hltParam]
                    }
                    bool {
                        lappend ancp_range_options -$ixnParam $truth([set $hltParam])
                    }
                    translate {
                        if {![info exists [set translateType]([set $hltParam])]} { continue; }
                        lappend ancp_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                    }
                    default {
                        lappend ancp_range_options -$ixnParam [set $hltParam]
                    }
                }
            }
            if {$ancp_range_options != ""} {
                lappend ancp_range_options -enabled true
                set retCode [ixNetworkNodeSetAttr \
                        $ancp_range_objref        \
                        $ancp_range_options       \
                        -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
            }
            # Set ANCP Globals
            if {![info exists events_per_interval]} {
                set ancp_global_options ""
                foreach {hltParam ixnParam paramType translateType} $ancpGlobalsParamsMap {
                    if {![info exists $hltParam]} {continue}
                    switch $paramType {
                        identity {
                            lappend ancp_global_options -$ixnParam [set $hltParam]
                        }
                        bool {
                            lappend ancp_global_options -$ixnParam $truth([set $hltParam])
                        }
                        translate {
                            if {![info exists [set translateType]([set $hltParam])]} { continue; }
                            lappend ancp_global_options -$ixnParam [set [set translateType]([set $hltParam])]
                        }
                        default {
                            lappend ancp_global_options -$ixnParam [set $hltParam]
                        }
                    }
                }
                if {$ancp_global_options != ""} {
                    set ancp_globals_objref [lindex \
                            [ixNet getList [ixNet getRoot]globals/protocolStack ancpGlobals] 0]
                    set retCode [ixNetworkNodeSetAttr                        \
                            $ancp_globals_objref                             \
                            $ancp_global_options                             \
                            -commit]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                }
            }
            # Set ANCP DSL Profiles
            if {[info exists dsl_profile_capabilities]} {
                foreach dsl_profile_elem $dsl_profile_capabilities {
                    set ancp_profile_options ""
                    set dsl_profile         [lindex [split $dsl_profile_elem ,] 0]
                    set dsl_profile_percent [lindex [split $dsl_profile_elem ,] 1]
                    if {[regexp {^::ixNet::OBJ-/globals/protocolStack/ancpGlobals/ancpDslProfile:[a-zA-Z0-9\"\-]$} \
                            $dsl_profile dsl_profile_ignore]} {
                        lappend ancp_profile_options -dslProfile $dsl_profile
                        lappend ancp_profile_options -percentage $dsl_profile_percent
                    }
                    if {$ancp_profile_options != ""} {
                        set retCode [ixNetworkNodeAdd     \
                                $ancp_range_objref        \
                                dslProfileAllocationTable \
                                $ancp_profile_options     \
                                -commit                   \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                    }
                }
            }
            # Set ANCP DSL Resyns Profiles
            if {[info exists dsl_resync_profile_capabilities]} {
                foreach dsl_resync_profile_elem $dsl_resync_profile_capabilities {
                    set ancp_resync_profile_options ""
                    set dsl_resync_profile         [lindex [split $dsl_profile_elem ,] 0]
                    set dsl_resync_profile_percent [lindex [split $dsl_profile_elem ,] 1]
                    if {[regexp {^::ixNet::OBJ-/globals/protocolStack/ancpGlobals/ancpDslResyncProfile:[a-zA-Z0-9\"\-]$} \
                            $dsl_resync_profile dsl_resync_profile_ignore]} {
                        lappend ancp_resync_profile_options -dslProfile $dsl_profile
                        lappend ancp_resync_profile_options -percentage $dsl_profile_percent
                    }
                    if {$ancp_resync_profile_options != ""} {
                        set retCode [ixNetworkNodeAdd           \
                                $ancp_range_objref              \
                                dslResyncProfileAllocationTable \
                                $ancp_resync_profile_options    \
                                -commit                         \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                    }
                }
            }
        }
    } elseif {$mode == "modify"} {
        set returnAncpRangeList $ancp_range_objrefs
        # Set ANCP Range
        foreach ancp_range_objref $ancp_range_objrefs {
            
            set ancpRangeParamsMapTmp $ancpRangeParamsMap
            
            if {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/ethernet:} $ancp_range_objref]} {
                append ancpRangeParamsMapTmp {
                    access_aggregation_dsl_inner_vlan       innerVlanId                    identity    none
                    access_aggregation_dsl_outer_vlan       outerVlanId                    identity    none
                    access_aggregation_dsl_inner_vlan_type  useDslInnerVlan                translate   translate_access_aggregation_dsl_type
                    access_aggregation_dsl_outer_vlan_type  useDslOuterVlan                translate   translate_access_aggregation_dsl_type
                }
            } else {
                append ancpRangeParamsMapTmp {
                    access_aggregation_dsl_vci              atmVci                         identity    none
                    access_aggregation_dsl_vpi              atmVpi                         identity    none
                    access_aggregation_dsl_vci_type         useDslInnerVlan                translate   translate_access_aggregation_dsl_type
                    access_aggregation_dsl_vpi_type         useDslOuterVlan                translate   translate_access_aggregation_dsl_type
                }
            }
            
            set ancp_range_options ""
            foreach {hltParam ixnParam paramType translateType} $ancpRangeParamsMapTmp {
                if {![info exists $hltParam]} {continue}
                switch $paramType {
                    math {
                        lappend ancp_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                    }
                    var_identity {
                        lappend ancp_range_options -$ixnParam [set $hltParam]
                    }
                    identity {
                        lappend ancp_range_options -$ixnParam [set $hltParam]
                    }
                    bool {
                        lappend ancp_range_options -$ixnParam $truth([set $hltParam])
                    }
                    translate {
                        if {![info exists [set translateType]([set $hltParam])]} { continue; }
                        lappend ancp_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                    }
                    default {
                        lappend ancp_range_options -$ixnParam [set $hltParam]
                    }
                }
            }
            if {$ancp_range_options != ""} {
                set retCode [ixNetworkNodeSetAttr \
                        $ancp_range_objref        \
                        $ancp_range_options       \
                        -commit                   \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
            }
            
            # Set ANCP Globals
            if {![info exists events_per_interval]} {
                set ancp_global_options ""
                foreach {hltParam ixnParam paramType translateType} $ancpGlobalsParamsMap {
                    if {![info exists $hltParam]} {continue}
                    switch $paramType {
                        identity {
                            lappend ancp_global_options -$ixnParam [set $hltParam]
                        }
                        bool {
                            lappend ancp_global_options -$ixnParam $truth([set $hltParam])
                        }
                        translate {
                            if {![info exists [set translateType]([set $hltParam])]} { continue; }
                            lappend ancp_global_options -$ixnParam [set [set translateType]([set $hltParam])]
                        }
                        default {
                            lappend ancp_global_options -$ixnParam [set $hltParam]
                        }
                    }
                }
                if {$ancp_global_options != ""} {
                    set ancp_globals_objref [lindex \
                            [ixNet getList [ixNet getRoot]globals/protocolStack ancpGlobals] 0]
                    set retCode [ixNetworkNodeSetAttr                        \
                            $ancp_globals_objref                             \
                            $ancp_global_options                             \
                            -commit]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                }
            }
            
            # Set ANCP DSL Profiles
            if {[info exists dsl_profile_capabilities]} {
                set dsl_profile_list [ixNet getList $ancp_range_objref dslProfileAllocationTable]
                foreach dsl_profile_elem $dsl_profile_list {
                    ixNet remove $dsl_profile_elem
                }
                if {[ixNet commit] != "::ixNet::OK"} {
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to remove existing profile\
                                allocation, before adding new allocations."
                        return $returnList
                    }
                }
                foreach dsl_profile_elem $dsl_profile_capabilities {
                    set ancp_profile_options ""
                    set dsl_profile         [lindex [split $dsl_profile_elem ,] 0]
                    set dsl_profile_percent [lindex [split $dsl_profile_elem ,] 1]
                    if {[regexp {^::ixNet::OBJ-/globals/protocolStack/ancpGlobals/ancpDslProfile:[a-zA-Z0-9\"\-]$} \
                            $dsl_profile dsl_profile_ignore]} {
                        lappend ancp_profile_options -dslProfile $dsl_profile
                        lappend ancp_profile_options -percentage $dsl_profile_percent
                    }
                    if {$ancp_profile_options != ""} {
                        set retCode [ixNetworkNodeAdd     \
                                $ancp_range_objref        \
                                dslProfileAllocationTable \
                                $ancp_profile_options     \
                                -commit                   \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                    }
                }
            }
            # Set ANCP DSL Resyns Profiles
            if {[info exists dsl_resync_profile_capabilities]} {
                set dsl_resync_profile_list [ixNet getList $ancp_range_objref dslResyncProfileAllocationTable]
                foreach dsl_resync_profile_elem $dsl_resync_profile_list {
                    ixNet remove $dsl_resync_profile_elem
                }
                if {[ixNet commit] != "::ixNet::OK"} {
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to remove existing resync profile\
                                allocation, before adding new allocations."
                        return $returnList
                    }
                }
                foreach dsl_resync_profile_elem $dsl_resync_profile_capabilities {
                    set ancp_resync_profile_options ""
                    set dsl_resync_profile         [lindex [split $dsl_profile_elem ,] 0]
                    set dsl_resync_profile_percent [lindex [split $dsl_profile_elem ,] 1]
                    if {[regexp {^::ixNet::OBJ-/globals/protocolStack/ancpGlobals/ancpDslResyncProfile:[a-zA-Z0-9\"\-]$} \
                            $dsl_resync_profile dsl_resync_profile_ignore]} {
                        lappend ancp_resync_profile_options -dslProfile $dsl_profile
                        lappend ancp_resync_profile_options -percentage $dsl_profile_percent
                    }
                    if {$ancp_resync_profile_options != ""} {
                        set retCode [ixNetworkNodeAdd           \
                                $ancp_range_objref              \
                                dslResyncProfileAllocationTable \
                                $ancp_resync_profile_options    \
                                -commit                         \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                    }
                }
            }
        }
    }
    if {$mode == "create" || $mode == "modify"} {
        # Set ANCP ATM/MAC Range
        foreach ancp_range_objref $ancp_range_objrefs {
            if {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/ethernet} $ancp_range_objref]} {
                set ancpMacRangeList [ixNet getList $ancp_range_objref ancpMacRange]
                if {$ancpMacRangeList == ""} {
                    set retCode [ixNetworkNodeAdd \
                            $ancp_range_objref    \
                            ancpMacRange          \
                            {-enabled true}       \
                            -commit               \
                            ]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                    set ancp_mac_range_objref [keylget retCode node_objref]
                } else {
                    set ancp_mac_range_objref [lindex $ancpMacRangeList 0]
                }
                set ancp_mac_range_options ""
                foreach {hltParam ixnParam paramType translateType} $ancpMacRangeParamsMap {
                    if {![info exists $hltParam]} {continue}
                    switch $paramType {
                        mac {
                            lappend ancp_mac_range_options -$ixnParam [convertToIxiaMac [set $hltParam] :]
                        }
                        math {
                            lappend ancp_mac_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                        }
                        var_identity {
                            lappend ancp_mac_range_options -$ixnParam [set $hltParam]
                        }
                        identity {
                            lappend ancp_mac_range_options -$ixnParam [set $hltParam]
                        }
                        bool {
                            lappend ancp_mac_range_options -$ixnParam $truth([set $hltParam])
                        }
                        translate {
                            if {![info exists [set translateType]([set $hltParam])]} { continue; }
                            lappend ancp_mac_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                        }
                        default {
                            lappend ancp_mac_range_options -$ixnParam [set $hltParam]
                        }
                    }
                }
                if {$ancp_mac_range_options != ""} {
                    lappend ancp_mac_range_options -enabled true
                    set retCode [ixNetworkNodeSetAttr \
                            $ancp_mac_range_objref    \
                            $ancp_mac_range_options   \
                            -commit                   \
                            ]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                }
            } else {
                set ancpAtmRangeList [ixNet getList $ancp_range_objref ancpAtmRange]
                if {$ancpAtmRangeList == ""} {
                    set retCode [ixNetworkNodeAdd \
                            $ancp_range_objref    \
                            ancpAtmRange          \
                            {-enabled true}       \
                            -commit               \
                            ]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                    set ancp_atm_range_objref [keylget retCode node_objref]
                } else {
                    set ancp_atm_range_objref [lindex $ancpAtmRangeList 0]
                }
                set ancp_atm_range_options ""
                foreach {hltParam ixnParam paramType translateType} $ancpAtmRangeParamsMap {
                    if {![info exists $hltParam]} {continue}
                    switch $paramType {
                        mac {
                            lappend ancp_atm_range_options -$ixnParam [convertToIxiaMac [set $hltParam] :]
                        }
                        math {
                            lappend ancp_atm_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                        }
                        var_identity {
                            lappend ancp_atm_range_options -$ixnParam [set $hltParam]
                        }
                        identity {
                            lappend ancp_atm_range_options -$ixnParam [set $hltParam]
                        }
                        bool {
                            lappend ancp_atm_range_options -$ixnParam $truth([set $hltParam])
                        }
                        translate {
                            if {![info exists [set translateType]([set $hltParam])]} { continue; }
                            lappend ancp_atm_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                        }
                        default {
                            lappend ancp_atm_range_options -$ixnParam [set $hltParam]
                        }
                    }
                }
                if {$ancp_atm_range_options != ""} {
                    lappend ancp_atm_range_options -enabled true
                    set retCode [ixNetworkNodeSetAttr \
                            $ancp_atm_range_objref    \
                            $ancp_atm_range_options   \
                            -commit                   \
                            ]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                }
            }
        }
    }
    # Set VLAN Range
    if {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/ethernet} $ancp_range_objref] &&\
            (([info exists vlan_id] && ($mode == "create")) || ($mode == "modify"))} {
                
        if {$mode == "create"} {
            set vlan true
            if {[info exists vlan_id_inner]} {
                set vlan_inner true
            }
        }
        foreach ancp_range_objref $ancp_range_objrefs {
            set ancpVlanRangeList [ixNet getList $ancp_range_objref ancpVlanRange]
            if {$ancpVlanRangeList == ""} {
                set retCode [ixNetworkNodeAdd \
                        $ancp_range_objref    \
                        ancpVlanRange         \
                        {-enabled true}       \
                        -commit               \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
                set ancp_vlan_range_objref [keylget retCode node_objref]
                # If we add the Vlan Range on mode modify then we need to enable vlans if needed
                if {$mode == "modify"} {
                    set vlan true
                    if {[info exists vlan_id_inner]} {
                        set vlan_inner true
                    }
                }
                
            } else {
                set ancp_vlan_range_objref [lindex $ancpVlanRangeList 0]
            }
            set ancp_vlan_range_options ""
            foreach {hltParam ixnParam paramType translateType} $ancpVlanRangeParamsMap {
                if {![info exists $hltParam]} {continue}
                switch $paramType {
                    math {
                        lappend ancp_vlan_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                    }
                    var_identity {
                        lappend ancp_vlan_range_options -$ixnParam [set $hltParam]
                    }
                    identity {
                        lappend ancp_vlan_range_options -$ixnParam [set $hltParam]
                    }
                    bool {
                        lappend ancp_vlan_range_options -$ixnParam $truth([set $hltParam])
                    }
                    translate {
                        if {![info exists [set translateType]([set $hltParam])]} { continue; }
                        lappend ancp_vlan_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                    }
                    default {
                        lappend ancp_vlan_range_options -$ixnParam [set $hltParam]
                    }
                }
            }
            if {$ancp_vlan_range_options != ""} {
                lappend ancp_vlan_range_options -enabled true
                set retCode [ixNetworkNodeSetAttr  \
                        $ancp_vlan_range_objref    \
                        $ancp_vlan_range_options   \
                        -commit                    \
                        ]

                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
            }
        }
    }
    
    if {($mode == "create" || $mode == "modify")} {
        # Set PVC Range
        foreach ancp_range_objref $ancp_range_objrefs {
            if {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/atm} $ancp_range_objref]} {
                set ancpPvcRangeList [ixNet getList $ancp_range_objref ancpPvcRange]
                if {$ancpPvcRangeList == ""} {
                    set retCode [ixNetworkNodeAdd \
                            $ancp_range_objref    \
                            ancpPvcRange          \
                            {-enabled true}       \
                            -commit               \
                            ]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                    set ancp_pvc_range_objref [keylget retCode node_objref]
                } else {
                    set ancp_pvc_range_objref [lindex $ancpPvcRangeList 0]
                }
                set ancp_pvc_range_options ""
                foreach {hltParam ixnParam paramType translateType} $ancpPvcRangeParamsMap {
                    if {![info exists $hltParam]} {continue}
                    switch $paramType {
                        math {
                            lappend ancp_pvc_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                        }
                        var_identity {
                            lappend ancp_pvc_range_options -$ixnParam [set $hltParam]
                        }
                        identity {
                            lappend ancp_pvc_range_options -$ixnParam [set $hltParam]
                        }
                        bool {
                            lappend ancp_pvc_range_options -$ixnParam $truth([set $hltParam])
                        }
                        translate {
                            if {![info exists [set translateType]([set $hltParam])]} { continue; }
                            lappend ancp_pvc_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                        }
                        default {
                            lappend ancp_pvc_range_options -$ixnParam [set $hltParam]
                        }
                    }
                }
                if {$ancp_pvc_range_options != ""} {
                    lappend ancp_pvc_range_options -enabled true
                    set retCode [ixNetworkNodeSetAttr  \
                            $ancp_pvc_range_objref     \
                            $ancp_pvc_range_options    \
                            -commit                    \
                            ]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                }
            }
            # Set IP Range
            set ancpIpRangeList [ixNet getList $ancp_range_objref ancpIpRange]
            if {$ancpIpRangeList == ""} {
                set retCode [ixNetworkNodeAdd \
                        $ancp_range_objref    \
                        ancpIpRange           \
                        {-enabled true}       \
                        -commit               \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
                set ancp_ip_range_objref [keylget retCode node_objref]
            } else {
                set ancp_ip_range_objref [lindex $ancpIpRangeList 0]
            }
            set ancp_ip_range_options ""
            foreach {hltParam ixnParam paramType translateType} $ancpIpRangeParamsMap {
                if {![info exists $hltParam]} {continue}
                switch $paramType {
                    math {
                        lappend ancp_ip_range_options -$ixnParam [expr "[set $hltParam] $translateType"]
                    }
                    var_identity {
                        lappend ancp_ip_range_options -$ixnParam [set $hltParam]
                    }
                    identity {
                        lappend ancp_ip_range_options -$ixnParam [set $hltParam]
                    }
                    bool {
                        lappend ancp_ip_range_options -$ixnParam $truth([set $hltParam])
                    }
                    translate {
                        if {![info exists [set translateType]([set $hltParam])]} { continue; }
                        lappend ancp_ip_range_options -$ixnParam [set [set translateType]([set $hltParam])]
                    }
                    default {
                        lappend ancp_ip_range_options -$ixnParam [set $hltParam]
                    }
                }
            }
            if {$ancp_ip_range_options != ""} {
                lappend ancp_ip_range_options -enabled true
                set retCode [ixNetworkNodeSetAttr \
                        $ancp_ip_range_objref     \
                        $ancp_ip_range_options    \
                        -commit                   \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
            }
            
            if {[info exists local_mac_addr_auto] && ($local_mac_addr_auto == 0) && [info exists local_mac_addr]} {
                if {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/ethernet} $ancp_range_objref]} {
                    set ancpMacRangeList [ixNet getList $ancp_range_objref ancpMacRange]
                    if {$ancpMacRangeList == ""} {
                        set retCode [ixNetworkNodeAdd \
                                $ancp_range_objref    \
                                ancpMacRange          \
                                {-enabled true}       \
                                -commit               \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                        set ancp_mac_range_objref [keylget retCode node_objref]
                    } else {
                        set ancp_mac_range_objref [lindex $ancpMacRangeList 0]
                    }
                    ixNet setAttribute $ancp_mac_range_objref -mac [convertToIxiaMac $local_mac_addr :]
                } else {
                    set ancpAtmRangeList [ixNet getList $ancp_range_objref ancpAtmRange]
                    if {$ancpAtmRangeList == ""} {
                        set retCode [ixNetworkNodeAdd \
                                $ancp_range_objref    \
                                ancpAtmRange          \
                                {-enabled true}       \
                                -commit               \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                        set ancp_atm_range_objref [keylget retCode node_objref]
                    } else {
                        set ancp_atm_range_objref [lindex $ancpAtmRangeList 0]
                    }
                    ixNet setAttribute $ancp_atm_range_objref -mac [convertToIxiaMac $local_mac_addr :]
                }
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList handle $returnAncpRangeList
    return $returnList
}

proc ::ixia::ixnetwork_ancp_profile_config { args opt_args} {
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    array set translate_code {
        access_loop_remote_id 2
        2 2 
        access_aggregation_circuit_id_ascii 3
        3 3 
        actual_net_data_upstream 129
        129 129 
        actual_net_data_rate_downstream 130
        130 130 
        minimum_net_data_rate_upstream 131
        131 131 
        minimum_net_data_rate_downstream 132
        132 132 
        attainable_net_data_rate_upstream 133
        133 133 
        attainable_net_data_rate_downstream 134
        134 134 
        maximum_net_data_rate_upstream 135
        135 135 
        maximum_net_data_rate_downstream 136
        136 136 
        minimum_net_low_power_data_rate_upstream 137
        137 137 
        minimum_net_low_power_data_rate_downstream 138
        138 138 
        maximum_interleaving_delay_upstream 139
        139 139 
        actual_interleaving_delay_upstream 140
        140 140 
        maximum_interleaving_delay_downstream 141
        141 141 
        actual_interleaving_delay_downstream 142
        142 142 
        access_loop_encapsulation 144
        144 144 
        dsl_type 145
        145 145 
    }
    
    array set translate_description {
        2 "Access Loop Remote ID"
        3 "Access Aggregation Circuit ID Ascii"
        129 "Actual Net Data Upstream [kbps]"
        130 "Actual Net Data Rate Downstream [kbps]"
        131 "Minimum Net Data Rate Upstream [kbps]"
        132 "Minimum Net Data Rate Downstream [kbps]"
        133 "Attainable Net Data Rate Upstream [kbps]"
        134 "Attainable Net Data Rate Downstream [kbps]"
        135 "Maximum Net Data Rate Upstream [kbps]"
        136 "Maximum Net Data Rate Downstream [kbps]"
        137 "Minimum Net Low Power Data Rate Upstream [kbps]"
        138 "Minimum Net Low Power Data Rate Downstream [kbps]" 
        139 "Maximum Interleaving Delay Upstream [ms]"
        140 "Actual Interleaving Delay Upstream [ms]"
        141 "Maximum Interleaving Delay Downstream [ms]"
        142 "Actual Interleaving Delay Downstream [ms]"
        144 "Access Loop Encapsulation"
        145 "DSL Type" 
    }
    
    set translate_dsl_profile_value {
        ADSL1       1
        ADSL2       2
        ADSL2+      3
        VDSL1       4
        VDSL2       5
        SDSL        6
        UNKNOWN     7
    }
    
    array set translate {
        dsl_profile,profile        ancpDslProfile
        dsl_profile,tlv            ancpDslTlv
        dsl_profile,map            regularProfileParamsMap
        dsl_resync_profile,profile ancpDslResyncProfile
        dsl_resync_profile,tlv     ancpDslResyncTlv
        dsl_resync_profile,map     resyncProfileParamsMap
        
    }
    
    set regularProfileParamsMap {
        code              code    translate
        description       name    translate
        dsl_profile_value value   translate_dsl_profile_value
    }
    
    set resyncProfileParamsMap {
        code                            code          translate
        dsl_resync_profile_first_value  firstValue    identity
        dsl_resync_profile_last_value   lastValue     identity
        dsl_resync_profile_mode         mode          translate
        dsl_resync_profile_step         stepValue     identity
    }
    
    if {$mode == "delete"} {
        foreach handle_elem $handle {
            ixNet remove $handle_elem
        }
        if {[set retCode [ixNet commit]] != "::ixNet::OK" } {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to remove profile(s) $handle. $retCode."
            return $returnList
        }
    }
    
    if {$mode == "get_default_profile"} {
        if {[info exists type]} {
            set types $type
        } else {
            set types {dsl_profile dsl_resync_profile}
        }
        foreach type_elem $types {
            set ancp_globals_objref [lindex \
                        [ixNet getList [ixNet getRoot]globals/protocolStack ancpGlobals] 0]
            set default_profile_list [ixNet getList \
                    $ancp_globals_objref            \
                    $translate($type_elem,profile)  ]
            foreach default_profile $default_profile_list {
                if {[string compare -nocase \
                        [ixNet getAttribute $default_profile -name] \
                        "DefaultProfile"] } {
                    if {[catch {keylget returnList handle} retCode]} {
                        keylset returnList handle $default_profile
                    } else {
                        keylset returnList handle [concat $default_profile $retCode]
                    }
                    set default_tlv_list [ixNet getList     \
                            $default_profile                \
                            $translate($type_elem,tlv)      ]
                    foreach default_tlv $default_tlv_list {
                        if {[catch {keylget returnList $default_profile tlvs} retCode]} {
                            keylset returnList $default_profile.tlvs $default_tlv
                        } else {
                            keylset returnList $default_profile.tlvs [concat $default_tlv $retCode]
                        }
                        foreach {hltParam ixnParam paramType} [set $translate($type,map)] {
                            keylset returnList $default_profile.$default_tlv.$hltParam \
                                    [ixNet getAttribute $default_tlv -$ixnParam]
                        }
                    }
                }
            }
        }
    }
    
    
    if {$mode == "create"} {
        set profile 0
        
        if {[info exists code]} {
            set description ""
            foreach code_elem $code {
                lappend description $translate_code($code_elem)
            }
        }
        for {set i 0} {$i < $tlv_count} {incr i} {
            set dsl_tlv_options ""
            foreach {hltParam ixnParam paramType} [set $translate($type,map)] {
                set translate_name translate_$hltParam
                if {[info exists $hltParam]} {
                    if {[llength [set $hltParam]] < $tlv_count} {
                        set append_string [string repeat \
                                "[lindex [set $hltParam] end] " [expr $tlv_count - [llength [set $hltParam]]]]
                        set $hltParam "[set $hltParam] $append_string"
                    }
                    switch $paramType {
                        identity {
                            lappend dsl_tlv_options -$ixnParam [lindex [set $hltParam] $i]
                        }
                        translate {
                            if {![info exists [set translate_name]([lindex [set $hltParam] $i])] && ($hltParam == "code")} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid code [lindex [set $hltParam] $i]."
                                return $returnList
                            }
                            if {![info exists [set translate_name]([lindex [set $hltParam] $i])]} {continue;}
                            lappend dsl_tlv_options -$ixnParam [set [set translate_name]([lindex [set $hltParam] $i])]
                        }
                        translate_dsl_profile_value {
                            if {[string is integer [lindex [set $hltParam] $i]]} {
                                lappend dsl_tlv_options -$ixnParam [lindex [set $hltParam] $i]
                            } elseif {[info exists [set translate_name]([lindex [set $hltParam] $i])]} {
                                lappend dsl_tlv_options -$ixnParam [set [set translate_name]([lindex [set $hltParam] $i])]
                            }
                        }
                        default {
                            lappend dsl_tlv_options -$ixnParam [lindex [set $hltParam] $i]
                        }
                    }
                }
            }
            if {$dsl_tlv_options != ""} {
                # Profile
                if {$profile == 0} {
                    set ancp_globals_list [ixNet getList [ixNet getRoot]globals/protocolStack ancpGlobals]
                    if {$ancp_globals_list == ""} {
                        set retCode [ixNetworkNodeAdd                            \
                                [ixNet getRoot]globals/protocolStack             \
                                ancpGlobals                                      \
                                {}                                               \
                                -commit                                          \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                        set ancp_globals_objref [keylget retCode node_objref]
                    } else {
                        set ancp_globals_objref [lindex $ancp_globals_list 0]
                    }
                    
                    set retCode [ixNetworkNodeAdd                            \
                            $ancp_globals_objref                             \
                            $translate($type,profile)                        \
                            {}                                               \
                            -commit                                          \
                            ]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                    set ancp_profile_objref [keylget retCode node_objref]
                    
                    keylset returnList handle $ancp_profile_objref
                    incr profile
                }
                # TLV
                set retCode [ixNetworkNodeAdd                            \
                        $ancp_profile_objref                             \
                        $translate($type,tlv)                            \
                        $dsl_tlv_options                                 \
                        -commit                                          \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
                set ancp_tlv_objref [keylget retCode node_objref]
                if {[catch {keylget returnList $ancp_profile_objref.tlvs} existing_tlvs]} {
                    keylset returnList $ancp_profile_objref.tlvs $ancp_tlv_objref
                } else {
                    keylset returnList $ancp_profile_objref.tlvs [concat $existing_tlvs $ancp_tlv_objref ]
                }
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_ancp_control { args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
        
    set supported_handle_types {
        ipEndpoint
        pppoxEndpoint
        dhcpEndpoint
        dhcpoPppClientEndpoint
        dhcpoPppServerEndpoint
        dhcpoLacEndpoint
        dhcpoLnsEndpoint
        l2tpEndpoint
    }
    
    set stack_type_list { ethernet atm }
    
    set supported_handle_types_paths {
        ipEndpoint
        pppoxEndpoint
        dhcpEndpoint
        pppox/dhcpoPppClientEndpoint
        pppox/dhcpoPppServerEndpoint
        ip/l2tp/dhcpoLacEndpoint
        ip/l2tp/dhcpoLnsEndpoint
        ip/l2tpEndpoint
    }
    
    if {![info exists ancp_handle]} {
        set ancp_handle {}
        # get all ancp ranges from all supported stacks
        foreach vport_objref [ixNetworkGetList [ixNet getRoot] vport] {
            foreach smt $stack_type_list {
                set l2List [ixNet getList $vport_objref/protocolStack $smt]
                if {[llength $l2List] == 0} {
                    continue
                }
                foreach supported_handle_type $supported_handle_types_paths {
                    set childElems [split $supported_handle_type /]
                    set startElem  [lindex $l2List 0]
                    foreach childElem $childElems {
                        set startElem [lindex [ixNet getList $startElem $childElem] 0]
                        if {[llength $startElem] == 0} {
                            break
                        }
                    }
                    if {[llength $startElem] == 0} {
                        continue
                    }
                    if {$startElem != [lindex $l2List 0]} {
                        if {![catch {ixNetworkGetList $startElem ancp} ancph] &&\
                                [llength $ancph] > 0} {
                            set rangeList [ixNet getList $startElem range]
                            foreach range $rangeList {
                                set ancp_range [ixNet getList $range ancpRange]
                                lappend ancp_handle $ancp_range
                            }
                        }
                    }
                }
            }
        }
    }
    
    if {[llength $ancp_handle] > 0} {
        foreach handle $ancp_handle {
            if {[info exists action]} {
                if {[ixNet exists $handle] == "false" || [ixNet exists $handle] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid or incorect -handle."
                    return $returnList
                }
                switch -- $action {
                    enable {
                        if [catch {ixNet setAttribute $handle -enabled true} status] {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to $action ANCP handle\
                                    $handle. $status"
                            return $returnList
                        }
                        if {[set status [ixNet commit]] != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to $action ANCP handle\
                                    $handle (commit). $status"
                            return $returnList
                        }
                    }
                    disable {
                        if [catch {ixNet setAttribute $handle -enabled false} status] {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to $action ANCP handle\
                                    $handle. $status"
                            return $returnList
                        }
                        if {[set status [ixNet commit]] != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to $action ANCP handle\
                                    $handle (commit). $status"
                            return $returnList
                        }
                    }
                    default {
                        keylset returnList log "Option $action for\
                                -action is not supported."
                    }
                }
            }
            array set action_control_map {
                decoupled_start             start
                decoupled_stop              stop
                bring_up_dsl_subscribers    ancpBringUpDslSubscribers
                tear_down_dsl_subscribers   ancpTeardownDslSubscribers
                start_adjacency             ancpStartAdjacency
                stop_adjacency              ancpStopAdjacency
                abort                       abort
                stop                        stop
            }
            if {[lsearch {decoupled_start decoupled_stop
                    bring_up_dsl_subscribers tear_down_dsl_subscribers
                    start_adjacency stop_adjacency
                    } $action_control] != -1} {
                if {[ixNet exists $handle] == "false" || [ixNet exists $handle] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid or incorect -handle."
                    return $returnList
                }
                if {$handle == [ixNet getNull]} {continue}
                switch -- $action_control {
                    decoupled_start {
                        if [catch {ixNetworkExec [list $action_control_map($action_control) $handle $action_control_type]} status] {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to $action_control ANCP.\
                                    $status"
                            return $returnList
                        }
                    }
                    bring_up_dsl_subscribers -
                    tear_down_dsl_subscribers -
                    start_adjacency - 
                    stop_adjacency -
                    decoupled_stop {
                        if [catch {ixNet exec $action_control_map($action_control) $handle $action_control_type} status] {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to $action_control ANCP.\
                                    $status"
                            return $returnList
                        }
                    }
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Option $action_control for\
                                -action_control is not supported."
                        return $returnList
                    }
                }
            } elseif {$action_control == "start_resync"} {
                if {[ixNet exists $handle] == "false" || [ixNet exists $handle] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid or incorect -handle."
                    return $returnList
                }
                switch $interval_unit {
                    millisecond {
                        set interval [expr int(ceil($interval/1000.0))]
                    }
                    microsecond {
                        set interval [expr int(ceil($interval/1000000.0))]
                    }
                    default {}
                }
                if [catch {ixNetworkExec [list ancpStartResync $handle $iteration_count $interval  $action_control_type]} status] {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action_control ANCP.\
                            $status"
                    return $returnList
                }
            } else {
                if {![regexp {^\d+/\d+/\d+$} $handle] && ([ixNet exists $handle] == "false" || [ixNet exists $handle] == 0)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid or incorect -handle."
                    return $returnList
                }
            
                set parent_handles {}
                if {[regexp {^\d+/\d+/\d+$} $handle]} {
                
                    set ret_val [::ixia::ixNetworkGetPortObjref $handle]
                    if {[keylget ret_val status] == $::SUCCESS} {
                        set vport_objref [keylget ret_val vport_objref]
                        
                        # get all ancp ranges from all supported stacks
                        foreach smt $stack_type_list {
                            set l2List [ixNet getList $vport_objref/protocolStack $smt]
                            if {[llength $l2List] == 0} {
                                continue
                            }
                            foreach supported_handle_type_p $supported_handle_types_paths supported_handle_type $supported_handle_types {
                                set childElems [split $supported_handle_type_p /]
                                set startElem  [lindex $l2List 0]
                                foreach childElem $childElems {
                                    set startElem [lindex [ixNet getList $startElem $childElem] 0]
                                    if {[llength $startElem] == 0} {
                                        break
                                    }
                                }
                                if {[llength $startElem] == 0} {
                                    continue
                                }
                                if {$startElem != [lindex $l2List 0]} {
                                    if {![catch {ixNetworkGetList $startElem ancp} ancph] &&\
                                            [llength $ancph] > 0} {
                                        set rangeList [ixNet getList $startElem range]
                                        foreach range $rangeList {
                                            set ancp_range [ixNet getList $range ancpRange]
                                            set parent_handle [ixNetworkGetParentObjref $ancp_range $supported_handle_type]
                                            lappend parent_handles $parent_handle
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    set null_parent_handles 0
                    foreach supported_handle_type $supported_handle_types {
                        set parent_handle [ixNetworkGetParentObjref $handle $supported_handle_type]
                        lappend parent_handles [ixNetworkGetParentObjref $handle $supported_handle_type]
                        if {$parent_handle == [ixNet getNull]} {
                            incr null_parent_handles
                        }
                    }
                    if {[llength $parent_handles] == $null_parent_handles } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to $action_control ANCP.\
                                There is no $supported_protocols_msg endpoint available."
                        return $returnList
                    }
                }
                
                
                foreach parent_handle $parent_handles {
                    if {$parent_handle == [ixNet getNull]} {continue}
                    switch -- $action_control {
                        start {
                            if [catch {ixNetworkExec [list start $parent_handle $action_control_type]} status] {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to $action_control ANCP.\
                                        $status"
                                return $returnList
                            }
                        }
                        stop -
                        abort {
                            debug "ixNet exec $action_control_map($action_control) $parent_handle $action_control_type"
                            if [catch {ixNet exec $action_control_map($action_control) $parent_handle $action_control_type} status] {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to $action_control ANCP.\
                                        $status"
                                return $returnList
                            }
                        }
                        default {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Option $action_control for\
                                    -action_control is not supported."
                            return $returnList
                        }
                    }
                }
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_ancp_stats { args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "One of the parameters\
                -port_handle or -handle must be provided."
        return $returnList
    }
    
    if {![info exists port_handle]} {
        set port_handles ""
        foreach handleElem $handle {
            set retCode [ixNetworkGetPortFromObj $handleElem]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            lappend port_handles [keylget retCode port_handle]
        }
    } else {
        set port_handles $port_handle
    }
    
    if {[info exists reset]} {
        if {[set retCode [catch {ixNet exec clearStats} retCode]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to clear statistics."
            return $returnList
        }
    }
    
    set portIndex 0
    foreach port_handle $port_handles {
        set result [ixNetworkGetPortObjref $port_handle]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the port \
                    object reference associated to the $port_handle port handle -\
                    [keylget result log]."
            return $returnList
        }
        set port_objref [keylget result vport_objref]
        
        # ANCP Adjacency Statistics
        array set stats_array_adjacency {
            "ANs Established"
            {ancp_adjacency.ans_established adj_estab_count}
            "ANCP Adjacency Packets Sent"
            {ancp_adjacency.tx.pkts         tx_total_pkts}
            "ANCP Adjacency Packets Received"
            {ancp_adjacency.rx.pkts         rx_total_pkts}
            "ANCP Adjacency Bytes Sent"
            {ancp_adjacency.tx.bytes        {} }
            "ANCP Adjacency Bytes Received"
            {ancp_adjacency.rx.bytes        {} }
            "ANCP Adjacency SYN Sent"
            {ancp_adjacency.tx.syn          tx_adj_ack_pkts}
            "ANCP Adjacency SYN Received"
            {ancp_adjacency.rx.syn          rx_adj_ack_pkts}
            "ANCP Adjacency ACK Sent"
            {ancp_adjacency.tx.ack          tx_adj_ack_pkts}
            "ANCP Adjacency ACK Received"
            {ancp_adjacency.rx.ack          rx_adj_ack_pkts}
            "ANCP Adjacency SYNACK Sent"
            {ancp_adjacency.tx.synack       tx_adj_syn_ack_pkts}
            "ANCP Adjacency SYNACK Received"
            {ancp_adjacency.rx.synack       rx_adj_syn_ack_pkts}
            "ANCP Adjacency RSTACK Sent"
            {ancp_adjacency.tx.rstack       tx_adj_rst_ack_pkts}
            "ANCP Adjacency RSTACK Received"
            {ancp_adjacency.rx.rstack       rx_adj_rst_ack_pkts}
        }
        array set stats_array_general {
			"Port Name"
            {ancp_general.port_name         {} }
            "DSL Lines Up"
            {ancp_general.dsl_lines_up      {} }
            "ANs Established"
            {ancp_general.ans_established   {} }
            "ANCP Packets Sent"
            {ancp_general.tx.pkts           {} }
            "ANCP Packets Received"
            {ancp_general.rx.pkts           {} }
            "ANCP Bytes Sent"
            {ancp_general.tx.bytes          {} }
            "ANCP Bytes  Received"
            {ancp_general.rx.bytes          {} }
        }
        array set stats_array_event {
            "DSL Lines Up"
            {ancp_port_event.dsl_lines_up   {} }
            "ANCP Port-Up Sent"
            {ancp_port_event.tx.port_up     {} }
            "ANCP Port-Down Sent"
            {ancp_port_event.tx.port_down   {} }
            "ANCP Ev Packets Sent"
            {ancp_port_event.tx.event_pkts  {} }
            "ANCP Ev Bytes Sent"
            {ancp_port_event.tx.event_bytes {} }
        }
                   
        set statistic_types {
            adjacency         "ANCP Adjacency"
            general           "ANCP General"
            event             "ANCP Port-Event"
        }
        
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
                            if {$portIndex == 0 && ([lindex $stats_array($stat) 1] != "")} {
                                keylset returnList [lindex $stats_array($stat) 1] \
                                        $rows_array($i,$stat)
                            }
                            keylset returnList ${port_handle}.[lindex $stats_array($stat) 0] \
                                    $rows_array($i,$stat)
                        } else {
                            if {$portIndex == 0 && ([lindex $stats_array($stat) 1] != "")} {
                                keylset returnList [lindex $stats_array($stat) 1] "N/A"
                            }
                            keylset returnList ${port_handle}.[lindex $stats_array($stat) 0] "N/A"
                        }
                    }
                    break
                }
            }
            if {!$found} {
                keylset returnList status $::FAILURE
                keylset returnList log "The '$port_handle' port couldn't be\
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

proc ::ixia::ixnetwork_ancp_subscriber_lines_config { args man_args opt_args } {

    variable ancp_profile_handles_array
    variable handles_state_evidence_array
    variable handles_state_evidence_resynch_array
        
    if {[catch {::ixia::parse_dashed_args -args $args \
            -mandatory_args $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {$mode == "enable_all" || $mode == "disable_all"} {
        set fail 0
        if {[info exists ancp_client_handle]} {
            foreach cl_handle $ancp_client_handle {
                if {![regexp {ancp} $ancp_client_handle] || [ixNet exists [lindex $cl_handle 0]] == "false" || [ixNet exists [lindex $cl_handle 0]] == 0} {
                    set fail 1
                }
            }
        }
        if {![info exists ancp_client_handle] || $fail == 1} {
            
            keylset returnList status $::FAILURE
            keylset returnList log "Parameter ancp_client_handle was not passed or it's not\
                    a valid ANCP Client handle returned by ::ixia::emulation_ancp_config."
            return $returnList
        }
    } elseif { $mode != "create" } {
        
        set num_replaces [regsub -all {\\\"} $handle {} handle_ignore]
        
        if {$num_replaces == 0} {
            regsub -all {\"} $handle {\\"} handle
        }
        
        # "
        
        if {![info exists handle] || ([info exists handle] && ![info exists ancp_profile_handles_array($handle)])} {
            
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, parameter -handle is mandatory.\
                    This parameter is currently missing or it's not an AN Subscriber Line \
                    returned by ::ixia::emulation_ancp_subscriber_lines_config."
            return $returnList
        }
        
        if {$mode == "enable" || $mode == "disable"} {
            if {![info exists handle] || ![info exists ancp_client_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode, parameters -handle and \
                        -ancp_client_handle are mandatory."
                return $returnList
            }
        }
    } elseif { $mode == "create" } {
        
        if {[info exists ancp_client_handle]} {
            set fail 0
            foreach cl_handle $ancp_client_handle {
                if {[ixNet exists [lindex $cl_handle 0]] == "false" || [ixNet exists [lindex $cl_handle 0]] == 0} {
                    set fail 1
                }
            }
            
            if {(![regexp {ancp} $ancp_client_handle] \
                || $fail == 1)} {
                
                keylset returnList status $::FAILURE
                keylset returnList log "Parameter ancp_client_handle is not \
                        a valid ANCP Client handle returned by ::ixia::emulation_ancp_config."
                return $returnList
            }
        }
    }
    
    array set translate_encap {
        na                          0x000000
        untagged_ethernet           0x000100
        single_tagged_ethernet      0x000200
        pppoa_llc                   0x000001
        pppoa_null                  0x000002
        ipoa_llc                    0x000003
        ipoa_null                   0x000004
        aal5_llc_w_fcs              0x000005
        aal5_llc_wo_fcs             0x000006
        aal5_null_w_fcs             0x000007
        aal5_null_wo_fcs            0x000008
    }

    array set translate_description {
        2   "Access Loop Remote ID"
        3   "Access Aggregation Circuit ID Ascii"
        129 "Actual Net Data Upstream [kbps]"
        130 "Actual Net Data Rate Downstream [kbps]"
        131 "Minimum Net Data Rate Upstream [kbps]"
        132 "Minimum Net Data Rate Downstream [kbps]"
        133 "Attainable Net Data Rate Upstream [kbps]"
        134 "Attainable Net Data Rate Downstream [kbps]"
        135 "Maximum Net Data Rate Upstream [kbps]"
        136 "Maximum Net Data Rate Downstream [kbps]"
        137 "Minimum Net Low Power Data Rate Upstream [kbps]"
        138 "Minimum Net Low Power Data Rate Downstream [kbps]" 
        139 "Maximum Interleaving Delay Upstream [ms]"
        140 "Actual Interleaving Delay Upstream [ms]"
        141 "Maximum Interleaving Delay Downstream [ms]"
        142 "Actual Interleaving Delay Downstream [ms]"
        144 "Access Loop Encapsulation"
        145 "DSL Type" 
    }
    
    array set translate_dsl_profile_value {
        adsl1       1
        adsl2       2
        adsl2_plus  3
        vdsl1       4
        vdsl2       5
        sdsl        6
        unknown     7
    }
    
    set tlv_enable_list [list                                                                \
            remote_id                           ena_remote_id                           2    \
            actual_rate_upstream                ena_actual_rate_upstream                129  \
            actual_rate_downstream              ena_actual_rate_downstream              130  \
            upstream_min_rate                   ena_upstream_min_rate                   131  \
            downstream_min_rate                 ena_downstream_min_rate                 132  \
            upstream_attainable_rate            ena_upstream_attainable_rate            133  \
            downstream_attainable_rate          ena_downstream_attainable_rate          134  \
            upstream_max_rate                   ena_upstream_max_rate                   135  \
            downstream_max_rate                 ena_downstream_max_rate                 136  \
            upstream_min_low_power_rate         ena_upstream_min_low_power_rate         137  \
            downstream_min_low_power_rate       ena_downstream_min_low_power_rate       138  \
            upstream_max_interleaving_delay     ena_upstream_max_interleaving_delay     139  \
            upstream_act_interleaving_delay     ena_upstream_act_interleaving_delay     140  \
            downstream_max_interleaving_delay   ena_downstream_max_interleaving_delay   141  \
            downstream_act_interleaving_delay   ena_downstream_act_interleaving_delay   142  \
            include_encap                       ena_include_encap                       144  \
            dsl_type                            ena_dsl_type                            145  \
        ]

    switch -- $mode {
        create {
            # Configure circuit id on ancp_client_handle
            if {[info exists circuit_id]} {
                # ancp_client_handle is mandatory here
                set fail 0
                if {[info exists ancp_client_handle]} {
                    foreach cl_handle $ancp_client_handle {
                        if {![regexp {ancp} $cl_handle] || [ixNet exists [lindex $cl_handle 0]] == "false" || [ixNet exists [lindex $cl_handle 0]] == 0} {
                            set fail 1
                        }
                    }
                }
                if {![info exists ancp_client_handle] || $fail == 1} {
                    
                    keylset returnList status $::FAILURE
                    keylset returnList log "Parameter ancp_client_handle was not passed or it's not\
                            a valid ANCP Client handle returned by ::ixia::emulation_ancp_config."
                    return $returnList
                }
                
                set ancp_client_handle_ll [llength $ancp_client_handle]
                if {($ancp_client_handle_ll != [llength $circuit_id]) ||
                    ([info exists circuit_id_suffix_step] && $ancp_client_handle_ll != [llength $circuit_id_suffix_step]) || 
                    ([info exists circuit_id_suffix] && $ancp_client_handle_ll != [llength $circuit_id_suffix]) || 
                    ([info exists circuit_id_suffix_repeat] && $ancp_client_handle_ll != [llength $circuit_id_suffix_repeat])} {
                   
                    keylset returnList status $::FAILURE
                    keylset returnList log "The following list paremeters need to have the same number of elements: ancp_client_handle, circuit_id_suffix, circuit_id_suffix_step, circuit_id_suffix_repeat"
                    return $returnList
                }
                
                for {set i 0} {$i < $ancp_client_handle_ll} {incr i} {
                    set cl_handle [lindex [lindex $ancp_client_handle $i] 0]
                    set circuit_id_value [lindex $circuit_id $i]
                    
                    if {[info exists circuit_id_suffix]} {
                        set circuit_id_suffix_el [lindex $circuit_id_suffix $i]
                        if {![info exists circuit_id_suffix_step]} {
                            set circuit_id_suffix_step_el 1
                        } else {
                            set circuit_id_suffix_step_el [lindex $circuit_id_suffix_step $i]
                        }

                        if {![info exists circuit_id_suffix_repeat]} {
                            set circuit_id_suffix_repeat_el 1
                        } else {
                            set circuit_id_suffix_repeat_el [lindex $circuit_id_suffix_repeat $i]
                        }
                        
                        append circuit_id_value "%${circuit_id_suffix_el}:${circuit_id_suffix_step_el}:${circuit_id_suffix_repeat_el}i"
                    }
                    
                    # Configure circuit id
                
                    set retCode [ixNetworkNodeSetAttr                        \
                            $cl_handle                                       \
                            [list -circuitId $circuit_id_value]              \
                            -commit                                          \
                            ]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                }
            }
            
            set max_length 1
            # compute max_length first
            foreach {tlv_param ena_param tlv_code} $tlv_enable_list {
                foreach tlv_inner_param $tlv_param {
                    if {[info exists $tlv_inner_param] && ![is_default_param_value $tlv_inner_param $args]} {
                        if {[llength [set $tlv_inner_param]] > $max_length} {
                            set max_length [llength [set $tlv_inner_param]]
                        }
                    }
                }
            }
            foreach {tlv_param ena_param tlv_code} $tlv_enable_list {
                foreach tlv_inner_param $tlv_param {
                    if {[info exists $tlv_inner_param] && ![is_default_param_value $tlv_inner_param $args]} {

                        set $ena_param 1
                        
                        if {[llength [set $tlv_inner_param]] > 1} {
                            # We're dealing with a list option
                            if {$max_length > 1} {
                                if {[llength [set $tlv_inner_param]] != $max_length} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "When parameters are configured with\
                                            lists of values, all parameters must have the same\
                                            length of values or just one value (that will be used multiple times)."
                                    return $returnList
                                }
                            }
                        }
                        if {[info exists ${tlv_inner_param}_min_value]} {
                            if {[llength [set ${tlv_inner_param}_min_value]] > 1} {
                                # We're dealing with a list option
                                if {$max_length > 1} {
                                    if {[llength [set ${tlv_inner_param}_min_value]] != $max_length} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "When parameters are configured with\
                                                lists of values, all parameters must have the same\
                                                length of values or just one value (that will be used multiple times)."
                                        return $returnList
                                    }
                                }
                            }
                        }
                    } else {
                        set $ena_param 0
                    }
                }
            }
            
            set dsl_handle_list ""
            set dsl_resync_handle_list ""
            set ret_handles ""
            
            for {set i 0} {$i < $max_length} {incr i} {
                
                set ancp_array_match_string ""
                
                if {$i == 0} {
                    debug "ixNet getList [ixNet getRoot]globals/protocolStack ancpGlobals"
                    set ancp_globals_list [ixNet getList [ixNet getRoot]globals/protocolStack ancpGlobals]
                    if {$ancp_globals_list == ""} {
                        set retCode [ixNetworkNodeAdd                            \
                                [ixNet getRoot]globals/protocolStack             \
                                ancpGlobals                                      \
                                {}                                               \
                                -commit                                          \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                        set ancp_globals_objref [keylget retCode node_objref]
                    } else {
                        set ancp_globals_objref [lindex $ancp_globals_list 0]
                    }
                    
                    # Remove default sync and resync profiles necessary for bug BUG517925
                    foreach dslProfile [ixNet getList $ancp_globals_objref ancpDslProfile] {
                        if {[llength $dslProfile] > 0} {
                            if {[regexp {DefaultProfile} [ixNet getA $dslProfile -name]]} {
                                if {[catch {ixNet remove $dslProfile} err] || $err != "::ixNet::OK"} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to remove default profile $dslProfile. $err"
                                    return $returnList
                                }
                            }
                        }
                    }
                    foreach dslResyncProfile [ixNet getList $ancp_globals_objref ancpDslResyncProfile] {
                        if {[llength $dslResyncProfile] > 0} {
                            if {[regexp {DefaultResyncProfile} [ixNet getA $dslResyncProfile -name]]} {
                                if {[catch {ixNet remove $dslResyncProfile} err] || $err != "::ixNet::OK"} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to remove default resync profile $dslResyncProfile. $err"
                                    return $returnList
                                }
                            }
                        }
                    }
                }
                
                set dsl_handle          "null"
                set dsl_resync_handle   "null"
                if { $profile_type == "both" || $profile_type == "dsl_sync" } {
                    # Add a DSL profile
                    set retCode [ixNetworkNodeAdd                            \
                            $ancp_globals_objref                             \
                            "ancpDslProfile"                                 \
                            {}                                               \
                            -commit                                          \
                            ]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                    set dsl_handle [keylget retCode node_objref]
                    lappend dsl_handle_list $dsl_handle
                }
                
                if { $profile_type == "both" || $profile_type == "dsl_resync" } {
                    # Add a DSL Resync profile
                    set retCode [ixNetworkNodeAdd                            \
                            $ancp_globals_objref                             \
                            "ancpDslResyncProfile"                           \
                            {}                                               \
                            -commit                                          \
                            ]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log " [keylget retCode log]"
                        return $returnList
                    }
                    set dsl_resync_handle [keylget retCode node_objref]
                    lappend dsl_resync_handle_list $dsl_resync_handle
                }
                
                foreach {tlv_param ena_param tlv_code} $tlv_enable_list {
                    
                    set tlv_arg_list ""
                    set tlv_arg_list_resync ""
                    
                    if {[info exists $ena_param] && [set $ena_param] == 1} {
                        
                        if {$tlv_param == "dsl_type"} {
                            if {[llength [set $tlv_param]] > 1} {
                                set tlv_param_value $translate_dsl_profile_value([lindex [set $tlv_param] $i])
                            } else {
                                set tlv_param_value $translate_dsl_profile_value([set $tlv_param])
                            }
                        } elseif {$tlv_param == "include_encap"} {
                            
                            set tlv_param_value 0x000000
                            
                            # compute actual encapsulation using data_link encap1 and encap2
                            if {[llength $data_link] > 1} {
                                set data_link_val [lindex $data_link $i]
                            } else {
                                set data_link_val $data_link
                            }
                            if {$data_link_val == "ethernet"} {
                                set tlv_param_value [expr $tlv_param_value | 0x010000]
                            }
                            
                            if {[info exists encap1]} {
                                
                                if {[llength $encap1] > 1} {
                                    set encap1_val [lindex $encap1 $i]
                                } else {
                                    set encap1_val $encap1
                                }
                                
                                set tlv_param_value [expr $tlv_param_value | $translate_encap($encap1_val)]
                            }
                            
                            if {[info exists encap2]} {
                            
                                if {[llength $encap2] > 1} {
                                    set encap2_val [lindex $encap2 $i]
                                } else {
                                    set encap2_val $encap2
                                }
                                
                                set tlv_param_value [expr $tlv_param_value | $translate_encap($encap2_val)]
                            }

                        } else {
                            
                            if {[llength [set $tlv_param]] > 1} {
                                set tlv_param_value [lindex [set $tlv_param] $i]
                            } else {
                                set tlv_param_value [set $tlv_param]
                            }
                            if {[info exists ${tlv_param}_min_value]} {
                                if {[llength [set ${tlv_param}_min_value]] > 1} {
                                    set tlv_param_value_min [lindex [set ${tlv_param}_min_value] $i]
                                } else {
                                    set tlv_param_value_min [set ${tlv_param}_min_value]
                                }
                            } else {
                                set tlv_param_value_min $tlv_param_value
                            }
                        }
                        
                        append ancp_array_match_string "$tlv_param_value,"
                        append ancp_array_match_string "$tlv_param_value_min,"
                        
                        # Add DSL Profile TLV
                        append tlv_arg_list "-code $tlv_code"
                        append tlv_arg_list " -value $tlv_param_value"
                        lappend tlv_arg_list -name $translate_description($tlv_code)
                        
                        if { $profile_type == "both" || $profile_type == "dsl_sync" } {
                            set retCode [ixNetworkNodeAdd                            \
                                    $dsl_handle                                      \
                                    "ancpDslTlv"                                     \
                                    $tlv_arg_list                                    \
                                    ]
                            if {[keylget retCode status] != $::SUCCESS} {
                                keylset returnList status $::FAILURE
                                keylset returnList log " [keylget retCode log]"
                                return $returnList
                            }
                        }
                        
                        # Add DSL Resync Profile TLV
                        append tlv_arg_list_resync "-code $tlv_code"
                        append tlv_arg_list_resync " -firstValue $tlv_param_value_min"
                        append tlv_arg_list_resync " -lastValue  $tlv_param_value"
                        lappend tlv_arg_list_resync -name $translate_description($tlv_code)
                        
                        if {$tlv_param == "actual_rate_upstream" || $tlv_param == "actual_rate_downstream"} {
                            
                            set step_name ${tlv_param}_step
                            if {[info exists $step_name] && ![is_default_param_value $step_name $args]} {
                                
                                set last_value_name ${tlv_param}_end
                                if {[info exists $last_value_name] && ![is_default_param_value $last_value_name $args]} {
                                    if {[llength [set $last_value_name]] > 1} {
                                        # if it gets here, the -lastValue param will appear twice
                                        # this is not a problem due to the fact that only the last param is taken into consideration
                                        append tlv_arg_list_resync " -lastValue [lindex [set $last_value_name] $i]"
                                        append ancp_array_match_string "[lindex [set $last_value_name] $i],"
                                    } else {
                                        append tlv_arg_list_resync " -lastValue [set $last_value_name]"
                                        append ancp_array_match_string "[set $last_value_name],"
                                    }   
                                } else {
                                    append ancp_array_match_string "na,"
                                }
                                
                                append tlv_arg_list_resync " -mode trend"
                                
                                if {[llength [set $step_name]] > 1} {
                                    append tlv_arg_list_resync " -stepValue [lindex [set $step_name] $i]"
                                    append ancp_array_match_string "[lindex [set $step_name] $i],"
                                } else {
                                    append tlv_arg_list_resync " -stepValue [set $step_name]"
                                    append ancp_array_match_string "[set $step_name],"
                                }
                                
                            } else {
                                append ancp_array_match_string "na,na,"
                            }
                        }
                        
                        switch -- $tlv_code {
                            2 -
                            3 -
                            144 -
                            145 {
                                # these tlvs are not valid for resync.
                                # don't configure them
                            }
                            default {
                                if { $profile_type == "both" || $profile_type == "dsl_resync" } {
                                    set retCode [ixNetworkNodeAdd                            \
                                            $dsl_resync_handle                               \
                                            "ancpDslResyncTlv"                               \
                                            $tlv_arg_list_resync                             \
                                            ]
                                    if {[keylget retCode status] != $::SUCCESS} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log " [keylget retCode log]"
                                        return $returnList
                                    }
                                }
                            }
                        }
                    } else {
                        append ancp_array_match_string "na,"
                    }
                }
                
                if {[string index $ancp_array_match_string end] == ","} {
                    set ancp_array_match_string [string replace $ancp_array_match_string end end]
                }
                if {[info exists ancp_profile_handles_array($ancp_array_match_string)]} {
                    # Rollback uncommited objects
                    debug "ixNet rollback"
                    if {[ixNet rollback] != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to rollback TLV uncommited objects.\
                                Uncommited TLV objects are deleted because an identical profile\
                                has already been configured."
                        return $returnList
                    }
                    
                    # Remove dsl and dsl resync objects from ixnetwork and from lists
                    if { $profile_type == "both" || $profile_type == "dsl_sync" } {
                        set handle_to_remove [lindex $dsl_handle_list end]
                        debug "a ixNet remove $handle_to_remove"
                        if {[ixNet remove $handle_to_remove] != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to remove $handle_to_remove.\
                                    Uncommited objects are deleted because an identical profile\
                                    has already been configured."
                            return $returnList
                        }
                        set dsl_handle_list [lreplace $dsl_handle_list end end]
                        lappend dsl_handle_list [lindex $ancp_profile_handles_array($ancp_array_match_string) 0]
                    }
                    
                    if { $profile_type == "both" || $profile_type == "dsl_resync" } {
                        set handle_to_remove [lindex $dsl_resync_handle_list end]
                        debug "b ixNet remove $handle_to_remove"
                        if {[ixNet remove $handle_to_remove] != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to remove $handle_to_remove.\
                                    Uncommited objects are deleted because an identical profile\
                                    has already been configured."
                            return $returnList
                        }
                        set dsl_resync_handle_list [lreplace $dsl_resync_handle_list end end]
                        lappend dsl_resync_handle_list [lindex $ancp_profile_handles_array($ancp_array_match_string) 1]
                    }
                    
                } else {
                    if { $profile_type == "both" || $profile_type == "dsl_sync" } {
                        set retCode [ixNetworkNodeSetAttr                            \
                                $dsl_handle                             \
                                [list -name $ancp_array_match_string]                                               \
                                -commit                                          \
                            ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                    }
                    if { $profile_type == "both" || $profile_type == "dsl_resync" } {
                        set retCode [ixNetworkNodeSetAttr                            \
                                $dsl_resync_handle                             \
                                [list -name "${ancp_array_match_string},resync"]                                               \
                                -commit                                          \
                            ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                    }
                    
#                     debug "ixNet commit"
#                     if {[catch {ixNet commit} err]} {
#                         keylset returnList status $::FAILURE
#                         keylset returnList log "Failed to configure profiles. $err"
#                         return $returnList
#                     }
                    
                    ancp_handles_array_add $ancp_array_match_string $dsl_handle $dsl_resync_handle

                }
            }
            
            lappend ret_handles $dsl_handle_list
            
            # if ancp_client_handle was set, continue attaching profiles
            if { [info exists ancp_client_handle] } {
                # Attach DSL profiles and DSL Resync profiles to protocol objects
                set ancp_client_handle_ll [llength $ancp_client_handle] 
                for {set i 0} {$i < $ancp_client_handle_ll} {incr i} {
                    set cl_handle [lindex [lindex $ancp_client_handle $i] 0]
                    array set dsl_profile_used_list ""
                    debug "ixNet getList $cl_handle dslProfileAllocationTable"
                    set dsl_profile_allocation_list [ixNet getList $cl_handle dslProfileAllocationTable]
                    foreach dsl_profile_allocation $dsl_profile_allocation_list {
                        set dsl_profile_used_list([ixNet getA $dsl_profile_allocation -dslProfile]) $dsl_profile_allocation
                    }
                    
                    set idx 0
                    foreach single_dsl_profile $dsl_handle_list {
                        
                        if {[llength $percentage] > 1} {
                            # if $percentage is a list, it's made of $ancp_client_handle_ll groups of dsl_handle_list length
                            # eg, [x1 x2 x3 y1 y2 y3], 2 ancp client handles, with 3 dsl profiles each
                            set percent_val [lindex $percentage [expr $i*[llength $dsl_handle_list]+$idx]]
                        } else {
                            set percent_val $percentage
                        }
                        
                        if {![info exists dsl_profile_used_list($single_dsl_profile)]} {
                            set retCode [ixNetworkNodeAdd                            \
                                    $cl_handle                               \
                                    "dslProfileAllocationTable"                      \
                                    [list -dslProfile $single_dsl_profile -percentage $percent_val]           \
                                    -commit]
                            if {[keylget retCode status] != $::SUCCESS} {
                                keylset returnList status $::FAILURE
                                keylset returnList log " [keylget retCode log]"
                                return $returnList
                            }
                        }
                        incr idx
                        
                        # Add the current profile to the state evidence array...
                        set handles_state_evidence_array($single_dsl_profile,$cl_handle,[keylget retCode node_objref]) [list $percent_val 1]
                        
                    }
                
                
                
                    array set resync_used_list ""
                    debug "ixNet getList $cl_handle dslResyncProfileAllocationTable"
                    set dsl_profile_resync_allocation_list [ixNet getList $cl_handle dslResyncProfileAllocationTable]
                    foreach dsl_profile_allocation $dsl_profile_resync_allocation_list {
                        debug "ixNet getA $dsl_profile_allocation -dslProfile"
                        set resync_used_list([ixNet getA $dsl_profile_allocation -dslProfile]) $dsl_profile_allocation
                    }
                    
                    set idx 0
                    foreach single_dsl_profile $dsl_resync_handle_list {
                        
                        if {[llength $percentage] > 1} {
                            set percent_val [lindex $percentage [expr $i*[llength $dsl_handle_list]+$idx]]
                        } else {
                            set percent_val $percentage
                        }
                    
                        if {![info exists resync_used_list($single_dsl_profile)]} {
                            set retCode [ixNetworkNodeAdd                            \
                                    $cl_handle                              \
                                    "dslResyncProfileAllocationTable"                \
                                    [list -dslProfile $single_dsl_profile -percentage $percent_val]           \
                                    -commit]
                            if {[keylget retCode status] != $::SUCCESS} {
                                keylset returnList status $::FAILURE
                                keylset returnList log " [keylget retCode log]"
                                return $returnList
                            }
                        }
                        
                        incr idx

                        # Add the current profile to the state evidence array...               
                        set handles_state_evidence_resynch_array($single_dsl_profile,$cl_handle,[keylget retCode node_objref]) [list $percent_val 1]
                        
                    }
                    
                    set cln_up_h [ancp_subscribers_cleanup $cl_handle]
                    if {[keylget cln_up_h status] != $::SUCCESS} {
                        return $cln_up_h
                    }
                }
            }
            
            keylset returnList handle $ret_handles
        }
        modify {
            
            set arr_idx_old       $ancp_profile_handles_array($handle)
            set dsl_handle        [lindex $ancp_profile_handles_array($arr_idx_old) 0]
            set dsl_resync_handle [lindex $ancp_profile_handles_array($arr_idx_old) 1]
            
            if {$dsl_handle != "null"} {
                set profile_type "dsl_sync"
                if {$dsl_resync_handle != "null"} {
                    set profile_type "both"
                }
            } else {
                set profile_type "dsl_resync"
            }
            
            # Remove all TLVs from this handle
            set tlv_list ""
            if {$profile_type == "both" || $profile_type == "dsl_sync"} {
                debug "ixNet getList $dsl_handle ancpDslTlv"
                lappend tlv_list [ixNet getList $dsl_handle ancpDslTlv]
            }
            
            if {$profile_type == "both" || $profile_type == "dsl_resync"} {
                debug "ixNet getList $dsl_resync_handle ancpDslResyncTlv"
                lappend tlv_list [ixNet getList $dsl_resync_handle ancpDslResyncTlv]
            }
            
            foreach tlv_object [join $tlv_list] {
                if {[llength $tlv_object] > 0} {
                    debug "ixNet remove $tlv_object"
                    if {[catch {ixNet remove $tlv_object} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to remove TLV object $tlv_object.\
                                All TLVs from object $handle are removed because procedure\
                                emulation_ancp_subscriber_lines_config procedure was called\
                                with mode 'modify'. This removes all TLVs objects from the\
                                $handle handle and creates new ones using the parameters provided."
                        return $returnList
                    }
                }
            }
            
            debug "ixNet commit"
            if {[catch {ixNet commit} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to remove TLV objects.\
                        All TLVs from object $handle are removed because procedure\
                        emulation_ancp_subscriber_lines_config procedure was called\
                        with mode 'modify'. This removes all TLVs objects from the\
                        $handle handle and creates new ones using the parameters provided."
                return $returnList
            }
            
            foreach {tlv_param ena_param tlv_code} $tlv_enable_list {
                foreach tlv_inner_param $tlv_param {
                    if {[info exists $tlv_inner_param] && ![is_default_param_value $tlv_inner_param $args]} {
                        
                        set $ena_param 1
                        
                        if {[llength [set $tlv_inner_param]] > 1} {
                            # We're dealing with a list option
                            
                            keylset returnList status $::FAILURE
                            keylset returnList log "When -mode is $mode parameters values\
                                    must be single values (not lists)."
                            return $returnList

                        }
                        if {[info exists ${tlv_inner_param}_min_value]} {
                            if {[llength [set ${tlv_inner_param}_min_value]] > 1} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "When -mode is $mode parameters values\
                                        must be single values (not lists)."
                                return $returnList
                            }
                        }
                        
                    } else {
                        set $ena_param 0
                    }
                }
            }
            
            debug "ixNet getList [ixNet getRoot]globals/protocolStack ancpGlobals"
            set ancp_globals_list [ixNet getList [ixNet getRoot]globals/protocolStack ancpGlobals]
            if {$ancp_globals_list == ""} {
                set retCode [ixNetworkNodeAdd                            \
                        [ixNet getRoot]globals/protocolStack             \
                        ancpGlobals                                      \
                        {}                                               \
                        -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
                set ancp_globals_objref [keylget retCode node_objref]
            } else {
                set ancp_globals_objref [lindex $ancp_globals_list 0]
            }
            
            set arr_idx_old $ancp_profile_handles_array($handle)
            set dsl_handle [lindex $ancp_profile_handles_array($arr_idx_old) 0]
            set dsl_resync_handle [lindex $ancp_profile_handles_array($arr_idx_old) 1]
            
            set ancp_array_match_string ""
            
            foreach {tlv_param ena_param tlv_code} $tlv_enable_list {
                
                set tlv_arg_list ""
                set tlv_arg_list_resync ""

                if {[info exists $ena_param] && [set $ena_param] == 1} {

                    if {$tlv_param == "dsl_type"} {
                    
                        set tlv_param_value $translate_dsl_profile_value([set $tlv_param])

                    } elseif {$tlv_param == "include_encap"} {
                        
                        set tlv_param_value 0x000000
                        
                        # compute actual encapsulation using data_link encap1 and encap2
                        
                        set data_link_val $data_link

                        if {$data_link_val == "ethernet"} {
                            set tlv_param_value [expr $tlv_param_value | 0x010000]
                        }
                        
                        if {[info exists encap1]} {
                            
                            set encap1_val $encap1
                            
                            set tlv_param_value [expr $tlv_param_value | $translate_encap($encap1_val)]
                        
                        }
                        
                        if {[info exists encap2]} {
                        
                            set encap2_val $encap2
                            
                            set tlv_param_value [expr $tlv_param_value | $translate_encap($encap2_val)]
                        }

                    } else {
                        set tlv_param_value [set $tlv_param]
                        
                        if {[info exists ${tlv_param}_min_value]} {
                            set tlv_param_value_min [set ${tlv_param}_min_value]
                        } else {
                            set tlv_param_value_min $tlv_param_value
                        }
                    }
                    
                    append ancp_array_match_string "$tlv_param_value,"
                    append ancp_array_match_string "$tlv_param_value_min,"
                    
                    # Add DSL Profile TLV
                    append tlv_arg_list "-code $tlv_code"
                    append tlv_arg_list " -value $tlv_param_value"
                    lappend tlv_arg_list -name $translate_description($tlv_code)
                    
                    if { $profile_type == "both" || $profile_type == "dsl_sync" } {
                        set retCode [ixNetworkNodeAdd                            \
                                $dsl_handle                                      \
                                "ancpDslTlv"                                     \
                                $tlv_arg_list                                    \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log " [keylget retCode log]"
                            return $returnList
                        }
                    }
                    
                    # Add DSL Resync Profile TLV
                    append tlv_arg_list_resync "-code $tlv_code"
                    append tlv_arg_list_resync " -firstValue $tlv_param_value_min"
                    append tlv_arg_list_resync " -lastValue  $tlv_param_value"
                    lappend tlv_arg_list_resync -name $translate_description($tlv_code)
                    
                    if {$tlv_param == "actual_rate_upstream" || $tlv_param == "actual_rate_downstream"} {
                        set step_name ${tlv_param}_step
                        if {[info exists $step_name] && ![is_default_param_value $step_name $args]} {
                            
                            set last_value_name ${tlv_param}_end
                            if {[info exists $last_value_name] && ![is_default_param_value $last_value_name $args]} {
                             
                                append tlv_arg_list_resync " -lastValue [set $last_value_name]"
                                append ancp_array_match_string "[set $last_value_name],"

                            } else {
                                append ancp_array_match_string "na,"
                            }
                            
                            append tlv_arg_list_resync " -mode trend"
                            append tlv_arg_list_resync " -stepValue [set $step_name]"
                            append ancp_array_match_string "[set $step_name],"
                        } else {
                            append ancp_array_match_string "na,na,"
                        }
                    }
                    
                    switch -- $tlv_code {
                        2 -
                        3 -
                        144 -
                        145 {
                            # these tlvs are not valid for resync.
                            # don't configure them
                        }
                        default {
                            if { $profile_type == "both" || $profile_type == "dsl_resync" } {
                                set retCode [ixNetworkNodeAdd                            \
                                        $dsl_resync_handle                               \
                                        "ancpDslResyncTlv"                               \
                                        $tlv_arg_list_resync                             \
                                        ]
                                if {[keylget retCode status] != $::SUCCESS} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log " [keylget retCode log]"
                                    return $returnList
                                }
                            }
                        }
                    }
                } else {
                    append ancp_array_match_string "na,"
                }
            }
            
            if {[string index $ancp_array_match_string end] == ","} {
                set ancp_array_match_string [string replace $ancp_array_match_string end end]
            }
            
            debug "ixNet commit"
            if {[catch {ixNet commit} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure profiles. $err"
                return $returnList
            }
            
            ancp_handles_array_update $arr_idx_old $ancp_array_match_string
        
        }
        delete {
            set tmp_arr_idx $ancp_profile_handles_array($handle)

            foreach handle_item $ancp_profile_handles_array($tmp_arr_idx) {
                debug "ixNet remove $handle_item"
                if {[catch {ixNet remove $handle_item} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to remove object $handle_item. $err."
                    return $returnList
                }
            }
            
            debug "ixNet commit"
            if {[catch {ixNet commit} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to remove objects $ancp_profile_handles_array($tmp_arr_idx). $err."
                return $returnList
            }
            
            ancp_handles_array_remove_by_idx $tmp_arr_idx
            
            # Look for all matching dsl profiles and delete them
            foreach complete_key [array names handles_state_evidence_array] {
                set key_match [lindex [split $complete_key ","] 0]
                if { $key_match == $handle } {
                    if {[catch {unset handles_state_evidence_array($complete_key)} err]} {
                        debug "Failed to unset handles_state_evidence_array($complete_key) -->> $err"
                    } 
                }
            }
            foreach complete_key [array names handles_state_evidence_resynch_array] {
                set key_match [lindex [split $complete_key ","] 0]
                if { $key_match == $handle } {
                    if {[catch {unset handles_state_evidence_resynch_array($complete_key)} err]} {
                        debug "Failed to unset handles_state_evidence_resynch_array($complete_key) -->> $err"
                    } 
                }
            }
        }
        enable {
            
            set commit_flag 0
            
            # Add the profile handle from $handle to the subscriber handle from ancp_client_handle
            set tmp_arr_idx $ancp_profile_handles_array($handle)
            set dsl_profile [lindex $ancp_profile_handles_array($tmp_arr_idx) 0]
            set dsl_profile_resync [lindex $ancp_profile_handles_array($tmp_arr_idx) 1]
            
            array set dsl_profile_used_list ""
            if {[llength $ancp_client_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ancp_client_handle should have only one element"
                return $returnList
            }
            debug "ixNet getList $ancp_client_handle dslProfileAllocationTable"
            set dsl_profile_allocation_list [ixNet getList $ancp_client_handle dslProfileAllocationTable]
            foreach dsl_profile_allocation $dsl_profile_allocation_list {
                debug "ixNet getA $dsl_profile_allocation -dslProfile"
                set dsl_profile_used_list([ixNet getA $dsl_profile_allocation -dslProfile]) $dsl_profile_allocation
            }

            if {![info exists dsl_profile_used_list($dsl_profile)]} {
                
                set commit_flag 1
                
                set retCode [ixNetworkNodeAdd                            \
                        $ancp_client_handle                               \
                        "dslProfileAllocationTable"                      \
                        [list -dslProfile $dsl_profile]           \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }

                set new_table [keylget retCode node_objref]
                enable_in_state_evidence $dsl_profile $ancp_client_handle $new_table                
            }
            
            
            array set resync_used_list ""
            debug "ixNet getList $ancp_client_handle dslResyncProfileAllocationTable"
            set dsl_profile_resync_allocation_list [ixNet getList $ancp_client_handle dslResyncProfileAllocationTable]
            foreach dsl_profile_allocation $dsl_profile_resync_allocation_list {
                debug "ixNet getA $dsl_profile_allocation -dslProfile"
                set resync_used_list([ixNet getA $dsl_profile_allocation -dslProfile]) $dsl_profile_allocation
            }
            
            if {![info exists resync_used_list($dsl_profile_resync)]} {
                
                set commit_flag 1
                                
                set retCode [ixNetworkNodeAdd                            \
                        $ancp_client_handle                              \
                        "dslResyncProfileAllocationTable"                \
                        [list -dslProfile $dsl_profile_resync]           \
                        ]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log " [keylget retCode log]"
                    return $returnList
                }
                
                set new_table [keylget retCode node_objref]
                enable_in_state_evidence_resynch $dsl_profile_resync $ancp_client_handle $new_table  
            }
            
            if {$commit_flag} {
                debug "ixNet commit"
                if {[catch {ixNet commit} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to enable profile. $err."
                    return $returnList
                }
            }
            
        }
        disable {

            set commit_flag 0        
            # Add the profile handle from $handle to the subscriber handle from ancp_client_handle
            set tmp_arr_idx $ancp_profile_handles_array($handle)
            set dsl_profile [lindex $ancp_profile_handles_array($tmp_arr_idx) 0]
            set dsl_profile_resync [lindex $ancp_profile_handles_array($tmp_arr_idx) 1]

            array set dsl_profile_used_list ""
            if {[llength $ancp_client_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ancp_client_handle should have only one element"
                return $returnList
            }
            debug "ixNet getList $ancp_client_handle dslProfileAllocationTable"
            set dsl_profile_allocation_list [ixNet getList $ancp_client_handle dslProfileAllocationTable]
            foreach dsl_profile_allocation $dsl_profile_allocation_list {
                debug "ixNet getA $dsl_profile_allocation -dslProfile"
                set dsl_profile_used_list([ixNet getA $dsl_profile_allocation -dslProfile]) $dsl_profile_allocation
            }

            set dsl_profile_not_clean $dsl_profile
            set dsl_profile [regsub -all {\\"} $dsl_profile \"]
            
            if {[info exists dsl_profile_used_list($dsl_profile)]} {
                set commit_flag 1
                
                debug "ixNet remove $dsl_profile_used_list($dsl_profile)"
                if {[catch {ixNet remove $dsl_profile_used_list($dsl_profile)}]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to disable $dsl_profile from $dsl_profile_used_list($dsl_profile)"
                    return $returnList
                }
                
                disable_in_state_evidence $dsl_profile_not_clean $ancp_client_handle
            }
   
            array set resync_used_list ""

            debug "ixNet getList $ancp_client_handle dslResyncProfileAllocationTable"
            set dsl_profile_resync_allocation_list [ixNet getList $ancp_client_handle dslResyncProfileAllocationTable]
            foreach dsl_profile_allocation $dsl_profile_resync_allocation_list {
                debug "ixNet getA $dsl_profile_allocation -dslProfile"
                set resync_used_list([ixNet getA $dsl_profile_allocation -dslProfile]) $dsl_profile_allocation
            }
            
            if {[info exists resync_used_list($dsl_profile_resync)]} {
                
                set commit_flag 1
                
                debug "ixNet remove $resync_used_list($dsl_profile_resync)"
                if {[catch {ixNet remove $resync_used_list($dsl_profile_resync)}]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to disable $dsl_profile_resync from $resync_used_list($dsl_profile_resync)"
                    return $returnList
                }
                
                disable_in_state_evidence_resynch $dsl_profile_resync $ancp_client_handle
            }
            
            if {$commit_flag} {
                debug "ixNet commit"
                if {[catch {ixNet commit} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to disable profile. $err."
                    return $returnList
                }
            }
        }
        enable_all {
            
            set commit_flag 0
            
            debug "ixNet getList [ixNet getRoot]globals/protocolStack ancpGlobals"
            set ancp_globals_list [ixNet getList [ixNet getRoot]globals/protocolStack ancpGlobals]
            if {$ancp_globals_list != ""} {
                
                debug "ixNet getList $ancp_globals_list ancpDslProfile"
                set all_dsl_profiles [ixNet getList $ancp_globals_list ancpDslProfile]
                
                debug "ixNet getList $ancp_globals_list ancpDslResyncProfile"
                set all_resync_profiles [ixNet getList $ancp_globals_list ancpDslResyncProfile]
            
                array set dsl_profile_used_list ""
                if {[llength $ancp_client_handle] > 1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ancp_client_handle should have only one element"
                    return $returnList
                }
                debug "ixNet getList $ancp_client_handle dslProfileAllocationTable"
                set dsl_profile_allocation_list [ixNet getList $ancp_client_handle dslProfileAllocationTable]
                foreach dsl_profile_allocation $dsl_profile_allocation_list {
                    debug "ixNet getA $dsl_profile_allocation -dslProfile"
                    set dsl_profile_used_list([ixNet getA $dsl_profile_allocation -dslProfile]) $dsl_profile_allocation
                }
                
                foreach dsl_single_profile $all_dsl_profiles {
                    if {![info exists dsl_profile_used_list($dsl_single_profile)]} {
                        # add it
                        set parent_obj $ancp_client_handle
                        set retCode [ixNetworkNodeAdd                     \
                                $parent_obj                               \
                                "dslProfileAllocationTable"               \
                                [list -dslProfile $dsl_single_profile]    \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "[keylget retCode log]"
                            return $returnList
                        }
                
                        set commit_flag 1

                        set new_table [keylget retCode node_objref]
                        enable_in_state_evidence $dsl_single_profile $ancp_client_handle $new_table 
                    }
                }
                
                array set resync_used_list ""
                debug "ixNet getList $ancp_client_handle dslResyncProfileAllocationTable"
                set dsl_profile_resync_allocation_list [ixNet getList $ancp_client_handle dslResyncProfileAllocationTable]
                foreach dsl_profile_allocation $dsl_profile_resync_allocation_list {
                    debug "ixNet getA $dsl_profile_allocation -dslProfile"
                    set resync_used_list([ixNet getA $dsl_profile_allocation -dslProfile]) $dsl_profile_allocation
                }
                
                foreach resync_single_profile $all_resync_profiles {
                    if {![info exists resync_used_list($resync_single_profile)]} {
                        # add it
                        set parent_obj $ancp_client_handle
                        set retCode [ixNetworkNodeAdd                     \
                                $parent_obj                               \
                                "dslResyncProfileAllocationTable"         \
                                [list -dslProfile $resync_single_profile] \
                                ]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "[keylget retCode log]"
                            return $returnList
                        }
                        
                        set commit_flag 1
                        
                        set new_table [keylget retCode node_objref]
                        enable_in_state_evidence_resynch $resync_single_profile $ancp_client_handle $new_table 
                    }
                }
                
                if {$commit_flag} {
                    debug "ixNet commit"
                    if {[catch {ixNet commit} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to enable all profiles. $err."
                        return $returnList
                    }
                }
                
            }
        }
        disable_all {
            
            set commit_flag 0
            
            debug "ixNet getList $ancp_client_handle dslProfileAllocationTable"
            debug "ixNet getList $ancp_client_handle dslResyncProfileAllocationTable"
            if {[llength $ancp_client_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ancp_client_handle should have only one element"
                return $returnList
            }
            foreach dsl_profile [ixNet getList $ancp_client_handle dslProfileAllocationTable] \
                    dsl_resync_profile [ixNet getList $ancp_client_handle dslResyncProfileAllocationTable] {
                
                foreach profile_handle [list $dsl_profile $dsl_resync_profile] {
                    debug "ixNet remove $profile_handle"
                    if {[catch {ixNet remove $profile_handle}]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to disable $profile_handle from $ancp_client_handle"
                        return $returnList
                    }
                    
                    set commit_flag 1
                }
                disable_in_state_evidence $dsl_profile $ancp_client_handle
                disable_in_state_evidence_resynch $dsl_resync_profile $ancp_client_handle
            }
            
            if {$commit_flag} {
                debug "ixNet commit"
                if {[catch {ixNet commit} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to disable all profiles. $err."
                    return $returnList
                }
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}



proc ::ixia::emulation_ancp_profile_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle  \{::ixia::emulation_ancp_profile_config $args\}]
        
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
    set opt_args {
        -code                           ANY
        -dsl_profile_value              ANY   
        -dsl_resync_profile_first_value NUMERIC 
                                        DEFAULT   1
        -dsl_resync_profile_last_value  NUMERIC 
                                        DEFAULT   1000
        -dsl_resync_profile_mode        CHOICES   random trend
                                        DEFAULT   random
        -dsl_resync_profile_step        NUMERIC   
                                        DEFAULT   10
        -handle                         ANY       
        -mode                           CHOICES   create delete
                                        DEFAULT   create
        -type                           CHOICES   dsl_profile dsl_resync_profile
                                        DEFAULT   dsl_profile
        -tlv_count                      NUMERIC
                                        DEFAULT 1
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ancp_profile_config $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_ancp_profile_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "ANCP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    
    return $returnList
}
