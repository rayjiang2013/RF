##Library Header.
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_rsvp_api.tcl
#
# Purpose:
#     A script development library containing RSVP APIs for test automation
#     with the Ixia chassis.
#
# Author:
#    Hasmik Shakaryan
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_rsvp_config
#    - emulation_rsvp_tunnel_config
#    - emulation_rsvp_control
#    - emulation_rsvp_info
#    - emulation_rsvp_tunnel_info
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

proc ::ixia::emulation_rsvp_config { args } {
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
                \{::ixia::emulation_rsvp_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable rsvp_handles_array

    ::ixia::utrackerLog $procName $args

    keylset returnList status $::SUCCESS

    # Arguments
    set man_args {
        -mode        CHOICES create delete disable enable modify
    }
    set opt_args {
        -port_handle                    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle
        -interface_handle
        -actual_restart_time            RANGE       50-4294967295
                                        DEFAULT     15000
        -bfd_registration               CHOICES 0 1
                                        DEFAULT 0
        -bundle_msg_sending             CHOICES 0 1
                                        DEFAULT 0
        -count                          NUMERIC
                                        DEFAULT 1
        -enable_bgp_over_lsp            CHOICES     0 1
                                        DEFAULT     1
        -gateway_ip_addr                IP
        -gateway_ip_addr_step           IP
                                        DEFAULT 0.0.1.0
        -graceful_restart               CHOICES     0 1
                                        DEFAULT     0
        -graceful_restart_helper_mode   CHOICES 0 1
                                        DEFAULT 0
        -graceful_restart_recovery_time RANGE       0-4294967295
                                        DEFAULT     30000
        -graceful_restart_restart_time  RANGE       100-4294967295
                                        DEFAULT     5000
        -graceful_restart_start_time    RANGE       50-4294967295
                                        DEFAULT     30000
        -graceful_restart_up_time       RANGE       50-4294967295
                                        DEFAULT     30000
        -graceful_restarts_count        RANGE       0-65535
                                        DEFAULT     0
        -hello_tlvs                     ANY
        -intf_ip_addr               IP
                                    DEFAULT 0.0.0.0
        -intf_prefix_length         RANGE   1-32
                                    DEFAULT 24
        -intf_ip_addr_step          IP
                                    DEFAULT 0.0.1.0
        -neighbor_intf_ip_addr      IP
                                    DEFAULT 0.0.0.0
        -neighbor_intf_ip_addr_step IP
                                    DEFAULT 0.0.1.0
        -refresh_interval           NUMERIC
        -refresh_retry_count        NUMERIC
        -summary_refresh            CHOICES 0 1
                                    DEFAULT 0
        -srefresh_interval          NUMERIC
        -hello_msgs                 CHOICES 0 1
        -hello_interval             RANGE   1-65535
        -hello_retry_count          RANGE   1-255
        -refresh_reduction          CHOICES 0 1
                                    DEFAULT 0
        -reliable_delivery          CHOICES 0 1
                                    DEFAULT 0
        -bundle_msgs                CHOICES 0 1
                                    DEFAULT 0
        -resv_confirm               CHOICES 0 1
        -record_route               CHOICES 0 1
        -ttl                        CHOICES 1 64
        -egress_label_mode          CHOICES nextlabel imnull exnull
        -max_label_value            RANGE   1-1048575
        -min_label_value            RANGE   1-1048575
        -vpi                        RANGE   0-255
        -vci                        RANGE   0-65535
        -vpi_step                   RANGE   0-255
        -vci_step                   RANGE   0-65535
        -atm_encapsulation          CHOICES VccMuxIPV4Routed
                                    CHOICES VccMuxIPV6Routed
                                    CHOICES VccMuxBridgedEthernetFCS
                                    CHOICES VccMuxBridgedEthernetNoFCS
                                    CHOICES LLCRoutedCLIP
                                    CHOICES LLCBridgedEthernetFCS
                                    CHOICES LLCBridgedEthernetNoFCS
        -vlan_id                    RANGE   0-4095
        -vlan_id_mode               CHOICES fixed increment
                                    DEFAULT increment
        -vlan_id_step               RANGE   0-4095
                                    DEFAULT 1
        -vlan_user_priority         RANGE   0-7
                                    DEFAULT 0
        -path_state_refresh_timeout RANGE   1-65535
        -resv_state_refresh_timeout RANGE   1-65535
        -router_alert               CHOICES 1
        -path_state_timeout_count   RANGE   1-255
        -resv_state_timeout_count   RANGE   1-255
        -reset
        -ip_version                 CHOICES 4
                                    DEFAULT 4
        -mac_address_init           MAC
        -mac_address_step           MAC
                                    DEFAULT 0000.0000.0001
        -no_write                   FLAG
        -vlan                       CHOICES 0 1
        -writeFlag                  CHOICES write nowrite
        -override_existence_check   CHOICES 0 1
                                    DEFAULT 0
        -override_tracking          CHOICES 0 1
                                    DEFAULT 0
    }

    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_rsvp_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }    

    # Items that we do not support or they are ON by default
    # router_alert          - on by default
    # ttl                   - N/A    It is not user configurable. By
    #                                default it is 1 for hello messages
    #                                and for anything else it is 64.
    # Items need clearification
    # max_lsps, mtu, user_priority
    #-vpi<RANGE 0-255>         \ Not supported yet
    #-vci<RANGE 0-65535>       \ Not supported yet
    #-timeout<RANGE 0-999999>  \ Not supported yet
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
    
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }
    
    if {($mode == "enable") || ($mode == "modify") || \
                ($mode == "create")} {
        set enable $::true
    } else {
        set enable $::false
    }
    
    # Setup the corresponding parameters array
    array set rsvpNeighborPair [list                     \
            enableNeighborPair     enable                \
            ipAddress              intf_ip_addr          \
            dutAddress             neighbor_intf_ip_addr \
            enableRefreshReduction refresh_reduction     \
            enableHello            hello_msgs            \
            helloInterval          hello_interval        \
            helloTimeoutMultiplier hello_retry_count     \
            summaryRefreshInterval srefresh_interval     \
            labelSpaceStart        min_label_value       \
            labelSpaceEnd          max_label_value       \
            enableBfdRegistration  bfd_registration      \
            ]

    array set enumList [list ]

    ### The rsvpSenderOptions and rsvpDestOptions are stored in the
    ### rsvp_handles_array; and they are used when configuring
    ### emulation_rsvpte_tunnel_config
    set rsvpOptions {                  \
            refresh_interval           \
            refresh_retry_count        \
            path_state_refresh_timeout \
            path_state_timeout_count   \
            record_route               \
            resv_confirm               \
            resv_state_refresh_timeout \
            resv_state_timeout_count   \
            egress_label_mode          }

    set tunnelOptionList [list]
    foreach option $rsvpOptions {
        if {[info exists $option]} {
            lappend tunnelOptionList "$option [set $option]"
        }
    }
    
    # Since  refresh reduction, reliable_delivery, bundle_msgs, and
    # summary_refresh configs apply to the same config parameter, if any one
    # of the options is set, the refresh_reduction is set.
    catch {set refresh_reduction [expr $refresh_reduction || $reliable_delivery \
                || $bundle_msgs || $summary_refresh]}
    
    set rsvp_neighbor_list [list]
    
    if {$mode == "delete"} {
        if {[info exists handle]} {
            foreach item $handle {
                if {![info exists rsvp_handles_array($handle,session)]} {
                    keylset returnList log "ERROR in $procName: Invalid handle\
                            $handle."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                set port_handle $rsvp_handles_array($handle,session)
                set port_list [format_space_port_list $port_handle]
                set interface [lindex $port_list 0]
                # Set chassis card port
                foreach {chasNum cardNum portNum} $interface {}
                ::ixia::addPortToWrite $chasNum/$cardNum/$portNum
                
                # Check if RSVP package has been installed on the port
                if {[catch {rsvpServer select $chasNum $cardNum $portNum} \
                            retCode]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The RSVP\
                            protocol has not been installed on port or\
                            is not supported on port: \
                            $chasNum/$cardNum/$portNum."
                    return $returnList
                }
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            rsvpServer select $chasNum $cardNum $portNum."
                    return $returnList
                }
                if {[rsvpServer delNeighborPair $handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to delete\
                            the RSVP TE $handle on port $chasNum $cardNum\
                            $portNum."
                    return $returnList
                }
                set retCode [::ixia::updateRsvpHandleArray \
                        -mode        delete  \
                        -handle_type session \
                        -handle      $handle ]
                
                if {[keylget retCode status] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget retCode log]"
                    return $returnList
                }
            }
            keylset returnList handles $handle
            
        } elseif {[info exists port_handle]} {
            set port_list [format_space_port_list $port_handle]
            set interface [lindex $port_list 0]
            # Set chassis card port
            foreach {chasNum cardNum portNum} $interface {}
            ::ixia::addPortToWrite $chasNum/$cardNum/$portNum
            
            # Check if RSVP package has been installed on the port
            if {[catch {rsvpServer select $chasNum $cardNum $portNum} \
                        retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The RSVP\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chasNum/$cardNum/$portNum."
                return $returnList
            }
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        rsvpServer select $chasNum $cardNum $portNum."
                return $returnList
            }
            
            if {[initializeRsvp $chasNum $cardNum $portNum]} {
                keylset returnList log "ERROR in $procName: Failed to\
                        initializeRsvp on port $chasNum.$cardNum.$portNum."
                keylset returnList status $::FAILURE
            }
            set retCode [::ixia::updateRsvpHandleArray \
                    -mode              reset           \
                    -handle_value      $chasNum/$cardNum/$portNum]
            
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }

            set handle_list [list]
            foreach {index value} [array get rsvp_handles_array] {
                if {$value == "$chasNum/$cardNum/$portNum"} {
                    lappend handle_list [lindex [split $index ,] 0]
                }
            }

            keylset returnList handles $handle_list
        } else  {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: -handle or\
                    -port_handle must be provided for -mode delete."
            return $returnList
        }
    }
    
    if {($mode == "disable") || ($mode == "enable")} {
        if {![info exists handle]} {
            keylset returnList log "ERROR in $procName: When -mode is $mode \
                    please specify -handle parameter."
            keylset returnList status $::FAILURE
            return $returnList
        }
        foreach item $handle {
            if {![info exists rsvp_handles_array($handle,session)]} {
                keylset returnList log "ERROR in $procName: Invalid handle\
                        $handle."
                keylset returnList status $::FAILURE
                return $returnList
            }
            set port_handle $rsvp_handles_array($handle,session)
            set port_list [format_space_port_list $port_handle]
            set interface [lindex $port_list 0]
            # Set chassis card port
            foreach {chasNum cardNum portNum} $interface {}
            ::ixia::addPortToWrite $chasNum/$cardNum/$portNum
            
            # Check if RSVP package has been installed on the port
            if {[catch {rsvpServer select $chasNum $cardNum $portNum} \
                        retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The RSVP\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chasNum/$cardNum/$portNum."
                return $returnList
            }
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        rsvpServer select $chasNum $cardNum $portNum."
                return $returnList
            }
            if {[rsvpServer getNeighborPair $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to delete\
                        the RSVP TE $handle on port $chasNum $cardNum\
                        $portNum."
                return $returnList
            }
            rsvpNeighborPair config -enableNeighborPair $enable
            if {[rsvpServer setNeighborPair $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to delete\
                        the RSVP TE $handle on port $chasNum $cardNum\
                        $portNum."
                return $returnList
            }
        }

        keylset returnList handles $handle
    }
    
    if {($mode == "delete") || ($mode == "enable") || ($mode == "disable")} {
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
    
    # CREATE OR MODIFY FROM HERE
    
    # If the user is modifying an existing configuration, the mode will be
    # modify and an input option handle will exist.  A flag will be set to
    # indicate this combination.
    set rsvpte_modify_flag 0

    # Check if the call is for modify
    if {$mode == "modify"} {
        if {![info exists handle]} {
            keylset returnList log "ERROR in $procName: When -mode is $mode \
                    please specify -handle parameter."
            keylset returnList status $::FAILURE
            return $returnList
        } elseif {[llength $handle] > 1} {
            keylset returnList log "ERROR in $procName: -handle must\
                    have only one element when -mode modify."
            keylset returnList status $::FAILURE
            return $returnList
        } elseif {![info exists rsvp_handles_array($handle,session)]} {
            keylset returnList log "ERROR in $procName: Invalid handle\
                    $handle."
            keylset returnList status $::FAILURE
            return $returnList
        }
        set port_handle $rsvp_handles_array($handle,session)
        set rsvpte_modify_flag 1
        if {![info exists count]} {
            set count 1
        }
    }
    
    if {$mode == "create"} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is $mode \
                    please specify -port_handle parameter."
            return $returnList
        }
    }
    
    set port_list [format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    # Set chassis card port
    foreach {chasNum cardNum portNum} $interface {}
    ::ixia::addPortToWrite $chasNum/$cardNum/$portNum
    
    # Check if RSVP package has been installed on the port
    if {[catch {rsvpServer select $chasNum $cardNum $portNum} retCode]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The RSVP protocol\
                has not been installed on port or is not supported on port: \
                $chasNum/$cardNum/$portNum."
        return $returnList
    }
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to\
                rsvpServer select $chasNum $cardNum $portNum."
        return $returnList
    }
    
    set max_nodes    $count

    if {$rsvpte_modify_flag == 0} {

        #################################
        #  CONFIGURE THE IXIA INTERFACES
        #################################
        set config_param \
                "-port_handle $port_handle     \
                -count        $max_nodes       \
                -ip_address   $intf_ip_addr    \
                -ip_version   $ip_version      "
        
        set config_options \
                "-mac_address            mac_address_init          \
                -gateway_ip_address      neighbor_intf_ip_addr     \
                -gateway_ip_address_step neighbor_intf_ip_addr_step\
                -netmask                 intf_prefix_length        \
                -vlan_id                 vlan_id                   \
                -vlan_id_mode            vlan_id_mode              \
                -vlan_id_step            vlan_id_step              \
                -vlan_user_priority      vlan_user_priority        \
                -ip_address_step         intf_ip_addr_step         \
                -no_write                no_write                  "
        
        foreach {option value_name} $config_options {
            if {[info exists $value_name]} {
                append config_param " $option [set $value_name] "
            }
        }
        
        set int_h_handles_rsvp ""
        
        if {[info exists interface_handle]} {
            # Nothing to do here, as the creation of the interface was the key
            # and this was done in the interface_config call.  No direct
            # association is made with the interface description in here.
            
            # Store the intf_ip_addr and neighbor_intf_ip_addr. They are needed to create
            #   the neighbors
            
            set max_nodes [llength $interface_handle]
            foreach intf_h $interface_handle {
                
                set ret_code [get_interface_parameter           \
                        -description    $intf_h                 \
                        -parameter      [list ipv4_address      \
                                              ipv4_gateway]     \
                        -input          intf_handle             \
                    ]
                if {[keylget ret_code status] != $::SUCCESS} {
                    keylset returnList log "ERROR in $procName: Could not\
                            get interface details from interface handle\
                            $intf_h. [keylget ret_code log]"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                
                set ip_addr       [keylget ret_code ipv4_address]
                set neighbor_addr [keylget ret_code ipv4_gateway]
                
                if {![isValidIPAddress $ip_addr]} {
                    keylset returnList log "ERROR in $procName: Interface\
                            '$intf_h' passed with '-interface_handle'\
                            parameter is not an IPv4 interface"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                
                if {![isValidIPAddress $neighbor_addr]} {
                    set neighbor_addr na
                }
                
                lappend int_h_handles_rsvp "$ip_addr,$neighbor_addr"
            }
            
        } else {
            set intf_status [eval ixia::protocol_interface_config $config_param]

            if {[keylget intf_status status] == $::FAILURE} {
                keylset returnList log "ERROR in $procName: Failed in\
                        protocol_interface_config call on $chasNum $cardNum\
                        $portNum.  Log : [keylget intf_status log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
        }

        if {[info exists reset]} {
            if {[rsvpServer clearAllNeighborPair]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        rsvpServer clearAllNeighborPair."
                return $returnList
            }
            set retCode [::ixia::updateRsvpHandleArray \
                    -mode              reset           \
                    -handle_value      $port_handle    ]
            
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
        }
    }

    for {set nodeId 1} {$nodeId <= $max_nodes} {incr nodeId} {

        # Get next neighbor on the Ixia interface
        if {![info exists handle]} {
            set next_NeighborPair [getNextNeighborPair $port_handle]
            rsvpNeighborPair setDefault
            rsvpNeighborPair clearAllDestinationRange
            rsvpNeighborPair clearHelloTlvList
        } else {
            set next_NeighborPair $handle
            if {[rsvpServer getNeighborPair $next_NeighborPair]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        rsvpServer getNeighborPair $next_NeighborPair."
                return $returnList
            }
        }
        
        if {[info exists int_h_handles_rsvp]} {
            set ip_pair [lindex $int_h_handles_rsvp [expr $nodeId - 1]]
            if {[llength $ip_pair] > 0} {
                foreach {ip_addr neighbor_addr} [split $ip_pair ,] {}
                set intf_ip_addr $ip_addr
                if {[isValidIPAddress $neighbor_addr]} {
                    set neighbor_intf_ip_addr $neighbor_addr
                    set gateway_ip_addr       $neighbor_addr
                }
            }
        }
        
        foreach item [array names rsvpNeighborPair] {
            if {![catch {set $rsvpNeighborPair($item)} value] } {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                catch {rsvpNeighborPair config -$item $value}
            }
        }

        if {$rsvpte_modify_flag == 0} {
            if {[rsvpServer addNeighborPair $next_NeighborPair] } {
                keylset returnList log "ERROR in $procName: Failed on\
                        rsvpServer addNeighborPair $next_NeighborPair call on\
                        port $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }

        } else {
            if {[rsvpServer setNeighborPair $next_NeighborPair]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed on\
                        rsvpServer setNeighborPair $next_NeighborPair call on\
                        port $chasNum $cardNum $portNum."
                return $returnList
            }
        }

        lappend rsvp_neighbor_list $next_NeighborPair

        ## increment the ipAddress and dutAddress for next node
        if {[info exists intf_ip_addr_step]} {
            set intf_ip_addr [increment_ipv4_address_hltapi\
                    $intf_ip_addr $intf_ip_addr_step]
        }
        if {[info exists neighbor_intf_ip_addr_step]} {
            set neighbor_intf_ip_addr [increment_ipv4_address_hltapi\
                    $neighbor_intf_ip_addr $neighbor_intf_ip_addr_step]
        }
    }

    foreach rsvp_handle $rsvp_neighbor_list {
        set retCode [::ixia::updateRsvpHandleArray \
                -mode              create          \
                -handle            $rsvp_handle    \
                -handle_type       session         \
                -handle_value      $port_handle    ]
        
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget retCode log]"
            return $returnList
        }
        writeRsvpHandleOptions $rsvp_handle tunnelOptions $tunnelOptionList
    }

    stat config -enableRsvpStats $::true
    if {[stat set $chasNum $cardNum $portNum ]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on stat set $chasNum\
                $cardNum $portNum call."
        return $returnList
    }
    
    if {[protocolServer get $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on protocolServer\
                get $chasNum $cardNum $portNum call."
        return $returnList
    }
    protocolServer config -enableRsvpService true
    if {[protocolServer set $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on protocolServer\
                set $chasNum $cardNum $portNum call."
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
    
    keylset returnList handles $rsvp_neighbor_list
    return $returnList
}


proc ::ixia::emulation_rsvp_tunnel_config { args } {
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
                \{::ixia::emulation_rsvp_tunnel_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable rsvp_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    keylset returnList status $::SUCCESS

    # Arguments
    set man_args {
        -mode                               CHOICES create delete modify
    }
    set opt_args {
        -adspec                             CHOICES 1
        -avoid_node_id                      VCMD ::ixia::isValidIPAddress
        -count                              NUMERIC
        -egress_behavior                        CHOICES always_use_configured_style
                                                CHOICES use_se_when_indicated_in_session_attribute
                                                DEFAULT always_use_configured_style
        -egress_ip_addr                     IP
                                            DEFAULT 0.0.0.0
        -egress_ip_count                    NUMERIC
        -egress_ip_step                     IP
                                            DEFAULT 0.0.1.0
        -egress_leaf_ip_count               NUMERIC
                                            DEFAULT 1
        -egress_leaf_range_count            NUMERIC
                                            DEFAULT 1
        -egress_leaf_range_param_type       CHOICES list single_value
                                            DEFAULT single_value
        -egress_leaf_range_step             IP
                                            DEFAULT 1.0.0.0
        -emulation_type                         CHOICES rsvpte rsvptep2mp
                                                DEFAULT rsvpte
        -enable_append_connected_ip             CHOICES 0 1
                                                DEFAULT 1
        -enable_prepend_tunnel_leaf_ip          CHOICES 0 1
                                                DEFAULT 1
        -enable_prepend_tunnel_head_ip          CHOICES 0 1
                                                DEFAULT 1
        -enable_send_as_rro                     CHOICES 0 1
                                                DEFAULT 1
        -enable_send_as_srro                    CHOICES 0 1
                                                DEFAULT 0
        -ero                                CHOICES 0 1
                                            DEFAULT 0
        -ero_dut_pfxlen                     RANGE 1-32
        -ero_list_as_num                    NUMERIC
        -ero_list_ipv4                      IP
        -ero_list_loose                     CHOICES 0 1
        -ero_list_pfxlen                    RANGE 1-128
        -ero_list_type                      CHOICES ipv4 as
                                            DEFAULT ipv4
        -ero_mode                           CHOICES loose strict none
                                            DEFAULT loose
        -explicit_traffic_item              CHOICES 0 1
                                            DEFAULT 0
        -extended_tunnel_id_type            CHOICES egress ingress custom
        -facility_backup                    CHOICES 0 1
                                            DEFAULT 0
        -fast_reroute                       CHOICES 0 1
                                            DEFAULT 0
        -fast_reroute_bandwidth
        -fast_reroute_exclude_any
        -fast_reroute_holding_priority      RANGE 0-255
                                            DEFAULT 7
        -fast_reroute_hop_limit             RANGE 0-255
                                            DEFAULT 3
        -fast_reroute_include_all
        -fast_reroute_include_any
        -fast_reroute_setup_priority        RANGE 0-255
                                            DEFAULT 7
        -h2l_info_dut_hop_type                  CHOICES strict loose
                                                DEFAULT loose
        -h2l_info_dut_prefix_length             RANGE   1-32
                                                DEFAULT 32
        -h2l_info_enable_append_tunnel_leaf     CHOICES 0 1
                                                DEFAULT 1
        -h2l_info_enable_prepend_dut            CHOICES 0 1
                                                DEFAULT 1
        -h2l_info_enable_send_as_ero            CHOICES 0 1
                                                DEFAULT 1
        -h2l_info_enable_send_as_sero           CHOICES 0 1
                                                DEFAULT 0
        -h2l_info_ero_sero_list                 ANY
        -h2l_info_tunnel_leaf_count             RANGE   1-4294967295
                                                DEFAULT 1
        -h2l_info_tunnel_leaf_hop_type          CHOICES strict loose
                                                DEFAULT loose
        -h2l_info_tunnel_leaf_ip_start          IP
                                                DEFAULT 0.0.0.0
        -h2l_info_tunnel_leaf_prefix_length     RANGE   1-32
                                                DEFAULT 32
        -handle
        -head_traffic_ip_type                   CHOICES ipv4 ipv6
                                                DEFAULT ipv4
        -head_traffic_ip_count                  RANGE   1-4294967295
                                                DEFAULT 1
        -head_traffic_start_ip                  IP
        -head_traffic_inter_tunnel_ip_step    IP
        -ingress_bandwidth                  DECIMAL
        -ingress_ip_addr                    IP
                                            DEFAULT 0.0.0.0
        -ingress_ip_count                   NUMERIC
        -ingress_ip_step                    IP
                                            DEFAULT 0.0.1.0
        -ingress_enable_interface_creation  CHOICES 0 1
                                            DEFAULT 1
        -lsp_id_count                       RANGE 0-65535
                                            DEFAULT 1
        -lsp_id_start                       RANGE 0-65535
                                            DEFAULT 0
        -lsp_id_step                        RANGE 0-65535
                                            DEFAULT 1
        -no_write                           FLAG
        -one_to_one_backup                  CHOICES 0 1
                                            DEFAULT 0
        -p2mp_id                                ANY
                                                DEFAULT "0.0.0.1"
        -p2mp_id_step                           ANY
                                                DEFAULT "0.0.0.0"
        -path_error_tlv                         ANY
        -path_tear_tlv                          ANY
        -path_tlv                               ANY
        -plr_id                             VCMD ::ixia::isValidIPAddress
        -port_handle                        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -record_route                           CHOICES 0 1
        -reservation_error_tlv                  ANY
        -reservation_style                      CHOICES ff se
                                                DEFAULT se
        -reservation_tear_tlv                   ANY
        -reservation_tlv                        ANY
        -rro                                CHOICES 0 1
                                            DEFAULT 0
        -rro_list_ctype                     RANGE 0-255
        -rro_list_flags                     RANGE 0-255
        -rro_list_ipv4                      IP
        -rro_list_label                     NUMERIC
        -rro_list_type                      CHOICES ipv4 label
                                            DEFAULT ipv4
        -rsvp_behavior                      CHOICES rsvpIngress rsvpEgress
                                            DEFAULT rsvpEgress
        -send_detour
        -sender_tspec_max_pkt_size          NUMERIC
        -sender_tspec_min_policed_size      NUMERIC
        -sender_tspec_peak_data_rate        DECIMAL
        -sender_tspec_token_bkt_rate        DECIMAL
        -sender_tspec_token_bkt_size        DECIMAL
        -session_attr                       CHOICES 1
        -session_attr_setup_priority        RANGE 0-255
        -session_attr_hold_priority         RANGE 0-255
        -session_attr_name
        -session_attr_local_protect         CHOICES 0 1
        -session_attr_label_record          CHOICES 0 1
        -session_attr_se_style              CHOICES 0 1
        -session_attr_bw_protect            CHOICES 0 1
        -session_attr_node_protect          CHOICES 0 1
        -session_attr_flags                 RANGE 0-255
        -session_attr_resource_affinities   CHOICES 0 1
                                            DEFAULT 0
        -session_attr_ra_exclude_any
        -session_attr_ra_include_any
        -session_attr_ra_include_all
        -session_attr_reroute               CHOICES 0 1
        -tail_traffic_ip_type                   CHOICES ipv4 ipv6
                                                DEFAULT ipv4
        -tail_traffic_ip_count                  RANGE   1-4294967295
                                                DEFAULT 1
        -tail_traffic_start_ip                  IP
        -tail_traffic_inter_tunnel_ip_step      IP
        -tunnel_id_start                    RANGE 0-65535
                                            DEFAULT 0
        -tunnel_id_count                    RANGE 0-65535
                                            DEFAULT 1
        -tunnel_id_step                     RANGE 0-65535
                                            DEFAULT 1
        -tunnel_pool_handle
        -writeFlag                          CHOICES write nowrite
                                            DEFAULT write
    }

    # Items that we do not support or they are ON by default
    # adspec                    - enabled by default
    # adspec_comp_mtu           - default to 0
    # adspec_csum               - default to 0
    # adspec_ctot               - default to 0
    # adspec_ctrl_load          - default to 0
    # adspec_dsum               - default to 0
    # adspec_dtot               - default to 0
    # adspec_est_path_bw        - default to 0
    # adspec_guaranteed_svc     - default to 0
    # adspec_hop_count          - default to 0
    # adspec_min_path_latency   - default to 0
    # destination_ip            - Ixia doesn't support
    # duration                  - Will not be used
    # extended_tunnel_id        - Ixia doesn't support
    # extended_tunnel_id_type   - Ixia doesn't support
    # interval                  - Will not be used
    # sender_adspec             - N/A
    # sender_cos                - Not user configurable
    # session_attr              - On by default
    # ttl                       - N/A It is not user configurable.  By default
    #                                 it is 1 for hello messages and for
    #                                 anything else it is 64.

    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_rsvp_tunnel_config $args $man_args $opt_args]
        return $returnList
    }    

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
    
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }
    
    if {$mode == "create"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: No -handle was\
                    provided to -mode create."
            return $returnList
        } elseif {[llength $handle] > 1} {
            keylset returnList log "ERROR in $procName: -handle must\
                    have only one element."
            keylset returnList status $::FAILURE
            return $returnList
        } elseif {![info exists rsvp_handles_array($handle,session)]} {
            keylset returnList log "ERROR in $procName: Invalid handle\
                    $handle."
            keylset returnList status $::FAILURE
            return $returnList
        }
        set port_handle $rsvp_handles_array($handle,session)
    } else  {
        if {![info exists tunnel_pool_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: No -tunnel_pool_handle\
                    was provided to -mode $mode."
            return $returnList
        } elseif {[llength $tunnel_pool_handle] > 1} {
            keylset returnList log "ERROR in $procName: -tunnel_pool_handle\
                    must have only one element."
            keylset returnList status $::FAILURE
            return $returnList
        } elseif {![info exists \
                    rsvp_handles_array($tunnel_pool_handle,tunnel)]} {
            
            keylset returnList log "ERROR in $procName: Invalid\
                    -tunnel_pool_handle $tunnel_pool_handle."
            keylset returnList status $::FAILURE
            return $returnList
        }
        set handle      $rsvp_handles_array($tunnel_pool_handle,tunnel)
        set port_handle $rsvp_handles_array($handle,session)
    }

    if { $mode == "delete"} {
        set enable $::false
    } else {
        set enable $::true
    }

    ### Get the options that's are set in emulation_rsvp_config which
    ### need to be set for each tunnel
    set configOptionsList [getRsvpHandleOptions $handle tunnelOptions]
    foreach {option} $configOptionsList {
        set [lindex $option 0] [lindex $option 1]
    }
    if {[info exists refresh_interval]} {

        if {![info exists path_state_refresh_timeout]} {
            set path_state_refresh_timeout $refresh_interval
        }
        if {![info exists resv_state_refresh_timeout]} {
            set resv_state_refresh_timeout $refresh_interval
        }
    }

    if {[info exists refresh_retry_count]} {
        if {![info exists path_state_timeout_count]} {
            set path_state_timeout_count $refresh_retry_count
        }
        if {![info exists resv_state_timeout_count]} {
            set resv_state_timeout_count $refresh_retry_count
        }
    }

    # Setup the corresponding parameters array
    array set rsvpDestinationRange [list \
            enableDestinationRange  enable                     \
            behavior                rsvp_behavior              \
            fromIpAddress           egress_ip_addr             \
            enableResvConf          resv_confirm               \
            enableSendRro           rro                        \
            enableEro               ero                        \
            eroMode                 ero_mode                   \
            prefixLength            ero_dut_pfxlen             \
            refreshInterval         resv_state_refresh_timeout \
            timeoutMultiplier       resv_state_timeout_count   \
            labelValue              egress_label_mode          \
            tunnelIdStart           tunnel_id_start            \
            tunnelIdEnd             local_tunnel_id_end        \
            enableFixedLabelForResv enableFixedLabelForResv    ]

    array set rsvpSenderRange [list \
            enableSenderRange                enable                         \
            fromIpAddress                    ingress_ip_addr                \
            refreshInterval                  path_state_refresh_timeout     \
            timeoutMultiplier                path_state_timeout_count       \
            tokenBucketRate                  sender_tspec_token_bkt_rate    \
            tokenBucketSize                  sender_tspec_token_bkt_size    \
            peakDataRate                     sender_tspec_peak_data_rate    \
            minPolicedUnit                   sender_tspec_min_policed_size  \
            maxPacketSize                    sender_tspec_max_pkt_size      \
            enableBandwidthProtectionDesired session_attr_bw_protect        \
            enableNodeProtectionDesired      session_attr_node_protect      \
            enableLocalProtectionDesired     session_attr_local_protect     \
            enableSeStyleDesired             session_attr_merge             \
            enableFastReroute                session_attr_reroute           \
            sessionName                      session_attr_name              \
            setupPriority                    session_attr_setup_priority    \
            holdingPriority                  session_attr_hold_priority     \
            enableLabelRecording             session_attr_label_record      \
            enableSeStyleDesired             session_attr_se_style          \
            enableRaSessionAttribute         session_attr_resource_affinities\
            excludeAny                       session_attr_ra_exclude_any    \
            includeAny                       session_attr_ra_include_any    \
            includeAll                       session_attr_ra_include_all    \
            lspIdStart                       lsp_id_start                   \
            lspIdEnd                         local_lsp_id_end               \
            bandwidth                        ingress_bandwidth              \
            enableOneToOneBackupDesired      one_to_one_backup              \
            enableFacilityBackupDesired      facility_backup                \
            enableFastReroute                fast_reroute                   \
            fastRerouteBandwidth             fast_reroute_bandwidth         \
            fastRerouteExcludeAny            fast_reroute_exclude_any       \
            fastRerouteHoldingPriority       fast_reroute_holding_priority  \
            fastRerouteHopLimit              fast_reroute_hop_limit         \
            fastRerouteIncludeAll            fast_reroute_include_all       \
            fastRerouteIncludeAny            fast_reroute_include_any       \
            fastRerouteSetupPriority         fast_reroute_setup_priority    \
            enableSendDetour                 send_detour                    \
            enableAutoSessionName            enableAutoSessionName       ]

    array set rsvpEroItem   [list \
            type                ero_list_type        \
            enableLooseFlag     local_ero_loose      \
            ipAddress           local_ero_ipv4       \
            prefixLength        local_ero_pfxlen     \
            asNumber            local_ero_as_num     ]

    array set rsvpRroItem   [list \
            type                        rro_list_type               \
            ipAddress                   local_rro_ipv4              \
            label                       local_rro_label             \
            cType                       local_rro_ctype             \
            enableProtectionInUse       local_protection_in_use     \
            enableProtectionAvailable   local_protection_available  \
            enableGlobalLabel           local_enable_global_label   \
            enableBandwidthProtection   local_bandwidth_protection  \
            enableNodeProtection        local_node_protection]

    array set rsvpPlrNodeIdPair [list \
            plrId               plr_id          \
            avoidNodeId         avoid_node_id   ]
    
    set port_list [format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    # Set chassis card port
    foreach {chasNum cardNum portNum} $interface {}
    ::ixia::addPortToWrite $chasNum/$cardNum/$portNum
    
    # Check if RSVP package has been installed on the port
    if {[catch {rsvpServer select $chasNum $cardNum $portNum} retCode]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The RSVP protocol\
                has not been installed on port or is not supported on port: \
                $chasNum/$cardNum/$portNum."
        return $returnList
    }
    
    
    set rsvpte_tunnel_list [list]

    array set enumList [list \
            ipv4    $::rsvpEroIpV4                  \
            as      $::rsvpAs                       \
            label   $::rsvpLabel                    \
            loose   $::rsvpPrependLoose             \
            strict  $::rsvpPrependStrict            \
            none    $::rsvpNone                     \
            imnull  $::rsvpLabelValueImplicitNull   \
            exnumm  $::rsvpLabelValueExplicitNull   ]

    set enableFixedLabelForResv $::false
    if {[info exists egress_label_mode]} {
        switch -- $egress_label_mode {
            imnull    {
                set enableFixedLabelForResv $::true
            }
            exnull    {
                set enableFixedLabelForResv $::true
            }
            nextlabel { }
        }
    }

    set enableAutoSessionName $::true
    if {[info exists session_attr_name] } {
        if {[string length $session_attr_name]} {
            set enableAutoSessionName $::false
        } else {
            unset session_attr_name
        }
    }

    if {![info exists rsvp_behavior]} {
        if {[info exists ingress_ip_addr]} {
            set rsvp_behavior rsvpIngress
        } else {
            set rsvp_behavior rsvpEgress
        }
    }

    if {![info exists rro]} {
        catch {set rro $record_route}
    }
        
    ### convert to Ixia format
    ### note: fastRerouteExcludeAny, fastRerouteIncludeAny,
    ### fastRerouteIncludeAll do not need to convert (Inconsistency in IxTclHal
    if {[info exists session_attr_ra_exclude_any]} {
        if {[string first 0x $session_attr_ra_exclude_any] == -1} {
            set session_attr_ra_exclude_any [format "0x%s" \
                    $session_attr_ra_exclude_any]
        }
        set session_attr_ra_exclude_any [val2Bytes \
                $session_attr_ra_exclude_any 4]
    }
    if {[info exists session_attr_ra_include_any]} {
        if {[string first 0x $session_attr_ra_include_any] == -1} {
            set session_attr_ra_include_any [format "0x%s" \
                    $session_attr_ra_include_any]
        }
        set session_attr_ra_include_any [val2Bytes \
                $session_attr_ra_include_any 4]
    }
    if {[info exists session_attr_ra_include_all]} {
        if {[string first 0x $session_attr_ra_include_all] == -1} {
            set session_attr_ra_include_all [format "0x%s" \
                    $session_attr_ra_include_all]
        }
        set session_attr_ra_include_all [val2Bytes \
                $session_attr_ra_include_all 4]
    }

    if {[rsvpServer select $chasNum $cardNum $portNum]} {
        keylset returnList log "ERROR in $procName: Failed on rsvpServer select\
                $chasNum $cardNum $portNum call."
        keylset returnList status $::FAILURE
        return $returnList
    }

    if {[rsvpServer getNeighborPair $handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on rsvpServer\
                getNeighborPair $handle call on port $chasNum $cardNum $portNum."
        return $returnList
    }

    if {$mode == "delete"} {
        if {[rsvpNeighborPair delDestinationRange $tunnel_pool_handle]} {
            keylset returnList log "ERROR in $procName: Failed on\
                    rsvpNeighborPair delDestinationRange $tunnel_pool_handle\
                    on port $chasNum $cardNum $portNum."
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {[rsvpServer setNeighborPair $handle]} {
            keylset returnList log "ERROR in $procName: Failed on rsvpServer\
                    setNeighborPair $handle call on port $chasNum\
                    $cardNum $portNum."
            keylset returnList status $::FAILURE
            return $returnList
        }
        
        set retCode [::ixia::updateRsvpHandleArray     \
                -mode              delete              \
                -handle            $tunnel_pool_handle ]
        
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget retCode log]"
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
        
        keylset returnList status $::SUCCESS
        return $returnList
    }

    if {$mode == "modify"} {
        if {[rsvpNeighborPair getDestinationRange $tunnel_pool_handle]} {
            keylset returnList log "ERROR in $procName: Failed on\
                    rsvpNeighborPair getDestinationRange $tunnel_pool_handle\
                    on port $chasNum $cardNum $portNum."
            keylset returnList status $::FAILURE
            return $returnList
        }
        if { [rsvpDestinationRange cget -behavior] } {
            set rsvp_behavior rsvpEgress
        } else {
            set rsvp_behavior rsvpIngress
        }
        set count 1
    }

    set tunnel_list [list]
    for {set node 0} {$node < $count} {incr node} {
        if {[info exists tunnel_id_start] && [info exists tunnel_id_count]} {
            set local_tunnel_id_end [expr $tunnel_id_start + \
                    $tunnel_id_count - 1]
        }
        if {[info exists lsp_id_start] && [info exists lsp_id_count]} {
            set local_lsp_id_end [expr $lsp_id_start + $lsp_id_count - 1]
        }

        if {$mode == "create"} {
            rsvpDestinationRange setDefault
        }
        foreach item [array names rsvpDestinationRange] {
            if {![catch {set $rsvpDestinationRange($item)} value] } {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                catch { rsvpDestinationRange config -$item $value }
            }
        }
        rsvpSenderRange setDefault
        if { $rsvp_behavior == "rsvpIngress" } {

            # This means that we need to create a Sender Range
            foreach item [array names rsvpSenderRange] {
                if {![catch {set $rsvpSenderRange($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch { rsvpSenderRange config -$item $value }
                }
            }
            foreach item [array names rsvpPlrNodeIdPair] {
                if {![catch {set $rsvpPlrNodeIdPair($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch { rsvpPlrNodeIdPair config -$item $value }
                }
            }

            if {[rsvpSenderRange addPlr]} {
                keylset returnList log "ERROR in $procName: Failed on\
                        rsvpSenderRange addPlr on port \
                        $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
            set  senderId [getNextSenderRange]
            if {[rsvpDestinationRange addSenderRange $senderId] } {
                keylset returnList log "ERROR in $procName: Failed on\
                        rsvpDestinationRange addSenderRange $senderId on\
                        port $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }

            if {[info exists rro] && $rro} {
                set returnList [rsvpAddRroItems]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
            }
            if {[info exists ero] && $ero} {
                set returnList [rsvpAddEroItems]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
            }
        }

        if {$mode == "create"} {
            set  destRangeId [getNextDestinationRange]
            if {[rsvpNeighborPair addDestinationRange $destRangeId] } {
                keylset returnList log "ERROR in $procName: Failed on\
                        rsvpNeighborPair addDestinationRange $destRangeId on\
                        port $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
            lappend tunnel_list $destRangeId
            set retCode [::ixia::updateRsvpHandleArray \
                    -mode              create          \
                    -handle            $destRangeId    \
                    -handle_type       tunnel          \
                    -handle_value      $handle         ]
            
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
        } else {
            if {[rsvpNeighborPair setDestinationRange $tunnel_pool_handle]} {
                keylset returnList log "ERROR in $procName: Failed on\
                       rsvpNeighborPair setDestinationRange\
                       $tunnel_pool_handle on port $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
            lappend tunnel_list $tunnel_pool_handle
        }

        ### Increment the ip addresses for next node
        if {[info exists egress_ip_addr] && [info exists egress_ip_step]} {
            set egress_ip_addr [::ixia::increment_ipv4_address_hltapi\
                     $egress_ip_addr $egress_ip_step]
        }
        if {[info exists ingress_ip_addr] && [info exists ingress_ip_step]} {
             set ingress_ip_addr [::ixia::increment_ipv4_address_hltapi\
                     $ingress_ip_addr $ingress_ip_step]
        }
        catch {incr tunnel_id_start $tunnel_id_step}
        catch {incr lsp_id_start $lsp_id_step}
    }

    if {[rsvpServer setNeighborPair $handle]} {
        keylset returnList log "ERROR in $procName: Failed on rsvpServer\
                setNeighborPair $handle call on port $chasNum $cardNum $portNum."
        keylset returnList status $::FAILURE
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

    keylset returnList status $::SUCCESS
    if {$mode == "create"} {
        keylset returnList tunnel_handle $tunnel_list
    }
    return $returnList
}


proc ::ixia::emulation_rsvp_control { args } {
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
                \{::ixia::emulation_rsvp_control $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable rsvp_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
        -mode CHOICES stop start restart sub_lsp_up sub_lsp_down
    }

    set opt_args {
        -handle
        -port_handle REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -teardown
        -restore
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
        set returnList [::ixia::ixnetwork_rsvp_control $args $man_args $opt_args]
        keylset returnList clicks [format "%u" $retValueClicks]
        keylset returnList seconds [format "%u" $retValueSeconds]
        return $returnList
    }    

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args\
            -optional_args $opt_args

    if {$mode == "sub_lsp_down" || $mode == "sub_lsp_up"} {
        keylset returnList log "$procName: -mode $mode is available only for IxTclNetwork."
        keylset returnList status $::FAILURE
        return $returnList
    }

    ### If port_handle option is not passed in, use the port_handle stored in
    ### the session handle
    if {[info exists port_handle]} {
        # Need to replace the slashes with spaces for IxTclHal api calls using
        # port lists
        set port_list [format_space_port_list $port_handle]
    } else {
        if {![info exists handle]} {
            keylset returnList log "$procName: must have either session\
                    handle or port handle option"
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {[array names rsvp_handles_array $handle,session] == ""} {
            keylset returnList log "$procName: cannot find the session handle \
                    $handle in the rsvp_handles_array"
            keylset returnList status $::FAILURE
            return $returnList
        }
        set port_handle [lindex $rsvp_handles_array($handle,session) 0]
        scan $port_handle "%d/%d/%d" chasNum cardNum portNum
        set port_list [list [list $chasNum $cardNum $portNum]]
    }
    
    # Check if RSVP package has been installed on the port
    foreach port_i $port_list {
        foreach {chs_i crd_i prt_i} $port_i {}
        if {[catch {rsvpServer select $chs_i $crd_i $prt_i } error]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The RSVP protocol\
                    has not been installed on port or is not supported on port: \
                    $chs_i/$crd_i/$prt_i."
            return $returnList
        }
    }
    
    switch -exact $mode {
        restart {
            if {[info exists teardown]} {
                set returnList [rsvpTunnelAction  $port_list $handle \
                        $teardown $::false]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                ::ixia::addPortToWrite $port_handle
            } elseif {[info exists handle]} {
                set returnList [rsvpNeighborPairAction $port_list \
                        $handle $::false]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                ::ixia::addPortToWrite $port_handle
            } else {
                if {[ixStopRsvp port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error stopping\
                            RSVP on the port list $port_list."
                    return $returnList
                }
            }
            if {[info exists restore]} {
                set returnList [rsvpTunnelAction $port_list $handle \
                        $restore $::true]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                ::ixia::addPortToWrite $port_handle
            }
            if {[info exists handle]} {
                set returnList [rsvpNeighborPairAction $port_list \
                        $handle $::true]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                ::ixia::addPortToWrite $port_handle
            }
            
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        ::ixia::writePortListConfig failed. \
                        [keylget retCode log]"
                return $returnList
            }
            
            if {[ixStartRsvp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error starting\
                        RSVP on the port list $port_list."
                return $returnList
            }
        }
        start {
            if {[info exists restore]} {
                set returnList [rsvpTunnelAction $port_list $handle \
                        $restore $::true]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                ::ixia::addPortToWrite $port_handle
            }
            if {[info exists handle]} {
                set returnList [rsvpNeighborPairAction $port_list \
                        $handle $::true]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                ::ixia::addPortToWrite $port_handle
            }
            
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        ::ixia::writePortListConfig failed. \
                        [keylget retCode log]"
                return $returnList
            }
            
            if {[ixStartRsvp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error starting\
                        RSVP on the port list $port_list."
                return $returnList
            }
        }
        stop {
            if {[info exists teardown]} {
                set returnList [rsvpTunnelAction  $port_list $handle \
                        $teardown $::false]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                ::ixia::addPortToWrite $port_handle
            } elseif {[info exists handle]} {
                set returnList [rsvpNeighborPairAction $port_list \
                        $handle $::false]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                ::ixia::addPortToWrite $port_handle
            } else {
                if {[ixStopRsvp port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error stopping\
                            RSVP on the port list $port_list."
                    return $returnList
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
            
        }
        default {
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_rsvp_info { args } {
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
                \{::ixia::emulation_rsvp_info $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable rsvp_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set opt_args {
        -mode        CHOICES stats clear_stats settings neighbors labels
                     DEFAULT stats
        -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -handle
    }

    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_rsvp_info $args $opt_args]
        return $returnList
    }    
    
    ::ixia::parse_dashed_args -args $args  -optional_args $opt_args
    
    if {[info exists port_handle]} {
        set port_list [format_space_port_list $port_handle]
        set interface [lindex $port_list 0]
        # Set chassis card port
        foreach {chasNum cardNum portNum} $interface {}
    } elseif {[info exists handle]} {
        if {![info exists rsvp_handles_array($handle,session)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The RSVP handle\
                    $handle is not valid."
            return $returnList
        }
        set port_handle $rsvp_handles_array($handle,session)
        set port_list [format_space_port_list \
                $rsvp_handles_array($handle,session)]
        set interface [lindex $port_list 0]
        # Set chassis card port
        foreach {chasNum cardNum portNum} $interface {}
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: -port_handle or\
                -handle must be provided."
        return $returnList
    }
    
    # Check if RSVP package has been installed on the port
    if {[catch {rsvpServer select $chasNum $cardNum $portNum} retCode]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The RSVP protocol\
                has not been installed on port or is not supported on port: \
                $chasNum/$cardNum/$portNum."
        return $returnList
    }
    
    if {$mode == "clear_stats"} {
        # Do nothing because we cannot retrieve message related information
    }
    
    if {$mode == "stats"} {
        # GET STATS
        statGroup setDefault
        statGroup add $chasNum $cardNum $portNum
        if {[statGroup get]} {
            keylset returnList log "ERROR in $procName: failed to issue\
                    statGroup get on port $chasNum.$cardNum.$portNum."
            keylset returnList status $::FAILURE
            return $returnList
        }
        statList setDefault
        if {[statList get $chasNum $cardNum $portNum]} {
            keylset returnList log "ERROR in $procName: failed to issue\
                    statList get on port $chasNum.$cardNum.$portNum."
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {[catch {statList cget -rsvpIngressLSPsConfigured} \
                    outbound_lsp_count]} {
            set outbound_lsp_count 0
        }
        if {[catch {statList cget -rsvpEgressLSPsUp}          \
                    inbound_lsp_count] } {
            set inbound_lsp_count  0
        }
        set total_lsp_count     [mpexpr $inbound_lsp_count  + \
                $outbound_lsp_count]
        
        
        # GET RX LABELS
        if {[info exists handle]} {
            set get_label_status [getRsvpTunnelLabelList $port_handle $handle]
        } else  {
            set get_label_status [getRsvpTunnelLabelList $port_handle]
        }
        set neighbors     ""
        set lsps          ""
        set rsvpLabelList ""
        if {[keylget get_label_status status] == $::SUCCESS} {
            set rsvpLabelList [keylget get_label_status labelList]
            foreach {rsvpElem} $rsvpLabelList {
                set rsvpTunnel [lindex $rsvpElem 0]
                set rsvpLabel  [lindex $rsvpElem 1]
                if {[regsub {Src: (.*):(.*)/Dst: T(.*):(.*)} $rsvpTunnel \
                            {\3} rsvpNeighbor]} {
                    lappend neighbors $rsvpNeighbor
                }
                lappend lsps $rsvpTunnel
            }
            set neighbors [lsort -unique $neighbors]
            set lsps      [lsort -unique $lsps]
        }
        
        keylset returnList lsp_count           $total_lsp_count
        keylset returnList num_lsp_setup       [llength $lsps]
        keylset returnList peer_count          [llength $neighbors]
    }
    
    if {$mode == "labels"} {
        # GET RX LABELS
        if {[info exists handle]} {
            set get_label_status [getRsvpTunnelLabelList $port_handle $handle]
        } else  {
            set get_label_status [getRsvpTunnelLabelList $port_handle]
        }
        
        if {[keylget get_label_status status] == $::SUCCESS} {
            set rsvpLabelList [keylget get_label_status labelList]
            if {$rsvpLabelList == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: There are no tunnel\
                        labels received on port $chasNum.$cardNum.$portNum."
                return $returnList
            }
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: failed to get the\
                    tunnel labels on port $chasNum.$cardNum.$portNum.  The\
                    labels list is empty."
            return $returnList
        }
        keylset returnList labels $rsvpLabelList
    }
    
    if {$mode == "neighbors"} {
        # GET RX LABELS
        if {[info exists handle]} {
            set get_label_status [getRsvpTunnelLabelList $port_handle $handle]
        } else  {
            set get_label_status [getRsvpTunnelLabelList $port_handle]
        }
        
        if {[keylget get_label_status status] == $::SUCCESS} {
            set neighbors ""
            set rsvpLabelList [keylget get_label_status labelList]
            foreach {rsvpElem} $rsvpLabelList {
                set rsvpTunnel [lindex $rsvpElem 0]
                set rsvpLabel  [lindex $rsvpElem 1]
                if {[regsub {Src: (.*):(.*)/Dst: T(.*):(.*)} $rsvpTunnel \
                            {\3} rsvpNeighbor]} {
                    lappend neighbors $rsvpNeighbor
                }
            }
            keylset returnList neighbors [lsort -unique $neighbors]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to get the\
                    tunnel labels on port $chasNum.$cardNum.$portNum."
            return $returnList
        }
    }
    
    if {$mode == "settings"} {
        if {[rsvpServer select $chasNum $cardNum $portNum]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    rsvpServer select $chasNum $cardNum $portNum."
            return $returnList
        }
        
        if {[info exists $handle]} {
            if {[rsvpServer getNeighborPair $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        rsvpServer getNeighborPair $handle."
                return $returnList
            }
            keylset returnList intf_ip_addr          \
                    [rsvpNeighborPair cget -ipAddress]
            
            keylset returnList neighbor_intf_ip_addr \
                    [rsvpNeighborPair cget -dutAddress]
        } else  {
            if {[rsvpServer getFirstNeighborPair]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        rsvpServer getFirstNeighborPair."
                return $returnList
            }
            set neighbors ""
            set ips       ""
            lappend neighbors [rsvpNeighborPair cget -dutAddress ]
            lappend ips       [rsvpNeighborPair cget -ipAddress  ]
            while {[rsvpServer getNextNeighborPair] == 0} {
                lappend neighbors [rsvpNeighborPair cget -dutAddress ]
                lappend ips       [rsvpNeighborPair cget -ipAddress  ]
            }
            keylset returnList neighbor_intf_ip_addr $neighbors
            keylset returnList intf_ip_addr          $ips
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_rsvp_tunnel_info { args } {
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
                \{::ixia::emulation_rsvp_tunnel_info $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable rsvp_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set opt_args {
        -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -handle
        -info_type   CHOICES assigned_info received_info both
                     DEFAULT both
    }

    variable new_ixnetwork_api
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_rsvp_tunnel_info $args $opt_args]
        return $returnList
    }    
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    if {(![info exists port_handle]) && (![info exists handle])} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: You must\
                provide -port_handle or -handle."
        return $returnList
    } elseif {[info exists handle]} {
        if {[info exists rsvp_handles_array($handle,session)]} {
            set handle_type session
        } elseif {[info exists rsvp_handles_array($handle,tunnel)]} {
            set handle_tunnel $handle
            set handle        $rsvp_handles_array($handle,tunnel)
            set handle_type   tunnel
        } else  {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Invalid\
                    parameter -handle $handle. This parameter should be an\
                    RSVP session handle or tunnel handle."
            return $returnList
        }
        set port_handle      $rsvp_handles_array($handle,session)
    } else  {
        set handle_type port
    }
    
    set port_list [format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    # Set chassis card port
    foreach {chasNum cardNum portNum} $interface {}
    
    # Check if RSVP package has been installed on the port
    if {[catch {rsvpServer select $chasNum $cardNum $portNum} retCode]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The RSVP protocol\
                has not been installed on port or is not supported on port: \
                $chasNum/$cardNum/$portNum."
        return $returnList
    }
    
    # GET STATS
    statGroup setDefault
    statGroup add $chasNum $cardNum $portNum
    if {[statGroup get]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: failed to issue statGroup\
                get command on port $chasNum.$cardNum.$portNum."
        return $returnList
    }
    statList setDefault
    if {[statList get $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: failed to issue statList\
                get command on port $chasNum.$cardNum.$portNum."
        return $returnList
    }
    
    if {[catch {statList cget -rsvpIngressLSPsUp} outbound_up_count]} {
        set outbound_up_count 0
    }
    if {[catch {statList cget -rsvpIngressLSPsConfigured} outbound_lsp_count]} {
        set outbound_lsp_count 0
    }
    if {[catch {statList cget -rsvpEgressLSPsUp} inbound_lsp_count] } {
        set inbound_lsp_count 0
    }
    set total_lsp_count     [mpexpr $inbound_lsp_count  + $outbound_lsp_count]
    set outbound_down_count [mpexpr $outbound_lsp_count - $outbound_up_count ]
    
    # GET LABELS
    if {[info exists handle]} {
        set get_label_status [getRsvpTunnelLabelList $port_handle $handle]
    } else  {
        set get_label_status [getRsvpTunnelLabelList $port_handle]
    }
    
    if {[keylget get_label_status status] == $::SUCCESS} {
        set rsvpLabelList [keylget get_label_status labelList]
        set rsvpReturnLabelList ""
    } else {
        set rsvpLabelList       [list N/A]
        set rsvpReturnLabelList [list N/A]
    }
    
    # GET SETTINGS AND SORT LABEL LIST
    foreach {index value} [array get rsvp_handles_array] {
        set h_name [lindex [split $index ,] 0]
        set h_type [lindex [split $index ,] 1]
        if {($h_type == "session") } {
            keylset rsvpKeys $value.$h_name.type session
        }
        if {($h_type == "tunnel") } {
            lappend rsvpSessions $h_name
            keylset rsvpKeys $rsvp_handles_array($value,session).$value.$h_name \
                    tunnel
        }
    }
    set portKeys [keylget rsvpKeys $port_handle]
    if {$handle_type == "port"} {
        set rsvpSessions [keylkeys portKeys]
    } else {
        set rsvpSessions $handle
    }
    
    foreach {rsvpSession} $rsvpSessions {
        if {[rsvpServer getNeighborPair $rsvpSession]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    rsvpServer getNeighborPair $rsvpSession."
            return $returnList
        }
        if {$handle_type == "tunnel"} {
            set rsvpTunnels $handle_tunnel
        } else  {
            set sessionKeys [keylget portKeys $rsvpSession]
            set rsvpTunnels [keylkeys sessionKeys]
            set pos [lsearch $rsvpTunnels type]
            if {$pos != -1} {
                set rsvpTunnels [lreplace $rsvpTunnels $pos $pos]
            }
        }
        foreach {rsvpTunnel} $rsvpTunnels {
            if {[rsvpNeighborPair getDestinationRange $rsvpTunnel]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        rsvpNeighborPair getDestinationRange $rsvpTunnel."
                return $returnList
            }
            set tunnel_id_start [rsvpDestinationRange cget -tunnelIdStart]
            set tunnel_id_end   [rsvpDestinationRange cget -tunnelIdEnd]
            
            set egress_ip_start [rsvpDestinationRange cget -fromIpAddress]
            set egress_ip_count [rsvpDestinationRange cget -rangeCount]
            
            keylset returnList tunnel_id.$rsvpTunnel $tunnel_id_start
            keylset returnList egress_ip.$rsvpTunnel $egress_ip_start
            
            if { [rsvpDestinationRange cget -behavior ] == $::rsvpIngress } {
                if {![rsvpDestinationRange getFirstSenderRange]} {
                    set ingress_ip_start [rsvpSenderRange cget -fromIpAddress]
                    set ingress_ip_count [rsvpSenderRange cget -rangeCount]
                    
                    set lsp_id_start [rsvpSenderRange cget -lspIdStart]
                    set lsp_id_end   [rsvpSenderRange cget -lspIdEnd]
                    
                    keylset returnList ingress_ip.$rsvpTunnel $ingress_ip_start
                    
                    set egress_ip    $egress_ip_start
                    set egressIpList [list $egress_ip]
                    for {set i 1} {$i < $egress_ip_count} {incr i} {
                        set egress_ip [::ixia::increment_ipv4_address_hltapi \
                                $egress_ip 0.0.0.1]
                        lappend egressIpList $egress_ip
                    }
                    
                    set ingress_ip    $ingress_ip_start
                    set ingressIpList [list $ingress_ip]
                    for {set i 1} {$i < $ingress_ip_count} {incr i} {
                        set ingress_ip [::ixia::increment_ipv4_address_hltapi \
                                $ingress_ip 0.0.0.1]
                        lappend ingressIpList $ingress_ip
                    }
                    if {$rsvpLabelList != "N/A"} {
                        foreach {rsvpElement} $rsvpLabelList {
                            catch {unset rsvpElemValues}
                            regsub "^Src: ((.)*):((.)*)/Dst: T((.)*):((.)*)$" \
                                    [lindex $rsvpElement 0] {\1 \3 \5 \7}     \
                                    rsvpElemValues
                            
                            if {[info exists rsvpElemValues]} {
                                set cond1 [expr [lsearch $ingressIpList  \
                                        [lindex $rsvpElemValues 0]] != -1]
                                
                                set cond2 [expr [lsearch $egressIpList   \
                                        [lindex $rsvpElemValues 2]] != -1]
                                
                                set cond3 [expr ($lsp_id_start <= [lindex      \
                                        $rsvpElemValues 1]) && ($lsp_id_end >= \
                                        [lindex  $rsvpElemValues 1])]
                                
                                set cond4 [expr ($tunnel_id_start <= [lindex   \
                                        $rsvpElemValues 3]) && ($tunnel_id_end \
                                        >= [lindex  $rsvpElemValues 3])]
                                
                                if {$cond1 && $cond2 && $cond3 && $cond4} {
                                    lappend rsvpReturnLabelList $rsvpElement
                                }
                            }
                        }
                    }
                }  
            }
        }
    }
    
    keylset returnList status              $::SUCCESS
    keylset returnList total_lsp_count     $total_lsp_count
    keylset returnList inbound_lsp_count   $inbound_lsp_count
    keylset returnList inbound_lsps        $inbound_lsp_count
    keylset returnList outbound_lsp_count  $outbound_lsp_count
    keylset returnList outbound_up_count   $outbound_up_count
    keylset returnList outbound_down_count $outbound_down_count
    keylset returnList label               $rsvpReturnLabelList
    
    return $returnList
}
