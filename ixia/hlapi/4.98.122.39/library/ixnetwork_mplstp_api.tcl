proc ::ixia::ixnetwork_mplstp_config { args man_args opt_args } {
    set procName [lindex [info level [info level]] 0]
    
    debug "$procName $args"

    variable objectMaxCount
    set objectCount 0
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -mandatory_args $man_args \
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
    
    # param checks here
    if {[llength $router_id] > 1 && [llength $router_id] != $router_count} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: -router_id list must have same length as -router_count parameter."
        return $returnList
    }
    if {[info exists interface_count] && $interface_count > 0 && $router_count > 1} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Creating multiple routers with multiple interfaces is not currently supported."
        return $returnList
    }
    if {[info exists interface_count] && (![info exists interface_handle] || [llength $interface_handle] != $interface_count)} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: -interface_handle list must have same length as -interface_count parameter."
        return $returnList
    }
    if {[info exists interface_count] && $interface_count > 0 && ![info exists dut_mac_addr]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: When -interface_count exists, parameter -dut_mac_addr is mandatory."
        return $returnList
    }
    if {[info exists handle] && 
            (![regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+$} $handle] &&
             ![regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+/interface:\d+$} $handle])
    } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Invalid form for parameter -handle. Only MPLS-TP routers and interfaces accepted."
        return $returnList
    }
    
    if {$mode == "modify" && [regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+/interface:\d+$} $handle] &&
        ((![info exists dut_mac_addr] && ![info exist interface_handle]) ||
        ([llength $dut_mac_addr] > 1 || [llength $interface_handle] > 1))
    } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: When mode is modify, -dut_mac_addr and -interface_handle must exist and have a single element"
        return $returnList
    }
    
    array set mplstpProtocolOptionsArray {
        apsChannelType                  aps_channel_type
        bfdCcChannelType                bfdcc_channel_type
        delayManagementChannelType      delay_management_channel_type
        enableHighPerformanceMode       high_performance_mode_enable
        faultManagementChannelType      fault_management_channel_type
        lossMeasurementChannelType      loss_measurement_channel_type
        onDemandCvChannelType           ondemand_cv_channel_type
        pwStatusChannelType             pw_status_channel_type
        y1731ChannelType                y1731_channel_type
    }
    
    switch -- $mode {
        "create" {
            if {![info exists port_handle] && ![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -mode is $mode, either -port_handle or -handle parameters must exist."
                return $returnList
            }
            
            if {![info exists handle]} {
                # create router(s)
                set retCode [ixNetworkGetPortObjref $port_handle]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Unable to find the port object reference \
                            associated to the $port_handle port handle -\
                            [keylget retCode log]."
                    return $returnList
                }
                set vport_objref    [keylget retCode vport_objref]
                set protocol_objref [keylget retCode vport_objref]/protocols/mplsTp
                
                # Check if protocols are supported
                set retCode [checkProtocols $vport_objref]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Port $port_handle does not support protocol\
                            configuration."
                    return $returnList
                }
                
                # Compose list of protocol options
                set mplstp_protocol_args "-enabled true"
                foreach {ixnOpt hltOpt}  [array get mplstpProtocolOptionsArray] {
                    if {[info exists $hltOpt]} {
                        lappend mplstp_protocol_args -$ixnOpt [set $hltOpt]
                    }
                }
                set retCode [ixNetworkNodeSetAttr $protocol_objref $mplstp_protocol_args -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
            
                set router_handle_list ""
                if {[llength $router_id] > 1} {
                    set r_router_id        [lindex $router_id 0]
                    set r_router_id_incr   ""
                } else {
                    set r_router_id        $router_id
                    set r_router_id_incr   $router_id_step
                }
                for {set i 0} {$i < $router_count} {incr i} {
                    set tmp_status [::ixia::ixNetworkNodeAdd                        \
                            $protocol_objref                                        \
                            "router"                                                \
                            "-enabled True -routerId $r_router_id"                  \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    if {![info exist no_write]} {
                        incr objectCount
                        if {[expr $objectCount % $objectMaxCount] == 0} {
                            ixNetworkCommit
                        }
                    }
                    set tmp_router_handle [keylget tmp_status node_objref]
                    lappend router_handle_list $tmp_router_handle
                    
                    # increment section
                    debug "$r_router_id_incr , $r_router_id"
                    if {$r_router_id_incr != ""} {
                        set r_router_id [::ixia::incr_ipv4_addr $r_router_id $r_router_id_incr]
                    } else {
                        # the last iteration is ignored
                        if {$i < [expr $router_count-1]} {
                            set r_router_id [lindex $router_id [expr $i+1]]
                        }
                    }
                }
            } else {
                set router_handle_list $handle
            }
                
            # create multiple interfaces on one router
            set intf_list ""
            if {($router_count == 1 || [info exists handle]) && [info exists interface_count] && $interface_count > 0} {
                if {[llength $dut_mac_addr] > 1} {
                    set intf_dut_mac        [ixNetworkFormatMac [lindex $dut_mac_addr 0]]
                    set intf_dut_mac_incr   ""
                } else {
                    set intf_dut_mac        [ixNetworkFormatMac $dut_mac_addr]
                    set intf_dut_mac_incr   [ixNetworkFormatMac $dut_mac_addr_step]
                }
            
                if {![info exists handle]} {
                    set handle $tmp_router_handle
                }
                for {set j 0} {$j < $interface_count} {mpincr j} {
                    set interface_handle_list "\
                        -enabled True \
                        -dutMacAddress $intf_dut_mac \
                        -interfaces [lindex $interface_handle $j]"
                    
                    set tmp_status [::ixia::ixNetworkNodeAdd                        \
                            $handle                                                 \
                            "interface"                                             \
                            $interface_handle_list                                  \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    if {![info exist no_write]} {
                        incr objectCount
                        if {[expr $objectCount % $objectMaxCount] == 0} {
                            ixNetworkCommit
                        }
                    }
                    lappend intf_list [keylget tmp_status node_objref]
                    
                    # increment section
                    if {$intf_dut_mac_incr != ""} {
                        set intf_dut_mac [::ixia::incr_mac_addr $intf_dut_mac $intf_dut_mac_incr]
                    } else {
                        # the last iteration is ignored
                        if {$j < [expr $interface_count-1]} {
                            set intf_dut_mac [ixNetworkFormatMac [lindex $dut_mac_addr [expr $j+1]]]
                        }
                    }
                }
            }
            
            ixNetworkCommit
            
            keylset returnList  router_handles       [ixNet remapIds $router_handle_list]
            if {[llength $intf_list] > 0} {
                keylset returnList  interface_handles   [ixNet remapIds $intf_list]
            }
        }
        "modify" {
            removeDefaultOptionVars $opt_args $args
        
            if {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+$} $handle]} {
                if {![info exists router_id] || [llength $router_id] > 1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When mode is modify, -router_id must exist and have a single element"
                    return $returnList
                }
                set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                        $handle                                                 \
                        "-routerId $router_id"                                  \
                        -commit                                                 \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
                keylset returnList  router_handles       $handle
            }
            if {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+/interface:\d+$} $handle]} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                         \
                        $handle                                                      \
                        "-dutMacAddress [ixNetworkFormatMac $dut_mac_addr] -interfaces $interface_handle" \
                        -commit                                                      \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
                keylset returnList  interface_handles     $handle
            }
        }
        "delete" {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -interface_count exists, parameter -dut_mac_addr is mandatory."
                return $returnList
            }
            set protocol_objref [::ixia::ixNetworkGetProtocolObjref $handle mplsTp]
            if {[keylget protocol_objref status] != $::SUCCESS} {
                return $retCode
            }
            set protocol_objref [keylget protocol_objref objref]
            
            ixNet remove $handle
            ixNetworkCommit
            
            if {[llength [ixNet getList $protocol_objref router]] == 0} {
                # Compose list of protocol options
                
                set mplstp_protocol_args "-enabled false"
                set retCode [ixNetworkNodeSetAttr $protocol_objref $mplstp_protocol_args -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
            }
        }
        "enable" {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -interface_count exists, parameter -dut_mac_addr is mandatory."
                return $returnList
            }
            
            set result [ixNetworkNodeSetAttr $handle "-enabled True" -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure $handle - [keylget result log]."
                return $returnList
            }
            
            if {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+$} $handle]} {
                keylset returnList  router_handles       $handle
            } else {
                keylset returnList  interface_handles     $handle
            }
        }
        "disable" {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -interface_count exists, parameter -dut_mac_addr is mandatory."
                return $returnList
            }
            
            set result [ixNetworkNodeSetAttr $handle "-enabled False" -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure $handle - [keylget result log]."
                return $returnList
            }
            
            if {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+$} $handle]} {
                keylset returnList  router_handles       $handle
            } else {
                keylset returnList  interface_handles     $handle
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    debug "$procName success: $returnList"
    return $returnList
}


proc ::ixia::ixnetwork_mplstp_lsp_pw_config { args man_args opt_args } {

    set procName [lindex [info level [info level]] 0]
    
    debug "$procName $args"

    variable objectMaxCount
    set objectCount 0
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -mandatory_args $man_args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    
    keylset returnList status $::SUCCESS
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    # translation arrays
    array set mplstp_options_map {
        lm_counter_type,32b                             32Bit
        lm_counter_type,64b                             64Bit
        protection_switching_type,one_to_one_bidir      "1:1Bidirectional"
        protection_switching_type,one_plus_one_bidir    "1+1Bidirectional"
        protection_switching_type,one_to_one_unidir     "1:1Unidirectional"
        protection_switching_type,one_plus_one_unidir   "1+1Unidirectional"
        cccv_type,y1731                                 y1731
        cccv_type,bfdcc                                 bfdCc
        cccv_type,none                                  none
        vlan_increment_mode,inner_first                 innerFirst
        vlan_increment_mode,outer_first                 outerFirst
        vlan_increment_mode,none                        noIncrement
        vlan_increment_mode,parallel                    parallelIncrement
        range_type,lsp                                  lsp
        range_type,pw                                   pw
        range_type,nested                               nestedLspPw
    }
    
    array set truth {1 true 0 false enable true disable false}
    
    # form: hltparam ixnparam type extensions
    set lsp_pw_range_params {
        enable                             enable                          value       _none
        alarm_traffic_class                alarmTrafficClass               value       _none
        alarm_type                         alarmType                       value       _none
        aps_traffic_class                  apsTrafficClass                 value       _none
        aps_type                           apsType                         value       _none
        cccv_interval                      cccvInterval                    value       _none
        cccv_traffic_class                 cccvTrafficClass                value       _none
        cccv_type                          cccvType                        translate   _none
        description                        description                     value       _none
        dest_ac_id                         destAcId                        value       _none
        dest_ac_id_step                    destAcIdStep                    value       _none
        dest_global_id                     destGlobalId                    value       _none
        dest_lsp_number                    destLspNumber                   value       _none
        dest_lsp_number_step               destLspNumberStep               value       _none
        dest_mep_id                        destMepId                       value       _none
        dest_mep_id_step                   destMepIdStep                   value       _none
        dest_node_id                       destNodeId                      value       _none
        dest_tunnel_number                 destTunnelNumber                value       _none
        dest_tunnel_number_step            destTunnelNumberStep            value       _none
        dm_time_format                     dmTimeFormat                    value       _none
        dm_traffic_class                   dmTrafficClass                  value       _none
        dm_type                            dmType                          value       _none
        ip_address                         ipAddress                       value       _none
        ip_address_mask_len                ipAddressMask                   value       _none
        ip_address_step                    ipAddressStep                   value       _none
        ip_host_per_lsp                    ipHostPerLsp                    value       _none
        ip_type                            ipType                          value       _none
        lm_counter_type                    lmCounterType                   translate   _none
        lm_initial_rx_value                lmInitialRxValue                value       _none
        lm_initial_tx_value                lmInitialTxValue                value       _none
        lm_rx_step                         lmRxStep                        value       _none
        lm_traffic_class                   lmTrafficClass                  value       _none
        lm_tx_step                         lmTxStep                        value       _none
        lm_type                            lmType                          value       _none
        lsp_incoming_label                 lspIncomingLabel                value       _none
        lsp_incoming_label_step            lspIncomingLabelStep            value       _none
        lsp_outgoing_label                 lspOutgoingLabel                value       _none
        lsp_outgoing_label_step            lspOutgoingLabelStep            value       _none
        mac_address                        macAddress                      mac         _none
        mac_per_pw                         macPerPw                        value       _none
        meg_id_integer_step                megIdIntegerStep                value       _none
        meg_id_prefix                      megIdPrefix                     value       _none
        meg_level                          megLevel                        value       _none
        lsp_count                          numberOfLsp                     value       _none
        pw_per_lsp_count                   numberOfPwPerLsp                value       _none
        on_demand_cv_traffic_class         onDemandCvTrafficClass          value       _none
        peer_lsp_pw_range                  peerLspOrPwRange                value       _none
        peer_nested_lsp_pw_range           peerNestedLspPwRange            value       _none
        pw_incoming_label                  pwIncomingLabel                 value       _none
        pw_incoming_label_step             pwIncomingLabelStep             value       _none
        pw_incoming_label_step_across_lsp  pwIncomingLabelStepAcrossLsp    value       _none
        pw_outgoing_label                  pwOutgoingLabel                 value       _none
        pw_outgoing_label_step             pwOutgoingLabelStep             value       _none
        pw_outgoing_label_step_across_lsp  pwOutgoingLabelStepAcrossLsp    value       _none
        pw_status_traffic_class            pwStatusTrafficClass            value       _none
        pw_status_fault_reply_interval     pwStatusFaultReplyInterval      value       _none
        range_role                         rangeRole                       value       _none
        repeat_mac                         repeatMac                       truth       _none
        src_ac_id                          srcAcId                         value       _none
        src_ac_id_step                     srcAcIdStep                     value       _none
        src_global_id                      srcGlobalId                     value       _none
        src_lsp_number                     srcLspNumber                    value       _none
        src_lsp_number_step                srcLspNumberStep                value       _none
        src_mep_id                         srcMepId                        value       _none
        src_mep_id_step                    srcMepIdStep                    value       _none
        src_node_id                        srcNodeId                       value       _none
        src_tunnel_number                  srcTunnelNumber                 value       _none
        src_tunnel_number_step             srcTunnelNumberStep             value       _none
        support_slow_start                 supportSlowStart                truth       _none
        protection_switching_type          typeOfProtectionSwitching       translate   _none
        range_type                         typeOfRange                     translate   _none
    }
    
    set lsp_pw_range_vlan_params {
        enable_vlan                        enableVlan                      truth       _none
        vlan_count                         vlanCount                       value       _none
        vlan_id                            vlanId                          value       _none
        vlan_increment_mode                vlanIncrementMode               translate   _none
        vlan_priority                      vlanPriority                    value       _none
        vlan_tp_id                         vlanTpId                        value       _none
        skip_zero_vlan_id                  skipZeroVlanId                  truth       _none
    }
    
    set lsp_pw_range_revert_params {
        revertive                          revertive                       truth       _none
        wait_to_revert_time                waitToRevertTime                value       _none
    }
    
    set range_param_lists {
        lsp_pw_range_params
    }
    
    set hlt_param_list {
        alarm_traffic_class alarm_type aps_traffic_class aps_type cccv_interval cccv_traffic_class                
        cccv_type description dest_ac_id dest_ac_id_step dest_global_id dest_lsp_number                   
        dest_lsp_number_step dest_mep_id dest_mep_id_step dest_node_id dest_tunnel_number                
        dest_tunnel_number_step dm_time_format dm_traffic_class dm_type ip_address ip_address_mask                   
        ip_address_step ip_host_per_lsp ip_type lm_counter_type lm_initial_rx_value               
        lm_initial_tx_value lm_rx_step lm_traffic_class lm_tx_step lm_type lsp_incoming_label                
        lsp_incoming_label_step lsp_outgoing_label lsp_outgoing_label_step mac_address                       
        mac_per_pw meg_id_integer_step meg_id_prefix lsp_count pw_per_lsp_count                  
        on_demand_cv_traffic_class peer_lsp_pw_range pw_incoming_label pw_incoming_label_step            
        pw_incoming_label_step_across_lsp pw_outgoing_label pw_outgoing_label_step            
        pw_outgoing_label_step_across_lsp pw_status_traffic_class range_role repeat_mac src_ac_id                         
        src_ac_id_step src_global_id src_lsp_number src_lsp_number_step src_mep_id src_mep_id_step                   
        src_node_id src_tunnel_number src_tunnel_number_step support_slow_start protection_switching_type         
        range_type    
    }
    set hlt_param_list_vlan {
        vlan_count vlan_id vlan_increment_mode vlan_priority vlan_tp_id skip_zero_vlan_id
    }
    
    
    # check params
    if {[info exists count] && $count > 1} {
        if {[info exists vlan_count]} {
            lappend hlt_param_list $hlt_param_list_vlan
        }
        if {[info exists wait_to_revert_time]} {
            lappend hlt_param_list wait_to_revert_time
        }
        foreach elem $hlt_param_list {
            if {[info exists $elem] && [llength [set $elem]] != $count} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: -count is greater than 1 and -$elem list doesn't have the same length"
                return $returnList
            }
        }
    }
    if {
        ($mode == "create" &&![regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+/interface:\d+$} $handle]) &&
        ($mode != "create" && ![regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+/interface:\d+\lspPwRange:\d+$} $handle])
    } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Invalid handle"
        return $returnList
    }
    
    switch -- $mode {
        "create" {
            set range_param_args_start "-enabled True"
            
            if {[info exists vlan_count]} {
                set enable_vlan 1
                lappend range_param_lists lsp_pw_range_vlan_params
            } else {
                lappend range_param_args_start -enableVlan False
            }
            
            if {[info exists wait_to_revert_time]} {
                set revertive 1
                lappend range_param_lists lsp_pw_range_revert_params
            } else {
                lappend range_param_args_start -revertive False
            }
            
            set range_handle_list ""
            
            for {set i 0} {$i < $count} {incr i} {
                set range_param_args $range_param_args_start
                
                foreach param_list $range_param_lists {
                    foreach {hlt_param ixn_param type extensions} [set $param_list] {
                        if {[info exists $hlt_param]} {
                            set hlt_param_value [lindex [set $hlt_param] $i]
                            switch -- $type {
                                value {
                                    set ixn_param_value $hlt_param_value
                                }
                                truth {
                                    set ixn_param_value $truth($hlt_param_value)
                                }
                                translate {    
                                    if {[info exists mplstp_options_map($hlt_param,$hlt_param_value)]} {
                                        set ixn_param_value $mplstp_options_map($hlt_param,$hlt_param_value)
                                    } else {
                                        set ixn_param_value $hlt_param_value
                                    }
                                }
                                mac {
                                    set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                                }
                            }
                            lappend range_param_args -$ixn_param $ixn_param_value
                        }
                    }
                }
               
                set tmp_status [::ixia::ixNetworkNodeAdd                        \
                        $handle                                                 \
                        "lspPwRange"                                            \
                        $range_param_args                                       \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
                if {![info exist no_write]} {
                    incr objectCount
                    if {[expr $objectCount % $objectMaxCount] == 0} {
                        ixNetworkCommit
                    }
                }
                set tmp_range_handle [keylget tmp_status node_objref]
                lappend range_handle_list $tmp_range_handle
            }
            
            ixNetworkCommit
            
            keylset returnList interface_handle  $handle
            keylset returnList range_handle_list [ixNet remapIds $range_handle_list]
        }
        "modify" {
            if {$count > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When mode is modify, parameters cannot be lists"
                return $returnList
            }
            
            set range_param_args_start ""
            
            foreach vlan_hlt_param $hlt_param_list_vlan {            
                if {[info exists $vlan_hlt_param]} {
                    set enable_vlan 1
                    lappend range_param_lists lsp_pw_range_vlan_params
                }
            }
            
            if {[info exists wait_to_revert_time]} {
                set revertive 1
                lappend range_param_lists lsp_pw_range_revert_params
            }
            
            removeDefaultOptionVars $opt_args $args
            
            set range_param_args $range_param_args_start
            foreach param_list $range_param_lists {
                foreach {hlt_param ixn_param type extensions} [set $param_list] {
                    if {[info exists $hlt_param]} {
                        set hlt_param_value [set $hlt_param]
                        switch -- $type {
                            value {
                                set ixn_param_value $hlt_param_value
                            }
                            truth {
                                set ixn_param_value $truth($hlt_param_value)
                            }
                            translate {    
                                if {[info exists mplstp_options_map($hlt_param,$hlt_param_value)]} {
                                    set ixn_param_value $mplstp_options_map($hlt_param,$hlt_param_value)
                                } else {
                                    set ixn_param_value $hlt_param_value
                                }
                            }
                            mac {
                                set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                            }
                        }
                        lappend range_param_args -$ixn_param $ixn_param_value
                    }
                }
            }
           
            set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                    $handle                                                 \
                    $range_param_args                                       \
                    -commit                                                 \
                ]
            if {[keylget tmp_status status] != $::SUCCESS} {
                keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                return $tmp_status
            }
            
            keylset returnList range_handle_list $handle
        }
        "delete" {
            ixNet remove $handle
            ixNetworkCommit
        }
        "enable" {
            set result [ixNetworkNodeSetAttr $handle "-enabled True" -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure $handle - [keylget result log]."
                return $returnList
            }
            
            keylset returnList range_handle_list $handle
        }
        "disable" {
            set result [ixNetworkNodeSetAttr $handle "-enabled False" -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure $handle - [keylget result log]."
                return $returnList
            }
            
            keylset returnList range_handle_list $handle
        }
    }
    
    debug "$procName success: $returnList"
    
    return $returnList
}


proc ::ixia::ixnetwork_mplstp_control {args man_args opt_args} {
    set procName [lindex [info level [info level]] 0]
    debug "$procName $args"
    
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
    
    if {[info exists handle] && $mode != "trigger" && ![regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+$} $handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Parameter -handle provided is not a valid MPLS-TP router handle"
        return $returnList
    }
    
    if {$mode == "trigger" && [info exists handle]} {
        # can either be a list of routers or a list of generalLearnedInfo objs
        set handle_type "glinfo"
        if {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+$} [lindex $handle 0]]} {
            set handle_type "router"
        }
        set ll [llength $handle]
        for {set i 1} {$i < $ll} {incr i} {
            if {
                ($handle_type == "glinfo" && 
                    [regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+$} [lindex $handle $i]]) ||
                ($handle_type == "router" && 
                    [regexp {^::ixNet::OBJ-/vport:\d+/protocols/mplsTp/router:\d+/learnedInformation/generalLearnedInfo:\d+$} [lindex $handle $i]])
            } {
                keylset returnList status $::FAILURE
                keylset returnList log "Parameter -handle can only have a list of routers or a list of general learned info objects."
                return $returnList
            }
        }
    }

    # translation arrays
    array set mplstp_options_map {
        lm_counter_type,32b                             32Bit
        lm_counter_type,64b                             64Bit
        aps_trigger_type,forced_switch                  forcedSwitch
        aps_trigger_type,manual_switch                  manualSwitch
        cccv_pause_trigger_option,both                  txRx
        cccv_resume_trigger_option,both                 txRx
        dm_mode,response_expected                       responseExpected
        dm_mode,no_response_expected                    noResponseExpected
        lm_mode,response_expected                       responseExpected
        lm_mode,no_response_expected                    noResponseExpected
        lsp_ping_encapsulation_type,gach                GAch
        lsp_ping_encapsulation_type,udp_ip_gach         "UDP over IP over GAch"
        lsp_trace_route_encapsulation_type,gach         GAch
        lsp_trace_route_encapsulation_type,udp_ip_gach  "UDP over IP over GAch"
    }
    
    array set truth {1 true 0 false enable true disable false}
    
    # form: hltparam ixnparam type extensions
    set li_params {
        alarm_enable                                enableAlarm                             truth       _none
        alarm_trigger                               alarmTrigger                            value       _none
        alarm_type                                  alarmType                               value       _none
        alarm_ais_enable                            enableAlarmAis                          truth       _none
        alarm_lck_enable                            enableAlarmLck                          truth       _none
        alarm_set_ldi_enable                        enableAlarmSetLdi                       truth       _none
        alarm_periodicity                           periodicity                             value       _none
        aps_trigger_enable                          enableApsTrigger                        truth       _none
        aps_trigger_type                            apsTriggerType                          translate   _none
        cccv_pause_trigger_option                   cccvPauseTriggerOption                  translate   _none
        cccv_resume_trigger_option                  cccvResumeTriggerOption                 translate   _none
        cccv_pause_enable                           enableCccvPause                         truth       _none
        cccv_resume_enable                          enableCccvResume                        truth       _none
        dm_trigger_enable                           enableDmTrigger                         truth       _none
        dm_interval                                 dmInterval	                            value       _none
        dm_iterations                               dmIterations	                        value       _none
        dm_mode                                     dmMode	                                translate   _none
        dm_pad_len                                  dmPadLen	                            value       _none
        dm_request_padded_reply                     dmRequestPaddedReply                    value       _none
        dm_time_format                              dmTimeFormat	                        value       _none
        dm_traffic_class                            dmTrafficClass	                        value       _none
        dm_type                                     dmType	                                value       _none
        last_dm_response_timeout                    lastDmResponseTimeout                   value       _none
        lm_trigger_enable                           enableLmTrigger                         truth       _none
        lm_initial_rx_value                         lmInitialRxValue                        value       _none
        lm_initial_tx_value                         lmInitialTxValue                        value       _none
        lm_interval                                 lmInterval	                            value       _none
        lm_iterations                               lmIterations	                        value       _none
        lm_mode                                     lmMode	                                translate   _none
        lm_rx_step                                  lmRxStep	                            value       _none
        lm_tx_step                                  lmTxStep                                value       _none
        lm_traffic_class                            lmTrafficClass                          value       _none
        lm_type                                     lmType                                  value       _none
        lm_counter_type                             counterType                             translate   _none
        last_lm_response_timeout                    lastLmResponseTimeout                   value       _none
        lsp_ping_enable                             enableLspPing                           truth       _none
        lsp_ping_fec_stack_validation_enable        enableLspPingFecStackValidation         truth       _none
        lsp_ping_response_timeout                   lspPingResponseTimeout                  value       _none
        lsp_ping_ttl_value                          lspPingTtlValue                         value       _none
        lsp_ping_encapsulation_type                 lspPingEncapsulationType                translate   _none
        lsp_trace_route_enable                      enableLspTraceRoute                     truth       _none
        lsp_trace_route_fec_stack_validation_enable enableLspTraceRouteFecStackValidation   truth       _none
        lsp_trace_route_response_timeout            lspTraceRouteResponseTimeout            value       _none
        lsp_trace_route_ttl_limit                   lspTraceRouteTtlLimit                   value       _none
        lsp_trace_route_encapsulation_type          lspTraceRouteEncapsulationType          translate   _none
        pw_status_clear_enable                      enablePwStatusClear                     truth       _none
        pw_status_fault_enable                      enablePwStatusFault                     truth       _none
        pw_status_clear_label_ttl                   pwStatusClearLabelTtl                   value       _none
        pw_status_clear_transmit_interval           pwStatusClearTransmitInterval           value       _none
        pw_status_code                              pwStatusCode                            hex         _none
        pw_status_fault_label_ttl                   pwStatusFaultLabelTtl                   value       _none
        pw_status_fault_transmit_interval           pwStatusFaultTransmitInterval           value       _none
    }
    
    array set refresh_infotype {
        generalLearnedInfo      isGeneralLearnedInformationRefreshed    
        dmLearnedInfo           isDmLearnedInformationRefreshed
        lmLearnedInfo           isLmLearnedInformationRefreshed
        pingLearnedInfo         isPingLearnedInformationRefreshed
        traceRouteLearnedInfo   isTraceRouteLearnedInformationRefreshed
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
            lappend protocol_objref_list $protocol_objref/protocols/mplsTp
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
            set retCode [ixNetworkGetProtocolObjref $_handle mplsTp]
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
            keylset returnList log "Failed to $mode MPLS-TP on the $vport_objref\
                    port. Port state is $portState, $portStateD."
            return $returnList
        }
    }
    
    if {$mode != "trigger"} {
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
                    keylset returnList log "Failed to $operation MPLS-TP on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
            }
            after 1000
        }
    } else {
        if {
            $alarm_enable || $aps_trigger_enable || $cccv_pause_enable || 
            $cccv_resume_enable || $dm_trigger_enable || $lm_trigger_enable ||
            $lsp_ping_enable || $lsp_trace_route_enable || $pw_status_clear_enable || $pw_status_fault_enable
        } {
            ## handle+labels, port+labels, handles of gli
            
            # generalLearnedInfo select part
            if {![info exists handle]} {
                # port handle exists
                # protocol_objref_list has mplsTp protocols on the port handle
                
                # WARNING: overwrite var
                set handle {}
                set handle_type "router"
                foreach protocol_objref $protocol_objref_list {
                    # WARNING: overwrite var
                    set handle [concat $handle [ixNet getList $protocol_objref router]]
                }
            }
            
            set trig_router_list {}
            set gli_list {}
            if {$handle_type == "router"} {
                set trig_router_list $handle
                
                # expand label lists
                set in_inn_lbl {}
                foreach iil $incoming_inner_label {
                    if {[regexp {^(\d+):(\d+):(\d+)$} $iil {} lstart lstep lcount]} {
                        set lbl $lstart
                        for {set lbli 0} {$lbli < $lcount} {mpincr lbli} {
                            lappend in_inn_lbl $lbl
                            mpincr lbl $lstep
                        }
                    } else {
                        lappend in_inn_lbl $iil
                    }
                }
                set in_out_lbl {}
                foreach iol $incoming_outer_label {
                    if {[regexp {^(\d+):(\d+):(\d+)$} $iol {} lstart lstep lcount]} {
                        set lbl $lstart
                        for {set lbli 0} {$lbli < $lcount} {mpincr lbli} {
                            lappend in_out_lbl $lbl
                            mpincr lbl $lstep
                        }
                    } else {
                        lappend in_out_lbl $iol
                    }
                }
                set out_inn_lbl {}
                foreach oil $outgoing_inner_label {
                    if {[regexp {^(\d+):(\d+):(\d+)$} $oil {} lstart lstep lcount]} {
                        set lbl $lstart
                        for {set lbli 0} {$lbli < $lcount} {mpincr lbli} {
                            lappend out_inn_lbl $lbl
                            mpincr lbl $lstep
                        }
                    } else {
                        lappend out_inn_lbl $oil
                    }
                }
                set out_out_lbl {}
                foreach ool $outgoing_outer_label {
                    if {[regexp {^(\d+):(\d+):(\d+)$} $ool {} lstart lstep lcount]} {
                        set lbl $lstart
                        for {set lbli 0} {$lbli < $lcount} {mpincr lbli} {
                            lappend out_out_lbl $lbl
                            mpincr lbl $lstep
                        }
                    } else {
                        lappend out_out_lbl $ool
                    }
                }
                
                debug "Label lists are \nii=$in_inn_lbl \nio=$in_out_lbl \noi=$out_inn_lbl \noo=$out_out_lbl"
                if {
                    [llength $in_inn_lbl] != [llength $in_out_lbl] || 
                    [llength $out_inn_lbl] != [llength $out_out_lbl] ||
                    [llength $in_out_lbl] != [llength $out_inn_lbl]
                } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The list parameters -incoming_inner_label; -incoming_outer_label; -outgoing_inner_label; -outgoing_outer_label\n\
                        need to have the same expanded length."
                    return $returnList
                }
                set lll [llength $in_inn_lbl]
                foreach router $handle {
                    # get all gli's from router
                    set no_of_refresh_tries 10
                    set li [ixNet getList $router learnedInformation]
                    for {set no 0} {$no < $no_of_refresh_tries} {incr no} {
                        set refresh_learned_info [ixNet exec refreshLearnedInformation $li]
                        if {[string first "::ixNet::OK" $refresh_learned_info] == -1 } {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to refresh learned info for\
                                    mplsTp router $router."
                            return $returnList
                        }
                        after 1000
                        set gli_l [ixNet getList $li generalLearnedInfo]
                        if {[llength $gli_l]>0} {
                            break
                        }
                    }
                    
                    for {set i 0} {$i < $lll} {mpincr i} {
                        set found 0
                        foreach gli $gli_l {
                            set incoming [split [ixNet getAttribute $gli -incomingLabelOuterInner] -]
                            set outgoing [split [ixNet getAttribute $gli -outgoingLabelOuterInner] -]
                            if {
                                [lindex $incoming 0] == [lindex $in_out_lbl $i] &&
                                [lindex $incoming 1] == [lindex $in_inn_lbl $i] &&
                                [lindex $outgoing 0] == [lindex $out_out_lbl $i] &&
                                [lindex $outgoing 1] == [lindex $out_inn_lbl $i]
                            } {
                                set found 1
                                lappend gli_list $gli
                            }
                        }
                        if {!$found} {
                            puts stderr "WARNING: Could not find an object to trigger with \n\
                                incomingLabelOuterInner=[lindex $in_out_lbl $i]-[lindex $in_inn_lbl $i] and \n\
                                outgoingLabelOuterInner=[lindex $out_out_lbl $i]-[lindex $out_inn_lbl $i]"
                        }
                    }
                }
            } else {
                set gli_list $handle
                foreach gli $handle {
                    lappend trig_router_list [ixNetworkGetParentObjref $gli router]
                }
            }
            
            if {[llength $gli_list] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "No objects to trigger have been found."
                return $returnList
            }
            
            foreach trouter $trig_router_list {
                set li [ixNet getList $trouter learnedInformation]
                set li_param_args {}
                
                foreach {hlt_param ixn_param type extensions} $li_params {
                    if {[info exists $hlt_param]} {
                        set hlt_param_value [set $hlt_param]
                        switch -- $type {
                            value {
                                set ixn_param_value $hlt_param_value
                            }
                            truth {
                                set ixn_param_value $truth($hlt_param_value)
                            }
                            translate {    
                                if {[info exists mplstp_options_map($hlt_param,$hlt_param_value)]} {
                                    set ixn_param_value $mplstp_options_map($hlt_param,$hlt_param_value)
                                } else {
                                    set ixn_param_value $hlt_param_value
                                }
                            }
                            hex {
                                set ixn_param_value [mpexpr 0x$hlt_param_value]
                            }
                        }
                        lappend li_param_args -$ixn_param $ixn_param_value
                    }
                }
                
                set result [ixNetworkNodeSetAttr $li $li_param_args -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to configure $li - [keylget result log]."
                    return $returnList
                }
            }
            
            # use the gli list
            foreach gli $gli_list {
                debug "ixNet exec addRecordForTrigger $gli"
                set exec_result [ixNet exec addRecordForTrigger $gli]
                if {[string first "::ixNet::OK" $exec_result] != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to addRecordForTrigger $gli -> $exec_result"
                    return $returnList
                }
            }
            
            after 1000

            foreach trouter $trig_router_list {
                set li [ixNet getList $trouter learnedInformation]
                
                debug "ixNet exec trigger $li"
                set exec_result [ixNet exec trigger $li]
                if {[string first "::ixNet::OK" $exec_result] != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to trigger $li -> $exec_result"
                    return $returnList
                }
            }
            
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to trigger, no actual trigger parameters have been enabled."
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    
    debug "$procName success: $returnList"
    
    return $returnList
}


proc ::ixia::ixnetwork_mplstp_info { args man_args opt_args } {
    set procName [lindex [info level [info level]] 0]
    debug "$procName $args"
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {[info exists port_handle]} {
        set li_handles      {}
        set port_handles    {}
        foreach {port} $port_handle {
            set retCode [ixNetworkGetPortObjref $port]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set vport_objref [keylget retCode vport_objref]
            set protocol_objref $vport_objref/protocols/mplsTp
            set router_objref [ixNet getList $protocol_objref router]
            foreach ro $router_objref {
                lappend li_handles $ro/learnedInformation
            }
            lappend port_handles $port
        }
        if {$li_handles == "" } {
            keylset returnList status $::FAILURE
            keylset returnList log "There are no MPLS-TP router on the ports\
                    provided through -port_handle."
            return $returnList
        }
    }
    
    if {[info exists handle]} {
        set port_handles    {}
        set li_handles      {}
        
        # remove duplicates
        set handle [lsort -unique $handle]
        
        foreach {_handle} $handle {
            if {[regexp {^(.*/protocols/mplsTp/router:\d+)/interface:\d+$} $_handle {} router_h]} {
                # accept interface handle, cast to router
                set _handle $router_h
            }            
            if {![regexp {^.*/protocols/mplsTp/router:\d+$} $_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The handle $handle is not a valid\
                        MPLS-TP router handle."
                return $returnList
            }
            set retCode [ixNetworkGetPortFromObj $_handle]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            
            lappend li_handles $_handle/learnedInformation
            lappend port_handles  [keylget retCode port_handle]
        }
    }
    
    keylset returnList status $::SUCCESS
    
    if {$mode == "clear_stats"} {
        debug "ixNet exec clearStats"
        if {[set retCode [catch {ixNet exec clearStats} retCode]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to clear statistics."
            return $returnList
        }
    }
    
    array set li_subobj_list_arr [list \
        learned_info                [list generalLearnedInfo dmLearnedInfo lmLearnedInfo pingLearnedInfo traceRouteLearnedInfo] \
        general_learned_info        [list generalLearnedInfo] \
        dm_learned_info             [list dmLearnedInfo] \
        lm_learned_info             [list lmLearnedInfo] \
        ping_learned_info           [list pingLearnedInfo] \
        trace_route_learned_info    [list traceRouteLearnedInfo] \
    ]
    
    array set translate_infotype {
        generalLearnedInfo      general_learned_info    
        dmLearnedInfo           dm_learned_info
        lmLearnedInfo           lm_learned_info
        pingLearnedInfo         ping_learned_info
        traceRouteLearnedInfo   trace_route_learned_info
    }
    
    array set refresh_infotype {
        generalLearnedInfo      isGeneralLearnedInformationRefreshed    
        dmLearnedInfo           isDmLearnedInformationRefreshed
        lmLearnedInfo           isLmLearnedInformationRefreshed
        pingLearnedInfo         isPingLearnedInformationRefreshed
        traceRouteLearnedInfo   isTraceRouteLearnedInformationRefreshed
    }
    
    set generalLearnedInfo_stats {
        aisRx                          ais_rx
        aisState                       ais_state
        aisTx                          ais_tx 
        alarmTypeAis                   alarm_type_ais
        alarmTypeLck                   alarm_type_lck
        apsLocalDataPath               aps_local_data_path    
        apsLocalFaultPath              aps_local_fault_path   
        apsLocalState                  aps_local_state
        apsRemoteDataPath              aps_remote_data_path   
        apsRemoteFaultPath             aps_remote_fault_path  
        apsRemoteRequestState          aps_remote_request_state     
        continuityCheckLocalState      continuity_check_local_state 
        continuityCheckRemoteState     continuity_check_remote_state
        incomingLabelOuterInner        incoming_label_outer_inner   
        lastAlarmDuration              last_alarm_duration    
        lckRx                          lck_rx 
        lckState                       lck_state      
        lckTx                          lck_tx 
        ldi                            ldi    
        localPwStatus                  local_pw_status
        outgoingLabelOuterInner        outgoing_label_outer_inner   
        role                           role   
        timeSinceLastAlarm             time_since_last_alarm  
        type                           type
    }
    
    set dmLearnedInfo_stats {
        averageLooseRtt                average_loose_rtt
        averageLooseRttVariation       average_loose_rtt_variation
        averageStrictRtt               average_strict_rtt
        averageStrictRttVariation      average_strict_rtt_variation
        dmQueriesSent                  dm_queries_sent
        dmResponsesReceived            dm_responses_received  
        incomingLabelOuterInner        incoming_label_outer_inner
        maxLooseRtt                    max_loose_rtt
        maxStrictRtt                   max_strict_rtt
        minLooseRtt                    min_loose_rtt
        minStrictRtt                   min_strict_rtt
        outgoingLabelOuterInner        outgoing_label_outer_inner
        type                           type   
    }
    set lmLearnedInfo_stats {
        incomingLabelOuterInner        incoming_label_outer_inner
        lastLmResponseDutRx            last_lm_response_dut_rx
        lastLmResponseDutTx            last_lm_response_dut_tx
        lastLmResponseMyTx             last_lm_response_my_tx
        lmQueriesSent                  lm_queries_sent
        lmRemoteUsing64Bit             lm_remote_using64_bit
        lmResponsesReceived            lm_responses_received
        outgoingLabelOuterInner        outgoing_label_outer_inner
        type                           type
    }
    set pingLearnedInfo_stats {
        incomingLabelOuterInner        incoming_label_outer_inner
        outgoingLabelOuterInner        outgoing_label_outer_inner
        reachability                   reachability
        returnCode                     return_code
        returnSubcode                  return_subcode
        rtt                            rtt
        senderHandle                   sender_handle
        sequenceNumber                 sequence_number
        type                           type
    }
    
    set traceRouteLearnedInfo_stats {
        incomingLabelOuterInner        incoming_label_outer_inner
        numberOfReplyingHops           number_of_replying_hops
        outgoingLabelOuterInner        outgoing_label_outer_inner
        reachability                   reachability
        senderHandle                   sender_handle
        type                           type
    }
    
    if {[lsearch [array names li_subobj_list_arr] $mode] != -1} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When mode is $mode, parameter -handle is mandatory."
            return $returnList
        }
    
        foreach li $li_handles {
            # get router handle to prepend keys
            set router_h [ixNetworkGetParentObjref $li router]
            
            foreach li_subobj_list $li_subobj_list_arr($mode) {
                foreach li_subobj $li_subobj_list {
                
                    # refresh
                    debug "ixNet exec refreshLearnedInformation $li"
                    ixNet exec refreshLearnedInformation $li
                    set retries 30
                    while {[ixNet getAttribute $li -$refresh_infotype($li_subobj)] != "true"} {
                        debug "ixNet getAttribute $li -$refresh_infotype($li_subobj) = [ixNet getAttribute $li -$refresh_infotype($li_subobj)]"
                        debug "ixNet exec refreshLearnedInformation $li retry $retries"
                        ixNet exec refreshLearnedInformation $li
                        after 10000
                        incr retries -1
                        if {$retries < 0} {
                            # for a specific request, return an error. otherwise go on
                            if {$mode != "learned_info"} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Refreshing learned info for\
                                        MPLS-TP router $router_h has timed out. Please try again later."
                                        
                                foreach {ixnOpt hltOpt} [set ${li_subobj}_stats] {
                                    keylset returnList \
                                        $router_h.NA:NA.$translate_infotype($li_subobj).$hltOpt \
                                        "NA"
                                }
                                return $returnList
                            }
                            break
                        }
                    }
                    after 1000
                
                    set li_obj_list [ixNet getList $li $li_subobj]
                    foreach li_obj $li_obj_list {
                        # get the labels
                        set incoming_label ""
                        set outgoing_label ""
                        foreach {ixnOpt hltOpt} [set ${li_subobj}_stats] {
                            if {$ixnOpt == "incomingLabelOuterInner"} {
                                set incoming_label [ixNet getAttribute $li_obj -$ixnOpt]
                            }
                            if {$ixnOpt == "outgoingLabelOuterInner"} {
                                set outgoing_label [ixNet getAttribute $li_obj -$ixnOpt]
                            }
                        }
                        set label_string ${incoming_label}:${outgoing_label}
                        foreach {ixnOpt hltOpt} [set ${li_subobj}_stats] {
                            if {$ixnOpt == "incomingLabelOuterInner" || $ixnOpt == "outgoingLabelOuterInner"} { continue }
                            keylset returnList \
                                $router_h.$label_string.$translate_infotype($li_subobj).$hltOpt \
                                [ixNet getAttribute $li_obj -$ixnOpt]
                        }
                        
                        if {$li_subobj == "generalLearnedInfo"} {
                            keylset returnList \
                                $router_h.$label_string.general_linfo_object $li_obj
                        }
                    }
                }
            } 
        }
    }
    
    if {$mode == "aggregate_stats"} {
        array set stats_array_aggregate {
            "Port Name"
            port_name
            "CCCV Configured"
            cccv_configured
            "CCCV Up"
            cccv_up
            "CCCV Down"
            cccv_down
            "CCCV Flap Count"
            cccv_flap_count
            "CCCV Tx"
            cccv_tx
            "CCCV Rx"
            cccv_rx
            "APS Tx"
            aps_tx
            "APS Rx"
            aps_rx
            "MPLS Echo Tx"
            mpls_echo_tx
            "MPLS Echo Rx"
            mpls_echo_rx
            "LM Request Tx"
            lm_request_tx
            "LM Request Rx"
            lm_request_rx
            "LM Reply Tx"
            lm_reply_tx
            "LM Reply Rx"
            lm_reply_rx
            "DM Request Tx"
            dm_request_tx
            "DM Request Rx"
            dm_request_rx
            "DM Reply Tx"
            dm_reply_tx
            "DM Reply Rx"
            dm_reply_rx
            "Alarm Tx"
            alarm_tx
            "Alarm Rx"
            alarm_rx
            "PW Status Tx"
            pw_status_tx
            "PW Status Rx"
            pw_status_rx
        }
        
        set statistic_types {
            aggregate "MPLSTP Aggregated Statistics"
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
            set port ""
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
                set port "$chassis_no/$card_no/$port_no"
                if {[lsearch $port_handles $port] != -1} {
                    set found true
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
    
    debug "$procName success: $returnList"
    
    return $returnList
}
