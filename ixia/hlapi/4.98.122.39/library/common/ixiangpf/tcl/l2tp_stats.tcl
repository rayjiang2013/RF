##Procedure Header
# Name:
#    ::ixiangpf::l2tp_stats
#
# Description:
#    Retrieves statistics for the L2TPoX sessions configured on the specified test port.
#
# Synopsis:
#    ::ixiangpf::l2tp_stats
#        -mode               CHOICES aggregate
#                            CHOICES session
#                            CHOICES tunnel
#                            CHOICES session_dhcpv6pd
#                            CHOICES session_dhcp_hosts
#                            CHOICES session_all
#                            DEFAULT aggregate
#        [-port_handle       ANY]
#        [-handle            ANY]
#x       [-source            CHOICES client server]
#x       [-execution_timeout NUMERIC
#x                           DEFAULT 1800]
#
# Arguments:
#    -mode
#        Specifies statistics retrieval mode as either aggregate for all configured sessions or on a per session basis.Valid choices are:
#    -port_handle
#        The port handle for which the L2TPoX sessions statistics needs to be
#        retrieved. Valid only when using IxNetwork.
#    -handle
#        The port for which the L2TPoX sessions statistics needs to be
#        retrieved. The statistics will be retrieved
#        for the port where that handle belongs.
#x   -source
#x       Optional parameter when mode is aggregate and port_handle was provided. If specified this
#x       will represent the type of statistics to be returned. If not specified the client statistics
#x       will be tried to be retrieved and if they are empty (ie.: not lac present on the port)
#x       the server ones (LNS) will be retuned insted.
#x   -execution_timeout
#x       This is the timeout for the function.
#x       The setting is in seconds.
#x       Setting this setting to 60 it will mean that the command must complete in under 60 seconds.
#x       If the command will last more than 60 seconds the command will be terminated by force.
#x       This flag can be used to prevent dead locks occuring in IxNetwork.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                                                         value:$::SUCCESS | $::FAILURE 
#    When status is failure, contains more information
#    key:log                                                            value:When status is failure, contains more information
#    CDN Rx
#    key:port_handle.aggregate.cdn_rx                                   value:CDN Rx
#    CDN Tx
#    key:port_handle.aggregate.cdn_tx                                   value:CDN Tx
#    CHAP Challenge Rx .Only for LAC.
#    key:port_handle.aggregate.chap_auth_chal_rx                        value:CHAP Challenge Rx .Only for LAC.
#    CHAP Challenge Tx .Only for LNS.
#    key:port_handle.aggregate.chap_auth_chal_tx                        value:CHAP Challenge Tx .Only for LNS.
#    CHAP Failure Rx .Only for LAC.
#    key:port_handle.aggregate.chap_auth_fail_rx                        value:CHAP Failure Rx .Only for LAC.
#    CHAP Failure Tx .Only for LNS.
#    key:port_handle.aggregate.chap_auth_fail_tx                        value:CHAP Failure Tx .Only for LNS.
#    CHAP Response Rx .Only for LNS.
#    key:port_handle.aggregate.chap_auth_rsp_rx                         value:CHAP Response Rx .Only for LNS.
#    CHAP Response Tx .Only for LAC.
#    key:port_handle.aggregate.chap_auth_rsp_tx                         value:CHAP Response Tx .Only for LAC.
#    CHAP Success Rx .Only for LAC.
#    key:port_handle.aggregate.chap_auth_succ_rx                        value:CHAP Success Rx .Only for LAC.
#    CHAP Success Tx .Only for LNS.
#    key:port_handle.aggregate.chap_auth_succ_tx                        value:CHAP Success Tx .Only for LNS.
#    Interfaces in PPP Negotiation .Only for LAC.
#    key:port_handle.aggregate.client_interfaces_in_ppp_negotiation     value:Interfaces in PPP Negotiation .Only for LAC.
#    Average Establishment Time (usec) .Only for LAC.
#    key:port_handle.aggregate.client_session_avg_latency               value:Average Establishment Time (usec) .Only for LAC.
#    Maximum Establishment Time (usec) .Only for LAC.
#    key:port_handle.aggregate.client_session_max_latency               value:Maximum Establishment Time (usec) .Only for LAC.
#    Minimum Establishment Time (usec) .Only for LAC.
#    key:port_handle.aggregate.client_session_min_latency               value:Minimum Establishment Time (usec) .Only for LAC.
#    L2TP Tunnels Up .Only for LAC.
#    key:port_handle.aggregate.client_tunnels_up                        value:L2TP Tunnels Up .Only for LAC.
#    LCP Code Reject Rx
#    key:port_handle.aggregate.code_rej_rx                              value:LCP Code Reject Rx
#    LCP Code Reject Tx
#    key:port_handle.aggregate.code_rej_tx                              value:LCP Code Reject Tx
#    L2TP Window Messages Duplicate Rx
#    key:port_handle.aggregate.duplicate_rx                             value:L2TP Window Messages Duplicate Rx
#    LCP Echo Request Rx
#    key:port_handle.aggregate.echo_req_rx                              value:LCP Echo Request Rx
#    LCP Echo Request Tx
#    key:port_handle.aggregate.echo_req_tx                              value:LCP Echo Request Tx
#    LCP Echo Response Rx
#    key:port_handle.aggregate.echo_rsp_rx                              value:LCP Echo Response Rx
#    LCP Echo Response Tx
#    key:port_handle.aggregate.echo_rsp_tx                              value:LCP Echo Response Tx
#    Hello Rx
#    key:port_handle.aggregate.hello_rx                                 value:Hello Rx
#    Hello Tx
#    key:port_handle.aggregate.hello_tx                                 value:Hello Tx
#    ICCN Rx
#    key:port_handle.aggregate.iccn_rx                                  value:ICCN Rx
#    ICCN Tx
#    key:port_handle.aggregate.iccn_tx                                  value:ICCN Tx
#    ICRP Rx
#    key:port_handle.aggregate.icrp_rx                                  value:ICRP Rx
#    ICRP Tx
#    key:port_handle.aggregate.icrp_tx                                  value:ICRP Tx
#    ICRQ Rx
#    key:port_handle.aggregate.icrq_rx                                  value:ICRQ Rx
#    ICRQ Tx
#    key:port_handle.aggregate.icrq_tx                                  value:ICRQ Tx
#    L2TP Window Messages Rx in Sequence
#    key:port_handle.aggregate.in_order_rx                              value:L2TP Window Messages Rx in Sequence
#    Interfaces in PPPoE Negotiation
#    key:port_handle.aggregate.interfaces_in_pppoe_l2tp_negotiation     value:Interfaces in PPPoE Negotiation
#    IPCP Config ACK Rx
#    key:port_handle.aggregate.ipcp_cfg_ack_rx                          value:IPCP Config ACK Rx
#    IPCP Config ACK Tx
#    key:port_handle.aggregate.ipcp_cfg_ack_tx                          value:IPCP Config ACK Tx
#    IPCP Config NAK Rx
#    key:port_handle.aggregate.ipcp_cfg_nak_rx                          value:IPCP Config NAK Rx
#    IPCP Config NAK Tx
#    key:port_handle.aggregate.ipcp_cfg_nak_tx                          value:IPCP Config NAK Tx
#    IPCP Config Reject Rx
#    key:port_handle.aggregate.ipcp_cfg_rej_rx                          value:IPCP Config Reject Rx
#    IPCP Config Reject Tx
#    key:port_handle.aggregate.ipcp_cfg_rej_tx                          value:IPCP Config Reject Tx
#    IPCP Config Request Rx
#    key:port_handle.aggregate.ipcp_cfg_req_rx                          value:IPCP Config Request Rx
#    IPCP Config Request Tx
#    key:port_handle.aggregate.ipcp_cfg_req_tx                          value:IPCP Config Request Tx
#    IPv6CP Config ACK Rx
#    key:port_handle.aggregate.ipv6cp_cfg_ack_rx                        value:IPv6CP Config ACK Rx
#    IPv6CP Config ACK Tx
#    key:port_handle.aggregate.ipv6cp_cfg_ack_tx                        value:IPv6CP Config ACK Tx
#    IPv6CP Config NAK Rx
#    key:port_handle.aggregate.ipv6cp_cfg_nak_rx                        value:IPv6CP Config NAK Rx
#    IPv6CP Config NAK Tx
#    key:port_handle.aggregate.ipv6cp_cfg_nak_tx                        value:IPv6CP Config NAK Tx
#    IPv6CP Config Reject Rx
#    key:port_handle.aggregate.ipv6cp_cfg_rej_rx                        value:IPv6CP Config Reject Rx
#    IPv6CP Config Reject Tx
#    key:port_handle.aggregate.ipv6cp_cfg_rej_tx                        value:IPv6CP Config Reject Tx
#    IPv6CP Config Request Rx
#    key:port_handle.aggregate.ipv6cp_cfg_req_rx                        value:IPv6CP Config Request Rx
#    IPv6CP Config Request Tx
#    key:port_handle.aggregate.ipv6cp_cfg_req_tx                        value:IPv6CP Config Request Tx
#    IPv6CP Router Advertisement Rx .Only for LAC.
#    key:port_handle.aggregate.ipv6cp_router_adv_rx                     value:IPv6CP Router Advertisement Rx .Only for LAC.
#    IPv6CP Router Advertisement Tx .Only for LNS.
#    key:port_handle.aggregate.ipv6cp_router_adv_tx                     value:IPv6CP Router Advertisement Tx .Only for LNS.
#    IPv6CP Router Solicitation Rx .Only for LNS.
#    key:port_handle.aggregate.ipv6cp_router_solicitation_rx            value:IPv6CP Router Solicitation Rx .Only for LNS.
#    L2TP Calls Up
#    key:port_handle.aggregate.l2tp_calls_up                            value:L2TP Calls Up
#    L2TP Tunnel Total Bytes Rx
#    key:port_handle.aggregate.l2tp_tunnel_total_bytes_rx               value:L2TP Tunnel Total Bytes Rx
#    L2TP Tunnel Total Bytes Tx
#    key:port_handle.aggregate.l2tp_tunnel_total_bytes_tx               value:L2TP Tunnel Total Bytes Tx
#    LCP Average Establishment Time (usec)
#    key:port_handle.aggregate.lcp_avg_latency                          value:LCP Average Establishment Time (usec)
#    LCP Configure ACK Rx
#    key:port_handle.aggregate.lcp_cfg_ack_rx                           value:LCP Configure ACK Rx
#    LCP Configure ACK Tx
#    key:port_handle.aggregate.lcp_cfg_ack_tx                           value:LCP Configure ACK Tx
#    LCP Configure NAK Rx
#    key:port_handle.aggregate.lcp_cfg_nak_rx                           value:LCP Configure NAK Rx
#    LCP Configure NAK Tx
#    key:port_handle.aggregate.lcp_cfg_nak_tx                           value:LCP Configure NAK Tx
#    LCP Configure Reject Rx
#    key:port_handle.aggregate.lcp_cfg_rej_rx                           value:LCP Configure Reject Rx
#    LCP Configure Reject Tx
#    key:port_handle.aggregate.lcp_cfg_rej_tx                           value:LCP Configure Reject Tx
#    LCP Configure Request Rx
#    key:port_handle.aggregate.lcp_cfg_req_rx                           value:LCP Configure Request Rx
#    LCP Configure Request Tx
#    key:port_handle.aggregate.lcp_cfg_req_tx                           value:LCP Configure Request Tx
#    LCP Maximum Establishment Time (usec)
#    key:port_handle.aggregate.lcp_max_latency                          value:LCP Maximum Establishment Time (usec)
#    LCP Minimum Establishment Time (usec)
#    key:port_handle.aggregate.lcp_min_latency                          value:LCP Minimum Establishment Time (usec)
#    LCP Protocol Reject Rx
#    key:port_handle.aggregate.lcp_protocol_rej_rx                      value:LCP Protocol Reject Rx
#    LCP Protocol Reject Tx
#    key:port_handle.aggregate.lcp_protocol_rej_tx                      value:LCP Protocol Reject Tx
#    LCP Total Rx
#    key:port_handle.aggregate.lcp_total_msg_rx                         value:LCP Total Rx
#    LCP Total Tx
#    key:port_handle.aggregate.lcp_total_msg_tx                         value:LCP Total Tx
#    IPCP Average Establishment Time (usec)
#    key:port_handle.aggregate.ncp_avg_latency                          value:IPCP Average Establishment Time (usec)
#    IPCP Maximum Establishment Time (usec)
#    key:port_handle.aggregate.ncp_max_latency                          value:IPCP Maximum Establishment Time (usec)
#    IPCP Minimum Establishment Time (usec)
#    key:port_handle.aggregate.ncp_min_latency                          value:IPCP Minimum Establishment Time (usec)
#    NCP Total Rx
#    key:port_handle.aggregate.ncp_total_msg_rx                         value:NCP Total Rx
#    NCP Total Tx
#    key:port_handle.aggregate.ncp_total_msg_tx                         value:NCP Total Tx
#    Sessions Total
#    key:port_handle.aggregate.num_sessions                             value:Sessions Total
#    L2TP Window Messages Rx Out of Order
#    key:port_handle.aggregate.out_of_order_rx                          value:L2TP Window Messages Rx Out of Order
#    L2TP Window Messages Rx Out of Window
#    key:port_handle.aggregate.out_of_win_rx                            value:L2TP Window Messages Rx Out of Window
#    PADI Rx .Only for LNS.
#    key:port_handle.aggregate.padi_rx                                  value:PADI Rx .Only for LNS.
#    PADI Timeouts .Only for LAC.
#    key:port_handle.aggregate.padi_timeouts                            value:PADI Timeouts .Only for LAC.
#    PADI Tx .Only for LAC.
#    key:port_handle.aggregate.padi_tx                                  value:PADI Tx .Only for LAC.
#    PADO Rx .Only for LAC.
#    key:port_handle.aggregate.pado_rx                                  value:PADO Rx .Only for LAC.
#    PADO Tx .Only for LNS.
#    key:port_handle.aggregate.pado_tx                                  value:PADO Tx .Only for LNS.
#    PADR Rx .Only for LNS.
#    key:port_handle.aggregate.padr_rx                                  value:PADR Rx .Only for LNS.
#    PADR Timeouts .Only for LAC.
#    key:port_handle.aggregate.padr_timeouts                            value:PADR Timeouts .Only for LAC.
#    PADR Tx .Only for LAC.
#    key:port_handle.aggregate.padr_tx                                  value:PADR Tx .Only for LAC.
#    PADS Rx .Only for LAC.
#    key:port_handle.aggregate.pads_rx                                  value:PADS Rx .Only for LAC.
#    PADS Tx .Only for LNS.
#    key:port_handle.aggregate.pads_tx                                  value:PADS Tx .Only for LNS.
#    PADT Rx
#    key:port_handle.aggregate.padt_rx                                  value:PADT Rx
#    PADT Tx
#    key:port_handle.aggregate.padt_tx                                  value:PADT Tx
#    PAP Authentication ACK Rx .Only for LAC.
#    key:port_handle.aggregate.pap_auth_ack_rx                          value:PAP Authentication ACK Rx .Only for LAC.
#    PAP Authentication ACK Tx .Only for LNS.
#    key:port_handle.aggregate.pap_auth_ack_tx                          value:PAP Authentication ACK Tx .Only for LNS.
#    PAP Authentication NAK Rx .Only for LAC.
#    key:port_handle.aggregate.pap_auth_nak_rx                          value:PAP Authentication NAK Rx .Only for LAC.
#    PAP Authentication NAK Tx .Only for LNS.
#    key:port_handle.aggregate.pap_auth_nak_tx                          value:PAP Authentication NAK Tx .Only for LNS.
#    PAP Authentication Request Rx .Only for LNS.
#    key:port_handle.aggregate.pap_auth_req_rx                          value:PAP Authentication Request Rx .Only for LNS.
#    PAP Authentication Request Tx .Only for LAC.
#    key:port_handle.aggregate.pap_auth_req_tx                          value:PAP Authentication Request Tx .Only for LAC.
#    PPP Total Bytes Rx
#    key:port_handle.aggregate.ppp_total_bytes_rx                       value:PPP Total Bytes Rx
#    PPP Total Bytes Tx
#    key:port_handle.aggregate.ppp_total_bytes_tx                       value:PPP Total Bytes Tx
#    L2TP Window Messages Retransmitted
#    key:port_handle.aggregate.retransmits                              value:L2TP Window Messages Retransmitted
#    SCCCN Rx
#    key:port_handle.aggregate.scccn_rx                                 value:SCCCN Rx
#    SCCCN Tx
#    key:port_handle.aggregate.scccn_tx                                 value:SCCCN Tx
#    SCCRP Rx
#    key:port_handle.aggregate.sccrp_rx                                 value:SCCRP Rx
#    SCCRP Tx
#    key:port_handle.aggregate.sccrp_tx                                 value:SCCRP Tx
#    SCCRQ Rx
#    key:port_handle.aggregate.sccrq_rx                                 value:SCCRQ Rx
#    SCCRQ Tx
#    key:port_handle.aggregate.sccrq_tx                                 value:SCCRQ Tx
#    Interfaces in PPP Negotiation .Only for LNS.
#    key:port_handle.aggregate.server_interfaces_in_ppp_negotiation     value:Interfaces in PPP Negotiation .Only for LNS.
#    Average Establishment Time (usec) .Only for LNS.
#    key:port_handle.aggregate.server_session_avg_latency               value:Average Establishment Time (usec) .Only for LNS.
#    Maximum Establishment Time (usec) .Only for LNS.
#    key:port_handle.aggregate.server_session_max_latency               value:Maximum Establishment Time (usec) .Only for LNS.
#    Minimum Establishment Time (usec) .Only for LNS.
#    key:port_handle.aggregate.server_session_min_latency               value:Minimum Establishment Time (usec) .Only for LNS.
#    L2TP Tunnels Up .Only for LNS.
#    key:port_handle.aggregate.server_tunnels_up                        value:L2TP Tunnels Up .Only for LNS.
#    Sessions Down
#    key:port_handle.aggregate.sessions_failed                          value:Sessions Down
#    Sessions Not Started
#    key:port_handle.aggregate.sessions_not_started                     value:Sessions Not Started
#    Sessions Up
#    key:port_handle.aggregate.sessions_up                              value:Sessions Up
#    SLI Rx
#    key:port_handle.aggregate.sli_rx                                   value:SLI Rx
#    SLI Tx
#    key:port_handle.aggregate.sli_tx                                   value:SLI Tx
#    StopCCN Rx
#    key:port_handle.aggregate.stopccn_rx                               value:StopCCN Rx
#    StopCCN Tx
#    key:port_handle.aggregate.stopccn_tx                               value:StopCCN Tx
#    Instantaneous Setup Rate .Only for LAC.
#    key:port_handle.aggregate.success_setup_rate                       value:Instantaneous Setup Rate .Only for LAC.
#    Teardown Failed .Only for LAC.
#    key:port_handle.aggregate.teardown_failed                          value:Teardown Failed .Only for LAC.
#    Instantaneous Teardown Rate .Only for LAC.
#    key:port_handle.aggregate.teardown_rate                            value:Instantaneous Teardown Rate .Only for LAC.
#    Teardown Succeeded .Only for LAC.
#    key:port_handle.aggregate.teardown_succeeded                       value:Teardown Succeeded .Only for LAC.
#    LCP Terminate ACK Rx
#    key:port_handle.aggregate.term_ack_rx                              value:LCP Terminate ACK Rx
#    LCP Terminate ACK Tx
#    key:port_handle.aggregate.term_ack_tx                              value:LCP Terminate ACK Tx
#    LCP Terminate Request Rx
#    key:port_handle.aggregate.term_req_rx                              value:LCP Terminate Request Rx
#    LCP Terminate Request Tx
#    key:port_handle.aggregate.term_req_tx                              value:LCP Terminate Request Tx
#    PPPoE TotalBytes Rx
#    key:port_handle.aggregate.total_bytes_rx                           value:PPPoE TotalBytes Rx
#    PPPoE TotalBytes Tx
#    key:port_handle.aggregate.total_bytes_tx                           value:PPPoE TotalBytes Tx
#    L2TP Window Messages Tx Attempt While Close
#    key:port_handle.aggregate.tun_tx_win_close                         value:L2TP Window Messages Tx Attempt While Close
#    L2TP Window Messages Tx Attempt While Open
#    key:port_handle.aggregate.tun_tx_win_open                          value:L2TP Window Messages Tx Attempt While Open
#    L2TP Window Messages ACKed By Peer
#    key:port_handle.aggregate.tx_pkt_acked                             value:L2TP Window Messages ACKed By Peer
#    WEN Rx
#    key:port_handle.aggregate.wen_rx                                   value:WEN Rx
#    WEN Tx
#    key:port_handle.aggregate.wen_tx                                   value:WEN Tx
#    ZLB Rx
#    key:port_handle.aggregate.zlb_rx                                   value:ZLB Rx
#    ZLB Tx
#    key:port_handle.aggregate.zlb_tx                                   value:ZLB Tx
#    CDN Rx
#    key:Device Group #.aggregate.cdn_rx                                value:CDN Rx
#    CDN Tx
#    key:Device Group #.aggregate.cdn_tx                                value:CDN Tx
#    CHAP Challenge Tx .Only for LNS.
#    key:Device Group #.aggregate.chap_auth_chal_tx                     value:CHAP Challenge Tx .Only for LNS.
#    CHAP Failure Tx .Only for LNS.
#    key:Device Group #.aggregate.chap_auth_fail_tx                     value:CHAP Failure Tx .Only for LNS.
#    CHAP Response Rx .Only for LNS.
#    key:Device Group #.aggregate.chap_auth_rsp_rx                      value:CHAP Response Rx .Only for LNS.
#    CHAP Success Tx .Only for LNS.
#    key:Device Group #.aggregate.chap_auth_succ_tx                     value:CHAP Success Tx .Only for LNS.
#    L2TP Tunnels Up
#    key:Device Group #.aggregate.client_tunnels_up                     value:L2TP Tunnels Up
#    LCP Code Reject Rx .Only for LNS.
#    key:Device Group #.aggregate.code_rej_rx                           value:LCP Code Reject Rx .Only for LNS.
#    LCP Code Reject Tx .Only for LNS.
#    key:Device Group #.aggregate.code_rej_tx                           value:LCP Code Reject Tx .Only for LNS.
#    L2TP Window Messages Duplicate Rx
#    key:Device Group #.aggregate.duplicate_rx                          value:L2TP Window Messages Duplicate Rx
#    LCP Echo Request Rx .Only for LNS.
#    key:Device Group #.aggregate.echo_req_rx                           value:LCP Echo Request Rx .Only for LNS.
#    LCP Echo Request Tx .Only for LNS.
#    key:Device Group #.aggregate.echo_req_tx                           value:LCP Echo Request Tx .Only for LNS.
#    LCP Echo Response Rx .Only for LNS.
#    key:Device Group #.aggregate.echo_rsp_rx                           value:LCP Echo Response Rx .Only for LNS.
#    LCP Echo Response Tx .Only for LNS.
#    key:Device Group #.aggregate.echo_rsp_tx                           value:LCP Echo Response Tx .Only for LNS.
#    Hello Rx
#    key:Device Group #.aggregate.hello_rx                              value:Hello Rx
#    Hello Tx
#    key:Device Group #.aggregate.hello_tx                              value:Hello Tx
#    ICCN Rx
#    key:Device Group #.aggregate.iccn_rx                               value:ICCN Rx
#    ICCN Tx
#    key:Device Group #.aggregate.iccn_tx                               value:ICCN Tx
#    ICRP Rx
#    key:Device Group #.aggregate.icrp_rx                               value:ICRP Rx
#    ICRP Tx
#    key:Device Group #.aggregate.icrp_tx                               value:ICRP Tx
#    ICRQ Rx
#    key:Device Group #.aggregate.icrq_rx                               value:ICRQ Rx
#    ICRQ Tx
#    key:Device Group #.aggregate.icrq_tx                               value:ICRQ Tx
#    L2TP Window Messages Rx in Sequence
#    key:Device Group #.aggregate.in_order_rx                           value:L2TP Window Messages Rx in Sequence
#    Interfaces in PPPoE Negotiation .Only for LNS.
#    key:Device Group #.aggregate.interfaces_in_pppoe_l2tp_negotiation  value:Interfaces in PPPoE Negotiation .Only for LNS.
#    IPCP Config ACK Rx .Only for LNS.
#    key:Device Group #.aggregate.ipcp_cfg_ack_rx                       value:IPCP Config ACK Rx .Only for LNS.
#    IPCP Config ACK Tx .Only for LNS.
#    key:Device Group #.aggregate.ipcp_cfg_ack_tx                       value:IPCP Config ACK Tx .Only for LNS.
#    IPCP Config NAK Rx .Only for LNS.
#    key:Device Group #.aggregate.ipcp_cfg_nak_rx                       value:IPCP Config NAK Rx .Only for LNS.
#    IPCP Config NAK Tx .Only for LNS.
#    key:Device Group #.aggregate.ipcp_cfg_nak_tx                       value:IPCP Config NAK Tx .Only for LNS.
#    IPCP Config Reject Rx .Only for LNS.
#    key:Device Group #.aggregate.ipcp_cfg_rej_rx                       value:IPCP Config Reject Rx .Only for LNS.
#    IPCP Config Reject Tx .Only for LNS.
#    key:Device Group #.aggregate.ipcp_cfg_rej_tx                       value:IPCP Config Reject Tx .Only for LNS.
#    IPCP Config Request Rx .Only for LNS.
#    key:Device Group #.aggregate.ipcp_cfg_req_rx                       value:IPCP Config Request Rx .Only for LNS.
#    IPCP Config Request Tx .Only for LNS.
#    key:Device Group #.aggregate.ipcp_cfg_req_tx                       value:IPCP Config Request Tx .Only for LNS.
#    IPv6CP Config ACK Rx .Only for LNS.
#    key:Device Group #.aggregate.ipv6cp_cfg_ack_rx                     value:IPv6CP Config ACK Rx .Only for LNS.
#    IPv6CP Config ACK Tx .Only for LNS.
#    key:Device Group #.aggregate.ipv6cp_cfg_ack_tx                     value:IPv6CP Config ACK Tx .Only for LNS.
#    IPv6CP Config NAK Rx .Only for LNS.
#    key:Device Group #.aggregate.ipv6cp_cfg_nak_rx                     value:IPv6CP Config NAK Rx .Only for LNS.
#    IPv6CP Config NAK Tx .Only for LNS.
#    key:Device Group #.aggregate.ipv6cp_cfg_nak_tx                     value:IPv6CP Config NAK Tx .Only for LNS.
#    IPv6CP Config Reject Rx .Only for LNS.
#    key:Device Group #.aggregate.ipv6cp_cfg_rej_rx                     value:IPv6CP Config Reject Rx .Only for LNS.
#    IPv6CP Config Reject Tx .Only for LNS.
#    key:Device Group #.aggregate.ipv6cp_cfg_rej_tx                     value:IPv6CP Config Reject Tx .Only for LNS.
#    IPv6CP Config Request Rx .Only for LNS.
#    key:Device Group #.aggregate.ipv6cp_cfg_req_rx                     value:IPv6CP Config Request Rx .Only for LNS.
#    IPv6CP Config Request Tx .Only for LNS.
#    key:Device Group #.aggregate.ipv6cp_cfg_req_tx                     value:IPv6CP Config Request Tx .Only for LNS.
#    IPv6CP Router Advertisement Tx .Only for LNS.
#    key:Device Group #.aggregate.ipv6cp_router_adv_tx                  value:IPv6CP Router Advertisement Tx .Only for LNS.
#    IPv6CP Router Solicitation Rx .Only for LNS.
#    key:Device Group #.aggregate.ipv6cp_router_solicitation_rx         value:IPv6CP Router Solicitation Rx .Only for LNS.
#    L2TP Calls Up
#    key:Device Group #.aggregate.l2tp_calls_up                         value:L2TP Calls Up
#    L2TP Tunnel Total Bytes Rx
#    key:Device Group #.aggregate.l2tp_tunnel_total_bytes_rx            value:L2TP Tunnel Total Bytes Rx
#    L2TP Tunnel Total Bytes Tx
#    key:Device Group #.aggregate.l2tp_tunnel_total_bytes_tx            value:L2TP Tunnel Total Bytes Tx
#    LCP Average Establishment Time (usec) .Only for LNS.
#    key:Device Group #.aggregate.lcp_avg_latency                       value:LCP Average Establishment Time (usec) .Only for LNS.
#    LCP Configure ACK Rx .Only for LNS.
#    key:Device Group #.aggregate.lcp_cfg_ack_rx                        value:LCP Configure ACK Rx .Only for LNS.
#    LCP Configure ACK Tx .Only for LNS.
#    key:Device Group #.aggregate.lcp_cfg_ack_tx                        value:LCP Configure ACK Tx .Only for LNS.
#    LCP Configure NAK Rx .Only for LNS.
#    key:Device Group #.aggregate.lcp_cfg_nak_rx                        value:LCP Configure NAK Rx .Only for LNS.
#    LCP Configure NAK Tx .Only for LNS.
#    key:Device Group #.aggregate.lcp_cfg_nak_tx                        value:LCP Configure NAK Tx .Only for LNS.
#    LCP Configure Reject Rx .Only for LNS.
#    key:Device Group #.aggregate.lcp_cfg_rej_rx                        value:LCP Configure Reject Rx .Only for LNS.
#    LCP Configure Reject Tx .Only for LNS.
#    key:Device Group #.aggregate.lcp_cfg_rej_tx                        value:LCP Configure Reject Tx .Only for LNS.
#    LCP Configure Request Rx .Only for LNS.
#    key:Device Group #.aggregate.lcp_cfg_req_rx                        value:LCP Configure Request Rx .Only for LNS.
#    LCP Configure Request Tx .Only for LNS.
#    key:Device Group #.aggregate.lcp_cfg_req_tx                        value:LCP Configure Request Tx .Only for LNS.
#    LCP Maximum Establishment Time (usec) .Only for LNS.
#    key:Device Group #.aggregate.lcp_max_latency                       value:LCP Maximum Establishment Time (usec) .Only for LNS.
#    LCP Minimum Establishment Time (usec) .Only for LNS.
#    key:Device Group #.aggregate.lcp_min_latency                       value:LCP Minimum Establishment Time (usec) .Only for LNS.
#    LCP Protocol Reject Rx .Only for LNS.
#    key:Device Group #.aggregate.lcp_protocol_rej_rx                   value:LCP Protocol Reject Rx .Only for LNS.
#    LCP Protocol Reject Tx .Only for LNS.
#    key:Device Group #.aggregate.lcp_protocol_rej_tx                   value:LCP Protocol Reject Tx .Only for LNS.
#    LCP Total Rx .Only for LNS.
#    key:Device Group #.aggregate.lcp_total_msg_rx                      value:LCP Total Rx .Only for LNS.
#    LCP Total Tx .Only for LNS.
#    key:Device Group #.aggregate.lcp_total_msg_tx                      value:LCP Total Tx .Only for LNS.
#    IPCP Average Establishment Time (usec) .Only for LNS.
#    key:Device Group #.aggregate.ncp_avg_latency                       value:IPCP Average Establishment Time (usec) .Only for LNS.
#    IPCP Maximum Establishment Time (usec) .Only for LNS.
#    key:Device Group #.aggregate.ncp_max_latency                       value:IPCP Maximum Establishment Time (usec) .Only for LNS.
#    IPCP Minimum Establishment Time (usec) .Only for LNS.
#    key:Device Group #.aggregate.ncp_min_latency                       value:IPCP Minimum Establishment Time (usec) .Only for LNS.
#    NCP Total Rx .Only for LNS.
#    key:Device Group #.aggregate.ncp_total_msg_rx                      value:NCP Total Rx .Only for LNS.
#    NCP Total Tx .Only for LNS.
#    key:Device Group #.aggregate.ncp_total_msg_tx                      value:NCP Total Tx .Only for LNS.
#    Sessions Total
#    key:Device Group #.aggregate.num_sessions                          value:Sessions Total
#    L2TP Window Messages Rx Out of Order
#    key:Device Group #.aggregate.out_of_order_rx                       value:L2TP Window Messages Rx Out of Order
#    L2TP Window Messages Rx Out of Window
#    key:Device Group #.aggregate.out_of_win_rx                         value:L2TP Window Messages Rx Out of Window
#    PADI Rx .Only for LNS.
#    key:Device Group #.aggregate.padi_rx                               value:PADI Rx .Only for LNS.
#    PADO Tx .Only for LNS.
#    key:Device Group #.aggregate.pado_tx                               value:PADO Tx .Only for LNS.
#    PADR Rx .Only for LNS.
#    key:Device Group #.aggregate.padr_rx                               value:PADR Rx .Only for LNS.
#    PADS Tx .Only for LNS.
#    key:Device Group #.aggregate.pads_tx                               value:PADS Tx .Only for LNS.
#    PADT Rx .Only for LNS.
#    key:Device Group #.aggregate.padt_rx                               value:PADT Rx .Only for LNS.
#    PADT Tx .Only for LNS.
#    key:Device Group #.aggregate.padt_tx                               value:PADT Tx .Only for LNS.
#    PAP Authentication ACK Tx .Only for LNS.
#    key:Device Group #.aggregate.pap_auth_ack_tx                       value:PAP Authentication ACK Tx .Only for LNS.
#    PAP Authentication NAK Tx .Only for LNS.
#    key:Device Group #.aggregate.pap_auth_nak_tx                       value:PAP Authentication NAK Tx .Only for LNS.
#    PAP Authentication Request Rx .Only for LNS.
#    key:Device Group #.aggregate.pap_auth_req_rx                       value:PAP Authentication Request Rx .Only for LNS.
#    PPP Total Bytes Rx .Only for LNS.
#    key:Device Group #.aggregate.ppp_total_bytes_rx                    value:PPP Total Bytes Rx .Only for LNS.
#    PPP Total Bytes Tx .Only for LNS.
#    key:Device Group #.aggregate.ppp_total_bytes_tx                    value:PPP Total Bytes Tx .Only for LNS.
#    L2TP Window Messages Retransmitted
#    key:Device Group #.aggregate.retransmits                           value:L2TP Window Messages Retransmitted
#    SCCCN Rx
#    key:Device Group #.aggregate.scccn_rx                              value:SCCCN Rx
#    SCCCN Tx
#    key:Device Group #.aggregate.scccn_tx                              value:SCCCN Tx
#    SCCRP Rx
#    key:Device Group #.aggregate.sccrp_rx                              value:SCCRP Rx
#    SCCRP Tx
#    key:Device Group #.aggregate.sccrp_tx                              value:SCCRP Tx
#    SCCRQ Rx
#    key:Device Group #.aggregate.sccrq_rx                              value:SCCRQ Rx
#    SCCRQ Tx
#    key:Device Group #.aggregate.sccrq_tx                              value:SCCRQ Tx
#    Interfaces in PPP Negotiation .Only for LNS.
#    key:Device Group #.aggregate.server_interfaces_in_ppp_negotiation  value:Interfaces in PPP Negotiation .Only for LNS.
#    Average Establishment Time (usec) .Only for LNS.
#    key:Device Group #.aggregate.server_session_avg_latency            value:Average Establishment Time (usec) .Only for LNS.
#    Maximum Establishment Time (usec) .Only for LNS.
#    key:Device Group #.aggregate.server_session_max_latency            value:Maximum Establishment Time (usec) .Only for LNS.
#    Minimum Establishment Time (usec) .Only for LNS.
#    key:Device Group #.aggregate.server_session_min_latency            value:Minimum Establishment Time (usec) .Only for LNS.
#    L2TP Tunnels Up
#    key:Device Group #.aggregate.server_tunnels_up                     value:L2TP Tunnels Up
#    Sessions Down
#    key:Device Group #.aggregate.sessions_failed                       value:Sessions Down
#    Sessions Not Started
#    key:Device Group #.aggregate.sessions_not_started                  value:Sessions Not Started
#    Sessions Up
#    key:Device Group #.aggregate.sessions_up                           value:Sessions Up
#    SLI Rx
#    key:Device Group #.aggregate.sli_rx                                value:SLI Rx
#    SLI Tx
#    key:Device Group #.aggregate.sli_tx                                value:SLI Tx
#    StopCCN Rx
#    key:Device Group #.aggregate.stopccn_rx                            value:StopCCN Rx
#    StopCCN Tx
#    key:Device Group #.aggregate.stopccn_tx                            value:StopCCN Tx
#    LCP Terminate ACK Rx .Only for LNS.
#    key:Device Group #.aggregate.term_ack_rx                           value:LCP Terminate ACK Rx .Only for LNS.
#    LCP Terminate ACK Tx .Only for LNS.
#    key:Device Group #.aggregate.term_ack_tx                           value:LCP Terminate ACK Tx .Only for LNS.
#    LCP Terminate Request Rx .Only for LNS.
#    key:Device Group #.aggregate.term_req_rx                           value:LCP Terminate Request Rx .Only for LNS.
#    LCP Terminate Request Tx .Only for LNS.
#    key:Device Group #.aggregate.term_req_tx                           value:LCP Terminate Request Tx .Only for LNS.
#    PPPoE TotalBytes Rx .Only for LNS.
#    key:Device Group #.aggregate.total_bytes_rx                        value:PPPoE TotalBytes Rx .Only for LNS.
#    PPPoE TotalBytes Tx .Only for LNS.
#    key:Device Group #.aggregate.total_bytes_tx                        value:PPPoE TotalBytes Tx .Only for LNS.
#    L2TP Window Messages Tx Attempt While Close
#    key:Device Group #.aggregate.tun_tx_win_close                      value:L2TP Window Messages Tx Attempt While Close
#    L2TP Window Messages Tx Attempt While Open
#    key:Device Group #.aggregate.tun_tx_win_open                       value:L2TP Window Messages Tx Attempt While Open
#    L2TP Window Messages ACKed By Peer
#    key:Device Group #.aggregate.tx_pkt_acked                          value:L2TP Window Messages ACKed By Peer
#    WEN Rx
#    key:Device Group #.aggregate.wen_rx                                value:WEN Rx
#    WEN Tx
#    key:Device Group #.aggregate.wen_tx                                value:WEN Tx
#    ZLB Rx
#    key:Device Group #.aggregate.zlb_rx                                value:ZLB Rx
#    ZLB Tx
#    key:Device Group #.aggregate.zlb_tx                                value:ZLB Tx
#    CDN Rx
#    key:l2tp_lac.session.row_id.cdn_rx                                 value:CDN Rx
#    CDN Tx
#    key:l2tp_lac.session.row_id.cdn_tx                                 value:CDN Tx
#    L2TP Window Messages Duplicate Rx
#    key:l2tp_lac.session.row_id.duplicate_rx                           value:L2TP Window Messages Duplicate Rx
#    Hello Rx
#    key:l2tp_lac.session.row_id.hello_rx                               value:Hello Rx
#    Hello Tx
#    key:l2tp_lac.session.row_id.hello_tx                               value:Hello Tx
#    ICCN Rx
#    key:l2tp_lac.session.row_id.iccn_rx                                value:ICCN Rx
#    ICCN Tx
#    key:l2tp_lac.session.row_id.iccn_tx                                value:ICCN Tx
#    ICRP Rx
#    key:l2tp_lac.session.row_id.icrp_rx                                value:ICRP Rx
#    ICRP Tx
#    key:l2tp_lac.session.row_id.icrp_tx                                value:ICRP Tx
#    ICRQ Rx
#    key:l2tp_lac.session.row_id.icrq_rx                                value:ICRQ Rx
#    ICRQ Tx
#    key:l2tp_lac.session.row_id.icrq_tx                                value:ICRQ Tx
#    L2TP Window Messages Rx in Sequence
#    key:l2tp_lac.session.row_id.in_order_rx                            value:L2TP Window Messages Rx in Sequence
#    L2TP Calls Up
#    key:l2tp_lac.session.row_id.l2tp_calls_up                          value:L2TP Calls Up
#    L2TP Tunnel Total Bytes Rx
#    key:l2tp_lac.session.row_id.l2tp_tunnel_total_bytes_rx             value:L2TP Tunnel Total Bytes Rx
#    L2TP Tunnel Total Bytes Tx
#    key:l2tp_lac.session.row_id.l2tp_tunnel_total_bytes_tx             value:L2TP Tunnel Total Bytes Tx
#    L2TP Window Messages Rx Out of Order
#    key:l2tp_lac.session.row_id.out_of_order_rx                        value:L2TP Window Messages Rx Out of Order
#    L2TP Window Messages Rx Out of Window
#    key:l2tp_lac.session.row_id.out_of_win_rx                          value:L2TP Window Messages Rx Out of Window
#    L2TP Window Messages Retransmitted
#    key:l2tp_lac.session.row_id.retransmits                            value:L2TP Window Messages Retransmitted
#    SCCCN Rx
#    key:l2tp_lac.session.row_id.scccn_rx                               value:SCCCN Rx
#    SCCCN Tx
#    key:l2tp_lac.session.row_id.scccn_tx                               value:SCCCN Tx
#    SCCRP Rx
#    key:l2tp_lac.session.row_id.sccrp_rx                               value:SCCRP Rx
#    SCCRP Tx
#    key:l2tp_lac.session.row_id.sccrp_tx                               value:SCCRP Tx
#    SCCRQ Rx
#    key:l2tp_lac.session.row_id.sccrq_rx                               value:SCCRQ Rx
#    SCCRQ Tx
#    key:l2tp_lac.session.row_id.sccrq_tx                               value:SCCRQ Tx
#    SLI Rx
#    key:l2tp_lac.session.row_id.sli_rx                                 value:SLI Rx
#    SLI Tx
#    key:l2tp_lac.session.row_id.sli_tx                                 value:SLI Tx
#    L2TP LAC Session Status
#    key:l2tp_lac.session.row_id.status                                 value:L2TP LAC Session Status
#    StopCCN Rx
#    key:l2tp_lac.session.row_id.stopccn_rx                             value:StopCCN Rx
#    StopCCN Tx
#    key:l2tp_lac.session.row_id.stopccn_tx                             value:StopCCN Tx
#    L2TP Window Messages Tx Attempt While Close
#    key:l2tp_lac.session.row_id.tun_tx_win_close                       value:L2TP Window Messages Tx Attempt While Close
#    L2TP Window Messages Tx Attempt While Open
#    key:l2tp_lac.session.row_id.tun_tx_win_open                        value:L2TP Window Messages Tx Attempt While Open
#    L2TP Window Messages ACKed By Peer
#    key:l2tp_lac.session.row_id.tx_pkt_acked                           value:L2TP Window Messages ACKed By Peer
#    WEN Rx
#    key:l2tp_lac.session.row_id.wen_rx                                 value:WEN Rx
#    WEN Tx
#    key:l2tp_lac.session.row_id.wen_tx                                 value:WEN Tx
#    ZLB Rx
#    key:l2tp_lac.session.row_id.zlb_rx                                 value:ZLB Rx
#    ZLB Tx
#    key:l2tp_lac.session.row_id.zlb_tx                                 value:ZLB Tx
#    CDN Rx
#    key:l2tp_lns.session.row_id.cdn_rx                                 value:CDN Rx
#    CDN Tx
#    key:l2tp_lns.session.row_id.cdn_tx                                 value:CDN Tx
#    L2TP Window Messages Duplicate Rx
#    key:l2tp_lns.session.row_id.duplicate_rx                           value:L2TP Window Messages Duplicate Rx
#    Hello Rx
#    key:l2tp_lns.session.row_id.hello_rx                               value:Hello Rx
#    Hello Tx
#    key:l2tp_lns.session.row_id.hello_tx                               value:Hello Tx
#    ICCN Rx
#    key:l2tp_lns.session.row_id.iccn_rx                                value:ICCN Rx
#    ICCN Tx
#    key:l2tp_lns.session.row_id.iccn_tx                                value:ICCN Tx
#    ICRP Rx
#    key:l2tp_lns.session.row_id.icrp_rx                                value:ICRP Rx
#    ICRP Tx
#    key:l2tp_lns.session.row_id.icrp_tx                                value:ICRP Tx
#    ICRQ Rx
#    key:l2tp_lns.session.row_id.icrq_rx                                value:ICRQ Rx
#    ICRQ Tx
#    key:l2tp_lns.session.row_id.icrq_tx                                value:ICRQ Tx
#    L2TP Window Messages Rx in Sequence
#    key:l2tp_lns.session.row_id.in_order_rx                            value:L2TP Window Messages Rx in Sequence
#    L2TP Calls Up
#    key:l2tp_lns.session.row_id.l2tp_calls_up                          value:L2TP Calls Up
#    L2TP Tunnel Total Bytes Rx
#    key:l2tp_lns.session.row_id.l2tp_tunnel_total_bytes_rx             value:L2TP Tunnel Total Bytes Rx
#    L2TP Tunnel Total Bytes Tx
#    key:l2tp_lns.session.row_id.l2tp_tunnel_total_bytes_tx             value:L2TP Tunnel Total Bytes Tx
#    L2TP Window Messages Rx Out of Order
#    key:l2tp_lns.session.row_id.out_of_order_rx                        value:L2TP Window Messages Rx Out of Order
#    L2TP Window Messages Rx Out of Window
#    key:l2tp_lns.session.row_id.out_of_win_rx                          value:L2TP Window Messages Rx Out of Window
#    L2TP Window Messages Retransmitted
#    key:l2tp_lns.session.row_id.retransmits                            value:L2TP Window Messages Retransmitted
#    SCCCN Rx
#    key:l2tp_lns.session.row_id.scccn_rx                               value:SCCCN Rx
#    SCCCN Tx
#    key:l2tp_lns.session.row_id.scccn_tx                               value:SCCCN Tx
#    SCCRP Rx
#    key:l2tp_lns.session.row_id.sccrp_rx                               value:SCCRP Rx
#    SCCRP Tx
#    key:l2tp_lns.session.row_id.sccrp_tx                               value:SCCRP Tx
#    SCCRQ Rx
#    key:l2tp_lns.session.row_id.sccrq_rx                               value:SCCRQ Rx
#    SCCRQ Tx
#    key:l2tp_lns.session.row_id.sccrq_tx                               value:SCCRQ Tx
#    L2TP Tunnels Up
#    key:l2tp_lns.session.row_id.server_tunnels_up                      value:L2TP Tunnels Up
#    Status
#    key:l2tp_lns.session.row_id.session_status                         value:Status
#    SLI Rx
#    key:l2tp_lns.session.row_id.sli_rx                                 value:SLI Rx
#    SLI Tx
#    key:l2tp_lns.session.row_id.sli_tx                                 value:SLI Tx
#    L2TP LNS Session Status
#    key:l2tp_lns.session.row_id.status                                 value:L2TP LNS Session Status
#    StopCCN Rx
#    key:l2tp_lns.session.row_id.stopccn_rx                             value:StopCCN Rx
#    StopCCN Tx
#    key:l2tp_lns.session.row_id.stopccn_tx                             value:StopCCN Tx
#    L2TP Window Messages Tx Attempt While Close
#    key:l2tp_lns.session.row_id.tun_tx_win_close                       value:L2TP Window Messages Tx Attempt While Close
#    L2TP Window Messages Tx Attempt While Open
#    key:l2tp_lns.session.row_id.tun_tx_win_open                        value:L2TP Window Messages Tx Attempt While Open
#    L2TP Window Messages ACKed By Peer
#    key:l2tp_lns.session.row_id.tx_pkt_acked                           value:L2TP Window Messages ACKed By Peer
#    WEN Rx
#    key:l2tp_lns.session.row_id.wen_rx                                 value:WEN Rx
#    WEN Tx
#    key:l2tp_lns.session.row_id.wen_tx                                 value:WEN Tx
#    ZLB Rx
#    key:l2tp_lns.session.row_id.zlb_rx                                 value:ZLB Rx
#    ZLB Tx
#    key:l2tp_lns.session.row_id.zlb_tx                                 value:ZLB Tx
#    AC Cookie
#    key:pppox_client.session.row_id.ac_cookie                          value:AC Cookie
#    AC Cookie Tag Rx
#    key:pppox_client.session.row_id.ac_cookie_tag_rx                   value:AC Cookie Tag Rx
#    AC Generic Error Occured
#    key:pppox_client.session.row_id.ac_generic_error_occured           value:AC Generic Error Occured
#    AC MAC Address
#    key:pppox_client.session.row_id.ac_mac_addr                        value:AC MAC Address
#    ACName
#    key:pppox_client.session.row_id.ac_name                            value:ACName
#    AC Offers Rx
#    key:pppox_client.session.row_id.ac_offers_rx                       value:AC Offers Rx
#    AC System Error Occured
#    key:pppox_client.session.row_id.ac_system_error_occured            value:AC System Error Occured
#    AC System Error Tag Rx
#    key:pppox_client.session.row_id.ac_system_error_tag_rx             value:AC System Error Tag Rx
#    Authentication ID
#    key:pppox_client.session.row_id.auth_id                            value:Authentication ID
#    Authentication Establishment Time (usec)
#    key:pppox_client.session.row_id.auth_latency                       value:Authentication Establishment Time (usec)
#    Authentication Password
#    key:pppox_client.session.row_id.auth_password                      value:Authentication Password
#    Authentication Protocol Rx
#    key:pppox_client.session.row_id.auth_protocol_rx                   value:Authentication Protocol Rx
#    Authentication Protocol Tx
#    key:pppox_client.session.row_id.auth_protocol_tx                   value:Authentication Protocol Tx
#    Authentication Total Rx
#    key:pppox_client.session.row_id.auth_total_rx                      value:Authentication Total Rx
#    Authentication Total Tx
#    key:pppox_client.session.row_id.auth_total_tx                      value:Authentication Total Tx
#    Establishment Time (usec)
#    key:pppox_client.session.row_id.avg_setup_time                     value:Establishment Time (usec)
#    Our Call ID
#    key:pppox_client.session.row_id.call_id                            value:Our Call ID
#    Call State
#    key:pppox_client.session.row_id.call_state                         value:Call State
#    CHAP Challenge Rx
#    key:pppox_client.session.row_id.chap_auth_chal_rx                  value:CHAP Challenge Rx
#    CHAP Failure Rx
#    key:pppox_client.session.row_id.chap_auth_fail_rx                  value:CHAP Failure Rx
#    CHAP Authentication Role
#    key:pppox_client.session.row_id.chap_auth_role                     value:CHAP Authentication Role
#    CHAP Response Tx
#    key:pppox_client.session.row_id.chap_auth_rsp_tx                   value:CHAP Response Tx
#    CHAP Success Rx
#    key:pppox_client.session.row_id.chap_auth_succ_rx                  value:CHAP Success Rx
#    LCP Code Reject Rx
#    key:pppox_client.session.row_id.code_rej_rx                        value:LCP Code Reject Rx
#    LCP Code Reject Tx
#    key:pppox_client.session.row_id.code_rej_tx                        value:LCP Code Reject Tx
#    Our Cookie
#    key:pppox_client.session.row_id.cookie                             value:Our Cookie
#    Our Cookie Length
#    key:pppox_client.session.row_id.cookie_len                         value:Our Cookie Length
#    Data NS
#    key:pppox_client.session.row_id.data_ns                            value:Data NS
#    Destination IP
#    key:pppox_client.session.row_id.destination_ip                     value:Destination IP
#    Destination Port
#    key:pppox_client.session.row_id.destination_port                   value:Destination Port
#    DNS Server List
#    key:pppox_client.session.row_id.dns_server_list                    value:DNS Server List
#    LCP Echo Request Rx
#    key:pppox_client.session.row_id.echo_req_rx                        value:LCP Echo Request Rx
#    LCP Echo Request Tx
#    key:pppox_client.session.row_id.echo_req_tx                        value:LCP Echo Request Tx
#    LCP Echo Response Rx
#    key:pppox_client.session.row_id.echo_rsp_rx                        value:LCP Echo Response Rx
#    LCP Echo Response Tx
#    key:pppox_client.session.row_id.echo_rsp_tx                        value:LCP Echo Response Tx
#    Gateway IP
#    key:pppox_client.session.row_id.gateway_ip                         value:Gateway IP
#    Generic Error Tag Rx
#    key:pppox_client.session.row_id.generic_error_tag_rx               value:Generic Error Tag Rx
#    Host MAC Address
#    key:pppox_client.session.row_id.host_mac_addr                      value:Host MAC Address
#    Host Name
#    key:pppox_client.session.row_id.host_name                          value:Host Name
#    IPCP Config ACK Rx
#    key:pppox_client.session.row_id.ipcp_cfg_ack_rx                    value:IPCP Config ACK Rx
#    IPCP Config ACK Tx
#    key:pppox_client.session.row_id.ipcp_cfg_ack_tx                    value:IPCP Config ACK Tx
#    IPCP Config NAK Rx
#    key:pppox_client.session.row_id.ipcp_cfg_nak_rx                    value:IPCP Config NAK Rx
#    IPCP Config NAK Tx
#    key:pppox_client.session.row_id.ipcp_cfg_nak_tx                    value:IPCP Config NAK Tx
#    IPCP Config Reject Rx
#    key:pppox_client.session.row_id.ipcp_cfg_rej_rx                    value:IPCP Config Reject Rx
#    IPCP Config Reject Tx
#    key:pppox_client.session.row_id.ipcp_cfg_rej_tx                    value:IPCP Config Reject Tx
#    IPCP Config Request Rx
#    key:pppox_client.session.row_id.ipcp_cfg_req_rx                    value:IPCP Config Request Rx
#    IPCP Config Request Tx
#    key:pppox_client.session.row_id.ipcp_cfg_req_tx                    value:IPCP Config Request Tx
#    IPCP Establishment Time (usec)
#    key:pppox_client.session.row_id.ipcp_latency                       value:IPCP Establishment Time (usec)
#    IPCP State
#    key:pppox_client.session.row_id.ipcp_state                         value:IPCP State
#    IPv6 Address
#    key:pppox_client.session.row_id.ipv6_addr                          value:IPv6 Address
#    IPv6 Prefix Length
#    key:pppox_client.session.row_id.ipv6_prefix_len                    value:IPv6 Prefix Length
#    IPv6CP Config ACK Rx
#    key:pppox_client.session.row_id.ipv6cp_cfg_ack_rx                  value:IPv6CP Config ACK Rx
#    IPv6CP Config ACK Tx
#    key:pppox_client.session.row_id.ipv6cp_cfg_ack_tx                  value:IPv6CP Config ACK Tx
#    IPv6CP Config NAK Rx
#    key:pppox_client.session.row_id.ipv6cp_cfg_nak_rx                  value:IPv6CP Config NAK Rx
#    IPv6CP Config NAK Tx
#    key:pppox_client.session.row_id.ipv6cp_cfg_nak_tx                  value:IPv6CP Config NAK Tx
#    IPv6CP Config Reject Rx
#    key:pppox_client.session.row_id.ipv6cp_cfg_rej_rx                  value:IPv6CP Config Reject Rx
#    IPv6CP Config Reject Tx
#    key:pppox_client.session.row_id.ipv6cp_cfg_rej_tx                  value:IPv6CP Config Reject Tx
#    IPv6CP Config Request Rx
#    key:pppox_client.session.row_id.ipv6cp_cfg_req_rx                  value:IPv6CP Config Request Rx
#    IPv6CP Config Request Tx
#    key:pppox_client.session.row_id.ipv6cp_cfg_req_tx                  value:IPv6CP Config Request Tx
#    IPv6CP Establishment Time (usec)
#    key:pppox_client.session.row_id.ipv6cp_latency                     value:IPv6CP Establishment Time (usec)
#    IPv6CP Router Advertisement Rx
#    key:pppox_client.session.row_id.ipv6cp_router_adv_rx               value:IPv6CP Router Advertisement Rx
#    IPv6CP State
#    key:pppox_client.session.row_id.ipv6cp_state                       value:IPv6CP State
#    LCP Configure ACK Rx
#    key:pppox_client.session.row_id.lcp_cfg_ack_rx                     value:LCP Configure ACK Rx
#    LCP Configure ACK Tx
#    key:pppox_client.session.row_id.lcp_cfg_ack_tx                     value:LCP Configure ACK Tx
#    LCP Configure NAK Rx
#    key:pppox_client.session.row_id.lcp_cfg_nak_rx                     value:LCP Configure NAK Rx
#    LCP Configure NAK Tx
#    key:pppox_client.session.row_id.lcp_cfg_nak_tx                     value:LCP Configure NAK Tx
#    LCP Configure Reject Rx
#    key:pppox_client.session.row_id.lcp_cfg_rej_rx                     value:LCP Configure Reject Rx
#    LCP Configure Reject Tx
#    key:pppox_client.session.row_id.lcp_cfg_rej_tx                     value:LCP Configure Reject Tx
#    LCP Configure Request Rx
#    key:pppox_client.session.row_id.lcp_cfg_req_rx                     value:LCP Configure Request Rx
#    LCP Configure Request Tx
#    key:pppox_client.session.row_id.lcp_cfg_req_tx                     value:LCP Configure Request Tx
#    LCP Establishment Time (usec)
#    key:pppox_client.session.row_id.lcp_latency                        value:LCP Establishment Time (usec)
#    LCP Protocol Reject Rx
#    key:pppox_client.session.row_id.lcp_protocol_rej_rx                value:LCP Protocol Reject Rx
#    LCP Protocol Reject Tx
#    key:pppox_client.session.row_id.lcp_protocol_rej_tx                value:LCP Protocol Reject Tx
#    LCP Total Rx
#    key:pppox_client.session.row_id.lcp_total_msg_rx                   value:LCP Total Rx
#    LCP Total Tx
#    key:pppox_client.session.row_id.lcp_total_msg_tx                   value:LCP Total Tx
#    Local IP Address
#    key:pppox_client.session.row_id.local_ip_addr                      value:Local IP Address
#    Local Ipv6 IID
#    key:pppox_client.session.row_id.local_ipv6_iid                     value:Local Ipv6 IID
#    Loopback Detected
#    key:pppox_client.session.row_id.loopback_detected                  value:Loopback Detected
#    Magic Number Negotiated
#    key:pppox_client.session.row_id.magic_no_negotiated                value:Magic Number Negotiated
#    Magic Number Rx
#    key:pppox_client.session.row_id.magic_no_rx                        value:Magic Number Rx
#    Magic Number Tx
#    key:pppox_client.session.row_id.magic_no_tx                        value:Magic Number Tx
#    MRU
#    key:pppox_client.session.row_id.mru                                value:MRU
#    MTU
#    key:pppox_client.session.row_id.mtu                                value:MTU
#    NCP Total Rx
#    key:pppox_client.session.row_id.ncp_total_msg_rx                   value:NCP Total Rx
#    NCP Total Tx
#    key:pppox_client.session.row_id.ncp_total_msg_tx                   value:NCP Total Tx
#    Negotiation End Time
#    key:pppox_client.session.row_id.negotiation_end_ms                 value:Negotiation End Time
#    Negotiation Start Time
#    key:pppox_client.session.row_id.negotiation_start_ms               value:Negotiation Start Time
#    PADI Timeouts
#    key:pppox_client.session.row_id.padi_timeouts                      value:PADI Timeouts
#    PADI Tx
#    key:pppox_client.session.row_id.padi_tx                            value:PADI Tx
#    PADO Rx
#    key:pppox_client.session.row_id.pado_rx                            value:PADO Rx
#    PADR Timeouts
#    key:pppox_client.session.row_id.padr_timeouts                      value:PADR Timeouts
#    PADR Tx
#    key:pppox_client.session.row_id.padr_tx                            value:PADR Tx
#    PADS Rx
#    key:pppox_client.session.row_id.pads_rx                            value:PADS Rx
#    PADT Rx
#    key:pppox_client.session.row_id.padt_rx                            value:PADT Rx
#    PADT Tx
#    key:pppox_client.session.row_id.padt_tx                            value:PADT Tx
#    PAP Authentication ACK Rx
#    key:pppox_client.session.row_id.pap_auth_ack_rx                    value:PAP Authentication ACK Rx
#    PAP Authentication NAK Rx
#    key:pppox_client.session.row_id.pap_auth_nak_rx                    value:PAP Authentication NAK Rx
#    PAP Authentication Request Tx
#    key:pppox_client.session.row_id.pap_auth_req_tx                    value:PAP Authentication Request Tx
#    Peer Call ID
#    key:pppox_client.session.row_id.peer_call_id                       value:Peer Call ID
#    Peer Tunnel ID
#    key:pppox_client.session.row_id.peer_id                            value:Peer Tunnel ID
#    Peer Ipv6 IID
#    key:pppox_client.session.row_id.peer_ipv6_iid                      value:Peer Ipv6 IID
#    PPP Close Mode
#    key:pppox_client.session.row_id.ppp_close_mode                     value:PPP Close Mode
#    PPP State
#    key:pppox_client.session.row_id.ppp_state                          value:PPP State
#    PPPoE Discovery Establishment Time (usec)
#    key:pppox_client.session.row_id.pppoe_discovery_latency            value:PPPoE Discovery Establishment Time (usec)
#    PPPoE Session ID
#    key:pppox_client.session.row_id.pppoe_session_id                   value:PPPoE Session ID
#    PPPoE State
#    key:pppox_client.session.row_id.pppox_state                        value:PPPoE State
#    Primary WINS Server
#    key:pppox_client.session.row_id.primary_wins_server                value:Primary WINS Server
#    Relay Session ID Tag Rx
#    key:pppox_client.session.row_id.relay_session_id_tag_rx            value:Relay Session ID Tag Rx
#    Remote IP Address
#    key:pppox_client.session.row_id.remote_ip_addr                     value:Remote IP Address
#    Secondary WINS Server
#    key:pppox_client.session.row_id.secondary_wins_server              value:Secondary WINS Server
#    Service Name
#    key:pppox_client.session.row_id.service_name                       value:Service Name
#    Service Name Error Tag Rx
#    key:pppox_client.session.row_id.service_name_error_tag_rx          value:Service Name Error Tag Rx
#    Source IP
#    key:pppox_client.session.row_id.source_ip                          value:Source IP
#    Source Port
#    key:pppox_client.session.row_id.source_port                        value:Source Port
#    PPPox Client Session Status
#    key:pppox_client.session.row_id.status                             value:PPPox Client Session Status
#    LCP Terminate ACK Rx
#    key:pppox_client.session.row_id.term_ack_rx                        value:LCP Terminate ACK Rx
#    LCP Terminate ACK Tx
#    key:pppox_client.session.row_id.term_ack_tx                        value:LCP Terminate ACK Tx
#    LCP Terminate Request Rx
#    key:pppox_client.session.row_id.term_req_rx                        value:LCP Terminate Request Rx
#    LCP Terminate Request Tx
#    key:pppox_client.session.row_id.term_req_tx                        value:LCP Terminate Request Tx
#    PPPoE TotalBytes Rx
#    key:pppox_client.session.row_id.total_bytes_rx                     value:PPPoE TotalBytes Rx
#    PPPoE TotalBytes Tx
#    key:pppox_client.session.row_id.total_bytes_tx                     value:PPPoE TotalBytes Tx
#    Our Tunnel ID
#    key:pppox_client.session.row_id.tunnel_id                          value:Our Tunnel ID
#    Tunnel State
#    key:pppox_client.session.row_id.tunnel_state                       value:Tunnel State
#    Vendor Specific Tag Rx
#    key:pppox_client.session.row_id.vendor_specific_tag_rx             value:Vendor Specific Tag Rx
#    AC MAC Address
#    key:pppox_server.session.row_id.ac_mac_addr                        value:AC MAC Address
#    ACName
#    key:pppox_server.session.row_id.ac_name                            value:ACName
#    Authentication ID
#    key:pppox_server.session.row_id.auth_id                            value:Authentication ID
#    Authentication Establishment Time (usec)
#    key:pppox_server.session.row_id.auth_latency                       value:Authentication Establishment Time (usec)
#    Authentication Password
#    key:pppox_server.session.row_id.auth_password                      value:Authentication Password
#    Authentication Protocol Rx
#    key:pppox_server.session.row_id.auth_protocol_rx                   value:Authentication Protocol Rx
#    Authentication Protocol Tx
#    key:pppox_server.session.row_id.auth_protocol_tx                   value:Authentication Protocol Tx
#    Authentication Total Rx
#    key:pppox_server.session.row_id.auth_total_rx                      value:Authentication Total Rx
#    Authentication Total Tx
#    key:pppox_server.session.row_id.auth_total_tx                      value:Authentication Total Tx
#    Establishment Time (usec)
#    key:pppox_server.session.row_id.avg_setup_time                     value:Establishment Time (usec)
#    Our Call ID
#    key:pppox_server.session.row_id.call_id                            value:Our Call ID
#    Call State
#    key:pppox_server.session.row_id.call_state                         value:Call State
#    CHAP Challenge Tx
#    key:pppox_server.session.row_id.chap_auth_chal_tx                  value:CHAP Challenge Tx
#    CHAP Failure Tx
#    key:pppox_server.session.row_id.chap_auth_fail_tx                  value:CHAP Failure Tx
#    CHAP Authentication Role
#    key:pppox_server.session.row_id.chap_auth_role                     value:CHAP Authentication Role
#    CHAP Response Rx
#    key:pppox_server.session.row_id.chap_auth_rsp_rx                   value:CHAP Response Rx
#    CHAP Success Tx
#    key:pppox_server.session.row_id.chap_auth_succ_tx                  value:CHAP Success Tx
#    LCP Code Reject Rx
#    key:pppox_server.session.row_id.code_rej_rx                        value:LCP Code Reject Rx
#    LCP Code Reject Tx
#    key:pppox_server.session.row_id.code_rej_tx                        value:LCP Code Reject Tx
#    Our Cookie
#    key:pppox_server.session.row_id.cookie                             value:Our Cookie
#    Our Cookie Length
#    key:pppox_server.session.row_id.cookie_len                         value:Our Cookie Length
#    Data NS
#    key:pppox_server.session.row_id.data_ns                            value:Data NS
#    Destination IP
#    key:pppox_server.session.row_id.destination_ip                     value:Destination IP
#    Destination Port
#    key:pppox_server.session.row_id.destination_port                   value:Destination Port
#    DNS Server List
#    key:pppox_server.session.row_id.dns_server_list                    value:DNS Server List
#    LCP Echo Request Rx
#    key:pppox_server.session.row_id.echo_req_rx                        value:LCP Echo Request Rx
#    LCP Echo Request Tx
#    key:pppox_server.session.row_id.echo_req_tx                        value:LCP Echo Request Tx
#    LCP Echo Response Rx
#    key:pppox_server.session.row_id.echo_rsp_rx                        value:LCP Echo Response Rx
#    LCP Echo Response Tx
#    key:pppox_server.session.row_id.echo_rsp_tx                        value:LCP Echo Response Tx
#    Gateway IP
#    key:pppox_server.session.row_id.gateway_ip                         value:Gateway IP
#    Generic Error Tag Rx
#    key:pppox_server.session.row_id.generic_error_tag_rx               value:Generic Error Tag Rx
#    Host MAC Address
#    key:pppox_server.session.row_id.host_mac_addr                      value:Host MAC Address
#    Host Name
#    key:pppox_server.session.row_id.host_name                          value:Host Name
#    IPCP Config ACK Rx
#    key:pppox_server.session.row_id.ipcp_cfg_ack_rx                    value:IPCP Config ACK Rx
#    IPCP Config ACK Tx
#    key:pppox_server.session.row_id.ipcp_cfg_ack_tx                    value:IPCP Config ACK Tx
#    IPCP Config NAK Rx
#    key:pppox_server.session.row_id.ipcp_cfg_nak_rx                    value:IPCP Config NAK Rx
#    IPCP Config NAK Tx
#    key:pppox_server.session.row_id.ipcp_cfg_nak_tx                    value:IPCP Config NAK Tx
#    IPCP Config Reject Rx
#    key:pppox_server.session.row_id.ipcp_cfg_rej_rx                    value:IPCP Config Reject Rx
#    IPCP Config Reject Tx
#    key:pppox_server.session.row_id.ipcp_cfg_rej_tx                    value:IPCP Config Reject Tx
#    IPCP Config Request Rx
#    key:pppox_server.session.row_id.ipcp_cfg_req_rx                    value:IPCP Config Request Rx
#    IPCP Config Request Tx
#    key:pppox_server.session.row_id.ipcp_cfg_req_tx                    value:IPCP Config Request Tx
#    IPCP Establishment Time (usec)
#    key:pppox_server.session.row_id.ipcp_latency                       value:IPCP Establishment Time (usec)
#    IPCP State
#    key:pppox_server.session.row_id.ipcp_state                         value:IPCP State
#    IPv6 Address
#    key:pppox_server.session.row_id.ipv6_addr                          value:IPv6 Address
#    IPv6 Prefix Length
#    key:pppox_server.session.row_id.ipv6_prefix_len                    value:IPv6 Prefix Length
#    IPv6CP Config ACK Rx
#    key:pppox_server.session.row_id.ipv6cp_cfg_ack_rx                  value:IPv6CP Config ACK Rx
#    IPv6CP Config ACK Tx
#    key:pppox_server.session.row_id.ipv6cp_cfg_ack_tx                  value:IPv6CP Config ACK Tx
#    IPv6CP Config NAK Rx
#    key:pppox_server.session.row_id.ipv6cp_cfg_nak_rx                  value:IPv6CP Config NAK Rx
#    IPv6CP Config NAK Tx
#    key:pppox_server.session.row_id.ipv6cp_cfg_nak_tx                  value:IPv6CP Config NAK Tx
#    IPv6CP Config Reject Rx
#    key:pppox_server.session.row_id.ipv6cp_cfg_rej_rx                  value:IPv6CP Config Reject Rx
#    IPv6CP Config Reject Tx
#    key:pppox_server.session.row_id.ipv6cp_cfg_rej_tx                  value:IPv6CP Config Reject Tx
#    IPv6CP Config Request Rx
#    key:pppox_server.session.row_id.ipv6cp_cfg_req_rx                  value:IPv6CP Config Request Rx
#    IPv6CP Config Request Tx
#    key:pppox_server.session.row_id.ipv6cp_cfg_req_tx                  value:IPv6CP Config Request Tx
#    IPv6CP Establishment Time (usec)
#    key:pppox_server.session.row_id.ipv6cp_latency                     value:IPv6CP Establishment Time (usec)
#    IPv6CP Router Advertisement Tx
#    key:pppox_server.session.row_id.ipv6cp_router_adv_tx               value:IPv6CP Router Advertisement Tx
#    IPv6CP Router Solicitation Rx
#    key:pppox_server.session.row_id.ipv6cp_router_solicitation_rx      value:IPv6CP Router Solicitation Rx
#    IPv6CP State
#    key:pppox_server.session.row_id.ipv6cp_state                       value:IPv6CP State
#    LCP Configure ACK Rx
#    key:pppox_server.session.row_id.lcp_cfg_ack_rx                     value:LCP Configure ACK Rx
#    LCP Configure ACK Tx
#    key:pppox_server.session.row_id.lcp_cfg_ack_tx                     value:LCP Configure ACK Tx
#    LCP Configure NAK Rx
#    key:pppox_server.session.row_id.lcp_cfg_nak_rx                     value:LCP Configure NAK Rx
#    LCP Configure NAK Tx
#    key:pppox_server.session.row_id.lcp_cfg_nak_tx                     value:LCP Configure NAK Tx
#    LCP Configure Reject Rx
#    key:pppox_server.session.row_id.lcp_cfg_rej_rx                     value:LCP Configure Reject Rx
#    LCP Configure Reject Tx
#    key:pppox_server.session.row_id.lcp_cfg_rej_tx                     value:LCP Configure Reject Tx
#    LCP Configure Request Rx
#    key:pppox_server.session.row_id.lcp_cfg_req_rx                     value:LCP Configure Request Rx
#    LCP Configure Request Tx
#    key:pppox_server.session.row_id.lcp_cfg_req_tx                     value:LCP Configure Request Tx
#    LCP Establishment Time (usec)
#    key:pppox_server.session.row_id.lcp_latency                        value:LCP Establishment Time (usec)
#    LCP Protocol Reject Rx
#    key:pppox_server.session.row_id.lcp_protocol_rej_rx                value:LCP Protocol Reject Rx
#    LCP Protocol Reject Tx
#    key:pppox_server.session.row_id.lcp_protocol_rej_tx                value:LCP Protocol Reject Tx
#    LCP Total Rx
#    key:pppox_server.session.row_id.lcp_total_msg_rx                   value:LCP Total Rx
#    LCP Total Tx
#    key:pppox_server.session.row_id.lcp_total_msg_tx                   value:LCP Total Tx
#    Local IP Address
#    key:pppox_server.session.row_id.local_ip_addr                      value:Local IP Address
#    Local Ipv6 IID
#    key:pppox_server.session.row_id.local_ipv6_iid                     value:Local Ipv6 IID
#    Loopback Detected
#    key:pppox_server.session.row_id.loopback_detected                  value:Loopback Detected
#    Magic Number Negotiated
#    key:pppox_server.session.row_id.magic_no_negotiated                value:Magic Number Negotiated
#    Magic Number Rx
#    key:pppox_server.session.row_id.magic_no_rx                        value:Magic Number Rx
#    Magic Number Tx
#    key:pppox_server.session.row_id.magic_no_tx                        value:Magic Number Tx
#    MRU
#    key:pppox_server.session.row_id.mru                                value:MRU
#    MTU
#    key:pppox_server.session.row_id.mtu                                value:MTU
#    NCP Total Rx
#    key:pppox_server.session.row_id.ncp_total_msg_rx                   value:NCP Total Rx
#    NCP Total Tx
#    key:pppox_server.session.row_id.ncp_total_msg_tx                   value:NCP Total Tx
#    Negotiation End Time
#    key:pppox_server.session.row_id.negotiation_end_ms                 value:Negotiation End Time
#    Negotiation Start Time
#    key:pppox_server.session.row_id.negotiation_start_ms               value:Negotiation Start Time
#    PADI Rx
#    key:pppox_server.session.row_id.padi_rx                            value:PADI Rx
#    PADO Tx
#    key:pppox_server.session.row_id.pado_tx                            value:PADO Tx
#    PADR Rx
#    key:pppox_server.session.row_id.padr_rx                            value:PADR Rx
#    PADS Tx
#    key:pppox_server.session.row_id.pads_tx                            value:PADS Tx
#    PADT Rx
#    key:pppox_server.session.row_id.padt_rx                            value:PADT Rx
#    PADT Tx
#    key:pppox_server.session.row_id.padt_tx                            value:PADT Tx
#    PAP Authentication ACK Tx
#    key:pppox_server.session.row_id.pap_auth_ack_tx                    value:PAP Authentication ACK Tx
#    PAP Authentication NAK Tx
#    key:pppox_server.session.row_id.pap_auth_nak_tx                    value:PAP Authentication NAK Tx
#    PAP Authentication Request Rx
#    key:pppox_server.session.row_id.pap_auth_req_rx                    value:PAP Authentication Request Rx
#    Peer Call ID
#    key:pppox_server.session.row_id.peer_call_id                       value:Peer Call ID
#    Peer Tunnel ID
#    key:pppox_server.session.row_id.peer_id                            value:Peer Tunnel ID
#    Peer Ipv6 IID
#    key:pppox_server.session.row_id.peer_ipv6_iid                      value:Peer Ipv6 IID
#    PPP Close Mode
#    key:pppox_server.session.row_id.ppp_close_mode                     value:PPP Close Mode
#    PPP State
#    key:pppox_server.session.row_id.ppp_state                          value:PPP State
#    PPPoE Discovery Establishment Time (usec)
#    key:pppox_server.session.row_id.pppoe_discovery_latency            value:PPPoE Discovery Establishment Time (usec)
#    PPPoE Session ID
#    key:pppox_server.session.row_id.pppoe_session_id                   value:PPPoE Session ID
#    PPPoE State
#    key:pppox_server.session.row_id.pppox_state                        value:PPPoE State
#    Primary WINS Server
#    key:pppox_server.session.row_id.primary_wins_server                value:Primary WINS Server
#    Relay Session ID Tag Rx
#    key:pppox_server.session.row_id.relay_session_id_tag_rx            value:Relay Session ID Tag Rx
#    Remote IP Address
#    key:pppox_server.session.row_id.remote_ip_addr                     value:Remote IP Address
#    Secondary WINS Server
#    key:pppox_server.session.row_id.secondary_wins_server              value:Secondary WINS Server
#    Service Name
#    key:pppox_server.session.row_id.service_name                       value:Service Name
#    Source IP
#    key:pppox_server.session.row_id.source_ip                          value:Source IP
#    Source Port
#    key:pppox_server.session.row_id.source_port                        value:Source Port
#    PPPox Server Session Status
#    key:pppox_server.session.row_id.status                             value:PPPox Server Session Status
#    LCP Terminate ACK Rx
#    key:pppox_server.session.row_id.term_ack_rx                        value:LCP Terminate ACK Rx
#    LCP Terminate ACK Tx
#    key:pppox_server.session.row_id.term_ack_tx                        value:LCP Terminate ACK Tx
#    LCP Terminate Request Rx
#    key:pppox_server.session.row_id.term_req_rx                        value:LCP Terminate Request Rx
#    LCP Terminate Request Tx
#    key:pppox_server.session.row_id.term_req_tx                        value:LCP Terminate Request Tx
#    PPPoE TotalBytes Rx
#    key:pppox_server.session.row_id.total_bytes_rx                     value:PPPoE TotalBytes Rx
#    PPPoE TotalBytes Tx
#    key:pppox_server.session.row_id.total_bytes_tx                     value:PPPoE TotalBytes Tx
#    Our Tunnel ID
#    key:pppox_server.session.row_id.tunnel_id                          value:Our Tunnel ID
#    Tunnel State
#    key:pppox_server.session.row_id.tunnel_state                       value:Tunnel State
#    Vendor Specific Tag Rx
#    key:pppox_server.session.row_id.vendor_specific_tag_rx             value:Vendor Specific Tag Rx
#
# Examples:
#    See files in the Samples/IxNetwork/L2TP subdirectory.
#
# Sample Input:
#    .
#
# Sample Output:
#    .
#
# Notes:
#
# See Also:
#

proc ::ixiangpf::l2tp_stats { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "l2tp_stats" $notImplementedParams $mandatoryParams $fileParams $args]
}
