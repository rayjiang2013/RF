namespace eval ixia::encapSize {
    variable vcc_mux_ppoa                2
    variable llc_pppoa                   6
    variable vcc_mux_bridged_eth_fcs     2
    variable llc_bridged_eth_fcs        10

    variable vc_mux_routed               0
    variable llc_routed_clip             8
    
    variable eth_ii             12
    variable eth_type           2
    variable ppp_header         8
    variable vlan               4
    variable svlan              4
    variable offsetCorrection   0
}

proc ::ixia::buildEmulatedIxAccessStream { args mandatory_args optional_args} {

    set procName [lindex [info level [info level]] 0]
    set ::ixia::encapSize::offsetCorrection 0

    ::ixia::utrackerLog $procName $args

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
        -mandatory_args $mandatory_args

    # Check for source and destination emulation
    set ppp_ip_addr_replace ""
    set ppp_ip_addr_step_replace ""
    set ppp_ip_addr_count_replace ""
    if { [info exists ip_src_mode] && $ip_src_mode == "emulation" } {
        set emulation_handle $emulation_src_handle
        set trafficFlow upstream
        if {[info exists ip_src_count]} {
            set numSessions $ip_src_count
        }
        if {[info exists emulation_src_vlan_protocol_tag_id]} {
            set emulation_vlan_protocol_tag_id $emulation_src_vlan_protocol_tag_id
        }
        if {$emulation_override_ppp_ip_addr == "upstream" || \
                $emulation_override_ppp_ip_addr == "both"} {
            if {[info exists ip_src_addr]} {
                set ppp_ip_addr_replace $ip_src_addr
                if {[info exists ip_src_step]} {
                    set ppp_ip_addr_step_replace $ip_src_step
                }
                if {[info exists ip_src_count]} {
                    set ppp_ip_addr_count_replace $ip_src_count
                }
            } elseif {[info exists ipv6_src_addr]} {
                set ppp_ip_addr_replace $ipv6_src_addr
                
                if {[info exists ipv6_src_step]} {
                    set ppp_ip_addr_step_replace $ipv6_src_step
                }
                if {[info exists ipv6_src_count]} {
                    set ppp_ip_addr_count_replace $ipv6_src_count
                }
            }
        }
    } elseif { ![info exists ip_src_addr] && ![info exists ipv6_src_addr]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: ip_src_addr is\
                not set when the ip_src_mode is not emulation"
        return $returnList
    }
    if { [info exists ip_dst_mode] && $ip_dst_mode == "emulation" } {
        if {![info exists emulation_dst_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: when ip_dst_mode is\
                    emulation then emulation_dst_handle parameter must be present"
            return $returnList
        }
        set emulation_handle $emulation_dst_handle
        set trafficFlow downstream
        if {[info exists ip_dst_count]} {
            set numSessions $ip_dst_count
        }
        if {[info exists emulation_dst_vlan_protocol_tag_id]} {
            set emulation_vlan_protocol_tag_id $emulation_dst_vlan_protocol_tag_id
        }
        if {$emulation_override_ppp_ip_addr == "downstream" || \
                $emulation_override_ppp_ip_addr == "both"} {
            if {[info exists ip_dst_addr]} {
                set ppp_ip_addr_replace $ip_dst_addr
                if {[info exists ip_dst_step]} {
                    set ppp_ip_addr_step_replace $ip_dst_step
                }
                if {[info exists ip_dst_count]} {
                    set ppp_ip_addr_count_replace $ip_dst_count
                }
            } elseif {[info exists ipv6_dst_addr]} {
                set ppp_ip_addr_replace $ipv6_dst_addr
                
                if {[info exists ipv6_dst_step]} {
                    set ppp_ip_addr_step_replace $ipv6_dst_step
                }
                if {[info exists ipv6_dst_count]} {
                    set ppp_ip_addr_count_replace $ipv6_dst_count
                }
            }
        }
    } elseif {![info exists ip_dst_addr] && ![info exists ipv6_dst_addr] } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: ip_dst_addr is\
                not set when the ip_dst_mode is not emulation"
        return $returnList
    }

    # Set chassis card port
    regexp IxTclAccess/(\[0-9\]+)/(\[0-9\]+)/(\[0-9\]+)/(\[0-9\]+)$ \
            $emulation_handle dummy subPortId chassis card port
    set subPortId [expr $subPortId - 1]
    set port_list [list "$chassis $card $port"]

    set numSessionsStart 0
    for {set spNo 0} {$spNo < $subPortId} {incr spNo} {
        if {[ixAccessSubPort get $chassis $card $port $spNo]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to \
                ixAccessSubPort get $chassis $card $port $spNo"
            return $returnList
        }
        set numSessionsStart [expr $numSessionsStart + \
                            [ixAccessSubPort cget -numSessions]]
    }

    if {![info exists numSessions]} {
        if {[ixAccessSubPort get $chassis $card $port $subPortId]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to \
                ixAccessSubPort get $chassis $card $port $subPortId"
            return $returnList
        }
        set numSessions [ixAccessSubPort cget -numSessions]
    }
    
    set numSessionsEnd [mpexpr $numSessionsStart + $numSessions]
    incr numSessionsStart
    ::ixia::debug "numSessionsStart = $numSessionsStart"
    ::ixia::debug "numSessionsEnd = $numSessionsEnd"

    if {[info exists l3_protocol] && $l3_protocol == "ipv6"} {
        set ipType 2
    } else {
        set ipType 1
    }

    # For unix/linux, we will use a directory structure in the /tmp
    # area, for write enabled issues.  So we will need to make sure
    # the directory exists
    if {[isUNIX]} {
        set dirName [file join / tmp [pid]-[clock seconds]]
        if {![file isdirectory $dirName]} {
            file mkdir $dirName
        }
    } else {
        set dirName [file join $::env(IXIA_HLTAPI_LIBRARY)]
    }
    
    set ret_data [::ixia::getPPPoXSessionData      \
            $chassis/$card/$port                   \
                $numSessionsStart $numSessionsEnd \
            [file join $dirName ixAccessStats.tcl] \
            {}                                     \
            $ipType                                \
            $ppp_ip_addr_replace                   \
            $ppp_ip_addr_step_replace              \
            $ppp_ip_addr_count_replace             \
            $emulation_override_ppp_ip_addr        \
            ]
    if {[keylget ret_data status] != $::SUCCESS} {
        return $ret_data
    }
    
    foreach {chTx caTx poTx} [split $port_handle /] {}
    # Verify session ids only for nonAtm cards. PPPoA does not include a sessionID
    if {(![port isValidFeature $chTx $caTx $poTx $::portFeatureAtm]) && \
          ([catch {keylget ret_data pppoeSessionIdList} retCode] || ($retCode == ""))} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to \
                configure traffic. The PPPoE session IDs are not valid (null)."
        return $returnList
    }
    
    if {[info exists emulation_vlan_protocol_tag_id]} {
        keylset ret_data emulation_vlan_protocol_tag_id $emulation_vlan_protocol_tag_id
    }
    
    set offsetArgs [list port_handle port_handle2 emulation_handle trafficFlow \
            ip_dst_addr ipv6_dst_addr ip_src_addr ipv6_src_addr ipType ret_data]

    foreach offsetArg $offsetArgs {
        if {![info exists $offsetArg]} {
            continue
        }
        append tmpArgs "-$offsetArg [set $offsetArg] "
    }
    
    set offsetCorrectionStatus [eval ::ixia::signatureOffsetCorrection $tmpArgs]
    
    if {[keylget offsetCorrectionStatus status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
            [keylget offsetCorrectionStatus log]"
        return $returnList
    }
    
    set streamType hltPPPoETraffic

    if { [port isValidFeature $chTx $caTx $poTx $::portFeatureAtm] } {
        if {[catch {keylget ret_data pppoeSessionIdList} err] || $err == ""} {
            # If there's no session id and port is atm we should build a
            # PPPoA stream.
            set streamType hltPPPoATraffic
        }

        # If there is session id and port is atm we should build a
        # PPPoEoA stream
      
        set pppoaStreamCmd "::ixia::${streamType}::buildATMStream "
        set tmpParams [list ip_dst_addr ip_dst_mode ip_dst_count ip_dst_step   \
            ipv6_dst_addr ipv6_dst_mode ipv6_dst_count ipv6_dst_step           \
            ip_src_addr ip_src_mode ip_src_count ip_src_step                   \
            ipv6_src_addr ipv6_src_mode ipv6_src_count ipv6_src_step           \
            ]

        foreach param $tmpParams {
            if {[info exists $param]} {
                append pppoaStreamCmd "-$param [set $param] "
            }
        }
        
        if {$trafficFlow == "downstream"} {
            set p_handle [split $port_handle /]
            if {[keylget ret_data ipType] == 1} {
                set status [::ixia::get_interface_entry_from_ip \
                        [list $p_handle] 4 $ip_src_addr]
            } else {
                set status [::ixia::get_interface_entry_from_ip \
                        [list $p_handle] 6 [::ipv6::expandAddress $ipv6_src_addr]]
            }
            if { [llength $status] } {
                keylset ret_data atmVpiList [interfaceEntry cget -atmVpi]
                keylset ret_data atmVciList [interfaceEntry cget -atmVci]
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        configure traffic. Port $port_handle has been provided\
                        as an IP/Network port, but there are no IP interfaces\
                        available on this port.\
                        Please check your configuration and try again."
                return $returnList
            }
        }

        append pppoaStreamCmd "-port_handle $chassis/$card/$port/$subPortId \
                -StreamInfo $ret_data -trafficFlow $trafficFlow -pppUsers $numSessions"

        ::ixia::debug $pppoaStreamCmd

        set streamStatus [eval $pppoaStreamCmd]

        return $streamStatus
    }
    
    if {$trafficFlow == "downstream"} {
        # Before overwriting the vlan enabled info we need to store it so
        # we would know what is the payload size for signature offset calculation
        set vlanEnabled  [lindex [keylget ret_data vlanEnabledList] 0]
        set svlanEnabled [lindex [keylget ret_data stackedVlanEnableddList] 0]

        if { $vlanEnabled != "N"} {
            if { $svlanEnabled != "N"} {
                set tmpPayload $::ixia::hltPPPoETraffic::payloadSVlan
            } else {
                set tmpPayload $::ixia::hltPPPoETraffic::payloadVlan
            }
        } else {
            set tmpPayload $::ixia::hltPPPoETraffic::payloadStd
        }
        
        if {[info exists vlan] && $vlan == "enable"} {
            keylset ret_data vlanEnabledList "Y"
            if {[info exists vlan_id] && [llength $vlan_id] > 1} {
                keylset ret_data stackedVlanEnableddList "Y"
            } else {
                keylset ret_data stackedVlanEnableddList "N"
            }
        } else {
            keylset ret_data vlanEnabledList "N"
            keylset ret_data stackedVlanEnableddList "N"
        }
    }
    
    ::ixia::debug "::ixia::hltPPPoETraffic::buildEthernetStream \
        -port_handle            $chassis/$card/$port/$subPortId    \
        -StreamInfo             $ret_data                          \
        -trafficFlow            $trafficFlow                       "
        
    set streamStatus [::ixia::hltPPPoETraffic::buildEthernetStream \
        -port_handle            $chassis/$card/$port/$subPortId    \
        -StreamInfo             $ret_data                          \
        -trafficFlow            $trafficFlow                       ]

    if {[info exists tmpPayload]} {
        keylset streamStatus protocolOffsetUserDefinedTag $tmpPayload
    }

    return $streamStatus
}


namespace eval ixia::hltPPPoETraffic {

    variable payloadStd   {88 64 11 00 00 00 00 30 00 21}
    variable payloadVlan  {81 00 00 00 88 64 11 00 00 00 00 30 00 21}
    variable payloadSVlan {81 00 00 00 81 00 00 00 88 64 11 00 00 00 00 30 00 21}

    variable offsetStd
    variable offsetVlan
    variable offsetSVlan

    array set offsetStd   { sessionId    16 \
                                length        6 \
                                vlanOverHead  0 }
    array set offsetVlan  { sessionId    20 \
                                length       10 \
                                vlanOverHead  4 }
    array set offsetSVlan { sessionId    24 \
                                length       14 \
                                vlanOverHead  8 }
}



proc ::ixia::hltPPPoETraffic::buildEthernetStream { args } {
    variable offsetStd
    variable offsetVlan
    variable offsetSVlan
    variable payloadStd
    variable payloadVlan
    variable payloadSVlan
    
    set mandatory_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+/[0-9]$
        -StreamInfo             ANY
        -trafficFlow            CHOICES upstream downstream
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $mandatory_args

    foreach {chassis card port subport} [split $port_handle /] {}

    set srcMacList   [keylget StreamInfo pppoeHostMacList]
    set destMacList  [keylget StreamInfo pppoeACMacList]
    
    ::ixia::debug "ixAccessPort get $chassis $card $port"
    if {[ixAccessPort get $chassis $card $port]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR: \
                ixAccessPort get $chassis $card $port."
        return $returnList
    }

    set pppSrcIpList [keylget StreamInfo pppLocalIpList]
    ::ixia::debug "pppSrcIpList = $pppSrcIpList"

    set sessionIdList [keylget StreamInfo pppoeSessionIdList]

    set vlanEnabled  [lindex [keylget StreamInfo vlanEnabledList] 0]
    set svlanEnabled [lindex [keylget StreamInfo stackedVlanEnableddList] 0]
    set pppIpv6      [keylget StreamInfo ipType]
    
    if { $vlanEnabled != "N"} {
        set ::ixia::encapSize::offsetCorrection [mpexpr                  \
                    $::ixia::encapSize::offsetCorrection    -            \
                    $::ixia::encapSize::vlan                             ]
        if { $svlanEnabled != "N"} {
            set payload $payloadSVlan
            array set offset [array get offsetSVlan]
            set ::ixia::encapSize::offsetCorrection [mpexpr              \
                    $::ixia::encapSize::offsetCorrection    -            \
                    $::ixia::encapSize::svlan                            ]
        } else {
            set payload $payloadVlan
            array set offset [array get offsetVlan]
        }
        if {($trafficFlow == "upstream") && ![catch {keylget StreamInfo emulation_vlan_protocol_tag_id}]} {
            set emulation_vlan_protocol_tag_id [keylget StreamInfo emulation_vlan_protocol_tag_id]
            set vlanProtocolTagIdStart 0
            set vlanProtocolTagIdEnd   1
            foreach vlanProtocolTagId $emulation_vlan_protocol_tag_id {
                #{81 00 00 00 81 00 00 00 88 64 11 00 00 00 00 30 00 21}
                set payload [lreplace           \
                        $payload                \
                        $vlanProtocolTagIdStart \
                        $vlanProtocolTagIdStart \
                        [lindex [::ixia::format_hex 0x$vlanProtocolTagId 16] 0]  ]
                
                set payload [lreplace           \
                        $payload                \
                        $vlanProtocolTagIdEnd   \
                        $vlanProtocolTagIdEnd   \
                        [lindex [::ixia::format_hex 0x$vlanProtocolTagId 16] 1]  ]
                        
                incr vlanProtocolTagIdStart 4
                incr vlanProtocolTagIdEnd   4
            }
        }
    } else {
        set payload $payloadStd
        array set offset [array get offsetStd]
    }
    
    set ::ixia::encapSize::offsetCorrection [mpexpr                      \
                    $::ixia::encapSize::offsetCorrection    -            \
                    $::ixia::encapSize::eth_ii              -            \
                    $::ixia::encapSize::eth_type                         ]
    
    if {$trafficFlow == "upstream"} {
        set ::ixia::encapSize::offsetCorrection [mpexpr                  \
                    $::ixia::encapSize::offsetCorrection    -            \
                    $::ixia::encapSize::ppp_header                       ]
        ::ixia::debug "ixAccessSubPort cget -baseDataOffset"
        set sigOffset 			[ixAccessSubPort cget -baseDataOffset]
        ::ixia::debug "ixAccessSubPort cget -l3HdrLen"
        set l3HdrLen            [ixAccessSubPort cget -l3HdrLen]
        ::ixia::debug "sigOffset = $sigOffset \nl3HdrLen = $l3HdrLen"
        if { $pppIpv6 == 1 } {
            set pppSrcIpOffset [expr $sigOffset - 8]
            set pppDstIpOffset [expr $pppSrcIpOffset + 4]
            ::ixia::debug "pppSrcIpOffset = $pppSrcIpOffset\npppDstIpOffset = $pppDstIpOffset"
        } else {
            set pppSrcIpOffset [expr $sigOffset - 32]
            set pppDstIpOffset [expr $pppSrcIpOffset + 16]
        }

        set protOffset			[expr $sigOffset - $l3HdrLen]
        ::ixia::debug "protOffset = $protOffset"
        set varyingPortOffset 	$sigOffset
        ::ixia::debug "varyingPortOffset = $varyingPortOffset"
    } else {
        array set DAoffsetStd [list 1 30 2 38]
        set pppDstIpOffset $DAoffsetStd($pppIpv6)
        ::ixia::debug "pppDstIpOffset = $pppDstIpOffset"

        if { $vlanEnabled != "N"} {
            incr pppDstIpOffset 4
            if { $svlanEnabled != "N"} {
                incr pppDstIpOffset 4
            }
        }
    }
    
    if { $trafficFlow == "upstream" } {
        set macOffset 6
        set pppIpOffset     $pppSrcIpOffset
        set pppIncrIpOffset $pppDstIpOffset
    } else {
        set macOffset 0
        set pppIpOffset     $pppDstIpOffset
#         set pppIncrIpOffset $pppSrcIpOffset
    }
    
    if { $vlanEnabled != "N"} {
        set vlanOffset 14
        if { $svlanEnabled != "N"} {
            set svlanOffset 14
            incr vlanOffset 4
        }
    }
    
    if {$trafficFlow == "downstream"} {
        set tableUdfColumns [list \
            {"PPP IP"}      ]

        set tableUdfOffsets [list \
            $pppIpOffset          ]

        set tableUdfSizes   [list 16]
        if {$pppIpv6 == 1} {
            set tableUdfSizes   [list 4]
        }

        set tableUdfTypes hex
        
        set tableUdfRows ""
        set rowNo 1
        foreach pppIp $pppSrcIpList {
            set rowValueList row_$rowNo
            lappend rowValueList $pppIp
            if {$pppIp != ""} {
                lappend tableUdfRows $rowValueList
                incr rowNo
            }
        }
        # We set this parameter so we wouldn't have problems with unset
        # variables. This variable will have no effect because for
        # downstreams protocolOffsetEnable is disabled
        set protOffset 10
        ::ixia::debug "protOffset = $protOffset"
        
    } else {
        set tableUdfColumns [list \
                    "Host Mac"    \
                    "Session Id"  \
                    "PPP IP"      ]

        set tableUdfOffsets [list       \
                    $macOffset          \
                    $offset(sessionId)  \
                    $pppIpOffset        ]

        set tableUdfSizes   [list 6 2 16]
        if {$pppIpv6 == 1} {
            set tableUdfSizes   [list 6 2 4]
        }

        if { $vlanEnabled != "N"} {
            lappend tableUdfColumns "Vlan Id"
            lappend tableUdfOffsets $vlanOffset
            lappend tableUdfSizes   2
            if { $svlanEnabled != "N"} {
                lappend tableUdfColumns "Stacked Vlan Id"
                lappend tableUdfOffsets $svlanOffset
                lappend tableUdfSizes   2
            }
        }

        set tableUdfTypes ""
        foreach _opt $tableUdfColumns {
            lappend tableUdfTypes hex
        }

        set tableUdfRows ""
        set rowNo 1
        foreach mac $srcMacList sid $sessionIdList pppIp $pppSrcIpList \
                vlan [keylget StreamInfo vlanIdList]                   \
                svlan [keylget StreamInfo stackedVlanIdList]           \
                acMac $destMacList {

            set rowValueList row_$rowNo
            set rowValues "$mac $sid $pppIp"
            if { $vlanEnabled } {
                append rowValues " $vlan"
                if { $svlanEnabled } {
                    append rowValues " $svlan"
                }
            }
            lappend rowValueList $rowValues
            if {[llength $rowValues] == [llength $tableUdfColumns]} {
                lappend tableUdfRows $rowValueList
                incr rowNo
            }
        }
    }
    
    if {$tableUdfRows == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR: Unable to configure traffic.\
                The PPP sessions are not completely established (parameters\
                like PPP IP or PPP session ID could not be determined for any session)."
        return $returnList
    }
    
    keylset returnList table_udf_column_name   $tableUdfColumns
    keylset returnList table_udf_column_type   $tableUdfTypes
    keylset returnList table_udf_column_offset $tableUdfOffsets
    keylset returnList table_udf_column_size   $tableUdfSizes
    keylset returnList table_udf_rows          $tableUdfRows
    if {$trafficFlow == "upstream"} {
        keylset returnList dstMacAddr [lindex $destMacList 0]
    }

    set frameSize 128
    set lengthHex    [format %04X [expr $frameSize - (24 + $offset(vlanOverHead))]]
    set payload [lreplace $payload $offset(length) [expr $offset(length) + 1] \
                     [string range $lengthHex 0 1] [string range $lengthHex 2 3]]

    if { $pppIpv6 == 2 } {
        set payload [lreplace $payload end-1 end 00 57]
    }
    if {$trafficFlow == "upstream"} {
        keylset returnList protocolOffsetEnable 1
        # Disable the vlan flag. If the vlan tag is enabled and the stream
        # originates from a pppoe session, the vlan tag will be put twice,
        # once by the table udf and once by the vlan flag.
        keylset returnList vlan     "disable"
    } else {
        keylset returnList protocolOffsetEnable 0
    }

    keylset returnList protocolOffsetOffset $protOffset

    keylset returnList protocolOffsetUserDefinedTag $payload

    keylset returnList payloadLength [expr 24 + $offset(vlanOverHead)]
    keylset returnList payloadOffset $offset(length)
    keylset returnList trafficFlow $trafficFlow
    keylset returnList pppType  "pppoe"

    keylset returnList status $::SUCCESS

#     keylset returnList stream_id $streamId
    return $returnList
}


proc ::ixia::hltPPPoETraffic::buildATMStream { args } {

    variable offsetStd
    variable payloadStd

    set mandatory_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+/[0-9]$
        -StreamInfo             ANY
        -trafficFlow            CHOICES upstream downstream
        -pppUsers               NUMERIC
    }

    set opt_args {
        -ip_src_addr            IP
        -ip_src_mode            CHOICES fixed increment decrement random
                                CHOICES emulation
        -ip_src_count           RANGE   1-1000000
        -ip_src_step            IP
        -ip_dst_addr            IP
        -ip_dst_mode            CHOICES fixed increment decrement random
                                CHOICES emulation
        -ip_dst_count           RANGE   1-1000000
        -ip_dst_step            IP
        -ipv6_src_addr          IP
        -ipv6_src_mode          CHOICES fixed increment decrement random
        -ipv6_src_count         RANGE   1-1000000
        -ipv6_src_step          IPV6
        -ipv6_dst_addr          IP
        -ipv6_dst_mode          CHOICES fixed increment decrement random
        -ipv6_dst_count         RANGE   1-1000000
        -ipv6_dst_step          IPV6
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $mandatory_args \
            -optional_args $opt_args

    set paramsToOverwrite ""
    foreach {chassis card port subport} [split $port_handle "/"] {}

    set nUsers $pppUsers

    if {$trafficFlow == "upstream" } {
        if {[ixAccessAddrList get $chassis $card $port $subport]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to ixAccessSubPort \
                        get $chassis $card $port $subport"
            return $returnList
        }
        if {[ixAccessAddrList cget -encapsulation] == \
                                    $::atmEncapsulationLLCBridgedEthernetFCS} {
            set encapValue   llc_bridged_eth_fcs
            set ::ixia::encapSize::offsetCorrection [mpexpr              \
                    $::ixia::encapSize::offsetCorrection    -            \
                    $::ixia::encapSize::llc_bridged_eth_fcs -            \
                    $::ixia::encapSize::eth_ii              -            \
                    $::ixia::encapSize::eth_type            -            \
                    $::ixia::encapSize::ppp_header                       ]
        } else {
            set encapValue   vcc_mux_bridged_eth_fcs
            set ::ixia::encapSize::offsetCorrection [mpexpr              \
                    $::ixia::encapSize::offsetCorrection        -        \
                    $::ixia::encapSize::vcc_mux_bridged_eth_fcs -        \
                    $::ixia::encapSize::eth_ii                  -        \
                    $::ixia::encapSize::eth_type                -        \
                    $::ixia::encapSize::ppp_header                       ]
        }
    } else {
        set encapValue llc_routed_clip
        incr ::ixia::encapSize::offsetCorrection \
                            -$::ixia::encapSize::llc_routed_clip
    }

    set srcMacList   [keylget StreamInfo pppoeHostMacList]
    set destMacList  [keylget StreamInfo pppoeACMacList]
    set pppIpv6      [keylget StreamInfo ipType]
    set vpi_values_list  [keylget StreamInfo atmVpiList]
    set vci_values_list  [keylget StreamInfo atmVciList]

    # All of the following code is here to determine if the ip_src_addr
    # or ip_dst_addr is the one wich is going to be used for the non-ppp
    # side and to set the variables to correct 10base numbers for the code to
    # handle using nested counter udf

    set _ip ""
    if {$pppIpv6 == 2} {
        set _ip v6
    }

    set fl src
    if {$trafficFlow == "upstream"} {
        set fl dst
    }

    set ntw_ip_list [list             \
        dstIp       ip${_ip}_${fl}_addr \
        dstIpIncr   ip${_ip}_${fl}_step \
        dstIpCount  ip${_ip}_${fl}_count\
        dstIpMode   ip${_ip}_${fl}_mode ]

    foreach {dstX valX} $ntw_ip_list {
        if {[info exists $valX]} {
            set $dstX [set $valX]
        }
    }
    set dstIpModeParamName ip${_ip}_${fl}_mode

    if {$_ip == ""} {
        set _ip v4
    }
    if {[info exists dstIp]} {
        regsub -all { } [::ixia::convert_${_ip}_addr_to_hex $dstIp] {} dstIp
        set dstIp [mpexpr 0x${dstIp}]
    }

    if {[info exists dstIpIncr]} {
        regsub -all { } [::ixia::convert_${_ip}_addr_to_hex $dstIpIncr] {} tmpVal
        set dstIpIncr [mpexpr 0x${tmpVal}]
    } else {
        set dstIpIncr 1
    }

    if {![info exists dstIpCount]} {
        set dstIpCount 1
    }

    ::ixia::debug "ixAccessPort get $chassis $card $port"
    if {[ixAccessPort get $chassis $card $port]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR : \
                ixAccessPort get $chassis $card $port."
        return $returnList
    }

    ::ixia::debug "ixAccessSubPort get $chassis $card $port $subport"
    if {[ixAccessSubPort get $chassis $card $port $subport]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR : \
                ixAccessSubPort get $chassis $card $port $subport."
        return $returnList
    }

    set pppSrcIpList [keylget StreamInfo pppLocalIpList]
    ::ixia::debug "pppSrcIpList = $pppSrcIpList"

    set sessionIdList [keylget StreamInfo pppoeSessionIdList]

    set payload $payloadStd
    array set offset [array get offsetStd]

    set fcsPenalty [ixAccessSubPort cget -fcsPenalty]

    set sigOffset 			[ixAccessSubPort cget -baseDataOffset]
    set l3HdrLen            [ixAccessSubPort cget -l3HdrLen]

    # IP, PPPoE, 6 bytes from the end of Eth Hdr
    set srcMacOffset		[expr $sigOffset - $l3HdrLen - 8 - 6]

    # IP, 6 bytes from the end of the PPPoE Hdr
    set sessionIdOffset		[expr $sigOffset - $l3HdrLen - 6]

    set pppIpv6 [keylget StreamInfo ipType]
    if { $pppIpv6 == 1 } {
        set pppSrcIpOffset [expr $sigOffset - 8]
        set pppDstIpOffset [expr $pppSrcIpOffset + 4]
    } else {
        set pppSrcIpOffset [expr $sigOffset - 32]
        set pppDstIpOffset 32
    }


    if { $trafficFlow == "upstream" } {
        # The first two bytes stay the same. We set the sa and da addresses
        # to the first value from the lists and the remaining 4 bytes of the
        # mac addresses will be overwritten with udfs
        set streamSrcMac    [lindex $srcMacList 0]
        set streamDstMac    [lindex $destMacList 0]
        set pppIpOffset     $pppSrcIpOffset
        set pppIncrIpOffset $pppDstIpOffset
        set da_sa_addr_list [list mac_src $streamSrcMac \
                                  mac_dst $streamDstMac \
                                  mac_src_mode fixed    \
                                  mac_dst_mode fixed    \
                            ]
        lappend paramsToOverwrite $da_sa_addr_list
    } else {
        # For upstream there are no da/sa addresses
        set pppIpOffset     24
        set pppIncrIpOffset 20
    }



    # Looks like protOffset is always 22 for PPPoEoA case, seems to start from the
    # end of AAL5 Header
    set protOffset          22
    set varyingPortOffset 	$sigOffset

    if { $trafficFlow == "upstream"} {
        set udfNum 1
        # UDF 1 is Src MAC address List
        foreach __src__mac $srcMacList {
            set tmpVar [string range $__src__mac 4 end]
#             set tmpVar [format %u 0x$tmpVar]
            set idx [lsearch $srcMacList $__src__mac]
            set srcMacList [lreplace $srcMacList $idx $idx $tmpVar]
        }
        set udfParams${udfNum} [list                        \
            enable_udf${udfNum}       1                 \
            udf${udfNum}_offset       $srcMacOffset\
            udf${udfNum}_mode         value_list        \
            udf${udfNum}_value_list   $srcMacList     \
            udf${udfNum}_counter_type   32              \
        ]

        lappend paramsToOverwrite [set udfParams${udfNum}]

        incr udfNum
        # UDF 2 is Session ID List
#         foreach __sess__id $sessionIdList {
#             set tmpVar [format %u 0x$__sess__id]
#             set idx [lsearch $sessionIdList $__sess__id]
#             set sessionIdList [lreplace $sessionIdList $idx $idx $tmpVar]
#         }
        set udfParams${udfNum} [list                     \
            enable_udf${udfNum}       1                  \
            udf${udfNum}_offset       $sessionIdOffset   \
            udf${udfNum}_mode         value_list         \
            udf${udfNum}_value_list   $sessionIdList     \
            udf${udfNum}_counter_type 16                 \
        ]

        lappend paramsToOverwrite [set udfParams${udfNum}]
    }

    if {$pppIpv6 == 1} {
        # UDF 3 is PPP IP List. If it's source or destination will be set
        # by the offset
        set udfNum 3
        set udfParams${udfNum} [list                     \
                enable_udf${udfNum}       1                  \
                udf${udfNum}_offset       $pppIpOffset   \
                udf${udfNum}_mode         value_list         \
                udf${udfNum}_value_list   $pppSrcIpList     \
                udf${udfNum}_counter_type 32                 \
            ]

        lappend paramsToOverwrite [set udfParams${udfNum}]

        incr udfNum

        if { $dstIpCount > 1 } {
            set udfParams${udfNum} [list                    \
                        enable_udf${udfNum}         1           \
                        udf${udfNum}_counter_type   32          \
                        udf${udfNum}_mode           nested      \
                        udf${udfNum}_counter_init_value $dstIp  \
                        udf${udfNum}_inner_repeat_count 1       \
                        udf${udfNum}_inner_step     0           \
                        udf${udfNum}_inner_repeat_value $pppUsers \
                        udf${udfNum}_counter_step   $dstIpIncr \
                        udf${udfNum}_counter_repeat_count $dstIpCount \
                        udf${udfNum}_enable_cascade 1           \
                        udf${udfNum}_cascade_type   from_shelf  \
                        udf${udfNum}_offset         $pppIncrIpOffset \
                    ]
            lappend paramsToOverwrite [set udfParams${udfNum}]
        }
    } else {
        # For IPv6 we'll use TableUDFs because UDFs counters are
        # on 32 bits.

        set pppIpOffset $pppSrcIpOffset
        if { $trafficFlow == "downstream" } {
            set pppIpOffset $pppDstIpOffset
        }

        set tableUdfColumns [list \
            {"PPP IP"}      ]

        set tableUdfOffsets [list \
            $pppIpOffset          ]

        set tableUdfSizes   [list 16]

        set tableUdfTypes hex

        set tableUdfRows ""
        set rowNo 1
        foreach pppIp $pppSrcIpList {
            set rowValueList row_$rowNo
            lappend rowValueList $pppIp
            lappend tableUdfRows $rowValueList
            incr rowNo
        }

        set tableUdfParams [list            \
                table_udf_column_name   $tableUdfColumns \
                table_udf_column_type   $tableUdfTypes   \
                table_udf_column_offset $tableUdfOffsets \
                table_udf_column_size   $tableUdfSizes   \
                table_udf_rows          $tableUdfRows    \
            ]

        lappend paramsToOverwrite $tableUdfParams
    }


    #
    # Setup vpi and vci lists
    #
    if {$trafficFlow == "upstream"} {
        set atmParams [list                                      \
                atm_counter_vpi_type           table             \
                atm_counter_vpi_data_item_list $vpi_values_list  \
                atm_counter_vci_type           table             \
                atm_counter_vci_data_item_list $vci_values_list  \
                atm_header_encapsulation       $encapValue       \
                atm_header_enable_auto_vpi_vci 0                 \
                atm_header_aal5error           no_error          ]
    } else {
        set atmParams [list                                      \
                vpi                            $vpi_values_list  \
                vci                            $vci_values_list  \
                atm_counter_vpi_type           fixed             \
                atm_counter_vci_type           fixed             \
                atm_header_encapsulation       $encapValue       \
                atm_header_aal5error           no_error          \
            ]
    }

    lappend paramsToOverwrite $atmParams

    # The real frame size will be calculated before the stream is set
    set frameSize 128
    set lengthHex    [format %04X [expr $frameSize - 20 - $fcsPenalty]]	;# ETH 14 + 6 PPPoE + 2 for (00 21) -2 (for  IxOS Bug)
    set payload [lreplace $payload $offset(length) [expr $offset(length) + 1] \
                     [string range $lengthHex 0 1] [string range $lengthHex 2 3]]

    if { $pppIpv6 == 2 } {
        set payload [lreplace $payload end-1 end 00 57]
    }

    foreach paramsList $paramsToOverwrite {
        foreach {param value} $paramsList {
            keylset returnList $param  $value
        }
    }

    if {$trafficFlow == "upstream"} {
        keylset returnList protocolOffsetEnable 1
    } else {
        keylset returnList protocolOffsetEnable 0
    }

    if {![info exists dstIpMode] || \
            ([info exists dstIpMode] && \
            ($dstIpMode != "fixed") && ($dstIpMode != "emulation"))} {
        ::ixia::debug "keylset returnList $dstIpModeParamName fixed"
        keylset returnList $dstIpModeParamName "fixed"
    }

    keylset returnList protocolOffsetOffset $protOffset

    keylset returnList protocolOffsetUserDefinedTag $payload

    keylset returnList payloadLength [expr 20 + $fcsPenalty]
    keylset returnList payloadOffset $offset(length)
    keylset returnList trafficFlow $trafficFlow
    keylset returnList pppType  "pppoeoa"
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::setPPPoXPayloadFramesize { payloadInfo frameSize ch ca po} {
    set payload [keylget payloadInfo protocolOffsetUserDefinedTag]
    set payloadLength [keylget payloadInfo payloadLength]
    set payloadOffset [keylget payloadInfo payloadOffset]
    
    set lengthHex    [format %04X [expr $frameSize - $payloadLength]]
    ::ixia::debug "==============lengthHex = $lengthHex============="
    set payload [lreplace $payload $payloadOffset [expr $payloadOffset + 1] \
                     [string range $lengthHex 0 1] [string range $lengthHex 2 3]]

    protocolOffset config -userDefinedTag $payload
    set status [protocolOffset set $ch $ca $po]
    if { $status } {
        keylset returnList status $::FAILURE
        keylset returnList log "Error : \
            Failed to protocolOffset set $ch $ca $po"
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::getPPPoXSessionData {
    port 
    userStart userEnd 
    tclFile csvFile 
    {ipType 1} 
    {ipAddr ""}
    {ipAddrStep ""}
    {ipAddrCount ""}
    {overridePppIp "none"}
} {
    foreach {ch cd pt} [split $port /] {}
    set ipAddrTemp $ipAddr
    set ipAddrCountTemp $ipAddrCount
    
    if {[file exists $tclFile]} {
        if {[catch {file delete $tclFile]}]} {
            keylset returnList log "Failed to delete PPPoX stat file."
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
    set retCode [ixAccessUtil::getSessionData  \
            $ch $cd $pt                        \
            -startrow    1                     \
            -endrow      $userEnd              \
            -tcllistfile $tclFile              \
            -csvfile     $csvFile              ]

    if {$retCode} {
        keylset returnList log "Failed to ixAccessUtil::getSessionData $ch $cd $pt."
        keylset returnList status $::FAILURE
        return $returnList
    }

    if {![file exists $tclFile]} {
        keylset returnList log "Failed to configure traffic. \
                The PPPoX stat file could not be created.\
                Please check if the PPP sessions are up."
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    if {[catch {set statFileId [open $tclFile r]}]} {
        keylset returnList log "Failed to configure traffic.\
                PPPoX stat file could not be open."
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    if {[catch {set fileData [read $statFileId]}]} {
        keylset returnList log "Failed to configure traffic.\
                PPPoX stat file could not be read."
        keylset returnList status $::FAILURE
        return $returnList
    }

    if {[catch {close $statFileId}]} {
        keylset returnList log "Failed to configure traffic.\
                PPPoX stat file. Could not be closed."
        keylset returnList status $::FAILURE
        return $returnList
    }

    set fileLines [split $fileData \n]
    set ixAccessExactVersion [split [ixAccessVersion cget -ixTCLIxAccessVersion] ,]
    set ixAccessMajor        [lindex $ixAccessExactVersion 0]
    set ixAccessMinor        [lindex $ixAccessExactVersion 1]
    set ixAccessBranch       [lindex $ixAccessExactVersion 2]
    set ixAccessBuild        [lindex $ixAccessExactVersion 3]
    set ixAccessHexVer       0x[format %04x \
            $ixAccessMajor][format %04x  \
            $ixAccessMinor][format %04x  \
            $ixAccessBranch][format %04x \
            $ixAccessBuild]
    # Compare with 2.30.21.78 or 2.30.20.16 (this builds have the fix for IxChanges 128185)
    set ixAccessHexRefVer1  0x[format %04x 2][format %04x 30][format %04x 21][format %04x 78]
    set ixAccessHexRefVer2  0x[format %04x 2][format %04x 30][format %04x 20][format %04x 16]
    
    set ixAccessFixed128185 [mpexpr ($ixAccessHexVer >= $ixAccessHexRefVer1) || \
            ($ixAccessHexVer >= $ixAccessHexRefVer2)]
    
    if {!$ixAccessFixed128185} {
        set statList {
            pppoeSessionId pppLocalIp pppPeerIp pppoeHostMac pppoeACMac
            vlanEnabled vlanId stackedVlanEnabledd stackedVlanId
            pppIpv6PrefixLen atmEnabled atmVpi atmVci
        }
    } else {
        set statList {
            pppoeSessionId pppLocalIp pppPeerIp pppoeHostMac pppoeACMac
            vlanEnabled vlanId stackedVlanEnabledd stackedVlanId
            pppIpv6Prefix atmEnabled atmVpi atmVci
        }
    }
    
    
    foreach countStat $statList {
        set ${countStat}List ""
    }
# pppLocalIpv6IID
    set statNames [lindex [lindex $fileLines 0] 0]
    set fileLines [lreplace $fileLines 0 0]
    foreach dataSet $fileLines {
        if {[lsearch $fileLines $dataSet] < [expr $userStart - 1] || \
                [lsearch $fileLines $dataSet] > [expr $userEnd - 1]} {
            continue
        }
        if {$dataSet == ""} { continue }
        if {[catch {set dataSet [lindex $dataSet 0]}]} {
            keylset returnList status $::FAILURE
            keylset returnList log "set dataSet \[lindex $dataSet 0\]"
            return $returnList
        }
        foreach countStat $statList {
            set statIndex [lsearch -exact $statNames $countStat]
            if {$statIndex > -1} {
                if {(!$ixAccessFixed128185) && ($statIndex > 2) && ($ipType == 2)} {
                    set countStatValue [lindex $dataSet [expr $statIndex + 1]]
                } else {
                    set countStatValue [lindex $dataSet $statIndex]
                }
                if {$countStatValue != ""} {
                    switch -- $countStat {
                        atmVpi -
                        atmVci {
                            set countStatValue [format %04x $countStatValue]
                        }
                        pppoeHostMac {
                            set tmpVal [split $countStatValue :]
                            regsub -all { } $tmpVal {} countStatValue
                        }
                        pppLocalIp -
                        pppIpv6PrefixLen -
                        pppIpv6Prefix
                        {
                            set countStat pppLocalIp
                            if {$ipAddrTemp != ""} {
                                set countStatValue $ipAddrTemp
                            }
                            if {[catch {::ixia::convert_v4_addr_to_hex \
                                            $countStatValue} tmpVal]} {
                                if {[catch {::ixia::convert_v6_addr_to_hex \
                                            $countStatValue} tmpVal]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR: invalid IP \
                                        address $countStatValue. $tmpVal."
                                    return $returnList
                                }
                                set ipType 2
                                if {$ipAddrTemp != "" && $ipAddrStep != ""} {
                                    set ipAddrTemp [::ixia::increment_ipv6_address_hltapi \
                                            $ipAddrTemp $ipAddrStep]
                                    if {$ipAddrCountTemp != ""} {
                                        incr ipAddrCountTemp -1
                                        if {$ipAddrCountTemp == 0} {
                                            set ipAddrTemp      $ipAddr
                                            set ipAddrCountTemp $ipAddrCount
                                        }
                                    }
                                }
                            } else {
                                set ipType 1
                                if {$ipAddrTemp != "" && $ipAddrStep != ""} {
                                    set ipAddrTemp [::ixia::increment_ipv4_address_hltapi \
                                            $ipAddrTemp $ipAddrStep]
                                    if {$ipAddrCountTemp != ""} {
                                        incr ipAddrCountTemp -1
                                        if {$ipAddrCountTemp == 0} {
                                            set ipAddrTemp      $ipAddr
                                            set ipAddrCountTemp $ipAddrCount
                                        }
                                    }
                                }
                            }

                            regsub -all { } $tmpVal {} countStatValue
                        }
                        pppoeSessionId -
                        stackedVlanId -
                        vlanId {
                            set countStatValue [format %04x $countStatValue]
                        }
                    }
                    lappend ${countStat}List $countStatValue
                }
            } 
        }
    }
#     set statList ""
    foreach countStat $statList {
        keylset returnList ${countStat}List [set ${countStat}List]
        keylset returnList ipType $ipType
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

# replace parameters from all_args based on pairs_args
# for example :
#  all_args {-a 1 -b 2 -c 3}
#  pairs_args {-a -c -b -f}
# result:
#  -a 3 -c 1 -f 2

proc ::ixia::switch_args {all_args pairs_args} {
    set idx_param [lsearch $all_args "-traffic_generator"]
    if {$idx_param != -1} {
        set all_args [lreplace $all_args [expr $idx_param + 1] [expr $idx_param + 1] "ixaccess"]
    }
    foreach {arga argb} $pairs_args {
        # get location of parameters in list
        set posarga [lsearch $all_args $arga]
        set posargb [lsearch $all_args $argb]
        # check cases of missing parameters
        if {$posarga == -1 && $posargb >= 0} {
            set posvalb [expr $posargb + 1]
            set value [lindex $all_args $posvalb]
            set all_args [lreplace $all_args $posargb $posvalb]
            lappend all_args $arga $value
        } elseif {$posargb == -1 && $posarga >= 0} {
            set posvala [expr $posarga + 1]
            set value [lindex $all_args $posvala]
            set all_args [lreplace $all_args $posarga $posvala]
            lappend all_args $argb $value
        } else {
            set posvala [expr $posarga + 1]
            set posvalb [expr $posargb + 1]
            set vala [lindex $all_args $posvala]
            set valb [lindex $all_args $posvalb]
            set all_args [lreplace $all_args $posvala $posvala $valb]
            set all_args [lreplace $all_args $posvalb $posvalb $vala]
        }
    }
    return $all_args
}

# do same think like previously but with environment instead of all_args param
proc ::ixia::switch_vars { switch_list } {
    array set switch_array $switch_list
    foreach {value ndx} $switch_list {
        set reversed_array($ndx) $value
    }
    set changes_list {}
    foreach {var} $switch_list {
        upvar $var $var
        if {[info exists $var]} {
            if {(([catch {set nextVar $switch_array($var)}] == 0) || \
                 ([catch {set nextVar $reversed_array($var)}] == 0)) && \
                 ([lsearch $changes_list $var] == -1)} {
                upvar $nextVar $nextVar
                if {[info exist $nextVar]} {
                    set _tmp [set $nextVar]
                    set $nextVar [set $var]
                    set $var $_tmp
                } else {
                    set $nextVar [set $var]
                    catch {unset $var}
                }
                lappend changes_list $var
                lappend changes_list $nextVar
            }
        }
    }
}


namespace eval ixia::hltPPPoATraffic {
    array set llcOffset { payloadStart 6 \
                              checksum 16 \
                              srcIp 18 }

    array set vcMuxOffset { payloadStart 2 \
                                checksum 12 \
                                srcIp 14 }
}


proc ::ixia::hltPPPoATraffic::buildATMStream { args } {
    variable offset
    variable llcOffset
    variable vcMuxOffset
    
    set mandatory_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+/[0-9]$
        -StreamInfo             ANY
        -trafficFlow            CHOICES upstream downstream
        -pppUsers               NUMERIC
    }
    
    set opt_args {
        -ip_src_addr            IP
        -ip_src_mode            CHOICES fixed increment decrement random
                                CHOICES emulation
        -ip_src_count           RANGE   1-1000000
        -ip_src_step            IP
        -ip_dst_addr            IP
        -ip_dst_mode            CHOICES fixed increment decrement random
                                CHOICES emulation
        -ip_dst_count           RANGE   1-1000000
        -ip_dst_step            IP
        -ipv6_src_addr          IP
        -ipv6_src_mode          CHOICES fixed increment decrement random
        -ipv6_src_count         RANGE   1-1000000
        -ipv6_src_step          IPV6
        -ipv6_dst_addr          IP
        -ipv6_dst_mode          CHOICES fixed increment decrement random
        -ipv6_dst_count         RANGE   1-1000000
        -ipv6_dst_step          IPV6
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $mandatory_args \
            -optional_args $opt_args

    foreach {chassis card port subport} [split $port_handle {/}] {}

    if {[ixAccessSubPort get $chassis $card $port $subport]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to ixAccessSubPort \
                    get $chassis $card $port $subport"
        return $returnList
    }
    
    set paramsToOverwrite ""

    if {$trafficFlow == "upstream"} {
        if {[ixAccessAddrList get $chassis $card $port $subport]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to ixAccessSubPort \
                        get $chassis $card $port $subport"
            return $returnList
        }
        if {[ixAccessAddrList cget -encapsulation] == \
                                    $::atmEncapsulationLLCPPPoA} {
            set encapValue   llc_pppoa
            incr ::ixia::encapSize::offsetCorrection -$::ixia::encapSize::llc_pppoa
        } else {
            set encapValue   vcc_mux_ppoa
            incr ::ixia::encapSize::offsetCorrection -$::ixia::encapSize::vcc_mux_ppoa
        }
    } else {
        set encapValue   llc_routed_clip
        incr ::ixia::encapSize::offsetCorrection -$::ixia::encapSize::llc_routed_clip
    }
    
    set pppSrcIpList [keylget StreamInfo pppLocalIpList]
    set vpi_values_list  [keylget StreamInfo atmVpiList]
    set vci_values_list  [keylget StreamInfo atmVciList]
    set pppIpv6      [keylget StreamInfo ipType]


    set _ip ""
    if {$pppIpv6 == 2} {
        set _ip v6
    }
    set fl src
    if {$trafficFlow == "upstream"} {
        set fl dst
    }

    set ntw_ip_list [list             \
        dstIp       ip${_ip}_${fl}_addr \
        dstIpIncr   ip${_ip}_${fl}_step \
        dstIpCount  ip${_ip}_${fl}_count\
        dstIpMode   ip${_ip}_${fl}_mode ]

    foreach {dstX valX} $ntw_ip_list {
        if {[info exists $valX]} {
            set $dstX [set $valX]
        }
    }

    set dstIpModeParamName ip${_ip}_${fl}_mode
    
    if {$_ip == ""} {
        set _ip v4
    }
    if {[info exists dstIp]} {
        regsub -all { } [::ixia::convert_${_ip}_addr_to_hex $dstIp] {} dstIp
        set dstIp [mpexpr 0x${dstIp}]
    }

    if {[info exists dstIpIncr]} {
        regsub -all { } [::ixia::convert_${_ip}_addr_to_hex $dstIpIncr] {} tmpVal
        set dstIpIncr [mpexpr 0x${tmpVal}]
    } else {
        set dstIpIncr 1
    }
    
    if {![info exists dstIpCount]} {
        set dstIpCount 1
    }

    array set offset {}
    if { $encapValue == "llc_pppoa" }  {
        array set offset [array get llcOffset]
    } else {
        array set offset [array get vcMuxOffset]
    }

    # UDF 1 is PPP source IP
    
    set sigOffset [ixAccessSubPort cget -baseDataOffset]

    if { $pppIpv6 == 1 } {
        set pppSrcIpOffset $offset(srcIp)
        set pppDstIpOffset [expr $pppSrcIpOffset + 4]
        set udfNum 1
        if { $trafficFlow == "upstream" } {
            set pppIpOffsetForUdf $pppSrcIpOffset
            set pppIncrIpOffset $pppDstIpOffset
        } else {
            # The offsets for downstream will be hardcoded for the moment
            set pppIpOffsetForUdf 24
            set pppIncrIpOffset 20
        }

        set udfParams${udfNum} [list                        \
                enable_udf${udfNum}       1                 \
                udf${udfNum}_offset       $pppIpOffsetForUdf\
                udf${udfNum}_mode         value_list        \
                udf${udfNum}_value_list   $pppSrcIpList     \
                udf${udfNum}_counter_type   32              \
            ]

        lappend paramsToOverwrite [set udfParams${udfNum}]


        set udfNum 4
        if { $dstIpCount > 1 } {
    #         set status [ixTraffic::setupIpIncrUdf $nestedUdf \
    #                         [ixAccessStream cget -destinationIp] $pppUsers $pppIncrIpOffset]
            set udfParams${udfNum} [list                    \
                    enable_udf${udfNum}         1           \
                    udf${udfNum}_counter_type   32          \
                    udf${udfNum}_mode           nested      \
                    udf${udfNum}_counter_init_value $dstIp  \
                    udf${udfNum}_inner_repeat_count 1       \
                    udf${udfNum}_inner_step     0           \
                    udf${udfNum}_inner_repeat_value $pppUsers \
                    udf${udfNum}_counter_step   $dstIpIncr \
                    udf${udfNum}_counter_repeat_count $dstIpCount \
                    udf${udfNum}_enable_cascade 1           \
                    udf${udfNum}_cascade_type   from_shelf  \
                    udf${udfNum}_offset         $pppIncrIpOffset \
                ]
            lappend paramsToOverwrite [set udfParams${udfNum}]
        }

    } else {
        # For IPv6 we'll use table udf because UDFs counters are
        # on 32 bits.
        
        set pppSrcIpOffset [expr $sigOffset - 32]
        set pppDstIpOffset 32
        
        set pppIpOffset $pppSrcIpOffset
        if { $trafficFlow == "downstream" } {
            set pppIpOffset $pppDstIpOffset
        }
        
        set tableUdfColumns [list \
            {"PPP IP"}      ]

        set tableUdfOffsets [list \
            $pppIpOffset          ]

        set tableUdfSizes   [list 16]
        
        set tableUdfTypes hex

        set tableUdfRows ""
        set rowNo 1
        foreach pppIp $pppSrcIpList {
            set rowValueList row_$rowNo
            lappend rowValueList $pppIp
            lappend tableUdfRows $rowValueList
            incr rowNo
        }
        
        set tableUdfParams [list            \
                table_udf_column_name   $tableUdfColumns \
                table_udf_column_type   $tableUdfTypes   \
                table_udf_column_offset $tableUdfOffsets \
                table_udf_column_size   $tableUdfSizes   \
                table_udf_rows          $tableUdfRows    \
            ]

        lappend paramsToOverwrite $tableUdfParams
    }

    #
    # Setup vpi and vci lists
    #
    if {$trafficFlow == "upstream"} {
        set atmParams [list                                      \
                atm_counter_vpi_type           table             \
                atm_counter_vpi_data_item_list $vpi_values_list  \
                atm_counter_vci_type           table             \
                atm_counter_vci_data_item_list $vci_values_list  \
                atm_header_encapsulation       $encapValue       \
                atm_header_enable_auto_vpi_vci 0                 \
                atm_header_aal5error           no_error          \
                atm_counter_vpi_mask_select    {0000}            \
                atm_counter_vci_mask_select    {0000}            ]

    } else {
         set atmParams [list                                     \
                vpi                            $vpi_values_list  \
                vci                            $vci_values_list  \
                atm_counter_vpi_type           fixed             \
                atm_counter_vci_type           fixed             \
                atm_header_encapsulation       $encapValue       \
                atm_header_aal5error           no_error          \
            ]
    }
    
    lappend paramsToOverwrite $atmParams
    
    foreach paramsList $paramsToOverwrite {
        foreach {param value} $paramsList {
            keylset returnList $param  $value
        }
    }

    if {![info exists dstIpMode] || \
            ([info exists dstIpMode] && \
            ($dstIpMode != "fixed") && ($dstIpMode != "emulation"))} {
        ::ixia::debug "keylset returnList $dstIpModeParamName fixed"
        keylset returnList $dstIpModeParamName "fixed"
    }
    
    keylset returnList protocolOffsetEnable 0
    keylset returnList trafficFlow $trafficFlow
    keylset returnList pppType  "pppoa"
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::GetFilterSetCommandList { ch ca po } {
    set cmdList [list]
    
    set pgrp [ixAccessPort cget -portGroup]
    if { [ixAccessPort cget -enablePatternFilter] || $pgrp != $::kIxAccessPPPoX } {
        set pattern       0x[join [packetGroup cget -signature] ""]
        set patternOffset [packetGroup cget -signatureOffset]
        lappend cmdList "filter --set-pattern=$pattern/0x00000000@$patternOffset:1"
    } else {
        lappend cmdList "filter --enable-mac-types=0x8863"
        lappend cmdList "filter --enable-pppoe-control"
        ixAccessPpp get $ch $ca $po
        if { [ixAccessPpp cget -enableIpv6cp] } {
            lappend cmdList "filter --enable-icmpv6-types=128,129,133,134"
        } else {
            lappend cmdList "filter --enable-icmp-types=0,1,8"
        }
    }
    return $cmdList
}


proc ::ixia::GetFilterResetCommandList { ch ca po } {
    set cmdList [list]

    set pgrp [ixAccessPort cget -portGroup]
    if { [ixAccessPort cget -enablePatternFilter] || $pgrp != $::kIxAccessPPPoX } {
        lappend cmdList "filter --set-pattern=0/0@0:0"
    } else {
        lappend cmdList "filter --disable-pppoe-control"
        lappend cmdList "filter --disable-mac-types=0x8863"
        ixAccessPpp get $ch $ca $po
        if { [ixAccessPpp cget -enableIpv6cp] } {
            lappend cmdList "filter --disable-icmpv6-types=128,129,133,134"
        } else {
            lappend cmdList "filter --disable-icmp-types=0,1,8"
        }
    }
    return $cmdList
}


proc ::ixia::updatePatternMismatchFilter { portList {mode ""} {adi 0}} {
    if {($mode == "reset") || $adi} {
        foreach port $portList {
            scan $port "%d %d %d" ch ca po
            if {([info exists ::ixia::aPortState($ch,$ca,$po,FILTER)] && \
                     $::ixia::aPortState($ch,$ca,$po,FILTER) == 1) || $adi} {
                ixAccessPort get $ch $ca $po
                set cmdList [GetFilterResetCommandList $ch $ca $po]
                set singlePortList [list "$ch $ca $po"]
                foreach cmd $cmdList {
                    set status [issuePcpuCommand singlePortList $cmd]
                    debug "issuePcpuCommand singlePortList $cmd returned $status"
                }
                set ::ixia::aPortState($ch,$ca,$po,FILTER) 0
            }
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    foreach port $portList {
        scan $port "%d %d %d" ch ca po
        set singlePortList [list "$ch $ca $po"]

        ixAccessPort get $ch $ca $po
        packetGroup getRx $ch $ca $po
        debug "Before ixAccessPort cget -filterUpdateRequired"
        if { ![ixAccessPort cget -filterUpdateRequired] } { continue }
        debug "After ixAccessPort cget -filterUpdateRequired"
        if {$adi} {
            set cmdList ""
        } else {
            set cmdList [GetFilterSetCommandList $ch $ca $po]
        }
        debug "GetFilterSetCommandList returned $cmdList"
        foreach cmd $cmdList {
            set status [issuePcpuCommand singlePortList $cmd]
            if { $status } {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to issue cmd $cmd on $ch $ca $po,\
                        status = $status."
                return $returnList
            }
            debug "issuePcpuCommand singlePortList $cmd returned $status"
        }
        set ::ixia::aPortState($ch,$ca,$po,FILTER) 1
        
        ixAccessPort config -filterUpdateRequired 0
        ixAccessPort set $ch $ca $po
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::signatureOffsetCorrection { args } {
    variable tgen_offset_value
    set man_args {
        -port_handle         ANY
        -emulation_handle    ANY
        -trafficFlow         ANY
        -ret_data            ANY
    }

    set opt_args {
        -port_handle2        ANY
        -ip_dst_addr         ANY
        -ipv6_dst_addr       ANY
        -ip_src_addr         ANY
        -ipv6_src_addr       ANY
        -ipType              ANY
        -ret_data            ANY
        }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args

    keylset returnList status $::SUCCESS
    # This procedure calculates the sum of offsets of the encapsulation added
    # when packet reaches destination.
    # The sum of offsets of encapsulations removed when packet leaves host is
    # calculated in the procedures that configure the streams
    # The value is kept in ::ixia::encapSize::offsetCorrection
    
    if {$trafficFlow == "upstream"} {
        if {[info exists port_handle2] && \
                (![info exists tgen_offset_value($port_handle2)] || \
                ![expr $tgen_offset_value($port_handle2) & 0x2])} {
        
            foreach  {chassis card port} [split $port_handle2 /] {}
            set p_handle [list $chassis $card $port]
            if {$ipType == 1} {
                set status [::ixia::get_interface_entry_from_ip [list $p_handle] \
                        4 $ip_dst_addr]
                set errMsg "Interface with IPv4 address $ip_dst_addr could not be found \
                        on port $port_handle2."
            } else {
                set status [::ixia::get_interface_entry_from_ip [list $p_handle] \
                        6 [::ipv6::expandAddress $ipv6_dst_addr]]
                set errMsg "Interface with IPv6 address $ipv6_dst_addr could not be found \
                        on port $port_handle2."
            }
            
            if { [llength $status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure traffic. $errMsg"
                return $returnList
            }
            
            if { [port isValidFeature $chassis $card $port $::portFeatureAtm] } {
                set encap [interfaceEntry cget -atmEncapsulation]
                switch -- $encap {
                    106 {
                        # ::atmEncapsulationLLCRoutedCLIP
                        set ::ixia::encapSize::offsetCorrection [mpexpr       \
                                $::ixia::encapSize::offsetCorrection    +     \
                                $::ixia::encapSize::llc_routed_clip           ]
                    }
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid atm encapsulation on port \
                                $port_handle2."
                        return $returnList
                    }
                }
            } else {
                set ::ixia::encapSize::offsetCorrection [mpexpr       \
                        $::ixia::encapSize::offsetCorrection    +     \
                        $::ixia::encapSize::eth_ii              +     \
                        $::ixia::encapSize::eth_type                  ]
    
                if {[interfaceEntry cget -enableVlan]} {
                    set ::ixia::encapSize::offsetCorrection [mpexpr       \
                            $::ixia::encapSize::offsetCorrection    +     \
                            $::ixia::encapSize::vlan                      ]
                }
            }
        }
    } else {
        regexp IxTclAccess/(\[0-9\]+)/(\[0-9\]+)/(\[0-9\]+)/(\[0-9\]+)$ \
                $emulation_handle dummy subPortId chassis card port
        
        set subPortId [expr $subPortId - 1]
        set port_list [list "$chassis $card $port"]

        if {[ixAccessAddrList get $chassis $card $port $subPortId]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to get configuration for IxAccess subport
                    $chassis $card $port $subPortId"
            return $returnList
        }

        if { [port isValidFeature $chassis $card $port $::portFeatureAtm] } {
            set encap [ixAccessAddrList cget -encapsulation]
            switch -- $encap {
                109 {
                    # ::atmEncapsulationLLCPPPoA
                    set ::ixia::encapSize::offsetCorrection [mpexpr        \
                        $::ixia::encapSize::offsetCorrection         +     \
                        $::ixia::encapSize::llc_pppoa                      ]
                }
                110 {
                    # ::atmEncapsulationVccMuxPPPoA
                    set ::ixia::encapSize::offsetCorrection [mpexpr        \
                        $::ixia::encapSize::offsetCorrection         +     \
                        $::ixia::encapSize::vcc_mux_ppoa                   ]
                }
                102 -
                103 {
                    # ::atmEncapsulationVccMuxBridgedEthernetFCS
                    # ::atmEncapsulationVccMuxBridgedEthernetNoFCS
                    set ::ixia::encapSize::offsetCorrection [mpexpr        \
                    $::ixia::encapSize::offsetCorrection        +          \
                    $::ixia::encapSize::vcc_mux_bridged_eth_fcs +          \
                    $::ixia::encapSize::eth_ii                  +          \
                    $::ixia::encapSize::eth_type                +          \
                    $::ixia::encapSize::ppp_header                         ]
                }
                107 -
                108 {
                    # ::atmEncapsulationLLCBridgedEthernetFCS
                    # ::atmEncapsulationLLCBridgedEthernetNoFCS
                    set ::ixia::encapSize::offsetCorrection [mpexpr        \
                            $::ixia::encapSize::offsetCorrection    +      \
                            $::ixia::encapSize::llc_bridged_eth_fcs +      \
                            $::ixia::encapSize::eth_ii              +      \
                            $::ixia::encapSize::eth_type            +      \
                            $::ixia::encapSize::ppp_header                 ]
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid atm encapsulation on port \
                                            $chassis/$card/$port."
                    return $returnList
                }
            }
        } else {
            set vlanEnabled  [lindex [keylget ret_data vlanEnabledList] 0]
            set svlanEnabled [lindex [keylget ret_data stackedVlanEnableddList] 0]
            if { $vlanEnabled != "N"} {
                set ::ixia::encapSize::offsetCorrection [mpexpr            \
                        $::ixia::encapSize::offsetCorrection    +          \
                        $::ixia::encapSize::vlan                           ]
                if { $svlanEnabled != "N"} {
                    set ::ixia::encapSize::offsetCorrection [mpexpr        \
                            $::ixia::encapSize::offsetCorrection    +      \
                            $::ixia::encapSize::svlan                      ]
                }
            }

            set ::ixia::encapSize::offsetCorrection [mpexpr                \
                        $::ixia::encapSize::offsetCorrection    +          \
                        $::ixia::encapSize::eth_ii              +          \
                        $::ixia::encapSize::eth_type            +          \
                        $::ixia::encapSize::ppp_header                     ]

        }
    }
    
    return $returnList
}
