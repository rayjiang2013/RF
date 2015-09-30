proc ::ixia::540trafficConfig { args } {
    
    set args [lindex $args 0]
    
    variable ixnetworkVersion
    variable 540IxNetTrafficGenerate
    variable current_streamid
    variable truth
    variable ngt_config_elements_array
    variable multicast_group_ip_to_handle
    variable pa_ip_idx
    catch {array unset ngt_config_elements_array}
    array set ngt_config_elements_array ""
    
    keylset returnList status $::SUCCESS
    # Get the version and product from the ixnetworkVersion variable
    regexp {^(\d+.\d+)(P|N|NO|P2NO)?$} $ixnetworkVersion {} version product
    
    set man_args_common {
        -mode                               CHOICES create modify remove reset 
                                            CHOICES enable disable append_header modify_or_insert
                                            CHOICES prepend_header replace_header
                                            CHOICES dynamic_update
                                            CHOICES get_available_protocol_templates
                                            CHOICES get_available_fields get_field_values set_field_values
                                            CHOICES add_field_level remove_field_level
                                            CHOICES get_available_egress_tracking_field_offset
                                            CHOICES get_available_dynamic_update_fields
                                            CHOICES get_available_session_aware_traffic
                                            CHOICES get_available_fields_for_link 
    }
    
    set opt_args_common {
        -traffic_generate                   CHOICES 0 1
                                            DEFAULT 1
        -transmit_distribution              ANY
        -tx_mode                            CHOICES advanced stream
        -stream_id
        -allow_self_destined                CHOICES 0 1
                                            DEFAULT 0
        -port_handle                        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -port_handle2                       REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -traffic_generator                  CHOICES ixos ixnetwork ixnetwork_540
                                            DEFAULT ixnetwork_540
        -emulation_dst_handle
        -emulation_multicast_dst_handle
        -emulation_multicast_dst_handle_type
        -emulation_multicast_rcvr_handle
        -emulation_multicast_rcvr_port_index NUMERIC
        -emulation_multicast_rcvr_host_index NUMERIC
        -emulation_multicast_rcvr_mcast_index NUMERIC
        -emulation_src_handle
        -emulation_scalable_dst_handle
        -emulation_scalable_dst_port_start
        -emulation_scalable_dst_port_count
        -emulation_scalable_dst_intf_start
        -emulation_scalable_dst_intf_count
        -emulation_scalable_src_handle
        -emulation_scalable_src_port_start
        -emulation_scalable_src_port_count
        -emulation_scalable_src_intf_start
        -emulation_scalable_src_intf_count
        -endpointset_count                  NUMERIC
                                            DEFAULT 1
        -circuit_type                       CHOICES none
                                            CHOICES l2vpn
                                            CHOICES l3vpn
                                            CHOICES mpls
                                            CHOICES 6pe
                                            CHOICES 6vpe
                                            CHOICES raw
                                            CHOICES vpls
                                            CHOICES stp
                                            CHOICES mac_in_mac
                                            CHOICES quick_flows
                                            CHOICES application
        -circuit_endpoint_type              CHOICES atm
                                            CHOICES ethernet_vlan
                                            CHOICES ethernet_vlan_arp
                                            CHOICES frame_relay
                                            CHOICES hdlc
                                            CHOICES ipv4
                                            CHOICES ipv4_arp
                                            CHOICES ipv4_application_traffic
                                            CHOICES ipv6
                                            CHOICES ipv6_application_traffic
                                            CHOICES ppp
                                            CHOICES fcoe
                                            CHOICES multicast_igmp
                                            CHOICES fc
        -l3_protocol                        CHOICES ipv4 ipv6 arp pause_control 
                                            CHOICES ipx
        -l4_protocol                        CHOICES icmp igmp ggp ip st tcp ucl 
                                            CHOICES egp igp bbn_rcc_mon nvp_ii 
                                            CHOICES pup argus emcon xnet chaos 
                                            CHOICES udp mux dcn_meas hmp prm 
                                            CHOICES xns_idp trunk_1 trunk_2 
                                            CHOICES leaf_1 leaf_2 rdp irtp 
                                            CHOICES iso_tp4 netblt mfe_nsp 
                                            CHOICES merit_inp sep cftp
                                            CHOICES sat_expak mit_subnet rvd 
                                            CHOICES ippc sat_mon ipcv 
                                            CHOICES br_sat_mon wb_mon wb_expak 
                                            CHOICES rip dhcp gre ospf
        -route_mesh                         CHOICES fully one_to_one
                                            DEFAULT one_to_one
        -src_dest_mesh                      CHOICES fully many_to_many one_to_one none
                                            DEFAULT one_to_one
        -name 
        -bidirectional                      CHOICES 0 1
        -convert_to_raw                     CHOICES 0 1 
        -source_filter
        -stream_packing                     CHOICES merge_destination_ranges
                                            CHOICES one_stream_per_endpoint_pair
                                            CHOICES optimal_packing
        -destination_filter
        -tag_filter                         ANY
        -preamble_size_mode                 CHOICES auto custom
        -preamble_custom_size               NUMERIC
        -atm_header_encapsulation           CHOICES vcc_mux_ipv4_routed
                                            CHOICES vcc_mux_bridged_eth_fcs
                                            CHOICES vcc_mux_bridged_eth_no_fcs
                                            CHOICES vcc_mux_ipv6_routed
                                            CHOICES vcc_mux_mpls_routed
                                            CHOICES llc_routed_clip
                                            CHOICES llc_bridged_eth_fcs
                                            CHOICES llc_bridged_eth_no_fcs
                                            CHOICES llc_pppoa
                                            CHOICES vcc_mux_ppoa 
                                            CHOICES llc_nlpid_routed
                                            CHOICES llc_ppp
                                            CHOICES llc_routed_snap
                                            CHOICES vcc_mux_ppp
                                            CHOICES vcc_mux_routed
        -l2_encap                           CHOICES atm_vc_mux
                                            CHOICES atm_vc_mux_ethernet_ii
                                            CHOICES atm_vc_mux_802.3snap
                                            CHOICES atm_snap_802.3snap_nofcs
                                            CHOICES atm_vc_mux_ppp
                                            CHOICES atm_vc_mux_pppoe
                                            CHOICES atm_snap
                                            CHOICES atm_snap_ethernet_ii
                                            CHOICES atm_snap_802.3snap
                                            CHOICES atm_vc_mux_802.3snap_nofcs
                                            CHOICES atm_snap_ppp
                                            CHOICES atm_snap_pppoe
                                            CHOICES hdlc_unicast
                                            CHOICES hdlc_broadcast
                                            CHOICES hdlc_unicast_mpls
                                            CHOICES hdlc_multicast_mpls
                                            CHOICES ethernet_ii
                                            CHOICES ethernet_ii_unicast_mpls
                                            CHOICES ethernet_ii_multicast_mpls
                                            CHOICES ethernet_ii_vlan
                                            CHOICES ethernet_ii_vlan_unicast_mpls
                                            CHOICES ethernet_ii_vlan_multicast_mpls
                                            CHOICES ethernet_ii_pppoe
                                            CHOICES ethernet_ii_vlan_pppoe
                                            CHOICES ppp_link
                                            CHOICES ietf_framerelay
                                            CHOICES cisco_framerelay
        -emulation_override_ppp_ip_addr     CHOICES upstream downstream both none
        -enable_dynamic_mpls_labels         CHOICES 0 1
        -skip_return_handles                CHOICES 0 1
                                            DEFAULT 0
        -merge_destinations                 CHOICES 0 1
        -egress_stats_list                  ANY
        -field_linked                       ANY
        -field_linked_to                    ANY
        -pending_operations_timeout         NUMERIC
                                            DEFAULT 10
        -stack_index                        NUMERIC
        -use_cp_size	                    CHOICES 0 1
                                            DEFAULT 1
		-use_cp_rate                        CHOICES 0 1
                                            DEFAULT 1
    
    }

        
    set opt_args_frame_size {
        -frame_size                         RANGE   12-13312
        -frame_size_max                     RANGE   12-13312
        -frame_size_min                     RANGE   12-13312
        -frame_size_step                    RANGE   0-13292
        -frame_size_distribution            CHOICES cisco imix quadmodal tolly
                                            CHOICES trimodal imix_ipsec imix_ipv6
                                            CHOICES imix_std imix_tcp
        -frame_size_gauss                   REGEXP  ^([0-9]+(\.[0-9])*:[0-9]+(\.[0-9])*:[0-9]+ ){0,3}[0-9]+(\.[0-9])*:[0-9]+(\.[0-9])*:[0-9]+$
        -frame_size_imix                    REGEXP  ^([0-9]+:[0-9]+ )*[0-9]+:[0-9]+$
        -length_mode                        CHOICES fixed increment random auto 
                                            CHOICES imix gaussian quad 
                                            CHOICES distribution
                                            DEFAULT fixed
        -l3_imix1_size                      RANGE   32-9000
        -l3_imix1_ratio                     RANGE   0-262144
        -l3_imix2_size                      RANGE   32-9000
        -l3_imix2_ratio                     RANGE   0-262144
        -l3_imix3_size                      RANGE   32-9000
        -l3_imix3_ratio                     RANGE   0-262144
        -l3_imix4_size                      RANGE   32-9000
        -l3_imix4_ratio                     RANGE   0-262144
        -l3_gaus1_avg                       DECIMAL
        -l3_gaus1_halfbw                    DECIMAL
        -l3_gaus1_weight                    NUMERIC
        -l3_gaus2_avg                       DECIMAL
        -l3_gaus2_halfbw                    DECIMAL
        -l3_gaus2_weight                    NUMERIC
        -l3_gaus3_avg                       DECIMAL
        -l3_gaus3_halfbw                    DECIMAL
        -l3_gaus3_weight                    NUMERIC
        -l3_gaus4_avg                       DECIMAL
        -l3_gaus4_halfbw                    DECIMAL
        -l3_gaus4_weight                    NUMERIC
        -l3_length                          RANGE   1-64000
        -l3_length_min                      RANGE   1-64000
        -l3_length_max                      RANGE   1-64000
        -l3_length_step                     RANGE   0-64000
        -skip_frame_size_validation         FLAG
        }
    
    set opt_args_instrumentation {
        -data_pattern                       
        -data_pattern_mode                  CHOICES incr_byte decr_byte fixed 
                                            CHOICES random repeating incr_word 
                                            CHOICES decr_word
        -fcs                                CHOICES 0 1
        -fcs_type                           CHOICES alignment dribble bad_CRC 
                                            CHOICES no_CRC
        -frame_sequencing                   CHOICES enable disable
        -frame_sequencing_mode              CHOICES rx_switched_path rx_switched_path_fixed advanced
                                            CHOICES rx_threshold }
    
    set opt_args_ratecontrol {
        -rate_bps
        -rate_kbps
        -rate_mbps
        -rate_byteps
        -rate_kbyteps
        -rate_mbyteps
        -rate_mode                          CHOICES first_option_provided percent pps bps 
                                            CHOICES kbps mbps byteps kbyteps mbyteps
                                            DEFAULT first_option_provided
        -rate_percent                       RANGE   0-100
        -rate_frame_gap                     RANGE   0-100
        -rate_pps
        -return_to_id
        -transmit_mode                      CHOICES continuous random_spaced
                                            CHOICES single_pkt single_burst
                                            CHOICES multi_burst continuous_burst
                                            CHOICES return_to_id advance
                                            CHOICES return_to_id_for_count
        -pkts_per_burst
        -inter_burst_gap
        -inter_frame_gap                    NUMERIC
        -inter_frame_gap_unit               CHOICES bytes ns
        -inter_stream_gap
        -burst_loop_count
        -tx_delay                           NUMERIC
        -number_of_packets_per_stream       RANGE   1-9999999999
        -number_of_packets_tx
        -loop_count
        -tx_delay_unit                      CHOICES bytes ns
        -enforce_min_gap                    NUMERIC
        -min_gap_bytes                      RANGE 1-2147483647
        -frame_rate_distribution_port       CHOICES apply_to_all split_evenly
        -frame_rate_distribution_stream     CHOICES apply_to_all split_evenly
        -duration                           NUMERIC
    }
    
    set opt_args_tracking {
        -track_by                         ANY
        -hosts_per_net                    NUMERIC
        -custom_offset                    NUMERIC
        -custom_values                    NUMERIC
        -egress_tracking                  CHOICES none dscp ipv6TC mplsExp custom custom_by_field
                                          CHOICES outer_vlan_priority outer_vlan_id_4 
                                          CHOICES outer_vlan_id_6 outer_vlan_id_8 
                                          CHOICES outer_vlan_id_10 outer_vlan_id_12 
                                          CHOICES inner_vlan_priority inner_vlan_id_4 
                                          CHOICES inner_vlan_id_6 inner_vlan_id_8 
                                          CHOICES inner_vlan_id_10 inner_vlan_id_12 
                                          CHOICES tos_precedence ipv6TC_bits_0_2 
                                          CHOICES ipv6TC_bits_0_5 vnTag_direction_bit 
                                          CHOICES vnTag_pointer_bit vnTag_looped_bit
        -egress_tracking_encap            CHOICES custom ethernet LLCRoutedCLIP LLCPPPoA 
                                          CHOICES LLCBridgedEthernetFCS LLCBridgedEthernetNoFCS 
                                          CHOICES VccMuxPPPoA VccMuxIPV4Routed 
                                          CHOICES VccMuxBridgedEthernetFCS 
                                          CHOICES VccMuxBridgedEthernetNoFCS
                                          CHOICES pos_ppp pos_hdlc frame_relay1490
                                          CHOICES frame_relay2427 frame_relay_cisco
        -egress_custom_offset             VCMD ::ixia::validate_egress_custom_offset
        -egress_custom_width              VCMD ::ixia::validate_egress_custom_width
        -egress_custom_field_offset       ANY
        -enable_override_value            CHOICES 0 1
        -latency_bins_enable              CHOICES 0 1
                                          DEFAULT 0
        -latency_bins                     RANGE   2-16
        -latency_values                   DECIMAL
        -override_value_list
    }
    
    set opt_args_atm_l1 {
        -atm_counter_vpi_data_item_list     RANGE   0-4096
                                            DEFAULT 0
        -atm_counter_vci_data_item_list     RANGE   0-65535
                                            DEFAULT 32
        -atm_counter_vpi_mask_value         ANY
                                            DEFAULT 0000
        -atm_counter_vci_mask_value         ANY
                                            DEFAULT 0000
        -atm_counter_vpi_mode               CHOICES incr cont_incr decr 
                                            CHOICES cont_decr
                                            DEFAULT incr
        -atm_counter_vci_mode               CHOICES incr cont_incr decr 
                                            CHOICES cont_decr
                                            DEFAULT incr
        -atm_counter_vpi_type               CHOICES fixed counter random table
                                            DEFAULT fixed
        -atm_counter_vci_type               CHOICES fixed counter random table
                                            DEFAULT fixed
        -vci                                RANGE   0-65535
                                            DEFAULT 32
        -vci_count                          RANGE   0-65535
                                            DEFAULT 1
        -vci_step                           RANGE   0-65534
                                            DEFAULT 1
        -vpi                                RANGE   0-4096
                                            DEFAULT 0
        -vpi_count                          RANGE   0-4096
                                            DEFAULT 1
        -vpi_step                           RANGE   0-4095
                                            DEFAULT 1 }
    
    set opt_args_l2_ethernet {
        -ethernet_value                     HEX
        -ethernet_value_mode                CHOICES fixed incr decr list
                                            DEFAULT fixed
        -ethernet_value_step                HEX
                                            DEFAULT 0x01
        -ethernet_value_count               NUMERIC
                                            DEFAULT 1
        -ethernet_value_tracking            CHOICES 0 1
        -isl                                CHOICES 0 1
                                            DEFAULT 0
        -isl_bpdu                           CHOICES 0 1
                                            DEFAULT 0
        -isl_bpdu_mode                      CHOICES fixed incr decr list
                                            DEFAULT fixed
        -isl_bpdu_step                      CHOICES 0 1
                                            DEFAULT 1
        -isl_bpdu_count                     NUMERIC
                                            DEFAULT 1
        -isl_bpdu_tracking                  CHOICES 0 1
        -isl_frame_type                     CHOICES ethernet atm fddi token_ring
        -isl_frame_type_mode                CHOICES fixed list
        -isl_frame_type_tracking            CHOICES 0 1
        -isl_index                          NUMERIC
        -isl_index_mode                     CHOICES fixed incr decr list
                                            DEFAULT fixed
        -isl_index_step                     NUMERIC
                                            DEFAULT 1
        -isl_index_count                    NUMERIC
                                            DEFAULT 1
        -isl_index_tracking                 CHOICES 0 1
        -isl_user_priority                  RANGE   0-7
        -isl_user_priority_mode             CHOICES fixed incr decr list
                                            DEFAULT fixed
        -isl_user_priority_step             RANGE 0-6
                                            DEFAULT 1
        -isl_user_priority_count            NUMERIC
                                            DEFAULT 1
        -isl_user_priority_tracking         CHOICES 0 1
        -isl_vlan_id                        RANGE   0-4095
        -isl_vlan_id_mode                   CHOICES fixed incr decr list
                                            DEFAULT fixed
        -isl_vlan_id_step                   NUMERIC
                                            DEFAULT 1
        -isl_vlan_id_count                  NUMERIC
                                            DEFAULT 1
        -isl_vlan_id_tracking               CHOICES 0 1
        -isl_mac_src_high                   HEX
        -isl_mac_src_high_mode              CHOICES fixed incr decr list
                                            DEFAULT fixed
        -isl_mac_src_high_step              HEX
                                            DEFAULT 0x01
        -isl_mac_src_high_count             NUMERIC
                                            DEFAULT 1
        -isl_mac_src_high_tracking          CHOICES 0 1
        -isl_mac_src_low                    HEX
        -isl_mac_src_low_mode               CHOICES fixed incr decr list
                                            DEFAULT fixed
        -isl_mac_src_low_step               HEX
                                            DEFAULT 0x01
        -isl_mac_src_low_count              NUMERIC
                                            DEFAULT 1
        -isl_mac_src_low_tracking           CHOICES 0 1
        -isl_mac_dst                        ANY
        -isl_mac_dst_mode                   CHOICES fixed incr decr list
                                            DEFAULT fixed
        -isl_mac_dst_step                   ANY
                                            DEFAULT 0000.0000.0001
        -isl_mac_dst_count                  NUMERIC
                                            DEFAULT 1
        -isl_mac_dst_tracking               CHOICES 0 1
        -mac_dst                            ANY
        -mac_dst_tracking                   CHOICES 0 1
        -mac_dst_count                      RANGE   0-2147483647
        -mac_dst_mask                       MAC
        -mac_dst_mode                       CHOICES fixed increment decrement
                                            CHOICES discovery random list repeatable_random
        -mac_dst_seed                       NUMERIC
        -mac_dst_step                       ANY
        -mac_src                            ANY
        -mac_src_tracking                   CHOICES 0 1
        -mac_src_count                      NUMERIC
        -mac_src_mask                       MAC
        -mac_src_mode                       CHOICES fixed increment decrement 
                                            CHOICES random emulation list repeatable_random
        -mac_src_seed                       NUMERIC
        -mac_src_step                       ANY
        -vlan                               CHOICES enable disable
        -vlan_cfi                           LIST_OF_LISTS_NO_TYPE_CHECK
        -vlan_cfi_count                     NUMERIC
                                            DEFAULT 1
        -vlan_cfi_mode                      CHOICES fixed incr decr list
                                            DEFAULT fixed
        -vlan_cfi_step                      CHOICES 0 1
                                            DEFAULT 1
        -vlan_cfi_tracking                  CHOICES 0 1
        -vlan_id                            LIST_OF_LISTS_NO_TYPE_CHECK
        -vlan_id_count                      RANGE   0-4095
        -vlan_id_mode                       CHOICES fixed increment decrement 
                                            CHOICES random nested_incr 
                                            CHOICES nested_decr list
        -vlan_id_step                       NUMERIC
        -vlan_id_tracking                   CHOICES 0 1
        -vlan_protocol_tag_id               LIST_OF_LISTS_NO_TYPE_CHECK
        -vlan_protocol_tag_id_count         NUMERIC
                                            DEFAULT 1
        -vlan_protocol_tag_id_mode          CHOICES fixed incr decr list
                                            DEFAULT fixed
        -vlan_protocol_tag_id_step          HEX
                                            DEFAULT 0x01
        -vlan_protocol_tag_id_tracking      CHOICES 0 1
        -vlan_user_priority                 LIST_OF_LISTS_NO_TYPE_CHECK
        -vlan_user_priority_count           NUMERIC
                                            DEFAULT 1
        -vlan_user_priority_mode            CHOICES fixed incr decr list
                                            DEFAULT fixed
        -vlan_user_priority_step            RANGE   0-6
                                            DEFAULT 1
        -vlan_user_priority_tracking        CHOICES 0 1
        -mpls                               CHOICES enable disable
        -mpls_bottom_stack_bit              LIST_OF_LISTS_NO_TYPE_CHECK
        -mpls_bottom_stack_bit_mode         CHOICES fixed incr decr list
                                            DEFAULT fixed
        -mpls_bottom_stack_bit_step         NUMERIC
                                            DEFAULT 1
        -mpls_bottom_stack_bit_count        NUMERIC
        -mpls_bottom_stack_bit_tracking     CHOICES 0 1
        -mpls_exp_bit                       LIST_OF_LISTS_NO_TYPE_CHECK
                                            DEFAULT 0
        -mpls_exp_bit_mode                  CHOICES fixed incr decr list
                                            DEFAULT fixed
        -mpls_exp_bit_step                  RANGE   1-6
                                            DEFAULT 1
        -mpls_exp_bit_count                 RANGE   1-8
                                            DEFAULT 1
        -mpls_exp_bit_tracking              CHOICES 0 1
        -mpls_labels                        LIST_OF_LISTS_NO_TYPE_CHECK
        -mpls_labels_mode                   CHOICES fixed incr decr list
                                            DEFAULT fixed
        -mpls_labels_step                   NUMERIC
                                            DEFAULT 1
        -mpls_labels_count                  NUMERIC
                                            DEFAULT 1
        -mpls_labels_tracking               CHOICES 0 1
        -mpls_ttl                           LIST_OF_LISTS_NO_TYPE_CHECK
                                            DEFAULT 64
        -mpls_ttl_mode                      CHOICES fixed incr decr list
                                            DEFAULT fixed
        -mpls_ttl_step                      RANGE   0-254
                                            DEFAULT 1
        -mpls_ttl_count                     RANGE   1-256
                                            DEFAULT 1
        -mpls_ttl_tracking                  CHOICES 0 1 }
    
    set opt_args_l3_ipv4_noqos {
        -ip_dst_addr                        IP
        -ip_dst_count                       RANGE   1-2147483647
        -ip_dst_mode                        CHOICES fixed increment decrement 
                                            CHOICES random emulation list
        -ip_dst_step                        IP
        -ip_dst_tracking                    CHOICES 0 1
        -ip_fragment                        CHOICES 0 1
        -ip_fragment_mode                   CHOICES fixed list
                                            DEFAULT fixed
        -ip_fragment_tracking               CHOICES 0 1
        -ip_fragment_last                   CHOICES more last 0 1
        -ip_fragment_last_mode              CHOICES fixed list
                                            DEFAULT fixed
        -ip_fragment_last_tracking          CHOICES 0 1
        -ip_fragment_offset                 RANGE   0-8191
        -ip_fragment_offset_count           NUMERIC
                                            DEFAULT 1
        -ip_fragment_offset_mode            CHOICES fixed incr decr list
                                            DEFAULT fixed
        -ip_fragment_offset_step            RANGE   0-8190
                                            DEFAULT 1
        -ip_fragment_offset_tracking        CHOICES 0 1
        -ip_id                              RANGE   0-65535
        -ip_id_count                        NUMERIC
                                            DEFAULT 1
        -ip_id_mode                         CHOICES fixed incr decr list
                                            DEFAULT fixed
        -ip_id_step                         RANGE   0-65534
                                            DEFAULT 1
        -ip_id_tracking                     CHOICES 0 1
        -ip_length_override                 CHOICES 0 1
        -ip_length_override_mode            CHOICES fixed list
                                            DEFAULT fixed
        -ip_length_override_tracking        CHOICES 0 1
        -ip_protocol                        RANGE   0-255
        -ip_protocol_count                  NUMERIC
                                            DEFAULT 1
        -ip_protocol_mode                   CHOICES fixed incr decr list
                                            DEFAULT fixed
        -ip_protocol_step                   RANGE   0-254
                                            DEFAULT 1
        -ip_protocol_tracking               CHOICES 0 1
        -ip_reserved                        CHOICES 0 1
        -ip_reserved_mode                   CHOICES fixed list
                                            DEFAULT fixed
        -ip_reserved_tracking               CHOICES 0 1
        -ip_src_addr                        IP
        -ip_src_count                       RANGE   1-2147483647
        -ip_src_mode                        CHOICES fixed increment decrement 
                                            CHOICES random emulation list
        -ip_src_step                        IP
        -ip_src_tracking                    CHOICES 0 1
        -ip_total_length                    RANGE   0-65535
        -ip_total_length_count              NUMERIC
                                            DEFAULT 1
        -ip_total_length_mode               CHOICES fixed incr decr list auto
                                            DEFAULT fixed
        -ip_total_length_step               RANGE   0-65534
                                            DEFAULT 1
        -ip_total_length_tracking           CHOICES 0 1
        -ip_ttl                             RANGE   0-255
        -ip_ttl_count                       NUMERIC
                                            DEFAULT 1
        -ip_ttl_mode                        CHOICES fixed incr decr list
                                            DEFAULT fixed
        -ip_ttl_step                        RANGE   0-254
                                            DEFAULT 1
        -ip_ttl_tracking                    CHOICES 0 1
        -ip_checksum                        NUMERIC
        -ip_checksum_count                  NUMERIC
                                            DEFAULT 1
        -ip_checksum_mode                   CHOICES fixed incr decr list
        -ip_checksum_step                   NUMERIC
                                            DEFAULT 1
        -ip_checksum_tracking               CHOICES 0 1
        -ip_hdr_length                      NUMERIC
        -ip_hdr_length_count                NUMERIC
                                            DEFAULT 1
        -ip_hdr_length_mode                 CHOICES fixed incr decr list
                                            DEFAULT fixed
        -ip_hdr_length_step                 NUMERIC
                                            DEFAULT 1
        -ip_hdr_length_tracking             CHOICES 0 1 }
    
    set opt_args_l3_ipv4_qos {
        -qos_type_ixn                  ANY
        -qos_value_ixn                 ANY
        -qos_value_ixn_mode            CHOICES fixed incr decr list
                                       DEFAULT fixed
        -qos_value_ixn_step            NUMERIC
                                       DEFAULT 1
        -qos_value_ixn_count           NUMERIC
                                       DEFAULT 1
        -qos_value_ixn_tracking        CHOICES 0 1
        -ip_precedence                 RANGE   0-7
        -ip_precedence_count           NUMERIC
                                       DEFAULT 1
        -ip_precedence_mode            CHOICES fixed incr decr list
                                       DEFAULT fixed
        -ip_precedence_step            RANGE   0-6
                                       DEFAULT 1
        -ip_precedence_tracking        CHOICES 0 1
        -ip_delay                      CHOICES 0 1
        -ip_delay_mode                 CHOICES fixed list
                                       DEFAULT fixed
        -ip_delay_tracking             CHOICES 0 1
        -ip_throughput                 CHOICES 0 1
        -ip_throughput_mode            CHOICES fixed list
                                       DEFAULT fixed
        -ip_throughput_tracking        CHOICES 0 1
        -ip_reliability                CHOICES 0 1
        -ip_reliability_mode           CHOICES fixed list
                                       DEFAULT fixed
        -ip_reliability_tracking       CHOICES 0 1
        -ip_cost                       CHOICES 0 1
        -ip_cost_mode                  CHOICES fixed list
                                       DEFAULT fixed
        -ip_cost_tracking              CHOICES 0 1
        -ip_dscp                       RANGE   0-63
        -ip_dscp_count                 NUMERIC
                                       DEFAULT 1
        -ip_dscp_mode                  CHOICES fixed incr decr list
                                       DEFAULT fixed
        -ip_dscp_step                  RANGE   0-62
                                       DEFAULT 1
        -ip_dscp_tracking              CHOICES 0 1
        -ip_cu                         RANGE   0-3
        -ip_cu_count                   NUMERIC
                                       DEFAULT 1
        -ip_cu_mode                    CHOICES fixed incr decr list
                                       DEFAULT fixed
        -ip_cu_step                    RANGE   0-2
                                       DEFAULT 1
        -ip_cu_tracking                CHOICES 0 1
        -qos_byte                      RANGE   0-127
        -qos_byte_count                NUMERIC
                                       DEFAULT 1
        -qos_byte_mode                 CHOICES fixed incr decr list
                                       DEFAULT fixed
        -qos_byte_step                 RANGE   0-126
                                       DEFAULT 1
        -qos_byte_tracking             CHOICES 0 1
        -data_tos                      RANGE   0-127
        -data_tos_count                NUMERIC
                                       DEFAULT 1
        -data_tos_mode                 CHOICES fixed incr decr list
                                       DEFAULT fixed
        -data_tos_step                 RANGE   0-126
                                       DEFAULT 1
        -data_tos_tracking             CHOICES 0 1 }
    
    set opt_args_l3_ipv6 {
        -ipv6_auth_payload_len                      ANY
                                                    DEFAULT 2
        -ipv6_auth_payload_len_count                NUMERIC
                                                    DEFAULT 1
        -ipv6_auth_payload_len_mode                 CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_auth_payload_len_step                 RANGE   0-254
                                                    DEFAULT 1
        -ipv6_auth_payload_len_tracking             CHOICES 0 1
        -ipv6_auth_seq_num                          ANY
                                                    DEFAULT 0
        -ipv6_auth_seq_num_count                    NUMERIC
                                                    DEFAULT 1
        -ipv6_auth_seq_num_mode                     CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_auth_seq_num_step                     REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
                                                    DEFAULT 1
        -ipv6_auth_seq_num_tracking                 CHOICES 0 1
        -ipv6_auth_spi                              ANY
                                                    DEFAULT 0
        -ipv6_auth_spi_count                        NUMERIC
                                                    DEFAULT 1
        -ipv6_auth_spi_mode                         CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_auth_spi_step                         REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
                                                    DEFAULT 1
        -ipv6_auth_spi_tracking                     CHOICES 0 1
        -ipv6_auth_type                             CHOICES md5 sha1
                                                    DEFAULT md5
        -ipv6_auth_string                           ANY
                                                    DEFAULT 00:00:00:00
        -ipv6_auth_string_count                     NUMERIC
                                                    DEFAULT 1
        -ipv6_auth_string_mode                      CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_auth_string_step                      ANY
                                                    DEFAULT 1
        -ipv6_auth_string_tracking                  CHOICES 0 1
        -ipv6_auth_md5sha1_string                   ANY
                                                    DEFAULT 00:00:00:00
        -ipv6_auth_md5sha1_string_count             NUMERIC
                                                    DEFAULT 1
        -ipv6_auth_md5sha1_string_mode              CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_auth_md5sha1_string_step              ANY
                                                    DEFAULT 1
        -ipv6_auth_md5sha1_string_tracking          CHOICES 0 1
        -ipv6_auth_next_header                      RANGE   0-255
        -ipv6_auth_next_header_count                NUMERIC
                                                    DEFAULT 1
        -ipv6_auth_next_header_mode                 CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_auth_next_header_step                 RANGE   0-254
                                                    DEFAULT 1
        -ipv6_auth_next_header_tracking             CHOICES 0 1
        -ipv6_auth_reserved                         REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
                                                    DEFAULT 0
        -ipv6_auth_reserved_count                   NUMERIC
                                                    DEFAULT 1
        -ipv6_auth_reserved_mode                    CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_auth_reserved_step                    REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
                                                    DEFAULT 1
        -ipv6_auth_reserved_tracking                CHOICES 0 1
        -ipv6_auth_padding                          HEX
                                                    DEFAULT 0
        -ipv6_auth_padding_count                    NUMERIC
                                                    DEFAULT 1
        -ipv6_auth_padding_mode                     CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_auth_padding_step                     HEX
                                                    DEFAULT 1
        -ipv6_auth_padding_tracking                 CHOICES 0 1
        -ipv6_dst_addr                              IP
        -ipv6_dst_count                             RANGE   1-2147483647
        -ipv6_dst_mask                              RANGE   0-128
        -ipv6_dst_mode                              CHOICES fixed increment decrement list incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group random
        -ipv6_dst_tracking                          CHOICES 0 1
        -ipv6_dst_step                              IPV6
        -ipv6_extension_header                      CHOICES none hop_by_hop routing 
                                                    CHOICES destination authentication 
                                                    CHOICES fragment encapsulation
                                                    CHOICES pseudo
        -ipv6_flow_label                            RANGE   0-1048575
        -ipv6_flow_label_count                      NUMERIC
                                                    DEFAULT 1
        -ipv6_flow_label_mode                       CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_flow_label_step                       RANGE   0-1048574
                                                    DEFAULT 1
        -ipv6_flow_label_tracking                   CHOICES 0 1
        -ipv6_frag_id                               ANY
        -ipv6_frag_id_count                         NUMERIC
                                                    DEFAULT 1    
        -ipv6_frag_id_mode                          CHOICES fixed incr decr list
                                                    DEFAULT fixed    
        -ipv6_frag_id_step                          RANGE   0-4294967294
                                                    DEFAULT 1
        -ipv6_frag_id_tracking                      CHOICES 0 1  
        -ipv6_frag_more_flag                        ANY
                                                    DEFAULT 0
        -ipv6_frag_more_flag_mode                   CHOICES fixed list
                                                    DEFAULT fixed    
        -ipv6_frag_more_flag_tracking               CHOICES 0 1
        -ipv6_frag_offset                           ANY
                                                    DEFAULT 100
        -ipv6_frag_offset_count                     NUMERIC
                                                    DEFAULT 1    
        -ipv6_frag_offset_mode                      CHOICES fixed incr decr list
                                                    DEFAULT fixed    
        -ipv6_frag_offset_step                      RANGE   0-8190   
                                                    DEFAULT 1     
        -ipv6_frag_offset_tracking                  CHOICES 0 1
        -ipv6_frag_res_2bit                         ANY
                                                    DEFAULT 3
        -ipv6_frag_res_2bit_count                   NUMERIC
                                                    DEFAULT 1    
        -ipv6_frag_res_2bit_mode                    CHOICES fixed incr decr list
                                                    DEFAULT fixed    
        -ipv6_frag_res_2bit_step                    RANGE   0-2  
                                                    DEFAULT 1    
        -ipv6_frag_res_2bit_tracking                CHOICES 0 1  
        -ipv6_frag_res_8bit                         ANY
        -ipv6_frag_res_8bit_count                   NUMERIC  
        -ipv6_frag_res_8bit_mode                    CHOICES fixed incr decr list
        -ipv6_frag_res_8bit_step                    RANGE   0-254
        -ipv6_frag_res_8bit_tracking                CHOICES 0 1
        -ipv6_routing_node_list                     ANY
        -ipv6_hop_by_hop_options                    ANY
        -ipv6_hop_limit                             RANGE   0-255
        -ipv6_hop_limit_count                       NUMERIC
                                                    DEFAULT 1
        -ipv6_hop_limit_mode                        CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_hop_limit_step                        RANGE   0-254
                                                    DEFAULT 1
        -ipv6_hop_limit_tracking                    CHOICES 0 1
        -ipv6_routing_res                           ANY
                                                    DEFAULT 00:00:00:00
        -ipv6_routing_res_count                     NUMERIC
                                                    DEFAULT 1    
        -ipv6_routing_res_mode                      CHOICES fixed incr decr list
                                                    DEFAULT fixed    
        -ipv6_routing_res_step                      ANY
                                                    DEFAULT 1    
        -ipv6_routing_res_tracking                  CHOICES 0 1  
        -ipv6_routing_type                          RANGE 0-255
        -ipv6_routing_type_count                    NUMERIC
                                                    DEFAULT 1
        -ipv6_routing_type_mode                     CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_routing_type_step                     RANGE 0-254
                                                    DEFAULT 1
        -ipv6_routing_type_tracking                 CHOICES 0 1
        -ipv6_src_addr                              IP
        -ipv6_src_count                             RANGE   1-2147483647
        -ipv6_src_mask                              RANGE   0-128
        -ipv6_src_mode                              CHOICES fixed increment decrement list incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group random
        -ipv6_src_step                              IPV6
        -ipv6_src_tracking                          CHOICES 0 1
        -ipv6_traffic_class                         RANGE   0-255
        -ipv6_traffic_class_count                   NUMERIC
                                                    DEFAULT 1
        -ipv6_traffic_class_mode                    CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_traffic_class_step                    RANGE   0-254
                                                    DEFAULT 1
        -ipv6_traffic_class_tracking                CHOICES 0 1
        -qos_ipv6_flow_label                        RANGE   0-1048575
        -qos_ipv6_traffic_class                     RANGE   0-255
        -ipv6_flow_version                          RANGE   0-15
        -ipv6_flow_version_count                    NUMERIC
                                                    DEFAULT 1
        -ipv6_flow_version_mode                     CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_flow_version_step                     RANGE   0-14
                                                    DEFAULT 1
        -ipv6_flow_version_tracking                 CHOICES 0 1
        -ipv6_next_header                           RANGE   0-255
        -ipv6_next_header_count                     NUMERIC
                                                    DEFAULT 1
        -ipv6_next_header_mode                      CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_next_header_step                      RANGE   0-254
                                                    DEFAULT 1
        -ipv6_next_header_tracking                  CHOICES 0 1
        -ipv6_encap_spi                             RANGE   0-4294967295
        -ipv6_encap_spi_count                       NUMERIC
                                                    DEFAULT 1
        -ipv6_encap_spi_mode                        CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_encap_spi_step                        RANGE   0-4294967294
                                                    DEFAULT 1
        -ipv6_encap_spi_tracking                    CHOICES 0 1
        -ipv6_encap_seq_number                      REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
                                                    DEFAULT 0x0
        -ipv6_encap_seq_number_count                NUMERIC
                                                    DEFAULT 1
        -ipv6_encap_seq_number_mode                 CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_encap_seq_number_step                 REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
                                                    DEFAULT 0x1
        -ipv6_encap_seq_number_tracking             CHOICES 0 1
        -ipv6_pseudo_dst_addr                       IPV6
                                                    DEFAULT 0::0
        -ipv6_pseudo_dst_addr_count                 NUMERIC
                                                    DEFAULT 1
        -ipv6_pseudo_dst_addr_mode                  CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_pseudo_dst_addr_step                  IPV6
                                                    DEFAULT 0::1
        -ipv6_pseudo_dst_addr_tracking              CHOICES 0 1
        -ipv6_pseudo_src_addr                       IPV6
                                                    DEFAULT 0::0
        -ipv6_pseudo_src_addr_count                 NUMERIC
                                                    DEFAULT 1
        -ipv6_pseudo_src_addr_mode                  CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_pseudo_src_addr_step                  IPV6
                                                    DEFAULT 0::1
        -ipv6_pseudo_src_addr_tracking              CHOICES 0 1
        -ipv6_pseudo_uppper_layer_pkt_length        RANGE   0-4294967295
                                                    DEFAULT 0
        -ipv6_pseudo_uppper_layer_pkt_length_count  NUMERIC
                                                    DEFAULT 1
        -ipv6_pseudo_uppper_layer_pkt_length_mode   CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_pseudo_uppper_layer_pkt_length_step   RANGE   0-4294967294
                                                    DEFAULT 1
        -ipv6_pseudo_uppper_layer_pkt_length_tracking    CHOICES 0 1
        -ipv6_pseudo_zero_number                    REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
                                                    DEFAULT 0x0
        -ipv6_pseudo_zero_number_count              NUMERIC
                                                    DEFAULT 1
        -ipv6_pseudo_zero_number_mode               CHOICES fixed incr decr list
                                                    DEFAULT fixed
        -ipv6_pseudo_zero_number_step               REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
                                                    DEFAULT 0x1
        -ipv6_pseudo_zero_number_tracking           CHOICES 0 1 }
    
    set opt_args_l3_arp {
        -arp_dst_hw_addr                         MAC
        -arp_dst_hw_count                        NUMERIC
        -arp_dst_hw_mode                         CHOICES fixed increment decrement list
        -arp_dst_hw_step                         MAC
        -arp_dst_hw_tracking                     CHOICES 0 1
        -arp_src_hw_addr                         MAC
        -arp_src_hw_count                        NUMERIC
        -arp_src_hw_mode                         CHOICES fixed increment decrement list
        -arp_src_hw_step                         MAC
        -arp_src_hw_tracking                     CHOICES 0 1
        -arp_operation                           CHOICES arpRequest arpReply
                                                 CHOICES rarpRequest
                                                 CHOICES rarpReply
                                                 CHOICES unknown
        -arp_operation_mode                      CHOICES fixed list
        -arp_operation_tracking                  CHOICES 0 1
        -arp_hw_type                             REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -arp_hw_type_count                       NUMERIC
        -arp_hw_type_mode                        CHOICES fixed incr decr list
        -arp_hw_type_step                        REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -arp_hw_type_tracking                    CHOICES 0 1
        -arp_protocol_type                       REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -arp_protocol_type_count                 NUMERIC
        -arp_protocol_type_mode                  CHOICES fixed incr decr list
        -arp_protocol_type_step                  REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -arp_protocol_type_tracking              CHOICES 0 1
        -arp_hw_address_length                   REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -arp_hw_address_length_count             NUMERIC
        -arp_hw_address_length_mode              CHOICES fixed incr decr list
        -arp_hw_address_length_step              REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -arp_hw_address_length_tracking          CHOICES 0 1
        -arp_protocol_addr_length                REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -arp_protocol_addr_length_count          NUMERIC
        -arp_protocol_addr_length_mode           CHOICES fixed incr decr list
        -arp_protocol_addr_length_step           REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -arp_protocol_addr_length_tracking       CHOICES 0 1
        -arp_dst_protocol_addr                   IP
        -arp_dst_protocol_addr_count             NUMERIC
        -arp_dst_protocol_addr_mode              CHOICES fixed incr decr list
        -arp_dst_protocol_addr_step              IP
        -arp_dst_protocol_addr_tracking          CHOICES 0 1
        -arp_src_protocol_addr                   IP
        -arp_src_protocol_addr_count             NUMERIC
        -arp_src_protocol_addr_mode              CHOICES fixed incr decr list
        -arp_src_protocol_addr_step              IP
        -arp_src_protocol_addr_tracking          CHOICES 0 1 }
    
    set opt_args_l4_icmp {
        -icmp_type                                         RANGE   0-255
        -icmp_type_count                                   NUMERIC
        -icmp_type_mode                                    CHOICES fixed incr decr list
        -icmp_type_step                                    RANGE   0-254
        -icmp_type_tracking                                CHOICES 0 1
        -icmp_code                                         RANGE   0-255
        -icmp_code_count                                   NUMERIC
        -icmp_code_mode                                    CHOICES fixed incr decr list
        -icmp_code_step                                    RANGE   0-254
        -icmp_code_tracking                                CHOICES 0 1
        -icmp_id                                           RANGE   0-65535
        -icmp_id_count                                     NUMERIC
        -icmp_id_mode                                      CHOICES fixed incr decr list
        -icmp_id_step                                      RANGE   0-65534
        -icmp_id_tracking                                  CHOICES 0 1
        -icmp_seq                                          RANGE   0-65535
        -icmp_seq_count                                    NUMERIC
        -icmp_seq_mode                                     CHOICES fixed incr decr list
        -icmp_seq_step                                     RANGE   0-65534
        -icmp_seq_tracking                                 CHOICES 0 1
        -icmp_pkt_too_big_mtu                              RANGE   0-4294967295
        -icmp_pkt_too_big_mtu_count                        NUMERIC
        -icmp_pkt_too_big_mtu_mode                         CHOICES fixed incr decr list
        -icmp_pkt_too_big_mtu_step                         RANGE   0-4294967294
        -icmp_pkt_too_big_mtu_tracking                     CHOICES 0 1
        -icmp_param_problem_message_pointer                RANGE   0-4294967295
        -icmp_param_problem_message_pointer_count          NUMERIC
        -icmp_param_problem_message_pointer_mode           CHOICES fixed incr decr list
        -icmp_param_problem_message_pointer_step           RANGE   0-4294967294
        -icmp_param_problem_message_pointer_tracking       CHOICES 0 1
        -icmp_max_response_delay_ms                        RANGE   0-65535
        -icmp_max_response_delay_ms_count                  NUMERIC
        -icmp_max_response_delay_ms_mode                   CHOICES fixed incr decr list
        -icmp_max_response_delay_ms_step                   RANGE   0-65534
        -icmp_max_response_delay_ms_tracking               CHOICES 0 1
        -icmp_multicast_address                            IPV6
        -icmp_multicast_address_count                      NUMERIC
        -icmp_multicast_address_mode                       CHOICES fixed incr decr list
        -icmp_multicast_address_step                       IPV6
        -icmp_multicast_address_tracking                   CHOICES 0 1
        -icmp_mc_query_v2_s_flag                           CHOICES 0 1
        -icmp_mc_query_v2_s_flag_mode                      CHOICES fixed list
        -icmp_mc_query_v2_s_flag_tracking                  CHOICES 0 1
        -icmp_mc_query_v2_robustness_var                   RANGE   0-7
        -icmp_mc_query_v2_robustness_var_count             NUMERIC
        -icmp_mc_query_v2_robustness_var_mode              CHOICES fixed incr decr list
        -icmp_mc_query_v2_robustness_var_step              RANGE   0-6
        -icmp_mc_query_v2_robustness_var_tracking          CHOICES 0 1
        -icmp_mc_query_v2_interval_code                    REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -icmp_mc_query_v2_interval_code_count              NUMERIC
        -icmp_mc_query_v2_interval_code_mode               CHOICES fixed incr decr list
        -icmp_mc_query_v2_interval_code_step               REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -icmp_mc_query_v2_interval_code_tracking           CHOICES 0 1
        -icmp_ndp_ram_hop_limit                            RANGE   0-255
        -icmp_ndp_ram_hop_limit_count                      NUMERIC
        -icmp_ndp_ram_hop_limit_mode                       CHOICES fixed incr decr list
        -icmp_ndp_ram_hop_limit_step                       RANGE   0-254
        -icmp_ndp_ram_hop_limit_tracking                   CHOICES 0 1
        -icmp_ndp_ram_m_flag                               CHOICES 0 1
        -icmp_ndp_ram_m_flag_mode                          CHOICES fixed list
        -icmp_ndp_ram_m_flag_tracking                      CHOICES 0 1
        -icmp_ndp_ram_o_flag                               CHOICES 0 1
        -icmp_ndp_ram_o_flag_mode                          CHOICES fixed list
        -icmp_ndp_ram_o_flag_tracking                      CHOICES 0 1
        -icmp_ndp_ram_h_flag                               CHOICES 0 1
        -icmp_ndp_ram_h_flag_mode                          CHOICES fixed list
        -icmp_ndp_ram_h_flag_tracking                      CHOICES 0 1
        -icmp_ndp_ram_router_lifetime                      RANGE   0-65535
        -icmp_ndp_ram_router_lifetime_count                NUMERIC
        -icmp_ndp_ram_router_lifetime_mode                 CHOICES fixed incr decr list
        -icmp_ndp_ram_router_lifetime_step                 RANGE   0-65534
        -icmp_ndp_ram_router_lifetime_tracking             CHOICES 0 1
        -icmp_ndp_ram_reachable_time                       RANGE   0-4294967295
        -icmp_ndp_ram_reachable_time_count                 NUMERIC
        -icmp_ndp_ram_reachable_time_mode                  CHOICES fixed incr decr list
        -icmp_ndp_ram_reachable_time_step                  RANGE   0-4294967294
        -icmp_ndp_ram_reachable_time_tracking              CHOICES 0 1
        -icmp_ndp_ram_retransmit_timer                     RANGE   0-4294967295
        -icmp_ndp_ram_retransmit_timer_count               NUMERIC
        -icmp_ndp_ram_retransmit_timer_mode                CHOICES fixed incr decr list
        -icmp_ndp_ram_retransmit_timer_step                RANGE   0-4294967294
        -icmp_ndp_ram_retransmit_timer_tracking            CHOICES 0 1
        -icmp_target_addr                                  IPV6
        -icmp_target_addr_count                            NUMERIC
        -icmp_target_addr_mode                             CHOICES fixed incr decr list
        -icmp_target_addr_step                             IPV6
        -icmp_target_addr_tracking                         CHOICES 0 1
        -icmp_ndp_nam_r_flag                               CHOICES 0 1
        -icmp_ndp_nam_r_flag_mode                          CHOICES fixed list
        -icmp_ndp_nam_r_flag_tracking                      CHOICES 0 1
        -icmp_ndp_nam_s_flag                               CHOICES 0 1
        -icmp_ndp_nam_s_flag_mode                          CHOICES fixed list
        -icmp_ndp_nam_s_flag_tracking                      CHOICES 0 1
        -icmp_ndp_nam_o_flag                               CHOICES 0 1
        -icmp_ndp_nam_o_flag_mode                          CHOICES fixed list
        -icmp_ndp_nam_o_flag_tracking                      CHOICES 0 1
        -icmp_ndp_rm_dest_addr                             IPV6
        -icmp_ndp_rm_dest_addr_count                       NUMERIC
        -icmp_ndp_rm_dest_addr_mode                        CHOICES fixed incr decr list
        -icmp_ndp_rm_dest_addr_step                        IPV6
        -icmp_ndp_rm_dest_addr_tracking                    CHOICES 0 1
        -icmp_mobile_pam_m_bit                             CHOICES 0 1
        -icmp_mobile_pam_m_bit_mode                        CHOICES fixed list
        -icmp_mobile_pam_m_bit_tracking                    CHOICES 0 1
        -icmp_mobile_pam_o_bit                             CHOICES 0 1
        -icmp_mobile_pam_o_bit_mode                        CHOICES fixed list
        -icmp_mobile_pam_o_bit_tracking                    CHOICES 0 1
        -icmp_unused                                       REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
        -icmp_unused_count                                 NUMERIC
        -icmp_unused_mode                                  CHOICES fixed incr decr list
        -icmp_unused_step                                  REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
        -icmp_unused_tracking                              CHOICES 0 
        -icmp_checksum                                     REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -icmp_checksum_count                               NUMERIC
        -icmp_checksum_mode                                CHOICES fixed incr decr list
        -icmp_checksum_step                                REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -icmp_checksum_tracking                            CHOICES 0 1 }
    
    set opt_args_l4_gre {
        -gre_checksum_enable                CHOICES 0 1
        -gre_checksum_enable_mode           CHOICES fixed list
        -gre_checksum_enable_tracking       CHOICES 0 1
        -gre_key_enable                     CHOICES 0 1
        -gre_key_enable_mode                CHOICES fixed list
        -gre_key_enable_tracking            CHOICES 0 1
        -gre_seq_enable                     CHOICES 0 1
        -gre_seq_enable_mode                CHOICES fixed list
        -gre_seq_enable_tracking            CHOICES 0 1
        -gre_reserved0                      REGEXP  (^[0-9a-fA-F]{1,3}$)|(^0x[0-9a-fA-F]{1,3})
        -gre_reserved0_step                 REGEXP  (^[0-9a-fA-F]{1,3}$)|(^0x[0-9a-fA-F]{1,3})
        -gre_reserved0_mode                 CHOICES fixed incr decr list
        -gre_reserved0_count                NUMERIC
        -gre_reserved0_tracking             CHOICES 0 1
        -gre_version                        RANGE   0-7
        -gre_version_step                   RANGE   0-6
        -gre_version_mode                   CHOICES fixed incr decr list
        -gre_version_count                  NUMERIC
        -gre_version_tracking               CHOICES 0 1
        -inner_protocol                     CHOICES ipv4 ipv6 none
                                            HEX
        -inner_protocol_step                HEX
        -inner_protocol_mode                CHOICES fixed incr decr
        -inner_protocol_count               NUMERIC
        -inner_protocol_tracking            CHOICES 0 1
        -gre_checksum                       REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -gre_checksum_step                  REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -gre_checksum_mode                  CHOICES fixed incr decr list
        -gre_checksum_count                 NUMERIC
        -gre_checksum_tracking              CHOICES 0 1
        -gre_reserved1                      REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -gre_reserved1_step                 REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -gre_reserved1_mode                 CHOICES fixed incr decr list
        -gre_reserved1_count                NUMERIC
        -gre_reserved1_tracking             CHOICES 0 1
        -gre_key                            REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
        -gre_key_step                       REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
        -gre_key_mode                       CHOICES fixed incr decr list
        -gre_key_count                      NUMERIC
        -gre_key_tracking                   CHOICES 0 1
        -gre_seq_number                     REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
        -gre_seq_number_step                REGEXP  (^[0-9a-fA-F]{1,8}$)|(^0x[0-9a-fA-F]{1,8})
        -gre_seq_number_mode                CHOICES fixed incr decr list
        -gre_seq_number_count               NUMERIC
        -gre_seq_number_tracking            CHOICES 0 1
        -inner_ip_dst_addr                  IPV4
        -inner_ip_dst_count                 RANGE   1-2147483647
        -inner_ip_dst_mode                  CHOICES fixed increment decrement random list
        -inner_ip_dst_step                  IPV4
        -inner_ip_dst_tracking              CHOICES 0 1
        -inner_ip_src_addr                  IPV4
        -inner_ip_src_count                 NUMERIC
        -inner_ip_src_mode                  CHOICES fixed increment decrement random list
        -inner_ip_src_step                  IPV4
        -inner_ip_src_tracking              CHOICES 0 1
        -inner_ipv6_dst_addr                IPV6
        -inner_ipv6_dst_count               RANGE   1-2147483647
        -inner_ipv6_dst_mode                CHOICES fixed increment decrement incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group random list
        -inner_ipv6_dst_step                IPV6
        -inner_ipv6_dst_tracking            CHOICES 0 1
        -inner_ipv6_flow_label              RANGE   0-1048575
        -inner_ipv6_flow_label_count        NUMERIC
        -inner_ipv6_flow_label_mode         CHOICES fixed incr decr list
        -inner_ipv6_flow_label_step         RANGE   0-1048574
        -inner_ipv6_flow_label_tracking     CHOICES 0 1
        -inner_ipv6_frag_id                 RANGE   0-4294967295
        -inner_ipv6_frag_id_mode            CHOICES fixed incr decr list
        -inner_ipv6_frag_id_step            RANGE   0-4294967294
        -inner_ipv6_frag_id_count           NUMERIC
        -inner_ipv6_frag_id_tracking        CHOICES 0 1
        -inner_ipv6_frag_more_flag          CHOICES 0 1
        -inner_ipv6_frag_more_flag_mode     CHOICES fixed list
        -inner_ipv6_frag_more_flag_tracking CHOICES 0 1
        -inner_ipv6_frag_offset             RANGE   0-8191
        -inner_ipv6_frag_offset_count       NUMERIC
        -inner_ipv6_frag_offset_mode        CHOICES fixed incr decr list
        -inner_ipv6_frag_offset_step        RANGE   0-8190
        -inner_ipv6_frag_offset_tracking    CHOICES 0 1
        -inner_ipv6_hop_limit               RANGE   0-255
        -inner_ipv6_hop_limit_count         NUMERIC
        -inner_ipv6_hop_limit_mode          CHOICES fixed incr decr list
        -inner_ipv6_hop_limit_step          RANGE   0-254
        -inner_ipv6_hop_limit_tracking      CHOICES 0 1
        -inner_ipv6_traffic_class           RANGE   0-255
        -inner_ipv6_traffic_class_count     NUMERIC
        -inner_ipv6_traffic_class_mode      CHOICES fixed incr decr list
        -inner_ipv6_traffic_class_step      RANGE   0-254
        -inner_ipv6_traffic_class_tracking  CHOICES 0 1
        -inner_ipv6_src_addr                IPV6
        -inner_ipv6_src_count               RANGE   1-2147483647
        -inner_ipv6_src_mode                CHOICES fixed increment decrement incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group random list
        -inner_ipv6_src_step                IPV6
        -inner_ipv6_src_tracking            CHOICES 0 1 
        -inner_ipv6_dst_mask                RANGE   0-128
        -inner_ipv6_src_mask                RANGE   0-128 }

    set opt_args_l4_udp {
        -udp_checksum                       CHOICES 0 1
                                            DEFAULT 1
        -udp_checksum_value                 REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -udp_checksum_value_tracking        CHOICES 0 1
        -udp_dst_port                       RANGE   0-65535
        -udp_dst_port_count                 NUMERIC
        -udp_dst_port_mode                  CHOICES fixed incr decr list
        -udp_dst_port_step                  RANGE   0-65534
        -udp_dst_port_tracking              CHOICES 0 1
        -udp_src_port                       RANGE   0-65535
        -udp_src_port_count                 NUMERIC
        -udp_src_port_mode                  CHOICES fixed incr decr list
        -udp_src_port_step                  RANGE   0-65534
        -udp_src_port_tracking              CHOICES 0 1
        -udp_length                         RANGE   0-65535
        -udp_length_count                   NUMERIC
        -udp_length_mode                    CHOICES fixed incr decr list
        -udp_length_step                    RANGE   0-65534
        -udp_length_tracking                CHOICES 0 1 }
    
    set opt_args_l4_dhcp {
        -dhcp_boot_filename
        -dhcp_boot_filename_tracking        CHOICES 0 1
        -dhcp_client_hw_addr                REGEXP  ^([A-Fa-f0-9]{2,2}[ .:])*([A-Fa-f0-9]{2,2})$
        -dhcp_client_hw_addr_count          NUMERIC
        -dhcp_client_hw_addr_mode           CHOICES fixed incr decr list
        -dhcp_client_hw_addr_step           REGEXP  ^([A-Fa-f0-9]{2,2}[ .:])*([A-Fa-f0-9]{2,2})$
        -dhcp_client_hw_addr_tracking       CHOICES 0 1
        -dhcp_client_ip_addr                IP
        -dhcp_client_ip_addr_count          NUMERIC
        -dhcp_client_ip_addr_mode           CHOICES fixed incr decr list
        -dhcp_client_ip_addr_step           IP
        -dhcp_client_ip_addr_tracking       CHOICES 0 1
        -dhcp_flags                         CHOICES broadcast no_broadcast
        -dhcp_flags_mode                    CHOICES fixed list
        -dhcp_flags_tracking                CHOICES 0 1
        -dhcp_hops                          NUMERIC
        -dhcp_hops_count                    NUMERIC
        -dhcp_hops_mode                     CHOICES fixed incr decr list
        -dhcp_hops_step                     NUMERIC
        -dhcp_hops_tracking                 CHOICES 0 1
        -dhcp_hw_len                        NUMERIC
        -dhcp_hw_len_count                  NUMERIC
        -dhcp_hw_len_mode                   CHOICES fixed incr decr list
        -dhcp_hw_len_step                   NUMERIC
        -dhcp_hw_len_tracking               CHOICES 0 1
        -dhcp_hw_type                       RANGE   1-21
        -dhcp_hw_type_count                 NUMERIC
        -dhcp_hw_type_mode                  CHOICES fixed incr decr list
        -dhcp_hw_type_step                  NUMERIC
        -dhcp_hw_type_tracking              CHOICES 0 1
        -dhcp_operation_code                CHOICES reply request
        -dhcp_operation_code_mode           CHOICES fixed list
        -dhcp_operation_code_tracking       CHOICES 0 1
        -dhcp_relay_agent_ip_addr           IP
        -dhcp_relay_agent_ip_addr_count     NUMERIC
        -dhcp_relay_agent_ip_addr_mode      CHOICES fixed incr decr list
        -dhcp_relay_agent_ip_addr_step      IP
        -dhcp_relay_agent_ip_addr_tracking  CHOICES 0 1
        -dhcp_seconds                       NUMERIC
        -dhcp_seconds_count                 NUMERIC
        -dhcp_seconds_mode                  CHOICES fixed incr decr list
        -dhcp_seconds_step                  NUMERIC
        -dhcp_seconds_tracking              CHOICES 0 1
        -dhcp_server_host_name              REGEXP ^.+$
        -dhcp_server_host_name_tracking     CHOICES 0 1
        -dhcp_server_ip_addr                IP
        -dhcp_server_ip_addr_count          NUMERIC
        -dhcp_server_ip_addr_mode           CHOICES fixed incr decr list
        -dhcp_server_ip_addr_step           IP
        -dhcp_server_ip_addr_tracking       CHOICES 0 1
        -dhcp_transaction_id                RANGE  0-65535
        -dhcp_transaction_id_count          NUMERIC
        -dhcp_transaction_id_mode           CHOICES fixed incr decr list
        -dhcp_transaction_id_step           RANGE  0-65534
        -dhcp_transaction_id_tracking       CHOICES 0 1
        -dhcp_your_ip_addr                  IP
        -dhcp_your_ip_addr_count            NUMERIC
        -dhcp_your_ip_addr_mode             CHOICES fixed incr decr list
        -dhcp_your_ip_addr_step             IP
        -dhcp_your_ip_addr_tracking         CHOICES 0 1
        -dhcp_magic_cookie                  REGEXP  (^[0-9a-fA-F]{1,32}$)|(^0x[0-9a-fA-F]{1,32})
        -dhcp_magic_cookie_count            NUMERIC
        -dhcp_magic_cookie_mode             CHOICES fixed incr decr list
        -dhcp_magic_cookie_step             REGEXP  (^[0-9a-fA-F]{1,32}$)|(^0x[0-9a-fA-F]{1,32})
        -dhcp_magic_cookie_tracking         CHOICES 0 1 
        -dhcp_option
        -dhcp_option_data   }
        
    set opt_args_l4_rip {
        -rip_version                        CHOICES 1 2
        -rip_command                        CHOICES request response trace_on
                                            CHOICES trace_off reserved
        -rip_command_mode                   CHOICES fixed list
        -rip_command_tracking               CHOICES 0 1
        -rip_unused                         RANGE  0-65535
        -rip_unused_count                   NUMERIC
        -rip_unused_mode                    CHOICES fixed incr decr list
        -rip_unused_step                    RANGE  0-65534
        -rip_unused_tracking                CHOICES 0 1
        -rip_rte_addr_family_id             REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -rip_rte_addr_family_id_count       NUMERIC
        -rip_rte_addr_family_id_mode        CHOICES fixed incr decr list
        -rip_rte_addr_family_id_step        REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -rip_rte_addr_family_id_tracking    CHOICES 0 1
        -rip_rte_v1_unused2                 RANGE  0-65535
        -rip_rte_v1_unused2_count           NUMERIC
        -rip_rte_v1_unused2_mode            CHOICES fixed incr decr
        -rip_rte_v1_unused2_step            RANGE  0-65534
        -rip_rte_v1_unused2_tracking        CHOICES 0 1
        -rip_rte_ipv4_addr                  IP
        -rip_rte_ipv4_addr_count            NUMERIC
        -rip_rte_ipv4_addr_mode             CHOICES fixed incr decr
        -rip_rte_ipv4_addr_step             IP
        -rip_rte_ipv4_addr_tracking         CHOICES 0 1
        -rip_rte_v1_unused3                 RANGE  0-4294967295
        -rip_rte_v1_unused3_count           NUMERIC
        -rip_rte_v1_unused3_mode            CHOICES fixed incr decr
        -rip_rte_v1_unused3_step            RANGE  0-4294967294
        -rip_rte_v1_unused3_tracking        CHOICES 0 1
        -rip_rte_v1_unused4                 RANGE  0-4294967295
        -rip_rte_v1_unused4_count           NUMERIC
        -rip_rte_v1_unused4_mode            CHOICES fixed incr decr
        -rip_rte_v1_unused4_step            RANGE  0-4294967294
        -rip_rte_v1_unused4_tracking        CHOICES 0 1
        -rip_rte_metric                     RANGE  0-4294967295
        -rip_rte_metric_count               NUMERIC
        -rip_rte_metric_mode                CHOICES fixed incr decr
        -rip_rte_metric_step                RANGE  0-4294967295
        -rip_rte_metric_tracking            CHOICES 0 1
        -rip_rte_v2_route_tag               RANGE  0-65535
        -rip_rte_v2_route_tag_count         NUMERIC
        -rip_rte_v2_route_tag_mode          CHOICES fixed incr decr
        -rip_rte_v2_route_tag_step          RANGE  0-65534
        -rip_rte_v2_route_tag_tracking      CHOICES 0 1
        -rip_rte_v2_subnet_mask             IP
        -rip_rte_v2_subnet_mask_count       NUMERIC
        -rip_rte_v2_subnet_mask_mode        CHOICES fixed incr decr
        -rip_rte_v2_subnet_mask_step        IP
        -rip_rte_v2_subnet_mask_tracking    CHOICES 0 1
        -rip_rte_v2_next_hop                IP
        -rip_rte_v2_next_hop_count          NUMERIC
        -rip_rte_v2_next_hop_mode           CHOICES fixed incr decr
        -rip_rte_v2_next_hop_step           IP
        -rip_rte_v2_next_hop_tracking       CHOICES 0 1 }
        
    set opt_args_l4_igmp {
        -igmp_group_addr                    IP
        -igmp_group_count                   RANGE   0-65535
        -igmp_group_mode                    CHOICES fixed increment decrement list
        -igmp_group_step                    RANGE   0-65534
        -igmp_group_tracking                CHOICES 0 1
        -igmp_max_response_time             RANGE   0-255
        -igmp_max_response_time_count       NUMERIC
        -igmp_max_response_time_mode        CHOICES fixed incr decr list
        -igmp_max_response_time_step        RANGE   0-254
        -igmp_max_response_time_tracking    CHOICES 0 1
        -igmp_multicast_src                 ANY
        -igmp_multicast_src_count           ANY
        -igmp_multicast_src_mode            ANY
        -igmp_multicast_src_step            ANY
        -igmp_multicast_src_tracking        ANY
        -igmp_qqic                          RANGE 0-255
        -igmp_qqic_count                    NUMERIC
        -igmp_qqic_mode                     CHOICES fixed incr decr list
        -igmp_qqic_step                     RANGE 0-254
        -igmp_qqic_tracking                 CHOICES 0 1
        -igmp_qrv                           RANGE 0-7
        -igmp_qrv_count                     NUMERIC
        -igmp_qrv_mode                      CHOICES fixed incr decr list
        -igmp_qrv_step                      RANGE 0-6
        -igmp_qrv_tracking                  CHOICES 0 1
        -igmp_record_type                   CHOICES mode_is_include
                                            CHOICES mode_is_exclude
                                            CHOICES change_to_include_mode
                                            CHOICES change_to_exclude_mode
                                            CHOICES allow_new_sources
                                            CHOICES block_old_sources
        -igmp_record_type_mode              CHOICES fixed list
        -igmp_record_type_tracking          CHOICES 0 1
        -igmp_s_flag                        CHOICES 0 1
        -igmp_s_flag_mode                   CHOICES fixed list
        -igmp_s_flag_tracking               CHOICES 0 1
        -igmp_type                          CHOICES membership_query
                                            CHOICES membership_report
                                            CHOICES leave_group dvmrp
                                            NUMERIC
        -igmp_valid_checksum                CHOICES 0 1
                                            DEFAULT 1
        -igmp_version                       CHOICES 1 2 3
        -igmp_msg_type                      CHOICES query report
        -igmp_msg_type_tracking             CHOICES 0 1
        -igmp_unused                        REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -igmp_unused_count                  NUMERIC
        -igmp_unused_mode                   CHOICES fixed incr decr list
        -igmp_unused_step                   REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -igmp_unused_tracking               CHOICES 0 1
        -igmp_checksum                      REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -igmp_checksum_count                NUMERIC
        -igmp_checksum_mode                 CHOICES fixed incr decr list
        -igmp_checksum_step                 REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -igmp_checksum_tracking             CHOICES 0 1
        -igmp_reserved_v3q                  RANGE 0-15
        -igmp_reserved_v3q_count            NUMERIC
        -igmp_reserved_v3q_mode             CHOICES fixed incr decr list
        -igmp_reserved_v3q_step             RANGE 0-14
        -igmp_reserved_v3q_tracking         CHOICES 0 1
        -igmp_reserved_v3r1                 RANGE 0-255
        -igmp_reserved_v3r1_count           NUMERIC
        -igmp_reserved_v3r1_mode            CHOICES fixed incr decr list
        -igmp_reserved_v3r1_step            RANGE 0-254
        -igmp_reserved_v3r1_tracking        CHOICES 0 1
        -igmp_reserved_v3r2                 RANGE 0-65535
        -igmp_reserved_v3r2_count           NUMERIC
        -igmp_reserved_v3r2_mode            CHOICES fixed incr decr list
        -igmp_reserved_v3r2_step            RANGE 0-65534
        -igmp_reserved_v3r2_tracking        CHOICES 0 1
        -igmp_aux_data_length               RANGE  0-255
        -igmp_aux_data_length_count         NUMERIC
        -igmp_aux_data_length_mode          CHOICES fixed incr decr list
        -igmp_aux_data_length_step          RANGE  0-254
        -igmp_aux_data_length_tracking      CHOICES 0 1
        -igmp_length_v3r                    RANGE  0-255
        -igmp_length_v3r_count              NUMERIC
        -igmp_length_v3r_mode               CHOICES fixed incr decr list
        -igmp_length_v3r_step               RANGE  0-254
        -igmp_length_v3r_tracking           CHOICES 0 1
        -igmp_data_v3r                      HEX
        -igmp_data_v3r_count                NUMERIC
        -igmp_data_v3r_mode                 CHOICES fixed incr decr list
        -igmp_data_v3r_step                 HEX
        -igmp_data_v3r_tracking             CHOICES 0 1 }
    
    set opt_args_l4_tcp {
        -tcp_ack_flag                  CHOICES 0 1
        -tcp_ack_flag_mode             CHOICES fixed list
        -tcp_ack_flag_tracking         CHOICES 0 1
        -tcp_ack_num                   RANGE   0-4294967295
        -tcp_ack_num_count             NUMERIC
        -tcp_ack_num_mode              CHOICES fixed incr decr list
        -tcp_ack_num_step              RANGE   0-4294967294
        -tcp_ack_num_tracking          CHOICES 0 1
        -tcp_dst_port                  RANGE   0-65535
        -tcp_dst_port_count            NUMERIC
        -tcp_dst_port_mode             CHOICES fixed incr decr list
        -tcp_dst_port_step             RANGE   0-65534
        -tcp_dst_port_tracking         CHOICES 0 1
        -tcp_fin_flag                  CHOICES 0 1
        -tcp_fin_flag_mode             CHOICES fixed list
        -tcp_fin_flag_tracking         CHOICES 0 1
        -tcp_psh_flag                  CHOICES 0 1
        -tcp_psh_flag_mode             CHOICES fixed list
        -tcp_psh_flag_tracking         CHOICES 0 1
        -tcp_rst_flag                  CHOICES 0 1
        -tcp_rst_flag_mode             CHOICES fixed list
        -tcp_rst_flag_tracking         CHOICES 0 1
        -tcp_seq_num                   RANGE   0-4294967295
        -tcp_seq_num_count             NUMERIC
        -tcp_seq_num_mode              CHOICES fixed incr decr list
        -tcp_seq_num_step              RANGE   0-4294967295
        -tcp_seq_num_tracking          CHOICES 0 1
        -tcp_src_port                  RANGE   0-65535
        -tcp_src_port_count            NUMERIC
        -tcp_src_port_mode             CHOICES fixed incr decr list
        -tcp_src_port_step             RANGE   0-65534
        -tcp_src_port_tracking         CHOICES 0 1
        -tcp_syn_flag                  CHOICES 0 1
        -tcp_syn_flag_mode             CHOICES fixed list
        -tcp_syn_flag_tracking         CHOICES 0 1
        -tcp_urgent_ptr                RANGE   0-65535
        -tcp_urgent_ptr_count          NUMERIC
        -tcp_urgent_ptr_mode           CHOICES fixed incr decr list
        -tcp_urgent_ptr_step           RANGE   0-65534
        -tcp_urgent_ptr_tracking       CHOICES 0 1
        -tcp_urg_flag                  CHOICES 0 1
        -tcp_urg_flag_mode             CHOICES fixed list
        -tcp_urg_flag_tracking         CHOICES 0 1
        -tcp_window                    RANGE   0-65535
        -tcp_window_count              NUMERIC
        -tcp_window_mode               CHOICES fixed incr decr list
        -tcp_window_step               RANGE   0-65534
        -tcp_window_tracking           CHOICES 0 1
        -tcp_data_offset               RANGE   0-15
        -tcp_data_offset_count         NUMERIC
        -tcp_data_offset_mode          CHOICES fixed incr decr list
        -tcp_data_offset_step          RANGE   0-15
        -tcp_data_offset_tracking      CHOICES 0 1
        -tcp_reserved                  RANGE   0-7
        -tcp_reserved_count            NUMERIC
        -tcp_reserved_mode             CHOICES fixed incr decr list
        -tcp_reserved_step             RANGE   0-6
        -tcp_reserved_tracking         CHOICES 0 1
        -tcp_ns_flag                   CHOICES 0 1
        -tcp_ns_flag_mode              CHOICES fixed list
        -tcp_ns_flag_tracking          CHOICES 0 1
        -tcp_cwr_flag                  CHOICES 0 1
        -tcp_cwr_flag_mode             CHOICES fixed list
        -tcp_cwr_flag_tracking         CHOICES 0 1
        -tcp_ecn_echo_flag             CHOICES 0 1
        -tcp_ecn_echo_flag_mode        CHOICES fixed list
        -tcp_ecn_echo_flag_tracking    CHOICES 0 1
        -tcp_checksum                  REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -tcp_checksum_count            NUMERIC
        -tcp_checksum_mode             CHOICES fixed incr decr list
        -tcp_checksum_step             REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -tcp_checksum_tracking         CHOICES 0 1 }

    set opt_args_routine_specific {
        -atm_header_encapsulation           CHOICES vcc_mux_ipv4_routed
                                            CHOICES vcc_mux_bridged_eth_fcs
                                            CHOICES vcc_mux_bridged_eth_no_fcs
                                            CHOICES vcc_mux_ipv6_routed
                                            CHOICES vcc_mux_mpls_routed
                                            CHOICES llc_routed_clip
                                            CHOICES llc_bridged_eth_fcs
                                            CHOICES llc_bridged_eth_no_fcs
                                            CHOICES llc_pppoa
                                            CHOICES vcc_mux_ppoa 
                                            CHOICES llc_nlpid_routed
                                            CHOICES llc_ppp
                                            CHOICES llc_routed_snap
                                            CHOICES vcc_mux_ppp
                                            CHOICES vcc_mux_routed
        -mode                               CHOICES create modify remove reset 
                                            CHOICES enable disable append_header modify_or_insert
                                            CHOICES prepend_header replace_header
                                            CHOICES dynamic_update
                                            CHOICES get_available_protocol_templates
                                            CHOICES get_available_fields get_field_values set_field_values
                                            CHOICES add_field_level remove_field_level
                                            CHOICES get_available_dynamic_update_fields
                                            CHOICES get_available_session_aware_traffic
                                            CHOICES get_available_fields_for_link 
        -handle
        -is_raw_item                        CHOICES 0 1
                                            DEFAULT 1
        -l2_encap                           CHOICES atm_vc_mux
                                            CHOICES atm_vc_mux_ethernet_ii
                                            CHOICES atm_vc_mux_802.3snap
                                            CHOICES atm_snap_802.3snap_nofcs
                                            CHOICES atm_vc_mux_ppp
                                            CHOICES atm_vc_mux_pppoe
                                            CHOICES atm_snap
                                            CHOICES atm_snap_ethernet_ii
                                            CHOICES atm_snap_802.3snap
                                            CHOICES atm_vc_mux_802.3snap_nofcs
                                            CHOICES atm_snap_ppp
                                            CHOICES atm_snap_pppoe
                                            CHOICES hdlc_unicast
                                            CHOICES hdlc_broadcast
                                            CHOICES hdlc_unicast_mpls
                                            CHOICES hdlc_multicast_mpls
                                            CHOICES ethernet_ii
                                            CHOICES ethernet_ii_unicast_mpls
                                            CHOICES ethernet_ii_multicast_mpls
                                            CHOICES ethernet_ii_vlan
                                            CHOICES ethernet_ii_vlan_unicast_mpls
                                            CHOICES ethernet_ii_vlan_multicast_mpls
                                            CHOICES ethernet_ii_pppoe
                                            CHOICES ethernet_ii_vlan_pppoe
                                            CHOICES ppp_link
                                            CHOICES ietf_framerelay
                                            CHOICES cisco_framerelay
        -l3_protocol                        CHOICES ipv4 ipv6 arp pause_control 
                                            CHOICES ipx
        -l4_protocol                        CHOICES icmp igmp ggp ip st tcp ucl 
                                            CHOICES egp igp bbn_rcc_mon nvp_ii 
                                            CHOICES pup argus emcon xnet chaos 
                                            CHOICES udp mux dcn_meas hmp prm 
                                            CHOICES xns_idp trunk_1 trunk_2 
                                            CHOICES leaf_1 leaf_2 rdp irtp 
                                            CHOICES iso_tp4 netblt mfe_nsp 
                                            CHOICES merit_inp sep cftp
                                            CHOICES sat_expak mit_subnet rvd 
                                            CHOICES ippc sat_mon ipcv 
                                            CHOICES br_sat_mon wb_mon wb_expak 
                                            CHOICES rip dhcp gre ospf
    }
    
    set opt_args_dyn_framesize {
        -handle
        -frame_size                         RANGE   12-13312
        -frame_size_max                     RANGE   12-13312
        -frame_size_min                     RANGE   12-13312
        -length_mode                        CHOICES fixed increment random auto 
                                            CHOICES imix gaussian quad 
                                            CHOICES distribution
                                            DEFAULT fixed
    }
    
    set opt_args_dyn_rate {
        -handle
        -rate_bps
        -rate_kbps
        -rate_mbps
        -rate_percent                       RANGE   0-100
        -rate_pps
        -inter_frame_gap                    NUMERIC
        -inter_frame_gap_unit               CHOICES bytes ns
        -enforce_min_gap                    NUMERIC
    }
    
    set opt_args_global {
        -global_dest_mac_retry_count               RANGE   1-2147483647
        -global_dest_mac_retry_delay               RANGE   1-2147483647
        -enable_data_integrity                     CHOICES 0 1
        -global_enable_dest_mac_retry              CHOICES 0 1
        -global_enable_min_frame_size              CHOICES 0 1
        -global_enable_staggered_transmit          CHOICES 0 1
        -global_enable_stream_ordering             CHOICES 0 1
        -global_stream_control                     CHOICES continuous iterations
        -global_stream_control_iterations          RANGE   1-2147483647
        -global_large_error_threshhold             NUMERIC
        -global_enable_mac_change_on_fly           CHOICES 0 1
        -global_max_traffic_generation_queries     NUMERIC
        -global_mpls_label_learning_timeout        NUMERIC
        -global_refresh_learned_info_before_apply  CHOICES 0 1
        -global_use_tx_rx_sync                     CHOICES 0 1
        -global_wait_time                          RANGE   1-2147483647
        -global_display_mpls_current_label_value   CHOICES 0 1
        -global_frame_ordering                     CHOICES flow_group_setup none peak_loading rfc2889
        -global_peak_loading_replication_count     NUMERIC
    }
    
    set opt_args_l2vpn_traffic {
        -atm_range_count         
        -vpi_increment_step      
        -vci_increment_step      
        -pvc_count_step          
        -vci_increment           
        -vpi_increment           
        -pvc_count               
        -fr_range_count          
        -dlci_value_step         
        -dlci_repeat_count_step  
        -dlci_value              
        -dlci_count_mode         
        -dlci_repeat_count       
        -ip_range_count          
        -ip_dst_range_step       
        -ip_dst_prefix_len_step  
        -ip_dst_increment_step   
        -ip_dst_count_step       
        -intf_handle
        -ip_dst_prefix_len       
        -ip_dst_increment        
        -lan_range_count         
        -indirect                
        -range_per_spoke         
        -mac_dst_count_step      
        -site_id_step            
        -vlan_enable             
        -site_id_enable          
        -site_id                 
    }
    
    set opt_args_not_implemented {
        -atm_counter_vci_mask_select
        -atm_counter_vpi_mask_select
        -atm_header_aal5error
        -atm_header_cell_loss_priority
        -atm_header_cpcs_length
        -atm_header_enable_auto_vpi_vci
        -atm_header_enable_cl
        -atm_header_enable_cpcs_length
        -atm_header_generic_flow_ctrl
        -atm_header_hec_errors
        -enable_auto_detect_instrumentation
        -enable_time_stamp
        -enable_pgid
        -integrity_signature 
        -mpls_type
    }
    
    set opt_args_l3_ipv4 "$opt_args_l3_ipv4_noqos $opt_args_l3_ipv4_qos"
    
    set opt_args_pt {
        -pt_handle
        -header_handle
        -field_handle
        -field_activeFieldChoice
        -field_auto
        -field_countValue
        -field_fieldValue
        -field_fullMesh
        -field_optionalEnabled
        -field_singleValue
        -field_startValue
        -field_stepValue
        -field_trackingEnabled
        -field_valueList
        -field_valueType
    }
    
    set opt_args_quick_flows {
        -enable_udf1
        -enable_udf2
        -enable_udf3
        -enable_udf4
        -enable_udf5
        -table_udf_column_name
        -table_udf_column_offset
        -table_udf_column_size
        -table_udf_column_type
        -table_udf_rows
        -udf1_cascade_type
        -udf1_chain_from
        -udf1_counter_init_value
        -udf1_counter_mode
        -udf1_counter_repeat_count
        -udf1_counter_step
        -udf1_counter_type
        -udf1_counter_up_down
        -udf1_enable_cascade
        -udf1_inner_repeat_count
        -udf1_inner_repeat_value
        -udf1_inner_step
        -udf1_mask_select
        -udf1_mask_val
        -udf1_mode
        -udf1_offset
        -udf1_skip_mask_bits
        -udf1_skip_zeros_and_ones
        -udf1_value_list
        -udf2_cascade_type
        -udf2_chain_from
        -udf2_counter_init_value
        -udf2_counter_mode
        -udf2_counter_repeat_count
        -udf2_counter_step
        -udf2_counter_type
        -udf2_counter_up_down
        -udf2_enable_cascade
        -udf2_inner_repeat_count
        -udf2_inner_repeat_value
        -udf2_inner_step
        -udf2_mask_select
        -udf2_mask_val
        -udf2_mode
        -udf2_offset
        -udf2_skip_mask_bits
        -udf2_skip_zeros_and_ones
        -udf2_value_list
        -udf3_cascade_type
        -udf3_chain_from
        -udf3_counter_init_value
        -udf3_counter_mode
        -udf3_counter_repeat_count
        -udf3_counter_step
        -udf3_counter_type
        -udf3_counter_up_down
        -udf3_enable_cascade
        -udf3_inner_repeat_count
        -udf3_inner_repeat_value
        -udf3_inner_step
        -udf3_mask_select
        -udf3_mask_val
        -udf3_mode
        -udf3_offset
        -udf3_skip_mask_bits
        -udf3_skip_zeros_and_ones
        -udf3_value_list
        -udf4_cascade_type
        -udf4_chain_from
        -udf4_counter_init_value
        -udf4_counter_mode
        -udf4_counter_repeat_count
        -udf4_counter_step
        -udf4_counter_type
        -udf4_counter_up_down
        -udf4_enable_cascade
        -udf4_inner_repeat_count
        -udf4_inner_repeat_value
        -udf4_inner_step
        -udf4_mask_select
        -udf4_mask_val
        -udf4_mode
        -udf4_offset
        -udf4_skip_mask_bits
        -udf4_skip_zeros_and_ones
        -udf4_value_list
        -udf5_cascade_type
        -udf5_chain_from
        -udf5_counter_init_value
        -udf5_counter_mode
        -udf5_counter_repeat_count
        -udf5_counter_step
        -udf5_counter_type
        -udf5_counter_up_down
        -udf5_enable_cascade
        -udf5_inner_repeat_count
        -udf5_inner_repeat_value
        -udf5_inner_step
        -udf5_mask_select
        -udf5_mask_val
        -udf5_mode
        -udf5_offset
        -udf5_skip_mask_bits
        -udf5_skip_zeros_and_ones
        -udf5_value_list
    }
     
    set opt_args_dynamic_fields {
        -dynamic_update_fields CHOICES ppp ppp_dst dhcp4 dhcp4_dst dhcp6 dhcp6_dst mpls_label_value
        -session_aware_traffic CHOICES ppp dhcp4 dhcp6
    }
     
    set opt_args_l47_traffic {
        -app_profile_type                    CHOICES FTP_CS_3K
                                            CHOICES FTP_SU_100
                                            CHOICES FTP_SU_MultiIterations
                                            CHOICES FTP_TM_20MB
                                            CHOICES FTP_TR_3K
                                            CHOICES HTTP_1.0/TCP_7500_Conncurrent_Connections
                                            CHOICES HTTP_1.0/TCP_Connection_Rate_2000
                                            CHOICES HTTP_1.0_Simulate_400_Users
                                            CHOICES HTTP_1.0_SU_MultiIteration
                                            CHOICES HTTP_1.0_Transaction_Rate_2000
                                            CHOICES HTTP1.1_7500_Concurrent_Connections
                                            CHOICES HTTP_1.1_Simulate_400_Users
                                            CHOICES HTTP_1.1_SU_MultiIterations
                                            CHOICES HTTP_1.1_TM_20MB
                                            CHOICES HTTP_1.1_Transaction_Rate_11000
                                            CHOICES HTTP_1.0/SSL/TCP_500_Concurrent_Connections
                                            CHOICES HTTP_1.1/SSL_Transaction_Rate_300
                                            CHOICES HTTP_FTP_SMTP_IMAP
                                            CHOICES IMAP_CC_4000
                                            CHOICES IMAP_CR_800
                                            CHOICES IMAP_SU_400
                                            CHOICES IMAP_SU_4000
                                            CHOICES IMAP_TM_6MB
                                            CHOICES IMAP_TR_3000
                                            CHOICES IMAP_TR_MultiIteration
                                            CHOICES TriplePlay
                                            CHOICES POP3_Simulate_4000_Users
                                            CHOICES POP3_SU_MultiIterations
                                            CHOICES RTSP_Simulate_500_Users
                                            CHOICES RTSP_SU_MultiIterations
                                            CHOICES SIP_TCP_SU
                                            CHOICES SIP_TCP_TR
                                            CHOICES SIP_UDP_SU
                                            CHOICES SIP_UDP_TR
                                            CHOICES SMTP_Simulate_1000_Users
                                            CHOICES SMTP_SU_MultiIterations
                                            CHOICES TELNET_CC_250
                                            CHOICES TELNET_CR_35
                                            CHOICES TELNET_SU_100
                                            CHOICES TELNET_SU_200
                                            CHOICES TELNET_SU_MultiIteration
                                            CHOICES TELNET_TR_150
                                            CHOICES TELNET_TR_MultiIterations
                                            CHOICES VIDEO_MultiIterations
                                            CHOICES VIDEO_PlayMedia_Custom
                                            CHOICES VIDEO_PlayMedia_EnableMSS
                                            CHOICES VIDEO_PlayMedia_Quicktimeplayer
                                            CHOICES VIDEO_RealPayLoad
                                            CHOICES VIDEO_SU_200
                                            CHOICES VIDEO_Syntheticpayload
        -ramp_up_percentage                    NUMERIC
        -test_objective_value               NUMERIC
        -num_dst_ports                        NUMERIC
        -use_all_ip_subnets                 CHOICES 0 1
                                            DEFAULT 1
    }

        
    set opt_args ""
        
    set opt_args_list {
        opt_args_frame_size         opt_args_common         opt_args_instrumentation
        opt_args_ratecontrol        opt_args_tracking       opt_args_atm_l1
        opt_args_l2_ethernet        opt_args_l3_ipv4        opt_args_l3_ipv6
        opt_args_l3_arp             opt_args_l4_icmp        opt_args_l4_gre
        opt_args_l4_udp             opt_args_l4_dhcp        opt_args_l4_rip
        opt_args_l4_igmp            opt_args_l4_tcp         opt_args_pt
        opt_args_global             opt_args_quick_flows    opt_args_l2vpn_traffic
        opt_args_l47_traffic        opt_args_dynamic_fields
    }
        
    foreach specific_opt_args $opt_args_list {
        append opt_args [set $specific_opt_args]
        append $specific_opt_args $opt_args_routine_specific
    }
    
    append opt_args_l3_arp $opt_args_l3_ipv4_noqos
    
    append opt_args $opt_args_not_implemented
        
    append opt_args "\n"
        
    set man_args $man_args_common
        
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }   
    
    if {[info exists app_profile_type]} {
        # Legacy Application feature was removed from IxNetwork
        keylset returnList status $::FAILURE
        keylset returnList log "Legacy Application Traffic was deprecated. Please use L4-7 AppLibrary Traffic parameters instead."
        return $returnList
    }
    
    # If rate_mode is different than the default value we must unset all other
    # rate_ parameters
    if {$rate_mode != "first_option_provided" && [info exists "rate_$rate_mode"]} {
        set rate_list [list rate_bps rate_kbps rate_mbps rate_byteps \
                            rate_kbyteps rate_mbyteps rate_percent rate_pps]
        foreach rate_item $rate_list {
            if {$rate_item != "rate_$rate_mode"} {
                catch {unset $rate_item}
            }
        }
    }
    
    # Upvar to get the arrays for scalable sources/destinations
    # IMPORTANT NOTE: 
    # This uses upvar 2 because parse_dashed_args is only called in 
    # ::ixia::540trafficConfig and we do not have the information required
    # to upvar in the parent execution context
    set input_name_list [list \
        emulation_scalable_dst_handle \
        emulation_scalable_dst_port_start \
        emulation_scalable_dst_port_count \
        emulation_scalable_dst_intf_start \
        emulation_scalable_dst_intf_count \
        emulation_scalable_src_handle \
        emulation_scalable_src_port_start \
        emulation_scalable_src_port_count \
        emulation_scalable_src_intf_start \
        emulation_scalable_src_intf_count]
    set output_name_list [list \
        arg_emulation_scalable_dst_handle \
        arg_emulation_scalable_dst_port_start \
        arg_emulation_scalable_dst_port_count \
        arg_emulation_scalable_dst_intf_start \
        arg_emulation_scalable_dst_intf_count \
        arg_emulation_scalable_src_handle \
        arg_emulation_scalable_src_port_start \
        arg_emulation_scalable_src_port_count \
        arg_emulation_scalable_src_intf_start \
        arg_emulation_scalable_src_intf_count]
    foreach input_var_name $input_name_list output_var_name $output_name_list {
        if {[info exists $input_var_name]} {
            set array_name [set $input_var_name]
            upvar 2 $array_name $output_var_name
        }
    }
    
    
    # BUG703174: The previous HLT version required
    # "-vlan enable" in order to use any of the 
    # vlan parameters. If any of the vlan parameters is given 
    # the vlan will be enabled if it has a value different from "disable"
    set vlan_param_list [list   vlan_cfi    \
            vlan_cfi_count                  \
            vlan_cfi_mode                   \
            vlan_cfi_step                   \
            vlan_cfi_tracking               \
            vlan_id                         \
            vlan_id_count                   \
            vlan_id_mode                    \
            vlan_id_step                    \
            vlan_id_tracking                \
            vlan_protocol_tag_id            \
            vlan_protocol_tag_id_count      \
            vlan_protocol_tag_id_mode       \
            vlan_protocol_tag_id_step       \
            vlan_protocol_tag_id_tracking   \
            vlan_user_priority              \
            vlan_user_priority_count        \
            vlan_user_priority_mode         \
            vlan_user_priority_step         \
            vlan_user_priority_tracking     \
    ]
    
    keylset returnList status $::SUCCESS
    
    if {[info exists traffic_generate]} {
        set 540IxNetTrafficGenerate $traffic_generate
    }
    
    set ::ixia::skip_return_handles $skip_return_handles
    
    # Do basic verifications
    set init_args_540_ports ""
    if {[info exists port_handle]} {
        lappend init_args_540_ports $port_handle
    }
    if {[info exists port_handle2]} {
        lappend init_args_540_ports $port_handle2
    }
    
    if {[llength $init_args_540_ports] > 0} {
        set retCode [540IxNetInit $init_args_540_ports]
    } else {
        set retCode [540IxNetInit]
    }
    if {[keylget retCode status] != $::SUCCESS} {
        return $retCode
    }
    
    # Translation arrays for dynamic updates fields and sesssion aware traffic
    array set dynamic_updates_fields_map {
        ppp                 ppp
		ppp_dst				pppDst
		dhcp4				dhcpv4
		dhcp4_dst			dhcpv4Dst
		dhcp6				dhcpv6
		dhcp6_dst 			dhcpv6Dst
        mpls_label_value    _mplsLabelValue
        _mplsLabelValue     mpls_label_value
    }
    array set session_aware_traffic_map {
        ppp                 ppp
		dhcp4				dhcpv4
		dhcp6				dhcpv6
    }
    
    array set transmit_distribution_map {
        b_dest_mac                                                                                          macInMacBDestAddress
        b_src_mac                                                                                           macInMacBSrcAddress
        b_vlan                                                                                              macInMacVlanId
        c_dest_mac                                                                                          macInMacCDestAddress
        c_src_mac                                                                                           macInMacCSrcAddress
        c_vlan                                                                                              macInMacVlanId
        dest_ip                                                                                             ipv4DestIp
        dest_mac                                                                                            ethernetIiDestinationaddress
        ethernet_ii_ether_type                                                                              ethernetIiEtherType
        ethernet_ii_pfc_queue                                                                               ethernetIiPfcQueue
        fcoe_cs_ctl                                                                                         fcoeCsCtl
        fcoe_dest_id                                                                                        fcoeDestId
        fcoe_ox_id                                                                                          fcoeOxId
        fcoe_src_id                                                                                         fcoeSrcId
        fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority                             fipFlogiLsAcc(fcf)FipFlogiDescriptorFibreChannelCsCtlPriority
        fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_did                                         fipFlogiLsAcc(fcf)FipFlogiDescriptorFibreChannelDId
        fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_ox_id                                       fipFlogiLsAcc(fcf)FipFlogiDescriptorFibreChannelOxId
        fip_flogi_ls_acc_fcf_fip_flogi_descriptor_fibre_channel_sid                                         fipFlogiLsAcc(fcf)FipFlogiDescriptorFibreChannelSId
        fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_cs_ctl_priority                             fipFlogiLsRjt(fcf)FipFlogiDescriptorFibreChannelCsCtlPriority
        fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_did                                         fipFlogiLsRjt(fcf)FipFlogiDescriptorFibreChannelDId
        fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_ox_id                                       fipFlogiLsRjt(fcf)FipFlogiDescriptorFibreChannelOxId
        fip_flogi_ls_rjt_fcf_fip_flogi_descriptor_fibre_channel_sid                                         fipFlogiLsRjt(fcf)FipFlogiDescriptorFibreChannelSId
        fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_cs_ctl_priority                          fipFlogiRequest(enode)FipFlogiDescriptorFibreChannelCsCtlPriority
        fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_did                                      fipFlogiRequest(enode)FipFlogiDescriptorFibreChannelDId
        fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_ox_id                                    fipFlogiRequest(enode)FipFlogiDescriptorFibreChannelOxId
        fip_flogi_request_enode_fip_flogi_descriptor_fibre_channel_sid                                      fipFlogiRequest(enode)FipFlogiDescriptorFibreChannelSId
        fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority                   fipNpivFdiscLsAcc(fcf)FipNpivFdiscDescriptorFibreChannelCsCtlPriority
        fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did                               fipNpivFdiscLsAcc(fcf)FipNpivFdiscDescriptorFibreChannelDId
        fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id                             fipNpivFdiscLsAcc(fcf)FipNpivFdiscDescriptorFibreChannelOxId
        fip_npiv_fdisc_ls_acc_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid                               fipNpivFdiscLsAcc(fcf)FipNpivFdiscDescriptorFibreChannelSId
        fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority                   fipNpivFdiscLsRjt(fcf)FipNpivFdiscDescriptorFibreChannelCsCtlPriority
        fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_did                               fipNpivFdiscLsRjt(fcf)FipNpivFdiscDescriptorFibreChannelDId
        fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_ox_id                             fipNpivFdiscLsRjt(fcf)FipNpivFdiscDescriptorFibreChannelOxId
        fip_npiv_fdisc_ls_rjt_fcf_fip_npiv_fdisc_descriptor_fibre_channel_sid                               fipNpivFdiscLsRjt(fcf)FipNpivFdiscDescriptorFibreChannelSId
        fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_cs_ctl_priority                fipNpivFdiscRequest(enode)FipNpivFdiscDescriptorFibreChannelCsCtlPriority
        fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_did                            fipNpivFdiscRequest(enode)FipNpivFdiscDescriptorFibreChannelDId
        fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_ox_id                          fipNpivFdiscRequest(enode)FipNpivFdiscDescriptorFibreChannelOxId
        fip_npiv_fdisc_request_enode_fip_npiv_fdisc_descriptor_fibre_channel_sid                            fipNpivFdiscRequest(enode)FipNpivFdiscDescriptorFibreChannelSId
        frame_size                                                                                          frameSize
        i_tag_isid                                                                                          macInMacISid
        inner_vlan                                                                                          vlanVlanId
        ipv4_dest_ip                                                                                        ipv4DestIp
        ipv4_precedence                                                                                     ipv4Precedence
        ipv4_source_ip                                                                                      ipv4SourceIp
        ipv6_dest_ip                                                                                        ipv6DestIp
        ipv6_flow_label                                                                                     ipv6Flowlabel
        ipv6_flowlabel                                                                                      ipv6Flowlabel
        ipv6_source_ip                                                                                      ipv6SourceIp
        ipv6_trafficclass                                                                                   ipv6Trafficclass
        l2tpv2_data_message_tunnel_id                                                                       l2tpv2DataMessageTunnelId
        mac_in_mac_priority                                                                                 macInMacPriority
        mac_in_mac_v42_bdest_address                                                                        macInMacV42BDestAddress
        mac_in_mac_v42_bsrc_address                                                                         macInMacV42BSrcAddress
        mac_in_mac_v42_btag_pcp                                                                             macInMacV42BtagPcp
        mac_in_mac_v42_cdest_address                                                                        macInMacV42CDestAddress
        mac_in_mac_v42_csrc_address                                                                         macInMacV42CSrcAddress
        mac_in_mac_v42_isid                                                                                 macInMacV42ISid
        mac_in_mac_v42_priority                                                                             macInMacV42Priority
        mac_in_mac_v42_stag_pcp                                                                             macInMacV42STagPcp
        mac_in_mac_v42_stag_vlan_id                                                                         macInMacV42STagVlanId
        mac_in_mac_v42_vlan_id                                                                              macInMacV42VlanId
        mac_in_mac_vlan_user_priority                                                                       macInMacVlanUserPriority
        mpls_label                                                                                          mplsMplsLabelValue
        mpls_mpls_exp                                                                                       mplsMplsExp
        mpls_flow_descriptor                                                                                mplsFlowDescriptor
        pppoe_session_sessionid                                                                             pppoeSessionSessionid
        rx_port                                                                                             rxPort
        s_vlan                                                                                              macInMacVlanId
        source_ip                                                                                           ipv4SourceIp
        endpoint_pair                                                                                       srcDestEndpointPair
        src_mac                                                                                             ethernetIiSourceaddress
        tcp_tcp_dst_prt                                                                                     tcpTcpDstPrt
        tcp_tcp_src_prt                                                                                     tcpTcpSrcPrt
        tos                                                                                                 ipv4Precedence
        udp_udp_dst_prt                                                                                     udpUdpDstPrt
        udp_udp_src_prt                                                                                     udpUdpSrcPrt
        vlan_vlan_user_priority                                                                             vlanVlanUserPriority
        assured_forwarding_phb                                                                              ipv4AssuredForwardingPhb
        class_selector_phb                                                                                  ipv4ClassSelectorPhb
        default_phb                                                                                         ipv4DefaultPhb
        expedited_forwarding_phb                                                                            ipv4ExpeditedForwardingPhb
        raw_priority                                                                                        ipv4Raw
    }
    
    if {$mode == "reset"} {
        foreach name [ixNet getList [ixNet getRoot]/traffic trafficItem] {
            ixNet remove $name
            set current_streamid 0
        }
        if {[info exists port_handle]} {
            foreach ph $port_handle {
                set result [ixNetworkGetPortObjref $ph]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the port object\
                            reference associated to the $ph port\
                            handle while trying to reset the static\
                            endpoints - [keylget result log]."
                    return $returnList
                } else {
                    set protocol_objref \
                            [keylget result vport_objref]/protocols/static
                }
                foreach endpoint_type {atm fr ip lan} {
                    set endpoint_list \
                            [ixNet getList $protocol_objref $endpoint_type]
                    foreach endpoint $endpoint_list {
                        ixNet remove $endpoint
                    }
                }
            }
            
        }
        debug "ixNet commit"
        ixNet commit
        set current_streamid 0
        keylset returnList status $::SUCCESS
        return $returnList
    }

    # If we receive a handle parameter which is a traffic item name, we should replace it with
    # the traffic item object reference
    if {[info exists stream_id] && $mode != "create"} {
        foreach stream_id_el $stream_id {
            if {![regexp {^::ixNet::OBJ-/traffic} $stream_id_el]} {
                # It's probably a traffic item name returned by stream_id key on mode create.
                # Get the actual traffic item object reference.
                set stream_id_tmp [540getTrafficItemByName $stream_id_el]
                if {$stream_id_tmp == "_none"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for -stream_id '$stream_id'. A traffic item with this\
                            name could not be found. Parameter -stream_id must be a handle\
                            returned by ::ixia::traffic_config procedure with the 'stream_id' key."
                    return $returnList
                }
                
                lappend stream_id_list $stream_id_tmp
                catch {unset stream_id_tmp}
            } else {
                lappend stream_id_list $stream_id_el
            }
         }
         set stream_id $stream_id_list
    }
    
    if {[info exists mode] && $mode == "modify"} {
        # If at least one of the vlan parameters is given then the 
        # vlan parameter must be set to enable
        # Need to support stacked vlans
        if {![info exists vlan]} {
            set max_element 0
            foreach vlan_element $vlan_param_list {
                if {[info exists $vlan_element]} {
                    if {$max_element < [llength [set $vlan_element]]} {
                        set max_element [llength [set $vlan_element]]
                    }
                }
            }
            if {$max_element != 0} {
                set vlan [list]
                for {set i 0} {$i < $max_element} {incr i} {
                    lappend vlan "enable"
                }
                append args " -vlan $vlan"
            }
        }
        
        if {[info exists stream_id]} {
            # Modify traffic parameters
            set traffic_item_modify_map {
                name            name             name
            }
            set traffic_item_args ""
            foreach {hlt_param ixn_param optType} $traffic_item_modify_map {
                if {[info exists $hlt_param]} {
                    set hlt_var [set $hlt_param]
                    switch $optType {
                        name {
                            # replace all spaces and commas with underline characters
                            set hlt_var [regsub -all {[ ,]} $hlt_var _]
                            lappend traffic_item_args -$ixn_param $hlt_var
                        }
                    }
                }
            }
            if {$traffic_item_args != ""} {
                set result [ixNetworkNodeSetAttr $stream_id \
                        $traffic_item_args -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not modify the traffic attributes for: $stream_id -\
                            [keylget result log]."
                    return $returnList
                }
            }
        }
    }
    
    # Verify protocol templates section -> BEGINS
    if {$mode == "modify_or_insert"} {
        if {![info exists stream_id]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Parameter -stream_id must be provided when mode is $mode."
            return $returnList
        }

        if {[regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+)(/stack)} $stream_id stack hls]} {
            # stream_id is highLevelStream/stack
            set stackList [ixNet getList $hls stack]
            set stackCount [llength $stackList]

            if {$stack_index <= $stackCount} {
                # if the stack_index exists => -mode modify
                set mode "modify"
            } else {
                # append_header only if stream_id is configElement/stack or highLevelStream/stack 
                # and the stack_index does not currently exist
                set mode "append_header"
            }
        } elseif {[regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+)(/stack)} $stream_id stack ce]} {
            # stream_id is configElement/stack
            set stackList [ixNet getList $ce stack]
            set stackCount [llength $stackList]
            if {$stack_index <= $stackCount} {
                # if the stack_index exists => -mode modify
                set mode "modify"
            } else {
                # append_header only if stream_id is configElement/stack or highLevelStream/stack 
                # and the stack_index does not currently exist
                set mode "append_header"
            }
        } elseif {[regexp {^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+} $stream_id ce]} {
            # stream_id is configElement
            set stackList [ixNet getList $ce stack]
            set stackCount [llength $stackList]
			if {[string first "fcs-" $stackList]} {
				incr stackCount -1
			}
            if {$stack_index <= $stackCount} {
                # if the stack_index exists => -mode modify
                set mode "modify"
            } else {
                # append_header only if stream_id is configElement or highLevelStream 
                # and the stack_index does not currently exist
                set mode "append_header"
				set stream_id [lindex $stackList end]
            }
        } else {
            # if stream_id is not configElement/stack or highLevelStream/stack +> -mode is modify
            set ret_val [540IxNetValidateObject $stream_id [list traffic_item config_element high_level_stream stack_hls stack_ce application_profile]]
            if {[keylget ret_val status] != $::SUCCESS} {
                keylset ret_val log "Invalid stream_id $stream_id for -mode $mode. It must be a traffic item, config element or high level stream\
                        handle. [keylget ret_val log]"
                return $ret_val
            }
            set mode "modify"
        }
        
        # Retrieve the last added stack for the current config element; this handle is used for scriptgen
        set get_stack_result [540IxNetGetConfigElementLastStack $stream_id]
        if {[keylget get_stack_result status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "The last stack could not be retrieved from the config element."
            return $returnList
        }
        set last_stack_key [keylget get_stack_result last_stack]
        keylset returnList last_stack $last_stack_key
    }

    if {($mode == "append_header" || $mode == "prepend_header" || $mode == "replace_header") && [info exists pt_handle] && [info exists stream_id]} {
        set alter_header 1
    } else {
        set alter_header 0
    }
    if {$mode == "get_available_protocol_templates" || $alter_header || $mode == "get_available_fields" || $mode == "get_field_values" || $mode == "set_field_values" || $mode == "add_field_level" || $mode == "remove_field_level"} {
        set pt_args ""
        set var_list_pt [getVarListFromArgs $opt_args_pt]
        if {[info exists stream_id]} {
            set handle $stream_id
        }
        foreach var_fs $var_list_pt {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend pt_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend pt_args -$var_fs $var_fs_value
                }
            }
        }

        if {[llength $pt_args] >= 0} {
            lappend pt_args -mode $mode
            if {[info exists stream_id]} {
                lappend pt_args -handle $stream_id
            }
            set pt_status [540protocolTemplates $pt_args $opt_args_pt]
            if {[keylget pt_status status] == $::FAILURE} {
                return $pt_status
            }

			if {$alter_header == 1} {
				keylset returnList last_stack [keylget pt_status handle]
			}
			
            if {![info exists handle]} {
                set handle_names_list {
                    stream_id header_handle pt_handle field_handle
                }
                foreach handle_item $handle_names_list {
                    if {[info exists $handle_item]} {
                        set handle [set $handle_item]
                        break;
                    }
                }
            }
            set ret_code ""
            if {[info exists handle]} {
                set ret_code [540IxNetTrafficReturnHandles $handle]
            }
            set ret_code [concat $ret_code $pt_status]
            # ret_code contains either a failure with status and log or success with all the return keys needed
            return $ret_code
        }
    }
    # Verify protocol templates section -> ENDS

    if {$mode != "create" && $mode != "reset"} {
        if {$version > "7.0"} {
            if {[info exists field_linked] && ![info exists stream_id]} {
                if {![regexp {::ixNet::OBJ-/traffic/trafficItem:[0-9]+/(configElement|highLevelStream):[0-9]+} $field_linked stream_id elem_type]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The -field_linked argument $field_linked is not defined correctly"
                    return $returnList
                }
            } elseif {[info exists field_linked_to] && ![info exists stream_id]} {
                if {![regexp {::ixNet::OBJ-/traffic/trafficItem:[0-9]+/(configElement|highLevelStream):[0-9]+} $field_linked_to stream_id elem_type]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The -field_linked_to argument $field_linked_to is not defined correctly"
                    return $returnList
                }
            }
        }
        if {![info exists stream_id]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -stream_id argument must be\
                    specified when the -mode argument is set to '$mode'."
            return $returnList
        }
        
        # If stream_id is a port handle ch/ca/po than this is tclHal EFM Script being run
        # with ixNetwork. For Backwards compatibility we will not return error but ignore the
        # call and print a warning
        if {[regexp -all {^[0-9]+/[0-9]+/[0-9]+$} $stream_id]} {
            puts "\nWARNING: If ::ixia::traffic_config -mode $mode was called with a -stream_id\
                        handle of an EFM stream returned by ::ixia::emulation_efm_config\
                        the call will be ignored. This is possible only with\
                        the IxTclHal implementation. This call will be ignored for backwards compatibility.\n"
            keylset returnList status $::SUCCESS
            return $returnList
        }
        
        switch -- $mode {
            "enable" -
            "disable" {
                array set action_map {enable true disable false}

                if {[ixNet getA [ixNet getRoot]/traffic -isTrafficRunning] != "false" || \
                        [ixNet getA [ixNet getRoot]/traffic -isApplicationTrafficRunning] != "false"} {
                    puts "\nWarning: Traffic is running. Trying to ${mode} traffic items while traffic is running\
                            will cause the traffic to stop!"
                }
                
                foreach stream_id_el $stream_id {
                    if {[regexp {^::ixNet::OBJ-/traffic/trafficItem:\d+$} $stream_id_el]} {
                    
                        # It's a traffic item handle. Enable/Disable it

                        set ti_obj $stream_id_el
                        
                        set retCode [ixNetworkNodeSetAttr $ti_obj \
                                [list -enabled $action_map($mode)] -commit]
                        if {[keylget retCode status] != $::SUCCESS} {
                            return $retCode
                        }
                        
                        set retCode [540IxNetTrafficGenerate $ti_obj]
                        if {[keylget retCode status] != $::SUCCESS} {
                            return $retCode
                        }
                        
                    } elseif {[regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+$)} $stream_id_el]} {
                    
                        # It's a high level stream handle. Suspend it.
                        array set action_map {enable false disable true}
                        
                        set retCode [ixNetworkNodeSetAttr $stream_id_el \
                                [list -suspend $action_map($mode)] -commit]
                        if {[keylget retCode status] != $::SUCCESS} {
                            return $retCode
                        }
                        
                    } elseif {[regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+$)} $stream_id_el]} {
                    
                        # It's a configElement handle. Can't disable or suspend it.
                        # Disable TI parent, but display warning
                        
                        set ti_obj [ixNetworkGetParentObjref $stream_id_el "trafficItem"]
                        
                        puts "\nWarning: Objects of type configElement returned with 'traffic_item' key\
                                cannot be ${mode}ed. Parent traffic item '$ti_obj' will be ${mode}ed.\n"
                        
                        
                        set retCode [ixNetworkNodeSetAttr $ti_obj \
                                [list -enabled $action_map($mode)] -commit]
                        if {[keylget retCode status] != $::SUCCESS} {
                            return $retCode
                        }
                        
                        set retCode [540IxNetTrafficGenerate $ti_obj]
                        if {[keylget retCode status] != $::SUCCESS} {
                            return $retCode
                        }
                        
                    } else {
                    
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid value '$stream_id_el' for parameter\
                                -stream_id. It must be one of the following keys returned\
                                by procedure traffic_config: stream_id, traffic_item,\
                                traffic_item.<trafficItem>.stream_ids"
                        return $returnList
                    }
                }
                    
                keylset returnList status $::SUCCESS
                return $returnList
            }
            "remove" {
                
                # It must be a traffic_item, stream_id, or stack
                
                if {[ixNet getA [ixNet getRoot]/traffic -isTrafficRunning] != "false" || \
                        [ixNet getA [ixNet getRoot]/traffic -isApplicationTrafficRunning] != "false"} {
                    puts "\nWarning: Traffic is running. Removing traffic items while traffic is running will cause the traffic to stop!"
                }
                
                if {[regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+$)} $stream_id]} {
                    
                    set ti_obj $stream_id
                    
                    # It's a high level stream handle. Suspend it.

                    set retCode [ixNetworkNodeSetAttr $ti_obj \
                            [list -suspend true] -commit]
                    if {[keylget retCode status] != $::SUCCESS} {
                        return $retCode
                    }
                    
                } elseif {[regexp {^::ixNet::OBJ-/traffic/trafficItem:\d+$} $stream_id]} {
                    
                    set ti_obj $stream_id
                    
                    # It's a traffic item handle. Remove it
                    if {[catch {ixNet remove $ti_obj} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to remove $ti_obj. Possible cause:\
                                handle was already removed. $err"
                        return $returnList
                    }
                    
                    if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to remove $ti_obj. Possible cause:\
                                handle was already removed. $err"
                        return $returnList
                    }
                    
                } elseif {[regexp {^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+$} $stream_id]} {
                    
                    # It's a configElement handle. Can't remove or suspend it.
                    # Remove TI parent, but display warning
                    
                    set ti_obj [ixNetworkGetParentObjref $stream_id "trafficItem"]
                    
                    puts "\nWarning: Objects of type configElement returned with 'traffic_item' key\
                            cannot be removed. Parent traffic item '$ti_obj' will be removed.\n"
                    
                    # It's a traffic item handle. Remove it
                    if {[catch {ixNet remove $ti_obj} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to remove $ti_obj. Possible cause:\
                                handle was already removed. $err"
                        return $returnList
                    }
                    
                    if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to remove $ti_obj. Possible cause:\
                                handle was already removed. $err"
                        return $returnList
                    }
                    
                } elseif {[regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+/stack)|((^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+/stack))} $stream_id]} {
                    
                    # It's a stack (aka header) element
                    
                    #if {[ixNet exists $stream_id] == "false"} {
                        #keylset returnList status $::FAILURE
                        #keylset returnList log "Invalid value '$stream_id' for parameter\
                        #-stream_id when mode is $mode. Handle does not exist."
                        #return $returnList
                    #}
                    
                    if {[catch {ixNet exec remove $stream_id} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to remove $stream_id. Possible cause:\
                                handle was already removed. $err."
                        return $returnList
                    }
                    
                    if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to remove $stream_id. 'ixNet commit failed with: $err"
                        return $returnList
                    }
                    
                    set retCode [540IxNetTrafficGenerate $stream_id]
                    if {[keylget retCode status] != $::SUCCESS} {
                        return $retCode
                    }
                    
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value '$stream_id' for parameter\
                            -stream_id when mode is $mode. It must be one of the following keys returned\
                            by procedure traffic_config: stream_id, traffic_item,\
                            traffic_item.<trafficItem>.stream_ids, traffic_item.<trafficItem>.headers,\
                            traffic_item.<trafficItem>.<stream_id>.headers"
                    return $returnList
                }
                
                set ret_code [540IxNetTrafficReturnHandles [ixNet getL [ixNet getRoot]traffic trafficItem]]
                # ret_code contains either a failure with status and log or success with all the return keys needed
                return $ret_code
                                
            }
            "append_header" -
            "prepend_header" -
            "replace_header" {
                if {![regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+/stack)|(^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+/stack)} $stream_id]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value '$stream_id' for parameter\
                            -stream_id when mode is $mode. It must be one of the following keys returned\
                            by procedure traffic_config: traffic_item.<trafficItem>.headers,\
                            traffic_item.<trafficItem>.<stream_id>.headers"
                    return $returnList
                }
                
                set handle $stream_id
				
                # Retrieve the last added stack for the current config element; this handle is used for scriptgen
                set get_stack_result [540IxNetGetConfigElementLastStack $handle]
                if {[keylget get_stack_result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The last stack could not be retrieved from the config element."
                    return $returnList
                } else {
                    keylset returnList last_stack [keylget get_stack_result last_stack]
                }
            }
            "modify" {
                set ret_val [540IxNetValidateObject $stream_id [list traffic_item config_element high_level_stream stack_hls stack_ce application_profile]]
                if {[keylget ret_val status] != $::SUCCESS} {
                    keylset ret_val log "Invalid stream_id $stream_id for -mode $mode. It must be a traffic item, config element or high level stream\
                            handle. [keylget ret_val log]"
                    return $ret_val
                }

                if {[keylget ret_val value] == "traffic_item"} {
                    set retrieve [540getConfigElementOrHighLevelStream $stream_id]
                    if {[keylget retrieve status] != $::SUCCESS} {
                        return $retrieve
                    }
                    set handle   [keylget retrieve handle]
                } else {
                    set handle $stream_id
                }
                set stream_id_tmp $stream_id
                removeDefaultOptionVars $opt_args $args
                set stream_id $stream_id_tmp

                # Retrieve the last added stack for the current config element; this handle is used for scriptgen
                if {[info exists stack_index]} {
                    set get_stack_result [540IxNetGetStackFromIndex $handle $stack_index]
                } else {
                    set get_stack_result [540IxNetGetConfigElementLastStack $handle]
                }
                if {[keylget get_stack_result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The last stack could not be retrieved from the config element."
                    return $returnList
                } else {
                    keylset returnList last_stack [keylget get_stack_result last_stack]
                }
            }
            "dynamic_update" {
            
                set ret_val [540IxNetValidateObject $stream_id [list traffic_item config_element high_level_stream]]
                if {[keylget ret_val status] != $::SUCCESS} {
                    keylset ret_val log "Invalid stream_id $stream_id for -mode $mode. It must be a traffic item\
                            config element or high level stream handle. [keylget ret_val log]"
                    return $ret_val
                }
                
                set handle $stream_id
                set handle_type [keylget ret_val value]
                
                if {[ixNet getA [ixNet getRoot]/traffic -isTrafficRunning] != "true" && \
                        [ixNet getA [ixNet getRoot]/traffic -isApplicationTrafficRunning] != "true"} {
                    
                    puts "\nWarning: Traffic is not running. Mode '$mode' is designed to\
                            update rate and framesize while traffic is running.\n"
                }
                
                set ret_val [540trafficGetDynamicObjects $handle $handle_type]
                if {[keylget ret_val status] != $::SUCCESS} {
                    keylset ret_val log "Could not perform dynamic update for $handle. [keylget ret_val log]"
                    return $ret_val
                }
                
                set framesize_dyn_handle_list [keylget ret_val framesize_handle]
                set rate_dyn_handle_list      [keylget ret_val rate_handle]
                
                removeDefaultOptionVars $opt_args $args
                
                foreach rate_dyn_handle $rate_dyn_handle_list {
                
                    set dyn_rate_args ""
                    
                    set var_list_dyn_rate [getVarListFromArgs $opt_args_dyn_rate]
                    foreach var_fs $var_list_dyn_rate {
                        if {[info exists $var_fs] && $var_fs != "handle"} {
                            set var_fs_value [set $var_fs]
                            if {[llength $var_fs_value]} {
                                lappend dyn_rate_args -$var_fs \{$var_fs_value\}
                            } else {
                                lappend dyn_rate_args -$var_fs $var_fs_value
                            }
                        }
                    }
                    
                    if {[llength $dyn_rate_args] > 0} {
                        
                        if {[llength $rate_dyn_handle] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error. Failed to update rate\
                                    on the fly. Object is missing: dynamicRate."
                            return $returnList
                        }
                        
                        if {[info exists rate_dyn_handle]} {
                            lappend dyn_rate_args -handle $rate_dyn_handle
                        }
                        
                        set dyn_rate_status [540trafficRateControl $dyn_rate_args $opt_args_dyn_rate]
                        if {[keylget dyn_rate_status status] != $::SUCCESS} {
                            return $dyn_rate_status
                        }
                    }
                }
                
                foreach framesize_dyn_handle $framesize_dyn_handle_list {
                    set dyn_framesize_args ""
                    
                    set var_list_dyn_framesize [getVarListFromArgs $opt_args_dyn_framesize]
                    foreach var_fs $var_list_dyn_framesize {
                        if {[info exists $var_fs] && $var_fs != "handle"} {
                            set var_fs_value [set $var_fs]
                            if {[llength $var_fs_value]} {
                                lappend dyn_framesize_args -$var_fs \{$var_fs_value\}
                            } else {
                                lappend dyn_framesize_args -$var_fs $var_fs_value
                            }
                        }
                    }
                    
                    if {[llength $dyn_framesize_args] > 0} {
                        
                        if {[llength $framesize_dyn_handle] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error. Failed to update framesize\
                                    on the fly. Object is missing: dynamicFrameSize."
                            return $returnList
                        }
                        
                        if {[info exists framesize_dyn_handle]} {
                            lappend dyn_framesize_args -handle $framesize_dyn_handle
                        }
                        
                        set dyn_framesize_status [540trafficFrameSize $dyn_framesize_args $opt_args_dyn_framesize]
                        if {[keylget dyn_framesize_status status] != $::SUCCESS} {
                            return $dyn_framesize_status
                        }
                    }
                }
                
                return $returnList
            }
            "get_available_egress_tracking_field_offset" {
                set ret_val [540IxNetValidateObject $stream_id [list traffic_item config_element high_level_stream stack_hls stack_ce]]
                if {[keylget ret_val status] != $::SUCCESS} {
                    keylset ret_val log "Invalid stream_id $stream_id for -mode $mode. It must be a traffic item,\
                            config element or high level stream handle. [keylget ret_val log]"
                    return $ret_val
                }

                if {[keylget ret_val value] == "traffic_item"} {
                    set retrieve [540getConfigElementOrHighLevelStream $stream_id]
                    if {[keylget retrieve status] != $::SUCCESS} {
                        return $retrieve
                    }
                    set handle   [keylget retrieve handle]
                } else {
                    set handle $stream_id
                }
                
                set traffic_item_objref [ixNetworkGetParentObjref $handle "trafficItem"]

                set fieldList [540trafficGetEgressTrackingFieldOffsets $traffic_item_objref]
                keylset returnList available_egress_tracking_field_offset $fieldList
                
                return $returnList
            }
            "get_available_dynamic_update_fields" {
                set ret_val [540IxNetValidateObject $stream_id [list traffic_item config_element high_level_stream stack_hls stack_ce]]
                if {[keylget ret_val status] != $::SUCCESS} {
                    keylset ret_val log "Invalid stream_id $stream_id for -mode $mode. It must be a traffic item,\
                            config element or high level stream handle. [keylget ret_val log]"
                    return $ret_val
                }

                if {[keylget ret_val value] == "traffic_item"} {
                    set retrieve [540getConfigElementOrHighLevelStream $stream_id]
                    if {[keylget retrieve status] != $::SUCCESS} {
                        return $retrieve
                    }
                    set handle   [keylget retrieve handle]
                } else {
                    set handle $stream_id
                }
                
                set traffic_item_objref [ixNetworkGetParentObjref $handle "trafficItem"]
                set dynamic_update [ixNet getList $traffic_item_objref dynamicUpdate]
                if {$dynamic_update != ""} {
                    set available_dynamic_update [ixNet getAttribute $dynamic_update -availableDynamicUpdateFields]
                    set available_dynamic_list [list]
                    foreach element $available_dynamic_update {
                        lappend dynamic_update_list $dynamic_updates_fields_map($element)
                    }
                    keylset returnList available_dynamic_update_fields $dynamic_update_list
                } else  {
                    keylset returnList available_dynamic_update_fields ""
                }
                
                return $returnList
            }
            "get_available_session_aware_traffic" {
                set ret_val [540IxNetValidateObject $stream_id [list traffic_item config_element high_level_stream stack_hls stack_ce]]
                if {[keylget ret_val status] != $::SUCCESS} {
                    keylset ret_val log "Invalid stream_id $stream_id for -mode $mode. It must be a traffic item,\
                            config element or high level stream handle. [keylget ret_val log]"
                    return $ret_val
                }

                if {[keylget ret_val value] == "traffic_item"} {
                    set retrieve [540getConfigElementOrHighLevelStream $stream_id]
                    if {[keylget retrieve status] != $::SUCCESS} {
                        return $retrieve
                    }
                    set handle   [keylget retrieve handle]
                } else {
                    set handle $stream_id
                }
                
                set traffic_item_objref [ixNetworkGetParentObjref $handle "trafficItem"]
                set dynamic_update [ixNet getList $traffic_item_objref dynamicUpdate]
                if {$dynamic_update != ""} {
                    set available_session_aware [ixNet getAttribute $dynamic_update -availableSessionAwareTrafficFields]                  
                    set available_session_list [list]
                    foreach element $available_session_aware {
                        lappend available_session_list $session_aware_traffic_map($element)
                    }
                    keylset returnList available_session_aware_traffic_fields $available_session_list
                } else  {
                    keylset returnList available_session_aware_traffic_fields ""
                }
                
                return $returnList
            }
            "get_available_fields_for_link" {
                if {$version < "7.10"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Mode get_available_fields_for_link available only for IxNetwork greater or equal than 7.10."
                    return $returnList
                }
                set ret_val [540IxNetValidateObject $stream_id [list config_element stack_ce high_level_stream stack_hls]]
                if {[keylget ret_val status] != $::SUCCESS} {
                    keylset ret_val log "Invalid stream_id $stream_id for -mode $mode. It must be a \
                            configElement or a highLevelStream handle. [keylget ret_val log]"
                    return $ret_val
                }

                if {[keylget ret_val value] == "traffic_item"} {
                    set retrieve [540getConfigElementOrHighLevelStream $stream_id]
                    if {[keylget retrieve status] != $::SUCCESS} {
                        return $retrieve
                    }
                    set handle   [keylget retrieve handle]
                } else {
                    set handle $stream_id
                }
                if {![regexp {::ixNet::OBJ-/traffic/trafficItem:[0-9]+/(configElement|highLevelStream):[0-9]+} $handle element_objref elem_type]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The -field_linked_to argument $field_linked_to is not defined correctly"
                    return $returnList
                }
                set stackLinks [ixNet getL $element_objref stackLink]
                
                keylset returnList available_fields_for_link  $stackLinks
                
                return $returnList
            }
        }
    }
    
    if {$mode == "create"} {
        if {[info exists name] && [regexp { } $name]} {
            set name [regsub -all { } $name _]
            puts "Warning: -name contained spaces. The new name is: $name"
        }
        set backwards_compatibility 0
        
        set endpoint_ranges {
            {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:"[0-9a-zA-Z\-]+"/dcbxEndpoint:"[0-9a-zA-Z\-]+"$}
            ./range/macRange {} all
            {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:"[0-9a-zA-Z\-]+"/dcbxEndpoint:"[0-9a-zA-Z\-]+"/range:"[0-9a-zA-Z\-]+"$}
            ./macRange       {} all
            {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:"[0-9a-zA-Z\-]+"/dcbxEndpoint:"[0-9a-zA-Z\-]+"/range:"[0-9a-zA-Z\-]+"/dcbxRange$}
            {../macRange}    {} all
            {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:"[0-9a-zA-Z\-]+"/ipEndpoint:"[0-9a-zA-Z\-]+"/range:"[0-9a-zA-Z\-]+"$}
            {../..}          {ixNet exec start $endpoint_handle} {ethernet(.*)}
            {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:"[0-9a-zA-Z\-]+"/pppox:"[0-9a-zA-Z\-]+"/dhcpoPppClientEndpoint:"[0-9a-zA-Z\-]+"/range:"[0-9a-zA-Z\-]+"$}
            {./pppoxRange}   {} all
        }
        
        if {[info exists emulation_src_handle]} {
            set endpoint_set_list ""
            foreach endpoint_set $emulation_src_handle {
                set endpoint_list ""
                foreach endpoint $endpoint_set {
                    if {[info exists circuit_endpoint_type] && $circuit_endpoint_type == "multicast_igmp" &&\
                            [isValidIPAddress $endpoint]} {
                        # if the configuration contains IGMP, and the enpoint source handle 
                        # is the protcol interface IP.
                        set ip_addr_found 0
                        foreach {key value} [array get pa_ip_idx] {
                            if {[regexp $endpoint $key]} {
                                set endpoint $value
                                set ip_addr_found 1
                                break
                            }
                        }
                        if {!$ip_addr_found} {
                            set translated_args [::ixiangpf::traffic_handle_translator  \
                                -emulation_src_handle   $endpoint                       \
                                -emulation_dst_handle   $emulation_dst_handle           \
                                -type                   $circuit_endpoint_type          \
                            ]
                            if {[keylget translated_args status] != $::SUCCESS} {
                                if {[info exists rollback_list] && [info exists mode]} {
                                    540trafficRollback $rollback_list $mode
                                }
                                return [util::make_error \
                                    "Could not translate handles in \
                                    ixiangpf::traffic_handle_translator. \
                                    Log: [keylget translated_args log]" \
                                ]
                            }
                            set endpoint [keylget translated_args emulation_src_handle]
                            set ip_addr_found 1
                        }
                        
                        if {!$ip_addr_found} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "The -emulation_src_handle provided is not a valid\
                                    protocol interface IP: $endpoint"
                            return $returnList
                        }
                    }
                    
                    if {[llength [info commands $endpoint]]} {
                        set endpoint_handle [$endpoint _ixn_handle]; # code generated handle
                    } else {
                        set endpoint_handle $endpoint; # hlt classic handle
                    }
                    foreach {regexp_elem path_elem exec_elem ep_type_elem} $endpoint_ranges {
                        if {$ep_type_elem == "all" || ([info exists circuit_endpoint_type] && [regexp $ep_type_elem $circuit_endpoint_type]) } {
                            if {[regexp $regexp_elem $endpoint_handle]} {
                                set path_list [split $path_elem /]
                                foreach path_ch $path_list {
                                    if {$path_ch == "."} {
                                        #
                                    } elseif {$path_ch == ".."} {
                                        set endpoint_handle [join [lrange [split $endpoint_handle /] 0 end-1] /]
                                    } else {
                                        if {$path_ch == "pppoxRange"} {
                                            if {[info exists circuit_endpoint_type] && $circuit_endpoint_type == "ipv4"} {
                                                set endpoint_handle [lindex [ixNet getList $endpoint_handle $path_ch] 0]
                                            }
                                        } else {
                                            set endpoint_handle [lindex [ixNet getList $endpoint_handle $path_ch] 0]
                                        }
                                    }
                                }
                                if {$exec_elem != ""} {
                                    eval $exec_elem
                                }
                            }
                        }
                    }
                    lappend endpoint_list $endpoint_handle
                }
                lappend endpoint_set_list $endpoint_list
            }
            set emulation_src_handle $endpoint_set_list
        }
        
        if {[info exists emulation_dst_handle]} {
            if (![info exists emulation_multicast_dst_handle]) {
                set emulation_multicast_dst_handle ""
                set emulation_multicast_dst_handle_type ""
            }
            set endpoint_set_list ""
            foreach endpoint_set $emulation_dst_handle {
                set endpoint_list ""
                foreach endpoint $endpoint_set {
                    if {[info exists circuit_endpoint_type] && $circuit_endpoint_type == "multicast_igmp" &&\
                            [regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $endpoint]} {
                        # if the configuration contains IGMP, and the enpoint source handle 
                        # is the protcol interface IP.
                        if {[info exists multicast_group_ip_to_handle($endpoint)]} {
                            set endpoint $multicast_group_ip_to_handle($endpoint)
                        } else {
                            lappend emulation_multicast_dst_handle "$endpoint"
                            lappend emulation_multicast_dst_handle_type igmp
                            
                        }
                    }
                    
                    if {[llength [info commands $endpoint]]} {
                        set endpoint_handle [$endpoint _ixn_handle]; # code generated handle
                    } else {
                        set endpoint_handle $endpoint; # hlt classic handle
                    }
                    foreach {regexp_elem path_elem exec_elem ep_type_elem} $endpoint_ranges {
                        if {$ep_type_elem == "all" || ([info exists circuit_endpoint_type] && [regexp $ep_type_elem $circuit_endpoint_type]) } {
                            if {[regexp $regexp_elem $endpoint_handle]} {
                                set path_list [split $path_elem /]
                                foreach path_ch $path_list {
                                    if {$path_ch == "."} {
                                        #
                                    } elseif {$path_ch == ".."} {
                                        set endpoint_handle [join [lrange [split $endpoint_handle /] 0 end-1] /]
                                    } else {
                                        if {$path_ch == "pppoxRange"} {
                                            if {[info exists circuit_endpoint_type] && $circuit_endpoint_type == "ipv4"} {
                                                set endpoint_handle [lindex [ixNet getList $endpoint_handle $path_ch] 0]
                                            }
                                        } else {
                                            set endpoint_handle [lindex [ixNet getList $endpoint_handle $path_ch] 0]
                                        }
                                    }
                                }
                                if {$exec_elem != ""} {
                                    eval $exec_elem
                                }
                            }
                        }
                    }
                    lappend endpoint_list $endpoint_handle
                }
                lappend endpoint_set_list $endpoint_list
            }
            set emulation_dst_handle $endpoint_set_list
        }
        if {[info exists circuit_endpoint_type] && $circuit_endpoint_type == "multicast_igmp"} {
            # if the traffic_config call contains IGMP IP handles,
            # set the circuit_endpoint_type to ipv4
            set circuit_endpoint_type ipv4
        }
        
        if {[info exists circuit_type] && $circuit_type == "quick_flows"} {
            if {![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Port handle is required for Tx traffic."
                return $returnList
            }
            
            set quick_flows_flag 1
                        
            # Unset all parameters that are not useful for this particular case...
            if {[info exists emulation_src_handle]} { unset emulation_src_handle }
            if {[info exists emulation_dst_handle]} { unset emulation_dst_handle }
            
            # Init vport variables...
            set good_code [ixNetworkGetPortObjref $port_handle]
            if {[keylget good_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not get ixnetwork object reference for\
                        port $port_handle. Possible cause: port was not added with \
                        ::ixia::connect procedure. [keylget good_code log]"
                return $returnList
            }
            set vport_handle [keylget good_code vport_objref]
            if {[info exists port_handle2]} {
                set good_code [ixNetworkGetPortObjref $port_handle2]
                if {[keylget good_code status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not get ixnetwork object reference for\
                            port $port_handle2. Possible cause: port was not added with \
                            ::ixia::connect procedure. [keylget good_code log]"
                    return $returnList
                }
                set vport_handle2 [keylget good_code vport_objref]
            } else {
                set vport_handle2 "none"
            }
        } else {
            set quick_flows_flag 0
        }
        
        if {[info exists emulation_src_handle] && ![info exists emulation_dst_handle] && ![info exists arg_emulation_scalable_dst_handle]} {
            if {![regexp {(^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$)|(^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$)|(^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$)|(^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$)} $emulation_src_handle]} {
                
                # Create static endpoints for L2VPN traffic
                # Check the destination port handle
                set result [ixNetworkGetPortObjref $port_handle]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the port object\
                            reference associated to the $port_handle port\
                            handle while trying to create the static\
                            endpoints - [keylget result log]."
                    return $returnList
                } else {
                    set port_objref [keylget result vport_objref]
                }

                # Check the destination enpoint parameters
                set endpoint_params [list atm_range_count vpi_step                  \
                        vpi_increment_step vci_step vci_increment_step              \
                        pvc_count_step vci vci_increment vpi vpi_increment          \
                        pvc_count atm_header_encapsulation fr_range_count           \
                        dlci_value_step dlci_repeat_count_step dlci_value           \
                        dlci_count_mode dlci_repeat_count ip_range_count            \
                        ip_dst_range_step ip_dst_prefix_len_step                    \
                        ip_dst_increment_step ip_dst_count_step intf_handle         \
                        l3_protocol ip_dst_addr ip_dst_prefix_len ip_dst_increment  \
                        ip_dst_count lan_range_count indirect range_per_spoke       \
                        mac_dst_step mac_dst_count_step vlan_id_step site_id_step   \
                        mac_dst mac_dst_mode mac_dst_count vlan_enable vlan_id      \
                        vlan_id_mode site_id_enable site_id                         \
                        ]

                set endpoint_creation_args "-port_objref $port_objref"
                foreach endpoint_param $endpoint_params {
                    if {[info exists $endpoint_param]} {
                        append endpoint_creation_args \
                                " -$endpoint_param [set $endpoint_param]"
                    }
                }

                if {$endpoint_creation_args != {}} {
                    # Create the endpoint(s)
                    set result [eval ixNetworkStaticEndpointCfg \
                            $endpoint_creation_args]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "No endpoint arguments have been\
                            specified and the destination handle is missing. No\
                            traffic can be configured unless valid destination\
                            enpoint arguments or one or more valid destination\
                            handles are specified."
                    return $returnList
                }

                # Process the result
                if {![catch {keylget result atm_endpoints}]} {
                    set atm_endpoints [keylget result atm_endpoints]
                } else {
                    set atm_endpoints [list]
                }
                if {![catch {keylget result fr_endpoints}]} {
                    set fr_endpoints [keylget result fr_endpoints]
                } else {
                    set fr_endpoints [list]
                }
                if {![catch {keylget result ip_endpoints}]} {
                    set ip_endpoints [keylget result ip_endpoints]
                } else {
                    set ip_endpoints [list]
                }
                if {![catch {keylget result lan_endpoints}]} {
                    set lan_endpoints [keylget result lan_endpoints]
                } else {
                    set lan_endpoints [list]
                }
                set emulation_dst_handle [concat $atm_endpoints $fr_endpoints \
                        $ip_endpoints $lan_endpoints]
                
            } else {
                set backwards_compatibility 1
                set unknown_ep "dst"
            }
        }       
        
        if {[info exists emulation_dst_handle] && ![info exists emulation_src_handle] && ![info exists arg_emulation_scalable_src_handle]} {
            if {![regexp {(^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$)|(^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$)|(^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$)|(^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$)} $emulation_dst_handle]} {
                
                keylset returnList status $::FAILURE
                keylset returnList log "Scenarios in which emulation_dst_handle exists and\
                        emulation_src_handle does not exist are supported only for PPPoX and\
                        L2TPoX handles for backwards compatibility."
                return $returnList
            }
            
            set backwards_compatibility 1
            set unknown_ep "src"
        }
                
        if {$backwards_compatibility} {
            # 'IxAccess like' stream is needed. We have one of the endpoints and the 
            # other should be a static endpoint
            
            if {$unknown_ep == "src"} {
                if {[info exists port_handle]} {
                    set search_port $port_handle
                }
            } else {
                if {[info exists port_handle2]} {
                    set search_port $port_handle2
                }
            }
            
            if {[info exists emulation_override_ppp_ip_addr] && $emulation_override_ppp_ip_addr != "none"} {
                set convert_to_raw 1
            }
            
            # Search for an interface with ip_${unknown_ep}_addr on port $search_port to
            # use as endpoint
            # If it doesn't exist, create a static endpoint
            set map_ip_to_ipv6 0
            if {[info exists l3_protocol]} {
                if {$l3_protocol == "ipv4"} {
                    if {![info exists ip_${unknown_ep}_addr]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Parameter ip_${unknown_ep}_addr is mandatory\
                                when parameter emulation_${unknown_ep}_handle is missing."
                        return $returnList
                    }
                } elseif {$l3_protocol == "ipv6"} {
                    if {![info exists ipv6_${unknown_ep}_addr]} {
                        if {![info exists ip_${unknown_ep}_addr]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Parameter ip_${unknown_ep}_addr is mandatory\
                                    when parameter emulation_${unknown_ep}_handle is missing."
                            return $returnList
                        } elseif {[isValidIPv4Address [set ip_${unknown_ep}_addr]]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Parameter ip_${unknown_ep}_addr is IPv4\
                                    when parameter emulation_${unknown_ep}_handle is missing and\
                                    l3_protocol is $l3_protocol."
                            return $returnList
                        } else {
                            # map ip to ipv6 params
                            set map_ip_to_ipv6 1
                        }
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unsupported l3_protocl $l3_protocol when\
                            when running protocol stack protocols."
                    return $returnList
                }
            } else {
                if {![info exists ip_${unknown_ep}_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Parameter ip_${unknown_ep}_addr is mandatory\
                            when parameter emulation_${unknown_ep}_handle is missing."
                    return $returnList
                } elseif {[isValidIPv4Address [set ip_${unknown_ep}_addr]]} {
                    set l3_protocol "ipv4"
                } else {
                    set l3_protocol "ipv6"
                    # map ip to ipv6 params
                    set map_ip_to_ipv6 1
                }
            }
            
            if {$map_ip_to_ipv6} {
                set ip_ipv6_mapping {
                    ip_dst_addr                        ipv6_dst_addr
                    ip_dst_count                       ipv6_dst_count
                    ip_dst_mode                        ipv6_dst_mode
                    ip_dst_step                        ipv6_dst_step
                    ip_dst_tracking                    ipv6_dst_tracking
                    ip_src_addr                        ipv6_src_addr    
                    ip_src_count                       ipv6_src_count   
                    ip_src_mode                        ipv6_src_mode    
                    ip_src_step                        ipv6_src_step    
                    ip_src_tracking                    ipv6_src_tracking
                }
                
                foreach {tmp_ip_pname tmp_ipv6_pname} $ip_ipv6_mapping {
                    if {[info exists $tmp_ip_pname]} {
                        set $tmp_ipv6_pname [set $tmp_ip_pname]
                    }
                }
            }
            
            if {$l3_protocol == "ipv4"} {
                set search_ip [set ip_${unknown_ep}_addr]
                set search_ip_version 4
            } else {
                set search_ip [expand_ipv6_addr [set ipv6_${unknown_ep}_addr]]
                set search_ip_version 6
                
                # Make sure QOS is configured with ip_precedence too
                if {![info exists qos_ipv6_traffic_class] && ![info exists ipv6_traffic_class]} {
                    set qos_params_bw_cptb {
                        ip_precedence       5       "0xE0"
                        ip_delay            4       "0x10"
                        ip_throughput       3       "0x08"
                        ip_reliability      2       "0x04"
                        ip_cost             1       "0x02"
                    }
                    set ipv6_traffic_class 0
                    
                    foreach {qos_param shift_val mask_val} $qos_params_bw_cptb {
                        if {[info exists $qos_param]} {
                            set qos_param_val [set $qos_param]
                            set ipv6_traffic_class [expr $ipv6_traffic_class | (($qos_param_val << $shift_val)  & $mask_val)]
                        }
                    }
                }
            }
            
            set create_static_ep 0
            if {![info exists search_port]} {
                
                set create_static_ep 1
                
            } else {

                set ret_code [interface_exists        \
                        -port_handle $search_port     \
                        -ip_version  $search_ip_version  \
                        -ip_address  $search_ip       ]
                
                if {[keylget ret_code status] == 1} {
                    set description [keylget ret_code description]
                    set intf_obj [ixNetworkGetIntfObjref $description]
                    if {$intf_obj != [ixNet getNull]} {
                    
                        set emulation_${unknown_ep}_handle $intf_obj
                        
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Failed to get interface handle\
                                for interface with description $description."
                        return $returnList
                    }
                } else {
                    set create_static_ep 1
                }
            }
            
            if {$create_static_ep} {
                # Create an IP static endpoint
                
                if {[info exists search_port]} {
                    set ret_code [ixNetworkGetPortObjref $search_port]
                    
                    if {[keylget ret_code status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not get ixnetwork object reference for\
                                port $search_port. Possible cause: port was not used in \
                                ::ixia::connect procedure. [keylget ret_code log]"
                        return $returnList
                    }
                    set port_obj_ref [keylget ret_code vport_objref]
                } else {
                    if {$unknown_ep == "src"} {
                        set port_obj_ref [ixNetworkGetParentObjref $emulation_dst_handle]
                    } else {
                        set port_obj_ref [ixNetworkGetParentObjref $emulation_src_handle]
                    }
                }
                
                set hlt_p_handle_tmp [ixNetworkGetRouterPort $port_obj_ref]
                
                if {$l3_protocol == "ipv4"} {
                    set static_ep_args "-port_handle $hlt_p_handle_tmp -ipv4_address $search_ip"
                } else {
                    set static_ep_args "-port_handle $hlt_p_handle_tmp -ipv6_address $search_ip"
                }
                
                #set intf_list [eval ixNetworkProtocolIntfCfg \
                    #$protocol_intf_args]
                #if {[keylget intf_list status] != $::SUCCESS} {
                    #keylset returnList status $::FAILURE
                    #keylset returnList log "Unable to create the\
                        #protocol interfaces. [keylget intf_list log]"
                    #return $returnList
                #}
                
                set tmp_cmd "ixNetworkProtocolIntfCfg $static_ep_args"
                set ret_code [eval $tmp_cmd]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set emulation_${unknown_ep}_handle [keylget ret_code connected_interfaces]
                 
            }
            
            set traffic_type ipv${search_ip_version}
            
        } else {
            
            # This is not a backwards compatible IxAccess script
            # Configure streams
            
            if {    ![info exists emulation_src_handle] &&              \
                    ![info exists emulation_dst_handle] &&              \
                    ![info exists arg_emulation_scalable_dst_handle] && \
                    ![info exists arg_emulation_scalable_src_handle] && \
                    ![info exists emulation_multicast_dst_handle]       \
                } {
                # This is a stream similar to the ones created with ixos
                # There are no protocol endpoints. Traffic is raw and protocol headers are added over it
                
                if {![info exists port_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "If emulation_src_handle parameter is not present, -port_handle\
                            parameter is mandatory."
                    return $returnList
                }
                set ret_code [ixNetworkGetPortObjref $port_handle]
                    
                if {[keylget ret_code status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not get ixnetwork object reference for\
                            port $port_handle. Possible cause: port was not added with \
                            ::ixia::connect procedure. [keylget ret_code log]"
                    return $returnList
                }
                set vport_handle [keylget ret_code vport_objref]
                
                set emulation_src_handle $vport_handle/protocols
                
                if {![info exists port_handle2]} {
                    set allow_self_destined 1
                    set emulation_dst_handle $vport_handle/protocols
                } else {
                    set ret_code [ixNetworkGetPortObjref $port_handle2]
                    
                    if {[keylget ret_code status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not get ixnetwork object reference for\
                                port $port_handle2. Possible cause: port was not added with \
                                ::ixia::connect procedure. [keylget ret_code log]"
                        return $returnList
                    }
                    set vport_handle2 [keylget ret_code vport_objref]
                    set emulation_dst_handle $vport_handle2/protocols
                }
                
                # Now we have the source and destinations configured
                # We'll ignore circuit_type and circuit_endpoint_type since this looks
                # a lot like an ixos style stream
                set traffic_type raw
                
            } else {
                
                # It looks like we have both emulation_src_handle and emulation_dst_handle
                # or a combination that includes the scalable versions or multicast destination
                # It's a specific ixnetwork stream where the source and destination are 
                # emulated
                
                # Determine traffic_type
        
                if {![info exists source_filter] && ![info exists destination_filter]} {
        
                  if {![info exists circuit_type]} {
                      set circuit_type "none"
                  }
                  
                  if {![info exists circuit_endpoint_type]} {
                      set circuit_endpoint_type "ipv4"
                  }
                  
                  array set translate_to_type {
                      none,atm                                atm
                      none,ethernet_vlan                      ethernet_vlan
                      none,ethernet_vlan_arp                  ethernet_vlan
                      none,frame_relay                        frame_relay
                      none,hdlc                               hdlc
                      none,ipv4                               ipv4
                      none,ipv4_arp                           ipv4
                      none,ipv4_application_traffic           ipv4_application_traffic
                      application,ipv4_application_traffic      ipv4_application_traffic
                      none,ipv6                               ipv6
                      none,ipv6_application_traffic           ipv6_application_traffic
                      application,ipv6_application_traffic      ipv6_application_traffic
                      none,ppp                                ppp
                      none,fcoe                               fcoe
                      l2vpn,atm                               atm
                      l2vpn,ethernet_vlan                     ethernet_vlan
                      l2vpn,ethernet_vlan_arp                 ethernet_vlan
                      l2vpn,frame_relay                       frame_relay
                      l2vpn,hdlc                              hdlc
                      l2vpn,ipv4                              ipv4
                      l2vpn,ipv4_arp                          ipv4
                      l2vpn,ipv4_application_traffic          ipv4_application_traffic
                      l2vpn,ipv6                              ipv6
                      l2vpn,ipv6_application_traffic          ipv6_application_traffic
                      l2vpn,ppp                               ppp
                      l2vpn,fcoe                              fcoe
                      l3vpn,atm                               atm
                      l3vpn,ethernet_vlan                     ethernet_vlan
                      l3vpn,ethernet_vlan_arp                 ethernet_vlan
                      l3vpn,frame_relay                       frame_relay
                      l3vpn,hdlc                              hdlc
                      l3vpn,ipv4                              ipv4
                      l3vpn,ipv4_arp                          ipv4
                      l3vpn,ipv4_application_traffic          ipv4_application_traffic
                      l3vpn,ipv6                              ipv6
                      l3vpn,ipv6_application_traffic          ipv6_application_traffic
                      l3vpn,ppp                               ppp
                      l3vpn,fcoe                              fcoe
                      mpls,atm                                atm
                      mpls,ethernet_vlan                      ethernet_vlan
                      mpls,ethernet_vlan_arp                  ethernet_vlan
                      mpls,frame_relay                        frame_relay
                      mpls,hdlc                               hdlc
                      mpls,ipv4                               ipv4
                      mpls,ipv4_arp                           ipv4
                      mpls,ipv4_application_traffic           ipv4_application_traffic
                      mpls,ipv6                               ipv6
                      mpls,ipv6_application_traffic           ipv6_application_traffic
                      mpls,ppp                                ppp
                      mpls,fcoe                               fcoe
                      6pe,atm                                 atm
                      6pe,ethernet_vlan                       ethernet_vlan
                      6pe,ethernet_vlan_arp                   ethernet_vlan
                      6pe,frame_relay                         frame_relay
                      6pe,hdlc                                hdlc
                      6pe,ipv4                                ipv4
                      6pe,ipv4_arp                            ipv4
                      6pe,ipv4_application_traffic            ipv4_application_traffic
                      6pe,ipv6                                ipv6
                      6pe,ipv6_application_traffic            ipv6_application_traffic
                      6pe,ppp                                 ppp
                      6pe,fcoe                                fcoe
                      6vpe,atm                                atm
                      6vpe,ethernet_vlan                      ethernet_vlan
                      6vpe,ethernet_vlan_arp                  ethernet_vlan
                      6vpe,frame_relay                        frame_relay
                      6vpe,hdlc                               hdlc
                      6vpe,ipv4                               ipv4
                      6vpe,ipv4_arp                           ipv4
                      6vpe,ipv4_application_traffic           ipv4_application_traffic
                      6vpe,ipv6                               ipv6
                      6vpe,ipv6_application_traffic           ipv6_application_traffic
                      6vpe,ppp                                ppp
                      6vpe,fcoe                               fcoe
                      raw,atm                                 raw
                      raw,ethernet_vlan                       raw
                      raw,ethernet_vlan_arp                   raw
                      raw,frame_relay                         raw
                      raw,hdlc                                raw
                      raw,ipv4                                raw
                      raw,ipv4_arp                            raw
                      raw,ipv4_application_traffic            raw
                      raw,ipv6                                raw
                      raw,ipv6_application_traffic            raw
                      raw,ppp                                 raw
                      raw,fcoe                                raw
                      vpls,atm                                atm
                      vpls,ethernet_vlan                      ethernet_vlan
                      vpls,ethernet_vlan_arp                  ethernet_vlan
                      vpls,frame_relay                        frame_relay
                      vpls,hdlc                               hdlc
                      vpls,ipv4                               ipv4
                      vpls,ipv4_arp                           ipv4
                      vpls,ipv4_application_traffic           ipv4_application_traffic
                      vpls,ipv6                               ipv6
                      vpls,ipv6_application_traffic           ipv6_application_traffic
                      vpls,ppp                                ppp
                      vpls,fcoe                               fcoe
                      stp,atm                                 atm
                      stp,ethernet_vlan                       ethernet_vlan
                      stp,ethernet_vlan_arp                   ethernet_vlan
                      stp,frame_relay                         frame_relay
                      stp,hdlc                                hdlc
                      stp,ipv4                                ipv4
                      stp,ipv4_arp                            ipv4
                      stp,ipv4_application_traffic            ipv4_application_traffic
                      stp,ipv6                                ipv6
                      stp,ipv6_application_traffic            ipv6_application_traffic
                      stp,ppp                                 ppp
                      stp,fcoe                                fcoe
                      mac_in_mac,atm                          atm
                      mac_in_mac,ethernet_vlan                ethernet_vlan
                      mac_in_mac,ethernet_vlan_arp            ethernet_vlan
                      mac_in_mac,frame_relay                  frame_relay
                      mac_in_mac,hdlc                         hdlc
                      mac_in_mac,ipv4                         ipv4
                      mac_in_mac,ipv4_arp                     ipv4
                      mac_in_mac,ipv4_application_traffic     ipv4_application_traffic
                      mac_in_mac,ipv6                         ipv6
                      mac_in_mac,ipv6_application_traffic     ipv6_application_traffic
                      mac_in_mac,ppp                          ppp
                      mac_in_mac,fcoe                         fcoe
                  }
                  
                  set traffic_type $translate_to_type($circuit_type,$circuit_endpoint_type)
                  # source_filter and destination_filter set to All
                  set source_filter {}
                  set destination_filter {}
                } elseif {[info exists source_filter] && [info exists destination_filter]} {
                
                  if {[info exists circuit_type] && $circuit_type == "raw"} {
                    set traffic_type $circuit_type  
                  } else {
                    if {![info exists circuit_endpoint_type]} {
                      keylset returnList status $::FAILURE
                      keylset returnList log "If using source_filter and destination_filter parameters and circuit_type is not raw, the circuit_endpoint_type is mandatory"
                      return $returnList
                    }
                    set traffic_type $circuit_endpoint_type
                  }
                  
                  # translate All to empty (ixnet)
                  set source_filter_temp ""
                  foreach source_filter_elem $source_filter {
                    if {[string compare -nocase $source_filter_elem "all"] == 0} {
                        lappend source_filter_temp {}
                    } else {
                        lappend source_filter_temp $source_filter_elem
                    }
                  }
                  set source_filter $source_filter_temp
                  set destination_filter_temp ""
                  foreach destination_filter_elem $destination_filter {
                    if {[string compare -nocase $destination_filter_elem "all"] == 0} {
                        lappend destination_filter_temp {}
                    } else {
                        lappend destination_filter_temp $destination_filter_elem
                    }
                  }
                  set destination_filter $destination_filter_temp
                  
                } else {
                  keylset returnList status $::FAILURE
                  keylset returnList log "Both source_filter and destination_filter parameters must be present at the same time."
                  return $returnList
                }
            }
        }
        
        array set translate_traffic_type {
            atm                         atm
            ethernet_vlan               ethernetVlan
            fcoe                        fcoe
            frame_relay                 frameRelay
            hdlc                        hdlc
            ipv4                        ipv4
            ipv4_application_traffic    ipv4ApplicationTraffic
            ipv6                        ipv6
            ipv6_application_traffic    ipv6ApplicationTraffic
            ppp                         ppp
            raw                         raw
            fc                          fc
        }
        
        # Code copied from ixnetwork_traffic_config
        
        array set translate_src_dest_mesh [list                 \
            fully                       fullMesh                \
            one_to_one                  oneToOne                \
            many_to_many                manyToMany              \
            none                        none                    \
        ]
    
        array set translate_route_mesh [list                    \
            fully                       fullMesh                \
            one_to_one                  oneToOne                \
        ]
        
        if {[info exists emulation_src_handle]} {
            if {[lindex $emulation_src_handle 0] == "endpointset"} {
                set emulation_src_handle [list [lrange $emulation_src_handle 1 end]]
            } elseif {[lindex [lindex $emulation_src_handle 0] 0] == "endpointset"} {
                set emulation_src_handle_temp ""
                foreach emulation_src_handle_item $emulation_src_handle {
                    if {[lindex $emulation_src_handle_item 0] == "endpointset"} {
                        set emulation_src_handle_item [lrange $emulation_src_handle_item 1 end]
                    }
                    lappend emulation_src_handle_temp [list $emulation_src_handle_item]
                }
                set emulation_src_handle $emulation_src_handle_temp
            } elseif {[lindex $emulation_src_handle 0] == [lindex [lindex $emulation_src_handle 0] 0]} {
                #set emulation_src_handle [list $emulation_src_handle]
            }
        }
        
        if {[info exists emulation_dst_handle]} {
            if {[lindex $emulation_dst_handle 0] == "endpointset"} {
                set emulation_dst_handle [list [lrange $emulation_dst_handle 1 end]]
            } elseif {[lindex [lindex $emulation_dst_handle 0] 0] == "endpointset"} {
                set emulation_dst_handle_temp ""
                foreach emulation_dst_handle_item $emulation_dst_handle {
                    if {[lindex $emulation_dst_handle_item 0] == "endpointset"} {
                        set emulation_dst_handle_item [lrange $emulation_dst_handle_item 1 end]
                    }
                    lappend emulation_dst_handle_temp [list $emulation_dst_handle_item]
                }
                set emulation_dst_handle $emulation_dst_handle_temp
            } elseif {[lindex $emulation_dst_handle 0] == [lindex [lindex $emulation_dst_handle 0] 0]} {
                #set emulation_dst_handle [list $emulation_dst_handle]
            }
        }
               
        # take an exception, due to compatibility issues
        # the form should consist of a list of handles, and has only one endpoint set
        if {([llength $emulation_src_handle] != $endpointset_count) && \
                ([llength $emulation_src_handle] != 1) && \
                (([regexp -all {::ixNet::OBJ-} $emulation_src_handle] == [llength $emulation_src_handle]) || \
                 ([string first "\{" $emulation_src_handle] == -1))} {   
            set emulation_src_handle [list $emulation_src_handle]
        }
        if {([llength $emulation_dst_handle] != $endpointset_count) && \
                ([llength $emulation_dst_handle] != 1) && \
                (([regexp -all {::ixNet::OBJ-} $emulation_dst_handle] == [llength $emulation_dst_handle]) || \
                 ([string first "\{" $emulation_dst_handle] == -1))} {
            set emulation_dst_handle [list $emulation_dst_handle]
        }
                
        if {[llength $emulation_src_handle] != $endpointset_count} {
            keylset returnList status $::FAILURE
            keylset returnList log "The number of endpointsets is not correct:\
                    -endpointset_count is $endpointset_count, and -emulation_src_handle\
                    has [llength $emulation_src_handle] elements."
            return $returnList
        }
        
        if {[llength $emulation_dst_handle] != $endpointset_count} {
            keylset returnList status $::FAILURE
            keylset returnList log "The number of endpointsets is not correct:\
                    -endpointset_count is $endpointset_count, and -emulation_dst_handle\
                    has [llength $emulation_dst_handle] elements."
            return $returnList
        }

        # tag_filter validation
        if {[info exists tag_filter] && [llength $tag_filter] != $endpointset_count} {
            # this may be a bug in parse_dashed_args, add a new list enclosure -ae
            set tag_filter [list $tag_filter]
        }
    
        # Begin configuring traffic item circuit.
        # Create traffic item argument list.
        if {![info exists name]} {
            set updated_name "TI$current_streamid-HLTAPI_TRAFFICITEM_540"
        } else {
            if {[string first "TI$current_streamid-" $name] != 0} {
                set updated_name "TI$current_streamid-$name"
            } else {
                set updated_name $name
            }
        }
        incr current_streamid
        set traffic_item_args [list -enabled true -name $updated_name]
        if {[info exists src_dest_mesh]} {
            lappend traffic_item_args -srcDestMesh \
                    $translate_src_dest_mesh($src_dest_mesh)
        }
        if {[info exists route_mesh]} {
            lappend traffic_item_args -routeMesh \
                    $translate_route_mesh($route_mesh)
        }
        if {[info exists traffic_type]} {
            lappend traffic_item_args -trafficType \
                    $translate_traffic_type($traffic_type)
        }
        
        if {[info exists bidirectional] && $bidirectional == 1} {
            lappend traffic_item_args -biDirectional true
        } else {
            lappend traffic_item_args -biDirectional false
        }
        
        if {[info exists allow_self_destined]} {
            lappend traffic_item_args -allowSelfDestined $truth($allow_self_destined)
        }
        
        if {[info exists use_cp_size]} {
            lappend traffic_item_args -useControlPlaneFrameSize $truth($use_cp_size)
        }

        if {[info exists use_cp_rate]} {
            lappend traffic_item_args -useControlPlaneRate $truth($use_cp_rate)
        }

        if {[info exists enable_dynamic_mpls_labels]} {
            lappend traffic_item_args -enableDynamicMplsLabelValues $truth($enable_dynamic_mpls_labels)
        }
        
        if {[info exists merge_destinations]} {
            lappend traffic_item_args -mergeDestinations $truth($merge_destinations)
        }
        
        set operational_hls "none"
        set traffic_node_required 0
        if {$quick_flows_flag} {
            # Build endpoint set arguments...
            set eps_arguments [list]
            lappend eps_arguments -sources "${vport_handle}/protocols"
            if {$vport_handle2 != "none"} {
                lappend eps_arguments -destinations "${vport_handle2}/protocols"
            }
            # Isolate HLS specific arguments...
            set hls_arguments [list]
            if {[info exists mac_dst_mode] && $mac_dst_mode == "discovery"} {
                lappend hls_arguments -destinationMacMode arp
            } else {
                lappend hls_arguments -destinationMacMode manual
            }
            if {[info exists preamble_size_mode]} {
                lappend hls_arguments -preambleFrameSizeMode $preamble_size_mode
            }
            if {[info exists preamble_custom_size]} {
                lappend hls_arguments -preambleCustomSize $preamble_custom_size
            }
            # Make it quick...
            lappend traffic_item_args -trafficItemType quick
            # Find existing quick nodes and add HLS...
            set existing_nodes [ixNet getList [ixNet getRoot]traffic trafficItem]
            if { [llength $existing_nodes] > 0 } {
                set we_should [addQuickHlsOverExistingTrafficItem $existing_nodes $eps_arguments $hls_arguments]
                if { [keylget we_should status] != $::SUCCESS} { return $we_should }
                if { [keylget we_should no_candidate] } {
                    set traffic_node_required 1
                } else {
                    set traffic_item_objref [keylget we_should traffic_handle]
                    set operational_hls     [keylget we_should hls_handle]
                }
            } else {
                set traffic_node_required 1
            }
        }
        
        # Add a whole traffic item is none found...
        if { $operational_hls == "none" } {
            set result [ixNetworkNodeAdd [ixNet getRoot]traffic \
                    trafficItem $traffic_item_args -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add a new traffic item -\
                        [keylget result log]."
                return $returnList
            } else {
                set traffic_item_objref [keylget result node_objref]
            }
        }
        lappend stream_id $updated_name
        lappend rollback_list $traffic_item_objref

        # Transform real port handles to vport handles for raw traffic
        set index_i 0
        foreach emulation_src_handle_item $emulation_src_handle {
            set index_j 0
            foreach src_item $emulation_src_handle_item {
                if {[regexp "^/topology" $src_item]} {
                    # Don't change/validate handles that start with /topology
                    
                } elseif {[regexp -all {^([0-9]+)/([0-9]+)/([0-9]+)} $src_item]} {
                    set result [::ixia::ixNetworkGetPortObjref $src_item]
                    if {[keylget result status] == $::FAILURE} {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log "The -emulation_src_handle\
                                argument contains the following values which\
                                are not valid traffic endpoints $src_item:\
                                [keylget result log]"
                        return $returnList
                    }
                    set emulation_src_handle_item [lreplace $emulation_src_handle_item \
                            $index_j $index_j [keylget result vport_objref]/protocols]
                    set emulation_src_handle [lreplace $emulation_src_handle           \
                            $index_i $index_i $emulation_src_handle_item]
                } elseif {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/vlans:\d+/macRanges:\d+$} $src_item]} {
                    
                    regsub {vlans}     $src_item {vlan} src_item
                    regsub {macRanges} $src_item {mac}  src_item
                    
                    set emulation_src_handle_item [lreplace $emulation_src_handle_item \
                            $index_j $index_j $src_item]
                    set emulation_src_handle [lreplace $emulation_src_handle           \
                            $index_i $index_i $emulation_src_handle_item]
                } elseif {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/trunk:\d+$} $src_item]} {
                    catch {unset trunk_mr_list}
                    if {[catch {ixNet getList $src_item macRanges} trunk_mr_list]} {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error when attempting to \
                                'ixNet getList $src_item macRanges'. $trunk_mr_list"
                        return $returnList
                    } elseif {[llength $trunk_mr_list] < 1} {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not create traffic because PBB-TE\
                                trunk traffic source '$src_item' must have at least one\
                                Mac Range configured to use as source endpoint."
                        return $returnList
                    }
                    
                    set trunk_mr_idx 0
                    foreach single_trunk_mr $trunk_mr_list {
                        if {$trunk_mr_idx == 0} {
                            set emulation_src_handle_item [lreplace $emulation_src_handle_item \
                                    $index_j $index_j $single_trunk_mr]
                            set emulation_src_handle [lreplace $emulation_src_handle           \
                                    $index_i $index_i $emulation_src_handle_item]
                        } else {
                            lappend emulation_src_handle_item $single_trunk_mr
                            set emulation_src_handle [lreplace $emulation_src_handle           \
                                    $index_i $index_i $emulation_src_handle_item]
                        }
                        incr trunk_mr_idx
                    }
                }
                incr index_j
            }
            incr index_i
        }
        
        # Adjust CFM handles
        set index_i 0
        foreach emulation_dst_handle_item $emulation_dst_handle {
            set index_j 0
            foreach dst_item $emulation_dst_handle_item {
                if {[regexp "^/topology" $dst_item]} {
                    # Don't change/validate handles that start with /topology
                    
                } elseif {[regexp -all {^([0-9]+)/([0-9]+)/([0-9]+)} $dst_item]} {
                    set result [::ixia::ixNetworkGetPortObjref $dst_item]
                    if {[keylget result status] == $::FAILURE} {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log "The -emulation_dst_handle\
                                argument contains the following values which\
                                are not valid traffic endpoints $dst_item:\
                                [keylget result log]"
                        return $returnList
                    }
                    set emulation_dst_handle_item [lreplace $emulation_dst_handle_item \
                            $index_j $index_j [keylget result vport_objref]/protocols]
                    set emulation_dst_handle [lreplace $emulation_dst_handle           \
                            $index_i $index_i $emulation_dst_handle_item]
                } elseif {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/vlans:\d+/macRanges:\d+$} $dst_item]} {
                    
                    regsub {vlans}     $dst_item {vlan} dst_item
                    regsub {macRanges} $dst_item {mac}  dst_item
    
                    set emulation_dst_handle_item [lreplace $emulation_dst_handle_item \
                            $index_j $index_j $dst_item]
                    set emulation_dst_handle [lreplace $emulation_dst_handle           \
                            $index_i $index_i $emulation_dst_handle_item]
                } elseif {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/trunk:\d+$} $dst_item]} {
                    catch {unset trunk_mr_list}
                    if {[catch {ixNet getList $dst_item macRanges} trunk_mr_list]} {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error when attempting to \
                                'ixNet getList $dst_item macRanges'. $trunk_mr_list"
                        return $returnList
                    } elseif {[llength $trunk_mr_list] < 1} {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not create traffic because PBB-TE\
                                trunk traffic destination '$dst_item' must have at least one\
                                Mac Range configured to use as destination endpoint."
                        return $returnList
                    }
                    
                    set trunk_mr_idx 0
                    foreach single_trunk_mr $trunk_mr_list {
                        if {$trunk_mr_idx == 0} {
                            set emulation_dst_handle_item [lreplace $emulation_dst_handle_item \
                                    $index_j $index_j $single_trunk_mr]
                            set emulation_dst_handle [lreplace $emulation_dst_handle           \
                                    $index_i $index_i $emulation_dst_handle_item]
                        } else {
                            lappend emulation_dst_handle_item $single_trunk_mr
                            set emulation_dst_handle [lreplace $emulation_dst_handle           \
                                    $index_i $index_i $emulation_dst_handle_item]
                        }
                        incr trunk_mr_idx
                    }
                }
                incr index_j
            }
            incr index_i
        }
        # Adjust RSVP handles
        set index_i 0
        foreach emulation_src_handle_item $emulation_src_handle {
            set index_j 0
            foreach src_item $emulation_src_handle_item {
                if {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+} $src_item]} {
                    # It is an RSVP handle. We must transform it to a valid RSVP traffic handle
                    set result [::ixia::ixnetwork_rsvp_get_valid_traffic_endpoint $src_item]
                    if {[keylget result status] == $::FAILURE} {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log [keylget result log]
                        return $returnList
                    }
                    set emulation_src_handle_item [lreplace $emulation_src_handle_item \
                            $index_j $index_j [keylget result endpointRef]]
                    set emulation_src_handle [lreplace $emulation_src_handle \
                            $index_i $index_i $emulation_src_handle_item]
                }
                incr index_j
            }
            incr index_i
        }
        # Adjust RSVP handles
        set index_i 0
        foreach emulation_dst_handle_item $emulation_dst_handle {
            set index_j 0
            foreach dst_item $emulation_dst_handle {
                if {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+} $dst_item]} {
                    # It is an RSVP handle. We must transform it to a valid RSVP traffic handle
                    set result [::ixia::ixnetwork_rsvp_get_valid_traffic_endpoint $dst_item]
                    if {[keylget result status] == $::FAILURE} {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log [keylget result log]
                        return $returnList
                    }
    
                    set emulation_dst_handle_item [lreplace $emulation_dst_handle_item \
                        $index_j $index_j [keylget result endpointRef]]
                    set emulation_dst_handle [lreplace $emulation_src_handle \
                            $index_i $index_i $emulation_dst_handle_item]
                }
                incr index_j
            }
            incr index_i
        }
        # Adjust the BGP handles
        set l3site_regex {::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:.+}
        set src_handle_list [list]
        foreach emulation_src_handle_item $emulation_src_handle {
            set src_handle [list]
            foreach handle $emulation_src_handle_item {
                if {[regexp $l3site_regex $handle]} {
                    debug "ixNet adjustIndexes $handle ::ixNet::OBJ-/vport/protocols/bgp/neighborRange.0"
                    lappend src_handle [ixNet adjustIndexes $handle ::ixNet::OBJ-/vport/protocols/bgp/neighborRange.0]
                } else {
                    lappend src_handle $handle
                }
            }
            if {$src_handle != ""} {
                set tmp_src_handle [list]
                foreach src_unique_handle $src_handle {
                    catch { set src_unique_handle [ixNet remapIds $src_unique_handle] }
                    lappend tmp_src_handle $src_unique_handle
                }
                set src_handle $tmp_src_handle
            } else {
                # an ixnet bug strips lists incorrectly; use a placeholder and replace later
                set src_handle "list_placeholder_hack"
            }
            lappend src_handle_list $src_handle
        }
        set dst_handle_list [list]
        foreach emulation_dst_handle_item $emulation_dst_handle {
            set dst_handle [list]
            foreach handle $emulation_dst_handle_item {
                if {[regexp $l3site_regex $handle]} {
                    debug "ixNet adjustIndexes $handle ::ixNet::OBJ-/vport/protocols/bgp/neighborRange.0"
                    lappend dst_handle [ixNet adjustIndexes $handle ::ixNet::OBJ-/vport/protocols/bgp/neighborRange.0]
                } else {
                    lappend dst_handle $handle
                }
            }
            if {$dst_handle != ""} {
                set tmp_dst_handle [list]
                foreach dst_unique_handle [split $dst_handle] {
                    catch { set dst_unique_handle [ixNet remapIds $dst_unique_handle] }
                    lappend tmp_dst_handle $dst_unique_handle
                }
                set dst_handle $tmp_dst_handle
            } else {
                # an ixnet bug strips lists incorrectly; use a placeholder and replace later
                set dst_handle "list_placeholder_hack"
            }
            lappend dst_handle_list $dst_handle
        }
        if { $quick_flows_flag && !($traffic_node_required) } {
            # Do nothing. Endpoint set already added.
        } else {
            # Add the traffic item pair
            set traffic_item_type [ixNet getA $traffic_item_objref -trafficItemType]
            set commit_needed 0
            set epsIndex 0
            
            # Make an array that contains all the scalable indexes that were specified
            set scalableInputArrayList [list \
                arg_emulation_scalable_dst_handle       \
                arg_emulation_scalable_dst_port_start   \
                arg_emulation_scalable_dst_port_count   \
                arg_emulation_scalable_dst_intf_start   \
                arg_emulation_scalable_dst_intf_count   \
                arg_emulation_scalable_src_handle       \
                arg_emulation_scalable_src_port_start   \
                arg_emulation_scalable_src_port_count   \
                arg_emulation_scalable_src_intf_start   \
                arg_emulation_scalable_src_intf_count   \
            ]
            ::ixia::540trafficConfig::make_scalable_indexes_array scalableIndexes $scalableInputArrayList
            unset scalableInputArrayList
            
            if {[info exists emulation_multicast_dst_handle] && \
                    [llength $emulation_multicast_dst_handle] == 0 } {
                unset emulation_multicast_dst_handle
                if { [info exists emulation_multicast_dst_handle_type] } {
                    unset emulation_multicast_dst_handle_type
                }
            }
            
            if { [info exists emulation_multicast_dst_handle] && \
                    $endpointset_count > 1 && \
                    ([llength $emulation_multicast_dst_handle] != $endpointset_count) } \
            {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                keylset returnList status $::FAILURE
                keylset returnList log "emulation_multicast_dst_handle length\
                        ([llength $emulation_multicast_dst_handle]) is not the\
                        same as the endpointset_count ($endpointset_count)"
                return $returnList
            }
            
            if { [info exists emulation_multicast_dst_handle] && \
                    ![info exists emulation_multicast_dst_handle_type] } \
            {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                keylset returnList status $::FAILURE
                keylset returnList log "-emulation_multicast_dst_handle_type is mandatory when\
                        -emulation_multicast_dst_handle is present."
                return $returnList
            }
            
            if { [info exists emulation_multicast_dst_handle_type] && \
                    $endpointset_count > 1 && \
                    ([llength $emulation_multicast_dst_handle_type] != $endpointset_count) } \
            {            
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                keylset returnList status $::FAILURE
                keylset returnList log "emulation_multicast_dst_handle_type length\
                        ([llength $emulation_multicast_dst_handle_type]) is not the\
                        same as the endpointset_count ($endpointset_count) and the\
                        same as emulation_multicast_dst_handle_type length."
                return $returnList
            }

            # BUG1112578
            # translate any legacy traffic endpoints
            set translated_args [::ixiangpf::traffic_handle_translator  \
                -emulation_src_handle   $src_handle_list    \
                -emulation_dst_handle   $dst_handle_list    \
                -type                   $traffic_type       \
            ]
            if {[keylget translated_args status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return [util::make_error \
                    "Could not translate handles in \
                    ixiangpf::traffic_handle_translator. \
                    Log: [keylget translated_args log]" \
                ]
            }
            set translated_keys [keylget translated_args translated_keys]
            if {[lsearch $translated_keys emulation_scalable_src_handle] >= 0 && \
                [lsearch $translated_keys emulation_scalable_dst_handle] >= 0    \
            } {
                # the translation func generated some scalable endpoints
                # if the user also specified emulation_scalable_*_handle throw 
                # and error since this is only to be used for legacy backwards compatibility
                if {[info exists arg_emulation_scalable_src_handle] ||  \
                    [info exists arg_emulation_scalable_dst_handle]     \
                } {
                    if {[info exists rollback_list] && [info exists mode]} {
                        540trafficRollback $rollback_list $mode
                    }
                    return [util::make_error \
                        "Detected a NGPF style endpoint in either -emulation_src_handle or \
                        -emulation_dst_handle. Passing NGPF endpoints in those two arguments is \
                        used for backwards compatibility only and none of the emulation_scalable_* \
                        arguments should be given in this case. In order to use new NGPF functionality, \
                        pass all the NGPF style endpoints using the respective emulation_scalable_* arguments" \
                    ]
                }
            }
            
            foreach src_handle $src_handle_list dst_handle $dst_handle_list {
                set traffic_item_add_params ""

                # BUG1112578
                # translate any legacy traffic endpoints per endpoint set
                set translated_args [::ixiangpf::traffic_handle_translator  \
                    -emulation_src_handle   $src_handle     \
                    -emulation_dst_handle   $dst_handle     \
                    -type                   $traffic_type   \
                ]
                if {[keylget translated_args status] != $::SUCCESS} {
                    if {[info exists rollback_list] && [info exists mode]} {
                        540trafficRollback $rollback_list $mode
                    }
                    return [util::make_error \
                        "Could not translate handles in \
                        ixiangpf::traffic_handle_translator. \
                        Log: [keylget translated_args log]" \
                    ]
                }
                set translated_keys [keylget translated_args translated_keys]
                foreach type {src dst} {
                    if {[lsearch $translated_keys emulation_scalable_${type}_handle] >= 0} {
                        set handle_value      [keylget translated_args emulation_scalable_${type}_handle]    
                        set port_start_value  [keylget translated_args emulation_scalable_${type}_port_start]
                        set port_count_value  [keylget translated_args emulation_scalable_${type}_port_count]
                        set intf_start_value  [keylget translated_args emulation_scalable_${type}_intf_start]
                        set intf_count_value  [keylget translated_args emulation_scalable_${type}_intf_count]

                        set scalableIndex [format "%s-%u" EndpointSet [expr $epsIndex+1]]
                        set arg_emulation_scalable_${type}_handle($scalableIndex)       $handle_value
                        set arg_emulation_scalable_${type}_port_start($scalableIndex)   $port_start_value
                        set arg_emulation_scalable_${type}_port_count($scalableIndex)   $port_count_value
                        set arg_emulation_scalable_${type}_intf_start($scalableIndex)   $intf_start_value
                        set arg_emulation_scalable_${type}_intf_count($scalableIndex)   $intf_count_value
                    }

                    if {[lsearch $translated_keys emulation_${type}_handle] >= 0} {
                        set ${type}_handle [keylget translated_args emulation_${type}_handle]
                    } else {
                        set ${type}_handle [list]
                    }
                }

                if {$src_handle == "list_placeholder_hack"} {
                    set src_handle [list [list ]]
                }
                if {$dst_handle == "list_placeholder_hack"} {
                    set dst_handle [list [list ]]
                }
                
                set waiting_operations_status [ixnetwork_wait_pending_operations $src_handle $pending_operations_timeout]
                if {[keylget waiting_operations_status status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget waiting_operations_status log]
                    return $returnList
                }
                
                set waiting_operations_status [ixnetwork_wait_pending_operations $dst_handle $pending_operations_timeout]
                if {[keylget waiting_operations_status status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget waiting_operations_status log]
                    return $returnList
                }
                
                lappend traffic_item_add_params -sources $src_handle -destinations $dst_handle
                if {[info exists source_filter] && [info exists destination_filter] && $traffic_item_type == "l2L3"} {
                    if {[lindex $source_filter $epsIndex] != ""} {
                        lappend traffic_item_add_params -sourceFilter [lindex $source_filter $epsIndex]
                    } else {
                        lappend traffic_item_add_params -sourceFilter [lindex $source_filter end]
                    }
                    if {[lindex $destination_filter $epsIndex] != ""} {
                        lappend traffic_item_add_params -destinationFilter [lindex $destination_filter $epsIndex]
                    } else {
                        lappend traffic_item_add_params -destinationFilter [lindex $destination_filter end]
                    }
                }
                
                # Create and add the scalable souces and scalable destinations if needed
                set scalableIndex [format "%s-%u" EndpointSet [expr $epsIndex+1]]
                if {[info exists scalableIndexes($scalableIndex)]} {
                    unset scalableIndexes($scalableIndex)
                }
                set scalable_sources [::ixia::540trafficConfig::make_scalable_handle src $scalableIndex]
                if {$scalable_sources != ""} {
                    lappend traffic_item_add_params -scalableSources $scalable_sources                    
                }
                set scalable_destinations [::ixia::540trafficConfig::make_scalable_handle dst $scalableIndex]
                if {$scalable_destinations != ""} {
                    lappend traffic_item_add_params -scalableDestinations $scalable_destinations
                }                
                
                if  { [info exists emulation_multicast_dst_handle] && $emulation_multicast_dst_handle != "" } \
                {
                    debug "Processing multicast handles: $emulation_multicast_dst_handle"
                    #  below code does not check if the handles are valid and if 
                    #  the correct number of elements are present in the handle.
                    #  This validation is allready done at this stage so
                    #  we can safely assume that the values are valid.
                    if {$endpointset_count>1} {
                        set current_emulation_multicast_dst_handle_list [lindex $emulation_multicast_dst_handle $epsIndex]
                        set current_emulation_multicast_dst_handle_type_list [lindex $emulation_multicast_dst_handle_type $epsIndex]
                    } else {
                        set current_emulation_multicast_dst_handle_list $emulation_multicast_dst_handle
                        set current_emulation_multicast_dst_handle_type_list $emulation_multicast_dst_handle_type
                    }

                    set multicastDestinations [list]
                    if {$current_emulation_multicast_dst_handle_list == "all_multicast_ranges"} {
                        lappend multicastDestinations [list True none 0.0.0.0 0.0.0.0 0]
                    } elseif { [regexp -all / $current_emulation_multicast_dst_handle_list] == \
                            [expr [llength $current_emulation_multicast_dst_handle_list] * 2]} \
                    {
                        # Each multicast destination must contain exactly 2 slashes (/) so
                        # we only enter below code if the number of / found is equal with 
                        # the number of elements in the list multiplied by 2 (to avoid SDM
                        # exceptions if the user enters an invalid multicast destination.

                        foreach emulation_multicast_handle $current_emulation_multicast_dst_handle_list \
                                emulation_multicast_handle_type $current_emulation_multicast_dst_handle_type_list \
                        {
                            debug "Processing endpointSet $epsIndex multicast handle \
                                    [lsearch $current_emulation_multicast_dst_handle_list\
                                    $emulation_multicast_handle] /\
                                    [llength $current_emulation_multicast_dst_handle_list]:\
                                    $emulation_multicast_handle with type $emulation_multicast_handle_type"
                            
                            # we already validated that the list has the expected number of / so 
                            # is safe to split by / and the lindex on the resulted list.
                            
                            set emulation_multicast_handle [split $emulation_multicast_handle /]

                            lappend multicastDestinations [list  \
                                    False                                       \
                                    $emulation_multicast_handle_type            \
                                    [lindex $emulation_multicast_handle 0]      \
                                    [lindex $emulation_multicast_handle 1]      \
                                    [lindex $emulation_multicast_handle 2] ]
                            

                        }
                    } elseif { ([string trim $current_emulation_multicast_dst_handle_list] != "") && \
                            ($current_emulation_multicast_dst_handle_list != "none") } \
                    {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log "Multicast destination handle \"$current_emulation_multicast_dst_handle_list\"\
                                is not a valid list of multicast destination handles (address/step/count format or one of the\
                                following special keywords: all_multicast_ranges, none or an empty list). Example of valid\
                                multicast destination handle: 224.0.0.0/0.0.1.0/1. Also the number of handles expected in the\
                                list needs to be the same as the number of endpoints."
                        return $returnList
                    }
                    if {[string trim $multicastDestinations] != ""} {
                        lappend traffic_item_add_params -multicastDestinations  $multicastDestinations
                    }
                }
                
                if  { [info exists emulation_multicast_rcvr_handle] && $emulation_multicast_rcvr_handle != "" } \
                {
                    debug "Processing multicastReveivers handles: $emulation_multicast_rcvr_handle"
                    #  below code does not check if the handles are valid and if 
                    #  the correct number of elements are present in the handle.
                    #  This validation is allready done at this stage so
                    #  we can safely assume that the values are valid.
                    if {![info exists emulation_multicast_rcvr_port_index] || \
                            ![info exists emulation_multicast_rcvr_host_index] || \
                            ![info exists emulation_multicast_rcvr_mcast_index]} {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log "If -emulation_multicast_rcvr_handle is provided, you must also provide the port index list (-emulation_multicast_rcvr_port_index),\
                                the host index list (-emulation_multicast_rcvr_host_index) and the group/joinPrune index list (-emulation_multicast_rcvr_mcast_index)."
                        return $returnList
                    }
                    if {$endpointset_count>1} {
                        set current_rcvr_handle_list [lindex $emulation_multicast_rcvr_handle $epsIndex]
                        set current_rcvr_port_index [lindex $emulation_multicast_rcvr_port_index $epsIndex]
                        set current_rcvr_host_index [lindex $emulation_multicast_rcvr_host_index $epsIndex]
                        set current_rcvr_mcast_index [lindex $emulation_multicast_rcvr_mcast_index $epsIndex]
                    } else {
                        set current_rcvr_handle_list $emulation_multicast_rcvr_handle
                        set current_rcvr_port_index $emulation_multicast_rcvr_port_index
                        set current_rcvr_host_index $emulation_multicast_rcvr_host_index
                        set current_rcvr_mcast_index $emulation_multicast_rcvr_mcast_index
                    }
                    
                    if {[llength $current_rcvr_handle_list] != [llength $current_rcvr_port_index] ||\
                            [llength $current_rcvr_port_index] != [llength $current_rcvr_host_index] ||\
                            [llength $current_rcvr_mcast_index] != [llength $current_rcvr_handle_list]} {
                            
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log "The number of elements in -emulation_multicast_rcvr_handle,-emulation_multicast_rcvr_port_index, \
                                -emulation_multicast_rcvr_host_index and -emulation_multicast_rcvr_mcast_index must be the same."
                        return $returnList
                    }
                    
                    set multicastReceivers [list]
                    for {set i 0} {$i < [llength $current_rcvr_handle_list]} {incr i} {
                        set cr [lindex $current_rcvr_handle_list $i]
                        set rp [lindex $current_rcvr_port_index $i]
                        set rh [lindex $current_rcvr_host_index $i]
                        set rm [lindex $current_rcvr_mcast_index $i]
                        # A multicastRecevier item should look like this: 
                        # {/topology:2/deviceGroup:1/ethernet:1/ipv4:1/pimV4Interface:1/pimV4JoinPruneList 0 1 0}
                        lappend multicastReceivers "$cr $rp $rh $rm"
                    }
                    
                    if {[string trim $multicastReceivers] != ""} {
                        lappend traffic_item_add_params -multicastReceivers $multicastReceivers
                    }
                }
                
                set result [ixNetworkNodeAdd $traffic_item_objref endpointSet $traffic_item_add_params]
                set commit_needed 1
                if {[keylget result status] == $::FAILURE} {
                    if {[info exists rollback_list] && [info exists mode]} {
                        540trafficRollback $rollback_list $mode
                    }
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not add a new traffic item pair\
                            to the $traffic_item_objref traffic item - [keylget result log]."
                    return $returnList
                }
                set eps_obj [keylget result node_objref]

                if {[info exists tag_filter] && $traffic_item_type == "l2L3"} {
                    if {[lindex $tag_filter $epsIndex] != ""} {
                        set current_ngpf_filter [lindex $tag_filter $epsIndex]
                    } else {
                        set current_ngpf_filter [lindex $tag_filter end]
                    }
                    set ixn_tag_value ""
                    foreach item $current_ngpf_filter {
                        if {[regexp {(\w+):([\d,]+)} $item all name values]} {
                            append ixn_tag_value "\{\"$name\" \{[split $values \{,\}]\}\} "
                        } else {
                            return [util::make_error \
                                "-tag_filter parameter has invalid elements. Should be \
                                a list of pairs <tagname>:<id1,id2,id3...>."]
                        }
                    }
                    set result [ixNetworkNodeSetAttr $eps_obj \
                        [list -ngpfFilters "$ixn_tag_value"]]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to configure tag filters - [keylget result log]."
                        return $returnList
                    }
                }
                incr epsIndex
            }
            
            set unprocessedScalableIndexes [array names scalableIndexes]
            if { $unprocessedScalableIndexes != "" } {
                # Print a warning that contains the list of unprocessed indexes
                puts "Warning: Scalable endpointset data was not processed for the followig indexes: ${unprocessedScalableIndexes}. Please make sure that these indexes are correct."
            }
            
            if {$commit_needed} {
                if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                    if {[info exists rollback_list] && [info exists mode]} {
                        540trafficRollback $rollback_list $mode
                    }
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to add endpointsets. $err"
                    return $returnList
                }
                catch {unset commit_needed}
            }
            
            if {$traffic_item_type == "l2L3"} {
                if {[llength [ixNet getList $traffic_item_objref configElement]] < 1} {
                    if {[info exists rollback_list] && [info exists mode]} {
                        540trafficRollback $rollback_list $mode
                    }
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not create traffic item.\
                            The sources/destinations/trafficType combination is not valid or\
                            the source_filter '$source_filter' did not match\
                            any of the source endpoints '$src_handle' or\
                            the destination_filter '$destination_filter'  did not match\
                            any of the destination endpoints '$dst_handle'."
                    return $returnList
                }
                
                if {[info exists convert_to_raw] && $convert_to_raw} {
                    if {[ixNet getA $traffic_item_objref -trafficType] != "raw"} {
                        set errFound 1 
                        for {set raw_convert_retry 0} {$raw_convert_retry < 3} {incr raw_convert_retry} {
                            
                            if {[catch {ixNet exec convertToRaw $traffic_item_objref} err]} {
                                set errFound 1
                                set errString "Failed to convert to raw '$traffic_item_objref'. $err."
                                debug "ixNet exec convertToRaw $traffic_item_objref --> $err"
                                
                                if {$raw_convert_retry == 1} {
                                    set retCode [540IxNetTrafficGenerate $traffic_item_objref]
                                    if {[keylget retCode status] != $::SUCCESS} {
                                        if {[info exists rollback_list] && [info exists mode]} {
                                            540trafficRollback $rollback_list $mode
                                        }
                                        return $retCode
                                    }
                                }
                                
                                after 500
                                continue
                            }
                            
                            set errFound 0
                            
                            set original_name [ixNet getA $traffic_item_objref -name]
                            debug "original_name == $original_name"
                            foreach tmp_ti [ixNet getL [ixNet getRoot]traffic trafficItem] {
                                set tmp_name [ixNet getA $tmp_ti -name]
                                debug "regexp \{$original_name Raw \\\(\\\d+\\\)\} $tmp_name"
                                if {[regexp "$original_name Raw \\\(\\\d+\\\)" $tmp_name]} {
                                    set raw_ti_objref $tmp_ti
                                    break
                                }
                            }
                            
                            if {[info exists raw_ti_objref]} {
                                break
                            }
                        }
                        
                        if {$errFound} {
                            if {[info exists rollback_list] && [info exists mode]} {
                                540trafficRollback $rollback_list $mode
                            }
                            keylset returnList status $::FAILURE
                            keylset returnList log $errString
                            return $returnList
                        }
                        
                        if {![info exists raw_ti_objref]} {
                            if {[info exists rollback_list] && [info exists mode]} {
                                540trafficRollback $rollback_list $mode
                            }
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error. Could not find Raw traffic item that resulted from convertToRaw for $traffic_item_objref."
                            return $returnList
                        }
                        
                        # It's a traffic item handle. Remove it
                        debug "ixNet remove $traffic_item_objref"
                        if {[catch {ixNet remove $traffic_item_objref} err]} {
                            if {[info exists rollback_list] && [info exists mode]} {
                                540trafficRollback $rollback_list $mode
                            }
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to remove $traffic_item_objref while\
                                    converting to raw. $err"
                            return $returnList
                        }
                        
                        set pos_ti [lsearch $rollback_list $traffic_item_objref]
                        if {$pos_ti != -1} {
                            set rollback_list [lreplace $rollback_list $pos_ti $pos_ti $raw_ti_objref]
                        }
                        
                        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                            if {[info exists rollback_list] && [info exists mode]} {
                                540trafficRollback $rollback_list $mode
                            }
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to remove $traffic_item_objref while\
                                    converting to raw. $err"
                            return $returnList
                        }
                        
                        set traffic_item_objref $raw_ti_objref
                        
                        set retCode [ixNetworkNodeSetAttr $traffic_item_objref \
                                [list -name $original_name] -commit]
                        if {[keylget retCode status] != $::SUCCESS} {
                            if {[info exists rollback_list] && [info exists mode]} {
                                540trafficRollback $rollback_list $mode
                            }
                            return $retCode
                        }
                        
                        catch {unset raw_ti_objref}
                    }
                }
            }
        }
        #return $traffic_item_objref
        
        set ixn_args ""
        
        if {![info exists tx_mode]} {
            debug "540IxNetTrafficItemGetFirstTxPort $traffic_item_objref"
            set ret_val [540IxNetTrafficItemGetFirstTxPort $traffic_item_objref]
            if {[keylget ret_val status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $ret_val
            }
            
            set vport_object [keylget ret_val value]
            set vport_transmit_mode [ixNet getAttribute $vport_object -txMode]
        } else {
            switch -- $tx_mode {
                "advanced" {
                    set vport_transmit_mode "interleaved"
                }
                "stream" {
                    set vport_transmit_mode "sequential"
                }
            }
        }
        
        if {[info exists vport_transmit_mode]} {
            if {[ixNet getAttribute $traffic_item_objref -transmitMode] != $vport_transmit_mode} {
                lappend ixn_args -transmitMode $vport_transmit_mode
            }
        }
        
        if {[llength $ixn_args] > 0} {
            
            set result [ixNetworkNodeSetAttr $traffic_item_objref \
                    $ixn_args -commit]
            if {[keylget result status] == $::FAILURE} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure $ixn_args - [keylget result log]."
                return $returnList
            }
            
        }
        
        #Skipping The Below code if traffic is L4L7 traffic
        # Finished configuring traffic item circuit.
        set retrieve [540getConfigElementOrHighLevelStream $traffic_item_objref]
        if {[keylget retrieve status] != $::SUCCESS} {
            if {[info exists rollback_list] && [info exists mode]} {
                540trafficRollback $rollback_list $mode
            }
            return $retrieve
        }
        if {$operational_hls != "none"} {
            set handle $operational_hls
        } else {
            set handle [keylget retrieve handle]
            foreach tmp_ce $handle {
                set ret_val [540IxNetValidateObject $tmp_ce config_element]
                if {[keylget ret_val status] != $::SUCCESS} {
                    continue
                }
                
                set ret_code [ixNetworkEvalCmd [list ixNet getL $tmp_ce stack]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    if {[info exists rollback_list] && [info exists mode]} {
                        540trafficRollback $rollback_list $mode
                    }
                    keylset ret_code log "Error in $procName. [keylget ret_code log]"
                    return $ret_code
                }
                
                set stack_names ""
                foreach tmp_stack [keylget ret_code ret_val] {
                    set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_stack -displayName]]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset ret_code log "Error in $procName. [keylget ret_code log]"
                        return $ret_code
                    }
                    lappend stack_names [keylget ret_code ret_val]
                }
                set ngt_config_elements_array($tmp_ce) $stack_names
                
                catch {unset stack_names}
                catch {unset tmp_stack}
            }
            catch {unset tmp_ce}
        }

        
        # Configure udf and table udf data if aplicable
        if {$quick_flows_flag} {
            set qf_args ""
            set var_list_qf [getVarListFromArgs $opt_args_quick_flows]
            foreach var_fs $var_list_qf {
                if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                    set var_fs_value [set $var_fs]
                    if {[llength $var_fs_value]} {
                        lappend qf_args -$var_fs \{$var_fs_value\}
                    } else {
                        lappend qf_args -$var_fs $var_fs_value
                    }
                }
            }
            if {[llength $qf_args] >= 0} {
                lappend qf_args -mode $mode
                lappend qf_args -handle [lindex $handle end]
                set qf_status [540quickFlowsConfig $qf_args $opt_args_quick_flows]
                if {[keylget qf_status status] != $::SUCCESS} {
                    return $qf_status
                }
            }
        }
    }

    #Skipping The Below code if traffic is L4L7 traffic

    foreach target_handle $handle {
        if {![regexp {(^::ixNet::OBJ-/traffic/trafficItem:[0-9]+/)((configElement)|(highLevelStream))(:[0-9]+)} $target_handle target_handle]} {continue}
        
        # Set specific attributes...
        
        set tmp_quick_flows_flag 0
        if {![info exists quick_flows_flag]} {
            set tmp_quick_ti [ixNetworkGetParentObjref $target_handle "trafficItem"]
            if {[ixNet getA $tmp_quick_ti -trafficItemType] == "quick"} {
                set tmp_quick_flows_flag 1
            }
        } else {
            set tmp_quick_flows_flag $quick_flows_flag
        }
        
        if {([info exists mac_dst_mode] && $mac_dst_mode == "discovery") && ($tmp_quick_flows_flag || ([info exists circuit_type] && $circuit_type == "raw"))} {
            ixNet setAttribute $target_handle -destinationMacMode arp
        } else {
            if {$mode != "modify"} {
                ixNet setAttribute $target_handle -destinationMacMode manual
            }
        }
        
        if {[info exists preamble_size_mode]} {
            ixNet setAttribute $target_handle -preambleFrameSizeMode $preamble_size_mode
        }
        if {[info exists preamble_custom_size]} {
            ixNet setAttribute $target_handle -preambleCustomSize $preamble_custom_size
        }
    }
    
    set handle_list $handle
    catch {unset handle}  
    set commit_needed 0
    
    foreach handle $handle_list {
        #
        # Configure Instrumentation
        #
        
        set instrumentation_args ""
        set var_list_instrumentation [getVarListFromArgs $opt_args_instrumentation]
        foreach var_fs $var_list_instrumentation {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend instrumentation_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend instrumentation_args -$var_fs $var_fs_value
                }
            }
        }
        
        if {[llength $instrumentation_args] > 0} {
            set commit_needed 1
            lappend instrumentation_args -mode $mode
            if {[info exists handle]} {
                lappend instrumentation_args -handle $handle
            }
            
            set instrumentation_status [540trafficInstrumentation $instrumentation_args $opt_args_instrumentation]
            if {[keylget instrumentation_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $instrumentation_status
            }
        }
        
     
        #
        # Configure Rate Control
        #
        
        set ratecontrol_args ""
        
        set var_list_ratecontrol [getVarListFromArgs $opt_args_ratecontrol]
        foreach var_fs $var_list_ratecontrol {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend ratecontrol_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend ratecontrol_args -$var_fs $var_fs_value
                }
            }
        }
        
        if {[llength $ratecontrol_args] > 0} {
            set commit_needed 1
            lappend ratecontrol_args -mode $mode
            if {[info exists handle]} {
                lappend ratecontrol_args -handle $handle
            }
            
            set ratecontrol_status [540trafficRateControl $ratecontrol_args $opt_args_ratecontrol]
            if {[keylget ratecontrol_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $ratecontrol_status
            }
        }
       
        #
        # Configure ATM Layer 1
        #
        
        set atm_l1_args ""
        
        set var_list_atm_l1 [getVarListFromArgs $opt_args_atm_l1]
        set atm_l1_args_are_default 1
        foreach var_fs $var_list_atm_l1 {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                if {![is_default_param_value $var_fs $args]} {
                    set atm_l1_args_are_default 0
                }
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend atm_l1_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend atm_l1_args -$var_fs $var_fs_value
                }
            }
        }
    
        if {[llength $atm_l1_args] > 0 && !$atm_l1_args_are_default} {
            set commit_needed 1
            lappend atm_l1_args -mode $mode
            if {[info exists handle]} {
                lappend atm_l1_args -handle $handle
            }
            
            if {[info exists traffic_type] && $traffic_type == "raw"} {
                lappend atm_l1_args -is_raw_item 1
            }
            
            set atm_l1_status [540trafficL2Atm $atm_l1_args $opt_args_atm_l1]
            if {[keylget atm_l1_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $atm_l1_status
            }
        }
           
        #
        # Configure Layer 2 Ethernet
        #
        
        set l2_ethernet_args ""
        
        set var_list_l2_ethernet [getVarListFromArgs $opt_args_l2_ethernet]
        foreach var_fs $var_list_l2_ethernet {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                append l2_ethernet_args " -$var_fs {$var_fs_value}"
            }
        }
        
        if {[llength $l2_ethernet_args] > 0} {
            set commit_needed 1
            lappend l2_ethernet_args -mode $mode
            if {[info exists handle]} {
                lappend l2_ethernet_args -handle $handle
            }
           
            set l2_ethernet_status [540trafficL2Ethernet $l2_ethernet_args $opt_args_l2_ethernet $args]
            if {[keylget l2_ethernet_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l2_ethernet_status
            }
        }
    
        #
        # Configure Layer 3 IPv4
        #
        
        set l3_ipv4_args ""
        
        set var_list_l3_ipv4 [getVarListFromArgs $opt_args_l3_ipv4]
        foreach var_fs $var_list_l3_ipv4 {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend l3_ipv4_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend l3_ipv4_args -$var_fs $var_fs_value
                }
            }
        }
    
        if {[llength $l3_ipv4_args] > 0} {
            set commit_needed 1
            lappend l3_ipv4_args -mode $mode
            if {[info exists handle]} {
                lappend l3_ipv4_args -handle $handle
            }
            
            set l3_ipv4_status [540trafficL3IpV4 $l3_ipv4_args $opt_args_l3_ipv4 $opt_args_l3_ipv4_qos $opt_args_l3_ipv4_noqos $args]
            if {[keylget l3_ipv4_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l3_ipv4_status
            }
        }
    
        #
        # Configure Layer 3 IPv6
        #
        
        set l3_ipv6_args ""
        
        set var_list_l3_ipv6 [getVarListFromArgs $opt_args_l3_ipv6]
        foreach var_fs $var_list_l3_ipv6 {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend l3_ipv6_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend l3_ipv6_args -$var_fs $var_fs_value
                }
            }
        }
        
        if {[llength $l3_ipv6_args] > 0} {
            set commit_needed 1
            lappend l3_ipv6_args -mode $mode
            if {[info exists handle]} {
                lappend l3_ipv6_args -handle $handle
            }
            
            set l3_ipv6_status [540trafficL3IpV6 $l3_ipv6_args $opt_args_l3_ipv6 $args]
            if {[keylget l3_ipv6_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l3_ipv6_status
            }
        }
        
    
        #
        # Configure Layer 3 ARP
        #
        
        set l3_arp_args ""
        
        set var_list_l3_arp [getVarListFromArgs $opt_args_l3_arp]
        foreach var_fs $var_list_l3_arp {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend l3_arp_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend l3_arp_args -$var_fs $var_fs_value
                }
            }
        }
        
        if {[llength $l3_arp_args] > 0} {
            set commit_needed 1
            lappend l3_arp_args -mode $mode
            if {[info exists handle]} {
                lappend l3_arp_args -handle $handle
            }
            
            set l3_arp_status [540trafficL3Arp $l3_arp_args $opt_args_l3_arp]
            if {[keylget l3_arp_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l3_arp_status
            }
        }
    
        #
        # Configure Layer 4 ICMP
        #
        
        set l4_icmp_args ""
        
        set var_list_l4_icmp [getVarListFromArgs $opt_args_l4_icmp]
        foreach var_fs $var_list_l4_icmp {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend l4_icmp_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend l4_icmp_args -$var_fs $var_fs_value
                }
            }
        }
        
        if {[llength $l4_icmp_args] > 0} {
            set commit_needed 1
            lappend l4_icmp_args -mode $mode
            if {[info exists handle]} {
                lappend l4_icmp_args -handle $handle
            }
            
            set l4_icmp_status [540trafficL4Icmp $l4_icmp_args $opt_args_l4_icmp]
            if {[keylget l4_icmp_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l4_icmp_status
            }
        }
        
        
        #
        # Configure Layer 4 GRE
        #
        
        set l4_gre_args ""
        
        set var_list_l4_gre [getVarListFromArgs $opt_args_l4_gre]
        foreach var_fs $var_list_l4_gre {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend l4_gre_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend l4_gre_args -$var_fs $var_fs_value
                }
            }
        }
        
        if {[llength $l4_gre_args] > 0} {
            set commit_needed 1
            lappend l4_gre_args -mode $mode
            if {[info exists handle]} {
                lappend l4_gre_args -handle $handle
            }
            
            set l4_gre_status [540trafficL4Gre $l4_gre_args $opt_args_l4_gre $opt_args_l3_ipv6 $opt_args_l3_ipv4 $opt_args_l3_ipv4_qos $opt_args_l3_ipv4_noqos]
            if {[keylget l4_gre_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l4_gre_status
            }
        }
        
    
        #
        # Configure Layer 4 UDP
        #
        
        set l4_udp_args ""
        
        set var_list_l4_udp [getVarListFromArgs $opt_args_l4_udp]
        foreach var_fs $var_list_l4_udp {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend l4_udp_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend l4_udp_args -$var_fs $var_fs_value
                }
            }
        }
        
        
        if {[llength $l4_udp_args] > 0} {
            set commit_needed 1
            lappend l4_udp_args -mode $mode
            if {[info exists handle]} {
                lappend l4_udp_args -handle $handle
            }
            
            set l4_udp_status [540trafficL4Udp $l4_udp_args $opt_args_l4_udp]
            if {[keylget l4_udp_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l4_udp_status
            }
        }
    
        #
        # Configure Layer 4 TCP
        #
        
        set l4_tcp_args ""
        
        set var_list_l4_tcp [getVarListFromArgs $opt_args_l4_tcp]
        foreach var_fs $var_list_l4_tcp {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend l4_tcp_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend l4_tcp_args -$var_fs $var_fs_value
                }
            }
        }
        
        
        if {[llength $l4_tcp_args] > 0} {
            set commit_needed 1
            lappend l4_tcp_args -mode $mode
            if {[info exists handle]} {
                lappend l4_tcp_args -handle $handle
            }
            
            set l4_tcp_status [540trafficL4Tcp $l4_tcp_args $opt_args_l4_tcp]
            if {[keylget l4_tcp_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l4_tcp_status
            }
        }
        
        #
        # Configure Layer 4 DHCP
        #
        
        set l4_dhcp_args ""
        
        set var_list_l4_dhcp [getVarListFromArgs $opt_args_l4_dhcp]
        foreach var_fs $var_list_l4_dhcp {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend l4_dhcp_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend l4_dhcp_args -$var_fs $var_fs_value
                }
            }
        }
        
        if {[llength $l4_dhcp_args] > 0} {
            set commit_needed 1
            lappend l4_dhcp_args -mode $mode
            if {[info exists handle]} {
                lappend l4_dhcp_args -handle $handle
            }
            
            set l4_dhcp_status [540trafficL4Dhcp $l4_dhcp_args $opt_args_l4_dhcp]
            if {[keylget l4_dhcp_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l4_dhcp_status
            }
        }
    
        #
        # Configure Layer 4 RIP
        #
        
        set l4_rip_args ""
        
        set var_list_l4_rip [getVarListFromArgs $opt_args_l4_rip]
        foreach var_fs $var_list_l4_rip {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend l4_rip_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend l4_rip_args -$var_fs $var_fs_value
                }
            }
        }
        
        if {[llength $l4_rip_args] > 0} {
            set commit_needed 1
            lappend l4_rip_args -mode $mode
            if {[info exists handle]} {
                lappend l4_rip_args -handle $handle
            }
            
            set l4_rip_status [540trafficL4Rip $l4_rip_args $opt_args_l4_rip]
            if {[keylget l4_rip_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l4_rip_status
            }
        }
        
        #
        # Configure Layer 4 IGMP
        #
        
        set l4_igmp_args ""
        
        set var_list_l4_igmp [getVarListFromArgs $opt_args_l4_igmp]
        foreach var_fs $var_list_l4_igmp {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend l4_igmp_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend l4_igmp_args -$var_fs $var_fs_value
                }
            }
        }
        
        if {[llength $l4_igmp_args] > 0} {
            set commit_needed 1
            lappend l4_igmp_args -mode $mode
            if {[info exists handle]} {
                lappend l4_igmp_args -handle $handle
            }
            
            set l4_igmp_status [540trafficL4Igmp $l4_igmp_args $opt_args_l4_igmp]
            if {[keylget l4_igmp_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $l4_igmp_status
            }
        }
        
        #
        # Configure Tracking
        #
        
        set tracking_args ""
        
        set var_list_tracking [getVarListFromArgs $opt_args_tracking]
        foreach var_fs $var_list_tracking {
            if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                set var_fs_value [set $var_fs]
                if {[llength $var_fs_value]} {
                    lappend tracking_args -$var_fs \{$var_fs_value\}
                } else {
                    lappend tracking_args -$var_fs $var_fs_value
                }
            }
        }
        
        if {[llength $tracking_args] > 0} {
            set commit_needed 1
            lappend tracking_args -mode $mode
            if {[info exists handle]} {
                lappend tracking_args -handle $handle
            }
            
            set tracking_status [540trafficTracking $tracking_args $opt_args_tracking]
            if {[keylget tracking_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $tracking_status
            }
        }
    }
    
    # Setting the -linkedTo field for the field_linked parameter
    if {[info exists field_linked] && [info exists field_linked_to]} {
        if {$version < "7.10"} {
            puts "Warning: Parameters field_linked and field_linked_to available only for \
                    IxNetwork greater or equal than 7.10."
        } else {
            if {[llength $field_linked] != [llength $field_linked_to]} {
                keylset ret_val status $::FAILURE
                keylset ret_val log "The field_linked and field_linked_to lists \
                        must have the same number of elements."
                return $ret_val
            }
            foreach field_linked_element $field_linked field_linked_to_element $field_linked_to {
                ixNet setAttribute $field_linked_element -linkedTo $field_linked_to_element
            }
        }
    }
    
    #
    # Configure Dynamic Update Fields
    #
    if {$mode == "modify"} {
        set traffic_item_objref [ixNetworkGetParentObjref $stream_id "trafficItem"]
    }

    if {[info exists traffic_item_objref] && $version > "7.0"} {
        set dynamic_updates [ixNet getList $traffic_item_objref dynamicUpdate]
    }
        
    # Configure the dynamic update fields if applicable
    if {[info exists dynamic_updates] && $dynamic_updates != "" && $version > "7.0"} {
        if {[info exists dynamic_update_fields]} {
            set dynamic_list [list]
            foreach dynamic_element $dynamic_update_fields {
                lappend dynamic_list $dynamic_updates_fields_map($dynamic_element)
            }
            ixNet setAttribute $dynamic_updates -enabledDynamicUpdateFields $dynamic_list
        }
        if {[info exists session_aware_traffic]} {
            set session_list [list]
            foreach session_element $session_aware_traffic {
                lappend session_list $session_aware_traffic_map($session_element)
            }              
            ixNet setAttribute $dynamic_updates -enabledSessionAwareTrafficFields $session_list
        }
    }
    
    #
    # Configure Traffic Globals
    #
    
    set global_args ""
    
    set var_list_global [getVarListFromArgs $opt_args_global]
    foreach var_fs $var_list_global {
        if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
            set var_fs_value [set $var_fs]
            if {[llength $var_fs_value]} {
                lappend global_args -$var_fs \{$var_fs_value\}
            } else {
                lappend global_args -$var_fs $var_fs_value
            }
        }
    }
    
    if {[llength $global_args] > 0} {
        set commit_needed 1
        lappend global_args -mode $mode

        set globals_status [540trafficGlobals $global_args $opt_args_global]
        if {[keylget globals_status status] != $::SUCCESS} {
            if {[info exists rollback_list] && [info exists mode]} {
                540trafficRollback $rollback_list $mode
            }
            return $globals_status
        }
    }

    #Skipping The Below code if traffic is L4L7 traffic
    #
    # Configure Frame Size
    #
    
    #####################################################
    # !!! Framesize should always be the last part !!!! #
    #####################################################
    # because it must measure the length of the Layer 2 headers
    foreach handle $handle_list {
        set framesize_args ""
        
        set var_list_framesize [getVarListFromArgs $opt_args_frame_size]
        foreach var_fs $var_list_framesize {
            if {[info exists $var_fs]} {
                switch -- $var_fs {
                    l4_protocol -
                    l3_protocol -
                    l2_encap -
                    is_raw_item -
                    atm_header_encapsulation -
                    mode -
                    handle {
                    }
                    skip_frame_size_validation {
                        lappend framesize_args -skip_frame_size_validation
                    }
                    default {
                        set var_fs_value [set $var_fs]
                        if {[llength $var_fs_value]} {
                            lappend framesize_args -$var_fs \{$var_fs_value\}
                        } else {
                            lappend framesize_args -$var_fs $var_fs_value
                        }
                    }
                }
            }
        }
        
        if {[llength $framesize_args] > 0} {
            lappend framesize_args -mode $mode
            if {[info exists handle]} {
                lappend framesize_args -handle $handle
            }
            
            set framesize_status [540trafficFrameSize $framesize_args $opt_args_frame_size]
            if {[keylget framesize_status status] != $::SUCCESS} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                return $framesize_status
            }
        }
    }
 
     #
    # Configure transmit distribution and txMode
    #
    
    if {$mode == "create"} {
        
        set ixn_args ""
        if {[info exists stream_packing] && (![info exists transmit_distribution] || [is_default_param_value "transmit_distribution" $args])} {
            switch -- $stream_packing {
                merge_destination_ranges -
                one_stream_per_endpoint_pair {
                    set transmit_distribution "endpoint_pair"
                }
                optimal_packing {
                    set transmit_distribution "none"
                }
            }
        }
        
        if {[info exists transmit_distribution]} {
            
            if {[lsearch $transmit_distribution "none"] != -1} {
                set ixn_transmit_distrib_list {}
            } else {
                set available_transmit_distrib [ixNet getA ${traffic_item_objref}/transmissionDistribution -availableDistributions]
                set ixn_transmit_distrib_list {}

                foreach td_type $transmit_distribution {
                    
                    if {[info exists transmit_distribution_map($td_type)]} {
                        # hlt distribution parameter type - for backward compatibility
                        # ixn_transmit_distrib_list
                        set ixn_transmit_distrib $transmit_distribution_map($td_type)
                        
                        if {[lsearch $available_transmit_distrib $ixn_transmit_distrib] == -1} {
                            set search_cmd "lsearch -regexp \{$available_transmit_distrib\} \
                                    \{${ixn_transmit_distrib}\\d+\}"
                            debug "--> eval $search_cmd"
                            if {[eval $search_cmd] == -1} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Transmit distribution $td_type\
                                    is not supported for this configuration. Possible cause: \
                                    transmit distribution type is not present in any of\
                                    the stream headers configured."
                                return $returnList
                            } else {
                                # The '0' at the end is not a typo. It's signifies the first header for which this
                                # td is valid
                                if {[lsearch $ixn_transmit_distrib_list "${ixn_transmit_distrib}0"] == -1} {
                                    lappend ixn_transmit_distrib_list "${ixn_transmit_distrib}0"
                                }
                            }
                        } else {
                            if {[lsearch $ixn_transmit_distrib_list $ixn_transmit_distrib] == -1} {
                                lappend ixn_transmit_distrib_list $ixn_transmit_distrib
                            }
                        }
                    } elseif {[lsearch $available_transmit_distrib $td_type] != -1} {
                        # IxN distribution parameter type
                        lappend ixn_transmit_distrib_list $td_type
                    } else {
                        # this distribution is not valid
                        if {[info exists rollback_list] && [info exists mode]} {
                            540trafficRollback $rollback_list $mode
                        }
                        keylset returnList status $::FAILURE
                        keylset returnList log "The -transmit_distribution argument $td_type \
                                is not a valid value for the configured traffic item."
                        return $returnList
                    }
                }
            }
            lappend ixn_args -distributions $ixn_transmit_distrib_list
        }

        if {[llength $ixn_args] > 0} {
            set result [ixNetworkNodeSetAttr ${traffic_item_objref}/transmissionDistribution \
                    $ixn_args -commit]
            if {[keylget result status] == $::FAILURE} {
                if {[info exists rollback_list] && [info exists mode]} {
                    540trafficRollback $rollback_list $mode
                }
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure $ixn_args - [keylget result log]."
                return $returnList
            }
            
        }
        
        if {$commit_needed} {
            set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            catch {unset commit_needed}
        }
        
        set retCode [540IxNetTrafficGenerate $traffic_item_objref]
        if {[keylget retCode status] != $::SUCCESS} {
            if {[info exists rollback_list] && [info exists mode]} {
                540trafficRollback $rollback_list $mode
            }
            return $retCode
        }

        set ret_code [540IxNetTrafficReturnHandles $traffic_item_objref]
        # ret_code contains either a failure with status and log or success with all the return keys needed
        if {[keylget ret_code status] != $::SUCCESS} {
            if {[info exists rollback_list] && [info exists mode]} {
#                 540trafficRollback $rollback_list $mode
            }
        }
        return $ret_code
    } elseif {[info exists handle]} {
        
        if {$mode == "modify"} {
            if { [isThisAQuickFlowItem $handle] } {
                set tryingTo [getMeHighLevelStreamFrom $handle]
                if { [keylget tryingTo status] != $::SUCCESS} { return $tryingTo }
                set qf_args ""
                set var_list_qf [getVarListFromArgs $opt_args_quick_flows]
                foreach var_fs $var_list_qf {
                    if {[info exists $var_fs] && $var_fs != "mode" && $var_fs != "handle"} {
                        set var_fs_value [set $var_fs]
                        if {[llength $var_fs_value]} {
                            lappend qf_args -$var_fs \{$var_fs_value\}
                        } else {
                            lappend qf_args -$var_fs $var_fs_value
                        }
                    }
                }
                if {[llength $qf_args] >= 0} {
                    lappend qf_args -mode $mode
                    lappend qf_args -handle [keylget tryingTo handle]
                    set qf_status [540quickFlowsConfig $qf_args $opt_args_quick_flows]
                    if {[keylget qf_status status] != $::SUCCESS} { return $qf_status }
                }
            } else {
                # Do nothing...
            }
            
            set traffic_item_objref [ixNetworkGetParentObjref $handle "trafficItem"]
            
            if {$traffic_item_objref == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to extract trafficItem handle from '$handle'."
                return $returnList
            }
            
            set ixn_args ""
            
            if {[info exists tx_mode]} {
                switch -- $tx_mode {
                    "advanced" {
                        set vport_transmit_mode "interleaved"
                    }
                    "stream" {
                        set vport_transmit_mode "sequential"
                    }
                }
            
            
                if {[ixNet getAttribute $traffic_item_objref -transmitMode] != $vport_transmit_mode} {
                    lappend ixn_args -transmitMode $vport_transmit_mode
                }
            }
            
            if {[llength $ixn_args] > 0} {
                
                set result [ixNetworkNodeSetAttr $traffic_item_objref \
                        $ixn_args -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to configure $ixn_args - [keylget result log]."
                    return $returnList
                }
                
            }
            
            set ixn_args ""
            
            set ret_code [540trafficGetTxDistributionObj $handle]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set tx_distrib_obj [keylget ret_code handle]
            
            if {[llength $tx_distrib_obj] > 0} {
                # The only case when this will happen is if $handle is a high level stream (or a child)
                # AND the high level stream packet was modified (and not it doesn't match any of the config elements)
                # In this case, don't configure tx distribution. A trafic item or config element handle would be more
                # appropriate for this operation.
                
                if {[info exists stream_packing] && (![info exists transmit_distribution] || [is_default_param_value "transmit_distribution" $args])} {
                    switch -- $stream_packing {
                        merge_destination_ranges -
                        one_stream_per_endpoint_pair {
                            set transmit_distribution "endpoint_pair"
                        }
                        optimal_packing {
                            set transmit_distribution "none"
                        }
                    }
                }
                
                if {[info exists transmit_distribution]} {
                    if {[lsearch $transmit_distribution "none"] != -1} {
                        set ixn_transmit_distrib_list {}
                    } else {
    
                        set available_transmit_distrib [ixNet getA $tx_distrib_obj -availableDistributions]
                        set ixn_transmit_distrib_list {}
                        
                        foreach td_type $transmit_distribution {
                            
                            if {[info exists transmit_distribution_map($td_type)]} {
                                # hlt distribution parameter type - for backward compatibility
                                # ixn_transmit_distrib_list
                                set ixn_transmit_distrib $transmit_distribution_map($td_type)
                                
                                if {[lsearch $available_transmit_distrib $ixn_transmit_distrib] == -1} {
                                    set search_cmd "lsearch -regexp \{$available_transmit_distrib\} \
                                            \{${ixn_transmit_distrib}\\d+\}"
                                    debug "--> eval $search_cmd"
                                    if {[eval $search_cmd] == -1} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Transmit distribution $td_type\
                                            is not supported for this configuration. Possible cause: \
                                            transmit distribution type is not present in any of\
                                            the stream headers configured."
                                        return $returnList
                                    } else {
                                        # The '0' at the end is not a typo. It's signifies the first header for which this
                                        # td is valid
                                        if {[lsearch $ixn_transmit_distrib_list "${ixn_transmit_distrib}0"] == -1} {
                                            lappend ixn_transmit_distrib_list "${ixn_transmit_distrib}0"
                                        }
                                    }
                                } else {
                                    if {[lsearch $ixn_transmit_distrib_list $ixn_transmit_distrib] == -1} {
                                        lappend ixn_transmit_distrib_list $ixn_transmit_distrib
                                    }
                                }
                            } elseif {[lsearch $available_transmit_distrib $td_type] != -1} {
                                # IxN distribution parameter type
                                lappend ixn_transmit_distrib_list $td_type
                            } else {
                                # this distribution is not valid
                                keylset returnList status $::FAILURE
                                keylset returnList log "The -transmit_distribution argument $td_type \
                                        is not a valid value for the configured traffic item."
                                return $returnList
                            }
                        }
                    }
                    
                    lappend ixn_args -distributions $ixn_transmit_distrib_list
                }
                
                if {[llength $ixn_args] > 0} {
                    
                    set result [ixNetworkNodeSetAttr $tx_distrib_obj \
                            $ixn_args -commit]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to configure $ixn_args - [keylget result log]."
                        return $returnList
                    }
                    
                }
            }
        }
        
        if {$commit_needed} {
            set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            catch {unset commit_needed}
        }
        
        set retCode [540IxNetTrafficGenerate $handle]
        if {[keylget retCode status] != $::SUCCESS} {
            if {[info exists rollback_list] && [info exists mode]} {
                540trafficRollback $rollback_list $mode
            }
            return $retCode
        }
        
        set ret_code [540IxNetTrafficReturnHandles $handle]
        # ret_code contains either a failure with status and log or success with all the return keys needed
        keylset ret_code last_stack [keylget returnList last_stack]
        return $ret_code
    }

    return $returnList
}


##Internal Procedure Header
#
# Description:
#   This is an internal procedure that generates the list of scalable destinations
#   for a given endpoint.
#
# Input:
#   type    The type of scalable handle to create. This is used to determine what
#           arrays need to be upvar-ed in order to build the scalable handle.
#           Must be either dst or src
#   index   This argument is the index used to identify the enpoint in the
#           arrays that define the scalable destinations.
#
# Upvar args:
#   arg_emulation_scalable_${type}_handle
#           An array containing the individual handles used to build the scalable handle
#   arg_emulation_scalable_${type}_port_start
#           An array containing the starting ports for each scalable handles
#   arg_emulation_scalable_${type}_port_count
#           An array containing the number of ports for each scalable handles
#   arg_emulation_scalable_${type}_intf_start
#           An array containing the starting interfaces for scalable handles
#   arg_emulation_scalable_${type}_intf_count
#           An array containing the number of interfaces for scalable handles
#
# Returns:
#   The list of scalable destinations for the endpointset identified by index
#
# Note:
#   KEEP THE ORDER OF THE PARAMS
#
namespace eval ::ixia::540trafficConfig {}
proc ::ixia::540trafficConfig::make_scalable_handle { type index } {

    set scalableResult [list ]    

    upvar arg_emulation_scalable_${type}_handle scalable_handle
    if {[info exists scalable_handle] && [info exists scalable_handle($index)]} {
            
        set scalable_handle_count [llength $scalable_handle($index)]
        
        upvar arg_emulation_scalable_${type}_port_start port_start
        if {![info exists port_start] || ![info exists port_start($index)]} {
            for {set tmpIndex 0} {$tmpIndex < $scalable_handle_count} {incr tmpIndex} {
                lappend local_port_start 1
            }
        } else {
            set local_port_start $port_start($index)
        }
        
        upvar arg_emulation_scalable_${type}_port_count port_count
        if {![info exists port_count] || ![info exists port_count($index)]} {
            for {set tmpIndex 0} {$tmpIndex < $scalable_handle_count} {incr tmpIndex} {
                lappend local_port_count 1
            }
        } else {
            set local_port_count $port_count($index)
        }
        
        upvar arg_emulation_scalable_${type}_intf_start intf_start
        if {![info exists intf_start] || ![info exists intf_start($index)]} {
            for {set tmpIndex 0} {$tmpIndex < $scalable_handle_count} {incr tmpIndex} {
                lappend local_intf_start 1
            }
        } else {
            set local_intf_start $intf_start($index)
        }
        
        upvar arg_emulation_scalable_${type}_intf_count intf_count
        if {![info exists intf_count] || ![info exists intf_count($index)]} {
            for {set tmpIndex 0} {$tmpIndex < $scalable_handle_count} {incr tmpIndex} {
                lappend local_intf_count 1
            }
        } else {
            set local_intf_count $intf_count($index)
        }
        
        foreach scalable_item_handle $scalable_handle($index)     \
                dst_port_start $local_port_start                \
                dst_port_count $local_port_count                \
                dst_intf_start $local_intf_start                \
                dst_intf_count $local_intf_count                \
        {
            foreach inner_scalable_item_handle $scalable_item_handle     \
            inner_dst_port_start $dst_port_start                \
            inner_dst_port_count $dst_port_count                \
            inner_dst_intf_start $dst_intf_start                \
            inner_dst_intf_count $dst_intf_count                \
            {
                lappend scalableResult [format "%s %u %u %u %u" $inner_scalable_item_handle $inner_dst_port_start $inner_dst_port_count $inner_dst_intf_start $inner_dst_intf_count]
            }
        }
    }
    
    return $scalableResult
}

##Internal Procedure Header
#
# Description:
#   This is an internal procedure that populates an array with all the indexes found
#   in a list of arrays array.
#
# Input:
#   indexes      An array that will contain all the indexes present in the previous
#                list of arrays.
#   upvarList    A list of arrays whose indexes we will merge into the indexes array
#
# Note:
#   KEEP THE ORDER OF THE PARAMS
#    
proc ::ixia::540trafficConfig::make_scalable_indexes_array { indexes upvarList } {

    ::ixia::util::upvar_variable_list $upvarList
    
    upvar 1 $indexes $indexes
    if {[info exists $indexes]} {
        unset $indexes
    }
    set indexList [list ]
    
    foreach inputArray $upvarList {
        set indexList [union $indexList [array names $inputArray]]
    }    
    
    foreach index $indexList {
        array set $indexes [list $index 0]
    }
}
