##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_ixaccess.tcl
#
# Purpose:
#    A script development library containing IxAccess APIs for test automation
#    with the Ixia chassis.
#
# Author:
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#    - ixaccess_per_session_traffic_stats
#    - ixaccess_traffic_control
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
#    ::ixia::ixaccess_traffic_control
#
# Description:
#    This command starts and stops traffic on the specified ports. It
#    starts/stops traffic on the configured pseudowires.
#
# # Synopsis:
#    ::ixia::ixaccess_traffic_control
#        -port_handle<interface_list>
#        -action<CHOICES sync_run run manual_trigger stop poll reset destroy
#                clear_stats>
#        [-latency_bins<NUMERIC>]
#        [-latency_values]
#        [-duration<NUMERIC>]
#
# Arguments:
#    -port_handle
#    -action
#        Action to take. Valid choices are:
#        sync_run       - Hardware synchronizes the generators and all defined
#                         traffic.
#        run            - Starts the generators and all configured traffic
#                         sources.
#        stop           - Stops the generators.
#        reset          - Clears generators to power up state and clears all
#                         traffic sources.
#        destroy        - Destroys the generators.
#    -latency_bins
#    -latency_values
#    -duration
#    -tx_ports_list
#    -rx_ports_list
#
# Return Values:
#    A keyed list
#    key:status     value:$::SUCCESS | $::FAILURE
#    key:log        value:On status of failure, gives detailed information.
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
proc ::ixia::ixaccess_traffic_control {args} {
    upvar 1 procName procName
    
    set mandatory_args {
        -port_handle REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -action      CHOICES sync_run run manual_trigger stop poll reset destroy
                     CHOICES clear_stats
    }
    
    set optional_args {
        -latency_bins   NUMERIC
        -latency_values
        -duration       NUMERIC
        -tx_ports_list
        -rx_ports_list
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args
    
    set port_list [format_space_port_list $port_handle]
    
    if {[info exists tx_ports_list] && [info exists rx_ports_list]} {
        set port_list [format_space_port_list \
               [lsort -unique [concat $tx_ports_list $rx_ports_list]]]
        
        set tx_ports_list [format_space_port_list $tx_ports_list]
        set rx_ports_list [format_space_port_list $rx_ports_list]
    } else  {
        set tx_ports_list $port_list
        set rx_ports_list $port_list
    }
    
    set stopped 0
    
    foreach item $action {
        switch -- $item {
            sync_run {
                set retCode [ixClearTimeStamp port_list]
                debug "ixClearTimeStamp {$port_list}"
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: clearing\
                            time stamps on ports $port_list."
                    return $returnList
                }
                set retCode [ixAccessStartTraffic $tx_ports_list $rx_ports_list]
                debug "ixAccessStartTraffic {$tx_ports_list} {$rx_ports_list}"
                
                if {$retCode != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            start traffic on ports {$tx_ports_list}. \
                            Status: $retCode"
                    return $returnList
                }
                
                set stopped 0
                # check to see where we have multicast
                set retCode [doMulticastOperation $tx_ports_list "start"]
            }
            run {
                set retCode [ixAccessStartTraffic $tx_ports_list $rx_ports_list]
                debug "ixAccessStartTraffic {$tx_ports_list} {$rx_ports_list}"
                
                if {$retCode != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            start traffic on ports {$tx_ports_list}. \
                            Status: $retCode"
                    return $returnList
                }
                
                set stopped 0
                # check to see where we have multicast
                set retCode [doMulticastOperation $tx_ports_list "start"]
            }
            stop {
                # check to see where we have multicast
                
                if {[info exists duration]} {
                    set retCode [ixAccessCheckTransmitDone $port_list $duration]
                    debug "ixAccessCheckTransmitDone {$port_list} $duration"
                    if { $retCode != $::TCL_OK} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to\
                                check transmit done on ports $port_list. \
                                Status: $retCode"
                        return $returnList
                    }
                }
                
                set retCode [doMulticastOperation $tx_ports_list "stop"]
                set retCode [ixAccessStopTraffic $port_list]
                debug "ixAccessStopTraffic {$port_list}"
                
                set stopped 1
            }
            reset -
            destroy {
                foreach port $port_list {
                    foreach {ch ca po} $port {}
                    set status [ixAccessResetTraffic [list $port]]
                    debug "ixAccessResetTraffic {$port}"
                    if { $status } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to reset port: $ch $ca $po"
                        return $returnList
                    }
                    set status [::ixia::ixaccess_set_traffic_ports [list $port] "reset"]
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
                            set resetSubPrt $::ixia::emulation_handles_array($handle)
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
                    foreach item [array names ::ixia::pgid_to_stream] {
                        foreach {chassis_num card_num port_num stream_num} \
                                [split $::ixia::pgid_to_stream($item) ,] {}
                        if {($ch == $chassis_num) && ($ca == $card_num) && ($po == $port_num)} {
                            catch {array unset ::ixia::pgid_to_stream $item}
                        }
                    }
                    if {[array names ::ixia::pgid_to_stream] == -1} {
                        set ::ixia::current_streamid 0
                    }
                }
                
                set stopped 1
            }
            manual_trigger {}
            poll {}
            clear_stats {
                if {[ixClearStats port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Clearing stats on ports\
                            $port_list failed."
                    return $returnList
                }
                if {[::ixia::are_ports_transmitting $port_list]} {
                    set stopped 0
                } else {
                    set stopped 1
                }
                if {[ixClearTimeStamp port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Clearing time stamps on ports\
                            $port_list failed."
                    return $returnList
                }
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList stopped $stopped
    return $returnList
}



##Internal Procedure Header
# Name:
#    ::ixia::ixaccess_per_session_traffic_stats
#
# Description:
#    This command starts and stops traffic on the specified ports. It
#    starts/stops traffic on the configured pseudowires.
#
# Synopsis:
#    ::ixia::ixaccess_per_session_traffic_stats
#        -port_handle  REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
#        -aggregation  CHOICES framesize qos user
#        [-csv_filename DEFAULT ""]
#
# Arguments:
#    -port_handle
#    -aggregation
#        Valid choices are:
#        framesize - aggregate stats by frame size
#        qos       - aggregate stats by qos group
#        user      - aggregate stats by user group
#    -csv_filename
#        Name and path of the file where statistics should be exported.
#
# Return Values:
#    A keyed list
#    key:status     value:$::SUCCESS | $::FAILURE
#    key:log        value:On status of failure, gives detailed information.
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
proc ::ixia::ixaccess_per_session_traffic_stats {args} {
    upvar 1 procName procName
    
    set counter_list ""
    
    set mandatory_args {
        -port_handle  REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -aggregation  CHOICES framesize qos user
    }

    set optional_args {
        -csv_filename DEFAULT ""
    }

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    set portList [format_space_port_list $port_handle]

    switch -- $aggregation {
        framesize {
            set aggregatorList {1 0 0}
        }
        qos {
            set aggregatorList {0 1 0}
        }
        user {
            set aggregatorList {0 0 1}
        }
    }

    array set statsArray [ixAccessGetPerSessionTrafficStats \
            $portList $portList $csv_filename $aggregatorList]

    debug "ixAccessGetPerSessionTrafficStats \
            {$portList} {$portList} {$csv_filename} {$aggregatorList}"
    
    debug "[array get statsArray]"
    foreach {index value_} [array get statsArray] {
        set indexList [split $index ,]
        set txChassis [lindex $indexList 0]
        set txCard    [lindex $indexList 1]
        set txPort    [lindex $indexList 2]
        set rxChassis [lindex $indexList 3]
        set rxCard    [lindex $indexList 4]
        set rxPort    [lindex $indexList 5]
        set rxSubPort [lindex $indexList 6]
        set qosGrp    [lindex $indexList 7]
        set qos       [lindex $indexList 8]
        set frameSize [lindex $indexList 9]
        set userGroup [lindex $indexList 10]
        set session   [lindex $indexList 11]
        set rSize     [lindex $indexList 12]

        set tx_port_handle $txChassis/$txCard/$txPort
        set rx_port_handle $rxChassis/$rxCard/$rxPort
        foreach value $value_ {
            debug "index=$index; value=$value"
            if {$aggregation == "framesize"} {
                if {$frameSize == ""} {
                    continue
                }
                set aggregate $frameSize
            } elseif {$aggregation == "qos"} {
                debug "qosGrp = $qosGrp \nqos = $qos"
                if {$qosGrp == "" || $qos == ""} {
                    continue
                }
                set aggregate $qosGrp.$qos
            } else {
                if {$userGroup == ""} {
                    continue
                }
                set aggregate $userGroup
            }
            
            set keytx $tx_port_handle.session.tx.$session.$aggregate
            set keyrx $rx_port_handle.session.rx.$session.$aggregate
    
            if {$session != ""} {
                regsub -all {\.} $keytx.pkt_count {~} temp_key
                if {![catch {keylget returnList $keytx.pkt_count} tempValue]} {
                    set stat [mpexpr $tempValue + [lindex $value 0]]
                    set temp_counter [keylget counter_list $temp_key]
                    keylset counter_list $temp_key $temp_counter
                } else {
                    set stat [lindex $value 0]
                    keylset counter_list $temp_key 1
                }
                keylset returnList $keytx.pkt_count $stat
    
                regsub -all {\.} $keyrx.pkt_count {~} temp_key
                if {![catch {keylget returnList $keyrx.pkt_count} tempValue]} {
                    set stat [mpexpr $tempValue + [lindex $value 1]]
                    set temp_counter [keylget counter_list $temp_key]
                    keylset counter_list $temp_key $temp_counter
                } else {
                    set stat [lindex $value 1]
                    keylset counter_list $temp_key 1
                }
                keylset returnList $keyrx.pkt_count $stat
    
                set tmp_min [lindex $value 2]
                if {![catch {keylget returnList $keyrx.min_delay} tempValue]} {
                    if {(($tempValue != 0) && ($tmp_min != 0) && \
                                ($tempValue < $tmp_min)) || ($tmp_min == 0)} {
                        set stat $tempValue
                    } else {
                        set stat $tmp_min
                    }
                } else {
                    set stat $tmp_min
                }
                keylset returnList $keyrx.min_delay $stat
    
                regsub -all {\.} $keyrx.avg_delay {~} temp_key
                if {![catch {keylget returnList $keyrx.avg_delay} tempValue]} {
                    set stat [mpexpr $tempValue + [lindex $value 3]]
                    set temp_counter [keylget counter_list $temp_key]
                    if {[lindex $value 3]} {
                        incr temp_counter
                    }
                    keylset counter_list $temp_key $temp_counter
                } else {
                    set stat [lindex $value 3]
                    keylset counter_list $temp_key 1
                }
                keylset returnList $keyrx.avg_delay $stat
    
                if {![catch {keylget returnList $keyrx.max_delay} tempValue]} {
                    if {$tempValue > [lindex $value 4]} {
                        set stat $tempValue
                    } else {
                        set stat [lindex $value 4]
                    }
                } else {
                    set stat [lindex $value 4]
                }
                keylset returnList $keyrx.max_delay $stat
            }
        }
    }
    foreach tmp [keylkeys counter_list] {
        regsub -all {~} $tmp {.} tmp_key
        set tmp_counter [keylget counter_list $tmp]
        set tmp_value [keylget returnList $tmp_key]
        set tmp_value [mpexpr $tmp_value / $tmp_counter]
        keylset returnList $tmp_key $tmp_value
    }
    
    unset counter_list
    
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::ixaccess_multicast_traffic_stats
#
# Description:
#    This command starts and stops traffic on the specified ports. It
#    starts/stops traffic on the configured pseudowires.
#
# Synopsis:
#    ::ixia::ixaccess_multicast_traffic_stats
#        -port_handle  REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
#        -aggregation  CHOICES framesize qos user
#        [-csv_filename DEFAULT ""]
#
# Arguments:
#    -port_handle
#    -aggregation
#        Valid choices are:
#        multicastAddress - aggregate stats by multicast address
#        mcGroupId   		  - aggregate stats by multicast group
#        tos              - aggregate stats by tos
#    -csv_filename
#        Name and path of the file where statistics should be exported.
#
# Return Values:
#    A keyed list
#    key:status     value:$::SUCCESS | $::FAILURE
#    key:log        value:On status of failure, gives detailed information.
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
proc ::ixia::ixaccess_multicast_traffic_stats {args} {
    upvar 1 procName procName
    
    set counter_list ""
        
    set mandatory_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -multicast_aggregation  CHOICES mc_address mc_group tos
    }

    set optional_args {
        -csv_filename DEFAULT ""
    }

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    set portList [format_space_port_list $port_handle]

    switch -- $multicast_aggregation {
        mc_group {
            set aggregatorList {0 1 0}
        }
        mc_address {
            set aggregatorList {1 0 0}
        }
        tos {
            set aggregatorList {0 0 1}
        }
    }

    array set statsArray [ixAccessGetMulticastTrafficStats \
        	$portList $portList $csv_filename $aggregatorList]

    debug "ixAccessGetMulticastTrafficStats \
            {$portList} {$portList} {$csv_filename} {$aggregatorList}"

    foreach {index value} [array get statsArray] {
        set indexList   [split $index ,]
        set txChassis   [lindex $indexList 0]
        set txCard      [lindex $indexList 1]
        set txPort      [lindex $indexList 2]
        set rxChassis   [lindex $indexList 3]
        set rxCard      [lindex $indexList 4]
        set rxPort      [lindex $indexList 5]
        set rxSubPort   [lindex $indexList 6]
        set qosGrp      [lindex $indexList 7]
        set qos         [lindex $indexList 8]
        set frameSize   [lindex $indexList 9]
        set userGroup   [lindex $indexList 10]
        set session     [lindex $indexList 11]
        set rSize       [lindex $indexList 12]
        set mcGroupId   [lindex $indexList 13]
        set mcGroupAddr [lindex $indexList 14]
        set tos         [lindex $indexList 15]

        set tx_port_handle $txChassis/$txCard/$txPort
        set rx_port_handle $rxChassis/$rxCard/$rxPort
        
        regsub -all {\.} $mcGroupAddr { } mcGroupAddr
        
        if {$multicast_aggregation == "mc_group"} {
            set  aggregate $mcGroupId
        } elseif {$multicast_aggregation == "tos"} {
            set aggregate $tos
        } elseif {$multicast_aggregation == "mc_address"} {
            set aggregate $mcGroupId.$mcGroupAddr
        }
        
        if {($multicast_aggregation == "tos") || ($mcGroupId != "")} {
            set keytx $tx_port_handle.multicast.tx.${aggregate}.pkt_count
            set keyrx $rx_port_handle.multicast.rx.${aggregate}
            
            set valueList [lindex $value 0]
            
            regsub -all {\.} $keytx {~} temp_key
            if {![catch {keylget returnList $keytx} tempValue]} {
                set stat [mpexpr $tempValue + [lindex $valueList 0]]
                set temp_counter [keylget counter_list $temp_key]
                if {[lindex $valueList 0]} {
                    incr temp_counter
                }
                keylset counter_list $temp_key $temp_counter
            } else {
                set stat [lindex $valueList 0]
                keylset counter_list $temp_key 1
            }
            keylset returnList $keytx $stat
            
            regsub -all {\.} $keyrx.pkt_count {~} temp_key
            if {![catch {keylget returnList $keyrx.pkt_count} tempValue]} {
                set stat [mpexpr $tempValue + [lindex $valueList 1]]
                set temp_counter [keylget counter_list $temp_key]
                if {[lindex $valueList 1]} {
                    incr temp_counter
                }
                keylset counter_list $temp_key $temp_counter
            } else {
                set stat [lindex $valueList 1]
                keylset counter_list $temp_key 1
            }
            keylset returnList $keyrx.pkt_count $stat

            set tmp_min [lindex $valueList 2]
            if {![catch {keylget returnList $keyrx.min_delay} tempValue]} {
                if {(($tempValue != 0) && ($tmp_min != 0) && \
                            ($tempValue < $tmp_min)) || ($tmp_min == 0)} {
                    set stat $tempValue
                } else {
                    set stat $tmp_min
                }
            } else {
                set stat $tmp_min
            }
            keylset returnList $keyrx.min_delay $stat

            regsub -all {\.} $keyrx.avg_delay {~} temp_key
            if {![catch {keylget returnList $keyrx.avg_delay} tempValue]} {
                set stat [mpexpr $tempValue + [lindex $valueList 3]]
                set temp_counter [keylget counter_list $temp_key]
                if {[lindex $valueList 3]} {
                    incr temp_counter
                }
                keylset counter_list $temp_key $temp_counter
            } else {
                set stat [lindex $valueList 3]
                keylset counter_list $temp_key 1
            }
            keylset returnList $keyrx.avg_delay $stat
    
            if {![catch {keylget returnList $keyrx.max_delay} tempValue]} {
                if {$tempValue > [lindex $valueList 4]} {
                    set stat $tempValue
                } else {
                  set stat [lindex $valueList 4]
                }
            } else {
                set stat [lindex $valueList 4]
            }
            keylset returnList $keyrx.max_delay $stat
        }
    }
    
    foreach tmp [keylkeys counter_list] {
        regsub -all {~} $tmp {.} tmp_key
        set tmp_counter [keylget counter_list $tmp]
        set tmp_value [keylget returnList $tmp_key]
        set tmp_value [mpexpr $tmp_value / $tmp_counter]
        keylset returnList $tmp_key $tmp_value
    }
    
    unset counter_list

    keylset returnList status $::SUCCESS
    return $returnList
}



##Internal Procedure Header
# Name:
#    ::ixia::ixaccess_igmpOverPpp_traffic_stats
#
# Description:
#    This command gathers aggregate traffic statistics for
#    IGMPoPPP
#
# Synopsis:
#    ::ixia::ixaccess_igmpOverPpp_traffic_stats
#        -port_handle  REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
#
# Arguments:
#    -port_handle
#
# Return Values:
#    A keyed list
#    key:status     value:$::SUCCESS | $::FAILURE
#    key:log        value:On status of failure, gives detailed information.
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
proc ::ixia::ixaccess_igmpOverPpp_traffic_stats {args} {
    upvar 1 procName procName
    
    set mandatory_args {
        -port_handle            REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
     }
    
    ::ixia::parse_dashed_args -args $args -mandatory_args $mandatory_args
    
    set portList [format_space_port_list $port_handle]
    debug "portList = $portList"
    
    foreach port $portList {
        foreach {ch ca po} $port {}
        debug "ixAccessPortStats get $ch $ca $po"
        if {[ixAccessPortStats get $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to\
                    ixAccessPortStats get $ch $ca $po"
            return $returnList
        }
        
        set key ${ch}/${ca}/${po}.igmpoppp
            
         debug "ixAccessPortStats cget -mcTotalBytesTx"
        set mc_total_bytes_tx  [ixAccessPortStats cget -mcTotalBytesTx]
        debug "ixAccessPortStats cget -mcTotalBytesRx"
        set mc_total_bytes_rx  [ixAccessPortStats cget -mcTotalBytesRx]
        debug "ixAccessPortStats cget -mcTotalFramesTx"
        set mc_total_frames_tx [ixAccessPortStats cget -mcTotalFramesTx]
        debug "ixAccessPortStats cget -mcTotalFramesRx"
        set mc_total_frames_rx [ixAccessPortStats cget -mcTotalFramesRx]
        
        keylset returnList $key.tx.mc_total_bytes\
                $mc_total_bytes_tx
        keylset returnList $key.rx.mc_total_bytes\
                $mc_total_bytes_rx
        keylset returnList $key.tx.mc_total_frames\
                $mc_total_frames_tx
        keylset returnList $key.rx.mc_total_frames\
                $mc_total_frames_rx
    }
    
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::doMulticastOperation {all_ports operation} {
    keylset returnList status $::SUCCESS
    foreach port $all_ports {
        scan $port "%d %d %d" c l p
        debug "c l p : $c $l $p"
        ixAccessPort get $c $l $p
        debug "ixAccessPort get $c $l $p"
        ixAccessSubPort get $c $l $p 0
        debug "ixAccessSubPort get $c $l $p 0"
        # the actual check
        if {([ixAccessPort cget -portRole ] == $::kIxAccessRole) && \
                    ([ixAccessSubPort cget -enableMulticast ] == 1)} {
                    
            # if we have multicast, starting multicast group joins
            set status [ixAccessSubPort ${operation}Multicast $c $l $p 0]
            debug "ixAccessSubPort ${operation}Multicast $c $l $p 0"
            if { $status } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Can't $operation \
                        multicast group join on port $c $l $p subport 0.  Status:\
                        [ixAccessGetErrorString $status]."
                return $returnList
            }
        }
    }
    return $returnList
}


proc ::ixia::ixaccess_create_operations {
    chassis card port 
    attempt_rate 
    disconnect_rate 
    enable_setup_throttling 
    max_outstanding
    flap_rate
    flap_repeat_count
    hold_time
    cool_off_time
} {
    variable emulation_handles_array
    
    ixAccessProfile select $chassis $card $port
    ixAccessProfile delAllOperations
    
    set _l [array names emulation_handles_array $chassis,$card,$port,*]
    set subports [expr [llength $_l] + 1]
    set startSession 1
    for {set i 0} {$i < $subports} {incr i} {
        ixAccessSubPort get $chassis $card $port $i
        
        set endSession [expr $startSession + [ixAccessSubPort cget -numSessions] - 1]
        # Setup Operation
        ixAccessOperation configure -opId                     setup_${chassis}_${card}_${port}_${i}
        ixAccessOperation configure -startSession             $startSession
        ixAccessOperation configure -endSession               $endSession
        catch {ixAccessOperation configure \
                -sessionSelectionModifier kIxAccessModifierNone}

        ixAccessOperation configure -operation                kIxAccessSetup
        ixAccessOperation configure -rate                     $attempt_rate
        if {[info exists enable_setup_throttling] && $enable_setup_throttling == 1} {
            ixAccessOperation configure -opMode               $::kIxAccessModeSeek
        } else {
            ixAccessOperation configure -opMode               $::kIxAccessModeConstant
        }
        ixAccessOperation configure -triggerEvent             $::kIxAccessCommand
        ixAccessOperation configure -delayAfterTrigger        0
        ixAccessOperation configure -maxOutstandingSessions   $max_outstanding
        ixAccessOperation configure -opList                   ""

        set status [ixAccessProfile addOperation]
        if { $status } {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to create setup\
                    operation for $chassis.$card.$port.  Status:\
                    [ixAccessGetErrorString $status]"
            return $returnList
        }
        
        # Teardown Operation
        ixAccessOperation configure -opId                     teardown_${chassis}_${card}_${port}_${i}
        ixAccessOperation configure -startSession             $startSession
        ixAccessOperation configure -endSession               $endSession
        catch {ixAccessOperation configure \
                -sessionSelectionModifier kIxAccessModifierNone}

        ixAccessOperation configure -operation                kIxAccessTeardown
        ixAccessOperation configure -rate                     $disconnect_rate
        ixAccessOperation configure -opMode                   $::kIxAccessModeConstant
        ixAccessOperation configure -triggerEvent             $::kIxAccessCommand
        ixAccessOperation configure -delayAfterTrigger        0
        ixAccessOperation configure -maxOutstandingSessions   $max_outstanding
        ixAccessOperation configure -opList                   ""

        set status [ixAccessProfile addOperation]
        if { $status } {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to create\
                    teardown operation for $chassis.$card.$port.  Status:\
                    [ixAccessGetErrorString $status]"
            return $returnList
        }
        
        # Flapping Operation 
        ixAccessOperation configure -opId                     flapping_${chassis}_${card}_${port}_${i}
        ixAccessOperation configure -startSession             $startSession
        ixAccessOperation configure -endSession               $endSession
        catch {ixAccessOperation configure \
                -sessionSelectionModifier kIxAccessModifierNone}

        ixAccessOperation configure -operation                kIxAccessFlapping
        ixAccessOperation configure -rate                     $flap_rate
        ixAccessOperation configure -flapRate                 $flap_rate
        ixAccessOperation configure -holdTime                 $hold_time
        ixAccessOperation configure -coolOffTime              $cool_off_time
        ixAccessOperation configure -repeatCount              $flap_repeat_count
        ixAccessOperation configure -opMode                   $::kIxAccessModeConstant
        ixAccessOperation configure -triggerEvent             $::kIxAccessCommand
        ixAccessOperation configure -delayAfterTrigger        0
        ixAccessOperation configure -maxOutstandingSessions   $max_outstanding
        ixAccessOperation configure -opList                   ""

        set status [ixAccessProfile addOperation]
        if { $status } {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to create\
                    teardown operation for $chassis.$card.$port.  Status:\
                    [ixAccessGetErrorString $status]"
            return $returnList
        }
        
        
        set startSession [expr $endSession + 1]
    }
    keylset returnList status $::SUCCESS
    return $returnList
}
