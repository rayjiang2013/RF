##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_bfd_api.tcl
#
# Purpose:
#     A script development library containing BFD APIs for test automation
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
#    - emulation_bfd_config
#    - emulation_bfd_session_config
#    - emulation_bfd_control
#    - emulation_bfd_info
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

proc ::ixia::emulation_bfd_config { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_bfd_config $args\}]
        
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
        -atm_encapsulation               CHOICES VccMuxIPV4Routed
                                         CHOICES VccMuxIPV6Routed
                                         CHOICES VccMuxBridgedEthernetFCS
                                         CHOICES VccMuxBridgedEthernetNoFCS
                                         CHOICES LLCRoutedCLIP
                                         CHOICES LLCBridgedEthernetFCS
                                         CHOICES LLCBridgedEthernetNoFCS
                                         DEFAULT LLCBridgedEthernetFCS
        -control_interval                NUMERIC
        -count                           NUMERIC
                                         DEFAULT 1
        -echo_rx_interval                RANGE 0-4294967295
                                         DEFAULT 0
        -echo_timeout                    RANGE 0-4294967295
                                         DEFAULT 1500
        -echo_tx_interval                RANGE 0-4294967295
                                         DEFAULT 0
        -enable_ctrl_plane_independent   CHOICES 0 1
                                         DEFAULT 0
        -enable_demand_mode              CHOICES 0 1
                                         DEFAULT 0
        -flap_tx_interval                RANGE 0-4294967295
                                         DEFAULT 0
        -gre_count                       NUMERIC
                                         DEFAULT 0
        -gre_ip_addr                     IPV4
        -gre_ip_addr_step                IPV4
                                         DEFAULT 0.0.1.0
        -gre_ip_addr_lstep               IPV4
        -gre_ip_addr_cstep               IPV4
        -gre_ip_prefix_length            RANGE   1-32
                                         DEFAULT 24
        -gre_ipv6_addr                   IPV6
        -gre_ipv6_addr_step              IPV6
                                         DEFAULT 0:0:0:1::0
        -gre_ipv6_addr_lstep             IPV6
        -gre_ipv6_addr_cstep             IPV6
        -gre_ipv6_prefix_length          RANGE   1-128
                                         DEFAULT 64
        -gre_dst_ip_addr                 IP
        -gre_dst_ip_addr_step            IP
        -gre_dst_ip_addr_lstep           IP
        -gre_dst_ip_addr_cstep           IP
        -gre_checksum_enable             CHOICES 0 1
                                         DEFAULT 0
        -gre_key_enable                  CHOICES 0 1
                                         DEFAULT 0
        -gre_key_in                      RANGE 0-4294967295
                                         DEFAULT 0
        -gre_key_in_step                 RANGE 0-4294967295
                                         DEFAULT 0
        -gre_key_out                     RANGE 0-4294967295
                                         DEFAULT 0
        -gre_key_out_step                RANGE 0-4294967295
                                         DEFAULT 0
        -gre_seq_enable                  CHOICES 0 1
                                         DEFAULT 0
        -gre_src_ip_addr_mode            CHOICES routed connected
                                         DEFAULT connected
        -handle
        -interface_handle
        -intf_count                      NUMERIC
                                         DEFAULT 1
        -intf_gw_ip_addr                 IPV4
                                         DEFAULT 0.0.0.0
        -intf_gw_ip_addr_step            IPV4
                                         DEFAULT 0.0.1.0
        -intf_ip_addr                    IP
        -intf_ip_addr_step               IP
                                         DEFAULT 0.0.1.0
        -intf_ip_prefix_length           RANGE   1-32
                                         DEFAULT 24
        -intf_ipv6_addr                  IPV6
        -intf_ipv6_addr_step             IPV6
                                         DEFAULT 0:0:0:1::0
        -intf_ipv6_prefix_length         RANGE   1-128
                                         DEFAULT 64
        -loopback_count                  NUMERIC
                                         DEFAULT 0
        -loopback_ip_addr                IPV4
        -loopback_ip_addr_step           IPV4
                                         DEFAULT 0.0.0.1
        -loopback_ip_addr_cstep          IPV4
        -loopback_ip_prefix_length       RANGE 0-128
                                         DEFAULT 24
        -loopback_ipv6_addr              IPV6
        -loopback_ipv6_addr_step         IPV6
                                         DEFAULT 0:0:0:1::0
        -loopback_ipv6_addr_cstep        IPV6
        -loopback_ipv6_prefix_length     RANGE 0-128
                                         DEFAULT 64
        -mac_address_init                MAC
                                         DEFAULT 0000.0000.0001
        -mac_address_step                MAC
                                         DEFAULT 0000.0000.0001
        -min_rx_interval                 RANGE 0-4294967295
                                         DEFAULT 1000
        -mode                            CHOICES create modify delete enable disable
                                         DEFAULT create
        -mtu                             NUMERIC
                                         DEFAULT 1500
        -multiplier                      RANGE 1-255
                                         DEFAULT 3
        -override_existence_check        CHOICES 0 1
                                         DEFAULT 0
        -override_tracking               CHOICES 0 1
                                         DEFAULT 0
        -pkts_per_control_interval       NUMERIC
        -poll_interval                   RANGE 0-4294967295
                                         DEFAULT 0
        -port_handle                     REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -reset                           FLAG
        -router_id                       IPV4
                                         DEFAULT 100.0.0.1
        -router_id_step                  IPV4
                                         DEFAULT 0.0.0.1
        -tx_interval                     RANGE 50-4294967295
                                         DEFAULT 1000
        -vlan                            CHOICES 0 1
                                         DEFAULT 0
        -vlan_id                         RANGE   0-4095
                                         DEFAULT 1
        -vlan_id_step                    RANGE 0-4096
                                         DEFAULT 1
        -vlan_user_priority              RANGE   0-7
                                         DEFAULT 0
        -vpi                             RANGE   0-255
                                         DEFAULT 1
        -vci                             RANGE   32-65535
                                         DEFAULT 32
        -vpi_step                        RANGE   0-255
                                         DEFAULT 1
        -vci_step                        RANGE   0-65535
                                         DEFAULT 1
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_bfd_config $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_bfd_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "BFD is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}

proc ::ixia::emulation_bfd_session_config { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_bfd_session_config $args\}]
        
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
        -count                        NUMERIC
                                      DEFAULT 1
        -enable_auto_choose_source    CHOICES 0 1
                                      DEFAULT 1
        -enable_learned_remote_disc   CHOICES 0 1
                                      DEFAULT 1
        -handle
        -ip_version                   CHOICES 4 6
                                      DEFAULT 4
        -local_disc                   RANGE 1-4294967295
                                      DEFAULT 1
        -local_disc_step              RANGE 1-4294967295
                                      DEFAULT 1
        -mode                         CHOICES create modify delete enable disable
                                      DEFAULT create
        -remote_disc                  RANGE 1-4294967295
                                      DEFAULT 1
        -remote_disc_step             RANGE 1-4294967295
                                      DEFAULT 1
        -remote_ip_addr               IP
        -remote_ip_addr_step          IP
        -session_handle
        -session_type                 CHOICES single_hop multi_hop
                                      DEFAULT single_hop
        -local_ip_addr                IP
        -local_ip_addr_step           IP
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_bfd_session_config $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_bfd_session_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "BFD is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}

proc ::ixia::emulation_bfd_control { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_bfd_control $args\}]
        
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
        set returnList [::ixia::ixnetwork_bfd_control $args $man_args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_bfd_control $args $man_args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "BFD is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}

proc ::ixia::emulation_bfd_info { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_bfd_info $args\}]
        
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
        set returnList [::ixia::ixnetwork_bfd_info $args $man_args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_bfd_info $args $man_args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "BFD is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}
