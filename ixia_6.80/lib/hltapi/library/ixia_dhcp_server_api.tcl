# Copyright © 2003-2009 by IXIA.
# All Rights Reserved.
#
# Name:
#    ixia_dhcp_server_api.tcl
#
# Purpose:
#    A script development library containing DHCP Server APIs for test 
#    automation with the Ixia chassis. 
#
# Author:
#    Lavinia Raicea
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#        emulation_dhcp_server_config
#        emulation_dhcp_server_control
#        emulation_dhcp_server_stats
#
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     parseddashedargs.tcl , a library containing the argument parsing 
#     procedures 
#
# Variables:
#    To be added
#
# Keywords:
#    To be defined
#
# Category:
#    To be defined
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


proc ::ixia::emulation_dhcp_server_config { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_dhcp_server_config $args\}]
        
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
        -count                       RANGE     1-100000
                                     DEFAULT   1
        -dhcp6_ia_type               CHOICES iana iata iapd iana_iapd
                                     DEFAULT iana
        -dhcp_ack_circuit_id         HEX       
        -dhcp_ack_cisco_server_id_override  IP  
                                            DEFAULT   0.0.0.0
        -dhcp_ack_link_selection            IP        
                                            DEFAULT   0.0.0.0
        -dhcp_ack_options                   CHOICES   0 1
                                            DEFAULT   0
        -dhcp_ack_remote_id                 HEX       
        -dhcp_ack_router_address            IP        
                                            DEFAULT   0.0.0.0
        -dhcp_ack_server_id_override        IP        
                                            DEFAULT   0.0.0.0
        -dhcp_ack_subnet_mask               IP        
                                            DEFAULT   0.0.0.0
        -dhcp_ack_time_offset               NUMERIC   
                                            DEFAULT   0
        -dhcp_ack_time_server_address       IP       
                                            DEFAULT   0.0.0.0
        -dhcp_ignore_mac                    MAC       
                                            DEFAULT   00:00:00:00:00:00
        -dhcp_ignore_mac_mask               MAC       
                                            DEFAULT   00:00:00:00:00:00
        -dhcp_mac_nak                       MAC       
                                            DEFAULT   00:00:00:00:00:00
        -dhcp_mac_nak_mask                  MAC       
                                            DEFAULT   00:00:00:00:00:00
        -dhcp_offer_circuit_id              ANY       
        -dhcp_offer_cisco_server_id_override IP 
                                            DEFAULT   0.0.0.0
        -dhcp_offer_link_selection          IP        
                                            DEFAULT   0.0.0.0
        -dhcp_offer_options                 CHOICES   0 1
                                            DEFAULT   0
        -dhcp_offer_remote_id               HEX       
        -dhcp_offer_router_address          IP        
                                            DEFAULT   0.0.0.0
		-dhcp_offer_router_address_step		IP
		-dhcp_offer_router_address_inside_step IP
        -dhcp_offer_server_id_override      IP      
                                            DEFAULT   0.0.0.0
        -dhcp_offer_subnet_mask             IP        
                                            DEFAULT   0.0.0.0
        -dhcp_offer_time_offset             NUMERIC   
                                            DEFAULT   0
        -dhcp_offer_time_server_address     IP     
                                            DEFAULT   0.0.0.0
        -encapsulation               CHOICES ETHERNET_II SAP SNAP
                                     CHOICES ethernet_ii ethernet_ii_vlan ethernet_ii_qinq 
                                     CHOICES vc_mux_ipv4_routed vc_mux_fcs vc_mux vc_mux_ipv6_routed llcsnap_routed llcsnap_fcs llcsnap llcsnap_ppp vc_mux_ppp
        -handle                      ANY       
        -ip_address                  IP 
        -ip_count                    NUMERIC
                                     DEFAULT   1
        -ip_dns1                     IP
        -ip_dns1_step                IP
        -ip_dns2                     IP
        -ip_dns2_step                IP
        -ip_gateway                  IP      
        -ip_gateway_inside_step      IP
        -ip_gateway_step             IP           
        -ip_prefix_length            RANGE     0-128
        -ip_prefix_step              ANY
        -ip_repeat                   NUMERIC   
                                     DEFAULT   1
        -ip_step                     IP
        -ip_inside_step              IP
        -ip_version                  CHOICES 4 6
                                     DEFAULT 4
        -ipaddress_count             RANGE     1-1000000
                                     DEFAULT   16000
        -ipaddress_increment         NUMERIC   
                                     DEFAULT   65536
        -ipaddress_pool              IP      
        -ipaddress_pool_step         IP     
        -ipaddress_pool_prefix_length   NUMERIC 
        -ipaddress_pool_prefix_step     NUMERIC
        -ipv6_gateway                IPV6
        -ipv6_gateway_step           IPV6
        -ipv6_gateway_inside_step    IPV6
        -lease_time                  RANGE     300-30000000
                                     DEFAULT   3600
        -lease_time_max              RANGE     300-30000000 DEFAULT 3600
        -local_mac                   MAC       
                                     DEFAULT   0000.0000.0001
        -local_mac_outer_step        MAC
                                     DEFAULT  0000.0001.0000
        -local_mac_step              MAC       
                                     DEFAULT   0000.0000.0001
        -local_mtu                   RANGE     500-9500
                                     DEFAULT   1500
        -mode                        CHOICES   create modify reset
                                     DEFAULT   create
        -ping_check                  CHOICES 0 1
                                     DEFAULT 0
        -ping_timeout                RANGE 1-100 DEFAULT 1
        -port_handle                 ANY       
        -pvc_incr_mode               CHOICES   vci vpi both
                                     DEFAULT   both
        -qinq_incr_mode              CHOICES   inner outer both
                                     DEFAULT   both
        -remote_mac                         MAC       
                                            DEFAULT   0000.0000.0001
        -single_address_pool         CHOICES 0 1 
                                     DEFAULT 0
        -spfc_mac_ipaddress_count           NUMERIC   
                                            DEFAULT   65536
        -spfc_mac_ipaddress_increment       NUMERIC  
                                            DEFAULT   1
        -spfc_mac_ipaddress_pool            IP        
        -spfc_mac_mask_pool                 MAC       
                                            DEFAULT   00:00:00:00:00:00
        -spfc_mac_pattern_pool              HEX       
                                            DEFAULT   00:00:00:00:00:00
        -vci                         RANGE 32-65535 
                                     DEFAULT 32
        -vci_count                   RANGE 1-65504
                                     DEFAULT 4063
        -vci_repeat                  RANGE 1-65504  
                                     DEFAULT 1
        -vci_step                    RANGE 0-65503  
                                     DEFAULT 1
        -vlan_ethertype              CHOICES   0x8100 0x88A8 0x9100 0x9200
                                     DEFAULT   0x8100
        -vlan_id                     RANGE     0-4095
        -vlan_id_count               RANGE     0-4095
                                     DEFAULT   1
        -vlan_id_count_inner         RANGE     0-4095
                                     DEFAULT   1
        -vlan_id_inner               RANGE     0-4095
        -vlan_id_repeat              NUMERIC   
                                     DEFAULT   1
        -vlan_id_repeat_inner        NUMERIC   
                                     DEFAULT   1
        -vlan_id_step                RANGE     0-4095
                                     DEFAULT   1
        -vlan_id_step_inner          RANGE     0-4095
                                     DEFAULT   1
        -vlan_id_inter_device_step   RANGE     0-4095
                                     DEFAULT   1
        -vlan_id_inner_inter_device_step RANGE     0-4095
                                     DEFAULT   1
        -vlan_user_priority          RANGE     0-7
                                     DEFAULT   0
        -vlan_user_priority_inner    RANGE     0-7
                                     DEFAULT   0
        -vpi                         RANGE 0-255
                                     DEFAULT 0
        -vpi_count                   RANGE 1-256
                                     DEFAULT 1
        -vpi_repeat                  RANGE 1-65535
                                     DEFAULT 1
        -vpi_step                    RANGE 0-255
                                     DEFAULT 1
        -functional_specification    CHOICES v4_compatible v4_v6_compatible
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args  
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_dhcp_server_config $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_dhcp_server_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "DHCP Server is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    
    return $returnList
}


proc ::ixia::emulation_dhcp_server_control { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_dhcp_server_control $args\}]
        
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
    set man_args {
        -action                      CHOICES abort abort_async renew reset collect
    }
    set opt_args {
        -dhcp_handle                 ANY
        -port_handle                 ANY
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args  -mandatory_args $man_args
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_dhcp_server_control $args $man_args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_dhcp_server_control $args $man_args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "DHCP Server is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    
    return $returnList
}


proc ::ixia::emulation_dhcp_server_stats { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_dhcp_server_stats $args\}]
        
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
    set man_args {
        -action                      CHOICES clear collect
    }
    set opt_args {
        -dhcp_handle                 ANY
        -port_handle                 ANY
        -ip_version                  CHOICES 4 6
                                     DEFAULT 4
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_dhcp_server_stats $args $man_args $opt_args]
        
    } else {
        # set returnList [::ixia::ixnetwork_dhcp_server_stats $args $man_args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "DHCP Server is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    
    return $returnList
}
