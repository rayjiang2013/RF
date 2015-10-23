##Procedure Header
# Name:
#    ixiangpf::pppox_stats
#
# Description:
#    Retrieves statistics for the PPPoX sessions configured on the
#    specified test port or for the PPPoX handle passed in -handle argument.
#
# Synopsis:
#    ixiangpf::pppox_stats
#        [-handle            ANY]
#        [-port_handle       ANY]
#        -mode               CHOICES aggregate
#                            CHOICES session
#                            CHOICES session_dhcpv6pd
#                            CHOICES session_dhcp_hosts
#                            CHOICES session_all
#x       [-source            CHOICES client server]
#n       [-csv_filename      ANY]
#n       [-retry             ANY]
#x       [-execution_timeout NUMERIC
#x                           DEFAULT 1800]
#
# Arguments:
#    -handle
#        The PPPoX handle for which the PPPoX sessions statistics needs to be retrieved.
#        When using IxNetwork the statistics will be retrieved
#        for the port where that handle belongs.
#    -port_handle
#        The port for which the PPPoX sessions statistics needs to be retrieved.
#        Only available when using IxNetwork to retrieve statistics.
#    -mode
#        Specifies statistics retrieval mode as either aggregate for all
#        configured sessions or on a per session basis.
#x   -source
#x       Valid only when a port handle is available
#n   -csv_filename
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -retry
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -execution_timeout
#x       This is the timeout for the function.
#x       The setting is in seconds.
#x       Setting this setting to 60 it will mean that the command must complete in under 60 seconds.
#x       If the command will last more than 60 seconds the command will be terminated by force.
#x       This flag can be used to prevent dead locks occuring in IxNetwork.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                                                              value:$::SUCCESS | $::FAILURE
#    If status is failure, detailed information provided.
#    key:log                                                                 value:If status is failure, detailed information provided.
#    The stats can be used with or without <port_handle>
#    key:AGGREGATE STATS                                                     value:The stats can be used with or without <port_handle>
#    If -handle is specified, the aggregate.* keys that are not prefixed are the pppox per range statistics. If more than one handle is specified, the per range statistics will be prefixed with the handle value. If -handle is not provided, the perRange statistics are not returned.
#    key:PER RANGE STATS                                                     value:If -handle is specified, the aggregate.* keys that are not prefixed are the pppox per range statistics. If more than one handle is specified, the per range statistics will be prefixed with the handle value. If -handle is not provided, the perRange statistics are not returned.
#    The aggregate statistic keys that are not documented as having a 'pppox_handle' prefix will always have the 'N/A' value.
#    key:PER RANGE STATS                                                     value:The aggregate statistic keys that are not documented as having a 'pppox_handle' prefix will always have the 'N/A' value.
#    Aggregate per port statistics will also be returned for the ports on which the pppox handles reside
#    key:PER RANGE STATS                                                     value:Aggregate per port statistics will also be returned for the ports on which the pppox handles reside
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.auth_total_rx                            value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.auth_total_tx                            value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.avg_setup_time                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.chap_auth_chal_rx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.chap_auth_chal_tx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.chap_auth_fail_rx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.chap_auth_fail_tx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.chap_auth_rsp_rx                         value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.chap_auth_rsp_tx                         value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.chap_auth_succ_rx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.chap_auth_succ_tx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.client_max_setup_rate                    value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.code_rej_rx                              value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.code_rej_tx                              value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.connect_success                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.connected                                value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.connecting                               value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.echo_req_rx                              value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.echo_req_tx                              value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.echo_rsp_rx                              value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.echo_rsp_tx                              value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.idle                                     value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.interfaces_in_ppp_negotiation            value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.interfaces_in_pppoe_l2tp_negotiation     value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.interfaces_teardown_rate                 value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipcp_cfg_ack_rx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipcp_cfg_ack_tx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipcp_cfg_nak_rx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipcp_cfg_nak_tx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipcp_cfg_rej_rx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipcp_cfg_rej_tx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipcp_cfg_req_rx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipcp_cfg_req_tx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipv6cp_cfg_ack_rx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipv6cp_cfg_ack_tx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipv6cp_cfg_nak_rx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipv6cp_cfg_nak_tx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipv6cp_cfg_rej_rx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipv6cp_cfg_rej_tx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipv6cp_cfg_req_rx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ipv6cp_cfg_req_tx                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_avg_latency                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_cfg_ack_rx                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_cfg_ack_tx                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_cfg_nak_rx                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_cfg_nak_tx                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_cfg_rej_rx                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_cfg_rej_tx                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_cfg_req_rx                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_cfg_req_tx                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_max_latency                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_min_latency                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_total_msg_rx                         value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.lcp_total_msg_tx                         value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.malformed_ppp_frames_rejected            value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.malformed_ppp_frames_used                value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.max_setup_time                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.min_setup_time                           value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ncp_avg_latency                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ncp_max_latency                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ncp_min_latency                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ncp_total_msg_rx                         value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ncp_total_msg_tx                         value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.num_sessions                             value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.padi_rx                                  value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.padi_timeout                             value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.padi_tx                                  value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pado_rx                                  value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pado_tx                                  value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.padr_rx                                  value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.padr_timeout                             value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.padr_tx                                  value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pads_rx                                  value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pads_tx                                  value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.padt_rx                                  value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.padt_tx                                  value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pap_auth_ack_rx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pap_auth_ack_tx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pap_auth_nak_rx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pap_auth_nak_tx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pap_auth_req_rx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pap_auth_req_tx                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.port_name                                value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ppp_total_bytes_rx                       value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.ppp_total_bytes_tx                       value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pppoe_avg_latency                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pppoe_max_latency                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pppoe_min_latency                        value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pppoe_total_bytes_rx                     value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.pppoe_total_bytes_tx                     value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.sessions_failed                          value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.sessions_up                              value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.sessions_initiated                       value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.success_setup_rate                       value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.teardown_rate                            value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.term_ack_rx                              value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.term_ack_tx                              value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.term_req_rx                              value:Available with IxNetwork
#    Available with IxNetwork
#    key:[<port_handle.>].aggregate.term_req_tx                              value:Available with IxNetwork
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].port_name                                          value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_addresses_discovered                      value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_advertisements_ignored                    value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_advertisements_received                   value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_enabled_interfaces                        value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_rebinds_sent                              value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_releases_sent                             value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_renews_sent                               value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_replies_received                          value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_requests_sent                             value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_sessions_failed                           value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_sessions_initiated                        value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_sessions_succeeded                        value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_setup_success_rate                        value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_solicits_sent                             value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_teardown_fail                             value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_teardown_initiated                        value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcpv6pd_teardown_success                          value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcp_hosts_sessions_failed                         value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcp_hosts_sessions_initiated                      value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    key:[<port_handle.>].dhcp_hosts_sessions_succeeded                      value:Available with IxNetwork when pppox was configured with dhcpv6_hosts_enable 1
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.connect_success                          value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.connected                                value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.interfaces_in_chap_negotiation           value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.interfaces_in_discovery                  value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.interfaces_in_ipcp_negotiation           value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.interfaces_in_ipv6cp_negotiation         value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.interfaces_in_lcp_negotiation            value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.interfaces_in_pap_negotiation            value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.interfaces_in_ppp_negotiation            value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.sessions_failed                          value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.sessions_up                              value:Available with IxNetwork. Only for per range statistics
#    Available with IxNetwork. Only for per range statistics
#    key:[<pppox_handle>].aggregate.sessions_initiated                       value:Available with IxNetwork. Only for per range statistics
#    (Available with IxNetwork only)
#x   key:SESSION STATS                                                       value:(Available with IxNetwork only)
#    "Port Name"
#x   key:session.<session ID>.port_name                                      value:"Port Name"
#    "AC Cookie"
#x   key:session.<session ID>.ac_cookie                                      value:"AC Cookie"
#    "AC System Error Occured"
#x   key:session.<session ID>.ac_system_error                                value:"AC System Error Occured"
#    "AC Generic Error Occured"
#x   key:session.<session ID>.ac_generic_error                               value:"AC Generic Error Occured"
#    "AC Cookie Tag Rx"
#x   key:session.<session ID>.ac_cookie_tag_rx                               value:"AC Cookie Tag Rx"
#    "AC MAC Address"
#x   key:session.<session ID>.ac_mac_addr                                    value:"AC MAC Address"
#    "AC System Error Tag Rx"
#x   key:session.<session ID>.ac_system_error_tag_rx                         value:"AC System Error Tag Rx"
#    "CHAP Authentication Role"
#x   key:session.<session ID>.chap_auth_role                                 value:"CHAP Authentication Role"
#    "DNS Server List"
#x   key:session.<session ID>.dns_server_list                                value:"DNS Server List"
#    "Discovery Start Time"
#x   key:session.<session ID>.discovery_start                                value:"Discovery Start Time"
#    "Discovery End Time"
#x   key:session.<session ID>.discovery_end                                  value:"Discovery End Time"
#    "Generic Error Tag Tx"
#x   key:session.<session ID>.generic_error_tag_tx                           value:"Generic Error Tag Tx"
#    "Host MAC Address"
#x   key:session.<session ID>.host_mac_addr                                  value:"Host MAC Address"
#    "IPv6 Prefix Length"
#x   key:session.<session ID>.ipv6_prefix_len                                value:"IPv6 Prefix Length"
#    "IPv6 Address"
#x   key:session.<session ID>.ipv6_addr                                      value:"IPv6 Address"
#    "IPv6CP Router Advertisement Rx"
#x   key:session.<session ID>.ipv6cp_router_adv_rx                           value:"IPv6CP Router Advertisement Rx"
#    "IPv6CP Router Advertisement Tx"
#x   key:session.<session ID>.ipv6cp_router_adv_tx                           value:"IPv6CP Router Advertisement Tx"
#    "Interface Identifier"
#x   key:session.<session ID>.interface_id                                   value:"Interface Identifier"
#    "Local IP Address"
#x   key:session.<session ID>.local_ip_addr                                  value:"Local IP Address"
#    "Local IPv6 IID"
#x   key:session.<session ID>.local_ipv6_iid                                 value:"Local IPv6 IID"
#    "LCP Protocol Reject Rx"
#x   key:session.<session ID>.lcp_protocol_rej_rx                            value:"LCP Protocol Reject Rx"
#    "LCP Protocol Reject Tx"
#x   key:session.<session ID>.lcp_protocol_rej_tx                            value:"LCP Protocol Reject Tx"
#    "Loopback Detected"
#x   key:session.<session ID>.loopback_detected                              value:"Loopback Detected"
#    "MRU"
#x   key:session.<session ID>.mru                                            value:"MRU"
#    "MTU"
#x   key:session.<session ID>.mtu                                            value:"MTU"
#    "Magic Number Negotiated"
#x   key:session.<session ID>.magic_no_negotiated                            value:"Magic Number Negotiated"
#    "Magic Number Rx"
#x   key:session.<session ID>.magic_no_rx                                    value:"Magic Number Rx"
#    "Magic Number Tx"
#x   key:session.<session ID>.magic_no_tx                                    value:"Magic Number Tx"
#    "Malformed PPPoE Frames Used"
#x   key:session.<session ID>.malformed_pppoe_frames_used                    value:"Malformed PPPoE Frames Used"
#    "Malformed PPPoE Frames Rejected"
#x   key:session.<session ID>.malformed_pppoe_frames_rejected                value:"Malformed PPPoE Frames Rejected"
#    "Negotiation Start Time \[ms\]"
#x   key:session.<session ID>.negotiation_start_ms                           value:"Negotiation Start Time \[ms\]"
#    "Negotiation End Time \[ms\]"
#x   key:session.<session ID>.negotiation_end_ms                             value:"Negotiation End Time \[ms\]"
#    "Peer IPv6 IID"
#x   key:session.<session ID>.peer_ipv6_iid                                  value:"Peer IPv6 IID"
#    "PPPoE Total Bytes Rx"
#x   key:session.<session ID>.pppoe_total_bytes_rx                           value:"PPPoE Total Bytes Rx"
#    "PPPoE Total Bytes Tx"
#x   key:session.<session ID>.pppoe_total_bytes_tx                           value:"PPPoE Total Bytes Tx"
#    "PPP state"
#x   key:session.<session ID>.pppoe_state                                    value:"PPP state"
#    "Range Identifier"
#x   key:session.<session ID>.range_id                                       value:"Range Identifier"
#    "Remote IP Address"
#x   key:session.<session ID>.remote_ip_addr                                 value:"Remote IP Address"
#    "Relay Session ID Tag Rx"
#x   key:session.<session ID>.relay_session_id_tag_rx                        value:"Relay Session ID Tag Rx"
#    "Service Name Error Tag Rx"
#x   key:session.<session ID>.service_name_error_tag_rx                      value:"Service Name Error Tag Rx"
#    "Session ID"
#x   key:session.<session ID>.session_id                                     value:"Session ID"
#    "Vendor Specific Tag Rx"
#x   key:session.<session ID>.vendor_specific_tag_rx                         value:"Vendor Specific Tag Rx"
#    Port Name
#x   key:session.server.<session ID>.port_name                               value:Port Name
#    Lease Name
#    key:session.server.<session ID>.dhcpv6pd_lease_name                     value:Lease Name
#    Offer Count
#x   key:session.server.<session ID>.dhcpv6pd_offer_count                    value:Offer Count
#    Bind Count
#x   key:session.server.<session ID>.dhcpv6pd_bind_count                     value:Bind Count
#    Bind Rapid Commit Count
#x   key:session.server.<session ID>.dhcpv6pd_bind_rapid_commit_count        value:Bind Rapid Commit Count
#    Renew Count
#x   key:session.server.<session ID>.dhcpv6pd_renew_count                    value:Renew Count
#    Release Count
#x   key:session.server.<session ID>.dhcpv6pd_release_count                  value:Release Count
#    Information-Requests Received
#x   key:session.server.<session ID>.dhcpv6pd_information_request_received   value:Information-Requests Received
#    Replies Sent
#x   key:session.server.<session ID>.dhcpv6pd_replies_sent                   value:Replies Sent
#    Lease State
#x   key:session.server.<session ID>.dhcpv6pd_lease_state                    value:Lease State
#    Lease Address
#x   key:session.server.<session ID>.dhcpv6pd_lease_address                  value:Lease Address
#    Valid Time
#x   key:session.server.<session ID>.dhcpv6pd_valid_time                     value:Valid Time
#    Prefered Time
#x   key:session.server.<session ID>.dhcpv6pd_prefered_time                  value:Prefered Time
#    Renew Time
#x   key:session.server.<session ID>.dhcpv6pd_renew_time                     value:Renew Time
#    Rebind Time
#x   key:session.server.<session ID>.dhcpv6pd_rebind_time                    value:Rebind Time
#    Client ID
#x   key:session.server.<session ID>.dhcpv6pd_client_id                      value:Client ID
#    Remote ID
#x   key:session.server.<session ID>.dhcpv6pd_remote_id                      value:Remote ID
#    Port Name
#x   key:session.client.<session ID>.port_name                               value:Port Name
#    Session Name
#x   key:session.client.<session ID>.dhcpv6pd_session_name                   value:Session Name
#    Solicits Sent
#x   key:session.client.<session ID>.dhcpv6pd_solicits_sent                  value:Solicits Sent
#    Advertisements Received
#x   key:session.client.<session ID>.dhcpv6pd_advertisements_received        value:Advertisements Received
#    Advertisements Ignored
#x   key:session.client.<session ID>.dhcpv6pd_advertisements_ignored         value:Advertisements Ignored
#    Requests Sent
#x   key:session.client.<session ID>.dhcpv6pd_requests_sent                  value:Requests Sent
#    Replies Received
#x   key:session.client.<session ID>.dhcpv6pd_replies_received               value:Replies Received
#    Renews Sent
#x   key:session.client.<session ID>.dhcpv6pd_renews_sent                    value:Renews Sent
#    Rebinds Sent
#x   key:session.client.<session ID>.dhcpv6pd_rebinds_sent                   value:Rebinds Sent
#    Releases Sent
#x   key:session.client.<session ID>.dhcpv6pd_releases_sent                  value:Releases Sent
#    IP Prefix
#x   key:session.client.<session ID>.dhcpv6pd_ip_prefix                      value:IP Prefix
#    Gateway Address
#x   key:session.client.<session ID>.dhcpv6pd_gateway_address                value:Gateway Address
#    DNS Server List
#x   key:session.client.<session ID>.dhcpv6pd_dns_server_list                value:DNS Server List
#    Prefix Lease Time
#x   key:session.client.<session ID>.dhcpv6pd_prefix_lease_time              value:Prefix Lease Time
#    Information Requests Sent
#x   key:session.client.<session ID>.dhcpv6pd_onformation_requests_sent      value:Information Requests Sent
#    DNS Search List
#x   key:session.client.<session ID>.dhcpv6pd_dns_search_list                value:DNS Search List
#    Solicits w/ Rapid Commit Sent
#x   key:session.client.<session ID>.dhcpv6pd_solicits_rapid_commit_sent     value:Solicits w/ Rapid Commit Sent
#    Replies w/ Rapid Commit Received
#x   key:session.client.<session ID>.dhcpv6pd_replies_rapid_commit_received  value:Replies w/ Rapid Commit Received
#    Lease w/ Rapid Commit
#x   key:session.client.<session ID>.dhcpv6pd_lease_rapid_commit             value:Lease w/ Rapid Commit
#    Port Name
#x   key:session.hosts.<session ID>.port_name                                value:Port Name
#    Interface Identifier
#x   key:session.hosts.<session ID>.dhcpv6pd_interface_identifier            value:Interface Identifier
#    Range Identifier
#x   key:session.hosts.<session ID>.dhcpv6pd_range_identifier                value:Range Identifier
#    IPv6 Address
#x   key:session.hosts.<session ID>.dhcpv6pd_ipv6_address                    value:IPv6 Address
#    Prefix Length
#x   key:session.hosts.<session ID>.dhcpv6pd_prefix_length                   value:Prefix Length
#    Status
#x   key:session.hosts.<session ID>.dhcpv6pd_status                          value:Status
#    Not supported
#n   key:AGGREGATE STATS                                                     value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.cdn_rx                                   value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.cdn_tx                                   value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.cookie_size_mismatch                     value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.data_seq_mismatch                        value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.duplicate_rx                             value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.ex_ack_rx                                value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.ex_ack_tx                                value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.hello_rx                                 value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.hello_tx                                 value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.hostname_mismatch                        value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.iccn_rx                                  value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.iccn_tx                                  value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.icrp_rx                                  value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.icrp_tx                                  value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.icrq_rx                                  value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.icrq_tx                                  value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.in_order_rx                              value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.l2_sub_layer_mismatch                    value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.l2tp_avg_setup_time                      value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.l2tp_last_avg_latency                    value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.l2tp_last_max_latency                    value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.l2tp_last_min_latency                    value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.l2tp_max_setup_time                      value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.l2tp_min_setup_time                      value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.last_avg_latency                         value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.last_max_latency                         value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.last_min_latency                         value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.lcp_last_avg_latency                     value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.lcp_last_max_latency                     value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.lcp_last_min_latency                     value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.msg_digest_algo_mismatch                 value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.msg_digest_val_mismatch                  value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.ncp_last_avg_latency                     value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.ncp_last_max_latency                     value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.ncp_last_min_latency                     value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.out_of_order_rx                          value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.out_of_win_rx                            value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.relay_session_id_tag_rx                  value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.remote_end_id_mismatch                   value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.report_count                             value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.retransmits                              value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.router_id_mismatch                       value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.scccn_rx                                 value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.scccn_tx                                 value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sccrp_rx                                 value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sccrp_tx                                 value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sccrq_rx                                 value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sccrq_tx                                 value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.service_name_error_tag_rx                value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sess_avg_latency                         value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sess_last_avg_latency                    value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sess_last_max_latency                    value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sess_last_min_latency                    value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sess_max_latency                         value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sess_min_latency                         value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.setup_rate                               value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sli_rx                                   value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.sli_tx                                   value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.stopccn_rx                               value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.stopccn_tx                               value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.test_duration                            value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.total_bytes_rx                           value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.total_bytes_tx                           value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.tun_tx_win_close                         value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.tun_tx_win_open                          value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.tunnels_neg                              value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.tunnels_up                               value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.tx_pkt_acked                             value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.vendor_specific_tag_rx                   value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.wen_rx                                   value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.wen_tx                                   value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.zlb_rx                                   value:Not supported
#    Not supported
#n   key:[<port_handle.>].aggregate.zlb_tx                                   value:Not supported
#    Not available
#n   key:SESSION STATS                                                       value:Not available
#n   key:session.<session ID>.ac_name                                        value:
#n   key:session.<session ID>.ac_offer_rx                                    value:
#n   key:session.<session ID>.auth_id                                        value:
#n   key:session.<session ID>.auth_password                                  value:
#n   key:session.<session ID>.auth_protocol_rx                               value:
#n   key:session.<session ID>.auth_protocol_tx                               value:
#n   key:session.<session ID>.auth_total_rx                                  value:
#n   key:session.<session ID>.auth_total_tx                                  value:
#n   key:session.<session ID>.chap_auth_chal_rx                              value:
#n   key:session.<session ID>.chap_auth_chal_tx                              value:
#n   key:session.<session ID>.chap_auth_fail_rx                              value:
#n   key:session.<session ID>.chap_auth_fail_tx                              value:
#n   key:session.<session ID>.chap_auth_rsp_rx                               value:
#n   key:session.<session ID>.chap_auth_rsp_tx                               value:
#n   key:session.<session ID>.chap_auth_succ_rx                              value:
#n   key:session.<session ID>.chap_auth_succ_tx                              value:
#n   key:session.<session ID>.close_mode                                     value:
#n   key:session.<session ID>.code_rej_rx                                    value:
#n   key:session.<session ID>.code_rej_tx                                    value:
#n   key:session.<session ID>.echo_req_rx                                    value:
#n   key:session.<session ID>.echo_req_tx                                    value:
#n   key:session.<session ID>.echo_rsp_rx                                    value:
#n   key:session.<session ID>.echo_rsp_tx                                    value:
#n   key:session.<session ID>.ipcp_cfg_ack_rx                                value:
#n   key:session.<session ID>.ipcp_cfg_ack_tx                                value:
#n   key:session.<session ID>.ipcp_cfg_nak_rx                                value:
#n   key:session.<session ID>.ipcp_cfg_nak_tx                                value:
#n   key:session.<session ID>.ipcp_cfg_rej_rx                                value:
#n   key:session.<session ID>.ipcp_cfg_rej_tx                                value:
#n   key:session.<session ID>.ipcp_cfg_req_rx                                value:
#n   key:session.<session ID>.ipcp_cfg_req_tx                                value:
#n   key:session.<session ID>.ipcp_state                                     value:
#n   key:session.<session ID>.ipv6cp_cfg_ack_rx                              value:
#n   key:session.<session ID>.ipv6cp_cfg_ack_tx                              value:
#n   key:session.<session ID>.ipv6cp_cfg_nak_rx                              value:
#n   key:session.<session ID>.ipv6cp_cfg_nak_tx                              value:
#n   key:session.<session ID>.ipv6cp_cfg_rej_rx                              value:
#n   key:session.<session ID>.ipv6cp_cfg_rej_tx                              value:
#n   key:session.<session ID>.ipv6cp_cfg_req_rx                              value:
#n   key:session.<session ID>.ipv6cp_cfg_req_tx                              value:
#n   key:session.<session ID>.ipv6cp_state                                   value:
#n   key:session.<session ID>.lcp_cfg_ack_rx                                 value:
#n   key:session.<session ID>.lcp_cfg_ack_tx                                 value:
#n   key:session.<session ID>.lcp_cfg_nak_rx                                 value:
#n   key:session.<session ID>.lcp_cfg_nak_tx                                 value:
#n   key:session.<session ID>.lcp_cfg_rej_rx                                 value:
#n   key:session.<session ID>.lcp_cfg_rej_tx                                 value:
#n   key:session.<session ID>.lcp_cfg_req_rx                                 value:
#n   key:session.<session ID>.lcp_cfg_req_tx                                 value:
#n   key:session.<session ID>.term_ack_rx                                    value:
#n   key:session.<session ID>.term_ack_tx                                    value:
#n   key:session.<session ID>.term_req_rx                                    value:
#n   key:session.<session ID>.term_req_tx                                    value:
#n   key:session.<session ID>.lcp_total_msg_rx                               value:
#n   key:session.<session ID>.lcp_total_msg_tx                               value:
#n   key:session.<session ID>.malformed_ppp_frames_rejected                  value:
#n   key:session.<session ID>.malformed_ppp_frames_used                      value:
#n   key:session.<session ID>.ncp_total_msg_rx                               value:
#n   key:session.<session ID>.ncp_total_msg_tx                               value:
#n   key:session.<session ID>.padi_rx                                        value:
#n   key:session.<session ID>.padi_tx                                        value:
#n   key:session.<session ID>.padi_timeout                                   value:
#n   key:session.<session ID>.pado_rx                                        value:
#n   key:session.<session ID>.pado_tx                                        value:
#n   key:session.<session ID>.padr_rx                                        value:
#n   key:session.<session ID>.padr_tx                                        value:
#n   key:session.<session ID>.padr_timeout                                   value:
#n   key:session.<session ID>.pads_rx                                        value:
#n   key:session.<session ID>.pads_tx                                        value:
#n   key:session.<session ID>.padt_rx                                        value:
#n   key:session.<session ID>.padt_tx                                        value:
#n   key:session.<session ID>.pap_auth_ack_rx                                value:
#n   key:session.<session ID>.pap_auth_ack_tx                                value:
#n   key:session.<session ID>.pap_auth_nak_rx                                value:
#n   key:session.<session ID>.pap_auth_nak_tx                                value:
#n   key:session.<session ID>.pap_auth_req_rx                                value:
#n   key:session.<session ID>.pap_auth_req_tx                                value:
#n   key:session.<session ID>.pppoe_state                                    value:
#n   key:session.<session ID>.ppp_total_bytes_rx                             value:
#n   key:session.<session ID>.ppp_total_bytes_tx                             value:
#n   key:session.<session ID>.service_name                                   value:
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    Coded versus functional specification.
#    1) Session ID will be PPPoE session ID for the case of PPPoE and PPPoEoA.
#    For the case of PPPoA, session ID will be VPI/VCI.
#    2) Per session stats retrieval can take long time.
#    3) Following stats have not been implemented yet:
#    aggregate.disconnecting
#    aggregate.atm_mode
#    aggregate.connect_attempts
#    aggregate.disconnect_success
#    aggregate.sessions_down
#    aggregate.disconnect_failed
#    4) PPPoX implementation using IxTclAccess is NOT SUPPORTED starting from HLTAPI 3.30.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub pppox_stats {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('pppox_stats', $args);
	# ixiahlt::utrackerLog ('pppox_stats', $args);

	return ixiangpf::runExecuteCommand('pppox_stats', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
