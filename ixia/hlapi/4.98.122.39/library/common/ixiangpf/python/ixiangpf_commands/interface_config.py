# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def interface_config(self, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    interface_config
		
		 Description:
		    This command configures an interface on an Ixia Load Module. It
		    provides the means for managing the Ixia Chassis Test Interface options.
		    Depending on whether the port is a SONET, Ethernet or ATM type, you have
		    access to the appropriate protocol properties.
		    This command accommodates
		    addressing schemes such as like IPv4, IPv6, MAC and VLAN. You also have
		    access to the SONET properties for a PoS port, and if the port is
		    configured for PPP, you have access to the PPP configuration options.
		
		 Synopsis:
		    interface_config
		        [-port_handle                                       REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
		x       [-protocol_name                                     ALPHA]
		x       [-protocol_handle                                   ANY]
		x       [-enable_loopback                                   CHOICES 0 1
		x                                                           DEFAULT 0]
		x       [-connected_to_handle                               ANY]
		x       [-ipv6_multiplier                                   NUMERIC]
		x       [-ipv6_loopback_multiplier                          NUMERIC]
		x       [-ipv4_resolve_gateway                              CHOICES 0 1
		x                                                           DEFAULT 1]
		x       [-ipv4_manual_gateway_mac                           MAC
		x                                                           DEFAULT 0000.0000.0001]
		x       [-ipv4_manual_gateway_mac_step                      MAC
		x                                                           DEFAULT 0000.0000.0001]
		x       [-ipv6_resolve_gateway                              CHOICES 0 1
		x                                                           DEFAULT 1]
		x       [-ipv6_manual_gateway_mac                           MAC]
		x       [-ipv6_manual_gateway_mac_step                      MAC
		x                                                           DEFAULT 0000.0000.0001]
		x       [-send_ping                                         CHOICES 0 1
		x                                                           DEFAULT 0]
		x       [-ping_dst                                          ANY]
		x       [-addresses_per_svlan                               RANGE 1-1000000000
		x                                                           DEFAULT 1]
		n       [-addresses_per_vci                                 ANY]
		x       [-addresses_per_vlan                                RANGE 1-1000000000
		x                                                           DEFAULT 1]
		n       [-addresses_per_vpi                                 ANY]
		x       [-arp                                               CHOICES 0 1
		x                                                           DEFAULT 1]
		x       [-arp_on_linkup                                     CHOICES 0 1
		x                                                           DEFAULT 1]
		x       [-arp_req_retries                                   NUMERIC
		x                                                           DEFAULT 2]
		n       [-arp_req_timer                                     ANY]
		        [-arp_send_req                                      CHOICES 0 1]
		x       [-atm_enable_coset                                  CHOICES 0 1]
		x       [-atm_enable_pattern_matching                       CHOICES 0 1]
		x       [-arp_refresh_interval                              RANGE 30-6000
		x                                                           DEFAULT 60]
		n       [-atm_encapsulation                                 ANY]
		x       [-atm_filler_cell                                   CHOICES idle unassigned]
		x       [-atm_interface_type                                CHOICES uni nni]
		x       [-atm_packet_decode_mode                            CHOICES frame cell]
		x       [-atm_reassembly_timeout                            NUMERIC]
		        [-autonegotiation                                   CHOICES 0 1]
		x       [-auto_detect_instrumentation_type                  CHOICES end_of_frame floating
		x                                                           DEFAULT floating]
		x       [-bert_configuration                                ANY]
		x       [-bert_error_insertion                              ANY]
		        [-clocksource                                       CHOICES internal loop external]
		x       [-connected_count                                   NUMERIC
		x                                                           DEFAULT 1]
		x       [-data_integrity                                    CHOICES 0 1]
		        [-duplex                                            CHOICES half full auto]
		        [-framing                                           CHOICES sonet sdh]
		        [-gateway                                           IPV4]
		x       [-gateway_incr_mode                                 CHOICES every_subnet every_interface
		x                                                           DEFAULT every_subnet]
		x       [-gateway_step                                      IPV4
		x                                                           DEFAULT 0.0.0.1]
		x       [-gre_checksum_enable                               CHOICES 0 1]
		x       [-gre_count                                         NUMERIC
		x                                                           DEFAULT 1]
		x       [-gre_dst_ip_addr                                   IP]
		x       [-gre_dst_ip_addr_step                              IP
		x                                                           DEFAULT 0.0.0.1]
		n       [-gre_ip_addr                                       ANY]
		n       [-gre_ip_addr_step                                  ANY]
		n       [-gre_ip_prefix_length                              ANY]
		n       [-gre_ipv6_addr                                     ANY]
		n       [-gre_ipv6_addr_step                                ANY]
		n       [-gre_ipv6_prefix_length                            ANY]
		x       [-gre_key_enable                                    CHOICES 0 1]
		x       [-gre_key_in                                        RANGE 0-4294967295]
		x       [-gre_key_out                                       RANGE 0-4294967295]
		x       [-gre_seq_enable                                    CHOICES 0 1]
		        [-ignore_link                                       CHOICES 0 1
		                                                            DEFAULT 0]
		x       [-integrity_signature                               REGEXP ^[0-9a-fA-F]{2}([.: ]{0,1}){0,11}[0-9a-fA-F]{2}$]
		x       [-integrity_signature_offset                        RANGE 24-64000]
		        [-interface_handle                                  ANY]
		        [-internal_ppm_adjust                               ANY]
		        [-intf_ip_addr                                      IPV4]
		x       [-intf_ip_addr_step                                 IPV4
		x                                                           DEFAULT 0.0.0.1]
		        [-intf_mode                                         CHOICES atm
		                                                            CHOICES pos_hdlc
		                                                            CHOICES pos_ppp
		                                                            CHOICES ethernet
		                                                            CHOICES ethernet_vm
		                                                            CHOICES multis
		                                                            CHOICES multis_fcoe
		                                                            CHOICES rame_relay1490
		                                                            CHOICES bert
		                                                            CHOICES frame_relay2427
		                                                            CHOICES frame_relay_cisco
		                                                            CHOICES srp
		                                                            CHOICES srp_cisco
		                                                            CHOICES rpr
		                                                            CHOICES gfp
		                                                            CHOICES ethernet_fcoe
		                                                            CHOICES fc]
		        [-intrinsic_latency_adjustment                      CHOICES 0 1]
		        [-ipv6_gateway                                      IPV6]
		x       [-ipv6_gateway_step                                 IPV6
		x                                                           DEFAULT 0000:0000:0000:0000:0000:0000:0000:0001]
		        [-ipv6_intf_addr                                    IPV6]
		x       [-ipv6_intf_addr_step                               IPV6
		x                                                           DEFAULT 0000:0000:0000:0000:0000:0000:0000:0001]
		        [-ipv6_prefix_length                                ANY]
		x       [-ipv6_addr_mode                                    CHOICES static autoconfig]
		x       [-l23_config_type                                   CHOICES protocol_interface
		x                                                           CHOICES static_endpoint
		x                                                           DEFAULT protocol_interface]
		        [-mode                                              CHOICES config modify destroy
		                                                            DEFAULT config]
		n       [-mss                                               ANY]
		x       [-mtu                                               RANGE 68-9216
		x                                                           DEFAULT 1500]
		        [-netmask                                           MASK]
		x       [-ndp_send_req                                      CHOICES 0 1]
		x       [-no_write                                          FLAG]
		x       [-ns_on_linkup                                      CHOICES 0 1
		x                                                           DEFAULT 0]
		        [-op_mode                                           CHOICES loopback
		                                                            CHOICES normal
		                                                            CHOICES monitor
		                                                            CHOICES sim_disconnect]
		x       [-override_existence_check                          CHOICES 0 1
		x                                                           DEFAULT 0]
		x       [-override_tracking                                 CHOICES 0 1
		x                                                           DEFAULT 0]
		x       [-check_gateway_exists                              CHOICES 0 1
		x                                                           DEFAULT 0]
		        [-check_opposite_ip_version                         CHOICES 0 1
		                                                            DEFAULT 1]
		x       [-pcs_period                                        NUMERIC]
		x       [-pcs_count                                         NUMERIC]
		x       [-pcs_repeat                                        NUMERIC]
		x       [-pcs_period_type                                   NUMERIC]
		x       [-pcs_lane                                          NUMERIC]
		x       [-pcs_enabled_continuous                            CHOICES 0 1]
		x       [-pcs_sync_bits                                     ANY]
		x       [-pcs_marker_fields                                 ANY]
		x       [-pgid_128k_bin_enable                              CHOICES 0 1]
		x       [-pgid_mask                                         ANY]
		x       [-pgid_offset                                       RANGE 4-32677]
		x       [-pgid_mode                                         CHOICES custom
		x                                                           CHOICES dscp
		x                                                           CHOICES ipv6TC
		x                                                           CHOICES mplsExp
		x                                                           CHOICES split
		x                                                           CHOICES outer_vlan_priority
		x                                                           CHOICES outer_vlan_id_4
		x                                                           CHOICES outer_vlan_id_6
		x                                                           CHOICES outer_vlan_id_8
		x                                                           CHOICES outer_vlan_id_10
		x                                                           CHOICES outer_vlan_id_12
		x                                                           CHOICES inner_vlan_priority
		x                                                           CHOICES inner_vlan_id_4
		x                                                           CHOICES inner_vlan_id_6
		x                                                           CHOICES inner_vlan_id_8
		x                                                           CHOICES inner_vlan_id_10
		x                                                           CHOICES inner_vlan_id_12
		x                                                           CHOICES tos_precedence
		x                                                           CHOICES ipv6TC_bits_0_2
		x                                                           CHOICES ipv6TC_bits_0_5]
		x       [-pgid_encap                                        CHOICES LLCRoutedCLIP
		x                                                           CHOICES LLCPPPoA
		x                                                           CHOICES LLCBridgedEthernetFCS
		x                                                           CHOICES LLCBridgedEthernetNoFCS
		x                                                           CHOICES VccMuxPPPoA
		x                                                           CHOICES VccMuxIPV4Routed
		x                                                           CHOICES VccMuxBridgedEthernetFCS
		x                                                           CHOICES VccMuxBridgedEthernetNoFCS]
		x       [-pgid_split1_mask                                  ANY]
		x       [-pgid_split1_offset                                NUMERIC]
		x       [-pgid_split1_offset_from                           CHOICES start_of_frame]
		x       [-pgid_split2_mask                                  ANY]
		x       [-pgid_split2_offset                                NUMERIC]
		x       [-pgid_split2_offset_from                           CHOICES start_of_frame]
		x       [-pgid_split2_width                                 RANGE 0-4]
		x       [-pgid_split3_mask                                  ANY]
		x       [-pgid_split3_offset                                NUMERIC]
		x       [-pgid_split3_offset_from                           CHOICES start_of_frame]
		x       [-pgid_split3_width                                 RANGE 0-4]
		        [-phy_mode                                          CHOICES copper fiber sgmii]
		x       [-master_slave_mode                                 CHOICES auto master slave
		x                                                           DEFAULT auto]
		x       [-port_rx_mode                                      REGEXP ^( *{{0,1} *(capture_and_measure|capture|echo|packet_group|data_integrity|sequence_checking|wide_packet_group|auto_detect_instrumentation) *}{0,1} *)+$
		x                                                           CHOICES capture
		x                                                           CHOICES packet_group
		x                                                           CHOICES data_integrity
		x                                                           CHOICES sequence_checking
		x                                                           CHOICES wide_packet_group
		x                                                           CHOICES echo
		x                                                           CHOICES auto_detect_instrumentation
		x                                                           CHOICES capture_and_measure]
		x       [-ppp_ipv4_address                                  IPV4]
		x       [-ppp_ipv4_negotiation                              CHOICES 0 1]
		x       [-ppp_ipv6_negotiation                              CHOICES 0 1]
		x       [-ppp_mpls_negotiation                              CHOICES 0 1]
		x       [-ppp_osi_negotiation                               CHOICES 0 1]
		n       [-pvc_incr_mode                                     ANY]
		x       [-qinq_incr_mode                                    CHOICES inner outer both
		x                                                           DEFAULT both]
		x       [-qos_byte_offset                                   RANGE 0-63]
		x       [-qos_packet_type                                   CHOICES ethernet
		x                                                           CHOICES ip_snap
		x                                                           CHOICES vlan
		x                                                           CHOICES custom
		x                                                           CHOICES ip_ppp
		x                                                           CHOICES ip_cisco_hdlc
		x                                                           CHOICES ip_atm]
		x       [-qos_pattern_mask                                  ANY]
		x       [-qos_pattern_match                                 ANY]
		x       [-qos_pattern_offset                                RANGE 0-65535]
		x       [-qos_stats                                         CHOICES 0 1]
		x       [-router_solicitation_retries                       RANGE 1-100
		x                                                           DEFAULT 2]
		x       [-rpr_hec_seed                                      CHOICES 0 1]
		        [-rx_c2                                             ANY]
		        [-rx_fcs                                            CHOICES 16 32]
		        [-rx_scrambling                                     CHOICES 0 1]
		x       [-send_router_solicitation                          CHOICES 0 1]
		x       [-sequence_checking                                 CHOICES 0 1]
		x       [-sequence_num_offset                               RANGE 24-64000]
		x       [-signature                                         REGEXP ^[0-9a-fA-F]{2}([.: ]{0,1}){0,11}[0-9a-fA-F]{2}$]
		x       [-signature_mask                                    REGEXP ^[0-9a-fA-F]{2}([.: ]{0,1}){0,11}[0-9a-fA-F]{2}$]
		x       [-signature_offset                                  RANGE 24-64000]
		x       [-signature_start_offset                            RANGE 0-64000]
		x       [-single_arp_per_gateway                            CHOICES 0 1
		x                                                           DEFAULT 1]
		x       [-single_ns_per_gateway                             CHOICES 0 1
		x                                                           DEFAULT 1]
		        [-speed                                             CHOICES ether10
		                                                            CHOICES ether100
		                                                            CHOICES ether1000
		                                                            CHOICES oc3
		                                                            CHOICES oc12
		                                                            CHOICES oc48
		                                                            CHOICES oc192
		                                                            CHOICES auto
		                                                            CHOICES ether10000wan
		                                                            CHOICES ether10000lan
		                                                            CHOICES ether40000lan
		                                                            CHOICES ether100000lan
		                                                            CHOICES ether10Gig
		                                                            CHOICES ether25Gig
		                                                            CHOICES ether40Gig
		                                                            CHOICES ether100Gig
		                                                            CHOICES fc2000
		                                                            CHOICES fc4000
		                                                            CHOICES fc8000
		                                                            CHOICES ether100vm
		                                                            CHOICES ether1000vm
		                                                            CHOICES ether2000vm
		                                                            CHOICES ether3000vm
		                                                            CHOICES ether4000vm
		                                                            CHOICES ether5000vm
		                                                            CHOICES ether6000vm
		                                                            CHOICES ether7000vm
		                                                            CHOICES ether8000vm
		                                                            CHOICES ether9000vm
		                                                            CHOICES ether10000vm]
		        [-src_mac_addr                                      MAC]
		x       [-src_mac_addr_step                                 MAC
		x                                                           DEFAULT 0000.0000.0001]
		n       [-target_link_layer_address                         ANY]
		        [-transmit_clock_source                             CHOICES internal
		                                                            CHOICES bits
		                                                            CHOICES loop
		                                                            CHOICES external
		                                                            CHOICES internal_ppm_adj]
		x       [-transmit_mode                                     CHOICES advanced
		x                                                           CHOICES stream
		x                                                           CHOICES advanced_coarse
		x                                                           CHOICES stream_coarse]
		        [-tx_c2                                             ANY]
		        [-tx_fcs                                            CHOICES 16 32]
		        [-tx_rx_sync_stats_enable                           CHOICES 0 1]
		        [-tx_rx_sync_stats_interval                         NUMERIC]
		        [-tx_scrambling                                     CHOICES 0 1]
		n       [-vci                                               ANY]
		n       [-vci_count                                         ANY]
		n       [-vci_step                                          ANY]
		        [-vlan                                              CHOICES 0 1]
		x       [-vlan_id                                           REGEXP ^[0-9]{1,4}(,[0-9]{1,4}){0,5}$
		x                                                           RANGE 0-4096]
		x       [-vlan_id_step                                      REGEXP ^[0-9]{1,4}(,[0-9]{1,4}){0,5}$
		x                                                           RANGE 0-4096
		x                                                           DEFAULT 1]
		x       [-vlan_id_count                                     REGEXP ^[0-9]{1,4}(,[0-9]{1,4}){0,5}$
		x                                                           RANGE 1-4094
		x                                                           DEFAULT 4094]
		x       [-vlan_tpid                                         CHOICES 0x8100
		x                                                           CHOICES 0x88a8
		x                                                           CHOICES 0x88A8
		x                                                           CHOICES 0x9100
		x                                                           CHOICES 0x9200
		x                                                           CHOICES 0x9300
		x                                                           DEFAULT 0x8100]
		x       [-vlan_user_priority                                REGEXP ^[0-7](,[0-7]){0,5}$
		x                                                           RANGE 0-7
		x                                                           DEFAULT 0]
		x       [-vlan_user_priority_step                           REGEXP ^[0-7](,[0-7]){0,5}$
		x                                                           RANGE 0-7
		x                                                           DEFAULT 1]
		x       [-vlan_id_list                                      REGEXP ^[0-9]{1,4}(,[0-9]{1,4}){0,5}$
		x                                                           RANGE 0-4096]
		x       [-vlan_id_mode                                      CHOICES fixed increment]
		x       [-vlan_protocol_id                                  CHOICES 0x8100
		x                                                           CHOICES 0x88a8
		x                                                           CHOICES 0x88A8
		x                                                           CHOICES 0x9100
		x                                                           CHOICES 0x9200
		x                                                           CHOICES 0x9300]
		x       [-vlan_id_inner                                     REGEXP ^[0-9]{1,4}(,[0-9]{1,4}){0,5}$
		x                                                           RANGE 0-4096]
		x       [-vlan_id_inner_mode                                CHOICES fixed increment]
		x       [-vlan_id_inner_count                               RANGE 1-4096]
		x       [-vlan_id_inner_step                                RANGE 0-4096
		x                                                           DEFAULT 1]
		x       [-use_vpn_parameters                                CHOICES 0 1]
		x       [-site_id                                           NUMERIC]
		n       [-vpi                                               ANY]
		n       [-vpi_count                                         ANY]
		n       [-vpi_step                                          ANY]
		x       [-enable_flow_control                               CHOICES fixed increment
		x                                                           CHOICES 0 1
		x                                                           DEFAULT 1]
		x       [-enable_ndp                                        CHOICES 0 1
		x                                                           DEFAULT 1]
		x       [-flow_control_directed_addr                        ANY]
		x       [-fcoe_priority_groups                              ANY]
		        [-fcoe_support_data_center_mode                     CHOICES 0 1]
		x       [-fcoe_priority_group_size                          CHOICES 4 8]
		x       [-fcoe_flow_control_type                            CHOICES ieee802.3x ieee802.1Qbb]
		x       [-fc_credit_starvation_value                        NUMERIC
		x                                                           DEFAULT 0]
		x       [-fc_no_rrdy_after                                  NUMERIC
		x                                                           DEFAULT 100]
		n       [-fc_tx_ignore_rx_link_faults                       ANY]
		x       [-tx_ignore_rx_link_faults                          CHOICES 0 1]
		x       [-laser_on                                          CHOICES 0 1]
		x       [-fc_max_delay_for_random_value                     RANGE 0-1000000
		x                                                           DEFAULT 0]
		x       [-fc_tx_ignore_available_credits                    CHOICES 0 1
		x                                                           DEFAULT 0]
		x       [-fc_min_delay_for_random_value                     NUMERIC
		x                                                           DEFAULT 0]
		x       [-fc_rrdy_response_delays                           CHOICES credit_starvation
		x                                                           CHOICES fixed_delay
		x                                                           CHOICES no_delay
		x                                                           CHOICES random_delay
		x                                                           DEFAULT no_delay]
		x       [-fc_fixed_delay_value                              RANGE 0-20000
		x                                                           DEFAULT 1]
		x       [-fc_force_errors                                   CHOICES no_errors
		x                                                           CHOICES no_rrdy
		x                                                           CHOICES no_rrdy_every
		x                                                           DEFAULT no_errors]
		x       [-enable_data_center_shared_stats                   CHOICES 0 1]
		x       [-additional_fcoe_stat_1                            CHOICES fcoe_invalid_delimiter
		x                                                           CHOICES fcoe_invalid_frames
		x                                                           CHOICES fcoe_invalid_size
		x                                                           CHOICES fcoe_normal_size_bad_fc_crc
		x                                                           CHOICES fcoe_normal_size_good_fc_crc
		x                                                           CHOICES fcoe_undersize_bad_fc_crc
		x                                                           CHOICES fcoe_undersize_good_fc_crc
		x                                                           CHOICES fcoe_valid_frames]
		x       [-additional_fcoe_stat_2                            CHOICES fcoe_invalid_delimiter
		x                                                           CHOICES fcoe_invalid_frames
		x                                                           CHOICES fcoe_invalid_size
		x                                                           CHOICES fcoe_normal_size_bad_fc_crc
		x                                                           CHOICES fcoe_normal_size_good_fc_crc
		x                                                           CHOICES fcoe_undersize_bad_fc_crc
		x                                                           CHOICES fcoe_undersize_good_fc_crc
		x                                                           CHOICES fcoe_valid_frames]
		x       [-tx_gap_control_mode                               CHOICES fixed average]
		x       [-tx_lanes                                          ANY]
		        [-static_enable                                     CHOICES 0 1
		                                                            DEFAULT 0]
		n       [-static_atm_header_encapsulation                   ANY]
		n       [-static_atm_range_count                            ANY]
		n       [-static_vci                                        ANY]
		n       [-static_vci_increment                              ANY]
		n       [-static_vci_increment_step                         ANY]
		n       [-static_vci_step                                   ANY]
		n       [-static_pvc_count                                  ANY]
		n       [-static_pvc_count_step                             ANY]
		n       [-static_vpi                                        ANY]
		n       [-static_vpi_increment                              ANY]
		n       [-static_vpi_increment_step                         ANY]
		n       [-static_vpi_step                                   ANY]
		n       [-static_dlci_count_mode                            ANY]
		n       [-static_dlci_repeat_count                          ANY]
		n       [-static_dlci_repeat_count_step                     ANY]
		n       [-static_dlci_value                                 ANY]
		n       [-static_dlci_value_step                            ANY]
		n       [-static_fr_range_count                             ANY]
		        [-static_intf_handle                                ANY]
		        [-static_ip_dst_count                               RANGE 1-4294967295
		                                                            DEFAULT 1]
		        [-static_ip_dst_count_step                          NUMERIC
		                                                            DEFAULT 0]
		        [-static_ip_dst_addr                                IP
		                                                            DEFAULT 0.0.0.0]
		        [-static_ip_dst_increment                           IP
		                                                            DEFAULT 0.0.0.1]
		        [-static_ip_dst_increment_step                      IP
		                                                            DEFAULT 0.0.0.0]
		        [-static_ip_dst_range_step                          IP
		                                                            DEFAULT 0.0.0.0]
		        [-static_ip_dst_prefix_len                          RANGE 0-128
		                                                            DEFAULT 24]
		        [-static_ip_dst_prefix_len_step                     NUMERIC
		                                                            DEFAULT 0]
		        [-static_ip_range_count                             NUMERIC
		                                                            DEFAULT 0]
		        [-static_l3_protocol                                CHOICES ipv4 ipv6
		                                                            DEFAULT ipv4]
		n       [-static_indirect                                   ANY]
		n       [-static_range_per_spoke                            ANY]
		n       [-static_lan_intermediate_objref                    ANY]
		        [-static_lan_range_count                            NUMERIC
		                                                            DEFAULT 0]
		        [-static_mac_dst                                    MAC
		                                                            DEFAULT 0000.0000.0000]
		        [-static_mac_dst_count                              RANGE 1-4294967295
		                                                            DEFAULT 1]
		        [-static_mac_dst_count_step                         NUMERIC
		                                                            DEFAULT 0]
		        [-static_mac_dst_mode                               CHOICES fixed increment
		                                                            DEFAULT increment]
		        [-static_mac_dst_step                               NUMERIC
		                                                            DEFAULT 0]
		        [-static_site_id                                    RANGE 0-4294967295
		                                                            DEFAULT 0]
		        [-static_site_id_enable                             CHOICES 0 1
		                                                            DEFAULT 0]
		        [-static_site_id_step                               NUMERIC
		                                                            DEFAULT 0]
		        [-static_vlan_enable                                ANY
		                                                            DEFAULT 0]
		        [-static_vlan_id                                    RANGE 1-4095
		                                                            DEFAULT 1]
		        [-static_vlan_id_mode                               CHOICES fixed increment inner outer
		                                                            DEFAULT fixed]
		        [-static_vlan_id_step                               ANY
		                                                            DEFAULT 0]
		x       [-static_lan_count_per_vc                           NUMERIC
		x                                                           DEFAULT 1]
		x       [-static_lan_incr_per_vc_vlan_mode                  CHOICES fixed increment inner outer
		x                                                           DEFAULT fixed]
		x       [-static_lan_mac_range_mode                         CHOICES normal bundled
		x                                                           DEFAULT normal]
		x       [-static_lan_number_of_vcs                          NUMERIC
		x                                                           DEFAULT 1]
		x       [-static_lan_skip_vlan_id_zero                      CHOICES 0 1
		x                                                           DEFAULT 1]
		x       [-static_lan_tpid                                   CHOICES 0x8100
		x                                                           CHOICES 0x88a8
		x                                                           CHOICES 0x88A8
		x                                                           CHOICES 0x9100
		x                                                           CHOICES 0x9200
		x                                                           DEFAULT 0x8100]
		x       [-static_lan_vlan_priority                          RANGE 0-7
		x                                                           DEFAULT 0]
		x       [-static_lan_vlan_stack_count                       NUMERIC
		x                                                           DEFAULT 1]
		n       [-static_ig_atm_encap                               ANY]
		n       [-static_ig_vlan_enable                             ANY]
		n       [-static_ig_ip_type                                 ANY]
		n       [-static_ig_interface_enable_list                   ANY]
		n       [-static_ig_interface_handle_list                   ANY]
		n       [-static_ig_range_count                             ANY]
		x       [-pgid_split1_width                                 RANGE 0-4]
		n       [-aps                                               ANY]
		n       [-aps_arch                                          ANY]
		n       [-aps_channel                                       ANY]
		n       [-aps_request_1_1                                   ANY]
		n       [-aps_request_1_n                                   ANY]
		n       [-aps_switch_mode                                   ANY]
		n       [-auto_line_rdi                                     ANY]
		n       [-auto_line_rei                                     ANY]
		n       [-auto_path_rdi                                     ANY]
		n       [-auto_path_rei                                     ANY]
		n       [-crlf_path_trace                                   ANY]
		n       [-control_plane_mtu                                 ANY]
		n       [-dst_mac_addr                                      ANY]
		n       [-ignore_pause_frames                               ANY]
		n       [-interpacket_gap                                   ANY]
		n       [-long_lof_wait                                     ANY]
		n       [-output_enable                                     ANY]
		n       [-pause_length                                      ANY]
		n       [-rx_enhanced_prdi                                  ANY]
		n       [-rx_equalization                                   ANY]
		n       [-rx_hec                                            ANY]
		n       [-section_unequip                                   ANY]
		n       [-signal_fail_ber                                   ANY]
		n       [-ss_bits_pointer_interp                            ANY]
		n       [-tx_enhanced_prdi                                  ANY]
		n       [-tx_k2                                             ANY]
		n       [-tx_preemphasis_main_tap                           ANY]
		n       [-tx_preemphasis_post_tap                           ANY]
		n       [-tx_s1                                             ANY]
		x       [-ethernet_attempt_enabled                          CHOICES 0 1]
		x       [-ethernet_attempt_rate                             RANGE 1-1000]
		x       [-ethernet_attempt_interval                         NUMERIC]
		x       [-ethernet_attempt_scale_mode                       CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ethernet_diconnect_enabled                        CHOICES 0 1]
		x       [-ethernet_disconnect_rate                          RANGE 1-1000]
		x       [-ethernet_disconnect_interval                      NUMERIC]
		x       [-ethernet_disconnect_scale_mode                    CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ipv4_send_arp_rate                                RANGE 1-1000]
		x       [-ipv4_send_arp_interval                            NUMERIC]
		x       [-ipv4_send_arp_max_outstanding                     RANGE 1-1000]
		x       [-ipv4_send_arp_scale_mode                          CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ipv4_attempt_enabled                              CHOICES 0 1]
		x       [-ipv4_attempt_rate                                 RANGE 1-1000]
		x       [-ipv4_attempt_interval                             NUMERIC]
		x       [-ipv4_attempt_scale_mode                           CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ipv4_diconnect_enabled                            CHOICES 0 1]
		x       [-ipv4_disconnect_rate                              RANGE 1-1000]
		x       [-ipv4_disconnect_interval                          NUMERIC]
		x       [-ipv4_disconnect_scale_mode                        CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ipv6_send_ns_rate                                 RANGE 1-1000]
		x       [-ipv6_send_ns_interval                             NUMERIC]
		x       [-ipv6_send_ns_max_outstanding                      RANGE 1-1000]
		x       [-ipv6_send_ns_scale_mode                           CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ipv6_attempt_enabled                              CHOICES 0 1]
		x       [-ipv6_attempt_rate                                 RANGE 1-1000]
		x       [-ipv6_attempt_interval                             NUMERIC]
		x       [-ipv6_attempt_scale_mode                           CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ipv6_diconnect_enabled                            CHOICES 0 1]
		x       [-ipv6_disconnect_rate                              RANGE 1-1000]
		x       [-ipv6_disconnect_interval                          NUMERIC]
		x       [-ipv6_disconnect_scale_mode                        CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ipv6_autoconfiguration_send_ns_enabled            CHOICES 0 1]
		x       [-ipv6_autoconfiguration_send_ns_rate               RANGE 1-1000]
		x       [-ipv6_autoconfiguration_send_ns_interval           NUMERIC]
		x       [-ipv6_autoconfiguration_send_ns_max_outstanding    RANGE 1-1000]
		x       [-ipv6_autoconfiguration_send_ns_scale_mode         CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ipv6_autoconfiguration_send_rs_enabled            CHOICES 0 1]
		x       [-ipv6_autoconfiguration_send_rs_rate               RANGE 1-1000]
		x       [-ipv6_autoconfiguration_send_rs_interval           NUMERIC]
		x       [-ipv6_autoconfiguration_send_rs_max_outstanding    RANGE 1-1000]
		x       [-ipv6_autoconfiguration_send_rs_scale_mode         CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ipv6_autoconfiguration_attempt_enabled            CHOICES 0 1]
		x       [-ipv6_autoconfiguration_attempt_rate               RANGE 1-1000]
		x       [-ipv6_autoconfiguration_attempt_interval           NUMERIC]
		x       [-ipv6_autoconfiguration_attempt_max_outstanding    RANGE 1-1000]
		x       [-ipv6_autoconfiguration_attempt_scale_mode         CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-ipv6_autoconfiguration_disconnect_enabled         CHOICES 0 1]
		x       [-ipv6_autoconfiguration_disconnect_rate            RANGE 1-1000]
		x       [-ipv6_autoconfiguration_disconnect_interval        NUMERIC]
		x       [-ipv6_autoconfiguration_disconnect_max_outstanding RANGE 1-1000]
		x       [-ipv6_autoconfiguration_disconnect_scale_mode      CHOICES port device_group
		x                                                           DEFAULT port]
		x       [-notify_mac_move                                   CHOICES 0 1]
		x       [-ipv4_re_send_arp_on_link_up                       ANY]
		x       [-ipv6_re_send_ns_on_link_up                        ANY]
		
		 Arguments:
		    -port_handle
		        List of ports of which to take ownership and perform configuration.
		        This option takes a list of port handles.
		x   -protocol_name
		x       This is the name of the protocol stack as it appears in the GUI.
		x   -protocol_handle
		x       Handle for the stack that the user wants to modify or delete.
		x   -enable_loopback
		x       This argument can be used to trigger the addition of loopback
		x       IPv4 or IPv6 protocols instead of the usual ones.
		x   -connected_to_handle
		x       A handle to another ethernet or loopback stack through which the current
		x       protocol stack will be connected.
		x       This argument will be ignored if the current protocol stack does not support
		x       connectors.
		x   -ipv6_multiplier
		x       This is the multiplier for the IPv6 stack as its used in the custom ratios.
		x   -ipv6_loopback_multiplier
		x       This is the multiplier for the IPv6 loopback stack as its used in the custom ratios.
		x   -ipv4_resolve_gateway
		x       Autoresolve gateway MAC addresses.
		x   -ipv4_manual_gateway_mac
		x       The manual gateway MAC addresses.
		x       This option has no effect unless ipv4_autoresolve_gateway_mac is set to 0.
		x   -ipv4_manual_gateway_mac_step
		x       The step of the manual gateway MAC addresses.
		x       This option has no effect unless ipv4_autoresolve_gateway_mac is set to 0.
		x   -ipv6_resolve_gateway
		x       Autoresolve gateway MAC addresses.
		x   -ipv6_manual_gateway_mac
		x       The manual gateway MAC addresses.
		x       This option has no effect unless ipv6_resolve_gateway is set to 0.
		x   -ipv6_manual_gateway_mac_step
		x       The step of the manual gateway MAC addresses.
		x       This option has no effect unless ipv6_resolve_gateway is set to 0.
		x   -send_ping
		x       Sends ping from the specified interfaces or protocol handles
		x       to the destination specified in ping_dst.
		x       This argument will have no effect if no ping_dst is specified.
		x   -ping_dst
		x       Specifies what destination to ping.
		x   -addresses_per_svlan
		x       How often a new outer VLAN ID is generated.
		x       This parameter is valid only when l23_config_type is static_endpoint (new API).
		n   -addresses_per_vci
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -addresses_per_vlan
		x       How often a new VLAN ID/inner VLAN ID is generated.
		x       This parameter is valid only when l23_config_type is static_endpoint (new API).
		n   -addresses_per_vpi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -arp
		x       Enables or disables the -arp_send_req parameter. If this is 0 -arp_send_req will be ignored.
		x   -arp_on_linkup
		x       Send ARP for the IPv4 interfaces when the port link becomes up.
		x       The option is global, for all ports and interfaces.
		x       This is valid only for the new API.
		x   -arp_req_retries
		x       The number of times the arp request will be attempted.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		n   -arp_req_timer
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -arp_send_req
		        Whether sending an ARP request to the DUT is enabled. You can use this
		        basic function to ensure correct addressing of the interfaces. By
		        default, the ARP is sent on the Ethernet port.
		        For IPv4 interfaces the arp request is sent to the gateway.
		        For IPv6 interfaces a router solicitation is sent to 'all routers'
		        multicast address.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Valid options are:
		        0 - Disable (DEFAULT).
		        1 - Enable.
		x   -atm_enable_coset
		x       If 1, enables the Coset algorithm to be used with the Header Error
		x       Control (HEC) byte.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -atm_enable_pattern_matching
		x       If 1, then the use of capture and filter based on ATM patterns is
		x       enabled and the maximum number of VCCs is reduced to 12,288.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -arp_refresh_interval
		x       A user configurable ARP refresh timer
		n   -atm_encapsulation
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -atm_filler_cell
		x       SONET frame transmission is continuous even when data or control
		x       messages are not being transmitted.This option allows the cell
		x       type that is transmitted during these intervals.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -atm_interface_type
		x       The type of interface to emulate.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles. Valid choices are:
		x       uni - (default) user to network interface
		x       nni - network to network interface
		x   -atm_packet_decode_mode
		x       This setting controls the interpretation of received packets when
		x       they are decoded.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -atm_reassembly_timeout
		x       Sets the value for the Reassembly Timeout, which is the period of time
		x       (expressed in seconds) that the receive side will wait for another cell
		x       on that channel - for reassembly of cells into a CPCS PDU (packet).If
		x       no cell is received within that period, the timer will expire.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		    -autonegotiation
		        Whether to enable auto-negotiation on each interface.
		        When the new IxNetwork TCL API is used and the autonegotiation is
		        enabled, the autonegotiation is performed using all the existing
		        Ethernet speed/duplex combinations: 1000, 100full, 100half, 10full
		        and 10half. The feature from HLTAPI 2.90, which allowed the user to
		        select only a subset of speed/duplex combinations to be used in the
		        autonegotiation process, is not supported by IxNetwork at this moment.
		        If the autonegotition is enabled, the speed and duplex options are
		        ignored.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Valid options are:
		        0 - Disable
		        1 - Enable (DEFAULT)
		x   -auto_detect_instrumentation_type
		x       How to insert the instrumentation signature. Valid only is port_rx_mode is auto_detect_instrumentation.
		x       Valid only for the new API (IxTclNetwork).
		x   -bert_configuration
		x       This option takes a list of physical lanes . This parameter is valid only with IxTclHal api.It has the following structure:
		x       <phy_lane>:<tx_pattern>,<tx_invert>,<rx_pattern>,<rx_invert>,<enable_stats>|....
		x       phy_lane - physical lane, it can take values from 0A-9A,0B-9B for 100Gig ports, and 0A-3A for 40Gig ports.
		x       tx_pattern - If set, indicates that the transmitted pattern is to be inverted. Valid options are:
		x       PRBS-31 - the 2^31 pattern as specified in ITU-T0151 is expected
		x       PRBS-23 - the 2^23 pattern as specified in ITU-T0151 is expected
		x       PRBS-20 - the 2^20 pattern as specified in ITU-T0151 is expected
		x       PRBS-15 - the 2^15 pattern as specified in ITU-T0151 is expected
		x       PRBS-11 - the 2^11 pattern as specified in ITU-T0151 is expected
		x       PRBS-9 - the 2^9 pattern as specified in ITU-T0151 is expected
		x       PRBS-7 - the 2^7 pattern as specified in ITU-T0151 is expected
		x       lane_detection - used to detect the lane pattern and how the lanes are connected between ports
		x       alternating - alternating ones and zeroes are expected
		x       all1 - all ones are expected
		x       tx_invert - If set, indicates that the transmitted pattern is to be inverted. Valid options are:
		x       0 - disable
		x       1- enable
		x       (default = disable)
		x       rx_pattern - If set, indicates the expected receive pattern. Valid options are:
		x       PRBS-31 - the 2^31 pattern as specified in ITU-T0151 is expected
		x       PRBS-23 - the 2^23 pattern as specified in ITU-T0151 is expected
		x       PRBS-20 - the 2^20 pattern as specified in ITU-T0151 is expected
		x       PRBS-15 - the 2^15 pattern as specified in ITU-T0151 is expected
		x       PRBS-11 - the 2^11 pattern as specified in ITU-T0151 is expected
		x       PRBS-9 - the 2^9 pattern as specified in ITU-T0151 is expected
		x       PRBS-7 - the 2^7 pattern as specified in ITU-T0151 is expected
		x       auto_detect - the pattern is automatically detected by the receiver.
		x       alternating - alternating ones and zeroes are expected.
		x       all1 - all ones are expected.
		x       rx_invert -If txRxPatternMode is set to independent, this indicates that the expected receive
		x       pattern is to be inverted. Valid options are:
		x       0 - disable
		x       1 - enable
		x       (default = disable)
		x       enable_stats - Only applicable when bert mode is active. If set, enables BERT lane
		x       statistics to be collected. Valid options are:
		x       0 - disable
		x       1 - enable
		x       (default = disable)
		x   -bert_error_insertion
		x       This command is used to configure the insertion of deliberate errors on a port. It takes
		x       a list of physical lanes for the error insertion. This parameter is valid only with IxTclHal api. It has the following structure:
		x       <phy_lane>:<single_error>,<error_bit_rate>,<error_bit_rate_unit>,<insert>|....
		x       phy_lane - physical lane, it can take values from 0A-9A,0B-9B for 100Gig ports, and 0A-3A for 40Gig ports.
		x       single_error - insert single error value
		x       error_bit_rate - a 32-bit mask, expressed as a list of four one-byte
		x       elements, which indicates which bit in a 32-bit word is to be errored.
		x       (default = 1)
		x       error_bit_rate_unit - During continuous burst rate situations, this is the error rate. Valid options are:
		x       e-2 - An error is inserted every 2^2 (4) bits.
		x       e-3 - An error is inserted every 2^3 (8) bits.
		x       e-4 - An error is inserted every 2^4 (16) bits.
		x       e-5 - An error is inserted every 2^5 (32) bits.
		x       e-6 - An error is inserted every 2^6 (64) bits.
		x       e-7 - An error is inserted every 2^7 (128) bits.
		x       e-8 - An error is inserted every 2^8 (256) bits.
		x       e-9 - An error is inserted every 2^9 (512) bits.
		x       e-10 - An error is inserted every 2^10 (1024) bits.
		x       e-11 - An error is inserted every 2^11 (2048) bits.
		x       insert - choose whether to insert the error or not
		    -clocksource
		        Clock source for SONET interfaces at which each interface is
		        configured.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		x   -connected_count
		x       The number of connected interfaces to be created, when trying to create
		x       multiple interfaces with a single interface_config call.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when static_enable is 0 and l23_config_type
		x       is static_endpoint or protocol_interface(new API).
		x   -data_integrity
		x       Whether to enable the data integrity checking capability on the port.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       Valid options are:
		x       0 - Disable (DEFAULT)
		x       1 - Enable
		    -duplex
		        Whether duplex is full or half.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		    -framing
		        POS interface type.
		        This option takes a list of values when -port_handle is a list of
		        port handles. Valid options are:
		        sonet
		        sdh
		    -gateway
		        List of IP addresses that configure the addresses of the gateway (that
		        is, the DUT interface IP addresses).
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		x   -gateway_incr_mode
		x       Determines when the gateway addresses are incremented.
		x       This option is valid only when l23_config_type is static_endpoint (new API).
		x   -gateway_step
		x       The incrementing step for the gateway address of the interface, when
		x       connected_count is greater than 1.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is static_endpoint.
		x   -gre_checksum_enable
		x       Enable/disable checksum on a GRE interface.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is protocol_interface.
		x   -gre_count
		x       The number of GRE interfaces to be created for each connected
		x       interface.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is protocol_interface.
		x   -gre_dst_ip_addr
		x       GRE tunnel destination IP address.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is protocol_interface.
		x   -gre_dst_ip_addr_step
		x       The incrementing step for the GRE Destination IP address of the
		x       interface, when connected_count is greater than 1.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is protocol_interface.
		n   -gre_ip_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -gre_ip_addr_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -gre_ip_prefix_length
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -gre_ipv6_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -gre_ipv6_addr_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -gre_ipv6_prefix_length
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -gre_key_enable
		x       Enable/disable key on a GRE interface.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is protocol_interface.
		x   -gre_key_in
		x       Value of the IN key on a GRE interface.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is protocol_interface.
		x   -gre_key_out
		x       Value of the OUT key on a GRE interface.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is protocol_interface.
		x   -gre_seq_enable
		x       Enable/disable sequencing on a GRE interface.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is protocol_interface.
		    -ignore_link
		        Transmit ignores the link status on Ethernet, POS or ATM port if set to
		        true.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		x   -integrity_signature
		x       Signature used in the packet for data integrity checking. When the
		x       Receive Mode for a port is configured to check for data integrity,
		x       received packets are matched for the data integrity signature value.
		x       This signature is a 4-byte value.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -integrity_signature_offset
		x       The offset of the data integrity signature in the packet.
		x       If -port_rx_mode is set to auto_detect_instrumentation then this
		x       offset will be ignored, only the -integrity_signature is needed.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		    -interface_handle
		        This parameter takes a list of interface handles. It is used
		        with -mode modify in order to modify L2-3 settings
		        when -l23_config_type is protocol_interface.
		        Parameter valid only with IxTclNetwork.
		        If the interface handle represents a routed interface,
		        the interface cannot be modified into a connected interface
		        (it can only be routed to another connected interface).
		    -internal_ppm_adjust
		        Parameter valid only when transmit_clock_source is set on internal_ppm_adj.
		        Specifies the PPM value to adjust the IEEE clock frequency tolerance.
		        This parameter can have values between -105,105
		    -intf_ip_addr
		        List of IP addresses that configure each of the traffic generation
		        tool interfaces.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		x   -intf_ip_addr_step
		x       The incrementing step for the IPv4 address of the interface, when
		x       connected_count is greater than 1.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This is valid only for the new API.
		    -intf_mode
		        SONET header type.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Please check Ixia Hardware and Reference Manual for the list of cards that support
		        this feature.
		    -intrinsic_latency_adjustment
		        This option enables the Intrinsic Latency Adjustment for poets that support
		        this feature. Valid values are:
		        0 - Not enabled (DEFAULT)
		        1 - Enabled
		    -ipv6_gateway
		        List of IPV6 addresses that configure the addresses of the gateway (that
		        is, the DUT interface IP addresses).
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		x   -ipv6_gateway_step
		x       The incrementing step for the IPv6 gateway of the interface, when
		x       connected_count is greater than 1.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		    -ipv6_intf_addr
		        List of IPv6 addresses that configure each of the traffic generation
		        tool interfaces.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		x   -ipv6_intf_addr_step
		x       The incrementing step for the IPv6 address of the interface, when
		x       connected_count is greater than 1.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is static_endpoint.
		    -ipv6_prefix_length
		        The mask width of the IPv6 address in an interface.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		x   -ipv6_addr_mode
		x       The address mode for Static ipv6 endpoints. May be static or autoconfig.
		x       This option is valid only when l23_config_type is static_endpoint.
		x   -l23_config_type
		x       The type of IP interface that will be configured. This argument is only supported for legacy compatibility with the ixia namespace.
		    -mode
		        Action to be taken on the interface selected.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		n   -mss
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -mtu
		x       This option configure Maximum Trasmision Unit for created interfaces.
		x       This parameter can be an interfaces - one MTU value for each interface
		x       to be created.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		    -netmask
		        Network mask used for IP address configuration of the traffic
		        generation tool interfaces.
		x   -ndp_send_req
		x       See -send_router_solicitation parameter.
		x       If both -ndp_send_req and -send_router_solicitation are present, -ndp_send_req takes precedence.
		x   -no_write
		x       If this option is present, the configuration is not written to the
		x       hardware. This option can be used to queue up multiple configurations
		x       before writing to the hardware.
		x   -ns_on_linkup
		x       Send Neighbor Solicitation for the IPv6 interfaces when the port link becomes up.
		x       The option is global, for all ports and interfaces.
		    -op_mode
		        Operational mode on the interface.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Valid options are:
		        loopback
		        normal
		        monitor
		        sim_disconnect
		x   -override_existence_check
		x       If this option is enabled, the interface existence check is skipped but
		x       the list of interfaces is still created and maintained in order to keep
		x       track of existing interfaces if required. Using this option will speed
		x       up the interfaces' creation.
		x       Valid only for -l23_config_type protocol_interface.
		x   -override_tracking
		x       If this option is enabled, the list of interfaces won t be created and
		x       maintained anymore, thus, speeding up the interfaces' creation even
		x       more. Also, it will enable -override_existence_check in case it wasn t
		x       already enabled because checking for interface existence becomes
		x       impossible if the the list of interfaces doesn t exist anymore.
		x       Valid only for -l23_config_type protocol_interface.
		x   -check_gateway_exists
		x       If 0, this check offers the possibility of creating routed/unconnected
		x       interfaces as connected interfaces.
		x       If 1, the command will check if the provided gateway address can be
		x       found on an existing interface. If an interface with the gateway IP
		x       address exists, the interface required will be configured as unconnected.
		    -check_opposite_ip_version
		        This parameter is used when trying to configure dual stack interfaces.
		        For example, if an interface_config with ipv4 parameters is called,
		        the procedure will search for an existing interface with the same MAC
		        address and ipv6 settings. If such an interface is found and check_opposite_ip_version
		        is set to 1 this interface will have the ipv4 settings created or modified if ipv4
		        settings already exists. In case check_opposite_ip_version is set to 0, an error
		        specifying that the MAC address is unique per port will be thrown.
		x   -pcs_period
		x       Periodicity of transmitted errors. The unit of period differs based on the type of
		x       error (pcs_period_type) selected.
		x       Type = lane markers, period = lane markers
		x       Type = lane markers and payload, period = 64/66 bit words
		x   -pcs_count
		x       Consecutive errors to transmit.
		x   -pcs_repeat
		x       Total number of errors to transmit. This is value ignored if pcs_enabled_continuous is
		x       set to 1 (true).
		x   -pcs_period_type
		x       Use to configure the PCS Error Period Type.
		x       Valid values are:
		x       0 - pcsLaneErrorPeriodTypeLaneMarkers - Lane Markers period type (only)
		x       1 - pcsLaneErrorPeriodTypeLaneMarkersAndPayload - both Lane Markers
		x       and Payload period types
		x   -pcs_lane
		x       Specifies which lane to insert errors into.
		x       Valid values range:
		x       0   19 for 100G load modules;
		x       0   3 for 40G load modules.
		x   -pcs_enabled_continuous
		x       If set to true, will transmit errors continuously at the given period and count. If
		x       false, see repeat, below. Valid choices are:
		x       0 - false
		x       1 - true
		x   -pcs_sync_bits
		x       Hex field for entering the error bits for the sync field.
		x   -pcs_marker_fields
		x       Hex field for entering the lane marker fields.
		x       Valid formats are: 00.00.00.00.00.00.00.02 , 00:00:00:00:00:00:00:02
		x   -pgid_128k_bin_enable
		x       Enables the 128k bin mode so that the wide packet group receive
		x       mode will be larger.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_mask
		x       The mask value to use when the -port_rx_mode is set to
		x       wide_packet_group.Value is by default a two byte value, in hex form,
		x       without any spaces (e.g., AAAA).
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_offset
		x       The group ID offset value.
		x       If -port_rx_mode is set to auto_detect_instrumentation then this
		x       offset will be ignored, only the pgid value is needed.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_mode
		x       This option can be used to specify the PGID mode in the filter
		x       section, on specified RX port.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       The predifined split pgid offsets used for egress tracking with IxNetwork TCL API
		x       are fixed. They do not adjust if the offsets monitored in the received packets are shifted.
		x   -pgid_encap
		x       Available only with IxNetwork TCL API. When -pgid_mode is configured to
		x       'ipv6TC', 'dscp', 'mplsExp', 'tos_precedence', 'ipv6TC_bits_0_2' or 'ipv6TC_bits_0_2'
		x       and the port is ATM, this option configures the encapsulation used for
		x       egress tracking. Valid options are:
		x       LLCRoutedCLIP - default
		x       LLCPPPoA
		x       LLCBridgedEthernetFCS
		x       LLCBridgedEthernetNoFCS
		x       VccMuxPPPoA
		x       VccMuxIPV4Routed
		x       VccMuxBridgedEthernetFCS
		x       VccMuxBridgedEthernetNoFCS
		x   -pgid_split1_mask
		x       The PGID mask bits for the first split PGID. It is a hexadecimal value
		x       in the 0x<HEX_VALUE> format. This option is available only for
		x       traffic_generator ixos. This option has any meaning only if
		x       the -pgid_mode option is set to split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_split1_offset
		x       The offset in bytes from pgid_split1_offset_from.
		x       This option has any meaning only if the -pgid_mode option is set to split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_split1_offset_from
		x       The frame location from which the pgid_split1_offset value is
		x       computed. This option is available only for traffic_generator ixos.
		x       This option has any meaning only if the -pgid_mode option is set to
		x       split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_split2_mask
		x       The PGID mask bits for the second split PGID. It is a hexadecimal
		x       value in the 0x<HEX_VALUE> format. This option is available only for
		x       traffic_generator ixos. This option has any meaning only if
		x       the -pgid_mode option is set to split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_split2_offset
		x       The offset in bytes from pgid_split2_offset_from. This option is
		x       available only for traffic_generator ixos. This option has any meaning
		x       only if the -pgid_mode option is set to split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_split2_offset_from
		x       The frame location from which the pgid_split2_offset value is
		x       computed. This option is available only for traffic_generator ixos.
		x       This option has any meaning only if the -pgid_mode option is set to
		x       split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_split2_width
		x       The width, in bytes, of the split PGID. This option is available only
		x       for traffic_generator ixos. This option has any meaning only if
		x       the -pgid_mode option is set to split.
		x   -pgid_split3_mask
		x       The PGID mask bits for the third split PGID. It is a hexadecimal value
		x       in the 0x<HEX_VALUE> format. This option is available only for
		x       traffic_generator ixos. This option has any meaning only if
		x       the -pgid_mode option is set to split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_split3_offset
		x       The offset in bytes from pgid_split_offsetX_from. This option is
		x       available only for traffic_generator ixos. This option has any meaning
		x       only if the -pgid_mode option is set to split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_split3_offset_from
		x       The frame location from which the pgid_split3_offset value is
		x       computed. This option is available only for traffic_generator ixos.
		x       This option has any meaning only if the -pgid_mode option is set to
		x       split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -pgid_split3_width
		x       The width, in bytes, of the split PGID. This option is available only
		x       for traffic_generator ixos. This option has any meaning only if
		x       the -pgid_mode option is set to split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		    -phy_mode
		        For dual mode ethernet interfaces only.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Valid options are:
		        copper
		        fiber
		        sgmii (valid only for IxNetwork)
		x   -master_slave_mode
		x       Valid only for IxNetwork for interfaces that support media-independent master/slave negotiation.
		x       Valid options are:
		x       auto
		x       master
		x       slave
		x   -port_rx_mode
		x       Configure the Receive Engine of the Ixia port.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -ppp_ipv4_address
		x       IPv4 address for which to enable or disable PPP IPv4 negotiation.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -ppp_ipv4_negotiation
		x       Whether to enable PPP IPv4 negotiation on this port.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       Valid options are:
		x       0 - Disable
		x       1 - (default) Enable
		x   -ppp_ipv6_negotiation
		x       Whether to enable PPP IPv6 negotiation on this port.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       Valid options are:
		x       0 - Disable
		x       1 - (default) Enable
		x   -ppp_mpls_negotiation
		x       Whether to enable PPP MPLS negotiation on this port.
		x       Valid options
		x       are:
		x       0 - Disable
		x       1 - (default) Enable
		x   -ppp_osi_negotiation
		x       Whether to enable OSI Network Control protocol on the Ixia PoS port.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       Valid options are:
		x       0 - Disable
		x       1 - (default) Enable
		n   -pvc_incr_mode
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -qinq_incr_mode
		x       The Method used to increment VLAN IDs. This parameter is valid only
		x       when l23_config_type is static_endpoint (new API).
		x   -qos_byte_offset
		x       The byte offset from the beginning of the packet for the byte which
		x       contains the QoS level for the packet.
		x   -qos_packet_type
		x       The type of packet that the QoS counters are looking for priority
		x       bits within. Choices are: ethernet, ip_snap, vlan, custom, ip_ppp,
		x       ip_cisco_hdlc, ip_atm.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -qos_pattern_mask
		x       The mask to be applied to the pattern match. Value of 1 indicate that
		x       the corresponding bit is not to be matched.
		x   -qos_pattern_match
		x       The value to be matched for at the Pattern Match Offset, subject to
		x       the Pattern Match Mask. The value is in hex.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -qos_pattern_offset
		x       The byte offset from the beginning of the packet for the byte(s) that
		x       contains a value to be matched. If the pattern is matched, then the
		x       packet is deemed to contain a QoS level.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -qos_stats
		x       Whether to have access to the QOS (IP TOS PRECEDENCE) statistics on
		x       this port.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles. Valid options are:
		x       0 - Disable
		x       1 - (default) Enable
		x   -router_solicitation_retries
		x       The number of times the router solicitation request will be attempted.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -rpr_hec_seed
		x       The initial setting of the CRC for the 16 byte header. This option is
		x       used only when intf_mode is set to rpr.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       Valid options are:
		x       0 - (default) 0x0000
		x       1 - 0xFFFF
		    -rx_c2
		        Receive Path Signal Label for the Ixia interface.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		    -rx_fcs
		        FCS value (16 or 32) for the receiving side of each interfaces.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Valid options are:
		        16
		        32
		    -rx_scrambling
		        Whether to enable data scrambling in the SONET framer of the Ixia
		        interface. (SPE Scrambling = X^43+1).
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Valid options are:
		        0 - Disable
		        1 - Enable (DEFAULT)
		x   -send_router_solicitation
		x       If is option is present and has value 1 then interfaces on specified
		x       port will sent IPv6 router solicitation ICMP message to the DUT.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -sequence_checking
		x       Whether to enable the frame sequence capability on this port.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       Valid options are:
		x       0 - (default) Disable
		x       1 - Enable
		x   -sequence_num_offset
		x       The offset of the sequence number in the packet.
		x       If -port_rx_mode is set to auto_detect_instrumentation then this
		x       offset will be ignored.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -signature
		x       Signature used in the packet for Packet Group Statistics when packet
		x       groups or wide packet groups are enable.
		x       This signature will be searched into the received packets at offset
		x       represented by -signature_offset.
		x       If -port_rx_mode is set to auto_detect_instrumentation then this
		x       option will represent the a signature value of 12 hex bytes.
		x       This signature will be searched into the received packets starting
		x       with offset -signature_start_offset.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -signature_mask
		x       Sets the signature mask when -port_rx_mode is set to
		x       auto_detect_instrumentation.
		x       Value 1 means don't care and value 0 means that that bit should
		x       correspond to the signature.
		x       If -signature is "00 00 00 00 00 00 00 00 23 45 67 89" and
		x       the -signature_mask is "FF FF FF FF FF FF FF FF 00 00 00 00",
		x       then only last 4 bytes will be searched in the packet.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -signature_offset
		x       The offset of the signature in the packet. You can configure a fully
		x       customized signature in the packet for advanced testing. The
		x       signature of the packet is a 4-byte value, "DE AD BE EF". This
		x       signature is used for ease of readability when capturing packets.
		x       If -port_rx_mode is set to auto_detect_instrumentation then this
		x       offset will be ignored.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -signature_start_offset
		x       If -port_rx_mode is set to auto_detect_instrumentation then this will
		x       be the offset start to search into the received packets for -signature
		x       <signature> option.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -single_arp_per_gateway
		x       Send single ARP per gateway for the IPv4 interfaces when the port link becomes up.
		x       The option is global, for all ports and interfaces.
		x       This is valid only for the new API.
		x   -single_ns_per_gateway
		x       Send single Neighbor Solicitation per gateway for the IPv6 interfaces when the port link becomes up.
		x       The option is global, for all ports and interfaces.
		x       This is valid only for the new API.
		    -speed
		        Speed at which each interface is configured. This option takes a list of values when -port_handle is a list of port handles.
		    -src_mac_addr
		        MAC address of the port.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Valid formats are:
		        {00 00 00 00 00 00}, 00:00:00:00:00:00, 0000.0000.0000,
		        00.00.00.00.00.00, {0000 0000 0000}
		x   -src_mac_addr_step
		x       The incrementing step for the MAC address of the connected interface,
		x       when connected_count is greater than 1.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This is valid for the new API.
		n   -target_link_layer_address
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -transmit_clock_source
		        Specifies the clock source for synchronous transmissions. You can set the
		        transmit clock source for Ethernet 10/100/1000/100Gig interfaces.
		        Options internal, bits, loop, external are not supported.
		x   -transmit_mode
		x       Type of stream for this port. This option takes a list of values when -port_handle is a list of port handles.
		    -tx_c2
		        Transmit Path Signal Label for the Ixia interface.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		    -tx_fcs
		        FCS value (16 or 32) for the transmitting side of each interfaces.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Valid options are:
		        16
		        32
		    -tx_rx_sync_stats_enable
		        This option starts / stops collecting Tx/Rx Sync stats.
		        Valid options are:
		        0 - stop collecting Sync stats (DEFAULT)
		        1 - start collecting Sync stats
		    -tx_rx_sync_stats_interval
		        This option represents the interval (ms) at which to synchronously
		        freeze TX and RX PGID stats.
		    -tx_scrambling
		        Whether to enable data scrambling in the SONET framer of the Ixia
		        interface. (SPE Scrambling = X^43+1).
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Valid options are:
		        0 - Disable
		        1 - Enable (DEFAULT)
		n   -vci
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vci_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vci_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -vlan
		        Whether to enable VLAN on the traffic generation tool interfaces.
		        This option takes a list of values when -port_handle is a list of
		        port handles.
		        Valid options are:
		        1 - Enable
		        0 - Disable (DEFAULT)
		x   -vlan_id
		x       VLAN ID of each interface where VLAN is enabled. This parameter
		x       accepts a list of numbers separated by ',' - the vlan id for each
		x       encapsulation 802.1q. This is how stacked vlan is configured.
		x       Each value should be between 0 and 4095, inclusive, for l23_config_type protocol_interfaces.
		x       Each value should be between 0 and 4094, inclusive, for l23_config_type static_endpoint.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -vlan_id_step
		x       The incrementing step for the VLAN ID of the interface, when
		x       connected_count is greater than 1.
		x       The vlan_id will be incremented modulo 4096, when the maximum value
		x       is reached, the counting starts again from 0.
		x       The vlan_id will be incremented modulo 4094 (by default), when the maximum value
		x       is reached, the counting starts again from 0, for l23_config_type static_endpoint,
		x       but the number of unique values can be modified by using vlan_id_count.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -vlan_id_count
		x       The number of unique outer VLAN IDs that will be created. This parameter
		x       accepts a list of numbers separated by ',' - the vlan id count for each
		x       encapsulation 802.1q. This is how stacked vlan is configured.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is static_endpoint (new API).
		x   -vlan_tpid
		x       Tag Protocol Identifier / TPID (hex). The EtherType that identifies
		x       the protocol header that follows the VLAN header (tag).
		x       Available TPIDs: 0x8100 (the default), 0x88a8, 0x9100, 0x9200.
		x       If the VLAN Count is greater than 1 (for stacked VLANs),
		x       this field also accepts comma-separated values so that different TPID
		x       values can be assigned to different VLANs. For example, to assign TPID
		x       0x8100, 0x9100, 0x9200, and 0x9200 to the first four created VLANs,
		x       enter: 0x8100,0x9100,0x9200,0x9200.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x       This option is valid only when l23_config_type is protocol_interface.
		x   -vlan_user_priority
		x       If VLAN is enabled on the interface, the priority of the VLAN. For each interface,
		x       the user priority list should be given as a list of integers separated by commas.
		x       This parameter accepts a list of user priority for each 802.1 encapsulation used.
		x       Valid choices for each element in the list are between 0 and 7, inclusive.
		x       This option takes a list of values when -port_handle is a list of port handles.
		x       For example, if we have 2 interfaces with 3 vlans each, the user priority could be: [list 1,2,7 1,3,4]
		x   -vlan_user_priority_step
		x       The incrementing step for the VLAN user priority of the interface, when
		x       connected_count is greater than 1. The vlan_user_priority will be
		x       incremented modulo 8, when the maximum value is reached, the counting
		x       starts again from 0.
		x       This option is valid only when l23_config_type is static_endpoint.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles.
		x   -vlan_id_list
		x       See description for -vlan_id parameter. If both vlan_id and vlan_id_list are present, vlan_id_List
		x       takes precedence. If vlan_id_list is present vlan_id_inner will be ignored.
		x   -vlan_id_mode
		x       Used to specify whether VLAN ID is the same, or incremented, for multiple addresses.
		x   -vlan_protocol_id
		x       See -vlan_tpid parameter
		x   -vlan_id_inner
		x       Set the VLAN ID 2 associated with the address pool.
		x       Only works if VLAN is enabled and vlan_id provided.
		x       Each value should be between 0 and 4095, inclusive.
		x   -vlan_id_inner_mode
		x       Used to specify whether VLAN ID is the same, or incremented, for multiple addresses.
		x       This parameter is ignored if -vlan_id_inner is not specified in the same command.
		x       This option is valid only when l23_config_type is static_endpoint (new API).
		x   -vlan_id_inner_count
		x       Count value of inner VLAN ID per outer VLAN. Depending on this value outer and inner VLANs
		x       are incremented in QinQ. If not specified outer and inner VLANs are incremented independently.
		x       This parameter is ignored if -vlan_id_inner is not specified in the same command.
		x       This option is valid only when l23_config_type is static_endpoint (new API).
		x   -vlan_id_inner_step
		x       Used to specify how much the VLAN ID 2 is incremented when vlan_id_inner_mode is increment.
		x       This parameter is ignored if -vlan_id_inner is not specified in the same command.
		x       This option is valid only when l23_config_type is static_endpoint (new API).
		x   -use_vpn_parameters
		x       Flag to determine whether optional VPN parameters are provided.
		x   -site_id
		x       VPN Site Identifier
		n   -vpi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vpi_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vpi_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -enable_flow_control
		x       If 1, enables the port's MAC flow control and mechanisms to listen for a directed address pause message. Valid only with ixnetwork api.
		x   -enable_ndp
		x       Enables or disables the -send_router_solicitation and -ndp_send_req parameters.
		x       If this is 0 both -send_router_solicitation and -ndp_send_req will be ignored.
		x   -flow_control_directed_addr
		x       The 48-bit MAC address that the port listens on for a directed pause.
		x       Valid only with ixnetwork api.
		x   -fcoe_priority_groups
		x       Valid only with ixnetwork api and when intf_mode is ethernet_fcoe and speed is
		x       ether10000wan or ether10000lan. If 802.3Qbb is selected as the fcoe_flow_control_type,
		x       the PFC/Priority settings is used to map each of the eight PFC priorities to one
		x       of the four Priority Groups (or to none). The Priority Groups are numbered 0 through 3.
		x       This parameter takes a list of values, with a length of maximum 8 elements 0,1,2,3 or none.
		x       Example: {0 3 1 2 none 3} will configure:
		x       PFC 0 - Priority Group 0
		x       PFC 1 - Priority Group 3
		x       PFC 2 - Priority Group 1
		x       PFC 3 - Priority Group 2
		x       PFC 4 - Priority Group None
		x       PFC 5 - Priority Group 3
		x       PFC 6 - Priority Group None
		x       PFC 7 - Priority Group None
		    -fcoe_support_data_center_mode
		x   -fcoe_priority_group_size
		x       Valid only with ixnetwork api and when intf_mode is ethernet_fcoe and speed is
		x       ether10000wan or ether10000lan. Configure the size of a priority group. Valid choices are:
		x       4 - 4
		x       8 (default) - 8
		x   -fcoe_flow_control_type
		x       Valid only with ixnetwork api. Selects and configures a flow control protocol for the FCoE Client port.
		x       Valid only when intf_mode is ethernet_fcoe and speed is ether10000wan or ether10000lan.
		x       Valid choices are:
		x       ieee802.3x - ieee802.3x
		x       ieee802.1Qbb (default) - ieee802.1Qbb
		x   -fc_credit_starvation_value
		x       Valid only with ixnetwork api. If selected, the programs encounter a delay value
		x       specified in the Hold R_RDY field. The counter starts counting down after it
		x       receives the first frame. The port holds R_RDY for all frames received until counter
		x       reaches to 0.
		x       Valid only when intf_mode is fc.
		x   -fc_no_rrdy_after
		x       Valid only with ixnetwork api. Send R_RDY signals without any delay.
		x       Valid only when intf_mode is fc.
		n   -fc_tx_ignore_rx_link_faults
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -tx_ignore_rx_link_faults
		x       Enable to send trafic even if the receive link is down.
		x   -laser_on
		x       Enable "laser on" option for Multis cards.
		x   -fc_max_delay_for_random_value
		x       Valid only with ixnetwork api. The maximum random delay value for the R_RDY primitives.
		x       Valid only when intf_mode is fc.
		x   -fc_tx_ignore_available_credits
		x       Valid only with ixnetwork api.
		x       Valid only when intf_mode is fc. Valid choices are:
		x       0 (default) - disable
		x       1 - enable
		x   -fc_min_delay_for_random_value
		x       Valid only with ixnetwork api. The minimum random delay value for the R_RDY primitives.
		x       Valid only when intf_mode is fc.
		x   -fc_rrdy_response_delays
		x       Valid only with ixnetwork api. The internal delays for the transmission of R_RDY Primitive Signal
		x       Valid only when intf_mode is fc. Valid choices are:
		x       credit_starvation
		x       fixed_delay
		x       no_delay (default)
		x       random_delay
		x   -fc_fixed_delay_value
		x       Valid only with ixnetwork api. Internal delays the R_RDY primitive signals.
		x       Valid only when intf_mode is fc.
		x   -fc_force_errors
		x       Valid only with ixnetwork api. Configure the port to introduce errors in the transmission of R_RDYPrimitives Signals.
		x       Valid only when intf_mode is fc. Valid choices are:
		x       no_errors (default)
		x       no_rrdy
		x       no_rrdy_every
		x   -enable_data_center_shared_stats
		x       Valid only with ixnetwork api. Globally enable Data Center Shared Statistics.
		x       Valid choices are:
		x       0 (default) - disabled
		x       1 - enabled
		x   -additional_fcoe_stat_1
		x       Valid only with ixnetwork api and when enable_data_center_shared_stats is 1.
		x   -additional_fcoe_stat_2
		x       Valid only with ixnetwork api and when enable_data_center_shared_stats is 1.
		x   -tx_gap_control_mode
		x       Valid only for new API when speed is ether10000wan or ether10000lan
		x       and intf_mode is ethernet | ethernet_fcoe.
		x   -tx_lanes
		x       This option takes a list of txLanes. This parameter is valid only with IxTclHal api.
		x       <phy_lane>:<pcs_lane>,<skew>|<phy_lane>:<pcs_lane>,<skew>|....
		    -static_enable
		        Enables creation of IxNetwork static endpoints. If this parameter is 1,
		        only IxNetwork static endpoints will be created. All other parameters
		        that configure protocol interfaces (-l23_config_type protocol_interface)
		        and SM static endpoints (-l23_config_type static_endpoint) will be ignored.
		        Valid choices are:
		        0 - disable (DEFAULT)
		        1 - enable
		n   -static_atm_header_encapsulation
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_atm_range_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_vci
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_vci_increment
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_vci_increment_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_vci_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_pvc_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_pvc_count_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_vpi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_vpi_increment
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_vpi_increment_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_vpi_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_dlci_count_mode
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_dlci_repeat_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_dlci_repeat_count_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_dlci_value
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_dlci_value_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_fr_range_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -static_intf_handle
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. Interface handles to be used by IP type.
		        These handles are returned by interface_config when - l23_config_type is
		        protocol_interface and -static_enable is 0. In order for an interface to be
		        a valid handle it must have the same encapsulations as the static endpoint ip
		        range (same IP type, number of vlans if any).
		    -static_ip_dst_count
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. Number of IPs to be generated on an IP range.
		    -static_ip_dst_count_step
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. Step to increment - static_ip_dst_count between ranges.
		    -static_ip_dst_addr
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. The first IP address in the range.
		    -static_ip_dst_increment
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. IP step used between IP on same IP range.
		    -static_ip_dst_increment_step
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. Step to increment -static_ip_dst_increment between ranges.
		    -static_ip_dst_range_step
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. IP step between IP ranges.
		    -static_ip_dst_prefix_len
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. The numbers of bits in the network mask
		        to be used with the IP address.
		    -static_ip_dst_prefix_len_step
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. Step to increment the number of bits in
		        the network masks to be used with the IP address between ranges.
		    -static_ip_range_count
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. Number of IP static endpoint ranges to be created.
		    -static_l3_protocol
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_ip_range_count > 0. The IP version number. Valid choices are:
		        ipv4 (DEFAULT)
		        ipv6
		n   -static_indirect
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_range_per_spoke
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_lan_intermediate_objref
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -static_lan_range_count
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1.
		        Number of LAN static endpoint ranges to be created.
		        If any of the following parameters -static_mac_dst, -static_mac_dst_count, -static_mac_dst_mode, -static_site_id, -static_site_id_enable, -static_vlan_enable, -static_vlan_id or -static_vlan_id_mode is present the default value is set to 1.
		    -static_mac_dst
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0. MAC address used in LAN ranges.
		    -static_mac_dst_count
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0. Number of MAC addresses to be generated by an LAN range.
		    -static_mac_dst_count_step
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0. The step to increment static_mac_dst_count between ranges.
		    -static_mac_dst_mode
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0. Valid choices are:
		        increment (DEFAULT)
		        fixed
		        For  increment  MAC address from LAN range will be incremented.
		    -static_mac_dst_step
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0. MAC step between LAN ranges.
		    -static_site_id
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0 and -static_site_id_enable 0 and -static_lan_mac_range_mode normal.
		        The Site ID is implemented for static (and dynamic) routes, including the Static Lan
		        end point. Users can configure traffic streams by grouping routes
		        belonging to the same Site ID.
		    -static_site_id_enable
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0 and -static_lan_mac_range_mode normal.
		        Enable site id value for LAN range(s). Valid choices are:
		        0 (DEFAULT)
		        1
		    -static_site_id_step
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0 and -static_site_id_enable 0 and -static_lan_mac_range_mode normal.
		        Step of site_id between LAN ranges.
		    -static_vlan_enable
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0. Enable VLAN for LAN ranges. Valid choices are:
		        1 - enable
		        0 - disable (DEFAULT)
		    -static_vlan_id
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0. Configure first VLAN ID.
		        If stacked vlans need to be created, a list of values separated by the colon(:) character
		        must be provided to this parameter.
		    -static_vlan_id_mode
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0 and -static_vlan_enable 1 and -static_lan_mac_range_mode normal.
		        Select increment or fixed mode for vlan_id value.
		    -static_vlan_id_step
		        Parameter valid only for IxNetwork static endpoints when -static_enable 1
		        and -static_lan_range_count > 0 and -static_vlan_enable 1. Step of start
		        VLAN ID between LAN ranges.
		        If stacked vlans need to be created then this parameter must be a list of values separated through
		        the colon(:) character. Each vlan ID will be incremented with coresponding values in this parameter.
		        Example:
		        If static_vlan_id is 1:2:3, static_lan_range_count is 4 and static_vlan_id_step is 2:4:6, four LAN ranges
		        will be created with the following VLAN IDs: "1,2,3", "3,6,9", "5,10,15", "7,14,21".
		x   -static_lan_count_per_vc
		x       Parameter valid only for IxNetwork static endpoints when -static_enable 1
		x       and -static_lan_range_count > 0 and -static_lan_mac_range_mode bundled.
		x       The total count per VC in this bundled mode.
		x   -static_lan_incr_per_vc_vlan_mode
		x       Parameter valid only for IxNetwork static endpoints when -static_enable 1
		x       and -static_lan_range_count > 0 and -static_lan_mac_range_mode bundled.
		x       Enable the use of multiple VLANs, which are incremented for each additional
		x       VLAN per VC. Valid choices are:
		x       fixed (DEFAULT)
		x       increment
		x       inner
		x       outer
		x   -static_lan_mac_range_mode
		x       Parameter valid only for IxNetwork static endpoints when -static_enable 1
		x       and -static_lan_range_count > 0. Configure available MAC Range Mode. Valid choices are:
		x       normal -
		x       bundled -
		x   -static_lan_number_of_vcs
		x       Parameter valid only for IxNetwork static endpoints when -static_enable 1
		x       and -static_lan_range_count > 0 and -static_lan_mac_range_mode bundled.
		x       The total number of VCs.
		x   -static_lan_skip_vlan_id_zero
		x       Parameter valid only for IxNetwork static endpoints when -static_enable 1
		x       and -static_lan_range_count > 0. Enable skip vlan id 0.
		x   -static_lan_tpid
		x       Parameter valid only for IxNetwork static endpoints when -static_enable 1
		x       and -static_lan_range_count > 0 and -static_vlan_enable 1. Tag Protocol Identifier / TPID (hex). The
		x       EtherType that identifies the protocol header that follows the VLAN header (tag).
		x       If stacked vlans need to be created, a list of values separated by the colon(:) character
		x       must be provided to this parameter.
		x       Valid choices are:
		x       0x8100 (DEFAULT)
		x       0x88a8
		x       0x9100
		x       0x9200
		x   -static_lan_vlan_priority
		x       Parameter valid only for IxNetwork static endpoints when -static_enable 1
		x       and -static_lan_range_count > 0 and -static_vlan_enable 1.
		x       The user priority of the VLAN tag: a value from 0 through 7. The use and interpretation
		x       of this field is defined in ISO/IEC 15802-3.
		x       If stacked vlans need to be created, a list of values separated by the colon(:) character
		x       must be provided to this parameter.
		x   -static_lan_vlan_stack_count
		x       Parameter valid only for IxNetwork static endpoints when -static_enable 1
		x       and -static_lan_range_count > 0 and -static_vlan_enable 1.
		x       The number of VLANs configured for stacked VLANs/QinQ.
		n   -static_ig_atm_encap
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_ig_vlan_enable
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_ig_ip_type
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_ig_interface_enable_list
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_ig_interface_handle_list
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -static_ig_range_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -pgid_split1_width
		x       The width, in bytes/bits, of the split PGID for IxOs/IxNetwork.
		x       This option has any meaning only if the -pgid_mode option is set to split.
		x       This option takes a list of values when -port_handle is a list of
		x       port handles. For IxOS the range accepted is 0-4 bytes.
		x       When IxNetwork TclAPI is used the range accepted is0-12 bits.
		n   -aps
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -aps_arch
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -aps_channel
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -aps_request_1_1
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -aps_request_1_n
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -aps_switch_mode
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -auto_line_rdi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -auto_line_rei
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -auto_path_rdi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -auto_path_rei
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -crlf_path_trace
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -control_plane_mtu
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -dst_mac_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -ignore_pause_frames
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -interpacket_gap
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -long_lof_wait
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -output_enable
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -pause_length
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -rx_enhanced_prdi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -rx_equalization
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -rx_hec
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -section_unequip
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -signal_fail_ber
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -ss_bits_pointer_interp
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -tx_enhanced_prdi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -tx_k2
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -tx_preemphasis_main_tap
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -tx_preemphasis_post_tap
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -tx_s1
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -ethernet_attempt_enabled
		x   -ethernet_attempt_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       bring up sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ethernet_attempt_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ethernet_attempt_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the ethernet protocols configured in the ixncfg
		x       and can be configured just when handle is /globals meaning that the user wants
		x       to configure only global protocol settings.
		x   -ethernet_diconnect_enabled
		x   -ethernet_disconnect_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       disconnect sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ethernet_disconnect_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ethernet_disconnect_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the ethernet protocols configured in the ixncfg
		x       and can be configured just when handle is /globals meaning that the user wants
		x       to configure only global protocol settings.
		x   -ipv4_send_arp_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       send ARP requests on sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ipv4_send_arp_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ipv4_send_arp_max_outstanding
		x       The maximum number of triggered instances of an action that is still awaiting a response or completion
		x   -ipv4_send_arp_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the IPv4 protocols configured in the ixncfg
		x       and can be configured just when handle is /globals meaning that the user wants
		x       to configure only global protocol settings.
		x   -ipv4_attempt_enabled
		x   -ipv4_attempt_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       bring up sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ipv4_attempt_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ipv4_attempt_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the IPv4 protocols configured in the ixncfg
		x       and can be configured just when handle is /globals meaning that the user wants
		x       to configure only global protocol settings.
		x   -ipv4_diconnect_enabled
		x   -ipv4_disconnect_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       disconnect sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ipv4_disconnect_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ipv4_disconnect_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the IPv4 protocols configured in the ixncfg
		x       and can be configured just when handle is /globals meaning that the user wants
		x       to configure only global protocol settings.
		x   -ipv6_send_ns_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       send NS requests on sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ipv6_send_ns_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ipv6_send_ns_max_outstanding
		x       The maximum number of triggered instances of an action that is still awaiting a response or completion
		x   -ipv6_send_ns_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the IPv6 protocols configured in the ixncfg
		x       and can be configured just when handle is /globals meaning that the user wants
		x       to configure only global protocol settings.
		x   -ipv6_attempt_enabled
		x   -ipv6_attempt_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       bring up sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ipv6_attempt_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ipv6_attempt_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the IPv6 protocols configured in the ixncfg
		x       and can be configured just when handle is /globals meaning that the user wants
		x       to configure only global protocol settings.
		x   -ipv6_diconnect_enabled
		x   -ipv6_disconnect_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       disconnect sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ipv6_disconnect_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ipv6_disconnect_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the IPv6 protocols configured in the ixncfg
		x       and can be configured just when handle is /globals meaning that the user wants
		x       to configure only global protocol settings.
		x   -ipv6_autoconfiguration_send_ns_enabled
		x   -ipv6_autoconfiguration_send_ns_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       send NS requests on sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ipv6_autoconfiguration_send_ns_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ipv6_autoconfiguration_send_ns_max_outstanding
		x       The maximum number of triggered instances of an action that is still awaiting a response or completion
		x   -ipv6_autoconfiguration_send_ns_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the IPv6 Autoconfiguration protocols configured
		x       in the ixncfg and can be configured just when handle is /globals meaning that
		x       the user wants to configure only global protocol settings.
		x   -ipv6_autoconfiguration_send_rs_enabled
		x   -ipv6_autoconfiguration_send_rs_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       send RS requests on sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ipv6_autoconfiguration_send_rs_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ipv6_autoconfiguration_send_rs_max_outstanding
		x       The maximum number of triggered instances of an action that is still awaiting a response or completion
		x   -ipv6_autoconfiguration_send_rs_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the IPv6 Autoconfiguration protocols configured
		x       in the ixncfg and can be configured just when handle is /globals meaning that
		x       the user wants to configure only global protocol settings.
		x   -ipv6_autoconfiguration_attempt_enabled
		x   -ipv6_autoconfiguration_attempt_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       bring up sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ipv6_autoconfiguration_attempt_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ipv6_autoconfiguration_attempt_max_outstanding
		x       The maximum number of triggered instances of an action that is still awaiting a response or completion
		x   -ipv6_autoconfiguration_attempt_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the IPv6 Autoconfiguration protocols configured
		x       in the ixncfg and can be configured just when handle is /globals meaning that
		x       the user wants to configure only global protocol settings.
		x   -ipv6_autoconfiguration_disconnect_enabled
		x   -ipv6_autoconfiguration_disconnect_rate
		x       Specifies the rate in attempts/second at which attempts are made to
		x       disconnect sessions.
		x       When using IxNetwork this parameter can take values from the 1-1000 range.
		x   -ipv6_autoconfiguration_disconnect_interval
		x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
		x   -ipv6_autoconfiguration_disconnect_max_outstanding
		x       The maximum number of triggered instances of an action that is still awaiting a response or completion
		x   -ipv6_autoconfiguration_disconnect_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This setting is global for all the IPv6 Autoconfiguration protocols configured
		x       in the ixncfg and can be configured just when handle is /globals meaning that
		x       the user wants to configure only global protocol settings.
		x   -notify_mac_move
		x       Flag to determine if MAC move notifications should be sent
		x   -ipv4_re_send_arp_on_link_up
		x       Resends ARP after link up.
		x   -ipv6_re_send_ns_on_link_up
		x       Resends neighbor solicitation after link up.
		
		 Return Values:
		    A list containing the ethernet protocol stack handles that were added by the command (if any).
		x   key:ethernet_handle                               value:A list containing the ethernet protocol stack handles that were added by the command (if any).
		    A list containing the ipv4 protocol stack handles that were added by the command (if any).
		x   key:ipv4_handle                                   value:A list containing the ipv4 protocol stack handles that were added by the command (if any).
		    A list containing the ipv6 protocol stack handles that were added by the command (if any).
		x   key:ipv6_handle                                   value:A list containing the ipv6 protocol stack handles that were added by the command (if any).
		    A list containing the ipv6autoconfiguration protocol stack handles that were added by the command (if any).
		x   key:ipv6autoconfiguration_handle                  value:A list containing the ipv6autoconfiguration protocol stack handles that were added by the command (if any).
		    A list containing the ipv6 loopback protocol stack handles that were added by the command (if any).
		x   key:ipv6_loopback_handle                          value:A list containing the ipv6 loopback protocol stack handles that were added by the command (if any).
		    A list containing the ipv4 loopback protocol stack handles that were added by the command (if any).
		x   key:ipv4_loopback_handle                          value:A list containing the ipv4 loopback protocol stack handles that were added by the command (if any).
		    A list containing the greoipv4 protocol stack handles that were added by the command (if any).
		x   key:greoipv4_handle                               value:A list containing the greoipv4 protocol stack handles that were added by the command (if any).
		    A list containing the greoipv6 protocol stack handles that were added by the command (if any).
		x   key:greoipv6_handle                               value:A list containing the greoipv6 protocol stack handles that were added by the command (if any).
		    $::SUCCESS | $::FAILURE
		    key:status                                        value:$::SUCCESS | $::FAILURE
		    On status of failure, gives detailed information.
		    key:log                                           value:On status of failure, gives detailed information.
		    A handle that can be used in router configs to designate an existing protocol interface. All static endpoints created with -static_enable 1 are returned on this key Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:interface_handle                              value:A handle that can be used in router configs to designate an existing protocol interface. All static endpoints created with -static_enable 1 are returned on this key Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    handles to the unconnected interfaces created in this call Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:routed_interface_handle                       value:handles to the unconnected interfaces created in this call Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    handle to the gre interfaces created in this call Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:gre_interface_handle                          value:handle to the gre interfaces created in this call Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    ATM static endpoints configured when -static_enable 1
		    key:atm_endpoints                                 value:ATM static endpoints configured when -static_enable 1
		    FR static endpoints configured when -static_enable 1
		    key:fr_endpoints                                  value:FR static endpoints configured when -static_enable 1
		    IP static endpoints configured when -static_enable 1
		    key:ip_endpoints                                  value:IP static endpoints configured when -static_enable 1
		    LAN static endpoints configured when -static_enable 1
		    key:lan_endpoints                                 value:LAN static endpoints configured when -static_enable 1
		    Interface Group static endpoints configured when -static_enable 1
		    key:ig_endpoints                                  value:Interface Group static endpoints configured when -static_enable 1
		    0 if arp table empty or 1 when arp table not empty. Available when -arp_send_req is 1.
		    key:<port_handle>.arp_request_success             value:0 if arp table empty or 1 when arp table not empty. Available when -arp_send_req is 1.
		    0 if neighbor discover table empty or 1 when neighbor discover table not empty. Available when -arp_send_req is 1 or -send_router_solicitation is 1.
		    key:<port_handle>.router_solicitation_success     value:0 if neighbor discover table empty or 1 when neighbor discover table not empty. Available when -arp_send_req is 1 or -send_router_solicitation is 1.
		    list of interface handles that failed to resolve their gateways ip addresses. Available when arp_request_success is 0.
		    key:<port_handle>.arp_ipv4_interfaces_failed      value:list of interface handles that failed to resolve their gateways ip addresses. Available when arp_request_success is 0.
		    list of interface handles that didn't get any response to the router solicitation. Available when arp_request_success is 0.
		    key:<port_handle>.arp_ipv6_interfaces_failed      value:list of interface handles that didn't get any response to the router solicitation. Available when arp_request_success is 0.
		    list of interface handles that failed to resolve their gateway. Available when arp_request_success is 0.
		    key:<protocol_handle>.arp_failed_item_handles     value:list of interface handles that failed to resolve their gateway. Available when arp_request_success is 0.
		    list of interface handles that are not started. Available when arp_request_success is 0 and at least one of the sessions on which arp was sent is not started.
		    key:<protocol_handle>.arp_interfaces_not_started  value:list of interface handles that are not started. Available when arp_request_success is 0 and at least one of the sessions on which arp was sent is not started.
		    0 if the ping request failed on any of the interfaces. Available only when -send_ping is 1 and -ping_dst is specified.
		    key:<port_handle>.ping_success                    value:0 if the ping request failed on any of the interfaces. Available only when -send_ping is 1 and -ping_dst is specified.
		    Detailed status of the ping request on the specified port. Available only when -send_ping is 1 and -ping_dst is specified.
		    key:<port_handle>.ping_details                    value:Detailed status of the ping request on the specified port. Available only when -send_ping is 1 and -ping_dst is specified.
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    Coded versus functional specification.
		    1) You can configure multiple interfaces on the same Ixia port.
		    2) If autonegotiation is explicitly set to 0, the valid speed/duplex
		    combinations are:
		    speed: ether10   duplex: half
		    speed: ether10   duplex: full
		    speed: ether100  duplex: half
		    speed: ether100  duplex: full
		    speed: ether1000 duplex: ignored, because it is always set to full
		    Any other combination will return an error.
		    If speed is set to ether10 or ether100 and the duplex parameter is missing the duplex will
		    be set to full.
		    3) Static endpoint parameters (active when -static_enable 1) that can have a separate value
		    for each static  endpoint range should be specified as comma separated lists. If a comma
		    separated parameter value accepts a list, the list will be separated by
		    semicolons (:). -static_vlan_id is such a parameter. When   static_lan_vlan_stack_count
		    is > 1, -static_vlan id will be a list separated with  : , each value corresponding to
		    a stack from the stacked vlans.
		    4) When -handle is provided with the /globals value the arguments that configure global protocol
		    setting accept both multivalue handles and simple values.
		    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
		    that configure global settings will only accept simple values. In this situation, these arguments will
		    configure only the settings of the parent device group or the ports associated with the parent topology.
		    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  interface_handle, routed_interface_handle, gre_interface_handle
		
		 See Also:
		
		'''
		hlpy_args = locals().copy()
		hlpy_args.update(kwargs)
		del hlpy_args['self']
		del hlpy_args['kwargs']

		not_implemented_params = ['port_handle', 'atm_enable_coset', 'atm_enable_pattern_matching', 'arp_refresh_interval', 'atm_filler_cell', 'atm_interface_type', 'atm_packet_decode_mode', 'atm_reassembly_timeout', 'autonegotiation', 'auto_detect_instrumentation_type', 'bert_configuration', 'bert_error_insertion', 'clocksource', 'data_integrity', 'duplex', 'framing', 'ignore_link', 'integrity_signature', 'integrity_signature_offset', 'internal_ppm_adjust', 'intf_mode', 'intrinsic_latency_adjustment', 'ns_on_linkup', 'op_mode', 'pcs_period', 'pcs_count', 'pcs_repeat', 'pcs_period_type', 'pcs_lane', 'pcs_enabled_continuous', 'pcs_sync_bits', 'pcs_marker_fields', 'pgid_128k_bin_enable', 'pgid_mask', 'pgid_offset', 'pgid_mode', 'pgid_encap', 'pgid_split1_mask', 'pgid_split1_offset', 'pgid_split1_offset_from', 'pgid_split2_mask', 'pgid_split2_offset', 'pgid_split2_offset_from', 'pgid_split2_width', 'pgid_split3_mask', 'pgid_split3_offset', 'pgid_split3_offset_from', 'pgid_split3_width', 'phy_mode', 'master_slave_mode', 'port_rx_mode', 'ppp_ipv4_address', 'ppp_ipv4_negotiation', 'ppp_ipv6_negotiation', 'ppp_mpls_negotiation', 'ppp_osi_negotiation', 'qos_byte_offset', 'qos_packet_type', 'qos_pattern_mask', 'qos_pattern_match', 'qos_pattern_offset', 'qos_stats', 'rpr_hec_seed', 'rx_c2', 'rx_fcs', 'rx_scrambling', 'sequence_checking', 'sequence_num_offset', 'signature', 'signature_mask', 'signature_offset', 'signature_start_offset', 'speed', 'transmit_clock_source', 'transmit_mode', 'tx_c2', 'tx_fcs', 'tx_rx_sync_stats_enable', 'tx_rx_sync_stats_interval', 'tx_scrambling', 'enable_flow_control', 'flow_control_directed_addr', 'fcoe_priority_groups', 'fcoe_support_data_center_mode', 'fcoe_priority_group_size', 'fcoe_flow_control_type', 'fc_credit_starvation_value', 'fc_no_rrdy_after', 'fc_tx_ignore_rx_link_faults', 'tx_ignore_rx_link_faults', 'laser_on', 'fc_max_delay_for_random_value', 'fc_tx_ignore_available_credits', 'fc_min_delay_for_random_value', 'fc_rrdy_response_delays', 'fc_fixed_delay_value', 'fc_force_errors', 'enable_data_center_shared_stats', 'additional_fcoe_stat_1', 'additional_fcoe_stat_2', 'tx_gap_control_mode', 'tx_lanes', 'pgid_split1_width']
		mandatory_params = ['port_handle']
		file_params = []

		try:
			return self.__execute_command(
				'interface_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
