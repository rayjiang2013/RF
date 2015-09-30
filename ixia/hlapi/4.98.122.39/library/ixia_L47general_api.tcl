##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_L47general_api.tcl
#
# Purpose:
#
# Author:   Mircea Hasegan
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - L47_network
#    - L47_dut
#    - L47_client_mapping
#    - L47_server_mapping
#    - L47_test
#    - L47_stats
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

proc ::ixia::L47_network {args} {
    variable executeOnTclServer
        
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    variable temporary_fix_122311
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 == 0} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::L47_network $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set returnList [checkL47 none]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode               CHOICES add remove modify enable disable
    }
    
    set opt_args {
        -handle             ANY
        -property           CHOICES network network_pool router_pool dns
        -target             CHOICES client server
                            DEFAULT client
        -port_handle        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -grat_arp_enable    CHOICES 0 1
                            DEFAULT 0
        -mac_mapping_mode   CHOICES macip macport
                            DEFAULT macip
        -source_port_from               RANGE 1024-65535
                                        DEFAULT 1024
        -source_port_to                 RANGE 1024-65535
                                        DEFAULT 65535
        -emulated_router_gateway        IP
        -emulated_router_subnet         ANY
        -ip_type                        CHOICES ipv4 ipv6
        -np_range_type                  CHOICES ethernet dhcp pppoe ipsec
                                        DEFAULT ethernet
        -np_enable_stats                CHOICES 0 1
        -np_first_ip                    IP
        -np_first_mac                   ANY
                                        DEFAULT 00.C6.12.00.01.00
        -np_mac_incr_step               ANY
        -np_gateway                     IP
        -np_gateway_incr_step           IP
        -np_ip_count                    NUMERIC
                                        DEFAULT 100
        -np_ip_incr_step                IP
        -np_inner_vlan_enable           CHOICES 0 1
        -np_inner_vlan_id               NUMERIC
        -np_inner_vlan_count            NUMERIC
        -np_inner_vlan_incr_step        NUMERIC
        -np_inner_vlan_priority         NUMERIC
        -np_inner_vlan_unique_count     NUMERIC
        -np_mss_enable                  CHOICES 0 1
                                        DEFAULT 0  
        -np_mss                         NUMERIC
                                        DEFAULT 1460
        -np_network_mask                ANY
        -np_vlan_increment_mode         CHOICES inner_first outer_first
        -np_vlan_enable                 CHOICES 0 1
        -np_vlan_id                     NUMERIC
        -np_vlan_count                  NUMERIC
        -np_vlan_incr_step              NUMERIC
        -np_vlan_priority               NUMERIC
        -np_vlan_unique_count           NUMERIC
        -np_circuit_id                  SHIFT
        -np_circuit_id_group_size       NUMERIC
        -np_circuit_id_enable           CHOICES 0 1
        -np_enable_cid_byte_stream      CHOICES 0 1
        -np_enable_remote_id            CHOICES 0 1
        -np_enable_rid_byte_stream      CHOICES 0 1
        -np_enable_vendor_class_identifier      CHOICES 0 1
        -np_first_server_reply          CHOICES 0 1
        -np_first_relay_ip              ANY
        -np_max_outstanding_requests    NUMERIC
        -np_max_client_per_second       NUMERIC
        -np_num_relay_agents            NUMERIC
        -np_packet_forward_mode         CHOICES 0 1 2
        -np_remote_id                   SHIFT
        -np_ra_server_ip                IP
        -np_remote_id_group_size        NUMERIC
        -np_server_ip                   IP
        -np_timeout                     NUMERIC
        -np_vendor_class_identifier     ANY
        -np_relay_vlan_enable           CHOICES 0 1
        -np_relay_vlan_id               NUMERIC
        -np_relay_vlan_count            NUMERIC
        -np_relay_vlan_incr_step        NUMERIC
        -np_ah_esp_options              CHOICES ah esp ah_and_esp
        -np_dh_group                    CHOICES dh1 dh2 dh5 dh14 dh15 dh16
        -np_emulated_subnet             IP
        -np_emulated_subnet_mask        IP
        -np_emulated_hosts              NUMERIC
        -np_enable_pfs                  CHOICES 0 1
        -np_ike_mode                    CHOICES main aggressive
        -np_increment_by                IP
        -np_num_retries                 NUMERIC
        -np_protected_subnet            IP
        -np_protected_subnet_mask       IP
        -np_peer_public_ip              IP
        -np_pre_shared_key              ANY
        -np_phase1_hash_algorithm       CHOICES md5 sha1
        -np_phase1_encryption_algorithm CHOICES des 3des aes128 aes192 aes256
        -np_phase1_lifetime             NUMERIC
        -np_phase2_hash_algorithm       CHOICES md5 sha1
        -np_phase2_encryption_algorithm CHOICES none 3des aes128 aes192 aes256
        -np_phase2_lifetime             NUMERIC
        -np_pfs_group                   CHOICES dh1 dh2 dh5 dh14 dh15 dh16
        -np_retry_interval              NUMERIC
        -np_retry_delay                 NUMERIC
        -np_role                        CHOICES p2p_initiator p2p_responder
                                        CHOICES dut_initiator
        -np_ac_name                     ANY
        -np_ac_selection                CHOICES match_name match_service
                                        CHOICES match_first
        -np_auth_type                   CHOICES none pap chap pap_or_chap
        -np_auth_timeout                NUMERIC
        -np_auth_retries                NUMERIC
        -np_chap_name                   ANY
        -np_chap_secret                 ANY
        -np_enable_throttling           CHOICES 0 1
        -np_enable_redial               CHOICES 0 1
        -np_enable_echo_reply           CHOICES 0 1
        -np_enable_echo_request         CHOICES 0 1
        -np_echo_request_interval       NUMERIC
        -np_lcp_timeout                 NUMERIC
        -np_lcp_retries                 NUMERIC
        -np_max_outstanding_sessions    NUMERIC
        -np_mtu                         NUMERIC
        -np_ncp_timeout                 NUMERIC
        -np_ncp_retries                 NUMERIC
        -np_padi_timeout                NUMERIC
        -np_padr_timeout                NUMERIC
        -np_padi_retries                NUMERIC
        -np_padr_retries                NUMERIC
        -np_pap_user                    ANY
        -np_pap_password                ANY
        -np_redial_timeout              NUMERIC
        -np_redial_max                  NUMERIC
        -np_setup_rate                  NUMERIC
        -np_server_response_timeout     NUMERIC
        -np_service_name                ANY
        -rp_first_mac                   ANY
        -rp_first_ip                    IP
        -rp_network_mask                ANY
        -rp_ip_count                    NUMERIC
        -rp_vlan_enable                 CHOICES 0 1
        -rp_vlan_id                     NUMERIC
        -tcp_enable_congestion_notification     CHOICES 0 1
        -tcp_enable_timestamp           CHOICES 0 1
        -tcp_fin_timeout                NUMERIC
        -tcp_enable_rx_bw_limit         CHOICES 0 1
        -tcp_enable_tx_bw_limit         CHOICES 0 1
        -tcp_keep_alive_interval        NUMERIC
        -tcp_keep_alive_probes          NUMERIC
        -tcp_keep_alive_time            NUMERIC
        -tcp_receive_buffer_size        NUMERIC
        -tcp_retransmit_retries         NUMERIC
        -tcp_rx_bw_limit                NUMERIC
        -tcp_rx_bw_limit_unit           CHOICES mb kb
        -tcp_syn_ack_retries            NUMERIC
        -tcp_syn_retries                NUMERIC
        -tcp_transmit_buffer_size       NUMERIC
        -tcp_tx_bw_limit                NUMERIC
        -tcp_tx_bw_limit_unit           CHOICES mb kb
        -dns_enable                     CHOICES 0 1
        -dns_cache_timeout              NUMERIC
        -dns_server                     IP
        -dns_suffix                     ANY
    }  
    
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                        -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
            
    if {$mode == "add"} {
        if {![info exists property]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -property\
                    must be provided."
            return $returnList
        }
    } else {
        removeDefaultOptionVars $opt_args $args
        
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle\
                    must be provided."
            return $returnList
        }
        
        if {![info exists property]} {
            set property [::ixia::ixL47GetProperty $handle none]
        }
    }
    
    # Network options
    set nw_option_list [list   procName mode handle target port_handle        \
            mac_mapping_mode source_port_from source_port_to                  \
            emulated_router_gateway emulated_router_subnet                    \
            grat_arp_enable tcp_enable_congestion_notification                \
            tcp_enable_timestamp tcp_fin_timeout tcp_keep_alive_interval      \
            tcp_enable_tx_bw_limit tcp_enable_rx_bw_limit                     \
            tcp_keep_alive_probes                                             \
            tcp_keep_alive_time tcp_receive_buffer_size tcp_retransmit_retries\
            tcp_rx_bw_limit tcp_rx_bw_limit_unit tcp_syn_ack_retries          \
            tcp_syn_retries tcp_transmit_buffer_size tcp_tx_bw_limit               \
            tcp_tx_bw_limit_unit dns_enable dns_cache_timeout                 ]
    
    set nw_args [list]
    
    # Network_pool options (for range_type IP only)
    set np_option_list [list procName mode handle np_range_type               \
            np_enable_stats np_first_ip ip_type                               \
            np_first_mac np_mac_incr_step np_gateway np_gateway_incr_step     \
            np_ip_count np_ip_incr_step np_inner_vlan_enable np_inner_vlan_id \
            np_inner_vlan_count np_inner_vlan_incr_step np_inner_vlan_priority\
            np_inner_vlan_unique_count np_mss_enable np_mss np_network_mask   \
            np_vlan_increment_mode np_vlan_enable np_vlan_id np_vlan_count    \
            np_vlan_incr_step np_vlan_priority np_vlan_unique_count           ]
    
    set np_args [list]
    
    # Network_pool dhcp options (for range_type IP/DHCP)
    set npDHCP_option_list [list np_circuit_id np_circuit_id_group_size       \
            np_circuit_id_enable np_enable_cid_byte_stream np_enable_remote_id\
            np_enable_rid_byte_stream np_enable_vendor_class_identifier       \
            np_first_server_reply np_first_relay_ip                           \
            np_max_outstanding_requests np_max_client_per_second              \
            np_num_relay_agents np_packet_forward_mode np_remote_id           \
            np_ra_server_ip np_remote_id_group_size np_server_ip np_timeout   \
            np_vendor_class_identifier np_relay_vlan_enable np_relay_vlan_id  \
            np_relay_vlan_count np_relay_vlan_incr_step                       ]
    
    # Network_pool IPsec options (for range_type IP/IPsec)
    set npIPsec_option_list [list np_ah_esp_options np_dh_group               \
            np_emulated_subnet np_emulated_subnet_mask np_emulated_hosts      \
            np_enable_pfs np_ike_mode np_increment_by np_num_retries          \
            np_protected_subnet np_protected_subnet_mask np_peer_public_ip    \
            np_pre_shared_key np_phase1_hash_algorithm                        \
            np_phase1_encryption_algorithm np_phase1_lifetime                 \
            np_phase2_hash_algorithm np_phase2_encryption_algorithm           \
            np_phase2_lifetime np_pfs_group np_retry_interval                 \
            np_retry_delay np_role                                            ]
    
    # Network_pool PPPoE options (for range_type IP/PPPoE)
    set npPPPoE_option_list [list np_ac_name np_ac_selection np_auth_type     \
            np_auth_timeout np_auth_retries np_chap_name np_chap_secret       \
            np_enable_throttling np_enable_redial np_enable_echo_reply        \
            np_enable_echo_request np_echo_request_interval np_lcp_timeout    \
            np_lcp_retries np_lcp_term_timeout np_lcp_term_retries            \
            np_max_outstanding_sessions np_mtu np_ncp_timeout np_ncp_retries  \
            np_padi_timeout np_padr_timeout np_padi_retries np_padr_retries   \
            np_pap_user np_pap_password np_redial_timeout np_redial_max       \
            np_setup_rate np_server_response_timeout np_service_name          ]
    
    # Router_pool
    set rp_option_list [list procName mode handle rp_first_mac ip_type       \
            rp_first_ip rp_ip_count rp_vlan_enable rp_vlan_id rp_network_mask]
    
    set rp_args [list]
    
    # DNS
    set dns_option_list [list procName mode handle dns_server dns_suffix]
    
    set dns_args [list]
    
    if {$mode == "add"} {
        switch -- $np_range_type {
            ethernet {
            }
            dhcp {
                set np_option_list [join [lappend np_option_list $npDHCP_option_list]]
            }
            pppoe {
                set np_option_list [join [lappend np_option_list $npPPPoE_option_list]]
            }
            ipsec {
                set np_option_list [join [lappend np_option_list $npIPsec_option_list]]
            }
        }
    } elseif {$mode == "modify"} {
        set np_option_list [join [lappend np_option_list $npDHCP_option_list]]
        set np_option_list [join [lappend np_option_list $npPPPoE_option_list]]
        set np_option_list [join [lappend np_option_list $npIPsec_option_list]]
    }
    
    set option_variables "nw_option_list nw_args np_option_list np_args     \
        rp_option_list rp_args dns_option_list dns_args"
    
    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                lappend $property_args "[set $item]"
            }
        }
    }
    
    switch -- $property {
        network {
            set returnList [eval [format "%s %s" ::ixia::ixL47Network \
                    $nw_args]]
            return $returnList
        }
        network_pool {
            if {[info exists np_first_ip]} {
                if {[ixL47GetIpType np_first_ip np_args ip_type]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument \
                            -np_first_ip is not a valid $ip_type address."
                    return $returnList
                }
            }
            set returnList [eval [format "%s %s" ::ixia::ixL47Range $np_args]]
            return $returnList
        }
        router_pool {
            if {[info exists rp_first_ip]} {
                if {[ixL47GetIpType rp_first_ip rp_args ip_type]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument \
                            -rp_first_ip is not a valid $ip_type address."
                    return $returnList
                }
            }
            set returnList [eval [format "%s %s" ::ixia::ixL47PoolAddr \
                    $rp_args]]
            return $returnList
        }
        dns {
            set returnList [eval [format "%s %s" ::ixia::ixL47Dns $dns_args]]
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -property does\
                    not have a valid value."
            return $returnList
        }
    }
}


proc ::ixia::L47_dut {args} {
    variable executeOnTclServer
  
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    variable temporary_fix_122311
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 == 0} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::L47_dut $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set returnList [checkL47 none]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode               CHOICES add remove modify
    }
    
    set opt_args {
        -handle                         ANY
        -enable_direct_server_return    CHOICES 0 1
        -ip_address                     ANY
        -type                           CHOICES external slb firewall
        -server_network                 ANY
    }  
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                        -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    if {$mode != "add"} {
        ::ixia::removeDefaultOptionVars $opt_args $args
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle\
                    must be provided."
            return $returnList
        }
    }
    
    set dut_option_list [list procName mode handle protocol \
            enable_direct_server_return   ip_address  server_network \
            type]
    
    set dut_args [list]
    
    foreach item $dut_option_list {
        if {[info exists $item]} {
            lappend dut_args "-$item"
            lappend dut_args "[set $item]"
        }
    }
    set returnList [eval [format "%s %s" ::ixia::ixL47Dut $dut_args]]
    return $returnList
}


proc ::ixia::L47_client_mapping {args} {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args

    variable temporary_fix_122311
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 == 0} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::L47_client_mapping $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set returnList [checkL47 none]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
        
    # Arguments
    set mandatory_args {
        -mode        CHOICES add remove modify enable disable
    }
    
    set opt_args {
        -handle                      ANY
        -agent_handle                ANY
        -client_network_handle       ANY
        -client_traffic_handle       ANY
        -iterations                  NUMERIC
                                     DEFAULT 1
        -objective_type              CHOICES na users connections crate trate
                                     CHOICES tputmb tputkb sessions
                                     DEFAULT na
        -objective_value             NUMERIC
        -offline_time                NUMERIC
                                     DEFAULT 0
        -port_map_policy             CHOICES pairs mesh
                                     DEFAULT pairs
        -ramp_down_time              NUMERIC
                                     DEFAULT 20
        -ramp_up_type                CHOICES users_per_second max_pending_users
                                     DEFAULT users_per_second
        -ramp_up_value               NUMERIC
        -ramp_up_interval            NUMERIC
        -standby_time                RANGE 0-3600000
                                     DEFAULT 0
        -sustain_time                RANGE 0-3600000
                                     DEFAULT 0
        -total_time                  NUMERIC
                                     DEFAULT 60
        -objective_type_for_activity CHOICES na users connections crate trate
                                     CHOICES tputmb tputkb sessions
        -objective_value_for_activity       NUMERIC
        -port_map_for_activity       CHOICES pairs mesh
                                     DEFAULT pairs
    }
    
    
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                        -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    if {$mode != "add"} {
        ::ixia::removeDefaultOptionVars $opt_args $args
        
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle\
                    must be provided."
            return $returnList
        }
    }
    
    set target client
    
    # Mapping parameters
    set map_option_list  [list procName mode handle                        \
            agent_handle client_network_handle client_traffic_handle       \
            iterations objective_type objective_value offline_time         \
            port_map_policy ramp_down_time ramp_up_type                    \
            ramp_up_value ramp_up_interval standby_time sustain_time       \
            total_time objective_type_for_activity                         \
            objective_value_for_activity port_map_for_activity target      ]
    
    set map_args [list]
    
    # Dut parameters
  
    foreach item $map_option_list {
        if {[info exists $item]} {
            lappend $map_args "-$item"
            lappend $map_args "[set $item]"
        }
    }
    
    set returnList [eval [format "%s %s" ::ixia::ixL47TrafficNetworkMapping \
            [set $map_args]]]
    return $returnList
}


proc ::ixia::L47_server_mapping {args} {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    variable temporary_fix_122311
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 == 0} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::L47_server_mapping $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set returnList [checkL47 none]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode        CHOICES add remove modify enable disable
    }
    
    set opt_args {
        -handle                      ANY
        -server_network_handle       ANY
        -server_traffic_handle       ANY
        -iterations                  NUMERIC
                                     DEFAULT 1
        -match_client_total_time     CHOICES 0 1
                                     DEFAULT 1
        -offline_time                NUMERIC
                                     DEFAULT 0
        -standby_time                RANGE 0-3600000
                                     DEFAULT 0
        -sustain_time                RANGE 0-3600000
                                     DEFAULT 0
        -total_time                  NUMERIC
                                     DEFAULT 60
    }
    
    

    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                    -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    if {$mode != "add"} {
        ::ixia::removeDefaultOptionVars $opt_args $args
        
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle\
                    must be provided."
            return $returnList
        }
    }
    
    set target server
    
    # Mapping parameters
    set map_option_list  [list procName mode handle                        \
            server_network_handle server_traffic_handle                    \
            iterations match_client_total_time                             \
            offline_time standby_time sustain_time total_time target       ]
    
    set map_args [list]
    
    # Dut parameters
    
    foreach item $map_option_list {
        if {[info exists $item]} {
            lappend $map_args "-$item"
            lappend $map_args "[set $item]"
        }
    }
    
    set returnList [eval [format "%s %s" ::ixia::ixL47TrafficNetworkMapping \
            [set $map_args]]]
    return $returnList
}


proc ::ixia::L47_test {args} {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    variable temporary_fix_122311
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 == 0} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::L47_test $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set protocol FTP
    set returnList [checkL47 none]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode        CHOICES add modify start
    }
    
    set opt_args {
        -handle                         ANY
        -map_handle                     ANY
        -force_ownership_enable         CHOICES 0 1
                                        DEFAULT 0
        -release_config_afterrun_enable CHOICES 0 1
                                        DEFAULT 0
        -reset_ports_enable             CHOICES 0 1
                                        DEFAULT 0
        -stats_required                 CHOICES 0 1
                                        DEFAULT 1
        -results_dir_enable             CHOICES 0 1
                                        DEFAULT 0
        -results_dir                    ANY
    }
    set args [::ixia::escapeBackslash $args results_dir]
    
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                    -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }    
    
    # check to see if user created the mapping
    if {$mode == "add"} {
        if {![info exists map_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -map_handle must be provided."
            return $returnList
        }
    }
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
        
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle must be provided."
            return $returnList
        }
    }
    
    set control_list  [list procName mode handle map_handle dut_handle \
            stats_handle force_ownership_enable release_config_afterrun_enable\
            reset_ports_enable stats_required results_dir_enable results_dir \
            protocol ]
    
    set control_args [list]
    set option_variables "control_list control_args"
    
    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                lappend $property_args "[set $item]"
            }
        }
    }
    set returnList [eval [format "%s %s" ::ixia::ixL47Control \
            $control_args]]
    return $returnList
    
}


proc ::ixia::L47_stats {args} {
    variable executeOnTclServer
	
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    variable temporary_fix_122311
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 == 0} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::L47_stats $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    ::ixia::utrackerLog $procName $args

    set returnList [checkIxLoad none]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    append args " -procName $procName "
   
    return [eval [format "%s %s" ::ixia::ixL47Statistics $args]]       
}
