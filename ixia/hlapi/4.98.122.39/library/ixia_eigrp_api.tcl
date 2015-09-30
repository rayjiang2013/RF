##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_eigrp_api.tcl
#
# Purpose:
#     A script development library containing EIGRP APIs for test automation
#     with the Ixia chassis.
#
# Author:
#    Lavinia Raicea
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_eigrp_config
#    - emulation_eigrp_route_config
#    - emulation_eigrp_control
#    - emulation_eigrp_info
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     parseddashedargs.tcl , a library containing the proceDescr and
#     parsedashedargds.tcl.
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


proc ::ixia::emulation_eigrp_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_eigrp_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    set opt_args {
        -active_time                       RANGE 1-4294967295 
                                           DEFAULT 3
        -as_number                         RANGE 0-4294967295 
                                           DEFAULT 1
        -as_number_step                    RANGE 0-4294967295 
                                           DEFAULT 0
        -atm_encapsulation                 CHOICES VccMuxIPV4Routed 
                                           CHOICES VccMuxIPV6Routed
                                           CHOICES VccMuxBridgedEthernetFCS
                                           CHOICES VccMuxBridgedEthernetNoFCS
                                           CHOICES LLCRoutedCLIP
                                           CHOICES LLCBridgedEthernetFCS
                                           CHOICES LLCBridgedEthernetNoFCS 
                                           DEFAULT LLCBridgedEthernetFCS
        -bandwidth                         RANGE 10000-4294967295
                                           DEFAULT 10000
        -bfd_registration                  CHOICES 0 1 
                                           DEFAULT 0
        -count                             NUMERIC 
                                           DEFAULT 1
        -delay                             RANGE 0-4294967295 
                                           DEFAULT 0
        -discard_learned_routes            CHOICES 0 1
                                           DEFAULT 1
        -eigrp_major_version               RANGE 0-255 
                                           DEFAULT 1 
        -eigrp_minor_version               RANGE 0-255 
                                           DEFAULT 2
        -enable_piggyback                  CHOICES 0 1 
                                           DEFAULT 0
        -gre_ip_addr                       IPV4
        -gre_ip_addr_step                  IPV4 
                                           DEFAULT 0.0.1.0
        -gre_ip_prefix_length              RANGE 1-32 
                                           DEFAULT 24
        -gre_ipv6_addr                     IPV6
        -gre_ipv6_addr_step                IPV6 
                                           DEFAULT 0:0:0:1::0
        -gre_ipv6_prefix_length            RANGE 1-128 
                                           DEFAULT 64
        -gre_dst_ip_addr                   IP
        -gre_dst_ip_addr_step              IP
        -gre_checksum_enable               CHOICES 0 1 
                                           DEFAULT 0
        -gre_key_enable                    CHOICES 0 1 
                                           DEFAULT 0
        -gre_key_in                        RANGE 0-4294967295 
                                           DEFAULT 0
        -gre_key_in_step                   RANGE 0-4294967295 
                                           DEFAULT 0
        -gre_key_out                       RANGE 0-4294967295 
                                           DEFAULT 0
        -gre_key_out_step                  RANGE 0-4294967295 
                                           DEFAULT 0
        -gre_seq_enable                    CHOICES 0 1 
                                           DEFAULT 0
        -handle                            REGEXP ^::ixNet::OBJ-/vport:[0-9]+/protocols/eigrp/router:[0-9]+$
        -hello_interval                    RANGE 5-65535  
                                           DEFAULT 5
        -hold_time                         RANGE 15-65535 
                                           DEFAULT 15
        -interface_handle
        -intf_gw_ip_addr                   IPV4 
                                           DEFAULT 0.0.0.0
        -intf_gw_ip_addr_step              IPV4 
                                           DEFAULT 0.0.1.0
        -intf_gw_ipv6_addr                 IPV6
                                           DEFAULT 0::0
        -intf_gw_ipv6_addr_step            IPV6
                                           DEFAULT 0:0:0:1::0
        -intf_ip_addr                      IP
        -intf_ip_addr_step                 IP 
                                           DEFAULT 0.0.1.0
        -intf_ip_prefix_length             RANGE 1-32 
                                           DEFAULT 24
        -intf_ipv6_addr                    IPV6
        -intf_ipv6_addr_step               IPV6 
                                           DEFAULT 0:0:0:1::0
        -intf_ipv6_prefix_length           RANGE 1-128 
                                           DEFAULT 64
        -ios_major_version                 RANGE 0-255 
                                           DEFAULT 12
        -ios_minor_version                 RANGE 0-255 
                                           DEFAULT 3
        -ip_version                        CHOICES 4 6
                                           DEFAULT 4
        -k1                                RANGE 0-255 
                                           DEFAULT 1
        -k2                                RANGE 0-255 
                                           DEFAULT 0
        -k3                                RANGE 0-255 
                                           DEFAULT 1
        -k4                                RANGE 0-255 
                                           DEFAULT 0
        -k5                                RANGE 0-255 
                                           DEFAULT 0
        -load                              RANGE 0-255 
                                           DEFAULT 0
        -mac_address_init                  MAC
        -mac_address_step                  MAC
                                           DEFAULT 0000.0000.0001
        -max_tlv_per_pkt                   RANGE 0-255 
                                           DEFAULT 30
        -mode                              CHOICES create modify delete enable 
                                           CHOICES disable 
                                           DEFAULT create
        -mtu                               NUMERIC 
                                           DEFAULT 1500
        -override_existence_check          CHOICES 0 1
                                           DEFAULT 0
        -override_tracking                 CHOICES 0 1
                                           DEFAULT 0
        -port_handle                       REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -reliability                       RANGE 0-255 
                                           DEFAULT 255
        -reset                             FLAG
        -router_id                         IPV4 
                                           DEFAULT 100.0.0.1
        -router_id_step                    IPV4 
                                           DEFAULT 0.0.0.1
        -split_horizon                     CHOICES 0 1 
                                           DEFAULT 0
        -vlan                              CHOICES 0 1 
        -vlan_id                           RANGE 0-4095   
        -vlan_id_step                      RANGE 0-4096   
                                           DEFAULT 1
        -vlan_user_priority                RANGE 0-7      
                                           DEFAULT 0
        -vpi                               RANGE 0-255    
                                           DEFAULT 1
        -vci                               RANGE 32-65535 
                                           DEFAULT 32
        -vpi_step                          RANGE 0-255    
                                           DEFAULT 1
        -vci_step                          RANGE 0-65535  
                                           DEFAULT 1
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_eigrp_config $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_eigrp_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "EIGRP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}


proc ::ixia::emulation_eigrp_route_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_eigrp_route_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    set opt_args {
        -bandwidth              RANGE 10000-4294967295 
                                DEFAULT 10000
        -count                  RANGE 1-16777216 
                                DEFAULT 1
        -delay                  RANGE 0-4294967295
                                DEFAULT 0
        -dst_count              RANGE 0-255 
                                DEFAULT 90
        -enable_packing         CHOICES 0 1
                                DEFAULT 1
        -ext_flag               CHOICES candidate_default
                                CHOICES external_route
                                DEFAULT external_route
        -ext_metric             RANGE 0-4294967295 
                                DEFAULT 1
        -ext_originating_as     RANGE 0-4294967295 
                                DEFAULT 1
        -ext_protocol           CHOICES bgp connected egp
                                CHOICES eigrp hello idrp
                                CHOICES igrp isis ospf rip static
                                DEFAULT igrp
        -ext_route_tag          RANGE 0-4294967295 
                                DEFAULT 0
        -ext_source             IP
        -handle                 REGEXP ^::ixNet::OBJ-/vport:[0-9]+/protocols/eigrp/router:[0-9]+$
        -hop_count              RANGE 0-255 
                                DEFAULT 0
        -load                   RANGE 0-255 
                                DEFAULT 0
        -mode                   CHOICES create modify delete 
                                CHOICES enable disable
                                DEFAULT create
        -mtu                    RANGE 0-16777216 
                                DEFAULT 1500
        -next_hop               IP
        -next_hop_inside_step   IP
        -next_hop_outside_step  IP
        -num_prefixes           RANGE 1-16777216 
                                DEFAULT 1
        -prefix_inside_step     IP
        -prefix_length          RANGE 0-128
        -prefix_outside_step    IP
        -prefix_start           IP
        -reliability            RANGE 0-255 
                                DEFAULT 255
        -reset                  FLAG
        -route_handle           REGEXP ^::ixNet::OBJ-/vport:[0-9]+/protocols/eigrp/router:[0-9]+/routeRange:[0-9]+$
        -type                   CHOICES internal external 
                                DEFAULT internal
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_eigrp_route_config $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_eigrp_route_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "EIGRP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}


proc ::ixia::emulation_eigrp_control { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_eigrp_control $args\}]
        
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
        -mode          CHOICES start stop restart
    }
    set opt_args {
        -port_handle   REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixNetworkProtocolControl \
                "-protocol eigrp $args"  \
                "-protocol $man_args"    \
                $opt_args                ]
        
    } else {
        # set returnList [::ixia::ixprotocol_eigrp_control $args $man_args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "EIGRP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}


proc ::ixia::emulation_eigrp_info { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_eigrp_info $args\}]
        
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
        -mode          CHOICES aggregate_stats learned_info clear_stats
    }
    set opt_args {
        -port_handle   REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_eigrp_info $args $man_args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_eigrp_info $args $man_args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "EIGRP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}

