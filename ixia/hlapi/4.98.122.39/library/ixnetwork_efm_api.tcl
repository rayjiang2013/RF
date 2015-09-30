proc ::ixia::ixnetwork_efm_config {args man_args opt_args} {

    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
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
    
    array set truth {1 true 0 false enable true disable false}

    foreach {ch ca po} [split $port_handle /] {}
    
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
    set protocol_objref [keylget retCode vport_objref]/protocols/linkOam
    
    # Check if protocols are supported
    set retCode [checkProtocols $vport_objref]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Port $port_handle does not support protocol\
                configuration."
        return $returnList
    }
    
    # Check if a link object is already configured on this port
    set link_obj_list [ixNet getList $protocol_objref link]
    
    # Flag to indicate if a link was already configured and is being modified
    set link_obj_modify 1
    if {$link_obj_list == ""} {
        set link_obj_modify 0
        # link object does not exist. Create it
        set tmp_status [::ixia::ixNetworkNodeAdd                        \
                $protocol_objref                                        \
                "link"                                                  \
                ""                                                      \
                -commit                                                 \
            ]
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
        
        set link_obj [keylget tmp_status node_objref]
        
    } elseif {[llength $link_obj_list] > 1} {
         puts "\nWARNING: Multiple OAM Link objects exit on the current port $port_handle.\
                    This cannot be configured from HLTAPI and might cause the implementation \
                    to misbehave .\n The first link object will be used."
        
        set link_obj [lindex $link_obj_list 0]
    } else {
        set link_obj $link_obj_list
    }
    # Enable linkOam on port
    ixNet setAttribute $protocol_objref -enabled true
    
    array set efm_options_map {
        single                          single
        periodic                        periodic
        enable_oam_remote_loopback      enableLoopback
        disable_oam_remote_loopback     disableLoopback
        active                          active
        passive                         passive
    }
    
    set efm_param_map {
        intf_enable                      enabled                          truth       interface
        intf_handle                      interfaceId                      value       interface
        critical_event                   enableCriticalEvent              truth       _none
        dying_gasp                       enableDyingGasp                  truth       _none
        enabled_efpt                     enabled                          truth       erroredFramePeriodTlv
        error_frame_period_count         frames                           value       erroredFramePeriodTlv
        error_frame_period_threshold     threshold                        value       erroredFramePeriodTlv
        error_frame_period_window        window                           value       erroredFramePeriodTlv
        enabled_eft                      enabled                          truth       erroredFrameTlv
        error_frame_count                frames                           value       erroredFrameTlv
        error_frame_threshold            threshold                        value       erroredFrameTlv
        error_frame_window               window                           value       erroredFrameTlv
        enabled_efsst                    enabled                          truth       erroredFrameSecondsSummaryTlv
        error_frame_summary_count        summary                          value       erroredFrameSecondsSummaryTlv
        error_frame_summary_threshold    threshold                        value       erroredFrameSecondsSummaryTlv
        error_frame_summary_window       window                           value       erroredFrameSecondsSummaryTlv
        enabled_espt                     enabled                          truth       erroredSymbolPeriodTlv
        error_symbol_period_count        symbols                          value       erroredSymbolPeriodTlv
        error_symbol_period_threshold    threshold                        value       erroredSymbolPeriodTlv
        error_symbol_period_window       window                           value       erroredSymbolPeriodTlv
        link_events                      supportsInterpretingLinkEvents   truth       _none
        link_fault                       enableLinkFault                  truth       _none
        mac_local                        macAddress                       mac         _none
        oui_value                        oui                              value       _none
        sequence_id                      sequenceNumber                   value_check _none
        overrideSequenceNumber           overrideSequenceNumber           truth       _none
        size                             maxOamPduSize                    value       _none
        variable_retrieval               supportsVariableRetrieval        truth       _none
        vsi_value                        vendorSpecificInformation        value       _none
        disable_information_pdu_tx       disableInformationPduTx          truth       _none
        disable_non_information_pdu_tx   disableNonInformationPduTx       truth       _none
        enable_loopback_response         enableLoopbackResponse           truth       _none
        enable_variable_response         enableVariableResponse           truth       _none
        event_interval                   eventInterval                    value       _none
        information_pdu_rate             informationPduCountPerSecond     value       _none
        link_event_tx_mode               linkEventTxMode                  translate   _none
        local_lost_link_timer            localLostLinkTimer               value       _none
        loopback_cmd                     loopbackCmd                      translate   _none
        loopback_timeout                 loopbackTimeout                  value       _none
        oam_mode                         operationMode                    translate   _none
        override_local_evaluating        overrideLocalEvaluating          truth       _none
        override_local_satisfied         overrideLocalSatisfied           truth       _none
        override_local_stable            overrideLocalStable              truth       _none
        override_remote_evaluating       overrideRemoteEvaluating         truth       _none
        override_remote_stable           overrideRemoteStable             truth       _none
        override_revision                overrideRevision                 truth       _none
        revision                         revision                         value       _none
        supports_remote_loopback         supportsRemoteLoopback           truth       _none
        supports_unidir_mode             supportsUnidirectionalMode       truth       _none
        variable_response_timeout        variableResponseTimeout          value       _none
        version                          version                          hex2int     _none
        enabled_oset                     enabled                          truth       organizationSpecificEventTlv
        os_event_tlv_oui                 oui                              hex2blob    organizationSpecificEventTlv
        os_event_tlv_value               value                            hex2blob    organizationSpecificEventTlv
        os_oampdu_data_oui               oui                              hex2blob    organizationSpecificOamPduData
        os_oampdu_data_value             value                            hex2blob    organizationSpecificOamPduData
    }
    
    # Configure flags as disabled if they are not present
    set default_flags {
        critical_event
        dying_gasp
        link_events
        link_fault
        variable_retrieval
    }
    
    foreach def_flg $default_flags {
        if {![info exists $def_flg]} {
            set $def_flg 0
        }
    }
    
    # Calculate timeouts from s to ms
    foreach timeout_p [list loopback_timeout variable_response_timeout] {
        if {[info exists $timeout_p]} {
            set p_val [set $timeout_p]
            if {![string is double $p_val] || $p_val < 0.5 || $p_val > 10} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid parameter $timeout_p $p_val. Parameter\
                        must be a valid floating point value in the range 0.5-10"
                return $returnList
            }
            
            set $timeout_p [mpexpr round($p_val * 1000)]
        }
    }
    
    # Enable event tlvs where necessary
    #######################################

    set enabled_efpt    0
    set enabled_eft     0
    set enabled_efsst   0
    set enabled_espt    0
    set enabled_oset    0
    
    foreach {hlt_param ixn_param p_type extensions} $efm_param_map {
        if {[info exists $hlt_param] && ![regexp {enabled_*} $hlt_param]} {
            switch -- $extensions {
                "erroredFramePeriodTlv" {
                    set enabled_efpt 1
                }
                "erroredFrameTlv" {
                    set enabled_eft 1
                }
                "erroredFrameSecondsSummaryTlv" {
                    set enabled_efsst 1
                }
                "erroredSymbolPeriodTlv" {
                    set enabled_espt 1
                }
                "organizationSpecificEventTlv" {
                    set enabled_oset 1
                }
            }
        }
    }

    # Init defaults for parameters that weren't initialized at parse dashed args

    set default_values_list {
        error_frame_count              0
        error_frame_period_count       0
        error_frame_period_threshold   30
        error_frame_period_window      300
        error_frame_threshold          40
        error_frame_window             400
        error_frame_summary_count      0
        error_frame_summary_threshold  30
        error_frame_summary_window     300
        error_symbol_period_count      0
        error_symbol_period_threshold  50
        error_symbol_period_window     500
        os_event_tlv_oui               0x000100
        os_event_tlv_value             0x00
        os_oampdu_data_oui             0x000100
        os_oampdu_data_value           0x00
        overrideSequenceNumber         0
    }
    foreach {efm_cfg_param default_value} $default_values_list {
        if {![info exists $efm_cfg_param]} {
            set $efm_cfg_param $default_value
        }
    }
    
    if {![info exists mac_local]} {
        set mac_local [::ixia::get_default_mac $ch $ca $po]
    }

    if {![::ixia::isValidMacAddress $mac_local]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid mac address value for -mac_local $mac_local"
        return $returnList
    }
    
    set mac_local [::ixia::convertToIxiaMac $mac_local]

    # Create connected interface for efm link
    set protocol_intf_options {
        -mac_address                 mac_local
        -port_handle                 port_handle
    }
    
    set protocol_intf_args ""
    foreach {option value_name} $protocol_intf_options {
        if {[info exists $value_name]} {
            append protocol_intf_args " $option [set $value_name]"
        }
    }
    
    # Create the necessary interfaces
    set intf_handle [eval ixNetworkProtocolIntfCfg \
            $protocol_intf_args]
    if {[keylget intf_handle status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to create the\
                protocol interfaces. [keylget intf_handle log]"
        return $returnList
    }
    
    set intf_handle [keylget intf_handle connected_interfaces]
    set intf_enable 1

    
    set ixn_link_args                       "-enabled 1"
    set erroredFramePeriodTlv_args          ""
    set erroredFrameTlv_args                ""
    set erroredFrameSecondsSummaryTlv_args  ""
    set erroredSymbolPeriodTlv_args         ""
    set organizationSpecificEventTlv_args   ""
    set organizationSpecificOamPduData      ""
    set interface_args                      ""
    
    foreach {hlt_param ixn_param p_type extensions} $efm_param_map {
        if {[info exists $hlt_param]} {
            
            set hlt_param_value [set $hlt_param]

            switch -- $p_type {
                value {
                    set ixn_param_value $hlt_param_value
                }
                truth {
                    set ixn_param_value $truth($hlt_param_value)
                }
                translate {
                    if {[info exists efm_options_map($hlt_param_value)]} {
                        set ixn_param_value $efm_options_map($hlt_param_value)
                    } else {
                        set ixn_param_value $hlt_param_value
                    }
                }
                mac {
                    set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                }
                value_check {
                    # This is only for sequence_id parameter
                    set overrideSequenceNumber 1
                    set ixn_param_value $hlt_param_value
                }
                hex2blob {
                    set ixn_param_value \{[::ixia::hex2list $hlt_param_value]\}
                }
                hex2int {
                    set ixn_param_value [format %d $hlt_param_value]
                }
            }
            
            if {$extensions == "_none"} {
                append ixn_link_args " -$ixn_param $ixn_param_value"
            } else {
                append ${extensions}_args "-$ixn_param $ixn_param_value "
            }
        }
    }
    
    if {$ixn_link_args != ""} {
        set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                $link_obj                                                   \
                $ixn_link_args                                              \
                -commit                                                     \
            ]
        
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
    }
    
    set l1_config_oam_params {
        enable_optional_tlv              enableTlvOption                  truth
        tlv_type                         tlvType                          value
        tlv_value                        tlvValue                         value
        idle_timer                       idleTimer                        value
        vsi_value_l1                     vendorSpecificInformation        value
        oui_value_l1                     organizationUniqueIdentifier     value
        enable_loopback                  loopback                         truth
        mac_local_l1                     macAddress                       mac
        size_l1                          maxOAMPDUSize                    value
        link_events_l1                   linkEvents                       truth
        enable_oam                       enabled                          truth
    }
    set l1_config_oam_args ""
    foreach {hlt_param ixn_param p_type} $l1_config_oam_params {
        if {[info exists $hlt_param]} {
        
            set hlt_param_value [set $hlt_param]
            switch -- $p_type {
                value {
                    set ixn_param_value $hlt_param_value
                }
                truth {
                    set ixn_param_value $truth($hlt_param_value)
                }
                mac {
                    set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                }
            }
            append l1_config_oam_args " -$ixn_param $ixn_param_value"
        }
    }

    if {$l1_config_oam_args != ""} {
        set l1_config_oam $vport_objref/l1Config/ethernet/oam
        set tmp_status [::ixia::ixNetworkNodeSetAttr    \
                $l1_config_oam                          \
                $l1_config_oam_args                     \
                -commit                                 \
            ]
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
    }
    
    set event_tlv_arg_lists [list                                               \
            erroredFramePeriodTlv_args          erroredFramePeriodTlv           \
            erroredFrameTlv_args                erroredFrameTlv                 \
            erroredFrameSecondsSummaryTlv_args  erroredFrameSecondsSummaryTlv   \
            erroredSymbolPeriodTlv_args         erroredSymbolPeriodTlv          \
            interface_args                      interface                       \
        ]
    
    foreach {args_list_name args_list_type} $event_tlv_arg_lists {
        
        set tmp_args_list [set $args_list_name]
        
        set target_obj [ixNet getList $link_obj $args_list_type]
        
        if {$target_obj == ""} {
            if {$tmp_args_list != ""} {
                set tmp_status [::ixia::ixNetworkNodeAdd                            \
                        $link_obj                                                   \
                        $args_list_type                                             \
                        $tmp_args_list                                              \
                        -commit                                                     \
                    ]
                
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "Failed to configure $args_list_type. [keylget tmp_status log]"
                    return $tmp_status
                }
            }
        } else {
            if {[llength $target_obj] > 1} {
                set target_obj [lindex $target_obj 0]
            }
            
            if {$tmp_args_list != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $target_obj                                                 \
                        $tmp_args_list                                              \
                        -commit                                                     \
                    ]
                
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "Failed to configure $args_list_type. [keylget tmp_status log]"
                    return $tmp_status
                }
            }
        }
        
        
    }
    
    set org_specific_arg_lists [list                                            \
            organizationSpecificEventTlv_args    organizationSpecificEventTlv   \
            organizationSpecificOamPduData_args  organizationSpecificOamPduData \
        ]
    
    foreach {args_list_name args_list_type} $org_specific_arg_lists {
        
        set tmp_args_list [set $args_list_name]
        
        if {$tmp_args_list != ""} {
            
            set org_spec_obj [ixNet getList $link_obj $args_list_type]
            
            if {$org_spec_obj == ""} {
                
                # Organization specific object does not exist. Create it
                set tmp_status [::ixia::ixNetworkNodeAdd                        \
                        $link_obj                                               \
                        $args_list_type                                         \
                        $tmp_args_list                                          \
                        -commit                                                 \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "Failed to configure $args_list_type. [keylget tmp_status log]"
                    return $tmp_status
                }
            } else {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $org_spec_obj                                               \
                        $tmp_args_list                                              \
                        -commit                                                     \
                    ]
                
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "Failed to configure $args_list_type. [keylget tmp_status log]"
                    return $tmp_status
                }
            }
        }
    }
    
    if {[ixNet getAttribute $link_obj -updateRequired] == "true"} {
        if {[catch {ixNet exec sendUpdatedParameters $link_obj} retCode] || \
                ([string first "::ixNet::OK" $retCode] == -1)} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to update EFM configurations on the\
                    $port_handle port. Error code: $retCode."
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList information_oampdu_id         $port_handle
    keylset returnList event_notification_oampdu_id  $port_handle
    
    return $returnList
}


proc ::ixia::ixnetwork_efm_control {args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
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
    
    array set translate_action {
        start_event                     startEventPduTransmission
        stop_event                      stopEventPduTransmission
        restart_discovery               restartDiscovery
        send_loopback                   sendLoopback
        send_org_specific_pdu           sendOrgSpecificPdu
        send_variable_request           sendVariableRequest
    }
    
    foreach p_handle $port_handle {
        set tmp_status [check_efm_port $p_handle]
                
        if {[keylget tmp_status status] != $::SUCCESS} {
            return $tmp_status
        }
        
        set link_obj            [keylget tmp_status link_handle]
        set vport_objref        [keylget tmp_status vport_handle]
        set protocol_objref     [keylget tmp_status protocol_handle]
        
        set retries 60
        set portState  [ixNet getAttribute $vport_objref -state]
        set portStateD [ixNet getAttribute $vport_objref -stateDetail]
        while {($retries > 0) && ( \
                ($portStateD != "idle") || ($portState  == "busy") || ($portState == "down"))} {
            debug "Port state: $portState, $portStateD ..."
            after 1000
            set portState  [ixNet getAttribute $vport_objref -state]
            set portStateD [ixNet getAttribute $vport_objref -stateDetail]
            incr retries -1
        }
        debug "Port state: $portState, $portStateD ..."
        if {($portStateD != "idle") || ($portState == "busy") || ($portState == "down")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to $mode EFM on the\
                    $p_handle port. Port state is $portState, $portStateD."
            return $returnList
        }
        
        switch -- $action {
            "start" -
            "stop" {
                debug "ixNetworkExec [list $action $protocol_objref]"
                if {[catch {ixNetworkExec [list $action $protocol_objref]} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action EFM on the\
                            $p_handle port. Error code: $retCode."
                    return $returnList
                }
            }
            default {
                for {set retry 0} {$retry < 10} {incr retry} {
                    set run_state [ixNet getAttribute $protocol_objref -runningState]
                    debug "Link Oam running state: $run_state"
                    if {$run_state == "started"} {
                        break
                    }
                    
                    after 1000
                }
                
                if {$run_state != "started"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action EFM on the\
                            $p_handle port because EFM protocol is not runing.\
                            EFM protocol must be started with \
                            ::ixia::emulation_efm_control -action start before calling\
                            ::ixia::emulation_efm_control -action $action."
                    return $returnList
                }
                
                debug "ixNet exec $translate_action($action) $link_obj"
                if {[catch {ixNet exec $translate_action($action) $link_obj} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action EFM on the\
                            $p_handle port. Error code: $retCode."
                    return $returnList
                }
            }
        }
    }
    
    return $returnList
}


proc ::ixia::ixnetwork_efm_org_var_config {args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
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
    
    array set efm_options_map {
            organization_specific_info_tlv        organizationSpecificInfoTlv
            variable_response_database            variableResponseDatabase
            variable_descriptors                  varDescriptor
        }
    
    if {$mode == "modify"} {
            removeDefaultOptionVars $opt_args $args
    }

    if {$mode != "create"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode -handle parameter is mandatory."
            return $returnList
        }
        
        foreach single_handle $handle {
            if {![regexp -all {(^::ixNet::OBJ-/vport/protocols/linkOam/link:\d+/organizationSpecificInfoTlv:\d+$)|\
                               (^::ixNet::OBJ-/vport/protocols/linkOam/link:\d+/varDescriptor:\d+$)|\
                               (^::ixNet::OBJ-/vport/protocols/linkOam/link:\d+/variableResponseDatabase:\d+$)\
                            } $single_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Parameter -handle $single_handle is not a valid\
                    handle of type 'organization specific info tlv' | 'variable response database' |\
                    'variable descriptor'."
                return $returnList
            }
            
            if {[ixNet exists $single_handle] == "false" || [ixNet exists $single_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Parameter -handle $single_handle does not exist."
                return $returnList
            }
        }
        
        if {$mode == "modify"} {
            if {[regexp -all {^::ixNet::OBJ-/vport/protocols/linkOam/link:\d+/organizationSpecificInfoTlv:\d+$} $handle]} {
                set type "organization_specific_info_tlv"
            } elseif {[regexp -all {^::ixNet::OBJ-/vport/protocols/linkOam/link:\d+/variableResponseDatabase:\d+$} $handle]} {
                set type "variable_response_database"
            } elseif {[regexp -all {^::ixNet::OBJ-/vport/protocols/linkOam/link:\d+/varDescriptor:\d+$} $handle]} {
                set type "variable_descriptors"
            }
            
            if {[ixNet exists $single_handle] == "false" || [ixNet exists $single_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Parameter -handle $single_handle does not exist."
                return $returnList
            }
        }
    }
    
    switch -- $type {
        "organization_specific_info_tlv" {
            set config_params {
                    enabled             enabled         truth         _none
                    os_info_tlv_oui     oui             efm_hex       "os_info_tlv_oui_step 0xffffffff"
                    os_info_tlv_value   value           efm_hex       "os_info_tlv_value_step _no_limit"
                }
        }
        "variable_descriptors" {
            set config_params {
                    variable_branch     variableBranch   efm_hex      "variable_branch_step 0xff"
                    variable_leaf       variableLeaf     efm_hex      "variable_leaf_step 0xffff"
                }
        }
        "variable_response_database" {
            set config_params {
                    enabled             enabled             truth        _none
                    variable_branch     variableBranch      efm_hex      "variable_branch_step 0xff"
                    variable_leaf       variableLeaf        efm_hex      "variable_leaf_step 0xffff"
                    variable_indication variableIndication  truth        _none
                    variable_value      variableValue       efm_hex      "variable_value_step _no_limit"
                    variable_width      variableWidth       efm_dec      "variable_width_step 128"
                }
        }
    }
    
    array set truth {1 true 0 false enable true disable false}
    
    switch -- $mode {
        "create" {
            set enabled 1
            
            if {![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode, parameter -port_handle is mandatory."
                return $returnList
            }
            
            set tmp_status [check_efm_port $port_handle]
            
            if {[keylget tmp_status status] != $::SUCCESS} {
                return $tmp_status
            }
            
            set link_obj            [keylget tmp_status link_handle]
            set vport_objref        [keylget tmp_status vport_handle]
            set protocol_objref     [keylget tmp_status protocol_handle]
            
            # Remove all md meg from this bridge if reset is present
            if {[info exists reset]} {
                set result [ixNetworkNodeRemoveList $bridge_handle \
                        [list [list child remove $efm_options_map($type)] {} ] -commit]
                if {[keylget result status] == $::FAILURE} {
                    return $result
                }
            }
            set ret_handle_list ""
            for {set counter 0} {$counter < $count} {incr counter} {
                
                set ixn_args ""
                
                foreach {hlt_param ixn_param p_type extensions} $config_params {

                    if {[info exists $hlt_param]} {
                        
                        set hlt_param_value [set $hlt_param]

                        switch -- $p_type {
                            value {
                                set ixn_param_value $hlt_param_value
                            }
                            truth {
                                set ixn_param_value $truth($hlt_param_value)
                            }
                            translate {
                                if {[info exists efm_options_map($hlt_param_value)]} {
                                    set ixn_param_value $efm_options_map($hlt_param_value)
                                } else {
                                    set ixn_param_value $hlt_param_value
                                }
                            }
                            efm_hex {
                                set p1 [lindex $extensions 0]
                                set p2 [lindex $extensions 1]
                                if {[info exists $p1]} {
                                    set ixn_param_value [efm_increment_hex_field \
                                                                $hlt_param_value \
                                                                [set $p1]        \
                                                                $counter         \
                                                                $p2        \
                                                        ]
                                } else {
                                    set ixn_param_value [efm_increment_hex_field \
                                                                $hlt_param_value \
                                                                [set $p1]        \
                                                                $counter         \
                                                                0x0              \
                                                        ]
                                }
                            }
                            efm_dec {
                                set p1 [lindex $extensions 0]
                                set p2 [lindex $extensions 1]
                                if {[info exists $p1]} {
                                    set ixn_param_value [efm_increment_dec_field \
                                                                $hlt_param_value \
                                                                [set $p1]        \
                                                                $counter         \
                                                                $p2        \
                                                        ]
                                } else {
                                    set ixn_param_value [efm_increment_dec_field \
                                                                $hlt_param_value \
                                                                [set $p1]        \
                                                                $counter         \
                                                                0x0              \
                                                        ]
                                }
                            }
                        }
                        
                        if {[llength $ixn_param_value] > 1} {
                            append ixn_args "-$ixn_param \{$ixn_param_value\} "
                        } else {
                            append ixn_args "-$ixn_param $ixn_param_value "
                        }
                    }
                }
                
                if {$ixn_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
                            $link_obj                                                   \
                            $efm_options_map($type)                                     \
                            $ixn_args                                                   \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        return $tmp_status
                    }
                    
                    set ret_handle [keylget tmp_status node_objref]
                    
                    lappend ret_handle_list $ret_handle
                }
            }
            
            keylset returnList handle $ret_handle_list
        }
        "modify" {
            if {[llength $handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Only one handle can be modified with one \
                        procedure call. Parameter -handle contains a list of handles."
                return $returnList
            }
            
            set ixn_args ""
            
            foreach {hlt_param ixn_param p_type extensions} $config_params {

                if {[info exists $hlt_param]} {
                    
                    set hlt_param_value [set $hlt_param]

                    switch -- $p_type {
                        value {
                            set ixn_param_value $hlt_param_value
                        }
                        truth {
                            set ixn_param_value $truth($hlt_param_value)
                        }
                        translate {
                            if {[info exists efm_options_map($hlt_param_value)]} {
                                set ixn_param_value $efm_options_map($hlt_param_value)
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                        }
                        efm_hex {
                            set ixn_param_value [::ixia::hex2list $hlt_param_value]
                        }
                        efm_dec {
                            set ixn_param_value $hlt_param_value
                        }
                    }
                    
                    if {[llength $ixn_param_value] > 1} {
                        append ixn_args "-$ixn_param \{$ixn_param_value\} "
                    } else {
                        append ixn_args "-$ixn_param $ixn_param_value "
                    }
                }
            }
            
            if {$ixn_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $handle                                                     \
                        $ixn_args                                                   \
                        -commit                                                     \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    return $tmp_status
                }
            }
        }
        "remove" {
            foreach single_handle $handle {
                debug "ixNet remove $single_handle"
                if {[ixNet remove $single_handle] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to remove handle $single_handle."
                    return $returnList
                }
            }
                
            debug "ixNet commit"
            if {[ixNet commit] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to remove -handle $handle."
                return $returnList
            }
        }
        "enable" -
        "disable" {
            foreach single_handle $handle {
                if {[regexp -all {^::ixNet::OBJ-/vport/protocols/linkOam/link:\d+/varDescriptor:\d+$} $handle]} {
                    puts "\nWARNING: Unable to $mode handle $single_handle because handles of type 'variable_descriptors'\
                            do not support -mode enable and disable.\n"
                    continue
                }
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $single_handle                                              \
                        [list -enabled $truth($mode)]                               \
                        -commit                                                     \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    return $tmp_status
                }
            }
        }
    }
    
    return $returnList
}

proc ::ixia::ixnetwork_efm_stat {args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args  -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    
    if {$action == "reset"} {
        puts "\nWARNING in emulation_efm_stat: -action reset cannot be performed for EFM implementation \
                using IxNetwork Tcl API.\n"
        keylset returnList status $::SUCCESS
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
    
    keylset returnList port_handle $port_handle
    
    # Set stats that are not supported to N/A
    set stats_na {
            statistics.oampdu_count.total_rx
        }
#     
    foreach na_stat $stats_na {
        keylset returnList $na_stat "N/A"
    }
    
    set tmp_status [check_efm_port $port_handle]
            
    if {[keylget tmp_status status] != $::SUCCESS} {
        return $tmp_status
    }
    
    set link_obj            [keylget tmp_status link_handle]
    set vport_objref        [keylget tmp_status vport_handle]
    set protocol_objref     [keylget tmp_status protocol_handle]    
    
    set stat_keys_disc_info {
            statistics.mac_remote                   remoteMacAddress
            statistics.oam_mode                     remoteMode
            statistics.unidir_enabled               remoteUnidirectionalSupport
            statistics.remote_loopback_enabled      remoteLoopbackSupport
            statistics.link_events_enabled          remoteLinkEvent
            statistics.variable_retrieval_enabled   remoteVariableRetrieval
            statistics.oampdu_size                  remoteMaxPduSize
            statistics.oui_value                    remoteOui
            statistics.vsi_value                    remoteVendorSpecificInfo
            statistics.remote_critical_event        remoteCriticalEvent
            statistics.remote_dying_gasp            remoteDyingGasp
            statistics.remote_evaluating            remoteEvaluating
            statistics.remote_link_fault            remoteLinkFault
            statistics.remote_mux_action            remoteMuxAction
            statistics.remote_oam_version           remoteOamVersion
            statistics.remote_parser_action         remoteParserAction
            statistics.remote_revision              remoteRevision
            statistics.remote_stable                remoteStable
            
        }
    
    set efm_status [::ixia::get_efm_learned_info                   \
                                $stat_keys_disc_info                \
                                $link_obj                           \
                                "refreshDiscLearnedInfo"            \
                                "isDiscLearnedInfoRefreshed"        \
                                "discoveredLearnedInfo"             \
                                "returnList"                        ]
    if {[keylget efm_status status] != $::SUCCESS} {
        keylset efm_status log "Failed to get Discovered Learned Info. [keylget efm_status log]"
        return $efm_status
    }
    
    set translate_stats {
        statistics.unidir_enabled
        statistics.remote_loopback_enabled
        statistics.link_events_enabled
        statistics.variable_retrieval_enabled
    }
    
    foreach translate_key $translate_stats {
        if {[keylget returnList $translate_key] == "true"} {
            keylset returnList $translate_key "Supported"
        } elseif {[keylget returnList $translate_key] == "false"} {
            keylset returnList $translate_key "Not Supported"
        }
    }
    
    set stat_keys_var_req_info {
            statistics.variable_request.branch          variableBranch
            statistics.variable_request.indication      variableIndication
            statistics.variable_request.leaf            variableLeaf
            statistics.variable_request.value           variableValue
            statistics.variable_request.width           variableWidth
        }
    
    set efm_status [::ixia::get_efm_learned_info                        \
                                $stat_keys_var_req_info                 \
                                $link_obj                               \
                                "sendVariableRequest"                   \
                                "isVariableRequestLearnedInfoRefreshed" \
                                "variableRequestLearnedInfo"            \
                                "returnList"                            ]
    if {[keylget efm_status status] != $::SUCCESS} {
        keylset efm_status log "Failed to get Variable Request Learned Info. [keylget efm_status log]"
        return $efm_status
    }
    
    set stat_keys_events {
            statistics.alarms.errored_frame_period_threshold            remoteFramePeriodThreshold
            statistics.alarms.errored_frame_period_window               remoteFramePeriodWindow
            statistics.alarms.errored_frame_seconds_summary_threshold   remoteFrameSecSumThreshold
            statistics.alarms.errored_frame_seconds_summary_window      remoteFrameSecSumWindow
            statistics.alarms.errored_frame_threshold                   remoteFrameThreshold
            statistics.alarms.errored_frame_window                      remoteFrameWindow
            statistics.alarms.errored_symbol_period_threshold           remoteSymbolPeriodThreshold
            statistics.alarms.errored_symbol_period_window              remoteSymbolPeriodWindow
        }
    
    set efm_status [::ixia::get_efm_learned_info                        \
                                $stat_keys_events                       \
                                $link_obj                               \
                                "refreshEventNotificationLearnedInfo"   \
                                "isEventNotificationLearnedInfoRefreshed"\
                                "eventNotificationLearnedInfo"          \
                                "returnList"                            ]
    if {[keylget efm_status status] != $::SUCCESS} {
        keylset efm_status log "Failed to get Variable Request Learned Info. [keylget efm_status log]"
        return $efm_status
    }
    
    set efm_status [::ixia::get_efm_aggregate_stats $port_handle "returnList"]
    if {[keylget efm_status status] != $::SUCCESS} {
        keylset efm_status log "Failed to get Variable Request Learned Info. [keylget efm_status log]"
        return $efm_status
    }
    
    return $returnList
}
