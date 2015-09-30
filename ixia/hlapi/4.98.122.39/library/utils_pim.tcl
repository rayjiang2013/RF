##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_pim.tcl
#
# Purpose:
#     A script development library containing utility procs for pim APIs 
#     for test automation with the Ixia chassis.    
#
# Author:
#    T. Kong
#
# Usage:
#
# Description:
#
# Requirements:
#
# Variables:
#    To be added
#
# Keywords:
#    To be define
#
# Category:
#    To be define
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
#    ::ixia::initializePimsm
#
# Description:
#    This command initializes the pimsm to its initial default configuration.
#
# Synopsis:
#
# Arguments:
#    chasNum - chassis ID
#    cardNum - load module number
#    portNum - port number
#
# Return Values:
#    0 - no error found
#    1 - error found
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
proc ::ixia::initializePimsm {chasNum cardNum portNum} \
{
    set retCode $::TCL_OK

    if {[pimsmServer select $chasNum $cardNum $portNum]} {
        set retCode $::TCL_ERROR
    }
    
    if {[pimsmServer clearAllRouters]} {
        set retCode $::TCL_ERROR
    }
    
    if {[pimsmServer set]} {
        set retCode $::TCL_ERROR
    }
    
    return $retCode
}


##Internal Procedure Header
# Name:
#    ::ixia::getAllPimsmInterfaceHandles
#
# Description:
#    This command retrieves all interface handles for a router from
#    ::ixia::pimsm_handles_array.
#
# Synopsis:
#    ::ixia::getAllPimsmInterfaceHandles
#        port_handle
#        router_handle
#
# Arguments:
#    port_handle   - The port where the interfaces should be retrieved.
#    router_handle - A PIM router handle.
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE.
#    key:handles       value:A list of interface handles for the specified router.
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
proc ::ixia::getAllPimsmInterfaceHandles {port_handle {router_handle ""}} {
    variable pimsm_handles_array
    
    set interface_handles ""
    set interface_list [array names pimsm_handles_array ${port_handle}*,interface]
    if {$router_handle == ""} {
        if {[catch {regsub -all {(.+?),interface} $interface_list {\1} \
                interface_handles} parseError]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed in ::ixia::getAllPimsmInterfaceHandles: \
                    $parseError"
            return $returnList
        }
    } else  {
        foreach {interface_index} $interface_list {
            if {[keylget pimsm_handles_array($interface_index) value] == \
                        $router_handle} {
                lappend interface_handles [lindex [split $interface_index ,] 0]
            }
        }
    }
    
    keylset returnList status  $::SUCCESS
    keylset returnList handles $interface_handles
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::getAllPimsmRouterHandles
#
# Description:
#    This command retrieves all router handles for a port from
#    ::ixia::pimsm_handles_array.
#
# Synopsis:
#    ::ixia::getAllPimsmRouterHandles
#        port_handle
#        router_handle
#
# Arguments:
#    port_handle   - The port where the router handles should be retrieved.
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE.
#    key:handles       value:A list of router handles for the specified port.
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
proc ::ixia::getAllPimsmRouterHandles {port_handle} {
    variable pimsm_handles_array
    
    set router_handles ""
    set router_list [array names pimsm_handles_array ${port_handle}*,session]
    if {[catch {regsub -all {(.+?),session} $router_list {\1} \
            router_handles} parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed in ::ixia::getAllPimsmRouterHandles: \
                $parseError"
        return $returnList
    }
    
    keylset returnList status  $::SUCCESS
    keylset returnList handles $router_handles
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::updatePimsmHandleArray
#
# Description:
#    This command creates or deletes an element in ::ixia::pimsm_handles_array.
#
# Synopsis:
#    ::ixia::updatePimsmHandleArray
#        [-mode           CHOICES create delete reset
#                         DEFAULT create]
#        [-handle_name    REGEXP
#        ^[0-9]+/[0-9]+/[0-9]+pimsm(Router|Interface|Source|JoinPrune|CRPRange)[0-9]+$ ]
#        [-handle_type    CHOICES session interface source joinprune crp]
#        [-handle_value]
#        [-handle_name_pattern]
#
# Arguments:
#    -mode - The action that needs to be completed.
#    -handle_name
#        It refers to the name of the element on hardware.
#        Mandatory for mode create or delete.
#    -handle_type
#        Specifies if the element is: session, interface, source, joinprune or crp
#        Mandatory for mode create.
#    -handle_value
#        Specifies the value that needs to be added in the array, corresponding 
#        to a specific handle_name and handle_type.
#        Mandatory for mode create.
#    -handle_name_pattern
#        Deletes all the elements in the array that match that pattern name.
#        Mandatory for mode reset.
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
proc ::ixia::updatePimsmHandleArray {args} {
    variable  pimsm_handles_array
    
    set opt_args {
        -mode           CHOICES create delete reset
                        DEFAULT create
        -handle_name    REGEXP  ^[0-9]+/[0-9]+/[0-9]+pimsm(Router|Interface|Source|JoinPrune|CRPRange)[0-9]+$
        -handle_type    CHOICES session interface source joinprune crp
        -handle_value
        -handle_name_pattern
        -mvpn_enable    CHOICES 0 1
                        DEFAULT 0
        -mvrf_unique    CHOICES 0 1
                        DEFAULT 0
        -default_mdt_ip IP
                        DEFAULT 0.0.0.0
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args}\
                parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed in ::ixia::updatePimsmInterfaceArray. \
                $parseError"
        return $returnList
    }
    
    switch $mode {
        create {
            if {(![info exists handle_name]) || (![info exists handle_type]) \
                    || (![info exists handle_value])} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed in\
                        ::ixia::updatePimsmInterfaceArray. \
                        Invalid handle options."
                return $returnList
            }
            keylset pimsm_handles_array($handle_name,$handle_type) \
                    value $handle_value
            
            keylset pimsm_handles_array($handle_name,$handle_type) \
                    mvpn_enable $mvpn_enable
            
            keylset pimsm_handles_array($handle_name,$handle_type) \
                    mvrf_unique $mvrf_unique
            
            keylset pimsm_handles_array($handle_name,$handle_type) \
                    default_mdt_ip $default_mdt_ip
        }
        delete {
            if {![info exists handle_name]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed in\
                        ::ixia::updatePimsmInterfaceArray. \
                        You must provide handle_name option."
                return $returnList
            }
            set handle_type [::ixia::getPimsmHandleType $handle_name]
            switch -- $handle_type {
                session {
                    unset pimsm_handles_array($handle_name,$handle_type)
                    set router_name $handle_name
                    foreach {i j} [array get pimsm_handles_array] {
                        if {[lsearch [keylget j value] $router_name] != -1 } {
                            unset pimsm_handles_array($i)
                            set interface_name [lindex [split $i ,] 0]
                            foreach {m n} [array get pimsm_handles_array] {
                                if {[lsearch [keylget n value] \
                                            $interface_name] != -1 } {
                                    unset pimsm_handles_array($m)
                                }
                            }
                        }
                    }
                }
                interface {
                    unset pimsm_handles_array($handle_name,$handle_type)
                    set interface_name $handle_name
                    foreach {m n} [array get pimsm_handles_array] {
                        if {[lsearch [keylget n value] \
                                    $interface_name] != -1 } {
                            unset pimsm_handles_array($m)
                        }
                    }
                }
                default {
                    unset pimsm_handles_array($handle_name,$handle_type)
                }
            }
        }
        reset {
            if {[info exists handle_name_pattern]} {
                array unset pimsm_handles_array ${handle_name_pattern}*
            } elseif {[info exists handle_name]} {
                set handle_type [::ixia::getPimsmHandleType $handle_name]
                switch -- $handle_type {
                    session {
                        set router_name $handle_name
                        foreach {i j} [array get pimsm_handles_array] {
                            if {[lsearch [keylget j value] $router_name] != -1 } {
                                unset pimsm_handles_array($i)
                                set interface_name [lindex [split $i ,] 0]
                                foreach {m n} [array get pimsm_handles_array] {
                                    if {[lsearch [keylget n value] \
                                                $interface_name] != -1 } {
                                        unset pimsm_handles_array($m)
                                    }
                                }
                            }
                        }
                    }
                    interface {
                        set interface_name $handle_name
                        foreach {m n} [array get pimsm_handles_array] {
                            if {[lsearch [keylget n value] \
                                        $interface_name] != -1 } {
                                unset pimsm_handles_array($m)
                            }
                        }
                    }
                    default {
                    }
                }
            } else  {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed in\
                        ::ixia::updatePimsmInterfaceArray. \
                        You must provide handle_name_pattern option or\
                        handle_name option."
                return $returnList
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}



##Internal Procedure Header
# Name:
#    ::ixia::getNextPimsmLabel
#
# Description:
#    This command creates a new handle name for various handle types.
#
# Synopsis:
#    ::ixia::getNextPimsmLabel
#        [-port_handle    REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-handle_name    REGEXP
#        ^pimsm(Router|Interface|Source|JoinPrune|CRPRange)$ ]
#        [-handle_type    CHOICES session interface source joinprune crp]
#
# Arguments:
#    -port_handle
#        The prot_handle where the element needs to be created.
#    -handle_name
#        It refers to the name of the element type on hardware.
#    -handle_type
#        Specifies if the element is: session, interface, source, joinprune
#        Mandatory for mode create.
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE.
#    key:log           value:When status is failure, contains more information
#    key:next_handle   value:The next handle.
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
proc ::ixia::getNextPimsmLabel {args} {
    
    variable pimsm_handles_array
    variable pim_counters
    
    set opt_args {
            -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
            -handle_name    REGEXP  ^pimsm(Router|Interface|Source|JoinPrune|CRPRange)$
            -handle_type    CHOICES session interface source joinprune crp
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args} \
                parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed in ::ixia::getNextPimsmRouterLabel. \
                $parseError"
        return $returnList
    }
    
    set handle ${port_handle}$handle_name,$handle_type
    set next_handle ${port_handle}$handle_name
    
    if {![info exists pim_counters($handle)]} {
        set pim_counters($handle) 1
    } else {
        incr pim_counters($handle)
    }
    set next_handle ${next_handle}$pim_counters($handle)    
    
    keylset returnList next_handle $next_handle
    keylset returnList status $::SUCCESS
    
    return $returnList
    
#     set handle ${port_handle}$handle_name
#     set allHandles [array names pimsm_handles_array "*,${handle_type}"]
#     regsub -all ",${handle_type}" $allHandles {} allHandles
#     
#     if {[llength $allHandles] == 0} {
#         keylset returnList next_handle ${handle}1
#         return $returnList
#     } else  {
#         regsub -all "(\[0-9\]+)/(\[0-9\]+)/(\[0-9\]+)${handle_name}(\[0-9\]+)" \
#                 $allHandles {\4} allHandles
#         
#         set allHandles [lsort -dictionary $allHandles]
#         
#         if {[lindex $allHandles 0] > 1} {
#             keylset returnList next_handle ${handle}1
#             return $returnList
#         }
#         set i 0
#         while {([mpexpr \
#                     [lindex $allHandles [mpexpr $i + 1]] \
#                     - \
#                     [lindex $allHandles $i]] == 1) && \
#                     ($i < [llength $allHandles])} {
#             
#             incr i
#         }
#         if {$i == [llength $allHandles]} {
#             set handle_num [mpexpr [lindex $allHandles end] + 1]
#         } else  {
#             set handle_num [mpexpr [lindex $allHandles $i] + 1]
#         }
#         keylset returnList next_handle ${handle}$handle_num
#         return $returnList
#     }
}



##Internal Procedure Header
# Name:
#    ::ixia::getPimsmHandleType
#
# Description:
#    This command creates a new handle name for various handle types.
#
# Synopsis:
#    ::ixia::getPimsmHandleType
#        handle_name    REGEXP
#        ^pimsm(Router|Interface|Source|JoinPrune|CRPRange)$
#
# Arguments:
#    handle_name
#        It refers to the name of the element type on hardware.
#
# Return Values:
#    Specifies if the element is: session, interface, source, joinprune.
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
proc ::ixia::getPimsmHandleType {handle_name} {
    array set typeArray [list     \
            Router      session   \
            Interface   interface \
            Source      source    \
            JoinPrune   joinprune \
            CRPRange    crp]
    
    foreach {type} [array names typeArray] {
        if {[regexp "(.)*pimsm${type}(.)*" $handle_name match] && \
                    ($handle_name == $match)} {
            return $typeArray($type)
        }
    }
    return "unknown"
}



##Internal Procedure Header
# Name:
#    ::ixia::pimsmGroupMemberAction
#
# Description:
#    Enables or disables the pimsmJoinPrune,pimsmSource or pimsmCRPRange objects. 
#
# Synopsis:
#
# Arguments:
#    portList -  the port specified in a list format "chassis card port" 
#    routerHander - pimsm router handle
#    groupMemberHandle - group memeber handle
#    action - choices are: $::true or $::false
#
# Return Values:
#
# Examples:
#
proc ::ixia::pimsmGroupMemberAction { portList routerHandle\
    groupMemberHandle action} {
    
    set procName [lindex [info level [info level]] 0]

    set portList [lindex $portList 0]
    scan $portList "%d %d %d" chasNum cardNum portNum
    if {[pimsmServer select $chasNum $cardNum $portNum]} {
        keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                select $chasNum $cardNum $portNum call."
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    if {[pimsmServer getRouter $routerHandle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                getRouter $routerHandle call on port $chasNum $cardNum\
                $portNum."
        return $returnList
    }
    
    set retCode [getAllPimsmInterfaceHandles $routerHandle]
    if {[keylget retCode status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: [keylget retCode log]"
        return $returnList
    }
    set interfaceHandles [keylget retCode handles]
    
    foreach {interfaceH} $interfaceHandles {
        if {[pimsmRouter getInterface $interfaceH]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed on pimsmRouter\
                    getInterface $interfaceH call on port $chasNum $cardNum $portNum."
            return $returnList
        }
        if {[string first JoinPrune $groupMemberHandle] >= 0} {
            if {[pimsmInterface getJoinPrune $groupMemberHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface getJoinPrune $groupMemberHandle on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            pimsmJoinPrune config -enable $action
            
            if {[pimsmInterface setJoinPrune $groupMemberHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface setJoinPrune $groupMemberHandle on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
        } elseif {[string first Source $groupMemberHandle] >= 0} {
            if {[pimsmInterface getSource $groupMemberHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface getSource $groupMemberHandle on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            pimsmSource config -enable $action
            
            if {[pimsmInterface setSource $groupMemberHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface setSource $groupMemberHandle on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
        }
        
        if {[string first CRPRange $groupMemberHandle] >= 0} {
            if {[pimsmInterface getCRPRange $groupMemberHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface getCRPRange $groupMemberHandle on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            pimsmCRPRange config -enable $action
            
            if {[pimsmInterface setCRPRange $groupMemberHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface setCRPRange $groupMemberHandle on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
        }
        if {[pimsmRouter setInterface $interfaceH]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed on pimsmRouter\
                    setInterface $interfaceH call on port\
                    $chasNum $cardNum $portNum."
            return $returnList
        }
    }
    
    if {[pimsmServer set]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                set call on port $chasNum $cardNum $portNum."
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}



#Internal Procedure Header
# Name:
#    ::ixia::pimsmRouterAction
#
# Description:
#    Enables or disables the pimsmRouter on the specified port and routerHandle
#
# Synopsis:
#
# Arguments:
#    portList -  the port specified in a list format "chassis card port" 
#    routerHander - pimsm router handle
#    action - choices are: $::true or $::false
#
# Return Values:
#
# Examples:
#
proc ::ixia::pimsmRouterAction { portList routerHandle action} {
    
    set procName [lindex [info level [info level]] 0]

    set portList [lindex $portList 0]
    scan $portList "%d %d %d" chasNum cardNum portNum
    if {[pimsmServer select $chasNum $cardNum $portNum]} {
        keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                select $chasNum $cardNum $portNum call."
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    if {[pimsmServer getRouter $routerHandle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                getRouter $routerHandle call on port $chasNum $cardNum\
                $portNum."
        return $returnList
    }
    
    pimsmRouter config -enable $action
    
    if {[pimsmServer setRouter $routerHandle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                setRouter $routerHandle call on port $chasNum $cardNum\
                $portNum."
        return $returnList
    }
    
    if {[pimsmServer set]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                 set call on port $chasNum $cardNum $portNum."
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}




##Internal Procedure Header
# Name:
#    ::ixia::pimsmGroupFlapConfig
#
# Description:
#    Configures the flap option on the specified port, routerHandle, and 
#    groupMemberHandle.
#
# Synopsis:
#
# Arguments:
#    configType - flap option.  Choices are:  enableFlap or flapInterval
#    configValue - the flap option value.
#    portList - the port specified in a list format "chassis card port"
#    routerHander - pimsm router handle
#    groupMemberHandle - pimsm group member handle
#
# Return Values:
#
# Examples:
#
proc ::ixia::pimsmGroupFlapConfig {configType configValue portList \
    {routerHandle NULL} {groupMemberHandle NULL}} {
    
    set procName [lindex [info level [info level]] 0]
    
    set portList [lindex $portList 0]
    scan $portList "%d %d %d" chasNum cardNum portNum
    
    if {[pimsmServer select $chasNum $cardNum $portNum]} {
        keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                select $chasNum $cardNum $portNum call."
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    if {$routerHandle == "NULL"} {
        set retCode [::ixia::getAllPimsmRouterHandles $chasNum/$cardNum/$portNum]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: [keylget retCode log]."
            return $returnList
        }
        set routerHandles [keylget retCode handles]
    } else  {
        set routerHandles $routerHandle
    }
    
    foreach {routerH} $routerHandles {
        if {[pimsmServer getRouter $routerH]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                    getRouter $routerH call on port $chasNum $cardNum $portNum."
            return $returnList
        }
        
        set retCode [pimsmFlapRouterConfig $routerH $configType $configValue]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: [keylget retCode log]."
            return $returnList
        }
    }
    
    if {[pimsmServer set]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                set call on port $chasNum $cardNum $portNum."
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}




##Internal Procedure Header
# Name:
#    ::ixia::pimsmFlapRouterConfig
#
# Description:
#    Configures the flap option on the specified groupMemberHandle. 
#    
# Synopsis:
#
# Arguments:
#    routerHandle - the router where this action occurs.
#    flapOption - flap option.  Choices are:  enableFlap or flapInterval
#    flapValue - the flap option value.
#    groupMemberHandle - pimsm group member handle
#
# Return Values:
#
# Examples:
#
proc ::ixia::pimsmFlapRouterConfig {routerHandle flapOption flapValue \
            {groupMemberHandle NULL}} {
       
    set procName [lindex [info level [info level]] 0]
    
    set retCode [getAllPimsmInterfaceHandles $routerHandle]
    if {[keylget retCode status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: [keylget retCode log]"
        return $returnList
    }
    set interfaceHandles [keylget retCode handles]
    foreach {interfaceH} $interfaceHandles {
        if {[pimsmRouter getInterface $interfaceH]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed on pimsmRouter\
                    getInterface call $interfaceH"
            return $returnList
        }
        
        if {$groupMemberHandle == "NULL"} {
            if {[pimsmInterface getFirstJoinPrune]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface getFirstJoinPrune call"
                return $returnList
            }
            
            pimsmJoinPrune config -$flapOption $flapValue
            
            if {[pimsmInterface setJoinPrune]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface setJoinPrune call"
                return $returnList
            }
            
            while {![pimsmInterface getNextJoinPrune]} {
                pimsmJoinPrune config -$flapOption $flapValue
                
                if {[pimsmInterface setJoinPrune]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to do\
                            pimsmInterface setJoinPrune call"
                    return $returnList
                }
            }
        } else {
            if {[string first JoinPrune $groupMemberHandle] >= 0} {
                if {[pimsmInterface getJoinPrune $groupMemberHandle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to do\
                            pimsmInterface getJoinPrune $groupMemberHandle call"
                    return $returnList
                }
                
                pimsmJoinPrune config -$flapOption $flapValue
                
                if {[pimsmInterface setJoinPrune $groupMemberHandle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to do\
                            pimsmInterface setJoinPrune $groupMemberHandle call"
                    return $returnList
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: the group_member_handle\
                        $group_member_handle is not a JoinPrune group handle."
                return $returnList
            }
        }
        if {[pimsmRouter setInterface $interfaceH]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed on pimsmRouter\
                    setInterface $interfaceH call. $::ixErrorInfo"
            return $returnList
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::multicast_item_exists {handle handle_type} {
    variable multicast_source_array
    variable multicast_group_array
    
    set ret_val 0
    
    switch -- $handle_type {
        "source" {
            set check_items {
                num_sources
                ip_addr_start
                ip_addr_step
                ip_prefix_len
            }
            
            set handle [lindex $handle 0]
            
            foreach second_index $check_items {
                if {[info exists multicast_source_array($handle,$second_index)]} {
                    set ret_val 1
                    break
                }
            }
        }
        "group" {
            set check_items {
                num_groups
                ip_addr_start
                ip_addr_step
                ip_prefix_len
            }
            
            foreach second_index $check_items {
                if {[info exists multicast_group_array($handle,$second_index)]} {
                    set ret_val 1
                    break
                }
            }
        }
    }
    
    return $ret_val
}
