##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_bgp_api.tcl
#
# Purpose:
#     A script development library containing BGP APIs for test automation with the Ixia chassis.
#
# Author:
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_bgp_config
#    - emulation_bgp_route_config
#    - emulation_bgp_control
#    - emulation_bgp_info
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     parseddashedargs.tcl , a library containing the proceDescr and
#     parsedashedargds.tcl
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

proc ::ixia::emulation_bgp_config { args } {

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
                \{::ixia::emulation_bgp_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable bgp_neighbor_handles_array
    variable bgp_route_handles_array

    ::ixia::utrackerLog $procName $args

    # Arguments
    set man_args {
        -mode        CHOICES delete disable enable modify reset
    }

    set opt_args {
        -md5_enable                   CHOICES 0 1
        -md5_key                      ANY
        -port_handle                  REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle
        -ip_version                   CHOICES 4 6
                                      DEFAULT 4
        -local_ip_addr                IPV4
        -gateway_ip_addr              IP
        -remote_ip_addr               IPV4
        -local_ipv6_addr              IPV6
        -remote_ipv6_addr             IPV6
        -local_addr_step              IP
        -remote_addr_step             IP
        -next_hop_enable              CHOICES 0 1
                                      FLAG
        -next_hop_ip                  IP
        -enable_4_byte_as             CHOICES 0 1
                                      DEFAULT 0
        -local_as                     RANGE   0-4294967295
        -local_as_mode                CHOICES fixed increment
                                      DEFAULT fixed
        -remote_as                    RANGE   0-4294967295
        -local_as_step                RANGE   0-4294967295
                                      DEFAULT 1
        -update_interval              RANGE   0-65535
        -count                        NUMERIC
                                      DEFAULT 1
        -local_router_id              IPV4
        -local_router_id_step         IPV4
                                      DEFAULT 0.0.0.1
        -vlan                         CHOICES 0 1
        -vlan_id                      RANGE   0-4095
        -vlan_id_mode                 CHOICES fixed increment
                                      DEFAULT increment
        -vlan_id_step                 RANGE   0-4096
                                      DEFAULT 1
        -vlan_user_priority           RANGE   0-7
        -vpi                          RANGE   0-255
        -vci                          RANGE   0-65535
        -vpi_step                     RANGE   0-255
        -vci_step                     RANGE   0-65535
        -atm_encapsulation            CHOICES VccMuxIPV4Routed
                                      CHOICES VccMuxIPV6Routed
                                      CHOICES VccMuxBridgedEthernetFCS
                                      CHOICES VccMuxBridgedEthernetNoFCS
                                      CHOICES LLCRoutedCLIP
                                      CHOICES LLCBridgedEthernetFCS
                                      CHOICES LLCBridgedEthernetNoFCS
        -interface_handle             
        -retry_time                   NUMERIC
        -hold_time                    NUMERIC
        -neighbor_type                CHOICES internal external
        -graceful_restart_enable      FLAG
        -restart_time                 RANGE   0-10000000
        -stale_time                   RANGE   0-10000000
        -tcp_window_size              RANGE   0-10000000
        -staggered_start_enable       FLAG
        -staggered_start_time         RANGE   0-10000000
        -retries                      RANGE   0-10000000
        -local_router_id_enable
        -active_connect_enable        FLAG
        -netmask                      RANGE   1-128
        -mac_address_start            MAC
        -mac_address_step             MAC
                                      DEFAULT 0000.0000.0001
        -ipv4_mdt_nlri                FLAG
        -ipv4_unicast_nlri            FLAG
        -ipv4_multicast_nlri          FLAG
        -ipv4_mpls_nlri               FLAG
        -ipv4_mpls_vpn_nlri           FLAG
        -ipv6_unicast_nlri            FLAG
        -ipv6_multicast_nlri          FLAG
        -ipv6_mpls_nlri               FLAG
        -ipv6_mpls_vpn_nlri           FLAG
        -local_loopback_ip_addr       IP
        -local_loopback_ip_prefix_length NUMERIC
        -local_loopback_ip_addr_step  IP
        -remote_loopback_ip_addr      IP
        -remote_loopback_ip_addr_step IP
        -ttl_value                    NUMERIC
        -updates_per_iteration        RANGE   0-10000000
        -bfd_registration             CHOICES 0 1
                                      DEFAULT 0
        -bfd_registration_mode        CHOICES single_hop multi_hop
                                      DEFAULT multi_hop
        -override_existence_check     CHOICES 0 1
                                      DEFAULT 0
        -override_tracking            CHOICES 0 1
                                      DEFAULT 0
        -no_write                     FLAG
        -vpls                         CHOICES 0 1 disabled vpn no_vpn
                                      DEFAULT 0      
        -vpls_nlri                    FLAG
    }
    
    # If vpls_nlri (or other params of type FLAG) is specified, move it at the end of the $args list
    # Otherwise you might see a parse dashed args error like this <can't use non-numeric string as operand of "!">
    set args [::ixia::move_flags_last $args [list -next_hop_enable -vpls_nlri -ipv4_unicast_nlri\
            -ipv4_mpls_vpn_nlri -ipv6_mpls_nlri -graceful_restart_enable -staggered_start_enable\
            -active_connect_enable -ipv4_mdt_nlri -ipv4_multicast_nlri -ipv4_mpls_nlri\
            -ipv6_unicast_nlri -ipv6_multicast_nlri -ipv6_mpls_vpn_nlri]]
    
    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_bgp_config $args $man_args $opt_args]
        if {![catch {set log [keylget returnList log]}]} {
            keylset returnList log "ERROR in $procName: $log"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
        # On a modify certain defaults still need set, if the user did not
        # pass them in.
        set count 1
        if {![info exists local_as_mode]} {
            set local_as_mode fixed
        }
    }

    set option_list [list ip_version local_ip_addr remote_ip_addr              \
            next_hop_enable next_hop_ip local_as local_as_mode update_interval \
            local_router_id retry_time hold_time neighbor_type                 \
            graceful_restart_enable restart_time stale_time tcp_window_size    \
            staggered_start_enable staggered_start_time retries                \
            local_router_id_enable active_connect_enable ipv4_mdt_nlri ipv4_unicast_nlri     \
            ipv4_multicast_nlri ipv6_unicast_nlri ipv6_multicast_nlri          \
            ipv4_mpls_nlri ipv4_mpls_vpn_nlri ipv6_mpls_nlri                   \
            ipv6_mpls_vpn_nlri updates_per_iteration gateway_ip_addr md5_enable \
            md5_key                                                 			]

    set option_index 1

    switch -- $mode {
        reset {
            if {![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        -mode is $mode, then -port_handle must be provided."
                return $returnList
            }
        }
        enable -
        disable {
            if {![info exists handle] && ![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        -mode is $mode, then -handle or -port_handle\
                        must be provided."
                return $returnList
            }
        }
        modify - 
        delete {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When \
                        -mode is $mode, then -handle must be provided."
                return $returnList
            }
        }
        default {}
    }

    if {[info exists port_handle]} {
        set port_list [format_space_port_list $port_handle]
        foreach {chassis card port} [lindex $port_list 0] {}
        ::ixia::addPortToWrite $chassis/$card/$port
    } elseif {[info exists handle]} {
        if {![info exists bgp_neighbor_handles_array($handle)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument\
                    -handle $handle is not a valid BGP session handle."
            return $returnList
        }
        set port_handle_get $bgp_neighbor_handles_array($handle)
        set port_list [format_space_port_list $port_handle_get]
        foreach {chassis card port} [lindex $port_list 0] {}
        ::ixia::addPortToWrite $chassis/$card/$port
    }

    # Check if BGP package has been installed on the port
    if {[catch {bgp4Server select $chassis $card $port} error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The BGP4 protocol\
                has not been installed on port or is not supported on port: \
                $chassis/$card/$port."
        return $returnList
    }
    
    # Delete BGP neighbors on port if mode is delete
    if {$mode == "delete"} {
        bgp4Server select $chassis $card $port
        set handles [list]
        if {[info exists port_handle]} {
            foreach {bgp_neighbor_index bgp_neighbor_port} \
                    [array get bgp_neighbor_handles_array] {

                if {$bgp_neighbor_port ==  "$chassis/$card/$port"} {
                    if {[bgp4Server delNeighbor $bgp_neighbor_index]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Could \
                                not delete BGP router: $bgp_neighbor_index."
                        return $returnList
                    }
                    lappend handles $bgp_neighbor_index
                }
            }
        } elseif {[info exists handle]} {
            foreach $handle_item $handle {
                if {[bgp4Server delNeighbor $handle_item]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Could \
                            not delete BGP router: $handle_item."
                    return $returnList
                }
                lappend handles $handle_item
            }
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
        keylset returnList handles $handles
        keylset returnList status $::SUCCESS
        return $returnList
    }

    # Disable BGP neighbors on port if mode is disable
    if {$mode == "disable"} {
        bgp4Server select $chassis $card $port
        set handles [list]
        if {[info exists port_handle]} {
            foreach {bgp_neighbor_index bgp_neighbor_port} \
                    [array get bgp_neighbor_handles_array] {

                if {$bgp_neighbor_port ==  "$chassis/$card/$port"} {
                    if {[bgp4Server getNeighbor $bgp_neighbor_index]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Could \
                                not get BGP router: $bgp_neighbor_index."
                        return $returnList
                    }
                    bgp4Neighbor config -enable false
                    if {[bgp4Server setNeighbor $bgp_neighbor_index]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Could \
                                not set BGP router: $bgp_neighbor_index."
                        return $returnList
                    }
                    lappend handles $bgp_neighbor_index
                }
            }
        } elseif {[info exists handle]} {
            if {[bgp4Server getNeighbor $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could \
                        not get BGP router: $handle."
                return $returnList
            }
            bgp4Neighbor config -enable false
            if {[bgp4Server setNeighbor $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could \
                        not set BGP router: $handle."
                return $returnList
            }
            lappend handles $handle
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
        keylset returnList handles $handles
        keylset returnList status $::SUCCESS
        return $returnList
    }

    # Enable BGP neighbors on port if mode is enable and -handle is present
    if {$mode == "enable"} {
        if {[info exists handle]} {
            bgp4Server select $chassis $card $port
            if {[bgp4Server getNeighbor $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could \
                        not get BGP router: $handle."
                return $returnList
            }
            bgp4Neighbor config -enable true
            if {[bgp4Server setNeighbor $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could \
                        not set BGP router: $handle."
                return $returnList
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
            keylset returnList handles $handle
            keylset returnList status $::SUCCESS
            return $returnList
        }
    }
    # If the user is modifying an existing configuration, the mode will be
    # modify and an input option handle will exist.  A flag will be set to
    # indicate this combination.
    set router_configuration_flag 0

    # Check if the call is for enable or reset
    if {($mode == "reset") || ($mode == "enable")} {
        # Create default value list and initialize parameters if required
        set param_value_list [list                      \
                neighbor_type                internal   \
                local_loopback_ip_addr       0.0.0.0    \
                local_loopback_ip_addr_step  0.1.0.0    \
                remote_loopback_ip_addr      0.0.0.0    \
                remote_loopback_ip_addr_step 0.1.0.0    \
                ]

        foreach {param value} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            }
        }
        
        if {![info exists local_ip_addr] && ![info exists local_ipv6_addr]} {
            set local_ip_addr 0.0.0.0
        }
        if {![info exists remote_ip_addr] && ![info exists remote_ipv6_addr]} {
            if {[info exists local_ip_addr]} {
                set remote_ip_addr 0.0.0.0
            } elseif {[info exists local_ipv6_addr]} {
                set remote_ipv6_addr 0:0:0:0:0:0:0:0
            } else {
                set remote_ip_addr 0.0.0.0
            }
        }
        if {[info exists vpls_nlri]} {
            if {($vpls_nlri != 0) && ($vpls_nlri != "disabled")} {
                set vpls 1
            } else {
                set vpls 0
            }
        } elseif {[info exists vpls]} {
            if {($vpls != 0) && ($vpls != "disabled")} {
                set vpls 1
            } else {
                set vpls 0
            }
        } else {
            set vpls 0
        }
    } else  {
        # Modify existing configuration
        set router_configuration_flag 1
        set port_handle $bgp_neighbor_handles_array($handle)
        
        if {[info exists vpls_nlri]} {
            if {($vpls_nlri != 0) && ($vpls_nlri != "disabled")} {
                set vpls 1
            } else {
                set vpls 0
            }
        } elseif {[info exists vpls]} {
            if {($vpls != 0) && ($vpls != "disabled")} {
                set vpls 1
            } else {
                set vpls 0
            }
        }
    }
    
    

    # This is creating the neighbor
    if {$router_configuration_flag == 0} {
        # Get the number of interfaces already configured on the port
        set number_of_interfaces [get_number_of_intf "$chassis $card $port"]

        #################################
        #  CONFIGURE THE IXIA INTERFACES
        #################################
        if {[info exists local_ipv6_addr]} {
            set connected_ip_version 6
            set local_ip_addr  $local_ipv6_addr
            set remote_ip_addr $remote_ipv6_addr
        } else {
            set connected_ip_version 4
        }
        if {[info exists local_loopback_ip_addr]} {
            if {[isIpAddressValid $local_loopback_ip_addr]} {
                set unconnected_ip_version 4
            } else {
                set unconnected_ip_version 6
            }
        } else {
            unconnected_ip_version 0
        }
        # Since these values can contain data for IPv4 and IPv6, we cannot
        # default them in the definition above.
        if {$connected_ip_version == 4} {
            if {![info exists netmask]} {
                set netmask 24
            } elseif {$netmask > 32}  {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid netmask \
                        $netmask for ip version ${connected_ip_version}."
                return $returnList
            }
            if {![info exists local_addr_step]} {
                set local_addr_step 0.1.0.0
            }
            if {![info exists remote_addr_step]} {
                set remote_addr_step 0.1.0.0
            }
            # Set gateway ip / gateway ip step
            if {![info exists gateway_ip_addr]} {
                if {[info exists remote_ip_addr]} {
                    set gateway_ip_addr $remote_ip_addr
                }
            } elseif {![isValidIPv4Address $gateway_ip_addr]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid gateway_ip_addr \
                        $gateway_ip_addr for ip version ${connected_ip_version}."
                return $returnList
            }
            
            set gateway_ip_addr_step $remote_addr_step
        } else {
            if {![info exists netmask]} {
                set netmask 64
            }
            if {![info exists local_addr_step] || \
                    ([info exists local_addr_step] && \
                    ![::ipv6::isValidAddress $local_addr_step])} {
                set local_addr_step 0:0:0:0:1::0
            }
            if {![info exists remote_addr_step] || \
                    ([info exists remote_addr_step] && \
                    ![::ipv6::isValidAddress $remote_addr_step])} {
                set remote_addr_step 0:0:0:0:1::0
            }
            
            # Set gateway ip / gateway ip step
            if {![info exists gateway_ip_addr]} {
                if {[info exists remote_ip_addr]} {
                    set gateway_ip_addr $remote_ip_addr
                }
            } elseif {![::ipv6::isValidAddress $gateway_ip_addr]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid gateway_ip_addr \
                        $gateway_ip_addr for ip version ${connected_ip_version}."
                return $returnList
            }
            set gateway_ip_addr_step $remote_addr_step

        }
        if {$unconnected_ip_version == 6} {
            if {![info exists local_loopback_ip_addr_step] || \
                    ([info exists local_loopback_ip_addr_step] && \
                    ![::ipv6::isValidAddress $local_loopback_ip_addr_step])} {
                set local_loopback_ip_addr_step 0:0:0:0:1::0
            }
            if {![info exists remote_loopback_ip_addr_step] || \
                    ([info exists remote_loopback_ip_addr_step] && \
                    ![::ipv6::isValidAddress $remote_loopback_ip_addr_step])} {
                set remote_loopback_ip_addr_step 0:0:0:0:1::0
            }
        }
        set config_param \
                "-port_handle $port_handle      \
                -count        $count            \
                -ip_address   $local_ip_addr    \
                -ip_version   $connected_ip_version "

        set config_options \
                "-mac_address             mac_address_start           \
                -ip_address_step          local_addr_step             \
                -gateway_ip_address       gateway_ip_addr             \
                -gateway_ip_address_step  gateway_ip_addr_step        \
                -netmask                  netmask                     \
                -vlan_id                  vlan_id                     \
                -vlan_id_mode             vlan_id_mode                \
                -vlan_id_step             vlan_id_step                \
                -vlan_user_priority       vlan_user_priority          \
                -loopback_ip_address      local_loopback_ip_addr      \
                -loopback_ip_address_step local_loopback_ip_addr_step \
                -no_write                 no_write"

        foreach {option value_name} $config_options {
            if {[info exists $value_name]} {
                append config_param " $option [set $value_name] "
            }
        }

        set intf_status [eval ixia::protocol_interface_config \
                $config_param]

        if {[keylget intf_status status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to create the\
                    needed protocol interfaces for the bgp configuration to\
                    utilize.  Log : [keylget intf_status log]"
            return $returnList
        }

        set intf_descs [keylget intf_status description]
    }

    set retCode [bgp4Server select $chassis $card $port]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to\
                bgp4Server select $chassis $card $port. \
                Return code was $retCode. \n$::ixErrorInfo"
        return $returnList
    }

    # Reset BGP neighbors if requested
    if {$mode == "reset"} {
        bgp4Server clearAllNeighbors
        foreach {bgp_neighbor_index bgp_neighbor_port} \
                [array get bgp_neighbor_handles_array] {
            if {$bgp_neighbor_port ==  "$chassis/$card/$port"} {
                foreach {bgp_route_index bgp_route_value} \
                        [array get bgp_route_handles_array] {

                    if {[keylget bgp_route_value neighbor] == \
                            $bgp_neighbor_index} {
                        unset bgp_route_handles_array($bgp_route_index)
                    }
                }
                unset bgp_neighbor_handles_array($bgp_neighbor_index)
            }
        }
        bgp4StatsQuery get $chassis $card $port
        bgp4StatsQuery clearAllNeighbors
        bgp4StatsQuery clearAllStats
    }

    for {set j 1} {$j <= $count} {incr j} {

        # Get next neighbor on the Ixia interface
        if {![info exists handle]} {
            # Get next available neighbor on the interface
            set retCode [::ixia::bgpGetNextHandle neighbor]
            set next_bgp_neighbor [keylget retCode next_handle]
            set bgp_type $neighbor_type

            bgp4Neighbor  setDefault
            bgp4RouteItem setDefault
            bgp4Server    setDefault
            bgp4Neighbor  clearAllRouteRanges
            bgp4Neighbor  clearAllMplsRouteRanges
            bgp4Neighbor  clearAllL3Sites

            bgp4Server config -enableInternalActiveConnect true
            bgp4Server config -enableInternalEstablishOnce false
            bgp4Server config -enableExternalActiveConnect true
            bgp4Server config -enableExternalEstablishOnce false

            bgp4Neighbor config -enableNextHop  false
            bgp4Neighbor config -enableBgpId    false
            bgp4Neighbor config -enableLinkFlap false

            # Interface Description
            set interface_description [lindex $intf_descs $j]

            # Set the BGP ID by default to the Ixia BGP router
            # Check for IPv6 default ID address!
            if {$connected_ip_version == 4} {
                bgp4Neighbor config -bgpId $local_ip_addr
            }
            if {$unconnected_ip_version == 4 && \
                    [info exists local_loopback_ip_addr] && \
                    ($local_loopback_ip_addr != "0.0.0.0")} {
                bgp4Neighbor config -bgpId $local_loopback_ip_addr
            }
        } else {

            set next_bgp_neighbor $handle
            bgp4Neighbor setDefault
            if {[bgp4Server getNeighbor $next_bgp_neighbor]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not get BGP\
                        router: $next_bgp_neighbor."
                return $returnList
            }

            # Get the BGP type for this neighbor
            set bgp_type_temp [bgp4Neighbor cget -type]

            if { $bgp_type_temp == 0 } {
                set bgp_type "internal"
            } elseif { $bgp_type_temp == 1 } {
                set bgp_type "external"
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not get BGP\
                        router type for BGP router: $next_bgp_neighbor."
                return $returnList
            }

            # Get the IP version for this neighbor
            if {[bgp4Neighbor cget -ipType] == $::addressTypeIpV4 } {
                set connected_ip_version 4
            } elseif {[bgp4Neighbor cget -ipType] == $::addressTypeIpV6 } {
                set connected_ip_version 6
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not get BGP\
                        IP version for BGP router: $next_bgp_neighbor."
                return $returnList
            }
            set unconnected_ip_version 0
        }

        bgp4Neighbor config -enable true

        if {$router_configuration_flag == 0} {
            # Check if the user passed the local as number of neighbor
            # is external
            if {$neighbor_type == "external"} {
                if {![info exists local_as]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When\
                            configuring External BGP neighbor, please\
                            configure the Local AS number with the option\
                            <-local_as>."
                    return $returnList
                }
            }

            # Default values, certain configs only available in IxOS 3.80 and
            # greater, so catch them to suppress inadvertant errors
            catch {bgp4Neighbor config -enableIpV4Unicast     false}
            catch {bgp4Neighbor config -enableIpV4Multicast   false}
            catch {bgp4Neighbor config -enableIpV4Mpls        false}
            catch {bgp4Neighbor config -enableIpV4MplsVpn     false}
            catch {bgp4Neighbor config -enableIpV6Unicast     false}
            catch {bgp4Neighbor config -enableIpV6Multicast   false}
            catch {bgp4Neighbor config -enableIpV6Mpls        false}
            catch {bgp4Neighbor config -enableIpV6MplsVpn     false}
            catch {bgp4Neighbor config -enableVpls            false}
            catch {bgp4Neighbor config -enableGracefulRestart false}
            bgp4Neighbor config -enableBgpId           false
            bgp4Neighbor config -enableStaggeredStart  false
            bgp4Neighbor config -enableNextHop         false

            if {$neighbor_type == "internal"} {
                # If the neighbor is internal, need to deactivate external active connection
                bgp4Server config -enableExternalActiveConnect false
            } elseif {$neighbor_type == "external"} {
                # If the neighbor is external, need to deactivate internal active connection
                bgp4Server config -enableInternalActiveConnect false
            }
        }

        foreach single_option_list $option_list {
            if {[info exists $single_option_list]} {
                eval set single_option_list_eval $$single_option_list
                set single_option [lindex $single_option_list_eval \
                        [expr $option_index-1]]

                switch -- $single_option_list {
                    md5_enable {
                        bgp4Neighbor config -authenticationType $single_option
                    }
                    md5_key {
                        bgp4Neighbor config -md5Key $single_option
                    }
                    bfd_registration {
                        bgp4Neighbor config  -enableBFDRegistration \
                                $bfd_registration
                    }
                    bfd_registration_mode {
                        array set translate_bfd {
                            multi_hop  0
                            single_hop 1
                        }
                        bgp4Neighbor config -bfdModeOfOperation \
                                $translate_bfd($bfd_registration_mode)
                    }
                    local_as_mode {
                        switch -- $single_option {
                            fixed       {
                                bgp4Neighbor config -asNumMode bgp4AsNumModeFixed
                            }
                            increment {
                                bgp4Neighbor config -asNumMode \
                                        bgp4AsNumModeIncrement
                            }
                            default {}
                        }
                    }
                    active_connect_enable {
                        if {$bgp_type == "internal"} {
                            bgp4Server config -enableInternalActiveConnect true
                        } elseif {$bgp_type == "external"} {
                            bgp4Server config -enableExternalActiveConnect true
                        }
                    }
                    graceful_restart_enable {
                        catch {bgp4Neighbor config -enableGracefulRestart true}
                    }
                    local_router_id_enable {
                        bgp4Neighbor config -enableBgpId true
                    }
                    next_hop_enable {
                        if {$single_option == ""} {
                            bgp4Neighbor config -enableNextHop true
                        } else  {
                            bgp4Neighbor config -enableNextHop $single_option
                        }
                    }
                    staggered_start_enable {
                        bgp4Neighbor config -enableStaggeredStart true
                    }
                    hold_time {
                        bgp4Neighbor config -holdTimer $single_option
                    }
                    ip_version {
                        if {[info exists local_loopback_ip_addr] && \
                                ($local_loopback_ip_addr != "0.0.0.0")} {
                            set single_option $unconnected_ip_version
                        } else {
                            set single_option $connected_ip_version
                        }
                        
                        switch -- $single_option {
                            4 {
                                bgp4Neighbor config -ipType addressTypeIpV4
                            }
                            6 {
                                bgp4Neighbor config -ipType addressTypeIpV6
                            }
                            default  {}
                        }
                    }
                    ipv4_mdt_nlri {
                        catch {bgp4Neighbor config -enableIpV4Mdt true}
                    }
                    ipv4_unicast_nlri {
                        catch {bgp4Neighbor config -enableIpV4Unicast true}
                    }
                    ipv4_multicast_nlri {
                        catch {bgp4Neighbor config -enableIpV4Multicast true}
                    }
                    ipv4_mpls_nlri {
                        catch {bgp4Neighbor config -enableIpV4Mpls true}
                    }
                    ipv4_mpls_vpn_nlri {
                        catch {bgp4Neighbor config -enableIpV4MplsVpn true}
                    }
                    ipv6_multicast_nlri {
                        catch {bgp4Neighbor config -enableIpV6Multicast true}
                    }
                    ipv6_unicast_nlri {
                        catch {bgp4Neighbor config -enableIpV6Unicast true}
                    }
                    ipv6_mpls_nlri {
                        catch {bgp4Neighbor config -enableIpV6Mpls true}
                    }
                    ipv6_mpls_vpn_nlri {
                        catch {bgp4Neighbor config -enableIpV6MplsVpn true}
                    }
                    vpls {
                        catch {bgp4Neighbor config -enableVpls $vpls}
                    }
                    local_as {
                        if {$bgp_type == "internal"} {
                            bgp4Server config -internalLocalAsNum $single_option

                            set isLinuxOnPort [port isValidFeature $chassis \
                                    $card 1 portFeatureIxRouter]
                            if {$isLinuxOnPort == 1} {
                                bgp4Neighbor config -localAsNumber \
                                        $single_option
                            }
                        } elseif {$bgp_type == "external"} {
                            bgp4Neighbor config -localAsNumber $single_option
                        }
                        if {($single_option < 0) || ($single_option > 65535)} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Invalid -local_as $single_option for BGP\
                                    neighbor ${next_bgp_neighbor}."
                            return $returnList
                        }
                    }
                    local_ip_addr {
                        if {[info exists local_loopback_ip_addr] && ($local_loopback_ip_addr != "0.0.0.0")} {
                            bgp4Neighbor config -localIpAddress $local_loopback_ip_addr
                        } else {
                            bgp4Neighbor config -localIpAddress $single_option
                        }
                    }
                    local_router_id {
                        bgp4Neighbor config -enableBgpId true
                        bgp4Neighbor config -bgpId $single_option
                    }
                    neighbor_type {
                        switch -- $single_option {
                            internal {
                                bgp4Neighbor config -type bgp4NeighborInternal
                            }
                            external  {
                                bgp4Neighbor config -type bgp4NeighborExternal
                            }
                            default  {}
                        }
                    }
                    next_hop_ip {
                        bgp4Neighbor config -enableNextHop true
                        bgp4Neighbor config -nextHop $single_option
                    }
                    updates_per_iteration {
                        bgp4Neighbor config -numUpdatesPerIteration \
                                $single_option
                    }
                    remote_ip_addr {
                        if {[info exists remote_loopback_ip_addr] && ($remote_loopback_ip_addr != "0.0.0.0")} {
                            bgp4Neighbor config -dutIpAddress $remote_loopback_ip_addr
                        } else {
                            bgp4Neighbor config -dutIpAddress $single_option
                        }
                    }
                    restart_time {
                        catch {bgp4Neighbor config -enableGracefulRestart true}
                        catch {bgp4Neighbor config -restartTime $single_option}
                    }
                    retries {
                        if {$bgp_type == "internal"} {
                            bgp4Server config -internalRetries $single_option
                        } elseif {$bgp_type == "external"} {
                            bgp4Server config -externalRetries $single_option
                        }
                    }
                    retry_time {
                        if {$bgp_type == "internal"} {
                            bgp4Server config -internalRetryDelay $single_option
                        } elseif {$bgp_type == "external"} {
                            bgp4Server config -externalRetryDelay $single_option
                        }
                    }
                    staggered_start_time {
                        bgp4Neighbor config -staggeredStartPeriod $single_option
                    }
                    stale_time {
                        bgp4Neighbor config -staleTime $single_option
                    }
                    tcp_window_size {
                        bgp4Neighbor config -tcpWindowSize $single_option
                    }
                    ttl_value {
                        bgp4Neighbor config -ucTTLval $single_option
                    }
                    update_interval {
                        bgp4Neighbor config -updateInterval $single_option
                    }
                }
            }
        }

        if {$router_configuration_flag == 0} {
#             set statLocalIpAddr [bgp4Neighbor cget -localIpAddress ]
#             set statDutIpAddr   [bgp4Neighbor cget -dutIpAddress   ]
#             if {[::ipv6::isValidAddress $statLocalIpAddr]} {
#                 set statIpType addressTypeIpV6
#             } else  {
#                 set statIpType addressTypeIpV4
#             }
            if {[bgp4Server addNeighbor $next_bgp_neighbor] != 0 } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not add BGP\
                        neighbor $next_bgp_neighbor to port: $chassis $card\
                        $port."
                return $returnList
            }
        } elseif {$router_configuration_flag == 1} {
            if {[bgp4Server setNeighbor $next_bgp_neighbor] != 0 } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not set BGP\
                        neighbor $next_bgp_neighbor to port: $chassis $card\
                        $port."
                return $returnList
            }
        }

        set retCode [bgp4Server set]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in call to\
                    bgp4Server set.  Return code was $retCode."
            return $returnList
        }

        lappend bgp_neighbor_list $next_bgp_neighbor

        # Maintain the list of references between ports and handles
        set bgp_neighbor_handles_array($next_bgp_neighbor) \
                "$chassis/$card/$port"

        ###
        # Increment IP addresses and AS number
        ###
        if {$router_configuration_flag == 0} {
            if {$connected_ip_version == 4} {
                set local_ip_addr [::ixia::increment_ipv4_address_hltapi \
                        $local_ip_addr $local_addr_step]
                set remote_ip_addr [::ixia::increment_ipv4_address_hltapi \
                        $remote_ip_addr $remote_addr_step]
            } elseif {$ip_version == 6} {
                set local_ip_addr [::ixia::increment_ipv6_address_hltapi \
                        $local_ip_addr $local_addr_step]
                set remote_ip_addr [::ixia::increment_ipv6_address_hltapi \
                        $remote_ip_addr $remote_addr_step]
            }
            
            if {$unconnected_ip_version == 4} {
                # Loopback Addresses
                if {$local_loopback_ip_addr != "0.0.0.0"} {
                    set local_loopback_ip_addr \
                            [::ixia::increment_ipv4_address_hltapi \
                            $local_loopback_ip_addr $local_loopback_ip_addr_step]
                }
                if {$remote_loopback_ip_addr != "0.0.0.0"} {
                    set remote_loopback_ip_addr \
                            [::ixia::increment_ipv4_address_hltapi \
                            $remote_loopback_ip_addr \
                            $remote_loopback_ip_addr_step]
                }
            } elseif {$ip_version == 6} {
                # Loopback Addresses
                if {$local_loopback_ip_addr != "0.0.0.0"} {
                    set local_loopback_ip_addr \
                            [::ixia::increment_ipv6_address_hltapi \
                            $local_loopback_ip_addr $local_loopback_ip_addr_step]
                }
                if {$remote_loopback_ip_addr != "0.0.0.0"} {
                    set remote_loopback_ip_addr \
                            [::ixia::increment_ipv6_address_hltapi \
                            $remote_loopback_ip_addr \
                            $remote_loopback_ip_addr_step]
                }
            }
        }

        # Increment the AS when local_as_mode is increment
        if {($local_as_mode == "increment") && [info exists local_as]} {
            incr local_as $local_as_step
        }

        # Increment local router id
        if {[info exists local_router_id] && \
                [info exists local_router_id_step]} {
            set local_router_id [::ixia::increment_ipv4_address_hltapi \
                    $local_router_id $local_router_id_step]
        }
    }

    stat config -enableBgpStats $::true
    set retCode [stat set $chassis $card $port]
    if {$retCode != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure in call to stat\
                set $chassis $card $port.  Return code was $retCode."
        return $returnList
    }

    set retCode [protocolServer get $chassis $card $port]
    if {$retCode != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure in call to\
                protocolServer get $chassis $card $port.  Return code was\
                $retCode."
        return $returnList
    }
    protocolServer config -enableBgp4Service true
    set retCode [protocolServer set $chassis $card $port]
    if {$retCode != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure in call to\
                protocolServer set $chassis $card $port.  Return code was\
                $retCode."
        return $returnList
    }

    set retCode [bgp4Server set]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure in call to\
                bgp4Server set.  Return code was $retCode."
        return $returnList
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
    keylset returnList status    $::SUCCESS

    if {($mode == "enable") || ($mode == "reset")} {
        keylset returnList handles $bgp_neighbor_list
    }

    return $returnList
}


proc ::ixia::emulation_bgp_route_config { args } {
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
                \{::ixia::emulation_bgp_route_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable bgp_neighbor_handles_array
    variable bgp_route_handles_array

    ::ixia::utrackerLog $procName $args
    # Arguments
    set man_args {
        -handle REGEXP  ^.+$
        -mode   CHOICES add remove
    }
    
    set opt_args {
        -end_of_rib                          CHOICES 0 1
        -route_handle                        REGEXP  ^.+$
        -l3_site_handle                      REGEXP  ^.+$
        -ip_version                          CHOICES 4 6
                                             DEFAULT 4
        -prefix                              IP
                                             CHOICES all
        -netmask                             IP
        -ipv6_prefix_length                  RANGE   1-128
        -num_sites                           NUMERIC
        -num_routes                          NUMERIC
        -num_labels                          RANGE   1-65535
                                             DEFAULT 1
        -num_labels_type                     CHOICES list single_value
                                             DEFAULT single_value
        -max_route_ranges                    NUMERIC
                                             DEFAULT 1
        -mtu                                 RANGE   0-65535
                                             DEFAULT 1500
        -prefix_from                         RANGE   0-128
        -prefix_to                           RANGE   0-128
        -prefix_step                         NUMERIC
        -prefix_step_across_vrfs             IP
        -packing_from                        RANGE   0-65535
        -packing_to                          RANGE   0-65535
        -route_ip_addr_step                  IP
        -origin_route_enable                 FLAG
        -originator_id_enable                VCMD ::ixia::validate_flag_choice_0_1
        -origin                              CHOICES igp egp incomplete
        -as_path                             REGEXP  ^.+$
        -as_path_set_mode                    CHOICES include_as_seq include_as_seq_conf include_as_set include_as_set_conf no_include prepend_as
                                             DEFAULT include_as_seq
        -next_hop                            IP
        -next_hop_enable                     CHOICES 0 1
                                             FLAG
                                             DEFAULT 1
        -next_hop_set_mode                   CHOICES same manual
                                             DEFAULT same
        -next_hop_ip_version                 CHOICES 4 6
        -next_hop_mode                       CHOICES fixed increment incrementPerPrefix
        -multi_exit_disc                     NUMERIC
        -local_pref                          NUMERIC
                                             DEFAULT 0
        -atomic_aggregate                    FLAG
        -aggregator                          REGEXP  ^[0-9]{1,5}:[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$
        -communities_enable                  FLAG
        -communities                         VCMD ::ixia::validate_bgp_communities
        -ext_communities                     REGEXP  ^.+$
        -enable_local_pref                   CHOICES 0 1
        -enable_as_path                      CHOICES 0 1
        -originator_id                       IP
        -cluster_list_enable                 CHOICES 0 1
                                             FLAG
        -cluster_list                        REGEXP ^([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}\s*)+|([0-9]+\s*)+$
        -label_block_offset                  RANGE 0-65535
                                             DEFAULT 0
        -label_block_offset_type             CHOICES list single_value
                                             DEFAULT single_value
        -label_value                         NUMERIC
                                             DEFAULT 16
        -label_id                            NUMERIC
                                             DEFAULT 0
        -label_value_end                     NUMERIC
        -label_value_type                    CHOICES list single_value
                                             DEFAULT single_value
        -label_incr_mode                     CHOICES fixed rd prefix
        -label_step                          NUMERIC
                                             DEFAULT 1
        -l2_start_mac_addr                   MAC
        -l2_mac_incr                         CHOICES 0 1
                                             DEFAULT 0
        -l2_mac_count                        NUMERIC
                                             DEFAULT 1
        -l2_enable_vlan                      CHOICES 0 1
                                             DEFAULT 0
        -l2_vlan_id                          RANGE 0-65535
                                             DEFAULT 1
        -l2_vlan_id_incr                     NUMERIC
        -l2_vlan_incr                        CHOICES 0 1 2 3 no_increment parallel_increment inner_first outer_first
                                             DEFAULT 0
        -rd_type                             RANGE 0-2
                                             DEFAULT 0
        -rd_admin_value                      IP
                                             NUMERIC
        -rd_admin_value_step                 IP
                                             NUMERIC
        -rd_admin_value_step_across_vrfs     IP
                                             NUMERIC
        -rd_assign_value                     NUMERIC
        -rd_assign_value_step                NUMERIC
        -rd_assign_value_step_across_vrfs    NUMERIC
        -rd_admin_step                       IP
                                             NUMERIC
        -rd_assign_step                      NUMERIC
        -rd_count                            NUMERIC
                                             DEFAULT 1
        -rd_count_per_vrf                    NUMERIC
                                             DEFAULT 1
        -site_id                             RANGE 0-65535
                                             DEFAULT 0
        -site_id_step                        RANGE 0-65535
                                             DEFAULT 0
        -target_type                         CHOICES as ip
        -target                              IP
                                             NUMERIC
        -target_count                        NUMERIC
        -target_assign                       NUMERIC
        -target_step                         IP
                                             NUMERIC
        -target_inner_step                   IP
                                             NUMERIC
        -target_assign_step                  NUMERIC
        -target_assign_inner_step            NUMERIC
        -import_target_type                  CHOICES as ip
        -import_target                       IP
                                             NUMERIC
        -import_target_assign                NUMERIC
        -import_target_step                  IP
                                             NUMERIC
        -import_target_inner_step            IP
                                             NUMERIC
        -import_target_assign_step           NUMERIC
        -import_target_assign_inner_step     NUMERIC
        -ipv4_unicast_nlri                   FLAG
        -ipv4_multicast_nlri                 FLAG
        -ipv4_mpls_nlri                      FLAG
        -ipv4_mpls_vpn_nlri                  FLAG
        -ipv6_unicast_nlri                   FLAG
        -ipv6_multicast_nlri                 FLAG
        -ipv6_mpls_nlri                      FLAG
        -ipv6_mpls_vpn_nlri                  FLAG
        -default_mdt_ip                      IP
        -default_mdt_ip_incr                 IP
        -enable_generate_unique_routes       FLAG
        -enable_partial_route_flap           FLAG
        -enable_route_flap                   FLAG
        -enable_traditional_nlri             CHOICES 0 1
                                             DEFAULT 1
        -flap_down_time                      NUMERIC
        -flap_up_time                        NUMERIC
        -partial_route_flap_from_route_index NUMERIC
        -partial_route_flap_to_route_index   NUMERIC
        -no_write                            FLAG
        -vpls                                FLAG
        -vpls_nlri                           FLAG
    }
    
    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_bgp_route_config $args $man_args $opt_args]
        if {![catch {set log [keylget returnList log]}]} {
            keylset returnList log "ERROR in $procName: $log"
        }
        return $returnList
    }
    if {[catch {::ixia::parse_dashed_args     \
            -args           $args             \
            -optional_args  $opt_args         \
            -mandatory_args $man_args         \
            } parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $parseError."
        return $returnList
    }

    set option_list {
            end_of_rib ip_version prefix netmask ipv6_prefix_length
            num_routes prefix_from prefix_to prefix_step packing_from
            packing_to origin_route_enable origin as_path as_path_set_mode next_hop
            next_hop_enable next_hop_mode next_hop_set_mode next_hop_ip_version
            multi_exit_disc local_pref atomic_aggregate aggregator
            communities_enable communities originator_id_enable
            originator_id cluster_list_enable cluster_list ext_communities
            label_value label_incr_mode label_step rd_type
            rd_admin_value rd_assign_value rd_admin_step rd_assign_step
            ipv4_unicast_nlri ipv4_multicast_nlri ipv4_mpls_nlri
            ipv4_mpls_vpn_nlri ipv6_unicast_nlri ipv6_multicast_nlri
            ipv6_mpls_nlri ipv6_mpls_vpn_nlri enable_generate_unique_routes
            enable_partial_route_flap enable_route_flap
            enable_traditional_nlri flap_down_time flap_up_time
            partial_route_flap_from_route_index
            partial_route_flap_to_route_index
            target_number import_target_number 
    }
	
    set l3_option_list [list rd_type rd_admin_value rd_assign_value         \
            rd_admin_step rd_assign_step cluster_list_enable cluster_list   ]

    # These values are what we are keying on to trigger either an MPLS route
    # range or a VPN route range instead of a regular route range
    set vpn_flag 0
    if {([info exists num_sites] || [info exists end_of_rib]) && ([info exists ipv4_mpls_vpn_nlri] || \
            [info exists ipv6_mpls_vpn_nlri])} {
        set vpn_flag vpn
    } elseif {[info exists ipv4_mpls_nlri] || [info exists ipv6_mpls_nlri]} {
        set vpn_flag mpls
    }
    if {[info exists vpls_nlri]} {
        if {($vpls_nlri != 0) && ($vpls_nlri != "disabled")} {
            set vpls 1
        } else {
            set vpls 0
        }
    } elseif {[info exists vpls]} {
        if {($vpls != 0) && ($vpls != "disabled")} {
            set vpls 1
        } else {
            set vpls 0
        }
    }

	if {![info exists num_sites]} {set num_sites 1}
	if {[info exists end_of_rib] && ![info exists num_routes]} {set num_routes 1}

    set option_index 1

    # Find the port handle given the handle
    if {[info exists bgp_neighbor_handles_array($handle)]} {
        set port_handle $bgp_neighbor_handles_array($handle)
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The neighbor handle\
                $handle is not valid."
        return  $returnList
    }

    set port_list [format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    # Set chassis card port
    foreach {chassis card port} $interface {}
    ::ixia::addPortToWrite $chassis/$card/$port

    # Check if BGP package has been installed on the port
    set retCode [bgp4Server select $chassis $card $port]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure on call bgp4Server\
                select $chassis $card $port.  Return code was $retCode. \
                This could mean the protocol is not installed on the port or\
                not supported on the port."
        return $returnList
    }

    set retCode [bgp4Server getNeighbor $handle]
    if {$retCode != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure on call bgp4Server\
                getNeighbor $handle.  Return code was $retCode."
        return $returnList
    }

    if {$mode == "add"} {
        if {(![info exists prefix]) && (![info exists end_of_rib])} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: -prefix parameter \
            missing in add mode"
            return $returnList
        }
        if {![info exists prefix]} {
            if {$ip_version == 4} {
                set prefix 0.0.0.0
            } else {
                set prefix "0:0:0:0:0:0:0:0"
            }
        }
        if {![info exists as_path]} {
            set as_path "as_set:[bgp4Neighbor cget -localAsNumber]"
        }
        if {$vpn_flag == "vpn"} {
            if {[info exists target_type]} {
                set target_number [llength $target_type]
                if {[llength $target] != $target_number} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The options\
                            -target and -target_type have differing number of\
                            values in their lists.  They must have the same\
                            number of values."
                    return $returnList
                }
                if {[llength $target_assign] != $target_number} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The options\
                            -target_assign and -target_type have differing\
                            number of values in their lists.  They must have\
                            the same number of values."
                    return $returnList
                }
                if {[info exists target_step] && ([llength $target_step] != \
                        $target_number)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The options\
                            -target_step and -target_type have differing\
                            number of values in their lists.  They must have\
                            the same number of values."
                    return $returnList
                }
                if {[info exists target_assign_step] && \
                        ([llength $target_assign_step] != $target_number)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The options\
                            -target_assign_step and -target_type have differing\
                            number of values in their lists.  They must have\
                            the same number of values."
                    return $returnList
                }
                set target_index 0
                foreach target_type_item $target_type \
                        target_item      $target      {
                    if {[info exists target_step]} {
                        set target_step_item [lindex \
                                $target_step $target_index]
                    }
                    if {$target_type_item == "as"} {
                        if {![string is integer $target_item]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Invalid value $target_item provided\
                                    for parameter -target.\
                                    An integer is expected."
                            return $returnList
                        }
                        if {[info exists target_step_item] && \
                                ![string is integer $target_step_item]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Invalid value $target_step_item provided\
                                    for parameter -target_step.\
                                    An integer is expected."
                            return $returnList
                        }
                    }
                    if {$target_type_item == "ip"} {
                        if {![isIpAddressValid $target_item]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Ivalid\
                                    -target value $target_item.\
                                    A valid IPv4 address is expected."
                            return $returnList
                        }
                        if {[info exists target_step_item] && \
                                ![isIpAddressValid $target_step_item]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Invalid value $target_step_item provided\
                                    for parameter -target_step.\
                                    A valid IPv4 address is expected."
                            return $returnList
                        }
                    }
                    incr target_index
                }
            }

            if {[info exists import_target_type]} {
                set import_target_number [llength $import_target_type]
                if {[llength $import_target] != $import_target_number} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The options\
                            -import_target and -import_target_type have\
                            differing number of values in their lists.  They\
                            must have the same number of values."
                    return $returnList
                }
                if {[llength $import_target_assign] != $import_target_number} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The options\
                            -import_target_assign and -import_target_type\
                            have differing number of values in their lists. \
                            They must have the same number of values."
                    return $returnList
                }
                if {[info exists import_target_step] && \
                        ([llength $import_target_step] != $target_number)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The options\
                            -import_target_step and -target_type have differing\
                            number of values in their lists.  They must have\
                            the same number of values."
                    return $returnList
                }
                if {[info exists import_target_assign_step] && ([llength \
                        $import_target_assign_step] != $target_number)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The options\
                            -import_target_assign_step and -target_type have\
                            differing number of values in their lists.  They\
                            must have the same number of values."
                    return $returnList
                }
                set import_index 0
                foreach import_target_type_item $import_target_type \
                        import_target_item      $import_target      {
                    if {[info exists import_target_step]} {
                        set import_target_step_item [lindex \
                                $import_target_step $import_index]
                    }
                    if {$import_target_type_item == "as"} {
                        if {![string is integer $import_target_item]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Invalid value $import_target_item provided\
                                    for parameter -import_target.\
                                    An integer is expected."
                            return $returnList
                        }
                        if {[info exists import_target_step_item] && \
                                ![string is integer $import_target_step_item]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Invalid value $import_target_step_item provided\
                                    for parameter -import_target_step.\
                                    An integer is expected."
                            return $returnList
                        }
                    }
                    if {$import_target_type_item == "ip"} {
                        if {![isIpAddressValid $import_target_item]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Ivalid\
                                    -import_target value $import_target_item.\
                                    A valid IPv4 address is expected."
                            return $returnList
                        }
                        if {[info exists import_target_step_item] && \
                                ![isIpAddressValid $import_target_step_item]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Invalid value $import_target_step_item provided\
                                    for parameter -import_target_step.\
                                    A valid IPv4 address is expected."
                            return $returnList
                        }
                    }
                    incr import_index
                }
            }

            if {![info exists rd_type]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The Route\
                        Distinguisher Type needs to be specified via the option\
                        -rd_type CHOICES 0 1."
                return $returnList
            }

            if {$num_sites > 1} {
                if {![info exists rd_admin_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The Route\
                            Distinguisher Administrator Step needs to be\
                            specified via the option -rd_admin_step."
                    return $returnList
                }
                if {![info exists rd_assign_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The Route\
                            Distinguisher Assigned Number Step needs to be\
                            specified via the option -rd_assign_step."
                    return $returnList
                }
            }

            if {![info exists route_ip_addr_step]} {
                set route_ip_addr_step 0.1.0.0
            }

            #########
            #  FOR EACH L3VPN PE
            #########
            for {set j 1} {$j <= $num_sites} {incr j} {

                # Get the next route range available for a particular BGP
                # neighbor
                set retCode [::ixia::bgpGetNextHandle bgp_vpn_site]
                set l3_site_number [keylget retCode next_handle]

                bgp4VpnL3Site clearAllVpnTargets
                bgp4VpnL3Site clearAllImportTargets
                bgp4VpnL3Site clearAllVpnRouteRanges

                bgp4VpnL3Site config -enable true

                if {[info exists default_mdt_ip]} {
                    bgp4VpnL3Site config -enableVpnMulticast true
                    bgp4VpnL3Site config -groupAddress $default_mdt_ip
                    if {[info exists default_mdt_ip_incr]} {
                        if {[isIpAddressValid $default_mdt_ip]} {
                            set default_mdt_ip \
                                    [::ixia::increment_ipv4_address_hltapi \
                                    $default_mdt_ip  $default_mdt_ip_incr]
                        } else  {
                            set default_mdt_ip \
                                    [::ixia::increment_ipv4_address_hltapi \
                                    $default_mdt_ip  $default_mdt_ip_incr]
                        }
                    }
                }

                set retCode [bgp4Neighbor addL3Site $l3_site_number]
                if {$retCode != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failure in call\
                            bgp4Neighbor addL3Site $l3_site_number.  Return\
                            code is $retCode."
                    return $returnList
                }

                keylset bgp_vpn_route_keyedlist $l3_site_number {}
                lappend bgp_vpn_route_list $l3_site_number

                # Add to array
                set     temp_esa "bgp_route_handles_array("
                append  temp_esa "bgp_vpn_site,$l3_site_number)"
                keylset $temp_esa neighbor $handle
            }

            set retCode [bgp4Server setNeighbor $handle]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call\
                        bgp4Server setNeighbor $handle.  Return code is $retCode"
                return $returnList
            }

            set number_of_L3_sites [llength $bgp_vpn_route_list]
            set l3_site_index 1
        }

        # The next loop is really for when the vpn_flag is set, so we are setting
        # a dummy value for non vpn.  This allows the majority of the code to
        # be the same, just using different execution commands, but the same
        # options, instead of having two large chucks of code that are very
        # similar.
        if {$vpn_flag != "vpn"} {
            set bgp_vpn_route_list [list nothing]
        }

        foreach l3_site_number $bgp_vpn_route_list {
            if {$vpn_flag == "vpn"} {
                bgp4VpnL3Site setDefault

                set retCode [bgp4Neighbor getL3Site $l3_site_number]
                if {$retCode != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failure in call\
                            to bgp4Neighbor getL3Site $l3_site_number.  Return\
                            code was $retCode."
                    return $returnList
                }

                set l3_option_index 1
                foreach l3_single_option_list $l3_option_list {
                    if {[info exists $l3_single_option_list]} {

                        eval set l3_single_option_list_eval \
                                $$l3_single_option_list

                        set l3_single_option [lindex \
                                $l3_single_option_list_eval \
                                [expr $l3_option_index - 1]]
                        switch -- $l3_single_option_list {
                            rd_admin_value {
                                if {![info exists rd_type]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            The Route Distinguisher Type needs\
                                            to be specified with the option\
                                            -rd_type CHOICES 0 1."
                                    return $returnList
                                }
                                if {$rd_type == 1} {
                                    if {![isIpAddressValid $l3_single_option]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in\
                                                $procName:  The Route\
                                                Distinguisher Type is set to 1\
                                                so -rd_admin_value should\
                                                be provided as an ip address."
                                        return $returnList
                                    }
                                    catch {bgp4VpnL3Site config     \
                                            -distinguisherIpAddress \
                                            $l3_single_option}
                                } elseif {$rd_type == 0} {
                                    if {![string is integer $l3_single_option]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in\
                                                $procName:  The Route\
                                                Distinguisher Type is set to 0\
                                                so -rd_admin_value should\
                                                be numeric."
                                        return $returnList
                                    }
                                    catch {bgp4VpnL3Site config    \
                                            -distinguisherAsNumber \
                                            $l3_single_option}
                                }
                            }
                            rd_assign_value {
                                catch {bgp4VpnL3Site config          \
                                        -distinguisherAssignedNumber \
                                        $l3_single_option}
                            }
                            rd_type {
                                switch -- $l3_single_option {
                                    0 {
                                        catch {bgp4VpnL3Site config    \
                                                -distinguisherType     \
                                                bgp4DistinguisherTypeAS}
                                    }
                                    1 {
                                        catch {bgp4VpnL3Site config    \
                                                -distinguisherType     \
                                                bgp4DistinguisherTypeIP}
                                    }
                                }
                            }
                            cluster_list {
                                catch {bgp4VpnL3Site config -enableCluster true}
                                set clusters [list]
                                foreach cluster $l3_single_option {
                                    set clusters [lappend clusters [ \
                                            ::ixia::ip_addr_to_num $cluster]]
                                }
                                catch {bgp4VpnL3Site config -clusterList      \
                                        $clusters}
                            }
                            cluster_list_enable {
                                catch {bgp4VpnL3Site config -enableCluster true}
                            }
                        }
                    }
                }
            }

            bgp4RouteFilter setDefault

            for {set cur_route_range 1} {$cur_route_range <= $max_route_ranges} \
                    {incr cur_route_range} {

                if {$vpn_flag == 0} {
                    set bgpCmd bgp4RouteItem
                    set retCode [::ixia::bgpGetNextHandle bgp]
                    set next_route_range [keylget retCode next_handle]
                } elseif {$vpn_flag == "vpn"} {
                    set bgpCmd bgp4VpnRouteRange
                    set retCode [::ixia::bgpGetNextHandle bgp_vpn_site_route]
                    set next_vpn_route_range [keylget retCode next_handle]
                } elseif {$vpn_flag == "mpls"} {
                    set bgpCmd bgp4MplsRouteRange
                    set retCode [::ixia::bgpGetNextHandle bgp_mpls]
                    set next_mpls_route_range [keylget retCode next_handle]
                }

                $bgpCmd clearASPathList

                # Default
                $bgpCmd setDefault
                # Turn off all on by default items
                $bgpCmd config -enableASPath                false
                $bgpCmd config -enableLocalPref             false
                $bgpCmd config -enableNextHop               false
                $bgpCmd config -enableOrigin                false
                $bgpCmd config -enableTraditionalNlriUpdate false
                $bgpCmd config -endOfRIB                    false
                
                foreach single_option_list $option_list {
                    if {[info exists $single_option_list]} {
                        eval set single_option $$single_option_list

                        switch -- $single_option_list {
                            aggregator {
                                $bgpCmd config -enableAtomicAggregate true
                                $bgpCmd config -enableAggregator      true
                                set single_option [split $single_option :]
                                $bgpCmd config -aggregatorASNum \
                                        [lindex $single_option 0]
                                $bgpCmd config -aggregatorIpAddress \
                                        [lindex $single_option 1]
                            }
                            as_path_set_mode {
                                if {$vpn_flag != 0} { continue  }
                                array set translate_as_path_set_mode {
                                    include_as_seq        bgpRouteAsPathIncludeAsSeq
                                    include_as_seq_conf   bgpRouteAsPathIncludeAsSeqConf
                                    include_as_set        bgpRouteAsPathIncludeAsSet
                                    include_as_set_conf   bgpRouteAsPathIncludeAsSetConf
                                    no_include            bgpRouteAsPathNoInclude
                                    prepend_as            bgpRouteAsPathPrependAs
                                }
                                $bgpCmd config -asPathSetMode $translate_as_path_set_mode($single_option)
                            }
                            as_path {
                                # Ex.: as_set:1,2,3,4
                                foreach single_as_path $single_option {
                                    set as_path_params [split $single_as_path :]
                                    bgp4AsPathItem setDefault
                                    bgp4AsPathItem config -enableAsSegment true

                                    set as_param [lindex $as_path_params 0]

                                    if {$as_param == "as_set"} {
                                        bgp4AsPathItem config -asSegmentType \
                                                bgpSegmentAsSet
                                    } elseif {$as_param == "as_seq"} {
                                        bgp4AsPathItem config -asSegmentType \
                                                bgpSegmentAsSequence
                                    } elseif {$as_param == "as_confed_set"} {
                                        bgp4AsPathItem config -asSegmentType \
                                                bgpSegmentAsConfedSet
                                    } elseif {$as_param == "as_confed_seq"} {
                                        bgp4AsPathItem config -asSegmentType \
                                                bgpSegmentAsConfedSequence
                                    } else {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in \
                                                $procName: The AS path type\
                                                is incorrect."
                                        return $returnList
                                    }

                                    set as_list \
                                            [split [lindex $as_path_params 1] ,]

                                    foreach as $as_list {
                                        if {![regexp {^\d+$} $as] || \
                                                ($as < 0) || ($as > 65535) } {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in \
                                                    $procName: One of the values\
                                                    in the AS path is not a\
                                                    valid AS number."
                                            return $returnList
                                        }
                                    }

                                    bgp4AsPathItem config -asList $as_list
                                    $bgpCmd addASPathItem
                                }
                                $bgpCmd config -enableASPath          true
                            }
                            enable_as_path {
                                if {$enable_as_path == 0} {
                                    $bgpCmd config -enableASPath      false
                                } else {
                                    if {![info exists as_path]} {
                                        $bgpCmd config -enableASPath      true
                                    }
                                }
                            }
                            atomic_aggregate {
                                $bgpCmd config -enableAtomicAggregate true
                            }
                            cluster_list {
                                $bgpCmd config -enableCluster         true
                                set clusters [list]
                                foreach cluster $single_option {
                                    set clusters [lappend clusters [ \
                                            ::ixia::ip_addr_to_num $cluster]]
                                }
                                $bgpCmd config -clusterList $clusters
                            }
                            cluster_list_enable {
                                $bgpCmd config -enableCluster         true
                            }
                            communities {
                                $bgpCmd config -enableCommunity       true
                                $bgpCmd config -communityList $single_option
                            }
                            communities_enable {
                                $bgpCmd config -enableCommunity       true
                            }
                            enable_generate_unique_routes {
                                $bgpCmd config -enableGenerateUniqueRoutes true
                            }
                            originator_id_enable {
                                if { $originator_id_enable == 0 } {
                                    $bgpCmd config -enableOriginatorId false
                                } else {
                                    $bgpCmd config -enableOriginatorId true
                                }
                            }
                            enable_partial_route_flap {
                                $bgpCmd config -enablePartialFlap  true
                            }
                            enable_route_flap {
                                $bgpCmd config -enableRouteFlap    true
                            }
							end_of_rib {
								$bgpCmd config -endOfRIB true
							}
                            origin_route_enable {
                                $bgpCmd config -enableOrigin       true
                            }
                            enable_traditional_nlri {
                                $bgpCmd config -enableTraditionalNlriUpdate \
                                        $single_option
                            }
                            ext_communities {
                                if {$vpn_flag == 0} {
                                    foreach ext_community $single_option {
                                        set _list    [split $ext_community ","]
                                        set _type    [lindex $_list 0]
                                        set _subType [lindex $_list 1]
                                        set _value   [lindex $_list 2]
                                        bgp4ExtendedCommunity setDefault
                                        bgp4ExtendedCommunity config -type \
                                                $_type
                                        bgp4ExtendedCommunity config -subType \
                                                $_subType
                                        bgp4ExtendedCommunity config -value \
                                                $_value
                                        $bgpCmd addExtendedCommunity
                                    }
                                }
                            }
                            flap_down_time {
                                $bgpCmd config -routeFlapDropTime $single_option
                            }
                            flap_up_time {
                                $bgpCmd config -routeFlapTime     $single_option
                            }
                            packing_from {
                                $bgpCmd config -fromPacking       $single_option
                            }
                            prefix_from {
                                $bgpCmd config -fromPrefix        $single_option
                            }
                            ipv4_mpls_nlri {
                                bgp4RouteFilter config -enableIpV4Mpls      true
                            }
                            ipv4_mpls_vpn_nlri {
                                bgp4RouteFilter config -enableIpV4MplsVpn   true
                            }
                            ipv4_multicast_nlri {
                                bgp4RouteFilter config -enableIpV4Multicast true
                            }
                            ipv4_unicast_nlri {
                                bgp4RouteFilter config -enableIpV4Unicast   true
                            }
                            ipv6_mpls_nlri {
                                bgp4RouteFilter config -enableIpV6Mpls      true
                            }
                            ipv6_mpls_vpn_nlri {
                                bgp4RouteFilter config -enableIpV6MplsVpn   true
                            }
                            ipv6_multicast_nlri {
                                bgp4RouteFilter config -enableIpV6Multicast true
                            }
                            ipv6_prefix_length {
                                $bgpCmd config -fromPrefix $single_option
                            }
                            ipv6_unicast_nlri {
                                bgp4RouteFilter config -enableIpV6Unicast   true
                            }
                            ip_version {
                                switch -- $single_option {
                                    4 {
                                        $bgpCmd config -ipType addressTypeIpV4
                                    }
                                    6 {
                                        $bgpCmd config -ipType addressTypeIpV6
                                    }
                                    default {}
                                }
                            }
                            local_pref {
                                $bgpCmd config -enableLocalPref true
                                $bgpCmd config -localPref $single_option
                            }
                            enable_local_pref {
                                switch -- $single_option {
                                    0 {
                                        $bgpCmd config -enableLocalPref false
                                    }
                                    1 {
                                        $bgpCmd config -enableLocalPref true
                                    }
                                    default {}
                                }
                            }
                            multi_exit_disc {
                                $bgpCmd config -enableMED true
                                $bgpCmd config -med $single_option
                            }
                            netmask {
                                $bgpCmd config -fromPrefix \
                                        [getIpV4MaskWidth $single_option]
                            }
                            next_hop_enable {
                                if {[info exists single_option]} {
                                    $bgpCmd config -enableNextHop $single_option
                                } else {
                                    $bgpCmd config -enableNextHop true
                                }
                            }
                            next_hop {
                                $bgpCmd config -nextHopIpAddress $single_option
                            }
                            next_hop_mode {
                                switch -exact -- $single_option {
                                    fixed {
                                        $bgpCmd config -nextHopMode 0
                                    }
                                    increment {
                                        $bgpCmd config -nextHopMode 1
                                    } 
                                    incrementPerPrefix {
                                        $bgpCmd config -nextHopMode 2
                                    } 
                                }
                            }
                            next_hop_ip_version {
                                catch {$bgpCmd config -nextHopIpType \
                                        addressTypeIpV$single_option}
                            }
                            next_hop_set_mode {
                                switch -exact $single_option {
                                    same {
                                        catch {$bgpCmd config -nextHopSetMode \
                                                bgpRouteNextHopSetSameAsLocalIp }
                                    }
                                    manual {
                                        catch {$bgpCmd config -nextHopSetMode \
                                                bgpRouteNextHopSetManually }
                                    }
                                }
                            }
                            num_routes {
                                $bgpCmd config -numRoutes $single_option
                            }
                            origin {
                                switch -- $single_option {
                                    igp {
                                        $bgpCmd config -originProtocol \
                                                bgpOriginIGP
                                    }
                                    egp {
                                        $bgpCmd config -originProtocol \
                                                bgpOriginEGP
                                    }
                                    incomplete {
                                        $bgpCmd config -originProtocol \
                                                bgpOriginIncomplete
                                    }
                                    default {}
                                }
                            }
                            originator_id {
                                $bgpCmd config -enableOriginatorId true
                                $bgpCmd config -originatorId     $single_option
                            }
                            partial_route_flap_from_route_index {
                                $bgpCmd config -routesToFlapFrom $single_option
                            }
                            partial_route_flap_to_route_index {
                                $bgpCmd config -routesToFlapTo   $single_option
                            }
                            prefix {
                                if {$vpn_flag == "vpn"} {
                                    if {$single_option == "all"} {
                                        bgp4VpnRouteRange config \
                                                -networkIpAddress 0.0.0.0
                                        set num_routes 999999999
                                    }
                                    bgp4VpnRouteRange config -networkIpAddress \
                                            $single_option
                                } else {
                                    if {$single_option == "all"} {
                                        $bgpCmd config -networkAddress 0.0.0.0
                                        set num_routes 999999999
                                    }
                                    $bgpCmd config -networkAddress $single_option
                                }
                            }
                            prefix_step {
                                $bgpCmd config -iterationStep  $single_option
                            }
                            packing_to {
                                $bgpCmd config -thruPacking    $single_option
                            }
                            prefix_to {
                                if {$vpn_flag == "vpn"} {
                                    bgp4VpnRouteRange config -toPrefix \
                                            $single_option
                                } else {
                                    $bgpCmd config -thruPrefix $single_option
                                }
                            }
                            import_target_number {
                                if {![info exists old_l3Site_i] || $old_l3Site_i !=\
                                         $l3_site_number} {
                                    set old_l3Site_i $l3_site_number
                                    for {set i 0} {$i < $import_target_number} \
                                            {incr i} {
                                        bgp4VpnImportTarget setDefault
                                        if {[info exists import_target_type]} {
                                            if {[lindex $import_target_type $i] == \
                                                    "ip"} {
                                                bgp4VpnImportTarget config -type 1
                                            } elseif {[lindex $import_target_type  \
                                                    $i] == "as"} {
                                                bgp4VpnImportTarget config -type 0
                                            }
                                        }
                                        if {[info exists import_target]} {
                                            if {[isIpAddressValid [lindex $import_target $i]] \
                                                    || [::ipv6::isValidAddress    \
                                                    [lindex $import_target $i]]} {
                                                bgp4VpnImportTarget config       \
                                                        -ipAddress               \
                                                        [lindex $import_target $i]
                                            } else  {
                                                bgp4VpnImportTarget config       \
                                                        -asNumber                \
                                                        [lindex $import_target $i]
                                            }
                                            set its_e [info exists \
                                                    import_target_step]
                                            if {(!$its_e) || ($its_e && ([llength \
                                                    $import_target_step] !=   \
                                                    $import_target_number))} {
    
                                                if {[isIpAddressValid \
                                                        [lindex $import_target $i]]} {
                                                    lappend import_target_step \
                                                            0.0.0.0
                                                } elseif {[::ipv6::isValidAddress \
                                                        [lindex $import_target $i]]} {
                                                    lappend import_target_step 0::0
                                                } else  {
                                                    lappend import_target_step 0
                                                }
                                            }
                                        }
                                        if {[info exists import_target_assign]} {
                                            bgp4VpnImportTarget config \
                                                    -assignedNumber    \
                                                    [lindex $import_target_assign $i]
                                            set itas_e [info exists \
                                                    import_target_assign_step]
                                            if {(!$itas_e) || ($itas_e && ([llength \
                                                    $import_target_assign_step]     \
                                                    != $import_target_number))} {
                                                lappend import_target_assign_step 0
                                            }
                                        }
                                        bgp4VpnL3Site addImportTarget
                                    }
                                }
                            }
                            label_end {
                                if {$vpn_flag == "vpn"} {
                                    bgp4VpnRouteRange config -labelEnd  \
                                            $single_option
                                } elseif {$vpn_flag == "mpls"} {
                                    bgp4MplsRouteRange config -labelEnd \
                                            $single_option
                                }
                            }
                            label_incr_mode {
                                switch -- $single_option {
                                    fixed {
                                        if {$vpn_flag == "vpn"} {
                                            bgp4VpnRouteRange config -labelMode \
                                                    bgp4VpnFixedLabel
                                        } elseif {$vpn_flag == "mpls"} {
                                            bgp4MplsRouteRange config \
                                                    -labelMode bgp4VpnFixedLabel
                                        }
                                    }
                                    prefix {
                                        if {$vpn_flag == "vpn"} {
                                            bgp4VpnRouteRange config -labelMode \
                                                    bgp4VpnIncrementLabel
                                        } elseif {$vpn_flag == "mpls"} {
                                            bgp4MplsRouteRange config \
                                                    -labelMode        \
                                                    bgp4VpnIncrementLabel
                                        }
                                    }
                                }
                            }
                            label_space_id {
                                if {$vpn_flag == "vpn"} {
                                    bgp4VpnRouteRange config -labelSpaceId  \
                                            $single_option
                                } elseif {$vpn_flag == "mpls"} {
                                    bgp4MplsRouteRange config -labelSpaceId \
                                            $single_option
                                }
                            }
                            label_step {
                                if {$vpn_flag == "vpn"} {
                                    bgp4VpnRouteRange config -labelStep  \
                                            $single_option
                                } elseif {$vpn_flag == "mpls"} {
                                    bgp4MplsRouteRange config -labelStep \
                                            $single_option
                                }
                            }
                            label_value {
                                if {$vpn_flag == "vpn"} {
                                    bgp4VpnRouteRange config -labelStart  \
                                            $single_option
                                } elseif {$vpn_flag == "mpls"} {
                                    bgp4MplsRouteRange config -labelStart \
                                            $single_option
                                }
                            }
                            rd_admin_value {
                                if {![info exists rd_type]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            The Route Distinguisher Type needs\
                                            to be specified with the option\
                                            -rd_type CHOICES 0 1."
                                    return $returnList
                                }
                                if {$rd_type == 1} {
                                    if {![isIpAddressValid $single_option]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in \
                                                $procName: The Route\
                                                Distinguisher Type is set to 1\
                                                so -rd_admin_value should\
                                                be provided as an ip address."
                                        return $returnList
                                    }
                                    bgp4VpnRouteRange config \
                                            -distinguisherIpAddress \
                                            $single_option
                                } elseif {$rd_type == 0} {
                                    if {![string is integer $single_option]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in\
                                                $procName: The Route\
                                                Distinguisher Type is set to 0\
                                                so -rd_admin_value should\
                                                be numeric."
                                        return $returnList
                                    }
                                    bgp4VpnRouteRange config \
                                            -distinguisherAsNumber $single_option
                                }
                            }
                            rd_assign_value {
                                bgp4VpnRouteRange config \
                                        -distinguisherAssignedNumber \
                                        $single_option
                            }
                            rd_type {
                                switch -- $single_option {
                                    0 {
                                        bgp4VpnRouteRange config   \
                                                -distinguisherType \
                                                bgp4DistinguisherTypeAS
                                    }
                                    1 {
                                        bgp4VpnRouteRange config   \
                                                -distinguisherType \
                                                bgp4DistinguisherTypeIP
                                    }
                                }
                            }
                            target_number {
                                if {![info exists old_l3Site_t] || $old_l3Site_t !=\
                                         $l3_site_number} {
                                    set old_l3Site_t $l3_site_number
                                    for {set i 0} {$i < $target_number} {incr i} {
                                        set old_l3Site $l3_site_number
                                        bgp4VpnTarget setDefault
                                        if {[info exists target_type]} {
                                            if {[lindex $target_type $i] == "ip"} {
                                                bgp4VpnTarget config -type \
                                                        bgp4TargetTypeIP
                                            } elseif {[lindex $target_type $i] == \
                                                    "as"} {
                                                bgp4VpnTarget config -type \
                                                        bgp4TargetTypeAS
                                            }
                                        }
                                        if {[info exists target]} {
                                            if {[lindex $target_type $i] == "ip"} {
                                                bgp4VpnTarget config -ipAddress   \
                                                        [lindex $target $i]
                                            } elseif {[lindex $target_type $i] == \
                                                    "as"} {
                                                bgp4VpnTarget config -asNumber    \
                                                        [lindex $target $i]
                                            }
                                            set ts_e [info exists target_step]
                                            if {(!$ts_e) || ($ts_e && \
                                                    ([llength $target_step] != \
                                                    $target_number))} {
    
                                                if {[isIpAddressValid [lindex $target $i]]} {
                                                    lappend target_step 0.0.0.0
                                                } elseif {[::ipv6::isValidAddress \
                                                        [lindex $target $i]]}  {
                                                    lappend target_step 0::0
                                                } else  {
                                                    lappend target_step 0
                                                }
                                            }
                                        }
                                        if {[info exists target_assign]} {
                                            bgp4VpnTarget config -assignedNumber  \
                                                    [lindex $target_assign $i]
                                            set tas_e [info exists \
                                                    target_assign_step]
                                            if {(! $tas_e) || ($tas_e && ([llength \
                                                    $target_assign_step]           \
                                                    != $target_number))} {
                                                lappend target_assign_step 0
                                            }
                                        }
                                        bgp4VpnL3Site addVpnTarget
                                    }
                                }
                            }
                        }
                    }
                }

                if {$vpn_flag == 0} {

                    bgp4RouteItem config -enableASPath     true
                    bgp4RouteItem config -enableRouteRange true
                    
                    if {[info exists enable_as_path] && $enable_as_path == 0} {
                        bgp4RouteItem config -enableASPath     false
                    }
                    
                    set retCode [bgp4Neighbor addRouteRange $next_route_range]
                    if {$retCode == 1} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failure in\
                                call to bgp4Neighbor addRouteRange\
                                $next_route_range.  Return code was $retCode."
                        return $returnList
                    }

                    # Increment the IP address of the BGP route range
                    if { $ip_version == 4 } {
                        if {![info exists route_ip_addr_step]} {
                            set route_ip_addr_step 1.0.0.0
                        }
                        set prefix [::ixia::increment_ipv4_address_hltapi \
                                $prefix $route_ip_addr_step]
                    } elseif { $ip_version == 6} {
                        if {![info exists route_ip_addr_step]} {
                            set route_ip_addr_step 0:0:0:1:0:0:0:0
                        }

                        set prefix [::ixia::increment_ipv6_address_hltapi \
                                $prefix $route_ip_addr_step]
                    }
                    lappend bgp_route_list $next_route_range
                    # Add to array
                    set     temp_esa "bgp_route_handles_array("
                    append  temp_esa "bgp,$next_route_range)"
                    keylset $temp_esa neighbor $handle

                } elseif {$vpn_flag == "vpn"} {
                    # Increment the items for the next Route Range
                    set prefix [::ixia::increment_ipv${ip_version}_address_hltapi \
                                $prefix $route_ip_addr_step]
                    
                    if {[info exists label_value] && [info exists label_step]} {
                        set label_value [expr $label_value + [expr $num_routes * $label_step]]
                    }

                    # Set the VPN route range and site
                    bgp4VpnRouteRange config -enable true
                    set retCode [bgp4VpnL3Site addVpnRouteRange \
                            $next_vpn_route_range]
                    if {$retCode != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failure in\
                                call to bgp4VpnL3Site addVpnRouteRange\
                                $next_vpn_route_range.  Return code was\
                                $retCode."
                        return $returnList
                    }

                    # Add to array
                    set     temp_esa "bgp_route_handles_array("
                    append  temp_esa "bgp_vpn_site_route,"
                    append  temp_esa "$next_vpn_route_range)"

                    keylset $temp_esa neighbor $handle
                    keylset $temp_esa l3_site  $l3_site_number

                    if {[info exists default_mdt_ip]} {
                        keylset $temp_esa default_mdt_ip \
                                $default_mdt_ip
                    }
                    if {[info exists default_mdt_ip_incr]} {
                        keylset $temp_esa default_mdt_ip_incr  \
                                $default_mdt_ip_incr
                    }

                    keylset bgp_vpn_route_keyedlist $l3_site_number \
                            "[keylget bgp_vpn_route_keyedlist       \
                            $l3_site_number] $next_vpn_route_range"

                } elseif {$vpn_flag == "mpls"} {

                    bgp4MplsRouteRange config -enableASPath     true
                    bgp4MplsRouteRange config -enableRouteRange true
                    
                    if {[info exists enable_as_path] && $enable_as_path == 0} {
                        bgp4MplsRouteRange config -enableASPath     false
                    }
                    
                    set retCode [bgp4Neighbor addMplsRouteRange \
                            $next_mpls_route_range]
                    if {$retCode == 1} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failure in\
                                call to bgp4Neighbor addMplsRouteRange\
                                $next_mpls_route_range.  Return code was\
                                $retCode."
                        return $returnList
                    }

                    # Increment the IP address of the BGP route range
                    if { $ip_version == 4 } {
                        if {![info exists route_ip_addr_step]} {
                            set route_ip_addr_step 1.0.0.0
                        }
                        set prefix [::ixia::increment_ipv4_address_hltapi \
                                $prefix $route_ip_addr_step]
                    } elseif { $ip_version == 6} {
                        if {![info exists route_ip_addr_step]} {
                            set route_ip_addr_step 0:0:0:1:0:0:0:0
                        }

                        set prefix [::ixia::increment_ipv6_address_hltapi \
                                $prefix $route_ip_addr_step]
                    }
                    lappend bgp_route_list $next_mpls_route_range
                    # Add to array
                    set     temp_esa "bgp_route_handles_array("
                    append  temp_esa "bgp_mpls,$next_mpls_route_range)"
                    keylset $temp_esa neighbor $handle
                }
            }

            if {$vpn_flag == "vpn"} {
                set retCode [bgp4Neighbor setL3Site $l3_site_number]
                if {$retCode != 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failure in\
                            call to bgp4Neighbor setL3Site $l3_site_number. \
                            Return code was $retCode."
                    return $returnList
                }
            }

            if {$vpn_flag == "vpn"} {
                ###########################
                # End of FOR EACH L3VPN CE
                ###########################
                if {$l3_site_index < $number_of_L3_sites} {
                    #Increment the IP address of the next L3VPN PE
                    if { $ip_version == 4 } {
                        if {$num_sites > 1} {
                            if {$rd_type == 0} {
                                set rd_admin_value [expr $rd_admin_value + \
                                        $rd_admin_step]
                            } elseif {$rd_type == 1} {
                                set temp_rd_admin_step \
                                        [split $rd_admin_step .]
                                set octet_number 1
                                foreach octet $temp_rd_admin_step {
                                    set rd_admin_value \
                                            [::ixia::increment_ipv4_address \
                                            $rd_admin_value \
                                            $octet_number $octet]
                                    incr octet_number
                                }
                            }

                            set rd_assign_value \
                                    [expr $rd_assign_value + $rd_assign_step]

                            # Increment target
                            if {[info exists target]} {
                                set target_list [list]
                                foreach {t} $target {t_step} $target_step {
                                    if {[info exists t_step]} {
                                        if {[isIpAddressValid $t]} {
                                            if {[isIpAddressValid $t_step]} {
                                                set t [increment_ipv4_address_hltapi \
                                                        $t $t_step]
                                            }
                                        } elseif {[::ipv6::isValidAddress $t]} {
                                            if {[::ipv6::isValidAddress $t_step]} {
                                                set t [increment_ipv6_address_hltapi \
                                                        $t $t_step]
                                            }
                                        } else  {
                                            if {[string is integer $t_step]} {
                                                set t [mpexpr $t + $t_step]
                                            }
                                        }
                                    }
                                    lappend target_list $t
                                }
                                set target $target_list
                            }
                            if {[info exists target_assign]} {
                                set target_assign_list [list]
                                foreach {ta}      $target_assign       \
                                        {ta_step} $target_assign_step  {

                                    lappend target_assign_list [mpexpr \
                                            $ta + $ta_step]
                                }
                                set target_assign $target_assign_list
                            }
                            # Increment import target
                            if {[info exists import_target]} {
                                set import_target_list [list]
                                foreach {it}      $import_target      \
                                        {it_step} $import_target_step {
                                    if {[info exists it_step]} {
                                        if {[isIpAddressValid $it]} {
                                            if {[isIpAddressValid $it_step]} {
                                                set it [increment_ipv4_address_hltapi \
                                                        $it $it_step]
                                            }
                                        } elseif {[::ipv6::isValidAddress $it]} {
                                            if {[::ipv6::isValidAddress $it_step]} {
                                                set it [increment_ipv6_address_hltapi \
                                                        $it $it_step]
                                            }
                                        } else  {
                                            if {[string is integer $it_step]} {
                                                set it [mpexpr $it + $it_step]
                                            }
                                        }
                                    }
                                    lappend import_target_list $it
                                }
                                set import_target $import_target_list
                            }
                            if {[info exists import_target_assign]} {
                                set import_target_assign_list [list]
                                foreach {ita}      $import_target_assign       \
                                        {ita_step} $import_target_assign_step  {

                                    lappend import_target_assign_list  \
                                            [mpexpr $ita + $ita_step]
                                }
                                set import_target_assign \
                                        $import_target_assign_list
                            }
                        }
                    } elseif {$ip_version == 6} {
                        # Do nothing for now
                    }
                }
                incr l3_site_index
            }
        }

        set retCode [bgp4Server setNeighbor $handle]
        if {$retCode != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in call\
                    to bgp4Server setNeighbor $handle.  Return code was\
                    $retCode."
            return $returnList
        }

    } elseif {$mode == "remove"} {

        # Remove the BGP Route
        if {![info exists route_handle] && ![info exists l3_site_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is remove,\
                    one or both of the options, -route_handle or\
                    -l3_site_handle, must be used to identify which BGP route\
                    to remove."
            return $returnList
        }

        if {[info exists route_handle]} {
            if {![::ixia::bgpRouteRangeExists $route_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid route range."
                return $returnList
            }
        }

        if {[info exists l3_site_handle]} {
            if {([::ixia::bgpGetRouteRangeType $l3_site_handle] != \
                    "bgp_vpn_site")} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid l3 site."
                return $returnList
            }
        }

        if {[info exists route_handle] && ![info exists l3_site_handle]} {
            switch -- [::ixia::bgpGetRouteRangeType $route_handle] {
                bgp_mpls           {
                    set retCode [bgp4Neighbor delMplsRouteRange $route_handle]
                    if {$retCode != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failure\
                                in call to bgp4Neighbor delMplsRouteRange\
                                $route_handle.  Return code was $retCode."
                        return $returnList
                    }
                }
                bgp_vpn_site       {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: You must use\
                            -l3_site_handle instead of -route_handle for this\
                            type of handle."
                    return $returnList
                }
                bgp_vpn_site_route {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: You must provide\
                            -l3_site_handle for this type of route handle."
                    return $returnList
                }
                default            {
                    set retCode [bgp4Neighbor delRouteRange $route_handle]
                    if {$retCode != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failure\
                                in call to bgp4Neighbor delRouteRange\
                                $route_handle.  Return code was $retCode."
                        return $returnList
                    }
                }
            }
            set arrayNames [array names bgp_route_handles_array]
            set arrayIndexList [lsearch -regexp $arrayNames "(.*)$route_handle"]
            foreach arrayIndex $arrayIndexList {
                if {$arrayIndex != -1} {
                    unset bgp_route_handles_array([lindex $arrayNames $arrayIndex])
                }
            }
        }

        if {[info exists route_handle] && [info exists l3_site_handle]} {
            if {([::ixia::bgpGetRouteRangeType $route_handle] != \
                    "bgp_vpn_site_route")} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid route range."
                return $returnList
            }

            set retCode [bgp4Neighbor getL3Site $l3_site_handle]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call\
                        to bgp4Neighbor getL3Site $l3_site_handle.  Return\
                        code was $retCode."
                return $returnList
            }
            set retCode [bgp4VpnL3Site delVpnRouteRange $route_handle]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        bgp4VpnL3Site delVpnRouteRange $route_handle.  Return\
                        code was $retCode."
                return $returnList
            }

            set arrayNames [array names bgp_route_handles_array]
            set arrayIndexList [lsearch -regexp $arrayNames "(.*)$route_handle"]
            foreach arrayIndex $arrayIndexList {
                if {$arrayIndex != -1} {
                    unset bgp_route_handles_array([lindex $arrayNames $arrayIndex])
                }
            }
            
            set retCode [bgp4Neighbor setL3Site $l3_site_handle]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        bgp4Neighbor setL3Site $l3_site_handle.  Return code\
                        was $retCode."
                return $returnList
            }
        }

        if {![info exists route_handle] && [info exists l3_site_handle]} {
            set retCode [bgp4Neighbor delL3Site $l3_site_handle]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call\
                        to bgp4Neighbor delL3Site $l3_site_handle.  Return\
                        code was $retCode."
                return $returnList
            }

            set arrayNames [array names bgp_route_handles_array]
            set arrayIndexList [lsearch -regexp $arrayNames "(.*)$l3_site_handle"]
            foreach arrayIndex $arrayIndexList {
                if {$arrayIndex != -1} {
                    unset bgp_route_handles_array([lindex $arrayNames $arrayIndex])
                }
            }
            
            foreach {item value} [array get bgp_route_handles_array] {
                if {(![catch {keylget value neighbor} tmp] && $tmp == $handle) && \
                        (![catch {keylget value l3_site} tmp] && $tmp == $l3_site_handle)} {
                    puts "unset bgp_route_handles_array($item)"
                    unset bgp_route_handles_array($item)
                }
            }
        }

        set retCode [bgp4Server setNeighbor $handle]
        if {$retCode != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in call to\
                    bgp4Server setNeighbor $handle.  Return code was $retCode."
            return $returnList
        }
    }

    set retCode [bgp4Server set]
    if {$retCode != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure in call to\
                bgp4Server set.  Return code was $retCode."
        return $returnList
    }

    if {![info exists no_write]} {
      set writeStat [writePortListConfig]
      set retCode [keylget writeStat status]
      if {$retCode != $::SUCCESS} {
         keylset returnList status $::FAILURE
         keylset returnList log "ERROR in $procName: Failure in call to\
                 writePortListConfig.  Return code was $retCode."
         return $returnList
      }
    }

    keylset returnList status $::SUCCESS
    if {$mode == "add"} {
        if {$vpn_flag == "vpn"} {
            keylset returnList bgp_sites  $bgp_vpn_route_keyedlist
            keylset returnList bgp_routes $bgp_vpn_route_list
        } else  {
            keylset returnList bgp_routes $bgp_route_list
        }
    }

    return $returnList
}


proc ::ixia::emulation_bgp_control { args } {
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
                \{::ixia::emulation_bgp_control $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable bgp_neighbor_handles_array

    ::ixia::utrackerLog $procName $args

    # Arguments
    set man_args {
        -mode        CHOICES link_flap restart start stop statistic
    }

    set opt_args {
        -handle
        -link_flap_up_time    RANGE  0-10000000
        -link_flap_down_time  RANGE  0-10000000
        -port_handle          REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }

    if {[isUNIX]} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValueClicks [eval "clientSend $::ixTclSvrHandle {clock clicks}"]
        set retValueSeconds [eval "clientSend $::ixTclSvrHandle {clock seconds}"]
    } else {
        set retValueClicks [clock clicks]
        set retValueSeconds [clock seconds]
    }
    keylset returnList clicks [format "%u" $retValueClicks]
    keylset returnList seconds [format "%u" $retValueSeconds]

    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_bgp_control $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName: [keylget returnList log]"
        }
        keylset returnList clicks [format "%u" $retValueClicks]
        keylset returnList seconds [format "%u" $retValueSeconds]
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
            -optional_args $opt_args

    if { (![info exists handle]) && ($mode == "link_flap" || \
            $mode == "statistic") } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: For -mode link_flap or \
                statistic a value for -handle option must be provided."
        return $returnList
    }

    # Get port_handle for the bgp handle given
    if {[info exists handle] && \
            [info exists bgp_neighbor_handles_array($handle)]} {
        set port_handle $bgp_neighbor_handles_array($handle)
        set neighborHandle $handle
    } elseif {[info exists handle] && [info exists \
            bgp_route_handles_array(bgp_vpn_site,$handle)]} {
        set neighborHandle [keylget \
                bgp_route_handles_array(bgp_vpn_site,$handle) neighbor]
        set port_handle $bgp_neighbor_handles_array($neighborHandle)
    } elseif {![info exists port_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The neighbor handle\
                $handle is not valid and no port handle was provided."
        return  $returnList
    }

    foreach {chassis card port} [split $port_handle /] {}

    # Check if BGP package has been installed on the port
    if {[catch {bgp4Server select $chassis $card $port} error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The BGP4 protocol\
                has not been installed on port or is not supported on port: \
                $chassis/$card/$port."
        return $returnList
    }

    if {($mode != "start") && ($mode != "statistic")} {
        # Modifiy neighbor properties for link_flap
        bgp4Server select $chassis $card $port

        if {[bgp4Server get] != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in call to\
                    bgp4Server get."
        }

        if {[info exists handle]} {
            if {[bgp4Server getNeighbor $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not get BGP\
                        router: $handle."
                return $returnList
            }
    
            if {$mode == "link_flap"} {
                bgp4Neighbor config -enableLinkFlap true
            } elseif {($mode == "stop") || ($mode == "restart")} {
                bgp4Neighbor config -enableLinkFlap false
            }
            if {[info exists link_flap_up_time]} {
                bgp4Neighbor config -linkFlapUpTime $link_flap_up_time
            }
            if {[info exists link_flap_down_time]} {
                bgp4Neighbor config -linkFlapDownTime $link_flap_down_time
            }
    
            if {[bgp4Server setNeighbor $handle] != 0 } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not set BGP\
                        neighbor $handle to port: $chassis $card $port."
                return $returnList
            }
    
            set retCode [bgp4Server set]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        bgp4Server set.  Return code was $retCode."
            }
    
            set retCode [bgp4Server write]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        bgp4Server write.  Return code was $retCode."
            }
        } else { ixPuts "WARNING: link_flap_up_time and link_flap_down_time will be ignored" }
    } elseif {$mode == "statistic"} {
        set retCode [bgp4Server getNeighbor $neighborHandle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    bgp4Server getNeighbor $neighbor_handle failed. \
                    Return code was $retCode."
            return $returnList
        }

        set statLocalIpAddr [bgp4Neighbor cget -localIpAddress ]
        set statDutIpAddr   [bgp4Neighbor cget -dutIpAddress   ]
        if {[::ipv6::isValidAddress $statLocalIpAddr]} {
            set statIpType addressTypeIpV6
        } else {
            set statIpType addressTypeIpV4
        }

        # Configure the statistics to query for this port
        if {[bgp4StatsQuery get $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    bgp4StatsQuery get $chassis $card $port."
            return $returnList
        }
        if {[bgp4StatsQuery addNeighbor $statLocalIpAddr $statDutIpAddr \
                $statIpType]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    bgp4StatsQuery addNeighbor \
                    $statLocalIpAddr $statDutIpAddr $statIpType."
            return $returnList
        }
        array set statIDs [list \
                keepalive_rx             bgpKeepAliveReceived        \
                keepalive_tx             bgpKeepAliveSent            \
                notify_rx                bgpNotificationReceived     \
                notify_tx                bgpNotificationSent         \
                open_rx                  bgpOpenReceived             \
                open_tx                  bgpOpenSent                 \
                update_rx                bgpUpdateReceived           \
                update_tx                bgpUpdateSent               \
                peers                    bgpPeerIP                   \
                routes_advertised_rx     bgpRoutesAdvertisedReceived \
                routes_advertised_tx     bgpRoutesAdvertised         ]

        foreach {index value} [array get statIDs] {
            if {[bgp4StatsQuery addStat $value]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        bgp4StatsQuery addStat $value."
                return $returnList
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

    set port_list [format_space_port_list $port_handle]

    # Perform start/stop/restart
    switch -exact $mode {
        restart {
            if {[ixStopBGP4 port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error stopping\
                        BGP4 on the port list $port_list."
                return $returnList
            }
            if {[ixStartBGP4 port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error starting\
                        BGP4 on the port list $port_list."
                return $returnList
            }
        }
        start {
            if {[ixStartBGP4 port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error starting\
                        BGP4 on the port list $port_list."
                return $returnList
            }
        }
        stop {
            if {[ixStopBGP4 port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error stopping\
                        BGP4 on the port list $port_list."
                return $returnList
            }
        }
        default {
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_bgp_info { args } {
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
                \{::ixia::emulation_bgp_info $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable bgp_neighbor_handles_array
    variable bgp_route_handles_array

    ::ixia::utrackerLog $procName $args

    # Arguments
    set man_args {
        -mode    CHOICES stats clear_stats settings neighbors labels
        -handle
    }

    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_bgp_info $args $man_args]
        if {![catch {set log [keylget returnList log]}]} {
            keylset returnList log "ERROR in $procName: $log"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args

    # Get port_handle for the bgp handle given
    if {[info exists handle]       && \
                [info exists bgp_neighbor_handles_array($handle)]} {
        set neighbor_handle  $handle
        set port_handle      $bgp_neighbor_handles_array($handle)
    } elseif {[info exists handle] && \
                [info exists bgp_route_handles_array(bgp_vpn_site,$handle)]}  {

        set neighbor_handle  [keylget \
                bgp_route_handles_array(bgp_vpn_site,$handle) neighbor]
        set port_handle      $bgp_neighbor_handles_array($neighbor_handle)
        set l3site_handle    $handle
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The neighbor/L3Site handle\
                $handle is not valid."
        return  $returnList
    }

    foreach {chassis card port} [split $port_handle /] {}

    # Check if BGP package has been installed on the port
    if {[catch {bgp4Server select $chassis $card $port} retCode]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The BGP4 protocol\
                has not been installed on port or is not supported on port: \
                $chassis/$card/$port."
        return $returnList
    }
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to\
                bgp4Server select $chassis $card $port failed. \
                Return code was $retCode."
        return $returnList
    }

    if {$mode == "stats"} {
        # MODE STATS
        set retCode [bgp4Server getNeighbor $neighbor_handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    bgp4Server getNeighbor $neighbor_handle failed. \
                    Return code was $retCode."
            return $returnList
        }

        set local_ip_address [bgp4Neighbor cget -localIpAddress ]
        set dut_ip_address   [bgp4Neighbor cget -dutIpAddress   ]
        set neighbor_type    [bgp4Neighbor cget -type           ]

        keylset returnList ip_address $local_ip_address
        if {$neighbor_type == 0} {
            keylset returnList routing_protocol internal
        } else  {
            keylset returnList routing_protocol external
        }

        set num_node_routes 0
        set retCode [bgp4Neighbor getFirstRouteRange]
        while {$retCode == 0} {
            incr num_node_routes [bgp4RouteItem         cget -numRoutes]
            set retCode [bgp4Neighbor getNextRouteRange]
        }

        set retCode [bgp4Neighbor getFirstMplsRouteRange]
        while {$retCode == 0} {
            incr num_node_routes [bgp4MplsRouteRange    cget -numRoutes]
            set retCode [bgp4Neighbor getNextMplsRouteRange]
        }

        set retCodeL3 [bgp4Neighbor getFirstL3Site]
        while {$retCodeL3 == 0} {
            set retCode [bgp4VpnL3Site getFirstVpnRouteRange]
            while {$retCode == 0} {
                incr num_node_routes [bgp4VpnRouteRange cget -numRoutes]
                set retCode [bgp4VpnL3Site getNextVpnRouteRange]
            }
            set retCodeL3 [bgp4Neighbor getNextL3Site]
        }
        keylset returnList num_node_routes $num_node_routes

        if {[::ipv6::isValidAddress $local_ip_address]} {
            set stat_ip_type addressTypeIpV6
        } else  {
            set stat_ip_type addressTypeIpV4
        }

        array set statIDs [list \
                keepalive_rx             bgpKeepAliveReceived        \
                keepalive_tx             bgpKeepAliveSent            \
                notify_rx                bgpNotificationReceived     \
                notify_tx                bgpNotificationSent         \
                open_rx                  bgpOpenReceived             \
                open_tx                  bgpOpenSent                 \
                update_rx                bgpUpdateReceived           \
                update_tx                bgpUpdateSent               \
                peers                    bgpPeerIP                   \
                routes_advertised_rx     bgpRoutesAdvertisedReceived \
                routes_advertised_tx     bgpRoutesAdvertised         ]

        set retCode [bgp4StatsQuery get $chassis $card $port]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    bgp4StatsQuery get $chassis $card $port failed. \
                    Return code was $retCode."
            return $returnList
        }

        foreach {index value} [array get statIDs] {
            bgp4StatsQuery setDefault
            set getResult [bgp4StatsQuery getStat \
                    $value $local_ip_address $dut_ip_address $stat_ip_type]
            for {set i 0} {($getResult != 0) && ($i < 5)} {incr i} {
                after 1000
                set getResult [bgp4StatsQuery getStat \
                        $value $local_ip_address $dut_ip_address $stat_ip_type]
            }
            if {$getResult == 0} {
                keylset returnList $index [bgp4StatsQuery cget -statValue]
            } else  {
                keylset returnList $index "N/A"
            }
        }

    } elseif {$mode == "clear_stats"} {
        # MODE CLEAR_STATS
        set retCode [bgp4StatsQuery get $chassis $card $port]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    bgp4StatsQuery get $chassis $card $port failed. \
                    Return code was $retCode."
            return $returnList
        }
        bgp4StatsQuery clearAllStats

    } elseif {$mode == "settings"} {
        # MODE SETTINGS
        set retCode [bgp4Server getNeighbor $neighbor_handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    bgp4Server getNeighbor $neighbor_handle failed. \
                    Return code was $retCode."
            return $returnList
        }
        keylset returnList ip_address [bgp4Neighbor cget -localIpAddress ]
        keylset returnList asn        [bgp4Neighbor cget -localAsNumber  ]

    } elseif {$mode == "neighbors"} {
        # MODE NEIGHBORS
        set retCode [bgp4Server getNeighbor $neighbor_handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    bgp4Server getNeighbor $neighbor_handle failed. \
                    Return code was $retCode."
            return $returnList
        }
        keylset returnList peers [bgp4Neighbor cget -dutIpAddress ]

    } elseif {$mode == "labels"} {
        # MODE LABELS
        set retCode [bgp4Server getNeighbor $neighbor_handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    bgp4Server getNeighbor $neighbor_handle failed. \
                    Return code was $retCode."
            return $returnList
        }
        if {[info exists l3site_handle]} {
            set retCode [bgp4Neighbor getL3Site $l3site_handle]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        bgp4Neighbor getL3Site $l3site_handle failed. \
                        Return code was $retCode."
                return $returnList
            }
            set retCode [bgp4VpnL3Site requestLearnedRoutes]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        bgp4VpnL3Site requestLearnedRoutes failed. \
                        Return code was $retCode."
                return $returnList
            }
            set requestResult [bgp4VpnL3Site getLearnedRouteList]
            for {set i 0} {($requestResult != 0) && ($i < 5)} {incr i} {
                after 3000
                set requestResult [bgp4VpnL3Site getLearnedRouteList]
            }
        } else  {
            set retCode [bgp4Neighbor requestLearnedRoutes]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        bgp4Neighbor requestLearnedRoutes failed. \
                        Return code was $retCode."
                return $returnList
            }
            set requestResult [bgp4Neighbor getLearnedRouteList]
            for {set i 0} {($requestResult != 0) && ($i < 5)} {incr i} {
                after 3000
                set requestResult [bgp4Neighbor getLearnedRouteList]
            }
        }
        if {$requestResult == 0} {
            set key 1
            array set familyId [list                     \
                    ipv4,unicast   bgp4FamilyIpV4Unicast   \
                    ipv4,multicast bgp4FamilyIpV4Multicast \
                    ipv4,mpls      bgp4FamilyIpV4Mpls      \
                    ipv4,mplsVpn   bgp4FamilyIpV4MplsVpn   \
                    ipv6,unicast   bgp4FamilyIpV6Unicast   \
                    ipv6,multicast bgp4FamilyIpV6Multicast \
                    ipv6,mpls      bgp4FamilyIpV6Mpls      \
                    ipv6,mplsVpn   bgp4FamilyIpV6MplsVpn   \
                    userdefined    bgp4FamilyUserDefined   \
                    ipvpls         bgp4FamilyIpVpls        ]
            foreach {index value} [array get familyId] {
                set version [lindex [split $index ,] 0]
                set type    [lindex [split $index ,] 1]

                set learnedRetCode [bgp4LearnedRoute getFirst  $value]
                while {$learnedRetCode == 0} {
                    set ipAddress     [bgp4LearnedRoute cget -ipAddress         ]
                    set prefixLen     [bgp4LearnedRoute cget -prefixLength      ]
                    set label         [bgp4LearnedRoute cget -label             ]
                    set distinguisher [bgp4LearnedRoute cget -routeDistinguisher]
                    set neighbor      [bgp4LearnedRoute cget -neighbor          ]

                    if {[bgp4Neighbor cget -enableNextHop]} {
                        set nextHop [bgp4Neighbor cget -nextHop      ]
                    } else  {
                        set nextHop [bgp4Neighbor cget -dutIpAddress ]
                    }
                    keylset returnList                           \
                            $key.next_hop       $nextHop         \
                            $key.neighbor       $neighbor        \
                            $key.network        $ipAddress       \
                            $key.prefix_len     $prefixLen       \
                            $key.distinguisher  $distinguisher   \
                            $key.label          $label           \
                            $key.version        $version         \
                            $key.type           $type

                    set  learnedRetCode [bgp4LearnedRoute getNext $value]
                    incr key
                }
            }
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}
