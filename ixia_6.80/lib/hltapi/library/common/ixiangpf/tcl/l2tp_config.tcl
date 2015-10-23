##Procedure Header
# Name:
#    ::ixiangpf::l2tp_config
#
# Description:
#    Configures L2TPoE and L2TPoA sessions and tunnels for the specified test
#    port. Each port can have upto 32000 sessions and 32000 tunnels.
#
# Synopsis:
#    ::ixiangpf::l2tp_config
#x       [-return_detailed_handles                        CHOICES 0 1
#x                                                        DEFAULT 0]
#        [-l2_encap                                       CHOICES atm_vc_mux
#                                                         CHOICES atm_snap
#                                                         CHOICES atm_vc_mux_ethernet_ii
#                                                         CHOICES atm_snap_ethernet_ii
#                                                         CHOICES atm_vc_mux_ppp
#                                                         CHOICES atm_snap_ppp
#                                                         CHOICES ethernet_ii
#                                                         CHOICES ethernet_ii_vlan
#                                                         CHOICES ethernet_ii_qinq]
#        [-l2tp_dst_addr                                  IP]
#        [-l2tp_src_addr                                  IP]
#        -mode                                            CHOICES lac lns
#        [-handle                                         ANY]
#        [-port_handle                                    REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-num_tunnels                                    RANGE 0-1024000]
#x       [-delete_attached_ppp                            CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-protocol_name                                  ALPHA]
#        [-attempt_rate                                   RANGE 1-1000]
#        [-auth_mode                                      CHOICES none pap chap pap_or_chap]
#        [-action                                         CHOICES create modify remove
#                                                         DEFAULT create]
#        [-auth_req_timeout                               RANGE 1-65535]
#        [-avp_hide                                       FLAG]
#n       [-avp_rx_connect_speed                           ANY]
#n       [-avp_tx_connect_speed                           ANY]
#        [-config_req_timeout                             RANGE 1-120]
#        [-ctrl_chksum                                    FLAG]
#        [-ctrl_retries                                   RANGE 1-100]
#        [-data_chksum                                    FLAG]
#        [-disconnect_rate                                RANGE 1-1000]
#        [-domain_group_map                               ANY]
#        [-echo_req                                       CHOICES 0 1]
#        [-echo_req_interval                              RANGE 1-65535]
#        [-echo_rsp                                       CHOICES 0 1
#                                                         DEFAULT 1]
#n       [-enable_magic                                   ANY]
#        [-hello_interval                                 RANGE 1-180]
#        [-hello_req                                      FLAG]
#        [-hostname                                       ANY]
#        [-hostname_wc                                    FLAG]
#        [-init_ctrl_timeout                              RANGE 1-20]
#        [-ip_cp                                          CHOICES ipv4_cp ipv6_cp dual_stack
#                                                         DEFAULT ipv4_cp]
#        [-ipcp_req_timeout                               RANGE 1-120]
#        [-l2tp_dst_step                                  IP]
#        [-l2tp_src_count                                 RANGE 1-1024
#                                                         DEFAULT 1]
#        [-l2tp_src_step                                  IP]
#        [-length_bit                                     FLAG]
#        [-max_auth_req                                   RANGE 1-65535]
#        [-max_ctrl_timeout                               RANGE 1-20]
#        [-max_ipcp_req                                   RANGE 1-255
#                                                         DEFAULT 10]
#n       [-max_outstanding                                ANY]
#        [-max_terminate_req                              RANGE 0-1000
#                                                         DEFAULT 10]
#        [-no_call_timeout                                RANGE 1-180
#                                                         DEFAULT 5]
#        [-offset_bit                                     FLAG]
#        [-offset_byte                                    RANGE 0-255]
#        [-offset_len                                     RANGE 0-255]
#        [-password                                       ALPHA]
#        [-password_wc                                    FLAG]
#        [-ppp_client_ip                                  IP]
#        [-ppp_client_step                                IP]
#        [-ppp_server_ip                                  IP]
#n       [-pvc_incr_mode                                  ANY]
#        [-redial                                         FLAG]
#        [-redial_max                                     RANGE 1-65535]
#        [-redial_timeout                                 RANGE 1-20]
#        [-rws                                            RANGE 1-2048]
#        [-secret                                         ANY]
#        [-secret_wc                                      FLAG]
#        [-sequence_bit                                   FLAG]
#n       [-sess_distribution                              ANY]
#n       [-session_id_start                               ANY]
#        [-sessions_per_tunnel                            RANGE 1-64000
#                                                         DEFAULT 1]
#n       [-terminate_req_timeout                          ANY]
#        [-tun_auth                                       CHOICES authenticate_hostname
#                                                         CHOICES tunnel_authentication_disabled]
#n       [-tun_distribution                               ANY]
#n       [-tunnel_id_start                                ANY]
#        [-udp_dst_port                                   RANGE 1-65535]
#        [-udp_src_port                                   RANGE 1-65535]
#        [-username                                       ALPHA]
#        [-username_wc                                    FLAG]
#n       [-vci                                            ANY]
#n       [-vci_count                                      ANY]
#n       [-vci_step                                       ANY]
#        [-vlan_count                                     RANGE 1-4094
#                                                         DEFAULT 4094]
#        [-vlan_id                                        RANGE 0-4095
#                                                         DEFAULT 1]
#        [-vlan_id_step                                   RANGE 0-4093
#                                                         DEFAULT 1]
#        [-vlan_user_priority                             RANGE 0-7
#                                                         DEFAULT 0]
#n       [-vpi                                            ANY]
#n       [-vpi_count                                      ANY]
#n       [-vpi_step                                       ANY]
#        [-wildcard_bang_end                              RANGE 0-65535]
#        [-wildcard_bang_start                            RANGE 0-65535]
#        [-wildcard_dollar_end                            RANGE 0-65535]
#        [-wildcard_dollar_start                          RANGE 0-65535]
#        [-wildcard_pound_end                             RANGE 0-65535]
#        [-wildcard_pound_start                           RANGE 0-65535]
#        [-wildcard_question_end                          RANGE 0-65535]
#        [-wildcard_question_start                        RANGE 0-65535]
#n       [-addr_count_per_vci                             ANY]
#n       [-addr_count_per_vpi                             ANY]
#x       [-address_per_vlan                               RANGE 1-1000000000
#x                                                        DEFAULT 1]
#x       [-bearer_capability                              CHOICES digital analog both]
#x       [-bearer_type                                    CHOICES digital analog]
#x       [-dhcpv6_hosts_enable                            CHOICES 0 1
#x                                                        DEFAULT 0]
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
#x       [-dhcp6_pgdata_max_outstanding_releases          RANGE 1-100000
#x                                                        DEFAULT 500]
#x       [-dhcp6_pgdata_max_outstanding_requests          RANGE 1-100000
#x                                                        DEFAULT 20]
#x       [-dhcp6_pgdata_override_global_setup_rate        CHOICES 0 1
#x                                                        DEFAULT 0]
#x       [-dhcp6_pgdata_override_global_teardown_rate     CHOICES 0 1
#x                                                        DEFAULT 0]
#n       [-dhcp6_pgdata_setup_rate_increment              ANY]
#x       [-dhcp6_pgdata_setup_rate_initial                RANGE 1-100000
#x                                                        DEFAULT 10]
#n       [-dhcp6_pgdata_setup_rate_max                    ANY]
#n       [-dhcp6_pgdata_teardown_rate_increment           ANY]
#x       [-dhcp6_pgdata_teardown_rate_initial             RANGE 1-100000
#x                                                        DEFAULT 50]
#n       [-dhcp6_pgdata_teardown_rate_max                 ANY]
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
#n       [-dhcp6_global_setup_rate_increment              ANY]
#x       [-dhcp6_global_setup_rate_initial                RANGE 1-100000
#x                                                        DEFAULT 10]
#n       [-dhcp6_global_setup_rate_max                    ANY]
#x       [-dhcp6_global_sol_max_rc                        RANGE 1-100
#x                                                        DEFAULT 3]
#x       [-dhcp6_global_sol_max_rt                        RANGE 1-10000
#x                                                        DEFAULT 120]
#x       [-dhcp6_global_sol_timeout                       RANGE 1-100
#x                                                        DEFAULT 4]
#n       [-dhcp6_global_teardown_rate_increment           ANY]
#x       [-dhcp6_global_teardown_rate_initial             RANGE 1-100000
#x                                                        DEFAULT 50]
#n       [-dhcp6_global_teardown_rate_max                 ANY]
#n       [-dhcp6_global_wait_for_completion               ANY]
#n       [-hosts_range_count                              ANY]
#n       [-hosts_range_eui_increment                      ANY]
#n       [-hosts_range_first_eui                          ANY]
#n       [-hosts_range_ip_prefix                          ANY]
#n       [-hosts_range_subnet_count                       ANY]
#x       [-dhcp6_pd_server_range_dns_domain_search_list   ANY]
#x       [-dhcp6_pd_server_range_first_dns_server         IP]
#n       [-hosts_range_ip_outer_prefix                    ANY]
#n       [-hosts_range_ip_prefix_addr                     ANY]
#x       [-dhcp6_pd_server_range_second_dns_server        IP]
#x       [-dhcp6_pd_server_range_subnet_prefix            NUMERIC]
#x       [-dhcp6_pd_server_range_start_pool_address       IP
#x                                                        DEFAULT ::0]
#n       [-lease_time_max                                 ANY]
#        [-lease_time                                     RANGE 300-30000000
#                                                         DEFAULT 3600]
#x       [-framing_capability                             CHOICES sync async both]
#x       [-inner_address_per_vlan                         RANGE 1-1000000000
#x                                                        DEFAULT 1]
#x       [-inner_vlan_count                               RANGE 1-4094
#x                                                        DEFAULT 4094]
#x       [-inner_vlan_id                                  RANGE 0-4095
#x                                                        DEFAULT 1]
#x       [-inner_vlan_id_step                             RANGE 0-4093
#x                                                        DEFAULT 1]
#x       [-inner_vlan_user_priority                       RANGE 0-7
#x                                                        DEFAULT 0]
#x       [-ipv6_pool_addr_prefix_len                      RANGE 0-128
#x                                                        DEFAULT 64]
#x       [-ipv6_pool_prefix                               ANY]
#x       [-ipv6_pool_prefix_len                           RANGE 1-127
#x                                                        DEFAULT 48]
#x       [-max_configure_req                              RANGE 1-255
#x                                                        DEFAULT 10]
#x       [-number_of_sessions                             RANGE 1-9216000]
#x       [-ppp_client_iid                                 IPV6
#x                                                        DEFAULT 00:11:11:11:00:00:00:01]
#x       [-ppp_client_iid_step                            IPV6
#x                                                        DEFAULT 00:00:00:00:00:00:00:01]
#x       [-ppp_server_iid                                 IPV6
#x                                                        DEFAULT 00:11:22:11:00:00:00:01]
#n       [-proxy                                          ANY]
#n       [-enable_term_req_timeout                        ANY]
#x       [-src_mac_addr                                   MAC]
#n       [-src_mac_addr_auto                              ANY]
#x       [-l2tp_src_gw                                    IP]
#x       [-l2tp_src_gw_step                               IP]
#x       [-l2tp_src_gw_incr_mode                          CHOICES per_subnet per_interface
#x                                                        DEFAULT per_subnet]
#x       [-l2tp_src_prefix_len                            RANGE 0-32
#x                                                        DEFAULT 16]
#n       [-avp_framing_type                               ANY]
#n       [-ppp_server_step                                ANY]
#n       [-vlan_user_priority_count                       ANY]
#n       [-vlan_user_priority_step                        ANY]
#n       [-avp_hide_list                                  ANY]
#n       [-l2tp_dst_count                                 ANY]
#x       [-lns_host_name                                  ANY]
#x       [-accept_any_auth_value                          CHOICES 0 1]
#x       [-dns_server_list                                ANY]
#x       [-send_dns_options                               CHOICES 0 1]
#x       [-lcp_accm                                       NUMERIC]
#x       [-lcp_enable_accm                                CHOICES 0 1]
#x       [-enable_mru_negotiation                         CHOICES 0 1]
#x       [-desired_mru_rate                               RANGE 64-10000]
#x       [-server_dns_options                             CHOICES accept_requested_addresses
#x                                                        CHOICES accept_only_requested_primary_address
#x                                                        CHOICES supply_primary_and_secondary
#x                                                        CHOICES supply_primary_only
#x                                                        CHOICES disable_extension]
#x       [-ppp_local_iid_step                             NUMERIC]
#x       [-ppp_local_ip_step                              IPV4]
#x       [-server_ipv4_ncp_configuration                  CHOICES serveronly clientmay]
#x       [-server_netmask                                 IPV4]
#x       [-server_netmask_options                         CHOICES accept_requested_netmask
#x                                                        CHOICES supply_netmask
#x                                                        CHOICES disable_extension]
#x       [-server_primary_dns_address                     IPV4]
#x       [-server_secondary_dns_address                   IPV4]
#x       [-enable_server_signal_iwf                       CHOICES 0 1]
#x       [-enable_server_signal_loop_char                 CHOICES 0 1]
#x       [-enable_server_signal_loop_encap                CHOICES 0 1]
#x       [-enable_server_signal_loop_id                   CHOICES 0 1]
#x       [-server_ipv6_ncp_configuration                  CHOICES serveronly clientmay]
#x       [-server_wins_options                            CHOICES accept_requested_addresses
#x                                                        CHOICES accept_only_requested_primary_address
#x                                                        CHOICES supply_primary_and_secondary
#x                                                        CHOICES supply_primary_only
#x                                                        CHOICES disable_extension]
#x       [-server_wins_primary_address                    IPV4]
#x       [-server_wins_secondary_address                  IPV4]
#x       [-enable_domain_groups                           CHOICES 0 1]
#x       [-chap_name                                      ALPHA]
#x       [-chap_secret                                    ALPHA]
#x       [-client_dns_options                             CHOICES request_primary_and_secondary
#x                                                        CHOICES request_primary_only
#x                                                        CHOICES accept_addresses_from_server
#x                                                        CHOICES accept_only_primary_address_from_server
#x                                                        CHOICES disable_extension]
#x       [-client_ipv4_ncp_configuration                  CHOICES learned request]
#x       [-client_netmask                                 IPV4]
#x       [-client_netmask_options                         CHOICES request_specific_netmask
#x                                                        CHOICES accept_netmask_from_server
#x                                                        CHOICES disable_extension]
#x       [-client_primary_dns_address                     IPV4]
#x       [-client_secondary_dns_address                   IPV4]
#x       [-client_ipv6_ncp_configuration                  CHOICES learned request]
#x       [-client_wins_options                            CHOICES request_primaryandsecondary_wins
#x                                                        CHOICES request_primaryonly_wins
#x                                                        CHOICES accept_addresses_from_server
#x                                                        CHOICES accept_only_primary_address_from_server
#x                                                        CHOICES disable_extension]
#x       [-client_wins_primary_address                    IPV4]
#x       [-client_wins_secondary_address                  IPV4]
#x       [-manual_gateway_mac                             MAC]
#x       [-resolve_gateway                                CHOICES 0 1]
#x       [-enable_exclude_hdlc                            CHOICES 0 1]
#
# Arguments:
#x   -return_detailed_handles
#x       This argument determines if individual interface, session or router handles are returned by the current command.
#x       This applies only to the command on which it is specified.
#x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
#x       decrease the size of command results and speed up script execution.
#x       The default is 0, meaning only protocol stack handles will be returned.
#    -l2_encap
#        Encapsulation type for the ATM and ethernet.Valid options are:
#        atm_vc_mux
#        atm_snap
#        atm_vc_mux_ethernet_ii
#        atm_snap_ethernet_ii
#        atm_vc_mux_ppp
#        atm_snap_ppp
#        ethernet_ii
#        ethernet_ii_vlan
#        ethernet_ii_qinq
#    -l2tp_dst_addr
#        Base Destination IPv4 address to be used for setting up tunnel.
#    -l2tp_src_addr
#        Base IPv4 address to be used for the local IP interface on the port.
#    -mode
#        Whether port will be acting as a LAC or LNS.
#    -handle
#        L2tp handle of a configuration to be modified or removed.
#        Dependencies: only available when IxNetwork is used for the L2tp configuration.
#    -port_handle
#        The port on which the L2TP sessions and tunnels are to be created.
#    -num_tunnels
#        Number of tunnels to be configured on the port.
#x   -delete_attached_ppp
#x       If 1, remove the attached device group (pppoxclient) for the LAC.This parameter is available only for -action remove.
#x   -protocol_name
#    -attempt_rate
#        Specifies the rate in attempts/second at which attempts are made to
#        bring up sessions.
#    -auth_mode
#        Authentication mode.Valid choices are:
#        none
#        pap
#        chap
#        pap_or_chap - Accept both pap and chap offered by DUT. This parameter is available only for -action create.
#    -action
#        The action mode for configuring L2tp. Valid choices are:
#        create
#        modify
#        remove
#    -auth_req_timeout
#        Specifies the timeout value in seconds for acknowledgement of an
#        authentication Request. This parameter is available only for -action create.
#    -avp_hide
#        Enable hiding of the AVPs in the L2TP control messages.
#n   -avp_rx_connect_speed
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -avp_tx_connect_speed
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -config_req_timeout
#        Specifies the timeout value in seconds for acknowledgement of a
#        Configure Request or Terminate Request. This parameter is available only for -action create.
#    -ctrl_chksum
#        Enable sending the valid UDP checksum in the L2TP control messages.
#    -ctrl_retries
#        Number of times to retry a L2TP control message.
#    -data_chksum
#        Enable sending the valid UDP checksum in the L2TP data messages.
#    -disconnect_rate
#        Specifies the rate in disconnects/s at which sessions are
#        disconnected.
#    -domain_group_map
#        List of domain group to LNS IP mapping.
#        Each domain group can have thousands of domains.
#        With the help of domain group it is very easy to map thousands of
#        domains to one or more LNS IP addresses.
#        When using IxNetwork:
#        The domain group list is defined as:
#        { { IP_list_definition } { { domain_name } { lnsIP1index lnsIP2index
#        ... } } }.
#        Where:
#        IP_list_definition is defined as:
#        { ip_count starting_ip increment_step incremented_byte }
#        ip_count <1-65535> : the number of LNS IPs.
#        starting_ip <IPv4> : base LNS IP.
#        increment_step <NUMERIC> : the step used to increment the LNS IP.
#        incremented_byte <1-4> : the byte of the LNS IP to be incremented.
#        domain_name is defined as:
#        { base_name wc wc_width wc_count wc_repeat trailing_name}
#        base_name <STRING> : name to be used for the domain(s).
#        wc {1|0} : enables wildcard substitution in the name field. If this
#        is set to 0, the rest of the following values
#        are ignored.
#        wc_width <0-65535> : defines the number of digits in the generated portion of
#        the domain name, and the first value to use in the
#        generated portion of the domain name. For example,
#        a wc_width of 001 will cause the generated portion
#        of the domain name to be three digits wide, with
#        the first value being 001. If the Base Name is mycompany,
#        the first generated domain name will be mycompany001.
#        The width of the generated portion is preserved when
#        values are incremented, so the next domains generated
#        will be mycompany002, mycompany003, and so forth.
#        wc_count <1-32000> : the number of iterations of the numerical field -
#        used for the name substitution
#        wc_repeat <1-32000> : the number of times the id is repreated before
#        passing to the next value - used for the name
#        substitution
#        trailing_name <STRING> : the string appended after the numerical
#        substitution part of the domain name.
#        lnsIPindex : The index of the LNS IP address from the IP list defined
#        in the IP_list_definition section.
#    -echo_req
#        When set to 1, enables Echo Requests, when set to 0, disables Echo
#        Requests.
#    -echo_req_interval
#        Specifies the time interval in seconds for sending LCP echo
#        requests. Valid only if -echo_req is set to 1. This parameter is available only for -action create.
#    -echo_rsp
#        When set to 0, disabled sending of the echo Responses, when set to
#        1, enables Echo Replies. Default enabled. This can be used to do
#        some negative testing. This parameter is available only for -action create.
#n   -enable_magic
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -hello_interval
#        Time interval between sending of the hello request. Only applicable
#        if the -hello_req is set to 1.
#    -hello_req
#        Enable sending of the hello request.
#    -hostname
#        The LAC Hostname to be used during the tunnel setup. Note that a range of
#        hostname can be setup using the autoincrement feature. See
#        option -hostname_wc.
#    -hostname_wc
#        Enables wildcard substitution in the hostname field.
#    -init_ctrl_timeout
#        Initial timeout for L2TP control message.
#    -ip_cp
#        Valid choices are:
#        ipv4_cp -
#        ipv6_cp -
#        dual_stack -
#    -ipcp_req_timeout
#        Specifies the timeout value in seconds for acknowledgement of an
#        IPCP configure request. This parameter is available only for -action create.
#    -l2tp_dst_step
#        The modifier for the l2tp destination address for multiple destination
#        addresses.
#    -l2tp_src_count
#        Number of source IP addresses to simulate on the port.
#    -l2tp_src_step
#        The modifier for the l2tp source address for multiple source addresses.
#    -length_bit
#        Enable sending of the length field in the L2TP data messages.
#    -max_auth_req
#        Specifies the maximum number of authentication requests that can be
#        sent without getting an authentication response from the DUT or if
#        getting a negative authentication response. This parameter is available only for -action create.
#    -max_ctrl_timeout
#        Maximum timeout for L2TP control message.
#    -max_ipcp_req
#        Specifies the maximum number of IPCP configure requests that can be
#        sent without getting an ack from the DUT.
#        The range is 1-255. This parameter is available only for -action create.
#n   -max_outstanding
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -max_terminate_req
#        Specifies the maximum number of Terminate Requests that can be sent
#        without acknowledgement. This parameter is available only for -action create.
#        The range is 0-1000.
#    -no_call_timeout
#        Number of seconds to wait before tearing down the tunnels when
#        the last sesision on the tunnel goes down.
#        The range is 1-180.
#    -offset_bit
#        Enable sending of the offset field in the L2TP data messages.
#    -offset_byte
#        This is the value inserted in the offset field, if enabled
#        by -offset_bit and -offset_len option.
#    -offset_len
#        If the -offset_bit is set to 1, this option controls number of
#        bytes (specified by the -offset_byte option) to be inserted in after
#        the L2TP data message header.
#    -password
#        Password, PAP, and CHAP only.
#    -password_wc
#        Enables wildcard substituation in the password field.
#    -ppp_client_ip
#        Base IP address of the client IP pool allocated by the LNS. Only
#        valid if the mode option is set lns. For IPv6 this is the client IID.
#        The value will be the formed from the least significant 64 bits of the
#        IPv6 address provided. This parameter is available only for -action create.
#    -ppp_client_step
#        Step size to use for allocating client IP addresses. Only
#        valid if the mode option is set lns. This parameter is available only for -action create.
#    -ppp_server_ip
#        Local IP address of the PPP server. Only valid if the mode is lns.
#        For IPv6 this is the server IID.
#        The value will be the formed from the least significant 64 bits of the
#        IPv6 address provided. This parameter is available only for -action create.
#n   -pvc_incr_mode
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -redial
#        Enable redialling of the session if the session drops after
#        establishment due to any reason other than operator initiated
#        teardown.
#    -redial_max
#        Number of times to redial before declaring it failure.
#    -redial_timeout
#        Number of seconds to wait between successive redial attempts.
#    -rws
#        Receive window size.
#    -secret
#        Secret to be used during the tunnel setup. Note that a range of
#        secret can be setup using the autoincrement feature. See
#        option -secret_wc.
#    -secret_wc
#        Enables wildcard substitution in the secret field.
#    -sequence_bit
#        Enable sequence numbering for the L2TP data messages.
#n   -sess_distribution
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -session_id_start
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -sessions_per_tunnel
#        Number of sessions per tunnel.
#        The range is 1-16000.
#n   -terminate_req_timeout
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -tun_auth
#        Enable tunnel authentication during the tunnel setup.
#n   -tun_distribution
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -tunnel_id_start
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -udp_dst_port
#        Destination UDP port to be used for tunnels setup.
#    -udp_src_port
#        Source UDP port to be used for tunnels setup.
#    -username
#        Username, PAP, and CHAP only.
#    -username_wc
#        Enables wildcard substitution in the username field.
#n   -vci
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -vlan_count
#        Number of VLAN IDs, applies to L2TPoE only and if -l2_encap is set to
#        ethernet_ii_vlan.
#    -vlan_id
#        Starting VLAN ID, applies to L2TPoE only and if -l2_encap is set to
#        ethernet_ii_vlan.
#    -vlan_id_step
#        Step value applied to VLAN ID, applies to L2TPo only and if -l2_encap
#        is set to ethernet_ii_vlan.
#    -vlan_user_priority
#        VLAN user priority, applies to L2TPoE only and if -l2_encap is set to
#        ethernet_ii_vlan.
#n   -vpi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -wildcard_bang_end
#        Ending value for wildcard symbol 1 (!) substitution.
#    -wildcard_bang_start
#        Starting value for wildcard symbol 1 (!) substitution.
#    -wildcard_dollar_end
#        Ending value for wildcard symbol 2 ($) substitution.
#    -wildcard_dollar_start
#        Starting value for wildcard symbol 2 ($) substitution.
#    -wildcard_pound_end
#        Ending value for wildcard symbol 1 (\) substitution. It is also
#        valid to useas the substitution symbol.
#    -wildcard_pound_start
#        Starting value for wildcard symbol 1 (\) substitution. It is also
#        valid to useas the substitution symbol.
#    -wildcard_question_end
#        Ending value for wildcard symbol 2 (?) substitution.
#    -wildcard_question_start
#        Starting value for wildcard symbol 2 (?) substitution.
#n   -addr_count_per_vci
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -addr_count_per_vpi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -address_per_vlan
#x       How often a new outer VLAN ID is generated. For example, a value of 10
#x       will cause a new VLAN ID to be used in blocks of 10 IP addresses.
#x   -bearer_capability
#x       Indicates to the DUT the bearer device types for which HLT can
#x       accept incoming calls.
#x   -bearer_type
#x       The device type requested by HLT for outgoing calls.
#x   -dhcpv6_hosts_enable
#x       Valid choices are:
#x       0  Configure standard PPPoE
#x       1  Enable using DHCPv6 hosts behind PPP CPE feature.
#x   -dhcp6_pd_client_range_duid_enterprise_id
#x       Define the vendors registered Private Enterprise Number as maintained by IANA.
#x       Available starting with HLT API 3.90. Valid when port_role is access;
#x       dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack;
#x       dhcp6_pd_client_range_duid_type is duid_en.
#x   -dhcp6_pd_client_range_duid_type
#x       Define the DHCP unique identifier type.
#x       Available starting with HLT API 3.90. Valid when port_role is access;
#x       dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_pd_client_range_duid_vendor_id
#x       Define the vendor-assigned unique ID for this range. This ID is incremented
#x       automatically for each DHCP client.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or
#x       dual_stack; dhcp6_pd_client_range_duid_type is duid_en.
#x   -dhcp6_pd_client_range_duid_vendor_id_increment
#x       Define the step to increment the vendor ID for each DHCP client.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack;
#x       dhcp6_pd_client_range_duid_type is duid_en.
#x   -dhcp6_pd_client_range_ia_id
#x       Define the identity association unique ID for this range. This ID is incremented
#x       automatically for each DHCP client.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is 
#x       access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_pd_client_range_ia_id_increment
#x       Define the step used to increment dhcp6_pd_client_range_ia_id for each
#x       DHCP client.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_pd_client_range_ia_t1
#x       Define the suggested time at which the client contacts the server from which
#x       the addresses were obtained to extend the lifetimes of the addresses assigned.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_pd_client_range_ia_t2
#x       Define the suggested time at which the client contacts any available
#x       server to extend the lifetimes of the addresses assigned.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_pd_client_range_ia_type
#x       Define Identity Association Type.
#x       Valid choices are:IAPD, IANA, IATA, IANA_IAPD
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is
#x       access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#n   -dhcp6_pd_client_range_param_request_list
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_pd_client_range_renew_timer
#x       Define the user-defined lease renewal timer. The value is estimated in seconds
#x       and will override the lease renewal timer if it is not zero and is smaller than the server-defined value.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is
#x       'access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#n   -dhcp6_pd_client_range_use_vendor_class_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pd_client_range_vendor_class_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_pgdata_max_outstanding_releases
#x       The maximum number of requests to be sent by all DHCP clients during session
#x       teardown. This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or
#x       dual_stack.
#x   -dhcp6_pgdata_max_outstanding_requests
#x       The maximum number of requests to be sent by all DHCP clients during session
#x       startup. This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or
#x       dual_stack.
#x   -dhcp6_pgdata_override_global_setup_rate
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter
#x       applies at the port level.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is
#x       access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_pgdata_override_global_teardown_rate
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter
#x       applies at the port level.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack
#n   -dhcp6_pgdata_setup_rate_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_pgdata_setup_rate_initial
#x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter
#x       applies at the port level.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x       Parameter dhcp6_pgdata_override_global_setup_rate is 1
#n   -dhcp6_pgdata_setup_rate_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_teardown_rate_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_pgdata_teardown_rate_initial
#x       Description This parameter refers to the DHCPv6 Client Port Group Data.
#x       This parameter applies at the port level.
#x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
#x       is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x       Parameter dhcp6_pgdata_override_global_teardown_rate is 1
#n   -dhcp6_pgdata_teardown_rate_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_global_echo_ia_info
#x       If 1 the DHCPv6 client will request the exact address as advertised by the server.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x       Valid choices are:
#x       0 - (DEFAULT) Disabled
#x       1 - Enabled
#x   -dhcp6_global_max_outstanding_releases
#x       The maximum number of requests to be sent by all DHCP clients during session
#x       teardown.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_max_outstanding_requests
#x       The maximum number of requests to be sent by all DHCP clients during session
#x       startup.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_reb_max_rt
#x       RFC 3315 max rebind timeout value in seconds.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_reb_timeout
#x       RFC 3315 initial rebind timeout value in seconds.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_rel_max_rc
#x       RFC 3315 release attempts.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_rel_timeout
#x       RFC 3315 initial release timeout in seconds.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_ren_max_rt
#x       RFC 3315 max renew timeout in secons.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_ren_timeout
#x       RFC 3315 initial renew timeout in secons.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_req_max_rc
#x       RFC 3315 max request retry attempts.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_req_max_rt
#x       RFC 3315 max request timeout value in secons.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_req_timeout
#x       RFC 3315 initial request timeout value in secons.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#n   -dhcp6_global_setup_rate_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_global_setup_rate_initial
#x       Setup rate is the number of clients to start in each second. This value
#x       represents the initial value for setup rate.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#n   -dhcp6_global_setup_rate_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_global_sol_max_rc
#x       RFC 3315 max solicit retry attempts.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_sol_max_rt
#x       RFC 3315 max solicit timeout value in seconds.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#x   -dhcp6_global_sol_timeout
#x       RFC 3315 initial solicit timeout value in seconds.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#n   -dhcp6_global_teardown_rate_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_global_teardown_rate_initial
#x       Setup rate is the number of clients to stop in each second. This value
#x       represents the initial value for teardown rate.
#x       This parameter applies globally for all the ports in the configuration.
#x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
#x       Valid when port_role is access; dhcpv6_hosts_enable is 1; ip_cp is ipv6_cp or dual_stack.
#n   -dhcp6_global_teardown_rate_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_global_wait_for_completion
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
#x   -dhcp6_pd_server_range_dns_domain_search_list
#x       Specifies the domain that the client will use when resolving host names with DNS.
#x   -dhcp6_pd_server_range_first_dns_server
#x       The first DNS server associated with this address pool. This is the first DNS
#x       address that will be assigned to any client that is allocated an IP address from this
#x       pool.
#n   -hosts_range_ip_outer_prefix
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -hosts_range_ip_prefix_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_pd_server_range_second_dns_server
#x       The second DNS server associated with this address pool. This is the second (of
#x       two) DNS addresses that will be assigned to any client that is allocated an IP
#x       address from this pool.
#x   -dhcp6_pd_server_range_subnet_prefix
#x       The prefix value used to subnet the addresses specified in the address pool. This
#x       is the subnet prefix length advertised in DHCPv6PD Offer and Reply messages.
#x   -dhcp6_pd_server_range_start_pool_address
#x       The starting IPv6 address for this DHCPv6 address pool.
#n   -lease_time_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -lease_time
#        The duration of an address lease, in seconds, if the client requesting the lease
#        does not ask for a specific expiration time. The default value is 3600; the
#        minimum is 300; and the maximum is 30,000,000.
#x   -framing_capability
#x       Indicates to the DUT the framing types for which HLT can accept
#x       incoming calls.
#x   -inner_address_per_vlan
#x       How often a new inner VLAN ID is generated. For example, a value of 10
#x       will cause a new VLAN ID to be used in blocks of 10 IP addresses, applies to L2TPoE only and if -l2_encap is set to
#x       ethernet_ii_qinq.
#x   -inner_vlan_count
#x       Number of inner VLAN IDs, applies to L2TPoE only and if -l2_encap is set to
#x       ethernet_ii_qinq.
#x   -inner_vlan_id
#x       Starting inner VLAN ID, applies to L2TPoE only and if -l2_encap is set to
#x       ethernet_ii_qinq.
#x   -inner_vlan_id_step
#x       Step value applied to inner VLAN ID, applies to L2TP only and if -l2_encap
#x       is set to ethernet_ii_qinq.
#x   -inner_vlan_user_priority
#x       Inner VLAN user priority, applies to L2TPoE only and if -l2_encap is set to
#x       ethernet_ii_qinq.
#x   -ipv6_pool_addr_prefix_len
#x       The IPv6 address prefix length. This parameter is available only for -action create.
#x   -ipv6_pool_prefix
#x       The IPv6 pool prefix.
#x   -ipv6_pool_prefix_len
#x       The IPv6 pool prefix length. Subtracting this from the address prefix
#x       length provides the size of the PPP IP pool. This parameter is available only for -action create.
#x       The range is 1-127.
#x   -max_configure_req
#x       The number of retries to be used for LCP negotiation.
#x       Any integer value may be used. This parameter is available only for -action create.
#x       The range is 1-255.
#x   -number_of_sessions
#x       Valid only for IxNetwork. If this parameter is specified, then the
#x       num_tunnels parameter will be ignored. This allows to specify then
#x       number of sessions to be created(usefull if sessions_per_tunnel
#x       number is not diving exaclty with the number of sessions).
#x   -ppp_client_iid
#x       Base IP address of the client IP pool allocated by the LNS. Only
#x       valid if the mode option is set lns. For DualStack this is the client IID.
#x       The value will be the formed from the least significant 64 bits of the
#x       IPv6 address provided. This parameter is available only for -action create.
#x   -ppp_client_iid_step
#x       Step size to use for allocating client IP addresses. Only
#x       valid if the mode option is set lns. This parameter is available only for -action create.
#x   -ppp_server_iid
#x       Local IP address of the PPP server. Only valid if the mode is lns.
#x       For DualStack this is the server IID.
#x       The value will be the formed from the least significant 64 bits of the
#x       IPv6 address provided. This parameter is available only for -action create.
#n   -proxy
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -enable_term_req_timeout
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -src_mac_addr
#x       This is used to specify the MAC address on the access endpoints. If it
#x       is missing, if an interface with the same IP as the one on the access
#x       endpoint exists, its MAC address will be used, if not the MAC address
#x       will be generated by the following rule:
#x       00:chassis:card:port:endpoint:01
#n   -src_mac_addr_auto
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -l2tp_src_gw
#x       This is used to specify the endpoint's gateway address, which can be
#x       different from the tunnel destination. If this attribute is not
#x       specified, the tunnel destination's IP will be used as gateway.
#x   -l2tp_src_gw_step
#x       This is used to specify the step of the endpoint's gateway address.
#x       Valid only for IxTclNetwork API.
#x   -l2tp_src_gw_incr_mode
#x       This is used to specify the mode of incrementing the gateway address.
#x       Valid only for IxTclNetwork API.
#x   -l2tp_src_prefix_len
#x       This is used to specify the endpoint's IP address prefix length.
#n   -avp_framing_type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -ppp_server_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vlan_user_priority_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vlan_user_priority_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -avp_hide_list
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -l2tp_dst_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -lns_host_name
#x       L2TP hostname sent by Ixia port when acting as LNS.
#x   -accept_any_auth_value
#x       Configures a PAP/CHAP authenticator to accept all offered usernames, passwords, and base domain names. This parameter is available only for -action create.
#x   -dns_server_list
#x       DNS server list separacted by semicolon. This parameter is available only for -action create.
#x   -send_dns_options
#x       Enable RDNSS routing advertisments. This parameter is available only for -action create.
#x   -lcp_accm
#x       Async-Control-Character-Map. Valid only when lcp_enable_accm is enabled. This parameter is available only for -action create.
#x   -lcp_enable_accm
#x       Enable Async-Control-Character-Map. This parameter is available only for -action create.
#x   -enable_mru_negotiation
#x       Enable MRU Negotiation. This parameter is available only for -action create.
#x   -desired_mru_rate
#x       Max Transmit Unit for PPP. This parameter is available only for -action create.
#x   -server_dns_options
#x       The server DNS options. This parameter is available only for -action create.
#x   -ppp_local_iid_step
#x       Server IPv6CP interface identifier increment, used in conjuction with the base identifier. This parameter is available only for -action create
#x   -ppp_local_ip_step
#x       **For internal use only**.
#x       For PPP/IP v4 server plugins, exactly one server address is used.
#x       As a result, 0.0.0.0 is the only legal value for this property. This parameter is available only for -action create.
#x   -server_ipv4_ncp_configuration
#x       The server ipv4 ncp configuration. This parameter is available only for -action create.
#x   -server_netmask
#x       The server netmask. This parameter is available only for -action create.
#x   -server_netmask_options
#x       Server netmask options. This parameter is available only for -action create.
#x   -server_primary_dns_address
#x       The server primary dns address. This parameter is available only for -action create.
#x   -server_secondary_dns_address
#x       The server secondary dns address. This parameter is available only for -action create.
#x   -enable_server_signal_iwf
#x       This parameter enables the server signal iwf. This parameter is available only for -action create.
#x   -enable_server_signal_loop_char
#x       This parameter enables the server signal loop char. This parameter is available only for -action create.
#x   -enable_server_signal_loop_encap
#x       This parameter enables the server signal loop encapsulation. This parameter is available only for -action create.
#x   -enable_server_signal_loop_id
#x       This parameter enables the server signal loop id. This parameter is available only for -action create.
#x   -server_ipv6_ncp_configuration
#x       The server ipv6 ncp configuration. This parameter is available only for -action create.
#x   -server_wins_options
#x       Server wins options for the primary and secondary addresses. This parameter is available only for -action create.
#x   -server_wins_primary_address
#x       The server wins primary address. This parameter is available only for -action create.
#x   -server_wins_secondary_address
#x       The server wins secondary address. This parameter is available only for -action create.
#x   -enable_domain_groups
#x       Enable domain groups. This parameter is available only for -action create.
#x   -chap_name
#x       User name when CHAP Authentication is being used. This parameter is available only for -action create.
#x   -chap_secret
#x       Secret when CHAP Authentication is being used
#x   -client_dns_options
#x   -client_ipv4_ncp_configuration
#x   -client_netmask
#x   -client_netmask_options
#x   -client_primary_dns_address
#x   -client_secondary_dns_address
#x   -client_ipv6_ncp_configuration
#x   -client_wins_options
#x   -client_wins_primary_address
#x   -client_wins_secondary_address
#x   -manual_gateway_mac
#x       User specified Gateway MAC addresses.
#x   -resolve_gateway
#x       Enable the gateway MAC address discovery.
#x   -enable_exclude_hdlc
#x       If checked, HDLC header is not encoded in the L2TP packets.
#
# Return Values:
#    A list containing the ethernet protocol stack handles that were added by the command (if any).
#x   key:ethernet_handle               value:A list containing the ethernet protocol stack handles that were added by the command (if any).
#    A list containing the ipv4 protocol stack handles that were added by the command (if any).
#x   key:ipv4_handle                   value:A list containing the ipv4 protocol stack handles that were added by the command (if any).
#    A list containing the lac protocol stack handles that were added by the command (if any).
#x   key:lac_handle                    value:A list containing the lac protocol stack handles that were added by the command (if any).
#    A list containing the lns protocol stack handles that were added by the command (if any).
#x   key:lns_handle                    value:A list containing the lns protocol stack handles that were added by the command (if any).
#    A list containing the pppox server sessions protocol stack handles that were added by the command (if any).
#x   key:pppox_server_sessions_handle  value:A list containing the pppox server sessions protocol stack handles that were added by the command (if any).
#    A list containing the pppox server protocol stack handles that were added by the command (if any).
#x   key:pppox_server_handle           value:A list containing the pppox server protocol stack handles that were added by the command (if any).
#    A list containing the pppox client protocol stack handles that were added by the command (if any).
#x   key:pppox_client_handle           value:A list containing the pppox client protocol stack handles that were added by the command (if any).
#    A list containing the dhcpv6 client protocol stack handles that were added by the command (if any).
#x   key:dhcpv6_client_handle          value:A list containing the dhcpv6 client protocol stack handles that were added by the command (if any).
#    A list containing the dhcpv6 server protocol stack handles that were added by the command (if any).
#x   key:dhcpv6_server_handle          value:A list containing the dhcpv6 server protocol stack handles that were added by the command (if any).
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:handle                        value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    $::SUCCESS | $::FAILURE
#    key:status                        value:$::SUCCESS | $::FAILURE
#    <l2tp handles>
#    key:handles                       value:<l2tp handles>
#    When status is failure, contains more information
#    key:log                           value:When status is failure, contains more information
#
# Examples:
#    See files in the Samples/IxNetwork/L2TP subdirectory.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) Coded versus functional specification.
#    2) Sessions might not be distributed as expected over tunnels and the number of
#    tunnels might be different from the what was requested when -mode "lac"
#    in the following particular case:
#    * -tun_distribution domain_group_map
#    * -sess_distribution next
#    * -l2tp_dst_step 0.0.0.0
#    * -num_tunnels  > 1
#    * More than 1 domains are configured in -domain_group_map
#    To avoid this use -sess_distribution "fill". If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
#
# See Also:
#

proc ::ixiangpf::l2tp_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "l2tp_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
