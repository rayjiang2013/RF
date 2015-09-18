##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_bgp.tcl
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
#    - ::ixia::bgpGetNextHandle
#    - ::ixia::bgpGetRouteRangeType
#    - ::ixia::bgpRouteRangeExists
#    - ::ixia::updateBgpHandleArray
#
# Requirements:
#    utils_bgp.tcl , a library containing BGP TCL utilities
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
#    ::ixia::bgpGetNextHandle
#
# Description:
#    Given the type of route range it returns the next route range that can
#    be created.
#
# Synopsis:
#    ::ixia::bgpGetNextHandle
#        type
#
# Arguments:
#        type
#            The type of bgp handle.
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

proc ::ixia::bgpGetNextHandle {type} {
    
    variable bgp_handle_index
    
    switch -- $type {
        neighbor           { set handle_name bgpNeighbor       }
        bgp                { set handle_name bgpRouteRange     }
        bgp_mpls           { set handle_name bgpMplsRouteRange }
        bgp_vpn_site       { set handle_name bgpL3Site         }
        bgp_vpn_site_route { set handle_name bgpVpnRouteRange  }
        default            { set handle_name bgpRouteRange     }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList next_handle ${handle_name}$bgp_handle_index
    incr bgp_handle_index
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::bgpRouteRangeExists
#
# Description:
#    Returns $::SUCCESS | $::FAILURE if the route handle provided exists or not.
#
# Synopsis:
#    ::ixia::bgpRouteRangeExists
#        route_handle
#
# Arguments:
#        route_handle
#
# Return Values:
#    $::SUCCESS | $::FAILURE.
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

proc ::ixia::bgpRouteRangeExists {routeHandle} {
    variable bgp_route_handles_array
    
    set allHandles [array names bgp_route_handles_array]
    
    if {[lsearch -regexp $allHandles "(.)*,$routeHandle"] == -1} {
        return $::FAILURE
    }
    
    
    set routeRanges [list bgpNeighbor bgpRouteRange bgpMplsRouteRange bgpL3Site\
     bgpVpnRouteRange]
    foreach {routeName} $routeRanges {
        if {[regsub "$routeName\[0-9\]+" $routeHandle {} routeIgnore] == 1} {
            return $::SUCCESS
        }
    }
    return $::FAILURE
}


##Internal Procedure Header
# Name:
#    ::ixia::bgpGetRouteRangeType
#
# Description:
#    Given the route range returns the type of that route range.
#
# Synopsis:
#    ::ixia::bgpGetRouteRangeType
#        route_handle
#
# Arguments:
#        route_handle
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

proc ::ixia::bgpGetRouteRangeType {routeHandle} {
    
    set routeRanges [list bgpNeighbor bgpRouteRange bgpMplsRouteRange bgpL3Site\
     bgpVpnRouteRange]
    foreach {routeName} $routeRanges {
        if {[regsub "$routeName\[0-9\]+" $routeHandle {} routeIgnore] == 1} {
            break;
        }
    }
    
    switch -- $routeName {
        bgpNeighbor       { return neighbor        }
        bgpRouteRange     { return bgp             }
        bgpMplsRouteRange { return bgp_mpls        }
        bgpL3Site         { return bgp_vpn_site    }
        bgpVpnRouteRange  { return bgp_vpn_site_route }
        default           { return bgp             }
    }

}


##Internal Procedure Header
# Name:
#    ::ixia::updateBgpHandleArray
#
# Description:
#    This deletes elements in ::ixia::bgp_neighbor_handles_array and
#    ::ixia::bgp_route_handles_array.
#
# Synopsis:
#    ::ixia::updateBgpHandleArray
#        -mode           CHOICES  reset
#        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
#        
#
# Arguments:
#    -mode - The action that needs to be completed.
#    -port_handle
#        The port where action should take place.
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE.
#    key:log           value:When status is failure, contains more information
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

proc ::ixia::updateBgpHandleArray {args} {
    variable  bgp_neighbor_handles_array
    variable  bgp_route_handles_array
    
    set handleTypes ""
    
    set mand_args {
        -mode           CHOICES reset
        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args   \
                $mand_args} parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed in ::ixia::updateBgpHandleArray. \
                $parseError"
        return $returnList
    }
    
    switch $mode {
        reset {
            foreach {neighbor port} [array get bgp_neighbor_handles_array] {
                if {$port == $port_handle} {
                    foreach {route route_keylist} [array get \
                            bgp_route_handles_array] {
                        if {[keylget route_keylist neighbor] == $neighbor} {
                            unset bgp_route_handles_array($route)
                        }
                    }
                    unset bgp_neighbor_handles_array($neighbor)
                }
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}
