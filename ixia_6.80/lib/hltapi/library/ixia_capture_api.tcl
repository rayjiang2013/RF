##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_capture_api.tcl
#
# Purpose:
#    A script development library containing capture APIs for
#    packet capturing and statistics with the Ixia chassis.
#
# Author:
#    Mircea Hasegan
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#    - packet_config_buffers
#    - packet_config_filter
#    - packet_config_triggers
#    - packet_control
#    - packet_stats
#
# Requirements:
#    parseddashedargs.tcl , a library containing the proceDescr and
#    parsedashedargds.tcl
#
# Variables:
#    To be added
#
# Keywords:
#    To be defined
#
# Category:
#    To be defined
#
################################################################################
#                                                                              #
#                                LEGAL  NOTICE:                                #
#                                ==============                                #
# The following code and documentation (hereinafter "the script") is an        #
# example script for demonstration purposes only.                              #
# The script is not a standard commercial product offered by Ixia and have     #
# been developed and is being provided for use only as indicated herein. The   #
# script [and all modifications, enhancements and updates thereto (whether     #
# made by Ixia and/or by the user and/or by a third party)] shall at all times #
# remain the property of Ixia.                                                 #
#                                                                              #
# Ixia does not warrant (i) that the functions contained in the script will    #
# meet the user's requirements or (ii) that the script will be without         #
# omissions or error-free.                                                     #
# THE SCRIPT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, AND IXIA        #
# DISCLAIMS ALL WARRANTIES, EXPRESS, IMPLIED, STATUTORY OR OTHERWISE,          #
# INCLUDING BUT NOT LIMITED TO ANY WARRANTY OF MERCHANTABILITY AND FITNESS FOR #
# A PARTICULAR PURPOSE OR OF NON-INFRINGEMENT.                                 #
# THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SCRIPT  IS WITH THE #
# USER.                                                                        #
# IN NO EVENT SHALL IXIA BE LIABLE FOR ANY DAMAGES RESULTING FROM OR ARISING   #
# OUT OF THE USE OF, OR THE INABILITY TO USE THE SCRIPT OR ANY PART THEREOF,   #
# INCLUDING BUT NOT LIMITED TO ANY LOST PROFITS, LOST BUSINESS, LOST OR        #
# DAMAGED DATA OR SOFTWARE OR ANY INDIRECT, INCIDENTAL, PUNITIVE OR            #
# CONSEQUENTIAL DAMAGES, EVEN IF IXIA HAS BEEN ADVISED OF THE POSSIBILITY OF   #
# SUCH DAMAGES IN ADVANCE.                                                     #
# Ixia will not be required to provide any software maintenance or support     #
# services of any kind (e.g., any error corrections) in connection with the    #
# script or any part thereof. The user acknowledges that although Ixia may     #
# from time to time and in its sole discretion provide maintenance or support  #
# services for the script, any such services are subject to the warranty and   #
# damages limitations set forth herein and will not obligate Ixia to provide   #
# any additional maintenance or support services.                              #
#                                                                              #
################################################################################


proc ::ixia::packet_config_buffers { args } {
    
    variable new_ixnetwork_api
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args
    ::ixia::logHltapiCommand $procName $args
    
    set man_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    set opt_args {
        -action                 CHOICES wrap stop
        -after_trigger_filter   CHOICES all filter condition_filter
        -before_trigger_filter  CHOICES all filter none
        -capture_mode           CHOICES continuous	trigger
        -continuous_filter      CHOICES all filter
        -small_packet_capture   CHOICES 0 1
        -slice_size             RANGE   0-8192
        -trigger_position       ANY
        -data_plane_capture_enable       CHOICES 0 1
                                         DEFAULT 1
        -control_plane_capture_enable    CHOICES 0 1
                                         DEFAULT 1
        -control_plane_filter_pcap       ANY
        -control_plane_trigger_pcap      ANY
        -no_write
      }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_packet_config_buffers $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }

    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args \
                    $opt_args -mandatory_args $man_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    set option_list1 [list                                  \
            action                fullAction                \
            after_trigger_filter  afterTriggerFilter        \
            before_trigger_filter beforeTriggerFilter       \
            capture_mode          captureMode               \
            continuous_filter     continuousFilter          \
            ]
    
    set option_list2 [list                                  \
            small_packet_capture  enableSmallPacketCapture  \
            slice_size            sliceSize                 \
            trigger_position      triggerPosition           \
            ]
            
    array set fullAction [list          \
            stop               0        \
            wrap               1        \
            ]
    
    array set afterTriggerFilter [list  \
            all                0        \
            filter             1        \
            condition_filter   2        \
            ]
    
    array set beforeTriggerFilter [list \
            all                0        \
            none               1        \
            filter             2        \
            ]
    
    array set captureMode [list         \
            continuous         0        \
            trigger            1        \
            ]
    
    array set continuousFilter [list   \
            all                0       \
            filter             1       \
            ]
    
    # Checking if everything is in it's place
    
    if {[info exists capture_mode] && $capture_mode == "continuous"} {
        if {([info exists after_trigger_filter]) || \
                    ([info exists before_trigger_filter]) || \
                    ([info exists trigger_position])} {
            keylset returnList status $::FAILURE
            keylset returnList log "The after_trigger_filter\
                    , before_trigger_filter and trigger_position\
                    parameters can be set only when capture_mode\
                    is trigger."
            return $returnList
        }
        
        
    } else  {
        if {[info exists continuous_filter]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The continuous_filter\
                    can be set only when capture mode is continuous."
            return $returnList
        }
        if {([info exists trigger_position]) && \
                    ((![info exists before_trigger_filter]) || \
                    ($before_trigger_filter == "none"))} {
            keylset returnList status $::FAILURE
            keylset returnList log "The trigger_position can \
                    be set only when before_trigger_filter is \
                    enabled."
            return $returnList
        }
    }
    
    # Done checking for missconfig's
    
    ::ixia::addPortToWrite $port_handle
    
    foreach port_h $port_handle {
        foreach {chassis card port} [split $port_h /] {}
        
        if {([info exists small_packet_capture]) && \
                ($small_packet_capture == 1)} {
                if {![card get $chassis $card]} {
                    set card_type [card cget -type]
                    if {($card_type != 8) && ($card_type != 75) && \
                            ($card_type != 77)} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The small_packet_capture \
                                parameter is available for OC12 cards only.
                                Card $card is [card cget -typeName]"
                        return $returnList
                    }
                } else  {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The card $card does not exist"
                    return $returnList
                }
        }

        if {[capture get $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "No connection chassis, or \
                    invalid port number provided."
            return $returnList
        }
        debug "capture get $chassis $card $port"
        
        capture setDefault
        debug "capture setDefault"        
        
        foreach {hlt_param ix_param} $option_list1 {
            if {[info exists $hlt_param]} {
                if {[catch  {capture config -$ix_param [set \
                                ${ix_param}([set $hlt_param])]} retError]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log $retError
                    return $returnList
                }
                debug "capture config -$ix_param [set \
                        ${ix_param}([set $hlt_param])]"
            }
        }

        foreach {hlt_param ix_param} $option_list2 {
            if {[info exists $hlt_param]} {
                if {[catch  {capture config -$ix_param [set $hlt_param]}\
                            retError]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log $retError
                    return $returnList
                }
                debug "capture config -$ix_param \
                        [set $hlt_param]"
            }
        }
        
        if {[capture set $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "capture set failure. \
                    Possible causes are: no connection to chassis\
                    or invalid port number provided or the port \
                    is being used by another user or configured \
                    parameters are not valid for this setting."
            return $returnList
        }
        debug "capture set $chassis $card $port"
    }
    
    if {![info exists no_write]} {
        set retCode [::ixia::writePortListConfig "no"]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
        debug "::ixia::writePortListConfig \"no\""
    }
    
    keylset returnList port_handle $port_handle
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::packet_config_filter { args } {
    
	variable new_ixnetwork_api
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args
    ::ixia::logHltapiCommand $procName $args
    
    set man_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    set opt_args {
        -mode                   CHOICES create addAtmFilter
                                DEFAULT create        
        -gfp_bad_fcs_error      CHOICES 0 1
        -gfp_eHec_error         CHOICES 0 1
        -gfp_payload_crc        CHOICES 0 1
        -gfp_tHec_error         CHOICES 0 1
        -DA1                    ANY
        -DA2                    ANY
        -DA_mask1               ANY
        -DA_mask2               ANY
        -gfp_error_condition    CHOICES 0 1
        -match_type1            ANY
        -match_type2            ANY
        -pattern1               HEX
        -pattern2               HEX
        -pattern_atm            HEX
        -pattern_mask1          HEX
        -pattern_mask2          HEX
        -pattern_mask_atm       HEX
        -pattern_offset1        NUMERIC
        -pattern_offset2        NUMERIC
        -pattern_offset_atm     NUMERIC
        -pattern_offset_type1   CHOICES startOfFrame startOfIp startOfProtocol startOfSonet
        -pattern_offset_type2   CHOICES startOfFrame startOfIp startOfProtocol startOfSonet
        -SA1                    ANY
        -SA2                    ANY
        -SA_mask1               ANY
        -SA_mask2               ANY
        -vpi                    RANGE   1-4096
        -vpi_count              RANGE   1-4096
        -vpi_step               RANGE   1-4096
        -vci                    RANGE   1-65535
        -vci_count              RANGE   1-65535
        -vci_step               RANGE   1-65535
        -no_write
    }
    
	if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_packet_config_filter $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }
	
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args \
                    $opt_args -mandatory_args $man_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    set match_type_list [list  IpEthernetII                         \
             Ip8023Snap  Vlan  User  IpPpp  IpCiscoHdlc             \
             IpSAEthernetII  IpDAEthernetII  IpSADAEthernetII       \
             IpSA8023Snap  IpDA8023Snap  IpSADA8023Snap             \
             IpSAPos  IpDAPos IpSADAPos  TcpSourcePortIPEthernetII  \
             TcpDestPortIPEthernetII  UdpSourcePortIPEthernetII     \
             UdpDestPortIPEthernetII  TcpSourcePortIP8023Snap       \
             TcpDestPortIP8023Snap  UdpSourcePortIP8023Snap         \
             UdpDestPortIP8023Snap  TcpSourcePortIPPos              \
             TcpDestPortIPPos  UdpSourcePortIPPos                   \
             UdpDestPortIPPos  SrpModeReserved000                   \
             SrpModeReserved001  SrpModeReserved010                 \
             SrpModeAtmCell011  SrpControlMessagePassToHost100      \
             SrpControlMessageBufferForHost101  SrpUsageMessage110  \
             SrpPacketData111  SrpAllControlMessages10x             \
             SrpUsageMessageOrPacketData11x                         \
             SrpControlUsageOrPacketData1xx  SrpInnerRing           \
             SrpOuterRing  SrpPriority0  SrpPriority1               \
             SrpPriority2  SrpPriority3  SrpPriority4               \
             SrpPriority5  SrpPriority6  SrpPriority7               \
             SrpParityOdd  SrpParityEven  SrpDiscoveryFrame         \
             SrpIpsFrame  RprRingId0  RprRingId1                    \
             RprFairnessEligibility0  RprFairnessEligibility1       \
             RprIdlePacket  RprControlPacket  RprFairnessPacket     \
             RprDataPacket  RprServiceClassC  RprServiceClassB      \
             RprServiceClassA1  RprServiceClassA0                   \
             RprWrapEligibility0  RprWrapEligibility1               \
             RprParityBit0  RprParityBit1  IpV6SAEthernetII         \
             IpV6DAEthernetII  IpV6SA8023Snap  IpV6DA8023Snap       \
             IpV6SAPos  IpV6DAPos  Ipv6TcpSourcePortEthernetII      \
             Ipv6TcpDestPortEthernetII  Ipv6UdpSourcePortEthernetII \
             Ipv6UdpDestPortEthernetII  Ipv6TcpSourcePort8023Snap   \
             Ipv6TcpDestPort8023Snap  Ipv6UdpSourcePort8023Snap     \
             Ipv6UdpDestPort8023Snap  Ipv6TcpSourcePortPos          \
             Ipv6TcpDestPortPos  Ipv6UdpSourcePortPos               \
             Ipv6UdpDestPortPos  Ipv6IpTcpSourcePortEthernetII      \
             Ipv6IpTcpDestPortEthernetII                            \
             Ipv6IpUdpSourcePortEthernetII                          \
             Ipv6IpUdpDestPortEthernetII                            \
             Ipv6IpTcpSourcePort8023Snap  Ipv6IpTcpDestPort8023Snap \
             Ipv6IpUdpSourcePort8023Snap  Ipv6IpUdpDestPort8023Snap \
             Ipv6IpTcpSourcePortPos  Ipv6IpTcpDestPortPos           \
             Ipv6IpUdpSourcePortPos  Ipv6IpUdpDestPortPos           \
             IpOverIpv6IpSAEthernetII  IpOverIpv6IpDAEthernetII     \
             IpOverIpv6IpSA8023Snap  IpOverIpv6IpDA8023Snap         \
             IpOverIpv6IpSAPos  IpOverIpv6IpDAPos                   \
             Ipv6OverIpIpv6SAEthernetII  Ipv6OverIpIpv6DAEthernetII \
             Ipv6OverIpIpv6SA8023Snap  Ipv6OverIpIpv6DA8023Snap     \
             Ipv6OverIpIpv6SAPos  Ipv6OverIpIpv6DAPos  Ipv6Ppp      \
             Ipv6CiscoHdlc  GfpDataFcsNullExtEthernet               \
             GfpDataNoFcsNullExtEthernet GfpDataFcsLinearExtEthernet\
             GfpDataNoFcsLinearExtEthernet                          \
             GfpMgmtFcsNullExtEthernet                              \
             GfpMgmtNoFcsNullExtEthernet                            \
             GfpMgmtFcsLinearExtEthernet                            \
             GfpMgmtNoFcsLinearExtEthernet                          \
             GfpDataFcsNullExtPpp  GfpDataNoFcsNullExtPpp           \
             GfpDataFcsLinearExtPpp  GfpDataNoFcsLinearExtPpp       \
             GfpMgmtFcsNullExtPpp  GfpMgmtNoFcsNullExtPpp           \
             GfpMgmtFcsLinearExtPpp  GfpMgmtNoFcsLinearExtPpp       \
            ]
        
    set option_list [list                                        \
             gfp_bad_fcs_error      enableGfpBadFcsError         \
             gfp_eHec_error         enableGfpeHecError           \
             gfp_payload_crc        enableGfpPayloadCrcError     \
             gfp_tHec_error         enableGfptHecError           \
             DA1                    DA1                          \
             DA2                    DA2                          \
             DA_mask1               DAMask1                      \
             DA_mask2               DAMask2                      \
             gfp_error_condition    gfpErrorCondition            \
             _match_type1           matchType1                   \
             _match_type2           matchType2                   \
             pattern1               pattern1                     \
             pattern2               pattern2                     \
             pattern_mask1          patternMask1                 \
             pattern_mask2          patternMask2                 \
             pattern_offset1        patternOffset1               \
             pattern_offset2        patternOffset2               \
             pattern_offset_type1   patternOffsetType1           \
             pattern_offset_type2   patternOffsetType2           \
             SA1                    SA1                          \
             SA2                    SA2                          \
             SA_mask1               SAMask1                      \
             SA_mask2               SAMask2                      \
         ]
 
    ::ixia::addPortToWrite $port_handle
    
    if {[info exists pattern_atm]} {
        set atm_status [::ixia::add_atm_filter $args]
        if {[keylget atm_status status] != $::SUCCESS} {
            return $atm_status
        }
        keylset returnList handle [keylget atm_status handle]
        if {$mode == "addAtmFilter"} {
            keylset returnList status $::SUCCESS
            if {![info exists no_write]} {
                set retCode [::ixia::writePortListConfig "no"]
                if {[keylget retCode status] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            ::ixia::writePortListConfig failed. \
                            [keylget retCode log]"
                    return $returnList
                }
                debug "::ixia::writePortListConfig \"no\""
            }
            return $returnList
        }
    }
    foreach port_h $port_handle {
        foreach {chassis card port} [split $port_h /] {}
        
        # If the port mode is set to ATM then no match types are supported 
        if {[info exists match_type1] || [info exists match_type2]} {
            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                keylset returnList status $::FAILURE
                keylset returnList log "match_type parameter is not supported \
                        when port mode is ATM."
                return $returnList
            }
        }
        
        if {[info exists match_type1]} {
            if {[lsearch $match_type_list $match_type1] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "match_type1 \
                        \"$match_type1\" is not valid."
                return $returnList
            } else  {
                set _match_type1 [lsearch $match_type_list $match_type1]
            }
            
        }
        
        if {[info exists match_type2]} {
            if {[lsearch $match_type_list $match_type2] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "match_type2 \
                        \"$match_type2\" is not valid."
                return $returnList
            } else  {
                set _match_type2 [lsearch $match_type_list $match_type2]
            }
        }
        
        if {[filterPallette get $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "filterPallette get $chassis \
                    $card $port returned an error. Possible \
                    causes are\n No connection to chassis or\n \
                    Invalid port number"
            return $returnList
        }
        
        debug "filterPallette get $chassis $card $port"
        
        if {[catch  {filterPallette setDefault} retError]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error: $retError"
            return $returnList
        }
        
        debug "filterPallette setDefault"
        
        foreach {hlt_param ix_param} $option_list {
            if {[info exists $hlt_param]} {
                switch -- $hlt_param {
                    DA1 -
                    DA2 -
                    SA1 -
                    SA2 -
                    DA_mask1 -
                    DA_mask2 -
                    SA_mask1 -
                    SA_mask2 {
                        set $hlt_param [::ixia::convertToIxiaMac \
                                [set $hlt_param]]
                    }
                    pattern_offset_type1 -
                    pattern_offset_type2 {
                        if {![port isValidFeature $chassis $card $port \
                                portFeaturePatternOffsetFlexible]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "The port $port does not \
                                    support the portFeaturePatternOffsetFlexible\
                                    feature. Please do not use the \
                                    pattern_offset_type parameter with this port."
                            return $returnList
                        }
                    }
                    _match_type1 {
                        if {$_match_type1 > 111} {
                            if {![port isValidFeature $chassis $card \
                                    $port $::portFeatureGfp]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Error! Port \
                            $chassis/$card/$port does not support portFeatureGfp."
                            return $returnList
                            }
                        } elseif {($_match_type1 > 51) && ($_match_type1 < 68)} {
                            if {![port isValidFeature $chassis $card \
                                    $port $::portFeatureRpr]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Error! Port \
                            $chassis/$card/$port does not support portFeatureRpr."
                            return $returnList
                            }
                        } elseif {($_match_type1 > 26) && ($_match_type1 < 52)} {
                            if {![port isValidFeature $chassis $card \
                                    $port $::portFeatureSrp]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Error! Port \
                            $chassis/$card/$port does not support portFeatureSrp."
                            return $returnList
                            }
                        }
                    }
                    _match_type2 {
                        if {$_match_type2 > 111} {
                            if {![port isValidFeature $chassis $card \
                                    $port $::portFeatureGfp]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Error! Port \
                            $chassis/$card/$port does not support portFeatureGfp."
                            return $returnList
                            }
                        } elseif {($_match_type2 > 51) && ($_match_type2 < 68)} {
                            if {![port isValidFeature $chassis $card \
                                    $port $::portFeatureRpr]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Error! Port \
                            $chassis/$card/$port does not support portFeatureRpr."
                            return $returnList
                            }
                        } elseif {($_match_type2 > 26) && ($_match_type2 < 52)} {
                            if {![port isValidFeature $chassis $card \
                                    $port $::portFeatureSrp]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Error! Port \
                            $chassis/$card/$port does not support portFeatureSrp."
                            return $returnList
                            }
                        }                        
                    }
                }
                if {[catch  {filterPallette config -$ix_param [set $hlt_param]}\
                            retError]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error: $retError"
                    return $returnList
                }
                debug "filterPallette config -$ix_param [set $hlt_param]"
            }
        }
        
        if {[filterPallette set $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "filterPallette set $chassis \
                    $card $port returned an error. Possible \
                    causes are\n No connection to chassis or\n\
                    Invalid port number or\n The port is being used by another\
                    user or\n The configured parameters are not valid for this \
                    port\n or \"$::ixErrorInfo\""
            return $returnList
        }
        
        debug "filterPallette set $chassis $card $port"
    }
    
    if {![info exists no_write]} {
        set retCode [::ixia::writePortListConfig "no"]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
        debug "::ixia::writePortListConfig \"no\""
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::packet_config_triggers { args } {
    
	variable new_ixnetwork_api
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args
    ::ixia::logHltapiCommand $procName $args
        
    set opt_args {
        -port_handle                        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -mode                               CHOICES create addAtmTrigger
                                            DEFAULT create
        -handle                             ANY
        -async_trigger1                     CHOICES 0 1
        -async_trigger1_SA                  CHOICES any SA1 notSA1 SA2 notSA2
        -async_trigger1_DA                  CHOICES any DA1 notDA1 DA2 notDA2
        -async_trigger1_error               ANY
        -async_trigger1_framesize           CHOICES 0 1 jumbo oversized undersized
        -async_trigger1_framesize_from      NUMERIC
        -async_trigger1_framesize_to        NUMERIC
        -async_trigger1_pattern             CHOICES any pattern1 notPattern1
                                            CHOICES pattern2 notPattern2
                                            CHOICES pattern1and2
        -async_trigger2                     CHOICES 0 1
        -async_trigger2_SA                  CHOICES any SA1 notSA1 SA2 notSA2
        -async_trigger2_DA                  CHOICES any DA1 notDA1 DA2 notDA2
        -async_trigger2_error               ANY
        -async_trigger2_framesize           CHOICES 0 1 jumbo oversized undersized
        -async_trigger2_framesize_from      NUMERIC
        -async_trigger2_framesize_to        NUMERIC
        -async_trigger2_pattern             CHOICES any pattern1 notPattern1
                                            CHOICES pattern2 notPattern2
                                            CHOICES pattern1and2
        -capture_filter                     CHOICES 0 1      
        -capture_filter_DA                  CHOICES any DA1 notDA1 DA2 notDA2
        -capture_filter_error               ANY
        -capture_filter_expression_string   ANY
        -capture_filter_framesize           CHOICES 0 1
        -capture_filter_framesize_from      NUMERIC
        -capture_filter_framesize_to        NUMERIC
        -capture_filter_pattern             CHOICES any pattern1 notPattern1
                                            CHOICES pattern2 notPattern2
                                            CHOICES pattern1and2 patternAtm
        -capture_filter_SA                  CHOICES any SA1 notSA1 SA2 notSA2      
        
        
        -capture_trigger                    CHOICES 0 1
        -capture_trigger_DA                 CHOICES any DA1 notDA1 DA2 notDA2
        -capture_trigger_error              ANY
        -capture_trigger_expression_string  ANY
        -capture_trigger_framesize          CHOICES 0 1
        -capture_trigger_framesize_from     NUMERIC
        -capture_trigger_framesize_to       NUMERIC
        -capture_trigger_pattern            CHOICES any pattern1 notPattern1
                                            CHOICES pattern2 notPattern2
                                            CHOICES pattern1and2 patternAtm
        -capture_trigger_SA                 CHOICES any SA1 notSA1 SA2 notSA2
        
        -uds1                               CHOICES 0 1
        -uds1_SA                            CHOICES any SA1 notSA1 SA2 notSA2
        -uds1_DA                            CHOICES any DA1 notDA1 DA2 notDA2
        -uds1_error                         ANY
        -uds1_framesize                     CHOICES 0 1 jumbo oversized undersized
        -uds1_framesize_from                NUMERIC
        -uds1_framesize_to                  NUMERIC
        -uds1_pattern                       CHOICES any pattern1 notPattern1
                                            CHOICES pattern2 notPattern2
                                            CHOICES pattern1and2 patternAtm
        -uds2                               CHOICES 0 1
        -uds2_SA                            CHOICES any SA1 notSA1 SA2 notSA2
        -uds2_DA                            CHOICES any DA1 notDA1 DA2 notDA2
        -uds2_error                         ANY
        -uds2_framesize                     CHOICES 0 1 jumbo oversized undersized
        -uds2_framesize_from                NUMERIC
        -uds2_framesize_to                  NUMERIC
        -uds2_pattern                       CHOICES any pattern1 notPattern1
                                            CHOICES pattern2 notPattern2
                                            CHOICES pattern1and2 patternAtm
        -no_write
    }
    
	if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_packet_config_triggers $args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }
	
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args \
                    $opt_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    set option_list [list                    \
            _DA              DA              \
            _error           Error           \
            _framesize       FrameSizeEnable \
            _framesize_from  FrameSizeFrom   \
            _framesize_to    FrameSizeTo     \
            _pattern         Pattern         \
            _SA              SA              \
            ]
    
    set mode_list [list                     \
            async_trigger1  asyncTrigger1   \
            async_trigger2  asyncTrigger2   \
            capture_filter  captureFilter   \
            capture_trigger captureTrigger  \
            uds1            userDefinedStat1\
            uds2            userDefinedStat2\
            ]
    
    array set value_array [list                                 \
            any          0                                 0 0  \
            SA1          1    DA1    1    pattern1     1   1 1  \
            notSA1       2    notDA1 2    notPattern1  2        \
            SA2          3    DA2    3    pattern2     3        \
            notSA2       4    notDA2 4    notPattern2  4        \
            pattern1and2 5
    ]
    
    
    set port_list [list]
    
    ::ixia::addPortToWrite $port_handle
    
    if {($mode == "create") && ![info exists port_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error! when mode is $mode \
                port_handle is mandatory."
        return $returnList
    }
    
    if {![info exists handle]} {
        foreach {param t} $mode_list {
            set param ${param}_pattern
            if {$param == "patternAtm"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error! when $param is patternAtm \
                        handle is mandatory."
                return $returnList
            }
        }
    } else {
        set atm_status [::ixia::add_atm_triggers $args]
        if {[keylget atm_status status] != $::SUCCESS} {
            return $atm_status
        }
        if {$mode == "addAtmTrigger"} {
            if {![info exists no_write]} {
                set retCode [::ixia::writePortListConfig "no"]
                if {[keylget retCode status] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            ::ixia::writePortListConfig failed. \
                            [keylget retCode log]"
                    return $returnList
                }
                debug "::ixia::writePortListConfig \"no\""
            }
            set returnList $atm_status
            return $returnList
        }
    }
    
    foreach {param t} $mode_list {
        set param ${param}_pattern
        if {[info exists $param]} {
            if {[set $param] == "patternAtm"} {
                set $param any
            }
        }
    }
    
	set error_list [list errAnyFrame errGoodFrame                \
            errBadCRC errBadFrame                                ]
            
	set enumFilterErrors10_100 [list errAlign errDribble         \
            errBadCRCAlignDribble                                ]
            
	set enumFilterErrorsGigabit [list errLineError               \
            errLineAndBadCRC errLineAndGoodCRC                   ]
            
	set enumSequenceErrors [list errAnySequenceError             \
            errSmallSequenceError errBigSequenceError            \
            errReverseSequenceError                              ]
    
    foreach port_h $port_handle {
        foreach {chassis card port} [split $port_h /] {}
        
        lappend port_list [list $chassis $card $port]
        
        set isGigabitPort 0

        set interfaceType [port getInterface $chassis $card $port]
        if {$interfaceType == $::interfaceGigabit} {
            set isGigabitPort 1
        }
        
    	if {$isGigabitPort && ![port isValidFeature $chassis $card $port \
                $::portFeatureLocalCPU]} {
    		set error_list [join [lappend error_list $enumFilterErrorsGigabit]]
    	} else {
    		if {[port isActiveFeature $chassis $card $port \
                    $::portFeatureRxSequenceChecking] || \
    			[port isActiveFeature $chassis $card $port \
                    $::portFeatureRxDataIntegrity]} {
    			
                if {[port isActiveFeature $chassis $card $port \
                        $::portFeatureRxSequenceChecking]} {
                    set error_list [join [lappend error_list $enumSequenceErrors]]
                }
                if {[port isActiveFeature $chassis $card $port \
                        $::portFeatureRxDataIntegrity]} {
                    set error_list [lappend error_list errDataIntegrityError]
                }
    		} else {
    			set error_list [join [lappend error_list \
                        $enumFilterErrors10_100]]
    		}		
    	}
    	
        set error_list [join [lappend error_list errGfpErrors errCdlErrors]]
         
        if {[stat get allStats $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error when \"stat get allStats \
                    $chassis $card $port\" \n Possible causes are: \n \
                    No connection to a chassis or \n Invalid port number \
                    or \n Network error between client and chassis."
            return $returnList
        }
        debug "stat get allStats $chassis $card $port"
        
        if {([info exists async_trigger1] && $async_trigger1 == 1) || \
                ([info exists async_trigger2] && $async_trigger2 == 1)} {
            if {[catch  {stat config -mode statStreamTrigger} retError]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error: $retError returned when \
                        stat config -mode statStreamTrigger. \
                        \n Possible errors are $::ixErrorInfo"
                return $returnList
            }
            set isAsync 1
            debug "stat config -mode statStreamTrigger"
        } else  {
            if {[catch  {stat config -mode statNormal} retError]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error: $retError returned when \
                        stat config -mode statNormal. \
                        \n Possible errors are $::ixErrorInfo"
                return $returnList
            }
            if {[info exists isAsync]} {
                unset isAsync
            }
            debug "stat config -mode statNormal"
        }
        
        if {[stat set $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR: stat set $chassis \
                    $card $port returned and error. Possible \
                    causes are: \n No connection to a chassis\
                    \n Invalid port number \n The port is being\
                    used by another user \n The configured\
                    parameters are not valid for this port \n \
                    Network error between client and chassis"
            return $returnList
        }
        
        debug "stat set $chassis $card $port"
        
        if {[filter get $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR: filter get $chassis \
                    $card $port returned and error. Possible \
                    causes are: \n No connection to a chassis\
                    \n Invalid port number"
            return $returnList
        }
        
        debug "filter get $chassis $card $port"
        
        filter setDefault
        
        debug "filter setDefault"
        
        set this_status [::ixia::set_trigger_params]
        
        if {[keylget this_status status] != $::SUCCESS} {
            return $this_status
        }
        
        if {[filter set $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR: filter set $chassis \
                    $card $port returned and error. Possible \
                    causes are: \n No connection to a chassis\
                    \n Invalid port number \n The port is being\
                    used by another user \n The configured\
                    parameters are not valid for this port"
            return $returnList
        }
        
        debug "filter set $chassis $card $port"
    }
    
    if {![info exists no_write]} {
        set retCode [::ixia::writePortListConfig "no"]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
        debug "::ixia::writePortListConfig \"no\""
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::packet_control { args } {
    
    variable new_ixnetwork_api
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args
    ::ixia::logHltapiCommand $procName $args
    
    
    set mandatory_args {
        -action         CHOICES start stop reset cumulative_start
        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    set optional_args {
        -packet_type    CHOICES both control data
                        DEFAULT both
    }
    
    if {[isUNIX]} {
        set retValueClicks [eval "clientSend $::ixTclSvrHandle {clock clicks}"]
        set retValueSeconds [eval "clientSend $::ixTclSvrHandle {clock seconds}"]
    } else {
        set retValueClicks [clock clicks]
        set retValueSeconds [clock seconds]
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        
        set returnList [::ixia::ixnetwork_packet_control $args $optional_args $mandatory_args]
        
        keylset returnList clicks [format "%u" $retValueClicks]
        keylset returnList seconds [format "%u" $retValueSeconds]
        
        if {[keylget returnList status] != $::SUCCESS} {
            keylset returnList log "Error in $procName: [keylget returnList log]"
        }
        return $returnList
    }
    
    keylset returnList clicks [format "%u" $retValueClicks]
    keylset returnList seconds [format "%u" $retValueSeconds]

    if {[catch  {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }

    set port_list [list]
    
    foreach port_h $port_handle {
        foreach {chassis card port} [split $port_h /] {}
        lappend port_list [list $chassis $card $port]
    }
    
    if {[ixCheckLinkState port_list] != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Links are not up"
        keylset returnList stopped 0
        return $returnList
    }
    
    if {$action == "start"} {
        if {[ixStartCapture port_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to $action capture"
            keylset returnList stopped 0
            return $returnList
        } else  {
            if {[startPacketGroups port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to startPacketGroups $port_list"
                return $returnList
            }
            debug "startPacketGroups $port_list"
            debug "ixStartCapture $port_list"
            keylset returnList status $::SUCCESS
            keylset returnList stopped 0
            return $returnList
        }
    }
    
    if {$action == "stop"} {
        if {[ixStopCapture port_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to $action capture"
            keylset returnList stopped 0
            return $returnList
        } else  {
            if {[stopPacketGroups port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to stopPacketGroups $port_list"
                return $returnList
            }
            debug "stopPacketGroups $port_list"
            debug "ixStopCapture $port_list"
            keylset returnList status $::SUCCESS
            keylset returnList stopped 1
            return $returnList
        }
    }
}


proc ::ixia::packet_stats { args } {
    
    variable new_ixnetwork_api
    
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args
    ::ixia::logHltapiCommand $procName $args
    
    
    keylset returnList status $::SUCCESS
    set mandatory_args {
        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    set opt_args {
        -dirname                ANY
        -format                 CHOICES var txt cap enc none csv
                                DEFAULT cap
        -frame_id_end           NUMERIC 
                                DEFAULT 20
        -frame_id_start         NUMERIC 
                                DEFAULT 1
        -stop                   CHOICES 0 1
                                DEFAULT 0
        -filename               ANY
        -chunk_size             NUMERIC
                                DEFAULT 10000
        -enable_ethernet_type   CHOICES 0 1
        -enable_framesize       CHOICES 0 1
        -enable_pattern         CHOICES 0 1
        -ethernet_type          HEX
        -framesize              NUMERIC
        -packet_type            CHOICES control data both
                                DEFAULT both
        -pattern                HEX
        -pattern_offset         NUMERIC
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        
        set returnList [::ixia::ixnetwork_packet_stats $args $mandatory_args $opt_args]
        if {[keylget returnList status] != $::SUCCESS} {
            keylset returnList log "Error in $procName: [keylget returnList log]"
        }
        return $returnList
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args \
                    $opt_args -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    
    # Check for invalid parameters
    if {([info exists enable_ethernet_type] && $enable_ethernet_type == 0) \
            || ![info exists enable_ethernet_type]} {
        if {[info exists ethernet_type]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ethernet_type $ethernet type \
                    available only when \"enable_ethernet_type\" \
                    is set to 1"
            return $returnList
        }
    }
    
    if {([info exists enable_framesize] && $enable_framesize == 0) \
                || ![info exists enable_framesize]} {
        if {[info exists framesize]} {
            keylset returnList status $::FAILURE
            keylset returnList log "framesize $framesize \
                    available only when \"enable_framesize\" \
                    is set to 1"
            return $returnList
        }
    }
    
    if {([info exists enable_pattern] && $enable_pattern == 0) \
                || (![info exists enable_pattern])} {
        if {[info exists pattern] || [info exists pattern_offset]} {
            keylset returnList status $::FAILURE
            keylset returnList log "pattern constraint is available \
                    only when \"enable_pattern\" is set to 1"
            return $returnList
        }
    }
    
    if {[info exists format] && $format == "csv"} {
        keylset returnList status $::FAILURE
        keylset returnList log "-format csv not supported with IxTclHal"
        return $returnList
    }
    
    set constraint_list [list                                          \
            enable_ethernet_type         enableEthernetType            \
            enable_framesize             enableFramesize               \
            enable_pattern               enablePattern                 \
            ethernet_type                ethernetType                  \
            framesize                    framesize                     \
            pattern                      pattern                       \
            pattern_offset               patternOffset                 \
            ]
    
    set aggregate_keys_list [list                                      \
            average_deviation            averageDeviation              \
            average_latency              averageLatency                \
            num_frames                   numFrames                     \
            max_latency                  maxLatency                    \
            min_latency                  minLatency                    \
            standard_deviation           standardDeviation             \
            ]
            
    set counter_keys_list [list                                       \
            uds1_frame_count             userDefinedStat1              \
            uds2_frame_count             userDefinedStat2              \
            ]
            
    # Stop the traffic if it is requested
    if {$stop == 1} {
        set stop_status [::ixia::packet_control \
                -port_handle	$port_handle \
                -action			   stop		      \
                ]
        
        if {[keylget stop_status status] != $::SUCCESS} {
            return $stop_status
        }
    }
    
    foreach port_h $port_handle {
        foreach {chassis card port} [split $port_h /] {}
        lappend port_list [list $chassis $card $port]
        
        set empty_buffer 0;     # if buffer is empty set stats to N/A
        
        if {[stat get allStats $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error when \"stat get allStats \
                    $chassis $card $port\" \n Possible causes are: \n \
                    No connection to a chassis or \n Invalid port number \
                    or \n Network error between client and chassis."
            return $returnList
        }
        debug "stat get allStats $chassis $card $port"
        
        # Add the uds5 and uds6 stats to our keys
        if {[stat cget -mode] == 2} {
            lappend counter_keys_list uds5_frame_count streamTrigger1 \
                    uds6_frame_count streamTrigger2
        }
        
        foreach {hlt_counter ix_counter} $counter_keys_list {
            set aggregate_key $port_h.aggregate.$hlt_counter
            set key_value [stat cget -$ix_counter]
            if {[info exists key_value]} {
                keylset returnList $aggregate_key $key_value
                debug "stat cget -$ix_counter"
            }
        }
        
        # First we have to find out how many frames were captured
        if {[capture get $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "No connection chassis, or \
                    invalid port number provided."
            return $returnList
        }
        debug "capture get $chassis $card $port"
        
        set start_frame 1
        set end_frame [capture cget -nPackets]
        debug "capture cget -nPackets"
        
        if {$end_frame > $chunk_size} {
            puts "\nWARNING: On port $port_h the number of packets captured \
                    ($end_frame) is larger than chunk size ($chunk_size). The following\
                    statistics may be inaccurate: aggregate.average_deviation, aggregate.standard_deviation.\
                    Please configure -chunk_size with a value greater than $end_frame.\n"
        }
        
        if {$end_frame == 0} {
            # continue
            set empty_buffer 1
            puts "WARNING: Capture buffer is empty. Some statistics will be 'N/A'."
        } elseif {([info exists format]) && ($format == "var") && \
                ($end_frame > 20)} {
            puts "WARNING: Capture will be truncated to 20 frames.\
                Capture too large to export to \
                keyed list (number of frames, $end_frame, greater \
                than the maximum number of frames, 20, allowed)."
            set end_frame 20
        }
        
        if {![info exists filename]} {
            set date [clock format [clock seconds] -format %m%d%y%H%M]
            set pport $chassis$card$port
            set filename ixia-$date-$pport
        }
        
        # Brign the capture buffer in chunks of 10000 frames each
        
        set average_deviation_per_chunk   ""
        set standard_deviation_per_chunk  ""
                
        set chunk $chunk_size
        set i 1

        set end_f $chunk
        if {$end_frame > $chunk} {
            while {$end_f <= $end_frame} {
                set start [mpexpr $end_f - $chunk + 1]
                set end $end_f
                ::ixia::set_aggregate_keys
                if {[keylget returnList status] != $::SUCCESS} {
                    return $returnList
                }
                set returnList [::ixia::set_frame_keys $port_h $start \
                    $end $format $filename-$i-$chassis$card$port $returnList]
                if {[keylget returnList status] != $::SUCCESS} {
                    return $returnList
                }
                set end_f [mpexpr $end_f + $chunk]
                incr i
            }
            set end_f [mpexpr $end_f - $chunk]
            if {$end_f < $end_frame} {
                set start [expr $end_f + 1]
                set end $end_frame
                ::ixia::set_aggregate_keys
                if {[keylget returnList status] != $::SUCCESS} {
                    return $returnList
                }
                set returnList [::ixia::set_frame_keys $port_h $start \
                    $end $format $filename-$i-$chassis$card$port $returnList]
                if {[keylget returnList status] != $::SUCCESS} {
                    return $returnList
                }
            }
        } else {
            set start $start_frame
            set end $end_frame
            ::ixia::set_aggregate_keys
            if {[keylget returnList status] != $::SUCCESS} {
                return $returnList
            }
            if {!$empty_buffer} {
                set returnList [::ixia::set_frame_keys $port_h $start \
                    $end $format $filename-$i-$chassis$card$port $returnList]
                if {[keylget returnList status] != $::SUCCESS} {
                    return $returnList
                }
            }
        }
        
        if {[llength $average_deviation_per_chunk] > 0} {
            debug "keylset returnList $port_h.aggregate.average_deviation_per_chunk $average_deviation_per_chunk"
            keylset returnList $port_h.aggregate.average_deviation_per_chunk $average_deviation_per_chunk
        } else {
            debug "keylset returnList $port_h.aggregate.average_deviation_per_chunk N/A"
            keylset returnList $port_h.aggregate.average_deviation_per_chunk "N/A"
        }
        
        if {[llength $standard_deviation_per_chunk] > 0} {
            debug "keylset returnList $port_h.aggregate.standard_deviation_per_chunk $standard_deviation_per_chunk"
            keylset returnList $port_h.aggregate.standard_deviation_per_chunk $standard_deviation_per_chunk
        } else {
            debug "keylset returnList $port_h.aggregate.standard_deviation_per_chunk N/A"
            keylset returnList $port_h.aggregate.standard_deviation_per_chunk "N/A"
        }

        if {![catch {keylget returnList $port_h.aggregate.average_deviation} \
                    tempValue] && [regexp {^[0-9\.]+$} $tempValue]} {
            
            if {![info exists average_deviation_counter] || $average_deviation_counter == 0} {
                set average_deviation_counter 1
            }
            debug "keylset returnList $port_h.aggregate.average_deviation \[mpexpr $tempValue/$average_deviation_counter\]"
            keylset returnList $port_h.aggregate.average_deviation [mpexpr $tempValue/$average_deviation_counter]
        }

        if {![catch {keylget returnList $port_h.aggregate.average_latency} \
                    tempValue] && [regexp {^[0-9\.]+$} $tempValue]} {
            
            if {![info exists average_latency_counter] || $average_latency_counter == 0} {
                set average_latency_counter 1
            }
            debug "keylset returnList $port_h.aggregate.average_latency \[mpexpr $tempValue/$average_latency_counter\]"
            keylset returnList $port_h.aggregate.average_latency [mpexpr $tempValue/$average_latency_counter]
        }

        if {![catch {keylget returnList $port_h.aggregate.standard_deviation} \
                    tempValue] && [regexp {^[0-9\.]+$} $tempValue]} {
            
            if {![info exists standard_deviation_counter] || $standard_deviation_counter == 0} {
                set standard_deviation_counter 1
            }
            debug "keylset returnList $port_h.aggregate.standard_deviation \[mpexpr $tempValue/$standard_deviation_counter\]"
            keylset returnList $port_h.aggregate.standard_deviation [mpexpr $tempValue/$standard_deviation_counter]
        }
        
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}
