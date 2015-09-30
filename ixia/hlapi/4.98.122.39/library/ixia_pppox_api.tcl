##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved
#
# Name:
#    ixia_pppox_api.tcl
#
# Purpose:
#    A script development library containing PPPoX APIs for test automation
#    with the Ixia chassis.
#
# Author:
#    Deepak Jain
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#    - pppox_config
#    - pppox_control
#    - pppox_stats
#
# Requirements:
#    parseddashedargs.tcl
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


proc ::ixia::pppox_config { args } {
    variable emulation_handles_array
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
                \{::ixia::pppox_config $args\}]

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
    set mandatory_args {
        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -protocol       CHOICES pppoa pppoeoa pppoe
        -encap          CHOICES ethernet_ii ethernet_ii_vlan ethernet_ii_qinq vc_mux vc_mux_routed vc_mux_nofcs llcsnap llcsnap_routed llcsnap_nofcs
        -num_sessions   RANGE   1-32000
    }

    set optional_args {
        -address_per_vlan               RANGE 1-1000000000
                                        DEFAULT 1
        -address_per_svlan              RANGE 1-1000000000
                                        DEFAULT 1
        -ac_select_list                 KEYLIST
                                        DEFAULT ""
        -ac_select_mode                 CHOICES first_responding
                                        CHOICES ac_mac ac_name service_name
                                        DEFAULT first_responding
        -auth_mode                      CHOICES none pap chap pap_or_chap
                                        DEFAULT none
        -auth_req_timeout               RANGE   1-65535
                                        DEFAULT 5
        -config_req_timeout             RANGE   1-120
                                        DEFAULT 5
        -echo_req                       RANGE   0-1
                                        DEFAULT 0
        -echo_rsp                       RANGE   0-1
                                        DEFAULT 1
        -enable_setup_throttling        CHOICES 0 1
                                        DEFAULT 0
        -ip_cp                          CHOICES ipv4_cp ipv6_cp dual_stack
                                        DEFAULT ipv4_cp
        -ipcp_req_timeout               RANGE   1-120
                                        DEFAULT 5
        -local_magic                    RANGE   0-1
                                        DEFAULT 1
        -max_auth_req                   RANGE   1-65535
                                        DEFAULT 10
        -max_padi_req                   RANGE   1-65535
                                        DEFAULT 10
        -max_padr_req                   RANGE   1-65535
                                        DEFAULT 10
        -max_terminate_req              RANGE   1-65535
                                        DEFAULT 10
        -padi_req_timeout               RANGE   1-65535
                                        DEFAULT 5
        -padr_req_timeout               RANGE   1-65535
                                        DEFAULT 5
        -password                       ANY
                                        DEFAULT ""
        -password_wildcard              RANGE   0-1
                                        DEFAULT 0
        -pvc_incr_mode                  CHOICES vpi vci both
                                        DEFAULT vci
        -qinq_incr_mode                 CHOICES inner outer both
                                        DEFAULT both
        -term_req_timeout               RANGE   1-65535
                                        DEFAULT 5
        -username                       ANY
                                        DEFAULT ""
        -username_wildcard              RANGE   0-1
                                        DEFAULT 0
        -vci                            RANGE   1-65535
                                        DEFAULT 32
        -vci_step                       RANGE   1-65534
                                        DEFAULT 1
        -vlan_id                        RANGE   0-4094
                                        DEFAULT 1
        -vlan_id_count                  RANGE   0-4094
                                        DEFAULT 4094
        -vlan_id_outer                  RANGE   0-4094
                                        DEFAULT 1
        -vlan_id_outer_count            RANGE   0-4094
                                        DEFAULT 4094
        -vlan_id_outer_step             RANGE   0-4094
                                        DEFAULT 1
        -vlan_id_step                   RANGE   0-4094
                                        DEFAULT 1
        -vlan_user_priority             RANGE   0-7
                                        DEFAULT 0
        -vlan_user_priority_outer       RANGE   0-7
                                        DEFAULT 0
        -vlan_user_priority_count       RANGE   1-8
                                        DEFAULT 8
        -vlan_user_priority_step        RANGE   1-7
                                        DEFAULT 1
        -vpi                            RANGE   0-255
                                        DEFAULT 0
        -vpi_step                       RANGE   1-255
                                        DEFAULT 1
        -vpi_count                      RANGE   1-256
                                        DEFAULT 1
        -wildcard_pound_end             REGEXP ^[0-9]{1,5}$
                                        DEFAULT 0
        -wildcard_pound_start           REGEXP ^[0-9]{1,5}$
                                        DEFAULT 0
        -wildcard_question_end          REGEXP ^[0-9]{1,5}$
                                        DEFAULT 0
        -wildcard_question_start        REGEXP ^[0-9]{1,5}$
                                        DEFAULT 0
        -ac_name                        ANY
        -agent_circuit_id               ANY
        -agent_remote_id                ANY
        -domain_group_map               ANY
        -enable_multicast               CHOICES 0 1
                                        DEFAULT 0
        -enable_throttling              CHOICES 0 1
                                        DEFAULT 0
        -group_ip_count                 RANGE   1-1000
                                        DEFAULT 1
        -group_ip_step                  IP
                                        DEFAULT 0.0.0.1
        -igmp_version                   CHOICES IGMPv2 IGMPv3
                                        DEFAULT IGMPv2
        -intermediate_agent             CHOICES 0 1
                                        DEFAULT 0
        -ipv6_pool_addr_prefix_len      NUMERIC
                                        DEFAULT 64
        -ipv6_pool_prefix               ANY
                                        DEFAULT 0::
        -ipv6_pool_prefix_len           NUMERIC
                                        DEFAULT 48
        -is_last_subport                CHOICES 0 1
                                        DEFAULT 1
        -join_leaves_per_second         RANGE   1-100
                                        DEFAULT 10
        -l4_dst_port                    RANGE   1-65535
                                        DEFAULT 1
        -l4_flow_number                 RANGE   1-65535
                                        DEFAULT 1
        -l4_flow_type                   CHOICES none tcp udp tcp_udp
                                        DEFAULT none
        -l4_flow_variant                CHOICES source destination
                                        DEFAULT source
        -l4_src_port                    RANGE   1-65535
                                        DEFAULT 1
        -mc_enable_general_query        CHOICES 0 1
                                        DEFAULT 1
        -mc_enable_group_specific_query CHOICES 0 1
                                        DEFAULT 1
        -mc_enable_immediate_response   CHOICES 0 1
                                        DEFAULT 0
        -mc_enable_packing              CHOICES 0 1
                                        DEFAULT 0
        -mc_enable_router_alert         CHOICES 0 1
                                        DEFAULT 0
        -mc_enable_suppress_reports     CHOICES 0 1
                                        DEFAULT 0
        -mc_enable_unsolicited          CHOICES 0 1
                                        DEFAULT 0
        -mc_group_id                    ANY
        -mc_report_frequency            RANGE   5-120
                                        DEFAULT 120
        -padi_include_tag               CHOICES 0 1
        -pado_include_tag               CHOICES 0 1
        -padr_include_tag               CHOICES 0 1
        -pads_include_tag               CHOICES 0 1
        -port_role                      CHOICES access network
                                        DEFAULT access
        -ppp_local_ip                   IPV4
        -ppp_local_ip_step              IPV4
        -ppp_local_iid                  ANY
                                        DEFAULT {00 00 00 00 00 00 00 00}
        -ppp_peer_iid                   ANY
                                        DEFAULT {00 00 00 00 00 00 00 00}
        -ppp_peer_ip                    IPV4
        -ppp_peer_ip_step               IPV4
        -ppp_local_mode                 CHOICES local_only local_may peer_only
                                        DEFAULT peer_only
        -ppp_peer_mode                  CHOICES local_only local_may peer_only
                                        DEFAULT peer_only
        -redial                         CHOICES 0 1
                                        DEFAULT 1
        -service_name                   ANY
                                        DEFAULT ""
        -service_type                   CHOICES any name
                                        DEFAULT any
        -start_group_ip                 IP
                                        DEFAULT 225.0.0.1
        -switch_duration                RANGE   100-1500
                                        DEFAULT 100
        -watch_duration                 RANGE   5-600
                                        DEFAULT 10
        -enable_delete_config           CHOICES 0 1
                                        DEFAULT 0
        -flap_repeat_count              RANGE 0-65535
                                        DEFAULT 0
        -flap_rate                      RANGE 1-300
                                        DEFAULT 10
        -hold_time                      RANGE 0-65535
                                        DEFAULT 0
        -cool_off_time                  RANGE 0-65535
                                        DEFAULT 0 }

    set optional_args_ixnetwork {
        -attempt_rate                                   RANGE   1-1000
                                                        DEFAULT 100
        -addr_count_per_vci                             RANGE 1-65535
                                                        DEFAULT 1
        -addr_count_per_vpi                             RANGE 1-65535
                                                        DEFAULT 1
        -dhcpv6pd_type                                  CHOICES client server
                                                        DEFAULT client
        -disconnect_rate                                RANGE   1-1000
        -dhcp6_pd_server_range_dns_domain_search_list   ANY
        -echo_req_interval                              RANGE   1-3600
                                                        DEFAULT 60
        -dhcp6_pd_server_range_first_dns_server         IP
        -hosts_range_ip_outer_prefix                    NUMERIC
                                                        DEFAULT 64
        -hosts_range_ip_prefix_addr                     IP
        -dhcp6_pd_server_range_second_dns_server        IP
        -dhcp6_pd_server_range_subnet_prefix            NUMERIC
        -dhcp6_pd_server_range_start_pool_address       IP
        -desired_mru_rate                               NUMERIC   
                                                        DEFAULT 1492
        -enable_mru_negotiation                         CHOICES 0 1
        -enable_max_payload                             CHOICES 0 1
        -max_payload                                    NUMERIC   
                                                        DEFAULT 1492
        -lease_time_max                                 RANGE   300-30000000
                                                        DEFAULT 864000
        -lease_time                                     RANGE   300-30000000
                                                        DEFAULT 864000
        -handle                                         ANY
        -mac_addr                                       ANY
        -mac_addr_step
        -max_outstanding                                RANGE   1-1000
                                                        DEFAULT 1000
        -vci_count                                      RANGE   1-65504
                                                        DEFAULT 1
        -redial_max                                     RANGE 1-255
                                                        DEFAULT 20
        -redial_timeout                                 RANGE   1-65535
                                                        DEFAULT 10
        -mode                                           CHOICES add modify remove
                                                        DEFAULT add
        -max_configure_req                              RANGE   1-255
                                                        DEFAULT 10
        -max_ipcp_req                                   RANGE   1-255
                                                        DEFAULT 10
        -enable_server_signal_loop_id                   CHOICES 0 1
                                                        DEFAULT 0
        -enable_client_signal_loop_id                   CHOICES 0 1
                                                        DEFAULT 0
        -enable_server_signal_loop_char                 CHOICES 0 1
                                                        DEFAULT 0
        -enable_client_signal_loop_char                 CHOICES 0 1
                                                        DEFAULT 0
        -actual_rate_upstream                           RANGE   1-65535
                                                        DEFAULT 10
        -actual_rate_downstream                         RANGE   1-65535
                                                        DEFAULT 10
        -enable_server_signal_iwf                       CHOICES 0 1
                                                        DEFAULT 0
        -enable_client_signal_iwf                       CHOICES 0 1
                                                        DEFAULT 0
        -enable_server_signal_loop_encap                CHOICES 0 1
                                                        DEFAULT 0
        -enable_client_signal_loop_encap                CHOICES 0 1
                                                        DEFAULT 0
        -data_link                                      CHOICES atm_aal5 ethernet
                                                        DEFAULT ethernet
        -intermediate_agent_encap1                      CHOICES na untagged_eth single_tagged_eth
                                                        DEFAULT untagged_eth
        -intermediate_agent_encap2                      CHOICES na pppoa_llc pppoa_null ipoa_llc
                                                        CHOICES ipoa_null eth_aal5_llc_fcs
                                                        CHOICES eth_aal5_llc_no_fcs eth_aal5_null_fcs
                                                        CHOICES eth_aal5_null_no_fcs
                                                        DEFAULT na
        -dhcpv6_hosts_enable                            CHOICES 0 1
                                                        DEFAULT 0
        -hosts_range_count                              RANGE   1-1000000
                                                        DEFAULT 1
        -hosts_range_eui_increment                      REGEXP  ^([A-Fa-f0-9]{2,2}[ .:]){7,7}([A-Fa-f0-9]{2,2})$
                                                        DEFAULT {00 00 00 00 00 00 00 01}
        -hosts_range_first_eui                          REGEXP  ^([A-Fa-f0-9]{2,2}[ .:]){7,7}([A-Fa-f0-9]{2,2})$
                                                        DEFAULT {00 00 00 00 00 00 11 11}
        -hosts_range_ip_prefix                          RANGE   64-128
                                                        DEFAULT 64
        -hosts_range_subnet_count                       RANGE   1-32
                                                        DEFAULT 1
        -dhcp6_pd_client_range_duid_enterprise_id       RANGE   1-2147483647
                                                        DEFAULT 10
        -dhcp6_pd_client_range_duid_type                CHOICES duid_en duid_llt duid_ll
                                                        DEFAULT duid_llt
        -dhcp6_pd_client_range_duid_vendor_id           RANGE   1-2147483647
                                                        DEFAULT 10
        -dhcp6_pd_client_range_duid_vendor_id_increment RANGE   1-2147483647
                                                        DEFAULT 1
        -dhcp6_pd_client_range_ia_id                    RANGE   1-2147483647
                                                        DEFAULT 10
        -dhcp6_pd_client_range_ia_id_increment          RANGE   1-2147483647
                                                        DEFAULT 1
        -dhcp6_pd_client_range_ia_t1                    RANGE   0-2147483647
                                                        DEFAULT 302400
        -dhcp6_pd_client_range_ia_t2                    RANGE   0-2147483647
                                                        DEFAULT 483840
        -dhcp6_pd_client_range_ia_type                  CHOICES iapd
                                                        DEFAULT iapd
        -dhcp6_pd_client_range_param_request_list       NUMERIC
                                                        DEFAULT {2 7 23 24}
        -dhcp6_pd_client_range_renew_timer              RANGE   0-1000000000
                                                        DEFAULT 0
        -dhcp6_pd_client_range_use_vendor_class_id      CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_pd_client_range_vendor_class_id          ANY
                                                        DEFAULT "Ixia DHCP Client"
        -dhcp6_pgdata_max_outstanding_releases          RANGE   1-100000
                                                        DEFAULT 500
        -dhcp6_pgdata_max_outstanding_requests          RANGE   1-100000
                                                        DEFAULT 20
        -dhcp6_pgdata_override_global_setup_rate        CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_pgdata_override_global_teardown_rate     CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_pgdata_setup_rate_increment              RANGE   0-100000
                                                        DEFAULT 0
        -dhcp6_pgdata_setup_rate_initial                RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_pgdata_setup_rate_max                    RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_pgdata_teardown_rate_increment           RANGE   0-100000
                                                        DEFAULT 50
        -dhcp6_pgdata_teardown_rate_initial             RANGE   1-100000
                                                        DEFAULT 50
        -dhcp6_pgdata_teardown_rate_max                 RANGE   1-100000
                                                        DEFAULT 500
        -ipv6_global_address_mode                       CHOICES icmpv6 dhcpv6_pd
                                                        DEFAULT icmpv6
        -dhcp6_global_echo_ia_info                      CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_global_reb_max_rt                        RANGE   1-10000
                                                        DEFAULT 500
        -dhcp6_global_reb_timeout                       RANGE   1-100
                                                        DEFAULT 10
        -dhcp6_global_rel_max_rc                        RANGE   1-100
                                                        DEFAULT 5
        -dhcp6_global_rel_timeout                       RANGE   1-100
                                                        DEFAULT 1
        -dhcp6_global_ren_max_rt                        RANGE   1-10000
                                                        DEFAULT 600
        -dhcp6_global_ren_timeout                       RANGE   1-100
                                                        DEFAULT 10
        -dhcp6_global_req_max_rc                        RANGE   1-100
                                                        DEFAULT 10
        -dhcp6_global_req_max_rt                        RANGE   1-10000
                                                        DEFAULT 30
        -dhcp6_global_req_timeout                       RANGE   1-100
                                                        DEFAULT 1
        -dhcp6_global_sol_max_rc                        RANGE   1-100
                                                        DEFAULT 3
        -dhcp6_global_sol_max_rt                        RANGE   1-10000
                                                        DEFAULT 120
        -dhcp6_global_sol_timeout                       RANGE   1-100
                                                        DEFAULT 4
        -dhcp6_global_max_outstanding_releases          RANGE   1-100000
                                                        DEFAULT 500
        -dhcp6_global_max_outstanding_requests          RANGE   1-100000
                                                        DEFAULT 20
        -dhcp6_global_setup_rate_increment              ANY
                                                        DEFAULT 0
        -dhcp6_global_setup_rate_initial                RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_global_setup_rate_max                    RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_global_teardown_rate_increment           ANY
                                                        DEFAULT 50
        -dhcp6_global_teardown_rate_initial             RANGE   1-100000
                                                        DEFAULT 50
        -dhcp6_global_teardown_rate_max                 RANGE   1-100000
                                                        DEFAULT 500
        -dhcp6_global_wait_for_completion               CHOICES 0 1
                                                        DEFAULT 0
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        append optional_args $optional_args_ixnetwork
        set returnList [::ixia::ixnetwork_pppox_config $args $mandatory_args \
                $optional_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxAccess API is not supported"
        return $returnList
    }
}


proc ::ixia::pppox_control { args } {
    variable executeOnTclServer
    variable emulation_handles_array
    variable pppox_accumulative
    variable pending_operations
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
                \{::ixia::pppox_control $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_pppox_control $args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxAccess API is not supported"
        return $returnList
    }
}


proc ::ixia::pppox_stats { args } {
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
                \{::ixia::pppox_stats $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    ::ixia::utrackerLog $procName $args

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_pppox_stats $args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxAccess API is not supported"
        return $returnList
    }
}
