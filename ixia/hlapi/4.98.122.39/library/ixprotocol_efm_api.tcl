proc ::ixia::ixprotocol_efm_config {args man_args opt_args} {

    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    array set truth {1 true 0 false enable true disable false}

    foreach {ch ca po} [split $port_handle /] {}
    
    # Enable linkOam on port

    debug "protocolServer get $ch $ca $po"
    if {[set retCode [protocolServer get $ch $ca $po]]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Call to protocolServer\
                get $ch $ca $po failed.\
                Return code was $retCode."
        return $returnList
    }
    
    debug "protocolServer cget -enableOamService"
    if {[protocolServer cget -enableOamService] != 1} {
        debug "protocolServer config -enableOamService true"
        protocolServer config -enableOamService true
        
        debug "protocolServer set $ch $ca $po"
        if {[set retCode [protocolServer set $ch $ca $po]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enable EFM Service. Call to protocolServer\
                    set $ch $ca $po failed.\
                    Return code was $retCode."
            return $returnList
        }
        
        ::ixia::addPortToWrite $ch/$ca/$po
    }
    
    debug "stat get allStats $ch $ca $po"
    if {[set retCode [stat get allStats $ch $ca $po]]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Call to protocolServer\
                get $ch $ca $po failed.\
                Return code was $retCode."
        return $returnList
    }
    
    debug "stat cget -enableOamStats"
    if {[stat cget -enableOamStats] != 1} {
        debug "stat config -enableOamStats true"
        stat config -enableOamStats true
        
        debug "stat set $ch $ca $po"
        if {[set retCode [stat set $ch $ca $po]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enable EFM statistics. Call to stat set\
                    $ch $ca $po failed.\
                    Return code was $retCode."
            return $returnList
        }
        
        ::ixia::addPortToWrite $ch/$ca/$po
    }
    
    # Check if a link object is already configured on this port
    debug "linkOamServer select $ch $ca $po"
    if {[set retCode [linkOamServer select $ch $ca $po]]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Call to linkOamServer\
                select $ch $ca $po failed.\
                Return code was $retCode."
        return $returnList
    }
    
    # Flag to indicate if a link was already configured and is being modified
    set link_obj_modify 1
    debug "linkOamServer getLink"
    if {[linkOamServer getLink]} {
        # There's no link configured. use addLink instead of setLink when configuring efmLink
        set link_obj_modify 0
        set link_obj efmlink_${ch}_${ca}_${po}
    }
    
    
    array set efm_options_map {
        single                          single
        periodic                        periodic
        enable_oam_remote_loopback      enableLoopback
        disable_oam_remote_loopback     disableLoopback
        active                          active
        passive                         passive
    }
    
    set efm_param_map {
        intf_enable                      enabled                          truth       linkOamInterface
        intf_handle                      protocolInterfaceDescription     value       linkOamInterface
        critical_event                   enableCriticalEvent              truth       _none
        dying_gasp                       enableDyingGasp                  truth       _none
        enabled_efpt                     enabled                          truth       linkOamPeriodTlv
        error_frame_period_count         errFrames                        value       linkOamPeriodTlv
        error_frame_period_threshold     errFrameThreshold                value       linkOamPeriodTlv
        error_frame_period_window        errFrameWindow                   value       linkOamPeriodTlv
        enabled_eft                      enabled                          truth       linkOamFrameTlv
        error_frame_count                errFrames                        value       linkOamFrameTlv
        error_frame_threshold            errFrameThreshold                value       linkOamFrameTlv
        error_frame_window               errFrameWindow                   value       linkOamFrameTlv
        enabled_efsst                    enabled                          truth       linkOamSSTlv
        error_frame_summary_count        errFrameSecSum                   value       linkOamSSTlv
        error_frame_summary_threshold    errFrameSecSumThreshold          value       linkOamSSTlv
        error_frame_summary_window       errFrameSecSumWindow             value       linkOamSSTlv
        enabled_espt                     enabled                          truth       linkOamSymTlv
        error_symbol_period_count        errSymbols                       value       linkOamSymTlv
        error_symbol_period_threshold    errSymbThreshold                 value       linkOamSymTlv
        error_symbol_period_window       errSymbWindow                    value       linkOamSymTlv
        link_events                      supportsInterpretingLinkEvents   truth       _none
        link_fault                       enableLinkFault                  truth       _none
        mac_local                        macAddress                       mac         _none
        oui_value                        oui                              blob        _none
        sequence_id                      sequenceNumber                   value_check _none
        overrideSequenceNumber           overrideSequenceNumber           truth       _none
        size                             maxOamPduSize                    value       _none
        variable_retrieval               supportsVariableRetrieval        truth       _none
        vsi_value                        vendorSpecificInformation        blob        _none
        disable_information_pdu_tx       disableInformationPduTx          truth       _none
        disable_non_information_pdu_tx   disableNonInformationPduTx       truth       _none
        enable_loopback_response         enableLoopbackResponse           truth       _none
        enable_variable_response         enableVariableResponse           truth       _none
        event_interval                   eventInterval                    value       _none
        information_pdu_rate             informationPduCountPerSecond     value       _none
        link_event_tx_mode               linkEventTxMode                  translate   _none
        local_lost_link_timer            localLostLinkTimer               value       _none
        loopback_cmd                     loopbackCommand                  translate   _none
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
        enabled_oset                     enabled                          truth       linkOamOrgEventTlv
        os_event_tlv_oui                 oui                              hex2blob    linkOamOrgEventTlv
        os_event_tlv_value               value                            hex2blob    linkOamOrgEventTlv
        os_oampdu_data_oui               oui                              hex2blob    linkOamOrgTlv
        os_oampdu_data_value             value                            hex2blob    linkOamOrgTlv
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
                "linkOamPeriodTlv" {
                    set enabled_efpt 1
                }
                "linkOamFrameTlv" {
                    set enabled_eft 1
                }
                "linkOamSSTlv" {
                    set enabled_efsst 1
                }
                "linkOamSymTlv" {
                    set enabled_espt 1
                }
                "linkOamOrgEventTlv" {
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
    
    set protocol_intf_args "-ip_version 4 -ip_address 0.0.0.0 -gateway_ip_address 0.0.0.0 -netmask 255.255.255.0"
    foreach {option value_name} $protocol_intf_options {
        if {[info exists $value_name]} {
            append protocol_intf_args " $option [set $value_name]"
        }
    }
    
    if {!$link_obj_modify} {
        debug "interfaceTable select $ch $ca $po"
        if {[interfaceTable select $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed on call to interfaceTable select\
                    $ch $ca $po."
            return $returnList
        }
        
        debug "interfaceTable getFirstInterface"
        if {[interfaceTable getFirstInterface] != 0} {
            # Create the necessary interfaces because no other interfaces exist on this port
            debug "ixia::protocol_interface_config $protocol_intf_args"
            set intf_status [eval ixia::protocol_interface_config \
                    $protocol_intf_args]
        
            if {[keylget intf_status status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to create the needed protocol interfaces\
                        for the EFM configuration. [keylget intf_status log]"
                return $returnList
            }
        
            set intf_handle [keylget intf_status description]
            
        } else {
            # Use the first interface as linkOamInterface
            debug "interfaceEntry cget -description"
            set intf_handle \{[interfaceEntry cget -description]\}
        }
        set intf_enable 1
    }

    
    set ixn_link_args                       "-enabled 1"
    set linkOamPeriodTlv_args               ""
    set linkOamFrameTlv_args                ""
    set linkOamSSTlv_args                   ""
    set linkOamSymTlv_args                  ""
    set linkOamOrgEventTlv_args             ""
    set linkOamOrgTlv_args                  ""
    set linkOamInterface_args               ""
    
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
                blob {
                    set ixn_param_value \{[::ixia::hex2list 0x$hlt_param_value]\}
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
        
        if {!$link_obj_modify} {
            debug "linkOamLink setDefault"
            linkOamLink setDefault
        }
        
        set tmpCmd "linkOamLink config $ixn_link_args"
        debug "$tmpCmd"
        eval $tmpCmd
        
        if {!$link_obj_modify} {
            debug "linkOamServer addLink $link_obj"
            if {[linkOamServer addLink $link_obj]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure EFM Link on port $ch/$ca/$po."
                return $returnList
            }
        } else {
            debug "linkOamServer setLink"
            if {[linkOamServer setLink]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to update EFM Link configuration on port $ch/$ca/$po."
                return $returnList
            }
        }
    }
    
    
    set event_tlv_arg_lists [list                                                                   \
            linkOamPeriodTlv_args          linkOamPeriodTlv    ErroredFramePeriodEventTlv      \
            linkOamFrameTlv_args           linkOamFrameTlv     ErroredFrameEventTlv            \
            linkOamSSTlv_args              linkOamSSTlv        ErroredFrameSSEventTlv          \
            linkOamSymTlv_args             linkOamSymTlv       ErroredSymbolPeriodEventTlv     \
            linkOamOrgEventTlv_args        linkOamOrgEventTlv  OrgSpecEventTlv                 \
        ]
    
    foreach {args_list_name args_list_type arg_cmd} $event_tlv_arg_lists {
        
        set tmp_args_list [set $args_list_name]
        
        if {[info exists $args_list_name] && $tmp_args_list != ""} {
        
            debug "linkOamLink get$arg_cmd"
            if {[linkOamLink get$arg_cmd]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get $arg_cmd on port $ch/$ca/$po."
                return $returnList
            }
            
            if {!$link_obj_modify} {
                debug "$args_list_type setDefault"
                $args_list_type setDefault
            }
            
            set tmpCmd "$args_list_type configure $tmp_args_list"
            debug $tmpCmd
            eval $tmpCmd
            
            debug "linkOamLink set$arg_cmd"
            if {[linkOamLink set$arg_cmd]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set $arg_cmd on port $ch/$ca/$po."
                return $returnList
            }
            
            set ::ixia::no_efm_event_trigger 0
            
        }
    }
    
    if {!$link_obj_modify && [linkOamLink getFirstInterface]} {
        debug "linkOamInterface setDefault"
        linkOamInterface setDefault
        
        if {[info exists linkOamInterface_args] && $linkOamInterface_args != ""} {
            set tmpCmd "linkOamInterface configure $linkOamInterface_args"
            debug $tmpCmd
            eval $tmpCmd
        }
        
        debug "linkOamLink addInterface intf_${ch}_${ca}_${po}"
        if {[linkOamLink addInterface intf_${ch}_${ca}_${po}]} {
#             keylset returnList status $::FAILURE
#             keylset returnList log "Failed to add EFM Interface on EFM Link \
#                     efmlink_${ch}_${ca}_${po}; port $ch/$ca/$po."
#             return $returnList
        }
    
    }
     
    
    set org_specific_arg_lists [list                           \
            linkOamOrgTlv_args  linkOamOrgTlv        OrgSpecTlv\
        ]
    
    if {[info exists linkOamOrgTlv_args] && $linkOamOrgTlv_args != ""} {
        if {!$link_obj_modify} {
            debug "linkOamLink clearAllOrgSpecTlvs"
            if {[linkOamLink clearAllOrgSpecTlvs]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to remove EFM OrgSpecTlv from EFM Link \
                        efmlink_${ch}_${ca}_${po}; port $ch/$ca/$po."
                return $returnList
            }
            
            debug "linkOamOrgTlv setDefault"
            linkOamOrgTlv setDefault
            

        }
        
        debug "linkOamLink showOrgSpecTlvNames"
        set orgName [linkOamLink showOrgSpecTlvNames]
        
        if {$orgName != ""} {
            debug "linkOamLink getFirstOrgSpecTlv"
            if {[linkOamLink getFirstOrgSpecTlv]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get first EFM OrgSpecTlv on EFM Link \
                        efmlink_${ch}_${ca}_${po}; port $ch/$ca/$po."
                return $returnList
            }
        }
        
        set tmpCmd "linkOamOrgTlv config $linkOamOrgTlv_args"
        debug $tmpCmd
        eval $tmpCmd
        
        if {$orgName != ""} {
            debug "linkOamLink setOrgSpecTlv $orgName"
            if {[linkOamLink setOrgSpecTlv [string trim $orgName]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set EFM OrgSpecTlv on EFM Link \
                        efmlink_${ch}_${ca}_${po}; port $ch/$ca/$po."
                return $returnList
            }
        } else {
            debug "linkOamLink addOrgSpecTlv org_spec_tlv_${ch}_${ca}_${po}"
            if {[linkOamLink addOrgSpecTlv org_spec_tlv_${ch}_${ca}_${po}]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to add EFM OrgSpecTlv on EFM Link \
                        efmlink_${ch}_${ca}_${po}; port $ch/$ca/$po."
                return $returnList
            }
        }
    }
    
    debug "linkOamLink cget -updateRequired"
    if {[linkOamLink cget -updateRequired] && $link_obj_modify} {
        debug "linkOamLink sendUpdatedParameters --> linkOamLink cget -updateRequired == [linkOamLink cget -updateRequired]; link_obj_modify == $link_obj_modify"
        if {[linkOamLink sendUpdatedParameters]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to update EFM configurations on the\
                    $port_handle port."
            return $returnList
        }
    }
    
    if {!$link_obj_modify} {
        set tmpCmd "linkOamServer setLink $link_obj"
    } else {
        set tmpCmd "linkOamServer setLink"
    }
    debug $tmpCmd
    if {[eval $tmpCmd]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to $tmpCmd on the\
                $port_handle port."
        return $returnList
    }
    
    debug "linkOamServer set"
    if {[linkOamServer set]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to linkOamServer set on the\
                $port_handle port."
        return $returnList
    }
    
    if {![info exists no_write]} {
        debug "linkOamServer write"
        if {[linkOamServer write]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to linkOamServer write on the\
                    $port_handle port."
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList information_oampdu_id         $port_handle
    keylset returnList event_notification_oampdu_id  $port_handle
    
    return $returnList
}


proc ::ixia::ixprotocol_efm_control {args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args  -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    
    array set translate_action {
        start_event                     startEventPDUTransmission
        stop_event                      stopEventPDUTransmission
        restart_discovery               restartDiscovery
        send_loopback                   sendLoopback
        send_org_specific_pdu           sendOrgSpecificPDU
        send_variable_request           requestVariableResponseLearnedInfo
    }
    
    foreach p_handle $port_handle {
    
        foreach {ch ca po} [split $p_handle /] {}
    
        debug "protocolServer get $ch $ca $po"
        if {[set retCode [protocolServer get $ch $ca $po]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Call to protocolServer\
                    get $ch $ca $po failed.\
                    Return code was $retCode."
            return $returnList
        }
        
        # Check if a link object is already configured on this port
        debug "linkOamServer select $ch $ca $po"
        if {[set retCode [linkOamServer select $ch $ca $po]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Call to linkOamServer\
                    select $ch $ca $po failed. Procedure\
                    ::ixia::emulation_efm_config must be called on port \
                    $p_handle before this procedure."
            return $returnList
        }
        
        debug "linkOamServer getLink"
        if {[linkOamServer getLink]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Call to linkOamServer\
                    getLink failed. No EFM Link exists on the configured port $p_handle.\
                    Procedure ::ixia::emulation_efm_config must be called on port \
                    $p_handle before this procedure."
            return $returnList
        }
        
        set link_obj            linkOamLink
        
        switch -- $action {
            "start" -
            "stop" {
                set p_ref [list [list $ch $ca $po]]
                set tmpCmd "ix[string totitle $action]Oam p_ref"
                debug $tmpCmd
                if {[eval $tmpCmd]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action EFM on the\
                            $p_handle port. Error code: $retCode."
                    return $returnList
                }
            }
            default {
                
                set tmpCmd "linkOamLink $translate_action($action)"
                debug $tmpCmd
                if {[eval $tmpCmd]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action EFM on the\
                            $p_handle port. Error code: $retCode."
                    return $returnList
                }
            }
        }
        
        debug "linkOamServer write"
        if {[linkOamServer write]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to linkOamServer write on the\
                    $p_handle port."
            return $returnList
        }
    }
    
    return $returnList
}


proc ::ixia::ixprotocol_efm_org_var_config {args man_args opt_args} {

    variable efm_global_counters

    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    
    array set efm_options_map {
            organization_specific_info_tlv        linkOamOrgInfoTlv
            variable_response_database            linkOamVarContainer
            variable_descriptors                  linkOamVarDescriptor
            organization_specific_info_tlv,add    addOrgSpecInfoTlv
            variable_response_database,add        addVariableResponseDbContainer
            variable_descriptors,add              addVarDescriptor
            organization_specific_info_tlv,clear  clearAllOrgSpecInfoTlvs
            variable_response_database,clear      clearAllVariableResponseDbContainer
            variable_descriptors,clear            clearAllVarDescriptors
            organization_specific_info_tlv,get    getOrgSpecInfoTlv
            variable_response_database,get        getVariableResponseDbContainer
            variable_descriptors,get              getVarDescriptor
            organization_specific_info_tlv,set    setOrgSpecInfoTlv
            variable_response_database,set        setVariableResponseDbContainer
            variable_descriptors,set              setVarDescriptor
            organization_specific_info_tlv,remove delOrgSpecInfoTlv
            variable_response_database,remove     delVariableResponseDbContainer
            variable_descriptors,remove           delVarDescriptor
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
            if {![regexp -all {(^linkOamOrgInfoTlv_\d+_\d+_\d+_\d+$)|(^linkOamVarContainer_\d+_\d+_\d+_\d+$)|(^linkOamVarDescriptor_\d+_\d+_\d+_\d+$)} $single_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Parameter -handle $single_handle is not a valid\
                    handle of type 'organization specific info tlv' | 'variable response database' |\
                    'variable descriptor'."
                return $returnList
            }
        }
        
        if {$mode == "modify"} {
            if {[regexp -all {^linkOamOrgInfoTlv_\d+_\d+_\d+_\d+$} $handle]} {
                set type "organization_specific_info_tlv"
            } elseif {[regexp -all {^linkOamVarContainer_\d+_\d+_\d+_\d+$} $handle]} {
                set type "variable_response_database"
            } elseif {[regexp -all {^linkOamVarDescriptor_\d+_\d+_\d+_\d+$} $handle]} {
                set type "variable_descriptors"
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
            
            foreach {ch ca po} [split $port_handle /] {}
            
            debug "protocolServer get $ch $ca $po"
            if {[set retCode [protocolServer get $ch $ca $po]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Call to protocolServer\
                        get $ch $ca $po failed.\
                        Return code was $retCode."
                return $returnList
            }
            
            # Check if a link object is already configured on this port
            debug "linkOamServer select $ch $ca $po"
            if {[set retCode [linkOamServer select $ch $ca $po]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Call to linkOamServer\
                        select $ch $ca $po failed. Procedure\
                        ::ixia::emulation_efm_config must be called on port \
                        $port_handle before this procedure."
                return $returnList
            }
            
            debug "linkOamServer getLink"
            if {[linkOamServer getLink]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Call to linkOamServer\
                        getLink failed. No EFM Link exists on the configured port $port_handle.\
                        Procedure ::ixia::emulation_efm_config must be called on port \
                        $port_handle before this procedure."
                return $returnList
            }
            
            # Remove all md meg from this bridge if reset is present
            if {[info exists reset]} {
                
                set tmpCmd "linkOamLink $efm_options_map($type,clear)"
                debug $tmpCmd
                
                if {[eval $tmpCmd]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to reset $type."
                    return $returnList
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
                    
                    set tmpCmd "$efm_options_map($type) setDefault"
                    debug $tmpCmd
                    eval $tmpCmd
                    
                    set tmpCmd "$efm_options_map($type) config $ixn_args"
                    debug $tmpCmd
                    eval $tmpCmd
                    
                    set tmpCmd "linkOamLink $efm_options_map($type,add) \
                            $efm_options_map($type)_${ch}_${ca}_${po}_$efm_global_counters($type)"
                    debug $tmpCmd
                    
                    if {[eval $tmpCmd]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to add $type."
                        return $returnList
                    }
                    
                    set ret_handle "$efm_options_map($type)_${ch}_${ca}_${po}_$efm_global_counters($type)"
                    
                    lappend ret_handle_list $ret_handle
                    
                    incr efm_global_counters($type)
                }
            }
            
            debug "linkOamServer setLink"
            if {[linkOamServer setLink]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to linkOamServer setLink on the\
                        $port_handle port."
                return $returnList
            }
            
            debug "linkOamServer set"
            if {[linkOamServer set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to linkOamServer set on the\
                        $port_handle port."
                return $returnList
            }
            
            debug "linkOamServer write"
            if {[linkOamServer write]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to linkOamServer write on the\
                        $port_handle port."
                return $returnList
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
            
            regexp -all {^[a-zA-Z]+_(\d+)_(\d+)_(\d+)_(\d+)$} $handle {} ch ca po {} 
            set port_handle $ch/$ca/$po
            
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
                
                debug "protocolServer get $ch $ca $po"
                if {[set retCode [protocolServer get $ch $ca $po]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Call to protocolServer\
                            get $ch $ca $po failed.\
                            Return code was $retCode."
                    return $returnList
                }
                
                # Check if a link object is already configured on this port
                debug "linkOamServer select $ch $ca $po"
                if {[set retCode [linkOamServer select $ch $ca $po]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Call to linkOamServer\
                            select $ch $ca $po failed. Procedure\
                            ::ixia::emulation_efm_config must be called on port \
                            $port_handle before this procedure."
                    return $returnList
                }
                
                debug "linkOamServer getLink"
                if {[linkOamServer getLink]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Call to linkOamServer\
                            getLink failed. No EFM Link exists on the configured port $port_handle.\
                            Procedure ::ixia::emulation_efm_config must be called on port \
                            $port_handle before this procedure."
                    return $returnList
                }
                
                set tmpCmd "linkOamLink $efm_options_map($type,get) $handle"
                debug $tmpCmd
                if {[eval $tmpCmd]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $tmpCmd."
                    return $returnList
                }
                
                set tmpCmd "$efm_options_map($type) configure $ixn_args"
                debug $tmpCmd
                eval $tmpCmd
                
                set tmpCmd "linkOamLink $efm_options_map($type,set) $handle"
                debug $tmpCmd
                if {[eval $tmpCmd]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $tmpCmd."
                    return $returnList
                }
                
                debug "linkOamServer setLink"
                if {[linkOamServer setLink]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to linkOamServer setLink on the\
                            $port_handle port."
                    return $returnList
                }
                
                debug "linkOamServer set"
                if {[linkOamServer set]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to linkOamServer set on the\
                            $port_handle port."
                    return $returnList
                }
                
                debug "linkOamServer write"
                if {[linkOamServer write]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to linkOamServer write on the\
                            $port_handle port."
                    return $returnList
                }

            }
        }
        "remove" {
            
            set previousPHandle "_placeholder_"
            
            foreach single_handle $handle {
            
                if {[regexp -all {^linkOamOrgInfoTlv_\d+_\d+_\d+_\d+$} $single_handle]} {
                    set type "organization_specific_info_tlv"
                } elseif {[regexp -all {^linkOamVarContainer_\d+_\d+_\d+_\d+$} $single_handle]} {
                    set type "variable_response_database"
                } elseif {[regexp -all {^linkOamVarDescriptor_\d+_\d+_\d+_\d+$} $single_handle]} {
                    set type "variable_descriptors"
                }

                regexp -all {^[a-zA-Z]+_(\d+)_(\d+)_(\d+)_(\d+)$} $single_handle {} ch ca po {}
                set port_handle $ch/$ca/$po
                set currentPHandle $ch/$ca/$po
                
                if {$currentPHandle != $previousPHandle} {
                    
                    if {$previousPHandle != "_placeholder_"} {
                        debug "linkOamServer setLink"
                        if {[linkOamServer setLink]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to linkOamServer setLink on the\
                                    $port_handle port."
                            return $returnList
                        }
                        
                        debug "linkOamServer set"
                        if {[linkOamServer set]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to linkOamServer set on the\
                                    $port_handle port."
                            return $returnList
                        }
                        
                        debug "linkOamServer write"
                        if {[linkOamServer write]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to linkOamServer write on the\
                                    $port_handle port."
                            return $returnList
                        }
                    }
                    
                    debug "protocolServer get $ch $ca $po"
                    if {[set retCode [protocolServer get $ch $ca $po]]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Call to protocolServer\
                                get $ch $ca $po failed.\
                                Return code was $retCode."
                        return $returnList
                    }
                    
                    # Check if a link object is already configured on this port
                    debug "linkOamServer select $ch $ca $po"
                    if {[set retCode [linkOamServer select $ch $ca $po]]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Call to linkOamServer\
                                select $ch $ca $po failed. Procedure\
                                ::ixia::emulation_efm_config must be called on port \
                                $port_handle before this procedure."
                        return $returnList
                    }
                    
                    debug "linkOamServer getLink"
                    if {[linkOamServer getLink]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Call to linkOamServer\
                                getLink failed. No EFM Link exists on the configured port $port_handle.\
                                Procedure ::ixia::emulation_efm_config must be called on port \
                                $port_handle before this procedure."
                        return $returnList
                    }
                }
                
                set tmpCmd "linkOamLink $efm_options_map($type,remove) $single_handle"
                debug $tmpCmd
                if {[eval $tmpCmd]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $tmpCmd."
                    return $returnList
                }

                set previousPHandle $currentPHandle
                
                if {[lindex $handle end] == $single_handle} {
                    debug "linkOamServer setLink"
                    if {[linkOamServer setLink]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to linkOamServer setLink on the\
                                $port_handle port."
                        return $returnList
                    }
                    
                    debug "linkOamServer set"
                    if {[linkOamServer set]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to linkOamServer set on the\
                                $port_handle port."
                        return $returnList
                    }
                    
                    debug "linkOamServer write"
                    if {[linkOamServer write]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to linkOamServer write on the\
                                $port_handle port."
                        return $returnList
                    }
                }
            }
        }
        "enable" -
        "disable" {
            
            set previousPHandle "_placeholder_"
            
            foreach single_handle $handle {
                if {[regexp -all {^linkOamVarDescriptor_\d+_\d+_\d+_\d+$} $handle]} {
                    puts "\nWARNING: Unable to $mode handle $single_handle because handles of type 'variable_descriptors'\
                            do not support -mode enable and disable.\n"
                    continue
                }
                
                if {[regexp -all {^linkOamOrgInfoTlv_\d+_\d+_\d+_\d+$} $single_handle]} {
                    set type "organization_specific_info_tlv"
                } elseif {[regexp -all {^linkOamVarContainer_\d+_\d+_\d+_\d+$} $single_handle]} {
                    set type "variable_response_database"
                } elseif {[regexp -all {^linkOamVarDescriptor_\d+_\d+_\d+_\d+$} $single_handle]} {
                    set type "variable_descriptors"
                }

                regexp -all {^[a-zA-Z]+_(\d+)_(\d+)_(\d+)_(\d+)$} $single_handle {} ch ca po {}
                set port_handle $ch/$ca/$po
                set currentPHandle $ch/$ca/$po
                
                if {$currentPHandle != $previousPHandle} {
                    
                    if {$previousPHandle != "_placeholder_"} {
                        debug "linkOamServer setLink"
                        if {[linkOamServer setLink]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to linkOamServer setLink on the\
                                    $port_handle port."
                            return $returnList
                        }
                        
                        debug "linkOamServer set"
                        if {[linkOamServer set]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to linkOamServer set on the\
                                    $port_handle port."
                            return $returnList
                        }
                        
                        debug "linkOamServer write"
                        if {[linkOamServer write]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to linkOamServer write on the\
                                    $port_handle port."
                            return $returnList
                        }
                    }
                    
                    debug "protocolServer get $ch $ca $po"
                    if {[set retCode [protocolServer get $ch $ca $po]]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Call to protocolServer\
                                get $ch $ca $po failed.\
                                Return code was $retCode."
                        return $returnList
                    }
                    
                    # Check if a link object is already configured on this port
                    debug "linkOamServer select $ch $ca $po"
                    if {[set retCode [linkOamServer select $ch $ca $po]]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Call to linkOamServer\
                                select $ch $ca $po failed. Procedure\
                                ::ixia::emulation_efm_config must be called on port \
                                $port_handle before this procedure."
                        return $returnList
                    }
                    
                    debug "linkOamServer getLink"
                    if {[linkOamServer getLink]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Call to linkOamServer\
                                getLink failed. No EFM Link exists on the configured port $port_handle.\
                                Procedure ::ixia::emulation_efm_config must be called on port \
                                $port_handle before this procedure."
                        return $returnList
                    }
                }
                
                set tmpCmd "linkOamLink $efm_options_map($type,get) $single_handle"
                debug $tmpCmd
                if {[eval $tmpCmd]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $tmpCmd."
                    return $returnList
                }
                
                set tmpCmd "$efm_options_map($type) configure -enabled $truth($mode)"
                debug $tmpCmd
                eval $tmpCmd
                
                set tmpCmd "linkOamLink $efm_options_map($type,set) $single_handle"
                debug $tmpCmd
                if {[eval $tmpCmd]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $tmpCmd."
                    return $returnList
                }

                set previousPHandle $currentPHandle
                
                if {[lindex $handle end] == $single_handle} {
                    debug "linkOamServer setLink"
                    if {[linkOamServer setLink]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to linkOamServer setLink on the\
                                $port_handle port."
                        return $returnList
                    }
                    
                    debug "linkOamServer set"
                    if {[linkOamServer set]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to linkOamServer set on the\
                                $port_handle port."
                        return $returnList
                    }
                    
                    debug "linkOamServer write"
                    if {[linkOamServer write]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to linkOamServer write on the\
                                $port_handle port."
                        return $returnList
                    }
                }
            }
        }
    }
    
    return $returnList
}

proc ::ixia::ixprotocol_efm_stat {args man_args opt_args} {
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    
    keylset returnList port_handle $port_handle
    
    # Set stats that are not supported to N/A
    set stats_na {
            statistics.oampdu_count.total_rx
        }

    foreach na_stat $stats_na {
        keylset returnList $na_stat "N/A"
    }
    
    
    foreach {ch ca po} [split $port_handle /] {}

    if {$action == "reset"} {
        
        puts "\nWARNING in emulation_efm_stat: -action reset cannot be performed for all\
                the statistic keys. Please check the documentation to determine which\
                statistic keys subject to reset.\n"
        
        set spaced_port_list [list [list $ch $ca $po]]
        
        if {[ixClearStats spaced_port_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Clearing stats on ports $spaced_port_list failed."
            return $returnList
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    debug "protocolServer get $ch $ca $po"
    if {[set retCode [protocolServer get $ch $ca $po]]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Call to protocolServer\
                get $ch $ca $po failed.\
                Return code was $retCode."
        return $returnList
    }
    
    # Check if a link object is already configured on this port
    debug "linkOamServer select $ch $ca $po"
    if {[set retCode [linkOamServer select $ch $ca $po]]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Call to linkOamServer\
                select $ch $ca $po failed. Procedure\
                ::ixia::emulation_efm_config must be called on port \
                $port_handle before this procedure."
        return $returnList
    }
    
    set no_link 0
    debug "linkOamServer getLink"
    if {[linkOamServer getLink]} {
        puts "\nWARNING: No EFM Link exists on the port $port_handle.\
                Some statistic values will be 'N/A'."
        set no_link 1
    }
    
    set link_obj            linkOamLink
    
    set stat_keys_disc_info {
            statistics.mac_remote                   remoteMacAddress
            statistics.oam_mode                     remoteMode
            statistics.unidir_enabled               remoteUnidirectionalSupport
            statistics.remote_loopback_enabled      remoteLoopbackSupport
            statistics.link_events_enabled          remoteLinkEvent
            statistics.variable_retrieval_enabled   remoteVariableRetrieval
            statistics.oampdu_size                  remoteMaxPduSize
            statistics.oui_value                    remoteOui
            statistics.vsi_value                    remoteVendorSpecInfo
            statistics.remote_critical_event        remoteCriticalEvent
            statistics.remote_dying_gasp            remoteDyingGasp
            statistics.remote_evaluating            remoteEvaluating
            statistics.remote_link_fault            remoteLinkFault
            statistics.remote_mux_action            remoteMuxAction
            statistics.remote_oam_version           remoteOamVersion
            statistics.remote_parser_action         remoteParserAction
            statistics.remote_revision              remoteRevision
            statistics.remote_stable                remoteStable
            statistics.oampdu_count.local_discovery_status  localDiscStatus
        }
    
    if {$no_link} {
    
        foreach {stat_key dummy} $stat_keys_disc_info {
            keylset returnList $stat_key "N/A"
        }
    
    } else {
    
        set efm_status [::ixia::get_efm_learned_info_tp                 \
                                    $stat_keys_disc_info                \
                                    $link_obj                           \
                                    "requestDiscLearnedInfo"            \
                                    "getDiscLearnedInfo"                \
                                    "linkOamDiscLearnedInfo"            \
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
            if {[keylget returnList $translate_key] == 1} {
                keylset returnList $translate_key "Supported"
            } elseif {[keylget returnList $translate_key] == 0} {
                keylset returnList $translate_key "Not Supported"
            }
        }
    }
    
    set stat_keys_var_req_info {
            statistics.variable_request.branch          variableBranch
            statistics.variable_request.indication      variableIndication
            statistics.variable_request.leaf            variableLeaf
            statistics.variable_request.value           variableValue
            statistics.variable_request.width           variableWidth
        }
    
    if {$no_link} {
    
        foreach {stat_key dummy} $stat_keys_var_req_info {
            keylset returnList $stat_key "N/A"
        }
    
    } else {
    
        set efm_status [::ixia::get_efm_learned_info_tp                     \
                                    $stat_keys_var_req_info                 \
                                    $link_obj                               \
                                    "requestVariableResponseLearnedInfo"    \
                                    "getVariableResponseLearnedInfoList"    \
                                    "linkOamVarRequestLearnedInfo"          \
                                    "returnList"                            ]
        if {[keylget efm_status status] != $::SUCCESS} {
            keylset efm_status log "Failed to get Variable Request Learned Info. [keylget efm_status log]"
            return $efm_status
        }
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
            statistics.alarms.errored_symbol_period_events              remoteSymbolPeriodEventRunningTotal
            statistics.alarms.errored_frame_events                      remoteFrameEventRunningTotal
            statistics.alarms.errored_frame_period_events               remoteFramePeriodEventRunningTotal
            statistics.alarms.errored_frame_seconds_summary_events      remoteFrameSecSumEventRunningTotal
            statistics.alarms.errored_symbol_period_events_tx           localSymbolPeriodEventRunningTotal
            statistics.alarms.errored_symbol_period_errors_tx           localSymbolPeriodErrorRunningTotal
            statistics.alarms.errored_symbol_period_errors              remoteSymbolPeriodErrorRunningTotal
            statistics.alarms.errored_frame_events_tx                   localFrameEventRunningTotal
            statistics.alarms.errored_frame_errors_tx                   localFrameErrorRunningTotal
            statistics.alarms.errored_frame_errors                      remoteFrameErrorRunningTotal
            statistics.alarms.errored_frame_period_events_tx            localFramePeriodEventRunningTotal
            statistics.alarms.errored_frame_period_errors_tx            localFramePeriodErrorRunningTotal
            statistics.alarms.errored_frame_period_errors               remoteFramePeriodErrorRunningTotal
            statistics.alarms.errored_frame_seconds_summary_events_tx   localFrameSecSumEventRunningTotal
            statistics.alarms.errored_frame_seconds_summary_errors_tx   localFrameSecSumErrorRunningTotal
            statistics.alarms.errored_frame_seconds_summary_errors      remoteFrameSecSumErrorRunningTotal
        }
    
    if {$no_link} {
    
        foreach {stat_key dummy} $stat_keys_events {
            keylset returnList $stat_key "N/A"
        }
    
    } else {
    
        set efm_status [::ixia::get_efm_learned_info_tp                     \
                                    $stat_keys_events                       \
                                    $link_obj                               \
                                    "requestEventNotifnLearnedInfo"         \
                                    "getEventNotifnLearnedInfo"             \
                                    "linkOamEventNotifnLearnedInfo"         \
                                    "returnList"                            ]
        if {[keylget efm_status status] != $::SUCCESS} {
            keylset efm_status log "Failed to get Variable Request Learned Info. [keylget efm_status log]"
            return $efm_status
        }
    }
    
    set efm_status [::ixia::get_efm_aggregate_stats_tp $port_handle "returnList"]
    if {[keylget efm_status status] != $::SUCCESS} {
        keylset efm_status log "Failed to get Variable Request Learned Info. [keylget efm_status log]"
        return $efm_status
    }
    
    return $returnList
}
