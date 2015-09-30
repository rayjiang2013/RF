##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_igmp.tcl
#
# Purpose:
#    A script development library containing IGMP APIs for test automation with
#    the Ixia chassis.
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - ::ixia::get_command_parameters
#    - ::ixia::igmp_add_group_member
#    - ::ixia::igmp_add_session_handle
#    - ::ixia::igmp_array_unset_values
#    - ::ixia::igmp_check_host_existence
#    - ::ixia::igmp_clear_all_groups
#    - ::ixia::igmp_clear_all_hosts
#    - ::ixia::igmp_create_group
#    - ::ixia::igmp_delete_group
#    - ::ixia::igmp_modify_group
#    - ::ixia::igmp_get_all_group_handles_session
#    - ::ixia::igmp_get_all_group_members
#    - ::ixia::igmp_get_all_host_handles_port
#    - ::ixia::igmp_get_next_handle
#    - ::ixia::igmp_get_port_handle_host
#    - ::ixia::igmp_get_host_handle_host
#    - ::ixia::igmp_get_filter_mode_host
#    - ::ixia::igmp_get_max_response_control_host
#    - ::ixia::igmp_get_max_response_time_host
#    - ::ixia::igmp_get_group_handle_group
#    - ::ixia::igmp_get_session_handle_group
#    - ::ixia::igmp_get_group_pool_handle_group
#    - ::ixia::igmp_get_session_handle_port
#    - ::ixia::igmp_group_members_by_port_session
#    - ::ixia::igmp_group_sessions_by_port
#    - ::ixia::igmp_modify_group_members
#    - ::ixia::igmp_modify_session_handles
#    - ::ixia::igmp_sort_handles
#    - ::ixia::igmp_select_host
#    - ::ixia::igmp_set_host
#    - ::ixia::igmp_set_server
#
# Requirements:
#    ixiaapiutils.tcl , a library containing TCL utilities
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
#    ::ixia::igmp_check_host_existence
#
# Description:
#    The procedure checks on an interface if an IGMP host is already created.
#
# Synopsis:
#    ::ixia::igmp_check_host_existence
#        intf
#        intf_description
#
# Arguments:
#        intf
#            A parameter containing a list with chassis card port where the
#            interface is located.
#        intf_description
#            The interface description of the interface.
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE
#    key:existence     value:0 - the interface has no IGMP hosts configured
#                      value:1 - the interface already has an IGMP host
#                            configured.
#    key:log       value:If status is failure, detailed information provided.
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

proc ::ixia::igmp_check_host_existence {intf intf_description} {
    
    foreach {chassis card port} $intf {}
    keylset returnList status $::SUCCESS
    keylset returnList existence 0
    if {[igmpVxServer select $chassis $card $port] != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to \
                igmpVxServer select $chassis $card $port"
    }
    set ret_code [igmpVxServer getFirstHost]
    if {$ret_code == 1} {
        return $returnList
    } else {
        while { $ret_code == 0 } {
            set host_intf_description \
                    [igmpHost cget -protocolInterfaceDescription ]
            if {$host_intf_description == $intf_description} {
                keylset returnList existence 1
                return $returnList
            }
            set ret_code [igmpVxServer getNextHost]
        }
        return $returnList
    }
}



proc ::ixia::igmp_array_operations {array_name array_operation element {match_regex {}}} {
    variable multicast_group_ip_to_handle
    variable multicast_source_ip_to_handle
    variable multicast_group_array
    variable multicast_source_array
    variable igmp_host_ip_handles_array
    
    keylset returnList status $::SUCCESS
    
    switch $array_operation {
        remove {
            switch $array_name {
                multicast_group_ip_to_handle {
                    if {[info exists [set array_name]($element)]} {
                        set values [set [set array_name]($element)]
                        if {([llength $values]>1)&&($match_regex!="")} {
                            # match the corresponding item
                            set matched_elem ""
                            foreach value $values {
                                if {[regexp $match_regex $value]} {
                                    set matched_elem $value
                                    break
                                }
                            }
                            set idx [lsearch $values $matched_elem]
                            set values [lreplace $values $idx $idx]
                            set [set array_name]($element) $values
                        } else {
                            unset [set array_name]($element)
                        }
                    }
                }
                multicast_group_array {
                    catch {unset [set array_name]($element,ip_addr_start)}
                    catch {unset [set array_name]($element,ip_addr_step)}
                    catch {unset [set array_name]($element,ip_prefix_len)}
                    catch {unset [set array_name]($element,num_groups)}
                }
                igmp_host_ip_handles_array {
                    catch {unset [set array_name]($element)}
                }
                default {}
            }
        }
        remapIds {
            set remap_handles ""
            foreach elem [join $element] {
                set remap_item [ixNet remapIds $elem]
                foreach {key value} [array get [set array_name]] {
                    foreach item $value {
                        if {$item == $elem} {
                            # replace item with remaped item
                            set new_value [regsub -all $item $value $remap_item]
                            set [set array_name]($key) $new_value
                        }
                    }
                }
                lappend remap_handles $remap_item
            }
            keylset returnList remap_handle_list $remap_handles
        }
    }
    
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::igmp_add_session_handle
#
# Description:
#    Adds a session_handle to the global array ::ixia::igmp_host_handles_array.
#
# Synopsis:
#    ::ixia::igmp_add_session_handle
#        session_handle
#        port_handle
#        host_handle
#        filter_mode
#
# Arguments:
#        session_handle
#            The session_handle for the session that must be added.
#        port_handle
#            The port where the session(IGMP host) is located.
#        host_handle
#            The host number of the IGMP host on the port.
#        filter_mode
#            Indicates how sources on the groups of that session should be
#            interpreted - include or exclude.
# Return Values:
#    A key list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:If status is failure, detailed information provided.
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

proc ::ixia::igmp_add_session_handle {args} {
    
    variable igmp_host_handles_array
    
    set mandatory_args {
        -session_handle
        -port_handle
        -host_handle
        -filter_mode
    }
    set optional_args {
        -max_response_control
        -max_response_time
    }
    if {[catch [::ixia::parse_dashed_args       \
                -args $args                     \
                -optional_args $optional_args   \
                -mandatory_args $mandatory_args ] value]} {
        
        keylset returnList status $::FAILURE
        keylset returnList log $value
        return $returnList
    }
    
    keylset tempList port_handle $port_handle
    keylset tempList host_handle $host_handle
    keylset tempList filter_mode $filter_mode
    
    if {[info exists max_response_control]} {
        keylset tempList max_response_control $max_response_control
    }
    
    if {[info exists max_response_time]} {
        keylset tempList max_response_time $max_response_time
    }
    
    set ::ixia::igmp_host_handles_array($session_handle) $tempList
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_modify_session_handle
#
# Description:
#    Modifies a session_handle to the global array
#    ::ixia::igmp_host_handles_array.
#
# Synopsis:
#    ::ixia::igmp_modify_session_handle
#        session_handle
#        port_handle
#        host_handle
#        filter_mode
#
# Arguments:
#        session_handle
#            The session_handle for the session that must be modified.
#        port_handle
#            The port where the session(IGMP host) is located.
#        host_handle
#            The host number of the IGMP host on the port.
#        filter_mode
#            Indicates how sources on the groups of that session should be
#            interpreted - include or exclude.
# Return Values:
#    A key list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:If status is failure, detailed information provided.
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

proc ::ixia::igmp_modify_session_handle {args} {
    
    variable igmp_host_handles_array
    
    set mandatory_args {
        -session_handle
    }
    set optional_args {
        -port_handle
        -host_handle
        -filter_mode
        -max_response_control
        -max_response_time
    }
    if {[catch [::ixia::parse_dashed_args       \
                -args $args                     \
                -optional_args $optional_args   \
                -mandatory_args $mandatory_args ] value]} {
        
        keylset returnList status $::FAILURE
        keylset returnList log $value
        return $returnList
    }
    set tempList $::ixia::igmp_host_handles_array($session_handle)
    
    if {[info exists port_handle]} {
        keylset tempList port_handle $port_handle
    }
    if {[info exists host_handle]} {
        keylset tempList host_handle $host_handle
    }
    if {[info exists filter_mode]} {
        keylset tempList filter_mode $filter_mode
    }
    
    if {[info exists max_response_control]} {
        keylset tempList max_response_control $max_response_control
    }
    
    if {[info exists max_response_time]} {
        keylset tempList max_response_time $max_response_time
    }
    
    set ::ixia::igmp_host_handles_array($session_handle) $tempList
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_modify_session_handles
#
# Description:
#    Modifies some group configurations for a list of session_handles.
#    If the sourceMode (include, exclude) is modified then the modifications
#    are also made to the global array ::ixia::igmp_host_handles_array
#
# Synopsis:
#    ::ixia::igmp_modify_session_handles
#        handle
#        parameter
#        parameter_value
#
#
# Arguments:
#        handle
#            The session handles where to apply modifications on the group
#            members.
#        parameter
#            The parameter that has to be modified on the group.
#        parameter_value
#            The value that has to be set for the given parameter name.
#
# Return Values:
#    A key list
#    key:status    value:$::SUCCESS | $::FAILURE.
#    key:log       value:If status is failure, detailed information provided.
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

proc ::ixia::igmp_modify_session_handles {handle parameter parameter_value \
            {write_flag no_write}} {
    
    set groupPortRet [::ixia::igmp_group_sessions_by_port $handle]
    if {[keylget groupPortRet status] == 0} { return $groupPortRet }
    array set sessions_per_port [keylget groupPortRet port_group]
    
    foreach port_handle [array names sessions_per_port] {
        set port_list [format_space_port_list $port_handle]
        foreach {chassis card port} [lindex $port_list 0] {}
        
        if {$parameter != "enable"} {
            # Don't add the port for configuration write if we only enable/disable the session
            # writeConfigTohardware stops the protocols
            ::ixia::addPortToWrite $chassis/$card/$port
        }
        
        # Select server
        if {[igmpVxServer select $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to \
                    igmpVxServer select $chassis $card $port"
            return $returnList
        }
        foreach session_handle $sessions_per_port($port_handle) {
            # Get host_handle
            set hostRet [::ixia::igmp_get_host_handle_host $session_handle]
            if {[keylget hostRet status] == 0} { return $hostRet }
            set host_handle [keylget hostRet host_handle]
            if {$parameter == "sourceMode"} {
                set retCode [::ixia::igmp_modify_session_handle \
                        -session_handle $session_handle      \
                        -port_handle    $port_handle         \
                        -host_handle    $host_handle         \
                        -filter_mode    $parameter_value     ]
                if {[keylget retCode status] == 0} { return $retCode }
            }
            set allGroupMembers [::ixia::igmp_get_all_group_members  \
                    $session_handle]
            if {[llength $allGroupMembers] > 0} {
                # Select host
                if {[igmpVxServer getHost $host_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to\
                            igmpVxServer getHost $host_handle"
                    return $returnList
                }
                foreach group_member  $allGroupMembers {
                    # Get group_handle
                    set groupRet [::ixia::igmp_get_group_handle_group \
                            $group_member]
                    if {[keylget groupRet status] == 0} { return $groupRet }
                    set group_handle [keylget groupRet group_handle]
                    if {[igmpHost getGroupRange $group_handle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to\
                                igmpHost getGroupRange $group_handle."
                        return $returnList
                    }
                    igmpGroupRange config -$parameter $parameter_value
                    if {[igmpHost setGroupRange $group_handle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to\
                                igmpHost setGroupRange $group_handle."
                        return $returnList
                    }
                }
            }
        }
        # Set the IGMP Server
        if {$write_flag == "write"} {
            set retSetServer [::ixia::igmp_write_server]
        } else  {
            set retSetServer [::ixia::igmp_set_server]
        }
        if {[keylget retSetServer status] == 0} { return $retSetServer }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_modify_group_members
#
# Description:
#    Modifies some group configurations for a list of group_members.
#    If the sourceMode (include, exclude) is modified then the modifications
#    are also made to the global array ::ixia::igmp_host_handles_array
#
# Synopsis:
#    ::ixia::igmp_modify_group_members
#        handle
#        parameter
#        parameter_value
#
#
# Arguments:
#        handle
#            The group_member_handles where to apply modifications.
#        parameter
#            The parameter that has to be modified on the group.
#        parameter_value
#            The value that has to be set for the given parameter name.
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE.
#    key:log       value:If status is failure, detailed information provided.
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

proc ::ixia::igmp_modify_group_members {handle parameter parameter_value \
            {write_flag no_write}} {
    
    set groupPortRet [::ixia::igmp_group_members_by_port_session $handle]
    if {[keylget groupPortRet status] == 0} { return $groupPortRet }
    array set groups_per_port_session [keylget groupPortRet port_session_group]
    
    foreach port_handle [array names groups_per_port_session] {
        set port_list [format_space_port_list $port_handle]
        foreach {chassis card port} [lindex $port_list 0] {}
        
        if {$parameter != "enable"} {
            ::ixia::addPortToWrite $chassis/$card/$port
        }
        
        # Select server
        if {[igmpVxServer select $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to\
                    igmpVxServer select $chassis $card $port"
            return $returnList
        }
        foreach {session_handle groups_per_session} \
                $groups_per_port_session($port_handle) {
                    
            # Get host_handle
            set hostRet [::ixia::igmp_get_host_handle_host $session_handle]
            if {[keylget hostRet status] == 0} { return $hostRet }
            set host_handle [keylget hostRet host_handle]
            if {$parameter == "sourceMode"} {
                set retCode [::ixia::igmp_modify_session_handle \
                -session_handle $session_handle      \
                -port_handle    $port_handle         \
                -host_handle    $host_handle         \
                -filter_mode    $parameter_value     ]
                
                if {[keylget retCode status] == 0} { return $retCode }
            }
            set allGroupMembers $groups_per_session
            if {[llength $allGroupMembers] > 0} {
                # Select host
                if {[igmpVxServer getHost $host_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to\
                    igmpVxServer getHost $host_handle"
                    return $returnList
                }
                foreach group_member  $allGroupMembers {
                    # Get group_handle
                    set groupRet [::ixia::igmp_get_group_handle_group \
                    $group_member]
                    if {[keylget groupRet status] == 0} { return $groupRet }
                    set group_handle [keylget groupRet group_handle]
                    if {[igmpHost getGroupRange $group_handle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to\
                        igmpHost getGroupRange $group_handle."
                        return $returnList
                    }
                    igmpGroupRange config -$parameter $parameter_value
                    if {[igmpHost setGroupRange $group_handle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to\
                        igmpHost setGroupRange $group_handle."
                        return $returnList
                    }
                }
            }
        }
        # Set the IGMP Server
        if {$write_flag == "write"} {
            set retSetServer [::ixia::igmp_write_server]
        } else  {
            set retSetServer [::ixia::igmp_set_server]
        }
        
        if {[keylget retSetServer status] == 0} { return $retSetServer }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_all_group_members
#
# Description:
#    Given a session_handle it returns all the group members created on that
#    session.
#
# Synopsis:
#    ::ixia::igmp_get_all_group_members
#        session_handle
#
# Arguments:
#        session_handle
#            The session handle where to search for group members.
# Return Values:
#        A list of all group members on that session.
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

proc ::ixia::igmp_get_all_group_members {session_handle} {
    
    variable igmp_group_handles_array
    
    set all_group_members [list ]
    foreach group_member [array names ::ixia::igmp_group_handles_array] {
        
        set session_handle_reg [keylget \
                ::ixia::igmp_group_handles_array($group_member) session_handle]
        
        if {$session_handle == $session_handle_reg} {
            lappend all_group_members $group_member
        }
    }
    return $all_group_members
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_all_group_handles_session
#
# Description:
#    Given a session_handle it returns all the group handles created on that
#    session.
#
# Synopsis:
#    ::ixia::igmp_get_all_group_handles_session
#        session_handle
#
# Arguments:
#        session_handle
#            The session handle where to search for group handles.
# Return Values:
#        A list of all group handles on that session.
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

proc ::ixia::igmp_get_all_group_handles_session {session_handle} {
    
    variable igmp_group_handles_array
    
    set all_group_handles [list ]
    foreach group_member [array names ::ixia::igmp_group_handles_array] {
        set session_handle_reg [keylget \
                ::ixia::igmp_group_handles_array($group_member) session_handle]
        
        set group_handle_reg [keylget \
                ::ixia::igmp_group_handles_array($group_member) group_handle]
        
        if {$session_handle == $session_handle_reg} {
            lappend all_group_handles $group_handle_reg
        }
    }
    return $all_group_handles
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_all_host_handles_port
#
# Description:
#    Given a port_handle it returns all the IGMP hosts created on that
#    port.
#
# Synopsis:
#    ::ixia::igmp_get_all_host_handles_port
#        port_handle
#
# Arguments:
#        port_handle
#            The port handle where to search for host handles.
# Return Values:
#        A list of all IGMP hosts on that port.
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

proc ::ixia::igmp_get_all_host_handles_port {port_handle} {
    
    variable igmp_host_handles_array
    
    set all_host_handles [list ]
    foreach session_handle [array names ::ixia::igmp_host_handles_array] {
        set port_handle_reg [keylget \
                ::ixia::igmp_host_handles_array($session_handle) port_handle]
        
        set host_handle_reg [keylget \
                ::ixia::igmp_host_handles_array($session_handle) host_handle]
        
        if {$port_handle == $port_handle_reg } {
            lappend all_host_handles $host_handle_reg
        }
    }
    return $all_host_handles
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_port_handle_host
#
# Description:
#    Given a session_handle returns the port_handle
#
# Synopsis:
#    ::ixia::igmp_get_port_handle_host
#        session_handle
#
# Arguments:
#        session_handle
#            The IGMP session handle that you want to get the port for.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                            provided.
#    key:port_handle    value:the port_handle for that session in the
#                            form of chassis/card/port.
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
proc ::ixia::igmp_get_port_handle_host {session_handle} {
    
    variable igmp_host_handles_array
    
    if {[info exists ::ixia::igmp_host_handles_array($session_handle)]} {
        set port_handle [keylget \
                ::ixia::igmp_host_handles_array($session_handle) port_handle]
        
        keylset returnList status $::SUCCESS
        keylset returnList port_handle $port_handle
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no information\
                available for session handle $session_handle"
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_host_handle_host
#
# Description:
#    Given a session_handle returns the host_handle
#
# Synopsis:
#    ::ixia::igmp_get_host_handle_host
#        session_handle
#
# Arguments:
#        session_handle
#            The IGMP session handle that you want to get the host for.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                            provided.
#    key:host_handle    value:the host_handle for that session in the
#                            form of host$number.
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
#
proc ::ixia::igmp_get_host_handle_host {session_handle} {
    
    variable igmp_host_handles_array
    
    if {[info exists ::ixia::igmp_host_handles_array($session_handle)]} {
        set host_handle [keylget \
                ::ixia::igmp_host_handles_array($session_handle) host_handle]
        
        keylset returnList status $::SUCCESS
        keylset returnList host_handle $host_handle
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no information\
                available for session handle $session_handle"
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_filter_mode_host
#
# Description:
#    Given a session_handle returns the filter_mode needed for the groups
#    belonging to that session
#
# Synopsis:
#    ::ixia::igmp_get_filter_mode_host
#        session_handle
#
# Arguments:
#        session_handle
#            The IGMP session handle that you want to get the filter mode for.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                            provided.
#    key:filter_mode    value:the filter_mode for that session in the
#                            form of include or exclude.
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
#

proc ::ixia::igmp_get_filter_mode_host {session_handle} {
    
    variable igmp_host_handles_array
    
    if {[info exists ::ixia::igmp_host_handles_array($session_handle)]} {
        set filter_mode [keylget \
                ::ixia::igmp_host_handles_array($session_handle) filter_mode]
        
        keylset returnList status $::SUCCESS
        keylset returnList filter_mode $filter_mode
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no information\
                available for session handle $session_handle"
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_max_response_control_host
#
# Description:
#    Given a session_handle returns the filter_mode needed for the groups
#    belonging to that session
#
# Synopsis:
#    ::ixia::igmp_get_max_response_control_host
#        session_handle
#
# Arguments:
#        session_handle
#            The IGMP session handle that you want to get the
#            max_response_control for.
#
# Return Values:
#    A key list
#    key:status                  value:$::SUCCESS | $::FAILURE.
#    key:log                     value:if status is failure, detailed
#                                      information provided.
#    key:max_response_control    value:the max_response_control for that
#                                      session.
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
#

proc ::ixia::igmp_get_max_response_control_host {session_handle} {
    
    variable igmp_host_handles_array
    
    if {[info exists ::ixia::igmp_host_handles_array($session_handle)]} {
        if {[lsearch [keylkeys \
                    ::ixia::igmp_host_handles_array($session_handle)]\
                    max_response_control]!= -1 } {
            
            set max_response_control [keylget                        \
                    ::ixia::igmp_host_handles_array($session_handle) \
                    max_response_control]
        } else  {
            set max_response_control ""
        }
        
        keylset returnList status $::SUCCESS
        keylset returnList max_response_control $max_response_control
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no information\
                available for session handle $session_handle"
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_max_response_time_host
#
# Description:
#    Given a session_handle returns the max_response_time needed for the groups
#    belonging to that session
#
# Synopsis:
#    ::ixia::igmp_get_max_response_time_host
#        session_handle
#
# Arguments:
#        session_handle
#            The IGMP session handle that you want to get the
#            max_response_time for.
#
# Return Values:
#    A key list
#    key:status               value:$::SUCCESS | $::FAILURE.
#    key:log                  value:If status is failure, detailed information
#                                   provided.
#    key:max_response_time    value:the max_response_time for that session.
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
#

proc ::ixia::igmp_get_max_response_time_host {session_handle} {
    
    variable igmp_host_handles_array
    
    if {[info exists ::ixia::igmp_host_handles_array($session_handle)]} {
        if {[lsearch [keylkeys \
                    ::ixia::igmp_host_handles_array($session_handle)]\
                    max_response_time]!= -1 } {
            
            set max_response_time [keylget                           \
                    ::ixia::igmp_host_handles_array($session_handle) \
                    max_response_time]
        } else  {
            set max_response_time ""
        }
        
        
        keylset returnList status $::SUCCESS
        keylset returnList max_response_time $max_response_time
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no information\
                available for session handle $session_handle"
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_group_sessions_by_port
#
# Description:
#    Given a list of session_handles it returns a list coresponding to an array
#    were the session_handles are grouped by port
#
# Synopsis:
#    ::ixia::igmp_group_sessions_by_port
#        handle
#
# Arguments:
#        handle
#            The IGMP session handle list that you want to group by port.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                            provided.
#    key:port_group     value:list of sessions grouped by port.
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
#

proc ::ixia::igmp_group_sessions_by_port {handle} {
    
    variable igmp_host_handles_array
    
    array set temp_array [list ]
    foreach session_handle $handle {
        if {[info exists ::ixia::igmp_host_handles_array($session_handle)]} {
            set portRet [::ixia::igmp_get_port_handle_host $session_handle]
            if {[keylget portRet status] == 0} { return $portRet }
            set port [keylget portRet port_handle]
            if {[info exists temp_array($port)]} {
                if {[lsearch -exact $temp_array($port) $session_handle] == -1} {
                    lappend temp_array($port) $session_handle
                }
            } else  {
                set temp_array($port) [list ]
                lappend temp_array($port) $session_handle
            }
        } else  {
            keylset returnList status $::FAILURE
            keylset returnList log "There is no information available about\
                    the session handle $session_handle"
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    keylset returnList port_group [array get temp_array]
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_group_members_by_port_session
#
# Description:
#    Given a list of group_members it returns a list coresponding to an array
#    were the group_members are grouped by session then by port
#
# Synopsis:
#    ::ixia::igmp_group_members_by_port_session
#        handle
#
# Arguments:
#        handle
#            The IGMP group member handles list that you want to group by
#            session, then by port.
#
# Return Values:
#    A key list
#    key:status             value:$::SUCCESS | $::FAILURE.
#    key:log                value:If status is failure, detailed information
#                                provided.
#    key:port_session_group value:list of group members grouped by session,
#                                port.
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
#

proc ::ixia::igmp_group_members_by_port_session {handle} {
    
    variable igmp_group_handles_array
    
    array set temp [list ]
    foreach group $handle {
        if {[info exists ::ixia::igmp_group_handles_array($group)]} {
            
            set retCode [::ixia::igmp_get_session_handle_group $group]
            if {[keylget retCode status] == 0} { return $retCode }
            set session [keylget retCode session_handle]
            
            set retCode [::ixia::igmp_get_port_handle_host $session]
            if {[keylget retCode status] == 0} { return $retCode }
            set port [keylget retCode port_handle]
            
            if {[info exists temp($port)]} {
                if {[set found [lsearch -exact $temp($port) $session]] == -1} {
                    lappend temp($port) $session
                    set temp($port) [concat                              \
                            [lrange $temp($port) 0 end]                  \
                            [list [concat                                \
                            [lindex $temp($port) [llength $temp($port)]] \
                            $group]]                                     ]
                } else  {
                    set pos [list [mpexpr $found + 1] end]
                    set temp($port) [concat                           \
                            [lrange $temp($port) 0 $found]            \
                            [list [concat                             \
                            [lindex $temp($port) [mpexpr $found + 1]] \
                            $group ] ]                                \
                            [lrange $temp($port) [mpexpr $found + 2] end]]
                }
            } else  {
                set temp($port) [list ]
                lappend temp($port) $session
                set temp($port) [list                           \
                        [lindex $temp($port) 0]                 \
                        [concat [lindex $temp($port) 1] $group] ]
            }
        } else  {
            keylset returnList status $::FAILURE
            keylset returnList log "There is no information available about\
                    the group handle $group"
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    keylset returnList port_session_group [array get temp]
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_array_unset_values
#
# Description:
#    Given an array it modifies the array by unseting those elements who's
#    values corespond to the given pattern
#
# Synopsis:
#    ::ixia::igmp_array_unset_values
#        array_handle
#        port_handle
#        session_handle
#
# Arguments:
#        array_handle
#            The array where you want to unset values.
#        port_handle
#            The pattern that you want to be applied to the values of the array.
#        session_handle
#            The pattern that you want to be applied to the values of the array.
#
# Return Values:
#    A key list
#    key:status          value:$::SUCCESS | $::FAILURE.
#    key:log             value:tf status is failure, detailed information
#                              provided.
#    key:unsetIndices    value:s list of the unset indices of the array
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
#

proc ::ixia::igmp_array_unset_values {args} {
    
    set mandatory_args {
        -array_handle
    }
    set optional_args {
        -session_handle
        -port_handle
    }
    if {[catch [::ixia::parse_dashed_args       \
                -args $args                     \
                -optional_args $optional_args   \
                -mandatory_args $mandatory_args ] value]} {
        
        keylset returnList status $::FAILURE
        keylset returnList log $value
        return $returnList
    }
    if {(![info exists session_handle]) && (![info exists port_handle])} {
        keylset returnList status $::FAILURE
        keylset returnList log "In order to delete handles you must provide\
                a port_handle or a session_handle"
        return $returnList
    }
    upvar $array_handle array_h
    
    set l [array get array_h]
    set unsetIndices [list ]
    foreach {index value} [array get array_h]  {
        if {[info exists port_handle]} {
            set res [keylget value port_handle]
            if {$res == $port_handle} {
                unset array_h($index)
                lappend unsetIndices $index
            }
        }
        if {[info exists session_handle]} {
            set res [keylget value session_handle]
            if {$res == $session_handle} {
                unset array_h($index)
                lappend unsetIndices $index
            }
        }
    }
    keylset returnList status $::SUCCESS
    keylset returnList unsetIndices $unsetIndices
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_sort_handles
#
# Description:
#    Given a list of handles(defined by the same string followed by a counter)
#    returns the list sorted by the counters.
#
# Synopsis:
#    ::ixia::igmp_sort_handles
#        handle
#
# Arguments:
#        handle
#            The list of handles that you want to sort by the counter.
#
# Return Values:
#        A list of the handle in ascendent order.
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
#

proc ::ixia::igmp_sort_handles {handle} {
    
    regsub -all {([a-zA-Z_]+)([0-9]+)} $handle {\1} handle_names
    set handle_name [lindex [lsort -unique $handle_names] 0]
    regsub -all {([a-zA-Z_]+)([0-9]+)} $handle {\2} handle_numbers
    set handle_numbers [lsort -integer $handle_numbers]
    regsub -all {([0-9]+)} $handle_numbers "$handle_name\\1" ordered_handles
    return $ordered_handles
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_next_handle
#
# Description:
#    Given a handle_name it returns the next_handle.
#
# Synopsis:
#    ::ixia::igmp_get_next_handle
#        handle_name
#
# Arguments:
#        handle_name
#            The name of the handle(ex: session, group_member, host etc).
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                           provided.
#    key:next_handle    value:the next available handle.
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
#

proc ::ixia::igmp_get_next_handle {handle_name} {
    variable igmp_counter
    keylset returnList status $::SUCCESS
    incr ::ixia::igmp_counters($handle_name)
    keylset returnList next_handle \
        ${handle_name}$::ixia::igmp_counters($handle_name)
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_add_group_member
#
# Description:
#    Adds a group_member to the global array ::ixia::igmp_group_handles_array
#
# Synopsis:
#    ::ixia::igmp_add_group_member
#        group_member_handle
#        session_handle
#        group_handle
#        group_pool_handle
#
# Arguments:
#        group_member_handle
#            The group_member that you want to add.
#        session_handle
#            The session_handle where the group was created.
#        group_handle
#            The group_handle (the groupRange number) that was created.
#        group_pool_handle
#            The group_pool_handle used to create the group.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
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
#

proc ::ixia::igmp_add_group_member {args} {
    
    variable igmp_group_handles_array
    
    set mandatory_args {
        -group_member_handle
        -session_handle
        -group_handle
        -group_pool_handle
    }
    
    if {[catch [::ixia::parse_dashed_args       \
                -args $args                     \
                -mandatory_args $mandatory_args ] value]} {
        
        keylset returnList status $::FAILURE
        keylset returnList log $value
        return $returnList
    }
    
    keylset tempList session_handle $session_handle
    keylset tempList group_handle $group_handle
    keylset tempList group_pool_handle $group_pool_handle
    
    keylset returnList status $::SUCCESS
    set ::ixia::igmp_group_handles_array($group_member_handle) $tempList
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_modify_group_member
#
# Description:
#    Modifies a group_member in the global
#    array ::ixia::igmp_group_handles_array
#
# Synopsis:
#    ::ixia::igmp_modify_group_member
#        group_member_handle
#        session_handle
#        group_handle
#        group_pool_handle
#
# Arguments:
#        group_member_handle
#            The group_member that you want to modify.
#        session_handle
#            The session_handle where the group was created.
#        group_handle
#            The group_handle (the groupRange number) that was created.
#        group_pool_handle
#            The group_pool_handle used to create the group.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
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
#

proc ::ixia::igmp_modify_group_member {args} {
    
    variable igmp_group_handles_array
    
    set mandatory_args {
        -group_member_handle
    }
    set optional_args {
        -session_handle
        -group_handle
        -group_pool_handle
    }
    if {[catch [::ixia::parse_dashed_args       \
                -args $args                     \
                -optional_args $optional_args   \
                -mandatory_args $mandatory_args ] value]} {
        
        keylset returnList status $::FAILURE
        keylset returnList log $value
        return $returnList
    }
    set tempList $::ixia::igmp_group_handles_array($group_member_handle)
    
    if {[info exists session_handle]} {
        keylset tempList session_handle $session_handle
    }
    if {[info exists group_handle]} {
        keylset tempList group_handle $group_handle
    }
    if {[info exists group_pool_handle]} {
        keylset tempList group_pool_handle $group_pool_handle
    }
    
    keylset returnList status $::SUCCESS
    set ::ixia::igmp_group_handles_array($group_member_handle) $tempList
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_group_pool_handle_group
#
# Description:
#    Given a group_member returns the group_pool_handle used for
#    that group_member.
#
# Synopsis:
#    ::ixia::igmp_get_group_pool_handle_group
#        group_member
#
# Arguments:
#        group_member
#            The group_member that you get group_pool_handle from.
#
# Return Values:
#    A key list
#    key:status               value:$::SUCCESS | $::FAILURE.
#    key:log                  value:If status is failure, detailed information
#                                   provided.
#    key:group_pool_handle    value:the group_pool_handle in case of success.
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

proc ::ixia::igmp_get_group_pool_handle_group {group_member} {
    
    variable igmp_group_handles_array
    
    if {[info exists ::ixia::igmp_group_handles_array($group_member)]} {
        set group_pool_handle [keylget                          \
                ::ixia::igmp_group_handles_array($group_member) \
                group_pool_handle                               ]
        
        keylset returnList status $::SUCCESS
        keylset returnList group_pool_handle $group_pool_handle
        
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no information\
                available for group member $group_member"
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_group_handle_group
#
# Description:
#    Given the group_member returns the group_handle from
#    that group_member.
#
# Synopsis:
#    ::ixia::igmp_get_group_handle_group
#        group_member
#
# Arguments:
#        group_member
#            The group_member that you get group_handle from.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                           provided.
#    key:group_handle   value:the group_handle in case of success.
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

proc ::ixia::igmp_get_group_handle_group {group_member} {
    
    variable igmp_group_handles_array
    
    if {[info exists ::ixia::igmp_group_handles_array($group_member)]} {
        set group_handle [keylget \
                ::ixia::igmp_group_handles_array($group_member) group_handle]
        
        keylset returnList status $::SUCCESS
        keylset returnList group_handle $group_handle
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no information\
                available for group member $group_member"
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_session_handle_port
#
# Description:
#    Given the group_member returns the session_handle from
#    that group_member.
#
# Synopsis:
#    ::ixia::igmp_get_session_handle_port
#        chassis card port
#
# Arguments:
#        port_handle
#            The port where to look for the session_handle.
#        host_handle
#            The host_handle for that port attached to the session_handle.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                           provided.
#    key:session_handle value:the session_handle in case of success.
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
#
proc ::ixia::igmp_get_session_handle_port {port_handle host_handle} {
    
    variable igmp_host_handles_array
    
    if {[array exists ::ixia::igmp_host_handles_array]} {
        set pattern $port_handle,$host_handle,(.*)
        
        foreach {session_handle session_value} \
                [array get ::ixia::igmp_host_handles_array] {
                    
                    set port_handle_reg [keylget session_value port_handle]
                    set host_handle_reg [keylget session_value host_handle]
                    if {($port_handle == $port_handle_reg) && \
                        ($host_handle == $host_handle_reg) } {
                        keylset returnList status $::SUCCESS
                        keylset returnList session_handle $session_handle
                        return $returnList
                    }
                }
    }
    keylset returnList status $::FAILURE
    keylset returnList log "There is no session_handle\
            available for port $port_handle and host $host_handle."
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_get_session_handle_group
#
# Description:
#    Given the group_member returns the session_handle from
#    that group_member.
#
# Synopsis:
#    ::ixia::igmp_get_session_handle_group
#        group_member
#
# Arguments:
#        group_member
#            The group_member that you get group_handle from.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                           provided.
#    key:session_handle value:the session_handle in case of success.
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
#
proc ::ixia::igmp_get_session_handle_group {group_member} {
    
    variable igmp_group_handles_array
    
    if {[info exists ::ixia::igmp_group_handles_array($group_member)]} {
        set session_handle [keylget \
                ::ixia::igmp_group_handles_array($group_member) session_handle]
        
        if {[info exists session_handle]} {
            keylset returnList status $::SUCCESS
            keylset returnList session_handle $session_handle
        } else  {
            keylset returnList status $::FAILURE
            keylset returnList log "The group member\
                    $group_member was not defined properly."
        }
        
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no information\
                available for group member $group_member"
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::get_command_parameters
#
# Description:
#    Given a command and a method for that command it returns a list with the
#    parameters and the values for that command
#
# Synopsis:
#    ::ixia::get_command_parameters
#        cmd
#        method
#
# Arguments:
#        cmd
#            The command that you want to get parameters for.
#        method
#            A method for that command
#
# Return Values:
#        A list with the parameters for that command and their values.
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
#        showCmd
#

proc ::ixia::get_command_parameters {cmd {method cget}} {
    set group_conf [list ]
    catch {$cmd $method} paramList
    foreach param [lsort [join $paramList]] {
        if {$param == "-this"} {
            continue
        }
        if {[string index $param 0] == "-"} {
            regsub -all {\-(.*)} $param {\1} temp_param
            lappend group_conf $temp_param [$cmd cget $param]
        }
    }
    return $group_conf
}
##Internal Procedure Header
# Name:
#    ::ixia::igmp_clear_all_hosts
#
# Description:
#    Clears all hosts and groups from a given port from the global arrays.
#
# Synopsis:
#    ::ixia::igmp_clear_all_hosts
#        session_handle
#
# Arguments:
#        session_handle
#            A list of session_handles where the user wants to clear
#            all groups.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                             provided.
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
#

proc ::ixia::igmp_clear_all_hosts {chassis card port} {
    variable igmp_host_handles_array
    variable igmp_group_handles_array
    
    if {[array exists ::ixia::igmp_host_handles_array]} {
        set retCode [::ixia::igmp_array_unset_values          \
                -array_handle ::ixia::igmp_host_handles_array \
                -port_handle  "$chassis/$card/$port"]
        if {[keylget retCode status] == 0} { return $retCode  }
        set unsetSessionHandles [keylget retCode unsetIndices]
        if {[llength $unsetSessionHandles]} {
            set unsetGroupMembers [list ]
            foreach ses_h $unsetSessionHandles {
                set allGroupMembers [::ixia::igmp_get_all_group_members $ses_h]
                foreach g_member $allGroupMembers {
                    unset ::ixia::igmp_group_handles_array($g_member)
                    lappend unsetGroupMembers $g_member
                }
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_select_host
#
# Description:
#    Selects IGMP host when given a port and a host_handle.
#
# Synopsis:
#    ::ixia::igmp_select_host
#        chassis card port
#        host_handle
#
# Arguments:
#        chassis card port
#            The port wanted for selection.
#        host_handle
#            The host wanted for selection
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                             provided.
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
#

proc ::ixia::igmp_select_host {chassis card port host_handle} {
    variable igmp_port
    
    set igmp_port(current) $chassis/$card/$port    
    if {($igmp_port(write) == 1) || ($igmp_port(current) != $igmp_port(last))} {
        if {[igmpVxServer select $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to\
                    igmpVxServer select $chassis $card $port"
            return $returnList
        }
        set igmp_port(last) $chassis/$card/$port
        set igmp_port(write) 1 
    }
    
    if {[igmpVxServer getHost $host_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to\
                igmpVxServer getHost $host_handle"
        return $returnList
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_set_host
#
# Description:
#    Sets IGMP Host when given a host_handle.
#    The host is previously selected with igmp_select_host.
#
# Synopsis:
#    ::ixia::igmp_set_host
#        host_handle
#
# Arguments:
#        host_handle
#            The host wanted for setting on the hardware.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                             provided.
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

proc ::ixia::igmp_set_host {host_handle} {
    variable igmp_port
    
    # Set the host
    if {[igmpVxServer setHost $host_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to\
                igmpVxServer setHost $host_handle"
        return $returnList
    }
    # Set the server
    if {$igmp_port(write)} {
        if {[igmpVxServer set]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to\
                    igmpVxServer set."
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_set_server
#
# Description:
#    Sets IGMP Server configuration to hardware.
#
# Synopsis:
#    ::ixia::igmp_set_server
#
# Arguments:
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                             provided.
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

proc ::ixia::igmp_set_server {} {
    
    # Set server
    if {[igmpVxServer set]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to\
                igmpVxServer set"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_write_server
#
# Description:
#    Writes IGMP Server configuration to hardware.
#
# Synopsis:
#    ::ixia::igmp_write_server
#
# Arguments:
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                             provided.
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

proc ::ixia::igmp_write_server {} {
    
    # Set server
    if {[igmpVxServer set]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to\
                igmpVxServer set"
        return $returnList
    }
    
    # Write server
    if {[igmpVxServer write]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to\
                igmpVxServer write"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_delete_group
#
# Description:
#    Deletes IGMP groups given a list of group_member_handles.
#
# Synopsis:
#    ::ixia::igmp_delete_group
#        handle
#
# Arguments:
#        handle
#            A list of group_member_handles that the user wants to delete.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                             provided.
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
#
proc ::ixia::igmp_delete_group {handle} {
    
    variable igmp_group_handles_array
    
    # Gets the port_handle, session_handlem host_handle from the
    # group_member handle and then deletes the group_handle
    foreach handle_i $handle {
        set groupRet [::ixia::igmp_get_group_handle_group $handle_i]
        if {[keylget groupRet status] == 0} { return $groupRet }
        set group_handle [keylget groupRet group_handle]
        
        set sessionRet [::ixia::igmp_get_session_handle_group $handle_i]
        if {[keylget sessionRet status] == 0} { return $sessionRet }
        set session_handle [keylget sessionRet session_handle]
        
        set portRet [::ixia::igmp_get_port_handle_host $session_handle]
        if {[keylget portRet status] == 0} { return $portRet }
        set port_handle [keylget portRet port_handle]
        
        set hostRet [::ixia::igmp_get_host_handle_host $session_handle]
        if {[keylget hostRet status] == 0} { return $hostRet }
        set host_handle [keylget hostRet host_handle]
        
        set port_list [format_space_port_list $port_handle]
        foreach {chassis card port} [lindex $port_list 0] {}
        ::ixia::addPortToWrite $chassis/$card/$port
        
        set retSelHost [::ixia::igmp_select_host \
                $chassis $card $port $host_handle]
        if {[keylget retSelHost status] == 0} { return $retSelHost }

        # Must be after igmp_select_host !!!
        uplevel {
            if {($::ixia::igmp_port(current) != $::ixia::igmp_port(last)) || \
                    ![info exists no_write]} {
                set ::ixia::igmp_port(write) 1
            } else {
                set ::ixia::igmp_port(write) 0
            }    
        }
                
        if {[igmpHost delGroupRange $group_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to\
                    delete the IGMP Host Group Range $group_handle."
            return $returnList
        }

        set retSetHost [::ixia::igmp_set_host $host_handle]
        if {[keylget retSetHost status] == 0} { return $retSetHost }
        
        unset ::ixia::igmp_group_handles_array($handle_i)
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_clear_all_groups
#
# Description:
#    Clears all groups on a given session.
#
# Synopsis:
#    ::ixia::igmp_clear_all_groups
#        session_handle
#
# Arguments:
#        session_handle
#            A list of session_handles where the user wants to clear
#            all groups.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                             provided.
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
#

proc ::ixia::igmp_clear_all_groups {session_handle} {
    
    variable igmp_group_handles_array
    
    foreach session_handle_i $session_handle {
        set portRet [::ixia::igmp_get_port_handle_host $session_handle_i]
        if {[keylget portRet status] == 0} { return $portRet }
        set port_handle [keylget portRet port_handle]
        
        set hostRet [::ixia::igmp_get_host_handle_host $session_handle_i]
        if {[keylget hostRet status] == 0} { return $hostRet }
        set host_handle [keylget hostRet host_handle]
        
        set port_list [format_space_port_list $port_handle]
        foreach {chassis card port} [lindex $port_list 0] {}
        ::ixia::addPortToWrite $chassis/$card/$port
        
        set retSelHost [::ixia::igmp_select_host \
                $chassis $card $port $host_handle]
        if {[keylget retSelHost status] == 0} { return $retSelHost }
        if {[igmpHost clearAllGroupRanges]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to\
                    delete the IGMP Host Group Range $group_handle."
            return $returnList
        }
        set retSetHost [::ixia::igmp_set_host $host_handle]
        if {[keylget retSetHost status] == 0} { return $retSetHost }
        
        set retUnset [::ixia::igmp_array_unset_values             \
                -array_handle    ::ixia::igmp_group_handles_array \
                -session_handle  $session_handle_i]
        if {[keylget retUnset status] == 0} { return $retUnset  }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_create_group
#
# Description:
#    Creates an IGMP group.
#
# Synopsis:
#    ::ixia::igmp_create_group
#         - session_handle
#         - group_pool_handle
#        [- source_pool_handle ]
#        [- reset ]
#
# Arguments:
#        session_handle
#            A session_handle where the user wants to create a group.
#        group_pool_handle
#            The group_pool_handle used to create the group.
#        source_pool_handle
#            A list of source_pool_handles used to add to the group.
#
# Return Values:
#    A key list
#    key:status              value:$::SUCCESS | $::FAILURE.
#    key:log                 value:If status is failure, detailed information
#                               provided.
#    key:handle              value:the group_member_handle.
#    key:group_pool_handle   value:the group_pool_handle used to create the
#                               group member.
#    key:source_pool_handles value:the source_pool_handles used to create the
#                               group member.
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
#

proc ::ixia::igmp_create_group  {args} {
    
    variable igmp_group_handles_array
    variable igmp_port
    variable ::ixia::igmp_attributes_array
    
    set mandatory_args {
        -session_handle
        -group_pool_handle
    }
    set optional_args {
        -source_pool_handle
        -reset
    }
    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args
    
    upvar #0 ::ixia::multicast_source_array msa
    upvar #0 ::ixia::multicast_group_array  mga
    
    array set enumList [list ]
    set igmp_group_pool_handle_list [list]
    set source_pool_handles_list [list ]
    
    # Get port_handle
    set portRet [::ixia::igmp_get_port_handle_host $session_handle]
    if {[keylget portRet status] == 0} { return $portRet }
    set port_handle [keylget portRet port_handle]
    
    # Get Host handle
    set hostRet [::ixia::igmp_get_host_handle_host $session_handle]
    if {[keylget hostRet status] == 0} { return $hostRet }
    set host_handle [keylget hostRet host_handle]
    
    set port_list [format_space_port_list $port_handle]
    foreach {chassis card port} [lindex $port_list 0] {}
    ::ixia::addPortToWrite $chassis/$card/$port
    
    # Select host
    set retSelHost [::ixia::igmp_select_host $chassis $card $port $host_handle]    
    if {[keylget retSelHost status] == 0} { return $retSelHost  }
    # Must be after igmp_select_host !!!
    uplevel {
        if {($::ixia::igmp_port(current) != $::ixia::igmp_port(last)) || \
                ![info exists no_write]} {
            set ::ixia::igmp_port(write) 1
        } else {
            set ::ixia::igmp_port(write) 0
        }    
    }
    if {[info exists reset]} {
        # If -reset is given then clear all group on a given session
        igmpHost clearAllGroupRanges
        set group_to_add 1
        if {[array exists ::ixia::igmp_group_handles_array]} {
            set retUnset [::ixia::igmp_array_unset_values             \
                    -array_handle    ::ixia::igmp_group_handles_array \
                    -session_handle  $session_handle]
            if {[keylget retUnset status] == 0} { return $retUnset  }
        }
    } else {
        # Find out the next group number
        set retGroup [::ixia::igmp_get_next_handle groupRange]
        if {[keylget retGroup status] == 0} { return $returnGroup  }
        set group_to_add [keylget retGroup next_handle]
    }
    # On modify or create you always add from sourceRange1
    set source_to_add 1
    igmpGroupRange clearAllSourceRanges
    if {[info exists source_pool_handle] } {
        # If given a source pool handle then add the sources
        foreach source_pool_handle_i $source_pool_handle {
            if {[info exists msa($source_pool_handle_i,ip_addr_start)]} {
                igmpSourceRange setDefault
                array set igmpSourceRange [list \
                        sourceIpFrom $msa($source_pool_handle_i,ip_addr_start) \
                        count        $msa($source_pool_handle_i,num_sources)   ]
                
                foreach item [array names igmpSourceRange] {
                    if {![catch {set igmpSourceRange($item)} value] } {
                        if {[lsearch [array names enumList] $value] != -1} {
                            set value $enumList($value)
                        }
                        catch {igmpSourceRange config -$item $value}
                    }
                }
                if {[igmpGroupRange addSourceRange sourceRange$source_to_add]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to\
                            add the Source Range sourceRange$source_to_add."
                    return $returnList
                }
                incr source_to_add
                lappend source_pool_handles_list $source_pool_handle_i
            } else  {
                keylset returnList status $::FAILURE
                keylset returnList log "Source pool handle\
                        $source_pool_handle_i was not valid."
                return $returnList
            }
        }
    }
    # Set group to default
    igmpGroupRange setDefault
    # Enable group
    igmpGroupRange config -enable true
    # setting packing/groupping parameters from emulation_igmp_config
    if {[info exists ::ixia::igmp_attributes_array($session_handle,attr)]} {
        foreach {name value} $::ixia::igmp_attributes_array($session_handle,attr) {
            set $name $value
        }
    }
    if {[info exists enable_packing] && $enable_packing == 1} {
        igmpGroupRange config -enablePacking true
        set packing_list {
            max_groups_per_pkts     recordsPerFrame  \
            max_sources_per_group   sourcesPerRecord \
        }
        foreach {pack_item ixos_param} $packing_list {
            if {[info exists $pack_item]} {
                igmpGroupRange config -$ixos_param [set $pack_item]
            }
        }
        lappend ::ixia::igmp_attributes_array($session_handle,group) $group_to_add
    }
    # Get group configuration
    if {[info exists mga($group_pool_handle,ip_addr_start)]} {
        set filterRet [::ixia::igmp_get_filter_mode_host $session_handle]
        if {[keylget filterRet status] == 0} { return $filterRet }
        array set igmpGroupRange [list             \
                groupIpFrom                            \
                $mga($group_pool_handle,ip_addr_start) \
                groupCount                             \
                $mga($group_pool_handle,num_groups)    \
                incrementStep                          \
                [::ixia::ip_addr_to_num $mga($group_pool_handle,ip_addr_step)] \
                sourceMode                             \
                [keylget filterRet filter_mode]        ]
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "Group pool handle\
                $group_pool_handle is not valid."
        return $returnList
    }
    # Set group configuration
    foreach item [array names igmpGroupRange] {
        if {![catch {set igmpGroupRange($item)} value] } {
            if {[lsearch [array names enumList] $value] != -1} {
                set value $enumList($value)
            }
            catch {igmpGroupRange config -$item $value}
        }
    }
    # Add group
    if {[igmpHost addGroupRange $group_to_add]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to\
                add the IGMP Host Group Range $group_to_add."
        return $returnList
    }
    # Set the host    
    set retSetHost [::ixia::igmp_set_host $host_handle]
    if {[keylget retSetHost status] == 0} { return $retSetHost  }
    set retGM [::ixia::igmp_get_next_handle group_member]
    set group_member [keylget retGM next_handle]
    # Add group member
    set retCode [::ixia::igmp_add_group_member      \
            -group_member_handle $group_member      \
            -session_handle      $session_handle    \
            -group_handle        $group_to_add      \
            -group_pool_handle   $group_pool_handle ]
    
    if {[keylget retCode status] == 0} { return $retCode }
    
    keylset returnList status $::SUCCESS
    keylset returnList handle $group_member
    keylset returnList group_pool_handle $group_pool_handle
    keylset returnList source_pool_handles $source_pool_handles_list
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::igmp_modify_group
#
# Description:
#    Modifies a group_member given by -handle.
#
# Synopsis:
#    ::ixia::igmp_modify_group
#         - handle
#        [- group_pool_handle  ]
#        [- source_pool_handle ]
#        [- reset ]
#
# Arguments:
#        handle
#            A group_member_handle the user wants to modify.
#        group_pool_handle
#            The group_pool_handle used to modify the group.
#        source_pool_handle
#            A list of source_pool_handles used for the group.
#
# Return Values:
#    A key list
#    key:status              value:$::SUCCESS | $::FAILURE.
#    key:log                 value:If status is failure, detailed information
#                               provided.
#    key:handle              value:the group_member_handle.
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
#

proc ::ixia::igmp_modify_group {args} {
    variable igmp_group_handles_array
    
    set mandatory_args {
        -handle
    }
    set optional_args {
        -group_pool_handle
        -source_pool_handle
    }
    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args
    
    upvar #0 ::ixia::multicast_source_array msa
    upvar #0 ::ixia::multicast_group_array  mga
    
    # Get old group_pool_handle
    set groupPoolRet [::ixia::igmp_get_group_pool_handle_group $handle]
    if {[keylget groupPoolRet status] == 0} { return $groupPoolRet }
    set group_pool_handle_old [keylget groupPoolRet group_pool_handle]
    
    # Get group_handle
    set groupRet [::ixia::igmp_get_group_handle_group $handle]
    if {[keylget groupRet status] == 0} { return $groupRet }
    set group_handle [keylget groupRet group_handle]
    
    # Get session_handle
    set sessionRet [::ixia::igmp_get_session_handle_group $handle]
    if {[keylget sessionRet status] == 0} { return $sessionRet }
    set session_handle [keylget sessionRet session_handle]
    
    # Get port_handle
    set portRet [::ixia::igmp_get_port_handle_host $session_handle]
    if {[keylget portRet status] == 0} { return $portRet }
    set port_handle [keylget portRet port_handle]
    
    # Get host_handle
    set hostRet [::ixia::igmp_get_host_handle_host $session_handle]
    if {[keylget hostRet status] == 0} { return $hostRet }
    set host_handle [keylget hostRet host_handle]
    
    set port_list [format_space_port_list $port_handle]
    foreach {chassis card port} [lindex $port_list 0] {}
    ::ixia::addPortToWrite $chassis/$card/$port
    
    array set enumList [list ]
    set igmp_group_pool_handle_list [list]
    set source_pool_handles_list [list ]
    
    # Select host
    set retSelHost [::ixia::igmp_select_host \
            $chassis $card $port $host_handle]
    if {[keylget retSelHost status] == 0} { return $retSelHost }

    uplevel {
        if {($::ixia::igmp_port(current) != $::ixia::igmp_port(last)) || \
                ![info exists no_write]} {
            set ::ixia::igmp_port(write) 1
        } else {
            set ::ixia::igmp_port(write) 0
        }    
    }
    
    if {[igmpHost getGroupRange $group_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to\
                igmpHost getGroupRange $group_handle."
        return $returnList
    }
    # On modify or create you always add from sourceRange1
    set source_to_add 1
    
    # Set and add the sourceRanges
    if {[info exists source_pool_handle] } {
        # If source_pool_handle given then add the sources
        igmpGroupRange clearAllSourceRanges
        foreach source_pool_handle_i $source_pool_handle {
            if {[info exists msa($source_pool_handle_i,ip_addr_start)]} {
                igmpSourceRange setDefault
                array set igmpSourceRange [list \
                        sourceIpFrom $msa($source_pool_handle_i,ip_addr_start) \
                        count        $msa($source_pool_handle_i,num_sources)   ]
                
                foreach item [array names igmpSourceRange] {
                    if {![catch {set igmpSourceRange($item)} value] } {
                        if {[lsearch [array names enumList] $value] != -1} {
                            set value $enumList($value)
                        }
                        catch {igmpSourceRange config -$item $value}
                    }
                }
                if {[igmpGroupRange addSourceRange sourceRange$source_to_add]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to\
                            add the Source Range sourceRange$source_to_add."
                    return $returnList
                }
                incr source_to_add
            } else  {
                keylset returnList status $::FAILURE
                keylset returnList log "Source pool handle\
                        $source_pool_handle_i was not valid."
                return $returnList
            }
        }
    }
    
    if {[info exists group_pool_handle]} {
        # If group_pool_handle was given then set the configuration from the
        # given group_pool
        if {[info exists mga($group_pool_handle,ip_addr_start)]} {
            set filterRet [::ixia::igmp_get_filter_mode_host $session_handle]
            if {[keylget filterRet status] == 0} { return $filterRet }
            array set igmpGroupRange [list             \
                    groupIpFrom                            \
                    $mga($group_pool_handle,ip_addr_start) \
                    groupCount                             \
                    $mga($group_pool_handle,num_groups)    \
                    incrementStep                          \
                    [::ixia::ip_addr_to_num $mga($group_pool_handle,ip_addr_step)]\
                    sourceMode                             \
                    [keylget filterRet filter_mode]        ]
            
        } else  {
            keylset returnList status $::FAILURE
            keylset returnList log "Group pool handle\
                    $group_pool_handle is not valid."
            return $returnList
        }
        # Set group to default
        igmpGroupRange setDefault
        # Enable group
        igmpGroupRange config -enable true
        # Set group configuration
        foreach item [array names igmpGroupRange] {
            if {![catch {set igmpGroupRange($item)} value] } {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                catch {igmpGroupRange config -$item $value}
            }
        }
    }
    # Set group
    if {[igmpHost setGroupRange $group_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to\
                igmpHost setGroupRange $group_handle."
        return $returnList
    }
    # Set the IGMP Server
    set retSetServer [::ixia::igmp_set_server]
    if {[keylget retSetServer status] == 0} { return $retSetServer }
    
    # Set the group_member
    if {[info exists group_pool_handle]} {
        ::ixia::igmp_modify_group_member             \
                -group_member_handle $handle         \
                -session_handle      $session_handle \
                -group_handle        $group_handle   \
                -group_pool_handle   $group_pool_handle
    } else  {
        ::ixia::igmp_modify_group_member             \
                -group_member_handle $handle         \
                -session_handle      $session_handle \
                -group_handle        $group_handle   \
                -group_pool_handle   $group_pool_handle_old
    }
    keylset returnList status $::SUCCESS
    keylset returnList handle $handle
    return $returnList
}
