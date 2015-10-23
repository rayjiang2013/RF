##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_l3vpn_api.tcl
#
# Purpose:
#    A script development library containing general APIs for test automation
#    with the Ixia chassis.
#
# Author:
#    Ixia engineering, direct all communication to support@ixiacom.com
#
# Usage:
#    package require Ixia
#
# Description:
#    This library contains a stream generation procedure for L3VPN setups.
#    The procedure should be called after the L3VPN setup is up and running.
#    All protocols should be running.
#
#
# Requirements:
#    ixiaapiutils.tcl , a library containing TCL utilities
#    parseddashedargs.tcl , a library containing the procDescr and
#        parse_dashed_args procedures
#
# Variables:
#
# Keywords:
#
# Category:
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


proc ::ixia::l3vpn_generate_stream {args} {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::l3vpn_generate_stream $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set mandatory_args {
        -pe_port_handle       REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -ce_port_handle       REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    set optional_args {
        -stream_generation            CHOICES pe_to_ce ce_to_pe both
                                      DEFAULT both
        -pe_label_protocol            CHOICES ldp rsvp
        -ce_routing_protocol          CHOICES ospf bgp isis rip
        -pe_router_handle
        -ce_router_handle
        -reset                        FLAG
        -length_mode                  CHOICES fixed increment random auto imix
                                      CHOICES gaussian quad
        -l3_length                    RANGE   1-64000
        -l3_length_min                RANGE   1-64000
        -l3_length_max                RANGE   1-64000
        -l3_length_step               RANGE   0-64000
        -l3_imix1_size                RANGE   32-9000
        -l3_imix1_ratio
        -l3_imix2_size                RANGE   32-9000
        -l3_imix2_ratio
        -l3_imix3_size                RANGE   32-9000
        -l3_imix3_ratio
        -l3_imix4_size                RANGE   32-9000
        -l3_imix4_ratio
        -l3_gaus1_avg                 DECIMAL
        -l3_gaus1_halfbw              DECIMAL
        -l3_gaus1_weight              NUMERIC
        -l3_gaus2_avg                 DECIMAL
        -l3_gaus2_halfbw              DECIMAL
        -l3_gaus2_weight              NUMERIC
        -l3_gaus3_avg                 DECIMAL
        -l3_gaus3_halfbw              DECIMAL
        -l3_gaus3_weight              NUMERIC
        -l3_gaus4_avg                 DECIMAL
        -l3_gaus4_halfbw              DECIMAL
        -l3_gaus4_weight              NUMERIC
        -rate_pps
        -rate_bps
        -rate_percent                 RANGE   0-100
        -transmit_mode                CHOICES continuous single_burst
        -pkts_per_burst
        -data_pattern
        -data_pattern_mode            CHOICES incr_byte decr_byte fixed random
                                      CHOICES repeating
        -enable_data_integrity        CHOICES 0 1
        -integrity_signature
        -integrity_signature_offset   RANGE   12-65535
        -frame_sequencing             CHOICES enable disable
        -frame_sequencing_offset
        -frame_size                   RANGE   20-13312
        -frame_size_max               RANGE   20-13312
        -frame_size_min               RANGE   20-13312
        -frame_size_step              RANGE   0-13292
        -ip_cost                      CHOICES 0 1
        -ip_delay                     CHOICES 0 1
        -ip_precedence                RANGE   0-7
        -ip_reliability               CHOICES 0 1
        -ip_reserved                  CHOICES 0 1
        -ip_throughput                CHOICES 0 1
        -enable_time_stamp            CHOICES 0 1
                                      DEFAULT 1
        -number_of_packets_per_stream RANGE   3-9999999999
        -enable_pgid                  CHOICES 0 1
        -pgid_value
        -signature
        -signature_offset             RANGE   8-64000
        -number_of_packets_tx
        -no_write                     FLAG
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args
    
    if {($stream_generation == "pe_to_ce") || ($stream_generation == "both")} {
        if {![info exists ce_routing_protocol]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the\
                    -stream_generation is $stream_generation, a\
                    -ce_routing_protocol is required.  Please supply\
                    this value."
            return $returnList
        }
        if {![info exists pe_label_protocol]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the\
                    -stream_generation is $stream_generation, a\
                    -pe_label_protocol is required.  Please supply\
                    this value."
            return $returnList
        }
    }
    
    # Remove -reset from argument list
    set index [lsearch $args "-reset"]
    if {$index != -1} {
        set args [lreplace $args $index $index]
    }
    
    # Leave only args specific to traffic_config
    set trafficArgs ""
    set l3vpnOptions [list                           \
            -pe_port_handle       -ce_port_handle    \
            -stream_generation    -pe_label_protocol \
            -ce_routing_protocol  -pe_router_handle  \
            -ce_router_handle                        ]
    foreach {option value} $args {
        if {[lsearch $l3vpnOptions $option] == -1} {
            lappend trafficArgs $option $value
        }
    }
    
    set peStreams ""
    set ceStreams ""
    foreach {peChassis peCard pePort} [split $pe_port_handle /] {}
    foreach {ceChassis ceCard cePort} [split $ce_port_handle /] {}
    
    # PE VPN configured routes
    ixPuts "Retrieving PE BGP configured routes ..."
    if {[info exists pe_router_handle]} {
        set peCfgRouteList [::ixia::l3vpnPEBgpGetRoutes \
                $peChassis $peCard $pePort $pe_router_handle]
    } else  {
        set peCfgRouteList [::ixia::l3vpnPEBgpGetRoutes \
                $peChassis $peCard $pePort]
    }
    if {[keylget peCfgRouteList status] != $::SUCCESS} {
        return $peCfgRouteList
    }
    array unset peCfgRoutes
    array set peCfgRoutes [keylget peCfgRouteList route]
    debug "PE CFG ROUTES: [array names peCfgRoutes]"
    
    if {[array get peCfgRoutes] == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: There are no BGP VPN\
                routes configured on PE side."
        return $returnList
    }
    
    # PE BGP learned VPN routes
    ixPuts "Retrieving PE BGP learned vpn routes ..."
    if {[info exists pe_router_handle]} {
        set peLearnedRouteList [::ixia::l3vpnBgpGetLearnedVpnRoutes \
                $peChassis $peCard $pePort $pe_router_handle]
    } else  {
        set peLearnedRouteList [::ixia::l3vpnBgpGetLearnedVpnRoutes \
                $peChassis $peCard $pePort]
    }
    if {[keylget peLearnedRouteList status] != $::SUCCESS} {
        return $peLearnedRouteList
    }
    array unset peLearnedRoutes
    array set peLearnedRoutes [keylget peLearnedRouteList record]
    debug "PE LEARNED ROUTES [array names peLearnedRoutes]"
    if {[array get peLearnedRoutes] == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: There are no VPN\
                learned labels on PE side."
        return $returnList
    }
    
    # CE configured routes
    ixPuts "Retrieving CE configured routes ..."
    if {[info exists ce_router_handle]} {
        set ceCfgRouteList [::ixia::l3vpnCEGetConfiguredRoutes  \
                $ce_routing_protocol $ceChassis $ceCard $cePort \
                $ce_router_handle]
    } else  {
        set ceCfgRouteList [::ixia::l3vpnCEGetConfiguredRoutes \
                $ce_routing_protocol $ceChassis $ceCard $cePort]
    }
    if {[keylget ceCfgRouteList status] != $::SUCCESS} {
        return $ceCfgRouteList
    }
    array unset ceCfgRoutes
    array set ceCfgRoutes [keylget ceCfgRouteList route]
    debug "CE CFG ROUTES: [array names ceCfgRoutes]"
    
    if {[array get ceCfgRoutes] == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: There are no [string \
                toupper $ce_routing_protocol] routes configured on CE side."
        return $returnList
    }
    
    # Get matching PE - CE routes
    ixPuts "Matching PE & CE routes ..."
    set matchedRouteList [::ixia::l3vpnGetMatchingCEPERoutes \
            [array get ceCfgRoutes] [array get peLearnedRoutes]  ]
    
    if {[keylget matchedRouteList status] != $::SUCCESS} {
        return $matchedRouteList
    }
    set matchedRoutes   [keylget matchedRouteList routes]
    set unmatchedRoutes [keylget matchedRouteList unmatched]
    debug "MATCHED ROUTES $matchedRoutes"
    if {$matchedRoutes == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The CE routes were not\
                learned on PE side. There are no routes retrieved.\
                Cannot continue."
        return $returnList
    }
    
    if {$unmatchedRoutes != ""} {
        keylset returnList log "WARNING in $procName: The following CE routes\
                weren't learned on PE side: $unmatchedRoutes."
    }
    
    # Build PE streams
    if {($stream_generation == "pe_to_ce") || ($stream_generation == "both")} {
        if {[info exists reset]} {
            set resetStatus [::ixia::traffic_config \
                    -port_handle $pe_port_handle    \
                    -mode        reset]
            if {[keylget resetStatus status] != $::SUCCESS} {
                return $resetStatus
            }
        }
        
        # Get MPLS learned labels
        ixPuts "Retrieving MPLS labels on PE port ..."
        switch -- $pe_label_protocol {
            ldp {
                set labelRoutes [::ixia::l3vpnLdpGetLearnedLabels  \
                        $peChassis $peCard $pePort]
            }
            rsvp {
                set labelRoutes [::ixia::l3vpnRsvpGetLearnedLabels \
                        $peChassis $peCard $pePort]
            }
            default {}
        }
        if {[keylget labelRoutes status] != $::SUCCESS} {
            return $labelRoutes
        }
        set learnedLabelRoutes [keylget labelRoutes record]
        debug "LABELS: $learnedLabelRoutes"
        if {$learnedLabelRoutes == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: There are no MPLS\
                    labels learned on PE side."
            return $returnList
            
        }
        
        set peStreams [::ixia::l3vpnGeneratePEStream  \
                $peChassis $peCard $pePort            \
                [array get peCfgRoutes] matchedRoutes \
                learnedLabelRoutes $trafficArgs]
        
        if {[keylget peStreams status] != $::SUCCESS} {
            return $peStreams
        }
    }
    
    # Build CE streams
    if {($stream_generation == "ce_to_pe") || ($stream_generation == "both")} {
        if {[info exists reset]} {
            set resetStatus [::ixia::traffic_config \
                    -port_handle $ce_port_handle    \
                    -mode        reset]
            if {[keylget resetStatus status] != $::SUCCESS} {
                return $resetStatus
            }
        }
        
        set ceStreams [::ixia::l3vpnGenerateCEStream \
                $ceChassis $ceCard $cePort           \
                [array get peCfgRoutes] matchedRoutes $trafficArgs]
        
        if {[keylget ceStreams status] != $::SUCCESS} {
            return $ceStreams
        }
    }
    
    if {![info exists no_write]} {
        set port_list [list [split $pe_port_handle /] [split $ce_port_handle /]]
        if {[ixWriteConfigToHardware port_list -noProtocolServer]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Unable to write\
                    config to hardware on port: $port_list"
            return $returnList
        }
    }
    
    if {$peStreams != ""} {
        keylset returnList stream_id.$pe_port_handle [keylget peStreams stream]
    }
    if {$ceStreams != ""} {
        keylset returnList stream_id.$ce_port_handle [keylget ceStreams stream]
    }
    keylset returnList status    $::SUCCESS
    return $returnList
}
