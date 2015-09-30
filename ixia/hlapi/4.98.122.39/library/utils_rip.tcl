##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_rip.tcl
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
#    - ::ixia::ripAddRouteRange
#    - ::ixia::ripAddSessionHandle
#    - ::ixia::ripArrayUnsetValues
#    - ::ixia::ripCalculatePrefixStep
#    - ::ixia::ripCheckParametersValidity
#    - ::ixia::ripCheckRouterExistence
#    - ::ixia::ripCheckRouterIdExistence
#    - ::ixia::ripClearAllRouteRanges
#    - ::ixia::ripClearAllRouters
#    - ::ixia::ripConfigureRouteRange
#    - ::ixia::ripDeleteSessionHandle
#    - ::ixia::ripEnableSessionHandle
#    - ::ixia::ripGetAllRoutesFromSession
#    - ::ixia::ripGetAllRouterIdsFromPort
#    - ::ixia::ripGetAllSessionHandlesFromPort
#    - ::ixia::ripGetNextHandle
#    - ::ixia::ripGetParamValueFromRoute
#    - ::ixia::ripGetParamvalueFromSession
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
#    ::ixia::ripAddSessionHandle
#
# Description:
#    Adds a session_handle to the global array
#        ::ixia::rip_router_handles_array.
#
# Synopsis:
#    ::ixia::ripAddSessionHandle
#        session_handle
#        port_handle
#        intf_description
#        rip_version
#        router_id
#
# Arguments:
#        session_handle
#            The session_handle for the session that must be added.
#        port_handle
#            The port where the session(RIP router) is located.
#        intf_description
#            The protocol interface description associated with the router.
#        rip_version
#            The rip version for the session. Values: ripv1, ripv2, ripng.
#        router_id
#            The router_id for a RIPng router.
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

proc ::ixia::ripAddSessionHandle {args} {
    
    variable rip_router_handles_array
    
    set mandatory_args {
        -session_handle
        -port_handle
        -intf_description
        -rip_version        CHOICES ripv1 ripv2 ripng
    }
    set optional_args {
        -router_id
    }
    if {[catch [::ixia::parse_dashed_args       \
                -args $args                     \
                -mandatory_args $mandatory_args \
                -optional_args  $optional_args  ] value]} {
        
        keylset returnList status $::FAILURE
        keylset returnList log "Failed parsing on adding \
                $session_handle.  $value"
        return $returnList
    }
    
    keylset tempList port_handle $port_handle
    keylset tempList intf_description $intf_description
    keylset tempList rip_version $rip_version
    
    if {[info exists router_id]} {
        keylset tempList router_id $router_id
    }
    set ::ixia::rip_router_handles_array($session_handle) $tempList
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripAddRouteRange
#
# Description:
#    Adds a route range to the global array
#        ::ixia::rip_route_handles_array.
#
# Synopsis:
#    ::ixia::ripAddRouteRange
#        session_handle
#        route_handle
#
# Arguments:
#        session_handle
#            The session_handle where the route_handle belongs.
#        route_handle
#            The route that needs to be added.
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

proc ::ixia::ripAddRouteRange {args} {
    
    variable rip_route_handles_array
    
    set mandatory_args {
        -session_handle
        -route_handle
    }
    set optional_args {
        -prefix_length
        -prefix_step
    }
    if {[catch [::ixia::parse_dashed_args       \
                -args $args                     \
                -mandatory_args $mandatory_args \
                -optional_args  $optional_args  ] value]} {
        
        keylset returnList status $::FAILURE
        keylset returnList log "Failed parsing on adding \
                $route_handle.  $value"
        return $returnList
    }
    
    keylset tempList session_handle $session_handle
    
    if {[info exists prefix_length]} {
        keylset tempList prefix_length $prefix_length
    }
    if {[info exists prefix_step]} {
        keylset tempList prefix_step $prefix_step
    }
    set ::ixia::rip_route_handles_array($route_handle) $tempList
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripCalculatePrefixStep
#
# Description:
#    Given a prefix length as a number and a prefix step as an IPv6 address
#    it transforms the prefix step into a number relative to the prefix length
#    so only the network part of a prefix address will be incremented when the
#    prefix_step is applied.
#
# Synopsis:
#    ::ixia::ripCalculatePrefixStep
#        prefix_length
#        prefix_step
#
# Arguments:
#        prefix_length
#            Number indicating the mask width for an IP address.
#        prefix_step
#            An IPv6 address indicating the step to increment a prefix address
#            with.
# Return Values:
#    A key list
#    key:status       value:$::SUCCESS | $::FAILURE
#    key:prefix_step  value:The prefix step transformed into a number.
#    key:log          value:If status is failure, detailed information provided.
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

proc ::ixia::ripCalculatePrefixStep {prefix_length prefix_step} {
    set prefix_step [::ipv6::expandAddress $prefix_step]
    set prefix_step	[hexlist2Value \
            [::ipv6::convertIpv6AddrToBytes $prefix_step]]
    
    set prefix_step [mpexpr \
            ($prefix_step >> (128 - $prefix_length)) & \
            0xFFFFFFFF]

    keylset returnList status $::SUCCESS
    keylset returnList prefix_step $prefix_step
    return $returnList
}



##Internal Procedure Header
# Name:
#    ::ixia::ripConfigureRouteRange
#
# Description:
#    Configures a route range.
#
# Synopsis:
#    ::ixia::ripConfigureRouteRange
#
# Arguments:
# 
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

proc ::ixia::ripConfigureRouteRange {} {
    uplevel 1 {
        set retCode [::ixia::ripGetParamValueFromSession $handle rip_version]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Configuring route range. \
                    [keylget retCode log]"
            return $returnList
        }
        set session_type [keylget retCode rip_version]
        
        set retCode [::ixia::ripGetParamValueFromSession $handle port_handle]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Configuring route range. \
                    [keylget retCode log]"
            return $returnList
        }
        set port_handle [keylget retCode port_handle]
        set port_list [format_space_port_list $port_handle]
        foreach {chassis card port} [lindex $port_list 0] {}
        ::ixia::addPortToWrite $chassis/$card/$port
        
        array set enumList [list ]
        
        switch $session_type {
            ripv1 {
                # Setup the corresponding parameters array
                array set ripRouteParams [list \
                        metric                         metric             \
                        networkIpAddress               prefix_start       \
                        networkMaskWidth               prefix_length      \
                        numberOfNetworks               num_prefixes       \
                        ]
                
                # Set the list of parameters with default values
                set param_value_list [list \
                        metric          1  \
                        route_tag       0  \
                        prefix_length   24 \
                        num_prefixes    1  \
                        ]
            }
            ripv2 {
                # Setup the corresponding parameters array
                array set ripRouteParams [list \
                        metric                         metric             \
                        networkIpAddress               prefix_start       \
                        networkMaskWidth               prefix_length      \
                        nextHop                        next_hop           \
                        numberOfNetworks               num_prefixes       \
                        routeTag                       route_tag          \
                        ]
                
                # Set the list of parameters with default values
                set param_value_list [list      \
                        metric          1       \
                        route_tag       0       \
                        prefix_length   24      \
                        next_hop        0.0.0.0 \
                        num_prefixes    1       \
                        ]
            }
            ripng {
                # Setup the corresponding parameters array
                array set ripRouteParams [list \
                        metric                         metric             \
                        networkIpAddress               prefix_start       \
                        maskWidth                      prefix_length_temp \
                        nextHop                        next_hop           \
                        numRoutes                      num_prefixes       \
                        routeTag                       route_tag          \
                        step                           prefix_step_number \
                        ]
                
                # Set the list of parameters with default values
                set param_value_list [list                 \
                        metric             1               \
                        route_tag          0               \
                        next_hop           0:0:0:0:0:0:0:0 \
                        num_prefixes       1               \
                        ]
                # Set prefix_length and prefix_step for create mode
                if {$mode == "create"} {
                    if {![info exists prefix_length]} {
                        set prefix_length_temp 64
                    } else  {
                        set prefix_length_temp $prefix_length
                    }
                    if {![info exists prefix_step]} {
                        set prefix_step_temp [::ixia::ipv6_net_incr  \
                                0:0:0:0:0:0:0:0 $prefix_length_temp]
                    } else  {
                        set prefix_step_temp $prefix_step
                    }
                }
                # Set prefix_length and prefix_step for modify mode
                if {$mode == "modify"} {
                    if {[info exists prefix_length] &&  \
                                [info exists prefix_step]} {
                    
                        set prefix_length_temp $prefix_length
                        set prefix_step_temp $prefix_step
                    } elseif {[info exists prefix_length]}  {
                        set prefix_length_temp $prefix_length
                        set prefix_step_temp [::ixia::ipv6_net_incr  \
                                0:0:0:0:0:0:0:0 $prefix_length_temp]
                    } elseif {[info exists prefix_step]} {
                        set prefix_length_temp 64
                        set prefix_step_temp $prefix_step
                    }
                }
                # Transform the prefix_step from IP into number relative to
                # the prefix_length
                if {[info exists prefix_length_temp] && \
                        [info exists prefix_step_temp]} {
                
                    set retCode [::ixia::ripCalculatePrefixStep  \
                            $prefix_length_temp $prefix_step_temp]
                    set prefix_step_number [keylget retCode prefix_step]
                }
            }
        }
        # Set the command names for the rip versions
        if {($session_type == "ripv1") || ($session_type == "ripv2")} {
            set ripCmdServer ripServer
            set ripCmdRouter ripInterfaceRouter
            set ripCmdRouteRange ripRouteRange
            set ripCmdEnableRouteRange enableRouteRange
            set ripCmdClearAllRouteRanges clearAllRouteRange
            set ripCmdGet 0
            set ripCmdSet 0
        } elseif {$session_type == "ripng"} {
            set ripCmdServer ripngServer
            set ripCmdRouter ripngRouter
            set ripCmdRouteRange ripngRouteRange
            set ripCmdEnableRouteRange enable
            set ripCmdClearAllRouteRanges clearAllRouteRanges
            set ripCmdGet 1
            set ripCmdSet 1
        }
        if {$mode == "create"} {
            set ripCmdRouteOperation addRouteRange
        } elseif {$mode == "modify"} {
            set ripCmdRouteOperation setRouteRange
        }
        if {$mode == "create"} {
            # Initialize non-existing parameters with default values
            foreach {param value} $param_value_list {
                if {![info exists $param]} {
                    set $param $value
                }
            }
        }
        # Select rip server 
        if {[$ripCmdServer select $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "On configuring route range failed\
                    to select $ripCmdServer select $chassis $card $port."
            return $returnList
        }
        if {$ripCmdGet} {
            # Get rip server
            if {[$ripCmdServer get]} {
                keylset returnList status $::FAILURE
                keylset returnList log "On configuring route range failed\
                        to $ripCmdServer get."
                return $returnList
            }
        }
        # Get router
        if {[$ripCmdServer getRouter $handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "On configuring route range failed\
                    to $ripCmdServer getRouter $handle."
            return $returnList
        }
        
        if {$mode == "create"} {
            # Clear all route ranges if -reset
            if {[info exists reset]} {
                $ripCmdRouter $ripCmdClearAllRouteRanges
                ::ixia::ripClearAllRouteRanges $handle
            }
            $ripCmdRouteRange setDefault
            catch {$ripCmdRouteRange configure -$ripCmdEnableRouteRange true}
            
            # Get next handle for route range
            set allRoutes [array names ::ixia::rip_route_handles_array]
            set retCode [::ixia::ripGetNextHandle $allRoutes route]
            if {[keylget retCode status] == 0} {
                keylset retCode log "Configuring route range. \
                        [keylget retCode log]"
                return retCode
            }
            set routeItem [keylget retCode next_handle]
        } elseif {$mode == "modify"}  {
            if {[$ripCmdRouter getRouteRange $routeItem]} {
                keylset returnList status $::FAILURE
                keylset returnList log "On configuring route range failed\
                        to $ripCmdRouter getRouteRange $routeItem."
                return $returnList
            }
        }
        
        # Configure route range
        foreach item [array names ripRouteParams] {
            if {![catch {set $ripRouteParams($item)} value] } {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                catch {$ripCmdRouteRange configure -$item $value}
            }
        }
        
        # Add or Set route range
        if {[$ripCmdRouter $ripCmdRouteOperation $routeItem] != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "On configuring route range failed to\
                    $ripCmdRouter $ripCmdRouteOperation $routeItem."
            return $returnList
        }
        
        # Set the router in create mode
        if {$mode == "create"} {
            if {[$ripCmdServer setRouter $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "On configuring route range failed\
                        to $ripCmdServer setRouter $handle."
                return $returnList
            }
        }
        
        if {$ripCmdSet} {
            # Set configuration on port
            if {[$ripCmdServer set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "On configuring route range\
                        $ripCmdServer set failed."
                return $returnList
            }
        }
        
        if {$mode == "create"} {
            ::ixia::ripAddRouteRange              \
                    -route_handle     $routeItem  \
                    -session_handle   $handle
        }
        if {[info exists prefix_length_temp]} {
            unset prefix_length_temp
        }
        if {[info exists prefix_step_temp]} {
            unset prefix_step_temp
        }
        if {[info exists prefix_step_number]} {
            unset prefix_step_number
        }
        
        keylset returnList status $::SUCCESS
        keylset returnList route_handle $routeItem
        return $returnList
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::ripDeleteSessionHandle
#
# Description:
#    Deletes a session_handle from the global array
#        ::ixia::rip_router_handles_array and from hardware.
#
# Synopsis:
#    ::ixia::ripDeleteSessionHandle
#        session_handle
#
# Arguments:
#        session_handle
#            The session_handle that must be deleted.
# 
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

proc ::ixia::ripDeleteSessionHandle {session_handle} {
    
    variable rip_router_handles_array
    
    set retCode [::ixia::ripGetParamValueFromSession \
            $session_handle rip_version]
    if {[keylget retCode status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on deleting $session_handle. \
                [keylget retCode log]"
        return $returnList
    }
    set rip_version [keylget retCode rip_version]
    if {($rip_version == "ripv1") || ($rip_version == "ripv2") } {
        set ripCmdServer ripServer
        set ripCmdGet 0
        set ripCmdSet 0
    } elseif {$rip_version == "ripng"} {
        set ripCmdServer ripngServer
        set ripCmdGet 1
        set ripCmdSet 1
    }
    set retCode [::ixia::ripGetParamValueFromSession \
            $session_handle port_handle]
    if {[keylget retCode status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on deleting $session_handle. \
                [keylget retCode log]"
        return $returnList
    }
    set port_handle [keylget retCode port_handle]
    
    set port_list [format_space_port_list $port_handle]
    foreach {chassis card port} [lindex $port_list 0] {}
    ::ixia::addPortToWrite $chassis/$card/$port
    
    # Select RIP server on the port
    if {[$ripCmdServer select $chassis $card $port]} {
        keylset returnList status $::FAILURE
        keylset returnList log "On deleting failed\
                to $ripCmdServer select $chassis $card $port."
        return $returnList
    }
    if {$ripCmdGet} {
        # Get RIP server configuration
        if {[$ripCmdServer get]} {
            keylset returnList status $::FAILURE
            keylset returnList log "On deleting failed\
                    to $ripCmdServer get."
            return $returnList
        }
    }
    # Delete router
    if {[$ripCmdServer delRouter $session_handle] != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "On deleting failed\
                to $ripCmdServer delRouter $session_handle."
        return $returnList
    }
    
    # Unset the global array values
    set allRoutes [::ixia::ripGetAllRoutesFromSession \
            $session_handle]
    unset ::ixia::rip_router_handles_array($session_handle)
    set retUnset [::ixia::ripArrayUnsetValues                 \
            -array_handle    ::ixia::rip_route_handles_array  \
            -session_handle  $session_handle]
    if {[keylget retUnset status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "On deleting failed. \
                [keylget retUnset log]."
        return $returnList
    }
    
    if {$ripCmdSet} {
        # Set configuration on port
        if {[$ripCmdServer set]} {
            keylset returnList status $::FAILURE
            keylset returnList log "On deleting failed\
                    to $ripCmdServer set."
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripEnableSessionHandle
#
# Description:
#    Enables or disables a session_handle on hardware.
#
# Synopsis:
#    ::ixia::ripEnableSessionHandle
#        session_handle
#        enable_value
#
# Arguments:
#        session_handle
#            The session_handle that must be enabled/disabled.
#        enable_value
#            Can be true or false, coresponding to the enabling or disabling
#            the session.
#
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

proc ::ixia::ripEnableSessionHandle {session_handle enable_value} {
    
    # Get the RIP version
    set retCode [::ixia::ripGetParamValueFromSession \
            $session_handle rip_version]
    if {[keylget retCode status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on enabling/disabling\
               $session_handle.  [keylget retCode log]"
        return $returnList
    }
    set rip_version [keylget retCode rip_version]
    
    # Set the server and router commands to be used
    if {($rip_version == "ripv1") || ($rip_version == "ripv2") } {
        set ripCmdServer ripServer
        set ripCmdRouter ripInterfaceRouter
        set ripParamEnable enableRouter
        set ripCmdGet 0
        set ripCmdSet 0
    } elseif {$rip_version == "ripng"} {
        set ripCmdServer ripngServer
        set ripCmdRouter ripngRouter
        set ripParamEnable enable
        set ripCmdGet 1
        set ripCmdSet 1
    }
    
    # Get the port_handle
    set retCode [::ixia::ripGetParamValueFromSession \
            $session_handle port_handle]
    if {[keylget retCode status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on enabling/disabling\
                $session_handle.  [keylget retCode log]"
        return $returnList
    }
    set port_handle [keylget retCode port_handle]
    set port_list [format_space_port_list $port_handle]
    foreach {chassis card port} [lindex $port_list 0] {}
    ::ixia::addPortToWrite $chassis/$card/$port
    
    # Select the RIP server on port
    if {[$ripCmdServer select $chassis $card $port]} {
        keylset returnList status $::FAILURE
        keylset returnList log "On enable/disable failed\
                to $ripCmdServer select $chassis $card $port."
        return $returnList
    }
    if {$ripCmdGet} {
        # Get the RIP server configuration
        if {[$ripCmdServer get]} {
            keylset returnList status $::FAILURE
            keylset returnList log "On enable/disable failed\
                    to $ripCmdServer get."
            return $returnList
        }
    }
    # Get router
    if {[$ripCmdServer getRouter $session_handle] != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "On enable/disable failed\
                to $ripCmdServer getRouter $session_handle."
        return $returnList
    }
    
    # Configure router
    catch {$ripCmdRouter config -$ripParamEnable $enable_value}
    
    # Set router
    if {[$ripCmdServer setRouter $session_handle] != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "On enable/disable failed\
                to $ripCmdServer setRouter $session_handle."
        return $returnList
    }
    
    if {$ripCmdSet} {
        # Set configuration on port
        if {[$ripCmdServer set]} {
            keylset returnList status $::FAILURE
            keylset returnList log "On enable/disable failed\
                    to $ripCmdServer set."
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripEnableRouteRange
#
# Description:
#    Enables or disables a route_handle on hardware.
#
# Synopsis:
#    ::ixia::ripEnableRouteRange
#        session_handle
#        enable_value
#
# Arguments:
#        route_handle
#            The session_handle that must be enabled/disabled.
#        enable_value
#            Can be true or false, coresponding to the enabling or disabling
#            the route.
#
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

proc ::ixia::ripEnableRouteRange {route_handle enable_value \
            {write_flag no_write}} {
    
    # Get the RIP session handle
    set retCode [::ixia::ripGetParamValueFromRoute\
            $route_handle session_handle]
    if {[keylget retCode status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on enabling/disabling\
                $route_handle.  [keylget retCode log]"
        return $returnList
    }
    set session_handle [keylget retCode session_handle]
    
    # Get the RIP version
    set retCode [::ixia::ripGetParamValueFromSession \
            $session_handle rip_version]
    if {[keylget retCode status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on enabling/disabling\
                $session_handle.  [keylget retCode log]"
        return $returnList
    }
    set rip_version [keylget retCode rip_version]
    
    # Set the server and router commands to be used
    if {($rip_version == "ripv1") || ($rip_version == "ripv2") } {
        set ripCmdServer ripServer
        set ripCmdRouter ripInterfaceRouter
        set ripCmdRouteRange ripRouteRange
        set ripParamEnable enableRouteRange
        set ripCmdGet 0
        set ripCmdSet 0
    } elseif {$rip_version == "ripng"} {
        set ripCmdServer ripngServer
        set ripCmdRouter ripngRouter
        set ripCmdRouteRange ripngRouteRange
        set ripParamEnable enable
        set ripCmdGet 1
        set ripCmdSet 1
    }
    
    # Get the port_handle
    set retCode [::ixia::ripGetParamValueFromSession \
            $session_handle port_handle]
    if {[keylget retCode status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on enabling/disabling\
                $session_handle.  [keylget retCode log]"
        return $returnList
    }
    set port_handle [keylget retCode port_handle]
    set port_list [format_space_port_list $port_handle]
    foreach {chassis card port} [lindex $port_list 0] {}
    if {$write_flag != "write"} {
        ::ixia::addPortToWrite $chassis/$card/$port
    }
    
    # Select the RIP server on port
    if {[$ripCmdServer select $chassis $card $port]} {
        keylset returnList status $::FAILURE
        keylset returnList log "On enable/disable failed\
                to $ripCmdServer select $chassis $card $port."
        return $returnList
    }
    
    if {$ripCmdGet} {
        # Get the RIP server configuration
        if {[$ripCmdServer get]} {
            keylset returnList status $::FAILURE
            keylset returnList log "On enable/disable failed\
                    to $ripCmdServer get."
            return $returnList
        }
    }
    
    # Get router
    if {[$ripCmdServer getRouter $session_handle] != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "On enable/disable failed\
                to $ripCmdServer getRouter $session_handle."
        return $returnList
    }
    
    # Get route range
    if {[$ripCmdRouter getRouteRange $route_handle] != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "On enable/disable failed\
                to $ripCmdRouter getRouteRange $route_handle."
        return $returnList
    }
    
    # Configure route range
    catch {$ripCmdRouteRange configure -$ripParamEnable $enable_value}
    
    # Set route range
    if {[$ripCmdRouter setRouteRange $route_handle] != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "On enable/disable failed\
                to $ripCmdRouter setRouteRange $route_handle."
        return $returnList
    }
    
    if {$ripCmdSet} {
        # Set configuration on port
        if {[$ripCmdServer set]} {
            keylset returnList status $::FAILURE
            keylset returnList log "On enable/disable failed\
                    to $ripCmdServer set."
            return $returnList
        }
    }
    
    if {$write_flag == "write"} {
        # Write configuration on port
        # Used only for advertise/withdraw
        if {[$ripCmdServer write]} {
            keylset returnList status $::FAILURE
            keylset returnList log "On enable/disable failed\
                    to $ripCmdServer write."
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripCheckRouterExistence
#
# Description:
#    Given a protocol interface description and a port handle it returns 1 if 
#    a router is found on that interface and on that port and 0 if not.
#
# Synopsis:
#    ::ixia::ripCheckRouterExistence
#        intf_description
#        rip_version
#        port_handle
#
# Arguments:
#        intf_description
#            A protocol interface description.
#        rip_version
#            The rip version also must match, because I can have two a router
#            on that interface but it can be of another type.
#        port_handle
#            A port handle where to look for routers.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                            provided.
#    key:existence      value:1 | 0.
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

proc ::ixia::ripCheckRouterExistence {intf_description rip_version port_handle} {
    
    variable rip_router_handles_array
    
    set allSessions [::ixia::ripGetAllSessionHandlesFromPort $port_handle]
    foreach session_handle $allSessions {
        set retCode [::ixia::ripGetParamValueFromSession       \
                $session_handle intf_description]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Checking router existence. \
                    [keylget retCode log]"
            return $returnList
        }
        set intf_description_reg [keylget retCode intf_description]
        
        set retCode [::ixia::ripGetParamValueFromSession       \
                $session_handle rip_version]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Checking router existence. \
                    [keylget retCode log]"
            return $returnList
        }
        set rip_version_reg [keylget retCode rip_version]

        if { ($intf_description_reg == $intf_description) && \
                    ([string range $rip_version_reg 0 3] ==  \
                    [string range $rip_version 0 3])} {
            keylset returnList status $::SUCCESS
            keylset returnList existence 1
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    keylset returnList existence 0
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripCheckRouterExistence
#
# Description:
#    Given a protocol interface description and a port handle it returns 1 if
#    a router is found on that interface and on that port and 0 if not.
#
# Synopsis:
#    ::ixia::ripCheckRouterExistence
#        intf_description
#        port_handle
#
# Arguments:
#        intf_description
#            A protocol interface description.
#        port_handle
#            A port handle where to look for routers.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                            provided.
#    key:existence      value:1 | 0.
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

proc ::ixia::ripCheckRouterIdExistence {router_id port_handle} {
    
    variable rip_router_handles_array
    
    set allSessions [::ixia::ripGetAllSessionHandlesFromPort $port_handle]
    foreach session_handle $allSessions {
        set retCode [::ixia::ripGetParamValueFromSession \
                $session_handle router_id]
        if {[keylget retCode status] == 1} {
            if {[keylget retCode router_id] == $router_id} {
                keylset returnList status $::SUCCESS
                keylset returnList existence 1
                return $returnList
            }
        }
        
    }
    keylset returnList status $::SUCCESS
    keylset returnList existence 0
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripCheckParametersValidity
#
# Description:
#    Checks that parameters that can only be used for one protocol only(ex: 
#    RIPng only, RIPv2 only) are not given for the other versions also.
#    It also sets the arrays of coresponding parameters for IxTclHal commands.
#
# Synopsis:
#    ::ixia::ripCheckParametersValidity
#
# Arguments:
#    There are no arguments because all the procedure is wrapped into an
#    uplevel call.
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
#

proc ::ixia::ripCheckParametersValidity {} {
    
    uplevel 1 {
        if {($session_type == "ripv1") || ($session_type == "ripv2")} {
            if {[info exists ip_version] && ($ip_version != 4)} {
                keylset returnList status $::FAILURE
                keylset returnList log "IP version v$ip_version is not\
                        valid for RIPv1 or RIPv2."
                return $returnList
            }
            # Check information for receive type and send type is valid
            if {$session_type == "ripv1"} {
                if {[info exists receive_type]} {
                    switch -- $receive_type {
                        v1 {}
                        default {
                            keylset returnList status $::FAILURE
                            keylset returnList log "-receive_type $receive_type \
                                    is not a valid choice with $session_type."
                            return $returnList
                        }
                    }
                }
                if {[info exists send_type]} {
                    switch -- $send_type {
                        broadcast_v1 {}
                        default {
                            keylset returnList status $::FAILURE
                            keylset returnList log "-send_type $send_type \
                                    is not a valid choice with $session_type."
                            return $returnList
                        }
                    }
                }
                if {[info exists authentication_mode]} {
                    unset authentication_mode
                }
                if {[info exists password]} {
                    unset password
                }
                set default_receive_type "v1"
                set default_send_type "broadcast_v1"
            }
            if {$session_type == "ripv2"} {
                if {[info exists receive_type]} {
                    switch -- $receive_type {
                        v2 {}
                        v1_v2 {}
                        default {
                            keylset returnList status $::FAILURE
                            keylset returnList log "-receive_type $receive_type \
                                    is not a valid choice with $session_type."
                            return $returnList
                        }
                    }
                }
                if {[info exists send_type]} {
                    switch -- $send_type {
                        broadcast_v2 {}
                        multicast {}
                        default {
                            keylset returnList status $::FAILURE
                            keylset returnList log "-send_type $send_type \
                                    is not a valid choice with $session_type."
                            return $returnList
                        }
                    }
                }
                set default_receive_type "v2"
                set default_send_type "multicast"
            }
            # Setup values for parameters
            array set enumList [list                           \
                    no_horizon       ripDefault                \
                    split_horizon    ripSplitHorizon           \
                    poison_reverse   ripPoisonReverse          \
                    discard          ripSplitHorizonSpaceSaver \
                    multicast        ripMulticast              \
                    broadcast_v1     ripBroadcastV1            \
                    broadcast_v2     ripBroadcastV2            \
                    v1               ripReceiveVersion1        \
                    v2               ripReceiveVersion2        \
                    v1_v2            ripReceiveVersion1And2    \
                    null             false                     \
                    text             true                      \
                    md5              false                     \
                    ]
            
            # Setup the corresponding parameters array
            array set ripInterfaceRouter [list                       \
                    responseMode             update_mode             \
                    sendType                 send_type               \
                    receiveType              receive_type            \
                    updateInterval           update_interval         \
                    updateIntervalOffset     update_interval_offset  \
                    enableAuthorization      authentication_mode     \
                    authorizationPassword    password                \
                    ]
            
        } elseif {$session_type == "ripng"}  {
            if {[info exists ip_version] && ($ip_version != 6)} {
                keylset returnList status $::FAILURE
                keylset returnList log "IP version v$ip_version is not\
                        valid for RIPng."
                return $returnList
            }
            # Enable interface metric if interface_metric provided
            if {[info exists interface_metric]} {
                if {$interface_metric == 0} {
                    set enable_interface_metric false
                } else  {
                    set enable_interface_metric true
                }
            }
            # Check if update mode is valid choice
            if {[info exists update_mode]} {
                if {$update_mode == "discard"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Discard is not a valid choice\
                            with RIPng. It is valid only forRIPv1 and RIPv2"
                    return $returnList
                }
            }
            # Check if receive type is valid choice
            if {[info exists receive_type]} {
                switch -- $receive_type {
                    ignore {}
                    store {}
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "-receive_type $receive_type \
                                is not a valid choice with $session_type."
                        return $returnList
                    }
                }
            }
            # Setup values for parameters
            array set enumList [list                           \
                    no_horizon       ripngNoSplitHorizon       \
                    split_horizon    ripngSplitHorizon         \
                    poison_reverse   ripngPoisonReverse        \
                    ignore           ripngIgnore               \
                    store            ripngStore                \
                    ]
            # Setup the corresponding parameters array
            array set ripngServer [list                              \
                    numRoutes                num_routes_per_period   \
                    timePeriod               time_period             \
                    ]
            
            # Setup the corresponding parameters array
            array set ripngRouter [list                              \
                    receiveType              receive_type            \
                    updateInterval           update_interval         \
                    updateIntervalOffset     update_interval_offset  \
                    enableInterfaceMetric    enable_interface_metric \
                    ]
            # Setup the corresponding parameters array
            array set ripngInterface [list                           \
                    responseMode             update_mode             \
                    interfaceMetric          interface_metric        \
                    ]
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::ripGetParamValueFromSession
#
# Description:
#    Given a session_handle returns the port_handle
#
# Synopsis:
#    ::ixia::ripGetParamValueFromSession
#        session_handle
#        parameter
#
# Arguments:
#        session_handle
#            The RIP session handle that you want to get the parameter value
#            for.
#        parameter
#            The parameter name that you want the value for. Valid parameter
#            names are: port_handle, rip_version, router_id, intf_description.
#
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                            provided.
#    key:parameter      value:the parameter value for that session.
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
proc ::ixia::ripGetParamValueFromSession {session_handle parameter} {
    
    variable rip_router_handles_array
    
    if {[info exists ::ixia::rip_router_handles_array($session_handle)]} {
        if {[lsearch [keylkeys \
                    ::ixia::rip_router_handles_array($session_handle)] \
                    $parameter] != -1} {
            
            set parameter_value [keylget \
                    ::ixia::rip_router_handles_array($session_handle) \
                    $parameter]
            
            keylset returnList status $::SUCCESS
            keylset returnList $parameter $parameter_value
        } else  {
            keylset returnList status $::FAILURE
            keylset returnList log "The $parameter parameter\
                    is not defined for $session_handle."
        }
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no information\
                available for session handle $session_handle"
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripGetParamValueFromRoute
#
# Description:
#    Given the route returns the session_handle from
#    that route.
#
# Synopsis:
#    ::ixia::ripGetParamValueFromRoute
#        route
#        parameter
#
# Arguments:
#        route
#            The route that you get parameter value from.
#        parameter
#            The name of the parameter that you want to get value for.
#            A valid parameter name is session_handle.
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
proc ::ixia::ripGetParamValueFromRoute {route parameter} {
    
    variable rip_route_handles_array
    
    if {[info exists ::ixia::rip_route_handles_array($route)]} {
        if {[lsearch [keylkeys ::ixia::rip_route_handles_array($route)] \
                    $parameter] != -1} {
            
            set parameter_value [keylget \
                    ::ixia::rip_route_handles_array($route) $parameter]
            
            keylset returnList status $::SUCCESS
            keylset returnList $parameter $parameter_value
        } else  {
            keylset returnList status $::FAILURE
            keylset returnList log "The $parameter parameter\
                    is not defined for $route."
        }
        
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no information\
                available for route $route"
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripClearAllRouters
#
# Description:
#    Clears all routers and routes from a given port from the global arrays.
#
# Synopsis:
#    ::ixia::ripClearAllRouters
#        chassis card port
#
# Arguments:
#        chassis card port
#            The port where the user wants to clear all routers.
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

proc ::ixia::ripClearAllRouters {chassis card port} {
    variable rip_router_handles_array
    variable rip_route_handles_array
    
    if {[array exists ::ixia::rip_router_handles_array]} {
        set retCode [::ixia::ripArrayUnsetValues               \
                -array_handle ::ixia::rip_router_handles_array \
                -port_handle  "$chassis/$card/$port"           ]
        if {[keylget retCode status] == 0} { return $retCode  }
        set unsetRouters [keylget retCode unsetIndices]
        foreach {index} $unsetRouters {
            set retCode [::ixia::ripArrayUnsetValues                  \
                    -array_handle    ::ixia::rip_route_handles_array  \
                    -session_handle  $index                           ]
        }
        
        if {[keylget retCode status] == 0} { return $retCode  }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripClearAllRouteRanges
#
# Description:
#    Clears all route ranges from a given router from the global arrays.
#
# Synopsis:
#    ::ixia::ripClearAllRouteRanges
#        session_handle
#
# Arguments:
#        session_handle
#            The router where the user wants to clear all routes.
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

proc ::ixia::ripClearAllRouteRanges {session_handle} {
    variable rip_route_handles_array
    
    if {[array exists ::ixia::rip_route_handles_array]} {
        set retCode [::ixia::ripArrayUnsetValues               \
                -array_handle ::ixia::rip_route_handles_array \
                -session_handle  $session_handle]
        if {[keylget retCode status] == 0} { return $retCode  }
        set unsetRouteHandles [keylget retCode unsetIndices]
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripGetAllRoutesFromSession
#
# Description:
#    Given a session_handle it returns all the routes created on that
#    session.
#
# Synopsis:
#    ::ixia::ripGetAllRoutesFromSession
#        session_handle
#
# Arguments:
#        session_handle
#            The session handle where to search for routes.
# Return Values:
#        A list of all routes on that session.
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

proc ::ixia::ripGetAllRoutesFromSession {session_handle} {
    
    variable rip_route_handles_array
    
    set all_routes [list ]
    foreach route [array names ::ixia::rip_route_handles_array] {
        set retCode [::ixia::ripGetParamValueFromRoute $route session_handle]
        set session_handle_reg [keylget retCode session_handle]
        
        if {$session_handle == $session_handle_reg} {
            lappend all_routes $route
        }
    }
    return $all_routes
}



##Internal Procedure Header
# Name:
#    ::ixia::ripGetAllSessionHandlesFromPort
#
# Description:
#    Given a port_handle it returns all the RIP routers created on that
#    port.
#
# Synopsis:
#    ::ixia::ripGetAllSessionHandlesFromPort
#        port_handle
#
# Arguments:
#        port_handle
#            The port handle where to search for session handles.
# Return Values:
#        A list of all RIP sessions on that port.
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

proc ::ixia::ripGetAllSessionHandlesFromPort {port_handle} {
    
    variable rip_router_handles_array
    
    set all_session_handles [list ]
    foreach session_handle [array names ::ixia::rip_router_handles_array] {
        set retCode [::ixia::ripGetParamValueFromSession \
                $session_handle port_handle]
        
        if {[keylget retCode status] == 1} {
            set port_handle_reg [keylget retCode port_handle]
            if {$port_handle == $port_handle_reg } {
                lappend all_session_handles $session_handle
            }
        }
    }
    return $all_session_handles
}

##Internal Procedure Header
# Name:
#    ::ixia::ripGetAllRouterIdsFromPort
#
# Description:
#    Given a port_handle it returns all the RIPng routers ids created on that
#    port. Valid only for RIPng.
#
# Synopsis:
#    ::ixia::ripGetAllRouterIdsFromPort
#        port_handle
#
# Arguments:
#        port_handle
#            The port handle where to search for router_ids.
# Return Values:
#    A key list
#    key:status         value:$::SUCCESS | $::FAILURE.
#    key:log            value:If status is failure, detailed information
#                             provided.
#    key:router_ids     value:A list of all RIPng router_ids on the given port.
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

proc ::ixia::ripGetAllRouterIdsFromPort {port_handle} {
    
    variable rip_router_handles_array
    
    set all_router_ids [list ]
    foreach session_handle [array names ::ixia::rip_router_handles_array] {
        set retCode [::ixia::ripGetParamValueFromSession \
                $session_handle port_handle]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed on getting port_handle \
                    for session.  [keylget retCode log]"
        }
        set port_handle_reg [keylget retCode port_handle]
        
        set retCode [::ixia::ripGetParamValueFromSession \
                $session_handle router_id]
        if {[keylget retCode status] == 1} {
            set router_id [keylget retCode router_id]
            if {$port_handle == $port_handle_reg } {
                lappend all_router_ids $router_id
            }
        }
    }
    keylset returnList status $::SUCCESS
    keylset returnList router_ids $all_router_ids
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ripGetNextHandle
#
# Description:
#    Given a list of handles and a the handle_name it returns the next_handle.
#
# Synopsis:
#    ::ixia::ripGetNextHandle
#        allHandles
#        handle_name
#
# Arguments:
#        allHandles
#            The list of similar handles.
#        handle_name
#            The name of the handle(ex: router, interface, route etc).
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

proc ::ixia::ripGetNextHandle {allHandles handle_name} {
    
    keylset returnList status $::SUCCESS
    if {[llength $allHandles] == 0} {
        keylset returnList next_handle ${handle_name}1
        return $returnList
    } else  {
        set allHandles [lsort -dictionary $allHandles]
        set pattern ""
        append pattern $handle_name "(\[0-9\]+)"
        regsub -all $pattern $allHandles {\1} allHandles
        if {[lindex $allHandles 0]>1} {
            keylset returnList next_handle ${handle_name}1
            return $returnList
        }
        set i 0
        while {([mpexpr \
                    [lindex $allHandles [mpexpr $i + 1]] \
                    - \
                    [lindex $allHandles $i]] == 1) && \
                    ($i < [llength $allHandles])} {
            
            incr i
        }
        if {$i == [llength $allHandles]} {
            set handle_num [mpexpr [lindex $allHandles end] + 1]
        } else  {
            set handle_num [mpexpr [lindex $allHandles $i] + 1]
        }
        keylset returnList next_handle ${handle_name}$handle_num
        return $returnList
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::ripArrayUnsetValues
#
# Description:
#    Given an array it modifies the array by unseting those elements who's
#    values corespond to the given pattern
#
# Synopsis:
#    ::ixia::ripArrayUnsetValues
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
#    key:log             value:if status is failure, detailed information
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

proc ::ixia::ripArrayUnsetValues {args} {
    
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
        keylset returnList log "Failed parsing on unsetting values.  $value"
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
            if {[lsearch [keylkeys value] port_handle] != -1} {
                set res [keylget value port_handle]
                if {$res == $port_handle} {
                    unset array_h($index)
                    lappend unsetIndices $index
                }
            }
            
        }
        if {[info exists session_handle]} {
            if {[lsearch [keylkeys value] session_handle] != -1} {
                set res [keylget value session_handle]
                if {$res == $session_handle} {
                    unset array_h($index)
                    lappend unsetIndices $index
                }
            }
        }
    }
    keylset returnList status $::SUCCESS
    keylset returnList unsetIndices $unsetIndices
    return $returnList
}

