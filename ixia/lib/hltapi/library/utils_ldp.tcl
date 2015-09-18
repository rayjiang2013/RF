##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_ldp.tcl
#
# Purpose:
#    Utility functions to suspport LDP protocol config/control
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
#    ::ixia::updateLdpHandleArray
#
# Description:
#    This command creates or deletes an element in ldp_handles_array.
#    
#    An element in ldp_handles_array is in the form of
#         ldp_handles_array($session_handle,session)  port_handle
#              
#    where $session_handle is the router handle,
#    and port_handle is in the form of $chassNum/$cardNum/$portNum.  
#
# Synopsis:
#
# Arguments:
#    mode - choices are: create, delete, reset
#    port_handle -  specifies the chassis/card/port        
#    handle -       session_handle
#
# Return Values:
#    $::TCL_OK for success
#    $::TCL_ERROR for failure to delete an element
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
proc ::ixia::updateLdpHandleArray {mode port_handle {handle NULL}} {
    variable  ldp_handles_array

    set procName [lindex [info level [info level]] 0]       
    set retCode $::TCL_OK

    switch $mode {
        create {
            set ldp_handles_array($handle,session) [list $port_handle]
        }
        delete {
            set ldpHandleList [array get ldp_handles_array]
            set match [lsearch $ldpHandleList ${handle},session]
            if {$match >= 0} {
                array unset ldp_handles_array ${handle},session
            } else {
                puts "Error in $procName:  Cannot delete the $handle in\
                        ldp_handle_array"
                set retCode $::TCL_ERROR
            }
        }
        reset {
            array unset ldp_handles_array $port_handle*
        }
    }
    return $retCode
}


##Internal Procedure Header
# Name:
#    ::ixia::create_ldp_route_array
# Description:
#    Creates ldp arrays of IxTclHal option to Cisco option pair for
#    each fec type. In addition, a higher layer array is
#    created to map the "fec type" to the name of the array
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
proc ::ixia::create_ldp_route_array {} {

    variable ldpCommandOptionsArray
    variable ldpRequestFecRangeArray
    variable ldpAdvertiseFecRangeArray
    variable ldpL2VpnInterfaceArray
    variable ldpL2VpnVcRangeArray
    variable ldpEnumList

    array set ldpCommandOptionsArray [list \
            ipv4_prefix \
            [list [list ldpAdvertiseFecRange ldpAdvertiseFecRangeArray]] \
            host_addr   \
            [list [list ldpRequestFecRange   ldpRequestFecRangeArray]]   \
            vc          \
            [list [list ldpL2VpnInterface    ldpL2VpnInterfaceArray]     \
            [list ldpL2VpnVcRange          ldpL2VpnVcRangeArray]]        \
            ]

    array set ldpRequestFecRangeArray [list \
            enable                      local_enable            \
            numRoutes                   num_routes              \
            networkIpAddress            fec_host_addr           \
            maskWidth                   fec_host_prefix_length  \
            enableHopCountTlv           hop_count_tlv_enable    \
            hopCount                    hop_count_value         \
            nextHopPeerIp               next_hop_peer_ip        \
            enableStaleTimer            stale_timer_enable      \
            staleRequestTime            stale_request_time      ]

    array set ldpAdvertiseFecRangeArray [list \
            enable                      local_enable            \
            labelIncrementMode          egress_label_mode       \
            numRoutes                   num_lsps                \
            networkIpAddress            fec_ip_prefix_start     \
            maskWidth                   fec_ip_prefix_length    \
            enablePacking               packing_enable          \
            labelValueStart             label_value_start       ]

    array set ldpL2VpnInterfaceArray [list \
            enable                  local_enable                \
            type                    fec_vc_type                 \
            groupId                 fec_vc_group_id             \
            count                   fec_vc_group_count          ]

    array set ldpL2VpnVcRangeArray [list \
            enable                  local_enable                \
            count                   fec_vc_id_count             \
            enableCBit              fec_vc_cbit                 \
            vcId                    fec_vc_id_start             \
            vcIdStep                fec_vc_id_step              \
            enableMtu               fec_vc_intf_mtu_enable      \
            mtuSize                 fec_vc_intf_mtu             \
            description             fec_vc_intf_desc            \
            enableDescription       local_vc_intf_desc_enable   \
            enablePacking           packing_enable              \
            labelMode               fec_vc_label_mode           \
            labelValueStart         fec_vc_label_value_start    \
            peerAddress             fec_vc_peer_address         ]

    array set ldpEnumList [list \
            fixed                   $::ldpAdvertiseFecRangeFixed    \
            nextlabel               $::ldpAdvertiseFecRangeIncrement\
            fixed_label             $::ldpL2VpnVcFixedLabel         \
            increment_label         $::ldpL2VpnVcIncrementLabel     \
            fr_dlci                 $::l2VpnInterfaceFrameRelay     \
            atm_aal5_vcc            $::l2VpnInterfaceATMAAL5        \
            atm_cell                $::l2VpnInterfaceATMXCell       \
            eth_vlan                $::l2VpnInterfaceVLAN           \
            eth                     $::l2VpnInterfaceEthernet       \
            hdlc                    $::l2VpnInterfaceHDLC           \
            ppp                     $::l2VpnInterfacePPP            \
            cem                     $::l2VpnInterfaceCEM            \
            atm_vcc_n_1             $::l2VpnInterfaceATMVCC         \
            atm_vpc_n_1             $::l2VpnInterfaceATMVPC         \
            eth_vpls                $::l2VpnInterfaceEthernetVPLS   \
            atm_vcc_1_1             $::l2VpnInterfaceATMVCC         \
            atm_vpc_1_1             $::l2VpnInterfaceATMVPC         ]
}


##Internal Procedure Header
# Name:
#    ::ixia::createLdpRouteObject
# Description:
#    Creates new route element to the session_handle.  This is done by
#    configuring and adding ldpRequestFecRange, ldpAdvertiseFecRange,
#    ldpL2VpnInterface, or ldpL2VpnVcRange IxTclHal objects to ldpRouter.    
#
# Synopsis:
#
# Arguments:    
#    handle -       session_handle
#    port_handle -  specifies the chassis/card/port        
#    args  -        options passed in from emulation_ldp_route_config.  These 
#                   options are used to set the IxTclHal's command options 
#
# Return Values:    
#    lsp_handle - the route element handle is returned
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
proc ::ixia::createLdpRouteObject {handle port_handle args} {
    
    variable ldpCommandOptionsArray
    variable ldpRequestFecRangeArray
    variable ldpAdvertiseFecRangeArray
    variable ldpL2VpnInterfaceArray
    variable ldpL2VpnVcRangeArray
    variable ldpEnumList
    
    set procName [lindex [info level [info level]] 0]
  
    ### upvar all the command options
    set args [join $args]
    foreach item $args {
        if {[string first - $item] == 0} {
            set option [string trimleft $item -]
            upvar $option $option
        }
    }

    set local_enable $::true

    ### Get the next element handle. 
    switch $fec_type {
        ipv4_prefix {
            set lsp_handle [ixia::getNextLabel ldpRouter AdvertiseFecRange \
                    ldp $port_handle]
            if {$egress_label_mode == "imnull"} {
                set egress_label_mode   fixed
                set label_value_start   3
            } elseif {$egress_label_mode == "exnull"} {
                set egress_label_mode   fixed
                set label_value_start   0
            }
        }
        host_addr {
            set lsp_handle [ixia::getNextLabel ldpRouter RequestFecRange \
                    ldp $port_handle]
        }
        vc {
            set lsp_handle [ixia::getNextLabel ldpRouter L2VpnInterface \
                    ldp $port_handle]
            ### there's only one l2VpnVcRange per ldpL2VpnInterface
            ### therefore, the vcrange_handle is fixed.
            set vcrange_handle ldp_vcRange1

            if {[info exists fec_vc_intf_desc]} {
                set local_vc_intf_desc_enable   1
            } else {
                set local_vc_intf_desc_enable   0
            }
        }
    }

    set ldpCommandParamLists $ldpCommandOptionsArray($fec_type)

    ### Configure the command options for each type of network
    foreach commandParam $ldpCommandParamLists {
        set command [lindex $commandParam 0]
        $command setDefault
        set paramsArray [lindex $commandParam 1]
        foreach {item itemName} [array get $paramsArray] {
            if {![catch {set $itemName} value] } {
                if {[lsearch [array names ldpEnumList] $value] != -1} {
                    set value $ldpEnumList($value)
                }
                ### debug
                #puts "--- $command config -$item $value"
                catch {$command config -$item $value}
            }
        }
    }

    ### Add the new element to ldpRouter
    switch $fec_type {
        ipv4_prefix {
            if {[ldpRouter addAdvertiseFecRange $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter addRequestFecRange\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
        host_addr {
            if {[ldpRouter addRequestFecRange $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter addRequestFecRange\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
        vc {
            if {[ldpL2VpnInterface addL2VpnVcRange $vcrange_handle]} {
                puts "ERROR in $procName: ldpL2VpnInterface addL2VpnVcRange\
                        $vcrange_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
            if {[ldpRouter addL2VpnInterface $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter addL2VpnInterface\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
    }

    if {[ldpServer setRouter $handle]} {
        puts "ERROR in $procName: ldpServer setRouter $handle command failed.\
                \n$::ixErrorInfo"                  
        return NULL
    }
    return $lsp_handle                   
}


##Internal Procedure Header
# Name:
#    ::ixia::modifyLdpRouteObject
# Description:
#    Modify the topology element    
#
# Synopsis:
#
# Arguments:    
#    args  -  options passed in from emulation_ldp_route_config. These  
#             options specify the parameters to be modified in the fec/lsp
#             route range configuration. 
#
# Return Values:    
#    lsp_handle - the lsp pool handle is returned
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
proc ::ixia::modifyLdpRouteObject {args} {

    variable ldpCommandOptionsArray
    variable ldpRequestFecRangeArray
    variable ldpAdvertiseFecRangeArray
    variable ldpL2VpnInterfaceArray
    variable ldpL2VpnVcRangeArray
    variable ldpEnumList

    set procName [lindex [info level [info level]] 0]
  
    ### upvar all the command options
    set args [join $args]
    foreach item $args {
        if {[string first - $item] == 0} {
            set option [string trimleft $item -]
            upvar $option $option
        }
    }

    ### figure out the type of element from the lsp_handle
    set fec_type [getFecTypeFromLsaHandle $lsp_handle]

    set local_enable $::true

    ### Get the element from the IxOs  
    switch $fec_type {
        ipv4_prefix {
            if {[ldpRouter getAdvertiseFecRange $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter getAdvertiseFecRange\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
        host_addr {
            if {[ldpRouter getRequestFecRange $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter getRequestFecRange\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
        vc {
            if {[ldpRouter getL2VpnInterface $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter getL2VpnInterface\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
            ### there's only one l2VpnVcRange per ldpL2VpnInterface
            ### therefore, the vcrange_handle is fixed.

            set vcrange_handle ldp_vcRange1
            if {[ldpL2VpnInterface getL2VpnVcRange $vcrange_handle]} {
                puts "ERROR in $procName: ldpL2VpnInterface getL2VpnVcRange\
                        $vcrange_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
    }

    set ldpCommandParamLists $ldpCommandOptionsArray($fec_type)

    ### Configure the command options for each type of network
    foreach commandParam $ldpCommandParamLists {
        set command [lindex $commandParam 0]
        set paramsArray [lindex $commandParam 1]
        foreach {item itemName} [array get $paramsArray] {
            if {![catch {set $itemName} value] } {
                if {[lsearch [array names ldpEnumList] $value] != -1} {
                    set value $ldpEnumList($value)
                }
                ### debug
                ##puts "--- $command config -$item $value"
                catch {$command config -$item $value}
            }
        }
    }

    ### Add the new element to ldpRouter
    switch $fec_type {
        ipv4_prefix {
            if {[ldpRouter setAdvertiseFecRange $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter setAdvertiseFecRange\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
        host_addr {
            if {[ldpRouter setRequestFecRange $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter setRequestFecRange\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
        vc {
            if {[ldpL2VpnInterface setL2VpnVcRange $vcrange_handle]} {
                puts "ERROR in $procName: ldpL2VpnInterface setL2VpnVcRangee\
                        $vcrange_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
            if {[ldpRouter setL2VpnInterface $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter setL2VpnInterface\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
    }
    return $lsp_handle
}


##Internal Procedure Header
# Name:
#    ::ixia::deleteLdpRouteObject
# Description:
#
# Synopsis:
#
# Arguments:    
#    handle -      session_handle
#    lsp_handle -  lsp pool handle to delete
#
# Return Values:  
#    lsp_handle  - lsp_handle is returned if the route object
#                  pointed by lsp_handle is deleted successfully.
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
proc ::ixia::deleteLdpRouteObject {handle lsp_handle} {

    set procName [lindex [info level [info level]] 0]       

    ### figure out the type of element from the lsp_handle
    set fec_type [getFecTypeFromLsaHandle $lsp_handle]

    ### Add the new element to ldpRouter
    switch $fec_type {
        ipv4_prefix {
            if {[ldpRouter delAdvertiseFecRange $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter delAdvertiseFecRange\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
        host_addr {
            if {[ldpRouter delRequestFecRange $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter delRequestFecRange\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
        vc {
            if {[ldpRouter delL2VpnInterface $lsp_handle]} {
                puts "ERROR in $procName: ldpRouter delL2VpnInterface\
                        $lsp_handle command failed.\n$::ixErrorInfo"
                return NULL
            }
        }
    }

    if {[ldpServer setRouter $handle]} {
        puts "ERROR in $procName: ldpServer setRouter $handle command failed.\
                \n$::ixErrorInfo"                  
        return NULL
    }

    return $lsp_handle
}


##Internal Procedure Header
# Name:
#    ::ixia::getFecTypeFromLsaHandle
# Description:
#    This proc examines the lsp_handle string and figures out fec_type.  
#
# Synopsis:
#
# Arguments:    
#
# Return Values: 
#    fec_type which is one of ipv4_prefix, host_addr, vc   
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
proc ::ixia::getFecTypeFromLsaHandle {lsp_handle} {

    set procName [lindex [info level [info level]] 0]       

    if {[string first ldpAdvertiseFecRange $lsp_handle] != -1} {
        return ipv4_prefix
    }

    if {[string first ldpRequestFecRange $lsp_handle] != -1} {
        return host_addr
    }

    if {[string first ldpL2VpnInterface $lsp_handle] != -1} {
        return vc
    } else {
        puts "Error in $procName:  cannot find the fec_type from lsp_handle:\
                $lsp_handle.  fec_type is defaulted to ipv4_prefix"
        return ipv4_prefix
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::cleanup_ldp_route_arrays
# Description:
#    Removes the ldp configuration arrays in ::ixia scope
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
proc ::ixia::cleanup_ldp_route_arrays {} {

    variable ldpCommandOptionsArray
    variable ldpRequestFecRangeArray
    variable ldpAdvertiseFecRangeArray
    variable ldpL2VpnInterfaceArray
    variable ldpL2VpnVcRangeArray
    variable ldpEnumList

    catch {unset ldpCommandOptionsArray}
    catch {unset ldpRequestFecRangeArray}
    catch {unset ldpAdvertiseFecRangeArray}
    catch {unset ldpL2VpnInterfaceArray}
    catch {unset ldpL2VpnVcRangeArray}
    catch {unset ldpEnumList}
}


##Internal Procedure Header
# Name:
#    ::ixia::getNextLdpRouter
#
# Description:
#    This command gets the next LDP router handle
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
proc ::ixia::getNextLdpRouter { serverCommand session_type port_handle } {

    set router_number 0

    if {[ldpServer getFirstRouter]} {
        incr router_number
        return ${port_handle}LdpRouter$router_number
    } else {
        incr router_number
        while {[ldpServer getNextRouter] == 0} {
            incr router_number
        }
        incr router_number
        return ${port_handle}LdpRouter$router_number
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::initializeLdp
#
# Description:
#    This command initializes the LDP to its initial default configuration.
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
proc ::ixia::initializeLdp {chasNum cardNum portNum} {
    
    set retCode $::TCL_OK

    if {[ldpServer select $chasNum $cardNum $portNum]} {
        set retCode $::TCL_ERROR
    }
    if {[ldpServer clearAllRouters]} {
        set retCode $::TCL_ERROR
    }
    if {[ldpServer set]} {
        set retCode $::TCL_ERROR
    }

    return $retCode
}


##Internal Procedure Header
# Name:
#    ::ixia::actionLdp
#
# Description:
#    This command deletes/enables/disables the LDP router
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
proc ::ixia::actionLdp {chasNum cardNum portNum mode handle} {

    keylset returnList status $::SUCCESS

    # Select LDP server
    if {[ldpServer select $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure in call to ldpServer select $chasNum\
                $cardNum $portNum."
        return $returnList
    }

    if {$mode == "delete"} {
        if {[ldpServer delRouter $handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure in call to ldpServer delRouter\
                    $handle on port $chasNum $cardNum $portNum."
        } else {
            if {[ldpServer set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure on call to ldpServer set\
                        on port $chasNum $cardNum $portNum."
            }
        }

        return $returnList

    } elseif {($mode == "disable") || ($mode == "enable")} {

        if {[ldpServer getRouter $handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to ldpServer getRouter\
                    $handle on port $chasNum $cardNum $portNum."
        }

        if {$mode == "enable"} {
            ldpRouter config -enable $::true
        } elseif {$mode == "disable"} {
            ldpRouter config -enable $::false
        }

        if {[ldpServer setRouter $handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to ldpServer setRouter\
                    $handle on port $chasNum $cardNum $portNum."
        }

        if {[ldpServer set]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to ldpServer set on\
                    port $chasNum $cardNum $portNum."
        }
        
        return $returnList
    }
}
