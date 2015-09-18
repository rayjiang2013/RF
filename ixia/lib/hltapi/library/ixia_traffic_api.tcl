##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_traffic_api.tcl
#
# Purpose:
#    A script development library containing general APIs for test automation
#    with the Ixia chassis.
#
# Author:
#    Karim Lacasse
#
# Usage:
#    package require Ixia
#
# Description:
#    This library contains general the traffic related procedures that can
#    be used during the TCL software development process.
#
#    Use this library during the development of a script or
#    procedure library to verify the software in a simulation
#    environment and to perform an internal unit test on the
#    software components.
#
# Requirements:
#    ixiaapiutils.tcl , a library containing TCL utilities
#    parseddashedargs.tcl , a library containing the procDescr and
#        parse_dashed_args procedures
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


##Procedure Header
# Name:
#    ::ixia::traffic_config
#
# Description:
#     This command configures traffic streams on the specified port with 
#     the specified options.
#
# Synopsis:
#    ::ixia::traffic_config
#        [-arp_dst_hw_addr              MAC]
#        [-arp_dst_hw_count             NUMERIC]
#        [-arp_dst_hw_mode              CHOICES fixed increment decrement]
#        [-arp_operation                CHOICES arpRequest arpReply rarpRequest rarpReply]
#        [-arp_src_hw_addr              MAC]
#        [-arp_src_hw_count             NUMERIC]
#        [-arp_src_hw_mode              CHOICES fixed increment decrement]
#        [-bidirectional                FLAG]
#        [-burst_loop_count             NUMERIC]
#        [-command_response             FLAG]
#        [-emulation_dst_handle         ]
#        [-emulation_src_handle         ]
#        [-fcs                          CHOICES 0 1]
#        [-icmp_checksum                ]
#        [-icmp_code                    RANGE 0-255]
#        [-icmp_id                      RANGE 0-65535]
#        [-icmp_seq                     RANGE 0-65535]
#        [-icmp_type                    RANGE 0-255]
#        [-igmp_group_addr              IP]
#        [-igmp_group_count             RANGE 0-65535]
#        [-igmp_group_mode              CHOICES fixed increment decrement]
#        [-igmp_group_step              ]
#        [-igmp_max_response_time       RANGE 0-255]
#        [-igmp_msg_type                ]
#        [-igmp_multicast_src           IP]
#        [-igmp_qqic                    RANGE 0-255]
#        [-igmp_qrv                     RANGE 0-7]
#        [-igmp_record_type             CHOICES mode_is_include mode_is_exclude change_to_include_mode change_to_exclude_mode allow_new_sources block_old_sources]
#        [-igmp_s_flag                  CHOICES 0 1]
#        [-igmp_type                    CHOICES membership_query membership_report dvmrp leave_group]
#        [-igmp_valid_checksum          CHOICES 0 1]
#        [-igmp_version                 CHOICES 1 2 3]
#        [-inter_burst_gap              NUMERIC]
#        [-inter_stream_gap             NUMERIC]
#        [-ip_checksum                  ]
#        [-ip_cu                        RANGE   0-3]
#        [-ip_dscp                      RANGE 0-63]
#        [-ip_dscp_count                ]
#        [-ip_dscp_step                 ]
#        [-ip_dst_addr                  IP]
#        [-ip_dst_count                 RANGE 1-4294967295]
#        [-ip_dst_mode                  CHOICES fixed increment decrement random emulation]
#        [-ip_dst_step                  IP]
#        [-ip_fragment                  CHOICES 0 1]
#        [-ip_fragment_last             CHOICES 0 1]
#        [-ip_fragment_offset           RANGE 0-8191]
#        [-ip_hdr_length                ]
#        [-ip_id                        RANGE 0-65535]
#        [-ip_precedence                RANGE 0-7]
#        [-ip_protocol                  RANGE 0-255]
#        [-ip_src_addr                  IP]
#        [-ip_src_count                 RANGE 1-4294967295]
#        [-ip_src_mode                  CHOICES fixed increment decrement random emulation]
#        [-ip_src_step                  IP]
#        [-ip_ttl                       RANGE 0-255]
#        [-ipv6_dst_addr                IPV6]
#        [-ipv6_dst_count               RANGE 1-4294967295]
#        [-ipv6_dst_mode                CHOICES fixed increment decrement random incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group]
#        [-ipv6_dst_step                IPV6]
#        [-ipv6_flow_label              RANGE 0-1048575]
#        [-ipv6_frag_id                 RANGE 0-4294967295]
#        [-ipv6_frag_more_flag          FLAG CHOICES 0 1]
#        [-ipv6_frag_offset             RANGE 0-8191]
#        [-ipv6_hop_limit               RANGE 0-255]
#        [-ipv6_next_header             RANGE 0-255]
#        [-ipv6_src_addr                IPV6]
#        [-ipv6_src_count               RANGE 1-4294967295]
#        [-ipv6_src_mode                CHOICES fixed increment decrement random incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group]
#        [-ipv6_src_step                IPV6]
#        [-ipv6_traffic_class           RANGE 0-255]]
#        [-l2_encap                     CHOICES atm_vc_mux atm_vc_mux_ethernet_ii atm_vc_mux_802.3snap atm_vc_mux_802.3snap_nofcs atm_vc_mux_ppp atm_vc_mux_pppoe atm_snap atm_snap_ethernet_ii atm_snap_802.3snap atm_snap_802.3snap_nofcs atm_snap_ppp atm_snap_pppoe hdlc_unicast hdlc_broadcast hdlc_unicast_mpls hdlc_multicast_mpls ethernet_ii ethernet_ii_unicast_mpls ethernet_ii_multicast_mpls ethernet_ii_vlan ethernet_ii_vlan_unicast_mpls ethernet_ii_vlan_multicast_mpls ethernet_ii_pppoe ethernet_ii_vlan_pppoe ppp_link ietf_framerelay cisco_framerelay]
#        [-l3_gaus1_avg                 DECIMAL]
#        [-l3_gaus1_halfbw              DECIMAL]
#        [-l3_gaus1_weight              NUMERIC]
#        [-l3_gaus2_avg                 DECIMAL]
#        [-l3_gaus2_halfbw              DECIMAL]
#        [-l3_gaus2_weight              NUMERIC]
#        [-l3_gaus3_avg                 DECIMAL]
#        [-l3_gaus3_halfbw              DECIMAL]
#        [-l3_gaus3_weight              NUMERIC]
#        [-l3_gaus4_avg                 DECIMAL]
#        [-l3_gaus4_halfbw              DECIMAL]
#        [-l3_gaus4_weight              NUMERIC]
#        [-l3_imix1_ratio               RANGE 0-262144]
#        [-l3_imix1_size                RANGE 32-9000]
#        [-l3_imix2_ratio               RANGE 0-262144]
#        [-l3_imix2_size                RANGE 32-9000]
#        [-l3_imix3_ratio               RANGE 0-262144]
#        [-l3_imix3_size                RANGE 32-9000]
#        [-l3_imix4_ratio               RANGE 0-262144]
#        [-l3_imix4_size                RANGE 32-9000]
#        [-l3_length                    RANGE 1-64000]
#        [-l3_length_max                RANGE 1-64000]
#        [-l3_length_min                RANGE 1-64000]
#        [-l3_protocol                  CHOICES ipv4 ipv6 arp pause_control ipx none]
#        [-l4_protocol                  CHOICES icmp igmp ggp gre ip st tcp ucl egp igp bbn_rcc_mon nvp_ii pup argus emcon xnet chaos udp mux dcn_meas hmp prm xns_idp trunk_1 trunk_2 leaf_1 leaf_2 rdp irtp iso_tp4 netblt mfe_nsp merit_inp sep cftp sat_expak mit_subnet rvd ippc sat_mon ipcv br_sat_mon wb_mon wb_expak rip ospf]
#        [-length_mode                  CHOICES fixed increment random auto imix gaussian quad distribution]
#        [-mac_dst                      MAC]
#        [-mac_dst2                     MAC]
#        [-mac_dst_count                NUMERIC]
#        [-mac_dst_mask                 MAC]
#        [-mac_dst_mode                 CHOICES fixed increment list decrement discovery random repeatable_random]
#        [-mac_dst_seed                 NUMERIC]
#        [-mac_dst_step                 MAC]
#        [-mac_src                      MAC]
#        [-mac_src2                     MAC]
#        [-mac_src_count                NUMERIC]
#        [-mac_src_mask                 MAC]
#        [-mac_src_mode                 CHOICES fixed increment decrement random emulation list repeatable_random]
#        [-mac_src_seed                 NUMERIC]
#        [-mac_src_step                 MAC]
#        [-mode                         CHOICES create modify remove reset enable disable append_header prepend_header replace_header dynamic_update get_available_protocol_templates get_available_fields get_field_values set_field_values add_field_level remove_field_level get_available_egress_tracking_field_offset get_available_dynamic_update_fields get_available_session_aware_traffic get_available_fields_for_link]
#        [-mpls_labels                  ]
#        [-pkts_per_burst               NUMERIC]
#        [-port_handle                  REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-port_handle2                 REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-rate_bps                     ]
#        [-rate_frame_gap               RANGE 0-100]
#        [-rate_percent                 RANGE 0-100]
#        [-rate_pps                     ]
#        [-stream_id                    ]
#        [-tcp_ack_flag                 CHOICES 0 1]
#        [-tcp_ack_num                  RANGE 0-4294967295]
#        [-tcp_dst_port                 RANGE 0-65535]
#        [-tcp_fin_flag                 CHOICES 0 1]
#        [-tcp_psh_flag                 CHOICES 0 1]
#        [-tcp_reserved                 ]
#        [-tcp_rst_flag                 CHOICES 0 1]
#        [-tcp_seq_num                  RANGE 0-4294967295]
#        [-tcp_src_port                 RANGE 0-65535]
#        [-tcp_syn_flag                 CHOICES 0 1]
#        [-tcp_urg_flag                 CHOICES 0 1]
#        [-tcp_urgent_ptr               RANGE 0-65535]
#        [-tcp_window                   RANGE 0-65535]
#        [-transmit_mode                CHOICES continuous random_spaced single_pkt single_burst multi_burst continuous_burst return_to_id return_to_id_for_count advance]
#        [-udp_checksum                 CHOICES 0 1 DEFAULT 1]
#        [-udp_dst_port                 RANGE 0-65535]
#        [-udp_src_port                 RANGE 0-65535]
#        [-vci                          RANGE 0-65535]
#        [-vci_count                    RANGE 0-65535]
#        [-vci_step                     RANGE 0-65534]
#        [-vlan_cfi                     CHOICES 0 1]
#        [-vlan_id                      RANGE 0-4095]
#        [-vlan_id_count                RANGE 0-4095]
#        [-vlan_id_mode                 CHOICES fixed increment decrement nested_incr nested_decr random list]
#        [-vlan_id_step                 NUMERIC]
#        [-vlan_user_priority           RANGE 0-7]
#        [-vpi                          RANGE 0-4096]
#        [-vpi_count                    RANGE 0-4096]
#        [-vpi_step                     RANGE 0-4095]
#x       [-adjust_rate                  ]
#x       [-allow_self_destined          CHOICES 0 1
#x       [-app_profile_type             CHOICES FTP_CS_3K
#x                                      CHOICES FTP_SU_100
#x                                      CHOICES FTP_SU_MultiIterations
#x                                      CHOICES FTP_TM_20MB
#x                                      CHOICES FTP_TR_3K
#x                                      CHOICES HTTP_1.0/TCP_7500_Conncurrent_Connections
#x                                      CHOICES HTTP_1.0/TCP_Connection_Rate_2000
#x                                      CHOICES HTTP_1.0_Simulate_400_Users
#x                                      CHOICES HTTP_1.0_SU_MultiIteration
#x                                      CHOICES HTTP_1.0_Transaction_Rate_2000
#x                                      CHOICES HTTP1.1_7500_Concurrent_Connections
#x                                      CHOICES HTTP_1.1_Simulate_400_Users
#x                                      CHOICES HTTP_1.1_SU_MultiIterations
#x                                      CHOICES HTTP_1.1_TM_20MB
#x                                      CHOICES HTTP_1.1_Transaction_Rate_11000
#x                                      CHOICES HTTP_1.0/SSL/TCP_500_Concurrent_Connections
#x                                      CHOICES HTTP_1.1/SSL_Transaction_Rate_300
#x                                      CHOICES HTTP_FTP_SMTP_IMAP
#x                                      CHOICES IMAP_CC_4000
#x                                      CHOICES IMAP_CR_800
#x                                      CHOICES IMAP_SU_400
#x                                      CHOICES IMAP_SU_4000
#x                                      CHOICES IMAP_TM_6MB
#x                                      CHOICES IMAP_TR_3000
#x                                      CHOICES IMAP_TR_MultiIteration
#x                                      CHOICES TriplePlay
#x                                      CHOICES POP3_Simulate_4000_Users
#x                                      CHOICES POP3_SU_MultiIterations
#x                                      CHOICES RTSP_Simulate_500_Users
#x                                      CHOICES RTSP_SU_MultiIterations
#x                                      CHOICES SIP_TCP_SU
#x                                      CHOICES SIP_TCP_TR
#x                                      CHOICES SIP_UDP_SU
#x                                      CHOICES SIP_UDP_TR
#x                                      CHOICES SMTP_Simulate_1000_Users
#x                                      CHOICES SMTP_SU_MultiIterations
#x                                      CHOICES TELNET_CC_250
#x                                      CHOICES TELNET_CR_35
#x                                      CHOICES TELNET_SU_100
#x                                      CHOICES TELNET_SU_200
#x                                      CHOICES TELNET_SU_MultiIteration
#x                                      CHOICES TELNET_TR_150
#x                                      CHOICES TELNET_TR_MultiIterations
#x                                      CHOICES VIDEO_MultiIterations
#x                                      CHOICES VIDEO_PlayMedia_Custom
#x                                      CHOICES VIDEO_PlayMedia_EnableMSS
#x                                      CHOICES VIDEO_PlayMedia_Quicktimeplayer
#x                                      CHOICES VIDEO_RealPayLoad
#x                                      CHOICES VIDEO_SU_200
#x                                      CHOICES VIDEO_Syntheticpayload
#x       [-arp_dst_hw_step              MAC]
#x       [-arp_dst_hw_tracking          CHOICES 0 1]
#x       [-arp_hw_address_length        REGEXP (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})]
#x       [-arp_hw_address_length_count  NUMERIC]
#x       [-arp_hw_address_length_mode   CHOICES fixed incr decr list]
#x       [-arp_hw_address_length_step   REGEXP (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})]
#x       [-arp_hw_address_length_tracking      CHOICES 0 1]
#x       [-arp_hw_type                  REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-arp_hw_type_count            NUMERIC]
#x       [-arp_hw_type_mode             CHOICES fixed incr decr list]
#x       [-arp_hw_type_step             REGEXP (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-arp_hw_type_tracking         CHOICES 0 1]
#x       [-arp_operation_mode           CHOICES fixed list]
#x       [-arp_operation_tracking       CHOICES 0 1]
#x       [-arp_protocol_addr_length     REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})]
#x       [-arp_protocol_addr_length_count    NUMERIC]
#x       [-arp_protocol_addr_length_mode     CHOICES fixed incr decr list]
#x       [-arp_protocol_addr_length_step     REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})]
#x       [-arp_protocol_addr_length_tracking  CHOICES 0 1]
#x       [-arp_protocol_type             REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-arp_protocol_type_count      NUMERIC]
#x       [-arp_protocol_type_mode       CHOICES fixed incr decr list]
#x       [-arp_protocol_type_step       REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-arp_protocol_type_tracking   CHOICES 0 1]
#x       [-arp_src_hw_step              MAC]
#x       [-arp_src_hw_tracking          CHOICES 0 1]
#x       [-atm_counter_vci_data_item_list    ANY]
#x       [-atm_counter_vci_mask_select  ANY]
#x       [-atm_counter_vci_mask_value   ANY]
#x       [-atm_counter_vci_mode         CHOICES incr cont_incr decr cont_decr]
#x       [-atm_counter_vci_type         CHOICES fixed counter random table]
#x       [-atm_counter_vpi_data_item_list   ANY]
#x       [-atm_counter_vpi_mask_select  ANY]
#x       [-atm_counter_vpi_mask_value   ANY]
#x       [-atm_counter_vpi_mode         CHOICES incr cont_incr decr cont_decr]
#x       [-atm_counter_vpi_type         CHOICES fixed counter random table]
#x       [-atm_header_aal5error         CHOICES no_error bad_crc]
#x       [-atm_header_cell_loss_priority       CHOICES 0 1]
#x       [-atm_header_cpcs_length       RANGE 28-65535]
#x       [-atm_header_enable_auto_vpi_vci       CHOICES 0 1]
#x       [-atm_header_enable_cl         CHOICES 0 1]
#x       [-atm_header_enable_cpcs_length        CHOICES 0 1]
#x       [-atm_header_encapsulation     CHOICES vcc_mux_ipv4_routed vcc_mux_bridged_eth_fcs vcc_mux_bridged_eth_no_fcs vcc_mux_ipv6_routed vcc_mux_mpls_routed  llc_routed_clip llc_bridged_eth_fcs llc_bridged_eth_no_fcs llc_pppoa vcc_mux_ppoa llc_nlpid_routed]
#x       [-atm_header_generic_flow_ctrl RANGE 0-15]
#x       [-atm_header_hec_errors        RANGE 0-8]
#x       [-atm_range_count              
#x       [-becn                         FLAG]
#x       [-circuit_endpoint_type        CHOICES atm ethernet_vlan ethernet_vlan_arp frame_relay hdlc ipv4 ipv4_arp ipv4_application_traffic ipv6 ipv6_application_traffic ppp fcoe fc DEFAULT ipv4]
#x       [-circuit_type                 CHOICES none l2vpn l3vpn mpls 6pe 6vpe raw vpls stp mac_in_mac quick_flows application DEFAULT none]
#x       [-convert_to_raw               CHOICES 0 1]
#x       [-custom_offset                NUMERIC]
#x       [-custom_values                NUMERIC]
#x       [-data_pattern                 ]
#x       [-data_pattern_mode            CHOICES incr_byte decr_byte fixed random repeating incr_word decr_word]
#x       [-data_tos                     RANGE   0-127]
#x       [-data_tos_count               NUMERIC DEFAULT 1]
#x       [-data_tos_mode                CHOICES fixed incr decr list DEFAULT fixed]
#x       [-data_tos_step                RANGE   0-126 DEFAULT 1]
#x       [-data_tos_tracking            CHOICES 0 1]
#x       [-destination_filter           CHOICES all ethernet atm framerelay hdlc ppp none l2vpn l3vpn mpls 6pe 6vpe bgpvpls mac_in_mac data_center_bridging]
#x       [-dhcp_boot_filename           ]
#x       [-dhcp_boot_filename_tracking  CHOICES 0 1]
#x       [-dhcp_client_hw_addr          REGEXP  ^([a-fA-F0-9]{2,2}[ .:])*([a-fA-F0-9]{2,2})$]
#x       [-dhcp_client_hw_addr_count    NUMERIC]
#x       [-dhcp_client_hw_addr_mode     CHOICES fixed incr decr list]
#x       [-dhcp_client_hw_addr_step     REGEXP  ^([a-fA-F0-9]{2,2}[ .:])*([a-fA-F0-9]{2,2})$]
#x       [-dhcp_client_hw_addr_tracking CHOICES 0 1]
#x       [-dhcp_client_ip_addr          IP]
#x       [-dhcp_client_ip_addr_count    NUMERIC]
#x       [-dhcp_client_ip_addr_mode     CHOICES fixed incr decr list]
#x       [-dhcp_client_ip_addr_step     IP]
#x       [-dhcp_client_ip_addr_tracking CHOICES 0 1]
#x       [-dhcp_flags                   CHOICES broadcast no_broadcast]
#x       [-dhcp_flags_mode              CHOICES fixed list]
#x       [-dhcp_flags_tracking          CHOICES 0 1]
#x       [-dhcp_hops                    NUMERIC]
#x       [-dhcp_hops_count              NUMERIC]
#x       [-dhcp_hops_mode               CHOICES fixed incr decr list]
#x       [-dhcp_hops_step               NUMERIC]
#x       [-dhcp_hops_tracking           CHOICES 0 1]
#x       [-dhcp_hw_len                  NUMERIC]
#x       [-dhcp_hw_len_count            NUMERIC]
#x       [-dhcp_hw_len_mode             CHOICES fixed incr decr list]
#x       [-dhcp_hw_len_step             NUMERIC]
#x       [-dhcp_hw_len_tracking         CHOICES 0 1]
#x       [-dhcp_hw_type                 RANGE 1-21]
#x       [-dhcp_hw_type_count           NUMERIC]
#x       [-dhcp_hw_type_mode            CHOICES fixed incr decr list]
#x       [-dhcp_hw_type_step            NUMERIC]
#x       [-dhcp_hw_type_tracking        CHOICES 0 1]
#x       [-dhcp_magic_cookie            REGEXP  (^[0-9a-fA-F]{1,32}$)|(^0x[0-9a-fA-F]{1,32})]
#x       [-dhcp_magic_cookie_count      NUMERIC]
#x       [-dhcp_magic_cookie_mode       CHOICES fixed incr decr list]
#x       [-dhcp_magic_cookie_step       REGEXP  (^[0-9a-fA-F]{1,32}$)|(^0x[0-9a-fA-F]{1,32})]
#x       [-dhcp_magic_cookie_tracking   CHOICES 0 1]
#x       [-dhcp_operation_code          CHOICES reply request]
#x       [-dhcp_operation_code_mode     CHOICES fixed list]
#x       [-dhcp_operation_code_tracking CHOICES 0 1]
#x       [-dhcp_option                  CHOICES dhcp_pad dhcp_end dhcp_subnet_mask dhcp_time_offset dhcp_gateways dhcp_time_server dhcp_name_server dhcp_domain_name_server dhcp_log_server dhcp_cookie_server dhcp_lpr_server dhcp_impress_server dhcp_resource_location_server dhcp_host_name dhcp_boot_file_size dhcp_merit_dump_file dhcp_domain_name dhcp_swap_server dhcp_root_path dhcp_extension_path dhcp_ip_forwarding_enable dhcp_non_local_src_routing_enable dhcp_policy_filter dhcp_max_datagram_reassembly_size dhcp_default_ip_ttl dhcp_path_mtu_aging_timeout dhcp_path_mtu_plateau_table dhcp_interface_mtu dhcp_all_subnets_are_local dhcp_broadcast_address dhcp_perform_mask_discovery dhcp_mask_supplier dhcp_perform_router_discovery dhcp_router_solicit_addr dhcp_static_route dhcp_trailer_encapsulation dhcp_arp_cache_timeout dhcp_ethernet_encapsulation dhcp_tcp_default_ttl dhcp_tcp_keep_alive_interval dhcp_tcp_keep_garbage dhcp_nis_domain dhcp_nis_server dhcp_ntp_server dhcp_vendor_specific_info dhcp_net_bios_name_svr dhcp_net_bios_datagram_dist_svr dhcp_net_bios_node_type dhcp_net_bios_scope dhcp_xwin_sys_font_svr dhcp_requested_ip_addr dhcp_ip_addr_lease_time dhcp_option_overload dhcp_tftp_svr_name dhcp_boot_file_name dhcp_message_type dhcp_svr_identifier dhcp_param_request_list dhcp_message dhcp_max_message_size dhcp_renewal_time_value dhcp_rebinding_time_value dhcp_vendor_class_id dhcp_client_id dhcp_xwin_sys_display_mgr dhcp_nis_plus_domain dhcp_nis_plus_server dhcp_mobile_ip_home_agent dhcp_smtp_svr dhcp_pop3_svr dhcp_nntp_svr dhcp_www_svr dhcp_default_finger_svr dhcp_default_irc_svr dhcp_street_talk_svr hcp_stda_svr dhcp_agent_information_option dhcp_netware_ip_domain dhcp_network_ip_option]
#x       [-dhcp_option_data             ANY]
#x       [-dhcp_relay_agent_ip_addr     IP]
#x       [-dhcp_relay_agent_ip_addr_count    NUMERIC]
#x       [-dhcp_relay_agent_ip_addr_mode     CHOICES fixed incr decr list]
#x       [-dhcp_relay_agent_ip_addr_step     IP]
#x       [-dhcp_relay_agent_ip_addr_tracking   CHOICES 0 1]
#x       [-dhcp_seconds                 NUMERIC]
#x       [-dhcp_seconds_count           NUMERIC]
#x       [-dhcp_seconds_mode            CHOICES fixed incr decr list]
#x       [-dhcp_seconds_step            NUMERIC]
#x       [-dhcp_seconds_tracking        CHOICES 0 1]
#x       [-dhcp_server_host_name        ]
#x       [-dhcp_server_host_name_tracking    CHOICES 0 1]
#x       [-dhcp_server_ip_addr          IP]
#x       [-dhcp_server_ip_addr_count    NUMERIC]
#x       [-dhcp_server_ip_addr_mode     CHOICES fixed incr decr list]
#x       [-dhcp_server_ip_addr_step     IP]
#x       [-dhcp_server_ip_addr_tracking CHOICES 0 1]
#x       [-dhcp_transaction_id          NUMERIC]
#x       [-dhcp_transaction_id_count    NUMERIC]
#x       [-dhcp_transaction_id_mode     CHOICES fixed incr decr list]
#x       [-dhcp_transaction_id_step     RANGE  0-65534]
#x       [-dhcp_transaction_id_tracking CHOICES 0 1]
#x       [-dhcp_your_ip_addr            IP]
#x       [-dhcp_your_ip_addr_count      NUMERIC]
#x       [-dhcp_your_ip_addr_mode       CHOICES fixed incr decr list]
#x       [-dhcp_your_ip_addr_step       IP]
#x       [-dhcp_your_ip_addr_tracking   CHOICES 0 1]
#x       [-discard_eligible             FLAG]
#x       [-dlci_core_enable             FLAG]
#x       [-dlci_core_value              RANGE 0-63]
#x       [-dlci_count_mode              CHOICES increment cont_increment decrement cont_decrement idle random]
#x       [-dlci_extended_address0       FLAG]
#x       [-dlci_extended_address1       FLAG]
#x       [-dlci_extended_address2       FLAG]
#x       [-dlci_extended_address3       FLAG]
#x       [-dlci_mask_select             HEX]
#x       [-dlci_mask_value              HEX]
#x       [-dlci_repeat_count            NUMERIC]
#x       [-dlci_size                    RANGE 2-4]
#x       [-dlci_value                   NUMERIC]
#x       [-duration                     NUMERIC]
#x       [-dynamic_update_fields        CHOICES ppp ppp_dst dhcp4 dhcp4_dst dhcp6 dhcp6_dst mpls_label_value]
#x       [-egress_custom_offset         NUMERIC | CHOICES NA DEFAULT NA]
#x       [-egress_custom_width          NUMERIC | CHOICES NA DEFAULT NA]
#x       [-egress_custom_field_offset   ANY]
#x       [-egress_tracking              CHOICES none dscp ipv6TC mplsExp custom custom_by_field outer_vlan_priority outer_vlan_id_4  outer_vlan_id_6 outer_vlan_id_8 outer_vlan_id_10 outer_vlan_id_12 inner_vlan_priority inner_vlan_id_4 inner_vlan_id_6 inner_vlan_id_8 inner_vlan_id_10 inner_vlan_id_12 tos_precedence ipv6TC_bits_0_2 ipv6TC_bits_0_5 vnTag_direction_bit vnTag_pointer_bit vnTag_looped_bit DEFAULT none]
#x       [-egress_tracking_encap        CHOICES custom ethernet LLCRoutedCLIP LLCPPPoA LLCBridgedEthernetFCS LLCBridgedEthernetNoFCS VccMuxPPPoA VccMuxIPV4Routed VccMuxBridgedEthernetFCS VccMuxBridgedEthernetNoFCS pos_ppp pos_hdlc frame_relay1490 frame_relay2427 frame_relay_cisco DEFAULT ethernet]
#x       [-emulation_dst_vlan_protocol_tag_id  REGEXP ^[0-9a-fA-F]{4}$]
#x       [-emulation_override_ppp_ip_addr      CHOICES upstream downstream both none DEFAULT none]
#x       [-emulation_src_vlan_protocol_tag_id  REGEXP ^[0-9a-fA-F]{4}$]
#x       [-emulation_multicast_dst_handle       ANY]
#x       [-emulation_multicast_dst_handle_type  ANY]
#x       [-emulation_scalable_dst_handle        ANY]
#x       [-emulation_scalable_dst_port_start    ANY]
#x       [-emulation_scalable_dst_port_count    ANY]
#x       [-emulation_scalable_dst_intf_start    ANY]
#x       [-emulation_scalable_dst_intf_count    ANY]
#x       [-emulation_scalable_src_handle        ANY]
#x       [-emulation_scalable_src_port_start    ANY]
#x       [-emulation_scalable_src_port_count    ANY]
#x       [-emulation_scalable_src_intf_start    ANY]
#x       [-emulation_scalable_src_intf_count    ANY]
#x       [-enable_auto_detect_instrumentation  CHOICES 0 1]
#x       [-enable_ce_to_pe_traffic      CHOICES 0 1
#x       [-enable_data_integrity        CHOICES 0 1]
#x       [-enable_dynamic_mpls_labels   CHOICES 0 1 DEFAULT 0]
#x       [-enable_override_value        CHOICES 0 1
#x       [-enable_pgid                  CHOICES 0 1]
#x       [-enable_test_objective        CHOICES 0 1]
#x       [-enable_time_stamp            CHOICES 0 1]
#x       [-enable_udf1                  ]
#x       [-enable_udf2                  ]
#x       [-enable_udf3                  ]
#x       [-enable_udf4                  ]
#x       [-enable_udf5                  ]
#x       [-endpointset_count            NUMERIC DEFAULT 1]
#x       [-enforce_min_gap              NUMERIC]
#x       [-ethernet_type                CHOICES ethernetII ieee8023snap ieee8023 ieee8022]
#x       [-ethernet_value               HEX]
#x       [-ethernet_value_count         NUMERIC  DEFAULT 1
#x       [-ethernet_value_mode          CHOICES fixed incr decr list DEFAULT fixed
#x       [-ethernet_value_step          HEX DEFAULT 0x01
#x       [-ethernet_value_tracking      CHOICES 0 1 DEFAULT 0
#x       [-fcs_type                     CHOICES bad_CRC no_CRC alignment dribble]
#x       [-fecn                         FLAG]
#x       [-field_activeFieldChoice      CHOICES 0 1 DEFAULT 1
#x       [-field_auto                   CHOICES 0 1 DEFAULT 0
#x       [-field_countValue             ANY
#x       [-field_fieldValue             ANY
#x       [-field_fullMesh               CHOICES 0 1 DEFAULT 0
#x       [-field_handle                 ]
#x       [-field_linked                 ANY]
#x       [-field_linked_to              ANY]
#x       [-field_optionalEnabled        CHOICES 0 1 DEFAULT 0
#x       [-field_singleValue            ANY
#x       [-field_startValue             ANY
#x       [-field_stepValue              ANY
#x       [-field_trackingEnabled        CHOICES 0 1 DEFAULT 0
#x       [-field_valueList              ANY
#x       [-field_valueType              ANY
#x       [-frame_rate_distribution_port       CHOICES apply_to_all split_evenly]
#x       [-frame_rate_distribution_stream     CHOICES apply_to_all split_evenly]
#x       [-frame_sequencing             CHOICES enable disable]
#x       [-frame_sequencing_mode        CHOICES rx_switched_path rx_switched_path_fixed rx_threshold]
#x       [-frame_sequencing_offset      ]
#x       [-frame_size                   RANGE 12-13312]
#x       [-frame_size_distribution      CHOICES cisco imix quadmodal tolly trimodal imix_ipsec imix_ipv6 imix_std imix_tcp DEFAULT cisco]
#x       [-frame_size_gauss             REGEXP ^([0-9]+:[0-9]+(\.[0-9]+)*:[0-9]+ ){0,3}[0-9]+:[0-9]+(\.[0-9]+)*:[0-9]+$]
#x       [-frame_size_imix              REGEXP ^([0-9]+:[0-9]+ )*[0-9]+:[0-9]+$]
#x       [-frame_size_max               RANGE 12-13312]
#x       [-frame_size_min               RANGE 12-13312]
#x       [-frame_size_step              RANGE 0-13292]
#x       [-global_dest_mac_retry_count        RANGE   1-2147483647]
#x       [-global_dest_mac_retry_delay        RANGE   1-2147483647]
#x       [-global_enable_dest_mac_retry       CHOICES 0 1]
#x       [-global_enable_min_frame_size       CHOICES 0 1]
#x       [-global_enable_staggered_transmit   CHOICES 0 1]
#x       [-global_enable_stream_ordering      CHOICES 0 1]
#x       [-global_stream_control              CHOICES continuous iterations]
#x       [-global_stream_control_iterations   RANGE   1-2147483647]
#x       [-global_large_error_threshhold      NUMERIC]
#x       [-global_enable_mac_change_on_fly    CHOICES 0 1]
#x       [-global_max_traffic_generation_queries     NUMERIC]
#x       [-global_display_mpls_current_label_value   CHOICES 0 1]
#x       [-global_mpls_label_learning_timeout NUMERIC]
#x       [-global_refresh_learned_info_before_apply  CHOICES 0 1]
#x       [-global_use_tx_rx_sync              CHOICES 0 1]
#x       [-global_wait_time                   RANGE   1-2147483647]
#x       [-gre_checksum                 HEX]
#x       [-gre_checksum_count           NUMERIC]
#x       [-gre_checksum_enable          CHOICES 0 1]
#x       [-gre_checksum_enable_mode     CHOICES fixed list]
#x       [-gre_checksum_enable_tracking CHOICES 0 1]
#x       [-gre_checksum_mode            CHOICES fixed incr decr list]
#x       [-gre_checksum_step            REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-gre_checksum_tracking        CHOICES 0 1]
#x       [-gre_key                      HEX]
#x       [-gre_key_count                NUMERIC]
#x       [-gre_key_enable               CHOICES 0 1]
#x       [-gre_key_enable_mode          CHOICES fixed list]
#x       [-gre_key_enable_tracking      CHOICES 0 1]
#x       [-gre_key_mode                 CHOICES fixed incr decr list]
#x       [-gre_key_step                 REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})]
#x       [-gre_key_tracking             CHOICES 0 1]
#x       [-gre_reserved0                HEX]
#x       [-gre_reserved0_count          NUMERIC]
#x       [-gre_reserved0_mode           CHOICES fixed incr decr list]
#x       [-gre_reserved0_step           REGEXP  (^[0-9a-fA-F]{1,3}$)|(^0x[0-9a-fA-F]{1,3})]
#x       [-gre_reserved0_tracking       CHOICES 0 1]
#x       [-gre_reserved1                HEX]
#x       [-gre_reserved1_count          NUMERIC]
#x       [-gre_reserved1_mode           CHOICES fixed incr decr list]
#x       [-gre_reserved1_step           REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-gre_reserved1_tracking       CHOICES 0 1]
#x       [-gre_seq_enable               CHOICES 0 1]
#x       [-gre_seq_enable_mode          CHOICES fixed list]
#x       [-gre_seq_enable_tracking      CHOICES 0 1]
#x       [-gre_seq_number               HEX]
#x       [-gre_seq_number_count         NUMERIC]
#x       [-gre_seq_number_mode          CHOICES fixed incr decr list]
#x       [-gre_seq_number_step          REGEXP (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})]
#x       [-gre_seq_number_tracking      CHOICES 0 1]
#x       [-gre_valid_checksum_enable    CHOICES 0 1]
#x       [-gre_version                  RANGE 0-7]
#x       [-gre_version_count            NUMERIC]
#x       [-gre_version_mode             CHOICES fixed incr decr list]
#x       [-gre_version_step             RANGE   0-6]
#x       [-gre_version_tracking         CHOICES 0 1]
#x       [-header_handle                ]
#x       [-hosts_per_net                NUMERIC]
#x       [-icmp_checksum_count          NUMERIC]
#x       [-icmp_checksum_mode           CHOICES fixed incr decr list]
#x       [-icmp_checksum_step           REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-icmp_checksum_tracking       CHOICES 0 1]
#x       [-icmp_code_count              NUMERIC]
#x       [-icmp_code_mode               CHOICES fixed incr decr list]
#x       [-icmp_code_step               RANGE   0-254]
#x       [-icmp_code_tracking           CHOICES 0 1]
#x       [-icmp_id_count                NUMERIC]
#x       [-icmp_id_mode                 CHOICES fixed incr decr list]
#x       [-icmp_id_step                 RANGE   0-65534]
#x       [-icmp_id_tracking             CHOICES 0 1]
#x       [-icmp_max_response_delay_ms   RANGE   0-65535]
#x       [-icmp_max_response_delay_ms_count   NUMERIC]
#x       [-icmp_max_response_delay_ms_mode    CHOICES fixed incr decr list]
#x       [-icmp_max_response_delay_ms_step    RANGE   0-65534]
#x       [-icmp_max_response_delay_ms_tracking   CHOICES 0 1]
#x       [-icmp_mc_query_v2_interval_code      REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})]
#x       [-icmp_mc_query_v2_interval_code_count  NUMERIC]
#x       [-icmp_mc_query_v2_interval_code_mode    CHOICES fixed incr decr list]
#x       [-icmp_mc_query_v2_interval_code_step    REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})]
#x       [-icmp_mc_query_v2_interval_code_tracking CHOICES 0 1]
#x       [-icmp_mc_query_v2_robustness_var       RANGE   0-7]
#x       [-icmp_mc_query_v2_robustness_var_count  NUMERIC]
#x       [-icmp_mc_query_v2_robustness_var_mode   CHOICES fixed incr decr list]
#x       [-icmp_mc_query_v2_robustness_var_step    RANGE   0-6]
#x       [-icmp_mc_query_v2_robustness_var_tracking   CHOICES 0 1]
#x       [-icmp_mc_query_v2_s_flag      CHOICES 0 1]
#x       [-icmp_mc_query_v2_s_flag_mode CHOICES fixed list]
#x       [-icmp_mc_query_v2_s_flag_tracking    CHOICES 0 1]
#x       [-icmp_mobile_pam_m_bit        CHOICES 0 1]
#x       [-icmp_mobile_pam_m_bit_mode   CHOICES fixed list]
#x       [-icmp_mobile_pam_m_bit_tracking CHOICES 0 1]
#x       [-icmp_mobile_pam_o_bit        CHOICES 0 1]
#x       [-icmp_mobile_pam_o_bit_mode   CHOICES fixed list]
#x       [-icmp_mobile_pam_o_bit_tracking CHOICES 0 1]
#x       [-icmp_multicast_address       IPV6]
#x       [-icmp_multicast_address_count NUMERIC]
#x       [-icmp_multicast_address_mode  CHOICES fixed incr decr list]
#x       [-icmp_multicast_address_step  IPV6]
#x       [-icmp_multicast_address_tracking   CHOICES 0 1]
#x       [-icmp_ndp_nam_o_flag          CHOICES 0 1]
#x       [-icmp_ndp_nam_o_flag_mode     CHOICES fixed list]
#x       [-icmp_ndp_nam_o_flag_tracking CHOICES 0 1]
#x       [-icmp_ndp_nam_r_flag          CHOICES 0 1]
#x       [-icmp_ndp_nam_r_flag_mode     CHOICES fixed list]
#x       [-icmp_ndp_nam_r_flag_tracking CHOICES 0 1]
#x       [-icmp_ndp_nam_s_flag          CHOICES 0 1]
#x       [-icmp_ndp_nam_s_flag_mode     CHOICES fixed list]
#x       [-icmp_ndp_nam_s_flag_tracking CHOICES 0 1]
#x       [-icmp_ndp_ram_h_flag          CHOICES 0 1]
#x       [-icmp_ndp_ram_h_flag_mode     CHOICES fixed list]
#x       [-icmp_ndp_ram_h_flag_tracking CHOICES 0 1]
#x       [-icmp_ndp_ram_hop_limit       RANGE   0-255]
#x       [-icmp_ndp_ram_hop_limit_count NUMERIC]
#x       [-icmp_ndp_ram_hop_limit_mode  CHOICES fixed incr decr list]
#x       [-icmp_ndp_ram_hop_limit_step  RANGE   0-254]
#x       [-icmp_ndp_ram_hop_limit_tracking                                      CHOICES 0 1]
#x       [-icmp_ndp_ram_m_flag          CHOICES 0 1]
#x       [-icmp_ndp_ram_m_flag_mode     CHOICES fixed list]
#x       [-icmp_ndp_ram_m_flag_tracking CHOICES 0 1]
#x       [-icmp_ndp_ram_o_flag          CHOICES 0 1]
#x       [-icmp_ndp_ram_o_flag_mode     CHOICES fixed list]
#x       [-icmp_ndp_ram_o_flag_tracking CHOICES 0 1]
#x       [-icmp_ndp_ram_reachable_time  RANGE   0-4294967295]
#x       [-icmp_ndp_ram_reachable_time_count  NUMERIC]
#x       [-icmp_ndp_ram_reachable_time_mode    CHOICES fixed incr decr list]
#x       [-icmp_ndp_ram_reachable_time_step   RANGE   0-4294967294]
#x       [-icmp_ndp_ram_reachable_time_tracking  CHOICES 0 1]
#x       [-icmp_ndp_ram_retransmit_timer          RANGE   0-4294967295]
#x       [-icmp_ndp_ram_retransmit_timer_count   NUMERIC]
#x       [-icmp_ndp_ram_retransmit_timer_mode    CHOICES fixed incr decr list]
#x       [-icmp_ndp_ram_retransmit_timer_step    RANGE   0-4294967294]
#x       [-icmp_ndp_ram_retransmit_timer_tracking   CHOICES 0 1]
#x       [-icmp_ndp_ram_router_lifetime          RANGE   0-65535]
#x       [-icmp_ndp_ram_router_lifetime_count    NUMERIC]
#x       [-icmp_ndp_ram_router_lifetime_mode     CHOICES fixed incr decr list]
#x       [-icmp_ndp_ram_router_lifetime_step     RANGE   0-65534]
#x       [-icmp_ndp_ram_router_lifetime_tracking CHOICES 0 1]
#x       [-icmp_ndp_rm_dest_addr                 IPV6]
#x       [-icmp_ndp_rm_dest_addr_count           NUMERIC]
#x       [-icmp_ndp_rm_dest_addr_mode            CHOICES fixed incr decr list]
#x       [-icmp_ndp_rm_dest_addr_step            IPV6]
#x       [-icmp_ndp_rm_dest_addr_tracking        CHOICES 0 1]
#x       [-icmp_param_problem_message_pointer    RANGE   0-4294967295]
#x       [-icmp_param_problem_message_pointer_count   NUMERIC]
#x       [-icmp_param_problem_message_pointer_mode    CHOICES fixed incr decr list]
#x       [-icmp_param_problem_message_pointer_step    RANGE   0-4294967294]
#x       [-icmp_param_problem_message_pointer_tracking   CHOICES 0 1]
#x       [-icmp_pkt_too_big_mtu                  RANGE   0-4294967295]
#x       [-icmp_pkt_too_big_mtu_count            NUMERIC]
#x       [-icmp_pkt_too_big_mtu_mode             CHOICES fixed incr decr list]
#x       [-icmp_pkt_too_big_mtu_step             RANGE   0-4294967294]
#x       [-icmp_pkt_too_big_mtu_tracking         CHOICES 0 1]
#x       [-icmp_seq_count                        NUMERIC]
#x       [-icmp_seq_mode                         CHOICES fixed incr decr list]
#x       [-icmp_seq_step                         RANGE   0-65534]
#x       [-icmp_seq_tracking                     CHOICES 0 1]
#x       [-icmp_target_addr                      IPV6]
#x       [-icmp_target_addr_count                NUMERIC]
#x       [-icmp_target_addr_mode                 CHOICES fixed incr decr list]
#x       [-icmp_target_addr_step                 IPV6]
#x       [-icmp_target_addr_tracking             CHOICES 0 1]
#x       [-icmp_type_count                       NUMERIC]
#x       [-icmp_type_mode                        CHOICES fixed incr decr list]
#x       [-icmp_type_step                        RANGE   0-254]
#x       [-icmp_type_tracking                    CHOICES 0 1]
#x       [-icmp_unused                           REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})]
#x       [-icmp_unused_count                     NUMERIC]
#x       [-icmp_unused_mode                      CHOICES fixed incr decr list]
#x       [-icmp_unused_step                      REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})]
#x       [-icmp_unused_tracking                  CHOICES 0]
#x       [-igmp_aux_data_length                  RANGE  0-255]
#x       [-igmp_aux_data_length_count            NUMERIC]
#x       [-igmp_aux_data_length_mode             CHOICES fixed incr decr list]
#x       [-igmp_aux_data_length_step             RANGE  0-254]
#x       [-igmp_aux_data_length_tracking         CHOICES 0 1]
#x       [-igmp_checksum                         REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-igmp_checksum_count                   NUMERIC]
#x       [-igmp_checksum_mode                    CHOICES fixed incr decr list]
#x       [-igmp_checksum_step                    REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-igmp_checksum_tracking                CHOICES 0 1]
#x       [-igmp_data_v3r                         HEX]
#x       [-igmp_data_v3r_count                   NUMERIC]
#x       [-igmp_data_v3r_mode                    CHOICES fixed incr decr list]
#x       [-igmp_data_v3r_step                    HEX]
#x       [-igmp_data_v3r_tracking                CHOICES 0 1]
#x       [-igmp_group_tracking                   CHOICES 0 1]
#x       [-igmp_length_v3r                       RANGE  0-255]
#x       [-igmp_length_v3r_count                 NUMERIC]
#x       [-igmp_length_v3r_mode                  CHOICES fixed incr decr list]
#x       [-igmp_length_v3r_step                  RANGE  0-254]
#x       [-igmp_length_v3r_tracking              CHOICES 0 1]
#x       [-igmp_max_response_time_count          NUMERIC]
#x       [-igmp_max_response_time_mode           CHOICES fixed incr decr list]
#x       [-igmp_max_response_time_step           RANGE   0-254]
#x       [-igmp_max_response_time_tracking       CHOICES 0 1]
#x       [-igmp_msg_type_tracking                CHOICES 0 1]
#x       [-igmp_multicast_src_count              ANY]
#x       [-igmp_multicast_src_mode               ANY]
#x       [-igmp_multicast_src_step               ANY]
#x       [-igmp_multicast_src_tracking           ANY]
#x       [-igmp_qqic_count                       NUMERIC]
#x       [-igmp_qqic_mode                        CHOICES fixed incr decr list]
#x       [-igmp_qqic_step                        RANGE 0-254]
#x       [-igmp_qqic_tracking                    CHOICES 0 1]
#x       [-igmp_qrv_count                        NUMERIC]
#x       [-igmp_qrv_mode                         CHOICES fixed incr decr list]
#x       [-igmp_qrv_step                         RANGE 0-6]
#x       [-igmp_qrv_tracking                     CHOICES 0 1]
#x       [-igmp_record_type_mode                 CHOICES fixed list]
#x       [-igmp_record_type_tracking             CHOICES 0 1]
#x       [-igmp_reserved_v3q                     RANGE 0-15]
#x       [-igmp_reserved_v3q_count               NUMERIC]
#x       [-igmp_reserved_v3q_mode                CHOICES fixed incr decr list]
#x       [-igmp_reserved_v3q_step                RANGE 0-14]
#x       [-igmp_reserved_v3q_tracking            CHOICES 0 1]
#x       [-igmp_reserved_v3r1                    RANGE 0-255]
#x       [-igmp_reserved_v3r1_count              NUMERIC]
#x       [-igmp_reserved_v3r1_mode               CHOICES fixed incr decr list]
#x       [-igmp_reserved_v3r1_step               RANGE 0-254]
#x       [-igmp_reserved_v3r1_tracking           CHOICES 0 1]
#x       [-igmp_reserved_v3r2                    RANGE 0-65535]
#x       [-igmp_reserved_v3r2_count              NUMERIC]
#x       [-igmp_reserved_v3r2_mode               CHOICES fixed incr decr list]
#x       [-igmp_reserved_v3r2_step               RANGE 0-65534]
#x       [-igmp_reserved_v3r2_tracking           CHOICES 0 1]
#x       [-igmp_s_flag_mode                      CHOICES fixed list]
#x       [-igmp_s_flag_tracking                  CHOICES 0 1]
#x       [-igmp_unused                           REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})]
#x       [-igmp_unused_count                     NUMERIC]
#x       [-igmp_unused_mode                      CHOICES fixed incr decr list]
#x       [-igmp_unused_step                      REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})]
#x       [-igmp_unused_tracking                  CHOICES 0 1]
#x       [-indirect                              ]
#x       [-inner_ip_dst_addr                     IPV4]
#x       [-inner_ip_dst_count                    RANGE   1-4294967295]
#x       [-inner_ip_dst_mode                     CHOICES fixed increment decrement random]
#x       [-inner_ip_dst_step                     IPV4]
#x       [-inner_ip_dst_tracking                 CHOICES 0 1]
#x       [-inner_ip_src_addr                     IPV4]
#x       [-inner_ip_src_count                    RANGE   1-4294967295]
#x       [-inner_ip_src_mode                     CHOICES fixed increment decrement random]
#x       [-inner_ip_src_step                     IPV4]
#x       [-inner_ip_src_tracking                 CHOICES 0 1]
#x       [-inner_ipv6_dst_addr                   IPV6]
#x       [-inner_ipv6_dst_count                  RANGE   1-4294967295]
#x       [-inner_ipv6_dst_mask                   RANGE 0-128]
#x       [-inner_ipv6_dst_mode                   CHOICES fixed increment decrement random incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group]
#x       [-inner_ipv6_dst_step                   IPV6]
#x       [-inner_ipv6_dst_tracking               CHOICES 0 1]
#x       [-inner_ipv6_flow_label                 RANGE   0-1048575]
#x       [-inner_ipv6_flow_label_count           NUMERIC]
#x       [-inner_ipv6_flow_label_mode            CHOICES fixed incr decr list]
#x       [-inner_ipv6_flow_label_step            RANGE   0-1048574]
#x       [-inner_ipv6_flow_label_tracking        CHOICES 0 1]
#x       [-inner_ipv6_frag_id                    RANGE   0-4294967295]
#x       [-inner_ipv6_frag_id_count              NUMERIC]
#x       [-inner_ipv6_frag_id_mode               CHOICES fixed incr decr list]
#x       [-inner_ipv6_frag_id_step               RANGE   0-4294967294]
#x       [-inner_ipv6_frag_id_tracking           CHOICES 0 1]
#x       [-inner_ipv6_frag_more_flag             FLAG]
#x       [-inner_ipv6_frag_more_flag_mode        CHOICES fixed list]
#x       [-inner_ipv6_frag_more_flag_tracking    CHOICES 0 1]
#x       [-inner_ipv6_frag_offset                RANGE   0-8191]
#x       [-inner_ipv6_frag_offset_count          NUMERIC]
#x       [-inner_ipv6_frag_offset_mode           CHOICES fixed incr decr list]
#x       [-inner_ipv6_frag_offset_step           RANGE   0-8190]
#x       [-inner_ipv6_frag_offset_tracking       CHOICES 0 1]
#x       [-inner_ipv6_hop_limit                  RANGE   0-255]
#x       [-inner_ipv6_hop_limit_count            NUMERIC]
#x       [-inner_ipv6_hop_limit_mode             CHOICES fixed incr decr list]
#x       [-inner_ipv6_hop_limit_step             RANGE   0-254]
#x       [-inner_ipv6_hop_limit_tracking         CHOICES 0 1]
#x       [-inner_ipv6_src_addr                   IPV6]
#x       [-inner_ipv6_src_count                  RANGE   1-4294967295]
#x       [-inner_ipv6_src_mask                   RANGE 0-128]
#x       [-inner_ipv6_src_mode                   CHOICES fixed increment decrement random incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group]
#x       [-inner_ipv6_src_step                   IPV6]
#x       [-inner_ipv6_src_tracking               CHOICES 0 1]
#x       [-inner_ipv6_traffic_class              RANGE   0-255]
#x       [-inner_ipv6_traffic_class_count        NUMERIC]
#x       [-inner_ipv6_traffic_class_mode         CHOICES fixed incr decr list]
#x       [-inner_ipv6_traffic_class_step         RANGE   0-254]
#x       [-inner_ipv6_traffic_class_tracking     CHOICES 0 1]
#x       [-inner_protocol                        CHOICES ipv4 ipv6 HEX]
#x       [-inner_protocol_count                  NUMERIC]
#x       [-inner_protocol_mode                   CHOICES fixed incr decr]
#x       [-inner_protocol_step                   HEX]
#x       [-inner_protocol_tracking               CHOICES 0 1]
#x       [-integrity_signature                   REGEXP ^([0-9a-fA-F]{2}[.: ]{0,1}){0,3}[0-9a-fA-F]{2}$]
#x       [-integrity_signature_offset            RANGE 12-65535]
#x       [-inter_frame_gap                       NUMERIC]
#x       [-inter_frame_gap_unit                  CHOICES bytes ns]
#x       [-ip_checksum_count                     NUMERIC DEFAULT 1]
#x       [-ip_checksum_mode                      CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ip_checksum_step                      NUMERIC  DEFAULT 1]
#x       [-ip_checksum_tracking                  CHOICES 0 1]
#x       [-ip_cost                               CHOICES 0 1]
#x       [-ip_cost_mode                          CHOICES fixed list DEFAULT fixed]
#x       [-ip_cost_tracking                      CHOICES 0 1]
#x       [-ip_cu_count                           NUMERIC  DEFAULT 1]
#x       [-ip_cu_mode                            CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ip_cu_step                            RANGE   0-2 DEFAULT 1]
#x       [-ip_cu_tracking                        CHOICES 0 1]
#x       [-ip_delay                              CHOICES 0 1]
#x       [-ip_delay_mode                         CHOICES fixed list DEFAULT fixed]
#x       [-ip_delay_tracking                     CHOICES 0 1]
#x       [-ip_dscp_mode                          CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ip_dscp_tracking                      CHOICES 0 1]
#x       [-ip_dst_tracking                       CHOICES 0 1]
#x       [-ip_fragment_last_mode                 CHOICES fixed list DEFAULT fixed]
#x       [-ip_fragment_last_tracking             CHOICES 0 1]
#x       [-ip_fragment_mode                      CHOICES fixed list DEFAULT fixed]
#x       [-ip_fragment_offset_count              NUMERIC  DEFAULT 1]
#x       [-ip_fragment_offset_mode               CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ip_fragment_offset_step               RANGE   0-8190 DEFAULT 1]
#x       [-ip_fragment_offset_tracking           CHOICES 0 1]
#x       [-ip_fragment_tracking                  CHOICES 0 1]
#x       [-ip_hdr_length_count                   NUMERIC DEFAULT 1]
#x       [-ip_hdr_length_mode                    CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ip_hdr_length_step                    NUMERIC DEFAULT 1]
#x       [-ip_hdr_length_tracking                CHOICES 0 1]
#x       [-ip_id_count                           NUMERIC DEFAULT 1]
#x       [-ip_id_mode                            CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ip_id_step                            RANGE   0-65534 DEFAULT 1]
#x       [-ip_id_tracking                        CHOICES 0 1]
#x       [-ip_length_override                    CHOICES 0 1]
#x       [-ip_length_override_mode               CHOICES fixed list DEFAULT fixed]
#x       [-ip_length_override_tracking           CHOICES 0 1]
#x       [-ip_opt_loose_routing                  IP]
#x       [-ip_opt_security                       ]
#x       [-ip_opt_strict_routing                 IP]
#x       [-ip_opt_timestamp                      ]
#x       [-ip_precedence_count                   NUMERIC DEFAULT 1]
#x       [-ip_precedence_mode                    CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ip_precedence_step                    RANGE   0-6 DEFAULT 1]
#x       [-ip_precedence_tracking                CHOICES 0 1]
#x       [-ip_protocol_count                     NUMERIC DEFAULT 1]
#x       [-ip_protocol_mode                      CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ip_protocol_step                      RANGE   0-254 DEFAULT 1]
#x       [-ip_protocol_tracking                  CHOICES 0 1]
#x       [-ip_reliability                        CHOICES 0 1]
#x       [-ip_reliability_mode                   CHOICES fixed list DEFAULT fixed]
#x       [-ip_reliability_tracking               CHOICES 0 1]
#x       [-ip_reserved                           CHOICES 0 1]
#x       [-ip_reserved_mode                      CHOICES fixed list DEFAULT fixed]
#x       [-ip_reserved_tracking                  CHOICES 0 1]
#x       [-ip_src_tracking                       CHOICES 0 1]
#x       [-ip_throughput                         CHOICES 0 1]
#x       [-ip_throughput_mode                    CHOICES fixed list DEFAULT fixed]
#x       [-ip_throughput_tracking                CHOICES 0 1]
#x       [-ip_total_length                       RANGE 0-65535]
#x       [-ip_total_length_count                 NUMERIC DEFAULT 1]
#x       [-ip_total_length_mode                  CHOICES fixed incr decr list auto DEFAULT fixed]
#x       [-ip_total_length_step                  RANGE   0-65534 DEFAULT 1]
#x       [-ip_total_length_tracking              CHOICES 0 1]
#x       [-ip_ttl_count                          NUMERIC DEFAULT 1]
#x       [-ip_ttl_mode                           CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ip_ttl_step                           RANGE   0-254 DEFAULT 1]
#x       [-ip_ttl_tracking                       CHOICES 0 1]
#x       [-ipv6_auth_next_header                 RANGE   0-255]
#x       [-ipv6_auth_next_header_count           NUMERIC DEFAULT 1]
#x       [-ipv6_auth_next_header_mode            CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_auth_next_header_step            RANGE   0-254 DEFAULT 1]
#x       [-ipv6_auth_next_header_tracking        CHOICES 0 1]
#x       [-ipv6_auth_padding                     HEX DEFAULT 0]
#x       [-ipv6_auth_padding_count               NUMERIC DEFAULT 1]
#x       [-ipv6_auth_padding_mode                CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_auth_padding_step                HEX DEFAULT 1]
#x       [-ipv6_auth_padding_tracking            CHOICES 0 1]
#x       [-ipv6_auth_payload_len                 RANGE 0-4294967295]
#x       [-ipv6_auth_payload_len_count           NUMERIC  DEFAULT 1]
#x       [-ipv6_auth_payload_len_mode            CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_auth_payload_len_step            RANGE   0-254 DEFAULT 1]
#x       [-ipv6_auth_payload_len_tracking        CHOICES 0 1]
#x       [-ipv6_auth_reserved                    REGEXP (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4}) DEFAULT 0]
#x       [-ipv6_auth_reserved_count              NUMERIC DEFAULT 1]
#x       [-ipv6_auth_reserved_mode               CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_auth_reserved_step               REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4}) DEFAULT 1]
#x       [-ipv6_auth_reserved_tracking           CHOICES 0 1]
#x       [-ipv6_auth_seq_num                     RANGE 0-4294967295]
#x       [-ipv6_auth_seq_num_count               NUMERIC DEFAULT 1]
#x       [-ipv6_auth_seq_num_mode                CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_auth_seq_num_step                REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8}) DEFAULT 1]
#x       [-ipv6_auth_seq_num_tracking            CHOICES 0 1]
#x       [-ipv6_auth_spi                         RANGE 0-4294967295]
#x       [-ipv6_auth_spi_count                   NUMERIC DEFAULT 1]
#x       [-ipv6_auth_spi_mode                    CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_auth_spi_step                    REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8}) DEFAULT 1]
#x       [-ipv6_auth_spi_tracking                CHOICES 0 1]
#x       [-ipv6_auth_string                      REGEXP ^([0-9a-fA-F]{2}[.:]{1})+[0-9a-fA-F]{2}$]
#x       [-ipv6_auth_string_count                NUMERIC DEFAULT 1]
#x       [-ipv6_auth_string_mode                 CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_auth_string_step                 ANY DEFAULT 1]
#x       [-ipv6_auth_string_tracking             CHOICES 0 1]
#x       [-ipv6_auth_type                        CHOICES md5 sha1 DEFAULT md5]
#x       [-ipv6_auth_md5sha1_string              REGEXP ^([0-9a-fA-F]{2}[.:]{1})+[0-9a-fA-F]{2}$]
#x       [-ipv6_auth_md5sha1_string_count        NUMERIC DEFAULT 1]
#x       [-ipv6_auth_md5sha1_string_mode         CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_auth_md5sha1_string_step         ANY DEFAULT 1]
#x       [-ipv6_auth_md5sha1_string_tracking     CHOICES 0 1]
#x       [-ipv6_dst_mask                         RANGE 0-128]
#x       [-ipv6_dst_tracking                     CHOICES 0 1]
#x       [-ipv6_encap_seq_number                 REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8}) DEFAULT 0x0]
#x       [-ipv6_encap_seq_number_count           NUMERIC DEFAULT 1]
#x       [-ipv6_encap_seq_number_mode            CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_encap_seq_number_step            REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8}) DEFAULT 0x1]
#x       [-ipv6_encap_seq_number_tracking        CHOICES 0 1]
#x       [-ipv6_encap_spi                        RANGE   0-4294967295]
#x       [-ipv6_encap_spi_count                  NUMERIC DEFAULT 1]
#x       [-ipv6_encap_spi_mode                   CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_encap_spi_step                   RANGE   0-4294967294 DEFAULT 1]
#x       [-ipv6_encap_spi_tracking               CHOICES 0 1]
#x       [-ipv6_extension_header                 CHOICES none hop_by_hop routing destination authentication fragment encapsulation pseudo]
#x       [-ipv6_flow_label_count                 NUMERIC DEFAULT 1]
#x       [-ipv6_flow_label_mode                  CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_flow_label_step                  RANGE   0-1048574 DEFAULT 1]
#x       [-ipv6_flow_label_tracking              CHOICES 0 1]
#x       [-ipv6_flow_version                     RANGE   0-15 DEFAULT 0]
#x       [-ipv6_flow_version_count               NUMERIC DEFAULT 1]
#x       [-ipv6_flow_version_mode                CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_flow_version_step                RANGE   0-14 DEFAULT 1]
#x       [-ipv6_flow_version_tracking            CHOICES 0 1]
#x       [-ipv6_frag_id_count                    NUMERIC DEFAULT 1    ]
#x       [-ipv6_frag_id_mode                     CHOICES fixed incr decr list DEFAULT fixed    ]
#x       [-ipv6_frag_id_step                     RANGE   0-4294967294 DEFAULT 1]
#x       [-ipv6_frag_id_tracking                 CHOICES 0 1  ]
#x       [-ipv6_frag_more_flag_mode              CHOICES fixed list DEFAULT fixed    ]
#x       [-ipv6_frag_more_flag_tracking          CHOICES 0 1]
#x       [-ipv6_frag_offset_count                NUMERIC DEFAULT 1    ]
#x       [-ipv6_frag_offset_mode                 CHOICES fixed incr decr list DEFAULT fixed    ]
#x       [-ipv6_frag_offset_step                 RANGE   0-8190  DEFAULT 1     ]
#x       [-ipv6_frag_offset_tracking             CHOICES 0 1]
#x       [-ipv6_frag_res_2bit                    RANGE 0-3]
#x       [-ipv6_frag_res_2bit_count              NUMERIC DEFAULT 1    ]
#x       [-ipv6_frag_res_2bit_mode               CHOICES fixed incr decr list DEFAULT fixed    ]
#x       [-ipv6_frag_res_2bit_step               RANGE   0-2 DEFAULT 1    ]
#x       [-ipv6_frag_res_2bit_tracking           CHOICES 0 1  ]
#x       [-ipv6_frag_res_8bit                    ANY]
#x       [-ipv6_frag_res_8bit_count              NUMERIC]
#x       [-ipv6_frag_res_8bit_mode               CHOICES fixed incr decr list]
#x       [-ipv6_frag_res_8bit_step               RANGE   0-254]
#x       [-ipv6_frag_res_8bit_tracking           CHOICES 0 1]
#x       [-ipv6_hop_by_hop_options               ]
#x       [-ipv6_hop_limit_count                  NUMERIC DEFAULT 1]
#x       [-ipv6_hop_limit_mode                   CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_hop_limit_step                   RANGE   0-254 DEFAULT 1]
#x       [-ipv6_hop_limit_tracking               CHOICES 0 1]
#x       [-ipv6_next_header_count                NUMERIC DEFAULT 1]
#x       [-ipv6_next_header_mode                 CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_next_header_step                 RANGE   0-254 DEFAULT 1]
#x       [-ipv6_next_header_tracking             CHOICES 0 1]
#x       [-ipv6_pseudo_dst_addr                  IPV6 DEFAULT 0::0]
#x       [-ipv6_pseudo_dst_addr_count            NUMERIC DEFAULT 1]
#x       [-ipv6_pseudo_dst_addr_mode             CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_pseudo_dst_addr_step             IPV6 DEFAULT 0::1]
#x       [-ipv6_pseudo_dst_addr_tracking         CHOICES 0 1]
#x       [-ipv6_pseudo_src_addr                  IPV6 DEFAULT 0::0]
#x       [-ipv6_pseudo_src_addr_count            NUMERIC DEFAULT 1]
#x       [-ipv6_pseudo_src_addr_mode             CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_pseudo_src_addr_step             IPV6 DEFAULT 0::1]
#x       [-ipv6_pseudo_src_addr_tracking         CHOICES 0 1]
#x       [-ipv6_pseudo_uppper_layer_pkt_length   RANGE   0-4294967295 DEFAULT 0]
#x       [-ipv6_pseudo_uppper_layer_pkt_length_count   NUMERIC DEFAULT 1]
#x       [-ipv6_pseudo_uppper_layer_pkt_length_mode    CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_pseudo_uppper_layer_pkt_length_step    RANGE   0-4294967294 DEFAULT 1]
#x       [-ipv6_pseudo_uppper_layer_pkt_length_tracking  CHOICES 0 1]
#x       [-ipv6_pseudo_zero_number               REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8}) DEFAULT 0x0]
#x       [-ipv6_pseudo_zero_number_count         NUMERIC  DEFAULT 1]
#x       [-ipv6_pseudo_zero_number_mode          CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_pseudo_zero_number_step          REGEXP (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8}) DEFAULT 0x1]
#x       [-ipv6_pseudo_zero_number_tracking      CHOICES 0 1]
#x       [-ipv6_routing_node_list                IPV6]
#x       [-ipv6_routing_res                      REGEXP ^([0-9a-fA-F]{2}[.:]{1}){3}[0-9a-fA-F]{2}$]
#x       [-ipv6_routing_res_count                NUMERIC DEFAULT 1    ]
#x       [-ipv6_routing_res_mode                 CHOICES fixed incr decr list DEFAULT fixed    ]
#x       [-ipv6_routing_res_step                 ANY DEFAULT 1    ]
#x       [-ipv6_routing_res_tracking             CHOICES 0 1  ]
#x       [-ipv6_routing_type                     RANGE 0-255]
#x       [-ipv6_routing_type_count               NUMERIC DEFAULT 1]
#x       [-ipv6_routing_type_mode                CHOICES fixed incr decr list  DEFAULT fixed]
#x       [-ipv6_routing_type_step                RANGE 0-254 DEFAULT 1]
#x       [-ipv6_routing_type_tracking            CHOICES 0 1]
#x       [-ipv6_src_mask                         RANGE 0-128]
#x       [-ipv6_src_tracking                     CHOICES 0 1]
#x       [-ipv6_traffic_class_count              NUMERIC DEFAULT 1]
#x       [-ipv6_traffic_class_mode               CHOICES fixed incr decr list DEFAULT fixed]
#x       [-ipv6_traffic_class_step               RANGE   0-254 DEFAULT 1]
#x       [-ipv6_traffic_class_tracking           CHOICES 0 1]
#x       [-isl                                   CHOICES 0 1 DEFAULT 0]
#x       [-isl_bpdu                              CHOICES 0 1] DEFAULT 0]
#x       [-isl_bpdu_count                        NUMERIC DEFAULT 1]
#x       [-isl_bpdu_mode                         CHOICES fixed incr decr listDEFAULT fixed]
#x       [-isl_bpdu_step                         CHOICES 0 1 DEFAULT 1]
#x       [-isl_bpdu_tracking                     CHOICES 0 1 DEFAULT 0]
#x       [-isl_frame_type                        CHOICES ethernet atm fddi token_ring]
#x       [-isl_frame_type_mode                   CHOICES fixed list DEFAULT fixed]
#x       [-isl_frame_type_tracking               CHOICES 0 1 DEFAULT 0]
#x       [-isl_index                             ]
#x       [-isl_index_count                       NUMERIC DEFAULT 1
#x       [-isl_index_mode                        CHOICES fixed incr decr list DEFAULT fixed
#x       [-isl_index_step                        NUMERIC DEFAULT 1
#x       [-isl_index_tracking                    CHOICES 0 1 DEFAULT 0
#x       [-isl_mac_dst                           ANY
#x       [-isl_mac_dst_count                     NUMERIC DEFAULT 1]
#x       [-isl_mac_dst_mode                      CHOICES fixed incr decr list DEFAULT fixed]
#x       [-isl_mac_dst_step                      ANY DEFAULT 0000.0000.0001]
#x       [-isl_mac_dst_tracking                  CHOICES 0 1 DEFAULT 0]
#x       [-isl_mac_src_high                      HEX
#x       [-isl_mac_src_high_count                NUMERIC DEFAULT 1]
#x       [-isl_mac_src_high_mode                 CHOICES fixed incr decr list DEFAULT fixed]
#x       [-isl_mac_src_high_step                 HEX  DEFAULT 0x01]
#x       [-isl_mac_src_high_tracking             CHOICES 0 1 DEFAULT 0]
#x       [-isl_mac_src_low                       HEX
#x       [-isl_mac_src_low_count                 NUMERIC DEFAULT 1]
#x       [-isl_mac_src_low_mode                  CHOICES fixed incr decr list DEFAULT fixed]
#x       [-isl_mac_src_low_step                  HEX  DEFAULT 0x01]
#x       [-isl_mac_src_low_tracking              CHOICES 0 1  DEFAULT 0]
#x       [-isl_user_priority                     RANGE 0-7]
#x       [-isl_user_priority_count               NUMERIC DEFAULT 1
#x       [-isl_user_priority_mode                CHOICES fixed incr decr list DEFAULT fixed
#x       [-isl_user_priority_step                RANGE 0-6 DEFAULT 1
#x       [-isl_user_priority_tracking            CHOICES 0 1 DEFAULT 0
#x       [-isl_vlan_id                           RANGE 1-4096]
#x       [-isl_vlan_id_count                     NUMERIC DEFAULT 1]
#x       [-isl_vlan_id_mode                      CHOICES fixed incr decr list DEFAULT fixed]
#x       [-isl_vlan_id_step                      NUMERIC DEFAULT 1]
#x       [-isl_vlan_id_tracking                  CHOICES 0 1 DEFAULT 0]
#x       [-l3_length_step                        RANGE 1-64000]
#x       [-lan_range_count                       ]
#x       [-latency_bins_enable                   CHOICES 0 1 DEFAULT 0]
#x       [-latency_bins                          RANGE   2-16]
#x       [-latency_values                        DECIMAL]
#x       [-loop_count                            ]
#x       [-mac_dst_count_step                    ]
#x       [-mac_dst_tracking                      CHOICES 0 1 DEFAULT 0]
#x       [-mac_src_tracking                      CHOICES 0 1 DEFAULT 0]
#x       [-merge_destinations                    CHOICES 0 1]
#x       [-min_gap_bytes                         RANGE 1-2147483647]
#x       [-mpls   CHOICES enable disable]
#x       [-mpls_bottom_stack_bit                 CHOICES 0 1]
#x       [-mpls_bottom_stack_bit_mode            CHOICES fixed incr decr list DEFAULT fixed]
#x       [-mpls_bottom_stack_bit_step            NUMERIC]
#x       [-mpls_bottom_stack_bit_count           NUMERIC]
#x       [-mpls_bottom_stack_bit_tracking        CHOICES 0 1 DEFAULT 0]
#x       [-mpls_exp_bit                          REGEXP  (([0-7]\,)*[0-7]) DEFAULT 0]
#x       [-mpls_exp_bit_count                    RANGE   1-8 DEFAULT 1]
#x       [-mpls_exp_bit_mode                     CHOICES fixed incr decr list DEFAULT fixed]
#x       [-mpls_exp_bit_step                     RANGE   1-6 DEFAULT 1]
#x       [-mpls_exp_bit_tracking                 CHOICES 0 1 DEFAULT 0]
#x       [-mpls_labels_count                     NUMERIC DEFAULT 1]
#x       [-mpls_labels_mode                      CHOICES fixed incr decr DEFAULT fixed]
#x       [-mpls_labels_step                      NUMERIC DEFAULT 1]
#x       [-mpls_labels_tracking                  CHOICES 0 1 DEFAULT 0]
#x       [-mpls_ttl                              ]
#x       [-mpls_ttl_count                        RANGE   1-256 DEFAULT 1]
#x       [-mpls_ttl_mode                         CHOICES fixed incr decr DEFAULT fixed]
#x       [-mpls_ttl_step                         RANGE   0-254 DEFAULT 1]
#x       [-mpls_ttl_tracking                     CHOICES 0 1 DEFAULT 0]
#x       [-mpls_type                             CHOICES unicast multicast]
#x       [-multiple_queues                       FLAG]
#x       [-name   ]
#x       [-tag_filter                            ANY]
#x       [-no_write                              ]
#x       [-num_dst_ports                         NUMERIC]
#x       [-number_of_packets_per_stream          ]
#x       [-number_of_packets_tx                  ]
#x       [-override_value_list                   ]
#x       [-pause_control_time                    RANGE 0-65535]
#x       [-pending_operations_timeout            NUMERIC]
#x       [-pgid_offset                           RANGE 4-32677]
#x       [-pgid_value                            REGEXP ^([0-9a-fA-F]{2}[.: ]{0,1}){0,3}[0-9a-fA-F]{2}$ NUMERIC]
#x       [-preamble_size_mode                    CHOICES auto custom]
#x       [-preamble_custom_size                  INTEGER]
#x       [-pt_handle                             ]
#x       [-public_port_ip                        IP]
#x       [-pvc_count                             ]
#x       [-pvc_count_step                        ]
#x       [-qos_byte                              RANGE 0-127]
#x       [-qos_byte_count                        NUMERIC DEFAULT 1]
#x       [-qos_byte_mode                         CHOICES fixed incr decr list DEFAULT fixed]
#x       [-qos_byte_step                         RANGE   0-126 DEFAULT 1]
#x       [-qos_byte_tracking                     CHOICES 0 1]
#x       [-qos_ipv6_flow_label                   RANGE 0-1048575]
#x       [-qos_ipv6_traffic_class                RANGE 0-255]
#x       [-qos_type_ixn                          CHOICES custom dscp tos ipv6]
#x       [-qos_value_ixn                         ]
#x       [-qos_value_ixn_count                   NUMERIC DEFAULT 1]
#x       [-qos_value_ixn_mode                    CHOICES fixed incr decr list DEFAULT fixed]
#x       [-qos_value_ixn_step                    NUMERIC DEFAULT 1]
#x       [-qos_value_ixn_tracking                CHOICES 0 1]
#x       [-queue_id                              NUMERIC]
#x       [-ramp_up_percentage                    NUMERIC]
#x       [-range_per_spoke                       ]
#x       [-rate_kbps                             ]
#x       [-rate_mbps                             ]
#x       [-rate_byteps                           ]
#x       [-rate_kbyteps                          ]
#x       [-rate_mbyteps                          ]
#x       [-rate_mode                             CHOICES first_option_provided percent pps bps kbps mbps byteps kbyteps mbyteps DEFAULT first_option_provided]
#x       [-return_to_id                          ]
#x       [-rip_command                           CHOICES request response trace_on trace_off reserved]
#x       [-rip_command_mode                      CHOICES fixed list]
#x       [-rip_command_tracking                  CHOICES 0 1]
#x       [-rip_rte_addr_family_id                REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-rip_rte_addr_family_id_count          NUMERIC]
#x       [-rip_rte_addr_family_id_mode           CHOICES fixed incr decr list]
#x       [-rip_rte_addr_family_id_step           REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-rip_rte_addr_family_id_tracking       CHOICES 0 1]
#x       [-rip_rte_ipv4_addr                     IP]
#x       [-rip_rte_ipv4_addr_count               NUMERIC]
#x       [-rip_rte_ipv4_addr_mode                CHOICES fixed incr decr]
#x       [-rip_rte_ipv4_addr_step                IP]
#x       [-rip_rte_ipv4_addr_tracking            CHOICES 0 1]
#x       [-rip_rte_metric                        RANGE  0-4294967295]
#x       [-rip_rte_metric_count                  NUMERIC]
#x       [-rip_rte_metric_mode                   CHOICES fixed incr decr]
#x       [-rip_rte_metric_step                   RANGE  0-4294967295]
#x       [-rip_rte_metric_tracking               CHOICES 0 1]
#x       [-rip_rte_v1_unused2                    RANGE  0-65535]
#x       [-rip_rte_v1_unused2_count              NUMERIC]
#x       [-rip_rte_v1_unused2_mode               CHOICES fixed incr decr]
#x       [-rip_rte_v1_unused2_step               RANGE  0-65534]
#x       [-rip_rte_v1_unused2_tracking           CHOICES 0 1]
#x       [-rip_rte_v1_unused3                    RANGE  0-4294967295]
#x       [-rip_rte_v1_unused3_count              NUMERIC]
#x       [-rip_rte_v1_unused3_mode               CHOICES fixed incr decr]
#x       [-rip_rte_v1_unused3_step               RANGE  0-4294967294]
#x       [-rip_rte_v1_unused3_tracking           CHOICES 0 1]
#x       [-rip_rte_v1_unused4                    RANGE  0-4294967295]
#x       [-rip_rte_v1_unused4_count              NUMERIC]
#x       [-rip_rte_v1_unused4_mode               CHOICES fixed incr decr]
#x       [-rip_rte_v1_unused4_step               RANGE  0-4294967294]
#x       [-rip_rte_v1_unused4_tracking           CHOICES 0 1]
#x       [-rip_rte_v2_next_hop                   IP]
#x       [-rip_rte_v2_next_hop_count             NUMERIC]
#x       [-rip_rte_v2_next_hop_mode              CHOICES fixed incr decr]
#x       [-rip_rte_v2_next_hop_step              IP]
#x       [-rip_rte_v2_next_hop_tracking          CHOICES 0 1]
#x       [-rip_rte_v2_route_tag                  RANGE  0-65535]
#x       [-rip_rte_v2_route_tag_count            NUMERIC]
#x       [-rip_rte_v2_route_tag_mode             CHOICES fixed incr decr]
#x       [-rip_rte_v2_route_tag_step             RANGE  0-65534]
#x       [-rip_rte_v2_route_tag_tracking         CHOICES 0 1]
#x       [-rip_rte_v2_subnet_mask                IP]
#x       [-rip_rte_v2_subnet_mask_count          NUMERIC]
#x       [-rip_rte_v2_subnet_mask_mode           CHOICES fixed incr decr]
#x       [-rip_rte_v2_subnet_mask_step           IP]
#x       [-rip_rte_v2_subnet_mask_tracking       CHOICES 0 1]
#x       [-rip_unused                            RANGE  0-65535]
#x       [-rip_unused_count                      NUMERIC]
#x       [-rip_unused_mode                       CHOICES fixed incr decr list]
#x       [-rip_unused_step                       RANGE  0-65534]
#x       [-rip_unused_tracking                   CHOICES 0 1]
#x       [-rip_version                           CHOICES 1 2]
#x       [-route_mesh                            CHOICES fully one_to_one DEFAULT fully]
#x       [-session_aware_traffic                 CHOICES ppp dhcp4 dhcp6]
#x       [-signature                             REGEXP ^([0-9a-fA-F]{2}[.: ]{0,1}){0,11}[0-9a-fA-F]{2}$]
#x       [-signature_offset                      ]
#x       [-site_id                               ]
#x       [-site_id_enable                        ]
#x       [-site_id_step                          ]
#x       [-skip_frame_size_validation            FLAG]
#x       [-source_filter                         CHOICES all ethernet atm framerelay hdlc ppp none l2vpn l3vpn mpls 6pe 6vpe bgpvpls mac_in_mac data_center_bridging]
#x       [-src_dest_mesh                         CHOICES fully many_to_many one_to_one DEFAULT fully]
#x       [-stream_packing                        CHOICES merge_destination_ranges one_stream_per_endpoint_pair optimal_packing DEFAULT optimal_packing]
#x       [-table_udf_column_name                 ]
#x       [-table_udf_column_offset               ]
#x       [-table_udf_column_size                 ]
#x       [-table_udf_column_type                 CHOICES hex ascii binary decimal mac ipv4 ipv6 REGEXP ^([0-9]+[a|b|d|x],) *[0-9]+[a|b|d|x]$]
#x       [-table_udf_rows                        ]
#x       [-tcp_ack_flag_mode                     CHOICES fixed list]
#x       [-tcp_ack_flag_tracking                 CHOICES 0 1]
#x       [-tcp_ack_num_count                     NUMERIC]
#x       [-tcp_ack_num_mode                      CHOICES fixed incr decr list]
#x       [-tcp_ack_num_step                      RANGE   0-4294967294]
#x       [-tcp_ack_num_tracking                  CHOICES 0 1]
#x       [-tcp_checksum                          REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-tcp_checksum_count                    NUMERIC]
#x       [-tcp_checksum_mode                     CHOICES fixed incr decr list]
#x       [-tcp_checksum_step                     REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})]
#x       [-tcp_checksum_tracking                 CHOICES 0 1]
#x       [-tcp_cwr_flag                          CHOICES 0 1]
#x       [-tcp_cwr_flag_mode                     CHOICES fixed list]
#x       [-tcp_cwr_flag_tracking                 CHOICES 0 1]
#x       [-tcp_data_offset                       RANGE   0-15]
#x       [-tcp_data_offset_count                 NUMERIC]
#x       [-tcp_data_offset_mode                  CHOICES fixed incr decr list]
#x       [-tcp_data_offset_step                  RANGE   0-15]
#x       [-tcp_data_offset_tracking              CHOICES 0 1]
#x       [-tcp_dst_port_count                    NUMERIC]
#x       [-tcp_dst_port_mode                     CHOICES fixed incr decr list]
#x       [-tcp_dst_port_step                     RANGE   0-65534]
#x       [-tcp_dst_port_tracking                 CHOICES 0 1]
#x       [-tcp_ecn_echo_flag                     CHOICES 0 1]
#x       [-tcp_ecn_echo_flag_mode                CHOICES fixed list]
#x       [-tcp_ecn_echo_flag_tracking            CHOICES 0 1]
#x       [-tcp_fin_flag_mode                     CHOICES fixed list]
#x       [-tcp_fin_flag_tracking                 CHOICES 0 1]
#x       [-tcp_ns_flag                           CHOICES 0 1]
#x       [-tcp_ns_flag_mode                      CHOICES fixed list]
#x       [-tcp_ns_flag_tracking                  CHOICES 0 1]
#x       [-tcp_psh_flag_mode                     CHOICES fixed list]
#x       [-tcp_psh_flag_tracking                 CHOICES 0 1]
#x       [-tcp_reserved_count                    NUMERIC]
#x       [-tcp_reserved_mode                     CHOICES fixed incr decr list]
#x       [-tcp_reserved_step                     RANGE   0-6]
#x       [-tcp_reserved_tracking                 CHOICES 0 1]
#x       [-tcp_rst_flag_mode                     CHOICES fixed list]
#x       [-tcp_rst_flag_tracking                 CHOICES 0 1]
#x       [-tcp_seq_num_count                     NUMERIC]
#x       [-tcp_seq_num_mode                      CHOICES fixed incr decr list]
#x       [-tcp_seq_num_step                      RANGE   0-65534]
#x       [-tcp_seq_num_tracking                  CHOICES 0 1]
#x       [-tcp_src_port_count                    NUMERIC]
#x       [-tcp_src_port_mode                     CHOICES fixed incr decr list]
#x       [-tcp_src_port_step                     RANGE   0-65534]
#x       [-tcp_src_port_tracking                 CHOICES 0 1]
#x       [-tcp_syn_flag_mode                     CHOICES fixed list]
#x       [-tcp_syn_flag_tracking                 CHOICES 0 1]
#x       [-tcp_urg_flag_mode                     CHOICES fixed list]
#x       [-tcp_urg_flag_tracking                 CHOICES 0 1]
#x       [-tcp_urgent_ptr_count                  NUMERIC]
#x       [-tcp_urgent_ptr_mode                   CHOICES fixed incr decr list]
#x       [-tcp_urgent_ptr_step                   RANGE   0-65534]
#x       [-tcp_urgent_ptr_tracking               CHOICES 0 1]
#x       [-tcp_window_count                      NUMERIC]
#x       [-tcp_window_mode                       CHOICES fixed incr decr list]
#x       [-tcp_window_step                       RANGE   0-65534]
#x       [-tcp_window_tracking                   CHOICES 0 1]
#x       [-test_objective_value                  NUMERIC]
#x       [-track_by                              CHOICES assured_forwarding_phb class_selector_phb default_phb expedited_forwarding_phb tos raw_priority endpoint_pair dest_ip source_ip ipv6_flow_label ipv6_dest_ip ipv6_source_ip ipv6_trafficclass mpls_label mpls_mpls_exp mpls_flow_descriptor dlci src_mac dest_mac inner_vlan custom_8bit custom_16bit custom_24bit custom_32bit b_src_mac b_dest_mac b_vlan i_tag_isid c_src_mac c_dest_mac s_vlan c_vlan none DEFAULT none]. For valid choices that apply only to IxNetwork 5.40, see detail.
#x       [-traffic_generate                      CHOICES 0 1 DEFAULT 1]
#x       [-traffic_generator                     CHOICES ixos ixnetwork ixnetwork_540]
#x       [-transmit_distribution                 CHOICES none assured_forwarding_phb b_dest_mac b_src_mac b_vlan c_dest_mac c_src_mac c_vlan class_selector_phb default_phb dest_ip dest_mac ethernet_ii_ether_type ethernet_ii_pfc_queue expedited_forwarding_phb fcoe_cs_ctl fcoe_dest_id fcoe_ox_id fcoe_src_id fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_did fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_ox_id fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_sid fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_did fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_ox_id fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_sid fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_cs_ctl_priority fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_did fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_ox_id fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_sid fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_did fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_ox_id fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_sid frame_size i_tag_isid inner_vlan ipv4_dest_ip ipv4_precedence ipv4_source_ip ipv6_dest_ip ipv6_flow_label ipv6_flowlabel ipv6_source_ip ipv6_trafficclass l2tpv2_data_message_tunnel_id mac_in_mac_priority mac_in_mac_v42_bdest_address mac_in_mac_v42_bsrc_address mac_in_mac_v42_btag_pcp mac_in_mac_v42_cdest_address mac_in_mac_v42_csrc_address mac_in_mac_v42_isid mac_in_mac_v42_priority mac_in_mac_v42_stag_pcp mac_in_mac_v42_stag_vlan_id mac_in_mac_v42_vlan_id mac_in_mac_vlan_user_priority mpls_label mpls_mpls_exp mpls_flow_descriptor pppoe_session_sessionid raw_priority rx_port s_vlan source_ip endpoint_pair src_mac tcp_tcp_dst_prt tcp_tcp_src_prt tos udp_udp_dst_prt udp_udp_src_prt vlan_vlan_user_priority DEFAULT endpoint_pair]
#x       [-tx_delay                              NUMERIC]
#x       [-tx_delay_unit                         CHOICES bytes ns]
#x       [-tx_mode                               CHOICES advanced stream]
#x       [-udf1_cascade_type                     ]
#x       [-udf1_chain_from                       CHOICES udfNone udf1 udf2 udf3 udf4 udf5]
#x       [-udf1_counter_init_value               ]
#x       [-udf1_counter_mode                     ]
#x       [-udf1_counter_repeat_count             ]
#x       [-udf1_counter_step                     ]
#x       [-udf1_counter_type                     ]
#x       [-udf1_counter_up_down                  ]
#x       [-udf1_enable_cascade                   ]
#x       [-udf1_inner_repeat_count               ]
#x       [-udf1_inner_repeat_value               ]
#x       [-udf1_inner_step                       ]
#x       [-udf1_mask_select                      ]
#x       [-udf1_mask_val                         ]
#x       [-udf1_mode                             ]
#x       [-udf1_offset                           ]
#x       [-udf1_skip_mask_bits                   ]
#x       [-udf1_skip_zeros_and_ones              ]
#x       [-udf1_value_list                       ]
#x       [-udf2_cascade_type                     ]
#x       [-udf2_chain_from                       CHOICES udfNone udf1 udf2 udf3 udf4 udf5]
#x       [-udf2_counter_init_value               ]
#x       [-udf2_counter_mode                     ]
#x       [-udf2_counter_repeat_count             ]
#x       [-udf2_counter_step                     ]
#x       [-udf2_counter_type                     ]
#x       [-udf2_counter_up_down                  ]
#x       [-udf2_enable_cascade                   ]
#x       [-udf2_inner_repeat_count               ]
#x       [-udf2_inner_repeat_value               ]
#x       [-udf2_inner_step                       ]
#x       [-udf2_mask_select                      ]
#x       [-udf2_mask_val                         ]
#x       [-udf2_mode                             ]
#x       [-udf2_offset                           ]
#x       [-udf2_skip_mask_bits                   ]
#x       [-udf2_skip_zeros_and_ones              ]
#x       [-udf2_value_list                       ]
#x       [-udf3_cascade_type                     ]
#x       [-udf3_chain_from                       CHOICES udfNone udf1 udf2 udf3 udf4 udf5]
#x       [-udf3_counter_init_value               ]
#x       [-udf3_counter_mode                     ]
#x       [-udf3_counter_repeat_count             ]
#x       [-udf3_counter_step                     ]
#x       [-udf3_counter_type                     ]
#x       [-udf3_counter_up_down                  ]
#x       [-udf3_enable_cascade                   ]
#x       [-udf3_inner_repeat_count               ]
#x       [-udf3_inner_repeat_value               ]
#x       [-udf3_inner_step                       ]
#x       [-udf3_mask_select                      ]
#x       [-udf3_mask_val                         ]
#x       [-udf3_mode                             ]
#x       [-udf3_offset                           ]
#x       [-udf3_skip_mask_bits                   ]
#x       [-udf3_skip_zeros_and_ones              ]
#x       [-udf3_value_list                       ]
#x       [-udf4_cascade_type                     ]
#x       [-udf4_chain_from                       CHOICES udfNone udf1 udf2 udf3 udf4 udf5]
#x       [-udf4_counter_init_value               ]
#x       [-udf4_counter_mode                     ]
#x       [-udf4_counter_repeat_count             ]
#x       [-udf4_counter_step                     ]
#x       [-udf4_counter_type                     ]
#x       [-udf4_counter_up_down                  ]
#x       [-udf4_enable_cascade                   ]
#x       [-udf4_inner_repeat_count               ]
#x       [-udf4_inner_repeat_value               ]
#x       [-udf4_inner_step                       ]
#x       [-udf4_mask_select                      ]
#x       [-udf4_mask_val                         ]
#x       [-udf4_mode                             ]
#x       [-udf4_offset                           ]
#x       [-udf4_skip_mask_bits                   ]
#x       [-udf4_skip_zeros_and_ones              ]
#x       [-udf4_value_list                       ]
#x       [-udf5_cascade_type                     ]
#x       [-udf5_chain_from                       CHOICES udfNone udf1 udf2 udf3 udf4 udf5]
#x       [-udf5_counter_init_value               ]
#x       [-udf5_counter_mode                     ]
#x       [-udf5_counter_repeat_count             ]
#x       [-udf5_counter_step                     ]
#x       [-udf5_counter_type                     ]
#x       [-udf5_counter_up_down                  ]
#x       [-udf5_enable_cascade                   ]
#x       [-udf5_inner_repeat_count               ]
#x       [-udf5_inner_repeat_value               ]
#x       [-udf5_inner_step                       ]
#x       [-udf5_mask_select                      ]
#x       [-udf5_mask_val                         ]
#x       [-udf5_mode                             ]
#x       [-udf5_offset                           ]
#x       [-udf5_skip_mask_bits                   ]
#x       [-udf5_skip_zeros_and_ones              ]
#x       [-udf5_value_list                       ]
#x       [-udp_checksum_value                    HEX]
#x       [-udp_checksum_value_tracking           CHOICES 0 1]
#x       [-udp_dst_port_count                    NUMERIC]
#x       [-udp_dst_port_mode                     CHOICES fixed incr decr list]
#x       [-udp_dst_port_step                     RANGE   0-65534]
#x       [-udp_dst_port_tracking                 CHOICES 0 1]
#x       [-udp_length                            RANGE   0-65535]
#x       [-udp_length_count                      NUMERIC]
#x       [-udp_length_mode                       CHOICES fixed incr decr list]
#x       [-udp_length_step                       RANGE   0-65534]
#x       [-udp_length_tracking                   CHOICES 0 1]
#x       [-udp_src_port_count                    NUMERIC]
#x       [-udp_src_port_mode                     CHOICES fixed incr decr list]
#x       [-udp_src_port_step                     RANGE   0-65534]
#x       [-udp_src_port_tracking                 CHOICES 0 1]
#x       [-use_all_ip_subnets                    CHOICES 0 1 DEFAULT 0]
#x       [-vci_increment                         ]
#x       [-vci_increment_step                    ]
#x       [-vlan   CHOICES enable disable]
#x       [-vlan_cfi_count                        NUMERIC DEFAULT 1]
#x       [-vlan_cfi_mode                         CHOICES fixed incr decr DEFAULT fixed]
#x       [-vlan_cfi_step                         CHOICES 0 1 DEFAULT 1]
#x       [-vlan_cfi_tracking                     CHOICES 0 1 DEFAULT 0]
#x       [-vlan_enable                           ]
#x       [-vlan_id_tracking                      CHOICES 0 1 DEFAULT 0]
#x       [-vlan_protocol_tag_id                  REGEXP ^[0-9a-fA-F]{4}$]
#x       [-vlan_protocol_tag_id_count            NUMERIC DEFAULT 1
#x       [-vlan_protocol_tag_id_mode             CHOICES fixed incr decr list DEFAULT fixed
#x       [-vlan_protocol_tag_id_step             HEX DEFAULT 0x01
#x       [-vlan_protocol_tag_id_tracking         CHOICES 0 1 DEFAULT 0
#x       [-vlan_user_priority_count              NUMERIC DEFAULT 1]
#x       [-vlan_user_priority_mode               CHOICES fixed incr decr list DEFAULT fixed]
#x       [-vlan_user_priority_step               RANGE   0-6 DEFAULT 1]
#x       [-vlan_user_priority_tracking           CHOICES 0 1 DEFAULT 0]
#x       [-vpi_increment                         ]
#x       [-vpi_increment_step                    ]
#n       [-csrc_list                             ]
#n       [-dlci_repeat_count_step                NUMERIC]
#n       [-dlci_value_step                       NUMERIC]
#n       [-fr_range_count                        ]
#n       [-intf_handle                           ]
#n       [-ip_bit_flags                          ]
#n       [-ip_dst_count_step                     ]
#n       [-ip_dst_increment                      ]
#n       [-ip_dst_increment_step                 ]
#n       [-ip_dst_prefix_len                     ]
#n       [-ip_dst_prefix_len_step                ]
#n       [-ip_dst_range_step                     ]
#n       [-ip_dst_skip_broadcast                 ]
#n       [-ip_dst_skip_multicast                 ]
#n       [-ip_mbz                                ]
#n       [-ip_range_count                        ]
#n       [-ip_src_skip_broadcast                 ]
#n       [-ip_src_skip_multicast                 ]
#n       [-ip_tos_count                          ]
#n       [-ip_tos_field                          ]
#n       [-ip_tos_step                           ]
#n       [-ipv6_checksum                         ]
#n       [-ipv6_frag_next_header                 ]
#n       [-ipv6_length                           ]
#n       [-mac_discovery_gw                      ]
#n       [-mac_dst2_count                        ]
#n       [-mac_dst2_mode                         ]
#n       [-mac_dst2_step                         ]
#n       [-mac_src2_count                        ]
#n       [-mac_src2_mode                         ]
#n       [-mac_src2_step                         ]
#n       [-ppp_session_id                        ]
#n       [-rtp_csrc_count                        ]
#n       [-rtp_payload_type                      ]
#n       [-ssrc   ]
#n       [-timestamp_initial_value               ]
#
#
# Arguments:
#    -arp_dst_hw_addr
#        Value of the destination MAC address for arp packets from a particular 
#        stream. Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.ARP
#    -arp_dst_hw_count
#        Number of destination MAC addresses used in ARP packets in a 
#        particular stream. Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.ARP
#    -arp_dst_hw_mode
#        Valid only for traffic_generator ixos/ixnetwork_540. This parameter configures 
#        the behavior for arp_dst_hw_addr. (DEFAULT = fixed) Valid choices are: 
#           fixed - the value is left unchanged for all packets.
#           increment - the value is incremented as specified with arp_dst_hw_step and arp_dst_hw_count.
#           decrement - the value is decremented as specified with arp_dst_hw_step and arp_dst_hw_count.
#           list - Parameter -arp_dst_hw contains a list of values. Each packet 
#               will use one of the values from the list.
#        Category: Layer4-7.ARP
#    -arp_operation
#        Type of ARP operation given to a particular ARP packet from a 
#        particular stream. Valid only for traffic_generator ixos/ixnetwork_540. Valid options are:
#        arpRequest - DEFAULT
#        arpReply
#        rarpRequest
#        rarpReply
#        unknown - Valid only for traffic_generator ixnetwork_540
#        Category: Layer4-7.ARP
#    -arp_src_hw_addr
#        Value of the source MAC address for arp packets from a particular 
#        stream. Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.ARP
#    -arp_src_hw_count
#        Number of source MAC addresses used in ARP packets in a particular 
#        stream. Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.ARP
#    -arp_src_hw_mode
#        Behavior of the source MAC address for ARP packets from a particular 
#        stream. Valid only for traffic_generator ixos. Valid choices are:
#        fixed - DEFAULT
#        increment - the value is incremented as specified with arp_src_hw_step and arp_src_hw_count.
#        decrement - the value is decremented as specified with arp_src_hw_step and arp_src_hw_count.
#        list - Parameter -arp_src_hw contains a list of values. Each packet 
#              will use one of the values from the list.
#        Category: Layer4-7.ARP
#    -bidirectional
#        Whether traffic is setup to transmit in both directions. 
#        When -traffic_generator is set to ixos:
#        The two ports receiving and transmitting are specified by options 
#        port_handle and port_handle2.
#        Option "l3_protocol" source and destination 
#        addresses are swapped to get the traffic flowing in both directions.
#        The parameters are based on the port associated with port_handle and 
#        are swapped for the port associated with port_handle2.
#        MAC addresses can be handled in two ways. 
#        First, if the MAC destination addresses are not provided, ARP is used 
#        to get the next hop MAC address based on the gateway IP address set in 
#        the command interface_config.
#        Second, use option "mac_dst" and "mac_dst2" addresses provided by this 
#        command. Option "mac_dst2" applies to the port associated with option 
#        "port_handle2". Option "stream_id" is the same for both directions. 
#        As for the source MAC, you can use option "mac_src2" to configure the 
#        MAC on the second port, and option "mac_dst2" to configure the 
#        destination MAC on the second port if you are not using L2 next hop.
#        When using subports (this is valid only for PPP/L2TP emulations), 
#        the traffic flow direction (upstream or downstream) is set per port, 
#        not per subport. 
#        All  the subports created must have the traffic flow set in the same 
#        direction (upstream or downstream). If subports have different traffic 
#        flow direction, the traffic will be bidirectional.
#        When -traffic_generator is set to ixnetwork: 
#        Two traffic items will be configured. 
#        The first traffic item will have:
#        source - the emulation specified by emulation_src_handle
#        destination - the destination specified by emulation_dst_handle
#        The second traffic item will have:
#        source - the emulation specified by emulation_dst_handle
#        destination - the destination specified by emulation_src_handle
#        The rest of the specified options will be set on both traffic items.
#        Valid choices are:
#        0 - Disabled.
#        1 - Enabled.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: General.Common
#    -burst_loop_count
#        Number of times to transmit a burst. 
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Stream Control and Data.Rate Control
#    -command_response
#        Set Command Response bit.
#        Valid only for traffic_generator ixos.
#        Category: General.Common
#    -emulation_dst_handle
#        The handle used to retrieve information for L2 or L3 dst addresses and use 
#        them to configure the destinations for traffic.
#        This should be the emulation handle that was obtained after 
#        configuring PPP/L2TP protocols with IxTclAccess or routing protocols 
#        with IxTclNetwork (BGP, OSPF, ISIS, LDP, RSVP, etc). 
#        This parameter can be provided with a list or with a list of lists elements. 
#        The following list will create one endpointset with n elements: 
#        {<endpoint_1> <endpoint_2> ... <endpoint_n>}
#        The following list of lists will create multiple endpointsets with m,n,...,p elements: 
#        { 
#            {endpointset <endpoint_1.1> <endpoint_1.2> ... <endpoint_1.m>} 
#            {endpointset <endpoint_2.1> <endpoint_2.2> ... <endpoint_1.n>} 
#            ...
#            {endpointset <endpoint_2.1> <endpoint_2.2> ... <endpoint_1.p>} 
#        }
#        Note that in this combination the first item in the list is endpointset. 
#        This string is optional. 
#        The parameter -endpointset_count should be equal to the number of list 
#        elements provided to -emulation_src_handle and -emulation_dst_handle. 
#        Example 1: 
#        endpointset_count       1 
#        emulation_src_handle    {<endpoint_1.1> <endpoint_1.2> <endpoint_1.3>} 
#        emulation_dst_handle    {<endpoint_2.1> <endpoint_2.2> <endpoint_2.3>} 
#        Example 2: 
#        endpointset_count       1 
#        emulation_src_handle    {{endpointset <endpoint_1.1> <endpoint_1.2> <endpoint_1.3>}} 
#        emulation_dst_handle    {{endpointset <endpoint_2.1> <endpoint_2.2> <endpoint_2.3>}} 
#        Example 3: 
#        endpointset_count       3 
#        emulation_src_handle    { 
#           {endpointset <endpoint_src_1.1> <endpoint_src_1.2> <endpoint_src_1.3> <endpoint_src_1.4>} 
#           {endpointset <endpoint_src_2.1> <endpoint_src_2.2> <endpoint_src_2.3>} 
#           {endpointset <endpoint_src_3.1> <endpoint_src_3.2> <endpoint_src_3.3> <endpoint_src_3.4> <endpoint_src_3.5>} 
#        } 
#        emulation_src_handle    { 
#           {endpointset <endpoint_dst_1.1> <endpoint_dst_1.2> <endpoint_dst_1.3> <endpoint_dst_1.4>} 
#           {endpointset <endpoint_dst_2.1> <endpoint_dst_2.2> <endpoint_dst_2.3>} 
#           {endpointset <endpoint_dst_3.1> <endpoint_dst_3.2> <endpoint_dst_3.3> <endpoint_dst_3.4> <endpoint_dst_3.5>} 
#        }
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: General.Endpoint Data
#    -emulation_src_handle
#        The handle used to retrieve information for L2 or L3 src addresses and use 
#        them to configure the sources for traffic.
#        This should be the emulation handle that was obtained after 
#        configuring PPP/L2TP protocols with IxTclAccess or routing protocols 
#        with IxTclNetwork (BGP, OSPF, ISIS, LDP, RSVP, etc). 
#        This parameter can be provided with a list or with a list of lists elements. 
#        The following list will create one endpointset with n elements: 
#        {<endpoint_1> <endpoint_2> ... <endpoint_n>}
#        The following list of lists will create multiple endpointsets with m,n,...,p elements: 
#        { 
#            {endpointset <endpoint_1.1> <endpoint_1.2> ... <endpoint_1.m>} 
#            {endpointset <endpoint_2.1> <endpoint_2.2> ... <endpoint_1.n>} 
#            ...
#            {endpointset <endpoint_q.1> <endpoint_q.2> ... <endpoint_q.p>} 
#        }
#        Note that in this combination the first item in the list is endpointset. 
#        This string is optional. 
#        The parameter -endpointset_count should be equal to the number of list 
#        elements provided to -emulation_src_handle and -emulation_dst_handle. 
#        Example 1: 
#        endpointset_count       1 
#        emulation_src_handle    {<endpoint_1.1> <endpoint_1.2> <endpoint_1.3>} 
#        emulation_dst_handle    {<endpoint_2.1> <endpoint_2.2> <endpoint_2.3>} 
#        Example 2: 
#        endpointset_count       1 
#        emulation_src_handle    {{endpointset <endpoint_1.1> <endpoint_1.2> <endpoint_1.3>}} 
#        emulation_dst_handle    {{endpointset <endpoint_2.1> <endpoint_2.2> <endpoint_2.3>}} 
#        Example 3: 
#        endpointset_count       3 
#        emulation_src_handle    { 
#           {endpointset <endpoint_src_1.1> <endpoint_src_1.2> <endpoint_src_1.3> <endpoint_src_1.4>} 
#           {endpointset <endpoint_src_2.1> <endpoint_src_2.2> <endpoint_src_2.3>} 
#           {endpointset <endpoint_src_3.1> <endpoint_src_3.2> <endpoint_src_3.3> <endpoint_src_3.4> <endpoint_src_3.5>} 
#        } 
#        emulation_src_handle    { 
#           {endpointset <endpoint_dst_1.1> <endpoint_dst_1.2> <endpoint_dst_1.3> <endpoint_dst_1.4>} 
#           {endpointset <endpoint_dst_2.1> <endpoint_dst_2.2> <endpoint_dst_2.3>} 
#           {endpointset <endpoint_dst_3.1> <endpoint_dst_3.2> <endpoint_dst_3.3> <endpoint_dst_3.4> <endpoint_dst_3.5>} 
#        }
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: General.Endpoint Data
#    -fcs
#        Whether to insert an fcs error in the frame. Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540. Valid choices are:
#        0 - Disabled.
#        1 - Enable. The fcs error type can be specified with -fcs_type option.
#        Category: General.Instrumentation/Flow Group
#    -icmp_checksum
#        Valid only for traffic_generator ixnetwork_540 and ICMPv4. 
#        Configure 2 byte HEX "Checksum" field.
#        Category: Layer4-7.ICMP
#    -icmp_code
#        Code for each ICMP message type. Valid choices are between 0 and 255, 
#        inclusive. Valid only for ICMPv4 with traffic_generator is ixos.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 0)
#        Category: Layer4-7.ICMP
#    -icmp_id
#        ID for each ping command, i.e. echoRequest. Valid choices are between 
#        0 and 65535, inclusive. Valid only for ICMPv4. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 0)
#        Category: Layer4-7.ICMP
#    -icmp_seq
#        Sequence number for each ping command, i.e. EchoRequest. Valid 
#        choices are between 0 and 65535, inclusive.  Valid only for ICMPv4 when traffic_generator is 'ixos'. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 0)
#        Category: Layer4-7.ICMP
#    -icmp_type
#        ICMP message type. Valid choices are between 0 and 255, inclusive. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 0)
#        Category: Layer4-7.ICMP
#    -igmp_group_addr
#        IP Multicast group address of the group being joined or left. Use a list of 
#        values when configuring multiple Group Records on IGMPv3 Messages. In case of 
#        IGMPv3 Memebership Report messages, the number of addresses from the igmp_group_addr 
#        field must match the number of lists of addresses from igmp_multicast_src parameter.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.IGMP
#    -igmp_group_count
#        Number of IGMP message to be sent. For option "igmp_group_mode" set to 
#        increment or decrement, this is the address range of the IGMP message. 
#        Valid choices are between 0 and 65535, inclusive. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 1)
#        Category: Layer4-7.IGMP
#    -igmp_group_mode
#        How the Group Address varies when the repeat count is greater than 1. 
#         Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#        fixed     - Group IP address is the same for all packets.
#        increment - Group IP address increments.
#        decrement - Group IP address decrements.
#        list - Parameter -igmp_group_addr contains a list of values. Each packet 
#              will use one of the values from the list.
#        Category: Layer4-7.IGMP
#    -igmp_group_step
#        Valid only for traffic_generator ixnetwork_540. 
#        Step value used to modify igmp_group_addr when igmp_group_mode is incr 
#        or decr.
#        Category: Layer4-7.IGMP
#    -igmp_max_response_time
#        Maximum allowed time before sending a responding report in units of 
#        1/10 second. Valid choices are between 0 and 65535, inclusive. 
#        Valid only for traffic_generator ixos/ixnetwork_540 with IGMPv2 and IGMPv3 
#        Membership Query messages.
#        (DEFAULT = 100)
#        Category: Layer4-7.IGMP
#    -igmp_msg_type
#        Valid only for traffic_generator ixnetwork_540. This parameter takes priority over 
#        igmp_type parameter when igmp_version is 3.
#        Select IGMPv3 message type to generate. Valid choices are:
#           query - Membership Query
#           report - Membership Report
#        Category: Layer4-7.IGMP
#    -igmp_multicast_src
#        (Only for IGMPv3 messages) A list of IPv4 source addresses for the 
#        group in the case of Membership Queries and a list of lists of IPv4 
#        source addresses in the case of Membership Reports. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.IGMP
#    -igmp_qqic
#        This option is only used for an IGMP v.3 group membership query. The 
#        querier’s query interval code, expressed in second. Values from 0 to 
#        127 are represented exactly, values from 128 to 255 are encoded into a 
#        floating point number with three bits of exponent and 4 bits of 
#        mantissa. A value higher than 255 will be silently forced to 255. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.IGMP
#    -igmp_qrv
#        This option is only used for an IGMP v.3 group membership queries. 
#        The querier’s robustness value, as a value from 0 to 7. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.IGMP
#    -igmp_record_type
#        The type of IGMP message to be sent. Valid only for traffic_generator ixos/ixnetwork_540. 
#        Specify this parameter as a list of values when configuring multiple Group Records. Valid choices are:
#        mode_is_include - A current-state-record which indicates that 
#                                 the interface has a filter mode of INCLUDE 
#                                 for the specified multicast address. The 
#                                 Source Address fields in this Group Record 
#                                 contain the interface’s source list for the 
#                                 multicast address.
#        mode_is_exclude - As in mode_is_include, except that the filter 
#                                 mode is EXCLUDE.
#        change_to_include_mode - A filter-mode-change record that indicates 
#                                 that the interface has changed to INCLUDE 
#                                 filter mode for the specified multicast 
#                                 address. The Source Address fields in this 
#                                 Group Record contain the interface’s new 
#                                 source list for the multicast address.
#        change_to_exclude_mode - As in change_to_include_mode, except that 
#                                 the filter mode is EXCLUDE.
#        allow_new_sources - A source-list-change that indicates that the 
#                                 Source Address fields in this Group Record 
#                                 contain a list of the additional sources that 
#                                 the system wishes to hear from, for packets 
#                                 sent to the multicast address. If the change 
#                                 was to an INCLUDE source list, these are the 
#                                 addresses that were added to the list; 
#                                 otherwise these are the addresses that were 
#                                 deleted from the list.
#        block_old_sources - A source-list-change that indicates that the 
#                                 Source Address fields in this Group Record 
#                                 contain a list of the sources that the system 
#                                 no longer wishes to hear from, for packets 
#                                 sent to the multicast address. If the change 
#                                 was to an INCLUDE source list, these are the 
#                                 addresses that were deleted from the list; 
#                                 otherwise these are the addresses that were 
#                                 added to the list.
#        Category: Layer4-7.IGMP
#    -igmp_s_flag
#        This option is only used for an IGMP v.3 group membership query. It 
#        is the suppress router-side processing flag. If set, receiving 
#        multicast routers will not send timer updates in the normal manner 
#        when a query is received. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.IGMP
#    -igmp_type
#        The type of IGMP message to be sent. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        With traffic_generator ixnetwork_540 a numeric value can also be configured for the igmp_type field. Valid choices are:
#        dvmrp - Distance-Vector Multicast Routing Protocol message. Not supported with traffic_generator ixnetwork_540 and will be silently set to membership_query.
#        leave_group - An IGMPv2 message sent by client to inform the DUT 
#                            of its interest to leave a group. Not supported with traffic_generator ixnetwork_540 for IGMPv1 and will be silently set to membership_query.
#        membership_query - General or group specific query messages sent by 
#                            the DUT.
#        membership_report - Message sent by client to inform the DUT of its 
#                            interest to join a group.
#        Category: Layer4-7.IGMP
#    -igmp_valid_checksum
#        If set, this causes a valid header checksum to be generated. If unchecked, 
#        then the one's complement of the correct checksum is generated. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 1)
#        Category: Layer4-7.IGMP
#    -igmp_version
#        IGMP version number. (DEFAULT = 2)
#        Valid only for traffic_generator ixos/ixnetwork_540. 
#        Valid choices are:
#           1 - IGMPv1
#           2 - IGMPv2
#           3 - IGMPv3
#        Category: Layer4-7.IGMP
#    -inter_burst_gap
#        Number of milliseconds between each burst in the loop count. 
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Stream Control and Data.Rate Control
#    -inter_stream_gap
#        Number milliseconds between each stream configured. 
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Stream Control and Data.Rate Control
#    -ip_checksum
#        Checksum for IPv4 packet. Valid only for traffic_generator ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_cu 
#        Valid only for traffic_generator ixnetwork_540.  
#        Configures 2-bit Diff-serv currently unused field in IP header.
#        Category: Layer3.IPv4
#    -ip_dscp
#        DSCP prcedence for a particular stream. Valid choices are between 0 
#        and 63, inclusive. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 0)
#        Category: Layer3.IPv4
#    -ip_dscp_count
#        Valid only for traffic_generator ixnetwork_540. 
#        Numeric value which configures the number of times the ip_dscp 
#        is incremeneted or decremented when ip_dscp_mode is incr or decr.
#        (DEFAULT = 1)
#        Category: Layer3.IPv4
#    -ip_dscp_step
#        Valid only for traffic_generator ixnetwork_540. 
#        Step value used to modify ip_dscp when ip_dscp_mode is incr 
#        or decr.
#        (DEFAULT = 1)
#        Category: Layer3.IPv4
#   -ip_dst_addr
#        Depending on the traffic_generator value, this option has different 
#        meanings:
#        ixos/ixnetwork_540: Destination IP address of the packet.
#        ixnetwork: This option is used to specify the value of the first IP 
#            of the first IP static endpoint range for L2VPN traffic. 
#            (Not supported in this release.)
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_dst_count
#        Depending on the traffic_generator value, this option has different 
#        meanings:
#        ixos/ixnetwork_540: Number of destination IP addresses when option 
#            "ip_dst_mode" is set to increment or decrement.
#        ixnetwork: This option is used to specify the value of the IP count 
#            of the first IP static endpoint range for L2VPN traffic.
#            (Not supported in this release.)
#        When traffic_generator is ixos the maximum value 
#        is 4294967295. When traffic_generator is ixnetwork_540 the maximum value 
#        is 2147483647.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_dst_mode
#        Destination IP address mode. Valid choices are:
#        fixed - The destination IP address is the same for all 
#                            packets.
#        increment - The destination IP address increments. 
#                            Valid only for traffic_generator ixos/ixnetwork_540.
#        decrement - The destination IP address decrements. 
#                            Valid only for traffic_generator ixos/ixnetwork_540.
#        random - The destination IP address is random. 
#                            Valid only for traffic_generator ixos. 
#                            With traffic_generator ixnetwork_540 this will be silently ignored and configured to 'fixed'.
#        emulation - Destination IP derived from the emulation handle. 
#                            Valid only for traffic_generator ixos/ixnetwork_540.
#        list - Parameter -ip_dst_addr contains a list of values. Each packet 
#                will use one of the values from the list. Valid only for traffic_generator ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_dst_step
#        The modifier for the increment and decrement choices of 
#        "-ip_dst_mode" which requires that only one field contain a non-zero 
#        value.  When ip_dst_mode is random, this acts as a mask if traffic_generator is ixos. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_fragment
#        Whether this is a fragmented datagram. This option is used in 
#        conjuction with option "ip_id" and "ip_fragment_last". Valid only for traffic_generator ixos/ixnetwork_540. 
#        Valid choices 
#        are:
#        0 - This is not a fragmented datagram.
#        1 - This is a fragmented datagram.
#        Category: Layer3.IPv4
#    -ip_fragment_last
#        Controls whether there are additional fragments used to assemble 
#        this datagram. Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#        0 - More fragments to come.
#        1 - (DEFAULT) No more fragments.
#        Category: Layer3.IPv4
#    -ip_fragment_offset
#        Where in the datagram this fragment belongs. The offset is measured 
#        in units of 8 octets (64 bits). Valid choices are between 0 and 8191, 
#        inclusive. Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv4
#   -ip_hdr_length
#       Configure header length field in IP header.
#       Valid only for traffic_generator ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_id
#        Identifying value assigned by the sender to aid in assembling the 
#        fragments of a datagram. Valid choices are between 0 and 65535. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 0)
#        Category: Layer3.IPv4
#    -ip_precedence
#        Part of the Type of Service byte of the IP header datagram that 
#        establishes precedence of delivery. Valid choices are between 0 and 
#        7, inclusive. With traffic_generator ixnetwork_540 this parameter configures QOS for IPv6 traffic only for 
#        ixaccess backwards compatibility mode (details in description for traffic_generator 
#        ixnetwork_540) and if qos_ipv6_traffic_class and ipv6_traffic_class parameters are 
#        missing. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_protocol
#        L4 protocol in the IP header. Valid choices are between 
#        0 and 255. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 255)
#        Category: Layer3.IPv4
#    -ip_src_addr
#        Source IP address of the packet. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_src_count
#        Number of source IP addresses when option "ip_src_mode" is set to 
#        increment or decrement. When traffic_generator is ixos the maximum value 
#        is 4294967295. When traffic_generator is ixnetwork_540 the maximum value 
#        is 2147483647. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_src_mode
#        Source IP address mode. Valid choices are:
#        fixed             - The source IP address is the same for all packets. 
#                            Valid only for traffic_generator ixos/ixnetwork_540.
#        increment         - The source IP address increments. 
#                            Valid only for traffic_generator ixos/ixnetwork_540.
#        decrement         - The source IP address decrements. 
#                            Valid only for traffic_generator ixos/ixnetwork_540.
#        random            - The source IP address is random. 
#                            Valid only for traffic_generator ixos. 
#                            With traffic_generator ixnetwork_540 this will be silently ignored and configured to 'fixed'.
#        emulation         - Source IP derived from the emulation handle. 
#                            Valid only for traffic_generator ixos/ixnetwork_540.
#        list - Parameter -ip_src_addr contains a list of values. Each packet 
#                will use one of the values from the list. Valid only for traffic_generator ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_src_step
#        The modifier for the increment and decrement choices of -ip_src_mode 
#        which requires that only one field contain a non-zero value.  When 
#        the ip_src_mode is random, then this acts as a mask if traffic_generator is ixos. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv4
#    -ip_ttl
#        Time-to-Live, measured in units of seconds. Valid choices are between 
#        0 and 255. 
#        Valid only for traffic_generator ixos.
#        (DEFAULT = 64)
#        Category: Layer3.IPv4
#    -ipv6_dst_addr
#        Destination IPv6 address of the packet. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv6
#    -ipv6_dst_count
#        Number of destination IPv6 addresses when option "ipv6_dst_mode" is 
#        set to increment or decrement. When traffic_generator is ixos the maximum value 
#        is 4294967295. When traffic_generator is ixnetwork_540 the maximum value 
#        is 2147483647. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv6
#    -ipv6_dst_mode
#        ipv6_dst_mode specifies how and if the ipv6_dst_addr is incremented.
#        The following is valid only for traffic_generator ixnetwork_540:
#        Valid options are:
#           increment
#           decrement
#           fixed
#           list
#        For backwards compatibility all modes starting with 'incr' will be configured 
#        as increment and all modes starting with 'decr' will be configured as decrement. 
#        Incrementing and decrementing depends only on ipv6_dst_step and ipv6_dst_count.
#        The following is valid only for traffic_generator ixos:
#        The ipv6_dst_mode depends on the IPv6 address type specified with ipv6_dst_addr parameter when traffic_generator is ixos.
#        Each ipv6_dst_mode allows a mask from a Mask range to be configured. 
#        The mask is configured using the ipv6_dst_mask attribute
#        The step used for incrementing or decrementing is configued using the 
#        ipv6_dst_step attribute which has the form of an IPv6 address.
#        The ipv6_dst_mask attribute specifies which part of the ipv6_dst_step 
#        address is used for incrementing as follows:
#             Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#             Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#             Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#             Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#             Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#             Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#             Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#             Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#        HEX values marked with 'x' in the format above are the ipv6_dst_step HEX 
#        values that are used for increment or decrement; HEX values marked with 
#        '0' are ignored.
#        The step is limited to a 32 bit counter. Example:
#           ipv6_dst_mode incr_network
#           ipv6_dst_mask 64
#        inner_ipv6_dst_step address portion that is used for incrementing will be:
#               0000:0000:xxxx:xxxx:0000:0000:00000:0000
#               32bit limit       Network Mask 64
#               0000:0000:xxxx:xxxx is the mask.
#               0000:0000 is the 32 bits that will NOT be incremented because of the limitation.
#               xxxx:xxxx is what gets incremented.
#        Destination IPv6 address mode. Valid only for traffic_generator ixos. The table below is sectioned by IPv6 address type. Then IPv6 increment mode and parameter description is listed in the left column (Value) and mask range in the right column (Usage). Valid choices are:
#             IPv6 address type - User Defined
#             fixed: IPv6 fixed address - Mask range 0-128
#             increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#             decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#             incr_host: Increment IPv6 host address - Mask range 96-128
#             decr_host: Decrement IPv6 host address - Mask range 96-128
#             incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#             IPv6 address type - Reserved
#             fixed: IPv6 fixed address - Mask range 0-128
#             increment: Increment IPv6 network prefix based on mask value  - Mask range 0-128
#             decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#             incr_host: Increment IPv6 host address - Mask range 96-128
#             decr_host: Decrement IPv6 host address - Mask range 96-128
#             incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#             Reserved for NSAP Allocation - .
#             fixed: IPv6 fixed address - Mask range 0-128
#             increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#             decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#             incr_host: Increment IPv6 host address - Mask range 96-128
#             decr_host: Decrement IPv6 host address  - Mask range 96-128
#             incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#             decr_network: Decrement IPv6 network prefix based on mask value  - Mask range 0-128
#             Reserved for IPX Allocation - .
#             fixed: IPv6 fixed address - Mask range 0-128
#             increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#             decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#             incr_host: Increment IPv6 host address - Mask range 96-128
#             decr_host: Decrement IPv6 host address - Mask range 96-128
#             incr_network: Increment IPv6 network prefix based on mask value  - Mask range 0-128
#             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#             Aggregatable Global Unicast Addresses - .
#             fixed: IPv6 fixed address - Mask range 0-128
#             increment: Increment interface ID - Mask range 96-128
#             decrement: Decrement interface ID - Mask range 96-128
#             incr_intf_id: Increment interface ID - Mask range 96-128
#             decr_intf_id: Decrement interface ID - Mask range 96-128
#             incr_global_top_level: Increment global unicast top level ID - Mask range 4-4
#             decr_global_top_level: Decrement global unicast top level ID - Mask range 4-4
#             incr_global_next_level: Increment global unicast next level ID  - Mask range 24-24
#             decr_global_next_level: Decrement global unicast next level ID - Mask range 24-24
#             incr_global_site_level: Increment global unicast site level ID - Mask range 48-48
#             decr_global_site_level: Decrement global unicast site level ID  - Mask range 48-48
#             Link-Local Unicast Addresses - .
#             fixed: IPv6 fixed address - Mask range 0-128
#             increment: Increment interface ID - Mask range 96-128
#             decrement: Decrement interface ID - Mask range 96-128
#             incr_intf_id: Increment interface ID  - Mask range 96-128
#             decr_intf_id: Decrement interface ID - Mask range 96-128
#             Site-Local Unicast Addresses - .
#             fixed: IPv6 fixed address - Mask range 0-128
#             increment: Increment site local unicast subnet ID - Mask range 48-48
#             decrement: Decrement site local unicast subnet ID - Mask range 48-48
#             incr_intf_id: Increment interface ID - Mask range 96-128
#             decr_intf_id: Decrement interface ID - Mask range 96-128
#             incr_local_site_subnet: Increment site local unicast subnet ID - Mask range 48-48
#             decr_local_site_subnet: Decrement site local unicast subnet ID - Mask range 48-48
#            Multicast Addresses - .
#             fixed: IPv6 fixed address - Mask range 0-128
#             increment: Increment multicast group ID - Mask range 96-96
#             decrement: Decrement multicast group ID - Mask range 96-96
#             incr_mcast_group: Increment multicast group ID - Mask range 96-96
#             decr_mcast_group: Decrement multicast group ID - Mask range96-96
#        Category: Layer3.IPv6
#    -ipv6_dst_step
#        Step size of the IPv6 addresses. 
#        ipv6_dst_mode specifies how and if the ipv6_dst_addr is incremented.
#        The following is valid only for traffic_generator ixnetwork_540:
#        Any IPv6 step is accepted. Incrementing and decrementing depends only on ipv6_dst_step and ipv6_dst_count.
#        The following is valid only for traffic_generator ixos:
#        The ipv6_dst_mode depends on the IPv6 address type specified with ipv6_dst_addr parameter.
#        Each ipv6_dst_mode allows a mask from a Mask range to be configured.
#        The mask is configured using the ipv6_dst_mask attribute
#        The step used for incrementing or decrementing is configued using the 
#        ipv6_dst_step attribute which has the form of an IPv6 address.
#        The ipv6_dst_mask attribute specifies which part of the ipv6_dst_step 
#        address is used for incrementing as follows:
#             Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#             Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#             Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#             Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#             Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#             Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#             Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#             Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#        HEX values marked with 'x' in the format above are the ipv6_dst_step HEX 
#        values that are used for increment or decrement; HEX values marked with 
#        '0' are ignored.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv6
#    -ipv6_flow_label
#        Flow label value of the IPv6 stream. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv6
#    -ipv6_frag_id
#        This can be used in two ways. 
#        If "-ipv6_extension_header fragment" is present then an IPv6 extension 
#        frament is added along with other IPv6 extension headers mentioned in 
#        ipv6_extension_header list. Also these option can be a list. 
#        If -ipv6_extension_header is not present then only one IPv6 fragment 
#        can be added and these option can only have one element. 
#        Identification field in the fragment extension header of an IPv6 
#        stream. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 286335522)
#        Category: Layer3.IPv6
#    -ipv6_frag_more_flag
#        This can be used in two ways. 
#        If "-ipv6_extension_header fragment" is present then an IPv6 extension 
#        frament is added along with other IPv6 extension headers mentioned 
#        in -ipv6_extension_header list. Also these option can be a list. 
#        If -ipv6_extension_header is not present then only one IPv6 fragment 
#        can be added and these option can only have one element. 
#        Whether the M Flag in the fragment extension header of an IPv6 stream 
#        is set. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 0)
#        Category: Layer3.IPv6
#    -ipv6_frag_offset
#        This can be used in two ways. 
#        If "-ipv6_extension_header fragment" is present then an IPv6 extension 
#        frament is added along with other IPv6 extension headers mentioned 
#        in -ipv6_extension_header list. Also these option can be a list. 
#        If -ipv6_extension_header is not present then only one IPv6 fragment 
#        can be added and these option can only have one element. 
#        Fragment offset in the fragment extension header of an IPv6 stream. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        (DEFAULT = 100)
#        Category: Layer3.IPv6
#    -ipv6_hop_limit
#        Hop limit value of the IPv6 stream. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv6
#    -ipv6_next_header
#        Valid only for traffic_generator ixnetwork_540. 
#        Configures the 1-byte next header field in the IPv6 header.
#        Category: Layer3.IPv6
#    -ipv6_src_addr
#        Source IPv6 address of the packet. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv6
#    -ipv6_src_count
#        Number of source IP address when option "ipv6_src_mode" is set to 
#        increment or decrement. When traffic_generator is ixos the maximum value 
#        is 4294967295. When traffic_generator is ixnetwork_540 the maximum value 
#        is 2147483647.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv6
#    -ipv6_src_mode
#        The following is valid only for traffic_generator ixnetwork_540:
#        Valid options are:
#           increment
#           decrement
#           fixed
#           list
#        For backwards compatibility all modes starting with 'incr' will be configured 
#        as increment and all modes starting with 'decr' will be configured as decrement. 
#        Incrementing and decrementing depends only on ipv6_src_step and ipv6_src_count.
#        The following is valid only for traffic_generator ixos:
#        Source IP address mode. Valid only for traffic_generator ixos.
#        ipv6_src_mode specifies how and if the ipv6_src_addr is incremented.
#        The ipv6_src_mode depends on the IPv6 address type specified with ipv6_src_addr parameter.
#        Each ipv6_src_mode allows a mask from a Mask range to be configured.
#        The mask is configured using the ipv6_src_mask attribute
#        The step used for incrementing or decrementing is configued using the 
#        ipv6_src_step attribute which has the form of an IPv6 address.
#        The ipv6_src_mask attribute specifies which part of the ipv6_src_step 
#        address is used for incrementing as follows:
#             Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#             Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#             Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#             Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#             Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#             Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#             Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#             Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#        HEX values marked with 'x' in the format above are the ipv6_src_step HEX 
#        values that are used for increment or decrement; HEX values marked with 
#        '0' are ignored.
#        The table below is sectioned by IPv6 address type. Then IPv6 increment mode and parameter description is listed in the left column (Value) and mask range in the right column (Usage). Valid choices are:
#             IPv6 address type - User Defined
#              fixed: IPv6 fixed address - Mask range 0-128
#              increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#              decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#              incr_host: Increment IPv6 host address - Mask range 96-128
#              decr_host: Decrement IPv6 host address - Mask range 96-128
#              incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#              decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#              Reserved - .
#              fixed: IPv6 fixed address - Mask range 0-128
#              increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#              decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#              incr_host: Increment IPv6 host address - Mask range 96-128
#              decr_host: Decrement IPv6 host address - Mask range 96-128
#              incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#              decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#              Reserved for NSAP Allocation - .
#              fixed: IPv6 fixed address - Mask range 0-128
#              increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#              decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#              incr_host: Increment IPv6 host address - Mask range 96-128
#              decr_host: Decrement IPv6 host address - Mask range 96-128
#              incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#              decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#              Reserved for IPX Allocation - .
#              fixed: IPv6 fixed address - Mask range 0-128
#              increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#              decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#              incr_host: Increment IPv6 host address - Mask range 96-128
#              decr_host: Decrement IPv6 host address - Mask range 96-128
#              incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#              decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#              Aggregatable Global Unicast Addresses - .
#              fixed: IPv6 fixed address - Mask range 0-128
#              increment: Increment interface ID - Mask range 96-128
#              decrement: Decrement interface ID - Mask range 96-128
#              incr_intf_id: Increment interface ID - Mask range 96-128
#              decr_intf_id: Decrement interface ID - Mask range 96-128
#              incr_global_top_level: Increment global unicast top level ID - Mask range 4-4
#              decr_global_top_level: Decrement global unicast top level ID - Mask range 4-4
#              incr_global_next_level: Increment global unicast next level ID - Mask range 24-24
#              decr_global_next_level: Decrement global unicast next level ID - Mask range 24-24
#              incr_global_site_level: Increment global unicast site level ID - Mask range 48-48
#              decr_global_site_level: Decrement global unicast site level ID - Mask range 48-48
#              Link-Local Unicast Addresses - .
#              fixed: IPv6 fixed address - Mask range 0-128
#              increment: Increment interface ID - Mask range 96-128
#              decrement: Decrement interface ID - Mask range 96-128
#              incr_intf_id: Increment interface ID - Mask range 96-128
#              decr_intf_id: Decrement interface ID - Mask range 96-128
#              Site-Local Unicast Addresses - .
#              fixed: IPv6 fixed address - Mask range 0-128
#              increment: Increment site local unicast subnet ID - Mask range 48-48
#              decrement: Decrement site local unicast subnet ID - Mask range 48-48
#              incr_intf_id: Increment interface ID - Mask range 96-128
#              decr_intf_id: Decrement interface ID - Mask range 96-128
#              incr_local_site_subnet: Increment site local unicast subnet ID - Mask range 48-48
#              decr_local_site_subnet: Decrement site local unicast subnet ID  - Mask range 48-48
#              Multicast Addresses  - .
#              fixed: IPv6 fixed address - Mask range 0-128
#              increment: Increment multicast group ID - Mask range 96-96
#              decrement: Decrement multicast group ID - Mask range 96-96
#              incr_mcast_group: Increment multicast group ID - Mask range 96-96
#              decr_mcast_group: Decrement multicast group ID - Mask range 96-96-128
#        Category: Layer3.IPv6
#    -ipv6_src_step
#        Step size of the source IP address. 
#        ipv6_src_mode specifies how and if the ipv6_src_addr is incremented.
#        The following is valid only for traffic_generator ixnetwork_540:
#        Any IPv6 step is accepted. Incrementing and decrementing depends only on ipv6_src_step and ipv6_src_count.
#        The following is valid only for traffic_generator ixos:
#        The ipv6_src_mode depends on the IPv6 address type specified with ipv6_src_addr parameter.
#        Each ipv6_src_mode allows a mask from a Mask range to be configured. 
#        The mask is configured using the ipv6_src_mask attribute.
#        The step used for incrementing or decrementing is configued using the 
#        ipv6_src_step attribute which has the form of an IPv6 address.
#        The ipv6_src_mask attribute specifies which part of the ipv6_src_step 
#        address is used for incrementing as follows:
#             Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#             Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#             Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#             Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#             Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#             Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#             Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#             Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#        HEX values marked with 'x' in the format above are the ipv6_src_step HEX 
#        values that are used for increment or decrement; HEX values marked with 
#        '0' are ignored.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv6
#    -ipv6_traffic_class
#        Traffic class value of the IPv6 stream. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer3.IPv6
#    -l2_encap
#        Set level 2 encapsulation. Valid only for traffic_generator ixos and ixnetwork_540. 
#        Valid options with traffic_generator ixos are:
#            atm_vc_mux
#            atm_vc_mux_ethernet_ii
#            atm_vc_mux_802.3snap
#            atm_vc_mux_802.3snap_nofcs
#            atm_vc_mux_ppp
#            atm_vc_mux_pppoe
#            atm_snap
#            atm_snap_ethernet_ii
#            atm_snap_802.3snap
#            atm_snap_802.3snap_nofcs
#            atm_snap_ppp
#            atm_snap_pppoe
#            hdlc_unicast
#            hdlc_broadcast
#            hdlc_unicast_mpls
#            hdlc_multicast_mpls
#            ethernet_ii
#            ethernet_ii_unicast_mpls
#            ethernet_ii_multicast_mpls
#            ethernet_ii_vlan
#            ethernet_ii_vlan_unicast_mpls
#            ethernet_ii_vlan_multicast_mpls
#            ethernet_ii_pppoe
#            ethernet_ii_vlan_pppoe
#            ppp_link
#            ietf_framerelay
#            cisco_framerelay
#         Valid options with traffic_generator ixnetwork_540 are:
#            ethernet_ii
#            ethernet_ii_unicast_mpls
#            ethernet_ii_vlan
#            ethernet_ii_vlan_unicast_mpls
#        Category: General.Common
#    -l3_gaus1_avg
#        The center of the first curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus1_halfbw
#        The width at half of the first curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus1_weight
#        The weigth of the first curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus2_avg
#        The center of the second curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus2_halfbw
#        The width at half of the second curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus2_weight
#        The weigth of the second curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus3_avg
#        The center of the third curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus3_halfbw
#        The width at half of the third curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus3_weight
#        The weigth of the third curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus4_avg
#        The center of the fourth curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus4_halfbw
#        The width at half of the fourth curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_gaus4_weight
#        The weigth of the fourth curve. Used if length_mode is set to 
#        gaussian or quad.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_imix1_ratio
#        Ratio of first packet size. Used if length_mode set to imix.
#        The sum of all ratio (l3_imix1_ratio, l3_imix2_ratio, l3_imix3_ratio, 
#        l3_imix4_ratio) must be between 0 and 262,144.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_imix1_size
#        First Packet size in bytes. Used if length_mode set to imix.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_imix2_ratio
#        Ratio of second packet size. Used if length_mode set to imix.
#        The sum of all ratio (l3_imix1_ratio, l3_imix2_ratio, l3_imix3_ratio, 
#        l3_imix4_ratio) must be between 0 and 262,144.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_imix2_size
#        Second Packet size in bytes. Used if length_mode set to imix.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_imix3_ratio
#        Ratio of third packet size. Used if length_mode set to imix.
#        The sum of all ratio (l3_imix1_ratio, l3_imix2_ratio, l3_imix3_ratio, 
#        l3_imix4_ratio) must be between 0 and 262,144.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_imix3_size
#        Third Packet size in bytes. Used if length_mode set to imix.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_imix4_ratio
#        Ratio of fourth packet size. Used if length_mode set to imix.
#        The sum of all ratio (l3_imix1_ratio, l3_imix2_ratio, l3_imix3_ratio, 
#        l3_imix4_ratio) must be between 0 and 262,144.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_imix4_size
#        Fourth Packet size in bytes. Used if length_mode set to imix.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_length
#        Packet size in bytes.  Use this option in conjunction with option 
#        "length_mode" set to fixed.  Valid choices are between 1 and 64000, 
#        inclusive. If frame_size parameter is used, this option is ignored.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_length_max
#        Maximum packet size for the specified stream in bytes.  Use this 
#        option in conjunction with option "length_mode" set to increment.
#        If frame_size_max parameter is used, this option is ignored.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_length_min
#        Minimum packet size for the specified stream in bytes.  Use this 
#        option in conjunction with option "length_mode" set to increment.
#        If frame_size_min parameter is used, this option is ignored.
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: General.Frame size
#    -l3_protocol
#        Configures a layer 3 protocol header. Depending on the traffic_generator 
#        value, this option has different choices. Valid choices are:
#        ixos - ipv4, ipv6, arp, pause_control, ipx, none
#        ixnetwork (not supported in this release) - ipv4, ipv6
#        ixnetwork_540 - ipv4, ipv6, arp
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: General.Common
#    -l4_protocol
#        In the Layer4 header in the IP-based packet, the Layer4 protocol. Valid only for traffic_generator ixos and ixnetwork_540. 
#        If -mode is modify and traffic_generator is ixnetwork_540, it is only possible to modify headers that already exist in the packet.
#        To replace the entire l4 header one must use traffic_config -mode replace_header.
#        Valid choices are:
#        gre  - For IPv4 and IPv6.
#        icmp - For IPv4 and IPv6.
#        igmp - For IPv4 only.
#        tcp  - For IPv4 and IPv6.
#        udp  - For IPv4 and IPv6.
#        rip  - For IPv4 only.
#        dhcp - For IPv4 only.
#        ospf - For IPv4 only.
#        ip   - For IPv4 only.
#        Category: General.Common
#    -length_mode
#        This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#        and -stream_id <traffic_item_handle>. The choices that are supported for dynamic_update are 
#        'fixed' and 'random'. 
#        Behavior of the frame/packet size for a particular stream. Parameters 
#        l3_length* are ignored when frame_size* parameters are used.
#        Valid choices are:
#        fixed - The frame/packet size is fixed. 
#           Dependencies: l3_length/frame_size when traffic_generator is set to ixos and ixnetwork_540, and 
#           only through parameter frame_size when traffic_generator is set to 
#           ixnetwork. PPPoX with traffic_generator ixnetwork supports only -length_mode fixed. 
#        increment - The frame/packet size will be incremented using a step from a 
#           minimum size to a maximum size. 
#           Dependencies: 
#           The incrementing step and minimum/maximum framesize/packet size 
#           must be specified using: 
#           l3_length_step/frame_size_step, l3_length_min/frame_size_min, l3_length_max/frame_size_max 
#           when traffic_generator is set to ixos and ixnetwork_540, and only through parameters 
#           frame_size_step, frame_size_min, frame_size_max when 
#           traffic_generator is set to ixnetwork.
#        random - The frame/packet size is random, but limited by a minimum and 
#           maximum value. 
#           Dependencies: The minimum and maximum framesize/packet size 
#           must be specified using: l3_length_min/frame_size_min, l3_length_max/frame_size_max 
#           when traffic_generator is set to ixos and ixnetwork_540, and only through parameters 
#           frame_size_min, frame_size_max when traffic_generator is set to ixnetwork.
#        auto - The frame/packet size is set automatically in order to have a 
#           valid frame, without overlapping headers and fields. 
#           Dependencies: 
#           This choice is valid only when traffic_generator is set to ixos and ixnetwork_540.
#        imix -  Mix of frame/packet sizes are generated during transmission. 
#           Dependencies: 
#           Imix settings must be specified using parameters:
#               traffic_generator ixos - l3_imix<i>_size, l3_imix<i>_ratio(<i> is from 1 to 4).
#               traffic generator is ixnetwork_540 - l3_imix<i>_size, l3_imix<i>_ratio(<i> is from 1 to 4) or 
#                   frame_size_imix. Parameter frame_size_imix has priority over l3_imix* parameters.
#               traffic generator is ixnetwork - Imix settings must be specified using parameter frame_size_imix.
#        gaussian, quad - Frame/packet sizes are specified as gaussian/quad curves. 
#           Dependencies: 
#               traffic_generator ixos -  these curves must be specified 
#                   using options l3_gaus<i>_avg, l3_gaus<i>_halfbw, l3_gaus<i>_weight, 
#                   where <i> is a number from 1 to 4. 
#               traffic_generator ixnetwork - these curves must be specified using option frame_size_gauss.
#               traffic_generator ixnetwork_540 - these curves must be specified 
#                   using options l3_gaus<i>_avg, l3_gaus<i>_halfbw, l3_gaus<i>_weight, 
#                   where <i> is a number from 1 to 4 OR frame_size_gauss. Parameter 
#                   frame_size_gauss has priority over l3_gaus* parameters.
#        distribution - Frame size is specified with a predefined distribution. 
#           Dependencies: For IxTclNetwork, this choice is valid only when traffic_generator is 
#           set to ixnetwork/ixnetwork_540 and the distribution must be set using option 
#           frame_size_distribution.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: General.Frame size
#    -mac_dst
#        Destination MAC address for a particular stream. 
#        For traffic_generator ixnetwork, can only be used for L2VPN traffic, but is not supported in this release. 
#        Valid formats are:
#        11:11:11:11:11:11
#        2222.2222.2222
#        {33 33 33 33 33 33} 
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Layer2.Ethernet
#    -mac_dst2
#        Value of the destination MAC address for port_handle2. This option 
#        applies to bidirectional only.  Valid only for traffic_generator ixos.
#        Valid MAC formats are:
#        11:11:11:11:11:11
#        2222.2222.2222
#        {33 33 33 33 33 33 } 
#        Category: Layer2.Ethernet
#    -mac_dst_count
#        Depending on the traffic_generator value, this option has different 
#        meanings. Valid choices are:
#        ixos - Number of destination MAC addresses used in a particular stream. 
#            Maximum value is 4294967295 (DEFAULT = 1).
#        ixnetwork_540 - Number of destination MAC addresses used in a particular stream. 
#            Maximum value is 2147483647 (DEFAULT = 1).
#        ixnetwork - MAC address count in the first LAN static endpoint range. 
#            It can take decimal values in the 1-4294967295 range. Also, it can 
#            be used just for L2VPN traffic, but is not supported in this release.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Layer2.Ethernet
#    -mac_dst_mask
#        Select this attribute to use random mask bit values. This parameter is 
#        available only when -mac_dst_mode is repeatable_random.
#        (DEFAULT = ff:ff:ff:ff:ff:ff)
#        Valid for traffic_generator ixos/ixnetwork_540.
#        Category: Layer2.Ethernet
#    -mac_dst_mode
#        Behavior of the destination MAC address for a particular stream. 
#        For traffic_generator ixnetwork, this option can only be used for 
#        L2VPN traffic, but is not supported in this release. For traffic_generator ixnetwork_540 will have the same behavior 
#        as for ixos. Valid choices are:
#        fixed     - The destination MAC will be idle (same for all packets). 
#                    Valid only for all values of traffic_generator.
#        increment - The Destination MAC will increment for all packets. 
#                    Valid only for all values of traffic_generator.
#        decrement - The Destination MAC will be decrement for all packets. 
#                    Valid only for traffic_generator ixos and ixnetwork_540.
#        random    - The Destination MAC will be random far all packets. 
#                    Valid only for traffic_generator ixos.
#        discovery - (DEFAULT) The Destination MAC will match the MAC address 
#                    received from the ARP request. 
#                    Valid only for traffic_generator ixos.
#        list      - Parameter -mac_dst contains a list of values. The Destination 
#                    MAC will be selected in order from the list passed with -mac_dst. 
#                    Valid only for traffic_generator ixnetwork_540.
#        repeatable_random - The Source MAC will be random for all packets, 
#                    but you can use mac_dst_mask, mac_dst_seed and mac_dst_count.
#        Category: Layer2.Ethernet
#    -mac_dst_seed
#        Value for setting the seed attribute. This parameter is available only  
#        when -mac_dst_mode is repeatable_random.
#        (DEFAULT = 1)
#        Valid for traffic_generator ixos/ixnetwork_540.
#        Category: Layer2.Ethernet
#    -mac_dst_step
#        Value by which the destination MAC Address is incremented. 
#        Valid only for traffic_generator ixos, ixnetwork_540 and ixnetwork.
#        For traffic_generator ixnetwork, this option is used to specify the 
#        step between the value of the first MAC address of each the LAN static 
#        endpoint range and can only be used for L2VPN traffic, but is not supported in this release.
#        For traffic_generator ixos the value for this parameter can also be given as a
#        positive integer number. For example, the values 1 and 00:00:00:00:00:01 are
#        equivalent.
#        Category: Layer2.Ethernet
#    -mac_src
#        Source MAC address for a particular stream. 
#        Valid only for traffic_generator ixos/ixnetwork_540. Valid formats are:
#        11:11:11:11:11:11
#        2222.2222.2222
#        {33 33 33 33 33 33} 
#        Category: Layer2.Ethernet
#    -mac_src2
#        Value of the source MAC address for port_handle2. This option applies 
#        to bidirectional only. 
#        Valid only for traffic_generator ixos.Valid MAC formats are:
#        11:11:11:11:11:11
#        2222.2222.2222
#        {33 33 33 33 33 33 }
#        Category: Layer2.Ethernet 
#    -mac_src_count
#        Number of source MAC addresses used in a particular stream. 
#        Valid only for traffic_generator ixos and ixnetwork_540.
#        (DEFAULT = 1)
#        Category: Layer2.Ethernet
#    -mac_src_mask
#        Select this attribute to use random mask bit values. This parameter is 
#        available only when -mac_src_mode is repeatable_random.
#        (DEFAULT = ff:ff:ff:ff:ff:ff)
#        Valid for traffic_generator ixos/ixnetwork_540.
#        Category: Layer2.Ethernet
#    -mac_src_mode
#        Behavior of the source MAC address for a particular stream. 
#        Valid only for traffic_generator ixos and ixnetwork_540.
#        Valid choices for traffic_generator ixos are:
#            fixed     - The Source MAC will be idle (same fo all packets).
#            increment - The Source MAC will be incremented for all packets.
#            decrement - The Source MAC will be decremented for all packets.
#            random    - The Source MAC will be random far all packets.
#            emulation - Not implemented.
#        Valid choices for traffic_generator ixnetwork_540 are:
#            fixed     - The Source MAC will be idle (same fo all packets).
#            increment - The Source MAC will be incremented for all packets.
#            decrement - The Source MAC will be decremented for all packets.
#            list      - Parameter -mac_src contains a list of values. The Source 
#                        MAC will be selected in order from the list passed with -mac_src.
#            random    - The Source MAC will be random for all packets.
#            repeatable_random - The Source MAC will be random for all packets, 
#                        but you can use mac_src_mask, mac_src_seed and mac_src_count.
#        Category: Layer2.Ethernet
#    -mac_src_seed
#        Value for setting the seed attribute. This parameter is available only  
#        when -mac_src_mode is repeatable_random.
#        (DEFAULT = 1)
#        Valid for traffic_generator ixos/ixnetwork_540.
#        Category: Layer2.Ethernet
#    -mac_src_step
#        Value by which the Source MAC address is incremented. 
#        Valid only for traffic_generator ixos and ixnetwork_540.
#        For traffic_generator ixos the value for this parameter can also be given as
#        positive integer number. For example, the values 1 and 00:00:00:00:00:01 are
#        equivalent.
#        Category: Layer2.Ethernet
#    -mode
#        What specific action is taken.  Valid choices are:
#        create  - Create only one stream/traffic item. 
#                  Dependencies: When traffic_generator is ixos, 
#                  the port_handle must also be provided when mode is create.
#        modify  - Modify only one existing stream/traffic item. 
#                  Dependencies: traffic_generator must be ixos/ixnetwork/ixnetwork_540 and 
#                  stream_id must be provided. NOTE: modify mode is not supported 
#                  for streams originating in PPPoX endpoints when -traffic_generator is ixos. 
#                  When traffic_generator ixnetwork_540 is used stream_id can also be a 
#                  header handle.
#        remove  - Remove/disable an existing stream/traffic item. 
#                  Dependencies: traffic_generator must be ixos/ixnetwork/ixnetwork_540 and 
#                  stream_id must be provided. 
#                  When traffic_generator is ixos, it disables the stream, when 
#                  traffic_generator is ixnetwork it removes the traffic item. 
#                  When traffic_generator is ixnetwork_540: if stream_id is a traffic_item 
#                  it removes it; if stream_id is a high level stream it suspends it; if 
#                  stream_id is a header handle it removes it.
#        reset   - Remove all existing traffic setups.
#        enable  - Enables an existing stream. 
#                  Dependencies: traffic_generator must be ixos/ixnetwork/ixnetwork_540 and 
#                  stream_id must be provided.
#        disable - Disables an existing stream/traffic item. 
#                  Dependencies: traffic_generator must be ixnetwork/ixnetwork_540 and 
#                  stream_id must be provided.
#        append_header - Append headers. 
#                  Dependencies: traffic_generator must be ixnetwork_540 and 
#                  stream_id must be a header handle.
#        prepend_header - Prepend headers. 
#                  Dependencies: traffic_generator must be ixnetwork_540 and 
#                  stream_id must be a header handle.
#        replace_header - Replace a header. 
#                  Dependencies: traffic_generator must be ixnetwork_540 and 
#                  stream_id must be a header handle.
#        dynamic_update - With traffic_generator 'ixnetwork_540' some rate and framesize parameters can 
#                  be changed while the traffic is running. To do this use -mode 'dynamic_update' and -stream_id 
#                  <traffic_item_handle>. The parameters that will be used for this mode are: frame_size, frame_size_max, 
#                  frame_size_min, length_mode (only fixed or random), rate_bps, rate_kbps, rate_mbps, rate_byteps, rate_kbyteps, rate_mbyteps, 
#                  rate_percent, rate_pps, inter_frame_gap, inter_frame_gap_unit and enforce_min_gap. Any other 
#                  parameters will be silently ignored. 
#                  Dependencies: traffic_generator must be ixnetwork_540 and 
#                  stream_id must be a traffic item handle.
#        get_available_protocol_templates - Returns a list of all available protocol templates in a user-friendly 
#                  format. The elements from the list (or the entire list) can be used as pt_handle object(s). 
#                  Returns key "pt_handle". 
#                  Dependencies: traffic_generator must be ixnetwork_540.
#        get_available_fields - Returns a list of all available fields specific to the provided header handle (in user friendly format). 
#                  The "header_handle" must be a stack object over a high level stream or a config element. 
#                  Returns key "handle". 
#                  Dependencies: traffic_generator must be ixnetwork_540.
#        get_available_dynamic_update_fields - Returns a list of all available 
#                  dynamic update fields for the provided stream_id.
#                  Returns key "available_dynamic_update_fields"
#                  Dependencies: traffic_generator must be ixnetwork_540.
#        get_available_session_aware_traffic - Returns a list of all available
#                  session aware traffic fields for the provided stream_id.
#                  Returns key "available_session_aware_traffic_fields" 
#                  Dependencies: traffic_generator must be ixnetwork_540.
#        get_available_fields_for_link  - Returns a list of all available
#                  valid stack link fields for the provided stream_id.
#                  Returns key "available_fields_for_link". Valid only for IxNetwork greater than 7.0. 
#                  Dependencies: traffic_generator must be ixnetwork_540.
#        get_field_values - Returns the values for the provided field handle. The field handle can be obtained 
#                  using mode "get_available_fields". The header handle must also be provided. 
#                  List of returned keys: 
#                       field_activeFieldChoice 
#                       field_auto 
#                       field_countValue 
#                       field_defaultValue 
#                       field_displayName 
#                       field_enumValues 
#                       field_fieldChoice 
#                       field_fieldValue 
#                       field_fullMesh 
#                       field_id 
#                       field_length 
#                       field_level 
#                       field_name 
#                       field_offset 
#                       field_offsetFromRoot 
#                       field_optional 
#                       field_optionalEnabled 
#                       field_rateVaried 
#                       field_readOnly 
#                       field_requiresUdf 
#                       field_singleValue 
#                       field_startValue 
#                       field_stepValue 
#                       field_trackingEnabled 
#                       field_valueFormat 
#                       field_valueList 
#                       field_valueType 
#                  Dependencies: traffic_generator must be ixnetwork_540.
#        set_field_values - Sets the specified values for the given field handle. Not all values provided 
#                  by "get_field_values" are available for set. Some of them are read-only. Valid fields: 
#                      field_activeFieldChoice 
#                      field_auto 
#                      field_countValue 
#                      field_fieldValue 
#                      field_fullMesh 
#                      field_optionalEnabled 
#                      field_singleValue 
#                      field_startValue 
#                      field_stepValue 
#                      field_trackingEnabled 
#                      field_valueList 
#                      field_valueType 
#                  Dependencies: traffic_generator must be ixnetwork_540.
#        add_field_level - Adds a new field level for the specified header if multiple levels are supported. 
#                  The "header_handle" and the "field_handle" must be provided. 
#                  Returns the new field handlers associated with the new level (key: handle). 
#                  Dependencies: traffic_generator must be ixnetwork_540.
#        remove_field_level - Removed the specified field level on the given header. 
#                  The "header_handle" and the "field_handle" must be provided. 
#                  Dependencies: traffic_generator must be ixnetwork_540.
#        get_available_egress_tracking_field_offset - Returns a list of all available
#                  egress tracking custom field offsets specific for the provided stream_id.
#                  Returns key "available_egress_tracking_field_offset".
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: General.Common
#    -mpls_labels
#        MPLS labels in the packets for each stream. Ixia supports multiple 
#        MPLS labels in a single packet. For example, to stack three labels 
#        in one packet, use -mpls_labels {14 18 78}, where 14, 18 and 78 are 
#        the label IDs in the packet. 
#        Valid only for traffic_generator ixos and ixnetwork_540.
#        Category: Layer2.MPLS
#    -pkts_per_burst
#        Number of packets to include in one burst.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Stream Control and Data.Rate Control
#    -port_handle
#        Depending on the traffic_generator value, this option has different 
#        meanings. If traffic_generator ixnetwork_540 is used this parameter is used 
#        only if emulation_src_handle parameter is missing. Valid choices are:
#        ixos/ixnetwork_540 - The port for which to configure traffic. Mandatory 
#            for -mode create/reset when -traffic_generator is set to 
#            ixos. For traffic_generator ixnetwork_540 this is mandatory on mode 
#            create only if parameter -emulation_src_handle is missing.
#        ixnetwork/ixnetwork_540 - The port_handle parameter is not necessary anymore. 
#            When using IxNetwork, traffic configurations will be done using previously 
#            created handles (IP interfaces, PPP ranges, L2TP ranges, Protocol Route Ranges 
#            etc.) as sources (parameter -emulation_src_handle) and destinations 
#            (-emulation_dst_handle).
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: General.Endpoint Data
#    -port_handle2
#        A second port for which to configure traffic configuration when 
#        option "bidirectional" is enabled. For traffic_generator ixnetwork_540 
#        this parameter is used only if emulation_src_handle and emulation_dst_handle 
#        parameters are missing. For traffic_generator ixnetwork_540 this parameter 
#        can be used as destination port for the unidirectional traffic too.
#        Valid for traffic_generator ixos/ixnetwork_540.
#        Category: General.Endpoint Data
#    -rate_bps
#        This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#        and -stream_id <traffic_item_handle>. 
#        Traffic rate to send in bps. 
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Stream Control and Data.Rate Control
#    -rate_frame_gap
#        Traffic rate in percent for the specified stream using a frame/gap ratio. 
#        Valid choices are between 0 and 100, inclusive. Only integer values are 
#        allowed.
#        The frame/gap percentage is defined as 
#        ( (frame_size + preamble)/(frame_size + preamble + frame_gap) )*100.
#        For ATM and POS ports the preamble will be 0.
#        If the rate cannot be achieved then it will be rounded to the 
#        closest legal value and the user will be informed about the value that 
#        will be used.
#        Limitations:
#        1. rate_frame_gap cannot be used in conjunction with the following 
#        parameters:
#           rate_bps
#           rate_percent
#           rate_pps
#        2. The following parameters can have limited choices:
#           length_mode only fixed
#           traffic_generator only ixos
#        3. Port must be configured with transmit mode packet_streams 
#        (::ixia::interface_config - transmit_mode stream)
#        4. Only supported with ports that implement minimumInterFrameGap and 
#        maximumInterFrameGap features. If the port does not support these 
#        features an error is returned. Refer to IxiaReferenceGuide.pdf for a 
#        list of ports and the supported features.
#        5. Supported only with IxOS version 5.10 or higher.
#        Valid only for traffic_generator ixos.
#        (DEFAULT = 100)
#        Category: Stream Control and Data.Rate Control
#    -rate_percent
#        This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#        and -stream_id <traffic_item_handle>. 
#        Traffic rate in percent of line rate for the specified stream.  Valid 
#        choices are between 0.00 and 100.00, inclusive. 
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        (DEFAULT = 100.00)
#        Category: Stream Control and Data.Rate Control
#    -rate_pps
#        This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#        and -stream_id <traffic_item_handle>. 
#        Traffic rate to send in pps. 
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Stream Control and Data.Rate Control
#    -stream_id
#        Required for -mode modify/remove/enable/disable/append_header/prepend_header/replace_header/dynamic_update calls. 
#        Stream ID is not required for configuring a stream for the first time. 
#        In this case, the stream ID is returned from the call.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: General.Common
#    -tcp_ack_flag
#        Whether the "acknowledge flag" in the TCP header is enabled. Valid only for traffic_generator ixos/ixnetwork_540. Valid 
#        choices are:
#        0 - (DEFAULT) Disabled.
#        1 - Enabled.
#        Category: Layer4-7.TCP
#    -tcp_ack_num
#        TCP tcp_window size field for this particular stream. Valid choices 
#        are between 0 and 65535, inclusive. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.TCP
#    -tcp_dst_port
#        TCP destination port for this particular stream. Valid choices are 
#        between 0 and 65535, inclusive. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.TCP
#    -tcp_fin_flag
#        Whether the "finished flag" in the TCP header is enabled. Valid only for traffic_generator ixos/ixnetwork_540. Valid 
#        choices are:
#        0 - (DEFAULT) Disabled.
#        1 - Enabled.
#        Category: Layer4-7.TCP
#    -tcp_psh_flag
#        Whether the "psh flag" in the TCP header is enabled. Valid only for traffic_generator ixos/ixnetwork_540. Valid choices 
#        are:
#        0 - (DEFAULT) Disabled.
#        1 - Enabled.
#        Category: Layer4-7.TCP
#    -tcp_reserved
#        Valid only for traffic_generator ixnetwork_540. 
#        Configure the TCP reserved field (0-7).
#        Category: Layer4-7.TCP
#    -tcp_rst_flag
#        Whether the "reset flag" in the TCP header is enabled. Valid only for traffic_generator ixos/ixnetwork_540. Valid choices 
#        are:
#        0 - (DEFAULT) Disabled.
#        1 - Enabled.
#        Category: Layer4-7.TCP
#    -tcp_seq_num
#        TCP sequence number for this particular stream. Valid choices are 
#        between 0 and 65535, inclusive. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.TCP
#    -tcp_src_port
#        TCP source port for this particular stream. Valid choices are between 
#        0 and 65535, inclusive. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.TCP
#    -tcp_syn_flag
#        Whether the "synchronize flag" in the TCP header is enabled. 
#        Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#        0 - (DEFAULT) Disabled.
#        1 - Enabled.
#        Category: Layer4-7.TCP
#    -tcp_urg_flag
#        Whether the "urgent flag" in the TCP header is enabled. Valid only for traffic_generator ixos/ixnetwork_540. Valid choices 
#        are:
#        0 - (DEFAULT) Disabled.
#        1 - Enabled.
#        Category: Layer4-7.TCP
#    -tcp_urgent_ptr
#        TCP Urgent Pointer value for this particular stream. Valid choices 
#        are between 0 and 65535, inclusive. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.TCP
#    -tcp_window
#        TCP tcp_window size field for this particular stream. Valid choices 
#        are between 0 and 65535, inclusive. 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer4-7.TCP
#    -transmit_mode
#        Type of transmit mode to use.  Note that all transmit modes need to 
#        have one value set in either rate_pps, rate_bps, or rate_percent. 
#        Also, not all choices may be available for a stream, depending on the 
#        ::ixia::interface_config -transmit_mode argument. 
#        Valid choices are:
#        advance                - after all the frames are sent from the 
#                                 current stream, the frames from the next 
#                                 stream on the port are transmitted. 
#                                 Valid only for traffic_generator ixos/ixnetwork_540.
#        continuous             - continuously transmit the frames on this 
#                                 stream.
#        continuous_burst       - continuously transmit bursts of frames on 
#                                 this stream. 
#                                 Valid only for traffic_generator 
#                                 ixos/ixnetwork_540.
#        multi_burst            - transmit multiple bursts and then stop all 
#                                 transmission from the port where this stream 
#                                 resides regardless of existence of other 
#                                 streams on this port. 
#                                 Valid only for traffic_generator 
#                                 ixos/ixnetwork_540.
#        return_to_id           - the last stream on the port is set to this 
#                                 mode to begin transmission of frames of the 
#                                 first stream in the list. Parameter 
#                                 return_to_id can be used to specify the 
#                                 stream number to begin with. 
#                                 Valid only for traffic_generator ixos/ixnetwork_540.
#        return_to_id_for_count - the last stream on the port is set to this 
#                                 mode to begin transmission of the first 
#                                 stream in the list for -loop_count intervals. 
#                                 Parameter return_to_id can be used to specify 
#                                 the stream number to begin with. 
#                                 Valid only for traffic_generator 
#                                 ixos/ixnetwork/ixnetwork_540.
#        random_spaced          - transmit random spaced frames. 
#                                 Valid only for traffic_generator ixos/ixnetwork_540.
#        single_burst           - transmit one burst and then stop all 
#                                 transmission from the port where this stream 
#                                 resides regardless of existence of other 
#                                 streams on this port. 
#                                 Valid only for traffic_generator 
#                                 ixos/ixnetwork_540.
#        single_pkt             - transmit one packet and then stop all 
#                                 transmission from the port where this stream 
#                                 resides regardless of existence of other 
#                                 streams on this port. 
#                                 Valid only for traffic_generator 
#                                 ixos/ixnetwork_540.
#        Category: Stream Control and Data.Rate Control
#    -udp_checksum
#        This parameter enables/disables UDP checksum. Valid choices are: 
#        1 - the UDP checksum is set as current checksum for UDP data
#        0 - If parameter udp_checksum_value is specified, the UDP checksum 
#            will be overriten by the value supplied through udp_checksum_value. 
#            If udp_checksum_value is not present, an invalid checksum will be 
#            set as the UDP checksum.
#        Valid only for traffic_generator ixos/ixnetwork_540 and when -l4_protocol is udp.
#        Category: Layer4-7.UDP
#    -udp_dst_port
#        UDP destination port for this particular stream. Valid choices are 
#        between 0 and 65535, inclusive. The port number needs to be different 
#        than the port number used for RIP and DHCP. 
#        Valid only for traffic_generator ixos/ixnetwork_540 and when -l4_protocol is udp.
#        Category: Layer4-7.UDP
#    -udp_src_port
#        UDP source port for this particular stream. Valid choices are between 
#        0 and 65535, inclusive. The port number needs to be different than the 
#        port number used for RIP and DHCP. 
#        Valid only for traffic_generator ixos/ixnetwork_540 and when -l4_protocol is udp.
#        Category: Layer4-7.UDP
#    -vci
#        The virtual circuit identifier. 
#        Depending on the traffic_generator value, this option has different 
#        meanings. Valid choices are:
#        ixos/ixnetwork_540 - The virtual circuit identifier (DEFAULT = 32).
#        ixnetwork - This option is used to specify the value of the first VCI 
#            of the first ATM static endpoint range. It can take any value in 
#            the 0-4294967295 range. Can be used only for L2VPN traffic, but is not supported in this release.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Layer2.ATM
#    -vci_count
#        If -atm_counter_vci_type is set to counter and atm_counter_vci_mode 
#        is set to incr or decr, then this is the number of times to increment 
#        the VCI value before repeating from the start value (DEFAULT 1). 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer2.ATM
#    -vci_step
#        Depending on the traffic_generator value, this option has different 
#        meanings.  Valid choices are:
#        ixos/ixnetwork_540 - If -atm_counter_vci_type is set to counter, then this 
#            is the value added/substracted  between successive vci values 
#            (DEFAULT = 1).
#        ixnetwork - This option is used to specify the step between the value 
#            of the first VCI of each the ATM static endpoint range. It can 
#            take any numeric value. Can be used only for L2VPN traffic, but is not supported in this release.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Layer2.ATM
#    -vlan_cfi
#        Whether VLAN CFI bit is set or unset for a particular stream. 
#        For stacked VLAN (QinQ) this parameter will be provided as a list 
#        of values, each of them representing whether VLAN CFI bit is set 
#        or unset for each VLAN from the stack. Valid only for traffic_generator ixos and ixnetwork_540.
#        Example: {1 0 1 1}
#        Valid options are:
#        0 - Unset
#        1 - Set
#        Category: Layer2.Ethernet
#    -vlan_id
#        VLAN tag for a particular stream. Valid choices are between 0 and 
#        4095, inclusive. For stacked VLAN (QinQ) this parameter will be 
#        provided as a list of values, each of them representing the id 
#        a VLAN from the stack.
#        Example: {10 13 14 20} 
#        Valid only for traffic_generator ixos, ixnetwork and ixnetwork_540.
#        If emulation_src_handle or emulation_dst_handle are present and 
#        traffic_generator argument is "ixos", the traffic will be configured 
#        over PPPoX sessions using IxOS. In this case the 
#        vlan parameters apply only to the downstream (traffic sent from IP/Network 
#        port to PPPoE access port). 
#        Upstream traffic will use vlan information from the PPPoE handle.
#        Downstream traffic will use vlan information set through this parameter.
#        For traffic generator ixnetwork is used only for L2VPN traffic, but is not supported in this release.
#        Category: Layer2.Ethernet
#    -vlan_id_count
#        Number of VLANs to be used for a particular stream. Option 
#        "vlan_id_mode" must be set to increment or decrement. Valid choices 
#        are between 1 and 4096, inclusive.
#        For stacked VLAN (QinQ) this parameter will be provided as a list 
#        of values, each of them representing the number of VLANs for each 
#        vlan_id from the stack.
#        Example: {2 5 1 13} 
#        Valid only for traffic_generator ixos and ixnetwork_540.
#        Category: Layer2.Ethernet
#    -vlan_id_mode
#        Behavior of the VLAN tag in packets for a particular stream. 
#        For stacked VLAN (QinQ) this parameter will be provided as a list 
#        of values, each of them representing the Behavior of each 
#        VLAN from the stack. Only the top two VLAN elements in a stacked 
#        VLAN may use values different from "fixed". 
#        For traffic_generator ixnetwork is used only for L2VPN traffic, but is not supported in this release.
#        For traffic_generator ixnetwork_540 the behavior is the same as for traffic_generator 
#        ixos.
#        Example: {increment nested_incr fixed fixed}
#        Valid choices are:
#        fixed     - Will set the VLAN tag to be in idle mode. 
#                    Available when using traffic_generator ixnetwork and ixos and ixnetwork_540.
#        increment - Will set the VLAN tag to be in increment mode.  
#                    Available when using traffic_generator ixnetwork and ixos and ixnetwork_540.  
#                    It is the default when using the ixos/ixnetwork_540 traffic 
#                    generator.
#        decrement - Will set the VLAN tag to be in decrement mode. 
#                    Available when using traffic_generator ixos and ixnetwork_540.
#        random    - Will set the VLAN tag to be in random mode. 
#                    Available when using traffic_generator ixos.
#        nested_incr - For the second VLAN in a stackedVlan, this may be 
#                    used to performed nested increment with respect to 
#                    the first stack element. 
#                    Available when using traffic_generator ixos.
#        nested_decr - For the second VLAN in a stackedVlan, this may be 
#                    used to performed nested decrement with respect to 
#                    the first stack element. 
#                    Available when using traffic_generator ixos.
#        list      -  Will set the VLAN tag to be a list of values. 
#                    Available when using traffic_generator ixnetwork_540 with mode append_header/modify_header.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Layer2.Ethernet
#    -vlan_id_step
#        The step value for a VLAN ID when the mode is increment or decrement 
#        For stacked VLAN (QinQ) this parameter will be provided as a list 
#        of values, each of them representing the step value for each 
#        VLAN ID from the stack.
#        Example: {2 4 6 1} 
#        Valid only for traffic_generator ixos, ixnetwork_540 and ixnetwork.
#        For traffic_generator ixnetwork is used only for L2VPN traffic, but is not supported in this release.
#        Category: Layer2.Ethernet
#    -vlan_user_priority
#        VLAN user priority for the stream. Valid choices are between 0 and 7, 
#        inclusive.
#        For stacked VLAN (QinQ) this parameter will be provided as a list 
#        of values, each of them representing the user priority for each 
#        VLAN ID from the stack.
#        Example: {2 4 6 0} 
#        Valid only for traffic_generator ixos and ixnetwork_540.
#        Category: Layer2.Ethernet
#    -vpi
#        Depending on the traffic_generator value, this option has different 
#        meanings.  Valid choices are:
#        ixos/ixnetwork_540 - The virtual path identifier (DEFAULT = 0).
#        ixnetwork - This option is used to specify the value of the first VPI 
#            of the first ATM static endpoint range. It can take any value in 
#            the 0-4294967295 range. Can be used only for L2VPN traffic, but is not supported in this release.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Layer2.ATM
#    -vpi_count
#        If -atm_counter_vpi_type is set to counter and atm_counter_vpi_mode 
#        is set to incr or decr, then this is the number of times to increment 
#        the VPI value before repeating from the start value (DEFAULT 1). 
#        Valid only for traffic_generator ixos/ixnetwork_540.
#        Category: Layer2.ATM
#    -vpi_step
#        Depending on the traffic_generator value, this option has different 
#        meanings.  Valid choices are:
#        ixos/ixnetwork_540 - If -atm_counter_vpi_type is set to counter, then this 
#            is the value added/substracted  between successive vpi values 
#            (DEFAULT = 1).
#        ixnetwork - This option is used to specify the step between the value 
#            of the first VPI of each the ATM static endpoint range. It can 
#            take any numeric value. Can be used only for L2VPN traffic, but is not supported in this release.
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#        Category: Layer2.ATM
#x   -adjust_rate
#x       Specialty code meant for limited use.  Some hardware (because of the 
#x       nature of the input data) will not set the stream rate at the exact 
#x       rate specified, and could be off slightly due to gaps, etc. 
#x       This will compensate for that by creating two streams in the advanced 
#x       stream mode that total the exact value required. 
#x       This is a very 
#x       focused feature, not meant to be used widely. It will be removed 
#x       when the new hardware support this capability. 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.Rate Control
#x   -allow_self_destined
#x       This argument can be used to specify if it is allowed to send traffic 
#x       from routes on an Ixia port to other routes on the same Ixia port. 
#x       Valid only for traffic_generator ixnetwork and ixnetwork_540. When using 
#x       traffic_generator ixnetwork_540, mode create and -port_handle parameter 
#x       but without -port_handle2 this parameter will be forced to '1'. and the source 
#x       (DEFAULT = 0)
#x       Category: General.Common
#x   -app_profile_type
#x       This argument can be used to specify the application traffic profile 
#x       used for setting up the application traffic test. 
#x       Valid only for traffic_generator ixnetwork.
#x       Category: Layer4-7.Application Traffic
#x   -arp_dst_hw_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify arp_dst_hw when arp_dst_hw_mode is incr 
#x       or decr.
#x       (DEFAULT = 0000.0000.0001)
#x       Category: Layer4-7.ARP
#x   -arp_dst_hw_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by arp_dst_hw_addr
#x          1 - enable tracking by arp_dst_hw_addr
#x       Category: Layer4-7.ARP
#x   -arp_hw_address_length
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure 1 byte HEX value for ARP Hardware Address Length.
#x       Category: Layer4-7.ARP
#x   -arp_hw_address_length_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the arp_hw_address_length 
#x       is incremeneted or decremented when arp_hw_address_length_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ARP
#x   -arp_hw_address_length_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for arp_hw_address_length. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with arp_hw_address_length_step and arp_hw_address_length_count.
#x          decr - the value is decremented as specified with arp_hw_address_length_step and arp_hw_address_length_count.
#x          list - Parameter -arp_hw_address_length contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ARP
#x   -arp_hw_address_length_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify arp_hw_address_length when arp_hw_address_length_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ARP
#x   -arp_hw_address_length_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by arp_hw_address_length
#x          1 - enable tracking by arp_hw_address_length
#x       Category: Layer4-7.ARP
#x   -arp_hw_type
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure 2 bytes HEX value for ARP Hardware Type.
#x       Category: Layer4-7.ARP
#x   -arp_hw_type_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the arp_hw_type 
#x       is incremeneted or decremented when arp_hw_type_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ARP
#x   -arp_hw_type_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for arp_hw_type. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with arp_hw_type_step and arp_hw_type_count.
#x          decr - the value is decremented as specified with arp_hw_type_step and arp_hw_type_count.
#x          list - Parameter -arp_hw_type contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ARP
#x   -arp_hw_type_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify arp_hw_type when arp_hw_type_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ARP
#x   -arp_hw_type_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - disable tracking by arp_hw_type
#x          1 - enable tracking by arp_hw_type
#x       Category: Layer4-7.ARP
#x   -arp_operation_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for arp_operation. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -arp_operation contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ARP
#x   -arp_operation_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by arp_operation
#x          1 - enable tracking by arp_operation
#x       Category: Layer4-7.ARP
#x   -arp_protocol_addr_length
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure 1 byte HEX value for ARP Protocol Address Length.
#x       Category: Layer4-7.ARP
#x   -arp_protocol_addr_length_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the arp_protocol_addr_length 
#x       is incremeneted or decremented when arp_protocol_addr_length_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ARP
#x   -arp_protocol_addr_length_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for arp_protocol_addr_length. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with arp_protocol_addr_length_step and arp_protocol_addr_length_count.
#x          decr - the value is decremented as specified with arp_protocol_addr_length_step and arp_protocol_addr_length_count.
#x          list - Parameter -arp_protocol_addr_length contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ARP
#x   -arp_protocol_addr_length_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify arp_protocol_addr_length when arp_protocol_addr_length_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ARP
#x   -arp_protocol_addr_length_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by arp_protocol_addr_length
#x          1 - enable tracking by arp_protocol_addr_length
#x       Category: Layer4-7.ARP
#x   -arp_protocol_type
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure 2 bytes HEX value for ARP Protocol Type.
#x       (DEFAULT = 0)
#x       Category: Layer4-7.ARP
#x   -arp_protocol_type_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the arp_protocol_type 
#x       is incremeneted or decremented when arp_protocol_type_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ARP
#x   -arp_protocol_type_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for arp_protocol_type. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with arp_protocol_type_step and arp_protocol_type_count.
#x          decr - the value is decremented as specified with arp_protocol_type_step and arp_protocol_type_count.
#x          list - Parameter -arp_protocol_type contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ARP
#x   -arp_protocol_type_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify arp_protocol_type when arp_protocol_type_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ARP
#x   -arp_protocol_type_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by arp_protocol_type
#x          1 - enable tracking by arp_protocol_type
#x       Category: Layer4-7.ARP
#x   -arp_src_hw_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify arp_src_hw_addr when arp_src_hw_mode is incr 
#x       or decr.
#x       (DEFAULT = 0000.0000.0001)
#x       Category: Layer4-7.ARP
#x   -arp_src_hw_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by arp_src_hw_addr
#x          1 - enable tracking by arp_src_hw_addr
#x       Category: Layer4-7.ARP
#x   -atm_counter_vci_data_item_list
#x       If the -atm_counter_vci_type option is set to table, this list is used 
#x       used for the set of values (DEFAULT ""). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer2.ATM
#x   -atm_counter_vci_mask_select
#x       If the -atm_counter_vci_type option is set to random, this 16-bit mask 
#x       indicates which bits are held constant The constant values are indicated 
#x       in the -atm_counter_vci_mask_value option (DEFAULT "00 00").  
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.ATM
#x   -atm_counter_vci_mask_value
#x       If the -atm_counter_vci_type option is set to random, this 16-bit value 
#x       indicates the values that the bits indicated in the 
#x       atm_counter_vci_mask_select option should have (DEFAULT "00 00"). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer2.ATM
#x   -atm_counter_vci_mode
#x       If the -atm_counter_vci_type option is set to counter, this indicates 
#x       what counter mode should be used (DEFAULT incr). Currently only the incr 
#x       and decr mode are supported. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer2.ATM
#x   -atm_counter_vci_type
#x       The type of counter to use on the vci. 
#x       Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#x       fixed - DEFAULT
#x       random - not supported with traffic_generator ixnetwork_540. Parameters 
#x                atm_counter_vci_mask_select and atm_counter_vci_mask_value are 
#x                also involved when setting this type.
#x       counter - parameter vci_count is also involved when setting this type.
#x       table - parameter atm_counter_vci_data_item_list is also involved when setting this type.
#x       Category: Layer2.ATM
#x   -atm_counter_vpi_data_item_list
#x       If the -atm_counter_vpi_type option is set to table, this list is used 
#x       used for the set of values (DEFAULT ""). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer2.ATM
#x   -atm_counter_vpi_mask_select
#x       If the -atm_counter_vpi_type option is set to random, this 16-bit mask 
#x       indicates which bits are held constant The constant values are indicated 
#x       in the -atm_counter_vpi_mask_value option (DEFAULT "00 00"). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.ATM
#x   -atm_counter_vpi_mask_value
#x       If the -atm_counter_vpi_type option is set to random, this 16-bit value 
#x       indicates the values that the bits indicated in the 
#x       atm_counter_vpi_mask_select option should have (DEFAULT "00 00"). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer2.ATM
#x   -atm_counter_vpi_mode
#x       If the -atm_counter_vpi_type option is set to counter, this indicates 
#x       what counter mode should be used (DEFAULT incr). Currently only the incr 
#x       and decr mode are supported. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer2.ATM
#x   -atm_counter_vpi_type
#x       The type of counter to use on the vpi (DEFAULT fixed). Currently only fixed, 
#x       counter, and table are supported. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer2.ATM
#x   -atm_header_aal5error
#x       May be used to insert a bad AAL5 CRC (DEFAULT no_error). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.ATM
#x   -atm_header_cell_loss_priority
#x       Sets the Cell Loss Priority (CLP) used to set the discard priority 
#x       level of the cell. It indicates whether the cell should be discarded 
#x       if it encounters extreme congestion as it moves through the network. 
#x       Value 0 has a higher priority than 1 (DEFAULT 0). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.ATM
#x   -atm_header_cpcs_length
#x       If -atm_header_enable_cpcs_length is 1, then this is used as the length 
#x       of the CPCS PDU (DEFAULT 28). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.ATM
#x   -atm_header_enable_auto_vpi_vci
#x       If set to 1, the vpi/vci values are forced to 0 and 32 (default 0). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.ATM
#x   -atm_header_enable_cl
#x       Indicates whether congestion has been experienced (default 0). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.ATM
#x   -atm_header_enable_cpcs_length
#x       If set to 1, -atm_header_cpcs_length is used as the length of the 
#x       CPCS PDU (default 0). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.ATM
#x   -atm_header_encapsulation
#x       The type of header encapsulation. Depending on the traffic_generator 
#x       value, this option has different value choices.  
#x       For ixnetwork traffic generator the parameter can be used only for 
#x       L2VPN traffic, but is not supported in this release. Valid choices are:
#x       ixos - vcc_mux_ipv4_routed, vcc_mux_bridged_eth_fcs, vcc_mux_bridged_eth_no_fcs, vcc_mux_ipv6_routed,vcc_mux_mpls_routed, llc_routed_clip, llc_bridged_eth_fcs, llc_bridged_eth_no_fcs, llc_pppoa, vcc_mux_ppoa, llc_nlpid_routed 
#x             (DEFAULT = llc_routed_clip).
#x       ixnetwork - llc_bridged_eth_fcs, llc_bridged_eth_no_fcs,llc_ppp, llc_routed_snap, vcc_mux_bridged_eth_fcs, vcc_mux_bridged_eth_no_fcs, vcc_mux_ppp, vcc_mux_routed
#x       ixnetwork_540 - vcc_mux_ipv4_routed, vcc_mux_bridged_eth_fcs, vcc_mux_bridged_eth_no_fcs, vcc_mux_ipv6_routed, vcc_mux_mpls_routed, llc_routed_clip, llc_bridged_eth_fcs, llc_bridged_eth_no_fcs, llc_pppoa, vcc_mux_ppoa, llc_ppp, llc_routed_snap, vcc_mux_ppp, vcc_mux_routed
#        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: Layer2.ATM
#x   -atm_header_generic_flow_ctrl
#x       The generic flow control for use in UNI mode device control signalling. 
#x       Uncontrolled equipment uses a setting of 0000 (default 0). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.ATM
#x   -atm_header_hec_errors
#x       Indicates the number of HEC errors to insert into the HEC byte 
#x       (default 0). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.ATM
#x   -atm_range_count
#x       This option is used to specify the number of ATM static endpoint 
#x       ranges. It can take any numeric value. 
#x       Valid for traffic_generator ixnetwork.
#x       Category: Layer2.ATM
#x    -becn
#x       Backward Explicit Congestion Notification. 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.Frame Relay
#x   -circuit_endpoint_type
#x       This argument can be used to specify the endpoint type that will be 
#x       used to generate traffic. Valid only for traffic_generator ixnetwork/ixnetwork_540. 
#x       Valid choices are:
#x       atm                      - Select this option if the endpoint supports 
#x                                  ATM.
#x       ethernet_vlan            - Select this option if the endpoint supports 
#x                                  Ethernet/VLAN (MAC addressing).
#x       ethernet_vlan_arp        - Select this option if the endpoint supports 
#x                                  Ethernet/VLAN (MAC addressing) and ARP.
#x       frame_relay              - Select this option if the endpoint supports 
#x                                  Frame Relay.
#x       hdlc                     - Select this option if the endpoint supports 
#x                                  HDLC/POS.
#x       ipv4                     - Select this option if the endpoint supports 
#x                                  IPv4.
#x       ipv4_arp                 - Select this option if the endpoint supports 
#x                                  IPv4 and ARP.
#x       ipv4_application_traffic - Select this option if the endpoint supports 
#x                                  IPv4 application traffic generation.
#x       ipv6                     - Select this option if the endpoint supports 
#x                                  IPv6.
#x       ipv6_application_traffic - Select this option if the endpoint supports 
#x                                  IPv6 application traffic generation.
#x       ppp                      - Select this option if the endpoint supports 
#x                                  PPP/POS.
#x       fcoe                     - Select this options if the endpoint supports fcoe.
#x       fc                       - Select this options if the endpoint supports fc.
#x       multicast_igmp           - Use this option only if -emulation_src_handle or -emulation_dst_handle 
#x                                  is represented by IP handles. Eg: 20.0.1.2/50.0.1.5/0.0.0.1/3. Valid 
#x                                  only for IxTclNetwork.
#x       Category: General.Endpoint Data
#x   -circuit_type
#x       This argument can be used to specify the circuit type that will be 
#x       used to transmit traffic. Valid only for traffic_generator ixnetwork/ixnetwork_540. 
#x       For traffic_generator ixnetwork_540:
#x          If the parameter is configured as raw the traffic endpoints must be raw. 
#x          If it is configured to anything else it will accept all the endpoint 
#x          types. For example, if circuit_type is vpls and emulation_src_handle is 
#x          a pppox handle it will ignore the 'vpls' restriction and use the pppox 
#x          handle as source. 
#x       For traffic_generator ixnetwork the valid choices are:
#x       vpls  - VPLS traffic will be sent by the transmit port.
#x       l2vpn - L2VPN encapsulated traffic will be sent by the transmit port.
#x       l3vpn - L3VPN encapsulated traffic will be sent by the transmit port.
#x       mpls  - MPLS encapsulated traffic will be sent by the transmit port.
#x       6pe   - 6PE encapsulated traffic will be sent by the transmit port.
#x       6vpe  - 6VPE encapsulated traffic will be sent by the transmit port.
#x       none  - no MPLS encapsulation will be used by the transmit port.
#x       stp   - L2 with 802.1q encapsulated traffic will be sent by the 
#x               transmit port.
#x       mac_in_mac - stacked vlan encapsulation will be used by the transmit port.
#x       raw   - if selected, traffic is sent on a port-to-port basis, without 
#x               the use of protocol interfaces. Configuration of source and 
#x               destination addresses and other information is manually 
#x               configured. If this type of circuit is selected, 
#x               the configuration of the -src_dest_mesh and -route_mesh 
#x               arguments is disabled.
#x       quick_flows - if selected, the traffic configuration will use IxNetwork 
#x               quick flow streams instead of L2L3 streams. This option also allows 
#x               the configuration and use of UDFs. 
#x               Note that when using quick flows there are some tracking limitations 
#x               to be considered: 
#x               1. The tracking option operates across ALL quick flows (per traffic item) 
#x               2. The track_by field can only support values: 
#x                  none, all custom modes, endpoint_pair, source_dest_value_pair, 
#x                  dest_endpoint, source_endpoint, source_dest_port_pair, source_port.
#x       application - if selected, L4 - L7 Application traffic is created 
#x               Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -convert_to_raw
#x       Valid for traffic_generator ixnetwork_540. If this parameter is 1 the 
#x       traffic item being created will be transformed into a raw traffic item 
#x       allowing to modify fields of the packet that are normally configured from 
#x       the learned info of the traffic endpoitns. For example, if two IPv4 interfaces 
#x       are used as traffic endpoints, ip_src_addr and ip_dst_addr cannot be configured 
#x       unless this flag is used. Valid choices are:
#x          0 - (DEFAULT) disable
#x          1 - enable
#x       Category: General.Common
#x   -custom_offset
#x       This argument can be used to specify the offset from the beginning of 
#x       the packet where the custom-defined value will be inserted (in bytes). 
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540 and track_by 
#x       custom_8bit/custom_16bit/custom_24bit/custom_32bit.
#x       Category: General.Tracking
#x   -custom_values
#x       Configure the values to be inserted at custom_offset. A list of values is 
#x       accepted. Valid only for traffic_generator ixnetwork_540 and track_by 
#x       custom_8bit/custom_16bit/custom_24bit/custom_32bit.
#x       Category: General.Tracking
#x   -data_pattern
#x       Payload value in bytes. For example, you can specify a custom payload 
#x       pattern like the following using option "data_pattern":
#x       00 44 00 44 
#x       Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -data_pattern_mode
#x       Packet payload mode for a particular stream. Valid choices are:
#x       incr_byte - Data patterm increments each byte in the packet payload. 
#x                   Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       decr_byte - Data patterm decrements each byte in the packet payload. 
#x                   Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       incr_word - Data patterm increments each word in the packet payload. 
#x                   Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       decr_byte - Data patterm decrements each word in the packet payload. 
#x                   Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       fixed     - Data patterm is idle for each byte in the packet payload. 
#x                   Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540. 
#x                   For traffic_generator ixnetwork, you can set data_pattern 
#x                   as one of the predefined patterns "00 FF 00 FF", 
#x                   "DE AD BE EF", "00 11 22 33", "AA 77 AA 77", or you can set 
#x                   any other type of pattern which will pass as a user 
#x                   defined pattern.
#x       random    - Data patterm is random for the packet payload. 
#x                   Valid only for traffic_generator ixos/ixnetwork_540.
#x       repeating - Data patterm repeats for the packet payload. 
#x                   Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -data_tos
#x       The TOS value when –enable_data is enabled. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer3.IPv4
#x   -data_tos_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the data_tos 
#x       is incremeneted or decremented when data_tos_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -data_tos_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for data_tos. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with data_tos_step and data_tos_count.
#x          decr - the value is decremented as specified with data_tos_step and data_tos_count.
#x          list - Parameter -data_tos contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -data_tos_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify data_tos when data_tos_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -data_tos_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by data_tos
#x          1 - enable tracking by data_tos
#x       Category: Layer3.IPv4
#x   -destination_filter
#x       Valid only for traffic_generator ixnetwork_540. 
#x       This parameter filter on the available destination endpoints that can be provided with emulation_dst_handle. 
#x       Valid choices are:
#x          all  - There are no filters applied
#x          ethernet - Ethernet endpoints only (for raw trafic only)
#x          atm - ATM endpoints only (for raw trafic only)
#x          framerelay - Frame Relay endpoints only (for raw trafic only)
#x          hdlc - HDLC endpoints only (for raw trafic only)
#x          ppp - PPP endpoints only (for raw trafic only)
#x          none - non MPLS endpoints only
#x          l2vpn - L2VPN endpoints only
#x          l3vpn - L3VPN endpoints only
#x          mpls - MPLS endpoints only
#x          6pe - 6PE endpoints only
#x          6vpe - 6VPE endpoints only
#x          bgpvpls - VPLS endpoints only
#x          mac_in_mac - MAC in MAC endpoints only
#x          data_center_bridging - Data Center and Bridging endpoints only
#x       Category: General.Endpoint Data
#x   -dhcp_boot_filename
#x       Boot file name, null terminated string; "generic" name or null in 
#x       DHCPDISCOVER, fully qualified directory-path name DHCPOFFER.
#x       (DEFAULT = "")
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_boot_filename_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_boot_filename
#x          1 - enable tracking by dhcp_boot_filename
#x       Category: Layer4-7.DHCP
#x   -dhcp_client_hw_addr
#x       Client hardware address.  Must be in the form of a string of hex 
#x       data.
#x       (DEFAULT = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_client_hw_addr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_client_hw_addr 
#x       is incremeneted or decremented when dhcp_client_hw_addr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_client_hw_addr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_client_hw_addr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_client_hw_addr_step and dhcp_client_hw_addr_count.
#x          decr - the value is decremented as specified with dhcp_client_hw_addr_step and dhcp_client_hw_addr_count.
#x          list - Parameter -dhcp_client_hw_addr contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_client_hw_addr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_client_hw_addr when dhcp_client_hw_addr_mode is incr 
#x       or decr.
#x       Category: Layer4-7.DHCP
#x   -dhcp_client_hw_addr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_client_hw_addr
#x          1 - enable tracking by dhcp_client_hw_addr
#x       Category: Layer4-7.DHCP
#x   -dhcp_client_ip_addr
#x       Client IP address.  Only filled in if client is in BOUND, RENEW, or 
#x       REBINDING state and can respond to ARP requests.
#x       (DEFAULT = 0.0.0.0) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_client_ip_addr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_client_ip_addr 
#x       is incremeneted or decremented when dhcp_client_ip_addr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_client_ip_addr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_client_ip_addr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_client_ip_addr_step and dhcp_client_ip_addr_count.
#x          decr - the value is decremented as specified with dhcp_client_ip_addr_step and dhcp_client_ip_addr_count.
#x          list - Parameter -dhcp_client_ip_addr contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_client_ip_addr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_client_ip_addr when dhcp_client_ip_addr_mode is incr 
#x       or decr.
#x       (DEFAULT = 0.0.0.0)
#x       Category: Layer4-7.DHCP
#x   -dhcp_client_ip_addr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_client_ip_addr
#x          1 - enable tracking by dhcp_client_ip_addr
#x       Category: Layer4-7.DHCP
#x   -dhcp_flags
#x       Tells whether to broadcast or not. Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#x          broadcast - broadcast
#x          no_broadcast - (DEFAULT) no_broadcast
#x       Category: Layer4-7.DHCP
#x   -dhcp_flags_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_flags. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -dhcp_flags contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_flags_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_flags
#x          1 - enable tracking by dhcp_flags
#x       Category: Layer4-7.DHCP
#x   -dhcp_hops
#x       Set to zero by client.
#x       (DEFAULT = 0) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_hops_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_hops 
#x       is incremeneted or decremented when dhcp_hops_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_hops_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_hops. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_hops_step and dhcp_hops_count.
#x          decr - the value is decremented as specified with dhcp_hops_step and dhcp_hops_count.
#x          list - Parameter -dhcp_hops contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_hops_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_hops when dhcp_hops_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_hops_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_hops
#x          1 - enable tracking by dhcp_hops
#x       Category: Layer4-7.DHCP
#x   -dhcp_hw_len
#x       Hardware address length.
#x       (DEFAULT = 6). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_hw_len_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_hw_len 
#x       is incremeneted or decremented when dhcp_hw_len_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_hw_len_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_hw_len. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_hw_len_step and dhcp_hw_len_count.
#x          decr - the value is decremented as specified with dhcp_hw_len_step and dhcp_hw_len_count.
#x          list - Parameter -dhcp_hw_len contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_hw_len_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_hw_len when dhcp_hw_len_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_hw_len_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_hw_len
#x          1 - enable tracking by dhcp_hw_len
#x       Category: Layer4-7.DHCP
#x   -dhcp_hw_type
#x       Hardware address types.
#x       (DEFAULT = 1). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_hw_type_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_hw_type 
#x       is incremeneted or decremented when dhcp_hw_type_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_hw_type_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_hw_type. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_hw_type_step and dhcp_hw_type_count.
#x          decr - the value is decremented as specified with dhcp_hw_type_step and dhcp_hw_type_count.
#x          list - Parameter -dhcp_hw_type contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_hw_type_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_hw_type when dhcp_hw_type_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_hw_type_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_hw_type
#x          1 - enable tracking by dhcp_hw_type
#x       Category: Layer4-7.DHCP
#x   -dhcp_magic_cookie
#x       Valid only for traffic_generator ixnetwork_540 and l4_protocol 'dhcp'.
#x       Configure the 4 bytes HEX number for the 'Magic Cookie' field.
#x       Category: Layer4-7.DHCP
#x   -dhcp_magic_cookie_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_magic_cookie 
#x       is incremeneted or decremented when dhcp_magic_cookie_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_magic_cookie_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_magic_cookie. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_magic_cookie_step and dhcp_magic_cookie_count.
#x          decr - the value is decremented as specified with dhcp_magic_cookie_step and dhcp_magic_cookie_count.
#x          list - Parameter -dhcp_magic_cookie contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_magic_cookie_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_magic_cookie when dhcp_magic_cookie_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_magic_cookie_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_magic_cookie
#x          1 - enable tracking by dhcp_magic_cookie
#x       Category: Layer4-7.DHCP
#x   -dhcp_operation_code
#x       Operation codes. Valid options are: 
#x          reply
#x          request (DEFAULT)
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_operation_code_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_operation_code. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -dhcp_operation_code contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_operation_code_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_operation_code
#x          1 - enable tracking by dhcp_operation_code
#x       Category: Layer4-7.DHCP
#x   -dhcp_option
#x       The DHCP options that can be added to the DHCP header. Valid only for traffic_generator ixos. 
#x       Valid choices are:
#x       dhcp_pad                          - for this option there should 
#x                                                be no data provided
#x       dhcp_end                          - for this option there should 
#x                                                be no data provided
#x       dhcp_subnet_mask                  - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_time_offset                  - accepted values:  0-4294967295; 
#x                                              number of values: 1
#x       dhcp_gateways                     - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_time_server                  - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_name_server                  - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_domain_name_server           - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_log_server                   - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_cookie_server                - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_lpr_server                   - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_impress_server               - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_resource_location_server     - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_host_name                    - accepted values:  string; 
#x                                              number of values: 1
#x       dhcp_boot_file_size               - accepted values:  0-65535; 
#x                                              number of values: 1
#x       dhcp_merit_dump_file              - accepted values:  string; 
#x                                              number of values: 1
#x       dhcp_domain_name                  - accepted values:  string; 
#x                                              number of values: 1
#x       dhcp_swap_server                  - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_root_path                    - accepted values:  string; 
#x                                              number of values: 1
#x       dhcp_extension_path               - accepted values:  string; 
#x                                              number of values: 1
#x       dhcp_ip_forwarding_enable         - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_non_local_src_routing_enable - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_policy_filter                - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_max_datagram_reassembly_size - accepted values:  0-65535; 
#x                                              number of values: 1
#x       dhcp_default_ip_ttl               - accepted values:  hex byte 
#x                                                (eg: aa); 
#x                                              number of bytes: 1
#x       dhcp_path_mtu_aging_timeout       - accepted values:  0-4294967295; 
#x                                              number of values: 1
#x       dhcp_path_mtu_plateau_table       - accepted values:  0-65535; 
#x                                              number of values: list
#x       dhcp_interface_mtu                - accepted values:  0-65535; 
#x                                              number of values: 1
#x       dhcp_all_subnets_are_local        - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_broadcast_address            - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_perform_mask_discovery       - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_mask_supplier                - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_perform_router_discovery     - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_router_solicit_addr          - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_static_route                 - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_trailer_encapsulation        - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_arp_cache_timeout            - accepted values:  0-4294967295; 
#x                                              number of values: 1
#x       dhcp_ethernet_encapsulation       - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_tcp_default_ttl              - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_tcp_keep_alive_interval      - accepted values:  0-4294967295; 
#x                                              number of values: 1
#x       dhcp_tcp_keep_garbage             - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_nis_domain                   - accepted values:  string; 
#x                                              number of values: 1
#x       dhcp_nis_server                   - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_ntp_server                   - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_vendor_specific_info         - accepted values:  hex byte 
#x                                                (eg: 0a); 
#x                                              number of bytes:  1
#x       dhcp_net_bios_name_svr            - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_net_bios_datagram_dist_svr   - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_net_bios_node_type           - accepted values:  hex byte 
#x                                                (eg: 0a); 
#x                                              number of bytes:  1
#x       dhcp_net_bios_scope               - accepted values:  hex bytes 
#x                                                (eg: 01.02 or 00:03); 
#x                                              number of values: 1+
#x       dhcp_xwin_sys_font_svr            - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_requested_ip_addr            - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_ip_addr_lease_time           - accepted values:  0-4294967295; 
#x                                              number of values: 1
#x       dhcp_option_overload              - accepted values:  bit; 
#x                                              number of values: 1
#x       dhcp_tftp_svr_name                - accepted values:  string; 
#x                                              number of values: 1
#x       dhcp_boot_file_name               - accepted values:  string; 
#x                                              number of values: 1
#x       dhcp_message_type                 - accepted values:  1-9; 
#x                                              number of values: 1
#x       dhcp_svr_identifier               - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_param_request_list           - accepted values:  hex bytes 
#x                                                (eg: 01.02 or 00:03); 
#x                                              number of values: 1+
#x       dhcp_message                      - accepted values:  string; 
#x                                              number of values: 1
#x       dhcp_max_message_size             - accepted values:  0-65535; 
#x                                              number of values: 1
#x       dhcp_renewal_time_value           - accepted values:  0-4294967295; 
#x                                              number of values: 1
#x       dhcp_rebinding_time_value         - accepted values:  0-4294967295; 
#x                                              number of values: 1
#x       dhcp_vendor_class_id              - accepted values:  hex bytes 
#x                                                (eg: 01.02 or 00:03); 
#x                                              number of values: 1+
#x       dhcp_client_id                    - accepted values:  hex bytes 
#x                                                (eg: 01.02 or 00:03); 
#x                                              number of values: 1+
#x       dhcp_xwin_sys_display_mgr         - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_nis_plus_domain              - accepted values:  string; 
#x                                              number of values: 1
#x       dhcp_nis_plus_server              - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_mobile_ip_home_agent         - accepted values:  IP; 
#x                                              number of values: list
#x       dhcp_smtp_svr                     - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_pop3_svr                     - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_nntp_svr                     - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_www_svr                      - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_default_finger_svr           - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_default_irc_svr              - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_street_talk_svr              - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_stda_svr                     - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_agent_information_option     - accepted values:  hex bytes 
#x                                                (eg: 01.02 or 00:03); 
#x                                              number of values: 1+
#x       dhcp_netware_ip_domain            - accepted values:  IP; 
#x                                              number of values: 1
#x       dhcp_network_ip_option            - accepted values:  hex bytes 
#x                                                (eg: 01.02 or 00:03); 
#x                                              number of values: 2 values 
#x                                                with at least one hex byte 
#x                                                and corresponding to the 
#x                                                format above
#x       Category: Layer4-7.DHCP
#x   -dhcp_option_data
#x      The data in the options section of a DHCP frame. 
#x      Option data may either be set as a single value (e.g. 255.255.255.0), 
#x      a stream of bytes (e.g. 01.03.06.0F.2C or 01:03:06:0F:2C) or as a list 
#x      of enumerated dhcp options (e.g. [list dhcp_subnet_mask dhcp_gateways 
#x      dhcp_domain_name_server]).
#x      (DEFAULT = ""). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.DHCP
#x   -dhcp_relay_agent_ip_addr
#x       Relay agent IP address, used in booting via a relay agent.
#x       (DEFAULT = 0.0.0.0). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_relay_agent_ip_addr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_relay_agent_ip_addr 
#x       is incremeneted or decremented when dhcp_relay_agent_ip_addr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_relay_agent_ip_addr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_relay_agent_ip_addr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_relay_agent_ip_addr_step and dhcp_relay_agent_ip_addr_count.
#x          decr - the value is decremented as specified with dhcp_relay_agent_ip_addr_step and dhcp_relay_agent_ip_addr_count.
#x          list - Parameter -dhcp_relay_agent_ip_addr contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_relay_agent_ip_addr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_relay_agent_ip_addr when dhcp_relay_agent_ip_addr_mode is incr 
#x       or decr.
#x       Category: Layer4-7.DHCP
#x   -dhcp_relay_agent_ip_addr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_relay_agent_ip_addr
#x          1 - enable tracking by dhcp_relay_agent_ip_addr
#x       Category: Layer4-7.DHCP
#x   -dhcp_seconds
#x       Seconds elapsed since client began address acquisition or renewal 
#x       process.
#x       (DEFAULT = 0). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_seconds_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_seconds 
#x       is incremeneted or decremented when dhcp_seconds_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_seconds_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_seconds. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_seconds_step and dhcp_seconds_count.
#x          decr - the value is decremented as specified with dhcp_seconds_step and dhcp_seconds_count.
#x          list - Parameter -dhcp_seconds contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_seconds_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_seconds when dhcp_seconds_mode is incr 
#x       or decr.
#x       Category: Layer4-7.DHCP
#x   -dhcp_seconds_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_seconds
#x          1 - enable tracking by dhcp_seconds
#x       Category: Layer4-7.DHCP
#x   -dhcp_server_host_name
#x       Optional server host name, null terminated string.
#x       (DEFAULT = ""). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_server_host_name_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_server_host_name
#x          1 - enable tracking by dhcp_server_host_name
#x       Category: Layer4-7.DHCP
#x   -dhcp_server_ip_addr
#x       IP address of next server to use in bootstrap; returned in DHCPOFFER, 
#x       DHCPACK by server.
#x       (DEFAULT = 0.0.0.0). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_server_ip_addr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_server_ip_addr 
#x       is incremeneted or decremented when dhcp_server_ip_addr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_server_ip_addr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_server_ip_addr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_server_ip_addr_step and dhcp_server_ip_addr_count.
#x          decr - the value is decremented as specified with dhcp_server_ip_addr_step and dhcp_server_ip_addr_count.
#x          list - Parameter -dhcp_server_ip_addr contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_server_ip_addr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_server_ip_addr when dhcp_server_ip_addr_mode is incr 
#x       or decr.
#x       Category: Layer4-7.DHCP
#x   -dhcp_server_ip_addr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_server_ip_addr
#x          1 - enable tracking by dhcp_server_ip_addr
#x       Category: Layer4-7.DHCP
#x   -dhcp_transaction_id
#x       Random number chosen by client and used by the client and server to 
#x       associate messages and responses between a client and a server.
#x       (DEFAULT = 0). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_transaction_id_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_transaction_id 
#x       is incremeneted or decremented when dhcp_transaction_id_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_transaction_id_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_transaction_id. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_transaction_id_step and dhcp_transaction_id_count.
#x          decr - the value is decremented as specified with dhcp_transaction_id_step and dhcp_transaction_id_count.
#x          list - Parameter -dhcp_transaction_id contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_transaction_id_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_transaction_id when dhcp_transaction_id_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_transaction_id_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_transaction_id
#x          1 - enable tracking by dhcp_transaction_id
#x       Category: Layer4-7.DHCP
#x   -dhcp_your_ip_addr
#x       "Your" (client) IP address.
#x       (DEFAULT = 0.0.0.0). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.DHCP
#x   -dhcp_your_ip_addr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the dhcp_your_ip_addr 
#x       is incremeneted or decremented when dhcp_your_ip_addr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.DHCP
#x   -dhcp_your_ip_addr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for dhcp_your_ip_addr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with dhcp_your_ip_addr_step and dhcp_your_ip_addr_count.
#x          decr - the value is decremented as specified with dhcp_your_ip_addr_step and dhcp_your_ip_addr_count.
#x          list - Parameter -dhcp_your_ip_addr contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.DHCP
#x   -dhcp_your_ip_addr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify dhcp_your_ip_addr when dhcp_your_ip_addr_mode is incr 
#x       or decr.
#x       Category: Layer4-7.DHCP
#x   -dhcp_your_ip_addr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by dhcp_your_ip_addr
#x          1 - enable tracking by dhcp_your_ip_addr
#x       Category: Layer4-7.DHCP
#x   -discard_eligible
#x       Set Discard Eligibility bit.
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.Frame Relay
#x   -dlci_core_enable
#x       available for 3 and 4-byte address, when D/C is checked. When the D/C 
#x       bit is turned on, the high six bits of the lowest byte in the Address 
#x       represent DL-Core value. They are not part of DLCI value.
#x       Valid only for traffic_generator ixos. 
#x       Category: Layer2.Frame Relay
#x   -dlci_core_value
#x       available for 3 and 4-byte address, when D/C is checked. When the D/C 
#x       bit is turned on, the high six bits of the lowest byte in the Address 
#x       represent DL-Core value. They are not part of DLCI value. 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.Frame Relay
#x   -dlci_count_mode
#x       Count mode of dlci_value. 
#x       Valid for traffic_generator ixos and ixnetwork. 
#x       When using the traffic_generator ixnetwork, it can take only take the 
#x       'fixed' or 'increment' values and can be used only for L2VPN traffic, but is not supported in this release.
#x       This option is not supported for traffic_generator ixnetwork in this release.
#x       Category: Layer4-7.Frame Relay
#x   -dlci_extended_address0
#x       Address Field Extension 0 - available for 2, 3, and 4-byte addresses.
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.Frame Relay
#x   -dlci_extended_address1
#x       Address Field Extension 1 - available for 2, 3, and 4-byte addresses.
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.Frame Relay
#x   -dlci_extended_address2
#x       Address Field Extension 2 - available for 2, 3, and 4-byte addresses.
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.Frame Relay
#x   -dlci_extended_address3
#x       Address Field Extension 3 - available for 2, 3, and 4-byte addresses.
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.Frame Relay
#x   -dlci_mask_select
#x       This option is used to select which bits from dlci_mask_value mask will
#x       be applied to the DLCI value.
#x         Example:
#x           mask value   0x00E4 
#x           mask select  0x00F3 
#x           mask to be applied  XXXXXXXX1110XX00
#x          X means that the mask will not be applied for those bits. 
#x       (DEFAULT = 0x0000)
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.Frame Relay
#x   -dlci_mask_value
#x       This is the mask that will be applied to the DLCI value. Only parts of 
#x       this mask will be applied to the DLCI value. Option dlci_mask_select 
#x       will specify which parts of the dlci_mask_value will be applied to the 
#x       DLCI value. 
#x       (DEFAULT = 0x0000)
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.Frame Relay
#x   -dlci_repeat_count
#x       Repeat count for dlci_value. Depending on the 
#x       traffic_generator value, this option has different 
#x       value ranges:
#x       ixos:      0-65535 range.
#x       ixnetwork (not supported in this release): 0-4294967295 range.
#x       Valid only for traffic_generator ixos and ixnetwork.
#x       When traffic_generator is ixnetwork, the option can only be used for 
#x       L2VPN traffic, but is not supported in this release.
#x       Category: Layer4-7.Frame Relay
#x   -dlci_size
#x       The size of the Q.922 frame relay address in bytes. 
#x       Choose one of: 2,3,4
#x       Valid only for traffic_generator ixos.
#x       (DEFAULT = 2)
#x       Category: Layer4-7.Frame Relay
#x   -dlci_value
#x       Data Link Connection Identifier value. Depending on the 
#x       traffic_generator value, this option has different 
#x       value ranges. Valid choices are:
#x       ixos - Valid range is 0-65535
#x       ixnetwork/ixnetwork_540 - Valid range is 0-4294967295. 
#x                                 The option can only be used for L2VPN traffic.
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: Layer4-7.Frame Relay
#x   -duration
#x       This parameter is available with
#x       traffic_generator ixnetwork_540 - The parameter should be used only 
#x       when tx_mode has been configured as interleaved. Along with this 
#x       parameter you can also set tx_delay and tx_delay_unit. You can also 
#x       use ::ixia::traffic_control to set the duration for all traffic items. 
#x       The parameter transmit_mode should not be specified along with duration 
#x       parameter (duration parameter implies fixed duration traffic mode).
#x       Valid for traffic_generator ixnetwork_540.
#x       Category: Layer4-7.Frame Relay
#x   -dynamic_update_fields
#x       The dynamic updated fields for the traffic item. Valid choices are: 
#x       ppp - enables dynamic update of PPP header fields for the respective traffic item
#x		 ppp_dst - enables destination dynamic update of PPP header fields for the respective traffic item
#x       dhcp4 - enables dynamic update of IPv4 header fields for the respective traffic item
#x       dhcp4_dst - enables destination dynamic update of IPv4 header fields for the respective traffic item
#x       dhcp6 - enables dynamic update of IPv6 header fields for the respective traffic item
#x       dhcp6_dst - enables destination dynamic update of IPv6 header fields for the respective traffic item
#x       mpls_label_value - enables dynamic update of MPLS label values for the respective 
#x                          traffic item. This is the same functionality provided by 
#x                          parameter enable_dynamic_mpls_labels. 
#x       Adding dynamic_update_field parameter when creating/modifying a traffic item the allows 
#x       IxNetwork to update the corresponding traffic packet fields on 
#x       the fly with the information learned from protocols. 
#x       This parameter can be provided with ppp value, mpls_label_value value or both {ppp mpls_label_value} as a list.
#x       If this parameter is provided with mpls_label_value only, the 
#x       session aware traffic fields will be automatically unset.
#x       Valid for traffic_generator ixnetwork_540.
#x       Category: General.Protocol Behaviour
#x   -egress_custom_offset
#x       Can be a list of positive integer values, or 'NA' strings in case it is not defined
#x       for the corresponding -egress_tracking element. Valid only for traffic_generator ixnetwork/ixnetwork_540 
#x       and if the corresponding -egress_tracking element is set to 'custom'. 
#x       Configure the offset in bits from the beginning of the packet.
#x       (DEFAULT = 0)
#x       Category: General.Tracking
#x   -egress_custom_width
#x       Can be a list of numbers, or 'NA' string in case it is not defined for the corresponding 
#x       -egress_tracking element. Valid only for traffic_generator ixnework/ixnetwork_540 
#x       and if the corresponding -egress_tracking element is set to 'custom'. The maximum number that can be set 
#x       depends on the card type that is used. If you specify a higher number than supported, IxNetwork will set 
#x       the value to the highest number supported. 
#x       Configure the number of bits that will be tracked on the egress side of the traffic.
#x       (DEFAULT = 0)
#x       Category: General.Tracking
#x   -egress_custom_field_offset
#x       Can be a list of egress tracking field offsets, or 'NA' strings in case it is not defined 
#x       for the corresponding -egress_tracking element. Valid only for traffic_generator ixnetwork/ixnetwork_540 
#x       and if the corresponding -egress_tracking element is set to 'custom_by_field'.
#x       The entire list of available egress tracking field offsets for a traffic item can be obtained by calling the 
#x       traffic_config procedure with mode 'get_available_egress_tracking_field_offset.'
#x       (DEFAULT = 0)
#x       Category: General.Tracking
#x   -egress_tracking
#x       Configures one or multiple egress tracking items. Egress tracking cannot be configured if no 
#x       tracking was configured with -track_by parameter.
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540. Can be a list of one or multiple elements.
#x       (DEFAULT = none) Valid choices are:
#x          none (default) - Disable egress tracking.
#x          dscp - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined IPv4 DSCP (6 bits) offset.
#x          ipv6TC - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined IPv6 Traffic Class (8 bits) offset.
#x          mplsExp - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined MPLS Exp (3 bits) offset.
#x          custom - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured manually with the parameters -egress_custom_offset and 
#x              egress_custom_width.
#x          custom_by_field - Enable egress tracking on this traffic item. The egress tracking offset will
#x              be configured manually with the parameter -egress_custom_field_offset.
#x          outer_vlan_priority - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Outer VLAN Priority (3 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          outer_vlan_id_4 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Outer VLAN ID (4 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          outer_vlan_id_6 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Outer VLAN ID (6 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          outer_vlan_id_8 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Outer VLAN ID (8 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          outer_vlan_id_10 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Outer VLAN ID (10 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          outer_vlan_id_12 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Outer VLAN ID (12 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          inner_vlan_priority - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Inner VLAN Priority (3 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          inner_vlan_id_4 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Inner VLAN ID (4 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          inner_vlan_id_6 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Inner VLAN ID (6 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          inner_vlan_id_8 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Inner VLAN ID (8 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          inner_vlan_id_10 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Inner VLAN ID (10 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          inner_vlan_id_12 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined Inner VLAN ID (12 bits) offset. 
#x              This choice is supported only on Ethernet load modules.
#x          tos_precedence - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined IPv4 TOS Precedence (3 bits) offset.
#x          ipv6TC_bits_0_2 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined IPv6 Traffic Class Bits 0-2 (3 bits) offset.
#x          ipv6TC_bits_0_5 - Enable egress tracking on this traffic item. The egress tracking offset will 
#x              be configured to the predefined IPv6 Traffic Class Bits 0-5 (6 bits) offset.
#x          vnTag_direction_bit - Enable egress tracking on this traffic item. The egress tracking offset will
#x              be configured to the predefined VNTag Direction Bit (1 bit) offset.
#x          vnTag_pointer_bit - Enable egress tracking on this traffic item. The egress tracking offset will
#x              be configured to the predefined VNTag Pointer Bit (1 bit) offset.
#x          vnTag_looped_bit - Enable egress tracking on this traffic item. The egress tracking offset will
#x              be configured to the predefined VNTag Looped Bit (1 bit) offset.
#x       Category: General.Tracking
#x   -egress_tracking_encap
#x       Configures the encapsulations used for the egress_tracking elements.
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540 and egress_tracking not void.
#x       For each card type there is a default value defined:
#x          - if the card is ATM the default is 'LLCRoutedCLIP'
#x          - if the card is POS the default is 'pos_hdlc'
#x          - otherwise, the default value is 'ethernet'
#x       It can be a list of one or more of the following valid options:
#x          custom
#x          ethernet
#x          LLCRoutedCLIP
#x          LLCPPPoA
#x          LLCBridgedEthernetFCS
#x          LLCBridgedEthernetNoFCS
#x          VccMuxPPPoA
#x          VccMuxIPV4Routed
#x          VccMuxBridgedEthernetFCS
#x          VccMuxBridgedEthernetNoFCS
#x          pos_ppp
#x          pos_hdlc
#x          frame_relay1490
#x          frame_relay2427
#x          frame_relay_cisco
#x       (DEFAULT = ethernet)
#x       Category: General.Tracking
#x   -emulation_dst_vlan_protocol_tag_id
#x       The protocol ID field of the VLAN tag. It can be any 4 digit hex number. 
#x       Example: 8100, 9100, 9200. 
#x       For stacked VLAN (QinQ) this parameter will be provided as a list 
#x       of values, each of them representing the protocol ID field of the 
#x       VLAN tag
#x       Example: {8100 9100 9200 9100}
#x       This parameter should be used when configuring ixos traffic over PPP sessions. 
#x       (DEFAULT = 8100). 
#x       Valid only for traffic_generator ixos and if emulation_dst_handle is present.
#x       Category: General.Endpoint Data
#x   -emulation_override_ppp_ip_addr
#x       This parameter should be used when configuring ixos traffic over PPP 
#x       sessions in order to override the IP address distributed through PPP with 
#x       the address provided through ip_src_addr. 
#x       Valid only for traffic_generator ixos/ixnetwork_540 and if emulation_src_handle or 
#x       emulation_dst_handle is present. With traffic_generator ixnetwork_540 any value (except 
#x       none) will have the same efect as '-convert_to_raw' and any field from the packet 
#x       can be modified. 
#x       Valid choices are:
#x       upstream - when setting this option, the PPP IP address will be 
#x                  overridden in the stream going from the access port 
#x                  (where the PPP emulation is configured) to the network port 
#x                  (the IP port)
#x       downstream - when setting this option, the PPP IP address will be 
#x                    overridden in the stream going from the network port 
#x                    (the IP port) to the access port (where the PPP 
#x                    emulation is configured)
#x       both - when setting this option, the PPP IP address will be 
#x                        overridden at both ends if the traffic is 
#x                        bidirectional, or at the corresponding end if the 
#x                        traffic is unidirectional.
#x       none (default) - the PPP IP address will be used when configuring the streams.
#x       Category: General.Endpoint Data
#x   -emulation_multicast_dst_handle
#x       A list of multicast destination handles in the address/step/count format or one of the 
#x       following special keywords: all_multicast_ranges (this mean all multicast ranges will 
#x       be used as a destination), none or an empty list (this means no multicast destination 
#x       will be used for the current endpoint). The number of elements in this list needs to 
#x       match the number of endpoints. Sample value for an ipv4 traffic item with 3 endpoints: 
#x       [list [list 224.0.0.0/0.0.0.1/1 225.0.0.0/0.0.0.1/1] none all_multicast_ranges].
#x       In the above example endpointset 1 has 2 multicast destinations: 224.0.0.0/0.0.0.1/1  
#x       and 225.0.0.0/0.0.0.1/1, endpointset 2 has no multicast destination and endpointset3
#x       has all the multicast destinations available in the IGMP host protocol.
#x       Sample value for an ipv6 traffic item with 2 endpoints: 
#x       [list 226:0:0:0:0:0:0:0/0:0:0:0:0:0:1:0/1 224:0:0:0:0:0:0:0/0:0:0:0:0:0:1:0/1].
#x       In the above example each endpoint has only one multicast destination.
#x       Valid for traffic_generator ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -emulation_multicast_dst_handle_type
#x       A list of multicast destination handles types. Valid values can be: none, igmp, mld. 
#x       The number of elements in this list needs to match the number of endpoints and 
#x       emulation_multicast_dst_handle.  When emulation_multicast_dst_handle is 
#x       all_multicast_ranges the type is ignored.
#x       Valid for traffic_generator ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -emulation_src_vlan_protocol_tag_id
#x       The protocol ID field of the VLAN tag. It can be any 4 digit hex number. 
#x       Example: 8100, 9100, 9200. 
#x       For stacked VLAN (QinQ) this parameter will be provided as a list 
#x       of values, each of them representing the protocol ID field of the 
#x       VLAN tag
#x       Example: {8100 9100 9200 9100}
#x       This parameter should be used when configuring ixos traffic over PPP sessions. 
#x       (DEFAULT = 8100). 
#x       Valid only for traffic_generator ixos and if emulation_src_handle is present.
#x       Category: General.Endpoint Data
#x   -emulation_scalable_dst_handle
#x       An array which contains lists of handles used to retrieve information for L3 
#x       dst addresses, indexed by the endpointset to which they correspond. 
#x       This should be a handle that was obtained after configuring protocols with 
#x       commands from the ::ixiangpf:: namespace. 
#x       This parameter can be used in conjunction with emulation_dst_handle. 
#x       In the case where NGPF handles are specified in the emulation_dst_handle 
#x       parameter (legacy backwards compatibility scenario), this parameter should 
#x       not be used. 
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540. 
#x       Category: General.Endpoint Data
#x   -emulation_scalable_dst_port_start
#x       An array which contains lists of numbers that encode the index of the first
#x       port on which the corresponding endpointset will be configured.
#x       This parameter will be ignored if no corresponding value is specified for 
#x       emulation_scalable_dst_handle.
#x       (DEFAULT = 1)
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -emulation_scalable_dst_port_count
#x       An array which contains lists of numbers that encode the number of ports on
#x       which the corresponding endpointset will be configured.
#x       This parameter will be ignored if no corresponding value is specified for 
#x       emulation_scalable_dst_handle.
#x       (DEFAULT = 1)
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -emulation_scalable_dst_intf_start
#x       An array which contains lists of numbers that encode the index of the first
#x       interface on which the corresponding endpointset will be configured.
#x       This parameter will be ignored if no corresponding value is specified for 
#x       emulation_scalable_dst_handle.
#x       (DEFAULT = 1)
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -emulation_scalable_dst_intf_count
#x       An array which contains lists of numbers that encode the number of interfaces
#x       on which the corresponding endpointset will be configured.
#x       This parameter will be ignored if no corresponding value is specified for 
#x       emulation_scalable_dst_handle.
#x       (DEFAULT = 1)
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -emulation_scalable_src_handle
#x       An array which contains lists of handles used to retrieve information for L3 
#x       dst addresses, indexed by the endpointset to which they correspond. 
#x       This should be a handle that was obtained after configuring protocols with 
#x       commands from the ::ixiangpf:: namespace. 
#x       This parameter can be used in conjunction with emulation_src_handle. 
#x       In the case where NGPF handles are specified in the emulation_src_handle 
#x       parameter (legacy backwards compatibility scenario), this parameter should 
#x       not be used. 
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540. 
#x       Category: General.Endpoint Data
#x   -emulation_scalable_src_port_start
#x       An array which contains lists of numbers that encode the index of the first
#x       port on which the corresponding endpointset will be configured.
#x       This parameter will be ignored if no corresponding value is specified for 
#x       emulation_scalable_src_handle.
#x       (DEFAULT = 1)
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -emulation_scalable_src_port_count
#x       An array which contains lists of numbers that encode the number of ports on
#x       which the corresponding endpointset will be configured.
#x       This parameter will be ignored if no corresponding value is specified for 
#x       emulation_scalable_src_handle.
#x       (DEFAULT = 1)
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -emulation_scalable_src_intf_start
#x       An array which contains lists of numbers that encode the index of the first
#x       interface on which the corresponding endpointset will be configured.
#x       This parameter will be ignored if no corresponding value is specified for 
#x       emulation_scalable_src_handle.
#x       (DEFAULT = 1)
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -emulation_scalable_src_intf_count
#x       An array which contains lists of numbers that encode the number of interfaces
#x       on which the corresponding endpointset will be configured.
#x       This parameter will be ignored if no corresponding value is specified for 
#x       emulation_scalable_src_handle.
#x       (DEFAULT = 1)
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -enable_auto_detect_instrumentation
#x       Enables/disable setup of PGID/SequenceCkecking/DataIntegrity without 
#x       having to specify the offset for the signatures, but just the 
#x       signature values.
#x       With this option enabled the packet size will be increased as follows:
#x       12 bytes - signature (mandatory)
#x       4 bytes  - pgid_value(mandatory) and data integrity(optional)
#x       4 bytes  - sequencing(optional)
#x       2 bytes  - data integrity checksum(optional)
#x       6 bytes  - timestamp(mandatory)
#x       This is a total of 28 bytes if data integrity and sequence checking 
#x       are enabled. 
#x       By default, all the following parameters 
#x       will be enabled, when enable_auto_detect_instrumentation is enabled:
#x       enable_time_stamp, enable_pgid, sequence_checking, enable_data_integrity.
#x       Starting with IxOS 5.10, timestamp, PGID, Sequencing, Data Integrity, 
#x       are all optional, and can be disabled by using their corresponding 
#x       parameters for enable/disable. 
#x       Valid only for traffic_generator ixos.
#x       Category: General.Instrumentation/Flow Group
#x   -enable_ce_to_pe_traffic 
#x       Enables sending traffic from PE to CE in MPLS setups.
#x       Valid only for traffic_generator ixnetwork.
#x       Category: Layer4-7.Frame Relay
#x   -enable_data_integrity
#x       Whether data integrity checking is enabled. 
#x       Valid only for traffic_generator ixos/ixnetwork_540. With traffic_generator 
#x       ixnetwork_540 this parameter applies globally, not per traffic_item. 
#x       Valid choices are:
#x       0 - Disabled.
#x       1 - Enabled.
#x       Category: General.Instrumentation/Flow Group
#x   -enable_dynamic_mpls_labels
#x       Whether dynamic MPLS label binding is enabled or not. 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x       0 - Disabled.
#x       1 - Enabled. This is the same functionality provided by 
#x                    parameter -dynamic_update_field with the following value: mpls_label_value.
#x       Category: General.Protocol Behaviour
#x   -enable_override_value
#x       This argument can be used to specify if the custom-defined values will 
#x       be added to the packets for tracking on the receiving side.
#x       Valid only for traffic_generator ixnetwork and with the 
#x       assured_forwarding_phb, class_selector_phb, default_phb, 
#x       expedited_forwarding_phb, tos, raw_priority or inner_vlan choices of 
#x       the -track_by argument.
#x       Category: General.Tracking
#x   -enable_pgid
#x       Enables or disables packet groups IDs in the stream.  
#x       Valid only for traffic_generator ixos.  The packet group offset will be 
#x       calculated automatically.
#x       DEFAULT = 1
#x       Category: General.Instrumentation/Flow Group
#x   -enable_test_objective
#x       This argument can be used to enable the overriding of the default 
#x       objective value of the application traffic profile.
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.Application Traffic
#x   -enable_time_stamp
#x       Whether time stamp insertion is enabled. 
#x       Valid only for traffic_generator ixos. Valid choices are:
#x       0 - Disabled.
#x       1 - Enabled. (default)
#x       Category: General.Instrumentation/Flow Group
#x   -enable_udf1
#x       If this option is set to true (1), then the UDF 1 counter will be 
#x       inserted into the frame. If traffic_generator is ixnetwork_540, circuit_type 
#x       must be configured to 'quick_flows'.
#x       (DEFAULT = 0) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -enable_udf2
#x       See description for this item as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -enable_udf3
#x       See description for this item as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -enable_udf4
#x       See description for this item as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -enable_udf5
#x       See description for this item as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -endpointset_count
#x       The number of endpointset to be created. The parameters -emulation_src_handle and -emulation_dst_handle 
#x       should be provided with a number of list elements equal to endpointset_count.
#x       Valid only for traffic_generator ixnetwork_540.
#x       (DEFAULT = 1)
#x       Category: General.Endpoint Data
#x   -enforce_min_gap
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. 
#x       This argument can be used to specify the smallest inter-packet gap 
#x       that will be allowed.
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -ethernet_type
#x       For ethernet ports only, the ethernet encapsulation type. Valid only for traffic_generator ixos. Valid 
#x       choices are:
#x       ethernetII   - Ethernet encapsulation at EthernetII.
#x       ieee8023snap - Ethernet encapsulation at ieee8023snap.
#x       ieee8023     - Ethernet encapsulation at ieee8023.
#x       ieee8022     - Ethernet encapsulation at ieee8022.
#x       Category: Layer2.Ethernet
#x   -ethernet_value
#x       For ethernet ports with the ethernet encapsulation type ethernetII, a 
#x       hex value can be specified as the Ethernet Type value. 
#x       Valid only for traffic_generator ixos and ixnetwork_540.
#x       Category: Layer2.Ethernet
#x   -ethernet_value_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ethernet_value 
#x       is incremeneted or decremented when ethernet_value_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -ethernet_value_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures  
#x       the behavior for ethernet_value. Valid choices are: 
#x          fixed (default) - the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ethernet_value_step and ethernet_value_count.
#x          decr - the value is decremented as specified with ethernet_value_step and ethernet_value_count.
#x          list - Parameter -ethernet_value contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.Ethernet
#x   -ethernet_value_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Hex step value used to modify ethernet_value when ethernet_value_mode is incr 
#x       or decr.
#x       (DEFAULT = 0x01)
#x       Category: Layer2.Ethernet
#x   -ethernet_value_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 (default) - disable tracking by ethernet_value
#x          1 - enable tracking by ethernet_value
#x       Category: Layer2.Ethernet
#x   -fcs_type
#x       The FCS error to be inserted in the frame. 
#x       Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540 and when -fcs is 1. 
#x       Valid choices with traffic_generator ixos are:
#x          alignment - An alignment error to be inserted in the frame (only valid for 10/100).
#x          dribble   - A dribble error to be inserted in the frame.
#x          bad_CRC   - A bad FCS error to be inserted in the frame.
#x          no_CRC    - No FCS error to be inserted in the frame.
#x       Valid choices with traffic_generator ixnetwork are:
#x          bad_CRC   - A bad FCS error to be inserted in the frame.
#x          no_CRC    - No FCS error to be inserted in the frame.
#x       Valid choices with traffic_generator ixnetwork_540 are:
#x          bad_CRC   - A bad FCS error to be inserted in the frame.
#x       Category: General.Instrumentation/Flow Group
#x   -fecn
#x       Forward Explicit Congestion Notification.
#x       Valid only for traffic_generator ixos.
#x       Category: Layer2.Frame Relay
#x   -field_activeFieldChoice
#x       Determines the involvement of the field in the current active configuration. 
#x       It is considered only if fieldChoice is true and can be used to pick and 
#x       choose certain parameters, for example between diff services and ToS.
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_auto
#x       Determines the automatic population of the field when chaining with other fields 
#x       where possible.
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_countValue
#x       Sets the number of steps for the incremental value types.
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_fieldValue
#x       The actual value of the field (which depends on the value type and the 
#x       indicated value).
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_fullMesh
#x       Describes the behavior of the field in relation with other fields giving 
#x       all combinations of values.
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_handle
#x       Provides the field name (stack object fields) on which specific operations are made. It is obtained 
#x       when mode is "get_available_fields". 
#x       Valid when mode is "get_field_values", "set_field_values", "add_field_level" or "remove_field_level".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_linked
#x       This parameter is used as the source field linked. In order for the stack provided 
#x       to this parameter to be valid for linking, you must set increment/decrement/list mode 
#x       for this field. Valid only for IxNetwork greater than 7.0. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_linked_to
#x       This parameter is used as the destination field linked. In order for the stack provided 
#x       to this parameter to be valid for linking, you must set increment/decrement/list mode 
#x       for this field. Valid only for IxNetwork greater than 7.0. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_optionalEnabled
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_singleValue
#x       Controls the value of the field when field_valueType is "singleValue".
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_startValue
#x       Controls the starting value of the field when field_valueType is
#x       "increment" or "decrement".
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_stepValue
#x       Sets the step applied to field_startValue for incremental value types.
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_trackingEnabled
#x       Controls the tracking option for this item.
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_valueList
#x       Sets multiple values for the current field when field_valueType is "valueList".
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -field_valueType
#x       Indicates the type of this field. This parameter determines what value 
#x       parameter will give the actual field value.
#x       Field attribute available for set when mode is "set_field_values".
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Packet/QoS.Per Protocol Stack Field Settings
#x   -frame_rate_distribution_port
#x       Configure how frame rate will be distributed. 
#x       Valid only for traffic_generator ixnetwork_540. Valid choices are:
#x          apply_to_all - Apply rate to all ports.
#x          split_evenly - (DEFAULT) Split rate evenly among ports.
#x       Category: Stream Control and Data.Rate Control
#x   -frame_rate_distribution_stream
#x       Configure how frame rate will be distributed. 
#x       Valid only for traffic_generator ixnetwork_540. Valid choices are:
#x          apply_to_all - Apply rate to all flow groups.
#x          split_evenly - (DEFAULT) Split rate evenly among flow groups.
#x       Category: Stream Control and Data.Rate Control
#x   -frame_sequencing
#x       Inserts a sequence signature into the packet. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: General.Instrumentation/Flow Group
#x   -frame_sequencing_mode
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid options are:
#x           rx_switched_path
#x           rx_switched_path_fixed
#x           rx_threshold
#x       Category: General.Instrumentation/Flow Group
#x   -frame_sequencing_offset
#x       The offset within the packet of the sequnce number. 
#x       This is valid only when sequence checking is enabled. 
#x       If -enable_auto_detect_instrumentation is 1, will be ignored. 
#x       Valid only for traffic_generator ixos.
#x       Category: General.Instrumentation/Flow Group
#x   -frame_size
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. 
#x       Actual total frame size coming out of the interface on the wire in 
#x       bytes. Valid choices are between 12 and 13312, inclusive. Parameter l3_length 
#x       is ignored if frame_size is present.
#x       (DEFAULT = 64) 
#x       Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Frame Size
#x   -frame_size_distribution
#x       This argument can be used to specify the predefined distribution of 
#x       the frames' length when length_mode = distribution. When IxTclNetwork path is used,this parameter 
#x       is valid only for traffic_generator ixnetwork/ixnetwork_540, mode create/modify, and length_mode distribution. 
#x       When IxTclProtocol path is used, this parameter is valid only when -length_mode is set to distribution. 
#x       Valid choices are:
#x       cisco     - A pre-programmed distribution, according to 
#x                   Cisco standards: 64:7, 594:4, and 1518:1.
#x       imix      - A pre-programmed distribution, according to 
#x                   IMIX standards: 64:7, 570:4, and 1518:1.
#x       quadmodal - A pre-programmed distribution: 
#x                   512:20, 1518:20, and 9000:20.
#x       tolly     - A pre-programmed distribution, according to Tolly testing 
#x                   group standards: 64:55, 78:5, 576:17, and 1518:23.
#x       trimodal  - A pre-programmed distribution: 64:60, 512:20,and 1518:20.
#x       imix_ipsec - A pre-programmed distribution: 90:58, 92:2, 594:23 and 1418:15. 
#x          Valid only for traffic_generator ixnetwork_540.
#x       imix_ipv6 - A pre-programmed distribution: 60:58, 496:2, 594:23 and 1518:15. 
#x          Valid only for traffic_generator ixnetwork_540.
#x       imix_std - A pre-programmed distribution: 58:58, 62:2, 594:23, 1518:15. 
#x          Valid only for traffic_generator ixnetwork_540.Valid only for traffic_generator ixnetwork_540.
#x       imix_tcp - A pre-programmed distribution: 90:58, 92:2, 594:23, 1518:15. 
#x          Valid only for traffic_generator ixnetwork_540.Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Frame Size
#x   -frame_size_gauss
#x       This argument can be used to specify a list of maximum 4 options which 
#x       describe a Quad Gauss distribution. The individual options which 
#x       characterize the Quad Gauss distributions have the following 
#x       structure: <center>:<width_at_half>:<weight>
#x       This argument has meaning only when mode is create/modify and 
#x       length_mode is gass|quad and traffic_generator is ixnetwork/ixnetwork_540.
#x       Valid for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: General.Frame Size
#x   -frame_size_imix
#x       This argument can be used to specify a list of lists, which, each of 
#x       them, describe a weight pair: <weight>:<framesize>.
#x       This argument has meaning only when mode is create/modify and 
#x       length_mode is imix and traffic_generator is ixnetwork/ixnetwork_540.
#x       Valid for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: General.Frame Size
#x   -frame_size_max
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. 
#x       Actual maximum total frame size coming out of the interface on the 
#x       wire in bytes when option "length_mode" is set to random. Valid 
#x       choices are between 12 and 13312. Parameter l3_length_max is ignored if 
#x       this parameter is used.
#x       (DEFAULT = 64) 
#x       Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Frame Size
#x   -frame_size_min
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. 
#x       Actual minimal total frame size coming out of the interface on the 
#x       wire in bytes when option "length_mode" is set to random. Valid 
#x       choices are between 12 and 13312. Parameter l3_length_min is ignored if 
#x       this parameter is used.
#x       (DEFAULT = 64) 
#x       Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Frame Size
#x   -frame_size_step
#x       Actual increment by which the actual total frame size in bytes coming 
#x       out of the interface on the wire will be incremented. Valid choices 
#x       are between 0 and 13292. Parameter l3_length_step is ignored if 
#x       this parameter is used.
#x       (DEFAULT = 64) 
#x       Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Frame Size
#x   -global_dest_mac_retry_count
#x       Configure the number of times to attempt to obtain the destination MAC address. 
#x       This parameter applies globally, not per traffic item. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_dest_mac_retry_delay
#x       The number of seconds to wait between attempts to obtain the 
#x       destination MAC address. This parameter applies globally, not per traffic item. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_enable_dest_mac_retry
#x       Enables the destination MAC address retry function. 
#x       This parameter applies globally, not per traffic item. 
#x       Valid choices are:
#x           0 - disable
#x           1 - enable
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_enable_mac_change_on_fly
#x       When 1, enables IxNetwork’s gratuitous ARP capability and 
#x       IxNetwork listens for gratuitous ARP messages from its neighbors 
#x       This parameter applies globally, not per traffic item. 
#x       Valid choices are:
#x           0 - disable
#x           1 - enable
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_enable_min_frame_size
#x       When this option is enabled, IxNetwork will allow the stream to use smaller packet 
#x       sizes. In the case of IPv4 and Ethernet, 64 bytes will be allowed. This is achieved by 
#x       reducing the size of the instrumentation tag, which will be identified by 
#x       receiving ports. Please note, reducing the size of the instrumentation tag will 
#x       increase the risk of mistaking it for user data at the receiving port. 
#x       This parameter applies globally, not per traffic item. 
#x       Valid choices are:
#x           0 - disable
#x           1 - enable
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_enable_staggered_transmit
#x       If 1, the start of transmit is staggered across ports. A 25-30 ms delay is 
#x       introduced between the time one port begins transmitting and the time 
#x       next port begins transmitting. 
#x       This parameter applies globally, not per traffic item. 
#x       Valid choices are:
#x           0 - disable
#x           1 - enable
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_enable_stream_ordering
#x       When this option is enabled, IxNetwork will allow stream ordering per RFC 2889. 
#x       This parameter applies globally, not per traffic item. 
#x       Valid choices are:
#x           0 - disable
#x           1 - enable
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_large_error_threshhold
#x       The user-configurable threshold value – used to determine error levels for 
#x       outof-sequence, received packets. 
#x       This parameter applies globally, not per traffic item. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_max_traffic_generation_queries
#x       Maximum number of traffic generation queries. 
#x       This parameter applies globally, not per traffic item. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_display_mpls_current_label_value
#x       Enable display MPLS current label value when tracking by MPLS flow descriptor. 
#x       This parameter applies globally, not per traffic item. 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - disable
#x          1 - enable
#x       Category: General.Common
#x   -global_mpls_label_learning_timeout
#x       This parameter controls the timeout in seconds for the MPLS Label learning database 
#x       during traffic generation. It helps to increase the timeout value, so that traffic 
#x       generation does not time out and all packets are generated for this traffic item 
#x       This parameter applies globally, not per traffic item. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_refresh_learned_info_before_apply
#x       This attribute refreshes the learned information from the DUT. 
#x       This parameter applies globally, not per traffic item. 
#x       Valid choices are:
#x          0 - disable
#x          1 - enable
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_stream_control
#x       This parameter applies globally, not per traffic item. 
#x       Valid choices are:
#x          continuous - continuous
#x          iterations - iterations
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_stream_control_iterations
#x       This parameter applies globally, not per traffic item. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_use_tx_rx_sync
#x       Synchronize Tx/Rx traffic ports. Disable this option when using multiple 
#x       chassis without sync cable (including GPS chassis chain). 
#x       This parameter applies globally, not per traffic item. 
#x       Valid choices are:
#x           0 - disable
#x           1 - enable
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -global_wait_time
#x       The time (in seconds) to wait after Stop Transmit before stopping Latency 
#x       Measurement. 
#x       This parameter applies globally, not per traffic item. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -gre_checksum
#x       Specify checksum for the GRE header (only if -l4_protocol is gre). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -gre_checksum_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the gre_checksum 
#x       is incremeneted or decremented when gre_checksum_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_checksum_enable
#x       Enable checksum for the GRE header (only if -l4_protocol is gre). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -gre_checksum_enable_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for gre_checksum_enable. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -gre_checksum_enable contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -gre_checksum_enable_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by gre_checksum_enable
#x          1 - enable tracking by gre_checksum_enable
#x       Category: Layer4-7.GRE
#x   -gre_checksum_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for gre_checksum. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with gre_checksum_step and gre_checksum_count.
#x          decr - the value is decremented as specified with gre_checksum_step and gre_checksum_count.
#x          list - Parameter -gre_checksum contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -gre_checksum_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify gre_checksum when gre_checksum_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_checksum_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by gre_checksum
#x          1 - enable tracking by gre_checksum
#x       Category: Layer4-7.GRE
#x   -gre_key
#x       Specify the key for the GRE header (only if -l4_protocol is gre). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -gre_key_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the gre_key 
#x       is incremeneted or decremented when gre_key_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_key_enable
#x       Enable key for the the GRE header (only if -l4_protocol is gre). 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -gre_key_enable_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for gre_key_enable. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -gre_key_enable contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -gre_key_enable_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by gre_key_enable
#x          1 - enable tracking by gre_key_enable
#x       Category: Layer4-7.GRE
#x   -gre_key_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for gre_key. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with gre_key_step and gre_key_count.
#x          decr - the value is decremented as specified with gre_key_step and gre_key_count.
#x          list - Parameter -gre_key contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -gre_key_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify gre_key when gre_key_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_key_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by gre_key
#x          1 - enable tracking by gre_key
#x       Category: Layer4-7.GRE
#x   -gre_reserved0
#x       Specify first reserved field of the GRE header. 
#x       (only if -l4_protocol is gre) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -gre_reserved0_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the gre_reserved0 
#x       is incremeneted or decremented when gre_reserved0_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_reserved0_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for gre_reserved0. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with gre_reserved0_step and gre_reserved0_count.
#x          decr - the value is decremented as specified with gre_reserved0_step and gre_reserved0_count.
#x          list - Parameter -gre_reserved0 contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -gre_reserved0_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify gre_reserved0 when gre_reserved0_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_reserved0_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by gre_reserved0
#x          1 - enable tracking by gre_reserved0
#x       Category: Layer4-7.GRE
#x   -gre_reserved1
#x       Specify second reserved field of the GRE header. 
#x       (only if -l4_protocol is gre) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -gre_reserved1_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the gre_reserved1 
#x       is incremeneted or decremented when gre_reserved1_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_reserved1_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for gre_reserved1. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with gre_reserved1_step and gre_reserved1_count.
#x          decr - the value is decremented as specified with gre_reserved1_step and gre_reserved1_count.
#x          list - Parameter -gre_reserved1 contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -gre_reserved1_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify gre_reserved1 when gre_reserved1_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_reserved1_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by gre_reserved1
#x          1 - enable tracking by gre_reserved1
#x       Category: Layer4-7.GRE
#x   -gre_seq_enable
#x       Enable sequence checking for the the GRE header. 
#x       (only if -l4_protocol is gre) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -gre_seq_enable_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for gre_seq_enable. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -gre_seq_enable contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -gre_seq_enable_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by gre_seq_enable
#x          1 - enable tracking by gre_seq_enable
#x       Category: Layer4-7.GRE
#x   -gre_seq_number
#x       Specify the sequence number for the GRE header. 
#x       (only if -l4_protocol is gre) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -gre_seq_number_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the gre_seq_number 
#x       is incremeneted or decremented when gre_seq_number_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_seq_number_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for gre_seq_number. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with gre_seq_number_step and gre_seq_number_count.
#x          decr - the value is decremented as specified with gre_seq_number_step and gre_seq_number_count.
#x          list - Parameter -gre_seq_number contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -gre_seq_number_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify gre_seq_number when gre_seq_number_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_seq_number_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by gre_seq_number
#x          1 - enable tracking by gre_seq_number
#x       Category: Layer4-7.GRE
#x   -gre_valid_checksum_enable
#x       Enable valid checksum for the GRE header (only if -l4_protocol is gre). 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer4-7.GRE
#x   -gre_version
#x       Specify version for GRE header. 
#x       (only if -l4_protocol is gre) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -gre_version_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the gre_version 
#x       is incremeneted or decremented when gre_version_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_version_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for gre_version. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with gre_version_step and gre_version_count.
#x          decr - the value is decremented as specified with gre_version_step and gre_version_count.
#x          list - Parameter -gre_version contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -gre_version_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify gre_version when gre_version_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -gre_version_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by gre_version
#x          1 - enable tracking by gre_version
#x       Category: Layer4-7.GRE
#x   -header_handle
#x       The header handle for which all the available fields will be analyzed. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -hosts_per_net
#x       This argument specifies the number of hosts from each route for 
#x       whom traffic will be generated. 
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: General.Tracking
#x   -icmp_checksum_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_checksum 
#x       is incremeneted or decremented when icmp_checksum_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_checksum_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_checksum. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_checksum_step and icmp_checksum_count.
#x          decr - the value is decremented as specified with icmp_checksum_step and icmp_checksum_count.
#x          list - Parameter -icmp_checksum contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_checksum_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_checksum when icmp_checksum_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_checksum_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_checksum
#x          1 - enable tracking by icmp_checksum
#x       Category: Layer4-7.ICMP
#x   -icmp_code_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_code 
#x       is incremeneted or decremented when icmp_code_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_code_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_code. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_code_step and icmp_code_count.
#x          decr - the value is decremented as specified with icmp_code_step and icmp_code_count.
#x          list - Parameter -icmp_code contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_code_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_code when icmp_code_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_code_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_code
#x          1 - enable tracking by icmp_code
#x       Category: Layer4-7.ICMP
#x   -icmp_id_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_id 
#x       is incremeneted or decremented when icmp_id_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_id_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_id. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_id_step and icmp_id_count.
#x          decr - the value is decremented as specified with icmp_id_step and icmp_id_count.
#x          list - Parameter -icmp_id contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_id_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_id when icmp_id_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_id_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_id
#x          1 - enable tracking by icmp_id
#x       Category: Layer4-7.ICMP
#x   -icmp_max_response_delay_ms
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure Maximum response delay (milliseconds) field for 'Multicast Listener Query Message Version 1' (-icmp_type 130), 
#x       'Multicast Listener Report Message Version 1' (-icmp_type 131), 'Multicast Listener Done Message' (-icmp_type 132) or 
#x       'Multicast Listener Query Message Version 2' (-icmp_type 130) message types.
#x       Category: Layer4-7.ICMP
#x   -icmp_max_response_delay_ms_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_max_response_delay_ms 
#x       is incremeneted or decremented when icmp_max_response_delay_ms_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_max_response_delay_ms_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_max_response_delay_ms. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_max_response_delay_ms_step and icmp_max_response_delay_ms_count.
#x          decr - the value is decremented as specified with icmp_max_response_delay_ms_step and icmp_max_response_delay_ms_count.
#x          list - Parameter -icmp_max_response_delay_ms contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_max_response_delay_ms_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_max_response_delay_ms when icmp_max_response_delay_ms_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_max_response_delay_ms_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_max_response_delay_ms
#x          1 - enable tracking by icmp_max_response_delay_ms
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_interval_code
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure 1 byte HEX "Querier's Query Interval Code" field  for 'Multicast Listener Query Message Version 2' 
#x       (-icmp_type 130) message type.
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_interval_code_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_mc_query_v2_interval_code 
#x       is incremeneted or decremented when icmp_mc_query_v2_interval_code_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_interval_code_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_mc_query_v2_interval_code. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_mc_query_v2_interval_code_step and icmp_mc_query_v2_interval_code_count.
#x          decr - the value is decremented as specified with icmp_mc_query_v2_interval_code_step and icmp_mc_query_v2_interval_code_count.
#x          list - Parameter -icmp_mc_query_v2_interval_code contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_interval_code_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_mc_query_v2_interval_code when icmp_mc_query_v2_interval_code_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_interval_code_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_mc_query_v2_interval_code
#x          1 - enable tracking by icmp_mc_query_v2_interval_code
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_robustness_var
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure "Querier's Robustness Variable" field (0-7) for 'Multicast Listener Query Message Version 2' 
#x       (-icmp_type 130) message type.
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_robustness_var_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_mc_query_v2_robustness_var 
#x       is incremeneted or decremented when icmp_mc_query_v2_robustness_var_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_robustness_var_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_mc_query_v2_robustness_var. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_mc_query_v2_robustness_var_step and icmp_mc_query_v2_robustness_var_count.
#x          decr - the value is decremented as specified with icmp_mc_query_v2_robustness_var_step and icmp_mc_query_v2_robustness_var_count.
#x          list - Parameter -icmp_mc_query_v2_robustness_var contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_robustness_var_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_mc_query_v2_robustness_var when icmp_mc_query_v2_robustness_var_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_robustness_var_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_mc_query_v2_robustness_var
#x          1 - enable tracking by icmp_mc_query_v2_robustness_var
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_s_flag
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure 'Supress router-side processing' flag for 'Multicast Listener Query Message Version 2' 
#x       (-icmp_type 130) message type. Valid choices are:
#x          0 - Supress router-side processing
#x          1 - Do not suppress router-side processing
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_s_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_mc_query_v2_s_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -icmp_mc_query_v2_s_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_mc_query_v2_s_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_mc_query_v2_s_flag
#x          1 - enable tracking by icmp_mc_query_v2_s_flag
#x       Category: Layer4-7.ICMP
#x   -icmp_mobile_pam_m_bit
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure the "M Bit" bit for 'Mobile Prefix Advertisement Message' (-icmp_type 147) message type.
#x       Valid choices are:
#x          0 - bit is 0
#x          1 - bit is 1
#x       Category: Layer4-7.ICMP
#x   -icmp_mobile_pam_m_bit_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_mobile_pam_m_bit. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -icmp_mobile_pam_m_bit contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_mobile_pam_m_bit_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_mobile_pam_m_bit
#x          1 - enable tracking by icmp_mobile_pam_m_bit
#x       Category: Layer4-7.ICMP
#x   -icmp_mobile_pam_o_bit
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure the "O Bit" bit for 'Mobile Prefix Advertisement Message' (-icmp_type 147) message type.
#x       Valid choices are:
#x          0 - bit is 0
#x          1 - bit is 1
#x       Category: Layer4-7.ICMP
#x   -icmp_mobile_pam_o_bit_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_mobile_pam_o_bit. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -icmp_mobile_pam_o_bit contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_mobile_pam_o_bit_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_mobile_pam_o_bit
#x          1 - enable tracking by icmp_mobile_pam_o_bit
#x       Category: Layer4-7.ICMP
#x   -icmp_multicast_address
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure IPv6 Multicast address field for 'Multicast Listener Query Message Version 1' (-icmp_type 130), 
#x       'Multicast Listener Report Message Version 1' (-icmp_type 131), 'Multicast Listener Done Message' (-icmp_type 132) or 
#x       'Multicast Listener Query Message Version 2' (-icmp_type 130) message types.
#x       Category: Layer4-7.ICMP
#x   -icmp_multicast_address_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_multicast_address 
#x       is incremeneted or decremented when icmp_multicast_address_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_multicast_address_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_multicast_address. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_multicast_address_step and icmp_multicast_address_count.
#x          decr - the value is decremented as specified with icmp_multicast_address_step and icmp_multicast_address_count.
#x          list - Parameter -icmp_multicast_address contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_multicast_address_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_multicast_address when icmp_multicast_address_mode is incr 
#x       or decr.
#x       (DEFAULT = 0::0)
#x       Category: Layer4-7.ICMP
#x   -icmp_multicast_address_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_multicast_address
#x          1 - enable tracking by icmp_multicast_address
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_nam_o_flag
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure the "Override existing cache entry" flag for 'Neighbor Advertisement' (-icmp_type 136) message type.
#x       Valid choices are:
#x          0 - disable O-Flag
#x          1 - enable O-Flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_nam_o_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_nam_o_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -icmp_ndp_nam_o_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_nam_o_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - disable tracking by icmp_ndp_nam_o_flag
#x          1 - enable tracking by icmp_ndp_nam_o_flag
#x       (DEFAULT = 0)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_nam_r_flag
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure the "Router" flag for 'Neighbor Advertisement' (-icmp_type 136) message type.
#x       Valid choices are:
#x          0 - disable Router flag
#x          1 - enable Router flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_nam_r_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_nam_r_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -icmp_ndp_nam_r_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_nam_r_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_ndp_nam_r_flag
#x          1 - enable tracking by icmp_ndp_nam_r_flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_nam_s_flag
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure the "Neighbor Solicitation" flag for 'Neighbor Advertisement' (-icmp_type 136) message type.
#x       Valid choices are:
#x          0 - disable Neighbor Solicitation flag
#x          1 - enable Neighbor Solicitation flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_nam_s_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_nam_s_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -icmp_ndp_nam_s_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_nam_s_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_ndp_nam_s_flag
#x          1 - enable tracking by icmp_ndp_nam_s_flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_h_flag
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure "Home Agent" flag for 'NDP Router Advertisement Message' 
#x       (-icmp_type 134) message type. Valid choices are:
#x          0 - disable H-Flag
#x          1 - enable H-Flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_h_flag_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_ram_h_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -icmp_ndp_ram_h_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_h_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_ndp_ram_h_flag
#x          1 - enable tracking by icmp_ndp_ram_h_flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_hop_limit
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure "Current hop limit" field (0-255) for 'NDP Router Advertisement Message' 
#x       (-icmp_type 134) message type.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_hop_limit_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_ndp_ram_hop_limit 
#x       is incremeneted or decremented when icmp_ndp_ram_hop_limit_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_hop_limit_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_ram_hop_limit. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_ndp_ram_hop_limit_step and icmp_ndp_ram_hop_limit_count.
#x          decr - the value is decremented as specified with icmp_ndp_ram_hop_limit_step and icmp_ndp_ram_hop_limit_count.
#x          list - Parameter -icmp_ndp_ram_hop_limit contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_hop_limit_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_ndp_ram_hop_limit when icmp_ndp_ram_hop_limit_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_hop_limit_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_ndp_ram_hop_limit
#x          1 - enable tracking by icmp_ndp_ram_hop_limit
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_m_flag
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure "Managed address configuration" flag for 'NDP Router Advertisement Message' 
#x       (-icmp_type 134) message type. Valid choices are:
#x          0 - disable M-Flag
#x          1 - enable M-Flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_m_flag_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_ram_m_flag. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -icmp_ndp_ram_m_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_m_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_ndp_ram_m_flag
#x          1 - enable tracking by icmp_ndp_ram_m_flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_o_flag
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure "Other stateful configuration" flag for 'NDP Router Advertisement Message' 
#x       (-icmp_type 134) message type. Valid choices are:
#x          0 - disable O-Flag
#x          1 - enable O-Flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_o_flag_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_ram_o_flag. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -icmp_ndp_ram_o_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_o_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_ndp_ram_o_flag
#x          1 - enable tracking by icmp_ndp_ram_o_flag
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_reachable_time
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure "Reachable time" field (0-4294967295) for 'NDP Router Advertisement Message' 
#x       (-icmp_type 134) message type.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_reachable_time_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_ndp_ram_reachable_time 
#x       is incremeneted or decremented when icmp_ndp_ram_reachable_time_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_reachable_time_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_ram_reachable_time. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_ndp_ram_reachable_time_step and icmp_ndp_ram_reachable_time_count.
#x          decr - the value is decremented as specified with icmp_ndp_ram_reachable_time_step and icmp_ndp_ram_reachable_time_count.
#x          list - Parameter -icmp_ndp_ram_reachable_time contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_reachable_time_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_ndp_ram_reachable_time when icmp_ndp_ram_reachable_time_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_reachable_time_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_ndp_ram_reachable_time
#x          1 - enable tracking by icmp_ndp_ram_reachable_time
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_retransmit_timer
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure "Retransmission timer" field (0-4294967295) for 'NDP Router Advertisement Message' 
#x       (-icmp_type 134) message type.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_retransmit_timer_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_ndp_ram_retransmit_timer 
#x       is incremeneted or decremented when icmp_ndp_ram_retransmit_timer_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_retransmit_timer_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_ram_retransmit_timer. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_ndp_ram_retransmit_timer_step and icmp_ndp_ram_retransmit_timer_count.
#x          decr - the value is decremented as specified with icmp_ndp_ram_retransmit_timer_step and icmp_ndp_ram_retransmit_timer_count.
#x          list - Parameter -icmp_ndp_ram_retransmit_timer contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_retransmit_timer_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_ndp_ram_retransmit_timer when icmp_ndp_ram_retransmit_timer_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_retransmit_timer_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_ndp_ram_retransmit_timer
#x          1 - enable tracking by icmp_ndp_ram_retransmit_timer
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_router_lifetime
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure "Router lifetime" field (0-65535) for 'NDP Router Advertisement Message' 
#x       (-icmp_type 134) message type.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_router_lifetime_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_ndp_ram_router_lifetime 
#x       is incremeneted or decremented when icmp_ndp_ram_router_lifetime_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_router_lifetime_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_ram_router_lifetime. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_ndp_ram_router_lifetime_step and icmp_ndp_ram_router_lifetime_count.
#x          decr - the value is decremented as specified with icmp_ndp_ram_router_lifetime_step and icmp_ndp_ram_router_lifetime_count.
#x          list - Parameter -icmp_ndp_ram_router_lifetime contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_router_lifetime_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_ndp_ram_router_lifetime when icmp_ndp_ram_router_lifetime_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_ram_router_lifetime_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_ndp_ram_router_lifetime
#x          1 - enable tracking by icmp_ndp_ram_router_lifetime
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_rm_dest_addr
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure the IPv6 "Destination address" field for 'NDP Redirect' (-icmp_type 137) 
#x       message type.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_rm_dest_addr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_ndp_rm_dest_addr 
#x       is incremeneted or decremented when icmp_ndp_rm_dest_addr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_rm_dest_addr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_ndp_rm_dest_addr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_ndp_rm_dest_addr_step and icmp_ndp_rm_dest_addr_count.
#x          decr - the value is decremented as specified with icmp_ndp_rm_dest_addr_step and icmp_ndp_rm_dest_addr_count.
#x          list - Parameter -icmp_ndp_rm_dest_addr contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_rm_dest_addr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_ndp_rm_dest_addr when icmp_ndp_rm_dest_addr_mode is incr 
#x       or decr.
#x       (DEFAULT = 0::0)
#x       Category: Layer4-7.ICMP
#x   -icmp_ndp_rm_dest_addr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_ndp_rm_dest_addr
#x          1 - enable tracking by icmp_ndp_rm_dest_addr
#x       Category: Layer4-7.ICMP
#x   -icmp_param_problem_message_pointer
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure 'Pointer' field for 'Parameter Problem' message (-icmp_type 4).
#x       Category: Layer4-7.ICMP
#x   -icmp_param_problem_message_pointer_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_param_problem_message_pointer 
#x       is incremeneted or decremented when icmp_param_problem_message_pointer_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_param_problem_message_pointer_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_param_problem_message_pointer. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_param_problem_message_pointer_step and icmp_param_problem_message_pointer_count.
#x          decr - the value is decremented as specified with icmp_param_problem_message_pointer_step and icmp_param_problem_message_pointer_count.
#x          list - Parameter -icmp_param_problem_message_pointer contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_param_problem_message_pointer_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_param_problem_message_pointer when icmp_param_problem_message_pointer_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_param_problem_message_pointer_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_param_problem_message_pointer
#x          1 - enable tracking by icmp_param_problem_message_pointer
#x       Category: Layer4-7.ICMP
#x   -icmp_pkt_too_big_mtu
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure MTU for 'Packet Too Big' messages (-icmp_type 2)
#x       Category: Layer4-7.ICMP
#x   -icmp_pkt_too_big_mtu_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_pkt_too_big_mtu 
#x       is incremeneted or decremented when icmp_pkt_too_big_mtu_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_pkt_too_big_mtu_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_pkt_too_big_mtu. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_pkt_too_big_mtu_step and icmp_pkt_too_big_mtu_count.
#x          decr - the value is decremented as specified with icmp_pkt_too_big_mtu_step and icmp_pkt_too_big_mtu_count.
#x          list - Parameter -icmp_pkt_too_big_mtu contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_pkt_too_big_mtu_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_pkt_too_big_mtu when icmp_pkt_too_big_mtu_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_pkt_too_big_mtu_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_pkt_too_big_mtu
#x          1 - enable tracking by icmp_pkt_too_big_mtu
#x       Category: Layer4-7.ICMP
#x   -icmp_seq_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_seq 
#x       is incremeneted or decremented when icmp_seq_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_seq_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_seq. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_seq_step and icmp_seq_count.
#x          decr - the value is decremented as specified with icmp_seq_step and icmp_seq_count.
#x          list - Parameter -icmp_seq contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_seq_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_seq when icmp_seq_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_seq_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_seq
#x          1 - enable tracking by icmp_seq
#x       Category: Layer4-7.ICMP
#x   -icmp_target_addr
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure the IPv6 "Target address" field for 'Neighbor Solicitation' 
#x       (-icmp_type 135), 'Neighbor Advertisement' (-icmp_type 136), 'NDP Redirect' (-icmp_type 137) 
#x       message types.
#x       Category: Layer4-7.ICMP
#x   -icmp_target_addr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_target_addr 
#x       is incremeneted or decremented when icmp_target_addr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_target_addr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_target_addr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_target_addr_step and icmp_target_addr_count.
#x          decr - the value is decremented as specified with icmp_target_addr_step and icmp_target_addr_count.
#x          list - Parameter -icmp_target_addr contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_target_addr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_target_addr when icmp_target_addr_mode is incr 
#x       or decr.
#x       (DEFAULT = 0::0)
#x       Category: Layer4-7.ICMP
#x   -icmp_target_addr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_target_addr
#x          1 - enable tracking by icmp_target_addr
#x       Category: Layer4-7.ICMP
#x   -icmp_type_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_type 
#x       is incremeneted or decremented when icmp_type_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_type_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_type. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_type_step and icmp_type_count.
#x          decr - the value is decremented as specified with icmp_type_step and icmp_type_count.
#x          list - Parameter -icmp_type contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_type_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_type when icmp_type_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_type_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_type
#x          1 - enable tracking by icmp_type
#x       Category: Layer4-7.ICMP
#x   -icmp_unused
#x       Valid only for traffic_generator ixnetwork_540 and ICMPv6. 
#x       Configure 4 byte HEX "Unused" field for 'Destination Unreachable' 
#x       (-icmp_type 2), 'Time Exceeded' (-icmp_type 3) message types.
#x       Category: Layer4-7.ICMP
#x   -icmp_unused_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the icmp_unused 
#x       is incremeneted or decremented when icmp_unused_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_unused_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for icmp_unused. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with icmp_unused_step and icmp_unused_count.
#x          decr - the value is decremented as specified with icmp_unused_step and icmp_unused_count.
#x          list - Parameter -icmp_unused contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.ICMP
#x   -icmp_unused_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify icmp_unused when icmp_unused_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.ICMP
#x   -icmp_unused_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by icmp_unused
#x          1 - enable tracking by icmp_unused
#x       Category: Layer4-7.ICMP
#x   -igmp_aux_data_length
#x       Valid only for traffic_generator ixnetwork_540, l4_protocol igmp, IGMPv3.  
#x       Configure the Auxiliary data length field (0-255) from the Group Record. 
#x       Use a list of values when configuring multiple Group Records.
#x       Category: Layer4-7.IGMP
#x   -igmp_aux_data_length_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_aux_data_length 
#x       is incremeneted or decremented when igmp_aux_data_length_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_aux_data_length_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_aux_data_length. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_aux_data_length_step and igmp_aux_data_length_count.
#x          decr - the value is decremented as specified with igmp_aux_data_length_step and igmp_aux_data_length_count.
#x       Category: Layer4-7.IGMP
#x   -igmp_aux_data_length_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_aux_data_length when igmp_aux_data_length_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_aux_data_length_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_aux_data_length
#x          1 - enable tracking by igmp_aux_data_length
#x       Category: Layer4-7.IGMP
#x   -igmp_checksum
#x       Valid only for traffic_generator ixnetwork_540, l4_protocol igmp, igmp_valid_checksum 0.
#x       Configure 2 byte HEX Checksum field for IGMP message.
#x       Category: Layer4-7.IGMP
#x   -igmp_checksum_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_checksum 
#x       is incremeneted or decremented when igmp_checksum_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_checksum_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_checksum. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_checksum_step and igmp_checksum_count.
#x          decr - the value is decremented as specified with igmp_checksum_step and igmp_checksum_count.
#x          list - Parameter -igmp_checksum contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.IGMP
#x   -igmp_checksum_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_checksum when igmp_checksum_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_checksum_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_checksum
#x          1 - enable tracking by igmp_checksum
#x       Category: Layer4-7.IGMP
#x   -igmp_data_v3r
#x       Valid only for traffic_generator ixnetwork_540, l4_protocol igmp, IGMPv3 Membership Report.
#x       Configure the data in auxiliary data field (HEX). Use a list of values when configuring multiple 
#x       Group records.
#x       Category: Layer4-7.IGMP
#x   -igmp_data_v3r_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_data_v3r 
#x       is incremeneted or decremented when igmp_data_v3r_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_data_v3r_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_data_v3r. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_data_v3r_step and igmp_data_v3r_count.
#x          decr - the value is decremented as specified with igmp_data_v3r_step and igmp_data_v3r_count.
#x       Category: Layer4-7.IGMP
#x   -igmp_data_v3r_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_data_v3r when igmp_data_v3r_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_data_v3r_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_data_v3r
#x          1 - enable tracking by igmp_data_v3r
#x       Category: Layer4-7.IGMP
#x   -igmp_group_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_group_addr
#x          1 - enable tracking by igmp_group_addr
#x       Category: Layer4-7.IGMP
#x   -igmp_length_v3r
#x       Valid only for traffic_generator ixnetwork_540, l4_protocol igmp, IGMPv3 Membership Report.
#x       Configure the length of the data from the auxiliary data field (0-255). Use a list of values 
#x       when configuring multiple Group Records.
#x       Category: Layer4-7.IGMP
#x   -igmp_length_v3r_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_length_v3r 
#x       is incremeneted or decremented when igmp_length_v3r_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_length_v3r_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_length_v3r. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_length_v3r_step and igmp_length_v3r_count.
#x          decr - the value is decremented as specified with igmp_length_v3r_step and igmp_length_v3r_count.
#x       Category: Layer4-7.IGMP
#x   -igmp_length_v3r_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_length_v3r when igmp_length_v3r_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_length_v3r_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_length_v3r
#x          1 - enable tracking by igmp_length_v3r
#x       Category: Layer4-7.IGMP
#x   -igmp_max_response_time_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_max_response_time 
#x       is incremeneted or decremented when igmp_max_response_time_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_max_response_time_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_max_response_time. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_max_response_time_step and igmp_max_response_time_count.
#x          decr - the value is decremented as specified with igmp_max_response_time_step and igmp_max_response_time_count.
#x          list - Parameter -igmp_max_response_time contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.IGMP
#x   -igmp_max_response_time_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_max_response_time when igmp_max_response_time_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_max_response_time_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_max_response_time
#x          1 - enable tracking by igmp_max_response_time
#x       Category: Layer4-7.IGMP
#x   -igmp_msg_type_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_msg_type
#x          1 - enable tracking by igmp_msg_type
#x       Category: Layer4-7.IGMP
#x   -igmp_multicast_src_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_multicast_src 
#x       is incremeneted or decremented when igmp_multicast_src_mode is incr or decr.
#x       Category: Layer4-7.IGMP
#x   -igmp_multicast_src_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_multicast_src. Valid choices are: 
#x          fixed - the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_multicast_src_step and igmp_multicast_src_count.
#x          decr - the value is decremented as specified with igmp_multicast_src_step and igmp_multicast_src_count.
#x       Category: Layer4-7.IGMP
#x   -igmp_multicast_src_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_multicast_src when igmp_multicast_src_mode is incr 
#x       or decr.
#x       Category: Layer4-7.IGMP
#x   -igmp_multicast_src_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - disable tracking by igmp_multicast_src
#x          1 - enable tracking by igmp_multicast_src
#x       Category: Layer4-7.IGMP
#x   -igmp_qqic_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_qqic 
#x       is incremeneted or decremented when igmp_qqic_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_qqic_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_qqic. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_qqic_step and igmp_qqic_count.
#x          decr - the value is decremented as specified with igmp_qqic_step and igmp_qqic_count.
#x          list - Parameter -igmp_qqic contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.IGMP
#x   -igmp_qqic_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_qqic when igmp_qqic_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_qqic_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_qqic
#x          1 - enable tracking by igmp_qqic
#x       Category: Layer4-7.IGMP
#x   -igmp_qrv_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_qrv 
#x       is incremeneted or decremented when igmp_qrv_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_qrv_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_qrv. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_qrv_step and igmp_qrv_count.
#x          decr - the value is decremented as specified with igmp_qrv_step and igmp_qrv_count.
#x          list - Parameter -igmp_qrv contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.IGMP
#x   -igmp_qrv_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_qrv when igmp_qrv_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_qrv_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_qrv
#x          1 - enable tracking by igmp_qrv
#x       Category: Layer4-7.IGMP
#x   -igmp_record_type_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_record_type. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_record_type_step and igmp_record_type_count.
#x          decr - the value is decremented as specified with igmp_record_type_step and igmp_record_type_count.
#x       Category: Layer4-7.IGMP
#x   -igmp_record_type_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_record_type
#x          1 - enable tracking by igmp_record_type
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3q
#x       Valid only for traffic_generator ixnetwork_540, l4_protocol igmp for IGMPv3 Membership Query 
#x       Messages. Configure the reserved field (0-15).
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3q_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_reserved_v3q 
#x       is incremeneted or decremented when igmp_reserved_v3q_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3q_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_reserved_v3q. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_reserved_v3q_step and igmp_reserved_v3q_count.
#x          decr - the value is decremented as specified with igmp_reserved_v3q_step and igmp_reserved_v3q_count.
#x          list - Parameter -igmp_reserved_v3q contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3q_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_reserved_v3q when igmp_reserved_v3q_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3q_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_reserved_v3q
#x          1 - enable tracking by igmp_reserved_v3q
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3r1
#x       Valid only for traffic_generator ixnetwork_540, l4_protocol igmp for IGMPv3 Membership Report 
#x       Messages. Configure the reserved1 field (0-255).
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3r1_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_reserved_v3r1 
#x       is incremeneted or decremented when igmp_reserved_v3r1_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3r1_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_reserved_v3r1. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_reserved_v3r1_step and igmp_reserved_v3r1_count.
#x          decr - the value is decremented as specified with igmp_reserved_v3r1_step and igmp_reserved_v3r1_count.
#x          list - Parameter -igmp_reserved_v3r1 contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3r1_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_reserved_v3r1 when igmp_reserved_v3r1_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3r1_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_reserved_v3r1
#x          1 - enable tracking by igmp_reserved_v3r1
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3r2
#x       Valid only for traffic_generator ixnetwork_540, l4_protocol igmp for IGMPv3 Membership Report 
#x       Messages. Configure the reserved2 field (0-65535).
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3r2_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_reserved_v3r2 
#x       is incremeneted or decremented when igmp_reserved_v3r2_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3r2_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_reserved_v3r2. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_reserved_v3r2_step and igmp_reserved_v3r2_count.
#x          decr - the value is decremented as specified with igmp_reserved_v3r2_step and igmp_reserved_v3r2_count.
#x          list - Parameter -igmp_reserved_v3r2 contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3r2_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_reserved_v3r2 when igmp_reserved_v3r2_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_reserved_v3r2_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_reserved_v3r2
#x          1 - enable tracking by igmp_reserved_v3r2
#x       Category: Layer4-7.IGMP
#x   -igmp_s_flag_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_s_flag. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -igmp_s_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.IGMP
#x   -igmp_s_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_s_flag
#x          1 - enable tracking by igmp_s_flag
#x       Category: Layer4-7.IGMP
#x   -igmp_unused
#x       Configure 1 byte HEX IGMPv1 Unused field when traffic_genrator is ixnetwork_540 and
#x       igmp_version is 1.
#x       Valid for traffic_generator ixnetwork_540.
#x       Category: Layer4-7.IGMP
#x   -igmp_unused_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the igmp_unused 
#x       is incremeneted or decremented when igmp_unused_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_unused_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for igmp_unused. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with igmp_unused_step and igmp_unused_count.
#x          decr - the value is decremented as specified with igmp_unused_step and igmp_unused_count.
#x          list - Parameter -igmp_unused contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.IGMP
#x   -igmp_unused_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify igmp_unused when igmp_unused_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.IGMP
#x   -igmp_unused_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by igmp_unused
#x          1 - enable tracking by igmp_unused
#x       Category: Layer4-7.IGMP
#x   -indirect
#x       This option can be used to specify whether a LAN static endpoint 
#x       is going to be connected through an ATM or Frame Relay endpoint 
#x       or not. This option is available only when using the ixnetwork 
#x       traffic generator for L2VPN traffic.
#x       Valid for traffic_generator ixnetwork.
#x       Category: Layer2.L2VPN
#x   -inner_ip_dst_addr
#x       Destination IP address for inner GRE IPv4 header. 
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ip_dst_count
#x       Number of destination IP addresses when option "-inner_ip_dst_mode" 
#x       is set to increment or decrement. When traffic_generator is ixos the maximum value 
#        is 4294967295. When traffic_generator is ixnetwork_540 the maximum value 
#        is 2147483647. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ip_dst_mode
#x       Destination IP address mode for inner GRE IPv4 header. This option is 
#x       only used when -l4_protocol is gre. Valid only for traffic_generator ixos/ixnetwork_540. 
#x       Valid choices are:
#x       fixed             - The destination IP address is the same for all 
#x                           packets.
#x       increment         - The destination IP address increments.
#x       decrement         - The destination IP address decrements.
#x       random            - The destination IP address is random. 
#x                           With traffic_generator ixnetwork_540 this will be silently ignored and configured to 'fixed'.
#x       list - Parameter -inner_ip_dst_addr contains a list of values. Each packet 
#x               will use one of the values from the list. Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ip_dst_step
#x       The modifier for the increment and decrement choices of 
#x       "-inner_ip_dst_mode". When traffic_generator is ixnetwork_540 it is required 
#x       that only one field contain a non-zero value.  
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ip_dst_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by inner_ip_dst_addr.
#x          1 - enable tracking by inner_ip_dst_addr.
#x       Category: Layer4-7.GRE
#x   -inner_ip_src_addr
#x       Source IP address for inner GRE IPv4 header (only used 
#x       when -l4_protocol is gre). 
#x       Valid only for traffic_generator ixos/ixnetworK_540.
#x       Category: Layer4-7.GRE
#x   -inner_ip_src_count
#x       Number of source IP addresses when option "inner_ip_src_mode" is set 
#x       to increment or decrement (only used when -l4_protocol is gre). 
#x       When traffic_generator is ixos the maximum value 
#x       is 4294967295. When traffic_generator is ixnetwork_540 the maximum value 
#x       is 2147483647. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ip_src_mode
#x       Source IP address mode for inner GRE IPv4 header. This option is only 
#x       used when -l4_protocol is gre.  Valid only for traffic_generator ixos. 
#x       Valid choices are:
#x       fixed             - The source IP address is the same for all packets.
#x       increment         - The source IP address increments.
#x       decrement         - The source IP address decrements.
#x       random            - The source IP address is random. 
#x                           With traffic_generator ixnetwork_540 this will be silently ignored and configured to 'fixed'.
#x       list - Parameter -inner_ip_src_addr contains a list of values. Each packet 
#x               will use one of the values from the list. Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ip_src_step
#x       The modifier for the increment and decrement choices of 
#x       inner_ip_src_mode which requires that only one field contain a 
#x       non-zero value. 
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ip_src_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by inner_ip_src_addr.
#x          1 - enable tracking by inner_ip_src_addr.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_dst_addr
#x       Destination IP address for inner GRE IPv6 header. 
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_dst_count
#x       Number of destination IPv6 addresses when option "inner_ipv6_dst_mode" 
#x       is set to increment or decrement. When traffic_generator is ixos the maximum value 
#        is 4294967295. When traffic_generator is ixnetwork_540 the maximum value 
#        is 2147483647. 
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_dst_mask
#x       Specify IPv6 mask to be used for inner_ipv6_dst_addr to increment. 
#x       This parameter is ignored with traffic_generator ixnetwork_540. Incrementing and 
#x       decrementing can be done with any step value with traffic_generator ixnetwork_540.
#x       Default value is specific to the inner_ipv6_dst_mode as follows:
#x          incr_global_top_level decr_global_top_level: Default 4
#x          incr_global_next_level decr_global_next_level: Default 24
#x          incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: Default 48
#x          incr_mcast_group decr_mcast_group: Default 96
#x          incr_host decr_host incr_intf_id decr_intf_id: Default 96
#x          incr_network decr_network: Default 96
#x       inner_ipv6_dst_mode specifies how and if the inner_ipv6_dst_addr is incremented.
#x       The inner_ipv6_dst_mode depends on the IPv6 address type specified with inner_ipv6_dst_addr parameter.
#x       Each inner_ipv6_dst_mode allows a mask from a Mask range to be configured.
#x       The mask is configured using the inner_ipv6_dst_mask attribute
#x       The step used for incrementing or decrementing is configued using the 
#x       inner_ipv6_dst_step attribute which has the form of an IPv6 address.
#x       The inner_ipv6_dst_mask attribute specifies which part of the inner_ipv6_dst_step 
#x       address is used for incrementing as follows:
#x            Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#x            Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#x            Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#x            Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#x       HEX values marked with 'x' in the format above are the inner_ipv6_dst_step HEX 
#x       values that are used for increment or decrement; HEX values marked with 
#x       '0' are ignored.
#x       Valid for traffic_generator ixos/ixnetwork.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_dst_mode
#x       Destination IPv6 address mode. This option is only used when -l4_protocol 
#x       is gre. Valid only for traffic_generator ixos/ixnetwork_540.
#x       The following is valid only for traffic_generator ixnetwork_540:
#x       Valid options are:
#x          increment
#x          decrement
#x          fixed
#x          list
#x       For backwards compatibility all modes starting with 'incr' will be configured 
#x       as increment and all modes starting with 'decr' will be configured as decrement. 
#x       Incrementing and decrementing depends only on inner_ipv6_dst_step and inner_ipv6_dst_count.
#x       The following is valid only for traffic_generator ixos: 
#x       inner_ipv6_dst_mode specifies how and if the inner_ipv6_dst_addr is incremented.
#x       The inner_ipv6_dst_mode depends on the IPv6 address type specified with inner_ipv6_dst_addr parameter.
#x       Each inner_ipv6_dst_mode allows a mask from a Mask range to be configured.
#x       The mask is configured using the inner_ipv6_dst_mask attribute
#x       The step used for incrementing or decrementing is configued using the 
#x       inner_ipv6_dst_step attribute which has the form of an IPv6 address.
#x       The inner_ipv6_dst_mask attribute specifies which part of the inner_ipv6_dst_step 
#x       address is used for incrementing as follows:
#x            Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#x            Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#x            Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#x            Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#x       HEX values marked with 'x' in the format above are the inner_ipv6_dst_step HEX 
#x       values that are used for increment or decrement; HEX values marked with 
#x       '0' are ignored.
#x       The step is limited to a 32 bit counter. Example:
#x          inner_ipv6_dst_mode incr_network
#x          inner_ipv6_dst_mask 64
#x       inner_ipv6_dst_step address portion that is used for incrementing will be:
#x              0000:0000:xxxx:xxxx:0000:0000:00000:0000
#x              32bit limit       Network Mask 64
#x              0000:0000:xxxx:xxxx is the mask.
#x              0000:0000 is the 32 bits that will NOT be incremented because of the limitation.
#x              xxxx:xxxx is what gets incremented.
#x       The table below is sectioned by IPv6 address type. Then IPv6 increment mode and parameter description is listed in the left column (Value) and mask range in the right column (Usage). Valid choices are:
#x            IPv6 address type - User Defined
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             incr_host: Increment IPv6 host address - Mask range 96-128
#x              decr_host: Decrement IPv6 host address - Mask range 96-128
#x             incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x              Reserved - .
#x              fixed: IPv6 fixed address - Mask range 0-128
#x            increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x            decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             incr_host: Increment IPv6 host address - Mask range 96-128
#x             decr_host: Decrement IPv6 host address - Mask range 96-128
#x             incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             Reserved for NSAP Allocation - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             incr_host: Increment IPv6 host address - Mask range 96-128
#x             decr_host: Decrement IPv6 host address - Mask range 96-128
#x             incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             Reserved for IPX Allocation - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x            incr_host: Increment IPv6 host address - Mask range 96-128
#x             decr_host: Decrement IPv6 host address - Mask range 96-128
#x            incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             Aggregatable Global Unicast Addresses - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x              increment: Increment interface ID - Mask range 96-128
#x             decrement: Decrement interface ID - Mask range 96-128
#x             incr_intf_id: Increment interface ID - Mask range 96-128
#x              decr_intf_id: Decrement interface ID - Mask range 96-128
#x             incr_global_top_level: Increment global unicast top level ID - Mask range 4-4
#x             decr_global_top_level: Decrement global unicast top level ID - Mask range 4-4
#x            incr_global_next_level: Increment global unicast next level ID - Mask range 24-24
#x            decr_global_next_level: Decrement global unicast next level ID - Mask range 24-24
#x             incr_global_site_level: Increment global unicast site level ID - Mask range 48-48
#x             decr_global_site_level: Decrement global unicast site level ID - Mask range 48-48
#x            Link-Local Unicast Addresses - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment interface ID - Mask range 96-128
#x             decrement: Decrement interface ID - Mask range 96-128
#x             incr_intf_id: Increment interface ID - Mask range 96-128
#x            decr_intf_id: Decrement interface ID - Mask range 96-128
#x             Site-Local Unicast Addresses - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment site local unicast subnet ID - Mask range 48-48
#x             decrement: Decrement site local unicast subnet ID - Mask range 48-48
#x             incr_intf_id: Increment interface ID - Mask range 96-128
#x             decr_intf_id: Decrement interface ID - Mask range 96-128
#x             incr_local_site_subnet: Increment site local unicast subnet ID - Mask range 48-48
#x              decr_local_site_subnet: Decrement site local unicast subnet ID  - Mask range 48-48
#x             Multicast Addresses  - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment multicast group ID - Mask range 96-96
#x             decrement: Decrement multicast group ID - Mask range 96-96
#x             incr_mcast_group: Increment multicast group ID - Mask range 96-96
#x              decr_mcast_group: Decrement multicast group ID - Mask range 96-96
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_dst_step
#x       Step size of the IPv6 addresses  when option "inner_ipv6_dst_mode" is 
#x       set to increment or decrement. 
#x       This option is only used when -l4_protocol is gre. 
#x       The following is valid only for traffic_generator ixnetwork_540:
#x       Any IPv6 step is accepted. Incrementing and decrementing depends only on inner_ipv6_dst_step and inner_ipv6_dst_count.
#x       The following is valid only for traffic_generator ixos:
#x       inner_ipv6_dst_mode specifies how and if the inner_ipv6_dst_addr is incremented.
#x       The inner_ipv6_dst_mode depends on the IPv6 address type specified with inner_ipv6_dst_addr parameter.
#x       Each inner_ipv6_dst_mode allows a mask from a Mask range to be configured.
#x       The mask is configured using the inner_ipv6_dst_mask attribute
#x       The step used for incrementing or decrementing is configued using the 
#x       inner_ipv6_dst_step attribute which has the form of an IPv6 address.
#x       The inner_ipv6_dst_mask attribute specifies which part of the inner_ipv6_dst_step 
#x       address is used for incrementing as follows:
#x            Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#x            Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#x            Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#x            Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#x       HEX values marked with 'x' in the format above are the inner_ipv6_dst_step HEX 
#x       values that are used for increment or decrement; HEX values marked with 
#x       '0' are ignored.
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_dst_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by inner_ipv6_dst_addr
#x          1 - enable tracking by inner_ipv6_dst_addr
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_flow_label
#x       Flow label value of the IPv6 inner header. 
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_flow_label_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the inner_ipv6_flow_label 
#x       is incremeneted or decremented when inner_ipv6_flow_label_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_flow_label_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for inner_ipv6_flow_label. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with inner_ipv6_flow_label_step and inner_ipv6_flow_label_count.
#x          decr - the value is decremented as specified with inner_ipv6_flow_label_step and inner_ipv6_flow_label_count.
#x          list - Parameter -inner_ipv6_flow_label contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_flow_label_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify inner_ipv6_flow_label when inner_ipv6_flow_label_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_flow_label_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by inner_ipv6_flow_label
#x          1 - enable tracking by inner_ipv6_flow_label
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_id
#x       Identification field in the fragment extension header of an IPv6 
#x       header. This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_id_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the inner_ipv6_frag_id 
#x       is incremeneted or decremented when inner_ipv6_frag_id_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_id_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for inner_ipv6_frag_id. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with inner_ipv6_frag_id_step and inner_ipv6_frag_id_count.
#x          decr - the value is decremented as specified with inner_ipv6_frag_id_step and inner_ipv6_frag_id_count.
#x          list - Parameter -inner_ipv6_frag_id contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_id_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify inner_ipv6_frag_id when inner_ipv6_frag_id_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_id_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by inner_ipv6_frag_id
#x          1 - enable tracking by inner_ipv6_frag_id
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_more_flag
#x       Whether the M Flag in the fragment extension header of an IPv6 header 
#x       is set. This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_more_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for inner_ipv6_frag_more_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -inner_ipv6_frag_more_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_more_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by inner_ipv6_frag_more_flag
#x          1 - enable tracking by inner_ipv6_frag_more_flag
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_offset
#x       Fragment offset in the fragment extension header of an IPv6 header. 
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_offset_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the inner_ipv6_frag_offset 
#x       is incremeneted or decremented when inner_ipv6_frag_offset_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_offset_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for inner_ipv6_frag_offset. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with inner_ipv6_frag_offset_step and inner_ipv6_frag_offset_count.
#x          decr - the value is decremented as specified with inner_ipv6_frag_offset_step and inner_ipv6_frag_offset_count.
#x          list - Parameter -inner_ipv6_frag_offset contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_offset_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify inner_ipv6_frag_offset when inner_ipv6_frag_offset_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_frag_offset_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by inner_ipv6_frag_offset
#x          1 - enable tracking by inner_ipv6_frag_offset
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_hop_limit
#x       Hop limit value of the IPv6 inner header. 
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_hop_limit_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the inner_ipv6_hop_limit 
#x       is incremeneted or decremented when inner_ipv6_hop_limit_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_hop_limit_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for inner_ipv6_hop_limit. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with inner_ipv6_hop_limit_step and inner_ipv6_hop_limit_count.
#x          decr - the value is decremented as specified with inner_ipv6_hop_limit_step and inner_ipv6_hop_limit_count.
#x          list - Parameter -inner_ipv6_hop_limit contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_hop_limit_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify inner_ipv6_hop_limit when inner_ipv6_hop_limit_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_hop_limit_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by inner_ipv6_hop_limit
#x          1 - enable tracking by inner_ipv6_hop_limit
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_src_addr
#x       Source IP address for inner GRE IPv6 header. 
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_src_count
#x       Number of source IP address when option "inner_ipv6_src_mode" is set 
#x       to increment or decrement. When traffic_generator is ixos the maximum value 
#        is 4294967295. When traffic_generator is ixnetwork_540 the maximum value 
#        is 2147483647. 
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_src_mask
#x       This parameter is ignored with traffic_generator ixnetwork_540. Incrementing and 
#x       decrementing can be done with any step value with traffic_generator ixnetwork_540.
#x       Specify IPv6 mask to be used for inner_ipv6_src_addr to increment. 
#x       Default value is minimum value specified in inner_ipv6_dst_mode (it 
#x       depends on address type and increment mode).
#x       inner_ipv6_src_mode specifies how and if the inner_ipv6_src_addr is incremented.
#x       The inner_ipv6_src_mode depends on the IPv6 address type specified with inner_ipv6_src_addr parameter.
#x       Each inner_ipv6_src_mode allows a mask from a Mask range to be configured.
#x       The mask is configured using the inner_ipv6_src_mask attribute
#x       The step used for incrementing or decrementing is configued using the 
#x       inner_ipv6_src_step attribute which has the form of an IPv6 address.
#x       The inner_ipv6_src_mask attribute specifies which part of the inner_ipv6_src_step 
#x       address is used for incrementing as follows:
#x            Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#x            Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#x            Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#x            Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#x       HEX values marked with 'x' in the format above are the inner_ipv6_src_step HEX 
#x       values that are used for increment or decrement; HEX values marked with 
#x       '0' are ignored.
#x       Valid for traffic_generator ixos/ixnetwork.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_src_mode
#x       Source IP address mode for inner GRE IPv6 header. This option is only 
#x       used when -l4_protocol is gre. Valid only for traffic_generator ixos/ixnetwork_540.
#x       The following is valid only for traffic_generator ixnetwork_540:
#x       Valid options are:
#x          increment
#x          decrement
#x          fixed
#x          list
#x       For backwards compatibility all modes starting with 'incr' will be configured 
#x       as increment and all modes starting with 'decr' will be configured as decrement. 
#x       Incrementing and decrementing depends only on ipv6_src_step and ipv6_src_count.
#x       The following is valid only for traffic_generator ixos: 
#x       inner_ipv6_src_mode specifies how and if the inner_ipv6_src_addr is incremented.
#x       The inner_ipv6_src_mode depends on the IPv6 address type specified with inner_ipv6_src_addr parameter.
#x       Each inner_ipv6_src_mode allows a mask from a Mask range to be configured.
#x       The mask is configured using the inner_ipv6_src_mask attribute
#x       The step used for incrementing or decrementing is configued using the 
#x       inner_ipv6_src_step attribute which has the form of an IPv6 address.
#x       The inner_ipv6_src_mask attribute specifies which part of the inner_ipv6_src_step 
#x       address is used for incrementing as follows:
#x            Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#x            Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#x            Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#x            Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#x       HEX values marked with 'x' in the format above are the inner_ipv6_src_step HEX 
#x       values that are used for increment or decrement; HEX values marked with 
#x       '0' are ignored.
#x       The table below is sectioned by IPv6 address type. Then IPv6 increment mode and parameter description is listed in the left column (Value) and mask range in the right column (Usage). Valid choices are:
#x            IPv6 address type - User Defined
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             incr_host: Increment IPv6 host address - Mask range 96-128
#x              decr_host: Decrement IPv6 host address - Mask range 96-128
#x             incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x              Reserved - .
#x              fixed: IPv6 fixed address - Mask range 0-128
#x            increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x            decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             incr_host: Increment IPv6 host address - Mask range 96-128
#x             decr_host: Decrement IPv6 host address - Mask range 96-128
#x             incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             Reserved for NSAP Allocation - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             incr_host: Increment IPv6 host address - Mask range 96-128
#x             decr_host: Decrement IPv6 host address - Mask range 96-128
#x             incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             Reserved for IPX Allocation - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decrement: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x            incr_host: Increment IPv6 host address - Mask range 96-128
#x             decr_host: Decrement IPv6 host address - Mask range 96-128
#x            incr_network: Increment IPv6 network prefix based on mask value - Mask range 0-128
#x             decr_network: Decrement IPv6 network prefix based on mask value - Mask range 0-128
#x             Aggregatable Global Unicast Addresses - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x              increment: Increment interface ID - Mask range 96-128
#x             decrement: Decrement interface ID - Mask range 96-128
#x             incr_intf_id: Increment interface ID - Mask range 96-128
#x              decr_intf_id: Decrement interface ID - Mask range 96-128
#x             incr_global_top_level: Increment global unicast top level ID - Mask range 4-4
#x             decr_global_top_level: Decrement global unicast top level ID - Mask range 4-4
#x            incr_global_next_level: Increment global unicast next level ID - Mask range 24-24
#x            decr_global_next_level: Decrement global unicast next level ID - Mask range 24-24
#x             incr_global_site_level: Increment global unicast site level ID - Mask range 48-48
#x             decr_global_site_level: Decrement global unicast site level ID - Mask range 48-48
#x            Link-Local Unicast Addresses - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment interface ID - Mask range 96-128
#x             decrement: Decrement interface ID - Mask range 96-128
#x             incr_intf_id: Increment interface ID - Mask range 96-128
#x            decr_intf_id: Decrement interface ID - Mask range 96-128
#x             Site-Local Unicast Addresses - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment site local unicast subnet ID - Mask range 48-48
#x             decrement: Decrement site local unicast subnet ID - Mask range 48-48
#x             incr_intf_id: Increment interface ID - Mask range 96-128
#x             decr_intf_id: Decrement interface ID - Mask range 96-128
#x             incr_local_site_subnet: Increment site local unicast subnet ID - Mask range 48-48
#x              decr_local_site_subnet: Decrement site local unicast subnet ID  - Mask range 48-48
#x             Multicast Addresses  - .
#x             fixed: IPv6 fixed address - Mask range 0-128
#x             increment: Increment multicast group ID - Mask range 96-96
#x             decrement: Decrement multicast group ID - Mask range 96-96
#x             incr_mcast_group: Increment multicast group ID - Mask range 96-96
#x              decr_mcast_group: Decrement multicast group ID - Mask range 96-96
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_src_step
#x       Step size of the source IP address when option "inner_ipv6_src_mode" 
#x       is set to increment or decrement. 
#x       This option is only used when -l4_protocol is gre. 
#x       The following is valid only for traffic_generator ixnetwork_540:
#x       Any IPv6 step is accepted. Incrementing and decrementing depends only on ipv6_src_step and ipv6_src_count.
#x       The following is valid only for traffic_generator ixos:
#x       inner_ipv6_src_mode specifies how and if the inner_ipv6_src_addr is incremented.
#x       The inner_ipv6_src_mode depends on the IPv6 address type specified with inner_ipv6_src_addr parameter.
#x       Each inner_ipv6_src_mode allows a mask from a Mask range to be configured.
#x       The mask is configured using the inner_ipv6_src_mask attribute
#x       The step used for incrementing or decrementing is configued using the 
#x       inner_ipv6_src_step attribute which has the form of an IPv6 address.
#x       The inner_ipv6_src_mask attribute specifies which part of the inner_ipv6_src_step 
#x       address is used for incrementing as follows:
#x            Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#x            Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#x            Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#x            Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#x       HEX values marked with 'x' in the format above are the inner_ipv6_src_step HEX 
#x       values that are used for increment or decrement; HEX values marked with 
#x       '0' are ignored.
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_src_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by inner_ipv6_src_addr.
#x          1 - enable tracking by inner_ipv6_src_addr.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_traffic_class
#x       Traffic class value of the IPv6 inner header. 
#x       This option is only used when -l4_protocol is gre. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_traffic_class_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the inner_ipv6_traffic_class 
#x       is incremeneted or decremented when inner_ipv6_traffic_class_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_traffic_class_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for inner_ipv6_traffic_class. Valid choices are: 
#x          fixed -  (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with inner_ipv6_traffic_class_step and inner_ipv6_traffic_class_count.
#x          decr - the value is decremented as specified with inner_ipv6_traffic_class_step and inner_ipv6_traffic_class_count.
#x          list - Parameter -inner_ipv6_traffic_class contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_traffic_class_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify inner_ipv6_traffic_class when inner_ipv6_traffic_class_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_ipv6_traffic_class_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 -  (DEFAULT) disable tracking by inner_ipv6_traffic_class
#x          1 - enable tracking by inner_ipv6_traffic_class
#x       Category: Layer4-7.GRE
#x   -inner_protocol
#x       Configures a layer 3 protocol header. This option specifies whether 
#x       to setup an IPv4 or IPv6 header (only used when 
#x       l4_protocol is gre). Valid only for traffic_generator ixos/ixnetwork_540. 
#x       Valid options are:
#x       ipv4
#x       ipv6
#x       none
#x       <hex value> 
#x       Category: Layer4-7.GRE
#x   -inner_protocol_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the inner_protocol 
#x       is incremeneted or decremented when inner_protocol_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_protocol_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for inner_protocol. Valid choices are: 
#x          fixed -  (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with inner_protocol_step and inner_protocol_count.
#x          decr - the value is decremented as specified with inner_protocol_step and inner_protocol_count.
#x          list - Parameter -inner_protocol contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.GRE
#x   -inner_protocol_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify inner_protocol when inner_protocol_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.GRE
#x   -inner_protocol_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 -  (DEFAULT) disable tracking by inner_protocol
#x          1 - enable tracking by inner_protocol
#x       Category: Layer4-7.GRE
#x   -integrity_signature
#x       Data integrity signature for the stream. 
#x       Valid only for traffic_generator ixos.
#x       Category: General.Instrumentation/Flow Group
#x   -integrity_signature_offset
#x       Data integrity signature offset for the stream. 
#x       If -enable_auto_detect_instrumentation is 1, will be ignored. 
#x       Valid only for traffic_generator ixos.
#x       Category: General.Instrumentation/Flow Group
#x   -inter_frame_gap
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. 
#x       This argument can be used to specify the time gap in clock ticks 
#x       between transmitted frames.
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -inter_frame_gap_unit
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. Valid only for traffic_generator ixnetwork_540.
#x       Configure unit for -inter_frame_gap. Valid choices are:
#x          bytes - bytes
#x          ns - nanoseconds
#x       Category: Stream Control and Data.Rate Control
#x   -ip_checksum_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ip_checksum 
#x       is incremeneted or decremented when ip_checksum_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_checksum_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_checksum. Valid choices are: 
#x          fixed -  (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ip_checksum_step and ip_checksum_count.
#x          decr - the value is decremented as specified with ip_checksum_step and ip_checksum_count.
#x          list - Parameter -ip_checksum contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_checksum_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ip_checksum when ip_checksum_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_checksum_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 -  (DEFAULT) disable tracking by ip_checksum
#x          1 - enable tracking by ip_checksum
#x       Category: Layer3.IPv4
#x   -ip_cost
#x       Part of the Type of Service byte of the IP header datagram (bit 6). 
#x       With traffic generator ixnetwork_540, this parameter configures QOS for IPv6 traffic only for 
#x       ixaccess backwards compatibility mode (details in description for traffic_generator 
#x       ixnetwork_540) and if qos_ipv6_traffic_class and ipv6_traffic_class parameters are 
#x       missing. 
#x       Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#x       0 - (default) Normal cost.
#x       1 - Low cost.
#x       Category: Layer3.IPv4
#x   -ip_cost_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_cost. Valid choices are:
#x          fixed -  (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -ip_cost contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_cost_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_cost
#x          1 - enable tracking by ip_cost
#x       Category: Layer3.IPv4
#x   -ip_cu_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ip_cu 
#x       is incremeneted or decremented when ip_cu_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_cu_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_cu. Valid choices are: 
#x          fixed -  (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ip_cu_step and ip_cu_count.
#x          decr - the value is decremented as specified with ip_cu_step and ip_cu_count.
#x          list - Parameter -ip_cu contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_cu_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ip_cu when ip_cu_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_cu_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_cu
#x          1 - enable tracking by ip_cu
#x       Category: Layer3.IPv4
#x   -ip_delay
#x       Part of the Type of Service byte of the IP header datagram (bit 3). 
#x       With traffic_generator ixnetwork_540 this parameter configures QOS for IPv6 traffic only for 
#x       ixaccess backwards compatibility mode (details in description for traffic_generator 
#x       ixnetwork_540) and if qos_ipv6_traffic_class and ipv6_traffic_class parameters are 
#x        missing. 
#x       Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#x       0 - (default) Normal delay.
#x       1 - Low delay.
#x       Category: Layer3.IPv4
#x   -ip_delay_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_delay. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -ip_delay contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_delay_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 -  (DEFAULT) disable tracking by ip_delay
#x          1 - enable tracking by ip_delay
#x       Category: Layer3.IPv4
#x   -ip_dscp_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_dscp. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ip_dscp_step and ip_dscp_count.
#x          decr - the value is decremented as specified with ip_dscp_step and ip_dscp_count.
#x          list - Parameter -ip_dscp contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_dscp_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_dscp
#x          1 - enable tracking by ip_dscp
#x       Category: Layer3.IPv4
#x   -ip_dst_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_dst_addr.
#x          1 - enable tracking by ip_dst_addr.
#x       Category: Layer3.IPv4
#x   -ip_fragment_last_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_fragment_last. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -ip_fragment_last contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_fragment_last_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_fragment_last
#x          1 - enable tracking by ip_fragment_last
#x       Category: Layer3.IPv4
#x   -ip_fragment_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_fragment. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -ip_fragment contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_fragment_offset_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ip_fragment_offset 
#x       is incremeneted or decremented when ip_fragment_offset_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_fragment_offset_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_fragment_offset. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ip_fragment_offset_step and ip_fragment_offset_count.
#x          decr - the value is decremented as specified with ip_fragment_offset_step and ip_fragment_offset_count.
#x          list - Parameter -ip_fragment_offset contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_fragment_offset_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ip_fragment_offset when ip_fragment_offset_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_fragment_offset_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_fragment_offset
#x          1 - enable tracking by ip_fragment_offset
#x       Category: Layer3.IPv4
#x   -ip_fragment_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_fragment
#x          1 - enable tracking by ip_fragment
#x       Category: Layer3.IPv4
#x   -ip_hdr_length_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ip_hdr_length 
#x       is incremeneted or decremented when ip_hdr_length_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_hdr_length_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_hdr_length. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ip_hdr_length_step and ip_hdr_length_count.
#x          decr - the value is decremented as specified with ip_hdr_length_step and ip_hdr_length_count.
#x          list - Parameter -ip_hdr_length contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_hdr_length_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ip_hdr_length when ip_hdr_length_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_hdr_length_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_hdr_length
#x          1 - enable tracking by ip_hdr_length
#x       Category: Layer3.IPv4
#x   -ip_id_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ip_id 
#x       is incremeneted or decremented when ip_id_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_id_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_id. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ip_id_step and ip_id_count.
#x          decr - the value is decremented as specified with ip_id_step and ip_id_count.
#x          list - Parameter -ip_id contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_id_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ip_id when ip_id_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_id_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_id
#x          1 - enable tracking by ip_id
#x       Category: Layer3.IPv4
#x   -ip_length_override
#x        Allows to change the length in ip header. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer3.IPv4
#x   -ip_length_override_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_length_override. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -ip_length_override contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_length_override_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_length_override
#x          1 - enable tracking by ip_length_override
#x       Category: Layer3.IPv4
#x   -ip_opt_loose_routing
#x       Will add an IP option for Loose Source and Record Route.  This option 
#x       is followed by an arbitrary length list of IP addresses. 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer3.IPv4
#x   -ip_opt_security
#x       Will add an IP option for security.  Must be given with a nine byte 
#x       option argument that contains the information, 2 bytes Security, 
#x       2 bytes Compartments, 2 bytes Handling Restrictions, and 3 bytes 
#x       Transmission Control Code. 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer3.IPv4
#x   -ip_opt_strict_routing
#x       Will add an IP option for Strict Source and Record Route.  This option 
#x       is followed by an arbitrary length list of IP addresses. 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer3.IPv4
#x   -ip_opt_timestamp
#x       Will add an IP option for Internet Timestamp. 
#x       Valid only for traffic_generator ixos.
#x       Category: Layer3.IPv4
#x   -ip_precedence_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ip_precedence 
#x       is incremeneted or decremented when ip_precedence_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_precedence_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_precedence. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ip_precedence_step and ip_precedence_count.
#x          decr - the value is decremented as specified with ip_precedence_step and ip_precedence_count.
#x          list - Parameter -ip_precedence contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_precedence_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ip_precedence when ip_precedence_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_precedence_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_precedence
#x          1 - enable tracking by ip_precedence
#x       Category: Layer3.IPv4
#x   -ip_protocol_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ip_protocol 
#x       is incremeneted or decremented when ip_protocol_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_protocol_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_protocol. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ip_protocol_step and ip_protocol_count.
#x          decr - the value is decremented as specified with ip_protocol_step and ip_protocol_count.
#x          list - Parameter -ip_protocol contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_protocol_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ip_protocol when ip_protocol_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_protocol_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_protocol
#x          1 - enable tracking by ip_protocol
#x       Category: Layer3.IPv4
#x   -ip_reliability
#x       Part of the Type of Service byte of the IP header datagram (bit 5). 
#x       With traffic generator ixnetwork_540, this parameter configures QOS for IPv6 traffic only for 
#x       ixaccess backwards compatibility mode (details in description for traffic_generator 
#x       ixnetwork_540) and if qos_ipv6_traffic_class and ipv6_traffic_class parameters are 
#x       missing. 
#x       Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#x       0 - (default) Normal reliability.
#x       1 - High reliability.
#x       Category: Layer3.IPv4
#x   -ip_reliability_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_reliability. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -ip_reliability contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_reliability_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_reliability
#x          1 - enable tracking by ip_reliability
#x       Category: Layer3.IPv4
#x   -ip_reserved
#x       Part of the Type of Service byte of the IP header datagram (bit 7). 
#x       Valid only for traffic_generator ixos/ixnetwork_540. Valid options are:
#x       0 - (default)
#x       1
#x       Category: Layer3.IPv4
#x   -ip_reserved_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_reserved. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -ip_reserved contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_reserved_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_reserved
#x          1 - enable tracking by ip_reserved
#x       Category: Layer3.IPv4
#x   -ip_src_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_src_addr.
#x          1 - enable tracking by ip_src_addr.
#x       Category: Layer3.IPv4
#x   -ip_throughput
#x       Part of the Type of Service byte of the IP header datagram (bit 4). 
#x       With traffic generator ixnetwork_540, this parameter configures QOS for IPv6 traffic only for 
#x       ixaccess backwards compatibility mode (details in description for traffic_generator 
#x       ixnetwork_540) and if qos_ipv6_traffic_class and ipv6_traffic_class parameters are 
#x       missing. 
#x       Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#x       0 - (default) Normal throughput.
#x       1 - High throughput.
#x       Category: Layer3.IPv4
#x   -ip_throughput_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_throughput. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -ip_throughput contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_throughput_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_throughput
#x          1 - enable tracking by ip_throughput
#x       Category: Layer3.IPv4
#x   -ip_total_length
#x        Total Length is the length of the datagram, measured in octets, 
#x        including internet header and data. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer3.IPv4
#x   -ip_total_length_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ip_total_length 
#x       is incremeneted or decremented when ip_total_length_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_total_length_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_total_length. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ip_total_length_step and ip_total_length_count.
#x          decr - the value is decremented as specified with ip_total_length_step and ip_total_length_count.
#x          list - Parameter -ip_total_length contains a list of values. Each packet 
#x              will use one of the values from the list.
#x          auto - the length of the datagram, measured in octets is autoset. Parameter ip_total_length is ignored if present.
#x       Category: Layer3.IPv4
#x   -ip_total_length_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ip_total_length when ip_total_length_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_total_length_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_total_length
#x          1 - enable tracking by ip_total_length
#x       Category: Layer3.IPv4
#x   -ip_ttl_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ip_ttl 
#x       is incremeneted or decremented when ip_ttl_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_ttl_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ip_ttl. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ip_ttl_step and ip_ttl_count.
#x          decr - the value is decremented as specified with ip_ttl_step and ip_ttl_count.
#x          list - Parameter -ip_ttl contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -ip_ttl_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ip_ttl when ip_ttl_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -ip_ttl_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ip_ttl
#x          1 - enable tracking by ip_ttl
#x       Category: Layer3.IPv4
#x   -ipv6_auth_next_header
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Next header in the authentication extention header. Range 0 - 255.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_next_header_count
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_auth_next_header 
#x       is incremeneted or decremented when ipv6_auth_next_header_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_next_header_mode 
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_auth_next_header. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_auth_next_header_step and ipv6_auth_next_header_count.
#x          decr - the value is decremented as specified with ipv6_auth_next_header_step and ipv6_auth_next_header_count.
#x          list - Parameter -ipv6_auth_next_header contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_next_header_step
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_auth_next_header when ipv6_auth_next_header_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_next_header_tracking
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_auth_next_header
#x          1 - enable tracking by ipv6_auth_next_header
#x       Category: Layer3.IPv6
#x   -ipv6_auth_padding
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure padding for authentication extension header. HEX values accepted.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_padding_count
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_auth_padding 
#x       is incremeneted or decremented when ipv6_auth_padding_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_padding_mode 
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_auth_padding. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_auth_padding_step and ipv6_auth_padding_count.
#x          decr - the value is decremented as specified with ipv6_auth_padding_step and ipv6_auth_padding_count.
#x          list - Parameter -ipv6_auth_padding contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_padding_step
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_auth_padding when ipv6_auth_padding_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_padding_tracking
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_auth_padding
#x          1 - enable tracking by ipv6_auth_padding
#x       Category: Layer3.IPv6
#x   -ipv6_auth_payload_len
#x       This is only for "-ipv6_extension_header authentication". 
#x       The length of the authentication data, expressed in 32-bit words.
#x       (DEFAULT = 2) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_payload_len_count
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_auth_payload_len 
#x       is incremeneted or decremented when ipv6_auth_payload_len_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_payload_len_mode 
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_auth_payload_len. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_auth_payload_len_step and ipv6_auth_payload_len_count.
#x          decr - the value is decremented as specified with ipv6_auth_payload_len_step and ipv6_auth_payload_len_count.
#x          list - Parameter -ipv6_auth_payload_len contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_payload_len_step
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_auth_payload_len when ipv6_auth_payload_len_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_payload_len_tracking
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_auth_payload_len
#x          1 - enable tracking by ipv6_auth_payload_len
#x       Category: Layer3.IPv6
#x   -ipv6_auth_reserved
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure the 2 byte reserved field in the authetication extension header.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_reserved_count
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_auth_reserved 
#x       is incremeneted or decremented when ipv6_auth_reserved_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_reserved_mode 
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_auth_reserved. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_auth_reserved_step and ipv6_auth_reserved_count.
#x          decr - the value is decremented as specified with ipv6_auth_reserved_step and ipv6_auth_reserved_count.
#x          list - Parameter -ipv6_auth_reserved contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_reserved_step
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_auth_reserved when ipv6_auth_reserved_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_reserved_tracking
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_auth_reserved
#x          1 - enable tracking by ipv6_auth_reserved
#x       Category: Layer3.IPv6
#x   -ipv6_auth_seq_num
#x       This is only for "-ipv6_extension_header authentication". 
#x       This is only for "-ipv6_extension_header authentication". 
#x       A sequence counter for the authentication header.
#x       (DEFAULT = 0) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_seq_num_count
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_auth_seq_num 
#x       is incremeneted or decremented when ipv6_auth_seq_num_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_seq_num_mode 
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_auth_seq_num. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_auth_seq_num_step and ipv6_auth_seq_num_count.
#x          decr - the value is decremented as specified with ipv6_auth_seq_num_step and ipv6_auth_seq_num_count.
#x          list - Parameter -ipv6_auth_seq_num contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_seq_num_step
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_auth_seq_num when ipv6_auth_seq_num_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_seq_num_tracking
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_auth_seq_num
#x          1 - enable tracking by ipv6_auth_seq_num
#x       Category: Layer3.IPv6
#x   -ipv6_auth_spi
#x       This is only for "-ipv6_extension_header authentication". 
#x       The security parameter index (SPI) associated with the authentication 
#x       header.
#x       (DEFAULT = 0) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_spi_count
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_auth_spi 
#x       is incremeneted or decremented when ipv6_auth_spi_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_spi_mode 
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_auth_spi. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_auth_spi_step and ipv6_auth_spi_count.
#x          decr - the value is decremented as specified with ipv6_auth_spi_step and ipv6_auth_spi_count.
#x          list - Parameter -ipv6_auth_spi contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_spi_step
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_auth_spi when ipv6_auth_spi_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_spi_tracking
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_auth_spi
#x          1 - enable tracking by ipv6_auth_spi
#x       Category: Layer3.IPv6
#x   -ipv6_auth_string
#x       This is only for "-ipv6_extension_header authentication". 
#x       A variable length string containing the packets integrity check value 
#x       (ICV).
#x       (DEFAULT = 00:00:00:00) 
#x       Valid only for traffic_generator ixos. 
#x       With traffic_generator ixnetwork_540 this parameter is deprecated. Use 
#x       ipv6_auth_md5sha1_string instead.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_string_count
#x       This is only for "-ipv6_extension_header authentication". 
#x       This parameter is deprecated. Use ipv6_auth_md5sha1_string_count instead.
#x       Valid only for traffic_generator ixnetwork_540.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_string_mode 
#x       This is only for "-ipv6_extension_header authentication". 
#x       This parameter is deprecated. Use ipv6_auth_md5sha1_string_mode instead.
#x       Valid for traffic_generator ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_string_step
#x       This is only for "-ipv6_extension_header authentication". 
#x       This parameter is deprecated. Use ipv6_auth_md5sha1_string_step instead.
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_string_tracking
#x       This is only for "-ipv6_extension_header authentication". 
#x       This parameter is deprecated. Use ipv6_auth_md5sha1_string_tracking instead.
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_type
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Configure authentication type of -ipv6_auth_string. Valid choices are:
#x          md5 - default
#x          sha1 - SHA1
#x       Category: Layer3.IPv6
#x   -ipv6_auth_md5sha1_string
#x       This is only for "-ipv6_extension_header authentication". 
#x       When ipv6_auth_type is 'md5' this represents the IPv6 Authentication MD5 field. 
#x       The length must be 16 bytes at most. 
#x       When ipv6_auth_type is 'sha1' this represents the IPv6 Authentication SHA1 field. 
#x       The length must be 20 bytes at most. 
#x       The field will be calculated automatically if the parameter is not specified. 
#x       (DEFAULT = 00:00:00:00)
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_md5sha1_string_count
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_auth_md5sha1_string 
#x       is incremeneted or decremented when ipv6_auth_md5sha1_string_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_md5sha1_string_mode 
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_auth_md5sha1_string. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_auth_md5sha1_string_step and ipv6_auth_md5sha1_string_count.
#x          decr - the value is decremented as specified with ipv6_auth_md5sha1_string_step and ipv6_auth_md5sha1_string_count.
#x          list - Parameter -ipv6_auth_md5sha1_string contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_auth_md5sha1_string_step
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_auth_md5sha1_string when ipv6_auth_md5sha1_string_mode is incr 
#x       or decr.
#x       (DEFAULT = 00:00:00:01)
#x       Category: Layer3.IPv6
#x   -ipv6_auth_md5sha1_string_tracking
#x       This is only for "-ipv6_extension_header authentication". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_auth_md5sha1_string
#x          1 - enable tracking by ipv6_auth_md5sha1_string
#x       Category: Layer3.IPv6
#x   -ipv6_dst_mask
#x       Specify IPv6 mask to be used for ipv6_dst_addr to increment. 
#x       This parameter is ignored with traffic_generator ixnetwork_540. Incrementing and 
#x       decrementing can be done with any step value with traffic_generator ixnetwork_540.
#x       Default value is specific to the ipv6_dst_mode as follows:
#x          incr_global_top_level decr_global_top_level: Default 4
#x          incr_global_next_level decr_global_next_level: Default 24
#x          incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: Default 48
#x          incr_mcast_group decr_mcast_group: Default 96
#x          incr_host decr_host incr_intf_id decr_intf_id: Default 96
#x          incr_network decr_network: Default 96
#x       ipv6_dst_mode specifies how and if the ipv6_dst_addr is incremented.
#x       The ipv6_dst_mode depends on the IPv6 address type specified with ipv6_dst_addr parameter.
#x       Each ipv6_dst_mode allows a mask from a Mask range to be configured.
#x       The mask is configured using the ipv6_dst_mask attribute
#x       The step used for incrementing or decrementing is configued using the 
#x       ipv6_dst_step attribute which has the form of an IPv6 address.
#x       The ipv6_dst_mask attribute specifies which part of the ipv6_dst_step 
#x       address is used for incrementing as follows:
#x            Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#x            Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#x            Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#x            Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#x       HEX values marked with 'x' in the format above are the ipv6_dst_step HEX 
#x       values that are used for increment or decrement; HEX values marked with 
#x       '0' are ignored.
#x       Valid for traffic_generator ixos/ixnetwork.
#x       Category: Layer3.IPv6
#x   -ipv6_dst_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_dst_addr
#x          1 - enable tracking by ipv6_dst_addr
#x       Category: Layer3.IPv6
#x   -ipv6_encap_seq_number
#x       Valid only for traffic_generator ixnetwork_540 and -ipv6_extension_header encapsulation.
#x       Configure 4 bytes HEX value for 'Sequence Number'.
#x       Category: Layer3.IPv6
#x   -ipv6_encap_seq_number_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_encap_seq_number 
#x       is incremeneted or decremented when ipv6_encap_seq_number_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_encap_seq_number_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_encap_seq_number. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_encap_seq_number_step and ipv6_encap_seq_number_count.
#x          decr - the value is decremented as specified with ipv6_encap_seq_number_step and ipv6_encap_seq_number_count.
#x          list - Parameter -ipv6_encap_seq_number contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_encap_seq_number_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_encap_seq_number when ipv6_encap_seq_number_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_encap_seq_number_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_encap_seq_number
#x          1 - enable tracking by ipv6_encap_seq_number
#x       Category: Layer3.IPv6
#x   -ipv6_encap_spi
#x       Valid only for traffic_generator ixnetwork_540 and -ipv6_extension_header encapsulation.
#x       Configure 'Security Parameters Index' (0-4294967295).
#x       Category: Layer3.IPv6
#x   -ipv6_encap_spi_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_encap_spi 
#x       is incremeneted or decremented when ipv6_encap_spi_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_encap_spi_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_encap_spi. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_encap_spi_step and ipv6_encap_spi_count.
#x          decr - the value is decremented as specified with ipv6_encap_spi_step and ipv6_encap_spi_count.
#x          list - Parameter -ipv6_encap_spi contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_encap_spi_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_encap_spi when ipv6_encap_spi_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_encap_spi_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_encap_spi
#x          1 - enable tracking by ipv6_encap_spi
#x       Category: Layer3.IPv6
#x   -ipv6_extension_header
#x       The type of the next extension header.  Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#x       none           - There is no next header.
#x       hop_by_hop     - Next header is hop-by-hop options.
#x       routing        - Next header has routing options.
#x       destination    - Next header has destination options.
#x       authentication - Next header is an IPSEC AH.
#x       encapsulation  - Next header is encapsulation.
#x       pseudo         - Next header is pseudo.
#x       fragment       - Payload is a fragment.
#x       Category: Layer3.IPv6
#x   -ipv6_flow_label_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_flow_label 
#x       is incremeneted or decremented when ipv6_flow_label_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_flow_label_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_flow_label. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_flow_label_step and ipv6_flow_label_count.
#x          decr - the value is decremented as specified with ipv6_flow_label_step and ipv6_flow_label_count.
#x          list - Parameter -ipv6_flow_label contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_flow_label_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_flow_label when ipv6_flow_label_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_flow_label_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_flow_label
#x          1 - enable tracking by ipv6_flow_label
#x       Category: Layer3.IPv6
#x   -ipv6_flow_version
#x       Configure flow version of the IPv6 header. Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_flow_version_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_flow_version 
#x       is incremeneted or decremented when ipv6_flow_version_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_flow_version_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_flow_version. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_flow_version_step and ipv6_flow_version_count.
#x          decr - the value is decremented as specified with ipv6_flow_version_step and ipv6_flow_version_count.
#x          list - Parameter -ipv6_flow_version contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_flow_version_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_flow_version when ipv6_flow_version_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_flow_version_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_flow_version
#x          1 - enable tracking by ipv6_flow_version
#x       Category: Layer3.IPv6
#x   -ipv6_frag_id_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_frag_id 
#x       is incremeneted or decremented when ipv6_frag_id_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_frag_id_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_frag_id. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_frag_id_step and ipv6_frag_id_count.
#x          decr - the value is decremented as specified with ipv6_frag_id_step and ipv6_frag_id_count.
#x          list - Parameter -ipv6_frag_id contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_frag_id_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_frag_id when ipv6_frag_id_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_frag_id_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_frag_id
#x          1 - enable tracking by ipv6_frag_id
#x       Category: Layer3.IPv6
#x   -ipv6_frag_more_flag_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_frag_more_flag. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -ipv6_frag_more_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_frag_more_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_frag_more_flag
#x          1 - enable tracking by ipv6_frag_more_flag
#x       Category: Layer3.IPv6
#x   -ipv6_frag_offset_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_frag_offset 
#x       is incremeneted or decremented when ipv6_frag_offset_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_frag_offset_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_frag_offset. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_frag_offset_step and ipv6_frag_offset_count.
#x          decr - the value is decremented as specified with ipv6_frag_offset_step and ipv6_frag_offset_count.
#x          list - Parameter -ipv6_frag_offset contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_frag_offset_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_frag_offset when ipv6_frag_offset_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_frag_offset_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_frag_offset
#x          1 - enable tracking by ipv6_frag_offset
#x       Category: Layer3.IPv6
#x   -ipv6_frag_res_2bit
#x       This is only for "-ipv6_extension_header fragment". 
#x       A 2-bit reserved field.
#x       (DEFAULT = 3) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_frag_res_2bit_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_frag_res_2bit 
#x       is incremeneted or decremented when ipv6_frag_res_2bit_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_frag_res_2bit_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_frag_res_2bit. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_frag_res_2bit_step and ipv6_frag_res_2bit_count.
#x          decr - the value is decremented as specified with ipv6_frag_res_2bit_step and ipv6_frag_res_2bit_count.
#x          list - Parameter -ipv6_frag_res_2bit contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_frag_res_2bit_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_frag_res_2bit when ipv6_frag_res_2bit_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_frag_res_2bit_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_frag_res_2bit
#x          1 - enable tracking by ipv6_frag_res_2bit
#x       Category: Layer3.IPv6
#x   -ipv6_frag_res_8bit
#x       This is only for "-ipv6_extension_header fragment". 
#x       An 8-bit reserved field.
#x       (DEFAULT = 30) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_frag_res_8bit_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_frag_res_8bit 
#x       is incremeneted or decremented when ipv8_frag_res_2bit_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_frag_res_8bit_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_frag_res_8bit. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_frag_res_8bit_step and ipv6_frag_res_8bit_count.
#x          decr - the value is decremented as specified with ipv6_frag_res_8bit_step and ipv6_frag_res_8bit_count.
#x          list - Parameter -ipv6_frag_res_8bit contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_frag_res_8bit_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_frag_res_8bit when ipv6_frag_res_8bit_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_frag_res_8bit_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_frag_res_8bit
#x          1 - enable tracking by ipv6_frag_res_8bit
#x       Category: Layer3.IPv6
#x   -ipv6_hop_by_hop_options
#x       This is only for "-ipv6_extension_header hop_by_hop". 
#x       This option will represent a list of keyed values. See Return Values table following -tx_ports_list. 
#x       The following types are accepted with ixnetwork_540 traffic generator: 
#x          pad1 - valid with traffic_generator ixos and ixnetwork_540
#x          padn - valid with traffic_generator ixos and ixnetwork_540
#x          user_defined - valid only with traffic generator ixnetwork_540.
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_hop_limit_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_hop_limit 
#x       is incremeneted or decremented when ipv6_hop_limit_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_hop_limit_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_hop_limit. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_hop_limit_step and ipv6_hop_limit_count.
#x          decr - the value is decremented as specified with ipv6_hop_limit_step and ipv6_hop_limit_count.
#x          list - Parameter -ipv6_hop_limit contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_hop_limit_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_hop_limit when ipv6_hop_limit_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_hop_limit_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_hop_limit
#x          1 - enable tracking by ipv6_hop_limit
#x       Category: Layer3.IPv6
#x   -ipv6_next_header_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_next_header 
#x       is incremeneted or decremented when ipv6_next_header_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_next_header_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_next_header. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_next_header_step and ipv6_next_header_count.
#x          decr - the value is decremented as specified with ipv6_next_header_step and ipv6_next_header_count.
#x          list - Parameter -ipv6_next_header contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_next_header_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_next_header when ipv6_next_header_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_next_header_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_next_header
#x          1 - enable tracking by ipv6_next_header
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_dst_addr
#x       Valid only for traffic_generator ixnetwork_540 and -ipv6_extension_header pseudo.
#x       Configure IPv6 destination address for pseudo extension header.
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_dst_addr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_pseudo_dst_addr 
#x       is incremeneted or decremented when ipv6_pseudo_dst_addr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_dst_addr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_pseudo_dst_addr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_pseudo_dst_addr_step and ipv6_pseudo_dst_addr_count.
#x          decr - the value is decremented as specified with ipv6_pseudo_dst_addr_step and ipv6_pseudo_dst_addr_count.
#x          list - Parameter -ipv6_pseudo_dst_addr contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_dst_addr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_pseudo_dst_addr when ipv6_pseudo_dst_addr_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_dst_addr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_pseudo_dst_addr
#x          1 - enable tracking by ipv6_pseudo_dst_addr
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_src_addr
#x       Valid only for traffic_generator ixnetwork_540 and -ipv6_extension_header pseudo.
#x       Configure IPv6 destination address for pseudo extension header.
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_src_addr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_pseudo_src_addr 
#x       is incremeneted or decremented when ipv6_pseudo_src_addr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_src_addr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_pseudo_src_addr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_pseudo_src_addr_step and ipv6_pseudo_src_addr_count.
#x          decr - the value is decremented as specified with ipv6_pseudo_src_addr_step and ipv6_pseudo_src_addr_count.
#x          list - Parameter -ipv6_pseudo_src_addr contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_src_addr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_pseudo_src_addr when ipv6_pseudo_src_addr_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_src_addr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_pseudo_src_addr
#x          1 - enable tracking by ipv6_pseudo_src_addr
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_uppper_layer_pkt_length
#x       Valid only for traffic_generator ixnetwork_540 and -ipv6_extension_header pseudo.
#x       Configure Upper-Layer Packet Length for pseudo extension header.
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_uppper_layer_pkt_length_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_pseudo_uppper_layer_pkt_length 
#x       is incremeneted or decremented when ipv6_pseudo_uppper_layer_pkt_length_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_uppper_layer_pkt_length_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_pseudo_uppper_layer_pkt_length. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_pseudo_uppper_layer_pkt_length_step and ipv6_pseudo_uppper_layer_pkt_length_count.
#x          decr - the value is decremented as specified with ipv6_pseudo_uppper_layer_pkt_length_step and ipv6_pseudo_uppper_layer_pkt_length_count.
#x          list - Parameter -ipv6_pseudo_uppper_layer_pkt_length contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_uppper_layer_pkt_length_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_pseudo_uppper_layer_pkt_length when ipv6_pseudo_uppper_layer_pkt_length_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_uppper_layer_pkt_length_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_pseudo_uppper_layer_pkt_length
#x          1 - enable tracking by ipv6_pseudo_uppper_layer_pkt_length
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_zero_number
#x       Valid only for traffic_generator ixnetwork_540 and -ipv6_extension_header pseudo.
#x       Configure 4 bytes HEX 'Zero' field for pseudo extension header.
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_zero_number_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_pseudo_zero_number 
#x       is incremeneted or decremented when ipv6_pseudo_zero_number_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_zero_number_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_pseudo_zero_number. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_pseudo_zero_number_step and ipv6_pseudo_zero_number_count.
#x          decr - the value is decremented as specified with ipv6_pseudo_zero_number_step and ipv6_pseudo_zero_number_count.
#x          list - Parameter -ipv6_pseudo_zero_number contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_zero_number_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_pseudo_zero_number when ipv6_pseudo_zero_number_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_pseudo_zero_number_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_pseudo_zero_number
#x          1 - enable tracking by ipv6_pseudo_zero_number
#x       Category: Layer3.IPv6
#x   -ipv6_routing_node_list 
#x       This is only for "-ipv6_extension_header routing". A list of 128-bit IPv6 addresses.   Valid only for traffic_generator ixos.
#x       Category: Layer3.IPv6
#x   -ipv6_routing_res
#x       This is only for "-ipv6_extension_header routing". 
#x       A 32-bit reserved field. 
#x       <4 HEX BYTES separated by ":" or "."> 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer3.IPv6
#x   -ipv6_routing_res_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_routing_res 
#x       is incremeneted or decremented when ipv6_routing_res_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_routing_res_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_routing_res. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_routing_res_step and ipv6_routing_res_count.
#x          decr - the value is decremented as specified with ipv6_routing_res_step and ipv6_routing_res_count.
#x          list - Parameter -ipv6_routing_res contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_routing_res_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_routing_res when ipv6_routing_res_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_routing_res_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_routing_res
#x          1 - enable tracking by ipv6_routing_res
#x       Category: Layer3.IPv6
#x   -ipv6_routing_type
#x       This is only for "-ipv6_extension_header routing". 
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure routing type (range 0-255) for 'routing' extension header.
#x       Category: Layer3.IPv6
#x   -ipv6_routing_type_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_routing_type 
#x       is incremeneted or decremented when ipv6_routing_type_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_routing_type_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_routing_type. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_routing_type_step and ipv6_routing_type_count.
#x          decr - the value is decremented as specified with ipv6_routing_type_step and ipv6_routing_type_count.
#x          list - Parameter -ipv6_routing_type contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_routing_type_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_routing_type when ipv6_routing_type_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_routing_type_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_routing_type
#x          1 - enable tracking by ipv6_routing_type
#x       Category: Layer3.IPv6
#x   -ipv6_src_mask
#x       This parameter is ignored with traffic_generator ixnetwork_540. Incrementing and 
#x       decrementing can be done with any step value with traffic_generator ixnetwork_540.
#x       Specify IPv6 mask to be used for ipv6_src_addr to increment. 
#x       Default value is minimum value specified in ipv6_src_mode (it depends 
#x       on address type and increment mode).
#x       ipv6_src_mode specifies how and if the ipv6_src_addr is incremented.
#x       The ipv6_src_mode depends on the IPv6 address type specified with ipv6_src_addr parameter.
#x       Each ipv6_src_mode allows a mask from a Mask range to be configured.
#x       The mask is configured using the ipv6_src_mask attribute
#x       The step used for incrementing or decrementing is configued using the 
#x       ipv6_src_step attribute which has the form of an IPv6 address.
#x       The ipv6_src_mask attribute specifies which part of the ipv6_src_step 
#x       address is used for incrementing as follows:
#x            Mask range 4-4, incr_global_top_level decr_global_top_level: xxxx::0
#x            Mask range 24-24, incr_global_next_level decr_global_next_level: 0:0xx:xxxx::0
#x            Mask range 48-48, incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet: 0:0:0:xxxx::0
#x            Mask range 96-96, incr_mcast_group decr_mcast_group: 0::xxxx:xxxx
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx:xxxx (when mask is 96)
#x            Mask range 96-128, incr_host decr_host incr_intf_id decr_intf_id: 0::xxxx      (when mask is 112)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0:0 (when mask is 96)
#x            Mask range 0-128, incr_network decr_network: 0::xxxx:xxxx:0   (when mask is 112)
#x       HEX values marked with 'x' in the format above are the ipv6_src_step HEX 
#x       values that are used for increment or decrement; HEX values marked with 
#x       '0' are ignored.
#x       Valid only for traffic_generator ixos.
#x       Category: Layer3.IPv6
#x   -ipv6_src_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_src_addr.
#x          1 - enable tracking by ipv6_src_addr.
#x       Category: Layer3.IPv6
#x   -ipv6_traffic_class_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the ipv6_traffic_class 
#x       is incremeneted or decremented when ipv6_traffic_class_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_traffic_class_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for ipv6_traffic_class. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with ipv6_traffic_class_step and ipv6_traffic_class_count.
#x          decr - the value is decremented as specified with ipv6_traffic_class_step and ipv6_traffic_class_count.
#x          list - Parameter -ipv6_traffic_class contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv6
#x   -ipv6_traffic_class_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify ipv6_traffic_class when ipv6_traffic_class_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv6
#x   -ipv6_traffic_class_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by ipv6_traffic_class
#x          1 - enable tracking by ipv6_traffic_class
#x       Category: Layer3.IPv6
#x   -isl
#x       Whether to enable ISL on the stream. You can then configure ISL 
#x       with options "isl_frame_type", "isl_vlan_id", "isl_user_priority", 
#x       "isl_bpdu", and "isl_index". Valid only for traffic_generator ixos and ixnetwork_540. 
#x       Valid choices are:
#x       0 - Disable ISL.
#x       1 - Enable ISL.
#x       Category: Layer2.Ethernet
#x   -isl_bpdu
#x       Whether to enable encapsulation of all Bridge Protocol Data Units by 
#x       the ISL packet. Valid only for traffic_generator ixos and ixnetwork_540. 
#x       Valid choices are:
#x       0 - (DEFAULT) Disable.
#x       1 - Enable.
#x       Category: Layer2.Ethernet
#x   -isl_bpdu_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the isl_bpdu 
#x       is incremeneted or decremented when isl_bpdu_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_bpdu_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for isl_bpdu. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with isl_bpdu_step and isl_bpdu_count.
#x          decr - the value is decremented as specified with isl_bpdu_step and isl_bpdu_count.
#x          list - Parameter -isl_bpdu contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.Ethernet
#x   -isl_bpdu_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify isl_bpdu when isl_bpdu_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_bpdu_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by isl_bpdu
#x          1 - enable tracking by isl_bpdu
#x       Category: Layer2.Ethernet
#x   -isl_frame_type
#x       Valid only for traffic_generator ixos and ixnetwork_540.
#x       Type of frame that is encapsulated. Valid options are:
#x       ethernet (default)
#x       atm
#x       fddi
#x       token_ring
#x       Category: Layer2.Ethernet
#x   -isl_frame_type_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for isl_frame_type. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -isl_frame_type contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.Ethernet
#x   -isl_frame_type_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by isl_frame_type
#x          1 - enable tracking by isl_frame_type
#x       Category: Layer2.Ethernet
#x   -isl_index
#x       Value of the selected register.
#x       (DEFAULT = 0) 
#x       Valid only for traffic_generator ixos and ixnetwork_540.
#x       Category: Layer2.Ethernet
#x   -isl_index_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the isl_index 
#x       is incremeneted or decremented when isl_index_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_index_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for isl_index. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with isl_index_step and isl_index_count.
#x          decr - the value is decremented as specified with isl_index_step and isl_index_count.
#x          list - Parameter -isl_index contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.Ethernet
#x   -isl_index_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify isl_index when isl_index_mode is incr 
#x       or decr. (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_index_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by isl_index
#x          1 - enable tracking by isl_index
#x       Category: Layer2.Ethernet
#x   -isl_mac_dst
#x       Valid only for traffic_generator ixnetwork_540.
#x       Mac address used to configure the destination mac address from the Cisco ISL header. 
#x       This is not a real MAC Address, this is actually a 40 bits hex.
#x       (DEFAULT 00.00.00.00.00)
#x       Category: Layer2.Ethernet
#x   -isl_mac_dst_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the isl_mac_dst 
#x       is incremeneted or decremented when isl_mac_dst_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_mac_dst_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for isl_mac_dst. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with isl_mac_dst_step and isl_mac_dst_count.
#x          decr - the value is decremented as specified with isl_mac_dst_step and isl_mac_dst_count.
#x          list - Parameter -isl_mac_dst contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.Ethernet
#x   -isl_mac_dst_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Mac address step value used to modify isl_mac_dst when isl_mac_dst_mode is incr 
#x       or decr. This is not actually a mac address, this is a 40 bits hex.
#x       (DEFAULT = 00.00.00.00.01)
#x       Category: Layer2.Ethernet
#x   -isl_mac_dst_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by isl_mac_dst
#x          1 - enable tracking by isl_mac_dst
#x       Category: Layer2.Ethernet
#x   -isl_mac_src_high
#x       Valid only for traffic_generator ixnetwork_540.
#x       Hex value used to configure the high 24 bits of the source mac address 
#x       from the Cisco ISL header.
#x       (DEFAULT 0x000000)
#x       Category: Layer2.Ethernet
#x   -isl_mac_src_high_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the isl_mac_src_high 
#x       is incremeneted or decremented when isl_mac_src_high_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_mac_src_high_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for isl_mac_src_high. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with isl_mac_src_high_step and isl_mac_src_high_count.
#x          decr - the value is decremented as specified with isl_mac_src_high_step and isl_mac_src_high_count.
#x          list - Parameter -isl_mac_src_high contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.Ethernet
#x   -isl_mac_src_high_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Hex step value used to modify isl_mac_src_high when isl_mac_src_high_mode is incr 
#x       or decr.
#x       (DEFAULT = 0x01)
#x       Category: Layer2.Ethernet
#x   -isl_mac_src_high_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by isl_mac_src_high
#x          1 - enable tracking by isl_mac_src_high
#x       Category: Layer2.Ethernet
#x   -isl_mac_src_low
#x       Valid only for traffic_generator ixnetwork_540.
#x       Hex value used to configure the low 24 bits of the source mac address 
#x       from the Cisco ISL header.
#x       (DEFAULT 0x000000)
#x       Category: Layer2.Ethernet
#x   -isl_mac_src_low_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the isl_mac_src_low 
#x       is incremeneted or decremented when isl_mac_src_low_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_mac_src_low_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for isl_mac_src_low. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with isl_mac_src_low_step and isl_mac_src_low_count.
#x          decr - the value is decremented as specified with isl_mac_src_low_step and isl_mac_src_low_count.
#x          list - Parameter -isl_mac_src_low contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.Ethernet
#x   -isl_mac_src_low_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Hex step value used to modify isl_mac_src_low when isl_mac_src_low_mode is incr 
#x       or decr.
#x       (DEFAULT = 0x01)
#x       Category: Layer2.Ethernet
#x   -isl_mac_src_low_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by isl_mac_src_low
#x          1 - enable tracking by isl_mac_src_low
#x       Category: Layer2.Ethernet
#x   -isl_user_priority
#x       Low order two bits of this value specify the priority of the packet as 
#x       it passes through the switch. Valid choices are between 0 and 7, 
#x       inclusive.
#x       (DEFAULT = 0) 
#x       Valid only for traffic_generator ixos and ixnetwork_540.
#x       Category: Layer2.Ethernet
#x   -isl_user_priority_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the isl_user_priority 
#x       is incremeneted or decremented when isl_user_priority_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_user_priority_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for isl_user_priority. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with isl_user_priority_step and isl_user_priority_count.
#x          decr - the value is decremented as specified with isl_user_priority_step and isl_user_priority_count.
#x          list - Parameter -isl_user_priority contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.Ethernet
#x   -isl_user_priority_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify isl_user_priority when isl_user_priority_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_user_priority_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by isl_user_priority
#x          1 - enable tracking by isl_user_priority
#x       Category: Layer2.Ethernet
#x   -isl_vlan_id
#x       Virtual LAN identification. Valid choices are between 1 and 4096, 
#x       inclusive. 
#x       (DEFAULT = 1) 
#x       Valid only for traffic_generator ixos and ixnetwork_540.
#x       Category: Layer2.Ethernet
#x   -isl_vlan_id_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the isl_vlan_id 
#x       is incremeneted or decremented when isl_vlan_id_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_vlan_id_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for isl_vlan_id. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with isl_vlan_id_step and isl_vlan_id_count.
#x          decr - the value is decremented as specified with isl_vlan_id_step and isl_vlan_id_count.
#x          list - Parameter -isl_vlan_id contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.Ethernet
#x   -isl_vlan_id_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify isl_vlan_id when isl_vlan_id_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.Ethernet
#x   -isl_vlan_id_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by isl_vlan_id
#x          1 - enable tracking by isl_vlan_id
#x       Category: Layer2.Ethernet
#x   -l3_length_step
#x       Step size by which the packet size will be incremented.  Use this 
#x       option in conjunction with option "length_mode" set to increment. 
#x       Valid only for traffic_generator ixos.
#x       Category: General.Frame Size
#x   -lan_range_count
#x       This option is used to specify the number of LAN static endpoint 
#x       ranges. It can take any numeric value. 
#x       Valid only for traffic_generator ixnetwork when configuring L2VPN traffic.
#x       Category: Layer2.L2VPN
#x   -latency_bins
#x       Valid only for traffic_generator ixnetwork_540. Configure the number of bins. 
#x       for the traffic item being configured. 
#x       For this configuration to be valid latency bins, jitter or delay measurement 
#x       global statistics must be enabled with ::ixia::traffic_control.
#x       Category: General.Tracking
#x   -latency_bins_enable
#x       Valid only for traffic_generator ixnetwork_540. Enable or disable latency_bins 
#x       for the traffic item being configured. Valid options are:
#x          0 - Default
#x          1 -  
#x       For this configuration to be valid latency bins, jitter or delay measurement 
#x       global statistics must be enabled with ::ixia::traffic_control.
#x       Category: General.Tracking
#x   -latency_values
#x       The splitting values for the bins. 0 and Max will be the absolute end 
#x       points. A list of {1.5 3 6.8} would create these four bins {0 - 1.5} 
#x       {1.5 3} {3 6.8} {6.8 MAX}. It is always greater than the lower value 
#x       and equal to or less than the upper value. 
#x       Valid for traffic_generator ixnetwork_540. 
#x       Otherwise, it will be ignored. 
#x       For this configuration to be valid latency bins, jitter or delay measurement 
#x       global statistics must be enabled with ::ixia::traffic_control.
#x       Category: General.Tracking
#x   -loop_count
#x       When in packet mode and stream is set to return to id for a count, 
#x       this is the count value for how many times to loop before stopping. 
#x       Valid only for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -mac_dst_count_step
#x       This option is used to specify the step between the value of the 
#x       MAC address count of each the LAN static endpoint range. It can 
#x       take any numeric value. 
#x       Valid for traffic_generator ixnetwork when configuring L2VPN traffic.
#x       Category: Layer2.L2VPN
#x   -mac_dst_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 (default) - disable tracking by mac_dst
#x          1 - enable tracking by mac_dst
#x       Category: Layer2.Ethernet
#x   -mac_src_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 (default) - disable tracking by mac_src
#x          1 - enable tracking by mac_src
#x       Category: Layer2.Ethernet
#x   -merge_destinations
#x       Valid only for traffic_generator ixnetwork_540.
#x       Valid choices are:
#x          0 - disable merging of traffic item destinations
#x          1 - enable merging of traffic item destinations
#x       Category: General.Common
#x   -min_gap_bytes
#x       The minimum gap, in bytes, between sending packets.
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -mpls
#x       Whether to enable MPLS on a particular stream. When enabled, configure 
#x       the MPLS parameters by usgin the options "mpls_labels", "mpls_ttl", 
#x       "mpls_exp_bit", "mpls_bottom_of_stack", and "mpls_type". Refer to 
#x       Section "Scripts Samples" for an example. 
#x       Valid only for traffic_generator ixnetwork_540 and ixos.
#x       Category: Layer2.MPLS
#x   -mpls_bottom_stack_bit
#x       Whether to enable the bottom of the stack bit. This bit is set to true 
#x       for the last entry in the label stack (for the bottom of the stack) 
#x       and false for all other label stack entries.
#x       (DEFAULT = 1) 
#x       Valid only for traffic_generator ixos and ixnetwork_540.
#x       Category: Layer2.MPLS
#x   -mpls_bottom_stack_bit_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the mpls_bottom_stack_bit 
#x       is incremeneted or decremented when mpls_labels_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.MPLS
#x   -mpls_bottom_stack_bit_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify mpls_bottom_stack_bit when mpls_bottom_stack_bit_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.MPLS
#x   -mpls_bottom_stack_bit_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for mpls_bottom_stack_bit. Valid choices are: 
#x          fixed (default) - the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with mpls_bottom_stack_bit_step and mpls_bottom_stack_bit_count.
#x          decr - the value is decremented as specified with mpls_bottom_stack_bit_step and mpls_bottom_stack_bit_count.
#x          list - Parameter -mpls_bottom_stack_bit contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.MPLS
#x   -mpls_bottom_stack_bit_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 (default) - disable tracking by mpls_bottom_stack_bit
#x          1 - enable tracking by mpls_bottom_stack_bit
#x       Category: Layer2.MPLS
#x   -mpls_exp_bit
#x       Sets the experimental use bit. Valid choices are between 0 and 7, 
#x       inclusive. If mpls_exp_bit_mode is list, you can use a list of values 
#x       from 0-7 (example: 0,1,2,3,4). When modifying this parameter the user 
#x       must set the mpls attribute to enable.
#x       Valid only for traffic_generator ixos and ixnetwork_540.
#x       (DEFAULT = 0)
#x       Category: Layer2.MPLS
#x   -mpls_exp_bit_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the mpls_exp_bit 
#x       is incremeneted or decremented when mpls_exp_bit_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.MPLS
#x   -mpls_exp_bit_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for mpls_exp_bit. Valid choices are: 
#x          fixed (default) - the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with mpls_exp_bit_step and mpls_exp_bit_count.
#x          decr - the value is decremented as specified with mpls_exp_bit_step and mpls_exp_bit_count.
#x          list - Parameter -mpls_exp_bit contains a list of values (example: 0,2,3,5,7). Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.MPLS
#x   -mpls_exp_bit_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify mpls_exp_bit when mpls_exp_bit_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.MPLS
#x   -mpls_exp_bit_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 (default) - disable tracking by mpls_exp_bit
#x          1 - enable tracking by mpls_exp_bit
#x       Category: Layer2.MPLS
#x   -mpls_labels_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the mpls_labels 
#x       is incremeneted or decremented when mpls_labels_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.MPLS
#x   -mpls_labels_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for mpls_labels. Valid choices are: 
#x          fixed (default) - the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with mpls_labels_step and mpls_labels_count.
#x          decr - the value is decremented as specified with mpls_labels_step and mpls_labels_count.
#x          list - Parameter -mpls_labels contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.MPLS
#x   -mpls_labels_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify mpls_labels when mpls_labels_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.MPLS
#x   -mpls_labels_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 (default) - disable tracking by mpls_labels
#x          1 - enable tracking by mpls_labels
#x       Category: Layer2.MPLS
#x   -mpls_ttl
#x       Time-to-live value for a particular tag in a stream. Valid choices are 
#x       between 0 and 255, inclusive.
#x       (DEFAULT = 64) 
#x       Valid only for traffic_generator ixos and ixnetwork_540.
#x       Category: Layer2.MPLS
#x   -mpls_ttl_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the mpls_ttl 
#x       is incremeneted or decremented when mpls_ttl_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.MPLS
#x   -mpls_ttl_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for mpls_ttl. Valid choices are: 
#x          fixed (default) - the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with mpls_ttl_step and mpls_ttl_count.
#x          decr - the value is decremented as specified with mpls_ttl_step and mpls_ttl_count.
#x          list - Parameter -mpls_ttl contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.MPLS
#x   -mpls_ttl_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify mpls_ttl when mpls_ttl_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.MPLS
#x   -mpls_ttl_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 (default) - disable tracking by mpls_ttl
#x          1 - enable tracking by mpls_ttl
#x       Category: Layer2.MPLS
#x   -mpls_type
#x       MPLS type. Valid choices are:
#x       Unicast   - (default)
#x       Multicast - Valid only for traffic_generator ixos.
#x       Category: Layer2.MPLS
#x   -multiple_queues
#x       This argument is used to specify the fact that the new steams will be 
#x       created on different stream queues (this applies only to ATM ports). 
#x       A maximum number of 15 queues can be created. These 15 queues will be 
#x       populated with streams in a round-robin fashion if  
#x       the -multiple_queues option will be used alone. If the -queue_id option is 
#x       used, the new stream will be added to the specified stream queue and 
#x       the round-robin mechanism will be circumvented.  
#x       Valid only for traffic_generator ixos. 
#x       Category: Stream Control and Data.Rate Control
#x   -name
#x       Stream string identifier/name. For ixnetwork 540+ traffic, if this name 
#x       contains spaces, the spaces will be translated to underscores and a warning 
#x       will be displayed. The string name must not contain commas.
#x       Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
#x       Category: General.Common
#x   -tag_filter
#x       This parameter specifies the filter regarding which tagged scenario 
#x       items will be used to run traffic. 
#x       Has the following format (for each endpoint set): list of <1. tag name, 2. tag id list>. 
#x       Eg. [list [list group1 [list 1 2] group2 [list 10]]] 
#x       Category: General.Endpoint Data
#x   -no_write
#x       Whether to enable procedure "traffic_config" to commit change to the 
#x       hardware. Enable this option when the you want to create multiple 
#x       streams on a single port by using a loop. Because committing the 
#x       configuration to hardware can take .5 seconds, this option allows you 
#x       to save the configuration after the procedure call. 
#x       Valid only for traffic_generator ixos.
#x       Category: General.Common
#x   -num_dst_ports
#x       This argument can be used to specify the number of ports on which the 
#x       video server will be running in Triple Play tests. 
#x       Valid only for traffic_generator ixnetwork, mode create/modify, 
#x       circuit_endpoint_type ipv4_application_traffic/ipv6_application_traffic.
#x       Category: Layer4-7.Application Traffic
#x   -number_of_packets_per_stream
#x       Number of maximum frames in the stream. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -number_of_packets_tx
#x       The number of packets that are to be transmitted in the stream 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -override_value_list
#x       This argument can be used to specify the list of tracking values that 
#x       will be used to label the generated traffic.
#x       Valid only for traffic_generator ixnetwork and with the 
#x       assured_forwarding_phb, class_selector_phb, default_phb, 
#x       expedited_forwarding_phb, tos, raw_priority, inner_vlan, custom_8bit, 
#x       custom_16bit, custom_24bit and custom_32bit choices of the -track_by 
#x       argument.
#x       The list has the following structure:
#x       assured_forwarding_phb: {{unused_bits af_class codepoint} {unused_bits  af_class codepoint} ...}
#x          where:  unused_bits     - 2 bit integer value
#x                  af_class        - integer value in the [1,4] interval
#x                  codepoint       - value in the {low,medium,high} set
#x       class_selector_phb: {{unused_bits precedence} {unused_bits precedence} ...}
#x          where:  unused_bits     - 2 bit integer value
#x                  precedence      - integer value in the [1,7] interval
#x       default_phb: {{unused_bits codepoint} {unused_bits codepoint} ...}
#x          where:  unused_bits     - 2 bit integer value
#x                  codepoint       - 6 bit integer value, in decimal format
#x       expedited_forwarding_phb: {{unused_bits codepoint} {unused_bits codepoint} ...}
#x          where:  unused_bits     - 2 bit integer value
#x                  codepoint       - 6 bit integer value, in decimal format
#x       tos: {{unused_bit monetary reliability throughput delay precedence} {unused_bit monetary reliability throughput delay precedence} ...}
#x          where:  unused_bit      - 1 bit value
#x                  monetary        - value in the {normal,minimize} set
#x                  reliability     - value in the {normal,high} set
#x                  throughput      - value in the {normal,high} set
#x                  delay           - value in the {normal,low} set
#x                  precedence      - value in the {routine,priority,immediate,flash,,flash_override,critical_ecp,internetwork_contol,network_contol} set
#x       raw_priority: {raw_priority raw_priority ...}
#x          where:  raw_priority    - 8 bit integer value, in decimal format
#x       inner_vlan: {{vlan_id cfi user_priority} {vlan_id cfi user_priority} ...}
#x          where:  vlan_id         - 12 bit integer value, in decimal format
#x                  cfi             - 1 bit value
#x                  user_priority   - 3 bit integer value
#x       custom_8bit: {custom_value custom_value ...}
#x          where:  unused_bit      - 8 bit integer value, in decimal format
#x       custom_16bit: {custom_value custom_value ...}
#x          where:  unused_bit      - 16 bit integer value, in decimal format
#x       custom_24bit: {custom_value custom_value ...}
#x          where:  unused_bit      - 24 bit integer value, in decimal format
#x       custom_32bit: {custom_value custom_value ...}
#x          where:  unused_bit      - 32 bit integer value, in decimal format
#x       Category: General.Tracking
#x   -pause_control_time
#x       Pause control time. Valid choices are between 0 and 65535, inclusive. 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.Rate Control
#x   -pending_operations_timeout
#x       This timeout is implemented for the async protocols. It represents a timer in seconds for the pending operations to end.
#x       (DEFAULT = 10)
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -pgid_offset
#x       The offset at which the PGID will be set. Valid only for traffic_generator ixos.
#x       Category: General.Instrumentation/Flow Group
#x   -pgid_value
#x       Unique value used to identify one packet group for another. 
#x       Up to 57344 different packet groups may be defined. 
#x       This parameter can take a list of values as follows: when traffic is 
#x       configured bidirectional and this parameter has one value, this value 
#x       will be set on both streams. When this parameter has a list of two 
#x       values the first value will be assigned to the first stream and the 
#x       second value to the second stream.
#x       (DEFAULT = current stream id) 
#x       Valid only for traffic_generator ixos.
#x       Category: General.Instrumentation/Flow Group
#x  -preamble_size_mode
#x       Used to set the preamble mode on a high level stream.
#x       auto - Automatic preamble size.
#x       custom - Preamble size will be given by parameter preamble_custom_size.
#x       (DEFAULT = auto)
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Frame Setup.Preamble Size
#x  -preamble_custom_size
#x       Provides the preamble size (measured in bytes) for a high level stream 
#x       only when the preamble size mode is set to custom. The default value is 6.
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Frame Setup.Preamble Size
#x   -pt_handle
#x       The protocol template handle used to manipulate headers. This handle is obtained 
#x       when using mode "get_available_protocol_templates" and it is presented in a 
#x       user friendly format.
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Frame Setup.Preamble Size
#x   -public_port_ip
#x       The IP address of the client as received from the PPPoE/L2TP 
#x       server. This address is used only for an IPv4 Access port to 
#x       match the traffic to a particular PPPoE/L2TP session.
#x       Valid only for traffic_generator ixos.
#x       Category: IxAccess.IxAccess
#x   -pvc_count
#x       This option is used to specify the number of PVCs created on the 
#x       first ATM static endpoint range. It can take any value in the 
#x       0-4294967295 range. 
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: Layer2.L2VPN
#x   -pvc_count_step
#x       This option is used to specify the step between the number of PVCs 
#x       created on each ATM static endpoint range. It can take any numeric 
#x       value. 
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: Layer2.L2VPN
#x   -qos_byte
#x       The combined value for the precedence, delay, throughput, reliability, 
#x       reserved and cost bits. 
#x       This is only for PPP, L2TP and L2TPv3 traffic when using traffic_generator ixnetwork.
#x       (DEFAULT = 0) 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer3.IPv4
#x   -qos_byte_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the qos_byte 
#x       is incremeneted or decremented when qos_byte_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -qos_byte_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for qos_byte. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with qos_byte_step and qos_byte_count.
#x          decr - the value is decremented as specified with qos_byte_step and qos_byte_count.
#x          list - Parameter -qos_byte contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -qos_byte_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify qos_byte when qos_byte_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -qos_byte_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by qos_byte
#x          1 - enable tracking by qos_byte
#x       Category: Layer3.IPv4
#x   -qos_ipv6_flow_label
#x       The IPv6 flow label, from 0 through 1,048,575. 
#x       Valid only if -encap is an ethernet encapsulation. 
#x       (DEFAULT = 0) 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer3.IPv4
#x   -qos_ipv6_traffic_class
#x       The IPv6 traffic class, from 0 through 255. 
#x       Valid only if -encap is an ethernet encapsulation. 
#x       (DEFAULT = 0) 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer3.IPv4
#x   -qos_type_ixn
#x       Sets the Quality of Service type. Possible values include:
#x          custom = A custom QoS type. With traffic_generator ixnetwork_540 use this in combination with parameters: qos_value_ixn, qos_value_ixn_mode, qos_value_ixn_step, qos_value_ixn_count, qos_value_ixn_tracking.
#x          dscp = User DSCP as the QoS. With traffic_generator ixnetwork_540 use this in combination with parameters: qos_value_ixn. The rest of the depending parameters are specified based on the value of qos_value_ixn.
#x          tos = Use ToS as the QoS.  With traffic_generator ixnetwork_540 configure precedence using qos_value_ixn, qos_value_ixn_mode, qos_value_ixn_step, qos_value_ixn_count, qos_value_ixn_tracking OR 
#x              ip_precedence, ip_precedence_mode, ip_precedence_step, ip_precedence_count, ip_precedence_tracking. The rest of the TOS bits are configured 
#x              using parameters: ip_delay, ip_delay_mode, ip_delay_tracking, ip_throughput, ip_throughput_mode, ip_throughput_tracking, ip_reliability, ip_reliability_mode, ip_reliability_tracking 
#x              ip_cost, ip_cost_mode, ip_cost_tracking.
#x          ipv6 = Use IPv6 as the QoS. (used when circuit_endpoint_type is ipv6. Only for traffic_generator ixnetwork)
#x       (DEFAULT = tos)
#x       Valid for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: Layer3.IPv4
#x   -qos_value_ixn
#x       The QoS value for this traffic stream. Depending on what type of QoS is 
#x       selected the following values are accepted:
#x       1. When -qos_type_ixn tos = a value in the [0 - 7] range specifying ToS traffic priority
#x           "0" = Routine (DEFAULT)
#x           "1" = Priority
#x           "2" = Immediate
#x           "3" = Flash
#x           "4" = Flash Override
#x           "5" = CRITIC/ECP
#x           "6" = Internet Control
#x           "7" = Network Control
#x          With traffic_generator ixnetwork_540 configure precedence using qos_value_ixn, qos_value_ixn_mode, qos_value_ixn_step, qos_value_ixn_count, qos_value_ixn_tracking OR 
#x          ip_precedence, ip_precedence_mode, ip_precedence_step, ip_precedence_count, ip_precedence_tracking. The rest of the TOS bits are configured 
#x          using parameters: ip_delay, ip_delay_mode, ip_delay_tracking, ip_throughput, ip_throughput_mode, ip_throughput_tracking, ip_reliability, ip_reliability_mode, ip_reliability_tracking 
#x          ip_cost, ip_cost_mode, ip_cost_tracking. 
#x       2. When -qos_type_ixn dscp
#x          "dscp_default" (DEFAULT) = any traffic that does not meet the 
#x            requirements of any of the other defined classes is placed in the 
#x            default PHB. Typically, the default PHB has best-effort forwarding 
#x            characteristics. For traffic_generator ixnetwork_540 with qos_value_ixn 'dscp_default' the 
#x            following parameters can also be configured: ip_dscp, ip_dscp_mode, ip_dscp_count, ip_dscp_step, ip_dscp_tracking, ip_cu, ip_cu_mode, ip_cu_count, ip_cu_step, ip_cu_tracking.
#x            Assured Fowarding PHB allows the operator to provide assurance of 
#x            delivery as long as the traffic does not exceed some subscribed rate.
#x            Traffic that exceeds the subscription rate faces a higher probability 
#x            of being dropped if congestion occurs. 
#x            The following AF options are available:
#x              "af_class1_low_precedence" (Assured Forwarding PHB, Class 1, Low Precendence)
#x              "af_class1_medium_precedence" (Assured Forwarding PHB, Class 1, Medium Precendence)
#x              "af_class1_high_precedence" (Assured Forwarding PHB, Class 1, High Precendence)
#x              "af_class2_low_precedence" (Assured Forwarding PHB, Class 2, Low Precendence)
#x              "af_class2_medium_precedence" (Assured Forwarding PHB, Class 2, Medium Precendence)
#x              "af_class2_high_precedence" (Assured Forwarding PHB, Class 2, High Precendence)
#x              "af_class3_low_precedence" (Assured Forwarding PHB, Class 3, Low Precendence)
#x              "af_class3_medium_precedence" (Assured Forwarding PHB, Class 3, Medium Precendence)
#x              "af_class3_high_precedence" (Assured Forwarding PHB, Class 3, High Precendence)
#x              "af_class4_low_precedence" (Assured Forwarding PHB, Class 4, Low Precendence)
#x              "af_class4_medium_precedence" (Assured Forwarding PHB, Class 4, Medium Precendence)
#x              "af_class4_high_precedence" (Assured Forwarding PHB, Class 4, High Precendence)
#x              "ef" - the EF PHB has the characteristics of low delay, low loss and 
#x                 low jitter. These characteristics are suitable for voice, video 
#x                 and other realtime services. EF traffic is often given strict 
#x                 priority queuing above all other traffic classes. Because an 
#x                 overload of EF traffic will cause queuing delays and affect 
#x                 the jitter and delay tolerances within the class, EF traffic 
#x                 is often strictly controlled through admission control, policing 
#x                 and other mechanisms.
#x           Class Selector PHB is used to maintain backward compatibility with network devices that still use the Precedence field, giving the following options:
#x             "cs_precedence1" (Class Selector PHB, Precedence 1)
#x             "cs_precedence2" (Class Selector PHB, Precedence 2)
#x             "cs_precedence3" (Class Selector PHB, Precedence 3)
#x             "cs_precedence4" (Class Selector PHB, Precedence 4)
#x             "cs_precedence5" (Class Selector PHB, Precedence 5)
#x             "cs_precedence6" (Class Selector PHB, Precedence 6)
#x             "cs_precedence7" (Class Selector PHB, Precedence 7)
#x       3. When -qos_type_ixn custom
#x            a value in the [0 - 255] range (DEFAULT 0). With traffic_generator ixnetwork_540 the following parameters are also available: qos_type_ixn_mode, qos_type_ixn_step, qos_type_ixn_count, qos_type_ixn_tracking.
#x       4. When -qos_type_ixn ipv6
#x            a value in the [0 - 255] range (DEFAULT 0) (Only available with traffic_generator ixnetwork_540)
#x       Valid for traffic_generator ixnetwork/ixnetwork_540.
#x       An error is returned if qos_value_ixn does not have any of the choices above.
#x       qos_value_ixn is set to default if it is one of the choices above but not 
#x       one that is valid for the configured qos_type_ixn.
#x       Category: Layer3.IPv4
#x   -qos_value_ixn_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the qos_value_ixn 
#x       is incremeneted or decremented when qos_value_ixn_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -qos_value_ixn_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for qos_value_ixn. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with qos_value_ixn_step and qos_value_ixn_count.
#x          decr - the value is decremented as specified with qos_value_ixn_step and qos_value_ixn_count.
#x          list - Parameter -qos_value_ixn contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer3.IPv4
#x   -qos_value_ixn_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify qos_value_ixn when qos_value_ixn_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer3.IPv4
#x   -qos_value_ixn_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by qos_value_ixn
#x          1 - enable tracking by qos_value_ixn
#x       Category: Layer3.IPv4
#x   -queue_id
#x       This argument is used to specify the queue in which the stream should 
#x       be created. The queue must already exist or, at least, be the next in 
#x       line to be created. If, for example, the 1, 2 and 3 queues exist, a 
#x       valid value for this option would be 1, 2, 3 or 4. This option has 
#x       meaning only if the -multiple_queues option is enabled. 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.Rate Control
#x   -ramp_up_percentage
#x       This argument can be used to specify how fast the objective value is 
#x       to be ramped up. 
#x       Valid only for traffic_generator ixnetwork, mode create/modify and 
#x       circuit_endpoint_type ipv4_application_traffic or 
#x       ipv6_application_traffic. The -enable_test_objective argument must be 
#x       set to 1 in order for the value of this argument to be used.
#x       Category: Layer4-7.Application Traffic
#x   -range_per_spoke
#x       This option can be used to specify the number of LAN static endpoints 
#x       that are going to be connected through one ATM or Frame Relay endpoint.
#x       Valid only for traffic_generator ixnetwork when configuring L2VPN traffic
#x       and only if the -indirect option is enabled.
#x       (DEFAULT = 1)
#x       Category: Layer2.L2VPN
#x   -rate_kbps
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. 
#x       Traffic rate to send in kbps. Valid only for traffic_generator ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -rate_mbps
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. 
#x       Traffic rate to send in mbps. Valid only for traffic_generator ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -rate_byteps
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. 
#x       Traffic rate to send in bytes per sec. Valid only for traffic_generator ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -rate_kbyteps
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. 
#x       Traffic rate to send in kbytes per sec. Valid only for traffic_generator ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -rate_mbyteps
#x       This parameter can be updated while the traffic is running with -mode 'dynamic_update' 
#x       and -stream_id <traffic_item_handle>. 
#x       Traffic rate to send in mbytes per sec. Valid only for traffic_generator ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -rate_mode
#x       This parameter denotes which rate parameter will be used. 
#x       Valid choices are: 
#x       first_option_provided - The first provided parameter will be used. The order in which the
#x          parameters are provided is the following: -rate_bps, -rate_kbps, -rate_mbps, -rate_byteps, 
#x          -rate_kbyteps, -rate_mbyteps, -rate_percent, -rate_pps
#x       bps - The -rate_bps parameter will be used. If it doesn't exist, the first parameter from the list
#x             specified in the first_option_provided will be used.
#x       kbps - The -rate_kbps parameter will be used. If it doesn't exist, the first parameter from the list
#x             specified in the first_option_provided will be used.
#x       mbps - The -rate_mbps parameter will be used. If it doesn't exist, the first parameter from the list
#x             specified in the first_option_provided will be used.
#x       byteps - The -rate_byteps parameter will be used. If it doesn't exist, the first parameter from the list
#x             specified in the first_option_provided will be used.
#x       kbyteps - The -rate_kbyteps parameter will be used. If it doesn't exist, the first parameter from the list
#x             specified in the first_option_provided will be used.
#x       mbyteps - The -rate_mbyteps parameter will be used. If it doesn't exist, the first parameter from the list
#x             specified in the first_option_provided will be used.
#x       percent - The -rate_percent parameter will used. If it doesn't exist, the first parameter from the list
#x             specified in the first_option_provided will be used.
#x       pps - The -rate_pps percent parameter will used. If it doesn't exist, the first parameter from the list
#x             specified in the first_option_provided will be used.
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -return_to_id
#x       When in packet mode, tells this stream to return to a specific stream 
#x       it after it is sent 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -rip_command
#x       For option "l4_protocol" set to "rip", this option defines the RIP 
#x       command for a particular stream.  Valid only for traffic_generator ixos/ixnetwork_540. 
#x       Valid options are:
#x           request
#x           response
#x           trace_on
#x           trace_off
#x           reserved
#x       Category: Layer4-7.RIP
#x   -rip_command_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_command. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -rip_command contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.RIP
#x   -rip_command_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_command
#x          1 - enable tracking by rip_command
#x       Category: Layer4-7.RIP
#x   -rip_rte_addr_family_id
#x       Valid only for traffic_generator ixnetwork_540 and l4_protocol set to rip. 
#x       Configure 2 bytes HEX Routing Table Entry Address Family Identifier. To configure  
#x       Address Family Identifier for multiple Routing Table Entries specify this parameter 
#x       as list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_addr_family_id_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the rip_rte_addr_family_id 
#x       is incremeneted or decremented when rip_rte_addr_family_id_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_addr_family_id_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_rte_addr_family_id. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with rip_rte_addr_family_id_step and rip_rte_addr_family_id_count.
#x          decr - the value is decremented as specified with rip_rte_addr_family_id_step and rip_rte_addr_family_id_count.
#x       Category: Layer4-7.RIP
#x   -rip_rte_addr_family_id_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify rip_rte_addr_family_id when rip_rte_addr_family_id_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_addr_family_id_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_rte_addr_family_id
#x          1 - enable tracking by rip_rte_addr_family_id
#x       Category: Layer4-7.RIP
#x   -rip_rte_ipv4_addr
#x       Valid only for traffic_generator ixnetwork_540 and l4_protocol set to rip. 
#x       Configure Routing Table Entry IPv4 Address field. To configure  
#x       IPv4 Address for multiple Routing Table Entries specify this parameter 
#x       as list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_ipv4_addr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the rip_rte_ipv4_addr 
#x       is incremeneted or decremented when rip_rte_ipv4_addr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_ipv4_addr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_rte_ipv4_addr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with rip_rte_ipv4_addr_step and rip_rte_ipv4_addr_count.
#x          decr - the value is decremented as specified with rip_rte_ipv4_addr_step and rip_rte_ipv4_addr_count.
#x       Category: Layer4-7.RIP
#x   -rip_rte_ipv4_addr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify rip_rte_ipv4_addr when rip_rte_ipv4_addr_mode is incr 
#x       or decr.
#x       Category: Layer4-7.RIP
#x   -rip_rte_ipv4_addr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_rte_ipv4_addr
#x          1 - enable tracking by rip_rte_ipv4_addr
#x       Category: Layer4-7.RIP
#x   -rip_rte_metric
#x       Valid only for traffic_generator ixnetwork_540 and l4_protocol. 
#x       Configure Routing Table Entry Metric field. To configure  
#x       Metric for multiple Routing Table Entries specify this parameter 
#x       as list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_metric_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the rip_rte_metric 
#x       is incremeneted or decremented when rip_rte_metric_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_metric_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_rte_metric. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with rip_rte_metric_step and rip_rte_metric_count.
#x          decr - the value is decremented as specified with rip_rte_metric_step and rip_rte_metric_count.
#x          list - Parameter -rip_rte_metric contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_metric_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify rip_rte_metric when rip_rte_metric_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_metric_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_rte_metric
#x          1 - enable tracking by rip_rte_metric
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused2
#x       Valid only for traffic_generator ixnetwork_540 and l4_protocol set to rip and 
#x       and rip_version 1. 
#x       Configure Routing Table Entry Unused2 field. To configure  
#x       Unused2 for multiple Routing Table Entries specify this parameter 
#x       as list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused2_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the rip_rte_v1_unused2 
#x       is incremeneted or decremented when rip_rte_v1_unused2_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused2_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_rte_v1_unused2. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with rip_rte_v1_unused2_step and rip_rte_v1_unused2_count.
#x          decr - the value is decremented as specified with rip_rte_v1_unused2_step and rip_rte_v1_unused2_count.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused2_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify rip_rte_v1_unused2 when rip_rte_v1_unused2_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused2_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_rte_v1_unused2
#x          1 - enable tracking by rip_rte_v1_unused2
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused3
#x       Valid only for traffic_generator ixnetwork_540 and l4_protocol set to rip and 
#x       and rip_version 1. 
#x       Configure Routing Table Entry Unused3 field. To configure  
#x       Unused3 for multiple Routing Table Entries specify this parameter 
#x       as list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused3_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the rip_rte_v1_unused3 
#x       is incremeneted or decremented when rip_rte_v1_unused3_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused3_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_rte_v1_unused3. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with rip_rte_v1_unused3_step and rip_rte_v1_unused3_count.
#x          decr - the value is decremented as specified with rip_rte_v1_unused3_step and rip_rte_v1_unused3_count.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused3_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify rip_rte_v1_unused3 when rip_rte_v1_unused3_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused3_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_rte_v1_unused3
#x          1 - enable tracking by rip_rte_v1_unused3
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused4
#x       Valid only for traffic_generator ixnetwork_540 and l4_protocol set to rip and 
#x       and rip_version 1. 
#x       Configure Routing Table Entry Unused4 field. To configure  
#x       Unused4 for multiple Routing Table Entries specify this parameter 
#x       as list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused4_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the rip_rte_v1_unused4 
#x       is incremeneted or decremented when rip_rte_v1_unused4_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused4_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_rte_v1_unused4. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with rip_rte_v1_unused4_step and rip_rte_v1_unused4_count.
#x          decr - the value is decremented as specified with rip_rte_v1_unused4_step and rip_rte_v1_unused4_count.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused4_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify rip_rte_v1_unused4 when rip_rte_v1_unused4_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v1_unused4_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_rte_v1_unused4
#x          1 - enable tracking by rip_rte_v1_unused4
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_next_hop
#x       Valid only for traffic_generator ixnetwork_540 and l4_protocol rip and 
#x       and rip_version 2. 
#x       Configure Routing Table Entry Next Hop IP address. To configure  
#x       Next Hop for multiple Routing Table Entries specify this parameter 
#x       as list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_next_hop_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the rip_rte_v2_next_hop 
#x       is incremeneted or decremented when rip_rte_v2_next_hop_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_next_hop_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_rte_v2_next_hop. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with rip_rte_v2_next_hop_step and rip_rte_v2_next_hop_count.
#x          decr - the value is decremented as specified with rip_rte_v2_next_hop_step and rip_rte_v2_next_hop_count.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_next_hop_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify rip_rte_v2_next_hop when rip_rte_v2_next_hop_mode is incr 
#x       or decr.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_next_hop_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_rte_v2_next_hop
#x          1 - enable tracking by rip_rte_v2_next_hop
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_route_tag
#x       Valid only for traffic_generator ixnetwork_540 and l4_protocol rip and 
#x       and rip_version 2. 
#x       Configure Routing Table Entry Route Tag. To configure  
#x       Route Tag for multiple Routing Table Entries specify this parameter 
#x       as list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_route_tag_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the rip_rte_v2_route_tag 
#x       is incremeneted or decremented when rip_rte_v2_route_tag_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_route_tag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_rte_v2_route_tag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with rip_rte_v2_route_tag_step and rip_rte_v2_route_tag_count.
#x          decr - the value is decremented as specified with rip_rte_v2_route_tag_step and rip_rte_v2_route_tag_count.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_route_tag_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify rip_rte_v2_route_tag when rip_rte_v2_route_tag_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_route_tag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_rte_v2_route_tag
#x          1 - enable tracking by rip_rte_v2_route_tag
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_subnet_mask
#x       Valid only for traffic_generator ixnetwork_540 and l4_protocol rip and 
#x       and rip_version 2. 
#x       Configure Routing Table Entry Subnet Mask. To configure  
#x       Subnet Mask for multiple Routing Table Entries specify this parameter 
#x       as list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_subnet_mask_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the rip_rte_v2_subnet_mask 
#x       is incremeneted or decremented when rip_rte_v2_subnet_mask_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_subnet_mask_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_rte_v2_subnet_mask. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with rip_rte_v2_subnet_mask_step and rip_rte_v2_subnet_mask_count.
#x          decr - the value is decremented as specified with rip_rte_v2_subnet_mask_step and rip_rte_v2_subnet_mask_count.
#x          list - Parameter -rip_rte_v2_subnet_mask contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_subnet_mask_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify rip_rte_v2_subnet_mask when rip_rte_v2_subnet_mask_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_rte_v2_subnet_mask_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_rte_v2_subnet_mask
#x          1 - enable tracking by rip_rte_v2_subnet_mask
#x       Category: Layer4-7.RIP
#x   -rip_unused
#x       For option "l4_protocol" set to "rip", this option defines the RIP "Unused" field.
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: Layer4-7.RIP
#x   -rip_unused_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the rip_unused 
#x       is incremeneted or decremented when rip_unused_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_unused_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for rip_unused. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with rip_unused_step and rip_unused_count.
#x          decr - the value is decremented as specified with rip_unused_step and rip_unused_count.
#x          list - Parameter -rip_unused contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.RIP
#x   -rip_unused_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify rip_unused when rip_unused_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.RIP
#x   -rip_unused_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by rip_unused
#x          1 - enable tracking by rip_unused
#x       Category: Layer4-7.RIP
#x   -rip_version
#x       For option "l4_protocol" set to "rip", this option defines the RIP 
#x       version for a particular stream. Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#x       1 - Version 1.
#x       2 - Version 2.
#x       Category: Layer4-7.RIP
#x   -route_mesh
#x       Specifies the mapping between source routes and destination routes. Valid only for traffic_generator ixnetwork/ixnetwork_540. 
#x       Valid choices are:
#x       fully      - full mesh, every source route is mapped to every 
#x                    destination route. This is the default when traffic_generator ixnetwork
#x       one_to_one - each source route is mapped with only one destination 
#x                    route. This is the default when traffic_generator ixnetwork_540
#x       Category: General.Endpoint Data
#x   -session_aware_traffic
#x       The session aware traffic field for a traffic item. The only available choice is ppp. 
#x       When session_aware_traffic is set to ppp|dhcp4|dhcp6, the kill bit will be enabled. Also, 
#x       when session_aware_traffic is set to ppp|dhcp4|dhcp6, the value of the dynamic_update_field parameter 
#x       will be automatically set to ppp|dhcp4|dhcp6. 
#x       Valid for traffic_generator ixnetwork_540.
#x       Category: General.Protocol Behaviour
#x   -signature
#x       In the transmitted packet, the signature uniquely signs the 
#x       transmitted packet as one destined for packet group filtering on 
#x       the receive port. On the receive port, the signature is used to 
#x       filter only those packets that have a matching signature and the 
#x       minimum, maximum and average latencies are obtained for those packets.
#x       (DEFAULT = "DE.AD.BE.EF")
#x       This parameter can take a list of values as follows: when traffic is 
#x       configured bidirectional and this parameter has one value, this value 
#x       will be set on both streams. When this parameter has a list of two 
#x       values the first value will be assigned to the first stream and the 
#x       second value to the second stream.
#x       If -enable_auto_detect_instrumentation is 1, then this option will 
#x       represent a signature value of 12 hex bytes. This signature will be 
#x       searched at receive side into the received packets and must by the 
#x       same with the signature set on receive port.
#x       (DEFAULT = "87.73.67.49.42.87.11.80.08.71.18.05") 
#x       Valid only for traffic_generator ixos.
#x       Category: General.Instrumentation/Flow Group
#x   -signature_offset
#x       The offset, within the packet, of the packet group signature. 
#x       This parameter can take a list of values as follows: when traffic is 
#x       configured bidirectional and this parameter has one value, this value 
#x       will be set on both streams. When this parameter has a list of two 
#x       values the first value will be assigned to the first stream and the 
#x       second value to the second stream.
#x       If -enable_auto_detect_instrumentation is 1, will be ignored. 
#x       Valid only for traffic_generator ixos.
#x       Category: General.Instrumentation/Flow Group
#x   -site_id 
#x       This option is used to specify the site id value for the first LAN 
#x       static endpoint range. It can take decimal values in the 0-4294967295 
#x       range. 
#x       Valid for traffic_generator ixnetwork when configuring L2VPN traffic.
#x       Category: Layer2.L2VPN
#x   -site_id_enable
#x       This option is used to specify whether the site id will be configured 
#x       for the LAN static endpoint range. 
#x       Valid for traffic_generator ixnetwork when configuring L2VPN traffic.
#x       Category: Layer2.L2VPN
#x   -site_id_step
#x       This option is used to specify the step between the value of the 
#x       site ip of each the LAN static endpoint range. It can 
#x       take any numeric value. 
#x       Valid for traffic_generator ixnetwork when configuring L2VPN traffic.
#x       Category: Layer2.L2VPN
#x   -skip_frame_size_validation
#x       This flag is used to reduce the configuration time for the ixia::traffic_config by skiping
#x       the computation of the frame_size. 
#x       Valid only for traffic_generator ixnetwork_540.
#x       Category: General.Common
#x   -source_filter
#x       Valid only for traffic_generator ixnetwork_540. 
#x       This parameter filter on the available source endpoints that can be provided with emulation_src_handle. 
#x       Valid choices are:
#x          all  - There are no filters applied
#x          ethernet - Ethernet endpoints only (for raw trafic only)
#x          atm - ATM endpoints only (for raw trafic only)
#x          framerelay - Frame Relay endpoints only (for raw trafic only)
#x          hdlc - HDLC endpoints only (for raw trafic only)
#x          ppp - PPP endpoints only (for raw trafic only)
#x          none - non MPLS endpoints only
#x          l2vpn - L2VPN endpoints only
#x          l3vpn - L3VPN endpoints only
#x          mpls - MPLS endpoints only
#x          6pe - 6PE endpoints only
#x          6vpe - 6VPE endpoints only
#x          bgpvpls - VPLS endpoints only
#x          mac_in_mac - MAC in MAC endpoints only
#x          data_center_bridging - Data Center and Bridging endpoints only 
#x       Category: General.Endpoint Data
#x   -src_dest_mesh
#x       Specifies the mapping between source and destination. Valid only for traffic_generator ixnetwork/ixnetwork_540. 
#x       Valid choices are:
#x       fully - full mesh, every source is combined with every 
#x                     destination. This is the default value when using traffic_generator ixnetwork.
#x       one_to_one - one to one, each source has one destination. 
#x                     This is the default value when using traffic_generator ixnetwork_540.
#x       many_to_many - Only for traffic_generator ixnetwork_540. many-to-many 
#x          matching occurs between each Source Endpoints 
#x          and all of the Destination Endpoints. One traffic flow is created for 
#x          each Source/Destination pair. For example:
#x          First pair - First Source Endpoint and first Destination Endpoint. 
#x          Second pair - First Source Endpoint and second Destination Endpoint. 
#x          Third pair - First Source Endpoint and third Destination Endpoint.
#x       The choice 'fully' used along with traffic_generator ixnetwork is equivalent to 
#x       the choice 'many_to_many' used along with traffic_generator ixnetwork_540.
#x       Category: General.Endpoint Data
#x   -stream_packing
#x       This argument can be used to specify the way the streams generated 
#x       for a traffic item are packed. Valid only for traffic_generator ixnetwork/ixnetwork_540. 
#x       This parameter is deprecated for traffic_generator ixnetwork_540, use transmit_distribution 
#x       instead. If traffic_generator is ixnetwork_540 and both parameters stream_packing and 
#x       transmit_distribution are used, stream_packing will be ignored. Valid choices are:
#x       merge_destination_ranges     - combine alike destinations, such as 
#x                                      route ranges, into one stream. With traffic_generator 
#x                                      ixnetwork_540 this option will perform the same action as 
#x                                      transmit_distribution 'endpoint_pair'.
#x       one_stream_per_endpoint_pair - one stream will be created per 
#x                                      source/destination endpoint pair. With traffic_generator 
#x                                      ixnetwork_540 this option will perform the same action as 
#x                                      transmit_distribution 'endpoint_pair'.
#x       optimal_packing              - each source endpoint and its 
#x                                      destination ranges will be packed 
#x                                      together into a single stream. With traffic_generator 
#x                                      ixnetwork_540 this option will perform the same action as 
#x                                      transmit_distribution 'none'.
#x       Category: General.Endpoint Data
#x   -table_udf_column_name
#x        List of column names.
#x       For -mode create/modify, all table_udf_... parameters are required. If one of the parameters
#x       is not present, no configuration is performed.
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -table_udf_column_offset
#x        List of column offsets in bytes from the beginning of the packet. 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -table_udf_column_size
#x        List of column sizes in bytes. 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -table_udf_column_type
#x        List of column types: hex ascii binary decimal mac ipv4 ipv6 and 
#x        also a custom type. The custom type can be a combination of numbers 
#x        and a,b,d, and x (eg: "8b,3d,16x") and is not valid with traffic_generator ixnetwork_540. 
#x        a - ascii; b - binary; d - decimal; x - hex. 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -table_udf_rows
#x        A keyed list of rows that need to be added to the table UDF. 
#x        The rows must respect column order, size and type. 
#x        The keyed list should have the format below for n columns and m rows:
#x        {row_1 {column_value_11 ... column_value_1n}}
#x        {row_2 {column_value_21 ... column_value_2n}}
#x         ...........................................
#x        {row_m {column_value_m1 ... column_value_mn}}
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -tcp_ack_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_ack_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -tcp_ack_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_ack_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_ack_flag
#x          1 - enable tracking by tcp_ack_flag
#x       Category: Layer4-7.TCP
#x   -tcp_ack_num_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the tcp_ack_num 
#x       is incremeneted or decremented when tcp_ack_num_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_ack_num_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_ack_num. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with tcp_ack_num_step and tcp_ack_num_count.
#x          decr - the value is decremented as specified with tcp_ack_num_step and tcp_ack_num_count.
#x          list - Parameter -tcp_ack_num contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_ack_num_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify tcp_ack_num when tcp_ack_num_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_ack_num_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_ack_num
#x          1 - enable tracking by tcp_ack_num
#x       Category: Layer4-7.TCP
#x   -tcp_checksum
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure the TCP Checksum field (2 bytes HEX).
#x       Category: Layer4-7.TCP
#x   -tcp_checksum_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the tcp_checksum 
#x       is incremeneted or decremented when tcp_checksum_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_checksum_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_checksum. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with tcp_checksum_step and tcp_checksum_count.
#x          decr - the value is decremented as specified with tcp_checksum_step and tcp_checksum_count.
#x          list - Parameter -tcp_checksum contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_checksum_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify tcp_checksum when tcp_checksum_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_checksum_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_checksum
#x          1 - enable tracking by tcp_checksum
#x       Category: Layer4-7.TCP
#x   -tcp_cwr_flag
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure the TCP ECN CWR bit.
#x       Category: Layer4-7.TCP
#x   -tcp_cwr_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_cwr_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -tcp_cwr_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_cwr_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_cwr_flag
#x          1 - enable tracking by tcp_cwr_flag
#x       Category: Layer4-7.TCP
#x   -tcp_data_offset
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure the TCP Data Offset field (0-15).
#x       Category: Layer4-7.TCP
#x   -tcp_data_offset_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the tcp_data_offset 
#x       is incremeneted or decremented when tcp_data_offset_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_data_offset_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_data_offset. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with tcp_data_offset_step and tcp_data_offset_count.
#x          decr - the value is decremented as specified with tcp_data_offset_step and tcp_data_offset_count.
#x          list - Parameter -tcp_data_offset contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_data_offset_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify tcp_data_offset when tcp_data_offset_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_data_offset_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_data_offset
#x          1 - enable tracking by tcp_data_offset
#x       Category: Layer4-7.TCP
#x   -tcp_dst_port_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the tcp_dst_port 
#x       is incremeneted or decremented when tcp_dst_port_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_dst_port_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_dst_port. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with tcp_dst_port_step and tcp_dst_port_count.
#x          decr - the value is decremented as specified with tcp_dst_port_step and tcp_dst_port_count.
#x          list - Parameter -tcp_dst_port contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_dst_port_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify tcp_dst_port when tcp_dst_port_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_dst_port_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_dst_port
#x          1 - enable tracking by tcp_dst_port
#x       Category: Layer4-7.TCP
#x   -tcp_ecn_echo_flag
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure the TCP ECN Echo bit.
#x       Category: Layer4-7.TCP
#x   -tcp_ecn_echo_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_ecn_echo_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -tcp_ecn_echo_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_ecn_echo_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_ecn_echo_flag
#x          1 - enable tracking by tcp_ecn_echo_flag
#x       Category: Layer4-7.TCP
#x   -tcp_fin_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_fin_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -tcp_fin_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_fin_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_fin_flag
#x          1 - enable tracking by tcp_fin_flag
#x       Category: Layer4-7.TCP
#x   -tcp_ns_flag
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Configure the TCP ECN NS bit.
#x       Category: Layer4-7.TCP
#x   -tcp_ns_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_ns_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -tcp_ns_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_ns_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_ns_flag
#x          1 - enable tracking by tcp_ns_flag
#x       Category: Layer4-7.TCP
#x   -tcp_psh_flag_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_psh_flag. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -tcp_psh_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_psh_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_psh_flag
#x          1 - enable tracking by tcp_psh_flag
#x       Category: Layer4-7.TCP
#x   -tcp_reserved_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the tcp_reserved 
#x       is incremeneted or decremented when tcp_reserved_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_reserved_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_reserved. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with tcp_reserved_step and tcp_reserved_count.
#x          decr - the value is decremented as specified with tcp_reserved_step and tcp_reserved_count.
#x          list - Parameter -tcp_reserved contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_reserved_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify tcp_reserved when tcp_reserved_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_reserved_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_reserved
#x          1 - enable tracking by tcp_reserved
#x       Category: Layer4-7.TCP
#x   -tcp_rst_flag_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_rst_flag. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -tcp_rst_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_rst_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_rst_flag
#x          1 - enable tracking by tcp_rst_flag
#x       Category: Layer4-7.TCP
#x   -tcp_seq_num_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the tcp_seq_num 
#x       is incremeneted or decremented when tcp_seq_num_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_seq_num_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_seq_num. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with tcp_seq_num_step and tcp_seq_num_count.
#x          decr - the value is decremented as specified with tcp_seq_num_step and tcp_seq_num_count.
#x          list - Parameter -tcp_seq_num contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_seq_num_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify tcp_seq_num when tcp_seq_num_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_seq_num_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_seq_num
#x          1 - enable tracking by tcp_seq_num
#x       Category: Layer4-7.TCP
#x   -tcp_src_port_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the tcp_src_port 
#x       is incremeneted or decremented when tcp_src_port_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_src_port_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_src_port. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with tcp_src_port_step and tcp_src_port_count.
#x          decr - the value is decremented as specified with tcp_src_port_step and tcp_src_port_count.
#x          list - Parameter -tcp_src_port contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_src_port_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify tcp_src_port when tcp_src_port_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_src_port_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_src_port
#x          1 - enable tracking by tcp_src_port
#x       Category: Layer4-7.TCP
#x   -tcp_syn_flag_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_syn_flag. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -tcp_syn_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_syn_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_syn_flag
#x          1 - enable tracking by tcp_syn_flag
#x       Category: Layer4-7.TCP
#x   -tcp_urg_flag_mode
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_urg_flag. Valid choices are:
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          list - Parameter -tcp_urg_flag contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_urg_flag_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_urg_flag
#x          1 - enable tracking by tcp_urg_flag
#x       Category: Layer4-7.TCP
#x   -tcp_urgent_ptr_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the tcp_urgent_ptr 
#x       is incremeneted or decremented when tcp_urgent_ptr_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_urgent_ptr_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_urgent_ptr. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with tcp_urgent_ptr_step and tcp_urgent_ptr_count.
#x          decr - the value is decremented as specified with tcp_urgent_ptr_step and tcp_urgent_ptr_count.
#x          list - Parameter -tcp_urgent_ptr contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_urgent_ptr_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify tcp_urgent_ptr when tcp_urgent_ptr_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_urgent_ptr_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_urgent_ptr
#x          1 - enable tracking by tcp_urgent_ptr
#x       Category: Layer4-7.TCP
#x   -tcp_window_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the tcp_window 
#x       is incremeneted or decremented when tcp_window_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_window_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for tcp_window. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with tcp_window_step and tcp_window_count.
#x          decr - the value is decremented as specified with tcp_window_step and tcp_window_count.
#x          list - Parameter -tcp_window contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.TCP
#x   -tcp_window_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify tcp_window when tcp_window_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.TCP
#x   -tcp_window_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by tcp_window
#x          1 - enable tracking by tcp_window
#x       Category: Layer4-7.TCP
#x   -test_objective_value
#x       Valid only for traffic_generator ixnetwork, mode create/modify and 
#x       circuit_endpoint_type ipv4_application_traffic ot 
#x       ipv6_application_traffic. The -enable_test_objective argument must be 
#x       set to 1 in order for the value of this argument to be used.
#x       Category: Layer4-7.Application Traffic
#x   -track_by
#x       This argument can be used to specify the method of tracking the 
#x       generated traffic in order to gather traffic statistics. 
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540. With traffic_generator ixnetwork_540 
#x       the values specified with -track_by on mode modify will be appended to the existing track_by  
#x       values of the traffic item.  For traffic_generator ixnetwork_540 we support all available 
#x       IxNetwork low level API choices. 
#x       Valid choices are:
#x       assured_forwarding_phb   - QoS assured forwarding PHB will be used as 
#x                                  the tracking item. When traffic_generator is ixnetwork_540 this is 
#x                                  valid only when qos_type_ixn is configured to 
#x                                  af_class1_low_precedence or af_class2_low_precedence or 
#x                                  af_class3_low_precedence or af_class4_low_precedence or 
#x                                  af_class1_medium_precedence or af_class2_medium_precedence or 
#x                                  af_class3_medium_precedence or af_class4_medium_precedence or 
#x                                  af_class1_high_precedence or af_class2_high_precedence or 
#x                                  af_class3_high_precedence or af_class4_high_precedence. 
#x                                  With traffic_generator ixnetwork this can be also  
#x                                  combined with usage of enable_override_value and 
#x                                  override_value_list arguments.
#x       class_selector_phb       - QoS class selector PHB will be used as the 
#x                                  tracking item. When traffic_generator is ixnetwork_540 this is 
#x                                  valid only when qos_type_ixn is configured to 
#x                                  cs_precedence1 or cs_precedence2 or cs_precedence3 
#x                                  cs_precedence4 or cs_precedence5 or cs_precedence6 
#x                                  cs_precedence7. 
#x                                  With traffic_generator ixnetwork this can be also combined with usage of 
#x                                  enable_override_value and override_value_list arguments.
#x       default_phb              - QoS default PHB will be used as the 
#x                                  tracking item. When traffic_generator is ixnetwork_540 this is 
#x                                  valid only when qos_type_ixn is configured to dscp_default or 
#x                                  qos_type_ixn is not specified and ip_dscp is specified. 
#x                                  With traffic_generator ixnetwork this can be also combined with usage of 
#x                                  enable_override_value and 
#x                                  override_value_list arguments.
#x       expedited_forwarding_phb - QoS expedited forwarding PHB will be used 
#x                                  as the tracking item. When traffic_generator is ixnetwork_540 this is 
#x                                  valid only when qos_type_ixn is configured to 'ef'. 
#x                                  With traffic_generator ixnetwork this can be also combined with usage of 
#x                                  enable_override_value and override_value_list arguments.
#x       endpoint_pair            - Tracking per source/destination endpoint 
#x                                  pair.
#x       tos                      - IP header TOS values will be used as 
#x                                  the tracking item. When traffic_generator is ixnetwork_540 this is 
#x                                  valid only when qos_type_ixn is configured to 'tos' or 
#x                                  qos_type_ixn, qos_byte and ip_dscp are not specified and 
#x                                  ip_precedence is configured. 
#x                                  With traffic_generator ixnetwork  this can be also combined with usage of 
#x                                  enable_override_value and override_value_list arguments.
#x       dest_ip                  - The Destination IP address will be used as 
#x                                  the tracking item.
#x       source_ip                - The Source IP address will be used as the 
#x                                  tracking item.
#x       ipv6_flow_label          - The IPv6 flow label address will be used as 
#x                                  the tracking item.
#x       mpls_label               - Available only for traffic that uses 
#x                                  MPLS labels. The MPLS label will be used as 
#x                                  the tracking item.
#x       mpls_mpls_exp            - Available only for traffic that uses 
#x                                  MPLS labels. The MPLS Exp Bit will be used as 
#x                                  the tracking item.
#x       mpls_flow_descriptor     - Available only for traffic that uses 
#x                                  MPLS labels. The MPLS flow descriptor will be used as 
#x                                  the tracking item.
#x       inner_vlan               - The VLAN ID will be used as the tracking  
#x                                  item. This can be also combined with  
#x                                  enable_override_value and override_value_list arguments.
#x       dst_mac                  - The Destination MAC address will be used 
#x                                  as the tracking item.
#x       src_mac                  - The Source MAC address will be used 
#x                                  as the tracking item.
#x       dlci                     - The FrameRelay DLCI address will be used as 
#x                                  the tracking item.
#x       raw_priority             - IP header raq qos values will be used as 
#x                                  the tracking item. When traffic_generator is ixnetwork_540 this is 
#x                                  valid only when qos_type_ixn is configured to 'custom' or 
#x                                  qos_type_ixn is not specified and qos_byte is configured. 
#x                                  With traffic_generator ixnetwork, custom, user-defined hex 
#x                                  values can be inserted into the packets for 
#x                                  tracking on the receiving side. This is also combined with usage of 
#x                                  enable_override_value and override_value_list arguments.
#x       custom_8bit              - A custom-defined 8bit value (or values) 
#x                                  will be used as the tracking item.
#x       custom_16bit             - A custom-defined 16bit value (or values) 
#x                                  will be used as the tracking item
#x       custom_24bit             - A custom-defined 24bit value (or values) 
#x                                  will be used as the tracking item
#x       custom_32bit             - A custom-defined 32bit value (or values) 
#x                                  will be used as the tracking item
#x       b_src_mac                - Valid when -circuit_type is mac_in_mac
#x       b_dest_mac               - Valid when -circuit_type is mac_in_mac
#x       b_vlan                   - Valid when -circuit_type is mac_in_mac
#x       i_tag_isid               - Valid when -circuit_type is mac_in_mac
#x       c_src_mac                - Valid when -circuit_type is mac_in_mac
#x       c_dest_mac               - Valid when -circuit_type is mac_in_mac
#x       s_vlan                   - Valid when -circuit_type is mac_in_mac
#x       c_vlan                   - Valid when -circuit_type is mac_in_mac
#x       none                     - No tracking will be implemented on the 
#x                                  receiving port.
#x       Valid choices only for ixnetwork_540:           - .
#x       cisco_frame_relay_dlci_high_order_bits          - .
#x       cisco_frame_relay_dlci_low_order_bits           - .
#x       dest_endpoint           - .
#x       dest_mac           - .
#x       dest_port           - .
#x       ethernet_ii_ether_type           - .
#x       ethernet_ii_pfc_queue           - .
#x       fcoe_cs_ctl            - .
#x       fcoe_dest_id            - .
#x       fcoe_ox_id            - .
#x       fcoe_src_id            - .
#x       fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority              - .
#x       fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_did                          - .
#x       fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_ox_id                        - .
#x       fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_sid                          - .
#x       fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority              - .
#x       fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_did                          - .
#x       fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_ox_id                        - .
#x       fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_sid                          - .
#x       fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_cs_ctl_priority           - .
#x       fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_did                       - .
#x       fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_ox_id                     - .
#x       fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_sid                       - .
#x       fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority    - .
#x       fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did                - .
#x       fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id              - .
#x       fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid                - .
#x       fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority    - .
#x       fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did                - .
#x       fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id              - .
#x       fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid                - .
#x       fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority - .
#x       fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_did             - .
#x       fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_ox_id           - .
#x       fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_sid             - .
#x       frame_relay_dlci_high_order_bits                                                     - .
#x       frame_relay_dlci_low_order_bits                                                      - .
#x       ipv4_dest_ip                                                                         - Same as dest_ip.
#x       ipv4_precedence                                                                      - .
#x       ipv4_source_ip                                                                       - Same as source_ip.
#x       ipv6_dest_ip                                                                         - .
#x       ipv6_source_ip                                                                       - .
#x       ipv6_trafficclass                                                                    - .
#x       l2tpv2_data_message_tunnel_id                                                        - .
#x       mac_in_mac_priority                                                                  - .
#x       mac_in_mac_v42_bdest_address                                                         - .
#x       mac_in_mac_v42_bsrc_address                                                          - .
#x       mac_in_mac_v42_btag_pcp                                                              - .
#x       mac_in_mac_v42_cdest_address                                                         - .
#x       mac_in_mac_v42_csrc_address                                                          - .
#x       mac_in_mac_v42_isid                                                                  - .
#x       mac_in_mac_v42_priority                                                              - .
#x       mac_in_mac_v42_stag_pcp                                                              - .
#x       mac_in_mac_v42_stag_vlan_id                                                          - .
#x       mac_in_mac_v42_vlan_id                                                               - .
#x       b_vlan_user_priority                                                                 - .
#x       mac_in_mac_ether_type_i_tag                                                          - .
#x       s_vlan_user_priority                                                                 - .
#x       c_vlan_user_priority                                                                 - .
#x       mpls_mpls_exp                                                                        - .
#x       pppoe_session_sessionid                                                              - .
#x       source_dest_port_pair                                                                - .
#x       source_dest_value_pair                                                               - .
#x       source_endpoint                                                                      - .
#x       source_port                                                                          - .
#x       tcp_tcp_dst_prt                                                                      - .
#x       tcp_tcp_src_prt                                                                      - .
#x       traffic_group                                                                        - .
#x       udp_udp_dst_prt                                                                      - .
#x       udp_udp_src_prt                                                                      - .
#x       vlan_vlan_user_priority                                                              - .
#x       traffic_item                                                                         - .
#x       Category: General.Tracking
#x   -traffic_generate
#x       If 1, the learned information (MAC addresses, MPLS labels) needed for 
#x       configuring traffic is retrieved for each traffic item. This will make 
#x       the process of configuring traffic items slower. 
#x       Valid for traffic_generator ixnetwork_540. 
#x       (DEFAULT = 1) 
#x       Category: General.Common
#x   -traffic_generator
#x       Selects the Ixia product that will be used for configuring traffic.
#x       Valid options are ixos, ixnetwork, ixnetwork_540.
#x       ixos - The traffic will be generated using IxOS.
#x       ixnetwork - The traffic will be generated using IxNetwork. 
#x           This choice is available only when using IxTclNetwork 5.30 or 
#x           greater. 
#x           The IxNetwork API is a higher level API, that will allow to 
#x           configure traffic for protocol suites (OSPF, ISIS, BGP, LDP, RSVP, 
#x           L3VPN, L2VPN/VPLS, MVPN, etc.) faster than before, just by 
#x           specifying the protocol emulation handles for traffic source and 
#x           destination (through parameters -emulation_src_handle 
#x           and -emulation_dst_handle). 
#x           The layer 2,3 parameters will be configured automatically.
#x       ixnetwork_540 - This choice is available when using IxTclNetwork 5.40 or 
#x           or greater. It provides backwards compatibility for almost all the 
#x           parameters and traffic_generator values. It also brings many new features 
#x           like -mode 'append_header', 'prepend_header', 'replace_header' which 
#x           allows customization of the packet, -tracking by multiple fields from 
#x           the packets, egress tracking at predefined offsets and many others. There 
#x           are three ways in which traffic can be created:
#x              ixos backwards compatibility way - use port_handle to confiure the originating 
#x                  port for the traffic. Optionally use port_handle2 to configure the destination 
#x                  port for the traffic. If port_handle2 is missing, the paremter -allow_self_destined 
#x                  is forced to '1' and the destination port will be the same with port_handle. 
#x                  The protocol headers that will be added to the packet are triggered by the port type 
#x                  (ethernet, atm), the atm_encapsulation, vlan, mpls, isl, l2_encap, 
#x                  l3_protocol, l4_protocol.
#x              ixaccess backwards compatibility way - use emulation_src_handle or emulation_dst_handle 
#x                  parameter to configure the src/dst pppox or l2tpox handle that will 
#x                  originate/terminate the traffic. Use ip_dst_addr/ip_src_addr parameters 
#x                  to configure the fixed IP addresses that will end/originate the traffic. 
#x                  When using emulation_src_handle port_handle2 parameter can be specified 
#x                  to configure the terminating port for the traffic. In this case 
#x                  an interface with ip_dst_addr IP address will be searched on that 
#x                  port to use. Similary for emulation_dst_handle and port_handle and ip_src_addr 
#x                  parameters.
#x              ixnetwork backwards compatibility way - use emulation_src_handle and 
#x                  emulation_dst_handle to configure the source and destination 
#x                  for the traffic pair.
#x           For all the configuration styles presented, the following applies: the 
#x           parameters that configure packet fields (ip_src_addr, ethernet_type, 
#x           tcp_port etc.) will override the fields with the values passed 
#x           with the parameters.
#x       Category: General.Common
#x   -transmit_distribution
#x       Valid only for traffic_generator ixnetwork_540 and -mode 'create'. 
#x       It configures how many streams will be created to accommodate the 
#x       traffic item. For example, if a traffic item configuration has 5 source 
#x       mac addresses, and transmit_distribution is eth_ii_destination_address 
#x       then the traffic item will have 5 streams. This parameter accepts a 
#x       combination of choices. If –transmit_distribution is [list 
#x       eth_ii_destination_address ip_src_addr] then the distribution of streams 
#x       within the traffic item will take into account both criteria. For 
#x       traffic_generator ixnetwork_540 we support all available IxNetwork 
#x       low level API choices.
#x       Valid choices are:
#x          none - disable transmit distribution
#x          endpoint_pair (default) - configure one stream per endpoint pair.
#x          assured_forwarding_phb - assured_forwarding_phb
#x          b_dest_mac - b_dest_mac
#x          b_src_mac - b_src_mac
#x          b_vlan - b_vlan
#x          c_dest_mac - c_dest_mac
#x          c_src_mac - c_src_mac
#x          c_vlan - c_vlan
#x          class_selector_phb - class_selector_phb
#x          default_phb - default_phb
#x          dest_ip - dest_ip
#x          dest_mac - dest_mac
#x          ethernet_ii_ether_type - ethernet_ii_ether_type
#x          ethernet_ii_pfc_queue - ethernet_ii_pfc_queue
#x          expedited_forwarding_phb - expedited_forwarding_phb
#x          fcoe_cs_ctl - fcoe_cs_ctl
#x          fcoe_dest_id - fcoe_dest_id
#x          fcoe_ox_id - fcoe_ox_id
#x          fcoe_src_id - fcoe_src_id
#x          fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority - fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority
#x          fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_did - fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_did
#x          fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_ox_id - fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_ox_id
#x          fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_sid - fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_sid
#x          fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority - fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority
#x          fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_did - fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_did
#x          fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_ox_id - fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_ox_id
#x          fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_sid - fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_sid
#x          fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_cs_ctl_priority - fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_cs_ctl_priority
#x          fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_did - fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_did
#x          fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_ox_id - fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_ox_id
#x          fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_sid - fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_sid
#x          fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority - fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority
#x          fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did - fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did
#x          fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id - fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id
#x          fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid - fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid
#x          fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority - fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority
#x          fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did - fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did
#x          fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id - fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id
#x          fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid - fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid
#x          fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority - fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority
#x          fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_did - fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_did
#x          fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_ox_id - fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_ox_id
#x          fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_sid - fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_sid
#x          frame_size - frame_size
#x          i_tag_isid - i_tag_isid
#x          inner_vlan - inner_vlan
#x          ipv4_dest_ip - ipv4_dest_ip
#x          ipv4_precedence - ipv4_precedence
#x          ipv4_source_ip - ipv4_source_ip
#x          ipv6_dest_ip - ipv6_dest_ip
#x          ipv6_flow_label - ipv6_flow_label
#x          ipv6_flowlabel - ipv6_flowlabel
#x          ipv6_source_ip - ipv6_source_ip
#x          ipv6_trafficclass - ipv6_trafficclass
#x          l2tpv2_data_message_tunnel_id - l2tpv2_data_message_tunnel_id
#x          mac_in_mac_priority - mac_in_mac_priority
#x          mac_in_mac_v42_bdest_address - mac_in_mac_v42_bdest_address
#x          mac_in_mac_v42_bsrc_address - mac_in_mac_v42_bsrc_address
#x          mac_in_mac_v42_btag_pcp - mac_in_mac_v42_btag_pcp
#x          mac_in_mac_v42_cdest_address - mac_in_mac_v42_cdest_address
#x          mac_in_mac_v42_csrc_address - mac_in_mac_v42_csrc_address
#x          mac_in_mac_v42_isid - mac_in_mac_v42_isid
#x          mac_in_mac_v42_priority - mac_in_mac_v42_priority
#x          mac_in_mac_v42_stag_pcp - mac_in_mac_v42_stag_pcp
#x          mac_in_mac_v42_stag_vlan_id - mac_in_mac_v42_stag_vlan_id
#x          mac_in_mac_v42_vlan_id - mac_in_mac_v42_vlan_id
#x          mac_in_mac_vlan_user_priority - mac_in_mac_vlan_user_priority
#x          mpls_label - mpls_label
#x          mpls_mpls_exp - mpls_mpls_exp
#x          mpls_flow_descriptor - mpls_flow_descriptor
#x          pppoe_session_sessionid - pppoe_session_sessionid
#x          raw_priority - raw_priority
#x          rx_port - rx_port
#x          s_vlan - s_vlan
#x          source_ip - source_ip
#x          srcDestEndpointPair - srcDestEndpointPair
#x          src_mac - src_mac
#x          tcp_tcp_dst_prt - tcp_tcp_dst_prt
#x          tcp_tcp_src_prt - tcp_tcp_src_prt
#x          tos - tos
#x          udp_udp_dst_prt - udp_udp_dst_prt
#x          udp_udp_src_prt - udp_udp_src_prt
#x          vlan_vlan_user_priority - vlan_vlan_user_priority
#x       Category: General.Instrumentation/Flow Group
#x   -tx_delay
#x       This argument can be used to specify the delay to the start of the 
#x       scheduled stream. 
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: Stream Control and Data.Rate Control
#x   -tx_delay_unit
#x       This argument can be used to specify the delay unit for tx_delay
#x       Valid only for traffic_generator ixnetwork_540.
#x       Valid choices are:
#x          bytes - bytes.
#x          ns - nano seconds.
#x       Category: Stream Control and Data.Rate Control
#x   -tx_mode
#x       Configure transmit mode of traffic item on -mode create and modify. 
#x       If this parameter is not provided, the transmit mode of the traffic item 
#x       will be configured to match the transmit mode of the first transmitting port 
#x       of the traffic item. The port transmit mode is configured using procedure 
#x       ::ixia::interface_config with parameter -transmit_mode.
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          advanced - interleaved.
#x          stream - sequential.
#x       Category: General.Common
#x   -udf1_cascade_type
#x       Indicates the source of the initial value for the counter. The initial 
#x       value for the first enabled stream always comes from the UDF 
#x       counter_init_value option. Valid only for traffic_generator ixos. 
#x       Valid choices are:
#x       none - (default) The initial value always comes from UDF 
#x          counter_init_value option.
#x       from_previous - The initial value is derived from the last executed 
#x          stream which used this UDF number with UDF cascade_type set to 
#x          from_previous.  An initial increment/decrement/random operation 
#x          is applied from the previous value.
#x       from_shelf - The initial value is derived from the last value 
#x          generated by this UDF with this stream. An initial increment/ 
#x          decrement/random operation is applied from the previous value.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_chain_from
#x       Allows the user to select what UDF the current UDF should chain 
#x       from. When this option is employed, the UDF will stay in its 
#x       initial value until the UDF it is chained from reaches its 
#x       terminating value. Valid only for traffic_generator ixos/ixnetwork_540. 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_counter_init_value
#x       The initial value of the counter.  This field is a list of hex 
#x       numbers for range_list mode; a hex number for all other modes.
#x       (DEFAULT = 0x0800) 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_counter_mode
#x       The counter will increment or decrement the bytes continuously or 
#x       a number of repeat counts.  The choices are:  continuous or count.
#x       (DEFAULT = count) 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_counter_repeat_count
#x       The counter is incremented or decremented the number of times based 
#x       on this option. If counter_mode is continuous, then this value is 
#x       ignored.
#x       (DEFAULT = 1) 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_counter_step
#x       The step size for counter up/down. 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       (DEFAULT = 1) 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_counter_type
#x       Describes the size of the UDF field in bits.  The choices are:
#x       8 16 24 32 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_counter_up_down
#x       This option describes whether the UDF counters are to be incremented 
#x       or decremented.  Choices are:  up, down. 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_enable_cascade
#x       If this option is set to true (1), then the UDF counter will not be 
#x       reset with the start of each stream, but will rather continue counting 
#x       from the ending value of the previous stream.
#x       (DEFAULT = 0) 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_inner_repeat_count
#x       The number of times the inner loop is repeated. Used when UDF mode is 
#x       set to nested.
#x       (DEFAULT = 1) 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_inner_repeat_value
#x       The number of times each value in the inner loop is repeated. Used 
#x       when UDF mode is set to nested.
#x       (DEFAULT = 1) 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_inner_step
#x       The steps size between inner loop values. Used when UDF mode is set 
#x       to nested.
#x       (DEFAULT = 1) 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_mask_select
#x       This is a 32-bit mask that enables, on a bit-by-bit basis, use of the 
#x       absolute counter value bits as defined by mask_val option. To be used for udf1_mode random. 
#x       (DEFAULT = {00 00}) 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_mask_val
#x       A 32-bit mask of absolute values for this UDF counter. It is used in 
#x       association with the mask_select; bits must be set 'on' or the bits in 
#x       mask_select will be ignored. To be used for udf1_mode random. 
#x       (DEFAULT = {00 00}) 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_mode
#x       The mode of operation of the counter. 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540. Valid choices are:
#x       counter - (default) Normal up-down counter as controlled by 
#x          counter_mode, counter_type, counter_init_value, mask_select, 
#x          mask_val, random, counter_repeat_count, counter_step, 
#x          counter_up_down and cascade_type options.
#x       random - Generates random values, based on the values in 
#x          counter_type, mask_select and mask_val.
#x       value_list - A list of distinct values, based on the values of 
#x          counter_type, value_list and cascade_type.
#x       nested - Two nested counters may be used to build complex 
#x          sequences, based on the values of counter_type, 
#x          counter_init_value, inner_repeat_count, inner_repeat_value, 
#x          inner_step, counter_repeat_count, counter_step, and 
#x          cascade_type options.
#x       range_list - A list of value ranges, based on counter_type, 
#x          cascade_type and ranges. Ranges are specified with 
#x          counter_init_value, counter_repeat_count, and counter_step.
#x       ipv4 - A counter which facilitates generation of IPv4 addresses, 
#x          based on counter_init_value, counter_repeat_count, counter_type, 
#x          inner_repeat_value, inner_step, skip_zeros_and_ones, 
#x          and skip_mask_bits options.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_offset
#x       The absolute offset to insert this UDF into the frame. Note that DA 
#x       and SA use the fixed offsets at 0 and 6, respectively. This option 
#x       applies to all UDF modes.
#x       (DEFAULT = 12) 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_skip_mask_bits
#x       If UDF mode is ipv4 and skip_zeros_and_ones is set to true (1), this 
#x       is the number of low order bits to check when looking for all 0s and 
#x       all 1s. This normally corresponds to network broadcast addresses.
#x       (DEFAULT = 8) 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_skip_zeros_and_ones
#x       If UDF mode is ipv4 and this option is set to true (1), then values 
#x       of all 0s and all 1s as masked by skip_mask_bits will be skipped 
#x       when generating values.  This normally corresponds to network 
#x       broadcast addresses.
#x       (DEFAULT = 1) 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf1_value_list
#x       A list of hex numbers which holds the values to be used when mode is 
#x       set to value_list. 
#x       If traffic_generator is ixnetwork_540, circuit_type must be configured to 'quick_flows'. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_cascade_type
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_chain_from
#x       Allows the user to select what UDF the current UDF should chain 
#x       from. When this option is employed, the UDF will stay in its 
#x       initial value until the UDF it is chained from reaches its 
#x       terminating value. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_counter_init_value
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_counter_mode
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_counter_repeat_count
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_counter_step
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_counter_type
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_counter_up_down
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_enable_cascade
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_inner_repeat_count
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_inner_repeat_value
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_inner_step
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_mask_select
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_mask_val
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_mode
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_offset
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_skip_mask_bits
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_skip_zeros_and_ones
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf2_value_list
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_cascade_type
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_chain_from
#x       Allows the user to select what UDF the current UDF should chain 
#x       from. When this option is employed, the UDF will stay in its 
#x       initial value until the UDF it is chained from reaches its 
#x       terminating value. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_counter_init_value
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_counter_mode
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_counter_repeat_count
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_counter_step
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_counter_type
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_counter_up_down
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_enable_cascade
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_inner_repeat_count
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_inner_repeat_value
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_inner_step
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_mask_select
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_mask_val
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_mode
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_offset
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_skip_mask_bits
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_skip_zeros_and_ones
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf3_value_list
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_cascade_type
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_chain_from
#x       Allows the user to select what UDF the current UDF should chain 
#x       from. When this option is employed, the UDF will stay in its 
#x       initial value until the UDF it is chained from reaches its 
#x       terminating value. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_counter_init_value
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_counter_mode
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_counter_repeat_count
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_counter_step
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_counter_type
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_counter_up_down
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_enable_cascade
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_inner_repeat_count
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_inner_repeat_value
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_inner_step
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_mask_select
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_mask_val
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_mode
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_offset
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_skip_mask_bits
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_skip_zeros_and_ones
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf4_value_list
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_cascade_type
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_chain_from
#x       Allows the user to select what UDF the current UDF should chain 
#x       from. When this option is employed, the UDF will stay in its 
#x       initial value until the UDF it is chained from reaches its 
#x       terminating value. 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_counter_init_value
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_counter_mode
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_counter_repeat_count
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_counter_step
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_counter_type
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_counter_up_down
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_enable_cascade
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_inner_repeat_count
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_inner_repeat_value
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_inner_step
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_mask_select
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_mask_val
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_mode
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_offset
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_skip_mask_bits
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_skip_zeros_and_ones
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udf5_value_list
#x       See description for this item same as udf1 
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Stream Control and Data.User Defined Fields
#x   -udp_checksum_value
#x       Value to be set for UDP checksum if "-udp_checksum 0" is specified.
#x       Valid only for traffic_generator ixos/ixnetwork_540.
#x       Category: Layer4-7.UDP
#x   -udp_checksum_value_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by udp_checksum_value
#x          1 - enable tracking by udp_checksum_value
#x       Category: Layer4-7.UDP
#x   -udp_dst_port_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the udp_dst_port 
#x       is incremeneted or decremented when udp_dst_port_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.UDP
#x   -udp_dst_port_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for udp_dst_port. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with udp_dst_port_step and udp_dst_port_count.
#x          decr - the value is decremented as specified with udp_dst_port_step and udp_dst_port_count.
#x          list - Parameter -udp_dst_port contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.UDP
#x   -udp_dst_port_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify udp_dst_port when udp_dst_port_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.UDP
#x   -udp_dst_port_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by udp_dst_port
#x          1 - enable tracking by udp_dst_port
#x       Category: Layer4-7.UDP
#x   -udp_length
#x       Valid only for traffic_generator ixnetwork_540 and when -l4_protocol is udp. 
#x       Configure the Length field of the UDP header.
#x       Category: Layer4-7.UDP
#x   -udp_length_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the udp_length 
#x       is incremeneted or decremented when udp_length_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.UDP
#x   -udp_length_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for udp_length. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with udp_length_step and udp_length_count.
#x          decr - the value is decremented as specified with udp_length_step and udp_length_count.
#x          list - Parameter -udp_length contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.UDP
#x   -udp_length_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify udp_length when udp_length_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.UDP
#x   -udp_length_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by udp_length
#x          1 - enable tracking by udp_length
#x       Category: Layer4-7.UDP
#x   -udp_src_port_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the udp_src_port 
#x       is incremeneted or decremented when udp_src_port_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.UDP
#x   -udp_src_port_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for udp_src_port. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with udp_src_port_step and udp_src_port_count.
#x          decr - the value is decremented as specified with udp_src_port_step and udp_src_port_count.
#x          list - Parameter -udp_src_port contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer4-7.UDP
#x   -udp_src_port_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify udp_src_port when udp_src_port_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer4-7.UDP
#x   -udp_src_port_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by udp_src_port
#x          1 - enable tracking by udp_src_port
#x       Category: Layer4-7.UDP
#x   -use_all_ip_subnets
#x       This argument can be used to enable the use of all advertised subnets 
#x       will be used to simulate application traffic when the profile 
#x       objective is rate-based, -enable_test_objective argument must be set 
#x       to 1 in order for the value of this argument to be used.
#x       Valid only for traffic_generator ixnetwork, mode create/modify, 
#x       circuit_endpoint_type ipv4_application_traffic or 
#x       ipv6_application_traffic.
#x       Category: Layer4-7.Application Traffic
#x   -vci_increment
#x       This option is used to specify the VCI increment of the first ATM 
#x       static endpoint range. It can take any value in the 0-4294967295 
#x       range. 
#x       Valid only for traffic_generator ixnetwork when configuring L2VPN traffic.
#x       Category: Layer2.L2VPN
#x   -vci_increment_step
#x       This option is used to specify the step between the VCI increment 
#x       of each ATM static endpoint range. It can take any numeric value.
#x       Valid only for traffic_generator ixnetwork when configuring L2VPN traffic.
#x       Category: Layer2.L2VPN
#x   -vlan
#x       This option will enable/disable VLAN and stacked VLAN (QinQ)on the 
#x       interface to be configured. If vlan is disable and vlan_id or other 
#x       vlan options are provided then these options will be ignored. 
#x       Valid only for traffic_generator ixos and ixnetwork_540.
#x       Category: Layer2.VLAN
#x   -vlan_cfi_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the vlan_cfi 
#x       is incremeneted or decremented when vlan_cfi_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.VLAN
#x   -vlan_cfi_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for vlan_cfi. Valid choices are: 
#x          fixed (default) - the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with vlan_cfi_step and vlan_cfi_count.
#x          decr - the value is decremented as specified with vlan_cfi_step and vlan_cfi_count.
#x          list - Parameter -vlan_cfi contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.VLAN
#x   -vlan_cfi_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify vlan_cfi when vlan_cfi_mode is incr 
#x       or decr.
#x       Valid options are: 0 and 1. (DEFAULT = 1)
#x       Category: Layer2.VLAN
#x   -vlan_cfi_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by vlan_cfi
#x          1 - enable tracking by vlan_cfi
#x       Category: Layer2.VLAN
#x   -vlan_enable
#x       This option is used to specify whether the VLAN id will be configured 
#x       for the LAN static endpoint range. 
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: Layer2.L2VPN
#x   -vlan_id_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by vlan_id
#x          1 - enable tracking by vlan_id
#x       Category: Layer2.VLAN
#x   -vlan_protocol_tag_id
#x       The protocol ID field of the VLAN tag. It can be any 4 digit hex number. 
#x       Example: 8100, 9100, 9200. 
#x       For stacked VLAN (QinQ) this parameter will be provided as a list 
#x       of values, each of them representing the protocol ID field of the 
#x       VLAN tag
#x       Example: {8100 9100 9200 9100}
#x       (DEFAULT = 8100). 
#x       Valid only for traffic_generator ixos and ixnetwork_540.
#x       When configuring traffic over PPP sessions this parameter is considered 
#x       to be the VLAN protocol tag ID for the downstream (the traffic from 
#x       network port to access port).
#x       Category: Layer2.VLAN
#x   -vlan_protocol_tag_id_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the vlan_protocol_tag_id 
#x       is incremeneted or decremented when vlan_protocol_tag_id_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.VLAN
#x   -vlan_protocol_tag_id_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for vlan_protocol_tag_id. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with vlan_protocol_tag_id_step and vlan_protocol_tag_id_count.
#x          decr - the value is decremented as specified with vlan_protocol_tag_id_step and vlan_protocol_tag_id_count.
#x          list - Parameter -vlan_protocol_tag_id contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.VLAN
#x   -vlan_protocol_tag_id_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Hex step value used to modify vlan_protocol_tag_id when vlan_protocol_tag_id_mode is incr 
#x       or decr.
#x       (DEFAULT = 0x0001)
#x       Category: Layer2.VLAN
#x   -vlan_protocol_tag_id_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 (default) - disable tracking by vlan_protocol_tag_id
#x          1 - enable tracking by vlan_protocol_tag_id
#x       Category: Layer2.VLAN
#x   -vlan_user_priority_count
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Numeric value which configures the number of times the vlan_user_priority 
#x       is incremeneted or decremented when vlan_user_priority_mode is incr or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.VLAN
#x   -vlan_user_priority_mode 
#x       Valid only for traffic_generator ixnetwork_540. This parameter configures 
#x       the behavior for vlan_user_priority. Valid choices are: 
#x          fixed - (DEFAULT) the value is left unchanged for all packets.
#x          incr - the value is incremented as specified with vlan_user_priority_step and vlan_user_priority_count.
#x          decr - the value is decremented as specified with vlan_user_priority_step and vlan_user_priority_count.
#x          list - Parameter -vlan_user_priority contains a list of values. Each packet 
#x              will use one of the values from the list.
#x       Category: Layer2.VLAN
#x   -vlan_user_priority_step
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Step value used to modify vlan_user_priority when vlan_user_priority_mode is incr 
#x       or decr.
#x       (DEFAULT = 1)
#x       Category: Layer2.VLAN
#x   -vlan_user_priority_tracking
#x       Valid only for traffic_generator ixnetwork_540. 
#x       Valid choices are:
#x          0 - (DEFAULT) disable tracking by vlan_user_priority
#x          1 - enable tracking by vlan_user_priority
#x       Category: Layer2.VLAN
#x   -vpi_increment
#x       This option is used to specify the VPI increment of the first ATM 
#x       static endpoint range. It can take any value in the 0-4294967295 
#x       range. 
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: Layer2.L2VPN
#x   -vpi_increment_step
#x       This option is used to specify the step between the VPI increment 
#x       of each ATM static endpoint range. It can take any numeric value. 
#x       Valid only for traffic_generator ixnetwork/ixnetwork_540.
#x       Category: Layer2.L2VPN
#n   -csrc_list
#n       Specifies the CSRC list which identifies the contributing sources 
#n       for the payload contained in this packet. The number of identifiers 
#n       is given by the CC field. If there are more than 15 contributing 
#n       sources, only 15 may be identified. CSRC identifiers are inserted 
#n       by mixers, using the SSRC identifiers of contributing sources. 
#n       Note: 0 to 15 items, 32 bits each and is required if csrc_count is > 0
#n   -dlci_repeat_count_step
#n       Repeat count step for dlci_value. The valid range is 0-4294967295. 
#n       Valid only for traffic_generator ixnetwork for L2VPN traffic, but is not supported in this release.
#n   -dlci_value_step
#n       Data Link Connection Identifier step. Depending on the 
#n       traffic_generator value, this option has different 
#n       value ranges. Valid choices are:
#n       ixos - Valid range is 0-65535.
#n       ixnetwork (not supported in this release) - Valid range is 0-4294967295. 
#n                                                  The option can only be used for L2VPN traffic.
#n   -fr_range_count
#n       This option is used to specify the number of Frame relay static 
#n       endpoint ranges. It can take any numeric value. This option is 
#n       available only when using the ixnetwork traffic generator for 
#n       L2VPN traffic, but is not supported in this release.
#n   -intf_handle
#n       This option is used to specify the interface handle to be associated 
#n       with the IP static endpoints that are going to be created. This 
#n       option is available only when using the ixnetwork traffic generator.
#n       (Not supported in this release.)
#n   -ip_bit_flags
#n   -ip_dst_count_step
#n       This option is used to specify the step between the value of the 
#n       first address count value of each the IP static endpoint range. 
#n       It can take any numeric value. This option is available only when 
#n       using the ixnetwork traffic generator for L2VPN traffic, but is not supported in this release.
#n   -ip_dst_increment
#n       This option is used to specify the value of the increment of the 
#n       first IP static endpoint range. It can take any numeric value in 
#n       the 1-4294967295 range. This option is available only when using 
#n       the ixnetwork traffic generator for L2VPN traffic, but is not supported in this release.
#n   -ip_dst_increment_step
#n       This option is used to specify the step between the value of the 
#n       first address increment value of each the IP static endpoint range. 
#n       It can take any numeric value. This option is available only when 
#n       using the ixnetwork traffic generator for L2VPN traffic, but is not supported in this release.
#n   -ip_dst_prefix_len
#n       This option is used to specify the value of the prefix length 
#n       of the first IP static endpoint range. This option is available 
#n       only when using the ixnetwork traffic generator for L2VPN traffic, but is not supported in this release.
#n   -ip_dst_prefix_len_step
#n       This option is used to specify the step between the value of the 
#n       first prefix lenght of each the IP static endpoint range. It can 
#n       take any an numeric value. This option is available only when 
#n       using the ixnetwork traffic generator for L2VPN traffic, but is not supported in this release.
#n   -ip_dst_range_step
#n       This option is used to specify the step between the value of the 
#n       first IP of each the IP static endpoint range. It can take 
#n       an IP value. This option is available only when 
#n       using the ixnetwork traffic generator for L2VPN traffic, but is not supported in this release.
#n   -ip_dst_skip_broadcast
#n   -ip_dst_skip_multicast
#n   -ip_mbz
#n   -ip_range_count
#n       This option is used to specify the number of IP static endpoint 
#n       ranges. It can take any numeric value. This option is available 
#n       only when using the ixnetwork traffic generator.
#n   -ip_src_skip_broadcast
#n   -ip_src_skip_multicast
#n   -ip_tos_count
#n   -ip_tos_field
#n   -ip_tos_step
#n   -ipv6_checksum
#n   -ipv6_frag_next_header
#n       Next header in the fragmentation extention header.
#n   -ipv6_length
#n   -mac_discovery_gw
#n       Default for -mac_dst_mode discovery is to use the interface gateway.
#n   -mac_dst2_count
#n   -mac_dst2_mode
#n   -mac_dst2_step
#n   -mac_src2_count
#n   -mac_src2_mode
#n   -mac_src2_step
#n   -ppp_session_id
#n   -rtp_csrc_count
#n       Specifies the CSRC count contains the number of CSRC identifiers that 
#n       follow the fixed header: Note: 4 bits
#n   -rtp_payload_type
#n       Specifies the format of the RTP payload and determines 
#n       its interpretation by the application - Note: 7 bits, G.729 codec is 
#n       payload type 18
#n   -ssrc
#n       Specifies the synchronization source
#n   -timestamp_initial_value
#n       Specifies the initial value of the timestamp
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information. On status of success, gives possible warnings.
#    key:stream_id    value:Stream identifier when not bidirectional. When traffic_generator is ixnetwork_540 this key returns the name of the traffic item created.
#    key:stream_id.$port_handle     value:Stream identifier for traffic sent out the port associated with "port_handle". Not valid for traffic_generator ixnetwork_540.
#    key:stream_id.$port_handle2    value:Stream identifier for traffic sent out the port associated with "port_handle2". Not valid for traffic_generator ixnetwork_540.
#    key:traffic_item               value:Valid only for traffic_generator ixnetwork_540. This key returns the object reference of the traffic item created.
#    key:<traffic_item>.headers     value:Valid only for traffic_generator ixnetwork_540. Returns the list of the packet headers configured in <traffic_item>. <traffic_item> is returned by key 'traffic_item'.
#    key:<traffic_item>.stream_ids  value:Valid only for traffic_generator ixnetwork_540. Returns the list of the flow groups created for <traffic_item>. <traffic_item> is returned by key 'traffic_item'.
#    key:<traffic_item>.<flow_group>.headers value:Valid only for traffic_generator ixnetwork_540. Returns the list of the packet headers created for <flow_group>. <flow_group> is one of the flow groups returned by key '<traffic_item>.stream_ids'.
#    key:pt_handle                  value:Protocol Template handle (or list) returned when mode is "get_available_protocol_templates".
#    key:handle                     value:Returns available fields or field handles when mode is "get_available_fields", "add_field_level" or "remove_field_level".
#    key:field_activeFieldChoice    value:Specific value for this key when mode is "get_field_values".
#    key:field_auto                 value:Specific value for this key when mode is "get_field_values".
#    key:field_countValue           value:Specific value for this key when mode is "get_field_values".
#    key:field_defaultValue         value:Specific value for this key when mode is "get_field_values".
#    key:field_displayName          value:Specific value for this key when mode is "get_field_values".
#    key:field_enumValues           value:Specific value for this key when mode is "get_field_values".
#    key:field_fieldChoice          value:Specific value for this key when mode is "get_field_values".
#    key:field_fieldValue           value:Specific value for this key when mode is "get_field_values".
#    key:field_fullMesh             value:Specific value for this key when mode is "get_field_values".
#    key:field_id                   value:Specific value for this key when mode is "get_field_values".
#    key:field_length               value:Specific value for this key when mode is "get_field_values".
#    key:field_level                value:Specific value for this key when mode is "get_field_values".
#    key:field_name                 value:Specific value for this key when mode is "get_field_values".
#    key:field_offset               value:Specific value for this key when mode is "get_field_values".
#    key:field_offsetFromRoot       value:Specific value for this key when mode is "get_field_values".
#    key:field_optional             value:Specific value for this key when mode is "get_field_values".
#    key:field_optionalEnabled      value:Specific value for this key when mode is "get_field_values".
#    key:field_rateVaried           value:Specific value for this key when mode is "get_field_values".
#    key:field_readOnly             value:Specific value for this key when mode is "get_field_values".
#    key:field_requiresUdf          value:Specific value for this key when mode is "get_field_values".
#    key:field_singleValue          value:Specific value for this key when mode is "get_field_values".
#    key:field_startValue           value:Specific value for this key when mode is "get_field_values".
#    key:field_stepValue            value:Specific value for this key when mode is "get_field_values".
#    key:field_trackingEnabled      value:Specific value for this key when mode is "get_field_values".
#    key:field_valueFormat          value:Specific value for this key when mode is "get_field_values".
#    key:field_valueList            value:Specific value for this key when mode is "get_field_values".
#    key:field_valueType            value:Specific value for this key when mode is "get_field_values".
#
# Examples:
#    See files starting with Streams_ in the Samples subdirectory.  Also see some of the other sample files in Appendix A, "Example APIs."
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1. Coded versus functional specification.
#    2. In order to use QoS groups, parameter -variable_user_rate must be set 
#    to 1 in traffic_config calls. The maximum number of qos groups that can 
#    be created is 7.  After the maximum number 
#    of QoS groups is exceeded, the sessions that will be created will belong 
#    to the first group that has the same qos_byte value. If there is no group 
#    with the same qos_byte value, then a random group is chosen.
#    3. When using QinQ (stacked Vlan):
#         - the parameters: vlan_id, vlan_id_mode, vlan_user_priority, 
#           vlan_cfi, vlan_id_count, vlan_id_step, vlan_protocol_tag_id, 
#           must be passed as a list of values (Example provided at their 
#           description).
#         - Each value from the list will be associated with a vlan from 
#           the stack
#         - If a parameter is not provided, then that parameter will 
#           take it’s default value and will be replicated for each vlan 
#           from the stack.
#         - Otherwise, when the parameter is provided, it should have the 
#           exact same number of values in the list as the number of vlan’s 
#           from the stack. If this condition is not met the procedure will 
#           return an error.
#         - Traffic is not supported over flapping sessions.  After the first 
#           session falls, the new session that arises will have a different 
#           session ID and the traffic created for the first session will not work.
#     4. When using IxNetwork, traffic configurations will be done using previously 
#        created handles (IP interfaces, PPP ranges, L2TP ranges, Protocol Route Ranges 
#        etc.) as sources (parameter -emulation_src_handle) and destinations 
#        (-emulation_dst_handle). The port_handle parameter is not necessary anymore.
#     5. When using IxNetwork, traffic can only be configured between Ixia endpoints.
#
# See Also:
#
