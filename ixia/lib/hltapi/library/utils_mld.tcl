##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_mld.tcl
#
# Purpose:
#     A script development library containing utility procs for pim APIs
#     for test automation with the Ixia chassis.
#
# Author:
#    D. Rusu
#
# Usage:
#
# Description:
#
# Requirements:
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

##Internal Procedure Header
# Name:
#    ::ixia::mldSetHostOptions
#
# Description:
#    This command sets the options for the current mldHost. It executes
#    in the scope of the calling procedure.
#
# Synopsis:
#
# Arguments:
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
proc ::ixia::mldSetHostOptions {} {
    uplevel 1 {
        foreach {mldCommand optionsArray}  [array get mldCommandArray] {
            foreach {item itemName} [array get $optionsArray] {
                if {![catch {set $itemName} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {$mldCommand config -$item $value}
                }
            }
        }

        if {[info exists mld_version]} {
            if {$mld_version == "v1"} {
                mldHost config -version mldVersion1
            } else  {
                mldHost config -version mldVersion2
            }
        }
        
        if {[info exists unsolicited_report_interval]} {
            if {$unsolicited_report_interval == 0} {
                mldHost config -enableUnsolicited false
            } else  {
                mldHost config -enableUnsolicited true
                mldHost config -reportFrequency $unsolicited_report_interval
            }
        } elseif {$mode == "create"} {
            # Default frequency 10 for v2, 100 for v1
            set defaultReportFrequency 10
            if {[info exists mld_version]} {
                if {[string equal $mld_version "v1"]} {
                    set defaultReportFrequency 100
                }
            }
            mldHost config -enableUnsolicited true
            mldHost config -reportFrequency $defaultReportFrequency
        }
        
        # When at least one of max_response_control or max_response_time
        # is modified, save the values then set enableImmediateResponse
        if {[info exists max_response_control] \
                || [info exists max_response_time]} {
                
            if {[info exists max_response_control]} {
                set mld_handles_array($mld_host,resp_ctrl) $max_response_control
            }
            
            if {[info exists max_response_time]} {
                set mld_handles_array($mld_host,resp_time) $max_response_time
            }

            if {($mld_handles_array($mld_host,resp_ctrl) == 1) \
                    && [info exists mld_handles_array($mld_host,resp_time)] \
                    && ($mld_handles_array($mld_host,resp_time) == 0)} {
                mldHost config -enableImmediateResponse true
            } else  {
                mldHost config -enableImmediateResponse false
            }
        }

        if {[info exists filter_mode]} {
            updateMldHandleArray -mode create -handle $mld_host \
                    -port $interface -filter_mode $filter_mode
        }
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::updateMldHandleArray
#
# Description:
#    This command creates or deletes an element in mld_handles_array.
#
#    An element in mld_handles_array is in the form of
#         ($session_handle,port)  port
#         ($session_handle,filter) filter_mode
#
#    where $session_handle is the mld session handle
#
# Synopsis:
#    ::ixia::updateMldHandleArray
#        -mode CHOICES create modify delete
#        [-handle]
#        [-port]
#        [-filter_mode]
#
# Arguments:
#    -mode
#        This option defines the action to be taken. Valid choices are:
#        create - inserts a value in array
#        modify - modifies a value in array
#        delete - when -handle option is present, the specified key is
#            deleted from array. If -port is present, all keys having port
#            value equal with the option are deleted.
#    -handle
#        Mld session handle. Used as key in array.
#    -port
#        Port on which the session was created.
#    -filter
#        Filter mode of session (include / exclude).
#
# Return Values:
#    $::TCL_OK for success
#    $::TCL_ERROR for failure to delete an element
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::updateMldHandleArray {args} {
    set procName [lindex [info level [info level]] 0]

    set mandatory_args {
        -mode CHOICES create modify delete
    }
    
    set optional_args {
        -handle
        -port
        -filter_mode            
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args \
                    -optional_args $optional_args     \
                    -mandatory_args $mandatory_args   }]} {
        return $::TCL_ERROR
    }

    variable  mld_handles_array

    if {($mode == "create") || ($mode == "modify")} {
        set mld_handles_array($handle,port) $port
        set mld_handles_array($handle,filter) $filter_mode
    }
    
    if {$mode == "delete"} {
        if {[info exists handle]} {
            array unset mld_handles_array $handle,*
            
            updateMldGroupRangeArray -mode delete -handle $handle
        } elseif {[info exists port]} {
            foreach {session intf} [array get mld_handles_array "*,port"] {
                if {$port == $intf} {
                    set mld_handle [string range $session 0 end-5]
                    
                    array unset mld_handles_array $mld_handle,*
                    
                    updateMldGroupRangeArray -mode delete -handle $mld_handle
                }
            }
        }
    }
    
    return $::TCL_OK
}


##Internal Procedure Header
# Name:
#    ::ixia::nextMldHandle
#
# Description:
#    Returns the next available mld session handle to be used in
#    mld_handles_array.
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    mld_session_handle
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::nextMldHandle {} {
    variable mld_handles_array

    set orderedNames [lsort -dictionary [array names mld_handles_array]]
    set lastName [lindex $orderedNames end]
    regsub {([^0-9]+)([0-9]+).*} $lastName {\2} lastValue
    set newValue [expr $lastValue + 1]
    return "mldHost$newValue"
}


##Internal Procedure Header
# Name:
#    ::ixia::updateMldGroupRangeArray
#
# Description:
#    This command creates or deletes an element in mld_handles_array.
#
#    An element in mld_handles_array is in the form of
#         ($group_range_handle)  session_handle
#
#    where $group_range_handle is the group range handle
#
# Synopsis:
#    ::ixia::updateMldGroupRangeArray
#        -mode CHOICES create modify delete
#        [-group_range_handle]
#        [-handle]
#
# Arguments:
#    -mode
#        This option defines the action to be taken. Valid choices are:
#        create - inserts a value in array
#        modify - modifies a value in array
#        delete - when -group_range_handle option is present, the specified
#            key is deleted from array. If -handle is present, all keys having
#            value equal with the option are deleted.
#    -group_range_handle
#        Group range handle. It is used as key in array.
#    handle
#        Mld session handle. Saved as value associated with the group range
#        handle.
#
# Return Values:
#    $::TCL_OK for success
#    $::TCL_ERROR for problems with parameters
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::updateMldGroupRangeArray {args} {
    set procName [lindex [info level [info level]] 0]

    set mandatory_args {
        -mode CHOICES create modify delete
    }
    
    set optional_args {
        -handle
        -group_range_handle
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args \
                    -optional_args $optional_args     \
                    -mandatory_args $mandatory_args   }]} {
        return $::TCL_ERROR
    }
    
    variable mld_group_ranges_array
    
    if {($mode == "create") || ($mode == "modify")} {
        set mld_group_ranges_array($group_range_handle) $handle
    }
    
    if {$mode == "delete"} {
        if {[info exists group_range_handle]} {
            array unset mld_group_ranges_array $group_range_handle
        } elseif {[info exists handle]}  {
            foreach {grp_range mld_handle} [array get mld_group_ranges_array] {
                if {$handle == $mld_handle} {
                    array unset mld_group_ranges_array $grp_range
                }
            }
        }
    }
    
    return $::TCL_OK
}


##Internal Procedure Header
# Name:
#    ::ixia::nextMldGroupRange
#
# Description:
#    Returns the next available group range handle to be used in
#    mld_group_ranges_array.
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    mld_group_range_handle
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::nextMldGroupRange {} {
    variable mld_group_ranges_array
    
    set orderedNames [lsort -dictionary [array names mld_group_ranges_array]]
    set lastName [lindex $orderedNames end]
    set newNumber [expr [string replace $lastName 0 9] + 1]
    return "groupRange$newNumber"
}