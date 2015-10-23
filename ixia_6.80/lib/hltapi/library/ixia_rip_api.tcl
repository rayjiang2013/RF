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
#    Lavinia Raicea
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


proc ::ixia::emulation_rip_config { args } {
    variable executeOnTclServer
	
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_rip_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable rip_router_handles_array
    variable rip_route_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
        -mode           CHOICES create delete modify enable disable
    }
    set opt_args {
        -port_handle                 REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -handle
        -session_type                CHOICES ripv1 ripv2 ripng
        -count                       NUMERIC
                                     DEFAULT 1
        -gre_checksum_enable         CHOICES 0 1
                                     DEFAULT 0
        -gre_count                   NUMERIC
                                     DEFAULT 0
        -gre_dst_ip_addr             IP
        -gre_dst_ip_addr_step        IP
        -gre_dst_ip_addr_cstep       IP
        -gre_ipv6_addr               IPV6
        -gre_ipv6_addr_step          IPV6
                                     DEFAULT 0:0:0:1::0
        -gre_ipv6_addr_cstep         IPV6
        -gre_ipv6_prefix_length      RANGE   1-128
                                     DEFAULT 64
        -gre_key_enable              CHOICES 0 1
                                     DEFAULT 0
        -gre_key_in                  RANGE 0-4294967295
                                     DEFAULT 0
        -gre_key_in_step             RANGE 0-4294967295
                                     DEFAULT 0
        -gre_key_out                 RANGE 0-4294967295
                                     DEFAULT 0
        -gre_key_out_step            RANGE 0-4294967295
                                     DEFAULT 0
        -gre_seq_enable              CHOICES 0 1
                                     DEFAULT 0
        -gre_src_ip_addr_mode        CHOICES routed connected
                                     DEFAULT connected
        -intf_count                  NUMERIC
                                     DEFAULT 1
        -intf_ip_addr                IP
        -intf_prefix_length          RANGE 1-128
        -intf_ip_addr_step           IP
        -interface_metric            REGEXP 0\+|0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16
        -interface_handle
        -neighbor_intf_ip_addr       IP
        -neighbor_intf_ip_addr_step  IP
        -update_interval             RANGE 1-1000
        -update_interval_offset      RANGE 0-15
        -authentication_mode         CHOICES null text md5
        -password                    ALPHANUM
        -update_mode                 CHOICES no_horizon split_horizon
                                     CHOICES poison_reverse discard
        -vpi                         RANGE 0-255
        -vci                         RANGE 0-65535
        -vpi_step                    RANGE 0-255
        -vci_step                    RANGE 0-65535
        -atm_encapsulation           CHOICES VccMuxIPV4Routed
                                     CHOICES VccMuxIPV6Routed
                                     CHOICES VccMuxBridgedEthernetFCS
                                     CHOICES VccMuxBridgedEthernetNoFCS
                                     CHOICES LLCRoutedCLIP
                                     CHOICES LLCBridgedEthernetFCS
                                     CHOICES LLCBridgedEthernetNoFCS
        -vlan                        CHOICES 0 1
        -vlan_id                     RANGE   0-4095
        -vlan_id_mode                CHOICES fixed increment
                                     DEFAULT increment
        -vlan_id_step                RANGE   0-4096
                                     DEFAULT 1
        -vlan_user_priority          RANGE   0-7
                                     DEFAULT 0
        -router_id                   RANGE 0-65535
        -router_id_step              RANGE 0-65535
                                     DEFAULT 1
        -send_type                   CHOICES multicast broadcast_v1
                                     CHOICES broadcast_v2
        -receive_type                CHOICES v1 v2 v1_v2 ignore store
        -time_period                 RANGE 0-999999
        -num_routes_per_period       RANGE 0-999999
        -reset                       FLAG
        -mac_address_init            MAC
        -mac_address_step            MAC
                                     DEFAULT 0000.0000.0001
        -no_write                    FLAG
        -override_existence_check    CHOICES 0 1
                                     DEFAULT 0
        -override_tracking           CHOICES 0 1
                                     DEFAULT 0
    }

    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_rip_config $args $man_args $opt_args]
        if {[keylget returnList status] != $::SUCCESS} {
            keylset returnList log "ERROR in $procName: [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
    
    
    if {$mode == "create"} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: No -port_handle was\
                    passed to in mode -$mode."
            return $returnList
        }
        if {![info exists intf_ip_addr]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: No -intf_ip_addr was\
                    passed to in mode -$mode."
            return $returnList
        }
        set port_list [format_space_port_list $port_handle]
        foreach {chassis card port} [lindex $port_list 0] {}
        if {![info exists session_type]} {
            set session_type ripv2
        }
        
        # Check if RIP package has been installed on the port
        if {($session_type == "ripv1") || ($session_type == "ripv2")} {
            if {[catch {ripServer select $chassis $card $port} retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The RIP\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chassis/$card/$port."
                return $returnList
            }
        } elseif {$session_type == "ripng"}  {
            # Check if RIPng protocol is supported
            if {![port isValidFeature $chassis $card $port \
                        portFeatureProtocolRIPng]} {
                
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : This card does not\
                        support RIPng protocol."
                return $returnList
            }
            if {[catch {ripngServer select $chassis $card $port} retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The RIPng\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chassis/$card/$port."
                return $returnList
            }
        }
        
        if {[catch {package present IxTclHal} versionIxTclHal] || \
                    ($versionIxTclHal < 3.80)} {
            
            if {$session_type == "ripng"} {
                set count 1
            }
        }
    } elseif {($mode == "enable") || ($mode == "disable") || \
                ($mode == "delete") || ($mode == "modify")}  {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: No -handle was\
                    passed to mode -$mode."
            return $returnList
        }
    }
    
    # Set IP version
    if {[info exists intf_ip_addr]} {
        if {![info exists ip_version]} {
            if {[llength [split $intf_ip_addr .]] == 4} {
                set ip_version 4
                set default_intf_prefix_length 24
                set default_intf_ip_addr_step 0.0.0.1
                set default_neighbor_intf_ip_addr_step 0.0.0.0
            } else {
                set ip_version 6
                set default_intf_prefix_length 64
                set default_intf_ip_addr_step 0::1
            }
        }
    }
    
    set rip_routers_list [list ]
    set description_list [list ]
    
    if {$mode == "delete"} {
        foreach session_handle $handle {
            set retCode [::ixia::ripDeleteSessionHandle $session_handle]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
        }
        
        keylset returnList handle $handle
    } elseif {$mode == "enable"}  {
        foreach session_handle $handle {
            set retCode [::ixia::ripEnableSessionHandle $session_handle true]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
        }

        keylset returnList handle $handle
    } elseif {$mode == "disable"}  {
        foreach session_handle $handle {
            set retCode [::ixia::ripEnableSessionHandle $session_handle false]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
        }

        keylset returnList handle $handle
    } elseif {$mode == "create"} {
        set retCode [::ixia::ripCheckParametersValidity ]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget retCode log]"
            return $returnList
        }
        # Clear all routers if -reset
        if {[info exists reset] && [info exists port_handle]} {
            set port_list [format_space_port_list $port_handle]
            foreach {chassis card port} [lindex $port_list 0] {}
            
            if {[ripServer select $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed\
                        to set ripServer select $chassis $card $port."
                return $returnList
            }
            ripServer clearAllRouters
            if {[ripngServer select $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed\
                        to ripngServer select $chassis $card $port."
                return $returnList
            }
            if {[ripngServer get]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed\
                        to ripngServer get."
                return $returnList
            }
            ripngServer clearAllRouters
            ::ixia::ripClearAllRouters $chassis $card $port
        }
        ::ixia::addPortToWrite $port_handle
        if {($session_type == "ripv1") || ($session_type == "ripv2")} {
            # Set the list of parameters with default values
            set param_value_list [list                                     \
                    intf_ip_addr_step          $default_intf_ip_addr_step  \
                    intf_prefix_length         $default_intf_prefix_length \
                    neighbor_intf_ip_addr      0.0.0.0                     \
                    neighbor_intf_ip_addr_step                             \
                    $default_neighbor_intf_ip_addr_step                    \
                    update_interval           30                           \
                    update_interval_offset    0                            \
                    receive_type              $default_receive_type        \
                    send_type                 $default_send_type           \
                    ]
            
            # Initialize non-existing parameters with default values
            foreach {param value} $param_value_list {
                if {![info exists $param]} {
                    set $param $value
                }
            }
            
            # Options that are mandatory for the protocol interface config call
            set config_param \
                    "-port_handle $port_handle      \
                    -ip_address   $intf_ip_addr     \
                    -ip_version   $ip_version       \
                    -count        $count            "
            
            # Options that are optional and will only be used if set for the
            # protocol interface config call.
            set config_options \
                    "-mac_address            mac_address_init           \
                    -gateway_ip_address      neighbor_intf_ip_addr      \
                    -gateway_ip_address_step neighbor_intf_ip_addr_step \
                    -ip_address_step         intf_ip_addr_step          \
                    -netmask                 intf_prefix_length         \
                    -vlan_id                 vlan_id                    \
                    -vlan_id_mode            vlan_id_mode               \
                    -vlan_id_step            vlan_id_step               \
                    -vlan_user_priority      vlan_user_priority         \
                    -atm_vci                 vci                        \
                    -atm_vci_step            vci_step                   \
                    -atm_vpi                 vpi                        \
                    -atm_vpi_step            vpi_step                   \
                    -no_write                no_write                   "
            
            foreach {option value_name} $config_options {
                if {[info exists $value_name]} {
                    append config_param " $option [set $value_name] "
                }
            }
            # Create interfaces
            set interface_config_status [eval         \
                    ::ixia::protocol_interface_config \
                    $config_param]
            if {[keylget interface_config_status status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        Could not configure the interface(s)\
                        on the Protocol Server for port:\
                        $chassis $card $port. Error Log :\
                        [keylget interface_config_status log]"
                return $returnList
            }
            set description_list [concat $description_list \
                    [keylget interface_config_status  description] ]
            
            set existentRouters [list ]
            foreach {intf_description} $description_list {
                set retCode [::ixia::ripCheckRouterExistence \
                        $intf_description                    \
                        $session_type                        \
                        $port_handle                         ]
                if {[keylget retCode status] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget retCode log]"
                    return $returnList
                } else  {
                    if {[keylget retCode existence] == 1} {
                        lappend existentRouters $intf_description
                    }
                }
            }
            if {[llength $existentRouters] > 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        The following interfaces already have a router\
                        configured: $existentRouters.  If you want to\
                        proceed please delete the existing routers."
                return $returnList
            }
            # Set protocol server
            set retCode [protocolServer get $chassis $card $port]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        protocolServer get $chassis $card $port.  Return code was\
                        $retCode."
                return $returnList
            }
            catch {protocolServer config -enableRipService true}
            set retCode [protocolServer set $chassis $card $port]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        protocolServer set $chassis $card $port.  Return code was\
                        $retCode."
                return $returnList
            }
            
            # Select port
            if {[ripServer select $chassis $card $port]} {
                keylset returnList log "ERROR in $procName:\
                        ripServer select $chassis $card $port failed."
                keylset returnList status $::FAILURE
                return $returnList
            }
            
            # Create hosts
            for {set router_num 1} {$router_num <= $count} {incr router_num} {
                set allRouters [array names ::ixia::rip_router_handles_array]
                set retCode [::ixia::ripGetNextHandle $allRouters router]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset retCode log "ERROR in $procName:\
                            [keylget retCode log]"
                    return $retCode
                }
                set rip_next_router [keylget retCode next_handle]
                
                ripInterfaceRouter setDefault
                ripInterfaceRouter clearAllRouteRange
                catch {ripInterfaceRouter config -enableRouter true}

                set description [lindex $description_list \
                        [expr $router_num - 1]]
                
                catch {ripInterfaceRouter config          \
                            -protocolInterfaceDescription \
                            "$description"}
                
                set retCode [::ixia::get_interface_parameter        \
                        -port_handle $port_handle                   \
                        -description $description                   \
                        -parameter   [list ipv${ip_version}_address \
                        ipv${ip_version}_mask]                      ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]."
                    return $returnList
                }
                
                set dataIpValue   [keylget retCode ipv${ip_version}_address]
                set dataMaskValue [keylget retCode ipv${ip_version}_mask   ]
                
                if {$dataIpValue != ""} {
                    catch {ripInterfaceRouter config -ipAddress "$dataIpValue"}
                }
                if {$dataMaskValue != ""} {
                    catch {ripInterfaceRouter config -ipMask \
                                "[getIpV4MaskFromWidth $dataMaskValue]"}
                }
                
                # Configure router
                foreach item [array names ripInterfaceRouter] {
                    if {![catch {set $ripInterfaceRouter($item)} value] } {
                        if {[lsearch [array names enumList] $value] != -1} {
                            set value $enumList($value)
                        }
                        catch {ripInterfaceRouter config -$item $value}
                    }
                }
                
                # Add router
                if {[ripServer addRouter $rip_next_router] != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Could not add\
                            Router $rip_next_router to the RIP server."
                    return $returnList
                }
                
                lappend rip_routers_list $rip_next_router
                # Set mandatory params for adding new session_handle
                set mandatory_add_config \
                        "-session_handle  $rip_next_router      \
                        -port_handle      $port_handle          \
                        -rip_version      $session_type         \
                        -intf_description \"$description\"      "
                
                # Add new session_handle
                set retCode [eval ::ixia::ripAddSessionHandle \
                        $mandatory_add_config]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget retCode log]"
                    return $returnList
                }
            }
            
            keylset returnList handle $rip_routers_list
        } elseif {$session_type == "ripng"}  {
            # Set the list of parameters with default values
            set param_value_list [list                                     \
                    intf_ip_addr_step         $default_intf_ip_addr_step   \
                    intf_prefix_length        $default_intf_prefix_length  \
                    update_interval           30                           \
                    update_interval_offset    0                            \
                    interface_metric          0                            \
                    num_routes_per_period     0                            \
                    receive_type              ignore                       \
                    ]
            # Initialize non-existing parameters with default values
            foreach {param value} $param_value_list {
                if {![info exists $param]} {
                    set $param $value
                }
            }
            
            # Options that are mandatory for the protocol interface config call
            set config_param \
                    "-port_handle $port_handle      \
                    -ip_address   $intf_ip_addr     \
                    -ip_version   $ip_version       \
                    -count        $count            "
            
            # Options that are optional and will only be used if set for the
            # protocol interface config call.
            set config_options \
                    "-mac_address            mac_address_init           \
                    -ip_address_step         intf_ip_addr_step          \
                    -netmask                 intf_prefix_length         \
                    -vlan_id                 vlan_id                    \
                    -vlan_id_mode            vlan_id_mode               \
                    -vlan_id_step            vlan_id_step               \
                    -vlan_user_priority      vlan_user_priority         \
                    -atm_vci                 vci                        \
                    -atm_vci_step            vci_step                   \
                    -atm_vpi                 vpi                        \
                    -atm_vpi_step            vpi_step                   \
                    -no_write                no_write                   "
            
            foreach {option value_name} $config_options {
                if {[info exists $value_name]} {
                    append config_param " $option [set $value_name] "
                }
            }
            
            # Create interfaces
            set interface_config_status [eval         \
                    ::ixia::protocol_interface_config \
                    $config_param]
            
            if {[keylget interface_config_status status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        Could not configure the interface(s)\
                        on the Protocol Server for port:\
                        $chassis $card $port. Error Log :\
                        [keylget interface_config_status log]"
                return $returnList
            }
            set description_list [concat $description_list \
                    [keylget interface_config_status  description] ]
            
            # Check the interfaces for already existent routers
            set existentRouters [list ]
            foreach {intf_description} $description_list {
                set retCode [::ixia::ripCheckRouterExistence \
                        $intf_description                    \
                        $session_type                        \
                        $port_handle                         ]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget retCode log]"
                    return $returnList
                } else  {
                    if {[keylget retCode existence] == 1} {
                        lappend existentRouters $intf_description
                    }
                }
            }
            # If we have routers on the interfaces return an error
            if {[llength $existentRouters] > 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        The following interfaces already have a router\
                        configured: $existentRouters.  If you want to\
                        proceed please delete the existing routers."
                return $returnList
            }
            # Check router id information
            if {[info exists router_id]} {
                set router_id [lindex $router_id 0]
                # If router_id information is provided then check if there
                # are already configured routers with the same router_id
                # and also check if any router_id gets out of range
                set router_id_i $router_id
                for {set i 0} {$i < $count} {incr i} {
                    if {$router_id_i > 65535} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Router id $router_id_i out of range."
                        return $returnList
                    }
                    set retCode [::ixia::ripCheckRouterIdExistence \
                            $router_id_i \
                            $port_handle ]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget retCode log]"
                        return $returnList
                    }
                    if {[keylget retCode existence] == 1} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                A router with the router_id $router_id_i\
                                already exists on the port $port_handle."
                        return $returnList
                    }
                    incr router_id_i $router_id_step
                }
                set rip_next_router_id $router_id
            } else  {
                # Get the next router_id for that port
                set retCode [::ixia::ripGetAllRouterIdsFromPort $port_handle]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget retCode log]"
                    return $returnList
                }
                set allRouterIds [keylget retCode router_ids]
                set retCode [::ixia::ripGetNextHandle $allRouterIds ""]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget retCode log]"
                    return $returnList
                }
                set rip_next_router_id [keylget retCode next_handle]
                
            }
            
            # Set protocol server
            set retCode [protocolServer get $chassis $card $port]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        protocolServer get $chassis $card $port.  Return code was\
                        $retCode."
                return $returnList
            }
            catch {protocolServer config -enableRipngService true}
            set retCode [protocolServer set $chassis $card $port]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        protocolServer set $chassis $card $port.  Return code was\
                        $retCode."
                return $returnList
            }
            
            # Select port
            if {[ripngServer select $chassis $card $port]} {
                keylset returnList log "ERROR in $procName:\
                        ripngServer select $chassis $card $port failed."
                keylset returnList status $::FAILURE
                return $returnList
            }
            
            # Get port configuration
            if {[ripngServer get]} {
                keylset returnList log "ERROR in $procName:\
                        ripngServer get failed."
                keylset returnList status $::FAILURE
                return $returnList
            }
            
            # Create hosts
            for {set router_num 1} {$router_num <= $count} {incr router_num} {
                set allRouters [array names ::ixia::rip_router_handles_array]
                set retCode [::ixia::ripGetNextHandle $allRouters router]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset retCode log "ERROR in $procName:\
                            [keylget retCode log]"
                    return retCode
                }
                set rip_next_router [keylget retCode next_handle]
                
                ripngRouter setDefault
                
                ripngRouter clearAllInterfaces
                
                ripngRouter clearAllRouteRanges
                
                # Configure interface
                ripngInterface setDefault
                catch {ripngInterface config -enable true}
                
                set description [lindex $description_list \
                        [expr $router_num - 1]]
                
                catch {ripngInterface config              \
                            -protocolInterfaceDescription \
                            "$description"}
                
                # Configure interface
                foreach item [array names ripngInterface] {
                    if {![catch {set $ripngInterface($item)} value] } {
                        if {[lsearch [array names enumList] $value] != -1} {
                            set value $enumList($value)
                        }
                        catch {ripngInterface config -$item $value}
                    }
                }
                
                # Add interface
                if {[ripngRouter addInterface interface1] != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Could not add\
                            the interface to the RIP router."
                    return $returnList
                }
                
                # Configure router
                catch {ripngRouter config -enable true}
                catch {ripngRouter config -routerId $rip_next_router_id}
                
                foreach item [array names ripngRouter] {
                    if {![catch {set $ripngRouter($item)} value] } {
                        if {[lsearch [array names enumList] $value] != -1} {
                            set value $enumList($value)
                        }
                        catch {ripngRouter config -$item $value}
                    }
                }
                
                # Add router
                if {[ripngServer addRouter $rip_next_router] != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Could not add\
                            Router $rip_next_router to the RIPng server."
                    return $returnList
                }
                lappend rip_routers_list $rip_next_router
                
                # Set mandatory params for adding new session_handle
                set mandatory_add_config \
                        "-session_handle  $rip_next_router      \
                        -port_handle      $port_handle          \
                        -intf_description \"$description\"      \
                        -rip_version      $session_type         \
                        -router_id        $rip_next_router_id   "
                
                # Add new session_handle
                set retCode [eval ::ixia::ripAddSessionHandle \
                        $mandatory_add_config]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget retCode log]"
                    return $returnList
                }
                
                # Get the next router_id
                if {[info exists router_id]} {
                    incr rip_next_router_id $router_id_step
                } else  {
                    # Get the next router_id for that port
                    set retCode [::ixia::ripGetAllRouterIdsFromPort \
                            $port_handle]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget retCode log]"
                        return $returnList
                    }
                    set allRouterIds [keylget retCode router_ids]
                    set retCode [::ixia::ripGetNextHandle $allRouterIds ""]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget retCode log]"
                        return $returnList
                    }
                    set rip_next_router_id [keylget retCode next_handle]
                }
            }
            ripngServer setDefault
            # Configure server
            foreach item [array names ripngServer] {
                if {![catch {set $ripngServer($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {ripngServer config -$item $value}
                }
            }
            # Set configuration on port
            if {[ripngServer set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        ripngServer set failed."
                return $returnList
            }
            
            keylset returnList handle $rip_routers_list
        }
    } elseif {$mode == "modify"} {
        # Check router id information
        if {[info exists router_id]} {
            if {[llength $router_id] != [llength $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        The list of router_ids must be the same\
                        length as the list of handles."
                return $returnList
            }
        }
        set session_index 0
        foreach {session_handle} $handle {
            # Get the port_handle
            set retCode [::ixia::ripGetParamValueFromSession \
                    $session_handle port_handle]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        Failed on modify $session_handle. \
                        [keylget retCode log]"
                return $returnList
            }
            set port_handle [keylget retCode port_handle]
            set port_list [format_space_port_list $port_handle]
            foreach {chassis card port} [lindex $port_list 0] {}
            ::ixia::addPortToWrite $chassis/$card/$port
            
            # Get the RIP version
            set retCode [::ixia::ripGetParamValueFromSession \
                    $session_handle rip_version]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        Failed on modify $session_handle. \
                        [keylget retCode log]"
                return $returnList
            }
            set session_type [keylget retCode rip_version]
            
            # Check if the given parameters are valid
            set retCode [::ixia::ripCheckParametersValidity ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
            # Modify routers
            if {($session_type == "ripv1") || ($session_type == "ripv2") } {
                if {[ripServer select $chassis $card $port]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed\
                            to ripServer select $chassis $card $port."
                    return $returnList
                }
                # Get router
                if {[ripServer getRouter $session_handle] != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed\
                            to ripServer getRouter $session_handle."
                    return $returnList
                }
                # Configure router
                foreach item [array names ripInterfaceRouter] {
                    if {![catch {set $ripInterfaceRouter($item)} value] } {
                        if {[lsearch [array names enumList] $value] != -1} {
                            set value $enumList($value)
                        }
                        catch {ripInterfaceRouter config -$item $value}
                    }
                }
                # Set router
                if {[ripServer setRouter $session_handle] != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed\
                            to ripServer setRouter $session_handle."
                    return $returnList
                }
                lappend rip_routers_list $session_handle
                
            } elseif {$session_type == "ripng"} {
                
                # Check if information for interface has to be changed
                set cvalue 0
                foreach {item value} [array get ripngInterface] {
                    if {[info exists $value] } {
                        incr cvalue
                    }
                }
                if {$cvalue != 0} {
                    if {[ripngServer select $chassis $card $port]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed\
                                to ripngServer select $chassis $card $port."
                        return $returnList
                    }
                    # Get server
                    if {[ripngServer get]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed\
                                to ripngServer get."
                        return $returnList
                    }
                    # Get router
                    if {[ripngServer getRouter $session_handle] != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed\
                                to ripngServer getRouter $session_handle."
                        return $returnList
                    }
                    # Get interface
                    if {[ripngRouter getInterface interface1] != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Failed to ripngRouter getInterface\
                                interface1."
                        return $returnList
                    }
                    # Configure interface
                    foreach item [array names ripngInterface] {
                        if {![catch {set $ripngInterface($item)} value] } {
                            if {[lsearch [array names enumList] $value] \
                                        != -1} {
                                set value $enumList($value)
                            }
                            catch {ripngInterface config -$item $value}
                        }
                    }
                    # Set interface
                    if {[ripngRouter setInterface interface1] != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Failed to ripngRouter setInterface\
                                interface1."
                        return $returnList
                    }
                    # Set configuration on port
                    if {[ripngServer set]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                ripngServer set failed."
                        return $returnList
                    }
                }
                # Check if information for router has to be changed
                if {[info exists router_id] && ([lindex $router_id \
                            $session_index] != "")} {
                    set cvalue 1
                    set retCode [::ixia::ripCheckRouterIdExistence \
                            [lindex $router_id $session_index]     \
                            "$chassis/$card/$port"                 ]
                    
                    if {[keylget retCode status] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget retCode log]"
                        return $returnList
                    }
                    if {[keylget retCode existence] == 1 } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                A router with the router_id\
                                [lindex $router_id $session_index]\
                                already exists on the port\
                                $chassis/$card/$port."
                        return $returnList
                    }
                } else  {
                    set cvalue 0
                    foreach {item value} [array get ripngRouter] {
                        if {[info exists $value] } {
                            incr cvalue
                        }
                    }
                }
                if {$cvalue != 0} {
                    if {[ripngServer select $chassis $card $port]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed\
                                to ripngServer select $chassis $card $port."
                        return $returnList
                    }
                    # Get server
                    if {[ripngServer get]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed\
                                to ripngServer get."
                        return $returnList
                    }
                    # Get router
                    if {[ripngServer getRouter $session_handle] != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed\
                                to ripngServer getRouter $session_handle."
                        return $returnList
                    }
                    
                    if {[info exists router_id] && ([lindex $router_id \
                                $session_index] != "")} {
                        
                        catch {ripngRouter config -routerId \
                                    [lindex $router_id $session_index]}
                    }
                    
                    # Configure router
                    foreach item [array names ripngRouter] {
                        if {![catch {set $ripngRouter($item)} value] } {
                            if {[lsearch [array names enumList] $value] != -1} {
                                set value $enumList($value)
                            }
                            catch {ripngRouter config -$item $value}
                        }
                    }
                    # Set router
                    if {[ripngServer setRouter $session_handle] != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed\
                                to ripServer setRouter $session_handle."
                        return $returnList
                    }
                } else  {
                    if {[ripngServer select $chassis $card $port]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed\
                                to ripngServer select $chassis $card $port."
                        return $returnList
                    }
                    # Get server
                    if {[ripngServer get]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed\
                                to ripngServer get."
                        return $returnList
                    }
                }
                
                # Configure server
                foreach item [array names ripngServer] {
                    if {![catch {set $ripngServer($item)} value] } {
                        if {[lsearch [array names enumList] $value] != -1} {
                            set value $enumList($value)
                        }
                        catch {ripngServer config -$item $value}
                    }
                }
                # Set configuration on port
                if {[ripngServer set]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            ripngServer set failed."
                    return $returnList
                }
                
                lappend rip_routers_list $session_handle
                
                # Modify router id information in the array
                if {[info exists router_id] && ([lindex $router_id \
                            $session_index] != "")} {
                    
                    set retCode [::ixia::ripGetParamValueFromSession \
                            $session_handle intf_description]
                    
                    if {[keylget retCode status] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget retCode log]."
                        return $returnList
                    }
                    ::ixia::ripAddSessionHandle                    \
                            -session_handle   $session_handle      \
                            -port_handle      $chassis/$card/$port \
                            -intf_description                      \
                            [keylget retCode intf_description]     \
                            -rip_version      $session_type        \
                            -router_id                             \
                            [lindex $router_id $session_index]
                }
                incr session_index
            }
        }
        keylset returnList handle $rip_routers_list
    }
    if {![info exists no_write]} {
        set retCode [::ixia::writePortListConfig ]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_rip_route_config { args } {
    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_rip_route_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    
    ::ixia::utrackerLog $procName $args
    
    set man_args {
        -mode            CHOICES create modify delete
    }

    set opt_args {
        -handle
        -route_handle
        -num_prefixes       RANGE 1-1000000
        -prefix_start       IP
        -prefix_length      RANGE 1-128
        -prefix_step        IP
        -metric             RANGE 0-4294967295
        -next_hop           IP
        -route_tag          RANGE 0-65535
        -reset              FLAG
        -no_write           FLAG
    }
        
    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_rip_route_config $args $man_args $opt_args]
        if {[keylget returnList status] != $::SUCCESS} {
            keylset returnList log "ERROR in $procName: [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
    
    # Verify parameters given for each option
    if {$mode == "create"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: No -handle was\
                    passed to $mode."
            return $returnList
        }
        
    } elseif {($mode == "modify") || ($mode == "delete") } {
        if {![info exists route_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: No -route_handle was\
                    passed to $mode."
            return $returnList
        }
    }

    if {$mode == "create"} {
        set retCode [::ixia::ripConfigureRouteRange ]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget retCode log]"
            return $returnList
        }
        keylset returnList status [keylget retCode status]
        if {[keylget retCode status] == 0} {
            keylset returnList log [keylget retCode log]
        } else  {
            keylset returnList route_handle [keylget retCode route_handle]
        }
        
    } elseif {$mode == "modify"}  {
        set rip_route_ranges [list ]
        foreach routeItem $route_handle {
            set retCode [::ixia::ripGetParamValueFromRoute \
                    $routeItem session_handle]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
            set handle [keylget retCode session_handle]
 
            set retCode [::ixia::ripConfigureRouteRange ]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList route_handle $rip_route_ranges
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
            lappend rip_route_ranges $routeItem
        }
        keylset returnList status $::SUCCESS
        keylset returnList route_handle $rip_route_ranges
    } elseif {$mode == "delete"} {
        foreach routeItem $route_handle {
            set retCode [::ixia::ripGetParamValueFromRoute \
                    $routeItem session_handle]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
            set handle [keylget retCode session_handle]
            
            set retCode [::ixia::ripGetParamValueFromSession \
                    $handle rip_version]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
            set session_type [keylget retCode rip_version]
            
            set retCode [::ixia::ripGetParamValueFromSession \
                    $handle port_handle]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
            set port_handle [keylget retCode port_handle]
            set port_list [format_space_port_list $port_handle]
            foreach {chassis card port} [lindex $port_list 0] {}
            ::ixia::addPortToWrite $chassis/$card/$port
            
            if {($session_type == "ripv1") || ($session_type == "ripv2")} {
                set ripCmdServer ripServer
                set ripCmdRouter ripInterfaceRouter
                set ripCmdRouteRange ripRouteRange
                set ripCmdGet 0
                set ripCmdSet 0
            } elseif {$session_type == "ripng"} {
                set ripCmdServer ripngServer
                set ripCmdRouter ripngRouter
                set ripCmdRouteRange ripngRouteRange
                set ripCmdGet 1
                set ripCmdSet 1
            }
            if {[$ripCmdServer select $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed\
                        to select $ripCmdServer select $chassis $card $port."
                return $returnList
            }
            
            if {$ripCmdGet} {
                if {[$ripCmdServer get]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed\
                            to $ripCmdServer get."
                    return $returnList
                }
            }
            
            if {[$ripCmdServer getRouter $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed\
                        to $ripCmdServer getRouter $handle."
                return $returnList
            }

            if {[$ripCmdRouter delRouteRange $routeItem]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed\
                        to $ripCmdRouter delRouteRange $routeItem."
                return $returnList
            }
            
            if {[$ripCmdServer setRouter $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed\
                        to $ripCmdServer setRouter $handle."
                return $returnList
            }
            
            # Set configuration on port
            if {$ripCmdSet} {
                if {[$ripCmdServer set]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed\
                            to $ripCmdServer set."
                    return $returnList
                }
            }
            
            unset ::ixia::rip_route_handles_array($routeItem)
        }
        keylset returnList status $::SUCCESS
    }
    
    if {![info exists no_write]} {
        set retCode [::ixia::writePortListConfig ]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
    }
    return $returnList
}


proc ::ixia::emulation_rip_control { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_rip_control $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments        
    set opt_args {
        -port_handle        REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -handle
        -mode               CHOICES stop start restart flap
        -advertise
        -withdraw
    }

    if {[isUNIX]} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValueClicks [eval "clientSend $::ixTclSvrHandle {clock clicks}"]
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValueSeconds [eval "clientSend $::ixTclSvrHandle {clock seconds}"]
    } else {
        set retValueClicks [clock clicks]
        set retValueSeconds [clock seconds]
    }
    keylset returnList clicks [format "%u" $retValueClicks]
    keylset returnList seconds [format "%u" $retValueSeconds]

    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_rip_control $args {} $opt_args]
        keylset returnList clicks [format "%u" $retValueClicks]
        keylset returnList seconds [format "%u" $retValueSeconds]
        if {[keylget returnList status] != $::SUCCESS} {
            keylset returnList log "ERROR in $procName: [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    # If port handle is provided then look for $mode
    if {[info exists port_handle]} {
        set port_list [format_space_port_list $port_handle]
        
        set retCode [::ixia::writePortListConfig ]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
                
        switch -exact $mode {
            restart {
                if {[ixStopRip port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Error stopping\
                            RIP on the port list $port_list."
                    return $returnList
                }
                if {[ixStartRip port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Error starting\
                            RIP on the port list $port_list."
                    return $returnList
                }
                if {[ixStopRipng port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Error stopping\
                            RIPng on the port list $port_list."
                    return $returnList
                }
                if {[ixStartRipng port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Error starting\
                            RIPng on the port list $port_list."
                    return $returnList
                }
            }
            start {
                if {[ixStartRip port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Error starting\
                            RIP on the port list $port_list."
                    return $returnList
                }
                if {[ixStartRipng port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Error starting\
                            RIPng on the port list $port_list."
                    return $returnList
                }
            }
            stop {
                if {[ixStopRip port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Error stopping\
                            RIP on the port list $port_list."
                    return $returnList
                }
                if {[ixStopRipng port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Error stopping\
                            RIPng on the port list $port_list."
                    return $returnList
                }
            }
            default {
            }
        }
    }
    
    # If handle is provided then look for $mode
    if {[info exists handle]} {
        set port_handles_list_ripv ""
        set port_handles_list_ripn ""
        foreach session_handle $handle {
            set retCode [::ixia::ripGetParamValueFromSession \
                    $session_handle rip_version]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
            set session_type [keylget retCode rip_version]
            
            set retCode [::ixia::ripGetParamValueFromSession \
                    $session_handle port_handle]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
            set port_handle [keylget retCode port_handle]
            
            set ripVersion [string range $session_type 0 3]
            if {[lsearch [set port_handles_list_${ripVersion}] \
                        $port_handle] == -1} {
                
                lappend port_handles_list_${ripVersion} $port_handle
            }
            
            switch -exact $mode {
                restart {
                    set retCode [::ixia::ripEnableSessionHandle \
                            $session_handle true]
                    if {[keylget retCode status] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget retCode log]"
                        return $returnList
                    }
                }
                start {
                    set retCode [::ixia::ripEnableSessionHandle \
                            $session_handle true]
                    if {[keylget retCode status] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget retCode log]"
                        return $returnList
                    }
                }
                stop {
                    set retCode [::ixia::ripEnableSessionHandle \
                            $session_handle false]
                    if {[keylget retCode status] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget retCode log]"
                        return $returnList
                    }
                }
                default {
                }
            }
        }
        
        set retCode [::ixia::writePortListConfig ]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
        
        set port_handles_list_ripv [::ixia::format_space_port_list \
                $port_handles_list_ripv]
        
        set port_handles_list_ripn [::ixia::format_space_port_list \
                $port_handles_list_ripn]
        
        switch -exact $mode {
            restart {
                if {[llength $port_handles_list_ripn] > 0} {
                    if {[ixStopRipng port_handles_list_ripn]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Error stopping\
                                RIPng on the port list $port_handles_list_ripn."
                        return $returnList
                    }
                    if {[ixStartRipng port_handles_list_ripn]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Error starting\
                                RIPng on the port list $port_handles_list_ripn."
                        return $returnList
                    }
                }
                if {[llength $port_handles_list_ripv] > 0} {
                    if {[ixStopRip port_handles_list_ripv]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Error stopping\
                                RIP on the port list $port_handles_list_ripv."
                        return $returnList
                    }
                    if {[ixStartRip port_handles_list_ripv]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Error starting\
                                RIP on the port list $port_handles_list_ripv."
                        return $returnList
                    }
                }
            }
            start {
                if {[llength $port_handles_list_ripn] > 0} {
                    if {[ixStartRipng port_handles_list_ripn]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Error starting\
                                RIPng on the port list $port_handles_list_ripn."
                        return $returnList
                    }
                }
                if {[llength $port_handles_list_ripv] > 0} {
                    if {[ixStartRip port_handles_list_ripv]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Error starting\
                                RIP on the port list $port_handles_list_ripv."
                        return $returnList
                    }
                }
            }
            stop {
                if {[llength $port_handles_list_ripn] > 0} {
                    if {[ixStopRipng port_handles_list_ripn]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Error stopping\
                                RIPng on the port list $port_handles_list_ripn."
                        return $returnList
                    }
                }
                if {[llength $port_handles_list_ripv] > 0} {
                    if {[ixStopRip port_handles_list_ripv]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Error stopping\
                                RIP on the port list $port_handles_list_ripv."
                        return $returnList
                    }
                }
            }
            default {
            }
        }
        
    }
    
    # If advertise is provided then enable routes
    if {[info exists advertise]} {
        foreach {route} $advertise {
            set retCode [::ixia::ripEnableRouteRange $route true write]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
        }
    }
    
    # If withdraw is provided then disable routes
    if {[info exists withdraw]} {
        foreach {route} $withdraw {
            set retCode [::ixia::ripEnableRouteRange $route false write]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
        }
    }
    
    
    keylset returnList status $::SUCCESS
    return $returnList
}
