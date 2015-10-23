##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_rip_api.tcl
#
# Purpose:
#     A script development library containing RIP APIs for test automation with 
#     the Ixia chassis.
#
# Author:
#    Radu Antonescu
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#    - emulation_rip_config
#    - emulation_rip_control
#    - emulation_rip_route_config
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     parseddashedargs.tcl , a library containing the proceDescr and 
#     parsedashedargds.tcl
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

proc ::ixia::ixnetwork_rip_config { args man_args opt_args } {
    variable objectMaxCount
    variable ixnetwork_port_handles_array
    set procName ixnetwork_rip_config

    set objectCount 0
    
    # on modify mode we could have rip and ripng handles.
    if {[regexp -- {-mode\s+modify} $args]} {
        set args [join $args]
        set modify_mode 1
        if {![regexp -- "-handle((\\s+(\[^-\](\[\\w:/-\])+))+)"\
                $args all handles]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Parameter -handle must be specified in\
                    modify mode."
            return $returnList
        }
        set ripng_args $args
        set ripng_enable 0
        set rip_enable   0
        foreach handle $handles {
            if {[regexp -- "::ixNet::OBJ-/vport:\\d+/protocols/rip/router:\\d+"\
                        $handle]} {
                set rip_enable 1
                if {[set handle_pos [lsearch $ripng_args $handle]] == -1} {
                    debug "lsearch $ripng_args $handle returned '-1'.\
                            This should never happen (debug purpose only)"
                }
                set ripng_args [lreplace $ripng_args $handle_pos\
                        $handle_pos]
            }
            if {[regexp -- "::ixNet::OBJ-/vport:\\d+/protocols/ripng/router:\\d+"\
                        $handle]} {
                set ripng_enable 1
                if {[set handle_pos [lsearch $args $handle]] == -1} {
                    debug "lsearch $args $handle returned '-1'. This\
                            should never happen (debug purpose only)"
                }
                set args [lreplace $args $handle_pos $handle_pos]
            }
        }
    } else {
        set modify_mode 0
    }
    if {$modify_mode == 0 || ($modify_mode == 1 && $ripng_enable == 1)} {
        if {$modify_mode == 1} {
            set ripng_status [::ixia::ixnetwork_ripng_config $ripng_args\
                    $man_args $opt_args]
        } else {
            set ripng_status [::ixia::ixnetwork_ripng_config $args $man_args\
                    $opt_args]
        }
        if {[keylget ripng_status status] != $::SUCCESS} {
            return $ripng_status
        } elseif {![catch {keylget ripng_status cont} err]} {
            if {$err == 0} {
                keyldel ripng_status cont
                if {$modify_mode == 0 || $rip_enable == 0} {
                    return $ripng_status
                }
            }
        }
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {($mode == "create") && [info exists reset]} {
        catch {set port $ixnetwork_port_handles_array($port_handle)}
        if {![info exists port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in ::ixia::ixnetwork_rip_config : invalid \
                port_handle parameter $port_handle"
            return $returnList
        }
        set router_list [ixNet getList $port/protocols/rip router]
        foreach router $router_list {
            ixNet remove $router
        }
        ixNet commit
    }

    # setting params
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }

    if {$mode == "create" || $mode == "modify"} {
        if {[info exists receive_type]} {
            switch -- $receive_type {
                v1 {set receive_type receiveVersion1}
                v2 {set receive_type receiveVersion2}
                v1_v2 {set receive_type receiveVersion1And2}
                ignore {
                    # this feature are not implemented for RIPv1 and v2
                    unset receive_type
                }
                store {
                    # this feature are not implemented for RIPv1 and v2
                    unset receive_type
                }
                default {
                    set receive_type deleted
                }
            }
        }
        if {[info exists session_type]} {
            switch -- $session_type {
                ripv1 {
                    if {![info exists send_type]} {
                        set send_type broadcastV1
                    }
                    if {![info exists receive_type]} {
                      set receive_type receiveVersion1
                    }
                }
                ripv2 {
                    if {![info exists send_type]} {
                        set send_type broadcastV2
                    }
                    if {![info exists receive_type]} {
                      set receive_type receiveVersion2
                    }
                }
                ripng {
                    keylset returnList log "FAILURE on ::ixia::ixnetwork_rip_config :\
                        RIPng not yet supported"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
        }
        if {[info exists update_mode]} {
            switch -- $update_mode {
                no_horizon {set update_mode default}
                split_horizon {set update_mode splitHorizon}
                poison_reverse {set update_mode poisonReverse}
                discard {set update_mode silent}
            }
        }
        if {[info exists send_type]} {
            switch -- $send_type {
                multicast {set send_type multicast}
                broadcast_v1 {set send_type broadcastV1}
                broadcast_v2 {set send_type broadcastV2}
            }
        }
            
        set rip_options_list { \
                intf_objRef                 interfaceId
                update_interval             updateInterval
                update_interval_offset      updateIntervalOffset
                update_mode                 responseMode
                send_type                   sendType
                receive_type                receiveType
                enable_auth                 enableAuthorization
                password                    authorizationPassword
                update_interval_offset      updateIntervalOffset
        }
        if {[info exists authentication_mode]} {
            if {$authentication_mode == "null"} {
                unset authentication_mode
            } elseif {$authentication_mode == "text"} {
                set enable_auth true
            } elseif {$authentication_mode == "md5"} {
                unset authentication_mode
                ixPuts "WARNING: MD5 authentication not supported."
            }
        }
    }
    
    switch -- $mode {
        create {
            if {![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$procName: port_handle must be specified \
                in create mode"
                return $returnList
            }
            if {![info exists update_interval]} {
                set update_interval 30
            }
            if {![info exists update_interval_offset]} {
                set update_interval_offset 0
            }
            if {![info exists interface_handle]} {
                # setting interfaces
                if {![info exists neighbor_intf_ip_addr_step]} {
                    set neighbor_intf_ip_addr_step 0.0.0.0
                }
                if {![info exists intf_ip_addr_step]} {
                    set intf_ip_addr_step 0.0.0.1
                }
                
                set intf_param_list {
                    port_handle                     port_handle
                    intf_ip_addr                    ipv4_address
                    intf_ip_addr_step               ipv4_address_step
                    neighbor_intf_ip_addr           gateway_address
                    neighbor_intf_ip_addr_step      gateway_address_step
                    intf_prefix_length              ipv4_prefix_length
                    count                           count
                    vci                             atm_vci
                    vci_step                        atm_vci_step
                    vpi                             atm_vpi
                    vpi_step                        atm_vpi_step
                    atm_encapsulation               atm_encapsulation
                    vlan                            vlan_enabled
                    vlan_id                         vlan_id
                    vlan_id_mode                    vlan_id_mode
                    vlan_id_step                    vlan_id_step
                    vlan_user_priority              vlan_user_priority
                    mac_address_init                mac_address
                    mac_address_step                mac_address_step
                    override_existence_check        override_existence_check
                    override_tracking               override_tracking
                }
                
                set intf_command "::ixia::ixNetworkProtocolIntfCfg "
                foreach {hlt_param prot_intf_param} $intf_param_list {
                    if {[info exists $hlt_param]} {
                        append intf_command "-$prot_intf_param [set $hlt_param] "
                    }
                }
                set retCode [catch {set retList [eval $intf_command]}]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "error running \"[join $intf_command]\"."
                    return $returnList
                }
                if {[keylget retList status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget retList log]
                    return $returnList
                }
                set intf_list [keylget retList connected_interfaces]
                if {[llength $intf_list] < $count} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Some interfaces has not been created."
                    return $returnList
                }
            } else {
                if {[llength $interface_handle] != $count} {
                    keylset returnList status $::FAILURE
                    keylset returnList log {ERROR in proc ::ixia::ixnetwork_ospf_config: \
                        interface number does not match.}
                    return $returnList                
                }
                set intf_list $interface_handle
            }
            set port $ixnetwork_port_handles_array($port_handle)
            # Check if protocols are supported
            set retCode [checkProtocols $port]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Port $port_handle does not support protocol\
                        configuration."
                return $returnList
            }
            # need to detect interface object which will be created later
            set intf_objRef 0
            # prepare configuration command list
            set rip_config_command [list]
            foreach {param cmd} $rip_options_list {
                if {[info exists $param]} {
                    append rip_config_command \
                            "ixNet setAttr \$routerRip -$cmd \[set $param\];"
                }
            }
            # setting rip
            ixNet setAttr $port/protocols/rip -enabled true
            set router_list {}
            foreach intf_objRef $intf_list {
                set routerRip [ixNet add $port/protocols/rip router]
                ixNet setAttr $routerRip -enabled true
                eval [subst $rip_config_command]
                incr objectCount
                if { $objectCount == $objectMaxCount} {
                    ixNet commit
                    set objectCount 0
                }
                lappend router_list $routerRip
            }
            if {$objectCount > 0} {
                ixNet commit
            }
            if {[llength $router_list] > 0} {
                keylset returnList handle [ixNet remapIds $router_list]
            } else {
                keylset returnList handle {}
            }
            keylset returnList status $::SUCCESS
        }
        delete {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$procName: handle must be specified \
                in delete mode"
                return $returnList
            }
            foreach rip_item $handle {
                debug "ixNet remove $rip_item"
                if {[catch {ixNet remove $rip_item} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to delete $rip_item.\
                            $err"
                    return $returnList
                }
            }
            ixNet commit

            keylset returnList handle $handle
            keylset returnList status $::SUCCESS
        }
        modify {
            set intf_param_list {
                intf_ip_addr                    ipv4_address
                neighbor_intf_ip_addr           gateway_address
                intf_prefix_length              ipv4_prefix_length
                vci                             atm_vci
                vpi                             atm_vpi
                atm_encapsulation               atm_encapsulation
                vlan                            vlan_enabled
                vlan_id                         vlan_id
                vlan_user_priority              vlan_user_priority
                mac_address_init                mac_address
            }
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$procName: handle must be specified \
                in modify mode"
                return $returnList
            }
            
            # validate lists length
            set handle_list $handle
            set option_index 0
            foreach handle $handle_list {
                if {[catch {set intf_hnd [ixNet getAttr $handle -interfaceId]} \
                        errorMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR on $procName: $errorMsg."
                    return $returnList
                }
                # Getting handles
                set retCode [ixia::ixNetworkGetPortFromObj $handle]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "invalid object \
                            specified $handle."
                    return $returnList
                }
                set port_handle [keylget retCode port_handle]
                if {[string equal $port_handle ""]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR on $procName: invalid \
                            interface handle specified."
                    return $returnList
                }
                set intf_cmd_modify "::ixia::ixNetworkConnectedIntfCfg \
                        -prot_intf_objref $intf_hnd -port_handle $port_handle"
                foreach {hlt_param intf_param} $intf_param_list {
                    if {[info exists $hlt_param]} {
                        set option_value_list [set $hlt_param]
                        if {[llength $option_value_list] == 1} {
                            set option_value $option_value_list
                        } elseif {[llength $option_value_list] == \
                                [llength $handle_list]} {
                            set option_value [lindex $option_value_list \
                                    $option_index]
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR on $procName: list\
                                    length mismatch."
                            return $returnList
                        }
                        append intf_cmd_modify " -$intf_param $option_value"
                    }
                }
                if {[catch {set retCode [eval $intf_cmd_modify]} errorMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR on $procName: $errorMsg."
                    return $returnList
                }
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
                # setting rip parameters
                foreach {param cmd} $rip_options_list {
                    if {[info exists $param]} {
                        set option_value_list [set $param]
                        if {[llength $option_value_list] == 1} {
                            set option_value $option_value_list
                        } elseif {[llength $option_value_list] == \
                                [llength $handle_list]} {
                            set option_value [lindex [set $param] $option_index]
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR on $procName: list \
                                    length mismatch."
                            return $returnList
                        }
                        if [catch {ixNet setAttr $handle -$cmd $option_value}] {
                            keylset returnList log "FAILURE on $procName: \
                                attribute $cmd cannot be set on $handle."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                }
                incr objectCount
                if { $objectCount == $objectMaxCount} {
                    ixNet commit
                    set objectCount 0
                }
                incr option_index
            }
            if {$objectCount > 0} {
                ixNet commit
            }

            keylset returnList handle $handle
            keylset returnList status $::SUCCESS
        }
        enable {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$procName: handle must be specified \
                in enable mode"
                return $returnList
            }
            foreach rip_item $handle {
                ixNet setAttr $rip_item -enabled true
                ixNet commit
            }

            keylset returnList handle $handle
            keylset returnList status $::SUCCESS
        }
        disable {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$procName: handle must be specified \
                in disable mode"
                return $returnList
            }
            foreach rip_item $handle {
                ixNet setAttr $rip_item -enabled false
                ixNet commit
            }

            keylset returnList handle $handle
            keylset returnList status $::SUCCESS
        }
    }
    return $returnList
}

proc ::ixia::ixnetwork_rip_route_config { args mandatory_args optional_args } {
    
    set ripng_status [::ixia::ixnetwork_ripng_route_config $args            \
                                                           $mandatory_args  \
                                                           $optional_args   ]
    if {[keylget ripng_status status] != $::SUCCESS} {
        return $ripng_status
    } elseif {![catch {keylget ripng_status cont} err]} {
        if {$err == 0} {
            keyldel ripng_status cont
            return $ripng_status
        }
    } 

    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $optional_args\
            -mandatory_args $mandatory_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {[info exists reset] && $mode == "create"} {
        # delete all route ranges
        set routeRange_list [ixNet getList $handle routeRange]
        foreach routeRange $routeRange_list {
            ixNet remove $routeRange
        }
        ixNet commit
    }

    if {$mode == "create" || $mode == "modify"} {
        # init options list and params
        set route_option_list { \
                num_prefixes        noOfRoutes \
                prefix_start        firstRoute \
                prefix_length       maskWidth \
                metric              metric \
                next_hop            nextHop \
                route_tag           routeTag \
        }
    }
    switch -- $mode {
        create {
            set routerRipRange [ixNet add $handle routeRange]
            ixNet setAttr $routerRipRange -enabled true
            foreach {param cmd} $route_option_list {
                if {[info exists $param]} {
                    if [catch {ixNet setAttr $routerRipRange -$cmd [set $param]}] {
                        ixPuts "Warning: $param cannot be set."
                    }
                }
            }
            ixNet commit
            keylset returnList status $::SUCCESS
            keylset returnList route_handle [ixNet remapIds $routerRipRange]
            return $returnList
        }
        modify {
            if {![info exists route_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "route_handle must be used in modify mode."
                return $returnList
            }
            foreach handle $route_handle {
                foreach {param cmd} $route_option_list {
                    if {[info exists $param]} {
                        if [catch {ixNet setAttr $handle -$cmd [set $param]}] {
                            ixPuts "Warning: $param cannot be set."
                        }
                    }
                }
            }
        }
        delete {
            if {![info exists route_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "route_handle must be used in delete mode."
                return $returnList
            }
            foreach handle $route_handle {
                ixNet remove $handle
            }
        }
    }
    ixNet commit
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_rip_control { args man_args opt_args } {

    if {[catch {::ixia::parse_dashed_args -args $args\
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {[info exists mode]} {
        set port_handle_list {}
        if {[info exists port_handle]} {
            foreach port $port_handle {
                set tmpPortStatus [::ixia::ixNetworkGetPortObjref $port]
                if {[keylget tmpPortStatus status] != $::SUCCESS} {
                    return $tmpPortStatus
                }
                set port_obj [keylget tmpPortStatus vport_objref]
                lappend port_handle_list $port_obj

                # get RIP type
                set types ""
                set tmpStatus [::ixia::ixNetworkNodeGetList \
                        $port_obj/protocols/rip             \
                        "router"                            \
                        -all                                ]
                if {$tmpStatus != "" && $tmpStatus != [ixNet getNull]} {
                    lappend rip_type_array($port_obj) "rip"
                }
                
                set tmpStatus [::ixia::ixNetworkNodeGetList \
                        $port_obj/protocols/ripng           \
                        "router"                            \
                        -all                                ]
                if {$tmpStatus != "" && $tmpStatus != [ixNet getNull]} {
                    lappend rip_type_array($port_obj) "ripng"
                }
            }
        } elseif {[info exists handle]} {
            foreach hnd $handle {
                catch {unset err}
                if {[catch {::ixNet exists $hnd} err] ||\
                        ([info exists err] && ($err == "false" || $err == 0))} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Handle $hnd does not exist."
                    keylset returnList cont 0
                    return $returnList
                }
                if {![regexp -- {^::ixNet::OBJ-/vport:\d+} $hnd port_obj]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Cannot extract port object from handle."
                    return $returnList
                }
                lappend port_handle_list $port_obj
                
                # check rip type for specified handles
                if {[regexp -- {^::ixNet::OBJ-/vport:\d+/protocols/rip/} $hnd]} {
                    lappend rip_type_array($port_obj) rip
                } elseif {[regexp -- {^::ixNet::OBJ-/vport:\d+/protocols/ripng/} $hnd]} {
                    lappend rip_type_array($port_obj) ripng
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid RIP/RIPng handle $hnd."
                    return $returnList
                }
                # end of handle procesing
            }
        } else {
            keylget returnList status $::FAILURE
            keylset returnList log "Option -port_handle or -handle must be\
                    specified."
            return $returnList
        }
        foreach port_obj [lsort -unique $port_handle_list] {
            # start or stop or restart RIP
            if {[info exists rip_type_array($port_obj)]} {
                # Get HLT port handle
                set get_port_status [::ixia::ixNetworkGetPortFromObj  $port_obj]
                if {[keylget get_port_status status] == $::FAILURE} {
                    return $get_port_status
                }
                set tmp_hlt_porth [keylget get_port_status port_handle]
          
                foreach rip_type [lsort -unique $rip_type_array($port_obj)] {
                    set returnList [::ixia::ixNetworkProtocolControl \
                            "-protocol $rip_type -port_handle $tmp_hlt_porth -mode $mode" \
                            "-protocol ANY"             \
                            $opt_args                   ]
                    if {[keylget returnList status] == $::FAILURE} {
                        return $returnList
                    }
                }
            } else {
                set retCode [ixNetworkGetPortFromObj $port_obj]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
                keylset returnList status $::FAILURE
                keylset returnList log "No RIP/RIPng specified/found on\
                        [keylget retCode port_handle]"
                return $returnList
            }
        }
    }
    if {[info exists advertise]} {
        foreach item $advertise {
            catch {unset err}
            if {[catch {::ixNet exists $item} err] ||\
                    ([info exists err] && ($err == "false" || $err == 0))} {
                keylset returnList status $::FAILURE
                keylset returnList log "Route handle -adevertise $item does not\
                        exist."
                keylset returnList cont 0
                return $returnList
            }
            
            if {![regexp {^::ixNet::OBJ-/vport:\d+/protocols/ripng/router:\d+/routeRange:\d+} $item] &&\
                    ![regexp {^::ixNet::OBJ-/vport:\d+/protocols/rip/router:\d+/routeRange:\d+} $item]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid route handle -adevertise $item."
                keylset returnList cont 0
                return $returnList
            }
            debug "ixNet setAttr $item -enabled true"
            if [catch {ixNet setAttr $item -enabled true} err] {
                keylset returnList status $::FAILURE
                keylset returnList log "$err."
                return $returnList
            }
        }
    }
    if {[info exists withdraw]} {
        foreach item $withdraw {
            catch {unset err}
            if {[catch {::ixNet exists $item} err] ||\
                    ([info exists err] && ($err == "false" || $err == 0))} {
                keylset returnList status $::FAILURE
                keylset returnList log "Route handle -adevertise $item does not\
                        exist."
                keylset returnList cont 0
                return $returnList
            }
            
            if {![regexp {^::ixNet::OBJ-/vport:\d+/protocols/ripng/router:\d+/routeRange:\d+} $item] &&\
                    ![regexp {^::ixNet::OBJ-/vport:\d+/protocols/rip/router:\d+/routeRange:\d+} $item]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid route handle -withdraw $item."
                keylset returnList cont 0
                return $returnList
            }
            debug "ixNet setAttr $item -enabled false"
            if [catch {ixNet setAttr $item -enabled false} err] {
                keylset returnList status $::FAILURE
                keylset returnList log "$err."
                return $returnList
            }
        }
    }
    catch {ixNet commit}
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_ripng_config { args man_args opt_args } {
    variable ixnetworkVersion
    variable objectMaxCount
    
    keylset returnList status $::SUCCESS
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {$mode == "create"} {
        if {![info exists session_type] || $session_type != "ripng"} {
            keylset returnList status $::SUCCESS
            keylset returnList cont 1
            return $returnList
        }
        
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "No -port_handle was passed in mode -$mode."
            return $returnList
        }
        
        if {![info exists intf_ip_addr] && ![info exists interface_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "No -intf_ip_addr or -interface_handle was \
                    passed to in mode -$mode."
            return $returnList
        }
    } elseif {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    } else {
        # Other modes will be handled by ::ixia::ixnetwork_rip_config
        keylset returnList status $::SUCCESS
        keylset returnList cont 1
        return $returnList
    }
    
    array set enabledValue {
        create     true
        enable     true
        disable    false
    }
    
    array set updateMode {
        no_horizon      noSplitHorizon
        split_horizon   splitHorizon
        poison_reverse  poisonReverse
    }
    
    array set ripngRouterOptionsArray {
        enableInterfaceMetric   enable_interface_metric
        enabled                 router_enabled
        receiveType             receive_type
        routerId                router_id
        updateInterval          update_interval
        updateIntervalOffset    update_interval_offset
    }
    
    array set ripngInterfaceOptionsArray {
        enabled             interface_enabled
        interfaceMetric     interface_metric
        responseMode        update_mode
    }
    if {[info exists enabledValue($mode)]} {
        set router_enabled    $enabledValue($mode)
    }
    set interface_enabled true
    
    if {$mode == "create"} {
        # Add port after connecting to IxNetwork TCL Server
        set retCode [ixNetworkPortAdd $port_handle {} force]
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        set retCode [ixNetworkGetPortObjref $port_handle]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the port object reference \
                    associated to the $port_handle port handle -\
                    [keylget retCode log]."
            return $returnList
        }
        set vport_objref    [keylget retCode vport_objref]
        set protocol_objref [keylget retCode vport_objref]/protocols/ripng
        # Check if protocols are supported
        set retCode [checkProtocols $vport_objref]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Port $port_handle does not support protocol\
                    configuration."
            return $returnList
        }
        if {[info exists reset]} {
            set result [ixNetworkNodeRemoveList $protocol_objref \
                    { {child remove router} {} } -commit]
            if {[keylget result status] == $::FAILURE} {
                return $returnList
            }
        }
        
        # Enable RIPng
        set retCode [ixNetworkNodeSetAttr $protocol_objref "-enabled true" -commit]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
        
        if {![info exists gre_count] || $gre_count == 0} {
            set intf_gre_count 1
        } else {
            set intf_gre_count $gre_count
        }
        
        # Configure the protocol interfaces
        if {[info exists interface_handle] && ([llength $interface_handle] != \
                [expr $count * $intf_count * $intf_gre_count])} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -interface_handle list should have\
                    [expr $count * $intf_count * \
                    $intf_gre_count] elements. Currently it has\
                    [llength $interface_handle] elements."
            return $returnList
        } elseif {[info exists interface_handle]} {
            set intf_list [list]
            foreach intf $interface_handle {
                lappend intf_list $intf
            }
        } else {
            set connected_count [expr $intf_count * $count]
            
            if {![info exists gre_dst_ip_addr_step] && [info exists gre_dst_ip_addr]} {
                if {[isIpAddressValid $gre_dst_ip_addr]} {
                    set gre_dst_ip_addr_step 0.0.0.1
                } else {
                    set gre_dst_ip_addr_step [::ixia::expand_ipv6_addr 0::1]
                }
            }
            
            if {![info exists intf_ip_addr]} {
                keylset returnList status $::FAILURE
                keylset returnList log "-intf_ip_addr was not provided when\
                        -inteface_handle is missing."
                return $returnList
            }
            
            set ip_version "v6"
            if {![info exists gre_ipv6_addr]} {
                if {[isIpAddressValid $intf_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "-intf_ip_addr can be IPv4 only when\
                            router inteface is GRE."
                    return $returnList
                }
            } else {
                if {[isIpAddressValid $intf_ip_addr]} {
                    set ip_version "v4"
                }
            }
            
            switch -- $ip_version {
                "v6" {
                    if {![info exists intf_ip_addr_step]} {
                        set intf_ip_addr_step [::ixia::expand_ipv6_addr 0::1]
                    }
                    if {![info exists intf_prefix_length]} {
                        set intf_prefix_length 64
                    }
                    if {[info exists neighbor_intf_ip_addr]} {
                        unset neighbor_intf_ip_addr
                    }
                    if {[info exists neighbor_intf_ip_addr_step]} {
                        unset neighbor_intf_ip_addr_step
                    }
                }
                "v4" {
                    if {![info exists intf_ip_addr_step]} {
                        set intf_ip_addr_step 0.0.0.1
                    }
                    if {![info exists intf_prefix_length]} {
                        set intf_prefix_length 24
                    }
                    if {[info exists neighbor_intf_ip_addr] && \
                            ![isIpAddressValid $neighbor_intf_ip_addr]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "-neighbor_intf_ip_addr must be\
                                 IPv4 when intf_ip_addr is IPv4."
                        return $returnList
                    }
                    if {[info exists neighbor_intf_ip_addr_step] && \
                            ![isIpAddressValid $neighbor_intf_ip_addr_step]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "-neighbor_intf_ip_addr_step\
                                  must be IPv4 when intf_ip_addr is IPv4."
                        return $returnList
                    }
                }
            }
            
            set gre_src_ip_addr_mode "connected"
            
            set protocol_intf_options {
                -atm_encapsulation           atm_encapsulation
                -atm_vci                     vci
                -atm_vci_step                vci_step
                -atm_vpi                     vpi
                -atm_vpi_step                vpi_step
                -count                       connected_count
                -gre_count                   gre_count
                -gre_ipv6_address            gre_ipv6_addr
                -gre_ipv6_prefix_length      gre_ipv6_prefix_length
                -gre_ipv6_address_step       gre_ipv6_addr_step
                -gre_ipv6_address_outside_connected_step      gre_ipv6_addr_cstep
                -gre_dst_ip_address          gre_dst_ip_addr
                -gre_dst_ip_address_step     gre_dst_ip_addr_step
                -gre_dst_ip_address_outside_connected_step    gre_dst_ip_addr_cstep
                -gre_src_ip_address          gre_src_ip_addr_mode
                -gre_checksum_enable         gre_checksum_enable
                -gre_seq_enable              gre_seq_enable
                -gre_key_enable              gre_key_enable
                -gre_key_in                  gre_key_in
                -gre_key_in_step             gre_key_in_step
                -gre_key_out                 gre_key_out
                -gre_key_out_step            gre_key_out_step
                -ip${ip_version}_address     intf_ip_addr
                -ip${ip_version}_prefix_length  intf_prefix_length
                -ip${ip_version}_address_step   intf_ip_addr_step
                -gateway_address             neighbor_intf_ip_addr
                -gateway_address_step        neighbor_intf_ip_addr_step
                -mac_address                 mac_address_init
                -mac_address_step            mac_address_step
                -override_existence_check    override_existence_check
                -override_tracking           override_tracking
                -port_handle                 port_handle
            }
            

            lappend protocol_intf_options \
                    -vlan_enabled                vlan               \
                    -vlan_id                     vlan_id            \
                    -vlan_id_mode                vlan_id_mode       \
                    -vlan_id_step                vlan_id_step       \
                    -vlan_user_priority          vlan_user_priority

            set protocol_intf_args ""
            foreach {option value_name} $protocol_intf_options {
                if {[info exists $value_name]} {
                    append protocol_intf_args " $option [set $value_name]"
                }
            }
    
            # Create the necessary interfaces
            set intf_list [eval ixNetworkProtocolIntfCfg \
                    $protocol_intf_args]
            if {[keylget intf_list status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to create the\
                        protocol interfaces. [keylget intf_list log]"
                return $returnList
            }
            
            if {[info exists gre_ipv6_addr]} {
                set intf_list [keylget intf_list gre_interfaces]
            } else {
                set intf_list [keylget intf_list connected_interfaces]
            }
        }
        
        set intfListIndex 0
        set intfCount [expr $intf_count * $intf_gre_count]
        
        set ripng_router_list ""
        set ripng_router_interface_list ""
        set ripng_router_protocol_interface_list ""
        set objectCount     0
        
        set rt_id_list [::ixia::ixNetworkNodeGetList $protocol_objref "router" -all]
        set exclude_list ""
        foreach rt $rt_id_list {
            lappend exclude_list [ixNet getA $rt -routerId]
        }
        
        for {set routerId 0} {$routerId < $count} {incr routerId} {
            # Compose list of router options
            set check_id_status [::ixia::ixnetwork_ripng_check_id \
                    $exclude_list "router_id"]
            if {[keylget check_id_status status] != $::SUCCESS} {
                return $check_id_status
            }
            foreach {ixnOpt hltOpt}  [array get ripngInterfaceOptionsArray] {
                if {$hltOpt == "interface_metric" } {
                    if {[info exists interface_metric]} {
                        if {$interface_metric == 0} {
                            set enable_interface_metric "false"
                        } elseif {$interface_metric == "0+"} {
                    set enable_interface_metric "true"
                            set interface_metric 0
                        } else {
                            set enable_interface_metric "true"
                        }
                    } else {
                        set enable_interface_metric "false"
                    }
                }
            }
            foreach {ixnOpt hltOpt}  [array get ripngRouterOptionsArray] {
                if {![info exists $hltOpt] && $hltOpt != "router_id"} {
                    continue
                }
                switch -- $hltOpt {
                    "receive_type" {
                        switch -- [set $hltOpt] {
                            ignore {
                                lappend ripng_router_args -$ixnOpt [set $hltOpt]
                            }
                            store {
                                lappend ripng_router_args -$ixnOpt [set $hltOpt]
                            }
                            default {
                                keylset returnList status $::FAILURE
                                keylset returnList log "-$hltOpt [set $hltOpt] \
                                        is not a valid choice with RIPng."
                                return $returnList
                            }
                        }
                    }
                    "router_id" {
                        lappend ripng_router_args -$ixnOpt \
                                [keylget check_id_status router_id]
                        lappend exclude_list [keylget check_id_status router_id]
                    }
                    default {
                        lappend ripng_router_args -$ixnOpt [set $hltOpt]
                    }
                }
            }
            
            # Create router
            set retCode [ixNetworkNodeAdd $protocol_objref router \
                    $ripng_router_args]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to add RIPng router.\
                        [keylget retCode log]."
                return $returnList
            }
            set router_objref [keylget retCode node_objref]
            if {$router_objref == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to add router to the \
                        $protocol_objref protocol object reference."
                return $returnList
            }
            incr objectCount
            if {$objectCount == $objectMaxCount} {
                debug "ixNet commit"
                ixNet commit
                set objectCount 0
            }
            lappend ripng_router_list $router_objref
            
            for {set intfIndex $intfListIndex} {$intfIndex < [expr $intfListIndex + $intfCount]} {incr intfIndex} {
                set intf_objref [lindex $intf_list $intfIndex]
                
                # Compose list of router interface options
                set ripng_intf_args ""
                foreach {ixnOpt hltOpt}  [array get ripngInterfaceOptionsArray] {
                    if {[info exists $hltOpt]} {
                        set hltOptVal [set $hltOpt]
                        if {[llength $hltOptVal] > 1} {
                            set hltOptVal [lindex $hltOptVal $intfIndex]
                        }
                        if {$hltOpt == "update_mode"} {
                            if {![info exists updateMode($hltOptVal)]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "-$hltOpt $hltOptVal\
                                        is not supported for RIPng"
                                return $returnList
                            } else {
                                lappend ripng_intf_args -$ixnOpt $updateMode($hltOptVal)
                            }
                        } else {
                            lappend ripng_intf_args -$ixnOpt $hltOptVal
                        }
                    }
                }
                set ripng_intf_final_args "$ripng_intf_args \
                        -interfaceId $intf_objref"
                set retCode [ixNetworkNodeAdd $router_objref interface \
                        $ripng_intf_final_args]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to add RIPng router interface.
                            [keylget retCode log]."
                    return $returnList
                }
                set router_intf_objref [keylget retCode node_objref]
                if {$router_intf_objref == [ixNet getNull]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to add RIPng router interface\
                            to the $router_objref router object reference"
                    return $returnList
                }
                incr objectCount
                if {$objectCount == $objectMaxCount} {
                    debug "ixNet commit"
                    ixNet commit
                    set objectCount 0
                }
                
                lappend ripng_router_interface_list          $router_intf_objref
                lappend ripng_router_protocol_interface_list $intf_objref
            }
            set intfListIndex [expr $intfListIndex + $intfCount]
            if {[info exists router_id]} {
                incr router_id $router_id_step
            }
        }
        if {$objectCount > 0} {
            debug "ixNet commit"
            ixNet commit
            set objectCount 0
        }
        if {$ripng_router_list != ""} {
            debug "ixNet remapIds {$ripng_router_list}"
            set ripng_router_list [ixNet remapIds $ripng_router_list]
        }
        if {$ripng_router_interface_list != ""} {
            debug "ixNet remapIds {$ripng_router_interface_list}"
            set ripng_router_interface_list [ixNet remapIds $ripng_router_interface_list]
        }
        keylset returnList handle $ripng_router_list
        keylset returnList cont 0
        return $returnList
    } elseif {$mode == "modify"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "handle must be specified \
                    in modify mode."
            return $returnList
        }
        
        set ripngHandleCount 0
        foreach {rHandle} $handle {
            if {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/ripng} $rHandle]} {
                incr ripngHandleCount
            }
        }
        
        if {$ripngHandleCount == 0} {
            # None of the handles is a ripng handle.
            # return and let the procedure that called ripng to handle this
            keylset returnList status $::SUCCESS
            keylset returnList cont 1
            return $returnList
        } elseif {$ripngHandleCount != [llength $handle]} {
            # Not all handles are RIPng handles. This is not suppose to work.
            keylset returnList status $::FAILURE
            keylset returnList log "One or more handles are not of type RIPng.\
                    Modify mode is only supported if all handles are of the\
                    same type."
            keylset returnList cont 0
            return $returnList
        }
        # All handles are RIPng handles. Continue configuration.
        if {[info exists interface_metric]} {
            set intf_length   [llength $interface_metric]
            if {$intf_length > 1} {
                set $intf_length n
            }
            set r_length      [llength $handle]
            if {$r_length > 1} {
                set $r_length n
            }
            switch ${intf_length}:${r_length} {
                1:1 -
                n:1 {
                    if {$interface_metric == 0} {
                        set enable_interface_metric false
                    } elseif {$interface_metric == "0+"} {
                        set interface_metric 0
                        set enable_interface_metric true
                    } else {
                        set enable_interface_metric true
                    }
                }
                1:n {
                    set enable_interface_metric {}
                    regsub -all {0\+} $interface_metric {true} enable_interface_metric
                    regsub -all {0} $enable_interface_metric {false} enable_interface_metric
                    regsub -all {[0-9]+} $enable_interface_metric {true} enable_interface_metric
                    regsub -all {true} $enable_interface_metric {1} enable_interface_metric
                    regsub -all {false} $enable_interface_metric {0} enable_interface_metric
                    
                    if {$enable_interface_metric != ""} {
                        expr [join $enable_interface_metric " | "]
                    } else {
                        set enable_interface_metric false
                    }
                }
                n:n {
                    set interface_metric_index 0
                    foreach interface_metric_elem $interface_metric {
                        
                        if {$interface_metric_elem == 0} {
                            lappend enable_interface_metric false
                        } elseif {$interface_metric_elem == "0+"} {
                            lreplace $interface_metric $interface_metric_index $interface_metric_index 0
                            lappend enable_interface_metric true
                        } else {
                            lappend enable_interface_metric true
                        }
                        incr interface_metric_index
                    }
                }
            }
        }
        
        set handleIndex 0
        foreach {rHandle} $handle {
            if {[regexp {router:\d*$} $rHandle]} {
                set router_objref  $rHandle
                set retCode [ixNetworkGetPortFromObj $rHandle]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
                set port_handle  [keylget retCode port_handle]
                set vport_objref [keylget retCode vport_objref]
                set protocol_objref [keylget retCode vport_objref]/protocols/ripng
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid RIPng handle $rHandle. Parameter\
                        -handle must provide with a list of RIPng routers."
                return $returnList
            }

            # Compose list of router options
            set ripng_router_args ""
            foreach {ixnOpt hltOpt}  [array get ripngRouterOptionsArray] {
                if {[info exists $hltOpt]} {
                    set length [llength [set $hltOpt]]
                    if {$hltOpt == "router_id"} {
                        if {$length == [llength $handle]} {
                            set tmpExcludeList [lreplace [set $hltOpt] \
                                    $handleIndex $handleIndex]
                            set tmpRtId [lindex [set $hltOpt] $handleIndex]
                            set check_id_status [::ixia::ixnetwork_ripng_check_id \
                                    $tmpExcludeList "tmpRtId"]
                            if {[keylget check_id_status status] != $::SUCCESS} {
                                return $check_id_status
                            }
                            lappend ripng_router_args -$ixnOpt \
                                    [lindex [set $hltOpt] $handleIndex]
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Invalid number of values\
                                    for -$hltOpt. The number of values\
                                    must be [llength $handle]."
                            return $returnList
                        }
                    } else {
                        if {$length == [llength $handle]} {
                            lappend ripng_router_args -$ixnOpt \
                                    [lindex [set $hltOpt] $handleIndex]
                        } elseif {$length == 1} {
                            lappend ripng_router_args -$ixnOpt [set $hltOpt]
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Invalid number of values\
                                    for -$hltOpt. The number of values\
                                    should be 1 or [llength $handle]."
                            return $returnList
                        }
                    }
                }
            }
            
            set router_intf_objrefs [ixNet getList $router_objref interface]
            debug "router_intf_objrefs = $router_intf_objrefs"
            if {[llength $handle] == 1} {
                # The interface values will apply to each interface of the router
                # specified by handle
                set intf_length [llength $router_intf_objrefs]
                debug "intf_length = $intf_length"
                set intf_index  "intfIndex"
            } else {
                # Each interface handle will apply to all interfaces of each
                # router
                set intf_length [llength $handle]
                set intf_index  "handleIndex"
            }
            
            set intfIndex 0
            foreach intfHdl $router_intf_objrefs {
                set interface_Index [set $intf_index]
                # Compose list of router interface options
                set ripng_intf_args ""
                foreach {ixnOpt hltOpt}  [array get ripngInterfaceOptionsArray] {
                    if {[info exists $hltOpt]} {
                        set length [llength [set $hltOpt]]
                        if {$length == $intf_length} {
                            debug "lindex [set $hltOpt] $interface_Index"
                            set tmpVal [lindex [set $hltOpt] $interface_Index]
                            debug "tmpVal = $tmpVal"
                        } elseif {$length == 1} {
                            set tmpVal [set $hltOpt]
                            debug "tmpVal = $tmpVal"
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Invalid number of values\
                                    for -$hltOpt. The number of values\
                                    should be 1 or $intf_length."
                            return $returnList
                        }
                        
                        if {$hltOpt == "update_mode"} {
                            if {![info exists updateMode($tmpVal)]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "-$hltOpt $tmpVal\
                                        is not supported for RIPng"
                                return $returnList
                            } else {
                                lappend ripng_intf_args -$ixnOpt $updateMode($tmpVal)
                            }
                        } elseif {$hltOpt == "interface_metric" } {
                            if {[info exists interface_metric]} {
                                if {$tmpVal == 0} {
                                    lappend ripng_intf_args -$ixnOpt $tmpVal
                                    if {$ixnetworkVersion<6.30} {
                                        lappend ripng_intf_args -enableInterfaceMetric false
                                    }
                                } elseif {$interface_metric == "0+"} {
                                    lappend ripng_intf_args -$ixnOpt 0
                                    if {$ixnetworkVersion<6.30} {
                                        lappend ripng_intf_args -enableInterfaceMetric true
                                    }
                                } else {
                                    lappend ripng_intf_args -$ixnOpt $tmpVal
                                    if {$ixnetworkVersion<6.30} {
                                        lappend ripng_intf_args -enableInterfaceMetric true
                                    }
                                }
                            } else {
                                lappend ripng_intf_args -$ixnOpt $tmpVal
                                if {$ixnetworkVersion<6.30} {
                                    lappend ripng_intf_args -enableInterfaceMetric false
                                }
                            }
                        } else {
                            debug "lappend ripng_intf_args -$ixnOpt $tmpVal"
                            lappend ripng_intf_args -$ixnOpt $tmpVal
                        }
                    }
                }
                # Setting router interface options
                if {$ripng_intf_args != ""} {
                    set retCode [ixNetworkNodeSetAttr $intfHdl \
                            $ripng_intf_args]
                    if {[keylget retCode status] == $::FAILURE} {
                        return $retCode
                    }
                }
                incr intfIndex
            }
            
            # Setting router arguments
            if {$ripng_router_args != ""} {
                set retCode [ixNetworkNodeSetAttr $router_objref $ripng_router_args]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
            }
        
            incr handleIndex
        }
        ixNet commit
        debug "ixNet commit"
        
        keylset returnList status $::SUCCESS
        keylset returnList cont 0
        return $returnList
    }
}


proc ::ixia::ixnetwork_ripng_check_id {excludeList routerId} {
    
    upvar $routerId rtId
    
    keylset returnList status $::SUCCESS
    
    if {[info exists rtId] && $rtId != ""} {
        set rtId [lindex $rtId 0]
        if {$rtId > 65535} {
            keylset returnList status $::FAILURE
            keylset returnList log "Router id $rtId out of range."
            return $returnList
        }
            
        if {[lsearch $excludeList $rtId] != -1} {
            keylset returnList status $::FAILURE
            keylset returnList log "A router with the router_id $rtId\
                    already exists on the port."
            return $returnList
        }
        keylset returnList router_id $rtId
    } else {
        set rt_id_list [lsort -dictionary $excludeList]
        foreach rt $rt_id_list {
            if {[lindex $rt_id_list 0] != 1} {
                keylset returnList router_id 1
            } elseif {[lindex $rt_id_list end] == $rt} {
                if {$rt < 65535} {
                    keylset returnList router_id [mpexpr $rt + 1]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "There are no more router ids\
                            available on the port."
                    return $returnList
                }
            } else {
                set next_rt [lindex $rt_id_list [mpexpr [lsearch $rt_id_list $rt] + 1]]
                if {[mpexpr $next_rt - $rt] > 1} {
                    keylset returnList router_id [mpexpr $rt + 1]
                    break
                }
            }
        }
        if {$rt_id_list == ""} {
            keylset returnList router_id 1
        }
    }
    return $returnList
}


proc ::ixia::ixnetwork_ripng_route_config { args man_args opt_args } {

    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    # Verify parameters given for each option
    if {$mode == "create"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "No -handle was\
                    passed to $mode."
            return $returnList
        }
        catch {unset err}
        if {[catch {::ixNet exists $handle} err] ||\
                ([info exists err] && ($err == "false" || $err == 0))} {
            keylset returnList status $::FAILURE
            keylset returnList log "Handle $handle does not exist."
            keylset returnList cont 0
            return $returnList
        }
        
        if {![regexp {^::ixNet::OBJ-/vport:\d+/protocols/ripng} $handle]} {
            if {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/rip} $handle]} {
                # Handle not RIPng type, let rip procedure handle it
                keylset returnList status $::SUCCESS
                keylset returnList cont 1
                return $returnList
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid -handle $handle."
                keylset returnList cont 0
                return $returnList
            }
        }
        if {[info exists reset]} {
            set result [ixNetworkNodeRemoveList $handle \
                    { {child remove routeRange} {} } -commit]
            if {[keylget result status] == $::FAILURE} {
                return $returnList
            }
        }
        # Handle is of RIPng type. Continue configuration.
    } elseif {($mode == "modify") || ($mode == "delete") } {
        if {![info exists route_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "No -route_handle was passed when -mode is\
                    $mode."
            return $returnList
        }
        foreach rt_handle $route_handle {
            catch {unset err}
            if {[catch {::ixNet exists $rt_handle} err] ||\
                    ([info exists err] && ($err == "false" || $err == 0))} {
                keylset returnList status $::FAILURE
                keylset returnList log "route_handle $rt_handle does not exist."
                keylset returnList cont 0
                return $returnList
            }
            
            if {![regexp {^::ixNet::OBJ-/vport:\d+/protocols/ripng/router:\d+/routeRange:\d+} $rt_handle]} {
                if {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/rip/router:\d+/routeRange:\d+} $rt_handle]} {
                    # Handle not RIPng type, let rip procedure handle it
                    keylset returnList status $::SUCCESS
                    keylset returnList cont 1
                    return $returnList
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid -route_handle $rt_handle."
                    keylset returnList cont 0
                    return $returnList
                }
            }
        }
    }
    
    set ipv6_params [list prefix_start prefix_step next_hop]
    foreach ipv6_addr $ipv6_params {
        if {[info exists $ipv6_addr]} {
            if {[isIpAddressValid [set $ipv6_addr]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid IPv6 address -$ipv6_addr\
                        [set $ipv6_addr]."
                return $returnList
            }
        }
    }

    # Setup the corresponding parameters array
    set ripRouteParams [list \
            enabled                        enabled            \
            metric                         metric             \
            firstRoute                     prefix_start       \
            maskWidth                      prefix_length_temp \
            nextHop                        next_hop           \
            numberOfRoute                  num_prefixes       \
            routeTag                       route_tag          \
            step                           prefix_step_number \
            ]
    
    # Set the list of parameters with default values
    set param_value_list [list                 \
            enabled            1               \
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
        } else {
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
    
    if {$mode == "create"} {
        # Initialize non-existing parameters with default values
        foreach {param value} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            }
        }
        
        set ripng_router_params ""
        foreach {ixnOpt hltOpt} $ripRouteParams {
            if {[info exists $hltOpt]} {
                lappend ripng_router_params -$ixnOpt [set $hltOpt]
            }
        }
        # Create route range
        set retCode [ixNetworkNodeAdd $handle routeRange \
                $ripng_router_params -commit]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to add RIPng route range.\
                    [keylget retCode log]."
            return $returnList
        }
        set route_objref [keylget retCode node_objref]
        if {$route_objref == [ixNet getNull]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to add route range to the \
                    $handle RIPng router object reference."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        keylset returnList route_handle $route_objref
        keylset returnList cont 0
        return $returnList
    } elseif {$mode == "modify"} {
        set ripng_router_params ""
        foreach handle $route_handle {
            foreach {ixnOpt hltOpt} $ripRouteParams {
                if {[info exists $hltOpt]} {
                    lappend ripng_router_params -$ixnOpt [set $hltOpt]
                }
            }
            if {$ripng_router_params != ""} {
                set retCode [ixNetworkNodeSetAttr $handle $ripng_router_params\
                        -commit]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
            }
        }
    } elseif {$mode == "delete"} {
        foreach handle $route_handle {
            ixNet remove $handle
        }
    }
    ixNet commit
    keylset returnList status $::SUCCESS
    keylset returnList cont 0
    return $returnList
}
