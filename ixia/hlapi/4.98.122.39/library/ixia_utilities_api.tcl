##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_utilities_api.tcl
#
# Purpose:
#    A script development library containing utilities used for conversion & misc.
#
# Author:
#    Ixia engineering, direct all communication to support@ixiacom.com
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - convert_vport_to_porthandle
#    - convert_porthandle_to_vport
#    - get_nodrop_rate
#    - reboot_port_cpu
#    - get_port_list_from_connect
#    - reset_port
#
# Requirements:
#    ixiaapiutils.tcl , a library containing TCL utilities
#    parseddashedargs.tcl , a library containing the procDescr and
#    parsedashedargds.tcl
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


proc ::ixia::convert_vport_to_porthandle { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
				\{::ixia::convert_vport_to_porthandle $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    if {[llength $args] == 1} {
        # port handle was passed directly
        # return an ixn handle or handle 0 ("::ixNet::OBJ-/vport:0")
        if {![regexp {^::ixNet::OBJ\-/vport:[0-9]+$} $args]} {
            debug "::ixia::convert_vport_to_porthandle: passed wrong handle"
            return "0/0/0"
        }
        set result [::ixia::ixNetworkGetPortFromObj $args]
        if {[keylget result status] != $::SUCCESS} {
            debug "::ixia::convert_vport_to_porthandle: ixNetworkGetPortFromObj failed"
            return "0/0/0"
        }
        return [keylget result port_handle]
    }
    
    set man_args {
        -vport  REGEXP  ^::ixNet::OBJ\-/vport:[0-9]+$
    }

    set opt_args {}
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
    
    set result [::ixia::ixNetworkGetPortFromObj $vport]
    if {[keylget result status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log [keylget result log]
        return $returnList
    }
    
    
    keylset returnList status $::SUCCESS
    keylset returnList handle [keylget result port_handle]
    
    return $returnList
}


proc ::ixia::convert_porthandle_to_vport { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::convert_porthandle_to_vport $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    if {[llength $args] == 1} {
        # port handle was passed directly
        # return an ixn handle or handle 0 ("::ixNet::OBJ-/vport:0")
        if {![regexp {^[0-9]+/[0-9]+/[0-9]+$} $args]} {
            debug "::ixia::convert_porthandle_to_vport: passed wrong handle"
            return "::ixNet::OBJ-/vport:0"
        }
        set result [::ixia::ixNetworkGetPortObjref $args]
        if {[keylget result status] != $::SUCCESS} {
            debug "::ixia::convert_porthandle_to_vport: ixNetworkGetPortObjref failed"
            return "::ixNet::OBJ-/vport:0"
        }
        return [keylget result vport_objref]
    }
    
    set man_args {
        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    set opt_args {}
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
            
    set result [::ixia::ixNetworkGetPortObjref $port_handle]
    if {[keylget result status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log [keylget result log]
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList handle [keylget result vport_objref]
    
    return $returnList
}


proc ::ixia::get_nodrop_rate { args } {

    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args
    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -stream_id         ANY
        -max_rate          NUMERIC
        -tx_port_handle    ANY
        -rx_port_handle    ANY
    }

    set optional_args {
        -stream_mode       CHOICES even uneven
                           DEFAULT even
        -min_percent       NUMERIC
                           DEFAULT 0
        -run_time_sec      NUMERIC
                           DEFAULT 10
        -tolerance         ANY
                           DEFAULT 0.5
        -poll_timeout_sec  NUMERIC
                           DEFAULT 100
        -display           CHOICES on off
                           DEFAULT on
    }


    set retlist {}

    ::ixia::parse_dashed_args -args $args \
        -mandatory_args $mandatory_args\
        -optional_args $optional_args
    
    # make sure max_rate and stream_id lists are aligned
    if {[llength $max_rate] == 1} {
        set max_rate_list {}
        foreach s $stream_id {
            lappend max_rate_list $max_rate
        }
        set max_rate $max_rate_list
    }

    if {[llength $max_rate] != [llength $stream_id]} {
        keylset retlist status $::FAILURE
        keylset retlist log "Unmatched max_rate and stream_id list"
        return $retlist
    }

    # make sure tx_port_handle and stream_id lists are aligned
    if {[llength $tx_port_handle] != [llength $stream_id]} {
        keylset retlist status $::FAILURE
        keylset retlist log \
            "Unmatched tx_port_handle and stream_id list"
        return $retlist
    }

    # sanity check for min_percent
    if {$min_percent<0 || $min_percent>100} {
        keylset retlist status $::FAILURE
        keylset retlist log \
            "min_prcent $min_percent is beyond 0-100"
        return $retlist
    }

    # sanity check for run_time
    if {$run_time_sec <= 0} {
        keylset retlist status $::FAILURE
        keylset retlist log \
            "run_time_sec $run_time_sec is not positive"
        return $retlist
    }
    
    # sanity check for tolerance
    if {$tolerance<0 || $tolerance>100} {
        keylset retlist status $::FAILURE
        keylset retlist log "tolerance $tolerance is beyond 0-100"
        return $retlist
    }

    # to ease the computation we use 0-1 scale instead of percentage
    set min_percent [expr $min_percent /100.0]
    set tolerance   [expr $tolerance   /100.0]

    # record the config to a keyed list
    if {$stream_mode == "even"} {
        set mode_even 1
    } else {
        set mode_even 0
    }
    
    keylset stream_info mode_even       $mode_even
    keylset stream_info rx_port_handle  [lsort -unique $rx_port_handle]
    keylset stream_info tx_port_handle  $tx_port_handle
    keylset stream_info port_handle     [lsort -unique [concat $rx_port_handle $tx_port_handle]]
    keylset stream_info stream_id       $stream_id
    keylset stream_info run_time_sec    $run_time_sec
    keylset stream_info poll_timeout_sec $poll_timeout_sec
    
    if {$display == "on"} {
        keylset stream_info display 1
    } else {
        keylset stream_info display 0
    }

    # for "even" mode, the scaling is universal
    if {$mode_even} {
        keylset stream_info high 1.0
        keylset stream_info low $min_percent
    }

    foreach stream $stream_id rate $max_rate handle $tx_port_handle {
        keylset stream_info $stream.max_rate $rate
        keylset stream_info $stream.tx_port_handle $handle

        # for uneven mode, scaling is individually managed
        if {!$mode_even} {
            keylset stream_info $stream.high 1.0
            keylset stream_info $stream.low $min_percent
        }
    }

    # if -min_percent is non-zero, make sure there is no loss
    if {$min_percent > 0} {
        puts "Check for minimum scale $min_percent ..."
        keylset stream_info cur $min_percent
        foreach stream $stream_id rate $max_rate {
            keylset stream_info $stream.cur_rate    [mpexpr int($min_percent * $rate)]
            keylset stream_info $stream.cur         $min_percent
        }
        # start the run
        set stream_info [::ixia::_get_nodrop_rate_run_traffic $stream_info]

        # check for error
        if {[keylget stream_info status] == $::FAILURE} {
            keylset retlist status $::FAILURE
            keylset retlist log [keylget stream_info log]
            return $retlist
        }
        
        # check for loss; if so we bail out
        if {![keylget stream_info nodrop]} {
            keylset retlist status $::FAILURE
            keylset retlist log "Packet loss at min_percent"
            return $retlist
        }
    }

    # min_percent test passed, get ready for binary run; start with
    # max rate
    keylset stream_info cur 1.0
    foreach stream $stream_id rate $max_rate {
        keylset stream_info $stream.cur_rate $rate
        keylset stream_info $stream.cur 1.0
    }

    # binary search loop
    while 1 {
        # fire up the traffic
        set stream_info [::ixia::_get_nodrop_rate_run_traffic $stream_info]

        # check for error
        if {[keylget stream_info status] == $::FAILURE} {
            keylset retlist status $::FAILURE
            keylset retlist log [keylget stream_info log]
            return $retlist
        }

        # if there is any stream receiving no packet we bail out
        set zero_rx_streams [keylget stream_info zero_rx_streams]
        if {[llength $zero_rx_streams] >0} {
            keylset retlist status $::FAILURE
            keylset retlist log "Following stream has RX zero: $zero_rx_streams"
            return $retlist
        }

        # now look at the loss situation
        if {$mode_even} {
            # one set of high, low, cur for all streams
            set old_high [keylget stream_info high]
            set old_low  [keylget stream_info low]
            set old_cur [keylget stream_info cur]

            # "nodrop" will be 1 if TX and RX match for all
            if {[keylget stream_info nodrop]} {
                set low $old_cur
                set high $old_high
                set cur [expr ($high + $low)/2.0]
            } else {
                set high $old_cur
                set low $old_low
                set cur [expr ($high + $low)/2.0]
            }                

            # see if we are done
            if {[expr $high - $low] <= $tolerance} {
                # record the result
                keylset retlist status $::SUCCESS
                keylset retlist nodrop_percent [expr 100.0*$low]
                foreach stream $stream_id {
                    keylset retlist $stream.nodrop_pps [keylget stream_info $stream.cur_rate]
                }
                return $retlist
            }

            # if not, get ready for the next run
            keylset stream_info high $high
            keylset stream_info low $low
            keylset stream_info cur $cur
            foreach stream $stream_id rate $max_rate {
                keylset stream_info $stream.cur_rate [mpexpr int($cur * $rate)]
            }
        }  else {
            # uneven case ...
            set all_in_tolerance 1
            foreach stream $stream_id rate $max_rate {
                set old_high [keylget stream_info $stream.high]
                set old_low  [keylget stream_info $stream.low]
                set old_cur  [keylget stream_info $stream.cur]
                
                # "nodrop" is on per stream 
                if {[keylget stream_info $stream.nodrop]} {
                    set low $old_cur
                    set high $old_high
                    set cur [expr ($high + $low)/2.0]
                } else {
                    set high $old_cur
                    set low $old_low
                    set cur [expr ($high + $low)/2.0]
                }                

                # see if we are OK with this stream
                if {[expr $high - $low] > $tolerance} {
                    set all_in_tolerance 0
                }

                # putting back for the next run
                keylset stream_info $stream.high $high
                keylset stream_info $stream.low $low
                keylset stream_info $stream.cur $cur
                keylset stream_info $stream.cur_rate \
                    [mpexpr int($cur * $rate)]
            }

            # check if we are done
            if {$all_in_tolerance} {
                # last check is necessary, since this config may 
                # not have been run before
                foreach stream $stream_id rate $max_rate {
                    set low [keylget stream_info $stream.low]
                    keylset stream_info $stream.cur_rate [mpexpr int($low * $rate)]
                }
                set stream_info [::ixia::_get_nodrop_rate_run_traffic $stream_info]

                # check for error
                if {[keylget stream_info status] == $::FAILURE} {
                    keylset retlist status $::FAILURE
                    keylset retlist log [keylget stream_info log]
                    return $retlist
                }

                # see if the lst run is OK
                if {[keylget stream_info nodrop]} {
                    # last run is successful
                    keylset retlist status $::SUCCESS
                    foreach stream $stream_id {
                        set low [keylget stream_info $stream.low]
                        keylset retlist $stream.nodrop_percent \
                            [expr 100.0 * $low]
                        keylset retlist $stream.nodrop_pps \
                            [keylget stream_info $stream.cur_rate]
                    }
                    return $retlist
                } else {
                    # this is an error in convergence due to 
                    # correlation of the stream performance
                    keylset retlist status $::FAILURE
                    keylset retlist log "Failed in final validation"
                    return $retlist
                }
            }
        } 
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::_get_nodrop_rate_run_traffic
#
# Description:
#     This command runs traffic as specified in the param
#     This should not be called manually
#
# Synopsis:
#    ::ixia::_get_nodrop_rate_run_traffic
#
# Arguments:
#    stream_info
#
# Return Values:
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
proc ::ixia::_get_nodrop_rate_run_traffic stream_info {
    
    set run_time_sec [keylget stream_info run_time_sec]
    set port_handle_list [keylget stream_info port_handle]
    set stream_id [keylget stream_info stream_id]
    set mode_even [keylget stream_info mode_even]

    # display the iteration
    puts "=========================================="
    puts [format "  %25s %25s %25s" StreamID TrafficRate RateScale]

    # modify the stream rates
    set total_tx_pkts 0
    foreach stream $stream_id {
        set handle [keylget stream_info $stream.tx_port_handle]
        set rate [keylget stream_info $stream.cur_rate]
        set burst_size($stream) [mpexpr $rate* $run_time_sec]
        incr total_tx_pkts $burst_size($stream)

        if {$mode_even} {
            puts [format "  %25s %25.0f %25.3f" $stream $rate [keylget stream_info cur]]
        } else {
            puts [format "  %25s %25.0f %25.3f" $stream $rate [keylget stream_info $stream.cur]]
        }

        set stream_modify [ixia::traffic_config                  \
                           -mode            modify               \
                           -port_handle     $handle              \
                           -stream_id       $stream              \
                           -pkts_per_burst  $burst_size($stream) \
                           -rate_pps        $rate                \
                           -transmit_mode   single_burst]
        if {[keylget stream_modify status] == $::FAILURE} {
            keylset stream_info status $::FAILURE
            keylset stream_info log [keylget stream_modify log]
            return $stream_info
        }
    }
    puts ""

    # clear stats
    set clear_stats [ixia::traffic_control              \
                         -port_handle $port_handle_list \
                         -action      clear_stats]
    
    if {[keylget clear_stats status] == $::FAILURE} {
        keylset stream_info status $::FAILURE
        keylset stream_info log [keylget clear_stats log]
        return $stream_info
    }

    # start traffic
    set start_traffic [ixia::traffic_control              \
                           -port_handle $port_handle_list \
                           -action      run]
    if {[keylget start_traffic status] == $::FAILURE} {
        keylset stream_info status $::FAILURE
        keylset stream_info log [keylget start_traffic log]
        return $stream_info
    }
   

    # display if desired
    if {[keylget stream_info display]} {
        set start_time [clock second]
        set traffic_time [mpexpr $start_time + $run_time_sec +2]
        while {[clock second] < $traffic_time} {
            set before_stats [clock second]
            
            # get per stream info
            set stream_info [_get_nodrop_rate_get_stats $stream_info]
            if {[keylget stream_info status] == $::FAILURE} {
                return $stream_info
            }

            puts "==> At time [mpexpr [clock second] -$start_time]"
            foreach stream $stream_id {
              puts \
               [format "    %s: %s %10.0f; %s %10.0f; %s %10d; %s %10d" \
                  "Stream $stream" \
                  "TxRate"  [keylget stream_info $stream.tx.rate]  \
                  "RxRate"  [keylget stream_info $stream.rx.rate]  \
                  "TxTotal" [keylget stream_info $stream.tx.total] \
                  "RxTotal" [keylget stream_info $stream.rx.total] ]
            }
            if {[clock second] == $before_stats} {
                after 1000
            }
        }
    } else {
        # display off
        sleep [$run_time_sec+2]
    }

    # polling till RX rates are zero
    puts "==> Polling for RX rate to down to zero..."
    set start_polling_time [clock second]
    set poll_timeout [mpexpr $start_polling_time + [keylget stream_info poll_timeout_sec]]
    
    while {[clock second] <= $poll_timeout} {
        # poll the result
        set stream_info [_get_nodrop_rate_get_stats $stream_info]
        if {[keylget stream_info status] == $::FAILURE} {
            return $stream_info
        }
        
        set all_rx_zero 1
        foreach stream $stream_id {
            set rx_rate [keylget stream_info $stream.rx.rate]
            puts "    Stream $stream_id RX rate $rx_rate"
            if {$rx_rate > 0}  {
                set all_rx_zero 0
            }
        }
        if {$all_rx_zero} break
    }

    # stop everything
    set stop_traffic [ixia::traffic_control              \
                          -port_handle $port_handle_list \
                          -action      stop]
    if {[keylget stop_traffic status] == $::FAILURE} {
        keylset stream_info status $::FAILURE
        keylset stream_info log [keylget stop_traffic log]
        return $stream_info
    }

    # fill in the loss information
    set actual_tx [keylget stream_info total_tx_pkts]
    if {$total_tx_pkts != $actual_tx} {
        # tester reports different number of TX than expected!
        keylset stream_info status $::FAILURE
        keylset stream_info log "Total TX reported by Ixia \
           $actual_tx is different from configured $total_tx_pkts; \
           is TX rate over linerate?"
    }

    # check for total RX
    if {[keylget stream_info total_rx_pkts] == $actual_tx} {
        keylset stream_info nodrop 1
    } else {
        keylset stream_info nodrop 0
    }

    # per stream nodrop is also needed for uneven case
    # we diaplay loss info for all streams
    puts "==> Stream loss info:"
    foreach stream $stream_id {
        if {[keylget stream_info $stream.rx.total] == 
            [keylget stream_info $stream.tx.total] } {
            puts "    Stream $stream has NO loss"
            keylset stream_info $stream.nodrop 1
        } else {
            puts "    Stream $stream has loss (!!)"
            keylset stream_info $stream.nodrop 0
        } 
    }

    keylget stream_info status $::SUCCESS                     
    return $stream_info
}
##Internal Procedure Header
# Name:
#    ::ixia::_get_nodrop_rate_get_stats
#
# Description:
#     This command gets traffic stats as specified in the param
#     This should not be called manually
#
# Synopsis:
#    ::ixia::_get_nodrop_rate_get_stats
#
# Arguments:
#    stream_info
#
# Return Values:
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
proc ::ixia::_get_nodrop_rate_get_stats stream_info {

    # needed: total_tx_pkts, total_rx_pkts, and individual tx,
    # rx rates  and total pkt counts for the streams
    
    after 5000

    set total_tx_pkts 0
    set total_rx_pkts 0
    set zero_rx_streams {}
    set stream_id [keylget stream_info stream_id]
    set tx_port_handle [keylget stream_info tx_port_handle]
    set rx_port_handle [keylget stream_info rx_port_handle]
    
    for {set i 0} {$i < 10} {incr i} {
        set stats [ixia::traffic_stats \
                       -port_handle [keylget stream_info port_handle] \
                       -mode stream \
                       -stream $stream_id]
        if {[keylget stats status] == $::FAILURE} {
            keylset stream_info status $::FAILURE
            keylset stream_info log [keylget stats log]
            return $stream_info
        }
        if {[keylget stats waiting_for_stats] == 0} { break }
        after 1000
    }
    if {$i == 10} {
        puts stderr "fail stats"
    }

    foreach stream $stream_id tx_handle $tx_port_handle {
        # we need to loop over all rx_port_handle list since
        # it is possible that one stream goes to multiple ports
        set rx_rate 0
        set rx_total 0
        foreach rx_handle $rx_port_handle {
            set rate [keylget stats $rx_handle.stream.$stream.rx.total_pkt_rate]
            set total [keylget stats $rx_handle.stream.$stream.rx.total_pkts]
            set rx_rate [expr $rx_rate + $rate]
            set rx_total [mpexpr $rx_total + $total]
        }
        keylset stream_info $stream.rx.rate $rx_rate
        keylset stream_info $stream.rx.total $rx_total
        set total_rx_pkts [mpexpr $total_rx_pkts + $rx_total]
        if {$rx_total == 0} {
            lappend zero_rx_streams $stream
        }

        set tx_rate [keylget stats $tx_handle.stream.$stream.tx.total_pkt_rate]
        set tx_total [keylget stats $tx_handle.stream.$stream.tx.total_pkts]
        keylset stream_info $stream.tx.rate $tx_rate
        keylset stream_info $stream.tx.total $tx_total
        
        set total_tx_pkts [mpexpr $total_tx_pkts + $tx_total]
    }

    keylset stream_info total_tx_pkts $total_tx_pkts
    keylset stream_info total_rx_pkts $total_rx_pkts
    keylset stream_info zero_rx_streams $zero_rx_streams
    keylset stream_info status $::SUCCESS
    return $stream_info
}


proc ::ixia::reboot_port_cpu { args } {
    
    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::reboot_port_cpu $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    set man_args {
        -port_list          REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args
    
    
    if {[info exists ::ixia::new_ixnetwork_api] && $::ixia::new_ixnetwork_api == 1} {
        foreach ph $port_list {
            set res [ixNetworkGetPortObjref $ph]
            if {[keylget res status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port object\
                        reference associated to the $ph port: [keylget res log]."
                return $returnList
            }
            set vport [keylget res vport_objref]
            ixNet exec resetPortCpu $vport
            ixNet exec setFactoryDefaults $vport
        }
    } else {
		set spaced_port_list [format_space_port_list $port_list]
        set res [ixia::reset_port_config $spaced_port_list]
        if {[keylget res status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to reset ports: [keylget res log]."
            return returnList
        }
        set res [ixia::set_factory_defaults $spaced_port_list write]
        if {[keylget res status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to factory defaults to ports: [keylget res log]."
            return returnList
        }
    }
    
    after 1000
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::get_port_list_from_connect { connect_status devices port_list } {

    set port_return {}

    if {[llength $devices] == 1} {
        foreach port $port_list {
            if {![catch {keylget connect_status port_handle.$devices.$port} \
                    temp_port]} {
                lappend port_return $temp_port
            }
        }
    } else {
        for {set index 0} {$index < [llength $devices]} {incr index} {
            set device [lindex $devices $index]
            set ports  [lindex $port_list $index]
            foreach port $ports {
                if {![catch {keylget connect_status port_handle.$device.$port} \
                        temp_port]} {
                    lappend port_return $temp_port
                }
            }
        }
    }

    return $port_return
}


proc ::ixia::find_in_csv { args } {
    set procName [lindex [info level [info level]] 0]

    ::ixia::utrackerLog $procName $args
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::find_in_csv $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    set man_args {
        -file_name REGEXP .+
    }
    
    set opt_args {
        -column1 ANY
        -column2 ANY
        -condition VCMD ::ixia::validate_find_in_csv_condition
    }
    
    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -optional_args  $opt_args     \
            -mandatory_args $man_args     } parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on parsing.\
                $parseError."
        return $returnList
    }
    
    # set default value for condition
    if {![info exists condition]} {
        set condition "=="
    }
    
    # Open the file_name
    if {[catch {open $file_name "r"} fileHandle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: while opening the file $file_name"
        return $returnList
    }
    
    # Get the name of the columns
    set header [split [gets $fileHandle] ,]
    set line_length [llength $header]
              
    if {[info exists column1]} {
        set column_index_1 -1
        set index 0
        foreach el $header {
            set search [lsearch $el $column1]
            if {$search != -1 || $el == $column1} {
                set column_index_1 $index
            }
            incr index
        }
        
        if {$column_index_1 == -1} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: cannot find column named $column1"
            close $fileHandle
            return $returnList
        }
    }
    
    # If columns2 exists and is not a number
    if {[info exists column2]} {
        set column_index_2 -1
        set index 0
        foreach el $header {
            set search [lsearch $el $column2]
            if {$search != -1 || $el == $column2} {
                set column_index_2 $index
            }
            incr index
        }

        if { $column_index_2 == -1} {
            unset column_index_2
        }
    }
    
    keylset returnList status $::SUCCESS
    
    set index 1
    while {![eof $fileHandle]} {
        set column1_value ""
        set column2_value ""
        
        set line [split [gets $fileHandle] ,]
        if {[llength $line] != $line_length} {
            continue
        }
        
        if {[info exists column_index_1] && [info exists column_index_2]} {;# If both columns are given
            set column1_value [lindex $line $column_index_1]
            set column2_value [lindex $line $column_index_2]
            
            if {$column1_value == "" || $column1_value == "N/A"} {
                set column1_value 0
            }
            
            if {$column2_value == "" || $column2_value == "N/A"} {
                set column2_value 0
            }

            if {[string is double -strict $column1_value] && [string is double -strict $column2_value]} {
                if {[catch {eval {expr $column1_value $condition $column2_value}} outcome]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: while evaluating '$column1_value $condition $column2_value: $outcome'"
                    close $fileHandle
                    catch {keyldel returnList row}
                    catch {keyldel returnList row_count}
                    return $returnList
                }
            } else {
                set outcome 0
                if {$condition == "==" || $condition == "!=" || $condition == "<" ||
                    $condition == ">" || $condition == "<=" || $condition == ">=" } {
                    set comparison [string compare $column1_value $column2_value]
                    switch -- $condition {
                        == {
                            if {$comparison == 0}  {
                                set outcome 1
                            }
                        }
                        != {
                            if {$comparison != 0} {
                                set outcome 1
                            }
                        }
                        < {
                            if {$comparison == -1} {
                                set outcome 1
                            }
                        }
                        > {
                            if {$comparison == 1} {
                                set outcome 1
                            }
                        }
                        <= {
                            if {$comparison <= 0} {
                                set outcome 1
                            }
                        }
                        >= {
                            if {$comparison >= 0} {
                                set outcome 1
                            }
                        }
                    }
                }
            }
        } elseif {[info exists column_index_1] && [info exists column2]} {;# If second column is number
            set column1_value [lindex $line $column_index_1]
            set column2_value $column2
            
            set column1_value [string trimleft $column1_value "\""]
            set column1_value [string trimright $column1_value "\""]
            
            if {$column1_value == "" || $column1_value == "N/A"} {
                set column1_value 0
            }
            
            if {$column2_value == "" || $column2_value == "N/A"} {
                set column2_value 0
            }
            if {[string is double -strict $column1_value] && [string is double -strict $column2_value]} {
                if {[catch {eval {expr $column1_value $condition $column2_value}} outcome]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: while evaluating '$column1_value $condition $column2_value: $outcome'"
                    close $fileHandle
                    catch {keyldel returnList row}
                    catch {keyldel returnList row_count}
                    return $returnList
                }
            } else {
                set outcome 0
                if {$condition == "==" || $condition == "!=" || $condition == "<" ||
                    $condition == ">" || $condition == "<=" || $condition == ">=" } {
                    set comparison [string compare $column1_value $column2_value]
                    switch -- $condition {
                        == {
                            if {$comparison == 0}  {
                                set outcome 1
                            }
                        }
                        != {
                            if {$comparison != 0} {
                                set outcome 1
                            }
                        }
                        < {
                            if {$comparison == -1} {
                                set outcome 1
                            }
                        }
                        > {
                            if {$comparison == 1} {
                                set outcome 1
                            }
                        }
                        <= {
                            if {$comparison <= 0} {
                                set outcome 1
                            }
                        }
                        >= {
                            if {$comparison >= 0} {
                                set outcome 1
                            }
                        }
                    }
                }
            }
        } else {
            set outcome 1;
        }
        if {$outcome} {;# Include the current row in the return list
            foreach el_header $header el_line $line {
                keylset returnList row.$index.$el_header $el_line
            }
            incr index
        }
    }
    
    # Close the file_name
    close $fileHandle
    
    keylset returnList row_count [expr {$index - 1}]
    
    return $returnList
}

proc ::ixia::validate_find_in_csv_condition {args} {
    set error 1

    set args_list [list * / % + << >> < > <= >= == != eq ne & ^ | && ||]
    foreach element $args_list {
        if {$element == $args} {
            set error 0
        }
    }
    
    if {$error} {
        return [list 0 "condition must be one of the following: *,/,%,+,<<,>>,<,>,<=,>=,==,!=,eq,ne,&,^,|,&&,||"]
    }
    
    return 1
}

proc ::ixia::reset_port {args}  {

    set procName [lindex [info level [info level]] 0]
    variable ixnetwork_port_handles_array
    
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::reset_port $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    set man_args {
        -mode                    CHOICES set_factory_defaults remove_protocol
        -port_handle             REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    set opt_args {
        -protocol                CHOICES bfd bgp cfm eigrp igmp isis lacp ldp efm
                                 CHOICES mld mplstp ospfv2 ospfv3 pim
                                 CHOICES rip ripng rsvp static stp all
                                 DEFAULT all
    }
    
    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args -optional_args $opt_args
    

    if {$port_handle == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Empty port handles specified.\
                Provide valid port handles"
        return $returnList
    }

    switch -- $mode {    
        set_factory_defaults {
            foreach port $port_handle {
                if {[info exists ixnetwork_port_handles_array($port)]} {
                    set vport $ixnetwork_port_handles_array($port)
                    if {[ixNet exec setFactoryDefaults $vport] != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to set the port $port\
                                to factory default."
                        return $returnList        
                    } else {
                        # reset protocols
                        set ret_val [::ixia::reset_protocol_interface_for_port \
                                    -port_handle $port]
                        if {[keylget ret_val status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in ::ixia::reset_port: \
                                    Resetting port $port failed (::ixia::reset_protocol_interface_for_port)"
                            return $returnList
                        }                        
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Invalid port handle specified.\
                            Provide a valid port handle."
                    return $returnList
                }
            }
        }
        remove_protocol {
            if {[info exists protocol]} {
                array set translate_hlt_ixnet [list \
                        efm linkOam     \
                        ospfv2 ospf     \
                        ospfv3 ospfV3   \
                        pim pimsm       \
                        bfd bfd         \
                        bgp bgp         \
                        cfm cfm         \
                        eigrp eigrp     \
                        igmp igmp       \
                        isis isis       \
                        lacp lacp       \
                        ldp ldp         \
                        static static   \
                        stp stp         \
                        mld mld         \
                        ripng ripng     \
                        rip rip         \
                        rsvp rsvp       \
                        all all         ]

                set translated_protocol $translate_hlt_ixnet($protocol)
                if {$translated_protocol == "all"} {
                    debug "$procName : Retreiving all protocols on the port for removing"
                    set p_regexp [regexp -inline -all {([\w]+)\s\([\w\s:,]+getList\)} [ixNet help [ixNet getRoot]/vport/protocols]]
                    debug "$procName : $p_regexp"
                    set protocol_list [list]
                    for {set x 1} {$x < [llength $p_regexp ]} {incr x 2} {lappend protocol_list [lindex $p_regexp  $x]}
                    debug "$procName : protocol_list: $protocol_list"
                } else {
                    set protocol_list $translated_protocol
                }

                foreach port $port_handle {
                    if {[info exists ixnetwork_port_handles_array($port)]} {
                        set vport $ixnetwork_port_handles_array($port)
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Invalid port handle specified.\
                                Provide a valid port handle."
                        return $returnList
                    }
                    foreach reset_protocol $protocol_list {
                        debug "$procName : resetting protocol: $reset_protocol"
                        set reset_protocol_handle($reset_protocol) [ixNet getList [ixNet getList $vport protocols] $reset_protocol]
                        set p_regexp [regexp -inline -all {([\w]+)\s\([\w\s:,]+getList\)} [ixNet help $reset_protocol_handle($reset_protocol)]]
                        if {[llength $p_regexp ] != 0} {
                            debug "$procName : p_regexp: $p_regexp"
                            set protocol_list_tmp [list]
                            for {set x 1} {$x < [llength $p_regexp ]} {incr x 2} {lappend protocol_list_tmp [lindex $p_regexp  $x]}
                            set protocol_child_list $protocol_list_tmp
                            debug "$procName : protocol_child_list: $protocol_child_list"
                            foreach child $protocol_child_list {
                                foreach obj [ixNet getL $reset_protocol_handle($reset_protocol) $child] {
                                    debug "$procName : removing $obj"
                                    if {[catch {set remove_child_obj [ixNet remove $obj]} removeError]} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in ::ixia::reset_port. \
                                                    $obj doesnt exist. $removeError"
                                            return $returnList
                                    }                                    
                                    debug "$procName : remove_child_obj: $remove_child_obj"
                                }
                            }
                        }
                        if {$reset_protocol != "static"} {
                            set disable_protocol [ixNet setAttribute $reset_protocol_handle($reset_protocol) -enabled "False"]
                                if {$disable_protocol != "::ixNet::OK"} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: Unable to disable the protocol $reset_protocol\
                                            for the port $port."
                                    return $returnList
                                }
                        }
                    }
                    
                    #Clear the corresponding protocol arrays in the HLTAPI
                    
                    set temp_port [split $port /]
                    set chasNum [lindex $temp_port 0] 
                    set cardNum [lindex $temp_port 1]
                    set portNum [lindex $temp_port 2]
                
                    switch -- $translated_protocol {        
                        bgp {
                            # BGP
                            ::ixia::updateBgpHandleArray -mode reset -port_handle $port
                        }
                        igmp {
                            # IGMP
                            ::ixia::igmp_clear_all_hosts $chasNum $cardNum $portNum

                        }
                        isis {
                           # ISIS
                           ::ixia::updateIsisHandleArray reset $port 
                        }
                        lacp {
                            # LACP
                            ::ixia::updateLacpHandleArray reset $port
                        }
                        ldp {
                            # LDP
                            ::ixia::updateLdpHandleArray reset $port
                        }
                        mld {
                            # MLD
                            ::ixia::updateMldHandleArray -mode delete -port [list $chasNum $cardNum \
                                    $portNum]
                        }
                        ospf {
                            ::ixia::updateOspfHandleArray reset $port NULL ospfv2
                        }
                        ospfV3 {
                            ::ixia::updateOspfHandleArray reset $port NULL ospfv3
                        }
                        pimsm {
                            # PIM
                            ::ixia::updatePimsmHandleArray -mode reset -handle_name_pattern $port
                        }
                        rip {
                            # RIP
                            ::ixia::ripClearAllRouters $chasNum $cardNum $portNum
                        }
                        rsvp {
                            # RSVP
                            ::ixia::updateRsvpHandleArray -mode reset -handle_value $port
                            if {[info exists ::ixia::rsvp_tunnel_parameters]} {
                                unset ::ixia::rsvp_tunnel_parameters
                            }
                            array set ::ixia::rsvp_tunnel_parameters {}
                        }
                        all {                        
                            # remove protocol stack
                            set pstack_regexp [regexp -inline -all {([\w]+)\s\([\w\s:,]+getList\)} [ixNet help [ixNet getRoot]/vport/protocolStack]]                            
                            if {[llength $pstack_regexp ] != 0} {
                                set protocol_stack_list ""
                                for {set x 1} {$x < [llength $pstack_regexp ]} {incr x 2} {if {[lindex $pstack_regexp  $x] != "options"} {lappend protocol_stack_list [lindex $pstack_regexp  $x]}}
                                debug "$procName : protocol_stack_list: $protocol_stack_list"
                                foreach pstack $protocol_stack_list {
                                    foreach child [ixNet getL $vport/protocolStack $pstack] {
                                        if {[catch {ixNet remove $child} removeError]} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in ::ixia::reset_port. \
                                                    $child doesnt exist. $removeError"
                                            return $returnList
                                        }
                                    }
                                }
                            }
                            
                            # remove interface
                            foreach interface [ixNet getL  $vport interface] {ixNet remove $interface}
                            
                            set ret_val [::ixia::reset_protocol_interface_for_port \
                                    -port_handle $port]
                            if {[keylget ret_val status] != $::SUCCESS} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in ::ixia::reset_port: \
                                        Resetting port $port failed (::ixia::reset_protocol_interface_for_port)"
                                return $returnList
                            }
                        }
                        default {
                            debug "$procName : No variables to clear for $translated_protocol"
                        }
                    }                   
                }
                
                if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to commit field values. $err"
                    return $returnList
                }

            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Please specify the protocol to be removed from the port.\
                        Valid options are: arp bfd bgp cfm eigrp igmp isis lacp ldp efm mld \
                        mplstp ospfv2 ospfv3 pim ping rip ripng rsvp static stp all"
                return $returnList
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

namespace eval ::ixia::stats_util {}

#     Procedure name: ::ixia::stats_util::get_default_snapshot_settings
#     Description:
#   Get the default system settings for snapshot operation. Note that the name of the default snapshot settings is predefined as "DefaultSnapshotSettings"
#     Return:
#           A list of key/value specifying the default system settings.
proc ::ixia::stats_util::get_default_snapshot_settings { }  {
      set status ""
      catch {set status [ixNet exec GetDefaultSnapshotSettings ] } err
      if { $status != "" }  {
           set settingList [ ::ixia::stats_util::parse_default_snapshot_settings_array $status ]
           return $settingList 
      }  else {
           return $err
      }
}

# Procedure: ::ixia::stats_util::parse_default_snapshot_settings_array 
# Description: Parse an array returned by an ixNet exec function, 
#              such as ::ixNet::OK-{kArray,{{kInteger,0},{kInteger,2}}}
# Input arguments: a
#      i_array  - string returned by an ixNet exec function
# Return:
#      a list of values embedded in the input string.
proc ::ixia::stats_util::parse_default_snapshot_settings_array { i_array } {
    set tmp1 [expr {[string first "-" $i_array ] + 1 } ]
    set tmp2 [string range $i_array $tmp1 end ]
    set tmp2 [lindex $tmp2 0]
    # get list of lists
    set tmp3 [string trimleft $tmp2 "kArray,"]
    set tmp3 [lindex $tmp3 0]

    set myLists [split $tmp3 ",\}"]
    set finalList [list]
    foreach el $myLists {
        if {$el != ""} {
            lappend finalList $el
        }
    }
    set count [llength $finalList]
    set myValues ""
    for {set i 1} { $i < $count } { incr i 2 } {
        lappend myValues [lindex $finalList $i]
    }
    return $myValues
}

proc ::ixia::convert_portname_to_vport { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::convert_portname_to_vport $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    if {[llength $args] == 1} {
		set result [::ixia::ixNetworkGetVportByName $args]
		if {[keylget result status] != $::SUCCESS} {
            debug "::ixia::convert_portname_to_vport: ixNetworkGetVportByName failed"
            return "::ixNet::OBJ-/vport:0"
        }
        return [keylget result vport_handle]
    }
	
	set man_args {
        -port_name    ANY
    }
	
	set opt_args {}
	
	::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
			
	set result [::ixia::ixNetworkGetVportByName $port_name]
	
	if {[keylget result status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log [keylget result log]
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList handle [keylget result vport_handle]
    
    return $returnList	
}
