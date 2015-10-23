##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved
#
# Name:
#    ixia_l2tpox_api.tcl
#
# Purpose:
#     A script development library containing L2TPoX APIs for test automation
#     with the Ixia chassis.
#
# Author:
#    Deepak Jain
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#    - l2tp_config
#    - l2tp_control
#    - l2tp_stats
#
# Requirements:
#     parseddashedargs.tcl
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


proc ::ixia::l2tp_config { args } {
    variable new_ixnetwork_api
    variable emulation_handles_array
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
                \{::ixia::l2tp_config $args\}]
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
        -l2_encap      CHOICES atm_vc_mux atm_snap atm_vc_mux_ethernet_ii
                       CHOICES atm_snap_ethernet_ii atm_vc_mux_ppp atm_snap_ppp
                       CHOICES ethernet_ii ethernet_ii_vlan ethernet_ii_qinq
        -l2tp_dst_addr IP
        -l2tp_src_addr IP
        -mode          CHOICES lac lns
        -port_handle   REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -num_tunnels   RANGE   0-32000
    }
    
    set common_opt_args {
        -address_per_vlan           RANGE       1-1000000000
                                    DEFAULT     1
        -attempt_rate               RANGE       1-1000
                                    DEFAULT     200
        -auth_mode                  CHOICES     none pap chap pap_or_chap
                                    DEFAULT     none
        -auth_req_timeout           RANGE       1-65535
                                    DEFAULT     5
        -avp_framing_type           NUMERIC
        -avp_hide                   FLAG
        -avp_rx_connect_speed       NUMERIC
                                    DEFAULT     128
        -avp_tx_connect_speed       NUMERIC
        -config_req_timeout         RANGE       1-120
                                    DEFAULT     5
        -ctrl_chksum                FLAG
        -ctrl_retries               RANGE       1-100
                                    DEFAULT     5
        -data_chksum                FLAG
        -disconnect_rate            RANGE       1-1000
                                    DEFAULT     200
        -domain_group_map
        -echo_req                   FLAG
        -echo_req_interval          RANGE       1-65535
                                    DEFAULT     60
        -echo_rsp                   FLAG
                                    DEFAULT     1
        -enable_magic               FLAG
        -hello_interval             RANGE       1-65535
                                    DEFAULT     60
        -hello_req                  FLAG
        -hostname                   REGEXP ^.*$
                                    DEFAULT lac
        -hostname_wc                FLAG
        -init_ctrl_timeout          RANGE       1-20
                                    DEFAULT     2
        -ipcp_req_timeout           RANGE       1-120
                                    DEFAULT     5
        -l2tp_dst_step              IP 
                                    DEFAULT     0.0.0.1
        -l2tp_src_count             RANGE       1-1024
                                    DEFAULT     1
        -l2tp_src_step              IP 
                                    DEFAULT     0.0.0.1
        -length_bit                 FLAG
        -max_auth_req               RANGE       1-65535
                                    DEFAULT     10
        -max_ctrl_timeout           RANGE       1-20
                                    DEFAULT     8
        -offset_bit                 FLAG
        -offset_byte                RANGE       0-255
                                    DEFAULT     0
        -offset_len                 RANGE       0-255
                                    DEFAULT     0
        -password                   ANY
                                    DEFAULT     pass
        -password_wc                FLAG
        -ppp_client_ip              IP 
        -ppp_client_step            IP 
        -ppp_server_ip              IP 
        -ppp_server_step            IPV6
        -ppp_client_iid             IPV6
        -ppp_client_iid_step        IPV6
        -ppp_server_iid             IPV6
        -pvc_incr_mode              CHOICES     vpi vci both
                                    DEFAULT     vci
        -redial                     FLAG
        -redial_max                 RANGE       1-65535
                                    DEFAULT     20
        -redial_timeout             RANGE       1-20
                                    DEFAULT     10
        -rws                        RANGE       1-2048
                                    DEFAULT     10
        -secret                     REGEXP ^.*$
                                    DEFAULT secret
        -secret_wc                  FLAG
        -sequence_bit               FLAG
        -sess_distribution          CHOICES     next fill
                                    DEFAULT     next
        -session_id_start           RANGE       1-65535
                                    DEFAULT     1
        -terminate_req_timeout      RANGE       1-65535
                                    DEFAULT     5
        -tun_auth                   FLAG
        -tun_distribution           CHOICES     next_tunnelfill_tunnel
                                    CHOICES     domain_group
                                    DEFAULT     next_tunnelfill_tunnel
        -tunnel_id_start            RANGE       1-65535
                                    DEFAULT     1
        -udp_dst_port               RANGE       1-65535
                                    DEFAULT     1701
        -udp_src_port               RANGE       1-65535
                                    DEFAULT     1701
        -username                   ANY
                                    DEFAULT     user
        -username_wc                FLAG
        -vci                        RANGE       32-65535
                                    DEFAULT     32
        -vci_count                  RANGE       1-16000
                                    DEFAULT     1
        -vci_step                   RANGE       1-65502
                                    DEFAULT     1
        -vlan_user_priority         RANGE       0-7
                                    DEFAULT     0
        -vlan_user_priority_count   RANGE       1-8
                                    DEFAULT     1
        -vlan_user_priority_step    RANGE       1-7
                                    DEFAULT     1
        -vpi                        RANGE       0-255
                                    DEFAULT     0
        -vpi_count                  RANGE       1-256
                                    DEFAULT     1
        -vpi_step                   RANGE       1-255
                                    DEFAULT     1
        -wildcard_bang_end          RANGE       0-65535
                                    DEFAULT     0
        -wildcard_bang_start        RANGE       0-65535
                                    DEFAULT     0
        -wildcard_dollar_end        RANGE       0-65535
                                    DEFAULT     0
        -wildcard_dollar_start      RANGE       0-65535
                                    DEFAULT     0
        -wildcard_pound_end         RANGE       0-65535
                                    DEFAULT     0
        -wildcard_pound_start       RANGE       0-65535
                                    DEFAULT     0
        -wildcard_question_end      RANGE       0-65535
                                    DEFAULT     0
        -wildcard_question_start    RANGE       0-65535
                                    DEFAULT     0
        -bearer_capability          CHOICES     digital analog both
                                    DEFAULT     digital
        -bearer_type                CHOICES     digital analog
                                    DEFAULT     digital
        -framing_capability         CHOICES     sync async both
                                    DEFAULT     sync
        -ip_cp                      CHOICES     ipv4_cp ipv6_cp dual_stack
                                    DEFAULT     ipv4_cp
        -ipv6_pool_addr_prefix_len  RANGE       0-128
                                    DEFAULT     64
        -ipv6_pool_prefix           ANY
                                    DEFAULT     ::
        -is_last_subport            CHOICES     0 1
                                    DEFAULT     1
        -l2tp_variant               CHOICES     ietf_variant cisco_variant
                                    DEFAULT     ietf_variant
        -proxy                      CHOICES     0 1
                                    DEFAULT     1
        -qos_rate_mode              CHOICES     percent pps bps
        -qos_rate                   NUMERIC
        -qos_byte                   RANGE       0-127
        -qos_atm_clp                CHOICES     0 1
        -qos_atm_efci               CHOICES     0 1
        -qos_atm_cr                 CHOICES     0 1
        -qos_fr_cr                  CHOICES     0 1
        -qos_fr_de                  CHOICES     0 1
        -qos_fr_becn                CHOICES     0 1
        -qos_fr_fecn                CHOICES     0 1
        -qos_ipv6_flow_label        RANGE       0-1048575
        -qos_ipv6_traffic_class     RANGE       0-255
        -flap_repeat_count          RANGE       0-65535
                                    DEFAULT     0
        -flap_rate                  RANGE       1-300
                                    DEFAULT     10
        -hold_time                  RANGE       0-65535
                                    DEFAULT     0
        -cool_off_time              RANGE       0-65535
                                    DEFAULT     0
        -enable_term_req_timeout    CHOICES     0 1
                                    DEFAULT     1
        -src_mac_addr               REGEXP ^([0-9a-fA-F]{12})|([0-9a-fA-F]{2}([:. ]{1}[0-9a-fA-F]{2}){5})|([0-9a-fA-F]{3}([:. ]{1}[0-9a-fA-F]{3}){3})|([0-9a-fA-F]{4}([:. ]{1}[0-9a-fA-F]{4}){2})$
        -src_mac_addr_auto          CHOICES 0 1
        -l2tp_src_gw                IP
        -l2tp_src_prefix_len        RANGE       0-128
    }
    
    set ixnetwork_opt_args {
        -addr_count_per_vci                             RANGE       1-65535
                                                        DEFAULT     1
        -addr_count_per_vpi                             RANGE       1-65535
                                                        DEFAULT     1
        -dhcpv6_hosts_enable                            CHOICES 0 1
                                                        DEFAULT 0
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
        -desired_mru_rate                               NUMERIC
                                                        DEFAULT 1492
        -enable_mru_negotiation                         CHOICES 0 1
        -hosts_range_ip_outer_prefix                    NUMERIC
                                                        DEFAULT 64
        -hosts_range_ip_prefix_addr                     IP
        -hosts_range_count                              RANGE   1-1000000
                                                        DEFAULT 1
        -hosts_range_eui_increment                      VCMD ::ixia::validate_eui64_or_ipv6
                                                        DEFAULT {00 00 00 00 00 00 00 01}
        -hosts_range_first_eui                          VCMD ::ixia::validate_eui64_or_ipv6
                                                        DEFAULT {00 00 00 00 00 00 11 11}
        -hosts_range_ip_prefix                          RANGE   64-128
                                                        DEFAULT 64
        -hosts_range_subnet_count                       RANGE   1-32
        -dhcp6_pd_server_range_dns_domain_search_list   ANY
        -dhcp6_pd_server_range_first_dns_server         IP
        -dhcp6_pd_server_range_second_dns_server        IP
        -dhcp6_pd_server_range_subnet_prefix            NUMERIC
        -dhcp6_pd_server_range_start_pool_address       IP
        -lease_time_max                                 RANGE   300-30000000
                                                        DEFAULT 864000
        -lease_time                                     RANGE   300-30000000
                                                        DEFAULT 864000
        -max_configure_req                              RANGE       1-255
                                                        DEFAULT     10
        -number_of_sessions                             RANGE       1-9216000
        -ipv6_pool_prefix_len                           RANGE       1-127
                                                        DEFAULT     48
        -max_ipcp_req                                   RANGE       1-255
                                                        DEFAULT     10
        -no_call_timeout                                RANGE       1-180
                                                        DEFAULT     5
        -sessions_per_tunnel                            RANGE       1-16000
                                                        DEFAULT     1
        -max_terminate_req                              RANGE       1-1000
                                                        DEFAULT     10
        -max_outstanding                                RANGE       1-1000
                                                        DEFAULT     200
        -vlan_count                                     RANGE       1-4094
                                                        DEFAULT     4094
        -vlan_id                                        RANGE       1-4094
                                                        DEFAULT     1
        -vlan_id_step                                   RANGE       0-4093
                                                        DEFAULT     1
        -inner_address_per_vlan                         RANGE       1-1000000000
                                                        DEFAULT     1
        -inner_vlan_count                               RANGE       1-4094
                                                        DEFAULT     4094
        -inner_vlan_id                                  RANGE       1-4094
                                                        DEFAULT     1
        -inner_vlan_id_step                             RANGE       0-4093
                                                        DEFAULT     1
        -inner_vlan_user_priority                       RANGE       0-7
                                                        DEFAULT     0
        -l2tp_src_gw_step                               IP
        -l2tp_src_gw_incr_mode                          CHOICES per_interface per_subnet
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_l2tp_config $args $man_args \
                "$common_opt_args $ixnetwork_opt_args"]
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


proc ::ixia::l2tp_control { args } {
    variable new_ixnetwork_api
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
                \{::ixia::l2tp_control $args\}]
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
        set procName [lindex [info level [info level]] 0]

        set man_args {
            -action CHOICES connect disconnect abort abort_async
        }
        set opt_args {
            -handle ANY
        }

        set returnList [::ixia::ixnetwork_l2tp_control $args $man_args $opt_args]
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


proc ::ixia::l2tp_stats { args } {
    variable new_ixnetwork_api
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
                \{::ixia::l2tp_stats $args\}]
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
        set procName [lindex [info level [info level]] 0]
        
        set man_args {
            -mode           CHOICES aggregate session session_dhcpv6pd session_dhcp_hosts session_all
                            DEFAULT aggregate
        }
        set opt_args {
            -port_handle
            -handle
        }

        set returnList [::ixia::ixnetwork_l2tp_stats $args $man_args $opt_args]
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
