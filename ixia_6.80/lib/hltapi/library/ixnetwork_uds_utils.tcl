
proc ::ixia::ixnetwork_uds_config {args} {
    
    # Configure UDS settings from ixnetwork (/vport/l1config/rxFilters/uds:1 - uds6)
    # Returns commit_needed key
    #         status        key
    #         log           key
    
    keylset returnList status $::SUCCESS
    keylset returnList commit_needed 0
    
    set procName [lindex [info level [info level]] 0]
    
    set man_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    set opt_args "-no_write"
    
    for {set id 1} {$id < 7} {incr id} {
        append opt_args "\n-uds${id}            CHOICES 0 1                         \n\
            -uds${id}_SA                        CHOICES any SA1 notSA1 SA2 notSA2   \n\
            -uds${id}_DA                        CHOICES any DA1 notDA1 DA2 notDA2   \n\
            -uds${id}_error                     CHOICES errAnyFrame                 \n\
                                                CHOICES errBadCRC                   \n\
                                                CHOICES errBadFrame                 \n\
                                                CHOICES errGoodFrame                \n\
            -uds${id}_framesize                 CHOICES 0 1 any                     \n\
                                                CHOICES custom                      \n\
                                                CHOICES jumbo                       \n\
                                                CHOICES oversized                   \n\
                                                CHOICES undersized                  \n\
            -uds${id}_framesize_from            NUMERIC                             \n\
            -uds${id}_framesize_to              NUMERIC                             \n\
            -uds${id}_pattern                   CHOICES any pattern1 notPattern1    \n\
                                                CHOICES pattern2 notPattern2        \n"
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args \
                    $opt_args -mandatory_args $man_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    for {set id 1} {$id < 7} {incr id} {
        set param_map$id [list                                                              \
            uds${id}                       isEnabled                         translate1     \
            uds${id}_SA                    sourceAddressSelector             translate1     \
            uds${id}_DA                    destinationAddressSelector        translate1     \
            uds${id}_error                 error                             value          \
            uds${id}_framesize             frameSizeType                     translate3     \
            uds${id}_framesize_from        customFrameSizeFrom               value          \
            uds${id}_framesize_to          customFrameSizeTo                 value          \
            uds${id}_pattern               patternSelector                   translate2     ]
    }
    
    array set translation_map1 {
        0                   false
        1                   true
        any                 anyAddr
        SA1                 addr1
        notSA1              notAddr1
        SA2                 addr2
        notSA2              notAddr2
        DA1                 addr1
        notDA1              notAddr1
        DA2                 addr2
        notDA2              notAddr2
    }
    
    array set translation_map2 {
        any                 anyPattern
        pattern1            pattern1
        notPattern1         notPattern1
        pattern2            pattern2
        notPattern2         notPattern2
    }
    
    array set translation_map3 {
        0               any
        1               custom
        any             any
        custom          custom
        jumbo           jumbo
        oversized       oversized
        undersized      undersized
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
        
        for {set id 1} {$id < 7} {incr id} {
            set ixn_args ""
            foreach {hlt_param ixn_param p_type} [set param_map$id] {
                if {![info exists $hlt_param]} {
                    continue
                }
                
                switch -- $p_type {
                    value {
                        set ixn_param_val [set $hlt_param]
                    }
                    translate1 {
                        if {![info exists translation_map1([set $hlt_param])]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Broken mappings in $procName for parameter\
                                    '$hlt_param': '[set $hlt_param]'"
                            return $returnList
                        }
                        
                        set ixn_param_val $translation_map1([set $hlt_param])
                    }
                    translate2 {
                        if {![info exists translation_map2([set $hlt_param])]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Broken mappings in $procName for parameter\
                                    '$hlt_param': '[set $hlt_param]'"
                            return $returnList
                        }
                        
                        set ixn_param_val $translation_map2([set $hlt_param])
                    }
                    translate3 {
                        if {![info exists translation_map3([set $hlt_param])]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Broken mappings in $procName for parameter\
                                    '$hlt_param': '[set $hlt_param]'"
                            return $returnList
                        }
                        
                        set ixn_param_val $translation_map3([set $hlt_param])
                    }
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error in $procName. Invalid parameter\
                                type '$p_type' for parameter '$hlt_param'"
                        return $returnList
                    }
                }
                
                lappend ixn_args -$ixn_param $ixn_param_val
            }
            
            if {[llength $ixn_args] == 0} {
                continue
            }
            
            set uds_obj "${vport_objref}/l1Config/rxFilters/uds:$id"
            
            if {[ixNet exists $uds_obj] == "false"} {
                puts "\nWarning: UDS$id is not available for port $port_h\n"
                continue
            }
            
            set commit_needed 1
            
            set retCode [ixNetworkNodeSetAttr      \
                            $uds_obj               \
                            $ixn_args              ]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set attributes for object $uds_obj:\
                        [keylget $retCode log]"
                return $returnList
            }
        }
    }
    
    if {![info exists no_write]} {
        set commit_needed 0
        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to commit capture settings"
            return $returnList
        }
    }
    
    keylset returnList commit_needed $commit_needed
    return $returnList
}



proc ::ixia::ixnetwork_uds_filter_pallette_config {args} {
    
    # Configure UDS settings from ixnetwork (/vport/l1config/rxFilters/filterPalette)
    # Returns commit_needed key
    #         status        key
    #         log           key
    
    keylset returnList status $::SUCCESS
    keylset returnList commit_needed 0
    
    set procName [lindex [info level [info level]] 0]
    
    set man_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    set opt_args {
        -DA1                    ANY
        -DA2                    ANY
        -DA_mask1               ANY
        -DA_mask2               ANY
        -pattern1               HEX
        -pattern2               HEX
        -pattern_mask1          HEX
        -pattern_mask2          HEX
        -pattern_offset1        NUMERIC
        -pattern_offset2        NUMERIC
        -pattern_offset_type1   CHOICES startOfFrame startOfIp startOfProtocol startOfSonet
        -pattern_offset_type2   CHOICES startOfFrame startOfIp startOfProtocol startOfSonet
        -SA1                    ANY
        -SA2                    ANY
        -SA_mask1               ANY
        -SA_mask2               ANY
        -clone_capture_filter   CHOICES 0 1
        -no_write
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args \
                    $opt_args -mandatory_args $man_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    ######################
    # Parameter Mappings
    ######################
    set param_map {
        DA1                    destinationAddress1              mac
        DA2                    destinationAddress2              mac
        DA_mask1               destinationAddress1Mask          mac
        DA_mask2               destinationAddress2Mask          mac
        pattern1               pattern1                         str2hex
        pattern2               pattern2                         str2hex
        pattern_mask1          pattern1Mask                     str2hex
        pattern_mask2          pattern2Mask                     str2hex
        pattern_offset1        pattern1Offset                   value
        pattern_offset2        pattern2Offset                   value
        pattern_offset_type1   pattern1OffsetType               translate
        pattern_offset_type2   pattern2OffsetType               translate
        SA1                    sourceAddress1                   mac
        SA2                    sourceAddress2                   mac
        SA_mask1               sourceAddress1Mask               mac
        SA_mask2               sourceAddress2Mask               mac
    }
    
    array set translation_map {
        startOfFrame           fromStartOfFrame
        startOfIp              fromStartOfIp
        startOfProtocol        fromStartOfProtocol
        startOfSonet           fromStartOfSonet
    }
    
    ########################################
    # Configure vport/capture attributes
    ########################################
    
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
        set filter_objref ${vport_objref}/l1Config/rxFilters/filterPalette
        
        if {[info exists clone_capture_filter] && $clone_capture_filter} {
            # Check if port data capture is enabled
            if {[catch {ixNetworkGetAttr ${vport_objref}/capture -hardwareEnabled} val] || $val == "false"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Data capture is not enabled on $port_h. Cannot clone capture filterPallette\
                        options on UDS"
                return $returnList
            }
        }
        
        set ixnet_args ""
        foreach {hlt_param ixn_param p_type} $param_map {
            
            if {[info exists clone_capture_filter] && $clone_capture_filter} {
                
                set hlt_value [ixNetworkUdsGetFilterAttr $vport_objref $hlt_param]

            } else {
            
                if {![info exists $hlt_param]} {
                    continue
                }
                
                set hlt_value [set $hlt_param]
            }
            
            switch -- $p_type {
                value {
                    set ixn_param_val $hlt_value
                }
                translate {
                    if {![info exists translation_map($hlt_value)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Broken mappings in $procName for parameter\
                                '$hlt_param': '$hlt_value'"
                        return $returnList
                    }
                    
                    set ixn_param_val $translation_map($hlt_value)
                }
                mac {
                    set ixn_param_val [ixNetworkFormatMac $hlt_value]
                }
                str2hex {
                    set ixn_param_val [convert_string_to_hex $hlt_value]
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error in $procName. Invalid parameter\
                            type '$p_type' for parameter '$hlt_param'"
                    return $returnList
                }
            }
            
            lappend ixnet_args -$ixn_param $ixn_param_val
        }
        
        if {[llength $ixnet_args] == 0} {
            continue
        }
        
        set commit_needed 1
        set retCode [ixNetworkNodeSetAttr      \
                        $filter_objref         \
                        $ixnet_args            ]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set attributes for object $filter_objref:\
                    [keylget $retCode log]"
            return $returnList
        }
    }
    
    if {![info exists no_write]} {
        set commit_needed 0
        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to commit capture settings"
            return $returnList
        }
    }
    
    keylset returnList commit_needed $commit_needed
    return $returnList
}


#######################################################################################
# Get the filter cofigurations from /vport/capture/filterPallette and set them on /vport/l1Config/rxFilters/filterPalette
#######################################################################################
proc ::ixia::ixNetworkUdsGetFilterAttr {vport_objref hlt_param} {
    
    array set reversed_param_map {
        DA1                    DA1               
        DA2                    DA2               
        DA_mask1               DAMask1           
        DA_mask2               DAMask2           
        pattern1               pattern1          
        pattern2               pattern2          
        pattern_mask1          patternMask1      
        pattern_mask2          patternMask2      
        pattern_offset1        patternOffset1    
        pattern_offset2        patternOffset2    
        pattern_offset_type1   patternOffsetType1
        pattern_offset_type2   patternOffsetType2
        SA1                    SA1               
        SA2                    SA2               
        SA_mask1               SAMask1           
        SA_mask2               SAMask2           
    }
    
    array set translation_map {
        filterPalletteOffsetStartOfFrame       startOfFrame   
        filterPalletteOffsetStartOfIp          startOfIp      
        filterPalletteOffsetStartOfProtocol    startOfProtocol
    }
    
    set filter_objref  ${vport_objref}/capture/filterPallette
    
    # Commit changes done on the filter_objref
    if {[regexp [string trimleft $filter_objref "::ixNet::OBJ-"] [ixNet h showUncommittedEdits]]} {
        ::ixia::debug "Commiting changes for $filter_objref because we need to do getAttr on it"
        if {[catch {ixNet commit} err]} {
            ::ixia::debug "ixNet commit failed in ixNetworkUdsGetFilterAttr with: '$err'"
        }
    }
    
    set ixn_param $reversed_param_map($hlt_param)
    set ixn_param_val [ixNetworkGetAttr $filter_objref -$ixn_param]
    switch -- $hlt_param {
        pattern_offset_type1 -
        pattern_offset_type2 {
            set hlt_param_val $translation_map($ixn_param_val)
        }
        default {
            set hlt_param_val $ixn_param_val
        }
    }
    
    return $hlt_param_val
}