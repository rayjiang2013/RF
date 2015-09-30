##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_ospf_api.tcl
#
# Purpose:
#    A script development library containing OSPF APIs for test automation with
#    the Ixia chassis.
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_ospf_config
#    - emulation_ospf_route_config
#
# Requirements:
#    ixiaapiutils.tcl , a library containing TCL utilities
#    parseddashedargs.tcl , a library containing the proceDescr and
#    parsedashedargds.tcl
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
#    ::ixia::getNextOspfRouter
#
# Description:
#    This command gets the next OSPFvX router handles
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
proc ::ixia::getNextOspfRouter { serverCommand session_type port_handle {getMode "from_array"}} {
    variable  ospf_handles_array
    if {$getMode == "from_array"} {
        set ospf_sessions [array get ospf_handles_array "*,session"]
        set temp_sessions ""
        foreach {index value} $ospf_sessions {
            lappend temp_sessions $index
        }
        set ospf_sessions $temp_sessions
        if {[llength $ospf_sessions]>0} {
            regsub -all ",session" $ospf_sessions {} ospf_sessions
            regsub -all {([0-9]+)/([0-9]+)/([0-9]+)ospfv[0-9]Router} \
                    $ospf_sessions {}  ospf_sessions
            set router_number [lindex [lsort -dictionary $ospf_sessions] end]
            set router_number [incr router_number]
            set next_handle "${port_handle}${session_type}Router$router_number"
        } else  {
            set next_handle "${port_handle}${session_type}Router1"
        }
    } else {
        # Get the OSPF information from handle
        if {[$serverCommand getFirstRouter] != 0} {
            set next_handle "${port_handle}${session_type}Router1"
        } else {
            set router_number 1
            while {[$serverCommand getNextRouter] == 0} {
                incr router_number
            }
            set next_handle "${port_handle}${session_type}Router[expr $router_number + 1]"
        }
    }
    return $next_handle
}


##Internal Procedure Header
# Name:
#    ::ixia::initializeOspf
#
# Description:
#    This command initializes the OSPF to its initial default configuration.
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
proc ::ixia::initializeOspf {chasNum cardNum portNum session_type} {

    set retCode $::TCL_OK

    if {$session_type == "ospfv2"} {
        if {[ospfServer select $chasNum $cardNum $portNum]} {
            set retCode $::TCL_ERROR
        }
        if {[ospfServer clearAllRouters]} {
            set retCode $::TCL_ERROR
        }
    } elseif {$session_type == "ospfv3"} {
        if {[ospfV3Server select $chasNum $cardNum $portNum]} {
            set retCode $::TCL_ERROR
        }
        if {[ospfV3Server clearAllRouters]} {
            set retCode $::TCL_ERROR
        }
    }
    return $retCode
}


##Internal Procedure Header
# Name:
#    ::ixia::actionOspf
#
# Description:
#    This command deletes/enables/disables the OSPF router
#
# Synopsis:
#
# Arguments:
#    chasNum
#        chassis ID
#    cardNum
#        Load Module number
#    portNum
#        port number
#    session_type
#    mode
#    handle
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
proc ::ixia::actionOspf {chasNum cardNum portNum session_type mode handle} {
    
    keylset returnList status $::SUCCESS

    if {$session_type == "ospfv2"} {
        set ospfServerCommand "ospfServer"
        set ospfRouterCommand "ospfRouter"
    } elseif {$session_type == "ospfv3"} {
        set ospfServerCommand "ospfV3Server"
        set ospfRouterCommand "ospfV3Router"
    }

    # Select OSPF server
    if {[$ospfServerCommand select $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure in call to $ospfServerCommand\
                select $chasNum $cardNum $portNum."
        return $returnList
    }

    # If the mode is delete
    if {$mode == "delete"} {

        # We do not want to modify anything when the mode is delete or disable
        set ospf_modify_flag 1
        if {[$ospfServerCommand delRouter $handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure in call to $ospfServerCommand\
                    delRouter $handle on port $chasNum $cardNum $portNum."
        }

        return $returnList

    } elseif {($mode == "disable") || ($mode == "enable")} {

        # We do not want to modify anything when the mode is delete, disable
        # or enable
        set ospf_modify_flag 1

        # Get the OSPF router
        ospfRouter setDefault
        if {[$ospfServerCommand getRouter $handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to $ospfServerCommand\
                    getRouter $handle on port $chasNum $cardNum $portNum."
            return $returnList
        }

        # Enable/Disable
        if {$mode == "enable"} {
            $ospfRouterCommand config -enable $::true
        } elseif {$mode == "disable"} {
            $ospfRouterCommand config -enable $::false
        }

        # Set OSPF Router
        if {[$ospfServerCommand setRouter $handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to $ospfServerCommand\
                    setRouter $handle on port $chasNum $cardNum $portNum."
            return $returnList
        }
        
        return $returnList
    }
}



##Internal Procedure Header
# Name:
#    ::ixia::actionUserLsaGroup
#
# Description:
#    This command either deletes a LSA or clears all LSA under the router
#
# Synopsis:
#
# Arguments:
#    chasNum
#        chassis ID
#    cardNum
#        Load Module number
#    portNum
#        port number
#    session_type
#    mode
#    router_handle 
#    group_handle 
#    lsa_handle
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
proc ::ixia::actionUserLsaGroup {chasNum cardNum portNum session_type mode \
        router_handle group_handle lsa_handle} {

    set procName [lindex [info level [info level]] 0]

    keylset returnList status $::SUCCESS

    if {$session_type == "ospfv2"} {
        set ospfServerCommand "ospfServer"
        set ospfRouterCommand "ospfRouter"
        set ospfUserLsaGroupCommand "ospfUserLsaGroup"
    } elseif {$session_type == "ospfv3"} {
        set ospfServerCommand "ospfV3Server"
        set ospfRouterCommand "ospfV3Router"
        set ospfUserLsaGroupCommand "ospfV3UserLsaGroup"
    }

    # Select OSPF server
    if {[$ospfServerCommand select $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName:  Failure in call to\
                $ospfServerCommand select $chasNum $cardNum $portNum."
        return $returnList
    }
    
    # If the mode is delete
    if {!($mode == "delete" || $mode == "reset")} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: invalid mode = $mode."
        return $returnList
    }
    
    if {[$ospfServerCommand getRouter $router_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure on call to\
                $ospfServerCommand getRouter $handle on port $chasNum\
                $cardNum $portNum."
        return $returnList
    }
    
    if {$mode == "delete"} {
        if {[$ospfRouterCommand getUserLsaGroup $group_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure on call to\
                    $ospfRouterCommand getUserLsaGroup $group_handle on port\
                    $chasNum $cardNum $portNum."
            return $returnList
        }
        
        if {[$ospfUserLsaGroupCommand delUserLsa $lsa_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure on call to\
                    $ospfUserLsaGroupCommand delUserLsa $lsa_handl on port\
                    $chasNum $cardNum $portNum."
            return $returnList
        }
        
        if {[$ospfRouterCommand setUserLsaGroup $group_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure on call to\
                    $ospfRouterCommand setUserLsaGroup $group_handle on port\
                    $chasNum $cardNum $portNum."
            return $returnList
        }
        
        unset ::ixia::ospf_handles_array($router_handle,userLsa,$lsa_handle)
    } else {
        if {[$ospfRouterCommand clearAllInterfaces]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure on call to\
                    $ospfRouterCommand clearAllInterfaces\
                    on port $chasNum $cardNum $portNum."
            return $returnList
        }
        
        if {[$ospfRouterCommand clearAllLsaGroups]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure on call to\
                    $ospfRouterCommand clearAllLsaGroups\
                    on port $chasNum $cardNum $portNum."
            return $returnList
        }
        
        array unset ::ixia::ospf_handles_array "$router_handle,userLsa,*"
        
        if {[$ospfRouterCommand clearAllRouteRanges]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure on call to\
                    $ospfRouterCommand clearAllRouteRanges\
                    on port $chasNum $cardNum $portNum."
            return $returnList
        }
        
        array unset ::ixia::ospf_handles_array "$router_handle,topology,*"
    }
        
    if {[$ospfServerCommand setRouter $router_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure on call to\
                $ospfServerCommand setRouter $router_handle\
                on port $chasNum $cardNum $portNum."
        return $returnList
    }
    
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::getNextUserLsa
#
# Description:
#    This command returns the next userLsa label Id.  This id is to be 
#    used with new LSA.
#
# Synopsis:
#
# Arguments:
#    userLsaGroupCommand
#        IxTclHal command to configure the userLsaGroup
#    session_type        
#        ospf session type:  ospfv2 or ospfv3
#
# Return Values:
#    The userLsa label Id
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
proc ::ixia::getNextUserLsa {session_type port_handle} {
    variable ospf_handles_array
    set userLsa_number 0

    set userLsa ${session_type}UserLsa
    
    set ospf_lsas [array get ospf_handles_array]
    set temp_sessions ""
    foreach {index value} $ospf_lsas {
        set index_value [lindex $value 0]
        set index_num [regsub "$userLsa" $index_value {} index_ignore]
        if {$index_num > 0} {
            lappend temp_sessions $index_value
        }
    }
    set ospf_lsas $temp_sessions
    if {[llength $ospf_lsas]>0} {
        regsub -all "(\[0-9\]+)/(\[0-9\]+)/(\[0-9\]+)$userLsa" $ospf_lsas {} \
                ospf_lsas
        set lsa_number [lindex [lsort -dictionary $ospf_lsas] end]
        set lsa_number [incr lsa_number]
        set next_handle "${port_handle}${userLsa}$lsa_number"
    } else  {
        set next_handle "${port_handle}${userLsa}1"
    }
    return $next_handle
}

##Internal Procedure Header
# Name:
#    ::ixia::getNextOspfLabel
#
# Description:
#    This command returns the next label id for ospf router commands.
#
# Synopsis:
#
# Arguments:
#    subCommand
#        This subCommand is appended session_type in order to retrieve the
#        next handle from the :;ixia::ospf_handles_array
#    session_type
#        session type:  ospfv2 or ospfv3.
#    port_handle
#        specifies the chassis/card/port
#
# Return Values:
#    The next handle.
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
proc ::ixia::getNextOspfLabel {subCommand session_type port_handle} {
    variable ospf_handles_array
    
    set label ${session_type}${subCommand}
    
    set ospf_labels [array get ospf_handles_array]
    set temp_sessions ""
    foreach {index value} $ospf_labels {
        set index_value [lindex $value 0]
        set index_num [regsub "$label" $index_value {} index_ignore]
        if {$index_num > 0} {
            lappend temp_sessions $index_value
        }
    }
    set ospf_labels $temp_sessions
    if {[llength $ospf_labels]>0} {
        regsub -all "(\[0-9\]+)/(\[0-9\]+)/(\[0-9\]+)$label" $ospf_labels {} \
                ospf_labels
        set label_number [lindex [lsort -dictionary $ospf_labels] end]
        set label_number [incr label_number]
        set next_handle "${port_handle}${label}$label_number"
    } else  {
        set next_handle "${port_handle}${label}1"
    }
    return $next_handle
}

##Internal Procedure Header
# Name:
#    ::ixia::updateOspfHandleArray
#
# Description:
#    This command creates or deletes an element in ospf_handles_array.
#    
#    An element in ospf_handles_array is in the form of
#         $session_handle,session
#           or
#         $session_handle,topology,$elem_handle
#            or
#         $session_handle,userLsa,$lsa_handle
#               ....
#    where $session_handle is the router handle
#    and $elem_handle is handle to topology element
#    and $lsa_handle is handle to user lsa element.
#    Below is the mapping for the topology vs. type of element handle
#           OSPF V2
#               router/grid/network -       ospfInterface handle
#               summary_routes/ext_routes - routeRange handle
#           OSPF V3
#               router/grid -               networkRange handle
#               network -                   userLsaGroup handle
#               summary_routes/ext_routes - routeRange handle
#
# Synopsis:
#
# Arguments:
#    This command creates or deletes an element in ospf_handles_array.
#    Each element stores the port_handle and session_type associated with
#    the session handle.
#
# Return Values:
#    $::TCL_OK for success
#    $::TCL_ERROR for failure to delete an element
#
# Examples:
#   [array get ospf_handles_array] shows 
#       1/6/1ospfv3Router1,session {1/6/1 ospfv3} 
#       1/6/1ospfv3Router1,topology,1/6/1ospfv3NetworkRange36917  
#                                           1/6/1ospfv3NetworkRange36917
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
proc ::ixia::updateOspfHandleArray {mode port_handle {handle NULL} \
            {session_type ospfv2}} {
    variable  ospf_handles_array

    set procName [lindex [info level [info level]] 0]       
    set retCode $::TCL_OK

    switch $mode {
        create {
            set ospf_handles_array($handle,session) \
                    [list $port_handle $session_type]
        }
        delete {
            set ospfHandleList [array get ospf_handles_array]
            set match [lsearch $ospfHandleList $handle]
            if {$match >= 0} {
                set ospfHandleList [lreplace $ospfHandleList \
                        $match [expr $match + 1]]
                array set ospf_handles_array $ospfHandleList
            } else {
                set match [array names ospf_handles_array -regexp "$handle,*"]
                if {[llength $match] >= 0} {
                    foreach match_item $match {
                        if {[catch {unset ospf_handles_array($match_item)} err]} {
                            puts "ERROR in $procName:  Cannot delete the $match_item in\
                                    ospf_handle_array. $err"
                            set retCode $::TCL_ERROR
                        }
                    }
                } else {
                    puts "ERROR in $procName:  Cannot delete the $handle in\
                            ospf_handle_array"
                    set retCode $::TCL_ERROR
                }
            }
        }
        reset {
            array unset ospf_handles_array ${port_handle}${session_type}*       
        }
    }
    return $retCode
}



##Internal Procedure Header
# Name:
#    ::ixia::configureOspfv2UserLsaParams
#
# Description:
#    Configures the OSPFV2 User Lsa parameters 
#
# Synopsis:
#
# Arguments:
#    ospfv2ArrayList
#        list of array names which hold the User Lsa parameters
#    refVarList
#        lists of variables defined in the parent scope.  Need to 
#        call upvar on each element
#    userLsaType
#        type is one of:  router, network, summary_pool, asbr_summary,
#        and ext_pool
#
# Return Values:
#    returnList with status of $::SUCCESS or $::FAILURE
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
proc ::ixia::configureOspfv2UserLsaParams {ospfv2ArrayList refVarList \
                                           userLsaType} {
     
    set procName [lindex [info level [info level]] 0]

    ### Make arrays in the ospfv2ArrayList accessable from local proc
    foreach arrayName $ospfv2ArrayList {
       upvar $arrayName $arrayName
    }
    
    ### Make variable accessable from local proc
    foreach varName $refVarList {
        upvar $varName $varName
    }
    
    array set enumList [list                                \
            ptop             $::ospfLinkPointToPoint        \
            transit          $::ospfLinkTransit             \
            stub             $::ospfLinkStub                \
            virtual          $::ospfLinkVirtual             \
            ]
    
    set serverCommand              "ospfServer"
    set routerCommand              "ospfRouter"
    set userLsaGroupCommand        "ospfUserLsaGroup"
    set userLsaCommand             "ospfUserLsa"
    set routerLsaInterfaceCommand  "ospfRouterLsaInterface"
    set routeRangeCommand          "ospfRouteRange"
    set routeRangeId               userRouteRange1
 
    switch -exact $userLsaType {
        router {
            ### only supporting -router_link_mode of create for now
            ### due to ixTclHal limitation
            if {[info exists router_link_mode]} {
                if {$router_link_mode == "create"} {
                    foreach {item itemName} [array get \
                            ospfV2RouterLsaInterfaceArray] {
                        
                        upvar $itemName $itemName
                        if {![catch {set $itemName} value] } {
                            if {[lsearch [array names enumList] $value] != -1} {
                                set value $enumList($value)
                            }
                            catch {$routerLsaInterfaceCommand config \
                                        -$item $value}
                        }
                    }
                    
                    if {[$userLsaCommand addInterfaceDescriptionToRouterLsa]} {
                        keylset returnList log "ERROR in $procName: Failed\
                                to addInterfaceDescriptionToRouterLsa. \
                                \n$::ixErrorInfo"
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                } else {
                    keylset returnList log "ERROR in $procName: \
                            $router_link_mode router link mode is not\
                            supported."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
            set lsaType $::ospfLsaRouter
        }
        network {
            if {[info exists net_attached_router]} {
                switch $net_attached_router {
                    create {
                        $userLsaCommand config -neighborId $attached_router_id
                    }
                    delete {
                        set neighborList [$userLsaCommand cget -neighborId]
                        if {[set idx [lsearch $neighborList \
                                    $attached_router_id]] > 0} {
                            
                            lreplace $neighborList $idx $idx
                            $userLsaCommand config -neighborId $neighborList
                        } else {
                            keylset returnList log "ERROR in $procName: \
                                    Cannot find $attached_router_id in\
                                    attached routers for the network LSA."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                    reset {
                        $userLsaCommand config -neighborId [list]
                    }
                }
            }
            set lsaType $::ospfLsaNetwork
        }
        summary_pool -
        asbr_summary {
            foreach {item itemName} [array get ospfV2LsaSummaryArray] {
                upvar $itemName $itemName
                if {![catch {set $itemName} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {$userLsaCommand config -$item $value}
                }
            }
            if {$userLsaType == "summary_pool"} {
                set lsaType $::ospfLsaSummaryIp
            } else {
                set lsaType $::ospfLsaSummaryAs
            }
        }
        ext_pool {
            foreach {item itemName} [array get ospfV2LsaExternalArray] {
                upvar $itemName $itemName
                if {![catch {set $itemName} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                          set value $enumList($value)
                    }
                    catch {$userLsaCommand config -$item $value}
                }
            }
            $userLsaCommand config -externalMetricEBit \
                    [expr $external_prefix_type - 1]
            
            set lsaType $::ospfLsaExternal
        }
        default {
            keylset returnList log "ERROR in $procName: LSA type of \
                    $userLsaType is not supported."
            keylset returnList status $::FAILURE
            return $returnList    
        }
    }
    $userLsaCommand config -routerCapabilityBits  3
    
    ## [expr $router_virtual_link_endpt << 2 | $router_abr << 1 | $router_asbr]

    ###### Set the NetworkMask ########
    foreach {item itemName} [array get ospfV2UserLsaArray] {
        upvar $itemName $itemName
        if {![catch {set $itemName} value] } {
            if {[lsearch [array names enumList] $value] != -1} {
                set value $enumList($value)
            }
            catch {$userLsaCommand config -$item $value}
        }
    }

    switch $userLsaType {
        network {
            set netPrefixLengthVar net_prefix_length
        }
        summary_pool -
        asbr_summary {
            set netPrefixLengthVar summary_prefix_length
        }
        ext_pool {
            set netPrefixLengthVar external_prefix_length
        }
        default {
            set netPrefixLengthVar default_prefix_length
        }
    }
    if {[info exists $netPrefixLengthVar]} {
         set maskHexVal 0
         set shiftBy 31
         for {set i 0} {$i < [set $netPrefixLengthVar]} \
                              {incr i; incr shiftBy -1} {
               set maskHexVal [expr $maskHexVal | (1 << $shiftBy)]
         }
         set networkMask [::ixia::long_to_ip_addr $maskHexVal]
    } else {
         set $netPrefixLengthVar 24
         set networkMask 255.255.255.0
    }
    $userLsaCommand config -networkMask $networkMask
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::configureOspfv3UserLsaParams
#
# Description:
#    Configures the OSPFV3 Lsa parameters 
#
# Synopsis:
#
# Arguments:
#    ospfv3ArrayList
#        list of array names which hold the User Lsa parameters
#    refVarList
#        lists of variables defined in the parent scope.  Need to 
#        call upvar on each element
#    userLsaType
#        type is one of:  router, network, summary_pool, asbr_summary,
#        and ext_pool
#
# Return Values:
#    returnList with status of $::SUCCESS or $::FAILURE
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
proc ::ixia::configureOspfv3UserLsaParams {ospfv3ArrayList refVarList \
                                            userLsaType} {

    set procName [lindex [info level [info level]] 0]

    ### Make arrays in the ospfv2ArrayList accessable from local proc
    foreach arrayName $ospfv3ArrayList {
       upvar $arrayName $arrayName
    }

    ### Make variable accessable from local proc
    foreach varName $refVarList {
        upvar $varName $varName
    }
    
    array set enumList [list                                         \
            ptop         $::ospfV3LsaRouterInterfacePointToPoint     \
            transit      $::ospfV3LsaRouterInterfaceTransit          \
            virtual      $::ospfV3LsaRouterInterfaceVirtual          \
            ]

    set serverCommand                  "ospfV3Server"
    set routerCommand                  "ospfV3Router"
    set userLsaGroupCommand            "ospfV3UserLsaGroup"
    set routerLsaInterfaceCommand      "ospfV3LsaRouterInterface"
    set routeRangeCommand              "ospfV3RouteRange"
    array set userLsaCommandArray [list                 \
            router             ospfV3LsaRouter          \
            network            ospfV3LsaNetwork         \
            summary_pool       ospfV3LsaInterAreaPrefix \
            asbr_summary       ospfV3LsaInterAreaRouter \
            ext_pool           ospfV3LsaAsExternal      ]
    
    set userLsaCommand         $userLsaCommandArray($userLsaType)  
    set routeRangeId           userRouteRange1
    
    switch -exact $userLsaType {
        router {
            foreach {item itemName} [array get ospfV3LsaRouterArray] {
                upvar $itemName $itemName
                if {![catch {set $itemName} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {$userLsaCommand    config -$item $value}
                }
            }          
            ### only supporting -router_link_mode of create for now
            ### due to ixTclHal limitation
            if {[info exists router_link_mode]} {
                if {$router_link_mode == "create"} {
                    foreach {item itemName} [array get \
                            ospfV3LsaRouterInterfaceArray] {
                        
                        upvar $itemName $itemName
                        if {![catch {set $itemName} value] } {
                            if {[lsearch [array names enumList] $value] != -1} {
                                set value $enumList($value)
                            }
                            catch {$routerLsaInterfaceCommand config \
                                        -$item $value}
                            
                        }
                    }
                    upvar router_link_id router_link_id
                    catch {::ixia::ip_addr_to_num $router_link_id} linkId
                    catch {$routerLsaInterfaceCommand config \
                                -neighborInterfaceId $linkId}
                    
                    if {[$userLsaCommand    addInterface]} {
                        keylset returnList log "ERROR in $procName: Failed to\
                                addInterface to $userLsaCommand\
                                \n$::ixErrorInfo"
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    
                } else {
                    keylset returnList log "ERROR in $procName: \
                            $router_link_mode router link mode\
                            is not supported."
                    keylset returnList status $::FAILURE
                    return $returnList                 
                }
            }

        }
        network {
            foreach {item itemName} [array get ospfV3LsaNetworkArray] {
                upvar $itemName $itemName
                if {![catch {set $itemName} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                          set value $enumList($value)
                    }
                    catch {$userLsaCommand    config -$item $value}
                }
            } 
            if {[info exists net_attached_router]} {
                switch $net_attached_router {
                    create {
                        catch {$userLsaCommand config -neighborRouterIdList \
                                    "$attached_router_id"}
                        
                    }
                    delete {
                        set neighborList \
                                [$userLsaCommand cget -neighborRouterIdList]
                        
                        if {[set idx [lsearch $neighborList \
                                    $attached_router_id]] >= 0} {
                            
                            lreplace $neighborList $idx $idx
                            $userLsaCommand config -neighborRouterIdList \
                                    $neighborList
                            
                        } else {
                            keylset returnList log "ERROR in $procName: \
                                    Cannot find $attached_router_id in\
                                    attached routers for the network LSA."
                            keylset returnList status $::FAILURE
                            return $returnList                 
                        }
                    }
                    reset {
                        $userLsaCommand config -neighborRouterIdList [list]
                    }
                }
            }
        }
        summary_pool {
            foreach {item itemName} [array get ospfV3LsaInterAreaPrefixArray] {
                upvar $itemName $itemName
                if {![catch {set $itemName} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {$userLsaCommand config -$item $value}
                }
            }
            upvar summary_prefix_step summary_prefix_step
            if {![catch {::ixia::ip_addr_to_num \
                        $summary_prefix_step} incrementBy]} {
                $userLsaCommand config -incrementPrefixBy $incrementBy
            }
        }
        asbr_summary {
            foreach {item itemName} [array get ospfV3LsaInterAreaRouterArray] {
                upvar $itemName $itemName
                if {![catch {set $itemName} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {$userLsaCommand config -$item $value}
                }
            }
        }
        ext_pool {
            foreach {item itemName} [array get ospfV3LsaAsExternalArray] {
                upvar $itemName $itemName
                if {![catch {set $itemName} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {$userLsaCommand config -$item $value}
                }
            }
            if {![catch {::ixia::ip_addr_to_num $external_prefix_step} \
                        incrementBy]} {
                
                $userLsaCommand config -incrementPrefixBy $incrementBy
                catch {$userLsaCommand config -incrementLinkStateIdBy  \
                            $external_prefix_step}
                
                catch {$userLsaCommand config -enableEBit              \
                            [expr $external_prefix_type - 1]}
                
            }  
        }
        default {
            keylset returnList log "ERROR in $procName: LSA type of \
                    $userLsaType is not supported."
            keylset returnList status $::FAILURE
            return $returnList    
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}



##Internal Procedure Header
# Name:
#    ::ixia::getNetMaskFromPrefixLen
# Description:
#    This procedure takes in prefix length and returns equivalent network mask
#    in IP format 
#
# Synopsis:
#
# Arguments:
#    prefixLen - prefix length
#
# Return Values:
#    network mask in IP format    
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
proc ::ixia::getNetMaskFromPrefixLen {prefixLen} {
    set maskHexVal 0
    set shiftBy 31
    for {set i 0} {$i < $prefixLen} {incr i; incr shiftBy -1} {
        set maskHexVal [expr $maskHexVal | (1 << $shiftBy)]
    }
    set networkMask [::ixia::long_to_ip_addr $maskHexVal]
    return $networkMask
}



##Internal Procedure Header
# Name:
#    ::ixia::create_ospf_topology_route_arrays
# Description:
#    Branches off to the appropriate proc for creating route configuration
#    arrays
#
# Synopsis:
#
# Arguments:
#    session_type - choices are:  ospfv2, ospfv3
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
proc ::ixia::create_ospf_topology_route_arrays {session_type} {

    if {$session_type == "ospfv2"} {
        ::ixia::create_ospfV2_topology_route_array
    } else {
        ::ixia::create_ospfV3_topology_route_array
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::create_ospfV2_topology_route_array
# Description:
#    Creates OSPF V2 arrays of IxTclHal option to Cisco option pair for
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
proc ::ixia::create_ospfV2_topology_route_array {} {

    variable ospfv2ConfigCommandArray
    variable ospfv2InterfaceArray
    variable ospfv2NetworkRangeArray
    variable ospfv2SummaryRouteRangeArray
    variable ospfv2ExternalRouteRangeArray
    variable ospfv2EnumList

    set procName [lindex [info level [info level]] 0]
    
    array set ospfv2ConfigCommandArray [list                     \
            router         [list   \
            [list ospfInterface    ospfv2InterfaceArray]         \
            [list ospfNetworkRange ospfv2NetworkRangeArray]]     \
            grid           [list   \
            [list ospfInterface    ospfv2InterfaceArray]         \
            [list ospfNetworkRange ospfv2NetworkRangeArray]]     \
            network        [list   \
            [list ospfInterface    ospfv2InterfaceArray]]        \
            summary_routes [list   \
            [list ospfRouteRange ospfv2SummaryRouteRangeArray]]  \
            ext_routes     [list   \
            [list ospfRouteRange ospfv2ExternalRouteRangeArray]] \
            ]

    ###########################################################
    ### General Router Configuration                        ###
    ###########################################################

    # OSPFv2 Interface
    array set ospfv2InterfaceArray {
        adminGroup                      {hexbytes    no_mapping                                  no_mapping}
        areaId                          {integer     area_id                                     {{router grid network}}}
        authenticationMethod            {translate   no_mapping                                  no_mapping}
        connectToDut                    {bool        no_mapping                                  no_mapping}
        deadInterval                    {integer     dead_interval                               {{router grid network}}}
        enable                          {bool        enable                                      {{router grid network}}}
        enableAdvertiseNetworkRange     {bool        enable_advertise                            {{router grid}}}
        enableBFDRegistration           {bool        bfd_registration                            {{router grid network}}}
        enableTrafficEngineering        {bool        no_mapping                                  no_mapping}
        enableValidateMtu               {bool        no_mapping                                  no_mapping}
        helloInterval                   {integer     hello_interval                              {{router grid network}}}
        ipAddress                       {IP          {interface_ip_address net_ip}               {{router grid} network}}
        ipMask                          {IP          {interface_ip_mask    ip_mask}              {{router grid} network}}
        linkMetric                      {integer     no_mapping                                  no_mapping}
        linkType                        {integer     link_type                                   {{router grid network}}}
        maxBandwidth                    {double      no_mapping                                  no_mapping}
        maxReservableBandwidth          {double      no_mapping                                  no_mapping}
        md5Key                          {string      no_mapping                                  no_mapping}
        md5KeyId                        {integer     no_mapping                                  no_mapping}
        metric                          {integer     interface_metric                            {{router grid network}}}
        mtuSize                         {integer     no_mapping                                  no_mapping}
        neighborIp                      {IP          no_mapping                                  no_mapping}
        neighborRouterId                {IP          neighbor_router_id                          {{router grid network}}}
        networkType                     {integer     no_mapping                                  no_mapping}
        numberOfLearnedLsas             {integer     no_mapping                                  no_mapping}
        options                         {integer     {interface_ip_options net_prefix_options}   {{router grid} network}}
        password                        {string      no_mapping                                  no_mapping}
        priority                        {integer     no_mapping                                  no_mapping}
        protocolInterfaceDescription    {string      no_mapping                                  no_mapping}
        unreservedBandwidthPriority0    {double      no_mapping                                  no_mapping}
        unreservedBandwidthPriority1    {double      no_mapping                                  no_mapping}
        unreservedBandwidthPriority2    {double      no_mapping                                  no_mapping}
        unreservedBandwidthPriority3    {double      no_mapping                                  no_mapping}
        unreservedBandwidthPriority4    {double      no_mapping                                  no_mapping}
        unreservedBandwidthPriority5    {double      no_mapping                                  no_mapping}
        unreservedBandwidthPriority6    {double      no_mapping                                  no_mapping}
        unreservedBandwidthPriority7    {double      no_mapping                                  no_mapping}
    }
    array set ospfv2NetworkRangeArray {
        enableAdvertiseRouterLsaLoopback    {bool            enable_advertise_loopback                      {{router grid}}}
        enableBBit                          {bool            {router_asbr}                                  {{router grid}}}
        enableEBit                          {bool            {router_abr}                                   {{router grid}}}
        enableIncrementIpFromMask           {bool            enable_incrementIp_from_mask                   {{router grid}}}
        enableTe                            {bool            {router_te              grid_te}               {router grid}}
        entryPointColumn                    {integer         {entry_point_column}                           {{router grid}}}
        entryPointRow                       {integer         {entry_point_row}                              {{router grid}}}
        firstRouterId                       {ip              {router_id   grid_router_id  }                 {router grid }}
        firstSubnetIpAddress                {ip              grid_prefix_start                              {{router grid}}}
        linkMetric                          {integer         link_te_metric                                 {{router grid}}}
        linkType                            {integer         grid_link_type                                 {{router grid}}}
        maskWidth                           {integer         grid_prefix_length                             {{router grid}}}
        maxBandwidth                        {bool            link_te_max_bw                                 {{router grid}}}
        maxReservableBandwidth              {bool            link_te_max_resv_bw                            {{router grid}}}
        numColumns                          {integer         {num_colums grid_col}                          {router grid}}
        numGeneratedLsas                    {integer         no_mapping                                     no_mapping}
        numRouters                          {integer         no_mapping                                     no_mapping}
        numRows                             {integer         {num_rows   grid_row}                          {router grid}}
        numSubnets                          {integer         no_mapping                                     no_mapping}
        routerIdIncrementBy                 {ip              grid_router_id_step                            {{router grid}}}
        subnetIpIncrementBy                 {ip              grid_prefix_step                               {{router grid}}}
        unreservedBandwidthPriority0        {double          link_te_unresv_bw_priority0                    {{router grid}}}
        unreservedBandwidthPriority1        {double          link_te_unresv_bw_priority1                    {{router grid}}}
        unreservedBandwidthPriority2        {double          link_te_unresv_bw_priority2                    {{router grid}}}
        unreservedBandwidthPriority3        {double          link_te_unresv_bw_priority3                    {{router grid}}}
        unreservedBandwidthPriority4        {double          link_te_unresv_bw_priority4                    {{router grid}}}
        unreservedBandwidthPriority5        {double          link_te_unresv_bw_priority5                    {{router grid}}}
        unreservedBandwidthPriority6        {double          link_te_unresv_bw_priority6                    {{router grid}}}
        unreservedBandwidthPriority7        {double          link_te_unresv_bw_priority7                    {{router grid}}}
    }


    ###########################################################
    ### Arrays for Summary Routes Configuration             ###
    ###########################################################    
    array set ospfv2SummaryRouteRangeArray [list            \
            enable              enable                      \
            routeOrigin         route_origin                \
            numberOfNetworks    summary_number_of_prefix    \
            networkIpAddress    summary_prefix_start        \
            prefix              summary_prefix_length       \
            metric              summary_prefix_metric       ]

    ###########################################################
    ### Arrays for External Routes Configuration            ###
    ###########################################################
    array set ospfv2ExternalRouteRangeArray [list           \
            enable              enable                      \
            routeOrigin         external_prefix_type        \
            numberOfNetworks    external_number_of_prefix    \
            networkIpAddress    external_prefix_start        \
            prefix              external_prefix_length       \
            metric              external_prefix_metric       ]


    ###########################################################
    ### Enum Definition
    ###########################################################
    array set ospfv2EnumList [list \
            broadcast         $::ospfNetworkRangeLinkBroadcast        \
            ptop_numbered     $::ospfNetworkRangeLinkPointToPoint     \
            ptop_unnumbered   $::ospfNetworkRangeLinkPointToPoint     \
            ]


}

##Internal Procedure Header
# Name:
#    ::ixia::createOspfv2RouteObject
#
# Description:
#    Creates new topology element to the session_handle.  This is done by
#    configuring and adding ospfInterface or ospfRouteRange objects 
#    to ospfRouter.
#
# Synopsis:
#
# Arguments:
#    session_handle 
#    port_handle
#        specifies the chassis/card/port
#    type  - type of router when creating topology element 
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
proc ::ixia::createOspfv2RouteObject {session_handle port_handle type} {
    variable ospfv2ConfigCommandArray
    variable ospfv2InterfaceArray
    variable ospfv2NetworkRangeArray
    variable ospfv2SummaryRouteRangeArray
    variable ospfv2ExternalRouteRangeArray
    variable ospfv2EnumList
    variable ospf_handles_array
    
    set procName [lindex [info level [info level]] 0]
    
    set ospfCommandParamLists $ospfv2ConfigCommandArray($type)
    
    ### list of variables need to be created in calling proc
    set upvarList {
        enable
        lsa_discard_mode
        entry_point_row
        entry_point_column
        num_rows
        num_columns
        enable_incrementIp_from_mask
        ip_mask
        net_prefix_length
        link_type
        network_type
        area_id
        grid_connect
        route_origin
        interface_mode
        neighbor_router_prefix_length
    }
    
    foreach item $upvarList    {
        upvar $item $item
    }
    ### Upvar all other variables
    if {$type == "summary_routes" || $type == "ext_routes"} {
        foreach commandParam $ospfCommandParamLists {
            set command     [lindex $commandParam 0]
            set paramsArray [lindex $commandParam 1]
            foreach {item itemName} [array get $paramsArray] { 
                upvar $itemName $itemName
            }
        }
    } else {
        foreach commandParam $ospfCommandParamLists {
            set command     [lindex $commandParam 0]
            set paramsArray [lindex $commandParam 1]
            foreach {item itemParams} [array get $paramsArray] {
                foreach {itemType itemNameList itemApplyListOfLists} $itemParams {
                    foreach itemName $itemNameList itemApplyList $itemApplyListOfLists {
                        if {$itemName == "no_mapping"} { continue }
                        if {[lsearch $itemApplyList $type] == -1} { continue }
                        upvar $itemName $itemName
                    }
                }
            }
        }
    }

    ### Don't change the order of following few lines
    if {$type == "router" || $type == "grid" || $type == "network"} {
        set interfaceName  [ixia::getNextOspfLabel Interface ospfv2  \
                $port_handle]
    } else {
        set routeRangeName [ixia::getNextOspfLabel RouteRange ospfv2 \
                $port_handle]
    }
    ### setDefaults ####
    foreach commandParam $ospfCommandParamLists {
        set command [lindex $commandParam 0]
        $command setDefault
    }

    ### Configure fixed command options for each type of network
    if {![info exists area_id]} {
        set area_id       [getAreaIdFromConnectedInterface ospfv2]
    }
    if {![info exists network_type]} {
        set network_type  $::ospfPointToPoint
    }
    ospfRouter config -autoGenerateRouterLsa $::true
    set enable  $::true
    switch $type {
        router {
            set entry_point_row     1
            set entry_point_column  1
            set num_rows            1
            set num_columns         1
            ospfInterface config -enableAdvertiseNetworkRange $::true
            ospfInterface config -connectToDut                $::false
        }
        grid {
            set entry_point_row                               [lindex $grid_connect 0]
            set entry_point_column                            [lindex $grid_connect 1]
            set enable_incrementIp_from_mask                  $::true
            ospfInterface config -enableAdvertiseNetworkRange $::true
            ospfInterface config -connectToDut                $::false
        }
        network {
            set ip_mask [::ixia::getNetMaskFromPrefixLen $net_prefix_length]
            set link_type                            $::ospfLinkTransit
            ospfInterface config -connectToDut       $::false
        }
        summary_routes {
            set route_origin   $::ospfRouteOriginArea 
        }
        ext_routes {
        }
    }

    ### Configure the command options for each type of network
    if {$type == "summary_routes" || $type == "ext_routes"} {
        foreach commandParam $ospfCommandParamLists {
            set command     [lindex $commandParam 0]
            set paramsArray [lindex $commandParam 1]
            foreach {item itemName} [array get $paramsArray] { 
                upvar $itemName $itemName
                if {![catch {set $itemName} value] } {
                     if {[lsearch [array names ospfv2EnumList] $value] != -1} {
                         set value $ospfv2EnumList($value)
                     }
                     catch {$command config -$item $value}
                }
            }
        }
    } else {
        foreach commandParam $ospfCommandParamLists {
            set command     [lindex $commandParam 0]
            set paramsArray [lindex $commandParam 1]
            foreach {item itemParams} [array get $paramsArray] {
                foreach {itemType itemNameList itemApplyListOfLists} $itemParams {
                    foreach itemName $itemNameList itemApplyList $itemApplyListOfLists {
                        if {$itemName == "no_mapping"} { continue }
                        if {[lsearch $itemApplyList $type] == -1} { continue }
                        upvar $itemName $itemName
                        if {![catch {set $itemName} value] } {
                             if {[lsearch [array names ospfv2EnumList] $value] != -1} {
                                 set value $ospfv2EnumList($value)
                             }
                             catch {$command config -$item $value}
                        }
                    }
                }
            }
        }
    }
    #### Set the options to IxTclHal objects
    switch $type {
        router -
        grid -
        network {
            if {[ospfRouter addInterface $interfaceName] } {
                puts "ERROR in $procName: failed to addInterface\
                        $interfaceName to ospfRouter"
                return NULL
            }
            set ospf_handles_array($session_handle,topology,$interfaceName) \
                    [list $interfaceName]
            
            set elem_handle $interfaceName

        }
        summary_routes -
        ext_routes {
 
            if {[ospfRouter addRouteRange $routeRangeName] } {
                puts "ERROR in $procName: failed to addRouteRange\
                        $routeRangeName to ospfRouter"
                return NULL
            }
            set ospf_handles_array($session_handle,topology,$routeRangeName) \
                    [list $routeRangeName]
            
            set elem_handle $routeRangeName
        }
    }

    if {[ospfServer setRouter $session_handle]} {
        puts "ERROR in $procName: ospfServer setRouter $session_handle\
                command failed. \n$::ixErrorInfo"
        
        return NULL
    }
    if {($type == "router" || $type == "grid")  && \
            ($interface_mode == "ospf_and_protocol_interface") && \
            ([info exists enable_advertise] && $enable_advertise == 0 ) && \
            ([info exists link_type] && $link_type == $::ospfInterfaceLinkPointToPoint) && \
            [info exists neighbor_router_id]} {
        set unconnected_intf_options {
            port_handle
            ip_address
            ip_version
            gateway_ip_address
            netmask
            mac_address
            connected_via
        }
        set ip_address          $neighbor_router_id
        set ip_version          4
        set retCode             [getInfoFromConnectedInterface ospfv2 $port_handle]
        if {[keylget retCode status] == $::FAILURE} {
            puts "ERROR in $procName: Cannot find configuration information for\
                    the OSPF router connected interface."
            return NULL
        }
        set gateway_ip_address  [keylget retCode ip_address]
        set mac_address         [keylget retCode mac_address]
        set connected_via       [list [keylget retCode connected_via]]
        set netmask             $neighbor_router_prefix_length
        
        set unconnected_intf_list {}
        foreach {intf_param} $unconnected_intf_options {
            if {[info exists $intf_param]} {
                append unconnected_intf_list " -$intf_param [set $intf_param]"
            }
        }
        if {[string length $unconnected_intf_list] > 0} {
            append unconnected_intf_list " -type routed"
            set intf_cmd_create "::ixia::protocol_interface_config $unconnected_intf_list"
            if {[catch {set retCode [eval $intf_cmd_create]} errorMsg]} {
                puts "ERROR in $procName: $errorMsg"
                return NULL
            }
            if {[keylget retCode status] != $::SUCCESS} {
                puts "ERROR in $procName: [keylget retCode log]."
                return NULL
            }
        }
    }
    
    return $elem_handle
}


##Internal Procedure Header
# Name:
#    ::ixia::modifyOspfv2RouteObject
# Description:
#    Modify configuration of the previously configured OSPF V2 topology element 
#
# Synopsis:
#
# Arguments:
#    session_handle 
#    elem_handle    - topology element handle
#    type           - type of router when creating topology element    
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
proc ::ixia::modifyOspfv2RouteObject {session_handle elem_handle type} {
    variable ospfv2ConfigCommandArray
    variable ospfv2InterfaceArray
    variable ospfv2RouterNetRangeArray
    variable ospfv2GridNetRangeArray
    variable ospfv2NetworkArray
    variable ospfv2SummaryRouteRangeArray
    variable ospfv2ExternalRouteRangeArray
    variable ospfv2EnumList
    variable ospf_handles_array
    
    set procName [lindex [info level [info level]] 0]
    
    ### list of variables need to be created in calling proc
    set upvarList [list                 \
            enable                      \
            lsa_discard_mode            \
            entry_point_row             \
            entry_point_column          \
            num_rows                    \
            num_columns                 \
            enable_incrementIp_from_mask\
            ip_mask                     \
            net_prefix_length           \
            link_type                   \
            network_type                \
            area_id                     \
            grid_connect                \
            route_origin                ]
    
    foreach item $upvarList    {
        upvar $item $item
    }
    
    ### Don't change the order of following few lines
    switch $type {
        router -
        grid -        
        network {
            if {[ospfRouter getInterface $elem_handle]} {
                puts "ERROR in $procName:  failed with ospfRouter\
                        getInterface $elem_handle command."
                return NULL            
            } 
        }
        summary_routes - 
        ext_routes {
            if {[ospfRouter getRouteRange $elem_handle]} {
                puts "ERROR in $procName:  failed with\
                        ospfRouter getInterface $elem_handle command."
                return NULL            
            } 
        }
    }
 
    #### Convert the input options to format accepted by IxTclHal commands
    switch $type {
        grid {
            if {[info exists grid_connect]} {
                set entry_point_row [lindex $grid_connect 0]
                set entry_point_column [lindex $grid_connect 1]
            }
        }
        network {
            if {[info exists grid_connect]} {
               set ip_mask [::ixia::getNetMaskFromPrefixLen $net_prefix_length]
            }
        }
        router -
        summary_routes -
        ext_routes {
        }
    }

    ### Get the IxTclHal Commnads from ospfv2ConfigCommandArray  ####
    set ospfCommandParamLists $ospfv2ConfigCommandArray($type)

    ### Configure the command options for each type of network
    foreach commandParam $ospfCommandParamLists {
        set command [lindex $commandParam 0]
        set paramsArray [lindex $commandParam 1]
        foreach {item itemName} [array get $paramsArray] { 
            upvar $itemName $itemName
            if {![catch {set $itemName} value] } {
                if {[lsearch [array names ospfv2EnumList] $value] != -1} {
                    set value $ospfv2EnumList($value)
                }
                catch {$command config -$item $value}
                ##puts "*** issued: $command config -$item $value"
            } else {
                ##puts "*** itemName = $itemName not passed in"
            }
        }
        ### debug
        #showCmd $command
    }

    #### Set the options to IxTclHal objects
    switch $type {
        router -
        grid -
        network {
            if {[ospfRouter setInterface $elem_handle] } {
                puts "ERROR in $procName: failed to addInterface \
                        $interfaceName to ospfRouter"
                return NULL
            }
        }
        summary_routes -
        ext_routes {
 
            if {[ospfRouter setRouteRange $elem_handle] } {
                puts "ERROR in $procName: failed to addRouteRange \
                        $routeRangeName to ospfRouter"
                return NULL
            }
        }
    }

    if {[ospfServer setRouter $session_handle]} {
        puts "ERROR in $procName: ospfServer setRouter $session_handle\
                command failed. \n$::ixErrorInfo"
        return NULL
    } 
    return $elem_handle
}


##Internal Procedure Header
# Name:
#    ::ixia:::deleteOspfv2RouteObject
# Description:
#    Deletes the previously configured OSPF V2 topology element
#
# Synopsis:
#
# Arguments:
#    session_handle 
#    elem_handle    - handle of topology element to be deleted        
#
# Return Values:
#    NULL        - returns NULL if there's error
#    elem_handle - the deleted topology element handle.  Returned to be 
#                  consistant with  modifyOspfv2RouteObject and  
#                  createOspfv2RouteObject       
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
proc ::ixia::deleteOspfv2RouteObject {session_handle elem_handle} {
    variable ospf_handles_array

    set procName [lindex [info level [info level]] 0]

    if {[string first Interface $elem_handle] >= 0} {
        if {[ospfRouter delInterface $elem_handle] } {
            puts "ERROR in $procName: failed to delInterface \
                    $elem_handle to ospfRouter"
            return NULL
        }
    } else {
        if {[ospfRouter delRouteRange $elem_handle] } {
            puts "ERROR in $procName: failed to delRouteRange \
                    $elem_handle to ospfRouter"
            return NULL
        }        
    }

    if {[ospfServer setRouter $session_handle]} {
        puts "ERROR in $procName: ospfServer setRouter $session_handle \
                command failed. \n$::ixErrorInfo"
        return NULL
    } 

    array unset ospf_handles_array $session_handle,topology,$elem_handle
    return $elem_handle   
}


##Internal Procedure Header
# Name:
#    ::ixia::cleanup_ospf_topology_route_arrays
# Description:
#    Cleans up the arrays created  with
#    ::ixia::create_ospf_topology_route_arrays
#
# Synopsis:
#
# Arguments:
#   session_type:  choices are ospfv2 or ospfv3   
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
proc ::ixia::cleanup_ospf_topology_route_arrays {session_type} {

    if {$session_type == "ospfv2"} {
        variable ospfv2ConfigCommandArray
        variable ospfv2InterfaceArray
        variable ospfv2RouterNetRangeArray
        variable ospfv2GridNetRangeArray
        variable ospfv2NetworkArray
        variable ospfv2SummaryRouteRangeArray
        variable ospfv2ExternalRouteRangeArray

        catch {unset ospfv2ConfigCommandArray}
        catch {unset ospfv2InterfaceArray}
        catch {unset ospfv2RouterNetRangeArray}
        catch {unset ospfv2GridNetRangeArray}
        catch {unset ospfv2NetworkArray}
        catch {unset ospfv2SummaryRouteRangeArray}
        catch {unset ospfv2ExternalRouteRangeArray}
    } else {
        variable ospfv3ConfigCommandArray
        variable ospfv3InterfaceArray
        variable ospfv3RouterNetRangeArray
        variable ospfv3GridNetRangeArray
        variable ospfv3NetworkArray
        variable ospfv3SummaryRouteRangeArray
        variable ospfv3ExternalRouteRangeArray

        catch {unset ospfv3ConfigCommandArray}
        catch {unset ospfv3InterfaceArray}
        catch {unset ospfv3RouterNetRangeArray}
        catch {unset ospfv3GridNetRangeArray}
        catch {unset ospfv3NetworkArray}
        catch {unset ospfv3SummaryRouteRangeArray}
        catch {unset ospfv3ExternalRouteRangeArray}
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::getAreaIdFromConnectedInterface
# Description:
#    This procedure loops through the interfaces configured for the ospfRouter.
#    Returns the areaId of the interface that's connected DUT
#
# Synopsis:
#
# Arguments:
#    
# Return Values:
#    areaId of the connected interface.  If connected interface is not found, 0
#    is returned.
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
proc ::ixia::getAreaIdFromConnectedInterface {session_type} {

    set procName [lindex [info level [info level]] 0]

    set foundInterface $::false
    if {$session_type == "ospfv2"} {
        set ospfInterfaceCmd    ospfInterface
        set ospfRouterCmd       ospfRouter
        ### the area_id of the NetworkRange must match with the connected
        ### interface
        if {[$ospfRouterCmd getFirstInterface] == $::TCL_OK} {
            if {[$ospfInterfaceCmd cget -connectToDut] == $::true} {
                set foundInterface $::true
            } else {
                set gotNextInterface [$ospfRouterCmd getNextInterface]
                while {$gotNextInterface  == $::TCL_OK} {
                    if {[$ospfInterfaceCmd cget -connectToDut] == $::true} {                       
                        break
                    } else {
                        set gotNextInterface [$ospfRouterCmd getNextInterface]
                    }
                }
            }
        } else {
            puts "ERROR in $procName:  failed with command ospfRouter \
                    getFirstInterface"
        }
    } else {
        set ospfInterfaceCmd    ospfV3Interface
        set ospfRouterCmd       ospfV3Router
        if {[$ospfRouterCmd getFirstInterface] == $::TCL_OK} {
            set foundInterface $::true
        } else {
            puts "ERROR in $procName:  failed with command $ospfRouterCmd\
                    getFirstInterface"
        }
    }

    if {$foundInterface} {
        set area_id [$ospfInterfaceCmd cget -areaId]
        return $area_id
    } else {
        return 0
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::getIpAddressFromConnectedInterface
# Description:
#    This procedure loops through the interfaces configured for the ospfRouter.
#    Returns the ip address of the interface that's connected DUT
#
# Synopsis:
#
# Arguments:
#    
# Return Values:
#    areaId of the connected interface.  If connected interface is not found, 0
#    is returned.
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
proc ::ixia::getInfoFromConnectedInterface {session_type port_handle} {

    set procName [lindex [info level [info level]] 0]

    set foundInterface $::false
    if {$session_type == "ospfv2"} {
        set ospfInterfaceCmd    ospfInterface
        set ospfRouterCmd       ospfRouter
        ### the area_id of the NetworkRange must match with the connected
        ### interface
        if {[$ospfRouterCmd getFirstInterface] == $::TCL_OK} {
            if {[$ospfInterfaceCmd cget -connectToDut] == $::true} {
                set foundInterface $::true
            } else {
                set gotNextInterface [$ospfRouterCmd getNextInterface]
                while {$gotNextInterface  == $::TCL_OK} {
                    if {[$ospfInterfaceCmd cget -connectToDut] == $::true} {                       
                        break
                    } else {
                        set gotNextInterface [$ospfRouterCmd getNextInterface]
                    }
                }
            }
        } else {
            puts "ERROR in $procName:  failed with command ospfRouter getFirstInterface"
            keylset returnList status $::FAILURE
            return $returnList
        }
    } else {
        set ospfInterfaceCmd    ospfV3Interface
        set ospfRouterCmd       ospfV3Router
        if {[$ospfRouterCmd getFirstInterface] == $::TCL_OK} {
            set foundInterface $::true
        } else {
            puts "ERROR in $procName:  Failed with command $ospfRouterCmd getFirstInterface"
            keylset returnList status $::FAILURE
            return $returnList
        }
    }

    if {$foundInterface} {
        set interface_id [$ospfInterfaceCmd cget -protocolInterfaceDescription]
        foreach {ch ca po} [split $port_handle] {}
        if {$session_type == "ospfv2"} {
            set retCode [get_interface_parameter \
                    -port_handle $port_handle    \
                    -description $interface_id   \
                    -parameter   ipv4_address    \
                     ]
            if {[keylget retCode status] == $::FAILURE} {
                 puts "ERROR in $procName: [keylget retCode log]"
                 keylset returnList status $::FAILURE
                 return $returnList
            }
            keylset returnList ip_address [keylget retCode ipv4_address]
        } else {
            set retCode [get_interface_parameter \
                    -port_handle $port_handle    \
                    -description $interface_id   \
                    -parameter   ipv6_address    \
                     ]
            if {[keylget retCode status] == $::FAILURE} {
                 puts "ERROR in $procName: [keylget retCode log]"
                 keylset returnList status $::FAILURE
                 return $returnList
            }
            keylset returnList ip_address [keylget retCode ipv6_address]
        }
        set retCode [get_interface_parameter \
                -port_handle $port_handle    \
                -description $interface_id   \
                -parameter   mac_address     \
                 ]
        if {[keylget retCode status] == $::FAILURE} {
             puts "ERROR in $procName: [keylget retCode log]"
             keylset returnList status $::FAILURE
             return $returnList
        }
        keylset returnList mac_address   [keylget retCode mac_address]
        keylset returnList connected_via $interface_id
        keylset returnList status $::SUCCESS
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        return $returnList
    }
}

  
##Internal Procedure Header
# Name:
#    ::ixia::create_ospfV3_topology_route_array
# Description:
#    Creates OSPF V3 arrays of IxTclHal option to Cisco option pair for
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
proc ::ixia::create_ospfV3_topology_route_array {} {

    variable ospfv3ConfigCommandArray
    variable ospfv3InterfaceArray
    variable ospfv3RouterNetRangeArray
    variable ospfv3GridNetRangeArray
    variable ospfv3NetworkArray
    variable ospfv3SummaryRouteRangeArray
    variable ospfv3ExternalRouteRangeArray
    variable ospfv3EnumList

    set procName [lindex [info level [info level]] 0]
    
    array set ospfv3ConfigCommandArray [list \
            router         [list \
            [list ospfV3NetworkRange ospfv3RouterNetRangeArray]]          \
            grid           [list \
            [list ospfV3NetworkRange ospfv3GridNetRangeArray]]            \
            network        [list \
            [list ospfV3IpV6Prefix   ospfv3NetworkArray]]                 \
            summary_routes [list \
            [list ospfV3RouteRange   ospfv3SummaryRouteRangeArray]]       \
            ext_routes     [list \
            [list ospfV3RouteRange   ospfv3ExternalRouteRangeArray]]      \
            ]


    ###########################################################
    ### Arrays for Router Configuration                     ###
    ###########################################################
     array set ospfv3RouterNetRangeArray [list      \
             numRows             num_rows           \
             numColumns          num_cols           \
             firstRouterId       router_id          ]
  

    ###########################################################
    ### Arrays for Grid Configuration                       ###
    ###########################################################
    array set ospfv3GridNetRangeArray [list         \
            numRows             grid_row            \
            numColumns          grid_col            \
            firstRouterId       grid_router_id      \
            routerIdIncrementBy grid_router_id_step \
            linkType            grid_link_type      \
            firstSubnetIpAddress        grid_prefix_start   \
            maskWidth                   grid_prefix_length  \
            entryPointRow               entry_point_row     \
            entryPointColumn            entry_point_column  ]

    ###########################################################
    ### Arrays for Network Configuration                    ###
    ###########################################################
    array set ospfv3NetworkArray [list              \
            address             net_ip              \
            length              net_prefix_length   \
            options             net_prefix_options  \
            incrementBy         net_prefix_step     ] 

    ###########################################################
    ### Arrays for Summary Routes Configuration             ###
    ###########################################################    
    array set ospfv3SummaryRouteRangeArray [list            \
            addressFamily       summary_address_family      \
            enable              enable                      \
            routeOrigin         route_origin                \
            numRoutes           summary_number_of_prefix    \
            networkIpAddress    summary_prefix_start        \
            maskWidth           summary_prefix_length       \
            ipType              summary_ip_type             \
            iterationStep       summary_prefix_step         \
            metric              summary_prefix_metric ]

    ###########################################################
    ### Arrays for External Routes Configuration            ###
    ###########################################################
    array set ospfv3ExternalRouteRangeArray [list   \
            addressFamily       external_address_family     \
            enable              enable                      \
            numRoutes           external_number_of_prefix   \
            networkIpAddress    external_prefix_start       \
            maskWidth           external_prefix_length      \
            ipType              external_ip_type            \
            iterationStep       external_prefix_step        \
            metric              external_prefix_metric      \
            routeOrigin         external_prefix_type ]

    ###########################################################
    ### Enum Definition
    ###########################################################
    array set ospfv3EnumList [list \
            broadcast         $::ospfNetworkRangeLinkBroadcast        \
            ptop_numbered     $::ospfNetworkRangeLinkPointToPoint     \
            ptop_unnumbered   $::ospfNetworkRangeLinkPointToPoint     \
	    ]


}

##Internal Procedure Header
# Name:
#    ::ixia::createOspfv3RouteObject
#
# Description:
#    Creates new OSPF V3 topology element to the session_handle.  This is done
#    by configuring and adding ospfV3NetworkRange, ospfV3RouteRange, and
#    ospfV3UserLsaGroup objects to ospfV3Router.
#    
# Synopsis:
#
# Arguments:
#    session_handle 
#    port_handle
#       specifies the chassis/card/port
#    type 
#       type of router when creating topology element 
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
proc ::ixia::createOspfv3RouteObject {session_handle port_handle type} {
    variable ospfv3ConfigCommandArray
    variable ospfv3InterfaceArray
    variable ospfv3RouterNetRangeArray
    variable ospfv3GridNetRangeArray
    variable ospfv3NetworkArray
    variable ospfv3SummaryRouteRangeArray
    variable ospfv3ExternalRouteRangeArray
    variable ospfv3EnumList
    variable ospf_handles_array

    set procName [lindex [info level [info level]] 0]
          
    ### list of variables need to be created in calling proc
    ### which are not defined in OSPFV3 topology arrays
    set upvarList [list                 \
            enable                      \
            lsa_discard_mode            \
            entry_point_row             \
            entry_point_column          \
            num_rows                    \
            num_columns                 \
            enable_incrementIp_from_mask\
            ip_mask                     \
            net_prefix_length           \
            link_type                   \
            network_type                \
            area_id                     \
            grid_connect                \
            router_abr                  \
            router_asbr                 \
            router_virtual_link_endpt   \
            router_wcr                  \
            route_origin                ]
    
    foreach item $upvarList    {
        upvar $item $item
    }
    
    ### Don't change the order of following few lines

    if {$type == "router" || $type == "grid"} { 
        ### ospfV3Router getFirst/getNext NetworkRange option is not implemented
        ### in ospfV3; therefore unique Id is created with clock
        set networkRangeName \
            "${port_handle}ospfv3NetworkRange[expr  [clock clicks] & 0xffff]"
    } elseif { $type == "network"} {
        set userLsaLabel  useLsaNetworkLink
        set userLsaGroupName [ixia::getNextOspfLabel  UserLsaGroup \
                ospfv3 $port_handle]
    } else {
        set routeRangeName   [ixia::getNextOspfLabel  RouteRange   \
                ospfv3 $port_handle]
    }

    ### setDefaults ####
    set ospfCommandParamLists $ospfv3ConfigCommandArray($type)
    foreach commandParam $ospfCommandParamLists {
        set command [lindex $commandParam 0]
        $command setDefault
    }

    ### Configure fixed command options for each type of network
    ospfV3Router config -disableAutoGenerateRouterLsa $::false
    ospfV3Router config -disableAutoGenerateLinkLsa $::false
    set enable  $::true
    switch $type {
        router {
            set num_rows    1
            set num_columns 1
        }
        grid {
            set entry_point_row                 [lindex $grid_connect 0]
            set entry_point_column              [lindex $grid_connect 1]
            set enable_incrementIp_from_mask    $::true
        }
        network {
            set ip_mask [::ixia::getNetMaskFromPrefixLen $net_prefix_length]
            set link_type      $::ospfLinkTransit
        }
        summary_routes {
            set route_origin   $::ospfRouteOriginArea 
        }
        ext_routes {
            ### route_origin is handled in ospfv3ExternalRouteRangeArray 
        }
    }

    ### Configure the command options for each type of network
    foreach commandParam $ospfCommandParamLists {
        set command [lindex $commandParam 0]
        set paramsArray [lindex $commandParam 1]
        
        foreach {item itemName} [array get $paramsArray] {
            upvar $itemName $itemName
        }
        
        foreach {item itemName} [array get $paramsArray] {
            if {![catch {set $itemName} value] } {
                 if {[lsearch [array names ospfv3EnumList] $value] != -1} {
                     set value $ospfv3EnumList($value)
                 }
                 
                 if { "summary_prefix_step" == $itemName } {
                     if {[isValidIPAddress $value]} {
                         # Route ranges accept numeric steps only
                         set value [ip_addr_to_num $value]
                         
                         # The numeric step is applied only to the network bytes
                         # shift the step value by prefix length
                         
                         if { [info exists summary_prefix_length] } {
                             set prefix_shift_by [expr 128 - $summary_prefix_length]
                         } else {
                             set prefix_shift_by [expr 128 - 64]
                         }
                         
                         set value [mpexpr $value >> $prefix_shift_by]
                         
                         # Maximum step value allowed is 32 bits
                         if {[mpexpr $value > 4294967295]} {
                             puts "ERROR in $procName: Invalid value for parameter $itemName.\
                                    The maximum numeric/IP value allowed is 4294967295/[num_to_ip_addr [mpexpr 4294967295 << $prefix_shift_by] 6]"
                             return NULL
                         }
                     }
                 }
                     
                 
                 ### debug
                 ### puts "$command config -$item $value"
                 catch {$command config -$item $value}
            }
        }
        ### debug
        #showCmd $command
    }

    #### Set the options to IxTclHal objects
    switch $type {
        router -
        grid {
            set area_id [ospfV3Interface cget -areaId]
            set enable_gen  $::true
            if {[ospfV3Router generateGridGroupLsa $enable_gen $area_id]} {
                puts "ERROR in $procName: failed to generate user\
                        LSAs for $type."
                return NULL
            }
            set ospf_handles_array($session_handle,topology,$networkRangeName)\
                    [list $networkRangeName]
            
            set elem_handle $networkRangeName

        }
        network {
            ospfV3LsaLink setDefault
            ospfV3LsaLink config -enable $::true
            ospfV3LsaLink config -advertisingRouterId \
                    [ospfV3Router cget -routerId]
            
            if {[ospfV3LsaLink addPrefix]} {
                puts "ERROR in $procName: failed with command - ospfV3LsaLink\
                        addPrefix"
                return NULL
            }
            ospfV3UserLsaGroup setDefault
            ospfV3UserLsaGroup config -description $userLsaGroupName
            ospfV3UserLsaGroup config -enable $::true
            ospfV3UserLsaGroup config -areaId \
                    [getAreaIdFromConnectedInterface ospfv3]
            ospfV3UserLsaGroup addUserLsa $userLsaLabel $::ospfV3LsaLink
            ospfV3Router addUserLsaGroup $userLsaGroupName

            #### Cleanup the prefixList so that the old prefixList
            #### does not hang around
            ospfV3LsaLink clearPrefixList
            set ospf_handles_array($session_handle,topology,$userLsaGroupName)\
                    [list $userLsaGroupName]
            set elem_handle $userLsaGroupName
        }
        summary_routes -
        ext_routes { 
            if {[ospfV3Router addRouteRange $routeRangeName] } {
                puts "ERROR in $procName: failed to addRouteRange \
                        $routeRangeName to ospfRouter"
                return NULL
            }
            set ospf_handles_array($session_handle,topology,$routeRangeName)\
                    [list $routeRangeName]
            set elem_handle $routeRangeName
        }
    }

    if {[ospfV3Server setRouter $session_handle]} {
        puts "ERROR in $procName: ospfV3Server setRouter $session_handle \
                command failed. \n$::ixErrorInfo"
        
        return NULL
    } 

    return $elem_handle
}


##Internal Procedure Header
# Name:
#    ::ixia::modifyOspfv3RouteObject
# Description:
#    Modify configuration of the previously configured OSPF V3 topology element 
#
# Synopsis:
#
# Arguments:
#    session_handle 
#    elem_handle    - topology element handle
#    type           - type of router when creating topology element    
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
proc ::ixia::modifyOspfv3RouteObject {session_handle elem_handle type} {
    variable ospfv3ConfigCommandArray
    variable ospfv3InterfaceArray
    variable ospfv3RouterNetRangeArray
    variable ospfv3GridNetRangeArray
    variable ospfv3NetworkArray
    variable ospfv3SummaryRouteRangeArray
    variable ospfv3ExternalRouteRangeArray
    variable ospfv3EnumList
    variable ospf_handles_array

    set procName [lindex [info level [info level]] 0]
          
    ### list of variables need to be created in calling proc
    ### which are not defined in OSPFV3 topology arrays
    set upvarList [list                 \
            enable                      \
            lsa_discard_mode            \
            entry_point_row             \
            entry_point_column          \
            num_rows                    \
            num_columns                 \
            enable_incrementIp_from_mask\
            ip_mask                     \
            net_prefix_length           \
            link_type                   \
            network_type                \
            area_id                     \
            grid_connect                \
            router_abr                  \
            router_asbr                 \
            router_virtual_link_endpt   \
            router_wcr                  \
            route_origin                ]
    
    foreach item $upvarList    {
        upvar $item $item
    }
    
    ### Get the IxTclHal Commnads from ospfv3ConfigCommandArray  ####
    set ospfCommandParamLists $ospfv3ConfigCommandArray($type)

    #### Set the options to IxTclHal objects
    switch $type {
        router -
        grid {
            puts "ERROR in $procName: modify mode is not supported for router\
                  or grid for OSPF V3"
            return NULL
        }
        network {
            #### fixed userLsaLink label for network configuration
            set userLsaLabel  useLsaNetworkLink
   
            if {[ospfV3Router getUserLsaGroup $elem_handle]} {
                puts "ERROR in $procName: cannot get the userLsaGroup with\
                        labelId=userLsaGroupForNetwork"
                return NULL
            }
            set ospfLsaObj [ospfV3UserLsaGroup getUserLsa $userLsaLabel]
            if {$ospfLsaObj == "NULL"} {
                puts "ERROR in $procName: cannot get the userLsa with\
                        labelId=$elem_handle"
                return NULL
            }
            # BUG692421: the $userLsaObj doesn't exist due to legacy issues
            set ospfRetCode [::ixia::getLsaOspfProcedure $ospfLsaObj]
            if {[keylget ospfRetCode status] != $::SUCCESS} {
                keylset returnList log "ERROR in $procName:cannot find a valid ospfV3 function for the \n
                        $userLsaObj object"
                keylset returnList status $::FAILURE
                return $returnList
            }
            set ospfLsaObj [keylget ospfRetCode ospfProcedure]
            
            if {[$ospfLsaObj clearPrefixList]} {
                puts "ERROR in $procName: cannot clearPrefixList with\
                        ospfV3LsaLink command"
                return NULL
            }
            ospfV3IpV6Prefix setDefault
        }
        summary_routes -
        ext_routes { 
            if {[ospfV3Router getRouteRange $elem_handle]} {
                puts "ERROR in $procName:  failed with\
                        ospfRouter getRouteRange $elem_handle command."
               return NULL            
           }
        }
    }

    ### Configure the command options for each type of network
    foreach commandParam $ospfCommandParamLists {
        set command [lindex $commandParam 0]
        set paramsArray [lindex $commandParam 1]
        foreach {item itemName} [array get $paramsArray] { 
            upvar $itemName $itemName
            if {![catch {set $itemName} value] } {
                 if {[lsearch [array names ospfv3EnumList] $value] != -1} {
                     set value $ospfv3EnumList($value)
                 }
                 ### debug
                 ### puts "$command config -$item $value"
                 catch {$command config -$item $value}
            }
        }
    }

    #### Set the options to IxTclHal objects
    switch $type {
        network {
            if {[$ospfLsaObj addPrefix]} {
                puts "ERROR in $procName: failed with command\
                        ospfV3LsaLink addPrefix"
                return NULL
            }
            if {[ospfV3UserLsaGroup setUserLsa $userLsaLabel]} {
                puts "ERROR in $procName: failed to\
                        setUserLsa $userLsaLabel to ospfV3UserLsaGroup"
                return NULL
            }
            ### don't call setUserLsaGroup; it'll mess up the userLsa config
            #if {[ospfV3Router setUserLsaGroup $elem_handle]} /{
            #    puts "ERROR in $procName: failed to etUserLsaGroup\
            #                         $elem_handle to ospfV3Router"
            #    return NULL
            #/}
         }
         summary_routes -
         ext_routes { 
            if {[ospfV3Router setRouteRange $elem_handle] } {
                puts "ERROR in $procName: failed to setRouteRange \
                        $routeRangeName to ospfV3Router"
                return NULL
            }
         }
         default {
         }
    }

    return $elem_handle
}


##Internal Procedure Header
# Name:
#    ::ixia:::deleteOspfv3RouteObject
# Description:
#    Deletes the previously configured OSPF V3 topology element
#
# Synopsis:
#
# Arguments:
#    session_handle 
#    elem_handle    - handle of topology element to be deleted        
#
# Return Values:
#    NULL        - returns NULL if there's error
#    elem_handle - the deleted topology element handle.  Returned to be 
#                  consistant with  modifyospfv3RouteObject and  
#                  createospfv3RouteObject       
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
proc ::ixia::deleteOspfv3RouteObject {session_handle elem_handle} {
    variable ospf_handles_array

    set procName [lindex [info level [info level]] 0]

    if {[string first ospfv3RouteRange $elem_handle] >= 0} {
        if {[ospfV3Router delRouteRange $elem_handle] } {
            puts "ERROR in $procName: failed to delRouteRange \
                    $elem_handle to ospfV3Router"
            return NULL
        }
        if {[ospfV3Server setRouter $session_handle]} {
            puts "ERROR in $procName: ospfV3Server setRouter $session_handle\
                    command failed. \n$::ixErrorInfo"
            return NULL
        } 
        array unset ospf_handles_array $session_handle,topology,$elem_handle
    } elseif {[string first ospfv3UserLsaGroup $elem_handle] >= 0 } {         
        if {[ospfV3Router delUserLsaGroup $elem_handle] } {
            puts "ERROR in $procName: failed to delUserLsaGroup \
                    $elem_handle to ospfV3Router"
            return NULL
        }
        if {[ospfV3Server setRouter $session_handle]} {
            puts "ERROR in $procName: ospfV3Server setRouter $session_handle\
                    command failed. \n$::ixErrorInfo"
            return NULL
        }
        array unset ospf_handles_array $session_handle,topology,$elem_handle
    } elseif {[string first ospfv3NetworkRange $elem_handle] >= 0 } {  
        ### this is router or network grid; loop thru the userLsaGroup and
        ### match the description with elem_handle 

        set foundUserLsaGroup $::false
        if {[ospfV3Router getFirstUserLsaGroup]} {
            puts "ERROR in $procName: Error getting first userLsaGroup."
            return $::TCL_ERROR
        }
        
        if {[ospfV3UserLsaGroup cget -description] == $elem_handle} {
            set foundUserLsaGroup $::true
        }
        
        while {!$foundUserLsaGroup} {
            if {[ospfV3Router getNextUserLsaGroup]} {
                puts "ERROR in $procName: Error getting nextUserLsaGroup."
                return $::TCL_ERROR
            } else {
                if {[ospfV3UserLsaGroup cget -description] == $elem_handle} {
                    set foundUserLsaGroup $::true
                }
            }
        }
        if {$foundUserLsaGroup} {
            ospfV3UserLsaGroup config -enable   $::false
            if {[ospfV3Router setUserLsaGroup]} {
                puts "ERROR in $procName: Error disabling UserLsaGroup."
                return $::TCL_ERROR
            }
        } else {
            puts "ERROR in $procName: cannot find the userLsaGroup with\
                 $elem_handle"
            return $::TCL_ERROR
        }

        #### Do Not call 'ospfV3Server setRouter' after setUserLsaGroup. 
        #### Calling setRouter after modification of lower objects causes
        #### problem. 

    } else {
        puts "ERROR in $procName: Cannot delete topology element $elem_handle"
        return NULL
    }

    array unset ospf_handles_array $session_handle,topology,$elem_handle
    return $elem_handle   
}


##Internal Procedure Header
# Name:
#    ::ixia::setRouterLsaHeaderBits
# Description:
#    This command configures B, E, V, W bits for OSPF V3 Router LSA 
#    configuration.  Prior to calling this proc, the ospfV3UserLsaGroup
#    must be selected.  This proc loops thru all the userLsas under the
#    current ospfV3UserLsaGroup and configures B, E, V, W bits if the 
#    userLsa type is a router. 
#
# Synopsis:
#
# Arguments:
#    bbit
#       B bit in lsa header
#    ebit
#       E bit in lsa header
#    vbit
#       V bit in lsa header
#    wbit
#       W bit in lsa header
#
# Return Values:
#    $::TCL_OK      for success
#    $::TCL_ERROR   if there's any error
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
proc ::ixia::setRouterLsaHeaderBits \
        {elem_handle {bbit ""} {ebit ""} {vbit ""} {wbit ""}} {

    set retCode $::TCL_OK
    set procName [lindex [info level [info level]] 0]

    ##########################################################################
    ### Find the UserLsaGroup that was auto generated with "ospfV3Router
    ### generateGridGroupLsa" command.
    ##########################################################################
    set foundUserLsaGroup $::false
    if {[ospfV3Router getFirstUserLsaGroup]} {
        puts "ERROR in $procName: Error getting first userLsaGroup."
        return $::TCL_ERROR
    }
    
    if {[ospfV3UserLsaGroup cget -description] == $elem_handle} {
        set foundUserLsaGroup $::true
    }
    
    while {!$foundUserLsaGroup} {
        if {[ospfV3Router getNextUserLsaGroup]} {
            puts "ERROR in $procName: Error getting nextUserLsaGroup."
            return $::TCL_ERROR
        } else {
            if {[ospfV3UserLsaGroup cget -description] == $elem_handle} {
                set foundUserLsaGroup $::true
            }
        }
    }

    if {!$foundUserLsaGroup} {
        puts "ERROR in $procName: Cannot get the auto generated\
                ospfV3UserLsaGroup with $elem_handle description"
        return $::TCL_ERROR
    } 

    set routerLsa [ospfV3UserLsaGroup getFirstUserLsa]
   
    while  {$routerLsa  != "NULL"} {
        # BUG692421: the $userLsaObj doesn't exist due to legacy issues
        set ospfRetCode [::ixia::getLsaOspfProcedure $routerLsa]
        if {[keylget ospfRetCode status] != $::SUCCESS} {
            keylset returnList log "ERROR in $procName:cannot find a valid ospfV3 function for the \n
                $userLsaObj object"
            keylset returnList status $::FAILURE
            return $returnList
        }
        set ospfProcedure [keylget ospfRetCode ospfProcedure]
        
        if {[$ospfProcedure cget -type] == $::ospfV3LsaRouter } {
            if {$ebit != ""} {
                $ospfProcedure config -enableEBit $ebit
            }
            if {$bbit != ""} {
                $ospfProcedure config -enableBBit $bbit
            }
            if {$vbit != ""} {
                $ospfProcedure config -enableVBit $vbit
            }
            if {$wbit != ""} {
                $ospfProcedure config -enableWBit $wbit
            }
            if {[ospfV3UserLsaGroup setUserLsa]} {
                puts "ERROR in $procName: Error setting router Lsa."
                set retCode $::TCL_ERROR
            }
        }
        set routerLsa [ospfV3UserLsaGroup getNextUserLsa]
    }
    
    return $retCode
}


##Internal Procedure Header
# Name:
#    ::ixia::configAutoGeneratedUserLsas
# Description:
#    This proc finds the Auto Generated ospfV3UserLsaGroup under ospfV3Router. 
#    If found, it renames the description of the group with the elem_handle. 
#
# Synopsis:
#
# Arguments:
#    elem_handle
#       topology element handle
#
# Return Values:
#    $::TCL_OK      for success
#    $::TCL_ERROR   if there's any error
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
proc ::ixia::configAutoGeneratedUserLsas {elem_handle} {
    
    set procName [lindex [info level [info level]] 0]

    ##########################################################################
    ### Find the UserLsaGroup that was auto generated with "ospfV3Router
    ### generateGridGroupLsa" command.
    ##########################################################################
    set foundUserLsaGroup $::false
    if {[ospfV3Router getFirstUserLsaGroup]} {
        puts "ERROR in $procName: Error getting first userLsaGroup."
        return $::TCL_ERROR
    }
    
    if {[ospfV3UserLsaGroup cget -description] == "Auto Generated Grid"} {
        set foundUserLsaGroup $::true
    }
    
    while {!$foundUserLsaGroup} {
        if {[ospfV3Router getNextUserLsaGroup]} {
            puts "ERROR in $procName: Error getting nextUserLsaGroup."
            return $::TCL_ERROR
        } else {
            if {[ospfV3UserLsaGroup cget -description] == \
                        "Auto Generated Grid"} {
                set foundUserLsaGroup $::true
            }
        }
    }

    if {$foundUserLsaGroup} {
        ospfV3UserLsaGroup config -description "$elem_handle"
    } else {
        puts "ERROR in $procName: Cannot get the auto generated UserLsaGroup."
        return $::TCL_ERROR
    }
    
    if {[ospfV3Router setUserLsaGroup]} {
        puts "ERROR in $procName: Error setting UserLsaGroup."
        return $::TCL_ERROR
    }
    
    return $::TCL_OK
}

##Internal Procedure Header
# Name:
#    ::ixia::getLsaOspfProcedure
# Description:
#    This procedure returns the corresponding ospfV3 
#    function for the given lsa object.
#    If the function is not found, null will be returned.
#
# Synopsis:
#
# Arguments:
#    lsaObj
#       the lsa object for which we want the ospv3 function
#
# Return Values:
#    if success it returns a keylist like:
#    {status 1} {ospfProcedure <value>}, where value is
#    one of the following possible functions:
#       ospfV3LsaAsExternal
#       spfV3LsaGrace
#       ospfV3LsaInterAreaPrefix
#       ospfV3LsaInterAreaRouter
#       ospfV3LsaIntraAreaPrefix
#       ospfV3LsaLink
#       ospfV3LsaNetwork
#       ospfV3LsaRouter
#       ospfV3LsaRouterInterface
#    if error it returns a keylist like:
#    {status 0} {log <error_message>}
#
# Examples:
#   [::ixia::getLsaOspfProcedure _f88c5704_p_TCLOspfV3LsaAsExternal] will
#   return ospfV3LsaAsExternal
#
proc ::ixia::getLsaOspfProcedure { lsaObj } {
    ################################################################
    # BUG692421
    # IxTclProtocol: ospfv3 lsa creation -> invalid command name 
    # "_f88c5704_p_TCLOspfV3LsaAsExternal"
    # It seems that when running  a script from a linux box the 
    # $lsaObj is an invalid command. The solution is to identify
    # the object type and perform a cget for the -type atribute using
    # the proper IxOs command.
    ################################################################
    set type_list [list ospfV3LsaAsExternal ospfV3LsaGrace ospfV3LsaInterAreaPrefix ospfV3LsaInterAreaRouter ospfV3LsaIntraAreaPrefix ospfV3LsaLink ospfV3LsaNetwork ospfV3LsaRouter ospfV3LsaRouterInterface]
    set ospfProcedure ""

    foreach ospfType $type_list {
       if {[regexp [string tolower $ospfType] [string tolower $lsaObj] ]} {
           set ospfProcedure $ospfType
           break
       }
    }

    if {$ospfProcedure == ""} {
       keylset returnList log "ERROR in $procName:invalid command $lsaObj \
           \n$::ixErrorInfo"
       keylset returnList status $::FAILURE
       return $returnList
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList ospfProcedure $ospfProcedure
    
    return $returnList
}
