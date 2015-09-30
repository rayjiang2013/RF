##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_l2tpv3.tcl
#
# Purpose:
#     A script development library containing utility procs for l2tpv3 APIs
#     for test automation with the Ixia chassis.
#
# Author:
#    Ixia engineering, direct all communication to support@ixiacom.com
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
#    ::ixia::l2tpv3CheckCcConfigParams
#
# Description:
#    This procedure check that all the required parameters of the procedure
#    l2tpv3_dynamic_cc_config are present.
#    It executes in the scope of the calling procedure.
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:If status is failure, contains more information
#    key:handle    value:Control connection group handle
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
proc ::ixia::l2tpv3CheckCcConfigParams {} {
    uplevel 1 {
        # When mode is delete/modify check if cc_handle is present
        if {($action == "delete") || ($action == "modify")} {
            if {![info exists cc_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -action is $action, a -cc_handle is required. \
                        Please supply this value."
                return $returnList
            }
            
            if {![info exists l2tpv3_cc_handles_array($cc_handle,port)] \
                        || ![info exists l2tpv3_cc_handles_array($cc_handle,subport)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Cannot find\
                        the cc handle $cc_handle in the\
                        l2tpv3_cc_handles_array"
                return $returnList
            }
            
            set subport $l2tpv3_cc_handles_array($cc_handle,subport)
            set interface [split $l2tpv3_cc_handles_array($cc_handle,port) /]
            foreach {chassis card port} $interface {}
        }
        
        # When mode is create check if port_handle, cc_src_ip, cc_dst_ip and
        # cc_gateway_ip are present
        if {$action == "create"} {
            if {![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -action is $action, a -port_handle is required. \
                        Please supply this value."
                return $returnList
            }
            
            if {![info exists cc_src_ip]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -action is $action, a -cc_src_ip is required. \
                        Please supply this value."
                return $returnList
            }
            
            if {![info exists cc_dst_ip]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -action is $action, a -cc_dst_ip is required. \
                        Please supply this value."
                return $returnList
            }
            
            if {($cc_ip_mode == "increment") && ![info exists cc_ip_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -cc_ip_mode is $cc_ip_mode, a -cc_ip_count is\
                        required.  Please supply this value."
                return $returnList
            }
            
            if {![info exists gateway_ip]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -action is $action, a -gateway_ip is required. \
                        Please supply this value."
                return $returnList
            }
        }
        
        if {($action == "create") || ($action == "modify")} {
            if {[info exists router_identification_mode]} {
                if {(($router_identification_mode == "hostname") \
                            || ($router_identification_mode == "both")) \
                            && ![info exists hostname]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When the\
                            -router_identification_mode is\
                            $router_identification_mode, a -hostname is\
                            required.  Please supply this value."
                    return $returnList
                }
                
                if {(($router_identification_mode == "routerid") \
                            || ($router_identification_mode == "both")) \
                            && ![info exists router_id_min]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When the\
                            -router_identification_mode is\
                            $router_identification_mode, a -router_id_min is\
                            required.  Please supply this value."
                    return $returnList
                }
            }
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::l2tpv3CheckSessionConfigParams
#
# Description:
#    This procedure check that all the required parameters of the procedure
#    l2tpv3_session_config are present.
#    It executes in the scope of the calling procedure.
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:If status is failure, contains more information
#    key:handle    value:Control connection group handle
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
proc ::ixia::l2tpv3CheckSessionConfigParams {} {
    uplevel 1 {
        # When mode is create check if cc_handle is present
        if {$action == "create"} {
            if {![info exists cc_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -action is $action, a -cc_handle is required. \
                        Please supply this value."
                return $returnList
            }
            
            if {![info exists num_sessions]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -action is $action, a -num_sessions is required. \
                        Please supply this value."
                return $returnList
            }
            
            if {![info exists vcid_start]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -action is $action, a -vcid_start is required. \
                        Please supply this value."
                return $returnList
            }
            
            if {![info exists pw_type]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -action is $action, a -pw_type is required. \
                        Please supply this value."
                return $returnList
            }
            
            if {![info exists l2tpv3_cc_handles_array($cc_handle,port)] \
                        || ![info exists l2tpv3_cc_handles_array($cc_handle,subport)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Cannot find\
                        the cc handle $cc_handle in the\
                        l2tpv3_cc_handles_array"
                return $returnList
            }
        }
        
        # When mode is delete/modify check if session_handle is present
        if {($action == "delete") || ($action == "modify")} {
            if {![info exists session_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -action is $action, a -session_handle is required. \
                        Please supply this value."
                return $returnList
            }
        }
        
        # When mode is create/modify check attachement circuit parameters
        if {(($action == "create") || ($action == "modify")) \
                && [info exists pw_type]} {
            
            if {($pw_type == "ethernet") || ($pw_type == "dot1q_ethernet")} {
                if {![info exists mac_src]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When the\
                            -pw_type is set to $pw_type, a -mac_src is\
                            required.  Please supply this value."
                    return $returnList
                }
                
                if {![info exists mac_dst]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When the\
                            -pw_type is set to $pw_type, a -mac_dst is\
                            required.  Please supply this value."
                    return $returnList
                }
            }
            
            if {($pw_type == "dot1q_ethernet") \
                        && ![info exists vlan_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -pw_type is set to $pw_type, a -vlan_id is required. \
                        Please supply this value."
                return $returnList
            }
            
            if {($pw_type == "frame_relay") && ![info exists fr_dlci_value]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the\
                        -pw_type is set to $pw_type, a -fr_dlci_value\
                        is required.  Please supply this value."
                return $returnList
            }
            
            if {$pw_type == "atm"} {
                if {![info exists vpi]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When the\
                            -pw_type is set to $pw_type, a -vpi is required. \
                            Please supply this value."
                    return $returnList
                }
                
                if {![info exists vci]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When the\
                            -pw_type is set to $pw_type, a -vci is required. \
                            Please supply this value."
                    return $returnList
                }
            }
        }
        
        # When mode is create/modify check if tosByte is present
        if {($action == "create") || ($action == "modifiy")} {
            if {[info exists ip_tos] && ($ip_tos == "fixed")} {
                if {![info exists ip_tos_value]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When the\
                            -ip_tos is set to $ip_tos, a -ip_tos_value is\
                            required.  Please supply this value."
                    return $returnList
                }
            }
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::updateL2tpv3CcHandleArray
#
# Description:
#    This command creates or deletes an element in l2tpv3_cc_handles_array.
#
#    An element in l2tpv3_cc_handles_array is in the form of
#         ($cc_handle,port)          port used by the group
#         ($cc_handle,subport)       subport used by the group
#         ($cc_handle,numRouters)    number of tunnels
#         ($cc_handle,ccIdStart)     first cc id in group
#         ($cc_handle,routerIdStart) first router id in group
#         ($cc_handle,ipConfig)      ip configuration parameters (source,
#                                    destination and gateway)
#         ($cc_handle,options)       l2tp options
#         ($cc_handle,traffic)       traffic configuration options
#         ($cc_handle,imix)          imix configuration options
#    where $cc_handle is the cc group handle
#
# Synopsis:
#    ::ixia::updateL2tpv3CcHandleArray
#        -mode CHOICES create modify delete
#        [-ccHandle]
#        [-port]
#        [-subport]
#        [-numRouters]
#        [-ccIdStart]
#        [-routerIdStart]
#        [-ipConfig]
#        [-options]
#        [-traffic]
#        [-imix]
#
# Arguments:
#    -mode
#        This option defines the action to be taken. Valid choices are:
#        create - inserts a value in array
#        modify - update the options list
#        delete - when -ccHandle option is present, the specified key is
#            deleted from array. If -port is present, all keys having port
#            value equal with the option are deleted.
#    -cc_handle
#        Cc group handle. Used as key in array.
#    -port
#        Port on which the tunnels are created.
#    -subport
#        Subport on which the tunnels are created.
#    -numRouters
#        Number of routers (tunnels) created on the subport.
#    -ccIdStart
#        Control connections have ids starting with ccIdStart to
#        ccId_start + numRouters - 1.
#    -routerIdStart
#        The routers have ids starting with router_id_start to
#        router_id_start + num_routers - 1.
#    -ipConfig
#        List containing IP configuration parameters.
#    -options
#        List containing names and values of the l2tp parameters.
#    -traffic
#        List containing traffic configuration options.
#    -imix
#        List containing imix rates and sizes.
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
proc ::ixia::updateL2tpv3CcHandleArray { args } {
    variable l2tpv3_cc_handles_array
    
    set procName [lindex [info level [info level]] 0]
    
    set mandatory_args {
        -mode CHOICES create modify delete
    }
    
    set optional_args {
        -ccHandle
        -port
        -subport
        -numRouters
        -ccIdStart
        -routerIdStart
        -ipConfig
        -options
        -traffic
        -imix
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args \
                    -optional_args $optional_args     \
                    -mandatory_args $mandatory_args   }]} {
        return $::TCL_ERROR
    }
    
    # Create
    if {$mode == "create"} {
        set l2tpv3_cc_handles_array($ccHandle,port)          $port
        set l2tpv3_cc_handles_array($ccHandle,subport)       $subport
        set l2tpv3_cc_handles_array($ccHandle,numRouters)    $numRouters
        set l2tpv3_cc_handles_array($ccHandle,ccIdStart)     $ccIdStart
        set l2tpv3_cc_handles_array($ccHandle,routerIdStart) $routerIdStart
        set l2tpv3_cc_handles_array($ccHandle,ipConfig)      $ipConfig
    }
    
    # Modify
    if {$mode == "modify"} {
        # Modify l2tpv3 options
        if {[info exists options]} {
            if {[info exists l2tpv3_cc_handles_array($ccHandle,options)]} {
                array set oldOptionsArray \
                        $l2tpv3_cc_handles_array($ccHandle,options)
            } else  {
                array set oldOptionsArray ""
            }
            array set newOptionsArray $options
            
            foreach optionName [array names newOptionsArray] {
                set oldOptionsArray($optionName) $newOptionsArray($optionName)
            }
            
            set optionList [array get oldOptionsArray]
            set l2tpv3_cc_handles_array($ccHandle,options) $optionList
        }
        
        # Modify traffic options
        if {[info exists traffic]} {
            if {[info exists l2tpv3_cc_handles_array($ccHandle,traffic)]} {
                array set oldOptionsArray \
                        $l2tpv3_cc_handles_array($ccHandle,traffic)
            } else  {
                array set oldOptionsArray ""
            }
            array set newOptionsArray $traffic
            
            foreach optionName [array names newOptionsArray] {
                set oldOptionsArray($optionName) $newOptionsArray($optionName)
            }
            
            set optionList [array get oldOptionsArray]
            set l2tpv3_cc_handles_array($ccHandle,traffic) $optionList
        }
        
        # Modify imix options
        if {[info exists imix]} {
            set l2tpv3_cc_handles_array($ccHandle,imix) $imix
        }
    }
    
    # Delete
    if {$mode == "delete"} {
        if {[info exists ccHandle]} {
            array unset l2tpv3_cc_handles_array $ccHandle,*
            updateL2tpv3SessionHandleArray -mode delete -ccHandle $ccHandle
        } elseif {[info exists port]} {
            foreach {handle intf} [array get l2tpv3_cc_handles_array "*,port"] {
                if {$port == $intf} {
                    set ccHandle [string range $handle 0 end-5]
                    array unset l2tpv3_cc_handles_array $ccHandle,*
                    updateL2tpv3SessionHandleArray -mode delete \
                            -ccHandle $ccHandle
                }
            }
        }
    }
    
    return $::TCL_OK
}


##Internal Procedure Header
# Name:
#    ::ixia::nextL2tpv3CcHandle
#
# Description:
#    Returns the next available cc group handle to be used in
#    l2tpv3_cc_handles_array.
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    cc_handle
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::nextL2tpv3CcHandle {} {
    variable l2tpv3_cc_handles_array
    
    set orderedNames [lsort -dictionary [array names l2tpv3_cc_handles_array]]
    set lastName [lindex $orderedNames end]
    regsub {([^0-9]+)([0-9]+).*} $lastName {\2} lastValue
    set newValue [expr $lastValue + 1]
    return "ccHandle$newValue"
}


##Internal Procedure Header
# Name:
#    ::ixia::updateL2tpv3SessionHandleArray
#
# Description:
#    This command creates or deletes an element in l2tpv3_session_handles_array.
#
#    An element in l2tpv3_session_handles_array is in the form of
#         ($session_handle,ccHandle)   session group belongs to this cc group
#         ($session_handle,vcidInfo)   [list firstVcid vcidStep numSessions]
#         ($session_handle,pwType)     pseudo-wire type
#         ($session_handle,acParams)   list containing AC params
#         ($session_handle,tosByte)    tos byte value
#         ($session_handle,ipParams)   list containing AC ip config
#
#    where $group_range_handle is the group range handle
#
# Synopsis:
#    ::ixia::updateL2tpv3SessionHandleArray
#        -mode CHOICES create modify delete
#        [-sessionHandle]
#        [-ccHandle]
#        [-vcidInfo]
#        [-pwType]
#        [-acParams]
#        [-tosByte]
#        [-ipParams]
#
# Arguments:
#    -mode
#        This option defines the action to be taken. Valid choices are:
#        create - inserts a value in array
#        delete - when -session_handle option is present, the specified
#            key is deleted from array. If -ccHandle is present, all keys
#            having ccHandle value equal with the option are deleted.
#    -session_handle
#        Session group handle. It is used as key in array.
#    -ccHandle
#        Cc group handle. Saved as value associated with the session handle.
#    -vcidInfo
#        Vcid data for the sessions. (list containing first vcid, number of
#        sessions and vcid step)
#    -pwType
#        Type of attachement circuit (ethernet, VLAN, frame relay, ATM).
#    -acParams
#        Attachement circuit params. Info related to configuration of ethernet,
#        VLAN, frame relay and ATM traffic.
#    -tosByte
#        Type Of Service byte value.
#    -ipParams
#        IP address configuration for the attachement circuits.
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
proc ::ixia::updateL2tpv3SessionHandleArray { args } {
    variable l2tpv3_session_handles_array
    
    set procName [lindex [info level [info level]] 0]
    
    set mandatory_args {
        -mode CHOICES create modify delete
    }
    
    set optional_args {
        -sessionHandle
        -ccHandle
        -vcidInfo
        -pwType
        -acParams
        -tosByte
        -qosParams
        -ipParams
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args \
                    -optional_args  $optional_args    \
                    -mandatory_args $mandatory_args   }]} {
        return $::TCL_ERROR
    }
    
    # Create
    if {$mode == "create"} {
        set l2tpv3_session_handles_array($sessionHandle,ccHandle)  $ccHandle
        set l2tpv3_session_handles_array($sessionHandle,vcidInfo)  $vcidInfo
        set l2tpv3_session_handles_array($sessionHandle,pwType)    $pwType
        set l2tpv3_session_handles_array($sessionHandle,acParams)  $acParams
        set l2tpv3_session_handles_array($sessionHandle,tosByte)   $tosByte
        set l2tpv3_session_handles_array($sessionHandle,qosParams) $qosParams
    }
    
    # Modify
    if {$mode == "modify"} {
        if {[info exists pwType]} {
            set l2tpv3_session_handles_array($sessionHandle,pwType)    $pwType
        }
        if {[info exists acParams]} {
            set l2tpv3_session_handles_array($sessionHandle,acParams)  $acParams
        }
        if {[info exists tosByte]} {
            set l2tpv3_session_handles_array($sessionHandle,tosByte)   $tosByte
        }
        if {[info exists qosParams]} {
            set l2tpv3_session_handles_array($sessionHandle,qosParams) $qosParams
        }
        if {[info exists ipParams]} {
            set l2tpv3_session_handles_array($sessionHandle,ipParams)  $ipParams
        }
    }
    
    # Delete
    if {$mode == "delete"} {
        if {[info exists sessionHandle]} {
            array unset l2tpv3_session_handles_array $sessionHandle,*
        } elseif {[info exists ccHandle]}  {
            set handlesList [array get l2tpv3_session_handles_array *,ccHandle]
            foreach {session handle} $handlesList {
                if {$handle == $ccHandle} {
                    set sessionHandle [string range $session 0 end-9]
                    array unset l2tpv3_session_handles_array $sessionHandle,*
                }
            }
        }
    }
    
    return $::TCL_OK
}


##Internal Procedure Header
# Name:
#    ::ixia::nextL2tpv3SessionHandle
#
# Description:
#    Returns the next available session group handle to be used in
#    l2tpv3_session_handles_array.
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    l2tpv3_session_handle
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::nextL2tpv3SessionHandle {} {
    variable l2tpv3_session_handles_array
    
    set orderedNames [lsort -dictionary \
            [array names l2tpv3_session_handles_array *,ccHandle]]
    set lastName [lindex $orderedNames end]
    regsub {l2tpv3/session([0-9]+).*} $lastName {\1} lastValue
    set newValue [expr $lastValue + 1]
    
    return "l2tpv3/session$newValue"
}


##Internal Procedure Header
# Name:
#    ::ixia::l2tpv3CreateConfiguration
#
# Description:
#    This procedure creates the configuration for the specified cc groups
#    and writes the configurations to the ports.  Then it creates the
#    operations for starting and stoping the sessions.
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:If status is failure, contains more information
#    key:handle    value:Control connection group handle
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
proc ::ixia::l2tpv3CreateConfiguration {ccHandleList} {
    variable l2tpv3_cc_handles_array
    variable l2tpv3_session_handles_array
    upvar procName procName
    
    array set pseudoWireTypes [list                          \
            ethernet        $::kIxAccessVcTypeEthernet       \
            dot1q_ethernet  $::kIxAccessVcTypeEthernetTagged \
            frame_relay     $::kIxAccessVcTypeFrameRelay     \
            atm             $::kIxAccessVcTypeAtmAal5Sdu     ]
    
    # Create port list
    set portList ""
    foreach ccHandle $ccHandleList {
        set port $l2tpv3_cc_handles_array($ccHandle,port)
        lappend portList [split $port /]
    }
    
    # Build configuration for each control group
    foreach ccHandle $ccHandleList {
        set interface [split $l2tpv3_cc_handles_array($ccHandle,port) /]
        foreach {chassis card port} $interface {}
        set subport $l2tpv3_cc_handles_array($ccHandle,subport)
        set numRouters $l2tpv3_cc_handles_array($ccHandle,numRouters)
        set firstRouter $l2tpv3_cc_handles_array($ccHandle,routerIdStart)
        set lastRouter [expr $firstRouter + $numRouters - 1]
        set sessionsPerTunnel [::ixia::l2tpv3GetNumberOfSessions $ccHandle]
        set totalSessions [expr $sessionsPerTunnel * $numRouters]
        
        if {$totalSessions == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: No session group\
                    configured for cc group $ccHandle on port\
                    $chassis.$card.$port."
            return $returnList
        }

        ixAccessPort setFactoryDefault $chassis $card $port
        
        set retCode [ixAccessSetupPorts [list "$chassis $card $port"]]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to setup port\
                    $chassis.$card.$port. \
                    Status: [ixAccessGetErrorString $retCode]"
            return $returnList
        }
        
        ixAccessPort get $chassis $card $port
        ixAccessPort setDefault
        ixAccessPort config -portRole $::kIxAccessRole
        if [port isActiveFeature $chassis $card $port $::portFeatureAtm] {
            ixAccessPort config -txMode $::kIxAccessPacketStream
        } else {
            ixAccessPort config -txMode $::kIxAccessAdvanceStream
        }
        set retCode [ixAccessPort set $chassis $card $port]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to set port\
                    parameters for port $chassis.$card.$port. \
                    Status: [ixAccessGetErrorString $retCode]"
            return $returnList
        }
        
        # Set subport
        ixAccessSubPort config -portMode $::kIxAccessPERouterEthernet
        ixAccessSubPort config -numSessions $totalSessions
        set retCode [ixAccessSubPort set $chassis $card $port $subport]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to set subport\
                    parameters for subport $chassis.$card.$port.$subport. \
                    Status: [ixAccessGetErrorString $retCode]"
            return $returnList
        }
        
        # Init IP config parameters from l2tp_cc_handles_array
        set ipConfig $l2tpv3_cc_handles_array($ccHandle,ipConfig)
        foreach {srcIp srcIpStep srcIpSubnetMask srcMac} \
                [lindex $ipConfig 0] {}
        foreach {dstIp dstIpStep} [lindex $ipConfig 1] {}
        foreach {gatewayIp gatewayStep} [lindex $ipConfig 2] {}
        foreach {enableUnconnectedIntf baseUnconnectedIp} \
                [lindex $ipConfig 3] {}
        
        # Set IP addresses
        ixAccessAddrList get $chassis $card $port $subport
        ixAccessAddrList clearAllAddr
        ixAccessAddrList configure -enableIp 1
        catch {ixAccessAddrList configure \
                -enableUnconnectedInterface $enableUnconnectedIntf}
        ixAccessAddrList set $chassis $card $port $subport
        
        ixAccessAddr setDefault
        ixAccessAddr config -addrId        "Addr_0"
        ixAccessAddr config -numAddress    $numRouters
        ixAccessAddr config -baseMac       $srcMac
        ixAccessAddr config -baseIP        $srcIp
        ixAccessAddr config -gatewayIP     $gatewayIp
        ixAccessAddr config -incrOctet     4
        ixAccessAddr config -baseIpIncr    $srcIpStep
        ixAccessAddr config -gatewayIpIncr $gatewayStep
        ixAccessAddr config -mask          $srcIpSubnetMask
        if {$enableUnconnectedIntf} {
            catch {ixAccessAddr config -baseUnconnectedIP $baseUnconnectedIp}
        }
        
        set retCode [ixAccessAddrList addAddr]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to set address\
                    parameters for $chassis.$card.$port.  Status:\
                    [ixAccessGetErrorString $retCode]"
            return $returnList
        }
        
        # Initialize L2tp parameters
        ixAccessL2tp setDefault
        ixAccessL2tp config -l2tpVersion       $::kIxAccessL2tpVersion3
        ixAccessL2tp config -sessionsPerTunnel $sessionsPerTunnel
        ixAccessL2tp config -localRouterIdStep 1
        ixAccessL2tp config -peerRouterIdStep  1
        ixAccessL2tp config -basePeerIp        $dstIp
        ixAccessL2tp config -peerIpIncr        $dstIpStep
        ixAccessL2tp config -numLocalRouters   $numRouters
        
        set optionList $l2tpv3_cc_handles_array($ccHandle,options)
        foreach {name value} $optionList {
            ixAccessL2tp config -$name $value
        }
        
        set retCode [ixAccessL2tp set $chassis $card $port $subport]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to set L2TP\
                    parameters for $chassis.$card.$port.$subport.  Status:\
                    [ixAccessGetErrorString $retCode]"
            return $returnList
        }
        
        # Create the sessions
        set trafficGroupId 1
        set sessionHandleList [::ixia::l2tpv3GetSessionList $ccHandle]
        foreach sessionHandle $sessionHandleList {
            # Init the variables
            set vcidInfo $l2tpv3_session_handles_array($sessionHandle,vcidInfo)
            foreach {vcidStart vcidStep numSessions} $vcidInfo {}
            set tosByte   $l2tpv3_session_handles_array($sessionHandle,tosByte)
            set pwType    $l2tpv3_session_handles_array($sessionHandle,pwType)
            set acParams  $l2tpv3_session_handles_array($sessionHandle,acParams)
            set qosParams $l2tpv3_session_handles_array($sessionHandle,qosParams)
            
            if {[info exists l2tpv3_session_handles_array($sessionHandle,ipParams)] \
                    && $l2tpv3_session_handles_array($sessionHandle,ipParams) != ""} {
                set trfIpParams \
                        $l2tpv3_session_handles_array($sessionHandle,ipParams)
                foreach {trfIpSrcParams trfIpDstParams} $trfIpParams {}
                foreach {trfSrcIp trfSrcIpStep} $trfIpSrcParams {}
                foreach {trfDstIp trfDstIpStep} $trfIpDstParams {}
            } else  {
                set trfSrcIp     0.0.0.0
                set trfSrcIpStep 0
                set trfDstIp     0.0.0.0
                set trfDstIpStep 0
            }
            
            switch -- $pwType {
                ethernet -
                dot1q_ethernet {
                    set macInfo [lindex $acParams 0]
                    set vlanInfo [lindex $acParams 1]
                    
                    foreach {macSrc macSrcStep macDst macDstStep} $macInfo {}
                    foreach {vlanId vlanStep} $vlanInfo {}
                    
                    set macSrc [::ixia::convertToIxiaMac $macSrc]
                    set macDst [::ixia::convertToIxiaMac $macDst]
                    set macSrcStep [::ixia::convertToIxiaMac $macSrcStep]
                    set macDstStep [::ixia::convertToIxiaMac $macDstStep]
                }
                frame_relay {
                    foreach {frDlciValue frDlciStep} $acParams {}
                }
                atm {
                    set vpiInfo [lindex $acParams 0]
                    set vciInfo [lindex $acParams 1]
                    
                    foreach {vpi vpiStep} $vpiInfo {}
                    foreach {vci vciStep} $vciInfo {}
                }
                default {
                }
            }
            
            # Create Qos group
            set resultList [::ixia::l2tpv3CreateQos $chassis $card $port \
                    $sessionHandle $tosByte $qosParams $totalSessions]
            
            if {[keylget resultList status] == $::FAILURE} {
                return $resultList
            }
            set qosGroupId [keylget resultList group]
            
            # For each router add pseudowires
            set peerIp $dstIp
            for {set i $firstRouter} {$i <= $lastRouter} {incr i} {
                ixAccessPseudoWiresTable select $chassis $card $port $subport $i
                
                # Create pseudowires
                set vcid $vcidStart
                for {set j 1} {$j <= $numSessions} {incr j} {
                    set pwDescription [::ixia::getL2tpv3PwDescription $subport \
                            $i $vcid]
                    set trfDescription [::ixia::getL2tpv3TrfDescription \
                            $subport $i $vcid]
                    
                    ixAccessPseudoWires config -description  $pwDescription
                    ixAccessPseudoWires config -pseudoWireId $vcid
                    ixAccessPseudoWires config -numPseudoWires 1
                    ixAccessPseudoWires config -pseudoWireType \
                            $pseudoWireTypes($pwType)
                    ixAccessPseudoWires config -peerIpAddress $peerIp
                    
                    set retCode [ixAccessPseudoWiresTable add]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to\
                                add PseudoWire to PseudoWiresTable\
                                for $chassis.$card.$port.$subport.$i.  Status:\
                                [ixAccessGetErrorString $retCode]"
                        return $returnList
                    }
                    
                    # Create pseudo-wire traffic
                    set resultList [::ixia::l2tpv3CreatePwTraffic]
                    if {[keylget resultList status] == $::FAILURE} {
                        return $resultList
                    }
                    
                    incr vcid $vcidStep
                }
                
                set peerIp [::ixia::increment_ipv4_address_hltapi $peerIp \
                        $dstIpStep]
            }
        }
        
        # Set traffic options
        set resultList [::ixia::l2tpv3CreateTraffic $chassis $card $port \
                $ccHandle]
        if {[keylget resultList status] == $::FAILURE} {
            return $resultList
        }
        
        # Write the configuration on the port
        set retCode [ixAccessWriteConfig [list [list $chassis $card $port]]]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to write port\
                    parameters for $chassis.$card.$port.  Status:\
                    [ixAccessGetErrorString $retCode]"
            return $returnList
        }
        
        # Check for the write config to finish on all the ports (10 seconds)
        set retCode [ixAccessPort checkCmdStatus $chassis $card $port 10000]
        if {$retCode != $::kIxAccessCmdStatusOk} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to write port\
                    parameters for $chassis.$card.$port.  Status: $retCode"
            return $returnList
        }
        
        set resultList [::ixia::l2tpv3CreatePortOperations $chassis $card \
                $port $totalSessions]
        if {[keylget resultList status] == $::FAILURE} {
            return $resultList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l2tpv3CreatePwTraffic
#
# Description:
#    This procedure creates the pw traffic entries for the current pseudowire.
#    It executes in the scope of the calling procedure.
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:If status is failure, contains more information
#    key:handle    value:Control connection group handle
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
proc ::ixia::l2tpv3CreatePwTraffic {} {
    uplevel 1 {
        # Create Pseudo-wire Traffic Group
        ixAccessPwTrafficGroupTable select $chassis $card $port $subport
        ixAccessPwTrafficGroup setDefault
        ixAccessPwTrafficGroup config -pwTrafficGroupId $trafficGroupId
        ixAccessPwTrafficGroup config -srcIp $trfSrcIp
        ixAccessPwTrafficGroup config -dstIp $trfDstIp
        
        set trfSrcIp [::ixia::increment_ipv4_address $trfSrcIp 4 $trfSrcIpStep]
        set trfDstIp [::ixia::increment_ipv4_address $trfDstIp 4 $trfDstIpStep]
        
        if {($pwType == "ethernet") || ($pwType == "dot1q_ethernet")} {
            ixAccessPwTrafficGroup config -srcMac $macSrc
            ixAccessPwTrafficGroup config -dstMac $macDst
            
            set macSrc [::ixia::incrementMacAdd $macSrc $macSrcStep]
            set macDst [::ixia::incrementMacAdd $macDst $macDstStep]
        }
        
        set retCode [ixAccessPwTrafficGroupTable add]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    add PwTrafficGroup to PwTrafficGroupTable\
                    for $chassis.$card.$port.  Here Status:\
                    [ixAccessGetErrorString $retCode]"
            return $returnList
        }
        
        # Create Pseudo-wire Traffic
        ixAccessPwTraffic setDefault
        ixAccessPwTraffic config -description $pwDescription
        ixAccessPwTraffic config -dstPortId "0.0.0"
        ixAccessPwTraffic config -qosGroupId  $qosGroupId
        switch -- $pwType {
            ethernet -
            dot1q_ethernet {
                ixAccessPwTraffic config -vlan $vlanId
                ixAccessPwTraffic config -numVcs [expr $vlanId ? 1 : 0]
                
                incr vlanId $vlanStep
            }
            frame_relay {
                ixAccessPwTraffic config -dlci $frDlciValue
                ixAccessPwTraffic config -numVcs 1
                
                incr frDlciValue $frDlciStep
            }
            atm {
                ixAccessPwTraffic config -vpi $vpi
                ixAccessPwTraffic config -vci $vci
                ixAccessPwTraffic config -numVcs 1
                
                incr vpi $vpiStep
                incr vci $vciStep
            }
            default {
            }
        }
        
        set retCode [ixAccessPwTraffic set $chassis $card $port $subport \
                $trafficGroupId $trfDescription]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    set PwTraffic for\
                    $chassis.$card.$port.$subport.$trafficGroupId. \
                    Status: [ixAccessGetErrorString $retCode]"
            return $returnList
        }
        
        incr trafficGroupId
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
}


proc ::ixia::l2tpv3CreateTraffic {chassis card port ccHandle} {
    variable l2tpv3_cc_handles_array
    upvar 1 procName procName
    
    set trafficOptionNamesList [list                              \
            frameSizeMode     frameSize           streamTxMode    \
            rateMode          percentageLineRate  packetPerSecond \
            bitsPerSecond     trafficType         numFrames       \
            numBursts         enableVariableUserRate              ]
    
    set trafficOptionList ""
    set imixList ""
    catch {set trafficOptionList $l2tpv3_cc_handles_array($ccHandle,traffic)}
    catch {set imixList $l2tpv3_cc_handles_array($ccHandle,imix)}
    if {$trafficOptionList != ""} {
        if {$imixList != ""} {
            set retCode [ixAccessImixTable select $chassis $card $port]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to select\
                        imix table for port $chassis.$card.$port.  Status:\
                        [ixAccessGetErrorString $retCode]"
                return $returnList
            }
            ixAccessImixTable clearAllImix
            
            foreach {frameSize ratio} $imixList {
                ixAccessImix config -frameSize $frameSize
                ixAccessImix config -ratio $ratio
                ixAccessImix config -enable 1
                
                set retCode [ixAccessImixTable addImix]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            add imix in imix table for port\
                            $chassis.$card.$port.  Status:\
                            [ixAccessGetErrorString $retCode]"
                    return $returnList
                }
            }
        }
        
        ixAccessTraffic get $chassis $card $port
        ixAccessTraffic setDefault
        ixAccessTraffic config -enablePerSessionStats  true
        ixAccessTraffic config -frameSizeMode          $::kIxAccessFrameSizeL3
        
        array set trafficOptionArray $trafficOptionList
        foreach optionName $trafficOptionNamesList {
            if {[info exists trafficOptionArray($optionName)]} {
                set optionValue $trafficOptionArray($optionName)
                ixAccessTraffic config -$optionName $optionValue
            }
        }
        
        set retCode [ixAccessTraffic set $chassis $card $port]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to set\
                    traffic for port $chassis.$card.$port.  Status:\
                    [ixAccessGetErrorString $retCode]"
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l2tpv3CreatePortOperations
#
# Description:
#    This procedure creates the operations required to start/stop the sessions
#    on the specified port.
#
# Synopsis:
#
# Arguments:
#    chassis
#    card
#    port
#    numSessions
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:If status is failure, contains more information
#    key:handle    value:Control connection group handle
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
proc ::ixia::l2tpv3CreatePortOperations {chassis card port numSessions} {
    upvar 1 procName procName
    
    ixAccessProfile select $chassis $card $port
    ixAccessProfile delAllOperations
    
    ixAccessOperation setDefault
    ixAccessOperation configure -opId                   setup1
    ixAccessOperation configure -startSession           1
    ixAccessOperation configure -endSession             $numSessions
    ixAccessOperation configure -operation              $::kIxAccessSetup
    ixAccessOperation configure -rate                   300
    ixAccessOperation configure -opMode                 $::kIxAccessModeConstant
    ixAccessOperation configure -triggerEvent           $::kIxAccessCommand
    ixAccessOperation configure -delayAfterTrigger      0
    ixAccessOperation configure -maxOutstandingSessions 1000
    ixAccessOperation configure -opList                 ""
    
    set retCode [ixAccessProfile addOperation]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to create setup\
                operation for $chassis.$card.$port.  Status:\
                [ixAccessGetErrorString $retCode]"
        return $returnList
    }
    
    ixAccessOperation setDefault
    ixAccessOperation configure -opId                   teardown
    ixAccessOperation configure -startSession           1
    ixAccessOperation configure -endSession             $numSessions
    ixAccessOperation configure -operation              $::kIxAccessTeardown
    ixAccessOperation configure -rate                   300
    ixAccessOperation configure -opMode                 $::kIxAccessModeConstant
    ixAccessOperation configure -triggerEvent           $::kIxAccessCommand
    ixAccessOperation configure -delayAfterTrigger      0
    ixAccessOperation configure -maxOutstandingSessions 1000
    ixAccessOperation configure -opList                 ""
    
    set retCode [ixAccessProfile addOperation]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to create teardown\
                operation for $chassis.$card.$port.  Status:\
                [ixAccessGetErrorString $retCode]"
        return $returnList
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l2tpv3CreateQos
#
# Description:
#    This procedure creates a qos group with one qos object inside it.
#
# Synopsis:
#
# Arguments:
#    chassis
#    card
#    port
#    qosGroupId
#    tosByte
#    sessions
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:If status is failure, contains more information
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
proc ::ixia::l2tpv3CreateQos {chassis card port qosGroupId tosByte qosParams sessions} {
    upvar 1 procName procName
    variable l2tpv3_session_handles_array
    array set qosParamsArray $qosParams
    
    ixAccessQosGroupTable select $chassis $card $port
    # Maximum number of qosGroups is 8
    # If max value has been reached then all following sessions will be added
    # to a QoSGroup that has the same tosByte or to a random QoSGroup
    if {[ixAccessQosGroupTable cget -numQosGroups ] == 8} {
        set allTosBytes [array get l2tpv3_session_handles_array \
                *${chassis}/${card}/${port}*,tosByte]
        
        if {[set posTos [lsearch $allTosBytes $tosByte]] != -1} {
            set qosGroupId [lindex [split [lindex $allTosBytes \
                    [expr $posTos - 1]] ,] 0]
        } else  {
            set qosGroupId [lindex [split [lindex $allTosBytes 0] ,] 0]
        }
        keylset returnList status $::SUCCESS
        keylset returnList group  $qosGroupId
        return $returnList
    }
    
    ixAccessQosGroup setDefault
    ixAccessQosGroup config -qosGroupId $qosGroupId
    ixAccessQosGroup config -rateMode   $qosParamsArray(rateMode)
    
    set retCode [ixAccessQosGroupTable add]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to add qos group\
                for $chassis.$card.$port.  Status:\
                [ixAccessGetErrorString $retCode]"
        return $returnList
    }
    
    # Add multiple QoS Items if required
    for {set i 0} {$i < [llength $tosByte]} {incr i} {
        ixAccessQos setDefault
        foreach {option value} $qosParams {
            if {[lindex $value $i] == ""} {
                set optValue [lindex $value end]
            } else  {
                set optValue [lindex $value $i]
            }
            if {($option == "percentageLineRate") || \
                        ($option == "packetPerSecond") ||  \
                        ($option == "bitsPerSecond")} {
                
                catch {ixAccessQos config -$option [mpexpr \
                            $optValue / $sessions]}
            } else  {
                catch {ixAccessQos config -$option $optValue}
            }
        }
        set iTosByte [lindex $tosByte $i]
        if {$iTosByte != 0} {
            set reserved    [expr $iTosByte & 0x01]
            set cost        [expr ($iTosByte >> 1) & 0x01]
            set reliability [expr ($iTosByte >> 2) & 0x01]
            set throughput  [expr ($iTosByte >> 3) & 0x01]
            set delay       [expr ($iTosByte >> 4) & 0x01]
            set precedence  [expr ($iTosByte >> 5) & 0x07]
            
            ixAccessQos config -reserved    $reserved
            ixAccessQos config -cost        $cost
            ixAccessQos config -reliability $reliability
            ixAccessQos config -throughput  $throughput
            ixAccessQos config -delay       $delay
            ixAccessQos config -precedence  $precedence
        }
        set retCode [ixAccessQos set $chassis $card $port \
                $qosGroupId [expr $i + 1]]
        
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to set qos object\
                    for $chassis.$card.$port.$qosGroupId.[expr $i + 1].  Status:\
                    [ixAccessGetErrorString $retCode]"
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList group  $qosGroupId
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::getL2tpv3PwDescription
#
# Description:
#    Creates a pseudowire description based on subport, router and vcid.
#
# Synopsis:
#
# Arguments:
#    subport    Subport id
#    router     Router id
#    vcid       Vcid
#
# Return Values:
#    pseudowireDescription
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::getL2tpv3PwDescription {subport router vcid} {
    set pwDescription "pw_${subport}_${router}_${vcid}"
    return $pwDescription
}


##Internal Procedure Header
# Name:
#    ::ixia::getL2tpv3TrfDescription
#
# Description:
#    Creates a pseudowire traffic description based on subport, router 
#    and vcid.
#
# Synopsis:
#
# Arguments:
#    subport    Subport id
#    router     Router id
#    vcid       Vcid
#
# Return Values:
#    pseudowireTrafficDescription
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::getL2tpv3TrfDescription {subport router vcid} {
    set trfDescription "trf_${subport}_${router}_${vcid}"
    return $trfDescription
}


##Internal Procedure Header
# Name:
#    ::ixia::getL2tpv3ConfiguredPortList
#
# Description:
#    Returns the list of ports on which control connections are configured.
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    portList
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::getL2tpv3ConfiguredPortList {} {
    variable l2tpv3_cc_handles_array
    
    set portHandleList ""
    foreach {ccHandle portHandle} [array get l2tpv3_cc_handles_array *,port] {
        if {[lsearch $portHandleList $portHandle] == -1} {
            lappend portHandleList $portHandle
        }
    }
    
    set portList ""
    foreach portHandle $portHandleList {
        foreach {chassis card port} [split $portHandle /] {}
        lappend portList [list $chassis $card $port]
    }
    
    return $portList
}


##Internal Procedure Header
# Name:
#    ::ixia::getL2tpv3CcHandleUsingPort
#
# Description:
#    Returns the cc group handle configured on the specified port, if such
#    a group exists. If no group is found, returns the empty string.
#
# Synopsis:
#
# Arguments:
#    portHandle
#
# Return Values:
#    ccHandle     - if one is found
#    empty string - if no handle is found
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::getL2tpv3CcHandleUsingPort {portHandle} {
    variable l2tpv3_cc_handles_array
    
    set portHandleList ""
    foreach {ccHandle port} [array get l2tpv3_cc_handles_array *,port] {
        if {$portHandle == $port} {
            return [string range $ccHandle 0 end-5]
        }
    }
    
    return ""
}


##Internal Procedure Header
# Name:
#    ::ixia::l2tpv3GetNumberOfSessions
#
# Description:
#    Returns the total number of pseudowires which will be configured on the
#    specified control connection group.
#
# Synopsis:
#
# Arguments:
#    ccHandle
#
# Return Values:
#    totalSessions - total number of sessions
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::l2tpv3GetNumberOfSessions {ccHandle} {
    variable l2tpv3_session_handles_array
    
    set totalSessions 0
    set sessionList [::ixia::l2tpv3GetSessionList $ccHandle]
    foreach sessionHandle $sessionList {
        set vcidInfo $l2tpv3_session_handles_array($sessionHandle,vcidInfo)
        set numSessions [lindex $vcidInfo 2]
        incr totalSessions $numSessions
    }
    
    return $totalSessions
}


##Internal Procedure Header
# Name:
#    ::ixia::l2tpv3GetSessionList
#
# Description:
#    Returns the list of sessions configured on the specified control
#    connection group.
#
# Synopsis:
#
# Arguments:
#    ccHandle
#
# Return Values:
#    sessionList
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::l2tpv3GetSessionList {ccHandle} {
    variable l2tpv3_session_handles_array
    
    set sessionList ""
    set handlesList [array get l2tpv3_session_handles_array *,ccHandle]
    foreach {session handle} $handlesList {
        if {$handle == $ccHandle} {
            set sessionHandle [string range $session 0 end-9]
            lappend sessionList $sessionHandle
        }
    }
    
    return $sessionList
}


##Internal Procedure Header
# Name:
#    ::ixia::l2tpv3GetCcHandles
#
# Description:
#    Returns the list of control connection groups configured on the ports
#    specified in the list.
#
# Synopsis:
#
# Arguments:
#    portList
#
# Return Values:
#    ccHandleList
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::l2tpv3GetCcHandles {portList} {
    variable l2tpv3_cc_handles_array
    
    set portHandleList ""
    foreach port $portList {
        foreach {chassis card port} $port {}
        lappend portHandleList "${chassis}/${card}/${port}"
    }
    
    set ccHandleList ""
    foreach {ccHandle portHandle} [array get l2tpv3_cc_handles_array *,port] {
        if {[lsearch $portHandleList $portHandle] != -1} {
            lappend ccHandleList [string range $ccHandle 0 end-5]
        }
    }
    
    return $ccHandleList
}


##Internal Procedure Header
# Name:
#    ::ixia::l2tpv3TrafficConfig
#
# Description:
#    This command adds or modifies traffic information for a session group. 
#    IxAccess allows traffic configuration to be set at a port level. 
#    This means that except for ip addresses all the parameters will 
#    be set on all sessions which belong to the same control connection. 
#    The options ip_src_count and ip_dst_count are ignored and the values 
#    set for the attachement circuits are used (eg. if 10 mac_addreses were 
#    created then 10 ip addresses are created)
# 
# Synopsis:
#    ::ixia::l2tpv3TrafficConfig
#        -port_handle ^[0-9]+/[0-9]+/[0-9]+$
#        -mode CHOICES create modify
#        -emulation_src_handle
#        [-length_mode CHOICES fixed imix]
#        [-l3_length RANGE 32-9000]
#        [-l3_imix1_size RANGE 32-9000]
#        [-l3_imix1_ratio NUMERIC]
#        [-l3_imix2_size RANGE 32-9000]
#        [-l3_imix2_ratio NUMERIC]
#        [-l3_imix3_size RANGE 32-9000]
#        [-l3_imix3_ratio NUMERIC]
#        [-l3_imix4_size RANGE 32-9000]
#        [-l3_imix4_ratio NUMERIC]
#        [-rate_pps]
#        [-rate_bps]
#        [-rate_percent RANGE 0-100]
#        [-transmit_mode CHOICES continuous single_pkt single_burst 
#                                multi_burst continuous_burst]
#        [-pkts_per_burst NUMERIC]
#        [-burst_loop_count NUMERIC]
#        [-ip_src_addr IP]
#        [-ip_src_mode CHOICES fixed increment decrement]
#        [-ip_src_count RANGE 1-1000000]
#        [-ip_src_step IP]
#        [-ip_dst_addr IP]
#        [-ip_dst_mode CHOICES fixed increment decrement]
#        [-ip_dst_count RANGE 1-1000000]
#        [-ip_dst_step IP]
#        [-adjust_rate CHOICES 0 1]
#
# Arguments:
#    -mode
#    -port_handle
#    -emulation_src_handle
#    -length_mode
#    -l3_length
#    -l3_imix1_size
#    -l3_imix1_ratio
#    -l3_imix2_size
#    -l3_imix2_ratio
#    -l3_imix3_size
#    -l3_imix3_ratio
#    -l3_imix4_size
#    -l3_imix4_ratio
#    -rate_pps
#    -rate_bps
#    -rate_percent
#    -transmit_mode
#    -pkts_per_burst
#    -burst_loop_count
#    -ip_src_addr
#    -ip_src_mode
#    -ip_src_count
#    -ip_src_step
#    -ip_dst_addr
#    -ip_dst_mode
#    -ip_dst_count
#    -ip_dst_step
#    -adjust_rate
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
proc ::ixia::l2tpv3TrafficConfig {args} {
    variable l2tpv3_session_handles_array
    variable current_streamid
    
    set procName [lindex [info level [info level]] 0]
    
    set mandatory_args {
        -port_handle          REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -mode                 CHOICES create modify
        -emulation_src_handle
    }
    set optional_args {
        -length_mode          CHOICES fixed imix
        -l3_length            RANGE 32-9000
        -l3_imix1_size        RANGE 32-9000
        -l3_imix1_ratio       NUMERIC
                              DEFAULT 100
        -l3_imix2_size        RANGE 32-9000
        -l3_imix2_ratio       NUMERIC
                              DEFAULT 100
        -l3_imix3_size        RANGE 32-9000
        -l3_imix3_ratio       NUMERIC
                              DEFAULT 100
        -l3_imix4_size        RANGE 32-9000
        -l3_imix4_ratio       NUMERIC
                              DEFAULT 100
        -rate_pps
        -rate_bps
        -rate_percent         RANGE 0-100
        -transmit_mode        CHOICES continuous single_pkt single_burst
                              CHOICES multi_burst continuous_burst
        -pkts_per_burst       NUMERIC
        -burst_loop_count     NUMERIC
        -ip_src_addr          IP
        -ip_src_mode          CHOICES fixed increment decrement
                              DEFAULT increment
        -ip_src_count         RANGE 1-1000000
        -ip_src_step          IP
                              DEFAULT 0.0.0.1
        -ip_dst_addr          IP
        -ip_dst_mode          CHOICES fixed increment decrement
                              DEFAULT increment
        -ip_dst_count         RANGE 1-1000000
        -ip_dst_step          IP
                              DEFAULT 0.0.0.1
        -adjust_rate          CHOICES 0 1
        -variable_user_rate   CHOICES 0 1
                              DEFAULT 0
        -l7_traffic           CHOICES 0 1
                              DEFAULT 0
        -duration             NUMERIC
                              DEFAULT 10
        -session_repeat_count RANGE 1-8000
                              DEFAULT 1
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args \
                    $optional_args -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Parameter not supported\
                for L2tpv3 emulations. $retError"
        return $returnList
    }
    array set trafficOptionsArray [list              \
            trafficType            length_mode       \
            frameSize              l3_length         \
            packetPerSecond        rate_pps          \
            bitsPerSecond          rate_bps          \
            percentageLineRate     rate_percent      \
            streamTxMode           transmit_mode     \
            numFrames              pkts_per_burst    \
            numBursts              burst_loop_count  \
            enableVariableUserRate variable_user_rate\
            enableLayer7Traffic    l7_traffic        \
            duration               duration          \
            session_repeat_count   sessionRepeatCount]
    
    array set enumList [list                              \
            fixed            $::kIxAccessTrafficFixed     \
            imix             $::kIxAccessTrafficImix      \
            continuous       $::kIxAccessTxModeContPacket \
            single_pkt       $::kIxAccessTxModeBurst      \
            single_burst     $::kIxAccessTxModeBurst      \
            multi_burst      $::kIxAccessTxModeBurst      \
            continuous_burst $::kIxAccessTxModeContBurst  ]
    
    if {![info exists l2tpv3_session_handles_array($emulation_src_handle,ccHandle)]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Cannot find the\
                session handle $emulation_src_handle in the\
                l2tpv3_session_handles_array"
        return $returnList
    }
    
    # Common for create and modify. Set the traffic options.
    set trafficOptionList ""

    if {[info exists transmit_mode]} {
        switch -- $transmit_mode {
            single_pkt {
                set pkts_per_burst 1
                set burst_loop_count 1
            }
            single_burst {
                set burst_loop_count 1
            }
            default {}
        }
    }
    
    foreach {item itemName} [array get trafficOptionsArray] {
        if {![catch {set $itemName} value] } {
            if {[lsearch [array names enumList] $value] != -1} {
                set value $enumList($value)
            }
            lappend trafficOptionList $item $value
        }
    }
    
    # Set the means by which line rates will be specified
    set rateMode ""
    if {[info exists rate_percent]} {
        set rateMode $::kIxAccessLineUtilization
    }
    if {[info exists rate_bps]} {
        set rateMode $::kIxAccessBitPerSec
    }
    if {[info exists rate_pps]} {
        set rateMode $::kIxAccessPacketPerSec
    }
    if {$rateMode != ""} {
        lappend trafficOptionList rateMode $rateMode
    }
    
    # Set imix parameter list
    set imixList ""
    for {set i 1} {$i <= 4} {incr i} {
        if {[info exists l3_imix${i}_size]} {
            set imixSize  [set l3_imix${i}_size]
            set imixRatio [set l3_imix${i}_ratio]
            lappend imixList $imixSize $imixRatio
        }
    }
    
    set ccHandle $l2tpv3_session_handles_array($emulation_src_handle,ccHandle)
    
    # Save the configuration
    ::ixia::updateL2tpv3CcHandleArray   \
            -mode modify                \
            -ccHandle $ccHandle         \
            -traffic $trafficOptionList \
            -imix $imixList
    
    # When mode is create set IP parameters
    if {$mode == "create"} {
        if {![info exists ip_src_addr]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -ip_src_addr is required.  Please supply this\
                    value."
            return $returnList
        }
        if {![info exists ip_dst_addr]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -ip_dst_addr is required.  Please supply this\
                    value."
            return $returnList
        }
        
        set srcIpStep [::ixia::ip_addr_to_num $ip_src_step]
        set dstIpStep [::ixia::ip_addr_to_num $ip_dst_step]
        
        if {$ip_src_mode == "fixed"} {
            set srcIpStep 0
        } elseif {$ip_src_mode == "decrement"} {
            set srcIpStep [mpexpr -$srcIpStep]
        }
        if {$ip_dst_mode == "fixed"} {
            set dstIpStep 0
        } elseif {$ip_dst_mode == "decrement"} {
            set dstIpStep [mpexpr -$dstIpStep]
        }
        
        set srcIpParams [list $ip_src_addr $srcIpStep]
        set dstIpParams [list $ip_dst_addr $dstIpStep]
        set ipParams    [list $srcIpParams $dstIpParams]
        
        ::ixia::updateL2tpv3SessionHandleArray       \
                -mode modify                         \
                -sessionHandle $emulation_src_handle \
                -ipParams $ipParams
    }
    
    incr current_streamid
    
    keylset returnList status    $::SUCCESS
    keylset returnList stream_id $current_streamid
    return $returnList
}
