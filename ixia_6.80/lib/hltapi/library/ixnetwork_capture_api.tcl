proc ::ixia::ixnetwork_packet_config_buffers { args man_args opt_args } {
    
    set procName [lindex [info level [info level]] 0]
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing in $procName. $parse_error"
        return $returnList
    }
    
    ##########################################
    # Check if all ports are in mode capture
    ##########################################
    set validation_status [::ixia::validate_capture_ports $port_handle]
    if {[keylget validation_status status] != $::SUCCESS} {
        return $validation_status
    }
    set vport_list [keylget validation_status vport_handle_list]
    
    ##############################################
    # Display warning for unsupported parameters
    ##############################################
    set unsupported_params ""
    foreach u_param {action small_packet_capture} {
        if {[info exists $u_param]} {
            lappend unsupported_params $u_param
        }
    }
    
    if {[llength $unsupported_params] > 0} {
        puts "\nWarning in packet_config_buffers: The following parameters are not supported\
                when using IxNetwork Tcl API: $unsupported_params\n"
    }
    
    ######################
    # Parameter Mappings
    ######################
    
    set param_map {
        after_trigger_filter            afterTriggerFilter              translate
        before_trigger_filter           beforeTriggerFilter             translate
        capture_mode                    captureMode                     translate
        continuous_filter               continuousFilters               translate
        slice_size                      sliceSize                       value
        trigger_position                triggerPosition                 value
        data_plane_capture_enable       hardwareEnabled                 translate
        control_plane_capture_enable    softwareEnabled                 translate
        control_plane_filter_pcap       controlCaptureFilter            value
        control_plane_trigger_pcap      controlCaptureTrigger           value
    }
    
    array set translation_map {
        after_trigger_filter,all                 captureAfterTriggerAll
        after_trigger_filter,filter              captureAfterTriggerFilter
        after_trigger_filter,condition_filter    captureAfterTriggerConditionFilter
        before_trigger_filter,all                captureBeforeTriggerAll
        before_trigger_filter,filter             captureBeforeTriggerFilter
        before_trigger_filter,none               captureBeforeTriggerNone
        capture_mode,continuous                  captureContinuousMode
        capture_mode,trigger                     captureTriggerMode
        continuous_filter,all                    captureContinuousAll
        continuous_filter,filter                 captureContinuousFilter
        data_plane_capture_enable,0              false
        data_plane_capture_enable,1              true
        control_plane_capture_enable,0           false
        control_plane_capture_enable,1           true
    }
    
    ########################################
    # Configure vport/capture attributes
    ########################################
    foreach vport_objref $vport_list {
        
        set capture_objref [lindex [ixNetworkGetList $vport_objref capture] 0]
        
        set ixnet_args ""
        foreach {hlt_param ixn_param p_type} $param_map {
            if {![info exists $hlt_param]} {
                continue
            }
            
            switch -- $p_type {
                value {
                    lappend ixnet_args -$ixn_param [set $hlt_param]
                }
                translate {
                    if {![info exists translation_map($hlt_param,[set $hlt_param])]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Broken mappings in $procName for parameter\
                                '$hlt_param': '[set $hlt_param]'"
                        return $returnList
                    }
                    
                    lappend ixnet_args -$ixn_param $translation_map($hlt_param,[set $hlt_param])
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error in $procName. Invalid parameter\
                            type '$p_type' for parameter '$hlt_param'"
                    return $returnList
                }
            }
        }
        
        if {[llength $ixnet_args] == 0} {
            continue
        }
        
        set retCode [ixNetworkNodeSetAttr      \
                        $capture_objref        \
                        $ixnet_args            ]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set attributes for object $capture_objref:\
                    [keylget $retCode log]"
            return $returnList
        }
    }
    
    if {![info exists no_write]} {
        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to commit capture settings"
            return $returnList
        }
    }
    
    keylset returnList port_handle $port_handle
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_packet_config_filter { args man_args opt_args } {
    
    set procName [lindex [info level [info level]] 0]
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing in $procName. $parse_error"
        return $returnList
    }
    
    ##########################################
    # Check if all ports are in mode capture
    ##########################################
    set validation_status [validate_capture_ports $port_handle]
    if {[keylget validation_status status] != $::SUCCESS} {
        return $validation_status
    }
    set vport_list [keylget validation_status vport_handle_list]
    
    ##############################################
    # Display warning for unsupported parameters
    ##############################################
    set unsupported_params ""
    set unsupported_param_list {
        mode 
        gfp_bad_fcs_error
        gfp_eHec_error
        gfp_payload_crc
        gfp_tHec_error
        gfp_error_condition
        pattern_atm
        pattern_mask_atm
        pattern_offset_atm
    }
    foreach u_param $unsupported_param_list {
        
        if {![info exists $u_param]} {
            continue
        }
        
        switch -- $u_param {
            mode {
                if {[set $u_param] != "addAtmFilter"} {
                    continue
                }
            }
            pattern_offset_type1 -
            pattern_offset_type2 {
                if {[set $u_param] != "startOfSonet"} {
                    catch {unset $u_param}
                    continue
                }
            }
        }
        
        lappend unsupported_params $u_param
    }
    
    if {[llength $unsupported_params] > 0} {
        puts "\nWarning in packet_config_filter: The following parameters are not supported\
                when using IxNetwork Tcl API: $unsupported_params\n"
    }
    
    ######################
    # Parameter Mappings
    ######################
    set param_map {
        DA1                    DA1                      mac
        DA2                    DA2                      mac
        DA_mask1               DAMask1                  mac
        DA_mask2               DAMask2                  mac
        pattern1               pattern1                 str2hex
        pattern2               pattern2                 str2hex
        pattern_mask1          patternMask1             str2hex
        pattern_mask2          patternMask2             str2hex
        pattern_offset1        patternOffset1           value
        pattern_offset2        patternOffset2           value
        pattern_offset_type1   patternOffsetType1       translate
        pattern_offset_type2   patternOffsetType2       translate
        SA1                    SA1                      mac
        SA2                    SA2                      mac
        SA_mask1               SAMask1                  mac
        SA_mask2               SAMask2                  mac
    }
    
    array set translation_map {
        startOfFrame           filterPalletteOffsetStartOfFrame
        startOfIp              filterPalletteOffsetStartOfIp
        startOfProtocol        filterPalletteOffsetStartOfProtocol
    }
    
    #################################################################################
    # Configure pattern, patternOffset and patternMask if match_type was specified
    #################################################################################
    foreach mt {1 2} {
        if {![info exists match_type$mt]} {
            continue
        }
        
        set match_type [set match_type$mt]
        set pattern_combination [get_pattern_settings $match_type]
        if {[keylget pattern_combination pattern_offset] == "TBD"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unsupported predefined match type: '-match_type$mt $match_type'"
            return $returnList
        }
        
        foreach pattern_detail {pattern_offset pattern pattern_mask} {
            
            set pattern_detail_mt ${pattern_detail}${mt}
            if {[info exists $pattern_detail_mt]} {
                continue
            }
            # e.g. 'set pattern_offset1 [keylget pattern_combination pattern_offset]'
            set $pattern_detail_mt [keylget pattern_combination $pattern_detail]
        }
    }
    
    ########################################
    # Configure vport/capture attributes
    ########################################
    
        
    foreach vport_objref $vport_list {
        
        set capture_objref [lindex [ixNetworkGetList $vport_objref capture] 0]
        set filter_objref  [lindex [ixNetworkGetList $capture_objref filterPallette] 0]
        
        set ixnet_args ""
        foreach {hlt_param ixn_param p_type} $param_map {
            if {![info exists $hlt_param]} {
                continue
            }
            
            set hlt_value [set $hlt_param]
            
            switch -- $p_type {
                value {
                    lappend ixnet_args -$ixn_param $hlt_value
                }
                translate {
                    if {![info exists translation_map($hlt_value)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Broken mappings in $procName for parameter\
                                '$hlt_param': '$hlt_value'"
                        return $returnList
                    }
                    
                    lappend ixnet_args -$ixn_param $translation_map($hlt_value)
                }
                mac {
                    lappend ixnet_args -$ixn_param [convertToIxiaMac $hlt_value]
                }
                str2hex {
                    lappend ixnet_args -$ixn_param [convert_string_to_hex $hlt_value]
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error in $procName. Invalid parameter\
                            type '$p_type' for parameter '$hlt_param'"
                    return $returnList
                }
            }
        }
        
        if {[llength $ixnet_args] == 0} {
            continue
        }
        
        set retCode [ixNetworkNodeSetAttr      \
                        $filter_objref        \
                        $ixnet_args            ]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set attributes for object $filter_objref:\
                    [keylget $retCode log]"
            return $returnList
        }
        
       
    
    }
    
   
    
    if {![info exists no_write]} {
        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to commit capture settings"
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}




proc ::ixia::ixnetwork_packet_config_triggers { args opt_args } {

    set procName [lindex [info level [info level]] 0]
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args } parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing in $procName. $parse_error"
        return $returnList
    }
    
    ##########################################
    # Check if all ports are in mode capture
    ##########################################
    set validation_status [validate_capture_ports $port_handle]
    if {[keylget validation_status status] != $::SUCCESS} {
        return $validation_status
    }
    set vport_list [keylget validation_status vport_handle_list]

    ##############################################
    # Display warning for unsupported parameters
    ##############################################
    set unsupported_params ""
    set unsupported_param_list {
        mode 
        handle
        capture_filter_error
        capture_trigger_error
        uds1_error
        uds2_error
        capture_trigger_pattern
        capture_filter_pattern
        uds1_pattern
        uds2_pattern
        async_trigger1_error
        async_trigger2_error
    }
    
    foreach u_param $unsupported_param_list {
        
        if {![info exists $u_param]} {
            continue
        }
        
        switch -- $u_param {
            mode {
                if {[set $u_param] != "addAtmTrigger"} {
                    continue
                }
            }
            async_trigger1_error -
            async_trigger2_error -
            uds1_error -
            uds2_error {
                switch -- [set $u_param] {
                    errAnyFrame -
                    errGoodFrame -
                    errBadCRC -
                    errBadFrame {
                        continue
                    }
                }
            }
            capture_filter_error -
            capture_trigger_error {
                
                switch -- [set $u_param] {
                    errAnyFrame -
                    errGoodFrame -
                    errBadCRC -
                    errBadFrame -
                    errSmallSequenceError -
                    errBigSequenceError -
                    errReverseSequenceError -
                    errDataIntegrityError -
                    errAnyIpTcpUdpChecksumError -
                    errInvalidFcoeFrame {
                        continue
                    }
                    errAnySequenceError {
                        # there seems to be a typo in ixnetwork sdm. change the hlt value to match
                        set $u_param errAnySequencekError
                        continue
                    }
                }
            }
            async_trigger1_pattern -
            async_trigger2_pattern -
            uds1_pattern -
            uds2_pattern {
                if {[set $u_param] != "patternAtm" && [set $u_param] != "pattern1AndPattern2"} {
                    continue
                }
            }
            capture_filter_pattern -
            capture_trigger_pattern {
                if {[set $u_param] != "patternAtm"} {
                    continue
                }
            }
        }
        
        append unsupported_params "$u_param [set $u_param], "
        catch {unset $u_param}
    }
    
    if {[llength $unsupported_params] > 0} {
        puts "\nWarning in packet_config_trigger: The following parameters/values are not supported\
                when using IxNetwork Tcl API: $unsupported_params\n"
    }
    
    ######################
    # Parameter Mappings
    ######################
    set param_map_filter {
        capture_filter         				captureFilterEnable                 translate
        capture_filter_SA					captureFilterSA						translate
		capture_filter_DA					captureFilterDA						translate
		capture_filter_error				captureFilterError					value
		capture_filter_framesize  			captureFilterFrameSizeEnable		translate
		capture_filter_framesize_from		captureFilterFrameSizeFrom			value
		capture_filter_framesize_to			captureFilterFrameSizeTo			value
		capture_filter_pattern				captureFilterPattern				translate
		capture_filter_expression_string    captureFilterExpressionString       value
		}
    
    set param_map_trigger {
        capture_trigger						captureTriggerEnable				translate
		capture_trigger_SA					captureTriggerSA					translate
		capture_trigger_DA					captureTriggerDA					translate
		capture_trigger_error				captureTriggerError					value
		capture_trigger_framesize			captureTriggerFrameSizeEnable		translate
		capture_trigger_framesize_from		captureTriggerFrameSizeFrom			value
		capture_trigger_framesize_to		captureTriggerFrameSizeTo			value
		capture_trigger_pattern				captureTriggerPattern				translate
		capture_trigger_expression_string   captureTriggerExpressionString      value
    }
    
    set param_map_uds {
        uds1                                uds1                    value
        uds1_SA                             uds1_SA                 value
        uds1_DA                             uds1_DA                 value
        uds1_error                          uds1_error              value
        uds1_framesize                      uds1_framesize          translate
        uds1_framesize_from                 uds1_framesize_from     value
        uds1_framesize_to                   uds1_framesize_to       value
        uds1_pattern                        uds1_pattern            value
        uds2                                uds2                    value
        uds2_SA                             uds2_SA                 value
        uds2_DA                             uds2_DA                 value
        uds2_error                          uds2_error              value
        uds2_framesize                      uds2_framesize          translate
        uds2_framesize_from                 uds2_framesize_from     value
        uds2_framesize_to                   uds2_framesize_to       value
        uds2_pattern                        uds2_pattern            value
        async_trigger1                      uds5                    value
        async_trigger1_SA                   uds5_SA                 value
        async_trigger1_DA                   uds5_DA                 value
        async_trigger1_error                uds5_error              value
        async_trigger1_framesize            uds5_framesize          translate
        async_trigger1_framesize_from       uds5_framesize_from     value
        async_trigger1_framesize_to         uds5_framesize_to       value
        async_trigger1_pattern              uds5_pattern            value
        async_trigger2                      uds6                    value
        async_trigger2_SA                   uds6_SA                 value
        async_trigger2_DA                   uds6_DA                 value
        async_trigger2_error                uds6_error              value
        async_trigger2_framesize            uds6_framesize          translate
        async_trigger2_framesize_from       uds6_framesize_from     value
        async_trigger2_framesize_to         uds6_framesize_to       value
        async_trigger2_pattern              uds6_pattern            value
    }

    
    array set translation_map {
        capture_filter,0                         false
        capture_filter,1                         true
        capture_filter_SA,any                    anyAddr
        capture_filter_SA,SA1                    addr1
        capture_filter_SA,notSA1                 notAddr1
        capture_filter_SA,SA2                    addr2
        capture_filter_SA,notSA2                 notAddr2
        capture_filter_DA,any                    anyAddr
        capture_filter_DA,DA1                    addr1
        capture_filter_DA,notDA1                 notAddr1
        capture_filter_DA,DA2                    addr2
        capture_filter_DA,notDA2                 notAddr2
        capture_filter_framesize,0               false
        capture_filter_framesize,1               true
        capture_filter_pattern,any               anyPattern
        capture_filter_pattern,pattern1          pattern1
        capture_filter_pattern,notPattern1       notPattern1
        capture_filter_pattern,pattern2          pattern2
        capture_filter_pattern,notPattern2       notPattern2
        capture_filter_pattern,pattern1and2      pattern1AndPattern2
        capture_trigger,0                        false
        capture_trigger,1                        true
        capture_trigger_SA,any                   anyAddr
        capture_trigger_SA,SA1                   addr1
        capture_trigger_SA,notSA1                notAddr1
        capture_trigger_SA,SA2                   addr2
        capture_trigger_SA,notSA2                notAddr2
        capture_trigger_DA,any                   anyAddr
        capture_trigger_DA,DA1                   addr1
        capture_trigger_DA,notDA1                notAddr1
        capture_trigger_DA,DA2                   addr2
        capture_trigger_DA,notDA2                notAddr2
        capture_trigger_framesize,0              false
        capture_trigger_framesize,1              true
        capture_trigger_pattern,any              anyPattern
        capture_trigger_pattern,pattern1         pattern1
        capture_trigger_pattern,notPattern1      notPattern1
        capture_trigger_pattern,pattern2         pattern2
        capture_trigger_pattern,notPattern2      notPattern2
        capture_trigger_pattern,pattern1and2     pattern1AndPattern2
    }
    
    array set translation_map_uds {
        0               any
        1               custom
        jumbo           jumbo
        oversized       oversized
        undersized      undersized
    }
    
    ########################################
    # Configure vport/capture attributes
    ########################################

    
    
    
    foreach vport_objref $vport_list {
        
        set capture_objref [lindex [ixNetworkGetList $vport_objref capture] 0]
        
        foreach obj_type [list filter trigger] {
        
            set objref [lindex [ixNetworkGetList $capture_objref $obj_type] 0]
        
            set ixnet_args ""
            foreach {hlt_param ixn_param p_type} [set param_map_$obj_type] {
                if {![info exists $hlt_param]} {
                    continue
                }
                
                set hlt_value [set $hlt_param]
                
                switch -- $p_type {
                    value {
                        lappend ixnet_args -$ixn_param $hlt_value
                    }
                    translate {
                        if {![info exists translation_map($hlt_param,$hlt_value)]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Broken mappings in $procName for parameter\
                                    '$hlt_param': '$hlt_value'"
                            return $returnList
                        }
                        
                        lappend ixnet_args -$ixn_param $translation_map($hlt_param,$hlt_value)
                    }            
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error in $procName. Invalid parameter\
                                type '$p_type' for parameter '$hlt_param'"
                        return $returnList
                    }
                }
            }
            
            if {[llength $ixnet_args] == 0} {
                continue
            }
            
            set retCode [ixNetworkNodeSetAttr      \
                            $objref                \
                            $ixnet_args            ]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set attributes for object $objref:\
                        [keylget $retCode log]"
                return $returnList
            }
        }
        
        # Setting the uds params for ixnetwork_uds_config procedure
        set uds_args ""
        foreach {hlt_param hlt_param2 p_type} $param_map_uds {
            if {![info exists $hlt_param]} {
                continue
            }
            
            switch -- $p_type {
                translate {
                    if {![info exists translation_map_uds([set $hlt_param])]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Broken mappings in $procName for parameter\
                                '$hlt_param': '[set $hlt_param]'"
                        return $returnList
                    }
                    lappend uds_args -$hlt_param2 $translation_map_uds([set $hlt_param])
                }
                value {
                    lappend uds_args -$hlt_param2 [set $hlt_param]
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error in $procName. Invalid parameter\
                            type '$p_type' for parameter '$hlt_param'"
                    return $returnList
                }
            }
        }
        if {[llength $uds_args] > 0} {
            
            set ret_code [ixNetworkGetPortFromObj $vport_objref]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Failed to extract port handle from\
                        $vport_objref. [keylget ret_code log]"
                return $returnList
            } 
            
            set real_port_h [keylget ret_code port_handle]
            
            
            set cmd "::ixia::ixnetwork_uds_config -port_handle $real_port_h $uds_args"
            if {[info exists no_write]} {
                append cmd " -no_write"
            }
            
            set result [eval $cmd]
            if {[keylget result status] != $::SUCCESS} {
                return $result
            }
            
            set cmd2 "::ixia::ixnetwork_uds_filter_pallette_config -port_handle $real_port_h -clone_capture_filter 1"
            if {[info exists no_write]} {
                append cmd2 " -no_write"
            }
            set result [eval $cmd2]
            if {[keylget result status] != $::SUCCESS} {
                return $result
            }
        }
        
    }
   
    if {![info exists no_write]} {
        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to commit capture settings"
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_packet_control {args optional_args mandatory_args} {
    
    set procName [lindex [info level [info level]] 0]
        
    if {[catch  {::ixia::parse_dashed_args -optional_args $optional_args -args $args -mandatory_args \
                    $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    ##########################################
    # Check if all ports are in mode capture
    ##########################################
    set validation_status [validate_capture_ports $port_handle]
    if {[keylget validation_status status] != $::SUCCESS} {
        return $validation_status
    }
    set vport_list [keylget validation_status vport_handle_list]
    
    array set stopped_array {
        pass,start              0
        pass,cumulative_start   0
        pass,stop               1
        failed,start            1
        failed,cumulative_start 1
        failed,stop             0
    }
    
    array set packet_type_array {
        both    allTraffic
        control controlTraffic
        data    dataTraffic
    }
    
    if {$action == "reset"} {;# Reset trigget, filter and filterPallette
        foreach vport $vport_list {        
            set capture ${vport}/capture
            set filter ${capture}/filter
            set trigger ${capture}/trigger
            set filterPallette ${capture}/filterPallette
            
            set filterList {
                captureFilterDA                 anyAddr
                captureFilterEnable             False
                captureFilterError              errAnyFrame
                captureFilterExpressionString   {}
                captureFilterFrameSizeEnable    False
                captureFilterFrameSizeFrom      64
                captureFilterFrameSizeTo        1518
                captureFilterPattern            anyPattern
                captureFilterSA                 anyAddr
                }
            set triggerList {
                captureTriggerDA                anyAddr
                captureTriggerEnable            False
                captureTriggerError             errAnyFrame
                captureTriggerExpressionString  {}
                captureTriggerFrameSizeEnable   False
                captureTriggerFrameSizeFrom     12
                captureTriggerFrameSizeTo       12
                captureTriggerPattern           anyPattern
                captureTriggerSA                anyAddr
                }
            set filterPalletteList {
                SAMask1                         {00 00 00 00 00 00}
                SAMask2                         {00 00 00 00 00 00}
                SA1                             {00 00 00 00 00 00}
                SA2                             {00 00 00 00 00 00}
                DAMask1                         {00 00 00 00 00 00}
                DAMask2                         {00 00 00 00 00 00}
                DA1                             {00 00 00 00 00 00}
                DA2                             {00 00 00 00 00 00}
                patternOffsetType1              filterPalletteOffsetStartOfFrame
                patternOffsetType2              filterPalletteOffsetStartOfFrame
                patternOffset1                  0
                patternOffset2                  12
                patternMask1                    00
                patternMask2                    00
                pattern1                        00
                pattern2                        00
            }
            foreach {filterElement filterValue} $filterList {
                if {[catch {ixNet setAttribute $filter -$filterElement $filterValue} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log $err
                    return $returnList
                }
            }
            foreach {triggerElement triggerValue} $triggerList {
                if {[catch {ixNet setAttribute $trigger -$triggerElement $triggerValue} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log $err
                    return $returnList
                }
            }
            foreach {filterPalletteElement filterPalletteValue} $filterPalletteList {
                if {[catch {ixNet setAttribute $filterPallette -$filterPalletteElement $filterPalletteValue} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log $err
                    return $returnList
                }
            }
        }
        
        if {[catch {ixNet commit} err]} {
            keylset returnList status $::FAILURE
            keylset returnList log $err
            return $returnList
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    # Assuming the call will end up successful
    # If any of the ports fail, this will change
    set stopped $stopped_array(pass,$action)
    set failed_vports ""
    set error_messages ""
    
    if {$action == "start"} {
        if {[ixNet exec closeAllTabs] != "::ixNet::OK"} {
            keylset returnList log "Failed to close previous Analyser tabs !!!"
            ixNetCleanUp
            keylset returnList status $::FAILURE
            return returnList
        }
    }
    set exec_action $action
    if {$exec_action == "cumulative_start"} {
        set exec_action start
    }
    foreach vport $vport_list {
        if {[catch {ixNet exec $exec_action ${vport}/capture $packet_type_array($packet_type)} err] || $err != "::ixNet::OK"} {
            set stopped $stopped_array(failed,$action)
            lappend failed_vports $vport
            append error_messages "${err}; "
        }
    }
    
    if {[llength $failed_vports] > 0} {
        keylset returnList stopped $stopped
        keylset returnList status $::FAILURE
        
        set failed_ports ""
        foreach vport $failed_vports {
            set ret_code [ixNetworkGetPortFromObj $vport]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Failed to extract port handle from\
                        $vport. [keylget ret_code log]"
                return $returnList
            }
            
            lappend failed_ports [keylget ret_code port_handle]
        }
        
        keylset returnList log "Capture action $action failed on the following ports: $failed_ports - $error_messages"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_packet_stats { args man_args opt_args} {
    
    set procName [lindex [info level [info level]] 0]
    
    keylset returnList status $::SUCCESS
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args \
                    $opt_args -mandatory_args $man_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }

    if {$frame_id_start > $frame_id_end} {
        set aux $frame_id_start
        set frame_id_start $frame_id_end
        set frame_id_end $aux
    }
    
    # Remove unsupported defaults
    foreach default_param [list chunk_size] {
        if {![info exists $default_param] || ![is_default_param_value $default_param $args]} {
            continue
        }
        
        catch {unset $default_param}
    }
    
    # array for uds statistics
    set keyed_array_index 0
    set keyed_array_name capture_stats_returned_keyed_array
    catch {array unset $keyed_array_name}
    array set $keyed_array_name ""
    
    ##########################################
    # Check if all ports are in mode capture
    ##########################################
    set validation_status [validate_capture_ports $port_handle]
    if {[keylget validation_status status] != $::SUCCESS} {
        return $validation_status
    }
    set vport_list [keylget validation_status vport_handle_list]
    
    
    ###############################
    # Make sure we're not in a 'waiting for stats' state
    ###############################
    set timeout 10; #seconds
    if {[540TrafficIsWaitingForStats $timeout]} {
        puts "\nWarning: A 10s timeout was exceeded while waiting for UDS statistics.\
                 The uds keys might be unavailable\n"
    }
    
    ##############################################
    # Display warning for unsupported parameters
    ##############################################
    set unsupported_params ""
    set unsupported_param_list {
        filename
        chunk_size
        enable_ethernet_type
        enable_framesize
        enable_pattern
        ethernet_type
        framesize
        pattern
        pattern_offset
    }
    foreach u_param $unsupported_param_list {
        
        if {![info exists $u_param]} {
            continue
        }
        
        lappend unsupported_params $u_param
    }
    
    if {[llength $unsupported_params] > 0} {
        puts "\nWarning in packet_stats: The following parameters are not supported\
                when using IxNetwork Tcl API: $unsupported_params\n"
    }
    
    # Stop the capture if it is requested
    if {$stop == 1} {
        # Packet control also checks if capture is ready
        set stop_status [::ixia::packet_control   \
                -port_handle    $port_handle      \
                -action         stop              \
                ]
        
        if {[keylget stop_status status] != $::SUCCESS} {
            return $stop_status
        }
    } else {
        ###########################################
        # Check if capture is ready
        ##########################################
        set ready_status [wait_capture_vports_ready $vport_list]
        if {[keylget ready_status status] != $::SUCCESS} {
            return $ready_status
        }
    }
    
    ############################
    # Create key maps and lists
    ############################
    
    set unsupported_keys {
        average_deviation
        average_deviation_per_chunk
        average_latency
        max_latency
        min_latency
        standard_deviation
        standard_deviation_per_chunk
    }
    
    # Save the capture in the specified directory
    if {[info exists dirname] && $format == "cap"} {
        if {[catch {ixNet exec saveCapture $dirname} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to saveCapture in directory $dirname"
            return $returnList
        }        
    }
    
    array set portStatsArray {
        "User Defined Stat 1"         {
                                       {hltName     uds1_frame_count}
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "User Defined Stat 1 Rate"    {
                                       {hltName     uds1_frame_rate }
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "User Defined Stat 2"         {
                                       {hltName     uds2_frame_count}
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "User Defined Stat 2 Rate"    {
                                       {hltName     uds2_frame_rate }
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "Capture Trigger (UDS 3)"     {
                                       {hltName     uds3_frame_count}
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "Capture Trigger (UDS 3) Rate" {
                                       {hltName     uds3_frame_rate }
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "Capture Filter (UDS 4)"      {
                                       {hltName     uds4_frame_count}
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "Capture Filter (UDS 4) Rate" {
                                       {hltName     uds4_frame_rate }
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "User Defined Stat 5"         {
                                       {hltName     uds5_frame_count}
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "User Defined Stat 5 Rate"    {
                                       {hltName     uds5_frame_rate }
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "User Defined Stat 6"         {
                                       {hltName     uds6_frame_count}
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
        "User Defined Stat 6 Rate"    {
                                       {hltName     uds6_frame_rate }
                                       {statType    none            }
                                       {ixnNameType strict          }
                                       {prefixKey   _default        }
                                      }
    }
    
    foreach port_h $port_handle {
        
        set retCode [ixNetworkGetPortObjref $port_h]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the port \
                    object reference associated to the $port_h port handle -\
                    [keylget retCode log]."
            return $returnList
        }
        set vport_objref [keylget retCode vport_objref]
        set capture_objref [lindex [ixNetworkGetList $vport_objref capture] 0]
        
        if {$format == "var"} {
            set currentPacket [lindex [ixNetworkGetList $capture_objref currentPacket] 0]
            
            if {[ixNetworkGetAttr $capture_objref -hardwareEnabled] == "true" && ($packet_type == "both" || $packet_type == "data")} {
                if {![catch {ixNetworkGetAttr $capture_objref -dataPacketCounter} dataPacketCounter] && [string first "::ixNet::ERROR" $dataPacketCounter] == -1} {
                    for {set i $frame_id_start} {$i <= $frame_id_end} {incr i} {
                        if {[expr $i - 1] < $dataPacketCounter} {
                            if {[catch {ixNet exec getPacketFromDataCapture $currentPacket [expr $i - 1]} err] || $err != "::ixNet::OK"} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to get data packet $i from capture."
                                return $returnList
                            }
                            
                            set stackList [ixNetworkGetList $currentPacket stack]
                    
                            foreach stack $stackList {
                                set fieldList [ixNetworkGetList $stack field]
                                foreach field $fieldList {
                                    set display_name [ixNetworkGetAttr $field -displayName]
                                    set field_value [ixNetworkGetAttr $field -fieldValue]
                                    
                                    keylset returnList ${port_h}.frame.data.$i.${field}.display_name $display_name
                                    keylset returnList ${port_h}.frame.data.$i.${field}.value $field_value
                                }
                            }
                        } else {
                            break
                        }
                    }
                    set data_start_id $frame_id_start
                    set data_stop_id [expr $i - 1]
                    
                    if {$data_start_id <= $data_stop_id} {
                        keylset returnList ${port_h}.frame.data.frame_id_start $data_start_id
                        keylset returnList ${port_h}.frame.data.frame_id_end $data_stop_id
                    }
                }
            }
            
            if {[ixNetworkGetAttr $capture_objref -softwareEnabled] == "true" && ($packet_type == "both" || $packet_type == "control")} {
                if {![catch {ixNetworkGetAttr $capture_objref -controlPacketCounter} controlPacketCounter] && [string first "::ixNet::ERROR" $controlPacketCounter] == -1} {
                    for {set i $frame_id_start} {$i <= $frame_id_end} {incr i} {
                        if {$i < $controlPacketCounter} {
                            if {[catch {ixNet exec getPacketFromControlCapture $currentPacket [expr $i - 1]} err] || $err != "::ixNet::OK"} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to get control packet $i from capture."
                                return $returnList
                            }
                            
                            set stackList [ixNetworkGetList $currentPacket stack]
                    
                            foreach stack $stackList {
                                set fieldList [ixNetworkGetList $stack field]
                                foreach field $fieldList {
                                    set display_name [ixNetworkGetAttr $field -displayName]
                                    set field_value [ixNetworkGetAttr $field -fieldValue]
                                    
                                    keylset returnList ${port_h}.frame.control.$i.${field}.display_name $display_name
                                    keylset returnList ${port_h}.frame.control.$i.${field}.value $field_value
                                }
                            }
                        } else {
                            break
                        }
                     }
                     set control_start_id $frame_id_start
                     set control_stop_id [expr $i - 1]
                     
                     if {$control_start_id <= $control_stop_id} {
                        keylset returnList ${port_h}.frame.control.frame_id_start $control_start_id
                        keylset returnList ${port_h}.frame.control.frame_id_end $control_stop_id
                     }
                 }
            }
         } elseif {$format == "csv"} {
            set currentPacket [lindex [ixNetworkGetList $capture_objref currentPacket] 0]
            # Check for the existence of the dirname parameter
            if {![info exists dirname]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When format is csv the dirname parameter must be given"
                return $returnList
            }
            
            set timestamp [clock seconds]
            set data_file "${dirname}/data_${timestamp}.csv"
            set control_file "${dirname}/control_${timestamp}.csv"
            
            if {$packet_type == "data" || $packet_type == "both"} {
                
                if {[ixNetworkGetAttr $capture_objref -hardwareEnabled] == "true"} {
                    if {![catch {ixNetworkGetAttr $capture_objref -dataPacketCounter} dataPacketCounter] && [string first "::ixNet::ERROR" $dataPacketCounter] == -1} {
                        
                        set fout [open $data_file "w"]
                        puts $fout "Field Id,Field Display Name,Field Value"
                        keylset returnList ${port_h}.data_file $data_file
                        
                        for {set i $frame_id_start} {$i <= $frame_id_end} {incr i} {
                            if {[expr $i - 1] < $dataPacketCounter} {
                                puts $fout "Packet [expr $i - 1]"
                                if {[catch {ixNet exec getPacketFromDataCapture $currentPacket [expr $i - 1]} err] || $err != "::ixNet::OK"} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to get data packet $i from capture."
                                    return $returnList
                                }
                                
                                set stackList [ixNetworkGetList $currentPacket stack]
                        
                                foreach stack $stackList {
                                    set display_name [ixNetworkGetAttr $stack -displayName]
                                    puts $fout "Display Stack Name: $display_name"
                                    set fieldList [ixNetworkGetList $stack field]
                                    foreach field $fieldList {
                                        set display_name [ixNetworkGetAttr $field -displayName]
                                        set field_value [ixNetworkGetAttr $field -fieldValue]
                                        # Add double-quotes if the field contains commans or double-quotes
                                        if {[string first "," $field_value] != -1 || [string first "\"" $field_value] != -1} {
                                            set field_value "\"$field_value\""
                                        }
                                        
                                        puts $fout "${field},${display_name},${field_value}"
                                    }
                                }
                            } else {
                                break
                            }
                        }
                        close $fout
                    } else {
                        keylset returnList ${port_h}.data_file "N/A"
                    }
                }
            }
            
            if {$packet_type == "control" || $packet_type == "both"} {
                if {[ixNetworkGetAttr $capture_objref -softwareEnabled] == "true"} {
                    if {![catch {ixNetworkGetAttr $capture_objref -controlPacketCounter} controlPacketCounter] && [string first "::ixNet::ERROR" $controlPacketCounter] == -1} {
                        set fout [open $control_file "w"]
                        puts $fout "Field Id,Field Display Name,Field Value"
                        keylset returnList ${port_h}.control_file $control_file
                        
                        for {set i $frame_id_start} {$i <= $frame_id_end} {incr i} {
                            if {[expr $i - 1] < $controlPacketCounter} {
                                puts $fout "Packet [expr $i - 1]"
                                if {[catch {ixNet exec getPacketFromControlCapture $currentPacket [expr $i - 1]} err] || $err != "::ixNet::OK"} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to get control packet $i from capture."
                                    return $returnList
                                }
                                
                                set stackList [ixNetworkGetList $currentPacket stack]
                        
                                foreach stack $stackList {
                                    set display_name [ixNetworkGetAttr $stack -displayName]
                                    puts $fout "Display Stack Name: $display_name"
                                    set fieldList [ixNetworkGetList $stack field]
                                    foreach field $fieldList {
                                        set display_name [ixNetworkGetAttr $field -displayName]
                                        set field_value [ixNetworkGetAttr $field -fieldValue]
                                        # Add double-quotes if the field contains commans or double-quotes
                                        if {[string first "," $field_value] != -1 || [string first "\"" $field_value] != -1} {
                                            set field_value "\"$field_value\""
                                        }
                                        
                                        puts $fout "${field},${display_name},${field_value}"
                                    }
                                }
                            } else {
                                break
                            }
                        }
                        close $fout
                    } else {
                        keylset returnList ${port_h}.control_file "N/A"
                    }
                }
            }
         }
        
        ##
        # Set unsupported keys to N/A
        ##
        
        foreach u_key $unsupported_keys {
            keylset returnList ${port_h}.aggregate.${u_key} "N/A"
        }
        
        ##
        # Set counter keys
        ##
        if {[ixNetworkGetAttr $capture_objref -hardwareEnabled] == "true"} {
            if {[catch {ixNetworkGetAttr $capture_objref -dataPacketCounter} data_pkt_count] && [string first "::ixNet::ERROR" $data_pkt_count] != -1} {
                set data_pkt_count "N/A"
            }
        } else {
            set data_pkt_count "N/A"
        }
        
        if {[ixNetworkGetAttr $capture_objref -softwareEnabled] == "true"} {
            if {[catch {ixNetworkGetAttr $capture_objref -controlPacketCounter} control_pkt_count] && [string first "::ixNet::ERROR" $control_pkt_count] != -1} {
                set control_pkt_count "N/A"
            }
        } else {
            set control_pkt_count "N/A"
        }
        
        if {$data_pkt_count != "N/A"} {
            set num_frames $data_pkt_count
            if {$control_pkt_count != "N/A"} {
                set num_frames [mpexpr $num_frames + $control_pkt_count]
            }
        } elseif {$control_pkt_count != "N/A"} {
            set num_frames $control_pkt_count
        } else {
            set num_frames "N/A"
        }
        
        keylset returnList ${port_h}.aggregate.num_frames           $num_frames
        keylset returnList ${port_h}.aggregate.num_frames_data      $data_pkt_count
        keylset returnList ${port_h}.aggregate.num_frames_control   $control_pkt_count
    }
    
    
    ################################
    # Create the UDS statistic view
    ################################
    set create_ret_code [540CreateProtocolPortView -port_handle $port_handle]
    if {[keylget create_ret_code status] != $::SUCCESS} {
        return $create_ret_code
    }
    set protocol_port_view [keylget create_ret_code protocol_port_view]
    
    ##
    # Set UDS keys
    ##
    after 2000
    set retCode [540GetStatViewSnapshot [ixNetworkGetAttr $protocol_port_view -caption]]
    if {[keylget retCode status] == $::FAILURE} {
        return $retCode
    }
    
    set pageCount [keylget retCode page]
    set rowCount  [keylget retCode row]
    array set rowsArray [keylget retCode rows]
    for {set i 1} {$i < $pageCount} {incr i} {
        for {set j 1} {$j < $rowCount} {incr j} {
             set rowName $rowsArray($i,$j)
            
            set matched [regexp {(.+)/Card([0-9]{2})/Port([0-9]{2})} \
                    $rowName matched_str hostname cd pt]
            if {$matched && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                set ch_ip $hostname
            }
            
            if {!$matched} {
                set rx_port_status [ixNetworkGetVportByName $rowName]
                if {[keylget rx_port_status status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get 'Port Statistics' while\
                            retrieving aggregate statistics, because the virtual port with the\
                            '$rowName' name could not be found. [keylget rx_port_status log]"
                    return $returnList
                }
                set rowName [keylget rx_port_status port_handle]
                
                set matched [regexp {([0-9]+)/([0-9]+)/([0-9]+)} \
                        $rowName matched_str ch cd pt]
            }
            
            if {!$matched} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get 'Port Statistics',\
                        because port number could not be identified. $rowName did not\
                        match the HLT port format ChassisIP/card/port. This can occur if\
                        the test was not configured with HLT."
                return $returnList
            }
            
            if {$matched && ($matched_str == $rowName) && \
                    [info exists ch_ip] && [info exists cd] && \
                    [info exists pt] } {
                set ch [ixNetworkGetChassisId $ch_ip]
            }
            set cd [string trimleft $cd 0]
            set pt [string trimleft $pt 0]

            set statPort $ch/$cd/$pt
            if {[lsearch $port_handle $statPort] == -1} {
                continue
            }
            foreach statName [array names portStatsArray] {
                if {![info exists rowsArray($i,$j,$statName)] } {continue}
                if {![info exists portStatsArray($statName)]  } {continue}
                
                set portStatsArrayValue $portStatsArray($statName)
                
                set retStatNameList [keylget portStatsArrayValue hltName]
                set statTypeList    [keylget portStatsArrayValue statType]
                set ixnNameTypeList [keylget portStatsArrayValue ixnNameType]
                set prefixKeyList   [keylget portStatsArrayValue prefixKey]
                
                foreach retStatName $retStatNameList statType $statTypeList ixnNameType $ixnNameTypeList prefixKey $prefixKeyList {

                    switch $prefixKey {
                        "_default" {
                            set current_key "${statPort}.aggregate.${retStatName}"
                        }
                        default {
                            set current_key "${prefixKey}.${retStatName}"
                        }
                    }
                    
                    if {![info exists rowsArray($i,$j,$statName)] } {
                        
                        if {![catch {set [subst $keyed_array_name]($current_key)} overlap_key_val]} {
                            
                            continue
                        } else {
                            set [subst $keyed_array_name]($current_key) "N/A"
                            incr keyed_array_index
                            continue
                        }
                    }

                    if {[catch {set [subst $keyed_array_name]($current_key)} oldValue]} {
                        set [subst $keyed_array_name]($current_key) $rowsArray($i,$j,$statName)
                        
                        incr keyed_array_index
                    } else {
                        set [subst $keyed_array_name]($current_key) $rowsArray($i,$j,$statName)
                        incr keyed_array_index
                    }
                }
                
            } ;# end of statName iterator
        } ;#end of row iterator
    } ;#end of page iterator
    
    set [subst $keyed_array_name](status) $::SUCCESS
    set retTemp [array get $keyed_array_name]
    eval "keylset returnList $retTemp"
    
    keylset returnList status $::SUCCESS
    return $returnList
}
