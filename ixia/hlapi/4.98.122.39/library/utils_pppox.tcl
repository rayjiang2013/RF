##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_pppox.tcl
#
# Purpose:
#    A script development library containing PPPoX APIs for test automation
#    with the Ixia chassis.
#
# Author:
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#    - get_interface_entry_from_ip
#    - ixaccess_create_network_port
#    - ixaccess_create_qos
#    - ixaccess_set_traffic_options
#    - ixaccess_set_traffic_user_options
#    - ixaccess_traffic_config
#    - pppox_status_loop
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


##Internal Procedure Header
# Name:
#    ::ixia::pppox_status_loop
#
# Description:
#    Check the status of PPPoX session connect and disconnect for
#    specified duration. By default wait till the action gets
#    completed.
#
# Synopsis:
#    ::ixia::pppox_status_loop
#        -port_list<interface list>
#        -mode<-CHOICES:connect|disconnect>
#
# Arguments:
#    -port_list
#        List of port for which to check the status of connect
#        or disconnect operation.
#    -mode
#        Mode to check. Valid choices are:
#        connect     - Check status of setup operation.
#        disconnect  - Check status of teardown operation.
#x   -wait_time
#        Maximum time to wait checkin status of the
#        connect or disconnect. A value of -1 (default) will
#        wait forever until the action gets completed.
#
# Return Values:
#    A key list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:If status is failure, detailed information provided.
#
# Examples:
#
# Sample Input:
#    set connect_status [ixia::pppox_status_loop \
#            -port_list $upstream_port_list       \
#            -mode connect                        \
#            -wait_time 60                        ]
#
# Sample Output:
#
# Notes:
#    1) This is an ixia specific utility function that
#       should become part of the HLTAPI.
#
# See Also:
#
proc ::ixia::pppox_status_loop { args } {
    
    set procName [lindex [info level [info level]] 0]
    
    # Arguments
    set mandatory_args [list                                        \
            {-port_list<^(\{*[0-9]+/[0-9]+/[0-9]+[\ ]*\}*[\ ]*)+$>} \
            -mode<-CHOICES:connect|disconnect>                      ]
    
    set wait_time     -1
    set print_summary 0
    
    set optional_args [list            \
            -print_summary<-RANGE:0-1> \
            -wait_time<-RANGE:0-65535> ]
    
    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args
    
    set port_list [format_space_port_list $port_list]
    if { $mode == "connect" } {
        set opName "setup"
    } else {
        set opName "teardown"
    }
    
    # Create a temp port group for the group stats
    set groupID 9876
    ixAccessPortGroup create $groupID
    foreach port $port_list {
        scan $port "%d %d %d" ch ca po
        set operationDone($ch.$ca.$po) 0
        ixAccessPortGroup add $groupID $ch $ca $po
    }
    
    set curWait        0
    set opCompleted    0
    while { $wait_time == -1 || $curWait < $wait_time } {
        foreach port $port_list {
            scan $port "%d %d %d" ch ca po
            if { $operationDone($ch.$ca.$po) == 0 } {
                if { $print_summary } {
                    puts -nonewline "($ch.$ca.$po): "
                    ixaPrintSummaryStats $ch $ca $po
                }
                
                ixAccessProfile select $ch $ca $po
                set opState [ixAccessProfile getOperationState $opName]
                if {($opState == $::kIxAccessDone) || \
                            ($opState == $::kIxAccessFailed)} {
                    incr opCompleted
                    if { $opState == $::kIxAccessDone } {
                        set operationDone($ch.$ca.$po) 1
                    } else {
                        set operationDone($ch.$ca.$po) -1
                    }
                }
            }
        }
        if { $opCompleted == [llength $port_list] } {
            break
        }
        incr curWait
        after 1000
    }
    
    ixAccessPortGroup setCommand $groupID kIxAccessGetSessionStats
    if { $opCompleted == [llength $port_list] } {
        keylset returnList status $::SUCCESS
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "WARN: Could not complete $mode\
                in $wait_time seconds"
    }
    ixAccessPortGroup destroy $groupID
    
    return $returnList
}


proc ::ixia::ixaccess_set_traffic_user_options {} {
    
    uplevel {
        set option_list "\
                ip_precedence ip_delay ip_throughput ip_reliability \
                ip_cost ip_reserved ip_dscp pgid_value data_pattern_mode \
                ipv6_traffic_class ipv6_flow_label public_port_ip \
                mac_src mac_src2 ip_dst_addr ip_src_addr \
                ip_dst_count ip_dst_step ip_src_count ip_src_step"
        
        # Traffic mapping must be disabled if we use host_behind_network
        if {[info exists host_behind_network]} {
            set option_list [lreplace $option_list \
                    [lsearch $option_list ip_dst_addr] end]
        }
        
        set _tos_list "ip_reserved ip_cost ip_reliability ip_throughput \
                ip_delay ip_precedence"
        
        ixAccessTrafficUser setDefault
        debug "ixAccessTrafficUser setDefault"
        
        switch -- $traffic_indicator {
            multicast {
                 set trafficIndex 0
                 for {set i [ixAccessTrafficUserTable getFirstTrafficUser]} {$i == 0} \
                         {set i [ixAccessTrafficUserTable getNextTrafficUser]} {
                     
                     incr trafficIndex
                 }
                 debug "trafficIndex=$trafficIndex"
                 
                 # Store the parameters in the user table object for later reprocessing
                 set theTrafficUserId range$trafficIndex
                 ixAccessTrafficUser configure -mcTrafficType $::kIxAccessTrafficTypeMulticast
            }
            voice {
                    if {[info exists voice_tos] && ($voice_tos != 0)} {
                        set ip_reserved    [expr $voice_tos & 0x01]
                        set ip_cost        [expr ($voice_tos >> 1) & 0x01]
                        set ip_reliability [expr ($voice_tos >> 2) & 0x01]
                        set ip_throughput  [expr ($voice_tos >> 3) & 0x01]
                        set ip_delay       [expr ($voice_tos >> 4) & 0x01]
                        set ip_precedence  [expr ($voice_tos >> 5) & 0x07]
                    } else {
                        foreach _tos_value $_tos_list {
                            if {[info exists $_tos_value]} {
                                unset _tos_value
                            }
                        }
                    }
                    set theTrafficUserId rangeVoice$trafficIndex
                    ixAccessTrafficUser configure -mcTrafficType $::kIxAccessTrafficTypeVoice
                }
            data {
                 if {[info exists data_tos] && ($data_tos != 0)} {
                     set ip_reserved    [expr $data_tos & 0x01]
                     set ip_cost        [expr ($data_tos >> 1) & 0x01]
                     set ip_reliability [expr ($data_tos >> 2) & 0x01]
                     set ip_throughput  [expr ($data_tos >> 3) & 0x01]
                     set ip_delay       [expr ($data_tos >> 4) & 0x01]
                     set ip_precedence  [expr ($data_tos >> 5) & 0x07]
                 } else {
                     foreach _tos_value $_tos_list {
                         if {[info exists $_tos_value]} {
                             unset _tos_value
                         }
                     }
                 }
                 set theTrafficUserId rangeData$trafficIndex
                 ixAccessTrafficUser configure -mcTrafficType $::kIxAccessTrafficTypeData
            }
            default {
                set trafficIndex 0
                for {set i [ixAccessTrafficUserTable getFirstTrafficUser]} {$i == 0} \
                        {set i [ixAccessTrafficUserTable getNextTrafficUser]} {
                    
                    incr trafficIndex
                }
                debug "trafficIndex=$trafficIndex"
                
                # Store the parameters in the user table object for later reprocessing
                set theTrafficUserId range$trafficIndex
            }
        }
        
        ixAccessTrafficUser config -trafficUserId $theTrafficUserId
        debug "ixAccessTrafficUser config -trafficUserId range$trafficIndex"
        
        if {[info exists $parm_port_handle]} {
            regsub -all {/} [set $parm_port_handle] " " interface2
            foreach {destChasID destCardID destPortID} $interface2 {}
            ixAccessTrafficUser config -destChasID  $destChasID
            debug "ixAccessTrafficUser config -destChasID  $destChasID"
            ixAccessTrafficUser config -destCardID  $destCardID
            debug "ixAccessTrafficUser config -destCardID  $destCardID"
            ixAccessTrafficUser config -destPortID  $destPortID
            debug "ixAccessTrafficUser config -destPortID  $destPortID"
            ixAccessTrafficUser config -gatewayIP   $ip_gw_addr
            debug "ixAccessTrafficUser config -gatewayIP   $ip_gw_addr"
        }
        
        if {[info exists variable_user_rate] && ($variable_user_rate == 1) && \
                    [info exists qosGroupId]} {
            ixAccessTrafficUser config -qosGroupId  $qosGroupId
            debug "ixAccessTrafficUser config -qosGroupId  $qosGroupId"
        } else {
            if {![info exists noQoSUsers]} {
                set noQoSUsers ""
            }
            lappend noQoSUsers $theTrafficUserId
        }
        ixAccessTrafficUser config -startInterface  1
        debug "ixAccessTrafficUser config -startInterface  1"
        ixAccessTrafficUser config -endInterface    $numSessions
        debug "ixAccessTrafficUser config -endInterface    $numSessions"
        
        # Configure mcGroupId for IGMPoPPP usage
        if {[info exists emulation_handles_array($mcIndex)]} {
            ixAccessTrafficUser config -mcGroupId     $emulation_handles_array($mcIndex)
            debug "ixAccessTrafficUser config -mcGroupId     $emulation_handles_array($mcIndex)"
        }        
        if {$session_traffic_stats || [info exists emulation_handles_array($mcIndex)]} {
            ixAccessTrafficUser config -pgidValueOption $::kIxAccessPgidAuto
            debug "ixAccessTrafficUser config -pgidValueOption $::kIxAccessPgidAuto"
        } else  {
            ixAccessTrafficUser config -pgidValueOption $::kIxAccessPgidStreamId
            debug "ixAccessTrafficUser config -pgidValueOption $::kIxAccessPgidStreamId"
        }
        
        foreach single_option_list $option_list {
            if {[info exists $single_option_list]} {
                eval set single_option $$single_option_list
                switch -- $single_option_list {
                    ip_precedence {
                        ixAccessTrafficUser config -precedence $single_option
                        debug "ixAccessTrafficUser config -precedence $single_option"
                    }
                    ip_delay {
                        ixAccessTrafficUser config -delay $single_option
                        debug "ixAccessTrafficUser config -delay $single_option"
                    }
                    ip_throughput {
                        ixAccessTrafficUser config -throughput $single_option
                        debug "ixAccessTrafficUser config -throughput $single_option"
                    }
                    ip_reliability {
                        ixAccessTrafficUser config -reliability $single_option
                        debug "ixAccessTrafficUser config -reliability $single_option"
                    }
                    ip_cost {
                        ixAccessTrafficUser config -cost $single_option
                        debug "ixAccessTrafficUser config -cost $single_option"
                    }
                    ip_reserved {
                        ixAccessTrafficUser config -reserved $single_option
                        debug "ixAccessTrafficUser config -reserved $single_option"
                    }
                    ip_dscp {
                        ixAccessTrafficUser setDiffServCodePoint $single_option
                        debug "ixAccessTrafficUser setDiffServCodePoint $single_option"
                    }
                    pgid_value {
                        ixAccessTrafficUser config -pgidValue $single_option
                        debug "ixAccessTrafficUser config -pgidValue $single_option"
                        
                        ixAccessTrafficUser config -pgidValueOption $::kIxAccessPgidFixed
                        debug "ixAccessTrafficUser config -pgidValueOption $::kIxAccessPgidFixed"
                    }
                    data_pattern {
                        ixAccessTrafficUser config -pattern $single_option
                        debug "ixAccessTrafficUser config -pattern $single_option"
                    }
                    data_pattern_mode {
                        switch -- $single_option {
                            fixed {
                                ixAccessTrafficUser config -patternType \
                                        $::nonRepeat
                                
                                debug "ixAccessTrafficUser config -patternType \
                                        $::nonRepeat"
                            }
                            incr_byte {
                                ixAccessTrafficUser config -patternType \
                                        $::incrByte
                                
                                debug "ixAccessTrafficUser config -patternType \
                                        $::incrByte"
                            }
                            decr_byte {
                                ixAccessTrafficUser config -patternType \
                                        $::decrByte
                                
                                debug "ixAccessTrafficUser config -patternType \
                                        $::decrByte"
                            }
                            random {
                                ixAccessTrafficUser config -patternType \
                                        $::patternTypeRandom
                                
                                debug "ixAccessTrafficUser config -patternType \
                                        $::patternTypeRandom"
                            }
                            repeating {
                                ixAccessTrafficUser config -patternType \
                                        $::repeat
                                
                                debug "ixAccessTrafficUser config -patternType \
                                        $::repeat"
                            }
                            default {
                                ixAccessTrafficUser config -patternType \
                                        $::incrByte
                                
                                debug "ixAccessTrafficUser config -patternType \
                                        $::incrByte"
                            }
                        }
                    }
                    ip_dst_addr {
                        if {$isSrcEmulating} {
                            ixAccessTrafficUser config -destIP $single_option
                            debug "ixAccessTrafficUser config -destIP $single_option"
                        }
                        
                    }
                    ip_src_addr {
                        if {$isDstEmulating} {
                            ixAccessTrafficUser config -destIP $single_option
                            debug "ixAccessTrafficUser config -destIP $single_option"
                        }
                    }
                    mac_src2 -
                    mac_src {
                        ixAccessTrafficUser config -destMac $single_option
                        debug "ixAccessTrafficUser config -destMac $single_option"
                    }
                    ipv6_traffic_class {
                        ixAccessTrafficUser config -ipv6TrafficClass \
                                $single_option
                        
                        debug "ixAccessTrafficUser config -ipv6TrafficClass \
                                $single_option"
                    }
                    ipv6_flow_label {
                        ixAccessTrafficUser config -ipv6FlowLabel \
                                $single_option
                        
                        debug "ixAccessTrafficUser config -ipv6FlowLabel \
                                $single_option"
                    }
                    ip_dst_count {
                        if {$isSrcEmulating} {
                            ixAccessTrafficUser config -destIPCount \
                                    $single_option
                            
                            debug "ixAccessTrafficUser config -destIPCount \
                                    $single_option"
                        }
                    }
                    ip_dst_step {
                        if {$isSrcEmulating} {
                            ixAccessTrafficUser config -destIPIncr \
                                    $single_option
                            
                            debug "ixAccessTrafficUser config -destIPIncr \
                                    $single_option"
                        }
                    }
                    ip_src_count {
                        if {$isDstEmulating} {
                            ixAccessTrafficUser config -destIPCount \
                                    $single_option
                            
                            debug "ixAccessTrafficUser config -destIPCount \
                                    $single_option"
                        }
                    }
                    ip_src_step {
                        if {$isDstEmulating} {
                            ixAccessTrafficUser config -destIPIncr \
                                    $single_option
                            
                            debug "ixAccessTrafficUser config -destIPIncr \
                                    $single_option"
                        }
                    }
                    public_port_ip {
                        ixAccessTrafficUser config -publicPortIP \
                                $single_option
                        
                        debug "ixAccessTrafficUser config -publicPortIP \
                                $single_option"
                    }
                }
            }
        }
    }
}


proc ::ixia::ixaccess_set_traffic_options {chassis card port} {
    namespace eval thisCmd {
        variable chassis 0
        variable card    0
        variable port    0
    }
    set thisCmd::chassis $chassis
    set thisCmd::card    $card
    set thisCmd::port    $port
    
    uplevel {
        set option_list "transmit_mode burst_loop_count number_of_packets_tx \
                pkts_per_burst rate_percent rate_pps rate_bps \
                l3_length number_of_packets_per_stream \
                number_of_packets_tx l7_traffic duration \
                pppoe_unique_acmac variable_user_rate \
                session_repeat_count"
        
        ixAccessTraffic get $thisCmd::chassis $thisCmd::card $thisCmd::port
        debug "ixAccessTraffic get $thisCmd::chassis $thisCmd::card $thisCmd::port"
        ixAccessTraffic config -frameSizeMode $::kIxAccessFrameSizeL3
        debug "ixAccessTraffic config -frameSizeMode $::kIxAccessFrameSizeL3"
        ixAccessTraffic config -enablePerSessionStats $session_traffic_stats
        debug "ixAccessTraffic config -enablePerSessionStats 1"
        
        foreach single_option_list $option_list {
            if {[info exists $single_option_list]} {
                eval set single_option $$single_option_list
                switch -- $single_option_list {
                    transmit_mode {
                        switch -- $single_option {
                            single_burst {
                                ixAccessTraffic config -streamTxMode \
                                        $::kIxAccessTxModeBurst
                                
                                debug "ixAccessTraffic config -streamTxMode \
                                        $::kIxAccessTxModeBurst"
                                
                                ixAccessTraffic config -numBursts 1
                                debug "ixAccessTraffic config -numBursts 1"
                            }
                            multi_burst {
                                ixAccessTraffic config -streamTxMode \
                                        $::kIxAccessTxModeBurst
                                
                                debug "ixAccessTraffic config -streamTxMode \
                                        $::kIxAccessTxModeBurst"
                            }
                            continuous_burst {
                                ixAccessTraffic config -streamTxMode \
                                        $::kIxAccessTxModeContBurst
                                
                                debug "ixAccessTraffic config -streamTxMode \
                                        $::kIxAccessTxModeContBurst"
                            }
                            continuous {
                                ixAccessTraffic config -streamTxMode \
                                        $::kIxAccessTxModeContPacket
                                
                                debug "ixAccessTraffic config -streamTxMode \
                                        $::kIxAccessTxModeContPacket"
                            }
                            single_pkt {
                                ixAccessTraffic config -streamTxMode \
                                        $::kIxAccessTxModeBurst
                                
                                debug "ixAccessTraffic config -streamTxMode \
                                        $::kIxAccessTxModeBurst"
                                
                                ixAccessTraffic config -numBursts 1
                                debug "ixAccessTraffic config -numBursts 1"
                                ixAccessTraffic config -numFrames 1
                                debug "ixAccessTraffic config -numFrames 1"
                            }
                            default { puts "PROBLEM $single_option" }
                        }
                    }
                    burst_loop_count {
                        ixAccessTraffic config -numBursts $single_option
                        debug "ixAccessTraffic config -numBursts $single_option"
                    }
                    number_of_packets_per_stream -
                    number_of_packets_tx {
                        ixAccessTraffic config -numFrames $single_option
                        debug "ixAccessTraffic config -numFrames $single_option"
                    }
                    pkts_per_burst {
                        ixAccessTraffic config -numFrames $single_option
                        debug "ixAccessTraffic config -numFrames $single_option"
                    }
                    rate_percent {
                        ixAccessTraffic config -rateMode \
                                $::kIxAccessLineUtilization
                        
                        debug "ixAccessTraffic config -rateMode \
                                $::kIxAccessLineUtilization"
                        
                        ixAccessTraffic config -percentageLineRate $single_option
                        debug "ixAccessTraffic config -percentageLineRate $single_option"
                    }
                    rate_pps {
                        ixAccessTraffic config -rateMode \
                                $::kIxAccessPacketPerSec
                        
                        debug "ixAccessTraffic config -rateMode \
                                $::kIxAccessPacketPerSec"
                        
                        ixAccessTraffic config -packetPerSecond $single_option
                        debug "ixAccessTraffic config -packetPerSecond $single_option"
                    }
                    rate_bps {
                        ixAccessTraffic config -rateMode \
                                $::kIxAccessBitPerSec
                        
                        debug "ixAccessTraffic config -rateMode \
                                $::kIxAccessBitPerSec"
                        
                        ixAccessTraffic config -bitsPerSecond $single_option
                        debug "ixAccessTraffic config -bitsPerSecond $single_option"
                    }
                    l3_length {
                        ixAccessTraffic config -frameSize $single_option
                        debug "ixAccessTraffic config -frameSize $single_option"
                        ixAccessTraffic config -trafficType \
                                $::kIxAccessTrafficFixed
                        
                        debug "ixAccessTraffic config -trafficType \
                                $::kIxAccessTrafficFixed"
                    }
                    l7_traffic {
                        ixAccessTraffic config -enableLayer7Traffic \
                                $single_option
                        
                        debug "ixAccessTraffic config -enableLayer7Traffic \
                                $single_option"
                    }
                    duration {
                        ixAccessTraffic config -streamTxMode $::kIxAccessTxModeFixed
                        debug "ixAccessTraffic config -streamTxMode $::kIxAccessTxModeFixed"
                        ixAccessTraffic config -duration $single_option
                        debug "ixAccessTraffic config -duration $single_option"
                    }
                    pppoe_unique_acmac {
                        ixAccessTraffic config -enablePppoeUniqueAcMac \
                                $single_option
                        
                        debug "ixAccessTraffic config -enablePppoeUniqueAcMac \
                                $single_option"
                    }
                    variable_user_rate {
                        if {[ixAccessPort cget -portRole] == $::kIxAccessRole } {
                            ixAccessTraffic config -enableVariableUserRate \
                                    $single_option
                            debug "ixAccessTraffic config -enableVariableUserRate \
                                    $single_option"
                        }
                    }
                    session_repeat_count {
                        ixAccessTraffic config -sessionRepeatCount \
                                $single_option
                        
                        debug "ixAccessTraffic config -sessionRepeatCount \
                                $single_option"
                    }
                }
            }
        }
        
        if {[info exists l3_imix1_size] || [info exists l3_imix2_size] || \
                    [info exists l3_imix3_size] || [info exists l3_imix4_size] } {
            ixAccessTraffic config -trafficType  $::kIxAccessTrafficImix
            debug "ixAccessTraffic config -trafficType  $::kIxAccessTrafficImix"
        }
        
        ixAccessTraffic set $thisCmd::chassis $thisCmd::card $thisCmd::port
        debug "ixAccessTraffic set $thisCmd::chassis $thisCmd::card $thisCmd::port"
        
        ixAccessImixTable select $thisCmd::chassis $thisCmd::card $thisCmd::port
        debug "ixAccessImixTable select $thisCmd::chassis $thisCmd::card $thisCmd::port"
        
        ixAccessImixTable clearAllImix
        debug "ixAccessImixTable clearAllImix"
        if {[info exists l3_imix1_size]} {
            ixAccessImix configure -frameSize   $l3_imix1_size
            debug "ixAccessImix configure -frameSize   $l3_imix1_size"
            ixAccessImix configure -ratio       $l3_imix1_ratio
            debug "ixAccessImix configure -ratio       $l3_imix1_ratio"
            ixAccessImix configure -enable      $::true
            debug "ixAccessImix configure -enable      $::true"
            ixAccessImixTable addImix
            debug "ixAccessImixTable addImix"
        }
        if {[info exists l3_imix2_size]} {
            ixAccessImix configure -frameSize   $l3_imix2_size
            debug "ixAccessImix configure -frameSize   $l3_imix2_size"
            ixAccessImix configure -ratio       $l3_imix2_ratio
            debug "ixAccessImix configure -ratio       $l3_imix2_ratio"
            ixAccessImix configure -enable      $::true
            debug "ixAccessImix configure -enable      $::true"
            ixAccessImixTable addImix
            debug "ixAccessImixTable addImix"
        }
        if {[info exists l3_imix3_size]} {
            ixAccessImix configure -frameSize   $l3_imix3_size
            debug "ixAccessImix configure -frameSize   $l3_imix3_size"
            ixAccessImix configure -ratio       $l3_imix3_ratio
            debug "ixAccessImix configure -ratio       $l3_imix3_ratio"
            ixAccessImix configure -enable      $::true
            debug "ixAccessImix configure -enable      $::true"
            ixAccessImixTable addImix
            debug "ixAccessImixTable addImix"
        }
        if {[info exists l3_imix4_size]} {
            ixAccessImix configure -frameSize   $l3_imix4_size
            debug "ixAccessImix configure -frameSize   $l3_imix4_size"
            ixAccessImix configure -ratio       $l3_imix4_ratio
            debug "ixAccessImix configure -ratio       $l3_imix4_ratio"
            ixAccessImix configure -enable      $::true
            debug "ixAccessImix configure -enable      $::true"
            ixAccessImixTable addImix
            debug "ixAccessImixTable addImix"
        }
        
        if { [info exists l4_protocol] } {
            ixAccessLayer4Flows setDefault
            debug "ixAccessLayer4Flows setDefault"
            if { $l4_protocol == "udp" } {
                ixAccessLayer4Flows config -flowType $::kIxAccessFlowTypeUdp
                default "ixAccessLayer4Flows config -flowType $::kIxAccessFlowTypeUdp"
                if {[info exists udp_src_port]} {
                    ixAccessLayer4Flows config -sourcePort $udp_src_port
                    debug "ixAccessLayer4Flows config -sourcePort $udp_src_port"
                }
                if {[info exists udp_dst_port]} {
                    ixAccessLayer4Flows config -destinationPort $udp_dst_port
                    debug "ixAccessLayer4Flows config -destinationPort $udp_dst_port"
                }
            } else {
                ixAccessLayer4Flows config -flowType $::kIxAccessFlowTypeTcp
                debug "ixAccessLayer4Flows config -flowType $::kIxAccessFlowTypeTcp"
                if {[info exists tcp_src_port]} {
                    ixAccessLayer4Flows config -sourcePort $tcp_src_port
                    debug "ixAccessLayer4Flows config -sourcePort $tcp_src_port"
                }
                if {[info exists tcp_dst_port]} {
                    ixAccessLayer4Flows config -destinationPort $tcp_dst_port
                    debug "ixAccessLayer4Flows config -destinationPort $tcp_dst_port"
                }
            }
            ixAccessLayer4Flows config -numberOfFlows 1
            debug "ixAccessLayer4Flows config -numberOfFlows 1"
            ixAccessLayer4Flows set $thisCmd::chassis $thisCmd::card $thisCmd::port
            debug "ixAccessLayer4Flows set $thisCmd::chassis $thisCmd::card $thisCmd::port"
        }
    }
    namespace forget thisCmd
}


##Internal Procedure Header
# Name:
#    ::ixia::get_interface_entry_from_ip
#
# Description:
#    Get the interface entry from the given IP address.
#
# Synopsis:
#    ::ixia::get_interface_entry_from_ip
#        interface
#        ip_version
#        ip_address
#
# Arguments:
#    interface
#        Chassis, card, and port in the form a b c.
#    ip_version
#        One of 4 or 6, representing the IP version.
#    ip_address
#        IP Address to look for.
#
# Return Values:
#    -1 : If the ip_address is not found.
#    index: index of the interface table entry starting from 1.
# Examples:
#
proc ::ixia::get_interface_entry_from_ip { portList ip_version ip_address } {
    foreach interface $portList {
        scan $interface "%d %d %d" chassis card port
        
        interfaceTable select $chassis $card $port
        set status [interfaceTable getFirstInterface]
        while { $status == 0 } {
            if {$ip_version == 4} {
                interfaceEntry getFirstItem addressTypeIpV4
                set entryIpAddress [interfaceIpV4 cget -ipAddress]
            } else {
                interfaceEntry getFirstItem addressTypeIpV6
                set entryIpAddress [interfaceIpV6 cget -ipAddress]
                set entryIpAddress [::ipv6::expandAddress $entryIpAddress]
            }
            if { $ip_address == $entryIpAddress } {
                
                return $interface
            }
            set status [interfaceTable getNextInterface]
        }
    }
    
    # No interface found
    return [list]
}


proc ::ixia::ixaccess_create_network_port { chassis card port } {
    variable emulation_handles_array
    
    ixAccessPort get $chassis $card $port
    debug "ixAccessPort get $chassis $card $port"
    if {[ixAccessPort cget -portState] == $::kIxAccessPortStateUnInitialized} {
        ixAccessPort config -portRole $::kIxNetworkRole
        debug "ixAccessPort config -portRole $::kIxNetworkRole"
        ixAccessPort config -portMode $::kIxAccessIP
        debug "ixAccessPort config -portMode $::kIxAccessIP"
        chassis getFromID $chassis
        port get $chassis $card $port
        portCpu get $chassis $card $port
        
        if {[port cget -transmitMode] == $::portTxPacketStreams} {
            ixAccessPort configure -txMode    $::kIxAccessPacketStream
            debug "ixAccessPort configure -txMode    $::kIxAccessPacketStream"
        } else {
            ixAccessPort configure -txMode    $::kIxAccessAdvanceStream
            debug "ixAccessPort configure -txMode    $::kIxAccessAdvanceStream"
        }
        ixAccessPort set $chassis $card $port
        debug "ixAccessPort set $chassis $card $port"
        ixAccessPort setHalProperties $chassis $card $port "chasip" \
                [chassis cget -ipAddress]
        
        debug "ixAccessPort setHalProperties $chassis $card $port \"chasip\" \
                [chassis cget -ipAddress]"
        
        ixAccessPort setHalProperties $chassis $card $port "portip" \
                [port cget -managerIp]
        
        debug "ixAccessPort setHalProperties $chassis $card $port \"portip\" \
                [port cget -managerIp]"
        
        ixAccessPort setHalProperties $chassis $card $port "memory" \
                [portCpu cget -memory]
        
        debug "ixAccessPort setHalProperties $chassis $card $port \"memory\" \
                [portCpu cget -memory]"
        
        set streamMode $::kIxAccessNoStreamTraffic
        if {[port isValidFeature $chassis $card $port portFeatureUdfTableMode]} {
            set streamMode [expr $streamMode | $::kIxAccessValueListUdf]
        }
        if {[port isValidFeature $chassis $card $port portFeatureTableUdf]} {
            set streamMode [expr $streamMode | $::kIxAccessTableModeUdf]
        }
        ixAccessPort setHalProperties $chassis $card $port "udf" $streamMode
        debug "ixAccessPort setHalProperties $chassis $card $port \"udf\" $streamMode"
        
        # This is required so that this port is known to IxAccess
        set retHandle "IxTclAccess/1/$chassis/$card/$port"
        set emulation_handles_array($chassis,$card,$port) $retHandle
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::ixaccess_traffic_config
#
# Description:
#     This command configures traffic streams on the specified port
#     for pppox.
#
# Synopsis:
#    ::ixia::ixaccess_traffic_config
#        -port_handle<^[0-9]+/[0-9]+/[0-9]+$>
#        -emulation_src_handle
#        -emulation_dst_handle
#        -mode<create|modify|remove|reset>
#        [-bidirectional<0|1>]
#        [-port_handle2<^[0-9]+/[0-9]+/[0-9]+$>]
#        [-stream_id<1-255>]
#        [-length_mode<fixed|imix>]
#        [-l3_length<20-9000>]
#        [-l3_imix1_size<-RANGE:32-9000>]
#        [-l3_imix1_ratio]
#        [-l3_imix2_size<-RANGE:32-9000>]
#        [-l3_imix2_ratio]
#        [-l3_imix3_size<-RANGE:32-9000>]
#        [-l3_imix3_ratio]
#        [-l3_imix4_size<-RANGE:32-9000>]
#        [-l3_imix4_ratio]
#        [-rate_pps]
#        [-rate_bps]
#        [-rate_percent<0-100>]
#        [-transmit_mode<continuous|random_speed|single_pkt|single_burst|
#                       multi_burst_continuous_burst>]
#        [-pkts_per_burst]
#        [-burst_loop_count]
#        [-inter_burst_gap]
#        [-inter_stream_gap]
#        [-mac_src<aa.bb.cc.dd.ee.ff>]
#        [-mac_src_mode<fixed>]
#        [-mac_dst<aa.bb.cc.dd.ee.ff>]
#        [-mac_dst_mode<fixed|discovery>]
#        [-mac_src2<aa.bb.cc.dd.ee.ff>]
#        [-mac_dst2<aa.bb.cc.dd.ee.ff>]
#        [-l3_protocol<ipv4|ipv6>]
#        [-ip_src_addr<-IP>]
#        [-ip_src_mode<fixed|emulation>]
#        [-ip_dst_addr<-IP>]
#        [-ip_dst_mode<fixed|emulation>]
#        [-ip_protocol<0-255>]
#        [-ip_precedence<0-7>]
#        [-ip_dscp<0-63>]
#        [-l4_protocol<tcp|udp>]
#        [-udp_src_port<0-65535>]
#        [-udp_dst_port<0-65535>]
#        [-tcp_src_port<0-65535>]
#        [-tcp_dst_port<0-65535>]
#x       [-data_pattern]
#x       [-data_pattern_mode<incr_byte|decr_byte|fixed|random|repeating>]
#x       [-frame_size<20-13312>]
#x       [-ip_cost<0|1>]
#x       [-ip_delay<0|1>]
#x       [-ip_reliability<0|1>]
#x       [-ip_reserved<0|1>]
#x       [-ip_throughput<0|1>]
#x       [-name]
#x       [-number_of_packets_per_stream]
#x       [-number_of_packets_tx]
#x       [-enable_pgid]
#x       [-pgid_value]
#x       [-qos_byte                   RANGE 0-127
#x                                    DEFAULT 0]
#x       [-qos_rate_mode              CHOICES percent pps bps
#x                                    DEFAULT bps]
#x       [-qos_rate                   NUMERIC]
#x       [-qos_atm_clp                CHOICES 0 1
#x                                    DEFAULT 0]
#x       [-qos_atm_efci               CHOICES 0 1
#x                                    DEFAULT 0]
#x       [-qos_atm_cr                 CHOICES 0 1
#x                                    DEFAULT 0]
#x       [-qos_fr_cr                  CHOICES 0 1
#x                                    DEFAULT 0]
#x       [-qos_fr_de                  CHOICES 0 1
#x                                    DEFAULT 0]
#x       [-qos_fr_becn                CHOICES 0 1
#x                                    DEFAULT 0]
#x       [-qos_fr_fecn                CHOICES 0 1
#x                                    DEFAULT 0]
#x       [-qos_ipv6_flow_label        RANGE 0-1048575
#x                                    DEFAULT 0]
#x       [-qos_ipv6_traffic_class     RANGE 0-255
#x                                    DEFAULT 0]
#x       [-session_traffic_stats      CHOICES 0 1
#x                                    DEFAULT 0]
#
# Arguments:
#    -port_handle
#        The port to for which to configure traffic.
#    -port_handle2
#        A second port for which to configure traffic configuration when
#        option "bidirectional" is enabled.
#    -emulation_src_handle
#        Optional. The handle used to retrieve information for L2 or L3 src
#        addresses.
#    -emulation_dst_handle
#        Optional. The handle used to retrieve information for L2 or L3 dst
#        addresses
#    -mode
#        What specific action is taken.  Valid choices are:
#        create - Create only one stream.
#        modify - Modify only one existing stream.
#        remove - Remove/disable an existing stream.
#        reset  - Remove all existing traffic setups.
#    -bidirectional
#        Whether traffic is setup to transmit in both directions. The two
#        ports receiving and transmitting are specified by options port_handle
#        and port_handle2. Option "l3_protocol" source and destination
#        addresses are swapped to get the traffic flowing in both directions.
#        The parameters are based on the port associated with port_handle and
#        are swapped for the port associated with port_handle2. MAC addresses
#        are handled in two ways: First, if the MAC destination addresses are
#        not provided, ARP is used to get the next hop MAC address based on
#        the gateway IP address set in the command interface_config. Second,
#        is to use option "mac_dst" and "mac_dst2" addresses provided by this
#        command. Option "mac_dst2" applies to the port associated with option
#        "port_handle2". Option "stream_id" is the same for both directions.
#        As for the Source MAC, you can use option "mac_src2" to configure the
#        MAC on the second port, and option "mac_dst2" to configure the
#        destination MAC on the second port if you are not using L2 next hop.
#        Valid choices are:
#        0 - Disabled.
#        1 - Enabled.
#    -stream_id
#        Required for -mode modify and remove calls. Stream ID is not required
#        for configuring a stream for the first time. In this case, the stream
#        ID is returned from the call.
#    -length_mode
#        Behavior of the packet size for a particular stream. Valid choices
#        are:
#        fixed
#        imix - Mix of packet sizes are specified using options
#               l3_imix1_size etc.
#    -l3_length
#        Packet size in bytes. Use this option in conjunction with option
#        "length_mode" set to fixed. Valid choices are between 40 and 64000,
#        inclusive.
#    -l3_imix1_size
#        First Packet size in bytes. Used if length_mode = imix.
#    -l3_imix1_ratio
#        Ratio of first packet size. Used if length_mode = imix.
#    -l3_imix2_size
#        Second Packet size in bytes. Used if length_mode = imix.
#    -l3_imix2_ratio
#        Ratio of second packet size. Used if length_mode = imix.
#    -l3_imix3_size
#        Third Packet size in bytes. Used if length_mode = imix.
#    -l3_imix3_ratio
#        Ratio of third packet size. Used if length_mode = imix.
#    -l3_imix4_size
#        Fourth Packet size in bytes. Used if length_mode = imix.
#    -l3_imix4_ratio
#        Ratio of fourth packet size. Used if length_mode = imix.
#    -rate_pps
#        Traffic rate to send in pps.
#    -rate_bps
#        Traffic rate to send in bps.
#    -rate_percent
#        Traffic rate in percent of line rate for the specified stream. Valid
#        choices are between 0.00 and 100.00, inclusive. (Default = 100.00)
#    -transmit_mode
#        Type of transmit mode to use. Note that all transmit modes need to
#        have one value set in either rate_pps, rate_bps, or rate_percent.
#        Valid choices are:
#        continuous
#        single_pkt
#        single_burst
#        multi_burst
#        continuous_burst
#    -pkts_per_burst
#        Number of packets to include in one burst.
#    -burst_loop_count
#        Number of times to transmit a burst.
#    -inter_burst_gap
#        Number of milliseconds between each burst in the loop count.
#    -inter_stream_gap
#        Number milliseconds between each stream configured.
#    -mac_src
#        Source MAC address for a particular stream. Valid formats are:
#        11:11:11:11:11:11
#        2222.2222.2222
#        {33 33 33 33 33 33}
#    -mac_src_mode
#        Behavior of the source MAC address for a particular stream. Valid
#        choices are:
#        fixed     - The Source MAC will be idle (same fo all packets).
#    -mac_dst
#        Destination MAC address for a particular stream. Valid formats are:
#        11:11:11:11:11:11
#        2222.2222.2222
#        {33 33 33 33 33 33}
#    -mac_dst_mode
#        Behavior of the destination MAC address for a particular stream.
#        Valid choices are:
#        fixed     - The destination MAC will be idle (same for all packets).
#        discovery - (default) The Destination MAC will match the MAC address
#                    received from the ARP request.
#    -mac_src2
#        Value of the source MAC address for port_handle2. This option applies
#        to bidirectional only. Valid MAC formats are:
#        11:11:11:11:11:11
#        2222.2222.2222
#        {33 33 33 33 33 33 }
#    -mac_dst2
#        Value of the destination MAC address for port_handle2. This option
#        applies to bidirectional only.  Valid MAC formats are:
#        11:11:11:11:11:11
#        2222.2222.2222
#        {33 33 33 33 33 33 }
#    -l3_protocol
#        Configures a layer 3 protocol header. This option specifies whether
#        to setup IPv4, or IPv6 packet. Configure the specifics using the
#        related options. Valid choices are:
#        ipv4
#        ipv6
#    -ip_src_addr
#        Source IP address of the packet.
#    -ip_src_mode
#        Source IP address mode. Valid choices are:
#        fixed             - The source IP address is the same for all packets.
#        emulation         - Source IP derived from the emulation handle.
#    -ip_dst_addr
#        Destination IP address of the packet.
#    -ip_dst_mode
#        Destination IP address mode. Valid choices are:
#        fixed             - The destination IP address is the same for all
#                            packets.
#        emulation         - Destination IP derived from the emulation handle.
#    -ip_protocol
#        L4 protocol in the IP header. Valid choices are between
#        0 and 255. (Default = 255)
#    -ip_precedence
#        Part of the Type of Service byte of the IP header datagram that
#        establishes precedence of delivery. Valid choices are between 0 and
#        7, inclusive.
#    -ip_dscp
#        DSCP prcedence for a particular stream. Valid choices are between 0
#        and 63, inclusive. (Default = 0)
#    -l4_protocol
#        In the layer 4 header in the IP-based packet, the layer 4 protocol.
#        Valid choices are:
#        tcp  - For IPv4 and IPv6.
#        udp  - For IPv4 and IPv6.
#    -udp_src_port
#        UDP source port for this particular stream. Valid choices are between
#        0 and 65535, inclusive.
#    -udp_dst_port
#        UDP destination port for this particular stream. Valid choices are
#        between 0 and 65535, inclusive.
#    -tcp_src_port
#        TCP source port for this particular stream. Valid choices are between
#        0 and 65535, inclusive.
#    -tcp_dst_port
#        TCP destination port for this particular stream. Valid choices are
#        between 0 and 65535, inclusive.
#x   -enable_data_integrity
#x       Whether data integrity checking is enabled. Valid choices are:
#x       0 - Disabled.
#x       1 - Enabled.
#x   -data_pattern
#x       Payload value in bytes. For example, you can specify a custom payload
#x       pattern like the following using option "data_pattern":
#x       00 44 00 44
#x   -data_pattern_mode
#x       Packet payload mode for a particular stream. Valid choices are:
#x       incr_byte - Data patterm increments each byte in the packet payload.
#x       decr_byte - Data patterm decrements each byte in the packet payload.
#x       fixed     - Data patterm is idle for each byte in the packet payload.
#x       random    - Data patterm is random for the packet payload.
#x       repeating - Data patterm repeats for the packet payload.
#x   -frame_size
#x       Actual total frame size coming out of the interface on the wire in
#x       bytes. Valid choices are between 20 and 13312, inclusive.
#x       (Default = 64)
#x   -integrity_signature
#x   -ip_cost
#x       Part of the Type of Service byte of the IP header datagram (bit 6).
#x       Valid choices are:
#x       0 - (default) Normal cost.
#x       1 - Low cost.
#x   -ip_delay
#x       Part of the Type of Service byte of the IP header datagram (bit 3).
#x       Valid choices are:
#x       0 - (default) Normal delay.
#x       1 - Low delay.
#x   -ip_reliability
#x       Part of the Type of Service byte of the IP header datagram (bit 5).
#x       Valid choices are:
#x       0 - (default) Normal reliability.
#x       1 - High reliability.
#x   -ip_reserved
#x       Part of the Type of Service byte of the IP header datagram (bit 7).
#x       Valid choices are:
#x       0 - (default)
#x       1
#x   -ip_throughput
#x       Part of the Type of Service byte of the IP header datagram (bit 4).
#x       Valid choices are:
#x       0 - (default) Normal throughput.
#x       1 - High throughput.
#x   -name
#x       Stream string identifier/name.
#x   -number_of_packets_per_stream
#x   -number_of_packets_tx
#x   -enable_pgid
#x   -pgid_value
#x   -qos_byte
#x       The combined value for the precedence, delay, throughput,reliability,
#x       reserved and cost bits.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = 0)
#x   -qos_rate_mode
#x       The means by which line rates will be specified. Valid choices are:
#x       percent - The line rate is expressed in percentage of maximum
#x                 line rate.
#x       pps     - The line rate is expressed in packets per second.
#x       bps     - The line rate is expressed in bits per second.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = bps)
#x   -qos_rate
#x       This is the data rate setting expressed. Default values are:
#x       5000000  - when -qos_rate_mode bps
#x       1000     - when -qos_rate_mode pps
#x       100      - when -qos_rate_mode percentage
#x       This rate represents the aggregated rate for all sessions belonging
#x       to the group. This is only for PPP, L2TP and L2TPv3 traffic.
#x   -qos_atm_clp
#x       The setting of the congestion loss priority bit.
#x       Valid only if -encap is a kind of atm encapsulation.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = 0)
#x   -qos_atm_efci
#x       The setting of the explicit forward congestion indication bit.
#x       Valid only if -encap is a kind of atm encapsulation.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = 0)
#x   -qos_atm_cr
#x       The setting of the command response bit.
#x       Valid only if -encap is a kind of atm encapsulation.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = 0)
#x   -qos_fr_cr
#x       The setting of the frame relay command response bit.
#x       Valid only if -encap is a kind of framerelay encapsulation.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = 0)
#x   -qos_fr_de
#x       The setting of the frame relay discard eligibility bit.
#x       Valid only if -encap is a kind of framerelay encapsulation.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = 0)
#x   -qos_fr_becn
#x       The setting of the frame relay backward congestion notification bit.
#x       Valid only if -encap is a kind of framerelay encapsulation.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = 0)
#x   -qos_fr_fecn
#x       The setting of the frame relay forward congestion notification bit.
#x       Valid only if -encap is a kind of framerelay encapsulation.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = 0)
#x   -qos_ipv6_flow_label
#x       The IPv6 flow label, from 0 through 1,048,575.
#x       Valid only if –encap is an ethernet encapsulation.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = 0)
#x   -qos_ipv6_traffic_class
#x       The IPv6 traffic class, from 0 through 255.
#x       Valid only if –encap is an ethernet encapsulation.
#x       This is only for PPP, L2TP and L2TPv3 traffic.
#x       (DEFAULT = 0)
#x   -l7_traffic
#x       If true, then layer 7 traffic using an external program is
#x       performed.
#x       (DEFAULT = 0)
#x   -duration
#x       The duration, in seconds, to run each frame size or mix of
#x       frame sizes.
#x       (DEFAULT = 10)
#x   -pppoe_unique_acmac
#x       If true, then the MAC address used for each access
#x       concentrator is unique.Streams will be configured using a
#x       separate UDF for the AC’s MAC address.
#x       (DEFAULT = 0)
#x   -variable_user_rate
#x       If true, each user group transmits at a different data rate.
#x       (DEFAULT = 0)
#x   -session_repeat_count
#x       The number of times that the traffic will be repeated. Legal
#x       values are between 1 and 8000.
#x       (DEFAULT = 1)
#x   -session_traffic_stats
#x       In order to retrieve per session traffic stats for PPP or L2TP, then
#x       this option should be 1. Values are 0 or 1.
#x       (DEFAULT = 0)
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:stream_id    value:Stream identifier when not bidirectional.
#    key:stream_id.$port_handle     value:Stream identifier for traffic sent
#                                         out the port associated with
#                                         "port_handle".
#    key:stream_id.$port_handle2    value:Stream identifier for traffic sent
#                                         out the port associated with
#                                         "port_handle2".
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#   1) enable_pgid: Needs to be one for now.
#   2) pattern: User defined pattern has not been implemented. Also it is
#      not possible to define the data pattern for L2TP mode as this is used
#      internally for constructing L2TP streams.
#
# See Also:
#
proc ::ixia::ixaccess_traffic_config { args } {
    variable reserved_port_list
    variable emulation_handles_array
    variable ixaccess_traffic_ports
    variable noQoSUsers
    variable current_streamid
    variable pgid_to_stream
    variable no_of_streams_per_port
    
    set procName [lindex [info level [info level]] 0]
    set is_multicast 0
    
    # _device is a global used to provide ip address to host name conversions
    global _device
    
    set mandatory_args {
        -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -mode        CHOICES create reset
    }
    
    set opt_args {
        -port_handle2         REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -emulation_src_handle REGEXP ^IxTclAccess/[0-9]+/[0-9]+/[0-9]+/[0-9]+$
        -emulation_dst_handle REGEXP ^IxTclAccess/[0-9]+/[0-9]+/[0-9]+/[0-9]+$
        -bidirectional        CHOICES 0 1
                              DEFAULT 0
        -stream_id            RANGE 1-255
        -length_mode          CHOICES fixed imix
        -l3_length            RANGE 32-9000
        -l3_imix1_size        RANGE 32-9000
        -l3_imix1_ratio
        -l3_imix2_size        RANGE 32-9000
        -l3_imix2_ratio
        -l3_imix3_size        RANGE 32-9000
        -l3_imix3_ratio
        -l3_imix4_size        RANGE 32-9000
        -l3_imix4_ratio
        -rate_pps
        -rate_bps
        -rate_percent         RANGE 0-100
        -transmit_mode        CHOICES continuous single_pkt single_burst
                              CHOICES multi_burst continuous_burst
        -pkts_per_burst
        -burst_loop_count
        -inter_burst_gap
        -inter_stream_gap
        -mac_src
        -mac_dst
        -mac_dst_mode                   CHOICES fixed discovery
        -mac_src2
        -mac_dst2
        -l3_protocol                    CHOICES ipv4 ipv6
        -ip_src_addr                    IP
        -ip_src_mode                    CHOICES fixed increment emulation
        -ip_src_count                   RANGE 1-32000
        -ip_src_step                    IP
                                        DEFAULT 0.0.0.1
        -ip_dst_addr                    IP
        -ip_dst_mode                    CHOICES fixed increment emulation
        -ip_dst_count                   RANGE 1-32000
        -ip_dst_step                    IP
                                        DEFAULT 0.0.0.1
        -host_behind_network            IP
        -ip_protocol                    RANGE 0-255
        -ip_precedence                  RANGE 0-7
        -ip_dscp                        RANGE 0-63
        -l4_protocol                    CHOICES tcp udp
        -udp_src_port                   RANGE 0-65535
        -udp_dst_port                   RANGE 0-65535
        -tcp_src_port                   RANGE 0-65535
        -tcp_dst_port                   RANGE 0-65535
        -data_pattern
        -data_pattern_mode              CHOICES incr_byte decr_byte fixed
                                        CHOICES random repeating
        -ip_cost                        CHOICES 0 1
        -ip_delay                       CHOICES 0 1
        -ip_reliability                 CHOICES 0 1
        -ip_reserved                    CHOICES 0 1
        -ip_throughput                  CHOICES 0 1
        -name
        -number_of_packets_per_stream   RANGE 3-9999999999
        -enable_pgid                    CHOICES 1 1
        -pgid_value
        -number_of_packets_tx
        -l7_traffic                     CHOICES 0 1
        -duration                       NUMERIC
        -pppoe_unique_acmac             CHOICES 0 1
        -variable_user_rate             CHOICES 0 1
        -session_repeat_count           RANGE 1-8000
        -ipv6_traffic_class             RANGE 0-255
        -ipv6_flow_label                RANGE 0-1048575
        -public_port_ip                 IP
        -qos_rate_mode                  CHOICES percent pps bps
        -qos_rate                       NUMERIC
        -qos_byte                       RANGE 0-127
        -qos_atm_clp                    CHOICES 0 1
        -qos_atm_efci                   CHOICES 0 1
        -qos_atm_cr                     CHOICES 0 1
        -qos_fr_cr                      CHOICES 0 1
        -qos_fr_de                      CHOICES 0 1
        -qos_fr_becn                    CHOICES 0 1
        -qos_fr_fecn                    CHOICES 0 1
        -qos_ipv6_flow_label            RANGE 0-1048575
        -qos_ipv6_traffic_class         RANGE 0-255
        -session_traffic_stats          CHOICES 0 1
                                        DEFAULT 0
        -enable_voice                   CHOICES 0 1
                                        DEFAULT 0
        -enable_data                    CHOICES 0 1
                                        DEFAULT 0
        -voice_tos                      RANGE   0-255
        -data_tos                       RANGE   0-255
        -traffic_generator              CHOICES ixaccess ixos
                                        DEFAULT ixaccess
        -no_write
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args \
                    $opt_args -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Parameter not supported\
                for PPP and L2tp emulations. $retError"
        return $returnList
    }
    
    keylset returnList status $::FAILURE
    
    set subPortId 0
    # This routine should only have one value in the port_handle.  Since
    # the parser will accept multiples, we need a separate check directly
    # after parsing to stop if more than one value.  If two ports are to
    # have streams created, it will be through the use of the bidirectional
    # and port_handle2 options
    if {[llength $port_handle] > 1} {
        keylset returnList log "ERROR in $procName: The port_handle contains\
                more than one value."
        return $returnList
    }
    
    # Set chassis card port
    foreach {chassis card port} [split $port_handle /] {}
    set txPortList [list [list $chassis $card $port]]
    
    # Check for the bidirectional flag and port_handle2
    if {$bidirectional && ![info exists port_handle2]} {
       keylset returnList log "ERROR in $procName: The bidirectional\
               flag was enabled but no port_handle2 was passed in."
       return $returnList
    }
    if {!$bidirectional} {
        set emulation_handles_array($chassis,$card,$port,unidirectional) 1
    }
    
    # Check for source and destination emulation
    set isSrcEmulating 0
    set isDstEmulating 0
    if { [info exists ip_src_mode] && $ip_src_mode == "emulation" } {
        if {![info exists emulation_src_handle]} {
            keylset returnList log "ERROR in $procName: When ip_src_mode is\
                    emulation, then emulation_src_handle must be present"
            return $returnList
        }
        set isSrcEmulating 1
    } elseif { ![info exists ip_src_addr] } {
        
        keylset returnList log "ERROR in $procName: ip_src_addr is\
                not set when the ip_src_mode is not emulation"
        return $returnList
    }
    if { [info exists ip_dst_mode] && $ip_dst_mode == "emulation" } {
        if {![info exists emulation_dst_handle]} {
            keylset returnList log "ERROR in $procName: When ip_dst_mode is\
                    emulation, then emulation_dst_handle must be present"
            return $returnList
        }
        set isDstEmulating 1
    } elseif { ![info exists ip_dst_addr] } {
        keylset returnList log "ERROR in $procName: ip_dst_addr is\
                not set when the ip_dst_mode is not emulation"
        return $returnList
    }
    
    if {!$bidirectional && !$isDstEmulating && ![info exists port_handle2]} {
        keylset returnList log "ERROR in $procName: When configuring\
                unidirectional traffic with just one emulation the\
                port_handle2 option must be provided."
        return $returnList
    }
    
    if {$isDstEmulating} {
        set interface2 [array names emulation_handles_array *,$emulation_dst_handle]
        foreach {chassis2 card2 port2 ignore} [split $interface2 ","] {}
    } else  {
        foreach {chassis2 card2 port2 } [split $port_handle2 "/"] {}
    }
    set rxPortList [list [list $chassis2 $card2 $port2]]
    
    set ip_gw_addr "0.0.0.0"
    # Add the network port in the DLL if not already defined
    # This is the downstream case
    if { $isSrcEmulating == 0 } {
        set status [ixAccessSetupPorts [list [list $chassis $card $port]]]
        debug "ixAccessSetupPorts [list [list $chassis $card $port]]"
        if {$status} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : Call to ixAccessSetupPorts\
                    [list [list $chassis $card $port]] failed.  IxAccess status : \
                    $status."
            return $returnList
        }
        # Add the port_handle as the network IP port
        ixaccess_create_network_port $chassis $card $port
        
        # Setup Subport parameters
        ixAccessSubPort get $chassis $card $port $subPortId
        debug "ixAccessSubPort get $chassis $card $port $subPortId"
        ixAccessSubPort configure -portMode      $::kIxAccessIP
        debug "ixAccessSubPort configure -portMode      $::kIxAccessIP"
        if {[info exists ip_src_count]} {
            ixAccessSubPort configure -numSessions   $ip_src_count
            debug "ixAccessSubPort configure -numSessions   $ip_src_count"
        } else  {
            ixAccessSubPort configure -numSessions   1
            debug "ixAccessSubPort configure -numSessions   1"
        }
        # check if we have multicast
        if {[info exists \
                    emulation_handles_array(mc_group,$chassis2,$card2,$port2,0)]} {
            ixAccessSubPort configure -enableMulticast 1
            set is_multicast 1
        }
        ixAccessSubPort set $chassis $card $port $subPortId
        
        set gwConfig [list \
                chassis                 chassis             \
                card                    card                \
                port                    port                \
                server_ip               ip_src_addr         \
                server_ip_step          ip_src_step         \
                port_list               txPortList          \
                mac_src                 mac_src             \
                mac_dst                 mac_dst             \
                num_addr                ip_src_count        \
                host_behind_network     host_behind_network \                
                ]
        
        foreach {parmName varName} $gwConfig {
            if {[info exists $varName]} {
                append gwStrConfig " -$parmName [set $varName] "
            }
        }
        
        set retCode [eval "ixaccess_create_gateway_table $gwStrConfig"]
        
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName: \
                    [keylget retCode log]"
            return $returnList
        }
        set ip_gw_addr [keylget retCode gateway_ip]
    }
    
    # This is the upstream case
    if { $isDstEmulating == 0 } {
        set status [ixAccessSetupPorts [list [list $chassis2 $card2 $port2]]]
        debug "ixAccessSetupPorts [list [list $chassis2 $card2 $port2]]"
        if {$status} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : Call to ixAccessSetupPorts\
                    [list [list $chassis2 $card2 $port2]] failed.  IxAccess status : \
                    $status."
            return $returnList
        }
        
        # Add the port_handle2 as the network IP port
        ixaccess_create_network_port $chassis2 $card2 $port2
        
        # Setup Subport parameters
        ixAccessSubPort get $chassis2 $card2 $port2 $subPortId
        debug "ixAccessSubPort get $chassis2 $card2 $port2 $subPortId"
        ixAccessSubPort configure -portMode        $::kIxAccessIP
        debug "ixAccessSubPort configure -portMode        $::kIxAccessIP"
        
        if {[info exists ip_dst_count]} {
            ixAccessSubPort configure -numSessions   $ip_dst_count
            debug "ixAccessSubPort configure -numSessions   $ip_dst_count"
        } else  {
            ixAccessSubPort configure -numSessions   1
            debug "ixAccessSubPort configure -numSessions   1"
        }
        if {[info exists \
                    emulation_handles_array(mc_group,$chassis,$card,$port,0)]} {
            ixAccessSubPort configure -enableMulticast 1
            set is_multicast 1
        }
        ixAccessSubPort set $chassis2 $card2 $port2 $subPortId
        
        set gwConfig [list \
                chassis                 chassis2                \
                card                    card2                   \
                port                    port2                   \
                server_ip               ip_dst_addr             \
                server_ip_step          ip_dst_step             \
                port_list               rxPortList              \
                mac_src                 mac_src2                \
                mac_dst                 mac_dst2                \
                num_addr                ip_dst_count            \
                host_behind_network     host_behind_network     \
				]
        
        foreach {parmName varName} $gwConfig {
            if {[info exists $varName]} {
                append gwStrConfig " -$parmName [set $varName] "
            }
        }
        
        set retCode [eval "ixaccess_create_gateway_table $gwStrConfig"]
        
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName: \
                    [keylget retCode log]"
            return $returnList
        }
        set ip_gw_addr [keylget retCode gateway_ip]
    }
    
    # Collect the list of ports for getting interface table
    
    if { $isSrcEmulating } {
        ixAccessPort get $chassis $card $port
        debug "ixAccessPort get $chassis $card $port"
        set portMode [ixAccessPort cget -portMode]
        set subPortId $emulation_handles_array($chassis,$card,$port,$emulation_src_handle)
        
        debug "ixAccessPort cget -portRole"
        if { [ixAccessPort cget -portRole] == $::kIxAccessRole } {
            # Source emulation - Access Role
            # Make sure that the ip_src_mode is set to emulation
            if {![info exists ip_src_mode] || $ip_src_mode != "emulation"} {
                keylset returnList log "ERROR: Access Port needs to have source \
                        mode set to emulation."
                return $returnList
            }
            if {![info exists ip_src_count] || $ip_src_count == 0} {
                keylset returnList log "ERROR: Access Port needs to have source \
                        count set"
                return $returnList
            }
            set numSessions $ip_src_count
            
            # QoS setting if required
            set qosParamsList [list \
                    qos_rate_mode qos_rate qos_byte qos_atm_clp qos_atm_efci \
                    qos_atm_cr qos_fr_cr qos_fr_de qos_fr_becn qos_fr_fecn   \
                    qos_ipv6_flow_label qos_ipv6_traffic_class               ]
            
            set qosConfigDefault "\
                    -port_handle $chassis/$card/$port   \
                    -handle      $emulation_src_handle  \
                    -sessions    $numSessions           "
            
            set qosConfigList ""
            foreach {qosParam} $qosParamsList {
                if {[info exists $qosParam]} {
                    append qosConfigList " -$qosParam [set $qosParam]"
                }
            }
            catch {unset qosGroupId}
            if {$qosConfigList != ""} {
                append qosConfigDefault $qosConfigList
                set retCode [eval ::ixia::ixaccess_create_qos $qosConfigDefault]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList log "ERROR in $procName: [keylget retCode log]"
                    return $returnList
                }
                set qosGroupId [keylget retCode group]
            } elseif {[info exists variable_user_rate] && $variable_user_rate} {
                keylset returnList log "ERROR in $procName: -variable_user_rate \
                        option was enabled, but no QOS options are present."
                return $returnList
            }
            
            # An access port is the transmitted port
            debug "ixaccess_set_traffic_options $chassis $card $port"
            ixaccess_set_traffic_options $chassis $card $port
            
            ixAccessTrafficUserTable select  $chassis $card $port $subPortId
            debug "ixAccessTrafficUserTable select  $chassis $card $port $subPortId"
            
            set mcIndex mc_group,$chassis,$card,$port,$subPortId
            # check if we have multicast traffic
            if {[info exists emulation_handles_array($mcIndex)]} {
                set traffic_indicator "multicast"
            } else  {
                set traffic_indicator "other"
            }
            set parm_port_handle port_handle2
            ixaccess_set_traffic_user_options
            
            set status [ixAccessTrafficUserTable addTrafficUser]
            debug "ixAccessTrafficUserTable addTrafficUser"
            if { $status } {
                keylset returnList log "ERROR: Unable to add range for interface \
                        table upload"
                return $returnList
            }
            
            # If qos was enabled we must check whether previously created
            # streams are assigned to any qos group
            if {[info exists noQoSUsers] && [info exists qosGroupId]} {
                foreach qosUser $noQoSUsers {
                    set status [ixAccessTrafficUserTable getTrafficUser $qosUser]
                    debug "ixAccessTrafficUserTable getTrafficUser $qosUser"
                    if { $status } {
                        keylset returnList log "ERROR: Unable to \
                                ixAccessTrafficUserTable getTrafficUser $qosUser"
                        return $returnList
                    }
                    ixAccessTrafficUser config -qosGroupId $qosGroupId
                    debug "ixAccessTrafficUser config -qosGroupId $qosGroupId"
                    
                    set status [ixAccessTrafficUserTable updateTrafficUser]
                    debug "ixAccessTrafficUserTable updateTrafficUser"
                    if { $status } {
                        keylset returnList log "ERROR: Unable to update range \
                                for interface table upload"
                        return $returnList
                    }
                }
                unset noQoSUsers
            }
            
            if {[info exists emulation_handles_array($mcIndex)]} {
                # check if we have voice unicast enabled
                if {$enable_voice == 1} {
                    set traffic_indicator "voice"
                    ixaccess_set_traffic_user_options
                    
                    set status [ixAccessTrafficUserTable addTrafficUser]
                    debug "ixAccessTrafficUserTable addTrafficUser"
                    if { $status } {
                        keylset returnList log "ERROR: Unable to add range for interface \
                                table upload"
                        return $returnList
                    }
                }
                # check if we have data unicast enabled
                if {$enable_data == 1} {
                    set traffic_indicator "data"
                    ixaccess_set_traffic_user_options
                    
                    set status [ixAccessTrafficUserTable addTrafficUser]
                    debug "ixAccessTrafficUserTable addTrafficUser"
                    if { $status } {
                        keylset returnList log "ERROR: Unable to add range for interface \
                                table upload"
                        return $returnList
                    }
                }
            }
            
            if {!$isDstEmulating} {
                # Destination IP - Network Role
                ixAccessPort get $chassis2 $card2 $port2
                debug "ixAccessPort get $chassis2 $card2 $port2"
                set portMode    [ixAccessPort cget -portMode]
                set numSessions [ixAccessPort cget -numSessions]
                if {$bidirectional} {
                    debug "ixaccess_set_traffic_options $chassis2 $card2 $port2"
                    ixaccess_set_traffic_options $chassis2 $card2 $port2
                }
            }
        } else {
            # source IP - Network Role
            ixAccessPort get $chassis $card $port
            debug "ixAccessPort get $chassis $card $port"
            set portMode    [ixAccessPort cget -portMode]
            set numSessions [ixAccessPort cget -numSessions]
            
            debug "ixaccess_set_traffic_options $chassis $card $port"
            ixaccess_set_traffic_options $chassis $card $port
        }
    }
    if {$isDstEmulating} {
        ixAccessPort get $chassis2 $card2 $port2
        debug "ixAccessPort get $chassis2 $card2 $port2"
        set portMode [ixAccessPort cget -portMode]
        set subPortId $emulation_handles_array($chassis2,$card2,$port2,$emulation_dst_handle)
        
        debug "ixAccessPort cget -portRole"
        if { [ixAccessPort cget -portRole] == $::kIxAccessRole } {
            # Destination emulation - Access Role
            # Make sure that the ip_dst_mode is set to emulation
            if {![info exists ip_dst_mode] || $ip_dst_mode != "emulation"} {
                keylset returnList log "ERROR: Access Port needs to have destination \
                        mode set to emulation."
                return $returnList
            }
            if {![info exists ip_dst_count] || $ip_dst_count == 0} {
                keylset returnList log "ERROR: Access Port needs to have destination \
                        count set"
                return $returnList
            }
            set numSessions $ip_dst_count
            
            # QoS setting if required
            set qosParamsList [list \
                    qos_rate_mode qos_rate qos_byte qos_atm_clp qos_atm_efci \
                    qos_atm_cr qos_fr_cr qos_fr_de qos_fr_becn qos_fr_fecn   \
                    qos_ipv6_flow_label qos_ipv6_traffic_class               ]
            
            set qosConfigDefault "\
                    -port_handle $chassis2/$card2/$port2 \
                    -handle      $emulation_dst_handle   \
                    -sessions    $numSessions            "
            
            set qosConfigList ""
            foreach {qosParam} $qosParamsList {
                if {[info exists $qosParam]} {
                    append qosConfigList " -$qosParam [set $qosParam]"
                }
            }
            catch {unset qosGroupId}
            if {$qosConfigList != ""} {
                append qosConfigDefault $qosConfigList
                set retCode [eval ::ixia::ixaccess_create_qos $qosConfigDefault]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList log "ERROR in $procName: [keylget retCode log]"
                    return $returnList
                }
            set qosGroupId [keylget retCode group]
            }
        
            # An access port is the receiving port
            if {$bidirectional} {
                debug "ixaccess_set_traffic_options $chassis2 $card2 $port2"
                ixaccess_set_traffic_options $chassis2 $card2 $port2
            }
            ixAccessTrafficUserTable select $chassis2 $card2 $port2 $subPortId
            debug "ixAccessTrafficUserTable select $chassis2 $card2 $port2 $subPortId"
            
            set mcIndex mc_group,$chassis2,$card2,$port2,$subPortId
            set parm_port_handle port_handle
            
            # check if we have multicast traffic
            if {[info exists emulation_handles_array($mcIndex)]} {
                set traffic_indicator "multicast"
            } else  {
                set traffic_indicator "other"
            }
            ixaccess_set_traffic_user_options
            
            set status [ixAccessTrafficUserTable addTrafficUser]
            debug "ixAccessTrafficUserTable addTrafficUser"
            if { $status } {
                keylset returnList log "ERROR: Unable to add range for interface \
                        table upload"
                return $returnList
            }
            
            # If qos was enabled we must check whether previously created
            # streams are assigned to any qos group
            if {[info exists noQoSUsers] && [info exists qosGroupId]} {
                foreach qosUser $noQoSUsers {
                    set status [ixAccessTrafficUserTable getTrafficUser $qosUser]
                    debug "ixAccessTrafficUserTable getTrafficUser $qosUser"
                    if { $status } {
                        keylset returnList log "ERROR: Unable to \
                                ixAccessTrafficUserTable getTrafficUser $qosUser"
                        return $returnList
                    }
                    ixAccessTrafficUser config -qosGroupId $qosGroupId
                    debug "ixAccessTrafficUser config -qosGroupId $qosGroupId"
                    
                    set status [ixAccessTrafficUserTable updateTrafficUser]
                    debug "ixAccessTrafficUserTable updateTrafficUser"
                    if { $status } {
                        keylset returnList log "ERROR: Unable to update range \
                                for interface table upload"
                        return $returnList
                    }
                }
                unset noQoSUsers
            }
            
            if {[info exists emulation_handles_array($mcIndex)]} {
                # check if we have voice unicast enabled
                if {$enable_voice == 1} {
                    set traffic_indicator "voice"
                    ixaccess_set_traffic_user_options
                    
                    set status [ixAccessTrafficUserTable addTrafficUser]
                    debug "ixAccessTrafficUserTable addTrafficUser"
                    if { $status } {
                        keylset returnList log "ERROR: Unable to add range for interface \
                                table upload"
                        return $returnList
                    }
                }
                # check if we have data unicast enabled
                if {$enable_data == 1} {
                    set traffic_indicator "data"
                    ixaccess_set_traffic_user_options
                    
                    set status [ixAccessTrafficUserTable addTrafficUser]
                    debug "ixAccessTrafficUserTable addTrafficUser"
                    if { $status } {
                        keylset returnList log "ERROR: Unable to add range for interface \
                                table upload"
                        return $returnList
                    }
                }
            }
            if {!$isSrcEmulating} {
                # Source IP - Network Role
                ixAccessPort get $chassis $card $port
                debug "ixAccessPort get $chassis $card $port"
                set portMode    [ixAccessPort cget -portMode]
                set numSessions [ixAccessPort cget -numSessions]
                
                debug "ixaccess_set_traffic_options $chassis $card $port"
                ixaccess_set_traffic_options $chassis $card $port
            }
        } else {
            # Destination IP - Network Role
            ixAccessPort get $chassis2 $card2 $port2
            debug "ixAccessPort get $chassis2 $card2 $port2"
            set portMode    [ixAccessPort cget -portMode]
            set numSessions [ixAccessPort cget -numSessions]
            
            if {$bidirectional} {
                debug "ixaccess_set_traffic_options $chassis2 $card2 $port2"
                ixaccess_set_traffic_options $chassis2 $card2 $port2
            }
        }
    }


    if {$bidirectional} {
        set status [::ixia::ixaccess_set_traffic_ports $txPortList "bidirectional"]
        if {[keylget status status] != $::SUCCESS} {
            return $status
        }
        set status [::ixia::ixaccess_set_traffic_ports $rxPortList "bidirectional"]
        if {[keylget status status] != $::SUCCESS} {
            return $status
        }
    } else {
        set status [::ixia::ixaccess_set_traffic_ports $txPortList "tx"]
        if {[keylget status status] != $::SUCCESS} {
            return $status
        }
        set status [::ixia::ixaccess_set_traffic_ports $rxPortList "rx"]
        if {[keylget status status] != $::SUCCESS} {
            return $status
        }
    }

    keylset returnList status $::SUCCESS   
    if {![info exists no_write]} {
        set txPorts $::ixia::ixaccess_traffic_ports(tx_ports)
        set rxPorts $::ixia::ixaccess_traffic_ports(rx_ports)
        debug "ixAccessConfigTraffic $txPorts $rxPorts no"
        
        set stream_id_list [ixAccessConfigTraffic $txPorts $rxPorts "no"]
        
        if { [llength $stream_id_list] == 0 } {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR: Unable to configure traffic"
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS

    foreach {t_ch t_ca t_po} [split $port_handle "/"] {}
    incr current_streamid
    if {![info exists no_of_streams_per_port($port_handle)]} {
        set no_of_streams_per_port($port_handle) 0
    }
    incr no_of_streams_per_port($port_handle)
    
    set pgid_to_stream($current_streamid) \
                $t_ch,$t_ca,$t_po,$no_of_streams_per_port($port_handle)
    
    keylset returnList stream_id $current_streamid
    
    if { $bidirectional } {
        keyldel returnList stream_id
        keylset returnList stream_id.$port_handle $current_streamid

        foreach {t_ch t_ca t_po} [split $port_handle2 "/"] {}
        incr current_streamid
        if {![info exists no_of_streams_per_port($port_handle2)]} {
            set no_of_streams_per_port($port_handle2) 0
        }
        incr no_of_streams_per_port($port_handle2)
        set pgid_to_stream($current_streamid) \
                $t_ch,$t_ca,$t_po,$no_of_streams_per_port($port_handle2)

        keylset returnList stream_id.$port_handle2 $current_streamid
    }
    return $returnList
}                                                                    


proc ::ixia::ixaccess_create_gateway_table {args} {
    set mandatory_args {
        -chassis     NUMERIC
        -card        NUMERIC
        -port        NUMERIC
        -server_ip   IP
        -port_list
    }

    set opt_args {
        -num_addr               NUMERIC
                                DEFAULT 1
        -server_ip_step         IP
                                DEFAULT 0.0.0.1
        -mac_src
        -mac_dst
        -host_behind_network    IP
    }

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args \
            $opt_args -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    keylset returnList status $::FAILURE

    set port_list [::ixia::format_space_port_list $port_list]
    ixAccessGatewayTable select $chassis $card $port
    debug "ixAccessGatewayTable select $chassis $card $port"
    ixAccessGatewayTable clearAllGateways
    debug "ixAccessGatewayTable clearAllGateways"
    ixAccessGateway setDefault
    debug "ixAccessGateway setDefault"
    ixAccessGateway configure -destIp		 "0.0.0.0"
    debug "ixAccessGateway configure -destIp		 0.0.0.0"
    ixAccessGateway configure -destMask	"0.0.0.0"
    debug "ixAccessGateway configure -destMask		 0.0.0.0"
    ixAccessGateway configure -serverIp $server_ip
    debug "ixAccessGateway configure -serverIp $server_ip"

    set server_ip_start $server_ip
    if {[info exists mac_src]} {
        set mac_src_start $mac_src
    }
    for {set i 0} {$i < $num_addr} {incr i} {
        # Find the ip entry & Add the default gateway table entry
        set status [get_interface_entry_from_ip $port_list 4 $server_ip]
        if { [llength $status] } {
            if {$i == 0} {
                set gateway_ip [interfaceIpV4 cget -gatewayIpAddress]
                keylset returnList gateway_ip $gateway_ip
                ixAccessGateway configure -gwIp      $gateway_ip
                debug "ixAccessGateway configure -gwIp $gateway_ip"
                ixAccessGateway configure -enableArp $::true
                debug "ixAccessGateway configure -enableArp $::true"
            }
            if { ![info exists mac_src] } {
                set mac_src_start [interfaceEntry cget -macAddress]
            }
            
            # Also update the addrlist object for the port including data offset
            ixAccessAddrList get $chassis $card $port
            debug "ixAccessAddrList get $chassis $card $port"
            ixAccessAddrList config -enableIp   $::true
            debug "ixAccessAddrList config -enableIp   $::true"
            ixAccessAddrList config -enableVlan \
                    [interfaceEntry cget -enableVlan]
            
            debug "ixAccessAddrList config -enableVlan \
                    [interfaceEntry cget -enableVlan]"
            
            ixAccessAddrList config -encapsulation \
                    [interfaceEntry cget -atmEncapsulation]
            
            debug "ixAccessAddrList config -encapsulation \
                    [interfaceEntry cget -atmEncapsulation]"
            
            set net_addr_not_exists [ixAccessAddrList getAddr \
                    "Addr_$server_ip"]
            
            ixAccessAddrList set $chassis $card $port
            debug "ixAccessAddrList set $chassis $card $port"
            
            # Configure all interface options
            if {$net_addr_not_exists} {
                ixAccessAddr setDefault
                debug "ixAccessAddr setDefault"
                ixAccessAddr configure -addrId        "Addr_$server_ip"
                debug "ixAccessAddr configure -addrId        \"Addr_$server_ip\""
                ixAccessAddr configure -numAddress    1
                debug "ixAccessAddr configure -numAddress    1"
                ixAccessAddr configure -baseMac       $mac_src_start
                debug "ixAccessAddr configure -baseMac       $mac_src_start"
                ixAccessAddr configure -baseIP        $server_ip
                debug "ixAccessAddr configure -baseIP        $server_ip"
                ixAccessAddr configure -gatewayIP     $gateway_ip
                debug "ixAccessAddr configure -gatewayIP     $gateway_ip"
                ixAccessAddr configure -incrOctet     1
                debug "ixAccessAddr configure -incrOctet     1"
                ixAccessAddr configure -baseIpIncr    1
                debug "ixAccessAddr configure -baseIpIncr    1"
                ixAccessAddr configure -gatewayIpIncr 1
                debug "ixAccessAddr configure -gatewayIpIncr 1"
                
                if [port isValidFeature $chassis $card $port $::portFeatureAtm] {
                    ixAccessAddr configure -firstVpi           \
                    [interfaceEntry cget -atmVpi]
                    
                    debug "ixAccessAddr configure -firstVpi    \
                    [interfaceEntry cget -atmVpi]"
                    
                    ixAccessAddr configure -vpiStep     1
                    debug "ixAccessAddr configure -vpiStep     1"
                    
                    ixAccessAddr configure -vpiCount    1
                    debug "ixAccessAddr configure -vpiCount    1"
                    
                    ixAccessAddr configure -firstVci           \
                    [interfaceEntry cget -atmVci]
                    
                    debug "ixAccessAddr configure -firstVci    \
                    [interfaceEntry cget -atmVci]"
                    
                    ixAccessAddr configure -vciStep      1
                    debug "ixAccessAddr configure -vciStep      1"
                    
                    ixAccessAddr configure -vciCount     1
                    debug "ixAccessAddr configure -vciCount     1"
                    
                    ixAccessAddr configure -addressPerVc 1
                    debug "ixAccessAddr configure -addressPerVc 1"
                    ixAccessAddr configure -mask         \
                    [interfaceIpV4 cget -maskWidth]
                    
                    debug "ixAccessAddr configure -mask         \
                    [interfaceIpV4 cget -maskWidth]"
                    
                } elseif { [interfaceEntry cget -enableVlan] } {
                    ixAccessAddr configure -firstVlanId         \
                    [interfaceEntry cget -vlanId]
                    
                    debug "ixAccessAddr configure -firstVlanId  \
                    [interfaceEntry cget -vlanId]"
                    
                    ixAccessAddr configure -vlanIdStep         1
                    debug "ixAccessAddr configure -vlanIdStep         1"
                    ixAccessAddr configure -vlanIdCount        1
                    debug "ixAccessAddr configure -vlanIdCount        1"
                    ixAccessAddr configure -addressPerVlan     1
                    debug "ixAccessAddr configure -addressPerVlan     1"
                    ixAccessAddr configure -firstPriority        \
                    [interfaceEntry cget -vlanPriority]
                    
                    debug "ixAccessAddr configure -firstPriority \
                    [interfaceEntry cget -vlanPriority]"
                    
                    ixAccessAddr configure -vlanPriorityStep   1
                    debug "ixAccessAddr configure -vlanPriorityStep   1"
                    
                    ixAccessAddr configure -vlanPriorityCount  1
                    debug "ixAccessAddr configure -vlanPriorityCount  1"
                    ixAccessAddr configure -addressPerPriority 1
                    debug "ixAccessAddr configure -addressPerPriority 1"
                    ixAccessAddr configure -mask               \
                    [interfaceIpV4 cget -maskWidth]
                    
                    debug "ixAccessAddr configure -mask        \
                    [interfaceIpV4 cget -maskWidth]"
                } else {
                    ixAccessAddr configure -mask               \
                    [interfaceIpV4 cget -maskWidth]
                    
                    debug "ixAccessAddr configure -mask        \
                    [interfaceIpV4 cget -maskWidth]"
                }
                
                set status_addr [ixAccessAddrList addAddr]
                debug "ixAccessAddrList addAddr"
                
                if {$status_addr} {
                    keylset returnList log "[ixAccessDefines getErrorString $status_addr]"
                    return $returnList
                }
            }
        } elseif {[info exists mac_dst] && [info exists mac_src]} {
            if {$i != 0} { continue  }
            set gateway_ip $server_ip
            keylset returnList gateway_ip $gateway_ip
            ixAccessGateway configure -gwIp         $server_ip
            debug "ixAccessGateway configure -gwIp         $server_ip"
            ixAccessGateway configure -gwMac        $mac_dst
            debug "ixAccessGateway configure -gwMac        $mac_dst"
            ixAccessGateway configure -enableArp    $::false
            debug "ixAccessGateway configure -enableArp    $::false"
        } elseif {[port isValidFeature $chassis $card $port $::portFeatureAtm] } {
            if {$i != 0} { continue  }
            set gateway_ip $server_ip
            keylset returnList gateway_ip $gateway_ip
            ixAccessGateway configure -gwIp $server_ip
            debug "ixAccessGateway configure -gwIp  $server_ip"
        } else {
            if {$i != 0} { continue  }
            keylset returnList log "mac_dst and mac_src\
                    not set when interface $server_ip does not exist"
            return $returnList
        }
        set server_ip     [increment_ipv4_address_hltapi $server_ip $server_ip_step]
        set mac_src_start [incrementMacAdd $mac_src_start]
    }
    
    if {[info exists host_behind_network]} {
        ixAccessGateway configure -enableHostBehindNetwork $::true
        debug "ixAccessGateway configure -enableHostBehindNetwork $::true"
        ixAccessGateway configure -hostBehindNetwork $host_behind_network
        debug "ixAccessGateway configure -hostBehindNetwork $host_behind_network"
    }
    
    set status [ixAccessPort writeConfig $chassis $card $port]
    debug "ixAccessPort writeConfig $chassis $card $port"
    if { $status } {
        keylset returnList log "Error writing port config on {$chassis $card $port}\n\
                Error = [ixAccessDefines getErrorString $status]"
        return $returnList
    }
    
    set status [ixAccessGatewayTable addGateway]
    debug "ixAccessGatewayTable addGateway"
    if { $status } {
        keylset returnList log "Error adding gateway on {$chassis $card $port}\n\
                [ixAccessDefines getErrorString $status]"
        return $returnList
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::ixaccess_create_qos
#
# Description:
#     This command configures traffic streams on the specified port
#     for pppox.
#
# Synopsis:
#     ::ixia::ixaccess_create_qos
#         -port_handle             REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
#         -handle                  ANY
#         [-qos_rate_mode          CHOICES percent pps bps
#                                  DEFAULT bps]
#         [-qos_rate               NUMERIC]
#         [-qos_byte               RANGE 0-127
#                                  DEFAULT 0]
#         [-qos_atm_clp            CHOICES 0 1
#                                  DEFAULT 0]
#         [-qos_atm_efci           CHOICES 0 1
#                                  DEFAULT 0]
#         [-qos_atm_cr             CHOICES 0 1
#                                  DEFAULT 0]
#         [-qos_fr_cr              CHOICES 0 1
#                                  DEFAULT 0]
#         [-qos_fr_de              CHOICES 0 1
#                                  DEFAULT 0]
#         [-qos_fr_becn            CHOICES 0 1
#                                  DEFAULT 0]
#         [-qos_fr_fecn            CHOICES 0 1
#                                  DEFAULT 0]
#         [-qos_ipv6_flow_label    RANGE 0-1048575
#                                  DEFAULT 0]
#         [-qos_ipv6_traffic_class RANGE 0-255
#                                  DEFAULT 0]
# Arguments:
#    -port_handle
#        The port to for which to configure qos groups.
#    -handle
#        PPP/L2TP handle where the group needs to be created.
#    -qos_byte
#        The combined value for the precedence, delay, throughput,reliability,
#        reserved and cost bits.
#        (DEFAULT = 0)
#    -qos_rate_mode
#        The means by which line rates will be specified. Valid choices are:
#        percent - The line rate is expressed in percentage of maximum
#                  line rate.
#        pps     - The line rate is expressed in packets per second.
#        bps     - The line rate is expressed in bits per second.
#        (DEFAULT = bps)
#    -qos_rate
#        This is the data rate setting expressed. Default values are:
#        5000000  - when -qos_rate_mode bps
#        1000     - when -qos_rate_mode pps
#        100      - when -qos_rate_mode percentage
#        This rate represents the aggregated rate for all sessions belonging
#        to the group.
#    -qos_atm_clp
#        The setting of the congestion loss priority bit.
#        (DEFAULT = 0)
#    -qos_atm_efci
#        The setting of the explicit forward congestion indication bit.
#        (DEFAULT = 0)
#    -qos_atm_cr
#        The setting of the command response bit.
#        (DEFAULT = 0)
#    -qos_fr_cr
#        The setting of the frame relay command response bit.
#        (DEFAULT = 0)
#    -qos_fr_de
#        The setting of the frame relay discard eligibility bit.
#        (DEFAULT = 0)
#    -qos_fr_becn
#        The setting of the frame relay backward congestion notification bit.
#        (DEFAULT = 0)
#    -qos_fr_fecn
#        The setting of the frame relay forward congestion notification bit.
#        (DEFAULT = 0)
#    -qos_ipv6_flow_label
#        The IPv6 flow label, from 0 through 1,048,575.
#        (DEFAULT = 0)
#    -qos_ipv6_traffic_class
#        The IPv6 traffic class, from 0 through 255.
#        (DEFAULT = 0)
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:group     value:QoS group.
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::ixaccess_create_qos {args} {
    set mandatory_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle                 ANY
        -sessions               NUMERIC
    }

    set opt_args {
        -qos_rate_mode          CHOICES percent pps bps
        DEFAULT bps
        -qos_rate               NUMERIC
        -qos_byte               RANGE 0-127
        DEFAULT 0
        -qos_atm_clp            CHOICES 0 1
        DEFAULT 0
        -qos_atm_efci           CHOICES 0 1
        DEFAULT 0
        -qos_atm_cr             CHOICES 0 1
        DEFAULT 0
        -qos_fr_cr              CHOICES 0 1
        DEFAULT 0
        -qos_fr_de              CHOICES 0 1
        DEFAULT 0
        -qos_fr_becn            CHOICES 0 1
        DEFAULT 0
        -qos_fr_fecn            CHOICES 0 1
        DEFAULT 0
        -qos_ipv6_flow_label    RANGE 0-1048575
        DEFAULT 0
        -qos_ipv6_traffic_class RANGE 0-255
        DEFAULT 0
    }
    
    ::ixia::parse_dashed_args -args $args -mandatory_args $mandatory_args \
            -optional_args $opt_args
    
    foreach {chassis card port} [split $port_handle /] {}
    
    array set qosEnumList [list \
            percent $::kIxAccessLineUtilization \
            pps     $::kIxAccessPacketPerSec    \
            bps     $::kIxAccessBitPerSec       ]
    
    array set qosOptList [list          \
            percent percentageLineRate  \
            pps     packetPerSecond     \
            bps     bitsPerSecond       \
            ]
    
    array set qosDefaultList [list     \
            percentageLineRate 100     \
            packetPerSecond    1000    \
            bitsPerSecond      5000000 \
            ]
    
    set qosParams ""
    array set qosParamsArray {
        rateMode             qos_rate_mode
        atmCLP               qos_atm_clp
        atmEFCI              qos_atm_efci
        atmCR                qos_atm_cr
        frCR                 qos_fr_cr
        frDE                 qos_fr_de
        frBECN               qos_fr_becn
        frFECN               qos_fr_fecn
        ipv6FlowLabel        qos_ipv6_flow_label
        ipv6TrafficClass     qos_ipv6_traffic_class
    }
    if {[info exists qos_rate_mode]} {
        if {[llength $qos_rate_mode] > 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "Only one QoS Group can\
                    be attached per session."
            return $returnList
        }
        set qosParamsArray($qosOptList($qos_rate_mode)) qos_rate
    }
    if {![info exists qos_rate]} {
        set qos_rate $qosDefaultList($qosOptList($qos_rate_mode))
    }
    
    foreach {qosOpt qosName} [array get qosParamsArray] {
        if {[info exists $qosName]} {
            if {[info exists qosEnumList([set $qosName])]} {
                set $qosName $qosEnumList([set $qosName])
            }
            lappend qosParams $qosOpt [set $qosName]
        }
    }
    
    ixAccessQosGroupTable select $chassis $card $port
    debug "ixAccessQosGroupTable select $chassis $card $port"
    # Maximum number of qosGroups is 8
    # If max value has been reached then all following sessions will be added
    # to a QoSGroup that has the same tosByte or to a random QoSGroup
    set qosId [ixAccessQosGroupTable cget -numQosGroups ]
    set qosId ${handle}${qosId}

    for {set retCode [ixAccessQosGroupTable getFirst]} \
            {$retCode == 0} {set retCode [ixAccessQosGroupTable getNext]} {
                
        set retQ [ixAccessQosGroup getFirstQos]
        if {$retQ} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to ixAccessQosGroup getFirstQos\
            for $chassis.$card.$port.  Status:\
            [ixAccessGetErrorString $retCode]"
            return $returnList
        }
        if {[ixAccessQos cget -tosByte] == $qos_byte} {
            keylset returnList status $::SUCCESS
            keylset returnList group  [ixAccessQosGroup cget -qosGroupId]
            return $returnList
        }
    }
    if {[ixAccessQosGroupTable cget -numQosGroups ] == 8} {        
        keylset returnList status $::FAILURE
        keylset returnList log "Maximum of 7 QoS groups exceeded\
                for $chassis.$card.$port."
        return $returnList
    }
    
    ixAccessQosGroup setDefault
    debug "ixAccessQosGroup setDefault"
    ixAccessQosGroup config -qosGroupId $qosId
    debug "ixAccessQosGroup config -qosGroupId $qosId"
    ixAccessQosGroup config -rateMode   $qos_rate_mode
    debug "ixAccessQosGroup config -rateMode   $qos_rate_mode"
    
    set retCode [ixAccessQosGroupTable add]
    debug "ixAccessQosGroupTable add"
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to add qos group\
                for $chassis.$card.$port.  Status:\
                [ixAccessGetErrorString $retCode]"
        return $returnList
    }
    
    ixAccessQos setDefault
    debug "ixAccessQos setDefault"
    foreach {ix_option hlt_option} [array get qosParamsArray] {
        if {($ix_option == "percentageLineRate") || \
                    ($ix_option == "packetPerSecond") ||  \
                    ($ix_option == "bitsPerSecond")} {
            
            catch {ixAccessQos config -$ix_option [mpexpr \
                        [set $hlt_option] / $sessions]}
            
            debug "ixAccessQos config -$ix_option [mpexpr \
                    [set $hlt_option] / $sessions]"
        } else  {
            catch {ixAccessQos config -$ix_option [set $hlt_option]}
            debug "ixAccessQos config -$ix_option [set $hlt_option]"
        }
    }
    
    if {$qos_byte != 0} {
        set reserved    [expr $qos_byte & 0x01]
        set cost        [expr ($qos_byte >> 1) & 0x01]
        set reliability [expr ($qos_byte >> 2) & 0x01]
        set throughput  [expr ($qos_byte >> 3) & 0x01]
        set delay       [expr ($qos_byte >> 4) & 0x01]
        set precedence  [expr ($qos_byte >> 5) & 0x07]
        
        ixAccessQos config -reserved    $reserved
        debug "ixAccessQos config -reserved    $reserved"
        ixAccessQos config -cost        $cost
        debug "ixAccessQos config -cost        $cost"
        ixAccessQos config -reliability $reliability
        debug "ixAccessQos config -reliability $reliability"
        ixAccessQos config -throughput  $throughput
        debug "ixAccessQos config -throughput  $throughput"
        ixAccessQos config -delay       $delay
        debug "ixAccessQos config -delay       $delay"
        ixAccessQos config -precedence  $precedence
        debug "ixAccessQos config -precedence  $precedence"
    }
    set retCode [ixAccessQos set $chassis $card $port $qosId 1]
    debug "ixAccessQos set $chassis $card $port $qosId 1"
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to set qos object\
                for $chassis.$card.$port.$qosId.1.  Status:\
                [ixAccessGetErrorString $retCode]"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList group  $qosId
    
    return $returnList
}


proc ::ixia::ixaccess_set_traffic_ports {port_handle mode} {
    variable ixaccess_traffic_ports
    
    keylset returnList status $::SUCCESS
    
    if {($mode != "tx") && ($mode != "rx") && ($mode != "bidirectional") &&\
            ($mode != "reset")} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid mode $mode in \
            ::ixia::ixaccess_set_traffic_ports"
        return $returnList
    }
    
    foreach port $port_handle {
        switch -- $mode {
            tx {
                if {[lsearch $::ixia::ixaccess_traffic_ports(tx_ports) \
                        $port] == -1} {
                    lappend ::ixia::ixaccess_traffic_ports(tx_ports) \
                            $port
                }
            }
            rx {
                if {[lsearch $::ixia::ixaccess_traffic_ports(rx_ports) \
                        $port] == -1} {
                    lappend ::ixia::ixaccess_traffic_ports(rx_ports) \
                            $port
                }
            }
            bidirectional {
                if {[lsearch $::ixia::ixaccess_traffic_ports(tx_ports) \
                        $port] == -1} {
                    lappend ::ixia::ixaccess_traffic_ports(tx_ports) \
                            $port
                }
                if {[lsearch $::ixia::ixaccess_traffic_ports(rx_ports) \
                        $port] == -1} {
                    lappend ::ixia::ixaccess_traffic_ports(rx_ports) \
                            $port
                }
            }
            reset {
                set tx_idx [lsearch $::ixia::ixaccess_traffic_ports(tx_ports) \
                        $port]
                set rx_idx [lsearch $::ixia::ixaccess_traffic_ports(rx_ports) \
                        $port]
                if {$tx_idx != -1} {
                    set ::ixia::ixaccess_traffic_ports(tx_ports) [lreplace \
                            $::ixia::ixaccess_traffic_ports(tx_ports) $tx_idx \
                            $tx_idx]
                    debug "set ::ixia::ixaccess_traffic_ports(tx_ports) \[lreplace \
                            $::ixia::ixaccess_traffic_ports(tx_ports) $tx_idx \
                            $tx_idx\]"
                }
                if {$rx_idx != -1} {
                    set ::ixia::ixaccess_traffic_ports(rx_ports) [lreplace \
                            $::ixia::ixaccess_traffic_ports(rx_ports) $rx_idx \
                            $rx_idx]
                    debug "set ::ixia::ixaccess_traffic_ports(rx_ports) \[lreplace \
                            $::ixia::ixaccess_traffic_ports(rx_ports) $rx_idx \
                            $rx_idx\]"
                }
            }
        }
    }
    return $returnList
}


proc ::ixia::ixaccess_reset_traffic {ch ca po} {
    variable ::ixia::emulation_handles_array

    if {![info exists emulation_handles_array] || \
        ![info exists emulation_handles_array($ch,$ca,$po)]} {
        # IxAccess traffic reset is not needed.
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    regexp {([a-zA-Z0-9]+)/.*} $emulation_handles_array($ch,$ca,$po) dummy emulation
    if {![info exists emulation] || $emulation != "IxTclAccess"} {
        # IxAccess traffic reset is not needed.
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    set resetPrtList [list [list $ch $ca $po]]
    set status [ixAccessResetTraffic $resetPrtList]
    debug "ixAccessResetTraffic {$resetPrtList}"
    if { $status } {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to reset port: $ch $ca $po"
        return $returnList
    }
    
    debug "ixaccess_set_traffic_ports $resetPrtList \"reset\""
    set status [::ixia::ixaccess_set_traffic_ports $resetPrtList "reset"]
    if { [keylget status status] != $::SUCCESS } {
        return $status
    }
    
    set status [ixAccessPort get $ch $ca $po]
    debug "ixAccessPort get $ch $ca $po"
    if { $status } {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to reset port: $ch $ca $po"
        return $returnList
    }
    if {[ixAccessPort cget -portRole] != $::kIxNetworkRole} {
        foreach handle [array names \
                ::ixia::emulation_handles_array -regexp ($ch,$ca,$po,.*)] {
            set resetSubPrt $emulation_handles_array($handle)
            set status [ixAccessTrafficUserTable select $ch $ca $po $resetSubPrt]
            debug "ixAccessTrafficUserTable select $ch $ca $po $resetSubPrt"
            if { $status } {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to reset port: $ch $ca $po"
                return $returnList
            }
            debug "ixAccessTrafficUserTable clearAllTrafficUser"
            ixAccessTrafficUserTable clearAllTrafficUser
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}
