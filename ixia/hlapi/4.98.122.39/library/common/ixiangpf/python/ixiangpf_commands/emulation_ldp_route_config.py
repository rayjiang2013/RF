# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_ldp_route_config(self, mode, handle, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_ldp_route_config
		
		 Description:
		    This procedure creates/modifies/deletes LSP (FEC) pools or FEC ranges on simulated LDP router Interface.
		
		 Synopsis:
		    emulation_ldp_route_config
		        -mode                                CHOICES create modify delete
		        -handle                              ANY
		x       [-return_detailed_handles            CHOICES 0 1
		x                                            DEFAULT 0]
		        [-egress_label_mode                  CHOICES nextlabel fixed imnull exnull
		                                             DEFAULT nextlabel]
		        [-fec_ip_prefix_start                IPV4
		                                             DEFAULT 0.0.0.0]
		x       [-fec_ip_prefix_step                 IPV4
		x                                            DEFAULT 0.0.0.1]
		x       [-fec_ip_prefix_length               RANGE 1-32
		x                                            DEFAULT 24]
		n       [-fec_host_addr                      ANY]
		n       [-fec_host_prefix_length             ANY]
		        [-fec_type                           CHOICES ipv4_prefix
		                                             CHOICES host_addr
		                                             CHOICES vc
		                                             CHOICES network_topology
		                                             DEFAULT ipv4_prefix]
		x       [-network_topology_type              CHOICES grid
		x                                            CHOICES mesh
		x                                            CHOICES custom
		x                                            CHOICES ring
		x                                            CHOICES hub-and-spoke
		x                                            CHOICES tree
		x                                            CHOICES ipv4-prefix
		x                                            CHOICES fat-tree
		x                                            CHOICES linear]
		x       [-fec_vc_atm_enable                  CHOICES 0 1
		x                                            DEFAULT 1]
		x       [-fec_vc_atm_max_cells               RANGE 1-65535
		x                                            DEFAULT 1]
		        [-fec_vc_cbit                        CHOICES 0 1
		                                             DEFAULT 1]
		n       [-fec_vc_ce_ip_addr                  ANY]
		n       [-fec_vc_ce_ip_addr_inner_step       ANY]
		n       [-fec_vc_ce_ip_addr_outer_step       ANY]
		x       [-fec_vc_cem_option                  RANGE 0-65535
		x                                            DEFAULT 0]
		x       [-fec_vc_cem_option_enable           CHOICES 0 1
		x                                            DEFAULT 0]
		x       [-fec_vc_cem_payload                 RANGE 48-1023
		x                                            DEFAULT 48]
		x       [-fec_vc_cem_payload_enable          CHOICES 0 1
		x                                            DEFAULT 1]
		x       [-fec_vc_count                       NUMERIC
		x                                            DEFAULT 1]
		x       [-fec_vc_fec_type                    CHOICES generalized_id_fec_vpls
		x                                            CHOICES pw_id_fec
		x                                            DEFAULT generalized_id_fec_vpls]
		        [-fec_vc_group_id                    NUMERIC]
		n       [-fec_vc_group_count                 ANY]
		        [-fec_vc_id_start                    RANGE 0-2147483647
		                                             DEFAULT 1]
		        [-fec_vc_id_step                     RANGE 0-2147483647
		                                             DEFAULT 1]
		n       [-fec_vc_id_count                    ANY]
		n       [-fec_vc_intf_mtu_enable             ANY]
		        [-fec_vc_intf_mtu                    RANGE 0-65535
		                                             REGEXP ^[0-9]+$
		                                             DEFAULT 0]
		        [-fec_vc_intf_desc                   ANY]
		x       [-fec_vc_intf_desc_enable            CHOICES 0 1]
		x       [-fec_vc_name                        ALPHA]
		x       [-fec_vc_active                      CHOICES 0 1]
		n       [-fec_vc_ip_range_addr_count         ANY]
		n       [-fec_vc_ip_range_addr_start         ANY]
		n       [-fec_vc_ip_range_addr_inner_step    ANY]
		n       [-fec_vc_ip_range_addr_outer_step    ANY]
		n       [-fec_vc_ip_range_enable             ANY]
		n       [-fec_vc_ip_range_prefix_len         ANY]
		n       [-fec_vc_label_mode                  ANY]
		x       [-fec_vc_label_value_start           RANGE 0-1046400
		x                                            DEFAULT 16]
		x       [-fec_vc_label_value_step            RANGE 0-1046400
		x                                            DEFAULT 0]
		x       [-fec_vc_mac_range_count             NUMERIC
		x                                            DEFAULT 1]
		x       [-fec_vc_mac_range_enable            CHOICES 0 1
		x                                            DEFAULT 0]
		x       [-fec_vc_mac_range_first_vlan_id     RANGE 0-4095
		x                                            DEFAULT 100]
		n       [-fec_vc_mac_range_repeat_mac        ANY]
		n       [-fec_vc_mac_range_same_vlan         ANY]
		x       [-fec_vc_mac_range_start             MAC
		x                                            DEFAULT 0000.0000.0000]
		n       [-fec_vc_mac_range_vlan_enable       ANY]
		x       [-fec_vc_peer_address                IP
		x                                            DEFAULT 0.0.0.0]
		        [-fec_vc_type                        CHOICES atm_aal5_vcc
		                                             CHOICES atm_cell
		                                             CHOICES atm_vcc_1_1
		                                             CHOICES atm_vcc_n_1
		                                             CHOICES atm_vpc_1_1
		                                             CHOICES atm_vpc_n_1
		                                             CHOICES cem
		                                             CHOICES eth
		                                             CHOICES eth_vlan
		                                             CHOICES eth_vpls
		                                             CHOICES fr_dlci
		                                             CHOICES hdlc
		                                             CHOICES ppp
		                                             CHOICES satop_e1
		                                             CHOICES satop_e3
		                                             CHOICES satop_t1
		                                             CHOICES satop_t3
		                                             CHOICES cesopsn_basic
		                                             CHOICES cesopsn_cas
		                                             CHOICES fr_dlci_rfc4619
		                                             DEFAULT eth_vlan]
		n       [-hop_count_tlv_enable               ANY]
		n       [-hop_count_value                    ANY]
		n       [-label_msg_type                     ANY]
		x       [-label_value_start                  RANGE 0-1048575
		x                                            DEFAULT 16]
		x       [-label_value_start_step             RANGE 0-1048575
		x                                            DEFAULT 1]
		        [-lsp_handle                         ANY]
		n       [-next_hop_peer_ip                   ANY]
		        [-num_lsps                           RANGE 1-34048
		                                             DEFAULT 1]
		n       [-num_routes                         ANY]
		x       [-packing_enable                     CHOICES 0 1
		x                                            DEFAULT 0]
		x       [-provisioning_model                 CHOICES bgp_auto_discovery
		x                                            CHOICES manual_configuration]
		n       [-stale_timer_enable                 ANY]
		n       [-stale_request_time                 ANY]
		n       [-no_write                           ANY]
		x       [-fec_vc_pw_status_enable            CHOICES 0 1]
		x       [-fec_vc_pw_status_code              CHOICES clear_fault_code
		x                                            CHOICES pw_not_forwarding_code
		x                                            CHOICES ac_rx_fault_code
		x                                            CHOICES ac_tx_fault_code
		x                                            CHOICES pw_rx_fault_code
		x                                            CHOICES pw_tx_fault_code]
		x       [-fec_vc_pw_status_send_notification CHOICES 0 1]
		x       [-fec_vc_down_start                  NUMERIC]
		x       [-fec_vc_down_interval               NUMERIC]
		x       [-fec_vc_up_interval                 NUMERIC]
		x       [-fec_vc_repeat_count                NUMERIC]
		x       [-fec_vc_type_vpls_id                CHOICES id_as_number id_ip_address]
		x       [-fec_vc_ip_address_vpls_id          ANY]
		x       [-fec_vc_as_number_vpls_id           ANY]
		x       [-fec_vc_assigned_number_vpls_id     ANY]
		x       [-fec_vc_source_aii_type             CHOICES as_ip number]
		x       [-fec_vc_source_aii_as_ip            IPV4]
		x       [-fec_vc_source_aii_as_number        ANY]
		x       [-fec_vc_target_aii_type             CHOICES as_ip number]
		x       [-fec_vc_target_aii_as_ip            IPV4]
		x       [-fec_vc_target_aii_as_number        NUMERIC]
		x       [-fec_vc_include_tdm_payload         ANY]
		x       [-fec_vc_tdm_data_size               NUMERIC]
		x       [-fec_vc_include_tdm_bitrate         ANY]
		x       [-fec_vc_tdm_bitrate                 ANY]
		x       [-fec_vc_include_rtp_header          ANY]
		x       [-fec_vc_include_tdm_option          ANY]
		x       [-fec_vc_timestamp_mode              CHOICES absolute differential]
		x       [-fec_vc_payload_type                ANY]
		x       [-fec_vc_frequency                   ANY]
		x       [-fec_vc_include_ssrc                ANY]
		x       [-fec_vc_ssrc                        ANY]
		x       [-fec_vc_cas                         CHOICES e1_trunk
		x                                            CHOICES t1_esf_trunk
		x                                            CHOICES t1_sf_trunk]
		x       [-fec_vc_sp                          CHOICES hexval1
		x                                            CHOICES hexval2
		x                                            CHOICES hexval3
		x                                            CHOICES hexval4]
		x       [-fec_vc_enable_cccv_negotiation     ANY]
		x       [-fec_vc_pw_ach_cc                   ANY]
		x       [-fec_vc_router_alert_cc             ANY]
		x       [-fec_vc_lsp_ping_cv                 ANY]
		x       [-fec_vc_bfd_udp_cv                  ANY]
		x       [-fec_vc_bfd_pw_cv                   ANY]
		x       [-fec_active                         CHOICES 0 1]
		x       [-fec_name                           ALPHA]
		x       [-topology_config_active             CHOICES 0 1]
		x       [-topology_router_active             CHOICES 0 1]
		x       [-topology_router_label_value        ANY]
		x       [-topology_router_id                 ANY]
		        [-grid_col                           RANGE 2-10000
		                                             DEFAULT 2]
		        [-grid_row                           RANGE 2-10000
		                                             DEFAULT 2]
		x       [-grid_include_emulated_device       CHOICES 0 1]
		x       [-grid_link_multiplier               NUMERIC]
		x       [-mesh_number_of_nodes               NUMERIC]
		x       [-mesh_include_emulated_device       CHOICES 0 1]
		x       [-mesh_link_multiplier               NUMERIC]
		x       [-ring_number_of_nodes               NUMERIC]
		x       [-ring_include_emulated_device       CHOICES 0 1]
		x       [-ring_link_multiplier               NUMERIC]
		x       [-hub_spoke_number_of_first_level    NUMERIC]
		x       [-hub_spoke_number_of_second_level   NUMERIC]
		x       [-hub_spoke_enable_level_2           CHOICES 0 1]
		x       [-hub_spoke_link_multiplier          NUMERIC]
		x       [-tree_number_of_nodes               NUMERIC]
		x       [-tree_include_emulated_device       CHOICES 0 1]
		x       [-tree_use_tree_depth                CHOICES 0 1]
		x       [-tree_depth                         NUMERIC]
		x       [-tree_max_children_per_node         NUMERIC]
		x       [-tree_link_multiplier               NUMERIC]
		x       [-custom_link_multiplier             NUMERIC]
		x       [-custom_from_node_index             NUMERIC]
		x       [-custom_to_node_index               NUMERIC]
		x       [-fat_tree_link_multiplier           NUMERIC]
		x       [-fat_tree_level_count               NUMERIC]
		x       [-fat_tree_node_count                NUMERIC]
		x       [-linear_nodes                       NUMERIC]
		x       [-linear_link_multiplier             NUMERIC]
		x       [-external_link_router_source        NUMERIC]
		x       [-external_link_router_destination   NUMERIC]
		x       [-external_link_network_group_handle ANY]
		x       [-connected_to_handle                ANY]
		n       [-fec_host_step                      ANY]
		n       [-path_vector_tlv                    ANY]
		n       [-path_vector_tlv_lsr                ANY]
		
		 Arguments:
		    -mode
		        Which mode is being performed.All but create require the use of
		        the -handle option.Valid choices are:
		        create- Create a new LDP interface
		        modify- Modify an existing LDP interface
		        delete- Delete the given LDP interface
		    -handle
		        The LDP handle.
		x   -return_detailed_handles
		x       This argument determines if individual interface, session or router handles are returned by the current command.
		x       This applies only to the command on which it is specified.
		x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
		x       decrease the size of command results and speed up script execution.
		x       The default is 0, meaning only protocol stack handles will be returned.
		    -egress_label_mode
		        This argument can be used to specify whether or not the same label
		        will be used for all the FECs in the FEC range. It has any meaning
		        only when the fec_type option is set to host_addr.
		    -fec_ip_prefix_start
		        The first network address in the range of advertising FECs, when
		        fec_type is ipv4_prefix.
		x   -fec_ip_prefix_step
		x       Provides step increment for fec_ip_prefix_start for adv Fec Range.
		x   -fec_ip_prefix_length
		x       The number of bits in the mask applied to the network address. The
		x       masked bits in the First Network address form the address prefix.
		x       Valid when fec_type is ipv4_prefix.
		n   -fec_host_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_host_prefix_length
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -fec_type
		        Note: this option cannot be modified with modify mode.
		        Valid choices are:
		        ipv4_prefix - configure FECs to be advertised by the
		        simulated router
		        host_addr - configure FECs to be requested of upstream peers, to be
		        used in download on demand advertising mode.
		        vc - configure parameters for VC range associated with an LDP L2 VPN
		        interface.
		x   -network_topology_type
		x       The type of topology route to create.
		x   -fec_vc_atm_enable
		x       If checked, indicates that ATM Transparent Cell Transport mode is
		x       being used. Multiple ATM cells may be grouped into a single MPLS frame
		x       for transmission from one ATM port connected to another ATM port.
		x       Valid only when -mode is create/modify and -fec_vc_type is atm_cell or
		x       atm_vcc_1_1 or atm_vpc_1_1 or atm_vcc_n_1 or atm_vpc_n_1 and fec_type is vc.
		x       Valid only when using IxTclNetwork.
		x   -fec_vc_atm_max_cells
		x       The Maximum number of ATM Cells which may be concatenated and sent in
		x       a single MPLS frame. This parameter is part of the FEC element.
		x       Valid only when -mode is create/modify and -fec_vc_type is atm_cell or
		x       atm_vcc_1_1 or atm_vpc_1_1 or atm_vcc_n_1 or atm_vpc_n_1 and fec_type is vc.
		x       Valid only when using IxTclNetwork.
		    -fec_vc_cbit
		        If checked, sets the C-Bit (flag). It is the highest order bit in the
		        VC Type field. If the bit is set, it indicates the presence of a
		        control word on this VC.
		        Valid when fec_type is vc. This parameter is always 1, when fec_vc_type is cem, fr_dlci or fr_dlci_rfc4619.
		n   -fec_vc_ce_ip_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_vc_ce_ip_addr_inner_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_vc_ce_ip_addr_outer_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -fec_vc_cem_option
		x       The value of the CEM option.
		x       Valid only when -mode is create/modify and -fec_vc_type is cem and fec_type is vc.
		x       Valid only when using IxTclNetwork.
		x   -fec_vc_cem_option_enable
		x       If checked, indicates that the CEM option is present.
		x       Valid only when -mode is create or modify and -fec_vc_type is cem and fec_type is vc.
		x       Valid only when using IxTclNetwork.
		x   -fec_vc_cem_payload
		x       The length of the CEM payload (in bytes).
		x       Valid only when -mode is create or modify and -fec_vc_type is cem and fec_type is vc.
		x       Valid only when using IxTclNetwork.
		x   -fec_vc_cem_payload_enable
		x       If checked, indicates that there is a CEM payload.
		x       Valid only when -mode is create or modify and -fec_vc_type is cem and fec_type is vc.
		x       Valid only when using IxTclNetwork.
		x   -fec_vc_count
		x       This option can be used to set the number of pseudowires to be
		x       configured on each LDP VC range.
		x       Valid only when using IxTclNetwork API and fec_type is vc.
		x   -fec_vc_fec_type
		x       Configure the FEC type Valid only when using IxTclNetwork API and fec_type is vc.
		x       Valid choices are:
		x       generalized_id_fec_vpls- Generalized Id FEC 0x81 VPLS
		x       pw_id_fec- PW Id FEC 0x80
		    -fec_vc_group_id
		        A user-defined 32-bit value used to identify a group of VCs.
		        Valid when fec_type is vc.
		n   -fec_vc_group_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -fec_vc_id_start
		        The 32-bit VC connection identifier. Used with the VC type to identify
		        a specific VC.
		        Valid when fec_type is vc.
		    -fec_vc_id_step
		        The increment step to be added to the VCID to create the next VCID in
		        a group of VCIDs.
		        Valid when fec_type is vc.
		n   -fec_vc_id_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_vc_intf_mtu_enable
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -fec_vc_intf_mtu
		        (in octets) The 2-octet value for the maximum Transmission Unit (MTU).
		        Valid when fec_type is vc.
		    -fec_vc_intf_desc
		        An optional user-defined Interface Description. It may be used with
		        ALL VC types. Valid length is 0 to 80 octets.
		        Valid when fec_type is vc.
		x   -fec_vc_intf_desc_enable
		x       Description Enabled
		x   -fec_vc_name
		x   -fec_vc_active
		x       Activates the FEC VC/LSP items.
		n   -fec_vc_ip_range_addr_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_vc_ip_range_addr_start
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_vc_ip_range_addr_inner_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_vc_ip_range_addr_outer_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_vc_ip_range_enable
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_vc_ip_range_prefix_len
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_vc_label_mode
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -fec_vc_label_value_start
		x       The first label in the range of labels.
		x       Valid when fec_type is vc.
		x   -fec_vc_label_value_step
		x       The incrementing step for the fec_vc_label_value_start.
		x       Valid when fec_type is vc and fec_vc_count is greater than 1.
		x       Valid only when using IxTclNetwork.
		x   -fec_vc_mac_range_count
		x       If fec_vc_mac_range_vlan_enable is 1, this it the number of MAC
		x       address/VLAN combinations that will be created. If
		x       fec_vc_mac_range_vlan_enable is 0, this is the number of MAC addresses
		x       that will be created.
		x       Valid only when -mode is create or modify and -fec_vc_type is eth or
		x       eth_vlan and fec_type is vc.
		x       Valid only when using IxTclNetwork.
		x   -fec_vc_mac_range_enable
		x       If checked, the MAC range corresponding to the layer2 VC range
		x       will be enabled.
		x       Valid only when -mode is create or modify and -fec_vc_type is eth or
		x       eth_vlan and fec_type is vc.
		x       Valid only when using IxTclNetwork.
		x   -fec_vc_mac_range_first_vlan_id
		x       The VLAN ID for the first VLAN in the MAC/VLAN range.
		x       Valid only when -mode is create or modify and -fec_vc_type is eth or
		x       eth_vlan and fec_type is vc.
		x       Valid only when using IxTclNetwork.
		n   -fec_vc_mac_range_repeat_mac
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -fec_vc_mac_range_same_vlan
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -fec_vc_mac_range_start
		x       The first MAC address in the MAC range.
		x       Valid only when -mode is create or modify and -fec_vc_type is eth or
		x       eth_vlan and fec_type is vc.
		x       Valid only when using IxTclNetwork.
		n   -fec_vc_mac_range_vlan_enable
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -fec_vc_peer_address
		x       The 32-bit IP address of the LDP Peer.
		x       Valid only when -mode is create or modify and fec_type is vc.
		    -fec_vc_type
		        The 15-bit VC Type used in the VC FEC element. It depends on the Layer
		        2 protocol used on the interface. Valid when fec_type is vc.
		        Valid choices are:
		        atm_aal5_vcc - ATM AAL5 VCC transport (VC Type 0x0002)
		        atm_cell - ATM Transparent cell transport (VC Type 0x0003)
		        atm_vcc_1_1 - ATM VCC cell transport (VC Type 0x0009)
		        atm_vcc_n_1 - ATM VCC cell transport (VC Type 0x0009)
		        atm_vpc_1_1 - ATM VPC cell transport (VC Type 0x000A)
		        atm_vpc_n_1 - ATM VPC cell transport (VC Type 0x000A)
		        cem - Circuit Emulation Service over MPLS (CEM), for encapsulation of TDM signal (VC Type 0x8008)
		        eth - untagged Ethernet frames (VC Type 0x0005)
		        eth_vlan - VLAN-tagged Ethernet frames (VC Type 0x0004)
		        eth_vpls - Internet Protocol packets (VC Type 0x000B)
		        fr_dlci - Frame Relay DLCI (VC Type 0x0001)
		        hdlc - HDLC frames (VC Type 0x0006)
		        ppp - Point-to-Point Protocol frames (VC Type 0x0007)
		        satop_e1 - Satop-E1
		        satop_e3 - Satop-E3
		        satop_t1 - Satop-T1
		        satop_t3 - Satop-T3
		        cesopsn_basic - CESoPSN-Basic
		        cesopsn_cas - CESoPSN-CAS
		        fr_dlci_rfc4619 - RFC 4619 Frame Relay DLCI (VC Type 0x0019)
		n   -hop_count_tlv_enable
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -hop_count_value
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -label_msg_type
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -label_value_start
		x       The first label in the range of labels.
		x       Valid when fec_type is ipv4_prefix.
		x   -label_value_start_step
		x       Specifies the step increment for Label Value start.
		    -lsp_handle
		        This option specifies on which lsp element to configure the
		        lsp pools/fec range options. The user must pass in this option
		        if the "type" is modify or delete.lsp_handle is returned by
		        this procedure when "type" is create.
		n   -next_hop_peer_ip
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -num_lsps
		        The number of network addresses to be included in the range. The
		        maximum number of valid possible addresses depends on the values for
		        the first network and the network mask.
		        Valid for fec_type ipv4_prefix.
		n   -num_routes
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -packing_enable
		x       For L2 VC FEC ranges and in Unsolicited Label Distribution Mode ONLY.
		x       If checked, L2 VC FEC ranges will be aggregated within a single LDP
		x       PDU to conserve bandwidth and processing.
		x   -provisioning_model
		x       This option denotes the Provisioning Model.
		x       Valid choices are:
		x       bgp_auto_discovery - bgp Auto Discovery
		x       manual_configuration - manual configuration
		x       (DEFAULT=bgp_auto_discovery)
		n   -stale_timer_enable
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -stale_request_time
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -no_write
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -fec_vc_pw_status_enable
		x       Enable PW Status
		x   -fec_vc_pw_status_code
		x       PW Status Code
		x   -fec_vc_pw_status_send_notification
		x       PW Status Send Notification
		x   -fec_vc_down_start
		x       DownStart
		x   -fec_vc_down_interval
		x       Down Interval
		x   -fec_vc_up_interval
		x       Up Interval
		x   -fec_vc_repeat_count
		x       Repeat Count
		x   -fec_vc_type_vpls_id
		x       VPLS ID Type
		x   -fec_vc_ip_address_vpls_id
		x       VPLS ID IP Address
		x   -fec_vc_as_number_vpls_id
		x       VPLS ID AS Number
		x   -fec_vc_assigned_number_vpls_id
		x       VPLS ID Assigned Number
		x   -fec_vc_source_aii_type
		x       Source AII Type
		x   -fec_vc_source_aii_as_ip
		x       Source AII as IP
		x   -fec_vc_source_aii_as_number
		x       Source AII as Number
		x   -fec_vc_target_aii_type
		x       Target AII Type
		x   -fec_vc_target_aii_as_ip
		x       Target AII as IP
		x   -fec_vc_target_aii_as_number
		x       Target AII as Number
		x   -fec_vc_include_tdm_payload
		x       Include TDM Payload
		x   -fec_vc_tdm_data_size
		x       TDM Data Size
		x   -fec_vc_include_tdm_bitrate
		x       Include TDM Bitrate
		x   -fec_vc_tdm_bitrate
		x       TDM Bitrate
		x   -fec_vc_include_rtp_header
		x       Include RTP Header
		x   -fec_vc_include_tdm_option
		x       Include TDM Option
		x   -fec_vc_timestamp_mode
		x       Timestamp Mode
		x   -fec_vc_payload_type
		x       Pay Load Type
		x   -fec_vc_frequency
		x       Frequency
		x   -fec_vc_include_ssrc
		x       Include SSRC
		x   -fec_vc_ssrc
		x       SSRC
		x   -fec_vc_cas
		x       CAS
		x   -fec_vc_sp
		x       SP
		x   -fec_vc_enable_cccv_negotiation
		x       Enable CCCV Negotiation
		x   -fec_vc_pw_ach_cc
		x       PW-ACH CC
		x   -fec_vc_router_alert_cc
		x       Router Alert CC
		x   -fec_vc_lsp_ping_cv
		x       LSP Ping CV
		x   -fec_vc_bfd_udp_cv
		x       BFD IP/UDP CV
		x   -fec_vc_bfd_pw_cv
		x       BFD PW-ACH CV
		x   -fec_active
		x       Enable/Activate the FEC Property Range.
		x   -fec_name
		x       Valid Name for the FEC Property Range.
		x   -topology_config_active
		x       This is to activate the ldp Simulated Topology Config object of the NetworkTopology in Network Group.
		x   -topology_router_active
		x       This attribute activates the pseudo Ldp router of network Topology.
		x   -topology_router_label_value
		x       This attribute set the Label Value of the LDP Topology Router of Network Toplogy
		x   -topology_router_id
		x       The router id of the LDP Topology router of Network topology.4 Byte Router Id in dotted decimal format.
		    -grid_col
		        Defines number of columns in a grid.
		        This option is valid only when -type is grid, otherwise it
		        is ignored. This option is available with IxTclNetwork and IxTclProtocol API.
		        (DEFAULT = 2)
		    -grid_row
		        Defines number of rows in a grid.
		        This option is valid only when -type is grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		        (DEFAULT = 2)
		x   -grid_include_emulated_device
		x   -grid_link_multiplier
		x   -mesh_number_of_nodes
		x   -mesh_include_emulated_device
		x   -mesh_link_multiplier
		x   -ring_number_of_nodes
		x   -ring_include_emulated_device
		x   -ring_link_multiplier
		x   -hub_spoke_number_of_first_level
		x   -hub_spoke_number_of_second_level
		x   -hub_spoke_enable_level_2
		x   -hub_spoke_link_multiplier
		x   -tree_number_of_nodes
		x   -tree_include_emulated_device
		x   -tree_use_tree_depth
		x   -tree_depth
		x   -tree_max_children_per_node
		x   -tree_link_multiplier
		x   -custom_link_multiplier
		x       number of links between two nodes
		x   -custom_from_node_index
		x   -custom_to_node_index
		x   -fat_tree_link_multiplier
		x       number of links between two nodes
		x   -fat_tree_level_count
		x       Number of Levels
		x   -fat_tree_node_count
		x       Number of Nodes Per Level
		x   -linear_nodes
		x       number of nodes
		x   -linear_link_multiplier
		x       number of links between two nodes
		x   -external_link_router_source
		x       Index of the originating node as defined in fromNetworkTopology
		x   -external_link_router_destination
		x       Index of the target node as defined in toNetworkTopology
		x   -external_link_network_group_handle
		x       Network Topology this link is pointing to
		x   -connected_to_handle
		x       Scenario element this connector is connecting to
		n   -fec_host_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -path_vector_tlv
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -path_vector_tlv_lsr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		
		 Return Values:
		    A list containing the network group protocol stack handles that were added by the command (if any).
		x   key:network_group_handle  value:A list containing the network group protocol stack handles that were added by the command (if any).
		    A list containing the fecproperty protocol stack handles that were added by the command (if any).
		x   key:fecproperty_handle    value:A list containing the fecproperty protocol stack handles that were added by the command (if any).
		    A list containing the ldppwvpls protocol stack handles that were added by the command (if any).
		x   key:ldppwvpls_handle      value:A list containing the ldppwvpls protocol stack handles that were added by the command (if any).
		    A list containing the ldpotherpws protocol stack handles that were added by the command (if any).
		x   key:ldpotherpws_handle    value:A list containing the ldpotherpws protocol stack handles that were added by the command (if any).
		    A list containing the ldpvplsbgpad protocol stack handles that were added by the command (if any).
		x   key:ldpvplsbgpad_handle   value:A list containing the ldpvplsbgpad protocol stack handles that were added by the command (if any).
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:fecproperty_handles   value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:ldppwvpls_handles     value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:ldpotherpws_handles   value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:ldpvplsbgpad_handles  value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		
		 Examples:
		    See files starting with LDP_ in the Samples subdirectory.  Also see some of the L2VPN, L3VPN, MPLS, and MVPN sample files for further examples of the LDP usage.
		    See the LDP example in Appendix A, "Example APIs," for one specific example usage.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    Coded versus functional specification.
		    If fec_type option is ipv4_prefix, the label_msg_type option must be
		    mapping; if fec_type option is host_addr, the the label_msg_type option
		    must be request.
		    For "modify" mode, the fec_type option and label_msg_type option will not
		    be updated for the lsp.
		    When using the new IxTclNetwork API 5.30, the label_msg_type option
		    is silently ignored. Only the fec_type option is used. If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  fecproperty_handles, ldppwvpls_handles, ldpotherpws_handles, ldpvplsbgpad_handles
		
		 See Also:
		
		'''
		hlpy_args = locals().copy()
		hlpy_args.update(kwargs)
		del hlpy_args['self']
		del hlpy_args['kwargs']

		not_implemented_params = []
		mandatory_params = []
		file_params = []

		try:
			return self.__execute_command(
				'emulation_ldp_route_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
