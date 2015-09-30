##Procedure Header
# Name:
#    ::ixiangpf::pppox_config
#
# Description:
#    This procedure configures PPPoA, PPPoEoA, PPPoE sessions for the
#    specified test port. This command allows the user to configure a specified
#    number of PPPoX sessions on the test port. Each port can have upto 32000
#    sessions.
#
# Synopsis:
#    ::ixiangpf::pppox_config
#x       [-port_role                                      CHOICES access network]
#        [-handle                                         ANY]
#x       [-protocol_name                                  ALPHA]
#x       [-unlimited_redial_attempts                      CHOICES 0 1]
#x       [-enable_mru_negotiation                         CHOICES 0 1]
#x       [-desired_mru_rate                               NUMERIC]
#x       [-max_payload                                    NUMERIC]
#x       [-enable_max_payload                             CHOICES 0 1]
#x       [-client_ipv6_ncp_configuration                  CHOICES learned request
#x                                                        DEFAULT learned]
#x       [-client_ipv4_ncp_configuration                  CHOICES learned request
#x                                                        DEFAULT learned]
#x       [-server_ipv6_ncp_configuration                  CHOICES clientmay serveronly
#x                                                        DEFAULT clientmay]
#x       [-server_ipv4_ncp_configuration                  CHOICES clientmay serveronly
#x                                                        DEFAULT clientmay]
#x       [-lcp_enable_accm                                CHOICES 0 1]
#x       [-lcp_accm                                       ANY]
#        [-num_sessions                                   RANGE 1-32000]
#        [-ac_select_mode                                 CHOICES first_responding
#                                                         CHOICES ac_mac
#                                                         CHOICES ac_name
#                                                         DEFAULT first_responding]
#        [-ac_match_name                                  ALPHA]
#        [-ac_match_mac                                   ALPHA]
#        [-auth_req_timeout                               RANGE 1-65535
#                                                         DEFAULT 5]
#        [-config_req_timeout                             RANGE 1-120
#                                                         DEFAULT 5]
#        [-echo_req                                       CHOICES 0 1
#                                                         DEFAULT 0]
#        [-echo_rsp                                       CHOICES 0 1
#                                                         DEFAULT 1]
#        [-ip_cp                                          CHOICES ipv4_cp ipv6_cp dual_stack
#                                                         DEFAULT ipv4_cp]
#        [-ipcp_req_timeout                               RANGE 1-120
#                                                         DEFAULT 5]
#        [-max_auth_req                                   RANGE 1-65535
#                                                         DEFAULT 10]
#        [-max_padi_req                                   RANGE 1-65535
#                                                         DEFAULT 10]
#        [-max_padr_req                                   RANGE 1-65535
#                                                         DEFAULT 10]
#        [-max_terminate_req                              RANGE 0-65535
#                                                         DEFAULT 10]
#        [-padi_req_timeout                               RANGE 1-65535
#                                                         DEFAULT 5]
#        [-padr_req_timeout                               RANGE 1-65535
#                                                         DEFAULT 5]
#        [-password                                       ALPHA]
#        [-chap_secret                                    ALPHA]
#        [-username                                       ALPHA]
#        [-chap_name                                      ALPHA]
#        [-vlan_id                                        RANGE 0-4095
#                                                         DEFAULT 1]
#        [-vlan_id_count                                  RANGE 1-4094
#                                                         DEFAULT 4094]
#        [-vlan_id_step                                   RANGE 0-4094
#                                                         DEFAULT 1]
#        [-vlan_user_priority                             RANGE 0-7
#                                                         DEFAULT 0]
#x       [-vlan_user_priority_step                        RANGE 1-7
#x                                                        DEFAULT 1]
#        [-vlan_user_priority_outer                       RANGE 0-7
#                                                         DEFAULT 0]
#        -mode                                            CHOICES add remove modify
#        [-auth_mode                                      CHOICES none pap chap pap_or_chap]
#        [-echo_req_interval                              RANGE 1-3600]
#        [-mac_addr                                       MAC]
#        [-mac_addr_step                                  MAC
#                                                         DEFAULT 0000.0000.0001]
#        [-max_configure_req                              RANGE 1-255]
#        [-max_ipcp_req                                   RANGE 1-255]
#x       [-ac_name                                        ALPHA]
#x       [-actual_rate_downstream                         RANGE 1-65535]
#x       [-actual_rate_upstream                           RANGE 1-65535]
#x       [-agent_circuit_id                               ALPHA]
#x       [-agent_remote_id                                ALPHA]
#x       [-data_link                                      CHOICES atm_aal5 ethernet]
#x       [-enable_domain_group_map                        CHOICES 0 1]
#x       [-domain_group_map                               ALPHA]
#x       [-enable_client_signal_iwf                       CHOICES 0 1]
#x       [-enable_client_signal_loop_char                 CHOICES 0 1]
#x       [-enable_client_signal_loop_encap                CHOICES 0 1]
#x       [-enable_client_signal_loop_id                   CHOICES 0 1]
#x       [-enable_server_signal_iwf                       CHOICES 0 1]
#x       [-enable_server_signal_loop_char                 CHOICES 0 1]
#x       [-enable_server_signal_loop_encap                CHOICES 0 1]
#x       [-enable_server_signal_loop_id                   CHOICES 0 1]
#x       [-intermediate_agent                             CHOICES 0 1]
#x       [-intermediate_agent_encap1                      CHOICES na
#x                                                        CHOICES untagged_eth
#x                                                        CHOICES single_tagged_eth]
#x       [-intermediate_agent_encap2                      CHOICES na
#x                                                        CHOICES pppoa_llc
#x                                                        CHOICES pppoa_null
#x                                                        CHOICES ipoa_llc
#x                                                        CHOICES ipoa_null
#x                                                        CHOICES eth_aal5_llc_fcs
#x                                                        CHOICES eth_aal5_llc_no_fcs
#x                                                        CHOICES eth_aal5_null_fcs
#x                                                        CHOICES eth_aal5_null_no_fcs]
#x       [-ipv6_global_address_mode                       CHOICES icmpv6 dhcpv6_pd
#x                                                        DEFAULT icmpv6]
#x       [-ipv6_pool_prefix_len                           NUMERIC]
#x       [-ipv6_pool_prefix                               IPV6
#x                                                        DEFAULT 00 00 00 00 00 00 00 00]
#x       [-ipv6_pool_addr_prefix_len                      NUMERIC]
#x       [-ppp_local_iid                                  IPV6
#x                                                        DEFAULT 00 00 00 00 00 00 00 00]
#x       [-ppp_local_ip                                   IPV4
#x                                                        DEFAULT 2.2.2.2]
#x       [-ppp_local_ip_step                              IPV4
#x                                                        DEFAULT 0.0.0.1]
#x       [-ppp_local_iid_step                             NUMERIC]
#x       [-ppp_peer_iid                                   IPV6
#x                                                        DEFAULT 00 00 00 00 00 00 00 00]
#x       [-ppp_peer_iid_step                              NUMERIC]
#x       [-ppp_peer_ip                                    IPV4
#x                                                        DEFAULT 1.1.1.1]
#x       [-ppp_peer_ip_step                               IPV4]
#x       [-redial                                         CHOICES 0 1
#x                                                        DEFAULT 1]
#x       [-redial_max                                     RANGE 1-255
#x                                                        DEFAULT 20]
#x       [-redial_timeout                                 RANGE 1-65535
#x                                                        DEFAULT 10]
#x       [-service_name                                   ALPHA]
#x       [-service_type                                   CHOICES any name]
#x       [-send_dns_options                               CHOICES 0 1]
#x       [-dns_server_list                                ANY]
#x       [-client_dns_options                             CHOICES request_primary_and_secondary
#x                                                        CHOICES request_primary_only
#x                                                        CHOICES accept_addresses_from_server
#x                                                        CHOICES accept_only_primary_address_from_server
#x                                                        CHOICES disable_extension
#x                                                        DEFAULT disable_extension]
#x       [-client_dns_primary_address                     IPV4]
#x       [-client_dns_secondary_address                   IPV4]
#x       [-client_netmask_options                         CHOICES disable_extension
#x                                                        CHOICES request
#x                                                        CHOICES request_specific_netmask
#x                                                        CHOICES accept_netmask_from_server
#x                                                        DEFAULT disable_extension]
#x       [-client_netmask                                 IPV4]
#x       [-client_wins_options                            CHOICES disable_extension
#x                                                        CHOICES request_primaryonly_wins
#x                                                        CHOICES request_primaryandsecondary_wins
#x                                                        CHOICES accept_addresses_from_server
#x                                                        CHOICES accept_only_primary_address_from_server
#x                                                        DEFAULT disable_extension]
#x       [-client_wins_primary_address                    IPV4]
#x       [-client_wins_secondary_address                  IPV4]
#x       [-server_dns_options                             CHOICES accept_requested_addresses
#x                                                        CHOICES accept_only_requested_primary_address
#x                                                        CHOICES supply_primary_and_secondary
#x                                                        CHOICES supply_primary_only
#x                                                        CHOICES disable_extension
#x                                                        DEFAULT disable_extension]
#x       [-server_dns_primary_address                     IPV4]
#x       [-server_dns_secondary_address                   IPV4]
#x       [-server_netmask_options                         CHOICES disable_extension
#x                                                        CHOICES request
#x                                                        CHOICES accept_requested_netmask
#x                                                        CHOICES supply_netmask
#x                                                        DEFAULT disable_extension]
#x       [-server_netmask                                 IPV4]
#x       [-server_wins_options                            CHOICES disable_extension
#x                                                        CHOICES accept_requested_addresses
#x                                                        CHOICES accept_only_requested_primary_address
#x                                                        CHOICES supply_primary_and_secondary
#x                                                        CHOICES supply_primary_only
#x                                                        DEFAULT disable_extension]
#x       [-server_wins_primary_address                    IPV4]
#x       [-server_wins_secondary_address                  IPV4]
#x       [-ra_timeout                                     NUMERIC]
#x       [-create_interfaces                              CHOICES 0 1]
#        [-attempt_rate                                   RANGE 1-1000
#                                                         DEFAULT 100]
#x       [-attempt_max_outstanding                        RANGE 1-1000]
#x       [-attempt_interval                               NUMERIC]
#x       [-attempt_enabled                                CHOICES 0 1]
#x       [-attempt_scale_mode                             CHOICES port device_group
#x                                                        DEFAULT port]
#        [-disconnect_rate                                RANGE 1-1000
#                                                         DEFAULT 100]
#x       [-disconnect_max_outstanding                     RANGE 1-1000]
#x       [-disconnect_interval                            NUMERIC]
#x       [-disconnect_enabled                             CHOICES 0 1]
#x       [-disconnect_scale_mode                          CHOICES port device_group
#x                                                        DEFAULT port]
#x       [-enable_session_lifetime                        CHOICES 0 1]
#x       [-min_lifetime                                   NUMERIC]
#x       [-max_lifetime                                   NUMERIC]
#x       [-enable_session_lifetime_restart                CHOICES 0 1]
#x       [-max_session_lifetime_restarts                  NUMERIC]
#x       [-unlimited_session_lifetime_restarts            CHOICES 0 1]
#x       [-accept_any_auth_value                          CHOICES 0 1]
#        [-port_handle                                    REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-protocol                                       CHOICES pppoe pppoeoa pppoa
#                                                         DEFAULT pppoe]
#n       [-vci                                            ANY]
#n       [-vci_step                                       ANY]
#n       [-vci_count                                      ANY]
#n       [-addr_count_per_vci                             ANY]
#n       [-vpi                                            ANY]
#n       [-vpi_step                                       ANY]
#n       [-vpi_count                                      ANY]
#n       [-addr_count_per_vpi                             ANY]
#n       [-pvc_incr_mode                                  ANY]
#        [-encap                                          CHOICES ethernet_ii
#                                                         CHOICES ethernet_ii_vlan
#                                                         CHOICES ethernet_ii_qinq
#                                                         CHOICES vc_mux
#                                                         CHOICES vc_mux_routed
#                                                         CHOICES vc_mux_nofcs
#                                                         CHOICES llcsnap
#                                                         CHOICES llcsnap_routed
#                                                         CHOICES llcsnap_nofcs]
#x       [-address_per_vlan                               RANGE 1-1000000000
#x                                                        DEFAULT 1]
#x       [-address_per_svlan                              RANGE 1-1000000000
#x                                                        DEFAULT 1]
#        [-qinq_incr_mode                                 CHOICES inner outer both
#                                                         DEFAULT both]
#        [-vlan_id_outer                                  RANGE 0-4095
#                                                         DEFAULT 1]
#        [-vlan_id_outer_count                            RANGE 1-4094
#                                                         DEFAULT 4094]
#        [-vlan_id_outer_step                             RANGE 0-4094
#                                                         DEFAULT 1]
#n       [-vlan_user_priority_count                       ANY]
#        [-password_wildcard                              CHOICES 0 1
#                                                         DEFAULT 0]
#        [-username_wildcard                              CHOICES 0 1
#                                                         DEFAULT 0]
#        [-wildcard_pound_start                           NUMERIC
#                                                         DEFAULT 0]
#        [-wildcard_pound_end                             NUMERIC
#                                                         DEFAULT 0]
#        [-wildcard_question_start                        NUMERIC
#                                                         DEFAULT 0]
#        [-wildcard_question_end                          NUMERIC
#                                                         DEFAULT 0]
#        [-ac_select_list                                 ANY]
#n       [-enable_throttling                              ANY]
#n       [-enable_setup_throttling                        ANY]
#n       [-enable_multicast                               ANY]
#n       [-local_magic                                    ANY]
#n       [-term_req_timeout                               ANY]
#x       [-lcp_max_failure                                NUMERIC]
#x       [-lcp_start_delay                                NUMERIC]
#        [-max_outstanding                                RANGE 1-1000
#                                                         DEFAULT 1000]
#x       [-dhcpv6_hosts_enable                            CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-dhcp6_global_echo_ia_info                      CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-dhcp6_global_max_outstanding_releases          RANGE 1-100000
#x                                                        DEFAULT 500]
#x       [-dhcp6_global_max_outstanding_requests          RANGE 1-100000
#x                                                        DEFAULT 20]
#x       [-dhcp6_global_reb_max_rt                        RANGE 1-10000
#x                                                        DEFAULT 500]
#x       [-dhcp6_global_reb_timeout                       RANGE 1-100
#x                                                        DEFAULT 10]
#x       [-dhcp6_global_rel_max_rc                        RANGE 1-100
#x                                                        DEFAULT 5]
#x       [-dhcp6_global_rel_timeout                       RANGE 1-100
#x                                                        DEFAULT 1]
#x       [-dhcp6_global_ren_max_rt                        RANGE 1-10000
#x                                                        DEFAULT 600]
#x       [-dhcp6_global_ren_timeout                       RANGE 1-100
#x                                                        DEFAULT 10]
#x       [-dhcp6_global_req_max_rc                        RANGE 1-100
#x                                                        DEFAULT 10]
#x       [-dhcp6_global_req_max_rt                        RANGE 1-10000
#x                                                        DEFAULT 30]
#x       [-dhcp6_global_req_timeout                       RANGE 1-100
#x                                                        DEFAULT 1]
#x       [-dhcp6_global_setup_rate_initial                RANGE 1-10000
#x                                                        DEFAULT 10]
#n       [-dhcp6_global_setup_rate_increment              ANY]
#n       [-dhcp6_global_setup_rate_max                    ANY]
#x       [-dhcp6_global_sol_max_rc                        RANGE 1-100
#x                                                        DEFAULT 3]
#x       [-dhcp6_global_sol_max_rt                        RANGE 1-10000
#x                                                        DEFAULT 120]
#x       [-dhcp6_global_sol_timeout                       RANGE 1-100
#x                                                        DEFAULT 4]
#x       [-dhcp6_global_teardown_rate_initial             RANGE 1-10000
#x                                                        DEFAULT 50]
#n       [-dhcp6_global_teardown_rate_increment           ANY]
#n       [-dhcp6_global_teardown_rate_max                 ANY]
#n       [-dhcp6_global_wait_for_completion               ANY]
#x       [-dhcpv6pd_type                                  CHOICES client server
#x                                                        DEFAULT client]
#x       [-dhcp6_pd_client_range_duid_enterprise_id       RANGE 1-2147483647
#x                                                        DEFAULT 10]
#x       [-dhcp6_pd_client_range_duid_type                CHOICES duid_en duid_llt duid_ll
#x                                                        DEFAULT duid_llt]
#x       [-dhcp6_pd_client_range_duid_vendor_id           RANGE 1-2147483647
#x                                                        DEFAULT 10]
#x       [-dhcp6_pd_client_range_duid_vendor_id_increment RANGE 1-2147483647
#x                                                        DEFAULT 1]
#x       [-dhcp6_pd_client_range_ia_id                    RANGE 1-2147483647
#x                                                        DEFAULT 10]
#x       [-dhcp6_pd_client_range_ia_id_increment          RANGE 1-2147483647
#x                                                        DEFAULT 1]
#x       [-dhcp6_pd_client_range_ia_t1                    RANGE 0-2147483647
#x                                                        DEFAULT 302400]
#x       [-dhcp6_pd_client_range_ia_t2                    RANGE 0-2147483647
#x                                                        DEFAULT 483840]
#x       [-dhcp6_pd_client_range_ia_type                  CHOICES iapd iana iata iana_iapd
#x                                                        DEFAULT iapd]
#n       [-dhcp6_pd_client_range_param_request_list       ANY]
#x       [-dhcp6_pd_client_range_renew_timer              RANGE 0-1000000000
#x                                                        DEFAULT 0]
#n       [-dhcp6_pd_client_range_use_vendor_class_id      ANY]
#n       [-dhcp6_pd_client_range_vendor_class_id          ANY]
#x       [-dhcp6_pd_server_range_dns_domain_search_list   ANY]
#x       [-dhcp6_pd_server_range_first_dns_server         IP]
#x       [-dhcp6_pd_server_range_second_dns_server        IP]
#x       [-dhcp6_pd_server_range_subnet_prefix            NUMERIC]
#x       [-dhcp6_pd_server_range_start_pool_address       IP]
#x       [-dhcp6_pgdata_max_outstanding_requests          RANGE 1-100000
#x                                                        DEFAULT 20]
#x       [-dhcp6_pgdata_override_global_setup_rate        CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-dhcp6_pgdata_setup_rate_initial                RANGE 1-10000
#x                                                        DEFAULT 10]
#n       [-dhcp6_pgdata_setup_rate_increment              ANY]
#n       [-dhcp6_pgdata_setup_rate_max                    ANY]
#x       [-dhcp6_pgdata_max_outstanding_releases          RANGE 1-100000
#x                                                        DEFAULT 500]
#x       [-dhcp6_pgdata_override_global_teardown_rate     CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-dhcp6_pgdata_teardown_rate_initial             RANGE 1-10000
#x                                                        DEFAULT 50]
#n       [-dhcp6_pgdata_teardown_rate_increment           ANY]
#n       [-dhcp6_pgdata_teardown_rate_max                 ANY]
#n       [-hosts_range_ip_outer_prefix                    ANY]
#n       [-hosts_range_ip_prefix_addr                     ANY]
#n       [-hosts_range_count                              ANY]
#n       [-hosts_range_eui_increment                      ANY]
#n       [-hosts_range_first_eui                          ANY]
#n       [-hosts_range_ip_prefix                          ANY]
#n       [-hosts_range_subnet_count                       ANY]
#n       [-lease_time_max                                 ANY]
#x       [-lease_time                                     RANGE 300-30000000
#x                                                        DEFAULT 3600]
#n       [-padi_include_tag                               ANY]
#n       [-pado_include_tag                               ANY]
#n       [-padr_include_tag                               ANY]
#n       [-pads_include_tag                               ANY]
#n       [-re_connect_on_link_up                          ANY]
#n       [-group_ip_count                                 ANY]
#n       [-group_ip_step                                  ANY]
#n       [-start_group_ip                                 ANY]
#n       [-igmp_version                                   ANY]
#n       [-is_last_subport                                ANY]
#n       [-join_leaves_per_second                         ANY]
#n       [-l4_src_port                                    ANY]
#n       [-l4_dst_port                                    ANY]
#n       [-l4_flow_number                                 ANY]
#n       [-l4_flow_type                                   ANY]
#n       [-l4_flow_variant                                ANY]
#n       [-mc_enable_general_query                        ANY]
#n       [-mc_enable_group_specific_query                 ANY]
#n       [-mc_enable_immediate_response                   ANY]
#n       [-mc_enable_packing                              ANY]
#n       [-mc_enable_router_alert                         ANY]
#n       [-mc_enable_suppress_reports                     ANY]
#n       [-mc_enable_unsolicited                          ANY]
#n       [-mc_group_id                                    ANY]
#n       [-mc_report_frequency                            ANY]
#n       [-ppp_local_mode                                 ANY]
#n       [-ppp_peer_mode                                  ANY]
#n       [-enable_delete_config                           ANY]
#n       [-flap_repeat_count                              ANY]
#n       [-flap_rate                                      ANY]
#n       [-switch_duration                                ANY]
#n       [-watch_duration                                 ANY]
#n       [-hold_time                                      ANY]
#n       [-cool_off_time                                  ANY]
#n       [-dut_assigned_src_addr                          ANY]
#n       [-include_id                                     ANY]
#n       [-sessions_per_vc                                ANY]
#x       [-enable_host_uniq                               ANY]
#x       [-host_uniq                                      ANY]
#x       [-multiplier                                     NUMERIC]
#
# Arguments:
#x   -port_role
#x       The role of the port in the test: access or network.
#    -handle
#        PPPoX handle of a configuration to be modified or removed.
#        Dependencies: only available when IxNetwork is used for the PPPoX configuration.
#        When -handle is provided with the /globals value the arguments that configure global protocol
#        setting accept both multivalue handles and simple values.
#        When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#        that configure global settings will only accept simple values. In this situation, these arguments will
#        configure only the settings of the parent device group or the ports associated with the parent topology.
#x   -protocol_name
#x   -unlimited_redial_attempts
#x       If checked, PPPoE unlimited redial attempts is enabled
#x   -enable_mru_negotiation
#x       Enable MRU Negotiation
#x   -desired_mru_rate
#x       Max Transmit Unit for PPP
#x   -max_payload
#x       Max Payload. Valid only when enable_max_payload is enabled.
#x   -enable_max_payload
#x       Enables PPP Max Payload tag
#x   -client_ipv6_ncp_configuration
#x       Valid only when ip_cp is ipv6_cp or dual_stack
#x   -client_ipv4_ncp_configuration
#x       Valid only when ip_cp is ipv4_cp or dual_stack
#x   -server_ipv6_ncp_configuration
#x       Valid only when ip_cp is ipv6_cp or dual_stack
#x   -server_ipv4_ncp_configuration
#x       Valid only when ip_cp is ipv4_cp or dual_stack
#x   -lcp_enable_accm
#x       Enable Async-Control-Character-Map
#x   -lcp_accm
#x       Async-Control-Character-Map. Valid only when lcp_enable_accm is enabled.
#    -num_sessions
#        The number of PPP sessions to configure.
#        For PPP servers this will configure the number of sessions supprted by each server.
#        For PPP clients this will configure the number of client sessions that are available.
#    -ac_select_mode
#        There are various ways AC can be selected based on the PADO
#        received from AC.
#    -ac_match_name
#    -ac_match_mac
#    -auth_req_timeout
#        Specifies the timeout value in seconds for acknowledgement of an
#        authentication Request.
#    -config_req_timeout
#        Specifies the timeout value in seconds for acknowledgement of a
#        Configure Request or Terminate Request.
#    -echo_req
#        When set to 1, enables Echo Requests, when set to 0, disables Echo
#        Requests.
#    -echo_rsp
#        This can be used to do negative testing. Dependencies: -mode add (when IxNetwork is used for the PPPoX configuration). Valid choices are:
#        0 - Disable sending of the echo Responses.
#        1 - (DEFAULT) Enable Echo Replies.
#    -ip_cp
#    -ipcp_req_timeout
#        Specifies the timeout value in seconds for acknowledgement of an
#        IPCP configure request.
#    -max_auth_req
#        Specifies the maximum number of Authentication Requests that can be
#        sent without getting an authentication response from the DUT.
#    -max_padi_req
#        Specifies the maximum number of PADI Requests that can be sent
#        without getting a PADO from the DUT.
#    -max_padr_req
#        Specifies the maximum number of PADR Requests that can be sent
#        without getting a PADS from the DUT.
#    -max_terminate_req
#        Specifies the maximum number of Terminate Requests that can be sent
#        without acknowledgement.
#    -padi_req_timeout
#        Specifies the timeout value in seconds for acknowledgement of a
#        PADI Request.
#    -padr_req_timeout
#        Specifies the timeout value in seconds for acknowledgement of a
#        PADR Request.
#    -password
#        Password, PAP and CHAP only.
#    -chap_secret
#        Secret when CHAP Authentication is being used
#    -username
#        Username, PAP and CHAP only.
#    -chap_name
#        User name when CHAP Authentication is being used
#    -vlan_id
#        Starting VLAN ID, applies to PPPoE w/VLAN only.
#    -vlan_id_count
#        Number of VLAN IDs, applies to PPPoE w/VLAN only.
#    -vlan_id_step
#        Step value applied to VLAN ID, PPPoEoE w/VLAN only.
#    -vlan_user_priority
#        VLAN user priority, PPPoEoE w/VLAN only.
#x   -vlan_user_priority_step
#    -vlan_user_priority_outer
#        Outer VLAN user priority, PPPoEoE w/VLAN only.
#    -mode
#        Dependencies: only available when IxNetwork is used for the PPPoX configuration.
#    -auth_mode
#        Authentication mode.
#    -echo_req_interval
#        Specifies the time interval in seconds for sending LCP echo
#        requests. Valid only if -echo_req is set to 1.
#        When using IxNetwork this parameter can take values from the 1-3600
#        range.
#    -mac_addr
#        <aa.bb.cc.dd.ee.ff>
#    -mac_addr_step
#        <aa.bb.cc.dd.ee.ff>
#        Dependencies: -mode add or modify (when IxNetwork is used for the PPPoX configuration).
#    -max_configure_req
#        Specifies the maximum number of LCP Configure Requests that can be sent
#        without acknowledgement.
#        When using IxNetwork this parameter can take values from the 1-255
#        range.
#    -max_ipcp_req
#        Specifies the maximum number of IPCP configure requests that can be
#        sent without getting an ack from the DUT.
#        When using IxNetwork this parameter can take values from the 1-255
#        range.
#x   -ac_name
#x       When the port is used as a server, this is the name sent in the
#x       PADO message.
#x   -actual_rate_downstream
#x       This parameter configures Access Loop Characteristics. For details
#x       refer to -enable_server_signal_loop_char.
#x       The actual downstream data rate (sub-option 0x81), in kbps.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1
#x   -actual_rate_upstream
#x       This parameter configures Access Loop Characteristics. For details
#x       refer to -enable_server_signal_loop_char.
#x       The actual upstream data rate (sub-option 0x82), in kbps
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1
#x   -agent_circuit_id
#x       When intermediate_agent is true, the program inserts an Agent
#x       Circuit ID and an Agent Remote ID into PPPoE tags for each PPPoE
#x       session. These IDs serve to distinguish the CPE premises from
#x       each other. This field has a maximum length of 32 characters.The
#x       agent_circuit_id field is defined in strings of the form:
#x       %<start-width>:<count>:<repeat count>i.
#x   -agent_remote_id
#x       When intermediate_agent is true, the program inserts an Agent
#x       Circuit ID and an Agent Remote ID into PPPoE tags for each PPPoE
#x       session. These IDs serve to distinguish the CPE premises from
#x       each other. This field has a maximum length of 32 characters. The
#x       agentRemoteId field is defined in strings of the form:
#x       %<start-width>:<count>:<repeat count>i.
#x   -data_link
#x       This parameter configures Signaling the Access Loop Encapsulation
#x       (sub-option 0x90), for details refer to -enable_server_signal_loop_encap.
#x       The PPPoE intermediate agent on the Access Node inserts the 0x90
#x       sub-option to signal to the BNG the data-link protocol on the Access Loop.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1
#x   -enable_domain_group_map
#x       This parameter configures the Interworking function (IWF). For details
#x       refer to -enable_server_signal_iwf.
#x       When enabled, the Access Node provides protocol translation between the
#x       ATM layer on the user side and the Ethernet layer on the network side.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1; -port_role access
#x   -domain_group_map
#x       List of domain group to LNS IP mapping.
#x       Each domain group can have thousands of domains.
#x       With the help of domain group it is very easy to map thousands of
#x       domains to one or more LNS IP addresses. Each domain group is defined
#x       as: { { domain_name } {lnsIP1 lnsIP2} }.
#x       Where domain_name is defined as:
#x       {name wc wc_start wc_end <wc_repeat >}
#x       name <string> : name to be used for the domain(s).
#x       wc {1|0} : enables wildcard substitution in the name field.
#x       wc_start <0-65535> : starting value for wildcard symbol for the name
#x       (%) substitution
#x       wc_end <0-65535> : ending value for wildcard symbol for the name
#x       (%) substitution
#x       lnsIP <a.b.c.d> : LNS IP address list to be used for this domain.
#x       Example: You want to set up 20 domains,
#x       out of which cisco1.com to cisco10.com going to 192.1.1.1 & 192.1.1.2
#x       and cisco11.com to cisco20.com going to 192.1.2.1. Also assume number
#x       of sessions per tunnel is 5. Your domain group list will look like:
#x       { { {cisco%.com 1 1 10} {192.1.1.1 192.1.1.2} }
#x       { {cisco%.com 1 11 20} {192.1.2.1} } }
#x       Tunnel Allocation will look like this:
#x       Sessions 1-5, tunnel1 dst 192.1.1.1;
#x       Sessions 5-10, tunnel2 dst 192.1.1.2;
#x       Sessions 11-15, tunnel3 dst 192.1.2.1;
#x       Sessions 16-20, tunnel4 dst 192.1.2.1.
#x   -enable_client_signal_iwf
#x       This parameter configures the Interworking function (IWF). For details
#x       refer to -enable_server_signal_iwf.
#x       When enabled, the Access Node provides protocol translation between the
#x       ATM layer on the user side and the Ethernet layer on the network side.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1; -port_role access
#x   -enable_client_signal_loop_char
#x       This parameter configures Access Loop Characteristics. For details
#x       refer to -enable_server_signal_loop_char.
#x       When this parameter is enabled, the discovery packets will include
#x       the 0x81 and 0x82 sub-options.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1; -port_role access
#x   -enable_client_signal_loop_encap
#x       This parameter configures Signaling the Access Loop Encapsulation
#x       (sub-option 0x90), for details refer to -enable_server_signal_loop_encap
#x       When this parameter is enabled, the discovery packets will include the
#x       0x90 sub-option.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1; -port_role access
#x   -enable_client_signal_loop_id
#x       When this parameter is 1, the discovery packets will include
#x       the -agent_circuit_id and -agent_remote_id options.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1; -port_role access
#x   -enable_server_signal_iwf
#x       This parameter configures the Interworking function (IWF) - When ATM
#x       is supported on the DSL line (the U interface), the Access Node must
#x       provide protocol translation between the ATM layer on the user side and
#x       the Ethernet layer on the network side.
#x       When enabled, the Access Node provides protocol translation between
#x       the ATM layer on the user side and the Ethernet layer on the network side.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1; -port_role network
#x   -enable_server_signal_loop_char
#x       This parameter configures Access Loop Characteristics - the Access Node
#x       reports the access loop sync rate and interleave delay to the
#x       Broadband Network Gateway (BNG). This allows the BNG to enable
#x       policy decisions and advanced QoS enforcement, while potentially
#x       taking full advantage of the data rate of a given access loop.
#x       When this parameter is enabled, the discovery packets will include
#x       the 0x81 and 0x82 sub-options.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1; -port_role network
#x   -enable_server_signal_loop_encap
#x       This parameter configures Signaling the Access Loop Encapsulation
#x       (sub-option 0x90): for access loop encapsulation the PPPoE intermediate
#x       agent inserts information in the PPPoE packets to signal to the BNG the
#x       data-link protocol and the encapsulation overhead on the Access Loop.
#x       For signaling of interworked sessions the Access Node must signal the
#x       BNG that a given PPPoE session is going to carry interworked PPPoA traffic.
#x       When this parameter is enabled, the discovery packets will include the
#x       0x90 sub-option.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1; -port_role network
#x   -enable_server_signal_loop_id
#x       When this parameter is 1, the discovery packets will include
#x       the -agent_circuit_id and -agent_remote_id options.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1; -port_role network
#x   -intermediate_agent
#x       Enables the Intermediate Agent feature. This feature allows for
#x       the testing of DSLAM/BRAS devices that translate from PPPoA
#x       traffic to PPPoE traffic. When this option is true, the program
#x       inserts agent_circuit_id and agent_remote_id values into PPPoE
#x       tags for each PPPoE session.
#x   -intermediate_agent_encap1
#x       This parameter configures Signaling the Access Loop Encapsulation
#x       (sub-option 0x90), for details refer to -enable_server_signal_loop_encap.
#x       The PPPoE intermediate agent on the Access Node inserts the 0x90
#x       sub-option to signal to the BNG the encapsulation overhead on the
#x       Access Loop.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1
#x   -intermediate_agent_encap2
#x       This parameter configures Signaling the Access Loop Encapsulation
#x       (sub-option 0x90), for details refer to -enable_server_signal_loop_encap.
#x       The PPPoE intermediate agent on the Access Node inserts the 0x90
#x       sub-option to signal to the BNG the encapsulation overhead on the
#x       Access Loop.
#x       Available only when IxNetwork is used for PPPoX configurations.
#x       Dependencies: -intermediate_agent 1
#x   -ipv6_global_address_mode
#x       Select the protocol used to set IPv6 global interfaces on PPP interfaces.
#x       This configuration applies at port level.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is
#x       'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -ipv6_pool_prefix_len
#x       Pool prefix length. The difference between the address and pool prefix
#x       lengths determine the size of the IPv6 IP pool
#x   -ipv6_pool_prefix
#x       Pool prefix length. The difference between the address and pool prefix
#x       lengths determine the size of the IPv6 IP pool
#x   -ipv6_pool_addr_prefix_len
#x       The IPv6 address prefix length.
#x   -ppp_local_iid
#x       The local base IPv6 interface ID.
#x   -ppp_local_ip
#x       The first address assigned on the local PPP node.
#x   -ppp_local_ip_step
#x       The value by which ppp_local_ip is incremented for each session.
#x   -ppp_local_iid_step
#x       Server IPv6CP interface identifier increment, used in conjuction with the base identifier
#x   -ppp_peer_iid
#x       The peer base IPv6 interface ID.
#x   -ppp_peer_iid_step
#x       Client IPv6CP interface identifier increment, used in conjuction with the base identifier
#x   -ppp_peer_ip
#x       The first address assigned on the peer PPP node.
#x   -ppp_peer_ip_step
#x       The value by which ppp_peer_ip is incremented for each session.
#x   -redial
#x       If true, enables access ports to redial at the PPPoE level.
#x   -redial_max
#x       The maximum number of redial attempts.
#x       When using IxNetwork this parameter can take values from the 1-255
#x       range.
#x   -redial_timeout
#x       The time to wait before restarting a session if the call was
#x       dropped, expressed in seconds.
#x       When using IxNetwork this parameter can take values from the 1-65535
#x       range.
#x   -service_name
#x       This string is used for matching of the PADO messages for the
#x       client. For server ports, this string is also sent by the server
#x       as the server name in the PADO message. Any string up to 32
#x       characters in length may be used.The string may contain text
#x       characters, plus a specification of the form:
#x       %[<start-width>:<modulo>:<repeat>]i
#x   -service_type
#x       The type of Access Concentrator matching that is desired.
#x   -send_dns_options
#x       Enable RDNSS routing advertisments
#x   -dns_server_list
#x       DNS server list separacted by semicolon. Enabled just for IPv6 and send_dns_options.
#x   -client_dns_options
#x   -client_dns_primary_address
#x   -client_dns_secondary_address
#x   -client_netmask_options
#x   -client_netmask
#x       Valid only when client_netmask_options is request_specific_netmask
#x   -client_wins_options
#x   -client_wins_primary_address
#x       Valid only when client_wins_options is request_primaryonly_wins or accept_only_primary_address_from_server
#x   -client_wins_secondary_address
#x       Valid only when client_wins_options is request_primaryonly_wins
#x   -server_dns_options
#x   -server_dns_primary_address
#x   -server_dns_secondary_address
#x   -server_netmask_options
#x   -server_netmask
#x       Valid only when server_netmask_options is supply_netmask
#x   -server_wins_options
#x   -server_wins_primary_address
#x       Valid when server_wins_options is supply_primary_and_secondary or supply_primary_only.
#x   -server_wins_secondary_address
#x       Valid when server_wins_options is supply_primary_and_secondary.
#x   -ra_timeout
#x       Time to wait (in seconds) for Router Advertisment before NCP up. Valid only for port_role access.
#x   -create_interfaces
#x       Enable echo request/reply. This command applies only for PPPv4 clients. Valid only for port_role access.
#    -attempt_rate
#        Specifies the rate in attempts/second at which attempts are made to
#        bring up sessions.
#        When using IxNetwork this parameter can take values from the 1-1000 range.
#x   -attempt_max_outstanding
#x       The number of triggered instances of an action that is still awaiting a response or completion
#x   -attempt_interval
#x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
#x   -attempt_enabled
#x   -attempt_scale_mode
#x       Indicates whether the control is specified per port or per device group.
#x       This setting is global for all the pppoxclient protocols configured in the ixncfg
#x       and can be configured just when handle is /globals (when the user wants to configure just the global settings)
#    -disconnect_rate
#        Specifies the rate in disconnects/s at which sessions are
#        disconnected. This parameter can take values from the 1-1000 range.
#x   -disconnect_max_outstanding
#x       The number of triggered instances of an action that is still awaiting a response or completion
#x   -disconnect_interval
#x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
#x   -disconnect_enabled
#x   -disconnect_scale_mode
#x       Indicates whether the control is specified per port or per device group.
#x       This setting is global for all the pppoxclient protocols configured in the ixncfg
#x       and can be configured just when handle is /globals (when the user wants to configure just the global settings)
#x   -enable_session_lifetime
#x       Enable session lifetime
#x   -min_lifetime
#x       Minimum session lifetime (in seconds)
#x   -max_lifetime
#x       Maximum session lifetime (in seconds)
#x   -enable_session_lifetime_restart
#x       Enable automatic session restart after stop at lifetime expiry
#x   -max_session_lifetime_restarts
#x       Maximum number of times each session is automatically restarted
#x   -unlimited_session_lifetime_restarts
#x       Allow each session to always be automatically restarted
#x   -accept_any_auth_value
#x       Configures a PAP/CHAP authenticator to accept all offered usernames, passwords, and base domain names
#    -port_handle
#        The port on which the PPPoX sessions is to be created.
#        Dependencies: -mode add (when IxNetwork is used for the
#        PPPoX configuration).
#    -protocol
#        Type of sessions to be configured.Valid options are:
#        pppoa
#        pppoeoa
#        pppoe
#        Only the pppoe options is supported.
#n   -vci
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -addr_count_per_vci
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -addr_count_per_vpi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -pvc_incr_mode
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -encap
#        Encapsulation type for session.
#        Dependencies: -mode add (when IxNetwork is used for the
#        PPPoX configuration) and -protocol.
#x   -address_per_vlan
#x       How often a new outer VLAN ID is generated. For example, a value of 10
#x       will cause a new VLAN ID to be used in blocks of 10 IP addresses.
#x   -address_per_svlan
#x       How often a new inner VLAN ID is generated. For example, a value of 10
#x       will cause a new VLAN ID to be used in blocks of 10 IP addresses.
#    -qinq_incr_mode
#    -vlan_id_outer
#        Starting outer VLAN ID, applies to PPPoE w/Stacked VLAN only.
#    -vlan_id_outer_count
#        Number of outer VLAN IDs, applies to PPPoE w/Stacked VLAN only.
#    -vlan_id_outer_step
#        Step value applied to outer VLAN ID, PPPoEoE w/Stacked VLAN only.
#n   -vlan_user_priority_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -password_wildcard
#        Enables wildcard substituation in the password field.
#        Notes: If mode is modify, all the wildcard parameters (password
#        username_wildcard password_wildcard wildcard_pound_start
#        wildcard_pound_end wildcard_question_start wildcard_question_end)
#        must be reconfigured. Otherwise invalid configurations may result.
#    -username_wildcard
#        Enables wildcard substitution in the username field.
#        Notes: If mode is modify, all the wildcard parameters (username
#        username_wildcard password_wildcard wildcard_pound_start
#        wildcard_pound_end wildcard_question_start wildcard_question_end)
#        must be reconfigured. Otherwise invalid configurations may result.
#    -wildcard_pound_start
#        Starting value for wildcard symbol 1 (\) substitution. It is also
#        valid to useas the substitution symbol.
#        Enables wildcard substitution in the username field.
#        Notes: If mode is modify, all the wildcard parameters (username
#        username_wildcard password_wildcard wildcard_pound_start
#        wildcard_pound_end wildcard_question_start wildcard_question_end)
#        must be reconfigured. Otherwise invalid configurations may result.
#        This parameter can be provided in various formats. For example, the
#        number 2 can be provided as follows: 2, 02, 002, 0002, 00002.
#    -wildcard_pound_end
#        Ending value for wildcard symbol 1 (\) substitution. It is also valid
#        to useas the substitution symbol.
#        Enables wildcard substitution in the username field.
#        Notes: If mode is modify, all the wildcard parameters (username
#        username_wildcard password_wildcard wildcard_pound_start
#        wildcard_pound_end wildcard_question_start wildcard_question_end)
#        must be reconfigured. Otherwise invalid configurations may result.
#        This parameter can be provided in various formats. For example, the
#        number 2 can be provided as follows: 2, 02, 002, 0002, 00002.
#        It must be the same format as for wildcard_pound_start.
#    -wildcard_question_start
#        Starting value for wildcard symbol 2 (?) substitution.
#        Enables wildcard substitution in the username field.
#        Notes: If mode is modify, all the wildcard parameters (username
#        username_wildcard password_wildcard wildcard_pound_start
#        wildcard_pound_end wildcard_question_start wildcard_question_end)
#        must be reconfigured. Otherwise invalid configurations may result.
#        This parameter can be provided in various formats. For example, the
#        number 2 can be provided as follows: 2, 02, 002, 0002, 00002.
#    -wildcard_question_end
#        Ending value for wildcard symbol 2 (?) substitution.
#        Enables wildcard substitution in the username field.
#        Notes: If mode is modify, all the wildcard parameters (username
#        username_wildcard password_wildcard wildcard_pound_start
#        wildcard_pound_end wildcard_question_start wildcard_question_end)
#        must be reconfigured. Otherwise invalid configurations may result.
#        This parameter can be provided in various formats. For example, the
#        number 2 can be provided as follows: 2, 02, 002, 0002, 00002.
#        It must be the same format as for wildcard_question_start.
#    -ac_select_list
#        This option is used in case ac_select_mode is chosen as ac_mac or.
#        ac_name. It specifies the AC MAC address and percentage pair as list:
#        {00:11:00:00:00:11|50 00:11:00:00:00:12|50} or
#        [list 00:11:00:00:00:11|50 00:11:00:00:00:12|50]
#        or it specifies the ac name and percentage pair as list:
#        {ciscoAC1|60 ciscoAC2|40} or [list ciscoAC1|60 ciscoAC2|40]
#n   -enable_throttling
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -enable_setup_throttling
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -enable_multicast
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -local_magic
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -term_req_timeout
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -lcp_max_failure
#x       Number of Configure-Nak packets received before abandon link setup
#x   -lcp_start_delay
#x       Delay time in milliseconds to wait before sending LCP Config packet
#    -max_outstanding
#        Specifies the maximum number of sessions in progress, which
#        includes the sessions in the process of either coming up or
#        disconnecting, at one time.
#        When using IxNetwork this parameter can take values from the 1-1000
#        range.
#x   -dhcpv6_hosts_enable
#x       Valid choices are:
#x       0 ' Configure standard PPPoE
#x       1 ' Enable using DHCPv6 hosts behind PPP CPE feature.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is 'access' and 'mode is 'create'. Configurations created with 'dhcpv6_hosts_enable '0'
#x       cannot coexist on the same port with ranges created with 'dhcpv6_hosts_enable 1.
#x   -dhcp6_global_echo_ia_info
#x       If 1 the DHCPv6 client will request the exact address as advertised by the server.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x       Valid choices are:
#x       0 - (DEFAULT) Disabled
#x       1 - Enabled
#x   -dhcp6_global_max_outstanding_releases
#x       The maximum number of requests to be sent by all DHCP clients during session
#x       teardown.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_max_outstanding_requests
#x       The maximum number of requests to be sent by all DHCP clients during session
#x       startup.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_reb_max_rt
#x       RFC 3315 max rebind timeout value in seconds.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_reb_timeout
#x       RFC 3315 initial rebind timeout value in seconds.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_rel_max_rc
#x       RFC 3315 release attempts.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_rel_timeout
#x       RFC 3315 initial release timeout in seconds.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_ren_max_rt
#x       RFC 3315 max renew timeout in secons.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_ren_timeout
#x       RFC 3315 initial renew timeout in secons.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_req_max_rc
#x       RFC 3315 max request retry attempts.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_req_max_rt
#x       RFC 3315 max request timeout value in secons.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_req_timeout
#x       RFC 3315 initial request timeout value in secons.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_setup_rate_initial
#x       Setup rate is the number of clients to start in each second. This value
#x       represents the initial value for setup rate.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#n   -dhcp6_global_setup_rate_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_global_setup_rate_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_global_sol_max_rc
#x       RFC 3315 max solicit retry attempts.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_sol_max_rt
#x       RFC 3315 max solicit timeout value in seconds.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_sol_timeout
#x       RFC 3315 initial solicit timeout value in seconds.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_global_teardown_rate_initial
#x       Setup rate is the number of clients to stop in each second. This value
#x       represents the initial value for teardown rate.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#n   -dhcp6_global_teardown_rate_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_global_teardown_rate_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_global_wait_for_completion
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcpv6pd_type
#x   -dhcp6_pd_client_range_duid_enterprise_id
#x       Define the vendor's registered Private Enterprise Number as maintained by IANA.
#x       Available starting with HLT API 3.90. Valid when port_role is 'access';
#x       dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack';
#x       dhcp6_pd_client_range_duid_type is 'duid_en'.
#x   -dhcp6_pd_client_range_duid_type
#x       Define the DHCP unique identifier type.
#x       Available starting with HLT API 3.90. Valid when port_role is 'access';
#x       dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_pd_client_range_duid_vendor_id
#x       Define the vendor-assigned unique ID for this range. This ID is incremented
#x       automatically for each DHCP client.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or
#x       'dual_stack'; dhcp6_pd_client_range_duid_type is 'duid_en'.
#x   -dhcp6_pd_client_range_duid_vendor_id_increment
#x       Define the step to increment the vendor ID for each DHCP client.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack';
#x       dhcp6_pd_client_range_duid_type is 'duid_en'.
#x   -dhcp6_pd_client_range_ia_id
#x       Define the identity association unique ID for this range. This ID is incremented
#x       automatically for each DHCP client.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is '
#x       access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_pd_client_range_ia_id_increment
#x       Define the step used to increment dhcp6_pd_client_range_ia_id for each
#x       DHCP client.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_pd_client_range_ia_t1
#x       Define the suggested time at which the client contacts the server from which
#x       the addresses were obtained to extend the lifetimes of the addresses assigned.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_pd_client_range_ia_t2
#x       Define the suggested time at which the client contacts any available
#x       server to extend the lifetimes of the addresses assigned.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_pd_client_range_ia_type
#x       Define Identity Association Type.
#x       Valid choices are:IAPD, IANA, IATA, IANA_IAPD
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is
#x       'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#n   -dhcp6_pd_client_range_param_request_list
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_pd_client_range_renew_timer
#x       Define the user-defined lease renewal timer. The value is estimated in seconds
#x       and will override the lease renewal timer if it is not zero and is smaller than the server-defined value.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is
#x       'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#n   -dhcp6_pd_client_range_use_vendor_class_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pd_client_range_vendor_class_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_pd_server_range_dns_domain_search_list
#x       Specifies the domain that the client will use when resolving host names with DNS.
#x   -dhcp6_pd_server_range_first_dns_server
#x       The first DNS server associated with this address pool. This is the first DNS
#x       address that will be assigned to any client that is allocated an IP address from this
#x       pool.
#x   -dhcp6_pd_server_range_second_dns_server
#x       The second DNS server associated with this address pool. This is the second (of
#x       two) DNS addresses that will be assigned to any client that is allocated an IP
#x       address from this pool.
#x   -dhcp6_pd_server_range_subnet_prefix
#x       The prefix value used to subnet the addresses specified in the address pool. This
#x       is the subnet prefix length advertised in DHCPv6PD Offer and Reply messages.
#x   -dhcp6_pd_server_range_start_pool_address
#x       The starting IPv6 address for this DHCPv6 address pool.
#x   -dhcp6_pgdata_max_outstanding_requests
#x       The maximum number of requests to be sent by all DHCP clients during session
#x       startup. This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or
#x       'dual_stack'.
#x       Parameter dhcp6_pgdata_override_global_setup_rate is '1'
#x   -dhcp6_pgdata_override_global_setup_rate
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter
#x       applies at the port level.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is
#x       'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x   -dhcp6_pgdata_setup_rate_initial
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter
#x       applies at the port level.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x       Parameter dhcp6_pgdata_override_global_setup_rate is '1'
#n   -dhcp6_pgdata_setup_rate_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_setup_rate_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_pgdata_max_outstanding_releases
#x       The maximum number of requests to be sent by all DHCP clients during session
#x       teardown. This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or
#x       'dual_stack'.
#x       Parameter dhcp6_pgdata_override_global_teardown_rate is '1'
#x   -dhcp6_pgdata_override_global_teardown_rate
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter
#x       applies at the port level.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'
#x   -dhcp6_pgdata_teardown_rate_initial
#x       Description This parameter refers to the DHCPv6 Client Port Group Data.
#x       This parameter applies at the port level.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
#x       Parameter dhcp6_pgdata_override_global_teardown_rate is '1'
#n   -dhcp6_pgdata_teardown_rate_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_teardown_rate_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -hosts_range_ip_outer_prefix
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -hosts_range_ip_prefix_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -hosts_range_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -hosts_range_eui_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -hosts_range_first_eui
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -hosts_range_ip_prefix
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -hosts_range_subnet_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -lease_time_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -lease_time
#x       The duration of an address lease, in seconds, if the client requesting the lease
#x       does not ask for a specific expiration time. The default value is 3600; the
#x       minimum is 300; and the maximum is 30,000,000.
#n   -padi_include_tag
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -pado_include_tag
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -padr_include_tag
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -pads_include_tag
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -re_connect_on_link_up
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -group_ip_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -group_ip_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -start_group_ip
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -igmp_version
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -is_last_subport
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -join_leaves_per_second
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -l4_src_port
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -l4_dst_port
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -l4_flow_number
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -l4_flow_type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -l4_flow_variant
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mc_enable_general_query
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mc_enable_group_specific_query
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mc_enable_immediate_response
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mc_enable_packing
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mc_enable_router_alert
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mc_enable_suppress_reports
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mc_enable_unsolicited
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mc_group_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mc_report_frequency
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -ppp_local_mode
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -ppp_peer_mode
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -enable_delete_config
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -flap_repeat_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -flap_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -switch_duration
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -watch_duration
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -hold_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -cool_off_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dut_assigned_src_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -include_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -sessions_per_vc
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -enable_host_uniq
#x       Enables PPPoE Host-Uniq tag
#x   -host_uniq
#x       Host-Uniq
#x   -multiplier
#x       number of layer instances per parent instance (multiplier)
#
# Return Values:
#    A list containing the pppox client protocol stack handles that were added by the command (if any).
#x   key:pppox_client_handle           value:A list containing the pppox client protocol stack handles that were added by the command (if any).
#    A list containing the pppox server protocol stack handles that were added by the command (if any).
#x   key:pppox_server_handle           value:A list containing the pppox server protocol stack handles that were added by the command (if any).
#    A list containing the pppox server sessions protocol stack handles that were added by the command (if any).
#x   key:pppox_server_sessions_handle  value:A list containing the pppox server sessions protocol stack handles that were added by the command (if any).
#    A list containing the dhcpv6 client protocol stack handles that were added by the command (if any).
#x   key:dhcpv6_client_handle          value:A list containing the dhcpv6 client protocol stack handles that were added by the command (if any).
#    A list containing the dhcpv6 server protocol stack handles that were added by the command (if any).
#x   key:dhcpv6_server_handle          value:A list containing the dhcpv6 server protocol stack handles that were added by the command (if any).
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:handle                        value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    $::SUCCESS | $::FAILURE
#    key:status                        value:$::SUCCESS | $::FAILURE
#    ppp handles
#    key:handles                       value:ppp handles
#    When status is failure, contains more information
#    key:log                           value:When status is failure, contains more information
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) Coded versus functional specification.
#    2) When -handle is provided with the /globals value the arguments that configure global protocol
#    setting accept both multivalue handles and simple values.
#    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#    that configure global settings will only accept simple values. In this situation, these arguments will
#    configure only the settings of the parent device group or the ports associated with the parent topology.
#    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
#
# See Also:
#

proc ::ixiangpf::pppox_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "pppox_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
