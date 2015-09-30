proc ::ixia::validate_capture_ports {port_handle_list} {
    
    ##########################################
    # Check if all ports are in mode capture
    ##########################################
    
    keylset returnList status $::SUCCESS
    
    set vport_list ""
    set invalid_ports ""
    set vport_handle_list ""
    foreach port_h $port_handle_list {
        
        set retCode [ixNetworkGetPortObjref $port_h]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the port \
                    object reference associated to the $port_h port handle -\
                    [keylget retCode log]."
            return $returnList
        }
        set vport_objref [keylget retCode vport_objref]
        lappend vport_handle_list $vport_objref
        
        switch -- [ixNetworkGetAttr $vport_objref -rxMode] {
            capture -
            captureAndMeasure {
            }
            default {
                lappend invalid_ports $port_h
            }
        }
    }
    
    if {[llength $invalid_ports] > 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "The following ports are not in capture mode. Please\
                configure them using interface_config procedure before calling\
                this procedure: $invalid_ports"
        return $returnList
    }
    
    keylset returnList vport_handle_list $vport_handle_list
    return $returnList
}

# Procedure that returns pattern, pattern_offset, pattern_mask, pattern_offset_type for a predefined offset
# this procedure was built to ensure backwards compatibility with ixos capture filterPallette matchType attribute
proc ::ixia::get_pattern_settings {predefined_pattern} {
    
    # the value of the array is $pattern_offset,$pattern,$pattern_mask,$pattern_bit_length
    array set patterns_array {
        GfpDataFcsNullExtEthernet         4,1001,0000
        IpCiscoHdlc                       2,0800,0000
        GfpDataFcsLinearExtEthernet       4,0001,0000
        GfpDataFcsLinearExtPpp            4,0002,0000
        GfpDataFcsNullExtPpp              4,2101,0000
        GfpDataNoFcsLinearExtEthernet     4,1101,0000
        GfpDataNoFcsLinearExtPpp          4,1102,0000
        GfpDataNoFcsNullExtEthernet       4,1001,0000
        GfpDataNoFcsNullExtPpp            4,1002,0000
        GfpMgmtFcsLinearExtEthernet       4,2001,0000
        GfpMgmtFcsLinearExtPpp            4,2002,0000
        GfpMgmtFcsNullExtEthernet         4,0101,0000
        GfpMgmtFcsNullExtPpp              4,0102,0000
        GfpMgmtNoFcsLinearExtEthernet     4,3101,0000
        GfpMgmtNoFcsLinearExtPpp          4,3102,0000
        GfpMgmtNoFcsNullExtEthernet       4,3001,0000
        GfpMgmtNoFcsNullExtPpp            4,3002,0000
        IpPpp                             2,0021,0000
        RprControlPacket                  1,10,CF
        RprDataPacket                     1,30,CF
        RprFairnessEligibility0           1,00,BF
        RprFairnessEligibility1           1,40,BF
        RprFairnessPacket                 1,20,CF
        RprIdlePacket                     1,00,CF
        RprParityBit0                     1,00,FE
        RprParityBit1                     1,01,FE
        RprRingId0                        1,00,7F
        RprRingId1                        1,80,7F
        RprServiceClassA0                 1,0C,F3
        RprServiceClassA1                 1,08,F3
        RprServiceClassB                  1,04,F3
        RprServiceClassC                  1,00,F3
        RprWrapEligibility0               1,00,FD
        RprWrapEligibility1               1,02,FD
        SrpAllControlMessages10x          1,40,9F
        SrpControlMessageBufferForHost101 1,50,8F
        SrpControlMessagePassToHost100    1,40,8F
        SrpControlUsageOrPacketData1xx    1,40,BF
        SrpDiscoveryFrame                 17,01,00
        SrpInnerRing                      1,80,7F
        SrpIpsFrame                       17,02,00
        SrpModeAtmCell011                 1,30,8F
        SrpModeReserved000                1,00,8F
        SrpModeReserved001                1,10,8F
        SrpModeReserved010                1,20,8F
        SrpOuterRing                      1,00,7F
        SrpPacketData111                  1,70,8F
        SrpParityEven                     1,00,FE
        SrpParityOdd                      1,01,FE
        SrpPriority0                      1,00,F1
        SrpPriority1                      1,02,F1
        SrpPriority2                      1,04,F1
        SrpPriority3                      1,06,F1
        SrpPriority4                      1,08,F1
        SrpPriority5                      1,0A,F1
        SrpPriority6                      1,0C,F1
        SrpPriority7                      1,0E,F1
        SrpUsageMessage110                1,60,8F
        SrpUsageMessageOrPacketData11x    1,60,9F
        IpDAPos                           20,DEEDEFFE,00000000
        IpSADAPos                         16,DEEDEFFEACCA0000,0000000000000000
        IpSAPos                           16,DEEDEFFE,00000000
        TcpDestPortIPPos                  26,DEEDEFFEACCA,0000
        TcpSourcePortIPPos                24,DEEDEFFEACCA,0000
        UdpDestPortIPPos                  26,DEEDEFFEACCA,0000
        UdpSourcePortIPPos                24,DEEDEFFEACCA,0000
        Ip8023Snap                        14,AAAA030000000800,0000000000000000
        IpDA8023Snap                      38,DEEDEFFEACCA,000000000000
        IpDAEthernetII                    30,DEEDEFFE,00000000
        IpEthernetII                      12,0800,0000
        IpOverIpv6IpDA8023Snap            78,DEEDEFFE,00000000
        IpOverIpv6IpDAEthernetII          70,DEEDEFFE,00000000
        IpOverIpv6IpDAPos                 60,DEEDEFFE,00000000
        IpOverIpv6IpSA8023Snap            74,DEEDEFFE,00000000
        IpOverIpv6IpSAEthernetII          66,DEEDEFFE,00000000
        IpOverIpv6IpSAPos                 56,DEEDEFFE,00000000
        IpSA8023Snap                      34,DEEDEFFEACCA,000000000000
        IpSADA8023Snap                    34,DEEDEFFEACCA,000000000000
        IpSADAEthernetII                  26,DEEDEFFEACCA0000,0000000000000000
        IpSAEthernetII                    26,DEEDEFFE,00000000
        IpV6DA8023Snap                    46,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        IpV6DAEthernetII                  38,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        IpV6DAPos                         28,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        IpV6SA8023Snap                    30,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        IpV6SAEthernetII                  22,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        IpV6SAPos                         12,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        Ipv6CiscoHdlc                     2,86DD,0000
        Ipv6IpTcpDestPort8023Snap         84,DEEDEFFEACCA,0000
        Ipv6IpTcpDestPortEthernetII       76,DEEDEFFEACCA,0000
        Ipv6IpTcpDestPortPos              66,DEEDEFFEACCA,0000
        Ipv6IpTcpSourcePort8023Snap       82,DEEDEFFEACCA,0000
        Ipv6IpTcpSourcePortEthernetII     74,DEEDEFFEACCA,0000
        Ipv6IpTcpSourcePortPos            64,DEEDEFFEACCA,0000
        Ipv6IpUdpDestPort8023Snap         84,DEEDEFFEACCA,0000
        Ipv6IpUdpDestPortEthernetII       76,DEEDEFFEACCA,0000
        Ipv6IpUdpDestPortPos              66,DEEDEFFEACCA,0000
        Ipv6IpUdpSourcePort8023Snap       82,DEEDEFFEACCA,0000
        Ipv6IpUdpSourcePortEthernetII     74,DEEDEFFEACCA,0000
        Ipv6IpUdpSourcePortPos            64,DEEDEFFEACCA,0000
        Ipv6OverIpIpv6DA8023Snap          66,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        Ipv6OverIpIpv6DAEthernetII        58,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        Ipv6OverIpIpv6DAPos               48,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        Ipv6OverIpIpv6SA8023Snap          50,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        Ipv6OverIpIpv6SAEthernetII        42,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        Ipv6OverIpIpv6SAPos               32,DEEDEFFEACCA00000000000000000000,00000000000000000000000000000000
        Ipv6Ppp                           2,0057,0000
        Ipv6TcpDestPort8023Snap           64,DEEDEFFEACCA,0000
        Ipv6TcpDestPortEthernetII         56,DEEDEFFEACCA,0000
        Ipv6TcpDestPortPos                46,DEEDEFFEACCA,0000
        Ipv6TcpSourcePort8023Snap         62,DEEDEFFEACCA,0000
        Ipv6TcpSourcePortEthernetII       54,DEEDEFFEACCA,0000
        Ipv6TcpSourcePortPos              44,DEEDEFFEACCA,0000
        Ipv6UdpDestPort8023Snap           64,DEEDEFFEACCA,0000
        Ipv6UdpDestPortEthernetII         56,DEEDEFFEACCA,0000
        Ipv6UdpDestPortPos                46,DEEDEFFEACCA,0000
        Ipv6UdpSourcePort8023Snap         62,DEEDEFFEACCA,0000
        Ipv6UdpSourcePortEthernetII       54,DEEDEFFEACCA,0000
        Ipv6UdpSourcePortPos              44,DEEDEFFEACCA,0000
        TcpDestPortIP8023Snap             44,DEEDEFFEACCA,0000
        TcpDestPortIPEthernetII           36,DEEDEFFEACCA,0000
        TcpSourcePortIP8023Snap           42,DEEDEFFEACCA,0000
        TcpSourcePortIPEthernetII         34,DEEDEFFEACCA,0000
        UdpDestPortIP8023Snap             44,DEEDEFFEACCA,0000
        UdpDestPortIPEthernetII           36,DEEDEFFEACCA,0000
        UdpSourcePortIP8023Snap           42,DEEDEFFEACCA,0000
        UdpSourcePortIPEthernetII         34,DEEDEFFEACCA,0000
        User                              12,DEEDEFFEACCA,000000000000
        Vlan                              12,8100,0000
    }
    
    if {![info exists patterns_array($predefined_pattern)]} {
        set pattern_settings "TBD,TBD,TBD"
    } else {
        set pattern_settings $patterns_array($predefined_pattern)
    }
    
    set pattern_settings [split $pattern_settings ,]
    
    keylset returnList pattern_offset [lindex $pattern_settings 0]
    keylset returnList pattern        [lindex $pattern_settings 1]
    keylset returnList pattern_mask   [lindex $pattern_settings 2]
    
    return $returnList
}


proc ::ixia::wait_capture_vports_ready {vport_list} {
    
    
    set retry_count 10
    set retry_interval 500; # milliseconds
    for {set attempt 0} {$attempt < $retry_count} {incr attempt} {
        set vports_not_ready ""
        foreach vport $vport_list {
            
            if {![catch {ixNetworkGetAttr ${vport}/capture -hardwareEnabled} val] && $val == "true"} {
                catch {ixNetworkGetAttr ${vport}/capture -dataCaptureState} state
                if {$state == "notReady"} {
                    lappend vports_not_ready $vport
                    continue 
                }
            }
            
            if {![catch {ixNetworkGetAttr ${vport}/capture -softwareEnabled} val] && $val == "true"} {
                catch {ixNetworkGetAttr ${vport}/capture -controlCaptureState} state
                if {$state == "notReady"} {
                    lappend vports_not_ready $vport
                    continue 
                }
            }
        }
        
        if {[llength $vports_not_ready] == 0} {
            break
        }
        
        after $retry_interval
    }
    
    if {[llength $vports_not_ready] > 0} {
        set ports_not_ready ""
        foreach vport [lsort -unique $vports_not_ready] {
            
            set ret_code [ixNetworkGetPortFromObj $vport]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Failed to extract port handle from\
                        $vport. [keylget ret_code log]"
                return $returnList
            } 
            
            lappend ports_not_ready [keylget ret_code port_handle]
        }
        
        keylset returnList status $::FAILURE
        keylset returnList log "The following ports were not ready to capture after 5 seconds: $ports_not_ready.\
                Possible cause: capture was not stopped for these ports"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}
