##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_isis.tcl
#
# Purpose:
#    Utility functions to suspport ISIS protocol config/control
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
#    ::ixia::formatAreaId
#
# Description:
#    This command formats the area_id parameter used in the ::ixia::emulation_isis_config
#   procedure. It must be used in order to maintain compatibility between the IxProtocols
#   and IxNetwork low level APIs. Currently the IxNetwork API accepts the area_id parameter
#   to be transmitted as a list of octets written in hexa, or a single number. The IxProtocols
#   only accepts area_id as a list of octets.
#   
#
# Synopsis:
#
# Arguments:
#    args    the area_id
#
# Return Values:
#    a list of formatted elements from the given args parameter
#
# Examples:
# formatAreaID 4 = [list 04]
# formatAreaID 44 = [list 44]
# formatAreaID 123 = [list 12 03]
# formatAreaID 1234 = [list 12 34]
# formatAreaID [list 33 44 55] = [list 33 44 55]
# formatAreaID [list 33 44 5] = [list 33 44 05]
#
proc ::ixia::formatAreaId {args} {
    set args [lindex $args 0]
    set returnList [list]
    set delimiter ""
    
    foreach el $args {
        set length [string length $el]
        set splitElement [list]
        
        if { $length % 2  == 1} {
            set el "0$el"
            set length [string length $el]
        }
        
        for {set i 0} {$i < $length} {incr i 2} {
            set first [string index $el $i]
            set second 0
            
            if {[expr {$i + 1}] < $length} {
                set second [string index $el [expr {$i + 1}]]
            } else {
                set second $first
                set first 0
            }
            
            set element "${first}${second}"

            lappend splitElement $element
        }
    
        append returnList "${delimiter}${splitElement}"
        set delimiter " "
    }

    return $returnList

}

##Internal Procedure Header
# Name:
#    ::ixia::actionIsis
#
# Description:
#    This command executes the specified action on an ISIS router
#
# Synopsis:
#
# Arguments:
#    chasNum    chassis number
#    cardNum    card number
#    portNum    port number
#    mode       actions.  choices are:  delete, enable, disable
#    handle     router handle where the actions are to be applied
#
# Return Values:
#    returnList with stauts == $::SUCCESS or $::FAILURE
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
proc ::ixia::actionIsis {chasNum cardNum portNum mode handle {child_handle ""} {child_type ""}} {
    
    keylset returnList status $::SUCCESS
    
    debug "isisServer select $chasNum $cardNum $portNum"
    if {[isisServer select $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure in call to isisServer\
                select $chasNum $cardNum $portNum."
        return $returnList
    }
    if {$child_handle == ""} {
        switch $mode {
            "delete" {
                debug "isisServer delRouter $handle"
                if {[isisServer delRouter $handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure in call to isisServer\
                            delRouter $handle on port $chasNum $cardNum $portNum."
                    return $returnList
                }
             }
            "enable" -
            "disable" {
                debug "isisServer getRouter $handle"
                if {[isisServer getRouter $handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure on call to isisServer\
                            getRouter $handle on port $chasNum $cardNum $portNum."
                    return $returnList
                }
                if {$mode == "enable"} {
                    debug "isisRouter config -enable $::true"
                    isisRouter config -enable $::true
                } else {
                    debug "isisRouter config -enable $::false"
                    isisRouter config -enable $::false
                }
                debug "isisServer setRouter $handle"
                if {[isisServer setRouter $handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure on call to isisServer\
                            setRouter $handle on port $chasNum $cardNum $portNum."
                    return $returnList
                }
             }
        }
    } else {
        debug "isisServer getRouter $handle"
        if {[isisServer getRouter $handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to isisServer\
                    getRouter $handle on port $chasNum $cardNum $portNum."
            return $returnList
        }
        array set dceMappings {
            dce_network_range {
                {parentCmd isisRouter}
                {selfCmd   isisDceNetworkRange}
                {delCmd    delDceNetworkRange}
                {getCmd    getDceNetworkRange}
                {setCmd    setDceNetworkRange}
            }
            dce_mcast_mac_range {
                {parentCmd isisRouter}
                {selfCmd   isisMulticastMacRange}
                {delCmd    delMulticastMacRange}
                {getCmd    getMulticastMacRange}
                {setCmd    setMulticastMacRange}
            }
            dce_mcast_ipv4_group_range {
                {parentCmd isisRouter}
                {selfCmd   isisDceMulticastIpv4GroupRange}
                {delCmd    delMulticastIpv4GroupRange}
                {getCmd    getMulticastIpv4GroupRange}
                {setCmd    setMulticastIpv4GroupRange}
            }
            dce_mcast_ipv6_group_range {
                {parentCmd isisRouter}
                {selfCmd   isisDceMulticastIpv6GroupRange}
                {delCmd    delMulticastIpv6GroupRange}
                {getCmd    getMulticastIpv6GroupRange}
                {setCmd    setMulticastIpv6GroupRange}
            }
            dce_node_mac_group {
                {parentCmd isisDceNetworkRange}
                {selfCmd   isisDceNodeMacGroups}
                {delCmd    delDceNodeMacGroups}
                {getCmd    getDceNodeMacGroups}
                {setCmd    setDceNodeMacGroups}
            }
            dce_node_ipv4_group {
                {parentCmd isisDceNetworkRange}
                {selfCmd   isisDceNodeIpv4Groups}
                {delCmd    delDceNodeIpv4Groups}
                {getCmd    getDceNodeIpv4Groups}
                {setCmd    setDceNodeIpv4Groups}
            }
            dce_node_ipv6_group {
                {parentCmd isisDceNetworkRange}
                {selfCmd   isisDceNodeIpv6Groups}
                {delCmd    delDceNodeIpv6Groups}
                {getCmd    getDceNodeIpv6Groups}
                {setCmd    setDceNodeIpv6Groups}
            }
            dce_outside_link {
                {parentCmd isisDceNetworkRange}
                {selfCmd   isisDceOutsideLinks}
                {delCmd    delDceOutsideLinks}
                {getCmd    getDceOutsideLinks}
                {setCmd    setDceOutsideLinks}
            }
        }
        set index 0
        foreach child_handle_elem $child_handle child_type_elem $child_type {
            switch $child_type_elem {
                dce_node_mac_group -
                dce_node_ipv4_group -
                dce_node_ipv6_group -
                dce_outside_link {
                    debug "isisRouter getDceNetworkRange $child_handle_elem"
                    if {[isisRouter getDceNetworkRange $child_handle_elem]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure in call to isisRouter getDceNetworkRange $child_handle_elem."
                        return $returnList
                    }
                }
            }
            incr index
            if {$index < [llength $child_handle]} { continue }
            switch $mode {
                "delete" {
                    if {[info exists dceMappings($child_type_elem)]} {
                        set parentCmd [keylget dceMappings($child_type_elem) parentCmd]
                        set delCmd    [keylget dceMappings($child_type_elem) delCmd]
                        debug "$parentCmd $delCmd $child_handle_elem"
                        if {[$parentCmd $delCmd $child_handle_elem]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failure in call to $parentCmd $delCmd $child_handle_elem."
                            return $returnList
                        }
                    }
                 }
                "enable" -
                "disable" {
                    if {[info exists dceMappings($child_type_elem)]} {
                        set parentCmd [keylget dceMappings($child_type_elem) parentCmd]
                        set selfCmd   [keylget dceMappings($child_type_elem) selfCmd]
                        set getCmd    [keylget dceMappings($child_type_elem) getCmd]
                        set setCmd    [keylget dceMappings($child_type_elem) setCmd]
                        debug "$parentCmd $getCmd $child_handle_elem"
                        if {[$parentCmd $getCmd $child_handle_elem]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failure in call to $parentCmd $getCmd $child_handle_elem."
                            return $returnList
                        }
                        if {$mode == "enable"} {
                            debug "$selfCmd config -enabled $::true"
                            $selfCmd config -enabled $::true
                        } else {
                            debug "$selfCmd config -enabled $::false"
                            $selfCmd config -enabled $::false
                        }
                        debug "$parentCmd $setCmd $child_handle_elem"
                        if {[$parentCmd $setCmd $child_handle_elem]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failure in call to $parentCmd $setCmd $child_handle_elem."
                            return $returnList
                        }
                    }
                }
            }
        }
    }
    return $returnList
}



##Internal Procedure Header
# Name:
#    ::ixia::updateIsisHandleArray
#
# Description:
#    This command creates or deletes an element in isis_handles_array.
#    
#    An element in isis_handles_array is in the form of
#         ($session_handle,session)  port_handle
#           or
#         ($session_handle,topology,$elem_handle)  type
#               ....
#    where $session_handle is the router handle
#    and $elem_handle is handle to topology element.  
#    Below is the mapping for the topology vs. type of element handle
#           ISIS
#               stub/external -         isisRouteRange handle
#               router/grid -           isisGrid handle
#
# Synopsis:
#
# Arguments:
#    This command creates or deletes an element in isis_handles_array.
#    Eech element stores the port_handle and session_type associated with
#    the session handle.
#
# Return Values:
#    $::TCL_OK for success
#    $::TCL_ERROR for failure to delete an element
#
# Examples:
#   [array get isis_handles_array] shows 
#       ...
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::updateIsisHandleArray {mode port_handle {handle NULL}} {
    variable  isis_handles_array

    set procName [lindex [info level [info level]] 0]       
    set retCode $::TCL_OK

    switch $mode {
        create {
            set isis_handles_array($handle,session) [list $port_handle]
            if {![info exists isis_handles_array($port_handle)]} {
                set isis_handles_array($port_handle) $handle
            } else {
                lappend isis_handles_array($port_handle) $handle
            }
        }
        delete {
            set isisHandleList [array get isis_handles_array]
            set match1 [lsearch $isisHandleList ${handle},session]
            set portHandle [lindex $isis_handles_array(${handle},session) 0]
            set match2 [lsearch $isis_handles_array($portHandle) $handle]
            if {$match1 >= 0} {
                array unset isis_handles_array ${handle},session
            } else {
                puts "Error in $procName:  Cannot delete the $handle in \
                                           isis_handle_array"
                set retCode $::TCL_ERROR
            }
            if {$match2 >= 0} {
                set isis_handles_array($portHandle) [lreplace $isis_handles_array($portHandle) $match2 $match2]
            }
        }
        reset {
            if {[info exists isis_handles_array(${port_handle},session)]} {
                set portHandle [lindex $isis_handles_array(${port_handle},session) 0]
                set match2 [lsearch $isis_handles_array($portHandle) $port_handle]
                if {$match2 >= 0} {
                    set isis_handles_array($portHandle) [lreplace $isis_handles_array($portHandle) $match2 $match2]
                }
            }
            array unset isis_handles_array ${port_handle}*
        }
    }
}



##Internal Procedure Header
# Name:
#    ::ixia::updateIsisTopologyHandleArray
#
# Description:
#    This command creates or deletes an element in isis_handles_array.
#    
#    An element in isis_handles_array is in the form of
#         ($session_handle,session)  port_handle
#           or
#         ($session_handle,topology,$elem_handle)  type
#               ....
#    where $session_handle is the router handle
#    and $elem_handle is handle to topology element.  
#    Below is the mapping for the topology vs. type of element handle
#           ISIS
#               stub/external -         isisRouteRange handle
#               router/grid -           isisGrid handle
#
# Synopsis:
#
# Arguments:
#    This command creates or deletes an element in isis_handles_array.
#    Eech element stores the port_handle and session_type associated with
#    the session handle.
#
# Return Values:
#    $::TCL_OK for success
#    $::TCL_ERROR for failure to delete an element
#
# Examples:
#   [array get isis_handles_array] shows 
#       ...
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::updateIsisTopologyHandleArray {mode handle elem_handle {type router} {ipVersion 4}} {
    variable  isis_handles_array

    set procName [lindex [info level [info level]] 0]       
    set retCode $::TCL_OK

    switch $mode {
        create {
            set isis_handles_array($handle,topology,${elem_handle}) [list $type $ipVersion]
        }
        delete {
            set isisHandleList [array get isis_handles_array]
            set match [lsearch $isisHandleList ${handle},topology,${elem_handle}]
            if {$match >= 0} {
                array unset isis_handles_array ${handle},topology,${elem_handle}
            } else {
                puts "Error in $procName:  Cannot delete the\ 
                     $handle,topology,${elem_handle} in isis_handle_array"
                set retCode $::TCL_ERROR
            }
        }
    }
    
    return $retCode
}



##Internal Procedure Header
# Name:
#    ::ixia::getIsisElemInfoFromHandle
#
# Description:
#    This command returns the type of the network for the session handle 
#    and the topology element handle
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
proc ::ixia::getIsisElemInfoFromHandle {handle elem_handle elem_name} {
    variable  isis_handles_array

    set procName [lindex [info level [info level]] 0]       

    if {[catch {set isis_handles_array(${handle},topology,${elem_handle})}\
            elem_info]} {
		# this is the -mode modify with session resume
		keylset returnList status $::FAILURE
		keylset returnList log "If the ixncfg is loaded using session resume,\
				please specify the -type parameter. Cannot find\
				the ${elem_handle} in isis_handles_array."
		return $returnList
    }

    switch $elem_name {
        type {
            keylset returnList status $::SUCCESS
            keylset returnList value  [lindex $elem_info 0]
            return $returnList
        }
        ip_version {
            keylset returnList status $::SUCCESS
            keylset returnList value  [lindex $elem_info 1]
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid attribute $elem_name for \
                    ${elem_handle}."
            return $returnList
        }
    }
}



##Internal Procedure Header
# Name:
#    ::ixia::create_isis_topology_route_array
# Description:
#    Creates ISIS arrays of IxTclHal option to Cisco option pair for
#    each type of network. In addition, a higher layer array is
#    create to map the "type" of network to the name of the array
#    to be used for configuration.
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
proc ::ixia::create_isis_topology_route_arrays {} {

    variable isisConfigCommandArray
    variable isisIpConfigCommandArray
    variable routerGridOptionsArray
    variable routerRangeTeOptionsArray
    variable gridOptionsArray
    variable gridRouteOptionsArray
    variable gridRangeTeOptionsArray
    variable stubRouteRangeOptionsArray
    variable externalRouteRangeOptionsArray
    variable gridInternodeRouterOptionsArray
    variable stubRouteRangeOptionsArray
    variable externalRouteRangeOptionsArray
    variable dceMcastMacRangeOptionsArray
    variable dceMcastMacRangeOptionsArrayType
    variable dceMcastIpV4GrpRangeOptionsArray
    variable dceMcastIpV6GrpRangeOptionsArray
    variable dceNetworkRangeOptionsArray
    variable dceNetworkRangeOptionsArrayType
    variable dceNodeMacGroupOptionsArray
    variable dceNodeMacGroupOptionsArrayType
    variable dceNodeIpv4GroupOptionsArray
    variable dceNodeIpv6GroupOptionsArray
    variable dceOutsideLinkOptionsArray
    variable dceOutsideLinkOptionsArrayType
    variable isisEnumList

    ### for stub and external networks, the options are Ip dependent
    array set isisConfigCommandArray {
        router {
            {isisGrid                 routerGridOptionsArray    }
            {isisGridRangeTe          routerRangeTeOptionsArray }
        }
        grid   {
            {isisGrid                 gridOptionsArray         }
            {isisGridRoute            gridRouteOptionsArray    }
            {isisGridRangeTe          gridRangeTeOptionsArray  }
        }
        dce_mcast_mac_range   {
            {isisDceMulticastMacRange         dceMcastMacRangeOptionsArray }
        }
        dce_mcast_ipv4_group_range {
            {isisDceMulticastIpv4GroupRange   dceMcastIpV4GrpRangeOptionsArray}
        }
        
        dce_mcast_ipv6_group_range {
            {isisDceMulticastIpv6GroupRange   dceMcastIpV6GrpRangeOptionsArray}
        }
        dce_network_range   {
            {isisDceNetworkRange              dceNetworkRangeOptionsArray }
        }
        dce_node_mac_group   {
            {isisDceNodeMacGroups             dceNodeMacGroupOptionsArray }
        }
        dce_node_ipv4_group {
            {isisDceNodeIpv4Groups            dceNodeIpv4GroupOptionsArray}
        }
        dce_node_ipv6_group {
            {isisDceNodeIpv6Groups            dceNodeIpv6GroupOptionsArray}
        }
        dce_outside_link {
            {isisDceOutsideLinks              dceOutsideLinkOptionsArray}
        }
    }

    ##### This configuration is IP version dependent
    array set isisIpConfigCommandArray {
        router {
            {isisGridInternodeRoute           gridInternodeRouterOptionsArray}
        }
        grid  {
            {isisGridInternodeRoute           gridInternodeRouterOptionsArray}
        }
        stub  {
            {isisRouteRange                   stubRouteRangeOptionsArray}
        }
        external {
            {isisRouteRange                   externalRouteRangeOptionsArray}
        }
        dce_mcast_mac_range   {
        }
        dce_mcast_ipv4_group_range {
        }
        dce_mcast_ipv6_group_range {
        }
        dce_network_range   {
        }
        dce_node_mac_group   {
        }
        dce_node_ipv4_group {
        }
        dce_node_ipv6_group {
        }
        dce_outside_link {
        }
    }
    
    ###########################################################
    ### Router Configuration Array                          ###
    ###########################################################
    
    array set routerGridOptionsArray [list                  \
            enable              enable                      \
            enableTe            link_te                     \
            enableUserWideMetric  local_wide_metric         \
            entryPointColumn    local_entry_point_column    \
            entryPointRow       local_entry_point_row       \
            firstRouterId       router_system_id            \
            interfaceMetric     local_link_metric           \
            linkType            router_link_type            \
            numColumns          local_num_columns           \
            numRows             local_num_rows              \
            teRouterId          router_id                   \
            ]

    ####### add this one manually ###########
    array set gridInternodeRouterOptionsArray [list         \
            ipAddress           local_ip_start              \
            ipMask              local_ip_pfx_len            \
            ipStep              local_ip_step               \
            ipType              local_ip_type               \
            ]


    array set routerRangeTeOptionsArray [list                           \
            linkMetric                      link_te_metric              \
            administrativeGroup             local_te_admin_group        \
            maxBandwidth                    link_te_max_bw              \
            maxReservableBandwidth          link_te_max_resv_bw         \
            unreservedBandwidthPriority0    link_te_unresv_bw_priority0 \
            unreservedBandwidthPriority1    link_te_unresv_bw_priority1 \
            unreservedBandwidthPriority2    link_te_unresv_bw_priority2 \
            unreservedBandwidthPriority3    link_te_unresv_bw_priority3 \
            unreservedBandwidthPriority4    link_te_unresv_bw_priority4 \
            unreservedBandwidthPriority5    link_te_unresv_bw_priority5 \
            unreservedBandwidthPriority6    link_te_unresv_bw_priority6 \
            unreservedBandwidthPriority7    link_te_unresv_bw_priority7 \
            ]
            
    ###########################################################
    ### Grid Configuration Array                            ###
    ###########################################################
    
    array set gridOptionsArray [list                          \
            enable                enable                      \
            enableTe              grid_te                     \
            enableUserWideMetric  grid_user_wide_metric       \
            entryPointColumn      local_entry_point_column    \
            entryPointRow         local_entry_point_row       \
            firstRouterId         grid_start_system_id        \
            interfaceMetric       grid_interface_metric       \
            linkType              grid_link_type              \
            numColumns            grid_col                    \
            numRows               grid_row                    \
            routerIdIncrementBy   grid_system_id_step         \
            teRouterId            grid_start_te_ip            \
            teRouterIdIncrementBy grid_te_ip_step             \
            ]

    #### grid_stub_per_router, grid_router_id, grid_router_id_step
    #### and stub_count, stub_ip_start, stub_ip_step are configuring
    #### the same options.  If both exists, the stub will overwrite
    #### the grid_router options
    array set gridRouteOptionsArray [list                   \
            enable                  enable                  \
            numberOfNetworks        grid_stub_per_router    \
            networkIpAddress        grid_router_id          \
            nodeStep                grid_router_id_step     \
            metric                  grid_router_metric      \
            prefix                  grid_router_ip_pfx_len  \
            enableRedistributed     grid_router_up_down_bit \
            routeOrigin             grid_router_origin      \
            ]

    array set gridRangeTeOptionsArray [list                             \
            linkMetric                      grid_te_metric              \
            administrativeGroup             grid_te_admin               \
            maxBandwidth                    grid_te_max_bw              \
            maxReservableBandwidth          grid_te_max_resv_bw         \
            unreservedBandwidthPriority0    grid_te_unresv_bw_priority0 \
            unreservedBandwidthPriority1    grid_te_unresv_bw_priority1 \
            unreservedBandwidthPriority2    grid_te_unresv_bw_priority2 \
            unreservedBandwidthPriority3    grid_te_unresv_bw_priority3 \
            unreservedBandwidthPriority4    grid_te_unresv_bw_priority4 \
            unreservedBandwidthPriority5    grid_te_unresv_bw_priority5 \
            unreservedBandwidthPriority6    grid_te_unresv_bw_priority6 \
            unreservedBandwidthPriority7    grid_te_unresv_bw_priority7 \
            ]
    
    ###########################################################
    ### Stub Configuration Array                            ###
    ###########################################################

    #### This array is used when the stub network is created behind
    #### a session router
    array set stubRouteRangeOptionsArray [list          \
            enable              enable                  \
            metric              stub_metric             \
            numberOfNetworks    stub_count              \
            prefix              local_stub_ip_pfx_len   \
            networkIpAddress    local_stub_ip_start     \
            enableRedistributed stub_up_down_bit        \
            routeOrigin         local_stub_route_origin \
            ipType              local_stub_ip_type      \
     ]                  

    #### This array is used when the stub network is created within
    #### grid (type == grid) - defined but not implemented yet.
    array set stubNodeRangeOptionsArray [list           \
            enable              enable                  \
            metric              stub_metric             \
            numberOfNetworks    stub_count              \
            prefix              local_stub_ip_pfx_len   \
            networkIpAddress    local_stub_ip_start     \
            enableRedistributed stub_up_down_bit        \
            routeOrigin         local_stub_route_origin \
            ipType              local_stub_ip_type      \
     ]                  


    ###########################################################
    ### External Configuration Array                        ###
    ###########################################################

    #### This array is used when the external network is created behind
    #### a session router
    array set externalRouteRangeOptionsArray [list      \
            enable              enable                  \
            metric              external_metric         \
            numberOfNetworks    external_count          \
            prefix              local_ext_ip_pfx_len    \
            networkIpAddress    local_ext_ip_start      \
            enableRedistributed external_up_down_bit    \
            routeOrigin         local_ext_route_origin  \
            ipType              local_ext_ip_type       \
     ]                  
 
     #### This array is used when the external network is created within
     #### grid (type == grid)
     array set externalNodeRangeOptionsArray [list      \
            enable              enable                  \
            metric              external_metric         \
            numberOfNetworks    external_count          \
            prefix              local_ext_ip_pfx_len    \
            networkIpAddress    local_ext_ip_start      \
            enableRedistributed external_up_down_bit    \
            routeOrigin         local_ext_route_origin  \
            ipType              local_ext_ip_type       \
     ]

    ###########################################################
    ### Dce Mcast Mac Range Configuration Array             ###
    ###########################################################

    #### This array is used when the dce_mast_mac_range network is created behind
    #### a session router
    array set dceMcastMacRangeOptionsArray {
        enabled                           enable
        interGroupUnicastMacIncrement     dce_inter_grp_ucast_step
        intraGroupUnicastMacIncrement     dce_intra_grp_ucast_step
        multicastMacCount                 dce_mcast_addr_count
        multicastMacStep                  dce_mcast_addr_step
        sourceGroupMapping                dce_src_grp_mapping
        startMulticastMac                 dce_mcast_start_addr
        startUnicastSourceMac             dce_ucast_src_addr
        unicastSourcesPerMulticastMac     dce_ucast_sources_per_mcast_addr
        vlanId                            dce_vlan_id
    }
    array set dceMcastMacRangeOptionsArrayType {
        interGroupUnicastMacIncrement     mac
        intraGroupUnicastMacIncrement     mac
        multicastMacStep                  mac
        startMulticastMac                 mac
        startUnicastSourceMac             mac
    }

    ###########################################################
    ### Dce Mcast IPv4 Group Range Configuration Array      ###
    ###########################################################

    #### This array is used when the dce_mast_mac_range network is created behind
    #### a session router
    array set dceMcastIpV4GrpRangeOptionsArray {
        enabled                            enable
        interGroupUnicastIpv4Increment     dce_inter_grp_ucast_step
        intraGroupUnicastIpv4Increment     dce_intra_grp_ucast_step
        multicastIpv4Count                 dce_mcast_addr_count
        multicastIpv4Step                  dce_mcast_addr_step
        sourceGroupMapping                 dce_src_grp_mapping
        startMulticastIpv4                 dce_mcast_start_addr
        startUnicastSourceIpv4             dce_ucast_src_addr
        unicastSourcesPerMulticastIpv4     dce_ucast_sources_per_mcast_addr
        vlanId                             dce_vlan_id
    }
#     array set dceMcastIpV4GrpRangeOptionsArrayType {
#         interGroupUnicastIpv4Increment     ipv4
#         intraGroupUnicastIpv4Increment     ipv4
#         multicastIpv4Step                  ipv4
#         startMulticastIpv4                 ipv4
#         startUnicastSourceIpv4             ipv4
#     }
    
    ###########################################################
    ### Dce Mcast IPv6 Group Range Configuration Array      ###
    ###########################################################

    #### This array is used when the dce_mast_mac_range network is created behind
    #### a session router
    array set dceMcastIpV6GrpRangeOptionsArray {
        enabled                            enable
        interGroupUnicastIpv6Increment     dce_inter_grp_ucast_step
        intraGroupUnicastIpv6Increment     dce_intra_grp_ucast_step
        multicastIpv6Count                 dce_mcast_addr_count
        multicastIpv6Step                  dce_mcast_addr_step
        sourceGroupMapping                 dce_src_grp_mapping
        startMulticastIpv6                 dce_mcast_start_addr
        startUnicastSourceIpv6             dce_ucast_src_addr
        unicastSourcesPerMulticastIpv6     dce_ucast_sources_per_mcast_addr
        vlanId                             dce_vlan_id
    }
#     array set dceMcastIpV6GrpRangeOptionsArrayType {
#         interGroupUnicastIpv6Increment     ipv6
#         intraGroupUnicastIpv6Increment     ipv6
#         multicastIpv6Step                  ipv6
#         startMulticastIpv6                 ipv6
#         startUnicastSourceIpv6             ipv6
#         unicastSourcesPerMulticastIpv6     ipv6
#     }
    
    ###########################################################
    ### DCE Network Range Configuration Array               ###
    ###########################################################
    array set dceNetworkRangeOptionsArray {
        deviceId                        dce_device_id
        startSwitchId                   dce_device_id
        deviceIdStep                    dce_device_id_step
        switchIdStep                    dce_device_id_step
        devicePriority                  dce_device_pri
        switchIdPriority                dce_device_pri
        enableFtag                      dce_ftag_enable
        enabled                         enable
        entryPointColumn                dce_local_entry_point_column
        entryPointRow                   dce_local_entry_point_row
        fTagValue                       dce_ftag
        firstRouterId                   dce_system_id
        startSystemId                   dce_system_id
        interfaceMetric                 dce_local_link_metric
        numColumns                      dce_local_num_columns
        numRows                         dce_local_num_rows
        numberOfMultiDestinationTrees   dce_num_mcast_destination_trees
        routerIdIncrementBy             dce_system_id_step
        systemIdIncrementBy             dce_system_id_step
        startBroadcastRootPriority      dce_bcast_root_pri
        startBroadcastRootPriorityStep  dce_bcast_root_pri_step
    }
    
    array set dceNetworkRangeOptionsArrayType {
        firstRouterId                   hex
        startSystemId                   hex
        routerIdIncrementBy             hex
        systemIdIncrementBy             hex
    }
    

    ###########################################################
    ### DCE Node Mac Group Configuration Array              ###
    ###########################################################
    array set dceNodeMacGroupOptionsArray {        
        includeMacGroups                   dce_include_groups
        interGroupUnicastMacIncrement      dce_inter_grp_ucast_step
        intraGroupUnicastMacIncrement      dce_intra_grp_ucast_step
        multicastAddressNodeStep           dce_mcast_addr_node_step
        multicastMacCount                  dce_mcast_addr_count
        multicastMacStep                   dce_mcast_addr_step
        sourceGroupMapping                 dce_src_grp_mapping
        startMulticastMac                  dce_mcast_start_addr
        startUnicastSourceMac              dce_ucast_src_addr
        unicastAddressNodeStep             dce_ucast_addr_node_step
        unicastSourcesPerMulticastMac      dce_ucast_sources_per_mcast_addr
        vlanId                             dce_vlan_id
    }
    
    array set dceNodeMacGroupOptionsArrayType {
        interGroupUnicastMacIncrement     mac
        intraGroupUnicastMacIncrement     mac
        multicastAddressNodeStep          mac
        multicastMacStep                  mac
        startMulticastMac                 mac
        startUnicastSourceMac             mac
        unicastAddressNodeStep            mac
    }
    
    ###########################################################
    ### DCE Node IPv4 Group Configuration Array             ###
    ###########################################################
    array set dceNodeIpv4GroupOptionsArray {        
        includeIpv4Groups                  dce_include_groups
        interGroupUnicastIpv4Increment     dce_inter_grp_ucast_step
        intraGroupUnicastIpv4Increment     dce_intra_grp_ucast_step
        multicastAddressNodeStep           dce_mcast_addr_node_step
        multicastIpv4Count                 dce_mcast_addr_count
        multicastIpv4Step                  dce_mcast_addr_step
        sourceGroupMapping                 dce_src_grp_mapping
        startMulticastIpv4                 dce_mcast_start_addr
        startUnicastSourceIpv4             dce_ucast_src_addr
        unicastAddressNodeStep             dce_ucast_addr_node_step
        unicastSourcesPerMulticastIpv4     dce_ucast_sources_per_mcast_addr
        vlanId                             dce_vlan_id
    }
    
    ###########################################################
    ### DCE Node IPv6 Group Configuration Array             ###
    ###########################################################
    array set dceNodeIpv6GroupOptionsArray {        
        includeIpv6Groups                  dce_include_groups
        interGroupUnicastIpv6Increment     dce_inter_grp_ucast_step
        intraGroupUnicastIpv6Increment     dce_intra_grp_ucast_step
        multicastAddressNodeStep           dce_mcast_addr_node_step
        multicastIpv6Count                 dce_mcast_addr_count
        multicastIpv6Step                  dce_mcast_addr_step
        sourceGroupMapping                 dce_src_grp_mapping
        startMulticastIpv6                 dce_mcast_start_addr
        startUnicastSourceIpv6             dce_ucast_src_addr
        unicastAddressNodeStep             dce_ucast_addr_node_step
        unicastSourcesPerMulticastIpv6     dce_ucast_sources_per_mcast_addr
        vlanId                             dce_vlan_id
    }
    
    
    
    ###########################################################
    ### DCE Outside Link Configuration Array                ###
    ###########################################################
    array set dceOutsideLinkOptionsArray {        
        connectionColumn                   dce_connection_column
        connectionRow                      dce_connection_row
        linkedRouterId                     dce_linked_router_id
    }
    
    array set dceOutsideLinkOptionsArrayType {    
        linkedRouterId                     hex
    }
    
    ###########################################################
    ### Enum List                                           ###
    ###########################################################
     set isisEnumListTemp [list                            \
            broadcast           ::isisGridLinkBroadcast    \
            ptop                ::isisGridLinkPointToPoint \
            stub                ::isisRouteInternal        \
            external            ::isisRouteExternal        \
            ipv4                ::addressTypeIpV4          \
            ipv6                ::addressTypeIpV6          \
            fully_meshed        ::fullyMeshedMapping       \
            one_to_one          ::oneToOneMapping          \
            manual_mapping      ::manualMapping            \
     ]
     foreach {hltElem ixnElem} $isisEnumListTemp {
        if {[info exists $ixnElem]} {
            set isisEnumList($hltElem) [set $ixnElem]
        }
     }
}


##Internal Procedure Header
# Name:
#    ::ixia::createIsisRouteObject
# Description:
#    Creates new topology element to the session_handle.  This is done by
#    configuring and adding isisRouteRange or isisGrid objects to isisRouter.    
#
# Synopsis:
#
# Arguments:    
#    handle -       session_handle
#    port_handle -  specifies the chassis/card/port        
#    args  -        options passed in from emulation_isis_config.  These 
#                   options are used to set the IxTclHal's command options 
#
# Return Values:    
#    elem_handle - the topology element handle is returned
#    NULL        - returns NULL if there's error
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
proc ::ixia::createIsisRouteObject {parent_handle port_handle args} {

    variable isisConfigCommandArray
    variable isisIpConfigCommandArray
    variable routerGridOptionsArray
    variable routerRangeTeOptionsArray
    variable gridOptionsArray
    variable gridRouteOptionsArray
    variable gridRangeTeOptionsArray
    variable stubRouteRangeOptionsArray
    variable externalRouteRangeOptionsArray
    variable gridInternodeRouterOptionsArray
    variable stubRouteRangeOptionsArray
    variable externalRouteRangeOptionsArray
    variable dceMcastMacRangeOptionsArray
    variable dceMcastMacRangeOptionsArrayType
    variable dceMcastIpV4GrpRangeOptionsArray
    variable dceMcastIpV6GrpRangeOptionsArray
    variable dceNetworkRangeOptionsArray
    variable dceNetworkRangeOptionsArrayType
    variable dceNodeMacGroupOptionsArray
    variable dceNodeMacGroupOptionsArrayType
    variable dceNodeIpv4GroupOptionsArray
    variable dceNodeIpv6GroupOptionsArray
    variable dceOutsideLinkOptionsArray
    variable dceOutsideLinkOptionsArrayType
    variable isisEnumList

    set procName [lindex [info level [info level]] 0]
  
    ### upvar all the command options
    set args [join $args]
    foreach item $args {
        if {[string first - $item] == 0} {
            set option [string trimleft $item -]
            upvar $option $option
        }
    }
    if {![info exists ip_version]} {
        set ip_version 4_6
    }
    if {![info exists type]} {
        puts "ERROR in $procName: Parameter type should be provided."                                      
        return NULL
    }
    
    # Check DCE parameters to see if they have the same type
    # Set default values
    if {$type == "dce_mcast_mac_range" || \
            $type == "dce_mcast_ipv4_group_range" || \
            $type == "dce_mcast_ipv6_group_range" || \
            $type == "dce_node_mac_group" || \
            $type == "dce_node_ipv4_group" || \
            $type == "dce_node_ipv6_group"} {
        set dce_param_list {
            dce_mcast_start_addr       {
                0100.0000.0000   224.0.0.0   FF03:0::0
                0100.0000.0000   224.0.0.0   FF03:0::0  
            }
            dce_mcast_addr_step        {
                0000.0000.0001   0.0.0.1     0::1
                0000.0000.0001   0.0.0.1     0::1       
            }
            dce_ucast_src_addr         {
                0000.0000.0000   0.0.0.0     0::0
                0000.0000.0000   0.0.0.0     0::0       
            }
            dce_intra_grp_ucast_step   {
                0000.0000.0001   0.0.0.1     0::1
                0000.0000.0001   0.0.0.1     0::1       
            }
            dce_inter_grp_ucast_step   {
                0000.0000.0000   0.0.0.0     0::0
                0000.0000.0000   0.0.0.0     0::0       
            }
            dce_mcast_addr_node_step   {
                {}               {}          {}
                0000.0000.0100   0.0.1.0     0::10
            }
            dce_ucast_addr_node_step   {
                {}               {}          {}
                0000.0000.0100   0.0.1.0     0::10
            }
        }
        foreach {dce_param  dce_default_values} $dce_param_list {
            switch -- $type {
                dce_mcast_mac_range {
                    if {[info exists $dce_param]} {
                        if {![::ixia::isValidMacAddress [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with a MAC value."                                      
                            return NULL
                        }
                    } else {
                        if {[lindex $dce_default_values 0] == ""} { continue }
                        set $dce_param [lindex $dce_default_values 0]
                    }
                }
                dce_mcast_ipv4_group_range {
                    if {[info exists $dce_param]} {
                        if {![isIpAddressValid [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with an IPv4 value."                                      
                            return NULL
                        }
                    } else {
                        if {[lindex $dce_default_values 1] == ""} { continue }
                        set $dce_param [lindex $dce_default_values 1]
                    }
                }
                dce_mcast_ipv6_group_range {
                    if {[info exists $dce_param]} {
                        if {![::ipv6::isValidAddress [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with an IPv6 value."                                      
                            return NULL
                        }
                    } else {
                        if {[lindex $dce_default_values 2] == ""} { continue }
                        set $dce_param [lindex $dce_default_values 2]
                    }
                }
                dce_node_mac_group {
                    if {[info exists $dce_param]} {
                        if {![::ixia::isValidMacAddress [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with a MAC value."                                      
                            return NULL
                        }
                    } else {
                        if {[lindex $dce_default_values 3] == ""} { continue }
                        set $dce_param [lindex $dce_default_values 3]
                    }
                }
                dce_node_ipv4_group {
                    if {[info exists $dce_param]} {
                        if {![isIpAddressValid [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with an IPv4 value."                                      
                            return NULL
                        }
                    } else {
                        if {[lindex $dce_default_values 4] == ""} { continue }
                        set $dce_param [lindex $dce_default_values 4]
                    }
                }
                dce_node_ipv6_group {
                    if {[info exists $dce_param]} {
                        if {![::ipv6::isValidAddress [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with an IPv6 value."                                      
                            return NULL
                        }
                    } else {
                        if {[lindex $dce_default_values 5] == ""} { continue }
                        set $dce_param [lindex $dce_default_values 5]
                    }
                }
            } 
        }
    }
    
    ### Don't change the order of following few lines
    if {$type == "dce_mcast_mac_range"} {
        set elem_handle [ixia::getNextLabel isisRouter          MulticastMacRange           isis ${parent_handle}]
    } elseif {$type == "dce_mcast_ipv4_group_range" } {
        set elem_handle [ixia::getNextLabel isisRouter          MulticastIpv4GroupRange     isis ${parent_handle}]
    } elseif {$type == "dce_mcast_ipv6_group_range"} {
        set elem_handle [ixia::getNextLabel isisRouter          MulticastIpv6GroupRange     isis ${parent_handle}]
    } elseif {$type == "dce_network_range"} {
        set elem_handle [ixia::getNextLabel isisRouter          DceNetworkRange             isis ${parent_handle}]
    } elseif {$type == "dce_node_mac_group"} {
        set elem_handle [ixia::getNextLabel isisDceNetworkRange DceNodeMacGroups            isis ${parent_handle}]
    } elseif {$type == "dce_node_ipv4_group" } {
        set elem_handle [ixia::getNextLabel isisDceNetworkRange DceNodeIpv4Groups           isis ${parent_handle}]
    } elseif {$type == "dce_node_ipv6_group"} {
        set elem_handle [ixia::getNextLabel isisDceNetworkRange DceNodeIpv6Groups           isis ${parent_handle}]
    } elseif {$type == "dce_outside_link"} {
        set elem_handle [ixia::getNextLabel isisDceNetworkRange DceOutsideLinks             isis ${parent_handle}]
    } elseif {$type == "router" || $type == "grid" } {
        set elem_handle [ixia::getNextLabel isisRouter          Grid                        isis ${parent_handle}]
    } else {
        set elem_handle [ixia::getNextLabel isisRouter          RouteRange                  isis ${parent_handle}]
    }
    
    set enable $::true

    ### Setup local variables - these are options in the IxTclHal which are 
    ### not passed into HLTAPI
    switch $type {
        router {
            set local_entry_point_column        1
            set local_entry_point_row           1
            set local_num_columns               1
            set local_num_rows                  1
            set local_wide_metric [isisRouter cget -enableWideMetric] 
            if {$local_wide_metric == $::true} {
                if {[info exists link_wide_metric]} {
                    set local_link_metric $link_wide_metric
                }
            } else {
                if {[info exists link_narrow_metric]} {
                    set local_link_metric $link_narrow_metric
                }
            }
            ### add "0x" if router_system_id does not have it already
            if {[info exists router_system_id]} {
                if {[string first 0x $router_system_id] == -1} {
                    set router_system_id [format "0x%s" $router_system_id]
                }
                set router_system_id [val2Bytes $router_system_id 6]
            }
            if {[info exists link_te_admin_group]} {
                set local_te_admin_group [val2Bytes $link_te_admin_group 4]
            }
        }
        grid {
            set local_entry_point_row      [lindex $grid_connect 0]
            set local_entry_point_column   [lindex $grid_connect 1]
            ### add "0x" if grid_start_system_id does not have it already
            if {[string first 0x $grid_start_system_id] == -1} {
                set grid_start_system_id [format "0x%s" $grid_start_system_id]
            }
            set grid_start_system_id [val2Bytes $grid_start_system_id 6]
            if {[string first 0x $grid_system_id_step] == -1} {
                set grid_system_id_step [format "0x%s" $grid_system_id_step]
            }
            set grid_system_id_step [val2Bytes $grid_system_id_step 6]
            if {[info exists grid_te_admin]} {
                set grid_te_admin [val2Bytes $grid_te_admin 4]
            }
        }
        stub {
           set local_route_origin  stub
        }
        external {
           set local_route_origin  external
        }
        dce_mcast_mac_range {
            set ip_version ""
        }
        dce_mcast_ipv4_group_range {
            set ip_version 4
        }
        dce_mcast_ipv6_group_range {
            set ip_version 6
        }
        dce_network_range {
            set ip_version ""
        }
        dce_node_mac_group {
            set ip_version ""
        }
        dce_node_ipv4_group {
            set ip_version 4
        }
        dce_node_ipv6_group {
            set ip_version 6
        }
        dce_outside_link {
            set ip_version ""
        }
        default {
        }
    }

    ##########################################################################
    ### apply non-IPV4/IPV6 specific HLTAPI options to Ixia's IxTclHal options
    ##########################################################################
    switch $type {
        router -
        grid {
            ### setDefaults ####
            set isisCommandParamLists $isisConfigCommandArray($type)
            foreach commandParam $isisCommandParamLists {
                set command [lindex $commandParam 0]
                debug "$command setDefault"
                $command setDefault
                
                if {$command == "isisGrid"} {
                    debug "$command clearAllInternodeRoutes"
                    $command clearAllInternodeRoutes
                    debug "$command clearAllRoutes"
                    $command clearAllRoutes
                    debug "$command clearAllOutsideLinks"
                    $command clearAllOutsideLinks
                    debug "$command clearAllTePaths"
                    $command clearAllTePaths
                }
                if {$command == "isisGridOutsideLink"} {
                    debug "$command clearAllRoutes"
                    $command clearAllRoutes
                }
            }

            ### Configure the command options for each type of network
            foreach commandParam $isisCommandParamLists {
                set command [lindex $commandParam 0]
                set paramsArray [lindex $commandParam 1]
                
                foreach {item itemName} [array get $paramsArray] {
                     if {![catch {set $itemName} value] } {
                         if {[lsearch [array names isisEnumList] $value] != -1} {
                             set value $isisEnumList($value)
                         }
                         debug "$command config -$item $value"
                         catch {$command config -$item $value}
                    }
                }
            }
            if {$type == "grid" && ($grid_stub_per_router > 0)} {
                debug "isisGrid addRoute"
                if {[isisGrid addRoute]} {
                    puts "ERROR in $procName: isisGrid addRoute command failed.\
                    \n$::ixErrorInfo"                                      
                    return NULL
                }
            }
                     
        }
        dce_mcast_mac_range -
        dce_mcast_ipv4_group_range -
        dce_mcast_ipv6_group_range -
        dce_network_range -
        dce_node_mac_group -
        dce_node_ipv4_group -
        dce_node_ipv6_group -
        dce_outside_link {
            ### setDefaults ####
            set isisCommandParamLists $isisConfigCommandArray($type)
            foreach commandParam $isisCommandParamLists {
                set command [lindex $commandParam 0]
                debug "$command setDefault"
                $command setDefault
            }
            ### Configure the command options for each type of network
            foreach commandParam $isisCommandParamLists {
                set command [lindex $commandParam 0]
                set paramsArray [lindex $commandParam 1]
                
                foreach {item itemName} [array get $paramsArray] {
                     if {![catch {set $itemName} value] } {
                         if {[lsearch [array names isisEnumList] $value] != -1} {
                             set value $isisEnumList($value)
                         }
                         
                         set typeArrayName ${paramsArray}Type
                         array set typeArray [array get $typeArrayName]
                         if {[info exists typeArray($item)] && [set typeArray($item)] == "mac"} {
                            set value [::ixia::convertToIxiaMac $value]
                         }
                         if {[info exists typeArray($item)] && [set typeArray($item)] == "hex"} {
                            set value [::ixia::convertToIxiaMac $value :]
                         }
                         debug "$command config -$item \"$value\""
                         catch {$command config -$item $value}
                    }
                }
            }
        }
        default {
        }
    }

    #####################################################################
    ### apply IPV4/IPV6 related HLTAPI options to Ixia's IxTclHal options
    #####################################################################
    set numIpProtocol [scan $ip_version "%d_%d" ipFirstVer ipNextVer]

    set isisCommandParamLists $isisIpConfigCommandArray($type)
    foreach commandParam $isisCommandParamLists {
        set command [lindex $commandParam 0]
        debug "$command setDefault"
        $command setDefault
    }
    set tmp_elem_handle $elem_handle
    for {set i 0} { $i < $numIpProtocol} {incr i} {
        if {$i == 0} {
            set ipProtocol $ipFirstVer
        } else {
            set ipProtocol $ipNextVer
        }
        switch $type {
            router {
                if {$ipProtocol == 4} {
                    if {[info exists link_ip_prefix_length]} {
                        set local_ip_pfx_len    $link_ip_prefix_length
                    }
                    if {[info exists link_ip_addr]} {
                        set local_ip_start      $link_ip_addr
                    }
                    set local_ip_type       ipv4
                    set local_ip_step       1
                } else {
                    if {[info exists link_ipv6_prefix_length]} {
                        set local_ip_pfx_len    $link_ipv6_prefix_length
                    }
                    if {[info exists link_ipv6_addr]} {
                        set local_ip_start      $link_ipv6_addr
                    }
                    set local_ip_type       ipv6
                    set local_ip_step       1
                }
            }
            grid {
                if {$ipProtocol == 4} {
                    if {[info exists grid_ip_pfx_len]} {
                        set local_ip_pfx_len    $grid_ip_pfx_len
                    }
                    if {[info exists grid_ip_start]} {
                        set local_ip_start      $grid_ip_start
                    }                    
                    set local_ip_step       1
                    set local_ip_type       ipv4
                } else {
                    if {[info exists grid_ipv6_pfx_len]} {
                        set local_ip_pfx_len    $grid_ipv6_pfx_len
                    }
                    if {[info exists grid_ipv6_start]} {
                        set local_ip_start      $grid_ipv6_start
                    }
                    set local_ip_step       1
                    set local_ip_type       ipv6
                }
            }
            stub { 
                set local_ip_route_origin   internal 
                if {$ipProtocol == 4} { 
                    if {[info exists stub_ip_pfx_len]} {
                        set local_stub_ip_pfx_len    $stub_ip_pfx_len
                    }
                    if {[info exists stub_ip_start]} {
                        set local_stub_ip_start      $stub_ip_start
                    }
                    set local_stub_ip_type       ipv4  
                } else {
                    if {[info exists stub_ipv6_pfx_len]} {
                        set local_stub_ip_pfx_len    $stub_ipv6_pfx_len
                    }
                    if {[info exists stub_ipv6_start]} {
                        set local_stub_ip_start      $stub_ipv6_start
                    }
                    
                    set local_stub_ip_type       ipv6  
                }
                if {[info exists stub_route_count]} {
                    set local_stub_route_count   $stub_route_count
                }
                set local_stub_route_origin $::isisRouteInternal               
            }
            external { 
                set local_ip_route_origin   external 
                if {$ipProtocol == 4} { 
                    if {[info exists external_ip_pfx_len]} {
                        set local_ext_ip_pfx_len    $external_ip_pfx_len
                    }
                    if {[info exists external_ip_start]} {
                        set local_ext_ip_start      $external_ip_start
                    }
                    set local_ext_ip_type       ipv4  
                } else {
                    if {[info exists external_ipv6_pfx_len]} {
                        set local_ext_ip_pfx_len    $external_ipv6_pfx_len
                    }
                    if {[info exists external_ipv6_start]} {
                        set local_ext_ip_start      $external_ipv6_start
                    }
                    set local_ext_ip_type       ipv6  
                }
                if {[info exists external_route_count]} {
                    set local_ext_route_count   $external_route_count
                }
                set local_ext_route_origin $::isisRouteExternal                
            }
            default {}
        }
        foreach commandParam $isisCommandParamLists {
            set command [lindex $commandParam 0]
            set paramsArray [lindex $commandParam 1]
            foreach {item itemName} [array get $paramsArray] { 
                if {![catch {set $itemName} value] } {
                     if {[lsearch [array names isisEnumList] $value] != -1} {
                         set value $isisEnumList($value)
                     }
                     debug "$command config -$item $value"
                     catch {$command config -$item $value}
                }
            }
        }         
        switch $type {
            router -
            grid {
                debug "isisGrid addInternodeRoute"
                if {[isisGrid addInternodeRoute]} {
                    puts "ERROR in $procName: isisGrid addInternodeRoute \
                    command failed.\n$::ixErrorInfo"
                    return NULL               
                }
            }
            stub - 
            external {
                set new_elem_handle IPv${ipProtocol}$tmp_elem_handle
                debug "isisRouter addRouteRange $new_elem_handle"
                if {[isisRouter addRouteRange $new_elem_handle]} {
                    puts "ERROR in $procName: isisRouter addRouteRange \
                    command failed.\n$::ixErrorInfo"
                    return NULL
                }
            }
        }
    }

    #### Set the options to IxTclHal objects
    switch $type {
        router {
            if {[info exists router_area_id]} {
                debug "isisRouter config -maxNumberOfAddresses [llength $router_area_id]"
                isisRouter config -maxNumberOfAddresses [llength $router_area_id]
                set area_list [list]
                foreach area_id $router_area_id {
                    set area_id [format "0x%s" $area_id]  
                    set area_id [::ixia::val2Bytes $area_id 4]
                    lappend area_list $area_id
                } 
                set area_list [join $area_list ,]
                debug "isisRouter config -areaAddressList $area_list"
                isisRouter config -areaAddressList $area_list
            }
            debug "isisRouter addGrid $elem_handle"
            if {[isisRouter addGrid $elem_handle]} {
                puts "ERROR in $procName: isisRouter addGrid command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        grid {
            debug "isisRouter addGrid $elem_handle"
            if {[isisRouter addGrid $elem_handle]} {
                puts "ERROR in $procName: isisRouter addGrid command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_mcast_mac_range {
            debug "isisRouter addMulticastMacRange $elem_handle"
            if {[isisRouter addMulticastMacRange $elem_handle]} {
                puts "ERROR in $procName: isisRouter addMulticastMacRange $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_mcast_ipv4_group_range {
            debug "isisRouter addMulticastIpv4GroupRange $elem_handle"
            if {[isisRouter addMulticastIpv4GroupRange $elem_handle]} {
                puts "ERROR in $procName: isisRouter addMulticastIpv4GroupRange $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_mcast_ipv6_group_range {
            debug "isisRouter addMulticastIpv6GroupRange $elem_handle"
            if {[isisRouter addMulticastIpv6GroupRange $elem_handle]} {
                puts "ERROR in $procName: isisRouter addMulticastIpv6GroupRange $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_network_range {
            debug "isisRouter addDceNetworkRange $elem_handle"
            if {[isisRouter addDceNetworkRange $elem_handle]} {
                puts "ERROR in $procName: isisRouter addDceNetworkRange $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_node_mac_group {
            debug "isisDceNetworkRange addDceNodeMacGroups $elem_handle"
            if {[isisDceNetworkRange addDceNodeMacGroups $elem_handle]} {
                puts "ERROR in $procName: isisDceNetworkRange addDceNodeMacGroups $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_node_ipv4_group {
            debug "isisDceNetworkRange addDceNodeIpv4Groups $elem_handle"
            if {[isisDceNetworkRange addDceNodeIpv4Groups $elem_handle]} {
                puts "ERROR in $procName: isisDceNetworkRange addDceNodeIpv4Groups $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_node_ipv6_group {
            debug "isisDceNetworkRange addDceNodeIpv6Groups $elem_handle"
            if {[isisDceNetworkRange addDceNodeIpv6Groups $elem_handle]} {
                puts "ERROR in $procName: isisDceNetworkRange addDceNodeIpv6Groups $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_outside_link {
            debug "isisDceNetworkRange addDceOutsideLinks $elem_handle"
            if {[isisDceNetworkRange addDceOutsideLinks $elem_handle]} {
                puts "ERROR in $procName: isisDceNetworkRange addDceOutsideLinks $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        default {
        }
    }
    switch $type {
        router -
        grid -
        external -
        stub -
        dce_mcast_mac_range -
        dce_mcast_ipv4_group_range -
        dce_mcast_ipv6_group_range -
        dce_network_range {
            debug "isisServer setRouter $parent_handle"
            if {[isisServer setRouter $parent_handle]} {
               puts "ERROR in $procName: isisServer setRouter $parent_handle command failed.\
                           \n$::ixErrorInfo"                  
               return NULL
            }
        }
        dce_node_mac_group -
        dce_node_ipv4_group -
        dce_node_ipv6_group -
        dce_outside_link {
           debug "isisRouter setDceNetworkRange $parent_handle"
            if {[isisRouter setDceNetworkRange $parent_handle]} {
               puts "ERROR in $procName: isisRouter setDceNetworkRange $parent_handle command failed.\
                           \n$::ixErrorInfo"                  
               return NULL
            }
            debug "isisServer setRouter $router_handle"
            if {[isisServer setRouter $router_handle]} {
               puts "ERROR in $procName: isisServer setRouter $router_handle command failed.\
                           \n$::ixErrorInfo"                  
               return NULL
            }
        }
        default {
        }
    }
    
    #### clean up the internode config in grid
    debug "isisGrid clearAllInternodeRoutes"
    if {[isisGrid clearAllInternodeRoutes]} {
       puts "ERROR in $procName: isisGrid clearAllInternodeRoutes command\
                    failed.\n$::ixErrorInfo"                  
       return NULL
    }
    
    if {[updateIsisTopologyHandleArray create $parent_handle $elem_handle $type $ip_version]} {
       puts "ERROR in $procName: failed to add the $elem_handle to isisHandleArray."                  
       return NULL
    }
    return $elem_handle
}



##Internal Procedure Header
# Name:
#    ::ixia::modifyIsisRouteObject
# Description:
#    Modify the topology element    
#
# Synopsis:
#
# Arguments:    
#    args  -  options passed in from emulation_topology_route_config. These  
#             options specify the parameters to be modified in the route 
#             topology. 
#
# Return Values:    
#    elem_handle - the topology element handle is returned
#    NULL        - returns NULL if there's error
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
proc ::ixia::modifyIsisRouteObject {args} {

    variable isisConfigCommandArray
    variable isisIpConfigCommandArray
    variable routerGridOptionsArray
    variable routerRangeTeOptionsArray
    variable gridOptionsArray
    variable gridRouteOptionsArray
    variable gridRangeTeOptionsArray
    variable stubRouteRangeOptionsArray
    variable externalRouteRangeOptionsArray
    variable gridInternodeRouterOptionsArray
    variable stubRouteRangeOptionsArray
    variable externalRouteRangeOptionsArray
    variable dceMcastMacRangeOptionsArray
    variable dceMcastMacRangeOptionsArrayType
    variable dceMcastIpV4GrpRangeOptionsArray
    variable dceMcastIpV6GrpRangeOptionsArray
    variable dceNetworkRangeOptionsArray
    variable dceNetworkRangeOptionsArrayType
    variable dceNodeMacGroupOptionsArray
    variable dceNodeMacGroupOptionsArrayType
    variable dceNodeIpv4GroupOptionsArray
    variable dceNodeIpv6GroupOptionsArray
    variable dceOutsideLinkOptionsArray
    variable dceOutsideLinkOptionsArrayType
    variable isisEnumList

    set procName [lindex [info level [info level]] 0]
  
    ### upvar all the command options
    set args [join $args]
    foreach item $args {
        if {[string first - $item] == 0} {
            set option [string trimleft $item -]
            upvar $option $option
        }
    }

    ### figure out the type of element from the elem_handle
    set retCode [getIsisElemInfoFromHandle $handle $elem_handle type]
    if {[keylget retCode status] == $::FAILURE} {
        return $retCode
    }
    set type [keylget retCode value]
    
    set retCode [getIsisElemInfoFromHandle $handle $elem_handle ip_version]
    if {[keylget retCode status] == $::FAILURE} {
        return $retCode
    }
    set ip_version [keylget retCode value]

    set enable $::true
    
    if {$type == "dce_mcast_mac_range" || \
            $type == "dce_mcast_ipv4_group_range" || \
            $type == "dce_mcast_ipv6_group_range" || \
            $type == "dce_node_mac_group" || \
            $type == "dce_node_ipv4_group" || \
            $type == "dce_node_ipv6_group"} {
        
        set dce_param_list {
            dce_mcast_start_addr       {
                0100.0000.0000   224.0.0.0   FF03:0::0
                0100.0000.0000   224.0.0.0   FF03:0::0  
            }
            dce_mcast_addr_step        {
                0000.0000.0001   0.0.0.1     0::1
                0000.0000.0001   0.0.0.1     0::1       
            }
            dce_ucast_src_addr         {
                0000.0000.0000   0.0.0.0     0::0
                0000.0000.0000   0.0.0.0     0::0       
            }
            dce_intra_grp_ucast_step   {
                0000.0000.0001   0.0.0.1     0::1
                0000.0000.0001   0.0.0.1     0::1       
            }
            dce_inter_grp_ucast_step   {
                0000.0000.0000   0.0.0.0     0::0
                0000.0000.0000   0.0.0.0     0::0       
            }
            dce_mcast_addr_node_step   {
                {}               {}          {}
                0000.0000.0100   0.0.1.0     0::10
            }
            dce_ucast_addr_node_step   {
                {}               {}          {}
                0000.0000.0100   0.0.1.0     0::10
            }
        }
        foreach {dce_param  dce_default_values} $dce_param_list {
            switch --$type {
                dce_mcast_mac_range {
                    if {[info exists $dce_param]} {
                        if {![::ixia::isValidMacAddress [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with a MAC value."                                      
                            return NULL
                        }
                    }
                }
                dce_mcast_ipv4_group_range {
                    if {[info exists $dce_param]} {
                        if {[isIpAddressValid [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with an IPv4 value."                                      
                            return NULL
                        }
                    }
                }
                dce_mcast_ipv6_group_range {
                    if {[info exists $dce_param]} {
                        if {[::ipv6::isValidAddress [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with an IPv6 value."                                      
                            return NULL
                        }
                    }
                }
                dce_node_mac_group {
                    if {[info exists $dce_param]} {
                        if {![::ixia::isValidMacAddress [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with a MAC value."                                      
                            return NULL
                        }
                    }
                }
                dce_node_ipv4_group {
                    if {[info exists $dce_param]} {
                        if {[isIpAddressValid [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with an IPv4 value."                                      
                            return NULL
                        }
                    }
                }
                dce_node_ipv6_group {
                    if {[info exists $dce_param]} {
                        if {[::ipv6::isValidAddress [set $dce_param]] == 1} {
                            puts "ERROR in $procName: Invalid value for\
                                    parameter -$dce_param. It should be\
                                    provided with an IPv6 value."                                      
                            return NULL
                        }
                    }
                }
            } 
        }
    }

    ### Setup local variables - these are options in the IxTclHal which are 
    ### not passed into HLTAPI
    set addIpV4Internode $::false
    set addIpV6Internode $::false
    switch $type {
        router {
            debug "isisRouter getGrid $elem_handle"
            if {[isisRouter getGrid $elem_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisRouter getGrid $elem_handle\
                        command failed.\n$::ixErrorInfo"
                return $returnList
            }

            #### If link_ip_addr and link_ipv6_addr are present, the 
            #### isisInternode routes need to be deleted, then recreate it
            #### later.
            if {[info exists link_ip_addr] ||\
                [info exists link_ip_prefix_length] } {
                delIsisInternodeRoute $::addressTypeIpV4
                set addIpV4Internode $::true
                debug "isisGridInternodeRoute setDefault"
                isisGridInternodeRoute setDefault
            }
            if {[info exists link_ipv6_addr] ||\
                [info exists link_ipv6_prefix_length] } {
                delIsisInternodeRoute $::addressTypeIpV6
                set addIpV6Internode $::true
                debug "isisGridInternodeRoute setDefault"
                isisGridInternodeRoute setDefault
            }

            set local_entry_point_column        1
            set local_entry_point_row           1
            set local_num_columns               1
            set local_num_rows                  1
            set local_wide_metric [isisRouter cget -enableWideMetric]
            if {$local_wide_metric == $::true} {
                if {[info exists link_wide_metric]} {
                    set local_link_metric $link_wide_metric
                }
            } else {
                if {[info exists link_narrow_metric]} {
                    set local_link_metric $link_narrow_metric
                }
            }
            ### add "0x" if router_system_id does not have it already
            if {[info exists router_system_id]} {
                if {[string first 0x $router_system_id] == -1} {
                    set router_system_id [format "0x%s" $router_system_id]
                }
                set router_system_id [val2Bytes $router_system_id 6]
            }
            if {[info exists link_te_admin_group]} {
                set local_te_admin_group [val2Bytes $link_te_admin_group 4]
            }
        }
        grid {
            debug "isisRouter getGrid $elem_handle"
            if {[isisRouter getGrid $elem_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisRouter getGrid $elem_handle\
                        command failed.\n$::ixErrorInfo"
                return $returnList
            }
            #### delete the node routes, then recreate it later
            if {[info exists grid_stub_per_router] ||\
                [info exists grid_router_id] ||\
                [info exists grid_router_id_step]} {
                debug "isisGrid getFirstRoute"
                if {[isisGrid getFirstRoute] == $::TCL_OK} {
                    if {[isisGrid delRoute]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "sisGrid delRoute command failed.\
                                \n$::ixErrorInfo"
                        return $returnList
                    }
                    debug "isisGridRoute setDefault"
                    isisGridRoute setDefault
                }
            }

            #### If grid_ip_start and grid_ipv6_start are present, the 
            #### isisInternode routes need to be deleted, then recreate it
            #### later.
            if {[info exists grid_ip_start] ||\
                [info exists grid_ip_pfx_len] ||\
                [info exists grid_ip_step]} {
                delIsisInternodeRoute $::addressTypeIpV4
                set addIpV4Internode $::true
                debug "isisGridInternodeRoute setDefault"
                isisGridInternodeRoute setDefault
            }
            if {[info exists grid_ipv6_start] ||\
                [info exists grid_ipv6_pfx_len] ||\
                [info exists grid_ipv6_step]} {           
                delIsisInternodeRoute $::addressTypeIpV6
                set addIpV6Internode $::true
                debug "isisGridInternodeRoute setDefault"
                isisGridInternodeRoute setDefault
            }
            if {[info exists grid_connect]} {
                set local_entry_point_row       [lindex $grid_connect 0]
                set local_entry_point_column   [lindex $grid_connect 1]
            }
            ### add "0x" if grid_start_system_id does not have it already
            if {[info exists grid_start_system_id]} {
                if {[string first 0x $grid_start_system_id] == -1} {
                    set grid_start_system_id [format "0x%s" $grid_start_system_id]
                }
                set grid_start_system_id [val2Bytes $grid_start_system_id 6]
            }
            if {[info exists grid_system_id_step]} {
                if {[string first 0x $grid_system_id_step] == -1} {
                    set grid_system_id_step [format "0x%s" $grid_system_id_step]
                }
                set grid_system_id_step [val2Bytes $grid_system_id_step 6]
            }
            if {[info exists grid_te_admin]} {
                set grid_te_admin [val2Bytes $grid_te_admin 4]
            }
        }
        default {
        }
    }

    ##########################################################################
    ### apply non-IPV4/IPV6 specific HLTAPI options to Ixia's IxTclHal options
    ##########################################################################
    switch $type {
        router -
        grid -
        dce_mcast_mac_range -
        dce_mcast_ipv4_group_range -
        dce_mcast_group_ipv6_range -
        dce_network_range -
        dce_node_mac_group -
        dce_node_ipv4_group -
        dce_node_group_ipv6 - 
        dce_outside_link {
            ### setDefaults ####
            set isisCommandParamLists $isisConfigCommandArray($type)

            ### Configure the command options for each type of network
            foreach commandParam $isisCommandParamLists {
                set command [lindex $commandParam 0]
                set paramsArray [lindex $commandParam 1]
                
                foreach {item itemName} [array get $paramsArray] {
                     if {![catch {set $itemName} value] } {
                         if {[lsearch [array names isisEnumList] $value] != -1} {
                             set value $isisEnumList($value)
                         }
                         
                         set typeArrayName ${paramsArray}Type
                         array set typeArray [array get $typeArrayName]
                         if {[info exists typeArray($item)] && [set typeArray($item)] == "mac"} {
                            set value [::ixia::convertToIxiaMac $value]
                         }
                         debug "$command config -$item \"$value\""
                         catch {$command config -$item "$value"}
                    }
                }
            }
            if {$type == "grid" && [info exists grid_stub_per_router]} {
                debug "isisGrid addRoute"
                if {[isisGrid addRoute]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "isisGrid addRoute command failed.\
                            \n$::ixErrorInfo"
                    return $returnList
                }
             }
                     
        }
        default {
        }
    }

    #####################################################################
    ### apply IPV4/IPV6 related HLTAPI options to Ixia's IxTclHal options
    #####################################################################
    set numIpProtocol [scan $ip_version "%d_%d" ipFirstVer ipNextVer]

    set isisCommandParamLists $isisIpConfigCommandArray($type)
    set tmp_elem_handle $elem_handle
    for {set i 0} { $i < $numIpProtocol} {incr i} {
        if {$i == 0} {
            set ipProtocol $ipFirstVer
        } else {
            set ipProtocol $ipNextVer
        }
        switch $type {
            router {
                if {($ipProtocol == 4) && $addIpV4Internode} {
                    if {[info exists link_ip_prefix_length]} {
                        set local_ip_pfx_len    $link_ip_prefix_length
                    }
                    if {[info exists link_ip_addr]} {
                        set local_ip_start      $link_ip_addr
                    }
                    set local_ip_type       ipv4
                    set local_ip_step       1
                } elseif {($ipProtocol == 6) && $addIpV6Internode} {
                    if {[info exists link_ipv6_prefix_length]} {
                        set local_ip_pfx_len    $link_ipv6_prefix_length
                    }
                    if {[info exists link_ipv6_addr]} {
                        set local_ip_start      $link_ipv6_addr
                    }
                    set local_ip_type       ipv6
                    set local_ip_step       1
                }
            }
            grid {
                if {($ipProtocol == 4) && $addIpV4Internode} { 
                    if {[info exists grid_ip_pfx_len]} {
                        set local_ip_pfx_len    $grid_ip_pfx_len
                    }
                    if {[info exists grid_ip_start]} {
                        set local_ip_start      $grid_ip_start
                    }                    
                    set local_ip_step       1
                    set local_ip_type       ipv4
                } elseif {($ipProtocol == 6) && $addIpV6Internode} {
                    if {[info exists grid_ipv6_pfx_len]} {
                        set local_ip_pfx_len    $grid_ipv6_pfx_len
                    }
                    if {[info exists grid_ipv6_start]} {
                        set local_ip_start      $grid_ipv6_start
                    }
                    set local_ip_step       1
                    set local_ip_type       ipv6
                }
            }
            stub {
                debug "isisRouter getRouteRange IPv${ipProtocol}$elem_handle"
                if {[isisRouter getRouteRange IPv${ipProtocol}$elem_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "isisRouter getRouteRange\
                            command failed.\
                            \n$::ixErrorInfo"
                    return $returnList
                }
                set local_route_origin  stub
 
                set local_ip_route_origin   internal 
                if {$ipProtocol == 4} { 
                    if {[info exists stub_ip_pfx_len]} {
                        set local_stub_ip_pfx_len $stub_ip_pfx_len
                    }
                    if {[info exists stub_ip_start]} {
                        set local_stub_ip_start $stub_ip_start
                    }
                    set   local_stub_ip_type    ipv4
                } else {
                    if {[info exists stub_ipv6_pfx_len]} {
                        set local_stub_ipv6_pfx_len $stub_ipv6_pfx_len
                    }
                    if {[info exists stub_ip_start]} {
                        set local_stub_ipv6_start $stub_ipv6_start
                    }
                    set local_stub_ip_type       ipv6  
                }
                set local_stub_route_origin $::isisRouteInternal               
            }
            external {
                debug "isisRouter getRouteRange IPv${ipProtocol}$elem_handle"
                if {[isisRouter getRouteRange IPv${ipProtocol}$elem_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "isisRouter getRouteRange\
                            $elem_handle command failed.\
                            \n$::ixErrorInfo"
                    return $returnList
                }
                set local_route_origin  external

                set local_ip_route_origin   external 
                if {$ipProtocol == 4} {  
                    if {[info exists external_ip_pfx_len]} {
                        set local_ext_ip_pfx_len $external_ip_pfx_len
                    }
                    if {[info exists external_ip_start]} {
                        set local_ext_ip_start $external_ip_start
                    }
                    set local_ext_ip_type       ipv4  
                } else {
                    if {[info exists external_ipv6_pfx_len]} {
                        set local_ext_ip_pfx_len $external_ipv6_pfx_len
                    }
                    if {[info exists external_ipv6_start]} {
                        set local_ext_ip_start $external_ipv6_start
                    }
                    set local_ext_ip_type       ipv6
                }
                set local_ext_route_origin $::isisRouteExternal   
            }
            default {}
        }
        foreach commandParam $isisCommandParamLists {
            set command [lindex $commandParam 0]
            set paramsArray [lindex $commandParam 1]
            foreach {item itemName} [array get $paramsArray] { 
                if {![catch {set $itemName} value] } {
                     if {[lsearch [array names isisEnumList] $value] != -1} {
                         set value $isisEnumList($value)
                     }
                     debug "$command config -$item $value"
                     catch {$command config -$item $value}
                }
            }
        }         
        switch $type {
            router -
            grid {
                if {($addIpV6Internode && ($ipProtocol == 6)) || \
                        ($addIpV4Internode && ($ipProtocol == 4))} {
                    debug "isisGrid addInternodeRoute"
                    if {[isisGrid addInternodeRoute]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "isisGrid addInternodeRoute \
                                command failed.\n$::ixErrorInfo"
                        return $returnList
                    }
                }
            }
            stub - 
            external {
                debug "isisRouter setRouteRange IPv${ipProtocol}$elem_handle"
                if {[isisRouter setRouteRange IPv${ipProtocol}$elem_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "isisRouter setRouteRange \
                            command failed.\n$::ixErrorInfo"
                    return $returnList
                }
            }
        }
    }

    #### Set the options to IxTclHal objects
    switch $type {
        router -
        grid {
            debug "isisRouter setGrid $elem_handle"
            if {[isisRouter setGrid $elem_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisRouter addGrid command failed.\
                        \n$::ixErrorInfo"
                return $returnList
            }
            #### clean up the internode config in grid
            debug "isisGrid clearAllInternodeRoutes"
            if {[isisGrid clearAllInternodeRoutes]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisGrid clearAllInternodeRoutes\
                        command failed.\n$::ixErrorInfo"
                return $returnList
            }

        }
        dce_mcast_mac_range {
            debug "isisRouter setMulticastMacRange $elem_handle"
            if {[isisRouter setMulticastMacRange $elem_handle]} {
                puts "ERROR in $procName: isisRouter setMulticastMacRange $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_mcast_ipv4_group_range {
            debug "isisRouter setMulticastIpv4GroupRange $elem_handle"
            if {[isisRouter setMulticastIpv4GroupRange $elem_handle]} {
                puts "ERROR in $procName: isisRouter setMulticastIpv4GroupRange $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_mcast_ipv4_group_range {
            debug "isisRouter setMulticastIpv6GroupRange $elem_handle"
            if {[isisRouter setMulticastIpv6GroupRange $elem_handle]} {
                puts "ERROR in $procName: isisRouter setMulticastIpv6GroupRange $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_network_range {
            debug "isisRouter setDceNetworkRange $elem_handle"
            if {[isisRouter setDceNetworkRange $elem_handle]} {
                puts "ERROR in $procName: isisRouter setDceNetworkRange $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_node_mac_range {
            debug "isisDceNetworkRange setDceNodeMacGroups $elem_handle"
            if {[isisDceNetworkRange setDceNodeMacGroups $elem_handle]} {
                puts "ERROR in $procName: isisDceNetworkRange setDceNodeMacGroups $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_node_ipv4_group_range {
            debug "isisDceNetworkRange setDceNodeIpv4Groups $elem_handle"
            if {[isisDceNetworkRange setDceNodeIpv4Groups $elem_handle]} {
                puts "ERROR in $procName: isisDceNetworkRange setDceNodeIpv4Groups $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_node_ipv4_group_range {
            debug "isisDceNetworkRange setDceNodeIpv6Groups $elem_handle"
            if {[isisDceNetworkRange setDceNodeIpv6Groups $elem_handle]} {
                puts "ERROR in $procName: isisDceNetworkRange setDceNodeIpv6Groups $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        default {
        }
    }
    keylset returnList status $::SUCCESS
    keylset returnList elem_handle $elem_handle
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::deleteIsisRouteObject
# Description:
#
# Synopsis:
#
# Arguments:    
#    handle      - session_handle
#    elem_handle - the topology element handle is returned
#
# Return Values:  
#    elem_handle - elem_handle is returned if the route object
#                  pointed by elem_handle is deleted successfully.
#    NULL        - returns NULL if there's error.
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
proc ::ixia::deleteIsisRouteObject {handle elem_handle} {

    set procName [lindex [info level [info level]] 0]       

    ### figure out the type of element from the elem_handle
    set retCode [getIsisElemInfoFromHandle $handle $elem_handle type]
    if {[keylget retCode status] == $::FAILURE} {
        return $retCode
    }
    set type [keylget retCode value]
    
    set retCode [getIsisElemInfoFromHandle $handle $elem_handle ip_version]
    if {[keylget retCode status] == $::FAILURE} {
        return $retCode
    }
    set ip_version [keylget retCode value]

    switch $type {
        router -
        grid {
            debug "isisRouter delGrid $elem_handle"
            if {[isisRouter delGrid $elem_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisRouter delGrid $elem_handle\
                        command failed.\n$::ixErrorInfo"
                return $returnList
            }
        }
        stub - 
        external {
            set numIpProtocol [scan $ip_version "%d_%d" ipFirstVer ipNextVer]
            for {set i 0} { $i < $numIpProtocol} {incr i} {
                if {$i == 0} {
                    set ipProtocol $ipFirstVer
                } else {
                    set ipProtocol $ipNextVer
                }
                debug "isisRouter delRouteRange IPv${ipProtocol}$elem_handle"
                if {[isisRouter delRouteRange IPv${ipProtocol}$elem_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "isisRouter delRouteRange\
                            IPv${ipProtocol}$elem_handle command failed.\
                            \n$::ixErrorInfo"
                    return $returnList
                }
            }
        }
        dce_network_range {
            debug "isisRouter delDceNetworkRange $elem_handle"
           if {[isisRouter delDceNetworkRange $elem_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisRouter delDceNetworkRange $elem_handle\
                        command failed.\n$::ixErrorInfo"
                return $returnList
            }
        }
        dce_mcast_mac_range {
            debug "isisRouter delMulticastMacRange $elem_handle"
           if {[isisRouter delMulticastMacRange $elem_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisRouter delMulticastMacRange $elem_handle\
                        command failed.\n$::ixErrorInfo"
                return $returnList
            }
        }
        dce_mcast_ipv4_group_range {
            debug "isisRouter delMulticastIpv4GroupRange $elem_handle"
            if {[isisRouter delMulticastIpv4GroupRange $elem_handle]} {
                puts "ERROR in $procName: isisRouter delMulticastIpv4GroupRange $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_mcast_ipv6_group_range {
            debug "isisRouter delMulticastIpv6GroupRange $elem_handle"
            if {[isisRouter delMulticastIpv6GroupRange $elem_handle]} {
                puts "ERROR in $procName: isisRouter delMulticastIpv6GroupRange $elem_handle command failed.\
                \n$::ixErrorInfo"                                      
                return NULL               
            }
        }
        dce_node_mac_group {
            debug "isisDceNetworkRange delDceNodeMacGroup $elem_handle"
           if {[isisDceNetworkRange delDceNodeMacGroup $elem_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisDceNetworkRange delDceNodeMacGroup $elem_handle\
                        command failed.\n$::ixErrorInfo"
                return $returnList
            }
        }
        dce_node_ipv4_group {
            debug "isisDceNetworkRange delDceNodeIpv4Group $elem_handle"
           if {[isisDceNetworkRange delDceNodeIpv4Group $elem_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisDceNetworkRange delDceNodeIpv4Group $elem_handle\
                        command failed.\n$::ixErrorInfo"
                return $returnList
            }
        }
        dce_node_ipv6_group {
            debug "isisDceNetworkRange delDceNodeIpv6Group $elem_handle"
           if {[isisDceNetworkRange delDceNodeIpv6Group $elem_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisDceNetworkRange delDceNodeIpv6Group $elem_handle\
                        command failed.\n$::ixErrorInfo"
                return $returnList
            }
        }
        dce_outside_link {
            debug "isisDceNetworkRange delDceOutsideLink $elem_handle"
           if {[isisDceNetworkRange delDceOutsideLink $elem_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisDceNetworkRange delDceOutsideLink $elem_handle\
                        command failed.\n$::ixErrorInfo"
                return $returnList
            }
        }
    }
    switch $type {
        router -
        grid -
        stub - 
        external -
        dce_network_range -
        dce_mcast_mac_range -
        dce_mcast_ipv4_group_range -
        dce_mcast_ipv6_group_range {
            debug "isisServer setRouter $handle"
            if {[isisServer setRouter $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisServer setRouter $handle command failed.\
                        \n$::ixErrorInfo"
                return $returnList
            }
        }
        dce_node_mac_group -
        dce_node_ipv4_group -
        dce_node_ipv6_group -
        dce_outside_link {
            debug "isisRouter setDceNetworkRange $handle"
            if {[isisRouter setDceNetworkRange $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "isisRouter setDceNetworkRange $handle command failed.\
                        \n$::ixErrorInfo"
                return $returnList
            }
        }
    }
    
    updateIsisTopologyHandleArray delete $handle $elem_handle
    keylset returnList status $::SUCCESS
    keylset returnList elem_handle $elem_handle
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::delIsisInternodeRoute 
# Description:
#    Deletes the first internodeRoute found in the isisGrid that matches
#    ipType.
#
# Synopsis:
#
# Arguments:
#   ipType - ip type of isis internodeRoute.  Choices are:
#      addressTypeIpV4, addressTypeIpV6     
#
# Return Values:    
#   $::TCL_ERROR for failure
#   $::TCL_OK for success
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
proc ::ixia::delIsisInternodeRoute {ipType} {

    set found $::false
    set procName [lindex [info level [info level]] 0]       

    #### When the firstInternode is deleted, the 2nd node becomes
    #### the first internode.
    debug "isisGrid getFirstInternodeRoute"
    while {($found == $::false)  && \
           [isisGrid getFirstInternodeRoute] == $::TCL_OK} {
        debug "isisGridInternodeRoute cget -ipType"
        if {[isisGridInternodeRoute cget -ipType] == $ipType} {
            set found  $::true
            
            debug "isisGrid delInternodeRoute"
            if {[isisGrid delInternodeRoute]} {
               puts "ERROR in $procName: isisGrid delInternodeRoute\
                     command failed.\n$::ixErrorInfo"
               return $::TCL_ERROR
            }
        }
        debug "isisGrid getFirstInternodeRoute"
    }
    return $::TCL_OK
}



##Internal Procedure Header
# Name:
#    ::ixia::cleanup_isis_topology_route_arrays
# Description:
#    Creates new topology element to the session_handle.  This is done by
#    configuring and adding isisRouteRange or isisGrid objects to isisRouter. 
#
# Synopsis:
#
# Arguments:    
#    handle -       session_handle
#    port_handle -  specifies the chassis/card/port        
#    args  -        options passed in from emulation_isis_config.  These 
#                   options are used to set the IxTclHal's command options 
#
# Return Values:    
#    elem_handle - the topology element handle is returned
#    NULL        - returns NULL if there's error
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
proc ::ixia::cleanup_isis_topology_route_arrays {} {

    variable isisConfigCommandArray
    variable isisIpConfigCommandArray
    variable routerGridOptionsArray
    variable routerRangeTeOptionsArray
    variable gridOptionsArray
    variable gridRouteOptionsArray
    variable gridRangeTeOptionsArray
    variable stubRouteRangeOptionsArray
    variable externalRouteRangeOptionsArray
    variable gridInternodeRouterOptionsArray
    variable stubRouteRangeOptionsArray
    variable externalRouteRangeOptionsArray
    variable dceMcastMacRangeOptionsArray
    variable dceMcastMacRangeOptionsArrayType
    variable dceMcastIpV4GrpRangeOptionsArray
    variable dceMcastIpV6GrpRangeOptionsArray
    variable dceNetworkRangeOptionsArray
    variable dceNetworkRangeOptionsArrayType
    variable dceNodeMacGroupOptionsArray
    variable dceNodeMacGroupOptionsArrayType
    variable dceNodeIpv4GroupOptionsArray
    variable dceNodeIpv6GroupOptionsArray
    variable dceOutsideLinkOptionsArray
    variable dceOutsideLinkOptionsArrayType
    variable isisEnumList

    catch {unset isisConfigCommandArray}
    catch {unset isisIpConfigCommandArray}
    catch {unset routerGridOptionsArray}
    catch {unset routerRangeTeOptionsArray}
    catch {unset gridOptionsArray}
    catch {unset gridRouteOptionsArray}
    catch {unset gridRangeTeOptionsArray}
    catch {unset stubRouteRangeOptionsArray}
    catch {unset externalRouteRangeOptionsArray}
    catch {unset gridInternodeRouterOptionsArray}
    catch {unset stubRouteRangeOptionsArray}
    catch {unset externalRouteRangeOptionsArray}
    catch {unset dceMcastMacRangeOptionsArray}
    catch {unset dceMcastMacRangeOptionsArrayType}
    catch {unset dceMcastIpV4GrpRangeOptionsArray}
    catch {unset dceMcastIpV6GrpRangeOptionsArray}
    catch {unset dceNetworkRangeOptionsArray}
    catch {unset dceNetworkRangeOptionsArrayType}
    catch {unset dceNodeMacGroupOptionsArray}
    catch {unset dceNodeMacGroupOptionsArrayType}
    catch {unset dceNodeIpv4GroupOptionsArray}
    catch {unset dceNodeIpv6GroupOptionsArray}
    catch {unset dceOutsideLinkOptionsArray}
    catch {unset dceOutsideLinkOptionsArrayType}
    catch {unset isisEnumList}
}


