proc ::ixia::get_intf_type { ch ca po } {

    set intf_type ""

    if {[port isActiveFeature $ch $ca $po portFeatureSonet]} {
        if {![sonet get $ch $ca $po]} {
            set header [sonet cget -header]

        if {[port get $ch $ca $po]} {
        }
        set portMode [port cget -portMode ]
        if {($portMode == $::portEthernetMode) || \
            ($portMode == $::port10GigWanMode) || \
            ($portMode == $::port10GigLanMode) } {
                set intf_type ethernet
            } elseif {$header == $::sonetCiscoHdlc} {
                set intf_type pos_hdlc
            } elseif {$header == $::sonetOther} {
                set intf_type other
            } elseif {$header == $::sonetFrameRelay1490} {
                set intf_type frame_relay1490
            } elseif {$header == $::sonetFrameRelay2427} {
                set intf_type frame_relay2427
            } elseif {$header == $::sonetFrameRelayCisco} {
                set intf_type frame_relay_cisco
            } elseif {$header == $::sonetSrp} {
                set intf_type srp
            } elseif {$header == $::sonetRpr} {
                set intf_type rpr
            } elseif {$header == $::sonetAtm} {
                set intf_type atm
            } elseif {$header == $::portBertMode} {
                set intf_type bert
            } elseif {$header == $::sonetHdlcPppIp} {
                set intf_type pos_ppp
            } elseif {$header == $::sonetGfp} {
                set intf_type gfp
            }
        }
    } elseif {[port isActiveFeature $ch $ca $po portFeatureAtm]} {
        set intf_type atm
    } else {
        set intf_type ethernet
    }

    return $intf_type
}


proc ::ixia::get_framing { ch ca po } {

    set framing ""

    if {[port isActiveFeature $ch $ca $po portFeaturePos] || \
            [port isActiveFeature $ch $ca $po portFeature10GigWan] || \
            [port isActiveFeature $ch $ca $po portFeatureOc192]} {

        if {![sonet get $ch $ca $po]} {
            set intf [sonet cget -interfaceType]

            if {($intf == $::oc3) || ($intf == $::oc12) || ($intf == $::oc48) \
                    || ($intf == $::oc192) || ($intf == $::ethOverSonet)} {
                set framing sonet
            } else {
                set framing sdh
            }
        }
    }

    return $framing
}


proc ::ixia::get_card_name { ch ca po } {

    if {[card get $ch $ca]} {
        set card_name ""
    } else {
        set card_name [card cget -typeName]
    }

    return $card_name
}


proc ::ixia::get_port_name { ch ca po } {

    if {[port get $ch $ca $po]} {
        set port_name ""
    } else {
        set port_name [port cget -typeName]
    }

    return $port_name
}


proc ::ixia::get_intf_speed { ch ca po } {

    set intf_speed ""
    if {[port isActiveFeature $ch $ca $po portFeaturePos]} {
        # Must be one of oc3, oc12, oc48, or oc192
        if {[sonet get $ch $ca $po]} {
            set intf_speed ""
            return
        }
        set intf [sonet cget -interfaceType]
        if {$intf == $::oc3} {
            set intf_speed oc3
        } elseif {$intf == $::oc12} {
            set intf_speed oc12
        } elseif {$intf == $::oc48} {
            set intf_speed oc48
        }
        if {[port isActiveFeature $ch $ca $po portFeatureOc192]} {
            set intf_speed oc192
        }
    } else {
        if {[port isActiveFeature $ch $ca $po portFeature40GigEthernet]} {
            set intf_speed ether40000lan
        } elseif {[port isActiveFeature $ch $ca $po portFeature100GigEthernet]} {
            set intf_speed ether100000lan
        } elseif {[port isActiveFeature $ch $ca $po portFeature10GigWan]} {
            set intf_speed ether10000wan
        } elseif {[port isActiveFeature $ch $ca $po portFeature10GigLan]} {
            set intf_speed ether10000lan
        } elseif {[port isActiveFeature $ch $ca $po portFeatureAtm]} {
            # Must be one of oc3, oc12, stm1, or stm4
            if {[sonet get $ch $ca $po]} {
                set intf_speed ""
                return
            }
            set intf [sonet cget -interfaceType]
            if {$intf == $::oc3} {
                set intf_speed oc3
            } elseif {$intf == $::oc12} {
                set intf_speed oc12
            } elseif {$intf == $::stm1c} {
                set intf_speed stm1
            } elseif {$intf == $::stm4c} {
                set intf_speed stm4
            }
        } else {
            if {[port get $ch $ca $po]} {
                set intf_speed ""
                return $intf_speed
            }
            switch [port cget -speed] {
                10 {
                    set intf_speed 10
                }
                100 {
                    set intf_speed 100
                }
                1000 {
                    set intf_speed 1000
                }
                default {
                    set intf_speed ""
                }
            }
        }
    }

    return $intf_speed
}


proc ::ixia::get_intf_stats { ch ca po } {

    statGroup setDefault
    statGroup add $ch $ca $po
    statGroup get
    statList get $ch $ca $po

    # tx_frames and rx_frames
    if {[port isActiveFeature $ch $ca $po portFeatureAtm]} {
        if {[atmPort get $ch $ca $po]} {
            keylset returnList tx_frames ""
            keylset returnList rx_frames ""
        } else {
            if {[atmPort cget -packetDecodeMode] == $::atmDecodeFrame} {
                if {[catch {statList cget -atmAal5FramesSent} val]} {
                    keylset returnList tx_frames ""
                } else {
                    keylset returnList tx_frames $val
                }
                if {[catch {statList cget -atmAal5FramesReceived} val]} {
                    keylset returnList rx_frames ""
                } else {
                    keylset returnList rx_frames $val
                }
            } else {
                if {[catch {statList cget -atmAal5CellsSent} val]} {
                    keylset returnList tx_frames ""
                } else {
                    keylset returnList tx_frames $val
                }
                if {[catch {statList cget -atmAal5CellsReceived} val]} {
                    keylset returnList rx_frames ""
                } else {
                    keylset returnList rx_frames $val
                }
            }
        }
    } else {
        if {[catch {statList cget -framesSent} val]} {
            keylset returnList tx_frames ""
        } else {
            keylset returnList tx_frames $val
        }
        if {[catch {statList cget -framesReceived} val]} {
            keylset returnList rx_frames ""
        } else {
            keylset returnList rx_frames $val
        }
    }

    # elapsed_time
    if {[catch {statList cget -transmitDuration} val]} {
        keylset returnList elapsed_time ""
    } else {
        keylset returnList elapsed_time [string map {" " ""} [format %100.2f \
                [mpexpr $val/double(1000000000)]]]
    }

    # rx_collisions
    if {[catch {statList cget -collisionFrames} val]} {
        keylset returnList rx_collisions ""
    } else {
        keylset returnList rx_collisions $val
    }

    # total_collisions
    if {[catch {statList cget -collisions} val]} {
        keylset returnList total_collisions ""
    } else {
        keylset returnList total_collisions $val
    }

    # duplex
    if {[catch {statList cget -duplexMode} val]} {
        keylset returnList duplex ""
    } else {
        if {$val == 0} {
            keylset returnList duplex half
        } else {
            keylset returnList duplex full
        }
    }

    # fcs_errors
    if {[catch {statList cget -fcsErrors} val]} {
        keylset returnList fcs_errors ""
    } else {
        keylset returnList fcs_errors $val
    }

    # late_collisions
    if {[catch {statList cget -lateCollisions} val]} {
        keylset returnList late_collisions ""
    } else {
        keylset returnList late_collisions $val
    }

    # link
    if {[catch {statList cget -link} val]} {
        keylset returnList link ""
    } else {
        keylset returnList link $val
    }

    return $returnList
}


proc ::ixia::get_pcs_lane_stats {ch ca po intf_speed} {
    if {[port get $ch $ca $po]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error when \"port get \
                $ch $ca $po\" \n Possible causes are: \n \
                No connection to a chassis or \n Invalid port number \
                or \n Network error between client and chassis."
        return $returnList
    }
    set port_mode [port cget -portMode]
    keylset returnList status $::SUCCESS
    if {($intf_speed == "ether40000lan" || $intf_speed == "ether100000lan") && $port_mode == $::portEthernetMode} {
        if {[pcsLaneStatistics get $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error when \"pcsLaneStatistics get \
                    $ch $ca $po\" \n Possible causes are: \n \
                    No connection to a chassis or \n Invalid port number \
                    or \n Network error between client and chassis."
            return $returnList
        }
        
        set pcs_lane_stats_map {
                sync_header_lock                           syncHeaderLock
                pcs_lane_marker_lock                     pcsLaneMarkerLock
                pcs_lane_marker_map                     pcsLaneMarkerMap
                relative_lane_skew                           relativeLaneSkew
                synk_header_error_count                syncHeaderErrorCount
                pcs_lane_error_marker_count          pcsLaneMarkerErrorCount
                bip8_error_count                             bip8ErrorCount
                lost_sync_header_lock                     lostSyncHeaderLock
                lost_pcs_lane_marker_lock               lostPcsLaneMarkerLock
        }
        
        set lanes [txLane getLaneList $ch $ca $po]
        foreach physical_lane $lanes {
            if {[pcsLaneStatistics getLane $physical_lane]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error when \"pcsLaneStatistics getLane \
                        $physical_lane\" \n Possible causes are: \n \
                        No connection to a chassis or \n Invalid physical lane \
                        or \n Network error between client and chassis."
                return $returnList
            }
            foreach {hlt_p ixos_p} $pcs_lane_stats_map {
                if {[catch {pcsLaneStatistics cget -$ixos_p} val]} {
                    keylset returnList $ch/$ca/$po.$physical_lane.$hlt_p "N/A"
                } else {
                    keylset returnList $ch/$ca/$po.$physical_lane.$hlt_p $val
                }
            }
        }
    }
    return $returnList
}


proc ::ixia::get_pcs_statistics {ch ca po intf_speed} {
    keylset returnList status $::SUCCESS
    if {[port get $ch $ca $po]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error when \"port get \
                $ch $ca $po\" \n Possible causes are: \n \
                No connection to a chassis or \n Invalid port number \
                or \n Network error between client and chassis."
        return $returnList
    }
    set port_mode [port cget -portMode]
    if {($intf_speed == "ether40000lan" || $intf_speed == "ether100000lan") && $port_mode == $::portEthernetMode} {
        set pcs_lane_stats_map {
                pcs_sync_errors_received                        pcsSyncErrorsReceived
                pcs_illegal_codes_received                       pcsIllegalCodesReceived
                pcs_remote_faults_received                      pcsRemoteFaultsReceived
                pcs_local_faults_received                         pcsLocalFaultsReceived
                pcs_illegal_ordered_set_received              pcsIllegalOrderedSetReceived
                pcs_illegal_idle_received                           pcsIllegalIdleReceived
                pcs_illegal_sof_received                            pcsIllegalSofReceived
                pcs_out_of_order_sof_received                 pcsOutOfOrderSofReceived
                pcs_out_of_order_eof_received                 pcsOutOfOrderEofReceived
                pcs_out_of_order_data_received               pcsOutOfOrderDataReceived
                pcs_out_of_order_ordered                        pcsOutOfOrderOrderedSetReceived
        }
        
        if {[stat get statAllStats $ch $ca $po]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error when \"stat get statAllStats \
                        $ch $ca $po\" \n Possible causes are: \n \
                        No connection to a chassis or \n Invalid port number \
                        or \n Network error between client and chassis."
                return $returnList
            }
        foreach {hlt_p ixos_p} $pcs_lane_stats_map {
            if {[catch {stat cget -$ixos_p} val]} {
                keylset returnList $ch/$ca/$po.${hlt_p}.count "N/A"
            } else {
                keylset returnList $ch/$ca/$po.${hlt_p}.count $val
            }
        }
        if {[stat getRate statAllStats $ch $ca $po]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error when \"stat getRate statAllStats \
                        $ch $ca $po\" \n Possible causes are: \n \
                        No connection to a chassis or \n Invalid port number \
                        or \n Network error between client and chassis."
                return $returnList
            }
        foreach {hlt_p ixos_p} $pcs_lane_stats_map {
            if {[catch {stat cget -$ixos_p} val]} {
                keylset returnList $ch/$ca/$po.${hlt_p}.rate "N/A"
            } else {
                keylset returnList $ch/$ca/$po.${hlt_p}.rate $val
            }
        }
    }
    return $returnList
}


proc ::ixia::get_bert_lane_statistics {ch ca po intf_speed} {
    keylset returnList status $::SUCCESS
    if {[port get $ch $ca $po]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error when \"port get \
                $ch $ca $po\" \n Possible causes are: \n \
                No connection to a chassis or \n Invalid port number \
                or \n Network error between client and chassis."
        return $returnList
    }
    set port_mode [port cget -portMode]
    keylset returnList status $::SUCCESS
    if {($intf_speed == "ether40000lan" || $intf_speed == "ether100000lan") && $port_mode == $::portBertMode} {
    
        set bert_lane_stats_map {
            bert_bits_sent                                           bertBitsSent
            bert_bits_received                                   bertBitsReceived
            bert_bit_errors_sent                                bertBitErrorsSent
            bert_bit_error_received                          bertBitErrorsReceived
            bert_pattern_lock                                     bertPatternLock
            bert_pattern_lock_lost                             bertPatternLockLost
            bert_pattern_transmitted                         bertPatternTransmitted
            bert_pattern_received                              bertPatternReceived
            bert_tx_lane                                               bertTxLane
            bert_bit_error_ratio                                  bertBitErrorRatio
            bert_number_mismatched_ones            bertNumberMismatchedOnes
            bert_mismatched_ones_ratio                 bertMismatchedOnesRatio
            bert_number_mismatched_zeros           bertNumberMismatchedZeros
            bert_mismatched_zeros_ratio                bertMismatchedZerosRatio
        }
        switch -- $intf_speed {
            ether40000lan {
                set bert_phy_lane_mappings {
                        0A          0
                        1A          1
                        2A          2
                        3A          3
                }
                foreach {phy_l phy_n} $bert_phy_lane_mappings {
                    if {[stat getBertLane $ch $ca $po $phy_n]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Error when \"stat getBertLane \
                                $ch $ca $po $phy_n\" \n Possible causes are: \n \
                                No connection to a chassis or \n Invalid physical lane \
                                or \n Network error between client and chassis."
                        return $returnList
                    }
                    foreach {hlt_p ixos_p} $bert_lane_stats_map {
                        if {[catch {stat cget -$ixos_p} val]} {
                            keylset returnList $ch/$ca/$po.$phy_l.$hlt_p "N/A"
                        } else {
                            keylset returnList $ch/$ca/$po.$phy_l.$hlt_p $val
                        }
                    }
                }
            }
            ether100000lan {
                set bert_phy_lane_mappings {
                        0A          0
                        0B          1
                        1A          2
                        1B          3
                        2A          4
                        2B          5
                        3A          6
                        3B          7
                        4A          8
                        4B          9
                        5A          10
                        5B          11
                        6A          12
                        6B          13
                        7A          14
                        7B          15
                        8A          16
                        8B          17
                        9A          18
                        9B          19
                }
                foreach {phy_l phy_n} $bert_phy_lane_mappings {
                    if {[stat getBertLane $ch $ca $po $phy_n]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Error when \"stat getBertLane \
                                $ch $ca $po $phy_n\" \n Possible causes are: \n \
                                No connection to a chassis or \n Invalid physical lane \
                                or \n Network error between client and chassis."
                        return $returnList
                    }
                    foreach {hlt_p ixos_p} $bert_lane_stats_map {
                        if {[catch {stat cget -$ixos_p} val]} {
                            keylset returnList $ch/$ca/$po.$phy_l.$hlt_p "N/A"
                        } else {
                            keylset returnList $ch/$ca/$po.$phy_l.$hlt_p $val
                        }
                    }
                }
            }
        }
    }
    return $returnList
}


proc ::ixia::setIntfConfig {} {
    uplevel {
        
        # List of parameters artificially initialized that must be unset at the end
        # because for multiple ports they will have bad values
        set unset_param_list ""
        foreach single_option_list $intf_option_list {
            if {[info exists $single_option_list]} {
                eval set single_option_list_eval $$single_option_list
                if {[llength $single_option_list_eval] == 1} {
                    set single_option $single_option_list_eval
                } else {
                    set single_option \
                            [lindex $single_option_list_eval $option_index]
                }
            }
            
            if {[info exists $single_option_list] ||\
                    ([info exists vlan] && [regexp {1} $vlan])} {
                # Doing this because IxTclHal wants ALL vlan parameters to have the same
                # length (items separated by commas) so that it creates proper stackedVlan.
                # If they don't have the same length, the current number of stacked vlans does not change
                if {![info exists $single_option_list]} {
                    switch -- $single_option_list {
                        vlan_id -
                        vlan_user_priority -
                        vlan_tpid {
                            array set tmp_vlan_map {
                                vlan_id            vlanId 
                                vlan_user_priority vlanPriority
                                vlan_tpid          vlanTPID
                                }
                            
                            set $single_option_list [interfaceEntry cget -[set tmp_vlan_map($single_option_list)]]
                            lappend unset_param_list $single_option_list
                            eval set single_option_list_eval $$single_option_list
                            set single_option $single_option_list_eval
                        
                            catch {unset tmp_vlan_map}
                        }
                        default {
                            continue
                        }
                    }
                }
                switch -- $single_option_list {
                    
                    vlan {
                        interfaceEntry config -enableVlan $single_option
                    }
                    vlan_id {
                    
                        set ret_code [protintf_svlan_csv_prepare               \
                            -vlan_id                 $single_option            \
                            -index                   $option_index             ]
                        if {[keylget ret_code status] != $::SUCCESS} {
                            return $ret_code
                        }
                        interfaceEntry config -vlanId [keylget ret_code vlan_id]
                        set intf_create_args(vlanId)  [keylget ret_code vlan_id]
                    }
                    vlan_user_priority {
                        if {[info exists vlan_id]} {
                            set ret_code [protintf_svlan_csv_prepare           \
                                -vlan_id                 $vlan_id              \
                                -vlan_user_priority      $single_option        \
                                -index                   $option_index         ]
                            if {[keylget ret_code status] != $::SUCCESS} {
                                return $ret_code
                            }
                            interfaceEntry config -vlanPriority [keylget ret_code vlan_user_priority]
                            set intf_create_args(vlanUserPriority) [keylget ret_code vlan_user_priority]
                        } else {
                            interfaceEntry config -vlanPriority $single_option
                            set intf_create_args(vlanUserPriority) $single_option
                        }
                    }
                    vlan_tpid {
                        
                        if {[info exists vlan_id]} {
                            set ret_code [protintf_svlan_csv_prepare           \
                                -vlan_id                 $vlan_id              \
                                -vlan_tpid               $single_option        \
                                -index                   $option_index         ]
                            if {[keylget ret_code status] != $::SUCCESS} {
                                return $ret_code
                            }
                            interfaceEntry config -vlanTPID [keylget ret_code vlan_tpid]
                        } else {
                            interfaceEntry config -vlanTPID $single_option
                        }
                    }
                    atm_encapsulation {
                        set retCode [port isValidFeature $chassis $card $port\
                                portFeatureAtm]
                        if {!$retCode} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: atm\
                                    feature not present"
                        }
                        interfaceEntry config -atmEncapsulation [format \
                                "atmEncapsulation%s" $single_option]
                    }
                    vpi {
                        set retCode [port isValidFeature $chassis $card $port\
                                portFeatureAtm]
                        if {!$retCode} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: atm\
                                    feature not present"
                        }
                        interfaceEntry config -atmVpi $single_option
                    }
                    vci {
                        set retCode [port isValidFeature $chassis $card $port\
                                portFeatureAtm]
                        if {!$retCode} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: atm\
                                    feature not present"
                        }
                        interfaceEntry config -atmVci $single_option
                    }
                    mtu {
                        interfaceEntry config -mtu $single_option
                    }
                    default {}
                }
            }
        }
        
        foreach unset_param $unset_param_list {
            catch {unset $unset_param}
        }
    }
}


proc ::ixia::setPortConfig {} {
    uplevel {
        keylset returnList status $::SUCCESS
        # atmPerVPIVCIStats is a variable introduced in IxOS 5.00
        if {[info exists ::atmPerVPIVCIStats]} {
            atmPort config -transmitStatsMode $::atmPerVPIVCIStats
        } elseif {[info exists ::atmPerStreamStats]} {
            atmPort config -transmitStatsMode $::atmPerStreamStats
        }
        
        set pcs_lanes_configured 0
        array set hundred_gig_mode {
            bert        5
            ethernet    0
        }
        foreach single_option_list $option_list {
            if {[info exists $single_option_list]} {
                eval set single_option_list_eval $$single_option_list
                if {[llength $single_option_list_eval] == 1} {
                    set single_option $single_option_list_eval
                } else {
                    set single_option \
                            [lindex $single_option_list_eval $option_index]
                }
                # BUG1121502: HLTAPI: interface_config - cannot set the port_rx_mode to do both sequence_checking and wide_packet_group
                # if we have a single port_handle with several values in port_rx_mode, set single_option as the whole list
                if {$single_option_list == "port_rx_mode"} {
                    if {[llength $port_handle] == 1} {
                        set single_option $single_option_list_eval
                    }
                }
                
                set neg(10,half)   1
                set neg(100,half)  2
                set neg(1000,half) 0
                set neg(10,full)   4
                set neg(100,full)  8
                set neg(1000,full) 16
                set neg(auto,half) 3
                set neg(auto,full) 28
                set neg(auto,auto) 31
                set neg(10,auto)   5
                set neg(100,auto)  10
                set neg(1000,auto) 16
                
                set neg_10h        1
                set neg_100h       2
                set neg_10f        4
                set neg_100f       8
                set neg_1000f      16
                
                switch -- $single_option_list {
                    framing {
                        # Speeds can only be set to the oc values.  If framing
                        # is sdh, then need to pull out the proper value from
                        # the sdh list.
                        if {[info exists speed]} {
                            if {[llength $speed] > 1} {
                                set speed_value [lindex $speed $option_index]
                            } else {
                                set speed_value $speed
                            }
                            switch -- $speed_value {
                                oc3 -
                                oc12 -
                                oc48 -
                                oc192 {
                                    set current_type $speed_value
                                }
                                ether10000wan {
                                    set current_type ethOverSonet
                                }
                                ether10000lan {
                                    set current_type ethOverSonet
                                }
                                default {
                                    set current_type none
                                }
                            }
                        } else  {
                            # Speed should exist. It is set by default in
                            # ixia_session_api.tcl
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Unable to determine speed on\
                                    port $chassis/$card/$port."
                            return $returnList
                        }
                        # 0 = OC3   <-> stm1c
                        # 1 = OC12  <-> stm4c
                        # 2 = OC48  <-> stm16c
                        # 3 = OC192 <-> stm64c
                        set sonet_type_list \
                                [list oc3 oc12 oc48 oc192 ethOverSonet]
                        
                        set sdh_type_list   \
                                [list stm1c stm4c stm16c stm64c ethOverSdh]
                        
                        if {$single_option == "sonet"} {
                            set index [lsearch $sonet_type_list $current_type]
                            if {$index != -1} {
                                set item [lindex $sonet_type_list $index]
                                catch {sonet config -interfaceType $item}
                                set sonet_flag 1
                            }
                        } elseif {$single_option == "sdh"} {
                            set index [lsearch $sonet_type_list $current_type]
                            if {$index != -1} {
                                set item [lindex $sdh_type_list $index]
                                catch {sonet config -interfaceType $item}
                                set sonet_flag 1
                            }
                        }
                    }
                    speed {
                        switch -- $single_option {
                            ether10 {
                                catch {port config -speed 10}
                            }
                            ether100 {
                                catch {port config -speed 100}
                            }
                            ether1000 {
                                set speed_flag 1000
                            }
                            oc3 -
                            oc12 -
                            oc48 -
                            oc192 {
                                set _pMode portPosMode
                                if {[info exists switchMode] && $switchMode == 2} {
                                    set _pMode portAtmMode
                                }
                                catch {port config -portMode $_pMode}
                                set portModeConfigured pos
                                catch {sonet config -interfaceType \
                                            $single_option}
                                set sonet_flag 1
                            }
                            ether10000wan {
                                catch {port config -portMode port10GigWanMode}
                                set portModeConfigured ethernet
                                if {(![info exists framing]) && \
                                            ((![info exists mode]) || \
                                            ([info exists mode] && ($mode == "config")))} {
                                    catch {sonet config -interfaceType ethOverSonet}
                                    set sonet_flag 1
                                }
                                
                            }
                            ether10000lan -
                            ether10Gig   {
                                catch {port config -portMode port10GigLanMode}
                                set portModeConfigured ethernet
                            }
                            ether40Gig -
                            ether100Gig -
                            ether40000lan -
                            ether100000lan {
                                set port_speed $single_option
                                if {$single_option == "ether100Gig" || $single_option == "ether100000lan"} {
                                    port config -speed 100000
                                } elseif {$single_option == "ether40Gig" || $single_option == "ether40000lan"} {
                                    port config -speed 40000
                                }
                                set portModeConfiguredInitial $portModeConfigured
                                if {[info exists intf_mode] && [info exists int_mode_single_option] && $int_mode_single_option == "bert"} {
                                    catch {port config -portMode $::portBertMode}
                                    set portModeConfigured bert
                                    port setTransmitMode $hundred_gig_mode(bert) $chassis $card $port
                                } else {
                                    catch {port config -portMode $::portEthernetMode}
                                    set portModeConfigured ethernet
                                    port setTransmitMode $hundred_gig_mode(ethernet) $chassis $card $port
                                }
                                if {(($portModeConfigured == "bert" && $portModeConfiguredInitial != "bert") || ($portModeConfigured == "ethernet" && $portModeConfiguredInitial == "bert")) &&\
                                        ([lsearch [::ixia::portSupports $chassis $card $port ethernet] 100000] != -1 || \
                                        [lsearch [::ixia::portSupports $chassis $card $port ethernet] 40000] != -1) && \
                                        ([::ixia::portSupports $chassis $card $port bert] == 1)} {
                                    if {[port write $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to set port $chassis $card $port in \
                                                $portModeConfigured mode."
                                        return $returnList
                                    }
                                    if {[port get $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to set port $chassis $card $port in \
                                                $portModeConfigured mode."
                                        return $returnList
                                    }
                                }
                            }
                            auto {
                                if {[info exists duplex]} {
                                    if {[llength $duplex] <= $option_index} {
                                        set duplex_value [lindex $duplex end]
                                    } else {
                                        set duplex_value [lindex $duplex $option_index]
                                    }
                                } else  {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: Auto value\
                                            to -speed option should be set in combination\
                                            with a -duplex value."
                                }
                                if {[info exists autonegotiation]} {
                                    if {[llength $autonegotiation] <= $option_index} {
                                        set autonegotiation_value [lindex $autonegotiation end]
                                    } else {
                                        set autonegotiation_value [lindex $autonegotiation $option_index]
                                    }
                                } else  {
                                    set autonegotiation_value 1
                                }
#                                 debug "SPEED = $autonegotiation_value $duplex_value $single_option"
                                if {$autonegotiation_value == 1} {
                                    if {[port set $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: Failed\
                                                to set configuration on port $chassis/$card/$port."
                                        return $returnList
                                    }
                                    set _type [lindex [::ixia::portSupports $chassis $card $port ethernet] end]
                                    switch -- $_type {
                                        10 -
                                        100 -
                                        1000 {
                                            port config -advertise10HalfDuplex   [expr $neg($single_option,$duplex_value) & $neg_10h  ]
                                            port config -advertise10FullDuplex   [expr $neg($single_option,$duplex_value) & $neg_10f  ]
                                            port config -advertise100HalfDuplex  [expr $neg($single_option,$duplex_value) & $neg_100h ]
                                            port config -advertise100FullDuplex  [expr $neg($single_option,$duplex_value) & $neg_100f ]
                                            port config -advertise1000FullDuplex [expr $neg($single_option,$duplex_value) & $neg_1000f]
                                        }
                                        default {
#                                             keylset returnList status $::FAILURE
                                            puts "Warning in $procName: Auto value \
                                                    to -speed option should be set only for Ethernet \
                                                    ports."
                                            update idletasks
                                            keylset returnList log "Warning in $procName: Auto value \
                                                    to -speed option should be set only for Ethernet \
                                                    ports."
                                        }
                                    }
                                } else  {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: Auto value \
                                            to -speed option should be set only when \
                                            -autonegotiation is true."
                                }
                            }
                            default {}
                        }
                        set retCode [port set $chassis $card $port]
                        if {$retCode} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: port set failed on\
                                    $chassis $card $port.  Return code was $retCode. $::ixErrorInfo."
                        }
                    }
                    duplex {
                        if {[::ixia::portSupports \
                                $chassis $card $port ethernet] != 0} {
                            if {$single_option == "auto"} {
                                if {[info exists speed]} {
                                    if {[llength $speed] <= $option_index} {
                                        set speed_value [lindex $speed end]
                                    } else {
                                        set speed_value [lindex $speed $option_index]
                                    }
                                } else  {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: Auto value \
                                            to -duplex option should be set in combination \
                                            with a -speed value."
                                }
                                if {[info exists autonegotiation]} {
                                    if {[llength $autonegotiation] <= $option_index} {
                                        set autonegotiation_value [lindex $autonegotiation end]
                                    } else {
                                        set autonegotiation_value [lindex $autonegotiation $option_index]
                                    }
                                } else  {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: Auto value \
                                            to -duplex option should be set only when \
                                            -autonegotiation is true."
                                }
                                debug "DUPLEX = $autonegotiation_value $single_option $speed_value "
                                if {$autonegotiation_value == 1} {
                                    set _type [lindex [::ixia::portSupports $chassis $card $port ethernet] end]
                                    switch -- $_type {
                                        10 -
                                        100 -
                                        1000 {
                                            set sv(ether10)   10
                                            set sv(ether100)  100
                                            set sv(ether1000) 1000
                                            set sv(auto)      auto
                                            set speed_value $sv($speed_value)
                                            port config -advertise10HalfDuplex   [expr $neg($speed_value,$single_option) & $neg_10h  ]
                                            port config -advertise10FullDuplex   [expr $neg($speed_value,$single_option) & $neg_10f  ]
                                            port config -advertise100HalfDuplex  [expr $neg($speed_value,$single_option) & $neg_100h ]
                                            port config -advertise100FullDuplex  [expr $neg($speed_value,$single_option) & $neg_100f ]
                                            port config -advertise1000FullDuplex [expr $neg($speed_value,$single_option) & $neg_1000f]
                                        }
                                        default {
#                                             keylset returnList status $::FAILURE
                                            puts "Warning in $procName: Auto value \
                                                    to -duplex option should be set only for Ethernet \
                                                    ports."
                                            update idletasks
                                            keylset returnList log "Warning in $procName: Auto value \
                                                    to -duplex option should be set only for Ethernet \
                                                    ports."
                                        }
                                    }
                                } else  {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: Auto value \
                                            to -duplex option should be set only when \
                                            -autonegotiation is true."
                                }
                            } else {
                                port config -duplex $single_option
                                
                                if {[llength $speed] == 1} {
                                    set temp_speed $speed
                                } else {
                                    set temp_speed [lindex $speed $option_index]
                                }
                                switch -- $temp_speed {
                                    ether10 -
                                    10 {
                                        port config -advertise100HalfDuplex $::false
                                        port config -advertise100FullDuplex $::false
                                        port config -advertise1000FullDuplex $::false
                                        switch $single_option {
                                            half {
                                                port config -advertise10HalfDuplex \
                                                        $::true
                                                port config -advertise10FullDuplex \
                                                        $::false
                                            }
                                            full {
                                                port config -advertise10HalfDuplex \
                                                        $::false
                                                port config -advertise10FullDuplex \
                                                        $::true
                                            }
                                        }
                                    }
                                    ether100 -
                                    100 {
                                        port config -advertise10HalfDuplex $::false
                                        port config -advertise10FullDuplex $::false
                                        port config -advertise1000FullDuplex $::false
                                        switch $single_option {
                                            half {
                                                port config -advertise100HalfDuplex \
                                                        $::true
                                                port config -advertise100FullDuplex \
                                                        $::false
                                            }
                                            full {
                                                port config -advertise100HalfDuplex \
                                                        $::false
                                                port config -advertise100FullDuplex \
                                                        $::true
                                            }
                                        }
                                    }
                                    ether1000 -
                                    1000 {
                                        port config -advertise10HalfDuplex $::false
                                        port config -advertise10FullDuplex $::false
                                        port config -advertise100HalfDuplex $::false
                                        port config -advertise100FullDuplex $::false
                                        port config -advertise1000FullDuplex $::true
                                    }
                                    default {}
                                }
                            }
                        }
                    }
                    op_mode {
                        if {[port isValidFeature $chassis $card $port \
                                portFeatureSimulateCableDisconnect]} {
                            switch -- $single_option {
                                normal   {
                                    port config -loopback $::false
                                    port config -enableSimulateCableDisconnect \
                                            $::false
                                }
                                loopback {
                                    port config -loopback $::true
                                    port config -enableSimulateCableDisconnect \
                                            $::false
                                }
                                sim_disconnect {
                                    port config -enableSimulateCableDisconnect \
                                            $::true
                                }
                            }
                        } elseif {($port_type == "sonet") || \
                                    ($port_type == "atm")} {
                            switch -- $single_option {
                                normal   {
                                    sonet config -operation sonetNormal
                                }
                                loopback {
                                    sonet config -operation sonetLineLoopback
                                }
                                monitor {
                                    sonet config -operation \
                                            sonetFramerDiagnosticLoopback
                                }
                            }
                            set sonet_flag 1
                        }
                    }
                    clocksource {
                        if { $single_option == "internal" } {
                            sonet config -useRecoveredClock $::sonetNoClock
                        } elseif {$single_option == "external"} {
                            sonet config -useRecoveredClock $::sonetExternalClock
                        } elseif {$single_option == "loop"} {
                            sonet config -useRecoveredClock $::sonetRecoveredClock
                        }
                        set sonet_flag 1
                    }
                    tx_fcs {
                        sonet config -txCrc sonetCrc$single_option
                        set sonet_flag 1
                    }
                    rx_fcs {
                        sonet config -rxCrc sonetCrc$single_option
                        set sonet_flag 1
                    }
                    rx_scrambling -
                    tx_scrambling {
                        sonet config -dataScrambling $single_option
                        set sonet_flag 1
                    }
                    autonegotiation {
                        port config -autonegotiate $single_option
                    }
                    rx_c2 {
                        sonet config -C2byteExpected \
                                [hex2dec_list $single_option]
                        
                        set sonet_flag 1
                    }
                    tx_c2 {
                        sonet config -C2byteTransmit \
                                [hex2dec_list $single_option]
                        
                        set sonet_flag 1
                    }
                    intf_mode {
                        set switchMode 0
                        set int_mode_single_option $single_option
                        switch $single_option {
                            pos_hdlc {
                                # It seems there is no difference between
                                # sonetCiscoHdlc and sonetCiscoHdlcIpv6, so
                                # always using sonetCiscoHdlc.
                                sonet config -header sonetCiscoHdlc
                                set switchMode 1
                                set sonet_flag 1
                            }
                            other {
                                sonet config -header sonetOther
                                set switchMode 1
                                set sonet_flag 1
                            }
                            frame_relay1490 {
                                sonet config -header sonetFrameRelay1490
                                set switchMode 1
                                set sonet_flag 1
                            }
                            frame_relay2427 {
                                sonet config -header sonetFrameRelay2427
                                set switchMode 1
                                set sonet_flag 1
                            }
                            frame_relay_cisco {
                                sonet config -header sonetFrameRelayCisco
                                set switchMode 1
                            }
                            srp {
                                sonet config -header sonetSrp
                                set sonet_flag 1
                            }
                            srp_cisco {
                                sonet config -header sonetSrp
                                sonet config -enableCiscoSrp true
                                set sonet_flag 1
                            }
                            rpr {
                                sonet config -header sonetRpr
                                sonet config -rprHecSeed $rpr_hec_seed
                                set sonet_flag 1
                            }
                            atm {
                                sonet config -header sonetAtm
                                set switchMode 2
                                set sonet_flag 1
                            }
                            pos_ppp {
                                sonet config -header sonetHdlcPppIp
                                ppp config   -enable $::true
                                set ppp_flag 1
                                set switchMode 1
                                set sonet_flag 1
                            }
                            gfp {
                                sonet config -header sonetGfp
                                set sonet_flag 1
                            }
                            ethernet {
                                catch {port config -portMode $::portEthernetMode}
                                set portModeConfiguredInitial $portModeConfigured
                                set portModeConfigured ethernet
                                if {[lsearch [::ixia::portSupports $chassis $card $port ethernet] 100000] != -1} {
                                    port setTransmitMode $hundred_gig_mode(ethernet) $chassis $card $port
                                }
                                if {(($portModeConfigured == "bert" && $portModeConfiguredInitial != "bert") || \
                                        ($portModeConfigured == "ethernet" && $portModeConfiguredInitial == "bert")) &&\
                                        ([lsearch [::ixia::portSupports $chassis $card $port ethernet] 100000] != -1 || \
                                        [lsearch [::ixia::portSupports $chassis $card $port ethernet] 40000] != -1) && \
                                        ([::ixia::portSupports $chassis $card $port bert] == 1)} {
                                    if {[port write $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to set port $chassis $card $port in \
                                                $portModeConfigured mode."
                                        return $returnList
                                    }
                                    if {[port get $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to set port $chassis $card $port in \
                                                $portModeConfigured mode."
                                        return $returnList
                                    }
                                }
                            }
                            bert {
                                catch {port config -portMode $::portBertMode}
                                set portModeConfiguredInitial $portModeConfigured
                                set portModeConfigured bert
                                port setTransmitMode $hundred_gig_mode(bert) $chassis $card $port
                                if {(($portModeConfigured == "bert" && $portModeConfiguredInitial != "bert") || ($portModeConfigured == "ethernet" && $portModeConfiguredInitial == "bert")) &&\
                                        ([lsearch [::ixia::portSupports $chassis $card $port ethernet] 100000] != -1 || \
                                        [lsearch [::ixia::portSupports $chassis $card $port ethernet] 40000] != -1) && \
                                        ([::ixia::portSupports $chassis $card $port bert] == 1)} {
                                    if {[port write $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to set port $chassis $card $port in \
                                                $portModeConfigured mode."
                                        return $returnList
                                    }
                                    if {[port get $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to set port $chassis $card $port in \
                                                $portModeConfigured mode."
                                        return $returnList
                                    }
                                }
                            }
                            default { }
                        }
                        
                        if {$switchMode} {
                            # This is special code for the LM622 module so
                            # that we will change the port mode as necessary
                            if {[port isValidFeature $chassis $card $port \
                                        portFeatureAtmPos]} {
                                if {[port isActiveFeature $chassis $card $port \
                                            portFeatureAtm]} {
                                    set atm2posChange 1
                                } else {
                                    set atm2posChange 0
                                }
                                if {$switchMode == 2} {
                                    port config -portMode portAtmMode
                                    set portModeConfigured atm
                                } else {
                                    port config -portMode portPosMode
                                    set portModeConfigured pos
                                }
                                port set $chassis $card $port
                                # If port is changed to portPosMode a default
                                # stream is created.
                                if {$atm2posChange == 1} {
                                    set retCode [port reset $chassis $card $port]
                                    if {$retCode} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR: \
                                                Unable to reset port:  \
                                                $chassis $card $port"
                                        return $returnList
                                    }
                                }
                            }
                        }
                    }
                    ppp_mpls_negotiation {
                        set ppp_flag 1
                        ppp config -enable $::true
                        ppp config -enableMpls $single_option
                    }
                    ppp_ipv6_negotiation {
                        set ppp_flag 1
                        ppp config -enable $::true
                        ppp config -enableIpV6 $single_option
                    }
                    ppp_ipv4_negotiation {
                        set ppp_flag 1
                        ppp config -enable $::true
                        ppp config -enableIp $single_option
                    }
                    ppp_osi_negotiation {
                        set ppp_flag 1
                        ppp config -enable $::true
                        ppp config -enableOsi $single_option
                    }
                    ppp_ipv4_address {
                        set ppp_flag 1
                        ppp config -localIPAddress $single_option
                    }
                    port_rx_mode {
                        foreach rx_mode $single_option {
                            
                            if {($rx_mode != "echo") && \
                                        ([port cget -receiveMode] == \
                                        $::portRxModeEcho)} {
                                catch {port config -transmitMode \
                                            portTxModeAdvancedScheduler}
                            }
                            
                            switch -- $rx_mode {
                                capture {
                                    set portReceiveMode [expr $portReceiveMode\
                                            | $::portCapture]
                                }
                                echo {
                                    if {[::ixia::get_port_type           \
                                                $chassis $card $port] == \
                                                "ethernet1000"} {
                                        set portReceiveMode [expr \
                                                $portReceiveMode  \
                                                | $::portRxModeEcho]
                                    } else  {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Rx Mode Echo\
                                                not supported on port: \
                                                $chassis/$card/$port"
                                        return $returnList
                                    }
                                    
                                }
                                packet_group {
                                    set portReceiveMode [expr $portReceiveMode\
                                            | $::portPacketGroup]
                                    set pgid_flag 1
                                }
                                data_integrity {
                                    set portReceiveMode [expr $portReceiveMode\
                                            | $::portRxDataIntegrity]
                                }
                                sequence_checking {
                                    set portReceiveMode [expr $portReceiveMode\
                                            | $::portRxSequenceChecking]
                                }
                                wide_packet_group {
                                    set portReceiveMode [expr $portReceiveMode\
                                            | $::portRxModeWidePacketGroup]
                                    if {$auto_detect_rx != 0} {
                                        set _optEna enableAutoDetectInstrumentation
                                        catch {port config -$_optEna $::false}
                                        autoDetectInstrumentation setDefault
                                        set auto_detect_rx_flag 1
                                    }
                                }
                                auto_detect_instrumentation {
                                    if {$auto_detect_rx == 0} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Auto detect\
                                                instrumentation is not\
                                                supported on port\
                                                $chassis $card $port"
                                        return $returnList
                                    }
                                    set portReceiveMode [expr $portReceiveMode\
                                            | $::portRxModeWidePacketGroup]
                                    
                                    set _optEna enableAutoDetectInstrumentation
                                    catch {port config -$_optEna $::true}
                                    
                                    autoDetectInstrumentation setDefault
                                    
                                    set auto_detect_rx_flag 1
                                }
                                default {}
                            }
                        }
                    }
                    pgid_mode {
                        if {[info exists port_rx_mode] && \
                                ([lindex $port_rx_mode $option_index] != "wide_packet_group") && \
                                ([lindex $port_rx_mode $option_index] != "auto_detect_instrumentation")} {
                            debug "port_rx_mode = $port_rx_mode"
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR on $procName: \
                                    pgid_mode is allowed only with port_rx_mode \
                                    = wide_packet_group"
                            return $returnList
                        }
                        array set pgidModeArray "                           \
                                custom      $::packetGroupCustom            \
                                dscp        $::packetGroupDscp              \
                                ipv6TC      $::packetGroupIpV6TrafficClass  \
                                mplsExp     $::packetGroupMplsExp           \
                                split       $::packetGroupSplit             \
                                "
                        debug "packetGroup config -groupIdMode $pgidModeArray($single_option)"
                        packetGroup config -groupIdMode $pgidModeArray($single_option)
                        if {[info exists port_rx_mode] && \
                                [lindex $port_rx_mode $option_index] == "wide_packet_group" && \
                                [info exists pgid_mode] && \
                                [lindex $pgid_mode $option_index] == "split"} {
                            set splitPacketGroup_command [list]
                            for {set i 1} {$i < 4} {incr i} {
                                set pg pgid_split${i}
                                if {[info exists ${pg}_mask] && \
                                        [info exists ${pg}_offset     ] && \
                                        [info exists ${pg}_offset_from] && \
                                        [info exists ${pg}_width      ] && \
                                        ([lindex [set ${pg}_mask]        $option_index] == {}) && \
                                        ([lindex [set ${pg}_offset]      $option_index] == {}) && \
                                        ([lindex [set ${pg}_offset_from] $option_index] == {}) && \
                                        ([lindex [set ${pg}_width]       $option_index] == {})} {
                                    continue
                                }
                                if {[info exists ${pg}_mask] || \
                                        [info exists ${pg}_offset] || \
                                        [info exists ${pg}_offset_from] || \
                                        [info exists ${pg}_width]} {
                                    append splitPacketGroup_command "splitPacketGroup setDefault; "
                                    if {[info exists ${pg}_mask] && [info exists ${pg}_width] && \
                                            [lindex [set ${pg}_mask] $option_index] != {} && \
                                            [lindex [set ${pg}_width] $option_index] != {}} {
                                        if {[regexp -nocase -- {^0x[\da-fA-F]+$} \
                                                [lindex [set ${pg}_mask] $option_index] split_hex] == 0} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in $procName:\
                                                    Invalid value for\
                                                    ${pg}_mask for\
                                                    interface $option_index."
                                            return $returnList
                                        } else {
                                            append splitPacketGroup_command "splitPacketGroup config\
                                                    -groupIdMask [list [hex2list $split_hex]]; "
                                        }
                                        if {![string is integer [lindex [set ${pg}_width] $option_index]] || \
                                                ([string is integer [lindex [set ${pg}_width] $option_index]] && \
                                                ([lindex [set ${pg}_width] $option_index] < 0 || \
                                                [lindex [set ${pg}_width] $option_index] > 4))} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in $procName:\
                                                    Invalid value([lindex [set ${pg}_width] $option_index]) for\
                                                    ${pg}_width for\
                                                    interface number $option_index."
                                            return $returnList
                                        } else {
                                            append splitPacketGroup_command "splitPacketGroup config\
                                                    -groupIdWidth [lindex [set ${pg}_width] $option_index]; "
                                        }
                                    } elseif {([info exists ${pg}_mask] && [info exists ${pg}_width] && \
                                            [lindex [set ${pg}_mask] $option_index] != {}) || \
                                            (  [info exists ${pg}_mask] && ![info exists ${pg}_width] && \
                                            [lindex [set ${pg}_mask] $option_index] != {})} {
                                        if {[regexp -nocase -- {^0x[\da-fA-F]+$} \
                                                [lindex [set ${pg}_mask] $option_index] split_hex] == 0} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in $procName:\
                                                    Invalid value([lindex [set ${pg}_mask] $option_index]) for\
                                                    ${pg}_mask for\
                                                    interface $option_index."
                                            return $returnList
                                        } else {
                                            append splitPacketGroup_command "splitPacketGroup config\
                                                    -groupIdMask [list [hex2list $split_hex]]; "
                                            
                                            append splitPacketGroup_command "splitPacketGroup config\
                                                    -groupIdWidth [llength [hex2list $split_hex]]; "
                                        }
                                    } elseif {([info exists ${pg}_mask] && [info exists ${pg}_width] && \
                                            [lindex [set ${pg}_width] $option_index] != {}) || \
                                            ( ![info exists ${pg}_mask] && [info exists ${pg}_width] && \
                                            [lindex [set ${pg}_width] $option_index] != {})} {
                                        if {![string is integer [lindex [set ${pg}_width] $option_index]] || \
                                                ([string is integer [lindex [set ${pg}_width] $option_index]] && \
                                                ([lindex [set ${pg}_width] $option_index] < 0 || \
                                                [lindex [set ${pg}_width] $option_index] > 4))} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in $procName:\
                                                    Invalid value([lindex [set ${pg}_width] $option_index]) for\
                                                    ${pg}_width for\
                                                    interface $option_index."
                                            return $returnList
                                        } else {
                                            append splitPacketGroup_command "splitPacketGroup config\
                                                    -groupIdWidth [lindex [set ${pg}_width] $option_index]; "
                                            
                                            append splitPacketGroup_command "splitPacketGroup config\
                                                    -groupIdMask [list [string trim [string repeat \
                                                    " FF" [lindex [set ${pg}_width] $option_index]]]]; "
                                        }
                                    }
                                    if {[info exists ${pg}_offset] && \
                                            [lindex [set ${pg}_offset] $option_index] != {}} {
                                        if {[string is integer [lindex [set ${pg}_offset] $option_index]]} {
                                            append splitPacketGroup_command "splitPacketGroup config\
                                                    -groupIdOffset [lindex [set ${pg}_offset] $option_index]; "
                                        } else {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in $procName:\
                                                    invalid value for\
                                                    ${pg}_offset for\
                                                    interface $option_index."
                                            return $returnList
                                        }
                                    }
                                    if {[info exists ${pg}_offset_from] && \
                                            [lindex [set ${pg}_offset_from] $option_index] != {}} {
                                        
                                        if {[lindex [set ${pg}_offset_from] $option_index] == \
                                                "start_of_frame"} {
                                            append splitPacketGroup_command "splitPacketGroup config\
                                                    -groupIdOffsetBaseType $::splitPgidStartOfFrame; "
                                        } elseif {[lindex [set ${pg}_offset_from] $option_index] == \
                                                "offset_from_signature"} {
                                            append splitPacketGroup_command "splitPacketGroup config\
                                                    -groupIdOffsetBaseType $::splitPgidOffsetFromSignature; "
                                        } else {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in $procName:\
                                                    invalid value for\
                                                    ${pg}_offset_from\
                                                    for\
                                                    interface $option_index."
                                            return $returnList
                                        }
                                    }
                                }
                                append splitPacketGroup_command "splitPacketGroup\
                                        set $chassis $card $port [expr $i - 1]; "
                            }
                        }
                    }
                    signature {
                        catch {unset _temp}
                        if {[info exists port_rx_mode] } {
                            set _temp [lsearch [lindex $port_rx_mode \
                                    $option_index] auto_detect_instrumentation]
                        }
                        
                        if {[info exists _temp] && ($_temp != -1) } {
                            if {$auto_detect_rx == 0} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        Auto detect\
                                        instrumentation is not\
                                        supported on port\
                                        $chassis $card $port"
                                return $returnList
                            }
                            if {[regexp {^[0-9a-fA-F]{2}( [0-9a-fA-F]{2}){11}$} $signature]} {
                                set single_option $signature
                            }
                            
                            set retCode [::ixia::format_signature_hex \
                                    $single_option 12]
                            
                            if {[keylget retCode status] == $::FAILURE} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        [keylget retCode log]."
                                return $returnList
                            }
                            set single_option [keylget retCode signature]
                            
                            autoDetectInstrumentation config -signature \
                                    $single_option
                        } else  {
                            if {[regexp {^[0-9a-fA-F]{2}( [0-9a-fA-F]{2}){3}$} $signature]} {
                                set single_option $signature
                            }
                            set retCode [::ixia::format_signature_hex \
                                    $single_option 4]
                            
                            if {[keylget retCode status] == $::FAILURE} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        [keylget retCode log]."
                                return $returnList
                            }
                            set single_option [keylget retCode signature]
                            packetGroup config -signature $single_option
                            if {![info exists tgen_offset_value($chassis/$card/$port)]} {
                                set tgen_offset_value($chassis/$card/$port) 0
                            }
                            set tgen_offset_value($chassis/$card/$port) [expr \
                                    $tgen_offset_value($chassis/$card/$port) | 0x4]
                        }
                    }
                    signature_mask {
                        if {$auto_detect_rx == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Invalid option\
                                    -signature_mask. Auto detect\
                                    instrumentation is not\
                                    supported on port\
                                    $chassis $card $port"
                            return $returnList
                        }
                        catch {unset _temp}
                        if {[info exists port_rx_mode] } {
                            set _temp [lsearch [lindex $port_rx_mode \
                                    $option_index] auto_detect_instrumentation]
                        }
                        if {[regexp {^[0-9a-fA-F]{2}( [0-9a-fA-F]{2}){11}$} $signature_mask]} {
                            set single_option $signature_mask
                        }
                        set retCode [::ixia::format_signature_hex \
                                $single_option 12]
                        
                        if {[keylget retCode status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    [keylget retCode log]."
                            return $returnList
                        }
                        set single_option [keylget retCode signature]
                        
                        if {[info exists _temp] && ($_temp != -1) } {
                            autoDetectInstrumentation config \
                                    -enableSignatureMask $::true
                            
                            autoDetectInstrumentation config \
                                    -signatureMask $single_option
                        }
                    }
                    signature_start_offset {
                        if {$auto_detect_rx == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Invalid option\
                                    -signature_start_offset. Auto detect\
                                    instrumentation is not\
                                    supported on port\
                                    $chassis $card $port"
                            return $returnList
                        }
                        catch {unset _temp}
                        if {[info exists port_rx_mode] } {
                            set _temp [lsearch [lindex $port_rx_mode \
                                    $option_index] auto_detect_instrumentation]
                        }
                        if {[info exists _temp] && ($_temp != -1) } {
                            autoDetectInstrumentation config -startOfScan \
                                    $single_option
                        }
                    }
                    signature_offset {
                        packetGroup config -signatureOffset $single_option
                        if {![info exists tgen_offset_value($chassis/$card/$port)]} {
                            set tgen_offset_value($chassis/$card/$port) 0
                        }
                        set tgen_offset_value($chassis/$card/$port) [expr \
                                $tgen_offset_value($chassis/$card/$port) | 0x2]
                    }
                    sequence_checking {
                        if {$single_option == 1} {
                            set portReceiveMode [expr $portReceiveMode | \
                                    $::portRxSequenceChecking]
                        }
                    }
                    sequence_num_offset {
                        packetGroup config -sequenceNumberOffset $single_option
                    }
                    data_integrity {
                        if {$single_option == 1} {
                            set portReceiveMode [expr $portReceiveMode | \
                                    $::portRxDataIntegrity]
                            
                            dataIntegrity setDefault
                            dataIntegrity config -enableTimeStamp $::true
                            
                            if {[info exists integrity_signature]} {
                                if {[regexp {^[0-9a-fA-F]{2}( [0-9a-fA-F]{2}){3}$} $integrity_signature]} {
                                    set is_option $integrity_signature
                                } elseif {[llength $integrity_signature] > 1} {
                                    set is_option [lindex $integrity_signature $option_index]
                                } else {
                                    set is_option $integrity_signature
                                }
                                set retCode [::ixia::format_signature_hex \
                                        $is_option 4]
                                
                                if {[keylget retCode status] == $::FAILURE} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: \
                                            [keylget retCode log]."
                                    return $returnList
                                }
                                set is_option [keylget retCode signature]
                                
                                dataIntegrity config -signature \
                                        $is_option
                            }
                            
                            if {[info exists integrity_signature_offset]} {
                                if {[llength $integrity_signature_offset] > 1} {
                                    set iso_option [lindex \
                                            $integrity_signature_offset \
                                            $option_index]
                                } else  {
                                    set iso_option $integrity_signature_offset
                                }
                                dataIntegrity config -signatureOffset \
                                        $iso_option
                            }
                            
                            if {[dataIntegrity setRx $chassis $card $port]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        Data Integrity not\
                                        supported on port $chassis $card $port"
                                return $returnList
                            }
                            
                            set statConfigMode statModeDataIntegrity
                        }
                    }
                    transmit_mode {
                        if {($single_option != "echo") && \
                                    ([port cget -transmitMode] == \
                                    $::portTxModeEcho)} {
                            catch {port config -receiveMode \
                                        portPacketGroup}
                        }
                        if {$single_option == "advanced"} {
                            catch {port config -transmitMode \
                                        portTxModeAdvancedScheduler}
                        } elseif {$single_option == "flows"} {
                            catch {port config -transmitMode \
                                        portTxPacketFlows}
                        } elseif {$single_option == "stream"} {
                            catch {port config -transmitMode \
                                        portTxPacketStreams}
                        } elseif {$single_option == "echo"} {
                            if {[::ixia::get_port_type $chassis $card $port ] \
                                        == "ethernet1000"} {
                                catch {port config -transmitMode \
                                            portTxModeEcho}
                                catch {port config -receiveMode \
                                            portRxModeEcho}
                            } else  {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        Tx Mode Echo not\
                                        supported on port $chassis $card $port"
                                return $returnList
                            }
                        }
                    }
                    qos_stats {
                        switch -- $single_option {
                            0 {
                                set statConfigMode statNormal
                            }
                            1 {
                                set statConfigMode statQos
                                set qos_flag 1
                            }
                        }
                    }
                    qos_packet_type {
                        if {$qos_packet_type == "not_specified" && [port\
                                isActiveFeature $chassis $card $port\
                                portFeatureAtm]} {
                            set single_option ip_atm
                            set qos_packet_type ip_atm
                        }
                        if {$qos_packet_type == "not_specified" && [port\
                                isActiveFeature $chassis $card $port\
                                portFeaturePos]} {
                            set single_option ip_cisco_hdlc
                            set qos_packet_type ip_cisco_hdlc
                        }
                        if {$qos_packet_type == "not_specified"} {
                            if {[info exists intf_mode]} {
                                if {[llength $intf_mode] > 1} {
                                    set cr_intf_mode [lindex $intf_mode $option_index]
                                } else {
                                    set cr_intf_mode $intf_mode
                                }
                                if {[catch {set single_option $QoSpacketTypeIntfModeArray($cr_intf_mode)}]} {
                                    set single_option ethernet
                                }
                            } else {
                                set single_option ethernet
                            }
                        }
                        if {[info exists qosEnumList($single_option)]} {
                            catch {qos config -packetType \
                                        $qosEnumList($single_option)}
                        }
                    }
                    qos_byte_offset {
                        if {$single_option != ""} {
                            catch {qos config -byteOffset $single_option}
                        }
                    }
                    qos_pattern_offset {
                        if {$single_option != ""} {
                            catch {qos config -patternOffset $single_option}
                        }
                    }
                    qos_pattern_match {
                        if {$single_option != ""} {
                            catch {qos config -patternMatch $single_option}
                        }
                    }
                    qos_pattern_mask {
                        if {$single_option != ""} {
                            catch {qos config -patternMask $single_option}
                        }
                    }
                    atm_enable_coset {
                        if {![info exists switchMode] || $switchMode != 2} {
                            # Skip atmPort config if portMode is not ATM
                            continue
                        }
                        catch {atmPort config -enableCoset $single_option}
                        set atm_flag 1
                    }
                    atm_enable_pattern_matching {
                        # Only valid in IxOS 3.80 and greater
                        if {![info exists switchMode] || $switchMode != 2} {
                            # Skip atmPort config if portMode is not ATM
                            continue
                        }
                        catch {atmPort config -enableAtmPatternMatching \
                                    $single_option}
                        set atm_flag 1
                    }
                    atm_filler_cell {
                        if {![info exists switchMode] || $switchMode != 2} {
                            # Skip atmPort config if portMode is not ATM
                            continue
                        }
                        switch -- $single_option {
                            idle {
                                atmPort config -fillerCell atmIdleCell
                            }
                            unassigned {
                                atmPort config -fillerCell atmUnassignedCell
                            }
                        }
                        set atm_flag 1
                    }
                    atm_interface_type {
                        if {![info exists switchMode] || $switchMode != 2} {
                            # Skip atmPort config if portMode is not ATM
                            continue
                        }
                        switch -- $single_option {
                            uni {
                                atmPort config -interfaceType atmInterfaceUni
                            }
                            nni {
                                atmPort config -interfaceType atmInterfaceNni
                            }
                        }
                        set atm_flag 1
                    }
                    atm_packet_decode_mode {
                        if {![info exists switchMode] || $switchMode != 2} {
                            # Skip atmPort config if portMode is not ATM
                            continue
                        }
                        switch -- $single_option {
                            frame {
                                atmPort config -packetDecodeMode atmDecodeFrame
                            }
                            cell {
                                atmPort config -packetDecodeMode atmDecodeCell
                            }
                        }
                        set atm_flag 1
                    }
                    atm_reassembly_timeout {
                        if {![info exists switchMode] || $switchMode != 2} {
                            # Skip atmPort config if portMode is not ATM
                            continue
                        }
                        atmPort config -reassemblyTimeout $single_option
                        set atm_flag 1
                    }
                    pgid_128k_bin_enable {
                        packetGroup config -enable128kBinMode $single_option
                    }
                    pgid_mask {
                        packetGroup config -enableGroupIdMask true
                        packetGroup config -groupIdMask \
                                [hextodec [join $single_option ""]]
                    }
                    pgid_offset {
                        packetGroup config -groupIdOffset $single_option
                        if {![info exists tgen_offset_value($chassis/$card/$port)]} {
                            set tgen_offset_value($chassis/$card/$port) 0
                        }
                        set tgen_offset_value($chassis/$card/$port) [expr \
                                $tgen_offset_value($chassis/$card/$port) | 0x1]
                    }
                    ignore_link {
                        if {[info exists switchMode] && $switchMode == 2} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    ignore_link feature not\
                                    supported for ports in atm mode."
                            return $returnList
                        }
                        if {[port isValidFeature $chassis $card $port 193]} {
                            if {$single_option == "1"} {
                                port config -ignoreLink true
                                set ignoreLinkState([list $chassis $card \
                                        $port]) 1
                            } else {
                                port config -ignoreLink false
                                set ignoreLinkState([list $chassis $card \
                                        $port]) 0
                            }
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Feature\
                                    Transmit Ignore Link Status not available\
                                    on specified ports."
                            return $returnList
                        }
                    }
                    transmit_clock_source {
                        if {[port isValidFeature $chassis $card $port portFeatureFrequencyOffset]} {
                            switch -- $single_option {
                                internal {
                                    catch {port configure -transmitClockMode $::portClockExternal}
                                }
                                bits {
                                    catch {port configure -transmitClockMode $::portClockExternal}
                                }
                                loop {
                                    catch {port configure -transmitClockMode $::portClockExternal}
                                }
                                external {
                                    catch {port configure -transmitClockMode $::portClockExternal}
                                }
                                internal_ppm_adj {
                                    catch {port configure -transmitClockMode $::portClockInternal}
                                }
                                default {
                                    catch {port configure -transmitClockMode $::portClockExternal}
                                }
                            }
                        } elseif {[card isValidFeature $chassis $card cardFeatureFrequencyOffset]} {
                            set processed_clock_select(${chassis}/${card}) 1
                            card get $chassis $card
                            switch -- $single_option {
                                internal {
                                    catch {card config -clockSelect 0}
                                }
                                external {
                                    catch {card config -clockSelect 1}
                                }
                                default {
                                    catch {card config -clockSelect 0}
                                }
                            }
                            card set $chassis $card
                            card write $chassis $card
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Card ${chassis}/${card} does not support\
                                    frequency deviation."
                        }
                    }
                    internal_ppm_adjust {
                        if {[port isValidFeature $chassis $card $port $::portFeatureFrequencyOffset]} {
                            catch {port config -transmitClockDeviation $single_option}
                        } elseif {[card isValidFeature $chassis $card $::cardFeatureFrequencyOffset]} {
                            if {[info exists processed_frequency_deviation(${chassis}/${card})]} {
                                continue
                            }
                            set processed_frequency_deviation(${chassis}/${card}) 1
                            card get $chassis $card
                            card config -txFrequencyDeviation $single_option
                            card set $chassis $card
                            card write $chassis $card
                        } elseif {[lsearch [list 191 193 197 199 200] [card cget -type]] != -1 } {
                            # Jasper cards
                            # 191 - XM100GE4CXP          - 4 ports 100Gig
                            # 193 - XM100GE4CXP+FAN      - 16 ports 1-4 100Gig 5-16 10/40 Gig
                            # 197 - XM40GE12QSFP+FAN     - 12 ports 10/40 Gig
                            # 199 - XM10/40GE12QSFP+FAN  - 12 ports 10/40 Gig
                            # 200 - XM10/40GE06QSFP+FAN  - 06 ports 10/40 Gig
                            if {[resourceGroupEx get $chassis $card $port]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to execute resourceGroupEx get $chassis $card $port\
                                        while configuring internal ppm. $::ixErrorInfo"
                                return $returnList
                            }
                            resourceGroupEx config -ppm $single_option
                            if {[resourceGroupEx set $chassis $card $port]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to execute resourceGroupEx set $chassis $card $port\
                                        while configuring internal ppm. $::ixErrorInfo"
                                return $returnList
                            }
                            if {[resourceGroupEx write $chassis $card $port]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to execute resourceGroupEx write $chassis $card $port\
                                        while configuring internal ppm. $::ixErrorInfo"
                                return $returnList
                            }
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Card ${chassis}/${card} does not support\
                                    frequency deviation."
                        }
                    }
                    intrinsic_latency_adjustment {
                        if {$single_option == 1} {
                            set intrinsic_value true
                        } else {
                            set intrinsic_value false
                        }
                        catch {ixEnablePortIntrinsicLatencyAdjustment $chassis $card $port $intrinsic_value write}
                    }
                    tx_rx_sync_stats_enable {
                        catch {port config -enableTxRxSyncStatsMode $single_option}
                    }
                    tx_rx_sync_stats_interval {
                        catch {port config -txRxSyncInterval $single_option}
                    }
                    tx_lanes {
                        # Check if port mode is set on ethernet
                        if {($portModeConfigured == "ethernet")} {
                            #send the txLanes string for parsing and validation
                            if {![info exists port_speed]} {
                                set port_speed ether100Gig
                            }
                            set txLaneCode [::ixia::validate_configure_tx_lane $single_option [join $interface /] $port_speed]
                            if {[keylget txLaneCode status] != $::SUCCESS} {
                                return $txLaneCode
                            }
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: PCS parameters can not be set on\
                                    $chassis/$card/$port . Port mode must be ethernet. Return code was $retCode.\
                                    \n$::ixErrorInfo"
                            return $returnList
                        }
                    }
                    bert_configuration {
                        # Check if port mode is set on BERT
                        if {($portModeConfigured == "bert")} {
                            if {![info exists port_speed]} {
                                set port_speed ether100Gig
                            }
                            set bertConfigCode [::ixia::validate_configure_bert $single_option [join $interface /] $port_speed]
                            if {[keylget bertConfigCode status] != $::SUCCESS} {
                                return $bertConfigCode
                            }
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: BERT parameters can not be set on\
                                    $chassis/$card/$port . Port mode must be bert. Return code was $retCode.\
                                    \n$::ixErrorInfo"
                            return $returnList
                        }
                    }
                    bert_error_insertion {
                        # Check if port mode is set on BERT
                        if {($portModeConfigured == "bert")} {
                            if {![info exists port_speed]} {
                                set port_speed ether100Gig
                            }
                            set bertConfigCode [::ixia::validate_configure_bert_error_insertion $single_option [join $interface /] $port_speed]
                            if {[keylget bertConfigCode status] != $::SUCCESS} {
                                return $bertConfigCode
                            }
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: BERT parameters can not be set on\
                                    $chassis/$card/$port . Port mode must be bert. Return code was $retCode.\
                                    \n$::ixErrorInfo"
                            return $returnList
                        }
                    }
                    pcs_marker_fields -
                    pcs_sync_bits -
                    pcs_enabled_continuous -
                    pcs_lane -
                    pcs_period_type -
                    pcs_repeat -
                    pcs_count -
                    pcs_period {
                        # Check if port mode is set on ethernet
                        if {(!$pcs_lanes_configured)&&($portModeConfigured == "ethernet")} {
                            set pcs_lanes_configured 1
                            set pcs_lanes_map {
                                        pcs_marker_fields           laneMarkerFields
                                        pcs_sync_bits               syncBits
                                        pcs_enabled_continuous      enableContinuous
                                        pcs_lane                    pcsLane
                                        pcs_period_type             periodType
                                        pcs_repeat                  repeat
                                        pcs_count                   count
                                        pcs_period                  period
                            }
                            if {[pcsLaneError get $chassis $card $port]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: PCS Lane Error get failed on\
                                        $chassis $card $port. Return code was $retCode. $::ixErrorInfo."
                                return $returnList
                            }
                            foreach {hlt_p ixos_p} $pcs_lanes_map {
                                if {![info exists $hlt_p]} {
                                    continue
                                }
                                if {[llength [set $hlt_p]] == 1} {
                                    if {($hlt_p != "pcs_marker_fields")} {
                                        set hlt_v [set $hlt_p]
                                    } else {
                                        set hlt_v [split [set $hlt_p] {. :}]
                                    }
                                } else {
                                    if {($hlt_p != "pcs_marker_fields")} {
                                        set hlt_v [lindex [set $hlt_p] $option_index]
                                    } else {
                                        set hlt_v [split [lindex [set $hlt_p] $option_index] {. :}]
                                    }
                                }
                                pcsLaneError configure -$ixos_p $hlt_v
                            }
                            if {[pcsLaneError set $chassis $card $port]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: PCS Lane Error set failed on\
                                        $chassis $card $port. Return code was $retCode. $::ixErrorInfo."
                                return $returnList
                            }
                        } elseif {$portModeConfigured != "ethernet"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: PCS parameters can not be set on\
                                    $chassis/$card/$port . Port mode must be ethernet. Return code was $retCode.\
                                    \n$::ixErrorInfo"
                            return $returnList
                        }
                    }
                    default {}
                }
            }
        }
        if {$portReceiveMode != 0} {
            port config -receiveMode $portReceiveMode
        }
        
        if {($portReceiveMode == 0) && (![info exists mode] || \
                ([info exists mode] && ($mode == "config"))) } {
            if {[port isValidFeature $chassis $card $port $::portFeatureRxPacketGroups]} {
                set portReceiveMode $::portPacketGroup
                port config -receiveMode $portReceiveMode
            } elseif {[port isValidFeature $chassis $card $port $::portFeatureRxWidePacketGroups]} {
                puts "WARNING: RX Mode Packet Groups not supported.\nUsing Wide Packet Groups."
                set portReceiveMode $::portRxModeWidePacketGroup
                port config -receiveMode $portReceiveMode
            } else {
                puts "WARNING: RX Modes Packet Groups and Wide Packet Groups are not supported.\
                        \nUsing default Port RX Mode. Check IxOS Reference Guide for details."
            }
            
        }

        if {(($portModeConfigured == "bert" && $portModeConfiguredInitial != "bert") || \
                ($portModeConfigured == "ethernet" && $portModeConfiguredInitial == "bert")) &&\
                ([lsearch [::ixia::portSupports $chassis $card $port ethernet] 100000] != -1 || \
                [lsearch [::ixia::portSupports $chassis $card $port ethernet] 40000] != -1) && \
                ([::ixia::portSupports $chassis $card $port bert] == 1)} {
            set retCode [port write $chassis $card $port]
        } else {
            set retCode [port set $chassis $card $port]
        }
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: port set failed on\
                    $chassis $card $port.  Return code was $retCode. $::ixErrorInfo."
        }
        
        # Stats should be set here, because stat mode depends on the port rx mode
        if {!([info exists new_ixnetwork_api] && $new_ixnetwork_api)} {
            stat config -enableProtocolServerStats $::true
            stat config -enableArpStats            $::true
        }
        
        if {[string compare -nocase $statConfigMode ""] == 0 && $mode != "modify"} {
            set qos_stats      1
            set qos_flag       1
            set statConfigMode statQos
        }
        if {[string compare -nocase $statConfigMode ""] != 0} {
            if {($statConfigMode == "statQos") } {
                if {[port isValidFeature $chassis $card $port $::portFeatureQos] } {
                    catch {stat config -mode $statConfigMode}
                    set retCode [stat set $chassis $card $port]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: stat set failed on\
                                $chassis $card $port.  Return code was $retCode.\
                                \n$::ixErrorInfo"
                        return $returnList
                    }
                }
            } else {
                catch {stat config -mode $statConfigMode}
                set retCode [stat set $chassis $card $port]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: stat set failed on\
                            $chassis $card $port.  Return code was $retCode.\
                            \n$::ixErrorInfo"
                    return $returnList
                }
            }
        }
        return $returnList
    }
}



proc ::ixia::validate_configure_tx_lane {tx_lane_string port_handle port_speed} {
    keylset returnList status $::SUCCESS
    set tx_lane_string [string map {:, :NA, ,| ,NA|} $tx_lane_string]
    set tx_lane_string [split $tx_lane_string [list : , |]]
    
    foreach {ch ca po} [split $port_handle /] {}
    
    foreach {phy_lane pcs_lane skew} $tx_lane_string {
    
        switch -- $port_speed {
            ether40000lan -
            ether40Gig {
                #phy_lane and pcs_lane validation for ether40Gig ports
                if {![regexp {[0-3][aA]} $phy_lane]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to select Physical Lane $phy_lane on port $port_handle. Valid options are 0A-3A.'"
                    return $returnList
                }
                if {![regexp {[0-3]|NA} $pcs_lane]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to select PCS Lane $pcs_lane for Physical Lane $phy_lane on port $port_handle. Valid options are 0-3.'"
                    return $returnList
                }
            }
            ether100000lan -
            ether100Gig {
                #phy_lane and pcs_lane validation for ether100Gig ports
                if {![regexp {[0-9][aAbB]} $phy_lane]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to select Physical Lane $phy_lane on port $port_handle. Valid options are 0A-9A,0B-9B.'"
                    return $returnList
                }
                if {![regexp {([0-9]){1,2}|NA} $pcs_lane]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to select PCS Lane $pcs_lane for Physical Lane $phy_lane on port $port_handle. Valid options are 0-19.'"
                    return $returnList
                }
            }
        }
    
        if {[catch {txLane select   $ch $ca $po} errCode] || $errCode != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to select txLane on port ${ch}/${ca}/${po}. Error code: $errCode; ixErrorInfo is '$::ixErrorInfo'"
            return $returnList
        }
        
        if {[catch {txLane getLane          $phy_lane} errCode] || $errCode != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to get txLane for physical lane ${phy_lane}, on port ${ch}/${ca}/${po}. Error code: $errCode; ixErrorInfo is '$::ixErrorInfo'"
            return $returnList
        }
        if {$pcs_lane != "NA"} {
            txLane config -pcsLane                            $pcs_lane
        }
        if {$skew != "NA"} {
            txLane config -skew                               $skew
        }
        
        # set the lane mapping to custom
        if {$::ixia::ixtclhal_version>6.30} {
            txLane config -laneMapping 4
        }
        if {[txLane setLane          $phy_lane] != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set txLane for physical lane ${phy_lane}, on port ${ch}/${ca}/${po}. Error code: $errCode; ixErrorInfo is '$::ixErrorInfo'"
            return $returnList
        }
    }
    if {$::ixia::ixtclhal_version>6.30} {
        if {[catch {txLane writeLaneList $ch $ca $po} errCode] || $errCode != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to write txLane on port ${ch}/${ca}/${po}. Error code: $errCode; ixErrorInfo is '$::ixErrorInfo'"
            return $returnList
        }
    }
    return $returnList
}

proc ::ixia::validate_configure_bert {bert_lane_string port_handle port_speed} {
    keylset returnList status $::SUCCESS
    set bert_lane_string [string map {:, :NA, ,| ,NA| ,, ,NA,} $bert_lane_string]
    set bert_lane_string [regsub -all ",," $bert_lane_string ",NA,"]
    set bert_lane_string [split $bert_lane_string [list : , |]]
    foreach {ch ca po} [split $port_handle /] {}
    array set pattern_map {
        PRBS-31                 bertPattern2_31
        PRBS-23                 bertPattern2_23
        PRBS-20                 bertPattern2_20
        PRBS-15                 bertPattern2_15
        PRBS-11                 bertPattern2_11
        PRBS-9                   bertPattern2_9
        PRBS-7                   bertPattern2_7
        lane_detection        bertPatternLaneDetect
        alternating                bertPatternAlternatingOneZero
        all1                            bertPatternAllZero
        auto_detect             bertPatternAutoDetect
    }
    foreach {phy_lane tx_pattern tx_invert rx_pattern rx_invert enable_stats} $bert_lane_string {
        switch -- $port_speed {
            ether40000lan -
            ether40Gig {
                if {![regexp {[0-3][aA]|NA} $phy_lane]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to select Physical Lane $phy_lane on port $port_handle. Valid options are 0A-3A.'"
                    return $returnList
                }
                set bert_phy_lane_mappings {
                        0A          0
                        1A          1
                        2A          2
                        3A          3
                }
            }
            ether100000lan -
            ether100Gig {
                if {![regexp {[0-9][aAbB]|NA} $phy_lane]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to select Physical Lane $phy_lane on port $port_handle. Valid options are 0A-9A,0B-9B.'"
                    return $returnList
                }
                set bert_phy_lane_mappings {
                        0A          0
                        0B          1
                        1A          2
                        1B          3
                        2A          4
                        2B          5
                        3A          6
                        3B          7
                        4A          8
                        4B          9
                        5A          10
                        5B          11
                        6A          12
                        6B          13
                        7A          14
                        7B          15
                        8A          16
                        8B          17
                        9A          18
                        9B          19
                }
            }
        }
        
        foreach {phy_l phy_n} $bert_phy_lane_mappings {
            if {$phy_lane!= $phy_l} {
                continue
            }
            if {[catch {bert get $ch $ca $po $phy_n} errCode] || $errCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get bert lane $phy_l for port ${ch}/${ca}/${po}. Error code: $errCode'"
                return $returnList
            }
            if {$tx_pattern != "NA"} {
                if {![info exists pattern_map($tx_pattern)]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get Tx Pattern $tx_pattern for bert lane $phy_l on port ${ch}/${ca}/${po}"
                    return $returnList
                }
                bert configure -txPatternIndex                            $pattern_map($tx_pattern)
            }
            if {$tx_invert != "NA"} {
                bert configure -enableInvertTxPattern                            $tx_invert
            }
            if {$rx_pattern != "NA"} {
                if {![info exists pattern_map($rx_pattern)]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get Rx Pattern $rx_pattern for bert lane $phy_l on port ${ch}/${ca}/${po}"
                    return $returnList
                }
                bert configure -rxPatternIndex                            $pattern_map($rx_pattern)
            }
            if {$rx_invert != "NA"} {
                bert configure -enableInvertRxPattern                            $rx_invert
            }
            if {$enable_stats != "NA"} {
                bert configure -enableStats                            $enable_stats
            }
            if {[catch {bert set $ch $ca $po $phy_n} errCode] || $errCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set bert lane $phy_l for port ${ch}/${ca}/${po}. Error code: $errCode'"
                return $returnList
            }
        }
    }
    
    return $returnList
}

proc ::ixia::validate_configure_bert_error_insertion {bert_error_string port_handle port_speed} {
    keylset returnList status $::SUCCESS
    set bert_error_string [string map {:, :NA, ,| ,NA| ,, ,NA,} $bert_error_string]
    set bert_error_string [regsub -all ",," $bert_error_string ",NA,"]
    set bert_error_string [split $bert_error_string [list : , |]]
    foreach {ch ca po} [split $port_handle /] {}
    array set error_bitrate_map {
        e-2                 bert_1e2
        e-3                 bert_1e3
        e-4                 bert_1e4
        e-5                 bert_1e5
        e-6                 bert_1e6
        e-7                 bert_1e7
        e-8                 bert_1e8
        e-9                 bert_1e9
        e-10               bert_1e10
        e-11               bert_1e11
    }
    foreach {phy_lane single_error error_bit_rate error_bit_rate_unit insert} $bert_error_string {
        switch -- $port_speed {
            ether40000lan -
            ether40Gig {
                if {![regexp {[0-3][aA]|NA} $phy_lane]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to select Physical Lane $phy_lane on port $port_handle. Valid options are 0A-3A.'"
                    return $returnList
                }
                set bert_phy_lane_mappings {
                        0A          0
                        1A          1
                        2A          2
                        3A          3
                }
            }
            ether100000lan -
            ether100Gig {
                if {![regexp {[0-9][aAbB]|NA} $phy_lane]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to select Physical Lane $phy_lane on port $port_handle. Valid options are 0A-9A,0B-9B.'"
                    return $returnList
                }
                set bert_phy_lane_mappings {
                        0A          0
                        0B          1
                        1A          2
                        1B          3
                        2A          4
                        2B          5
                        3A          6
                        3B          7
                        4A          8
                        4B          9
                        5A          10
                        5B          11
                        6A          12
                        6B          13
                        7A          14
                        7B          15
                        8A          16
                        8B          17
                        9A          18
                        9B          19
                }
            }
        }
        foreach {phy_l phy_n} $bert_phy_lane_mappings {
            if {$phy_lane!= $phy_l} {
                continue
            }
            if {[catch {bertErrorGeneration get $ch $ca $po $phy_n} errCode] || $errCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get bert lane $phy_l for port ${ch}/${ca}/${po} for bert error generation. Error code: $errCode'"
                return $returnList
            }
            if {($single_error != "NA") && ($single_error == "insert")} {
                if {[catch {bertErrorGeneration insertSingleError $ch $ca $po $phy_n} errCode] || $errCode != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to insert single error for port ${ch}/${ca}/${po} in physical lane $phy_l. Error code: $errCode'"
                    return $returnList
                }
            }
            if {$error_bit_rate != "NA"} {
                bertErrorGeneration config -bitMask                            "[::ixia::bit_mask_32 $error_bit_rate 8 { }]"
            }
            if {$error_bit_rate_unit != "NA"} {
                if {![info exists error_bitrate_map($error_bit_rate_unit)]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get error bit rate unit $error_bit_rate_unit for bert lane $phy_l on port ${ch}/${ca}/${po}"
                    return $returnList
                }
                bertErrorGeneration config -errorBitRate                            $error_bitrate_map($error_bit_rate_unit)
            }
            if {$insert != "NA"} {
                bertErrorGeneration config -continuousErrorInsert $insert
            }
            if {[catch {bertErrorGeneration set $ch $ca $po $phy_n} errCode] || $errCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set bert lane $phy_l for port ${ch}/${ca}/${po}. . Error code: $errCode'"
                return $returnList
            }
        }
    }
   return $returnList
}


# Inspects arp table of each port from the portList. If there are interfaces which
# haven't resolved ARP with their gateway the procedure returns a list with the
# status of each interface
proc ::ixia::get_arp_table { portList } {
    variable pa_descr_idx
    
    set retryCount [array size pa_descr_idx]
    keylset returnList status $::SUCCESS
    foreach port $portList {
        set arp_ipv4_interfaces_failed ""
        set arp_ipv6_interfaces_failed ""
        set tmpArpList ""

        foreach {ch ca po} $port {}
               
        # Get a keyed list of form {ipv4 {intId intGw} .. {intIdN intGwN}
        # ipv6 {intId 1} .. {intIdN 1}}
        set intfInfo [::ixia::get_gateway_list $ch/$ca/$po]
        if {$intfInfo == ""} {
            continue
        }

        set ipv4InterfacesList ""
        if {![catch {keylget intfInfo ipv4}]} {
            # List with all ipv4 interfaces from keyed list
            set ipv4InterfacesList [keylkeys intfInfo ipv4]
        }

        set ipv6InterfacesList ""
        if {![catch {keylget intfInfo ipv6}]} {
            # List with all ipv6 interfaces from keyed list
            set ipv6InterfacesList [keylkeys intfInfo ipv6]
        }

        # Get all interfaces from port and get each interfaces arp table
        debug "interfaceTable select $ch $ca $po"
        if {[interfaceTable select $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to 'interfaceTable select $ch $ca $po'."
            return $returnList
        }
        debug "interfaceTable sendArpRefresh"
        if {[interfaceTable sendArpRefresh]} {
            keylset returnList status $::FAILURE
            keylset returnList log "'interfaceTable sendArpRefresh' failed."
            return $returnList
        }
        debug "interfaceTable requestDiscoveredTable"
        set start [clock seconds]
        if {[interfaceTable requestDiscoveredTable]} {
            keylset returnList status $::FAILURE
            keylset returnList log "'interfaceTable requestDiscoveredTable' \
                    failed."
            return $returnList
        }
        set stop [clock seconds]
        debug "\tinterfaceTable requestDiscoveredTable time: [mpexpr $stop - $start] (s)"
        
        # Wait a little to get the arp table from the port

        set intfCfgNo 1
        while {1} {
            if {$intfCfgNo == 1} {
                debug "interfaceTable getFirstInterface"
                if {[interfaceTable getFirstInterface]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "No interfaces on port $ch/$ca/$po."
                    return $returnList
                }
            } else {
                debug "interfaceTable getNextInterface"
                if {[interfaceTable getNextInterface]} {
                    break
                }
            }
            # We need description to determine interface handle from internal arrays
            set tmpDescription [interfaceEntry cget -description]
            
            set ipIntf [rfget_interface_handle_by_description $tmpDescription]
            
            if {[llength $ipIntf] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Interface with description \
                        '$tmpDescription' does not exist on port $ch/$ca/$po."
                return $returnList
            }
            
            # Wait a little to get the arp table from the port
            set success 0
            set wait_time 100
            for {set retry 1} {$retry <= 30} {incr retry} {
                update idletasks
                debug "interfaceTable getDiscoveredList"
                set tmpStatus [interfaceTable getDiscoveredList]
                if {$tmpStatus == $::TCL_OK} {
                    set success 1
                    break
                }
                after $wait_time
                if {$retry > 10} {
                    incr wait_time $retryCount
                }
            }
            
            if {!$success} {
                keylset returnList status $::FAILURE
                keylset returnList log "'interfaceTable getDiscoveredList' \
                        failed."
                return $returnList
            }
            
            set cfgNo 1
            while {1} {
                if {$cfgNo == 1} {
                    if {[discoveredList getFirstNeighbor]} {
                        break
                    }
                } else {
                    if {[discoveredList getNextNeighbor]} {
                        break
                    }
                }
                
                set nestedCfgNo 1
                while {1} {
                    if {$nestedCfgNo == 1} {
                        if {[discoveredNeighbor getFirstAddress]} {
                            break
                        }
                    } else {
                        if {[discoveredNeighbor getNextAddress]} {
                            break
                        }
                    }
                    # Get ip address of arp table entry
                    set ipAddrTmp [discoveredAddress cget -ipAddress]
                    if {[isIpAddressValid $ipAddrTmp]} {
                        if {[info exists arpTable($ipIntf,ipv4)]} {
                            lappend arpTable($ipIntf,ipv4) $ipAddrTmp
                        } else {
                            set arpTable($ipIntf,ipv4) $ipAddrTmp
                        }
                    } else {
                        set arpTable($ipIntf,ipv6) 1
                    }
                    incr nestedCfgNo
                }
                incr cfgNo
            }
            incr intfCfgNo
        }
        
        # Inspect interfaces to see if their gateways are found in the arp table
        foreach ipIntf [concat $ipv4InterfacesList $ipv6InterfacesList] {
            if {[lsearch $ipv4InterfacesList $ipIntf] != -1} {
                set gwAddr ""
                set gwAddr [keylget intfInfo ipv4.$ipIntf]
                if {![info exists arpTable($ipIntf,ipv4)] || \
                            [lsearch $arpTable($ipIntf,ipv4) $gwAddr] == -1} {
                    if {[lsearch $arp_ipv4_interfaces_failed $ipIntf] == -1} {
                        lappend arp_ipv4_interfaces_failed $ipIntf
                    }
                }
            }

            if {[lsearch $ipv6InterfacesList $ipIntf] != -1} {
                if {![info exists arpTable($ipIntf,ipv6)]} {
                    if {[lsearch $arp_ipv6_interfaces_failed $ipIntf] == -1} {
                        lappend arp_ipv6_interfaces_failed $ipIntf
                    }
                }
            }
        }

        if {$arp_ipv4_interfaces_failed != ""} {
            keylset returnList $ch/$ca/$po.arp_ipv4_interfaces_failed \
                    $arp_ipv4_interfaces_failed
        }
        
        if {$arp_ipv6_interfaces_failed != ""} {
            keylset returnList $ch/$ca/$po.arp_ipv6_interfaces_failed \
                    $arp_ipv6_interfaces_failed
        }
        if {[info exists arpTable]} {
            unset arpTable
        }
    }
    return $returnList
}


proc ::ixia::get_gateway_list {port} {
    variable ::ixia::pa_inth_idx
    variable ::ixia::gateway_list
    set retList ""
    
    if {[catch {keylget gateway_list $port} gw_list]} {
        foreach {ch ca po} [split $port /] {}
        foreach intfName [array names pa_inth_idx] {
            set description [rfget_interface_description_from_handle $intfName]
            set retStatus [::ixia::get_interface_parameter \
                    -port_handle $ch/$ca/$po \
                    -description $description \
                    -parameter ipv4_gateway ipv4_address ipv6_address]
            if {[keylget retStatus status] != $::SUCCESS} {
                continue
            }
            
            if {[keylget retStatus ipv4_address] != ""} {
                set gw [keylget retStatus ipv4_gateway]
                keylset retList $port.ipv4.$intfName $gw
            }
            
            if {[keylget retStatus ipv6_address] != ""} {
                keylset retList $port.ipv6.$intfName 1
            }
        }
        return $retList
    } else {
        return $gw_list
    }
}

proc ::ixia::ipv6SendRouterSolicitation { port_list } {
    variable ::ixia::pa_inth_idx
    variable ::ixia::gateway_list
    foreach port $port_list {
        scan $port "%d %d %d" ch ca po
        debug "interfaceTable select $ch $ca $po"
        if {[interfaceTable select $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to 'interfaceTable select $ch $ca $po'."
            return $returnList
        }
        set ipv6_intf_list [list]
        catch {
            set ipv6_intf_list [keylget gateway_list [join $port /].ipv6]
        }
        foreach ipv6_intf_id [keylkeys ipv6_intf_list] {
            set description [rfget_interface_description_from_handle $ipv6_intf_id]
            debug "interfaceTable sendRouterSolicitation \{$description\}"
            if {[interfaceTable sendRouterSolicitation $description]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Cannot send Router Solicitation for\
                        interface \{$description\}"
                return $returnList
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::wait_pending_operations {} {
    variable ::ixia::pending_operations
    set opIdxList [lsort -dictionary [array names pending_operations]]
    # The index of the operation is also the time in seconds when the operation
    # was started
    set currentPort 0/0/0
    foreach opIdx $opIdxList {
        debug "currentPort = $currentPort"
        foreach {startTime operation} $pending_operations($opIdx) {}
        regexp {([a-zA-Z0-9]+)_([0-9]+)_([0-9]+)_([0-9]+)_([0-9]+)} \
                $operation dummy op_name ch ca po sp
        debug "\tdummy=$dummy\n\top_name=$op_name\n\tch=$ch\n\t$ca=$ca\n\tpo=$po\n\tsp=$sp"
        set op_port $ch/$ca/$po
        # Avoid calling IxAccessProfile select for a port that is already
        # selected
        if {$currentPort != $op_port} {
            debug "\tixAccessProfile select $ch $ca $po"
            if {[ixAccessProfile select $ch $ca $po]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get operations from port $op_port"
                return $returnList
            }
            set currentPort $op_port
        }

        debug "\tixAccessProfile getOperation $operation"
        set status [ixAccessProfile getOperation $operation]
        if { $status } {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid operation $op_name for port \
                    $op_port, subport $sp. [ixAccessGetErrorString $status]"
            return $returnList
        }

        set startSession   [ixAccessOperation cget -startSession]
        set endSession     [ixAccessOperation cget -endSession]
        set rate [ixAccessOperation cget -rate ]
        set totalSessions [mpexpr $endSession - $startSession + 1]
        debug "\ttotalSessions=$totalSessions"
        # Expected disconnect time + 20 seconds for cleanup
        set expectedTime [mpexpr $totalSessions / $rate]
        if {[mpexpr $totalSessions % $rate] != 0} {
            incr expectedTime
        }
        incr expectedTime 20
        debug "\texpectedTime=$expectedTime"
        debug "\tstartTime=$startTime\n\tcurrentTime=[clock seconds]"
        set elapsedTime [mpexpr [clock seconds] - $startTime]
        debug "\telapsedTime=$elapsedTime"
        if {$elapsedTime >= $expectedTime} {
            debug "\tixAccessProfile isOperationComplete $operation"
            if {![ixAccessProfile isOperationComplete $operation]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Operation $op_name could not be completed \
                        on port $op_port, subport $sp."
                return $returnList
            }
        } else {
            set remainingTime [mpexpr $expectedTime - $elapsedTime]
            if {$remainingTime < 20} {
                puts "Expected time to finish operation $op_name on port \
                        $op_port, subport $sp: 0 (s)"
            } else {
                puts "Expected time to finish operation $op_name on port \
                        $op_port, subport $sp: [mpexpr $remainingTime - 20] (s)"
            }
            puts "Please wait until operation is complete..."
            update idletasks

            # wait for the operation to be completed
            for { set k 0 } { $k < $remainingTime } { incr k 5} {
                debug "\t$k ixAccessProfile isOperationComplete $operation"
                if {[ixAccessProfile isOperationComplete $operation]} {
                    after 1000
                    break
                }
                after 5000
            }
            if { $k >= $remainingTime} {
                keylset returnList status $::FAILURE
                keylset returnList log "Operation $op_name could not be completed\
                        on port $op_port, subport $sp."
                return $returnList
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::set_gateway_list {interface_params intfName port} {
    
    variable ::ixia::gateway_list
    
    array set intf_params $interface_params
    switch -- $intf_params(ipVersion) {
        4 {
            keylset gateway_list $port.ipv4.$intfName $intf_params(ipV4Gateway)
        }
        6 {
            keylset gateway_list $port.ipv6.$intfName 1
        }
        4_6 {
            keylset gateway_list $port.ipv4.$intfName $intf_params(ipV4Gateway)
            keylset gateway_list $port.ipv6.$intfName 1
        }
    }
}


proc ::ixia::remove_gateway_list_by_port {port_handle} {
    catch {keyldel ::ixia::gateway_list $port_handle}
}


proc ::ixia::remove_gateway_list_item {port_handle interface_handle ip_version} {
    switch $ip_version {
        4 {
            catch {keyldel ::ixia::gateway_list ${port_handle}.ipv4.${interface_handle}}
        }
        6 {
            catch {keyldel ::ixia::gateway_list ${port_handle}.ipv6.${interface_handle}}
        }
        46 -
        4_6 {
            catch {keyldel ::ixia::gateway_list ${port_handle}.ipv4.${interface_handle}}
            catch {keyldel ::ixia::gateway_list ${port_handle}.ipv6.${interface_handle}}
        }
    }
}


proc ::ixia::configuration_save {file_name} {
    keylset returnList status $::SUCCESS
    
    # Save all namespace variables to a file
    # The first line will contain the variable name (including namespace) and the variable type (array or not)
    # The second line will contain the variable value and so on
    
    if {[catch {open [file normalize $file_name] w} fd]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to save configuration. Could not open\
                file '$file_name'. $fd"
        return $returnList
    }
    
    set first_line "hltcfgfile [clock format [clock seconds] -format {%T %D}]"
    if {[info exists ::ixia::hltapi_version]} {
        append first_line " $::ixia::hltapi_version"
    }
    puts $fd $first_line
    
    foreach var [lsort [info vars ::ixia::*]] {
        if {![info exists $var]} {
            continue
        }
        
        if {[array exists $var]} {
            puts $fd "$var array"
            puts $fd [regsub -all {\r} [regsub -all {\n} [array get $var] { }] { }]
        } else {
            puts $fd "$var variable"
            puts $fd [regsub -all {\r} [regsub -all {\n} [set $var] { }] { }]
        }
    }

    if {[info exists env(IXIA_VERSION)]} {
        puts $fd "IXIA_VERSION env"
        puts $fd $env(IXIA_VERSION)
    }
    
    close $fd
    
    return $returnList
}


proc ::ixia::configuration_load {file_name} {
    keylset returnList status $::SUCCESS
    
    # Load all namespace variables from a file
    # The first line will contain the variable name (including namespace) and the variable type (array or not)
    # The second line will contain the variable value and so on
    
    if {[catch {open [file normalize $file_name] r} fd]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to Load configuration. Could not open\
                file '$file_name'. $fd"
        return $returnList
    }
    
    set file_contents [read $fd]
    close $fd
    
    set file_contents [split $file_contents \n]
    
    set first_line [lindex $file_contents 0]
    
    if {![regexp {^hltcfgfile} $first_line]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to Load configuration.\
                File '$file_name' is not a valid HLTAPI configuration file"
        return $returnList
    }
    
    set ret_code [get_time_build_line $first_line]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to Load configuration.\
                [keylget ret_code log]"
        return $returnList
    }
    
    puts "\nLoading HLT configuration from file $file_name"
    puts "\tConfiguration file created on: [keylget ret_code hlt_date]"
    puts "\tConfiguration file created with HLT build: [keylget ret_code hlt_build]\n"
    
    set file_contents [lrange $file_contents 1 end]
    
    foreach {var_line value_line} $file_contents {
        foreach {var_name var_type} $var_line {}
        switch -exact $var_type {
            "array" {
                array set $var_name $value_line
            }
            "variable" {
                set $var_name $value_line
            }
            "env" {
                set env($var_name) $value_line
            }
        }
    }
    
    return $returnList
}


proc ::ixia::session_resume {file_name} {
    variable ixnetwork_tcl_proxy
    variable ixnetworkVersion
    variable ixnetwork_tcl_server
    variable ixn_traffic_version
    variable file_debug
    variable connected_tcl_srv
    variable close_server_on_disconnect
    variable tcl_proxy_username
    variable ixnetwork_license_servers
    variable ixnetwork_license_type
    variable conToken
    array set truth [list  1 True 0 False]
    keylset returnList status $::SUCCESS
    
    
    # I want to store the current connect (if any) because i do not want to connect all
    # over again if configuration_load will want to connect to the same ixnetwork_tcl_server
    if {![catch {ixNet getList [ixNet getRoot] vport} retCode]} {
                
        set ixnetwork_tcl_server_bak $ixnetwork_tcl_server
        set ixn_traffic_version_bak  $ixn_traffic_version
    }
    
    if {$connected_tcl_srv != ""} {
        set connected_tcl_srv_bak $connected_tcl_srv
    }
    
    set ret_code [configuration_load $file_name]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    if {![info exists ixn_traffic_version]} {
        set ixn_major [lindex [split $::ixia::ixnetworkVersion .] 0]
        regexp {(^\d+)} [lindex [split $::ixia::ixnetworkVersion .] 1] ixn_minor
        set ixn_traffic_version $ixn_major.$ixn_minor
    }
    
    # Connect to tcl server if the configuration file indicates that we should be
    #    and if we're not already connected to that tcl server
    if {$connected_tcl_srv != "" && (![info exists connected_tcl_srv_bak] ||\
            $connected_tcl_srv_bak != $connected_tcl_srv)} {
        
        if {[connect_to_tcl_server $connected_tcl_srv]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not connect to tcl_server \
                    $connected_tcl_srv. ($::ixErrorInfo)"
            return $returnList
        }
    }
        
    
    if {[info exists ixnetwork_tcl_server]                      &&\
            (![info exists ixnetwork_tcl_server_bak]            ||\
             $ixnetwork_tcl_server != $ixnetwork_tcl_server_bak ||\
             ![info exists ixn_traffic_version_bak]             ||\
             $ixn_traffic_version != $ixn_traffic_version_bak)} {
                 
        catch {ixNet disconnect}
        
        set remoteIp   [lindex [split $ixnetwork_tcl_server ":"] 0]
        set remotePort [lindex [split $ixnetwork_tcl_server ":"] 1]
        set remoteService $remoteIp
        if {$remotePort != ""} {
            append remoteService " -port $remotePort"
        } else {
            set remotePort 8009
        }
        
       
        if {$ixn_traffic_version < 5.40} {
            set _cmd [format "%s" "ixNet connect $remoteService"]
            debug $_cmd
        } else {
            if {[info exists close_server_on_disconnect]} {
                # Translate close_server_on_disconnect from 0/1 to False/True (format required by ixNet api)
                append remoteService " -closeServerOnDisconnect $truth($close_server_on_disconnect)"
            }
            if {[info exists tcl_proxy_username]} {
                append remoteService " -serverusername $tcl_proxy_username"
            }

            set _cmd [format "%s" "ixNet connect $remoteService -version $ixn_traffic_version"]
            debug $_cmd
        }
        
        if {[info exists _connect_result]} {
            unset _connect_result
        }
        puts "Connecting to IxNetwork Tcl Server $remoteService ..."
        catch {eval $_cmd} _connect_result
        if {!([info exists _connect_result] && \
                $_connect_result == "::ixNet::OK")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not connect to IxNetwork TCL Server: \
                        $remoteService"
            return $returnList
        } else {
            set _conToken [ixNet connectiontoken]
            set conToken ""
            if {$_conToken != ""} {
                set res [regsub -all {\-} $_conToken "" conToken]
                lappend conToken usingTclProxy 1 serverversion [ixNet getA [ixNet getRoot]/globals -buildNumber]
            } else {
                lappend conToken usingTclProxy 0 serverversion [ixNet getA [ixNet getRoot]/globals -buildNumber] \
                                port $remotePort
            }
        }
        after 500
    }
    catch {
        if {[regexp {setAttribute strict}  [ixNet setSessionParameters]]} {
            puts "WARNING: IxNetwork sessionParameter setAttribute is set to strict mode! This can cause unexpected results while running HLT tests. Setting it back to default (looseNoWarning)"
            ixNet setSessionParameters setAttribute looseNoWarning
        }
    }
    ::ixia::set_license_servers
    return $returnList
}


proc ::ixia::get_time_build_line {first_line} {
    
    # hltcfgfile 12:43:32 12/17/10 4.10.48.23
    
    keylset returnList status $::SUCCESS
    
    if {[llength $first_line] == 3} {
        # hlt build number is missing
        set date [lrange $first_line 1 end]
        keylset returnList hlt_date $date
        keylset returnList hlt_build "Unknown"
    } elseif {[llength $first_line] == 4} {
        # hlt build number is present
        set hlt_build [lindex $first_line end]
        set first_line [lreplace $first_line end end]
        set date [lrange $first_line 1 end]
        if {![regexp {\d+\.\d+\.\d+\.\d+} $hlt_build]} {
            set hlt_build "Development build"
        }
        keylset returnList hlt_build $hlt_build
        keylset returnList hlt_date  $date
        
    } else {
        # invalid first line
        keylset returnList status $::FAILURE
        keylset returnList log "Not a valid HLT configuration file."
    }
    
    return $returnList
}


proc ::ixia::session_detect_and_restore {ixnetwork_tcl_server_input file_ixncfg_exists file_ixncfg device port_list} {
    
    variable ixnetworkVersion
    variable ixnetwork_tcl_server
    variable ixnetwork_tcl_proxy
    variable ixn_traffic_version
    variable file_debug
    variable connected_tcl_srv
    variable tcl_proxy_username
    variable ixnetwork_license_servers
    variable ixnetwork_license_type
    variable close_server_on_disconnect
    variable conToken
    array set truth [list  1 True 0 False]
    keylset returnList status $::SUCCESS
    
    # I want to store the current connect (if any) because i do not want to connect all
    # over again if configuration_load will want to connect to the same ixnetwork_tcl_server
    if {![catch {ixNet getList [ixNet getRoot] vport} retCode]} {
                
        set ixnetwork_tcl_server_bak $ixnetwork_tcl_server
        set ixn_traffic_version_bak  $ixn_traffic_version
    }
    
    if {![info exists ixn_traffic_version]} {
        set ixn_major [lindex [split $::ixia::ixnetworkVersion .] 0]
        regexp {(^\d+)} [lindex [split $::ixia::ixnetworkVersion .] 1] ixn_minor
        set ixn_traffic_version $ixn_major.$ixn_minor
    }
    
    # First connect to the ixnetwork tcl server if it's necessary
    if { \
        ![info exists ixnetwork_tcl_server_bak]                  || \
        $ixnetwork_tcl_server_input != $ixnetwork_tcl_server_bak || \
        ![info exists ixn_traffic_version_bak]                   || \
        $ixn_traffic_version != $ixn_traffic_version_bak \
    } {    
        catch {ixNet disconnect}
        
        set remoteIp   [lindex [split $ixnetwork_tcl_server_input ":"] 0]
        set remotePort [lindex [split $ixnetwork_tcl_server_input ":"] 1]
        set remoteService $remoteIp
        if {$remotePort != ""} {
            append remoteService " -port $remotePort"
        } else {
            set remotePort 8009
        }
        if {$ixn_traffic_version < 5.40} {
            set _cmd [format "%s" "ixNet connect $remoteService"]
            debug $_cmd
        } else {
            if {[info exists close_server_on_disconnect]} {
                # Translate close_server_on_disconnect from 0/1 to False/True (format required by ixNet api)
                append remoteService " -closeServerOnDisconnect $truth($close_server_on_disconnect)"
            }
            if {[info exists tcl_proxy_username]} {
                append remoteService " -serverusername $tcl_proxy_username"
            }

            set _cmd [format "%s" "ixNet connect $remoteService -version $ixn_traffic_version"]
            debug $_cmd
        }
        
        if {[info exists _connect_result]} {
            unset _connect_result
        }
        
        puts "Connecting to IxNetwork Tcl Server $remoteService ..."
        
        catch {eval $_cmd} _connect_result
        if {!([info exists _connect_result] && \
                $_connect_result == "::ixNet::OK")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not connect to IxNetwork TCL Server: \
                    $remoteService"
            return $returnList
        } else {
            set _conToken [ixNet connectiontoken]
            set conToken ""
            if {$_conToken != ""} {
                set res [regsub -all {\-} $_conToken "" conToken]
                lappend conToken usingTclProxy 1 serverversion [ixNet getA [ixNet getRoot]/globals -buildNumber]
            } else {
                lappend conToken usingTclProxy 0 serverversion [ixNet getA [ixNet getRoot]/globals -buildNumber] \
                                port $remotePort
            }
        }
        
        set ::ixia::ixnetwork_tcl_server $remoteIp
        
        after 500
    }
    catch {
        if {[regexp {setAttribute strict}  [ixNet setSessionParameters]]} {
            puts "WARNING: IxNetwork sessionParameter setAttribute is set to strict mode! This can cause unexpected results while running HLT tests. Setting it back to default (looseNoWarning)"
            ixNet setSessionParameters setAttribute looseNoWarning
        }
    }
    # Load ixncfg if required
    ::ixia::set_license_servers
    if {$file_ixncfg_exists} {
        if {[catch {ixNet exec loadConfig [ixNet readFrom $file_ixncfg]} err]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to load IxNetwork configuration from\
                    '$file_ixncfg'. $err"
            return $returnList
        }
    }
    
    # If device and port_list exist: remove all available hardware
    # the vports will be connected to the hardware specified with device and port_list
    set port_handle_pool "_na"
    if {$device != "_na" && $port_list != "_na"} {
        
        if {[llength $device] > 1} {
            if {[llength $device] != [llength $port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The number of devices\
                        and the number of port_lists are not equal."
                return $returnList
            }
        } else {
            set port_list [list $port_list]
        }
        
        # port_handle_pool will be returned to ::ixia::connect.
        # The vport_list variable will be initialized with the value of port_handle_pool, just as if it was passed as parameter.
        # ::ixia::connect will do the mapping of hardware to virtual ports
        # port_handle_pool will also be used to give a port handle to the virtual ports that are
        #   found on ixnetwork_tcl_server
        
        set port_handle_pool ""
        set chassis_id    [get_valid_chassis_id 0]
        foreach device_ip $device inner_pl $port_list {
            set port_handle_inner_pool ""
            
            foreach single_port $inner_pl {
                lappend port_handle_inner_pool "${chassis_id}/${single_port}"
            }
            
            lappend port_handle_pool $port_handle_inner_pool
            
            incr chassis_id
        }
        
        # Remove all available hardware from ixnetwork
        # Unassign all virtual ports
        puts "\nRemoving all available hardware from IxNetwork Tcl Server"
        set err_found 0
        set err_msg "Failed to remove available hardware found on ixnetwork tcl server"
        if {![catch {ixNetworkGetList [ixNet getRoot]availableHardware chassis} ch_obj_list]} {
            foreach ch_obj $ch_obj_list {
                if {[catch {ixNet remove $ch_obj} err]} {
                    set err_found 1
                    break
                }
            }
            if {[catch {ixNet commit} err]} {
                set err_found 1
            }
        } else {
            set err $ch_obj_list
        }
        
        if {$err_found} {
            keylset returnList status $::FAILURE
            keylset returnList log "${err_msg}: $err"
            return $returnList
        }
        
        puts "\nDisconnecting existing virtual ports"
        
        if {![catch {ixNetworkGetList [ixNet getRoot] vport} vport_obj_list]} {
            foreach vport_obj $vport_obj_list {
                set result [ixNetworkNodeSetAttr $vport_obj \
                        [list -connectedTo [ixNet getNull]]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to disconnect\
                            vport $vport_obj: [keylget result log]"
                    return $returnList
                }
            }
            
            if {[catch {ixNet commit} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to disconnect vports: $err"
                return $returnList
            }
        }
    }
    
    if {[llength $device] == 1} {
        set port_handle_pool [join $port_handle_pool]
    }
    keylset returnList port_handle_pool $port_handle_pool
    
    # Connect to tcl server if we're not connected
    # First try to connect to the tcl server on ixnetwork_tcl_server
    #       if that is not possible, try to connect to the chassis IPs
    #       from availableHardware on ixnetwork tcl server
    set remoteIp [lindex [split $ixnetwork_tcl_server_input ":"] 0]
    if {$connected_tcl_srv == "" && $::tcl_platform(platform) != "windows"} {
        set ret_code [detect_and_connect_tcl_server $remoteIp]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not connect to tcl_server \
                    $remoteIp. [keylget ret_code log]"
            return $returnList
        }
    }
        
    #   proc name                                message            params
    set detect_list {
        detect_session_variables                 session            _na
        detect_port_variables                    port               port_handle_pool
        detect_interface_variables               interface          _na
        detect_protocol_variables                protocols          _na
        detect_dhcp_variables                    "dhcp client"      _na
    }
    
    foreach {proc_call message params} $detect_list {
        if {$message == "interface" && $::ixia::session_resume_keys == 0} {
            # BUG687027: HLT session_resume_keys 0 should not get interface configuration
            # getting the properties fo each interface takes to long.
            continue
        }
        if {[info commands $proc_call] == [list]} {
            puts "Warning: $message related data could not be loaded because\
                    procedure $proc_call is not implemented."
            continue
        }
        
        set cmd "$proc_call"
        if {$params != "_na"} {
            lappend cmd [set $params]
        }
        
        set ret_code [eval $cmd]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to detect $message related data.\
                    [keylget ret_code log]"
            return $returnList
        }
    }
    
    return $returnList
}


proc ::ixia::detect_and_connect_tcl_server {ixn_tcl_server} {
    
    keylset returnList status $::SUCCESS
    
    if {[connect_to_tcl_server $ixn_tcl_server]} {
        set chassis_list [get_avail_hw_chassis_ip $ixn_tcl_server]
    } else {
        set ::ixia::connected_tcl_srv $ixn_tcl_server
        return $returnList
    }
    
    set connected 0
    foreach ch_ip $chassis_list {
        if {![connect_to_tcl_server $ch_ip]} {
            set ::ixia::connected_tcl_srv $ixn_tcl_server
            set connected 1
            break
        }
    }
    
    if {!$connected} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not find a tcl server. Machines on which connect\
                was attempted are: $ixn_tcl_server $chassis_list"
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::get_avail_hw_chassis_ip {ixn_tcl_server} {
    # Get the list of chassis ips to which ixnetwork tcl server is connected
    variable connect_timeout
    
    if {[catch {ixNetworkGetList [ixNet getRoot]availableHardware chassis} ch_obj_list]} {
        return ""
    }
    
    set start_time [clock seconds]
    set all_connected 0
    
    while {[expr [clock seconds] - $start_time] < $connect_timeout && !$all_connected} {
        set all_connected 1
        set ch_ip_list ""
        foreach ch_obj $ch_obj_list {
            if {[ixNet getA $ch_obj -state] != "ready"} {
                set all_connected 0
            } else {
                lappend ch_ip_list [ixNetworkGetAttr $ch_obj -hostname]
            }
        }
    }
    
    return [lsort -unique $ch_ip_list]
}


proc ::ixia::detect_session_variables {} {
    
    #::ixia::ixNetworkChassisConnected
    #::ixia::chassis_list
    #::ixia::ixnetwork_chassis_list
    #::ixia::session_owner_tclhal
    
    keylset returnList status $::SUCCESS
    
    set remoteIp [lindex [split $::ixia::ixnetwork_tcl_server ":"] 0]
    set chassis_ip_list [get_avail_hw_chassis_ip $remoteIp]
    if {[llength $chassis_ip_list] > 0} {
        set ::ixia::ixNetworkChassisConnected $::SUCCESS
        set ::ixia::ixnetwork_chassis_list ""
        set ::ixia::chassis_list           ""
        set id [get_valid_chassis_id]
        foreach chassis_ip $chassis_ip_list {
            lappend ::ixia::ixnetwork_chassis_list [list $id $chassis_ip]
            lappend ::ixia::chassis_list           [list $chassis_ip $id]
            incr id
        }
    } else {
        set ::ixia::ixNetworkChassisConnected $::FAILURE
    }
    
    # Not setting ::ixia::session_owner_tclhal because there's no way to get that
    #       from ixnetwork
    
    return $returnList
}


proc ::ixia::detect_port_variables {port_handle_pool} {
    #::ixia::ixnetwork_port_handles_array array
    #0/2/4 ::ixNet::OBJ-/vport:2 0/2/3 ::ixNet::OBJ-/vport:1
    #::ixia::ixnetwork_rp2vp_handles_array array
    #0/2/4 0/2/4 0/2/3 0/2/3

    set array_clear_list {
        ixnetwork_port_handles_array
        ixnetwork_port_handles_array_vport2rp
        ixnetwork_rp2vp_handles_array
    }
    foreach array_name $array_clear_list {
        catch {array unset ::ixia::$array_name}
    }
    
    keylset returnList status $::SUCCESS
    
    set remoteIp [lindex [split $::ixia::ixnetwork_tcl_server ":"] 0]
    set port_handle_pool_liniar "_na"
    
    if {$port_handle_pool != "_na"} {
        set port_handle_pool_liniar [join $port_handle_pool]
        
        set vport_objref_list [ixNet getList [ixNet getRoot] vport]
        if {[llength $vport_objref_list] < [llength $port_handle_pool_liniar]} {
            puts "\nWARNING: The number of virtual ports found on session resume is\
                    insufficient for the hardware specified with -device and -port_list.\
                    New virtual ports will be created in order to accomodate the hardware\
                    specified with -device and -port_list"
            
            set commit_needed 0
            for {set i 0} {$i < [mpexpr [llength $port_handle_pool_liniar] - [llength $vport_objref_list]]} {incr i} {
                set ret_code [ixNetworkNodeAdd [ixNet getRoot] vport]
                if {[keylget ret_code status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to create the virtual ports needed to accomodate the\
                            required hardware while doing session resume: [keylget ret_code log]"
                    return $returnList
                }
                
                set commit_needed 1
            }
            
            if {$commit_needed} {
                if {[catch {ixNet commit} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to create the virtual ports needed to accomodate the\
                            required hardware while doing session resume: $err"
                    return $returnList
                }
            }
        }
        
        if {[llength $vport_objref_list] > [llength $port_handle_pool_liniar]} {
            puts "\nWARNING: The number of virtual ports found on session resume is\
                    larger than the number of real ports specified with -device and -port_list.\
                    Some virtual ports will remain unassigned"
            
            for {set i 0} {$i < [mpexpr [llength $vport_objref_list] - [llength $port_handle_pool_liniar]]} {incr i} {
                lappend port_handle_pool_liniar "0/0/[expr $i + 1]"
            }
        }
    }
        
    set vport_objref_list [ixNet getList [ixNet getRoot] vport]
    
    set list_item_idx -1
    set vport_idx     1
    set check_port_handles_array 0
    foreach vport_objref $vport_objref_list {
        incr list_item_idx
        
        set retries 20
        while {([ixNet getA $vport_objref -isPullOnly] == "true" || [ixNet getA $vport_objref -isAvailable] == "false") && ($retries > 0)} {
            incr retries -1
            continue
        }
        
        set vport_status [ixNetworkVportIsReady $vport_objref]
        if {[keylget vport_status status] != $::SUCCESS} {
            return $vport_status
        }
        
        if {$port_handle_pool_liniar == "_na"} {
            set connected_hw [ixNet getA $vport_objref -connectedTo]
            if {![regexp {^(::ixNet::OBJ-/availableHardware/chassis:")(.+)("/card:)(\d+)(/port:)(\d+)$}\
                    $connected_hw {} {} ch_ip {} ca {} po]} {
                
                # Port is not connected. Give it a vport handle and store it in ixnetwork_port_handles_array
                set vport_handle 0/0/$vport_idx
                incr vport_idx
                set ::ixia::ixnetwork_port_handles_array($vport_handle) $vport_objref
                set ::ixia::ixnetwork_port_handles_array_vport2rp($vport_objref) $vport_handle
                incr check_port_handles_array
                continue
            }
            
            set ixn_index  [lsearch -regexp $::ixia::ixnetwork_chassis_list $ch_ip]
            if {$ixn_index == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to create internal mapping array real ports (ch/ca/po)\
                        to virtual ports (vch/vca/vpo). Could not find chassis with ip $ch_ip in\
                        internal list ixnetwork_chassis_list."
                return $returnList
            }
            
            set ch_idx [lindex [lindex $::ixia::ixnetwork_chassis_list $ixn_index] 0]
            # Vport_handle will be the same as real port_handle. I cannot detect if the user connected 
            # a virtual port to a real port and so on (shuffled real port to virtual ports will be a
            # known limitation)

            set vport_handle $ch_idx/$ca/$po
            set ::ixia::ixnetwork_rp2vp_handles_array($ch_idx/$ca/$po) $vport_handle
            
        } else {
            set vport_handle [lindex $port_handle_pool_liniar $list_item_idx]
            if {$vport_handle == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error in session resume. Insufficient port_handles\
                        in port_handle_pool_liniar. Attempted to get port_handle with index\
                        $list_item_idx from '$port_handle_pool_liniar' for virtual port\
                        $vport_objref"
                return $returnList
            }
        }
        
        set ::ixia::ixnetwork_port_handles_array($vport_handle) $vport_objref
        set ::ixia::ixnetwork_port_handles_array_vport2rp($vport_objref) $vport_handle

        incr check_port_handles_array
    }
    
    if {$check_port_handles_array != [llength $vport_objref_list]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error in session resume. ixnetwork_port_handles_array\
                does not contain all the ports in $vport_objref_list"
        return $returnList
    }
    
    return $returnList
}

namespace eval ::ixia::session_resume::filter_build {
    # this is a list of required attributes used by session_resume::sr_initialize
    # all of the objects here are assumed to be used in the ::ixia::$func_name where
    # func_name is the analogous function
    # if there are any attributes that are required and not present here, sr_get_attribute
    # will throw an error
    proc detect_interface_variables {} {
        return {
            "/vport/interface"                {-type}
            "/vport/interface/ipv4"           {-ip -maskWidth -gateway}
            "/vport/interface/ipv6"           {-ip -prefixLength -gateway}
            "/vport/interface/vlan"           {-vlanEnable -vlanId -vlanPriority}
            "/vport/interface/ethernet"       {-macAddress}
            "/vport/interface/atm"            {-encapsulation -vpi -vci}
            "/vport/interface/gre"            {-dest}
            "/vport/interface/unconnected"    {-connectedVia}
        }
    }
}

proc ::ixia::detect_interface_variables {} {
    #::ixia::pa_descr_idx
    #::ixia::pa_inth_idx
    #::ixia::pa_ip_idx
    #::ixia::pa_mac_idx
    variable cmdProtIntfParamsList

    ## These are the positions of the parameters that are being kept in the
    ## protocol_interfaces array indices
    ## NOTE: If a new parameter needs to be added it should be added here also.
    variable cmdProtIntfParamsPositions
    
    variable ixnetwork_port_handles_array_vport2rp
    
    keylset returnList status $::SUCCESS
    
    catch {array unset ::ixia::pa_descr_idx}
    catch {array unset ::ixia::pa_inth_idx}
    catch {array unset ::ixia::pa_ip_idx}
    catch {array unset ::ixia::pa_mac_idx}
    
    array set translate_array {
        default             connected
        gre                 gre
        routed              routed
        vcMuxIpv4           VccMuxIPV4Routed           
        vcMuxIpv6           VccMuxIPV6Routed           
        vcMuxBridgeFcs      VccMuxBridgedEthernetFCS   
        vcMuxBridgeNoFcs    VccMuxBridgedEthernetNoFCS 
        llcClip             LLCRoutedCLIP              
        llcBridgeFcs        LLCBridgedEthernetFCS      
        llcBridgeNoFcs      LLCBridgedEthernetNoFCS    
    }
    
    set ipv4_param_map {
        ipv4_address            ip              value
        ipv4_mask               maskWidth       value
        ipv4_gateway            gateway         value
    }
    
    set ipv6_param_map {
        ipv6_address            ip              value
        ipv6_mask               prefixLength    value
        ipv6_gateway            gateway         value
    }
    
    set vlan_param_map {
        vlan_id            vlanId               vlan_value
        vlan_priority      vlanPriority         vlan_value
    }
    
    set mac_param_map {
        mac_address        macAddress           mac
    }
    
    set atm_param_map {
        atm_encap          encapsulation        translate
        atm_vpi            vpi                  value
        atm_vci            vci                  value
    }
    
    set gre_param_map {
        ipv4_dst_address   dest                 value
    }

    # ensure initialized, may be called multiple times
    session_resume::sr_initialize
    namespace import -force ::ixia::session_resume::sr_get_ixnhandle
    namespace import -force ::ixia::session_resume::sr_get_node_by_ixnhandle
    namespace import -force ::ixia::session_resume::sr_get_attribute
    namespace import -force ::ixia::session_resume::sr_get_child_list
    
    foreach vport_objref [array names ixnetwork_port_handles_array_vport2rp] vport_handle [array names ::ixia::ixnetwork_port_handles_array] {
        set vport_elem [sr_get_node_by_ixnhandle $vport_objref]
        set t0 [clock clicks -milliseconds]
        foreach intf_elem [sr_get_child_list $vport_elem interface] {
            foreach var $cmdProtIntfParamsList {
                catch {unset $var}
            }

            set port_handle $vport_handle
            set type $translate_array([sr_get_attribute $intf_elem -type])
            
            set ipv4_elem [sr_get_child_list $intf_elem ipv4]
            if {$ipv4_elem != ""} {
                foreach {hltp ixnp ptype} $ipv4_param_map {
                    if {$hltp == "ipv4_gateway" && $type != "connected"} {
                        # The gateway property from network is set only for connected interfaces
                        # For unconnected we'll set the connectedVia handle as gateway
                        continue
                    }
                    switch -- $ptype {
                        value {
                            set $hltp [sr_get_attribute $ipv4_elem -$ixnp]
                        }
                        default {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error in\
                                    detect_interface_variables. Object [sr_get_ixnhandle $ipv4_elem];\
                                    parameter $hltp; unhandled parameter type $ptype"
                            return $returnList
                        }
                    }
                }
            }
            
            set ipv6_elem [sr_get_child_list $intf_elem ipv6]
            if {$ipv6_elem != ""} {
                foreach {hltp ixnp ptype} $ipv6_param_map {
                    if {$hltp == "ipv6_gateway" && $type != "connected"} {
                        # The gateway property from network is set only for connected interfaces
                        # For unconnected we'll set the connectedVia handle as gateway
                        continue
                    }
                    switch -- $ptype {
                        value {
                            set $hltp [sr_get_attribute $ipv6_elem -$ixnp]
                        }
                        default {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error in\
                                    detect_interface_variables. Object [sr_get_ixnhandle $ipv6_elem];\
                                    parameter $hltp; unhandled parameter type $ptype"
                            return $returnList
                        }
                    }
                }
            }
            
            set vlan_elem [sr_get_child_list $intf_elem vlan]
            if {$type == "connected" && $vlan_elem != ""} {
                if {[sr_get_attribute $vlan_elem -vlanEnable] == "true"} {
                    foreach {hltp ixnp ptype} $vlan_param_map {
                        switch -- $ptype {
                            vlan_value {
                                set $hltp [lindex [split [sr_get_attribute $vlan_elem -$ixnp] ,] 0]
                            }
                            default {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Internal error in\
                                        detect_interface_variables. Object [sr_get_ixnhandle $vlan_elem];\
                                        parameter $hltp; unhandled parameter type $ptype"
                                return $returnList
                            }
                        }
                    }
                }
            }
            
            set ethernet_elem [sr_get_child_list $intf_elem ethernet]
            if {$ethernet_elem != ""} {
                foreach {hltp ixnp ptype} $mac_param_map {
                    switch -- $ptype {
                        mac {
                            set $hltp [sr_get_attribute $ethernet_elem -$ixnp]
                            set $hltp [convertToIxiaMac [set $hltp]]
                        }
                        default {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error in\
                                    detect_interface_variables. Object [sr_get_ixnhandle $ethernet_elem];\
                                    parameter $hltp; unhandled parameter type $ptype"
                            return $returnList
                        }
                    }
                }
            }
            
            if {[sr_get_attribute $vport_elem -type] == "atm"} {
                set atm_elem [sr_get_child_list $intf_elem atm]
                if {$atm_elem != ""} {
                    foreach {hltp ixnp ptype} $atm_param_map {
                        switch -- $ptype {
                            translate {
                                if {[catch {set $hltp $translate_array([sr_get_attribute $atm_elem -$ixnp])} err]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Internal error in\
                                            detect_interface_variables. Object [sr_get_ixnhandle $atm_elem];\
                                            parameter $hltp; missing translate entry for\
                                            parameter value. $err"
                                    return $returnList
                                }
                            }
                            value {
                                set $hltp [sr_get_attribute $atm_elem -$ixnp]
                            }
                            default {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Internal error in\
                                        detect_interface_variables. Object [sr_get_ixnhandle $atm_elem];\
                                        parameter $hltp; unhandled parameter type $ptype"
                                return $returnList
                            }
                        }
                    }
                }
            }
            
            if {$type == "gre"} {
                set gre_elem [sr_get_child_list $intf_elem gre]
                if {$gre_elem != ""} {
                    foreach {hltp ixnp ptype} $gre_param_map {
                        switch -- $ptype {
                            value {
                                set $hltp [sr_get_attribute $gre_elem -$ixnp]
                            }
                            default {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Internal error in\
                                        detect_interface_variables. Object [sr_get_ixnhandle $gre_elem];\
                                        parameter $hltp; unhandled parameter type $ptype"
                                return $returnList
                            }
                        }
                    }
                }
            }
            
            if {$type == "routed"} {
                set unconnected_elem [sr_get_child_list $intf_elem unconnected]
                if {$unconnected_elem != ""} {
                    set connectedViaTmp [sr_get_attribute $unconnected_elem -connectedVia]
                    if {$connectedViaTmp != [ixNet getNull]} {
                        set ipv4_gateway $connectedViaTmp
                    }
                }
            }
            
            if {[info exists mac_address]} {
                set int_mac 0x[join $mac_address ""]
                if {[mpexpr $::ixia::protocol_interfaces_mac_address < $int_mac]} {
                    set ::ixia::protocol_interfaces_mac_address $int_mac
                }
            }
            
            set cs_intf_details_new ""
            foreach {dataInput} $cmdProtIntfParamsList {
                if {[info exists $dataInput]} {
                    # Vlans use commas to define stackedVlan. Replace them with colon
                    lappend cs_intf_details_new [regsub -all , [set $dataInput] :]
                } else  {
                    lappend cs_intf_details_new (.*)
                }
            }
            
            set cs_intf_details_new [join $cs_intf_details_new ,]
            set ret_code [rfadd_interface_by_details $cs_intf_details_new]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed in detect_interface_variables.\
                        [keylget ret_code log]"
                return $returnList
            }
        }
    }
    
    return $returnList
}

namespace eval ::ixia::session_resume::filter_build {
    # this is a list of required attributes used by session_resume::sr_initialize
    # all of the objects here are assumed to be used in the ::ixia::$func_name where
    # func_name is the analogous function
    # if there are any attributes that are required and not present here, sr_get_attribute
    # will throw an error
    proc detect_protocol_variables {} {
        set ret {
            "/vport/protocols/mld/host/groupRange"              {-incrementStep -groupCount -groupIpFrom}
            "/vport/protocols/mld/host/groupRange/sourceRange"  {-ipFrom -count}
            "/vport/protocols/pimsm/router/interface/joinPrune" {-groupAddress -groupCount}
            "/vport/protocols/pimsm/router/interface/source"    {-sourceAddress -sourceCount}
            "/vport/protocols/igmp/host"   {-interfaces}
            "/vport/interface/ipv4"        {-ip}
            "/vport/protocolStack/ethernet/dhcpEndpoint/range"  {}
            "/vport/protocolStack/ethernet/pppoxEndpoint/range" {}
            "/vport/protocols/igmp/host/group"        {-groupFrom -incrementStep -groupCount}
            "/vport/protocols/igmp/host/group/source" {-sourceRangeStart -sourceRangeCount}

            "/globals/protocolStack/ancpGlobals/ancpDslProfile/ancpDslTlv"             {-code -value}
            "/globals/protocolStack/ancpGlobals/ancpDslResyncProfile/ancpDslResyncTlv" {-code -lastValue -mode -stepValue -firstValue}

            "/vport" {-type}
        }

        set prot_stack_prefixes {
            "/vport/protocolStack/atm"
            "/vport/protocolStack/ethernet"
        }
        set prot_stack_suffixes {
            "ipEndpoint" {}
            "pppoxEndpoint" {}
            "dhcpEndpoint" {}
            "pppox/dhcpoPppClientEndpoint" {}
            "pppox/dhcpoPppServerEndpoint" {}
            "ip/l2tp/dhcpoLacEndpoint" {}
            "ip/l2tp/dhcpoLnsEndpoint" {}
            "ip/l2tpEndpoint" {}
        }
        set prot_stack_suffixes2 {
            "ancp" {}
            "range" {}
            "range/ancpRange" {}
            "range/ancpRange/dslProfileAllocationTable"       {-dslProfile -percentage}
            "range/ancpRange/dslResyncProfileAllocationTable" {-dslProfile -percentage}
        }

        foreach prefix $prot_stack_prefixes {
            foreach {suffix attr_list} $prot_stack_suffixes {
                set item "$prefix/$suffix"
                lappend ret $item $attr_list
                foreach {suffix2 attr_list2} $prot_stack_suffixes2 {
                    lappend ret "$item/$suffix2" $attr_list2
                }
            }
        }

        return $ret
    }
}

proc ::ixia::detect_protocol_variables {} {
    keylset returnList status $::SUCCESS
    
    variable ancp_handles_array
    variable ancp_profile_handles_array
    variable handles_state_evidence_array
    variable handles_state_evidence_resynch_array
    variable multicast_group_ip_to_handle
    variable multicast_source_ip_to_handle
    variable igmp_host_ip_handles_array
    
    set tlv_enable_list [list                                                            \
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
    
    ixia::util::import_namespace_procs "::ixia::session_resume" {
        sr_initialize

        sr_equal_obj
        sr_get_ixnhandle
        sr_get_node_by_ixnhandle
        sr_get_attribute
        sr_get_child_list
        sr_get_root
        sr_is_valid_obj
    }
    # ensure initialized
    sr_initialize

    # note: this may be a source of bugs, detect_protocol_variables is called for each session_info call because 
    # some keys depend on internal HLT data, and it must be updated each time in order to get the good keys (and no errors)
    set array_clear_list {
        multicast_group_array
        multicast_source_array
        multicast_group_ip_to_handle
        multicast_source_ip_to_handle
        ancp_profile_handles_array
        handles_state_evidence_array
        handles_state_evidence_resynch_array
    }
    foreach array_name $array_clear_list {
        catch {array unset ::ixia::$array_name}
    }
    
    # Build IGMP handles, if the config contains IGMP
    set vport_list [sr_get_child_list [sr_get_root] vport]
    foreach vport_objref $vport_list {
        set vport_proto [sr_get_child_list $vport_objref protocols]
        set proto_pim [sr_get_child_list $vport_proto pimsm]
        set proto_mld [sr_get_child_list $vport_proto mld]
        set proto_igmp [sr_get_child_list $vport_proto igmp]

        set group_create_list [list]
        set source_create_list [list]
        
        foreach pim_router [sr_get_child_list $proto_pim router] {
            foreach pim_interface [sr_get_child_list $pim_router interface] {
                foreach pim_join_prune [sr_get_child_list $pim_interface joinPrune] {
                    set gr_from_addr [sr_get_attribute $pim_join_prune -groupAddress]
                    set gr_count [sr_get_attribute $pim_join_prune -groupCount]
                    if {[::ixia::isValidIPv4Address $gr_from_addr]} {
                        set gr_step 0.0.0.1
                    } else {
                        set gr_step 0:0:0:0:0:0:0:1
                    }
                    lappend group_create_list $gr_count $gr_from_addr $gr_step
                }
                
                foreach pim_source [sr_get_child_list $pim_interface source] {
                    set ip_addr [sr_get_attribute $pim_source -sourceAddress]
                    set count [sr_get_attribute $pim_source -sourceCount]
                    if {[::ixia::isValidIPv4Address $ip_addr]} {
                        set step 0.0.0.1
                    } else {
                        set step 0:0:0:0:0:0:0:1
                    }
                    lappend source_create_list $count $ip_addr $step
                }
            }
        }
        
        foreach mld_host [sr_get_child_list $proto_mld host] {
            foreach mld_group_range [sr_get_child_list $mld_host groupRange] {
                set gr_from_addr [sr_get_attribute $mld_group_range -groupIpFrom]
                set gr_step [::ixia::num_to_ip_addr [sr_get_attribute $mld_group_range -incrementStep] 6]
                set gr_count [sr_get_attribute $mld_group_range -groupCount]
                
                set mcast [::ixia::emulation_multicast_group_config \
                    -mode create -num_groups $gr_count \
                    -ip_addr_start $gr_from_addr -ip_addr_step $gr_step]
                
                if {[keylget mcast status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "[keylget mcast log]. Could not add a new MLD\
                            group to the internal arrays."
                    return $returnList
                }
                
                foreach mld_source_range [sr_get_child_list $mld_group_range sourceRange] {
                    set ip_addr [sr_get_attribute $mld_source_range -ipFrom]
                    set count [sr_get_attribute $mld_source_range -count]
                    set step 0:0:0:0:0:0:0:1
                    lappend source_create_list $count $ip_addr $step
                }
            }
        }
        
        foreach igmp_host [sr_get_child_list $proto_igmp host] {
            set intf_igmp_id [sr_get_node_by_ixnhandle [sr_get_attribute $igmp_host -interfaces]]
            if {[sr_is_valid_obj $intf_igmp_id]} {
                set host_ip_obj [sr_get_child_list $intf_igmp_id ipv4]
                # only protocol interfaces have ip
                if {[sr_is_valid_obj $host_ip_obj]} {
                    set host_ip [sr_get_attribute $host_ip_obj -ip]
                    set igmp_host_ip_handles_array($host_ip) $igmp_host
                }
            }

            foreach igmp_group [sr_get_child_list $igmp_host group] {
                set gr_from_addr [sr_get_attribute $igmp_group -groupFrom]
                set gr_step [::ixia::num_to_ip_addr [sr_get_attribute $igmp_group -incrementStep] 4]
                set gr_count [sr_get_attribute $igmp_group -groupCount]

                lappend group_create_list $gr_count $gr_from_addr $gr_step
                if {[info exist multicast_group_ip_to_handle($gr_from_addr/$gr_step/$gr_count)]} {
                    lappend multicast_group_ip_to_handle($gr_from_addr/$gr_step/$gr_count) [sr_get_ixnhandle $igmp_group]
                } else {
                    set multicast_group_ip_to_handle($gr_from_addr/$gr_step/$gr_count) [sr_get_ixnhandle $igmp_group]
                }
                
                foreach source [sr_get_child_list $igmp_group source] {
                    set ip_addr [sr_get_attribute $source -sourceRangeStart]
                    set count [sr_get_attribute $source -sourceRangeCount]
                    set step 0.0.0.1

                    lappend source_create_list $count $ip_addr $step
                    set multicast_source_ip_to_handle($ip_addr/$step/$count) [sr_get_ixnhandle $source]
                }
            }
        }

        foreach {count ip_addr step} $group_create_list {
            set mcast [::ixia::emulation_multicast_group_config \
                -mode create                                    \
                -num_groups $count                              \
                -ip_addr_start $ip_addr                         \
                -ip_addr_step $step                             \
            ]
            if {[keylget mcast status] != $::SUCCESS} {
                return [ixia::util::make_error "[keylget mcast log]. Could not add a new IGMP group to the internal arrays."]
            }
        }

        foreach {count ip_addr step} $source_create_list {
            set mcast [::ixia::emulation_multicast_source_config \
                -mode create                                     \
                -num_sources $count                              \
                -ip_addr_start $ip_addr                          \
                -ip_addr_step $step                              \
            ]
            if {[keylget mcast status] != $::SUCCESS} {
                return [ixia::util::make_error "[keylget mcast log]. Could not add a new IGMP source to the internal arrays."]
            }
        }
    }

    # Build the ancp_profile_handles_array. It's an array indexed in the following way:
    #       1. Index is the global dsl sync/resync profile handle; value is the comma separated tlv values
    #       2. Index is the comma separated tlv values; value is a list of 2 elements:
    #           2.1 first element is the global dsl sync profile (if there isn't one 'null' string is there)
    #           2.2 second element is the global dsl resync profile (if there isn't one 'null' string is there)
    #
    # This array keeps track of the global dsl sync/resync profiles created and their tlv values

    set globals_prot_stack [sr_get_node_by_ixnhandle ::ixNet::OBJ-/globals/protocolStack]
    set ancp_globals_obj [sr_get_child_list $globals_prot_stack ancpGlobals]
    
    if {![sr_is_valid_obj $ancp_globals_obj]} {
        return $returnList
    }
    
    # Add dsl sync profiles to array
    set dsl_profile_list [sr_get_child_list $ancp_globals_obj ancpDslProfile]
    
    foreach dsl_profile $dsl_profile_list {
        foreach {plc_holder0 plc_holder1 tlv_code} $tlv_enable_list {
            set tlv_codes_array($tlv_code) "na"
            
            #switch -- $tlv_code {
                #129 -
                #130 {
                    ## actual_rate_upstream and actual_rate_downstream
                    ## They can be in mode trend and have a step value
                    #set tlv_codes_array($tlv_code) "na,na,na,na"
                #}
                #default {
                    #set tlv_codes_array($tlv_code) "na,na"
                #}
            #}
        }
        
        foreach tlv_obj [sr_get_child_list $dsl_profile ancpDslTlv] {
            set tlv_code  [sr_get_attribute $tlv_obj -code]
            set tlv_value [sr_get_attribute $tlv_obj -value]
            
            set tmp_val "${tlv_value},${tlv_value}"
            
            switch -- $tlv_code {
                29 -
                130 {
                    # actual_rate_upstream and actual_rate_downstream
                    # They can be in mode trend and have a step value
                    append tmp_val "na,na"
                }
            }
            
            set tlv_codes_array($tlv_code) $tmp_val
        }
        
        set dsl_profile_csv ""
        foreach {plc_holder0 plc_holder1 tlv_code} $tlv_enable_list {
            # I'm using the tlv_enable_list because i know for sure that the elements are
            #   in the order that they were added
            # Arrays are not ordered and i need to add the comma separated string with it's tlv elements
            #   in a specific order
            append dsl_profile_csv $tlv_codes_array($tlv_code),
        }
        
        if {[string index $dsl_profile_csv end] == ","} {
            set dsl_profile_csv [string replace $dsl_profile_csv end end]
        }
        
        set num_replaces [regsub -all {\\\"} $dsl_profile  {} handle_ignore]
        
        if {$num_replaces == 0} {
            regsub -all {\"} $dsl_profile  {\\"} dsl_profile 
        }
        
        set dsl_profile [lindex $dsl_profile 0]
        
        ancp_handles_array_add $dsl_profile_csv [list [sr_get_ixnhandle $dsl_profile]] null

        array unset tlv_codes_array
    }
    
    # Add dsl resync profiles to array
    foreach dslr_profile [sr_get_child_list $ancp_globals_obj ancpDslResyncProfile] {
        foreach {plc_holder0 plc_holder1 tlv_code} $tlv_enable_list {
            set tlv_codes_array($tlv_code) "na"
            
            #switch -- $tlv_code {
                #129 -
                #130 {
                    ## actual_rate_upstream and actual_rate_downstream
                    ## They can be in mode trend and have a step value and last value
                    #set tlv_codes_array($tlv_code) "na,na,na,na"
                #}
                #default {
                    #set tlv_codes_array($tlv_code) "na,na"
                #}
            #}
        }
        
        foreach tlv_obj [sr_get_child_list $dslr_profile ancpDslResyncTlv] {
            set tlv_code     [sr_get_attribute $tlv_obj -code]
            set tlv_value    [sr_get_attribute $tlv_obj -lastValue]
            set tlv_min_val  $tlv_value
            set tlv_step_val "na"
            set tlv_end_val  "na"
            
            switch -- $tlv_code {
                29 -
                130 {
                    # actual_rate_upstream and actual_rate_downstream
                    # They can be in mode trend and have a step value
                    if {[sr_get_attribute $tlv_obj -mode] == "trend"} {
                        set tlv_step_val [sr_get_attribute $tlv_obj -stepValue]
                        set tlv_end_val  $tlv_value
                    }
                    set tlv_codes_array($tlv_code) "${tlv_value},${tlv_min_val},${tlv_end_val},${tlv_step_val}"
                }
                default {
                    # 144 and 145 don't have min value
                    if {$tlv_code != 144 && $tlv_code != 145} {
                        set tlv_min_val [sr_get_attribute $tlv_obj -firstValue]
                    }
                    
                    set tlv_codes_array($tlv_code) "${tlv_value},${tlv_min_val}"
                }
            }
        }
        
        set dslr_profile_csv ""
        foreach {plc_holder0 plc_holder1 tlv_code} $tlv_enable_list {
            # I'm using the tlv_enable_list because i know for sure that the elements are
            #   in the order that they were added
            # Arrays are not ordered and i need to add the comma separated string with it's tlv elemnts
            #   in a specific order
            append dslr_profile_csv $tlv_codes_array($tlv_code),
        }
        
        if {[string index $dslr_profile_csv end] == ","} {
            set dslr_profile_csv [string replace $dslr_profile_csv end end]
        }
        
        set num_replaces [regsub -all {\\\"} $dslr_profile {} handle_ignore]
        
        if {$num_replaces == 0} {
            regsub -all {\"} $dslr_profile {\\"} dslr_profile
        }
        
        set dslr_profile [lindex $dslr_profile 0]
        
        ancp_handles_array_add $dslr_profile_csv null [list [sr_get_ixnhandle $dslr_profile]]

        array unset tlv_codes_array
    }
    
    ##########################################
    ##########################################
    
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
    
    foreach vport_objref $vport_list {
        # Build the ancp_handles_array. It's an array indexed by the range 
        #       of the underlying protocol (ip, pppox, dhcp) and value of 1
        #       if it has ANCP and 0 if it doesn't
        
        set vport_proto_stack [sr_get_child_list $vport_objref protocolStack]
        if {[sr_get_attribute $vport_objref -type] != "ethernet"} {
            set l2list [sr_get_child_list $vport_proto_stack atm]
        } else {
            set l2list [sr_get_child_list $vport_proto_stack ethernet]
        }
        if {[llength $l2list] == 0} {
            continue
        }
        
        foreach l2item $l2list {
            foreach supported_handle_type $supported_handle_types {
                
                set childElems [split $supported_handle_type /]
                set startElem  $l2item
                foreach childElem $childElems {
                    set startElem [lindex [sr_get_child_list $startElem $childElem] 0]
                    if {![sr_is_valid_obj $startElem]} {
                        break
                    }
                }
                if {![sr_is_valid_obj $startElem]} {
                    continue
                }
                
                if {![sr_equal_obj $startElem $l2item]} {
                    if {![catch {sr_get_child_list $startElem ancp} ancph] && [llength $ancph] > 0} {
                        set ancp_present 1
                    } else {
                        set ancp_present 0
                    }
                    
                    set rangeList [sr_get_child_list $startElem range]
                    
                    foreach range $rangeList {
                        set ancp_handles_array([sr_get_ixnhandle $range]) $ancp_present
                        
                        set ancp_range [sr_get_child_list $range ancpRange]
                        if {![sr_is_valid_obj $ancp_range]} {
                            continue
                        }
                        set ancp_range_ixn [sr_get_ixnhandle $ancp_range]
                        
                        # must rebuild handles_state_evidence_array
                        # This array is used to determine which global dsl profile is used by which ancp range with what percentage
                        #       and wether it's enabled or not (enabled/disabled is not available from ixNetwork)
                        #       enable == the ancp range uses the dsl profile\
                        #       disable == the dsl profile does not exist in the ancp range
                        #       enable (after disable) == adds the dsl global profile in the ancp range
                        # handles_state_evidence_array($dsl_global_profile,$ancp_range,$dsl_allocation_table) [list $percentage $enabled])
                        #   $enabled is 0|1
                        # All profiles will be enabled (1)
                        # When a profile is disabled in HLT, we delete it from the range
                        # We cannot restore profiles that were disabled from HLT because that information is stored in HLT only in
                        #   the current session
                        foreach dsl_alloc [sr_get_child_list $ancp_range dslProfileAllocationTable] {
                            # ixn sometimes returns this attribute with the ::ixNet::OBJ prefix and sometimes it doesnt
                            set dsl_gprof [sr_get_attribute $dsl_alloc -dslProfile]
                            if {[string first "::ixNet::OBJ-" $dsl_gprof] == -1} {
                                set dsl_gprof "::ixNet::OBJ-$dsl_gprof"
                            }
                            set percentage [sr_get_attribute $dsl_alloc -percentage]
                            
                            set dsl_alloc_ixn [sr_get_ixnhandle $dsl_alloc]
                            set key "$dsl_gprof,$ancp_range_ixn,$dsl_alloc_ixn"
                            set ::ixia::handles_state_evidence_array($key) [list $percentage 1]
                        }
                        
                        # Same thing is done for dsl resync profiles
                        foreach dsl_rsync_alloc [sr_get_child_list $ancp_range dslResyncProfileAllocationTable] {
                            # ixn sometimes returns this attribute with the ::ixNet::OBJ prefix and sometimes it doesnt
                            set dsl_rsync_gprof [sr_get_attribute $dsl_rsync_alloc -dslProfile]
                            if {[string first "::ixNet::OBJ-" $dsl_rsync_gprof] == -1} {
                                set dsl_rsync_gprof "::ixNet::OBJ-$dsl_rsync_gprof"
                            }
                            set percentage [sr_get_attribute $dsl_rsync_alloc -percentage]
                            
                            set dsl_rsync_alloc_ixn [sr_get_ixnhandle $dsl_rsync_alloc]
                            set key "$dsl_rsync_gprof,$ancp_range_ixn,$dsl_rsync_alloc_ixn"
                            set ::ixia::handles_state_evidence_resynch_array($key) [list $percentage 1]
                        }
                    }
                }
            }
        }
    }
    
    return $returnList
}

namespace eval ::ixia::session_resume::filter_build {
    # this is a list of required attributes used by session_resume::sr_initialize
    # all of the objects here are assumed to be used in the ::ixia::$func_name where
    # func_name is the analogous function
    # if there are any attributes that are required and not present here, sr_get_attribute
    # will throw an error
    proc detect_dhcp_variables {} {
        set global_params {
            -acceptPartialConfig       
            -dhcp4AddrLeaseTime        
            -dhcp4MaxMsgSize           
            -dhcp4ResponseTimeout      
            -dhcp4NumRetry             
            -dhcp4ServerPort           
            -waitForCompletion         
            -dhcp6EchoIaInfo           
            -dhcp6RebMaxRt             
            -dhcp6RebTimeout           
            -dhcp6RelMaxRc             
            -dhcp6RelTimeout           
            -dhcp6RenMaxRt             
            -dhcp6RenTimeout           
            -dhcp6ReqMaxRc             
            -dhcp6ReqMaxRt             
            -dhcp6ReqTimeout           
            -dhcp6SolMaxRc             
            -dhcp6SolMaxRt             
            -dhcp6SolTimeout           
            -dhcp4ResponseTimeoutFactor
        }
        set options_args {
            -maxOutstandingReleases    
            -maxOutstandingRequests    
            -teardownRateInitial       
            -teardownRateIncrement     
            -setupRateInitial          
            -setupRateIncrement            
            -associates                    
            -overrideGlobalSetupRate   
            -overrideGlobalTeardownRate
            -teardownRateMax           
            -setupRateMax              
        }
        
        return [list \
            "/globals/protocolStack/dhcpGlobals" $global_params \
            "/vport/protocolStack/dhcpOptions" $options_args \
        ]
    }
}

proc ::ixia::detect_dhcp_variables {} {
    keylset returnList status $::SUCCESS
    
    variable dhcp_globals_params
    variable dhcp_options_params
    
    # repopulate the dhcp client arrays from ixn
    
    set global_params {
        acceptPartialConfig       
        dhcp4AddrLeaseTime        
        dhcp4MaxMsgSize           
        dhcp4ResponseTimeout      
        dhcp4NumRetry             
        dhcp4ServerPort           
        waitForCompletion         
        dhcp6EchoIaInfo           
        dhcp6RebMaxRt             
        dhcp6RebTimeout           
        dhcp6RelMaxRc             
        dhcp6RelTimeout           
        dhcp6RenMaxRt             
        dhcp6RenTimeout           
        dhcp6ReqMaxRc             
        dhcp6ReqMaxRt             
        dhcp6ReqTimeout           
        dhcp6SolMaxRc             
        dhcp6SolMaxRt             
        dhcp6SolTimeout           
        dhcp4ResponseTimeoutFactor
    }

    set options_args {
        maxOutstandingReleases    
        maxOutstandingRequests    
        teardownRateInitial       
        teardownRateIncrement     
        setupRateInitial          
        setupRateIncrement            
        associates                    
        overrideGlobalSetupRate   
        overrideGlobalTeardownRate
        teardownRateMax           
        setupRateMax              
    }

    # ensure initialized
    session_resume::sr_initialize
    namespace import -force ::ixia::session_resume::sr_get_ixnhandle
    namespace import -force ::ixia::session_resume::sr_get_node_by_ixnhandle
    namespace import -force ::ixia::session_resume::sr_get_root
    namespace import -force ::ixia::session_resume::sr_get_attribute
    namespace import -force ::ixia::session_resume::sr_get_child_list
    
    # there should be just one object
    set protocol_stack [sr_get_node_by_ixnhandle ::ixNet::OBJ-/globals/protocolStack]
    set globals_obj [sr_get_child_list $protocol_stack dhcpGlobals]
    foreach ixn_arg $global_params {
        # ixn param has not been created
        if {[catch {sr_get_attribute $globals_obj -$ixn_arg} res]} { continue }
        set dhcp_globals_params($ixn_arg) $res
    }
    
    set dhcp_options_params(ixn_param_list) $options_args
    
    # gather dhcpOptions from each vport
    set vport_list [sr_get_child_list [sr_get_root] vport]
    foreach vp $vport_list {
        set vp_protstack [sr_get_child_list $vp protocolStack]
        set optl_obj [sr_get_child_list $vp_protstack dhcpOptions]
        if {[llength $optl_obj] == 0} { continue }
        
        foreach ixn_arg $options_args {
            # ixn param has not been created
            if {[catch {sr_get_attribute $optl_obj -$ixn_arg} res]} { continue }
            set dhcp_options_params($vp,$ixn_arg) $res
        }
    }
    
    return $returnList
}


proc ::ixia::get_ixn_obj_list_filtered {type_paths tp_ixn_obj_ref} {    
    upvar 1 $tp_ixn_obj_ref tp_ixn_obj

    foreach ixn_object_shape $type_paths {
        ixNetworkGetObjWithShape $ixn_object_shape tp_ixn_obj
    }
}


proc ::ixia::get_ixn_obj_list { crt_objref {all_objects ""}} {
    
    array set all_objects_array $all_objects
    
    set    skip_list_regex  (^::ixNet::OBJ-/eventScheduler)
    append skip_list_regex |(^::ixNet::OBJ-/integratedTest)
    append skip_list_regex |(^::ixNet::OBJ-/statistics)
    append skip_list_regex |(^::ixNet::OBJ-/testConfiguration)
    append skip_list_regex |(^::ixNet::OBJ-/traffic/dynamicFrameSize)
    append skip_list_regex |(^::ixNet::OBJ-/traffic/dynamicRate)
    append skip_list_regex |(^::ixNet::OBJ-/traffic/protocolTemplate)
    append skip_list_regex |(^::ixNet::OBJ-/traffic/statistics)
    append skip_list_regex |(^::ixNet::OBJ-/traffic/trafficGroup)
    append skip_list_regex |(^::ixNet::OBJ-/vport:\\d+/capture)
    append skip_list_regex |(^::ixNet::OBJ-/vport:\\d+/discoveredNeighbor)
    append skip_list_regex |(^::ixNet::OBJ-/vport:\\d+/rateControlParameters)
    append skip_list_regex |(^::ixNet::OBJ-/vport:\\d+/l1Config)
    
    set exec_regex {^\s+(\w+\(Objref=/.+\)\s+Returning.*)$}
    set attr_regex {^\s+(\w+\s+\w+(\s+\(readonly\))?$)}
    set chld_regex {^\s+(\w+$)}
    
    set exec_title_regex {(Member execs:)|(Execs:)}
    set attr_title_regex {Attributes:}
    set chld_title_regex {(Child lists:)|(Child Lists:)}
    
    # get the contents of the current object
    set crt_obj_content [split [ixNet help $crt_objref] "\n"];
    # start exploring the object
    set in_list "none";
    set exec_list [list]
    set attr_list [list]
    set chld_list [list]
    foreach line $crt_obj_content {
        if {$line == ""} {
            continue
        }
        if {[regexp $exec_title_regex $line]} {
            set in_list "exec"
            continue;
        }
        if {[regexp $attr_title_regex $line]} {
            set in_list "attribute"
            continue;
        }
        if {[regexp $chld_title_regex $line]} {
            set in_list "child"
            continue;
        }
        switch -- $in_list {
            "exec" {
                if {[regexp $exec_regex $line {} match]} {
                    lappend exec_list $match
                }
            }
            "attribute" {
                if {[regexp $attr_regex $line {} match]} {
                    lappend attr_list $match
                }
            }
            "child" {
                if {[regexp $chld_regex $line {} match]} {
                    lappend chld_list $match
                }
            }
        }
    }
    
    foreach elem $chld_list {
        if {$crt_objref == "::ixNet::OBJ-/"} {
            set elem_shape $crt_objref$elem
        } else {
            set elem_shape $crt_objref/$elem
        }
        
        if {[regexp $skip_list_regex $elem_shape]} {
            continue
        }
        
        if {[catch {ixNet getList $crt_objref $elem} chld_obj_list]} {
            continue
        }
        
        foreach chld_obj $chld_obj_list {
            if {[llength $chld_obj] > 0} {
                set chld_obj_path ""
                foreach path_item [lrange [split $chld_obj /] 1 end] {
                    append chld_obj_path "/[lindex [split $path_item :] 0]"
                }
                
                if {[llength $chld_obj_path] == 0} {
                    continue
                }
                
                if {[info exists all_objects_array($chld_obj_path)]} {
                    set bak_obj_list $all_objects_array($chld_obj_path)
                    lappend bak_obj_list $chld_obj
                    set all_objects_array($chld_obj_path) [lsort -unique $bak_obj_list]
                } else {
                    set all_objects_array($chld_obj_path) $chld_obj
                }
                
                array set all_objects_array [::ixia::get_ixn_obj_list $chld_obj [array get all_objects_array]]
            }
        }
    }
    
    return [array get all_objects_array]
}

proc ::ixia::connect_to_tcl_server {tcl_server} {
    
    global _device
    set procName [lindex [info level [info level]] 0]
    
    if {![isIpAddressValid $tcl_server]} {
        if {[info exists _device($tcl_server)]} {
            if {[isIpAddressValid $_device($tcl_server)]} {
                set ip_tcl_server $_device($tcl_server)
            } else {
                set ::ixErrorInfo "ERROR in $procName: An invalid IP\
                        address was found for $tcl_server in _device"
                return 1
            }
        } elseif {[catch {set ip_list [host_info addresses $tcl_server]}]\
                || $ip_list == ""} {
            set ::ixErrorInfo "ERROR in $procName: $tcl_server cannot be resolved by DNS - $ip_list "
            return 1
        } else {
            set _device($tcl_server) [lindex $ip_list 0]
            set ip_tcl_server [lindex $ip_list 0]
        }
    } else {
        set ip_tcl_server $tcl_server
    }
    
    return [ixConnectToTclServer $ip_tcl_server]
}


proc ::ixia::set_aggregated_mode {port_handle_list} {
    variable aggregation_mode
    variable aggregation_resource_mode
    keylset returnList status $::SUCCESS
    
    if {[llength $aggregation_mode] > 1} {
        set aggregation_mode [lindex $aggregation_mode 0]
    }
    array set processed_cards ""
    foreach port $port_handle_list {
        foreach {chassis_id card_id port_id} [split $port /] {}
        if {[card isValidFeature $chassis_id $card_id 280]} {
            if {[info exists processed_cards(${chassis_id}/${card_id})]} {
                continue
            }
            set processed_cards(${chassis_id}/${card_id}) 1
            array set translate_mode {
                0                       normal
                1                       one_gig_aggregation
                2                       ten_gig_aggregation
                normal                  0
                one_gig_aggregation     1
                ten_gig_aggregation     2
            }
            set currentMode [card cget -operationMode]
            if {$translate_mode($currentMode) == $translate_mode($aggregation_mode)} {
                continue
            }
            
            if {[card writeOperationMode $translate_mode($aggregation_mode) $chassis_id $card_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed while setting aggregated mode for card $chassis_id/$card_id. $::ixErrorInfo"
                return $returnList
            }
            return $returnList
        }
    }
    set aggregation_resource_mode ""
    foreach port $port_handle_list {
        lappend aggregation_resource_mode $aggregation_mode
    }
    # clear variable aggregation_mode
    
    set agg_resource_mode_status [set_aggregation_resource_mode $port_handle_list]
    if {[keylget agg_resource_mode_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to set the aggregation mode \"$aggregation_mode\". \
                [keylget agg_resource_mode_status log]"
    }
    unset ::ixia::aggregation_mode
    return $returnList
}

proc ::ixia::set_jasper_resource_aggregation {} {
    uplevel {
    
        if { $local_aggr_res_mode == "ten_gig_fan_out"} {
            puts "WARNING! Aggreation mode $local_aggr_res_mode is not supported for IxOS. Using three_by_ten_gig_fan_out mode instead for $port!"
            set local_aggr_res_mode three_by_ten_gig_fan_out
        }
        
        if { $local_aggr_res_mode == "four_by_ten_gig_fan_out"} {
            puts "WARNING! Aggreation mode $local_aggr_res_mode is not supported for IxOS. Using eight_by_ten_gig_fan_out mode instead for $port!"
            set local_aggr_res_mode eight_by_ten_gig_fan_out
        }
        
        debug "Setting aggregation $local_aggr_res_mode on $chassis_id $card_id $port_id"
        set changes_needed 0
        debug "resourceGroupEx get $chassis_id $card_id $port_id"
        if {[resourceGroupEx get $chassis_id $card_id $port_id]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error setting aggregation_resource_mode:\
                    failed to execute resourceGroupEx get $chassis_id $card_id\
                    $port_id while configuring card resource groups. $::ixErrorInfo"
            return $returnList
        }
        set existing_mode [resourceGroupEx cget -mode]
        debug "resourceGroupEx cget -mode returned $existing_mode"
        
        if {$local_aggr_res_mode == "hundred_gig_non_fan_out"} {
            if {[lsearch $jasper_100g_supported $card_type_id] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Card type $card_type does not support hundred_gig_non_fan_out"
                return $returnList
            }
            if {$port_id > 4} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error setting aggregation_resource_mode:\
                        port $port_id from card $card_type does not support\
                        hundred_gig_non_fan_out (only ports 1-4 can be in 100Gig mode). "
                return $returnList
            }

            # ports 1,2,3,4 are 100Gig
            # mode 7 means 100Gig speed
            # if mode id already 100gig then there is nothing to set
            if { $existing_mode != 7 } {
                set changes_needed 1
                set mode 7
                set activeCapturePortList "{{$chassis_id $card_id $port_id}}"
                set activePortList "{{$chassis_id $card_id $port_id}}"
            }
                    
        } elseif {$local_aggr_res_mode == "forty_gig_fan_out" || \
                $local_aggr_res_mode == "three_by_ten_gig_fan_out"  || \
                $local_aggr_res_mode == "forty_gig_normal_mode" } {
           
            if {[lsearch $jasper_100g_supported $card_type_id] != -1} {
                if {$port_id <= 4} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error setting aggregation_resource_mode:\
                            port $port_id from card $card_type does not support\
                            $local_aggr_res_mode (ports 1-4 can only be in 100Gig mode). "
                    return $returnList
                } else {
                    #if card supports 100G too then the port numbers starts from 5 instead of 1
                    set temp_difference 4
                }
            } else {
                set temp_difference 0
            }

            if {$local_aggr_res_mode == "forty_gig_fan_out" || \
                   $local_aggr_res_mode == "forty_gig_normal_mode" } {
                # mode 8 means 40Gig speed
                set mode 8
            } 
            
            if {$local_aggr_res_mode == "three_by_ten_gig_fan_out"} {
                # mode 10 means 10Gig speed
                set mode 10
            }

            switch [expr $port_id - $temp_difference] {
                "1" -
                "2" -
                "3" {
                    # Resource group 1 10Gig or 40Gig ports
                    set temp_start_port [expr 1+$temp_difference]
                }
                "4" -
                "5" -
                "6" {
                    # Resource group 2 10Gig or 40Gig ports
                    set temp_start_port [expr 4+$temp_difference]
                }
                "7" -
                "8" -
                "9" 
                {
                    # Resource group 3 10Gig or 40Gig ports
                    set temp_start_port [expr 7+$temp_difference]
                }
                "10" -
                "11" -
                "12" {
                    # Resource group 4 10Gig or 40Gig ports
                    set temp_start_port [expr 10+$temp_difference]
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error setting $local_aggr_res_mode \
                            aggregation_resource_mode: invalid port \
                            \"{$chassis_id $card_id $port_id}\""
                    return $returnList
                }
            }
            
            if { $mode != $existing_mode } {
                set changes_needed 1
                set activeCapturePortList "{{$chassis_id $card_id $port_id}}"
                set activePortList "{{$chassis_id $card_id $temp_start_port}\ 
                        {$chassis_id $card_id [expr $temp_start_port + 1]}\
                        {$chassis_id $card_id [expr $temp_start_port + 2]}}"
            }
        } elseif {$local_aggr_res_mode == "eight_by_ten_gig_fan_out" } {

            if {[lsearch $jasper_8x10g_supported $card_type_id] == -1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error setting aggregation_resource_mode:\
                            card $card_type does not support $local_aggr_res_mode . "
                    return $returnList
            }
            
            if {$card_type_id == 193 } {
                if {$port_id <= 16} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error setting aggregation_resource_mode:\
                            port $port_id from card $card_type does not support\
                            $local_aggr_res_mode (port number needs to be greater than 16). "
                    return $returnList
                }
                set temp_difference 16
            } elseif {$card_type_id == 200 } {
                if {$port_id <= 6} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error setting aggregation_resource_mode:\
                            port $port_id from card $card_type does not support\
                            $local_aggr_res_mode (port number needs to be greater than 6). "
                    return $returnList
                }
                set temp_difference 6
            } else {
                if {$port_id <= 12} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error setting aggregation_resource_mode:\
                            port $port_id from card $card_type does not support\
                            $local_aggr_res_mode (port number needs to be greater than 12). "
                    return $returnList
                }
                set temp_difference 12
            }
            
            # mode 9 means 8X10Gig speed
            set mode 9

            switch [expr $port_id - $temp_difference] {
                "1" -
                "2" -
                "3" -
                "4" -
                "5" -
                "6" -
                "7" -
                "8" {
                    # Resource group 1 10Gig or 40Gig ports
                    set temp_start_port [expr 1+$temp_difference]
                }
                "9" -
                "10" -
                "11" -
                "12" -
                "13" -
                "14" -
                "15" -
                "16" {
                    # Resource group 2 10Gig or 40Gig ports
                    set temp_start_port [expr 9+$temp_difference]
                }
                "17" -
                "18" -
                "19" -
                "20" -
                "21" -
                "22" -
                "23" -
                "24" 
                {
                    # Resource group 3 10Gig or 40Gig ports
                    set temp_start_port [expr 17+$temp_difference]
                }
                "25" -
                "26" -
                "27" -
                "28" -
                "29" -
                "30" -
                "31" -
                "32" {
                    # Resource group 4 10Gig or 40Gig ports
                    set temp_start_port [expr 25+$temp_difference]
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error setting $local_aggr_res_mode \
                            aggregation_resource_mode: invalid port \
                            \"{$chassis_id $card_id $port_id}\""
                    return $returnList
                }
            }
            
            if { $mode != $existing_mode } {
                set changes_needed 1
                set activeCapturePortList "{{$chassis_id $card_id $port_id}}"
                set activePortList "{{$chassis_id $card_id $temp_start_port}\ 
                        {$chassis_id $card_id [expr $temp_start_port + 1]}\
                        {$chassis_id $card_id [expr $temp_start_port + 2]}\
                        {$chassis_id $card_id [expr $temp_start_port + 3]}\
                        {$chassis_id $card_id [expr $temp_start_port + 4]}\
                        {$chassis_id $card_id [expr $temp_start_port + 5]}\
                        {$chassis_id $card_id [expr $temp_start_port + 6]}\
                        {$chassis_id $card_id [expr $temp_start_port + 7]}}"
            }
        } else {
            keylset returnList log "Error setting aggregation_resource_mode:\
                    $local_aggr_res_mode is not supported."
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {$changes_needed} {
            debug "resourceGroupEx config -mode $mode"
            resourceGroupEx config -mode $mode
            debug "resourceGroupEx config -activePortList $activePortList"
            resourceGroupEx config -activePortList $activePortList
            debug "resourceGroupEx config -activeCapturePortList $activeCapturePortList"
            resourceGroupEx config -activeCapturePortList $activeCapturePortList
        
            debug "resourceGroupEx set $chassis_id $card_id $port_id"
            if {[resourceGroupEx set $chassis_id $card_id $port_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error setting aggregation_resource_mode:\
                        failed to execute resourceGroupEx set $chassis_id $card_id $port_id\
                        while configuring card resource groups. $::ixErrorInfo"
                return $returnList
            }
            
            
            debug "resourceGroupEx write $chassis_id $card_id $port_id"
            if {[resourceGroupEx write $chassis_id $card_id $port_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error setting aggregation_resource_mode:\
                        failed to execute resourceGroupEx write $chassis_id $card_id $port_id\
                        while configuring card resource groups. $::ixErrorInfo"
                return $returnList
            }
        
        } else {
            debug "Aggregation mode is allready in $local_aggr_res_mode mode. Skipping set."
        }
    }
}

proc ::ixia::set_aggregation_resource_mode {port_handle_list} {
    
    variable aggregation_resource_mode
    keylset returnList status $::SUCCESS
    set local_aggregation_mode $aggregation_resource_mode
    unset ::ixia::aggregation_resource_mode
    
    foreach port $port_handle_list local_aggr_res_mode $local_aggregation_mode {
        if {$local_aggr_res_mode == "not_supported"} {
            continue 
        }
        foreach {chassis_id card_id port_id} [split $port /] {}
        if {[card get $chassis_id $card_id]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to get card $chassis_id/$card_id while configuring card aggregation mode. $::ixErrorInfo"
            return $returnList
        }
        
        set card_type_id [card cget -type]
        set card_type [card cget -typeName]
        set numPorts [card cget -portCount]
        
        
        set jasper_100g_only_cards_ids [list 191]
        set jasper_10_40_100_cards_ids [list 193]
        set jasper_10_40_cards_ids [list 197 199 200]
        set jasper_100g_supported "$jasper_100g_only_cards_ids $jasper_10_40_100_cards_ids"
        set jasper_8x10g_supported "$jasper_10_40_100_cards_ids $jasper_10_40_cards_ids"
        set jasper_cards_ids "$jasper_100g_only_cards_ids $jasper_10_40_100_cards_ids\
                $jasper_10_40_cards_ids"
       
        # 191 - XM100GE4CXP          - 4 ports 100Gig
        # 193 - XM100GE4CXP+FAN+10G  - 16 ports 1-4 100Gig 5-16 10/40 Gig
        # 197 - XM40GE12QSFP+FAN+10G - 12 ports 10/40 Gig
        # 199 - XM10/40GE12QSFP+FAN  - 12 ports 10/40 Gig
        # 200 - XM10/40GE06QSFP+FAN  - 06 ports 10/40 Gig
        if {[lsearch $jasper_cards_ids $card_type_id] != -1 } {
            # Jasper Card
            ::ixia::set_jasper_resource_aggregation
            continue
        }
        if {$numPorts==6} {
            # The card is Lava 6 port 40/100Gig. It supports single_mode_aggregation and dual_mode_aggregation
            if {$local_aggr_res_mode=="single_mode_aggregation" || $local_aggr_res_mode=="dual_mode_aggregation"} {
                if {($local_aggr_res_mode=="single_mode_aggregation")} {
                    if {$port_id==3 || $port_id==4} { set port_id 1}
                    if {$port_id==5 || $port_id==6} { set port_id 2}
                }
                if {($local_aggr_res_mode=="dual_mode_aggregation")} {
                    if {$port_id==1} {set port_id 3}
                    if {$port_id==2} {set port_id 5}
                }
                if {[cfpPort get $chassis_id $card_id $port_id]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to execute cfpPort get $chassis_id $card_id $port_id\
                            while configuring card aggregation mode. $::ixErrorInfo"
                    return $returnList
                }
                if {[cfpPort forceEnablePort $chassis_id $card_id $port_id]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to execute cfpPort forceEnablePort $chassis_id $card_id $port_id\
                            while configuring card aggregation mode. $::ixErrorInfo"
                    return $returnList
                }
                if {[cfpPort set $chassis_id $card_id $port_id]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to execute cfpPort set $chassis_id $card_id $port_id\
                            while configuring card aggregation mode. $::ixErrorInfo"
                    return $returnList
                }
                if {[cfpPort write $chassis_id $card_id $port_id]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to execute cfpPort write $chassis_id $card_id $port_id\
                            while configuring card aggregation mode. $::ixErrorInfo"
                    return $returnList
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Port $chassis_id $card_id $port_id supports only single_mode_aggregation\
                        or dual_mode_aggregation."
                return $returnList
            }
            continue
        }
        
        # Check if the Card supports Resource Groups - kFeatureResourceGroup
        if {![card isValidFeature $chassis_id $card_id 454]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The current card $chassis_id/$card_id does\
                    not support resource groups. $::ixErrorInfo"
            return $returnList
        }
        # Get the max. number of Resource Groups per Card
        set maxRG [card getMaxResourceGroups $chassis_id $card_id]
        
        # Number of Resource Groups. 20 for combo; 16 for Everest 10G
        set portsPerRG [expr $numPorts / $maxRG]
        
        # There are 5 ports in Resource Group for 40G combo, and 4 ports in
        # Resource Group for 10G
        set rgPorts1 [list [list 1] [list 2] [list 3] [list 4]]
        set rgPorts2 [list [list 5] [list 6] [list 7] [list 8]]
        set rgPorts3 [list [list 9] [list 10] [list 11] [list 12]]
        set rgPorts4 [list [list 13] [list 14] [list 15] [list 16]]
        # Check if card is Everest 10/40G Combo
        if {[card isValidFeature $chassis_id $card_id 435]} {
            lappend rgPorts1 [list 17]
            lappend rgPorts2 [list 18]
            lappend rgPorts3 [list 19]
            lappend rgPorts4 [list 20]
        }

        set verifiy_port [::ixia::verify_port_aggregation $card_type $port $local_aggr_res_mode]
        if {[keylget verifiy_port status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error setting aggregation mode on $port.\
                    [keylget verifiy_port log]"
            return $returnList
        }
        
        switch $local_aggr_res_mode {
            normal {
                set agg_speed 10000
            }
            ten_gig_aggregation {
                set agg_speed 10000
            }
            forty_gig_aggregation {
                set agg_speed 40000
            }
            default {
                set agg_speed 10000
            }
        }
        array set rgPorts_mapping {
            1       rgPorts1
            2       rgPorts1
            3       rgPorts1
            4       rgPorts1
            5       rgPorts2
            6       rgPorts2
            7       rgPorts2
            8       rgPorts2
            9       rgPorts3
            10      rgPorts3
            11      rgPorts3
            12      rgPorts3
            13      rgPorts4
            14      rgPorts4
            15      rgPorts4
            16      rgPorts4
            17      rgPorts1
            18      rgPorts2
            19      rgPorts3
            20      rgPorts4
        }
        # Verify if the desired aggregation type is the same as the current one
        set configuredRGList [card getConfiguredResourceGroupList $chassis_id $card_id]
        if {$configuredRGList != ""} {
            set same_aggregation 0
            set port_delete 0
            foreach {port speed rgPorts} [join $configuredRGList] {
                if {($port_id == $port) && ($local_aggr_res_mode != "normal")} {
                    set same_aggregation 1
                } elseif {[lsearch $rgPorts $port_id] != -1} {
                    set port_delete $port
                    break
                }
            }
            if {$same_aggregation == 0} {
                if {$port_delete != 0} {
                    set dList [list [list $port_delete]]
                } else {
                    set dList [list [list $port_id]]
                }
                card deleteResourceGroups $chassis_id $card_id $dList
            } elseif {$same_aggregation == 1} {
                continue
            }
        }
        # Adding resource group on the port
        if {$local_aggr_res_mode != "normal"} {
            card addResourceGroup $port_id $agg_speed [set $rgPorts_mapping($port_id)]
            card createResourceGroups $chassis_id $card_id
        }
    }
    return $returnList
}

proc ::ixia::protintf_svlan_csv_prepare {args} {
    
    keylset returnList status $::SUCCESS
    set man_args {
        -vlan_id                  ANY
    }
    set opt_args {
        -vlan_id_mode             ANY
        -vlan_id_step             ANY
        -vlan_tpid                ANY
        -vlan_user_priority       ANY
        -vlan_user_priority_step  ANY
        -index                    NUMERIC
                                  DEFAULT 0
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -mandatory_args $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    set upvar_param_list {vlan_id vlan_id_mode vlan_id_step vlan_tpid vlan_user_priority vlan_user_priority_step}
    
    # If the parameter list length is smaller than port_count duplicate it's last value
    # so that it has the same length
    # If it's smaller trim it. They must have the same length, otherwise ixos does not change
    # the number of vlans in stackedVlan
    foreach var $upvar_param_list {
        
        if {![info exists $var]} {
            continue
        }
        
        if {[llength [set $var]] == 1} {
            set ${var}_at_index [set $var]
        } else {
            set ${var}_at_index [lindex [set $var] $index]
        }
    }
    
    # expand the parameters that have a single value
    set vlan_count [llength [split $vlan_id_at_index ,]]
    foreach hlt_param_list $upvar_param_list {
        
        set hlt_param_list ${hlt_param_list}_at_index
        if {![info exists $hlt_param_list]} {
            continue
        }
        
        set hlt_param_list_value [set $hlt_param_list]
        set hlt_param_list_length [llength [split $hlt_param_list_value ,]]
        if {$hlt_param_list_length < $vlan_count} {
            set tmp_last_value [lindex [split $hlt_param_list_value ,] end]
            for {set i $hlt_param_list_length} {$i < $vlan_count} {incr i} {
                append $hlt_param_list ",$tmp_last_value"
            }
            catch {unset tmp_last_value}
        } elseif {$hlt_param_list_length > $vlan_count} {
            set $hlt_param_list [join [lrange [split $hlt_param_list_value ,] 0 [expr $vlan_count - 1]] ,]
        }
    }

    # check the VLAN ID value
    set vlan_id_temp_list [split $vlan_id_at_index ,]
    set vlan_id_list [list]
    foreach vlan_id_tmp $vlan_id_temp_list {
        if {$vlan_id_tmp >= 0 && $vlan_id_tmp <= 4095} {
            lappend vlan_id_list $vlan_id_tmp
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed on parsing the -vlan_id option. $vlan_id_tmp is not a valid VLAN ID."
            return $returnList
        }
    }
    
    # check the VLAN ID mode value
    if {[info exists vlan_id_mode_at_index]} {
        set vlan_id_mode_list [split $vlan_id_mode_at_index ,]
        if {[llength $vlan_id_mode_list] != [llength $vlan_id_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The length of the -vlan_id_mode option must be the same as that of the -vlan_id option."
            return $returnList
        }
    }
    
    # check the VLAN ID step value
    if {[info exists vlan_id_step_at_index]} {
        set vlan_id_temp_step_list [split $vlan_id_step_at_index ,]
        if {[llength $vlan_id_temp_step_list] != [llength $vlan_id_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The length of the -vlan_id_step option must be the same as that of the -vlan_id option."
            return $returnList
        }
        set vlan_id_step_list [list]
        foreach vlan_id_step_tmp $vlan_id_temp_step_list {
            if {$vlan_id_step_tmp < 0 || $vlan_id_step_tmp > 4095} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed on parsing the -vlan_id_step option. $vlan_id_step_tmp is not a valid VLAN ID step."
                return $returnList
            }
        }
    }
    
    if {[info exists vlan_tpid_at_index]} {
        # check the VLAN TPID value
        set vlan_tpid_list [split $vlan_tpid_at_index ,]
        if {[llength $vlan_tpid_list] != [llength $vlan_id_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The length of the -vlan_tpid option must be the same as that of the -vlan_id option."
            return $returnList
        }
    }
    
    if {[info exists vlan_user_priority_at_index]} {
        # check the VLAN user priority value
        set vlan_user_priority_list [split $vlan_user_priority_at_index ,]
        if {[llength $vlan_user_priority_list] != [llength $vlan_id_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The length of the -vlan_user_priority option must be the same as that of the -vlan_id option."
            return $returnList
        }
    }
    
    if {[info exists vlan_user_priority_step_at_index]} {
        # check the VLAN user priority step value
        set vlan_user_priority_step_list [split $vlan_user_priority_step_at_index ,]
        if {[llength $vlan_user_priority_step_list] != [llength $vlan_id_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The length of the -vlan_user_priority_step option must be the same as that of the -vlan_id option."
            return $returnList
        }
    }
    
    # Replace element at $index from $var with $var_at_index
    foreach element $upvar_param_list {
        
        if {![info exists $element]} {
            continue
        }
        
        set element_at_index ${element}_at_index
        keylset returnList $element [set $element_at_index]
    }

    return $returnList
}

proc ::ixia::protintf_svlan_csv_increment {
        vlan_id_param
        vlan_id_mode_param
        vlan_id_step_param
        vlan_user_priority_param
        vlan_user_priority_step_param
    } {
    
    foreach var {
        vlan_id
        vlan_id_mode
        vlan_id_step
        vlan_user_priority
        vlan_user_priority_step
    } {
        upvar [set ${var}_param] $var
    }
    
    set vlan_id            [protintf_svlan_csv_incr $vlan_id            $vlan_id_step            4096 $vlan_id_mode]
    set vlan_user_priority [protintf_svlan_csv_incr $vlan_user_priority $vlan_user_priority_step 8    $vlan_id_mode]
}

proc ::ixia::protintf_svlan_csv_incr {value step modulo {mode {increment}}} {
    
    set value_list [split $value ,]
    set step_list  [split $step ,]
    set mode_list  [split $mode ,]
    
    for {set index 0} {$index < [llength $value_list]} {incr index} {
        set base_val [lindex $value_list $index]
        
        if {[llength $step_list] < [expr $index + 1]} {
            set base_step [lindex $step_list end]
        } else {
            set base_step [lindex $step_list $index]
        }
        
        if {[llength $mode_list] < [expr $index + 1]} {
            set base_mode [lindex $mode_list end]
        } else {
            set base_mode [lindex $mode_list $index]
        }
        
        if {$base_mode == "increment"} {
            set value_list [lreplace $value_list $index $index [expr ($base_val + $base_step) % $modulo]]
        }
    }
    set value [join $value_list ,]
    return $value
}

proc ::ixia::guardrail_info {{print_msgs true}} {
    set returnList ""
    keylset returnList status $::SUCCESS
    set x 0
    keylset returnList guardrail_messages {}
    if {[catch { foreach err [ixNet getL /globals/appErrors error] {
            if {![regexp {/error:\"\d+\"$} $err]} {
                incr x        
                set error       [ixNet getA $err -errorLevel]
                set provider    [ixNet getA $err -provider]
                set desc        [string map {\n " "} [ixNet getA $err -description]]
                set name        [ixNet getA $err -name]
                if {[string trim $desc] == ""} {set desc $name}
                set msg "[string toupper [string range $error 1 end]]: $provider - $desc"
                if {$print_msgs && ($error =="kError" || $error == "kWarning")} { puts "$msg" }
                keylset returnList guardrail_messages.$x $msg
            }
        }} error ] } {
            keylset returnList status $::FAILURE
            keylset returnList logs $error
    }
    return $returnList
}
proc ::ixia::connection_key_builder {con_token} {
    set returnList ""
    array set truth [list  True 1 False 0]
    #puts "con_token: $con_token"
    foreach {param value} $con_token {
        switch -- $param {
            processid {
                keylset returnList process_id $value
            }
            sessionid {
                keylset returnList session_id $value
            }
            serverusername {
                keylset returnList tcl_proxy_username $value
            }
            serverversion {
                keylset returnList server_version $value
            }
            port {
                keylset returnList port $value
            }
            rdp {
                keylset returnList rdp $truth($value)
            }
            state {
                keylset returnList state $value
            }
            starttime {
                keylset returnList start_time $value
            }
            closeServerOnDisconnect {
                keylset returnList close_server_on_disconnect $truth($value)
            }
            usingTclProxy {
                keylset returnList using_tcl_proxy $value
            }
        }            
    }
    
    set chassisList [ixNetworkNodeGetList [ixNet getRoot]availableHardware chassis -all]
    foreach chassis $chassisList {
        set hostname  [ixNet getA $chassis -hostname]
        keylset returnList chassis.$hostname.hostname                $hostname
        keylset returnList chassis.$hostname.ip                          [ixNet getA $chassis -ip]
        keylset returnList chassis.$hostname.chassis_protocols_version   [ixNet getA  $chassis -protocolBuildNumber]
        keylset returnList chassis.$hostname.chassis_type                [ixNet getA $chassis -chassisType]
        keylset returnList chassis.$hostname.chassis_version             [ixNet getA $chassis -chassisVersion]
        keylset returnList chassis.$hostname.is_master_chassis           [expr [ixNet getA $chassis -isMaster] ?1:0]
        if {[keylget returnList chassis.$hostname.is_master_chassis]} {
            keylset returnList chassis.$hostname.chain_type                  [ixNet getA $chassis -chainTopology]
            if { [keylget returnList chassis.$hostname.chain_type] == "daisy" } {
                keylset returnList chassis.$hostname.chassis_chain.sequence_id   [ixNet getA $chassis -sequenceId]
            }
        } else {
            keylset returnList chassis.$hostname.chassis_chain.master_device [ixNet getA $chassis -masterChassis]
            keylset returnList chassis.$hostname.chassis_chain.sequence_id    [ixNet getA $chassis -sequenceId]
            keylset returnList chassis.$hostname.chassis_chain.cable_length  [expr int([ixNet getA $chassis -cableLength])]
        }
    }
    
    keylset returnList client_version [package present IxTclNetwork]
    keylset returnList username [ixNet getA [ixNet getRoot]/globals -username]
    keylset returnList hostname [ixNet getA [ixNet getRoot]/eventScheduler -hostName]
    set current_licensingServers [ixNet getA [ixNet getRoot]/globals/licensing -licensingServers]
    set current_mode [ixNet getA [ixNet getRoot]/globals/licensing -mode]
    if {$current_mode == "subscription"} {
            set current_mode "subscription_[ixNet getA [ixNet getRoot]/globals/licensing -tier]"
    }
    debug "Using license type ${current_mode} from following servers: $current_licensingServers."
    keylset returnList license.server $current_licensingServers
    keylset returnList license.type $current_mode
    return $returnList
}


