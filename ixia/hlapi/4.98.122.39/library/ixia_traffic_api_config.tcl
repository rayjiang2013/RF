proc ::ixia::traffic_config {args} {
    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::traffic_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable current_streamid
    variable pgid_to_stream
    variable atmStatsConfig
    variable new_ixnetwork_api
    variable tgen_offset_value
    variable stream_to_queue_map
    variable port_queue_num
    variable frameGapMessage
    variable ixn_traffic_version
    variable ixnetwork_rp2vp_handles_array
    catch {unset frameGapMessage}

    ::ixia::utrackerLog $procName $args
    
#     set frame_size_gaus_regex              "(^([0-9]+:[0-9]+(\.[0-9])*:[0-9]+ ){0,3}[0-9]+:[0-9]+(\.[0-9])*:[0-9]+$)|(^([0-9]+(\.[0-9])*:[0-9]+(\.[0-9])*:[0-9]+ ){0,3}[0-9]+(\.[0-9])*:[0-9]+(\.[0-9])*:[0-9]+$)"
    
    set man_args {
        -mode                               CHOICES create modify remove reset 
                                            CHOICES enable disable append_header modify_or_insert
                                            CHOICES prepend_header replace_header
                                            CHOICES dynamic_update
                                            CHOICES get_available_protocol_templates
                                            CHOICES get_available_fields get_field_values set_field_values
                                            CHOICES add_field_level remove_field_level
                                            CHOICES get_available_session_aware_traffic
                                            CHOICES get_available_dynamic_update_fields
                                            CHOICES get_available_fields_for_link 
    }

    set opt_args {
        -adjust_rate                        CHOICES 0 1
                                            DEFAULT 0
        -allow_self_destined                CHOICES 0 1
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
        -atm_header_aal5error               CHOICES no_error bad_crc
        -atm_header_cell_loss_priority      CHOICES 0 1
        -atm_header_cpcs_length             RANGE   28-65535
        -atm_header_enable_auto_vpi_vci     CHOICES 0 1
        -atm_header_enable_cl               CHOICES 0 1
        -atm_header_enable_cpcs_length      CHOICES 0 1
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
        -atm_header_generic_flow_ctrl       RANGE   0-15
        -atm_header_hec_errors              RANGE   0-8
        -atm_counter_vpi_data_item_list     ANY
        -atm_counter_vci_data_item_list     ANY
        -atm_counter_vpi_mask_select        ANY
        -atm_counter_vci_mask_select        ANY
        -atm_counter_vpi_mask_value         ANY
        -atm_counter_vci_mask_value         ANY
        -atm_counter_vpi_mode               CHOICES incr cont_incr decr 
                                            CHOICES cont_decr
        -atm_counter_vci_mode               CHOICES incr cont_incr decr 
                                            CHOICES cont_decr
        -atm_counter_vpi_type               CHOICES fixed counter random table
        -atm_counter_vci_type               CHOICES fixed counter random table
        -atm_range_count
        -becn                               FLAG
        -bidirectional                      CHOICES 0 1
        -burst_loop_count
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
                                            CHOICES fc
                                            CHOICES multicast_igmp
        -command_response                   FLAG
        -convert_to_raw                     CHOICES 0 1
        -custom_offset                      NUMERIC
        -data_pattern
        -data_pattern_mode                  CHOICES incr_byte decr_byte fixed 
                                            CHOICES random repeating incr_word 
                                            CHOICES decr_word
        -data_tos                           RANGE   0-127
        -destination_filter
        -dhcp_option                        CHOICES dhcp_pad
                                            CHOICES dhcp_end
                                            CHOICES dhcp_subnet_mask
                                            CHOICES dhcp_time_offset
                                            CHOICES dhcp_gateways
                                            CHOICES dhcp_time_server
                                            CHOICES dhcp_name_server
                                            CHOICES dhcp_domain_name_server
                                            CHOICES dhcp_log_server
                                            CHOICES dhcp_cookie_server
                                            CHOICES dhcp_lpr_server
                                            CHOICES dhcp_impress_server
                                            CHOICES dhcp_resource_location_server
                                            CHOICES dhcp_host_name
                                            CHOICES dhcp_boot_file_size
                                            CHOICES dhcp_merit_dump_file
                                            CHOICES dhcp_domain_name
                                            CHOICES dhcp_swap_server
                                            CHOICES dhcp_root_path
                                            CHOICES dhcp_extension_path
                                            CHOICES dhcp_ip_forwarding_enable
                                            CHOICES dhcp_non_local_src_routing_enable
                                            CHOICES dhcp_policy_filter
                                            CHOICES dhcp_max_datagram_reassembly_size
                                            CHOICES dhcp_default_ip_ttl
                                            CHOICES dhcp_path_mtu_aging_timeout
                                            CHOICES dhcp_path_mtu_plateau_table
                                            CHOICES dhcp_interface_mtu
                                            CHOICES dhcp_all_subnets_are_local
                                            CHOICES dhcp_broadcast_address
                                            CHOICES dhcp_perform_mask_discovery
                                            CHOICES dhcp_mask_supplier
                                            CHOICES dhcp_perform_router_discovery
                                            CHOICES dhcp_router_solicit_addr
                                            CHOICES dhcp_static_route
                                            CHOICES dhcp_trailer_encapsulation
                                            CHOICES dhcp_arp_cache_timeout
                                            CHOICES dhcp_ethernet_encapsulation
                                            CHOICES dhcp_tcp_default_ttl
                                            CHOICES dhcp_tcp_keep_alive_interval
                                            CHOICES dhcp_tcp_keep_garbage
                                            CHOICES dhcp_nis_domain
                                            CHOICES dhcp_nis_server
                                            CHOICES dhcp_ntp_server
                                            CHOICES dhcp_vendor_specific_info
                                            CHOICES dhcp_net_bios_name_svr
                                            CHOICES dhcp_net_bios_datagram_dist_svr
                                            CHOICES dhcp_net_bios_node_type
                                            CHOICES dhcp_net_bios_scope
                                            CHOICES dhcp_xwin_sys_font_svr
                                            CHOICES dhcp_requested_ip_addr
                                            CHOICES dhcp_ip_addr_lease_time
                                            CHOICES dhcp_option_overload
                                            CHOICES dhcp_tftp_svr_name
                                            CHOICES dhcp_boot_file_name
                                            CHOICES dhcp_message_type
                                            CHOICES dhcp_svr_identifier
                                            CHOICES dhcp_param_request_list
                                            CHOICES dhcp_message
                                            CHOICES dhcp_max_message_size
                                            CHOICES dhcp_renewal_time_value
                                            CHOICES dhcp_rebinding_time_value
                                            CHOICES dhcp_vendor_class_id
                                            CHOICES dhcp_client_id
                                            CHOICES dhcp_xwin_sys_display_mgr
                                            CHOICES dhcp_nis_plus_domain
                                            CHOICES dhcp_nis_plus_server
                                            CHOICES dhcp_mobile_ip_home_agent
                                            CHOICES dhcp_smtp_svr
                                            CHOICES dhcp_pop3_svr
                                            CHOICES dhcp_nntp_svr
                                            CHOICES dhcp_www_svr
                                            CHOICES dhcp_default_finger_svr
                                            CHOICES dhcp_default_irc_svr
                                            CHOICES dhcp_street_talk_svr
                                            CHOICES dhcp_stda_svr
                                            CHOICES dhcp_agent_information_option
                                            CHOICES dhcp_netware_ip_domain
                                            CHOICES dhcp_network_ip_option
        -dhcp_option_data                   ANY
        -discard_eligible                   FLAG
        -dlci_core_enable                   FLAG
        -dlci_core_value                    RANGE 0-63
        -dlci_count_mode                    CHOICES increment cont_increment 
                                            CHOICES decrement cont_decrement 
                                            CHOICES idle random
        -dlci_mask_value                    HEX
        -dlci_mask_select                   HEX
        -dlci_repeat_count                  NUMERIC
        -dlci_repeat_count_step             NUMERIC
        -dlci_size                          RANGE 2-4
        -dlci_value                         NUMERIC
        -dlci_value_step                    NUMERIC
        -duration                           NUMERIC
                                            DEFAULT 10
        -dlci_extended_address0             FLAG
        -dlci_extended_address1             FLAG
        -dlci_extended_address2             FLAG
        -dlci_extended_address3             FLAG
        -dynamic_update_fields              CHOICES ppp ppp_dst dhcp4 dhcp4_dst dhcp6 dhcp6_dst mpls_label_value
        -emulation_dst_handle
        -emulation_dst_vlan_protocol_tag_id REGEXP ^[0-9a-fA-F]{4}$
        -emulation_override_ppp_ip_addr     CHOICES upstream downstream both none
                                            DEFAULT none
        -emulation_multicast_dst_handle
        -emulation_multicast_dst_handle_type
        -emulation_multicast_rcvr_handle
        -emulation_multicast_rcvr_port_index NUMERIC
        -emulation_multicast_rcvr_host_index NUMERIC
        -emulation_multicast_rcvr_mcast_index NUMERIC
        -emulation_src_handle
        -emulation_src_vlan_protocol_tag_id REGEXP ^[0-9a-fA-F]{4}$
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
        -enable_auto_detect_instrumentation CHOICES 0 1
        -enable_ce_to_pe_traffic            CHOICES 0 1
                                            DEFAULT 0
        -enable_data                        CHOICES 0 1
                                            DEFAULT 0
        -enable_data_integrity              CHOICES 0 1
        -enable_dynamic_mpls_labels         CHOICES 0 1
        -enable_override_value              CHOICES 0 1
                                            DEFAULT 0
        -enable_pgid                        CHOICES 0 1
        -enable_test_objective              CHOICES 0 1
                                            DEFAULT 0
        -enable_time_stamp                  CHOICES 0 1
                                            DEFAULT 1
        -enable_udf1                        CHOICES 0 1
        -enable_udf2                        CHOICES 0 1
        -enable_udf3                        CHOICES 0 1
        -enable_udf4                        CHOICES 0 1
        -enable_udf5                        CHOICES 0 1
        -enable_voice                       CHOICES 0 1
                                            DEFAULT 0
        -endpointset_count                  NUMERIC
                                            DEFAULT 1
        -enforce_min_gap                    NUMERIC
        -ethernet_type                      CHOICES ethernetII ieee8023snap 
                                            CHOICES ieee8023 ieee8022
        -ethernet_value                     HEX
        -ethernet_value_mode                CHOICES fixed incr decr list
                                            DEFAULT fixed
        -ethernet_value_step                HEX
                                            DEFAULT 0x01
        -ethernet_value_count               NUMERIC
                                            DEFAULT 1
        -ethernet_value_tracking            CHOICES 0 1
        -fecn                               FLAG
        -fcs                                CHOICES 0 1
        -fcs_type                           CHOICES alignment dribble bad_CRC 
                                            CHOICES no_CRC
        -field_handle                       
        -field_activeFieldChoice            CHOICES 0 1
                                            DEFAULT 1
        -field_auto                         CHOICES 0 1
                                            DEFAULT 0
        -field_countValue                   ANY
        -field_fieldValue                   ANY
        -field_fullMesh                     CHOICES 0 1
                                            DEFAULT 0
        -field_linked                       ANY
        -field_linked_to                    ANY
        -field_optionalEnabled              CHOICES 0 1
                                            DEFAULT 0
        -field_singleValue                  ANY
        -field_startValue                   ANY
        -field_stepValue                    ANY
        -field_trackingEnabled              CHOICES 0 1
                                            DEFAULT 0
        -field_valueList                    ANY
        -field_valueType                    ANY
        -fr_range_count
        -frame_rate_distribution_port       CHOICES apply_to_all split_evenly
                                            DEFAULT split_evenly
        -frame_rate_distribution_stream     CHOICES apply_to_all split_evenly
        -frame_sequencing                   CHOICES enable disable
        -frame_sequencing_offset
        -frame_size                         RANGE   12-13312
        -frame_size_max                     RANGE   12-13312
        -frame_size_min                     RANGE   12-13312
        -frame_size_step                    RANGE   0-13292
        -frame_size_distribution            CHOICES cisco imix quadmodal tolly
                                            CHOICES trimodal imix_ipsec imix_ipv6
                                            CHOICES imix_std imix_tcp
        -frame_size_gauss                   REGEXP (^([0-9]+:[0-9]+(\.[0-9])*:[0-9]+ ){0,3}[0-9]+:[0-9]+(\.[0-9])*:[0-9]+$)|(^([0-9]+(\.[0-9])*:[0-9]+(\.[0-9])*:[0-9]+ ){0,3}[0-9]+(\.[0-9])*:[0-9]+(\.[0-9])*:[0-9]+$)
        -frame_size_imix                    REGEXP ^([0-9]+:[0-9]+ )*[0-9]+:[0-9]+$
        -global_dest_mac_retry_count        RANGE   1-2147483647
        -global_dest_mac_retry_delay        RANGE   1-2147483647
        -global_enable_dest_mac_retry       CHOICES 0 1
        -global_enable_min_frame_size       CHOICES 0 1
        -global_enable_staggered_transmit   CHOICES 0 1
        -global_enable_stream_ordering      CHOICES 0 1
        -global_stream_control              CHOICES continuous iterations
        -global_stream_control_iterations   RANGE   1-2147483647
        -global_large_error_threshhold      NUMERIC
        -global_enable_mac_change_on_fly    CHOICES 0 1
        -global_max_traffic_generation_queries     NUMERIC
        -global_display_mpls_current_label_value   CHOICES 0 1
        -global_mpls_label_learning_timeout NUMERIC
        -global_refresh_learned_info_before_apply  CHOICES 0 1
        -global_use_tx_rx_sync              CHOICES 0 1
        -global_wait_time                   RANGE   1-2147483647
        -global_frame_ordering              CHOICES flow_group_setup none peak_loading rfc2889
        -global_peak_loading_replication_count      NUMERIC
        -gre_valid_checksum_enable          CHOICES 0 1
        -header_handle
        -host_behind_network                IP
        -hosts_per_net                      NUMERIC
        -indirect
        -inner_ipv6_dst_mask                RANGE   0-128
        -inner_ipv6_src_mask                RANGE   0-128       
        -integrity_signature
        -integrity_signature_offset         RANGE   12-65535
        -inter_burst_gap
        -inter_frame_gap                    NUMERIC
        -inter_frame_gap_unit               CHOICES bytes ns
        -inter_stream_gap
        -intf_handle
        -ip_cost                            CHOICES 0 1
        -ip_delay                           CHOICES 0 1
        -ip_dscp                            RANGE   0-63
        -ip_dst_addr                        IP
        -ip_dst_count                       RANGE   1-4294967295
        -ip_dst_count_step
        -ip_dst_increment
        -ip_dst_increment_step
        -ip_dst_prefix_len
        -ip_dst_prefix_len_step
        -ip_dst_range_step
        -ip_dst_step                        IP
        -ip_fragment                        CHOICES 0 1
        -ip_fragment_last                   CHOICES more last 0 1
        -ip_fragment_offset                 RANGE   0-8191
        -ip_id                              RANGE   0-65535
        -ip_length_override                 CHOICES 0 1
        -ip_opt_loose_routing               IP
        -ip_opt_security
        -ip_opt_strict_routing              IP
        -ip_opt_timestamp
        -ip_precedence                      RANGE   0-7
        -ip_protocol                        RANGE   0-255
        -ip_range_count
        -ip_reliability                     CHOICES 0 1
        -ip_reserved                        CHOICES 0 1
        -ip_src_addr                        IP
        -ip_src_count                       RANGE   1-4294967295
        -ip_src_mode                        CHOICES fixed increment decrement 
                                            CHOICES random emulation list
        -ip_src_step                        IP
        -ip_throughput                      CHOICES 0 1
        -ip_total_length                    RANGE   0-65535
        -ip_ttl                             RANGE   0-255
        -ipv6_frag_res_8bit                 ANY
                                            DEFAULT 30
        -ipv6_frag_res_8bit_count           NUMERIC  
        -ipv6_frag_res_8bit_mode            CHOICES fixed incr decr list
        -ipv6_frag_res_8bit_step            RANGE   0-254
        -ipv6_frag_res_8bit_tracking        CHOICES 0 1  
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
                                            DEFAULT fixed
        -isl_frame_type_tracking            CHOICES 0 1
        -isl_index
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
        -isl_user_priority_step             RANGE   0-6
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
                                            DEFAULT 00.00.00.00.01
        -isl_mac_dst_count                  NUMERIC
                                            DEFAULT 1
        -isl_mac_dst_tracking               CHOICES 0 1
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
        -l3_protocol                        CHOICES ipv4 ipv6 arp pause_control 
                                            CHOICES ipx none
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
                                            RANGE   0-255
        -l7_traffic                         CHOICES 0 1
                                            DEFAULT 0
        -lan_range_count
        -latency_bins_enable                CHOICES 0 1
                                            DEFAULT 0
        -latency_bins                       RANGE   2-16
        -latency_values                     DECIMAL
        -length_mode                        CHOICES fixed increment random auto 
                                            CHOICES imix gaussian quad 
                                            CHOICES distribution
        -loop_count
        -mac_dst
        -mac_dst2
        -mac_dst_count                      RANGE   0-4294967295
        -mac_dst_count_step
        -mac_dst_mask                       MAC
        -mac_dst_seed                       NUMERIC
        -mac_dst_tracking                   CHOICES 0 1
        -mac_src_tracking                   CHOICES 0 1
        -mac_dst_mode                       CHOICES fixed increment decrement
                                            CHOICES discovery random list repeatable_random
        -mac_dst_step
        -mac_src
        -mac_src2
        -mac_src_count                      NUMERIC
        -mac_src_mode                       CHOICES fixed increment decrement 
                                            CHOICES random emulation list repeatable_random
        -mac_src_step
        -mac_src_mask                       MAC
        -mac_src_seed                       NUMERIC
        -min_gap_bytes                      RANGE 1-2147483647
        -mpls                               CHOICES enable disable
        -mpls_bottom_stack_bit              CHOICES 0 1
                                            DEFAULT 1
        -mpls_bottom_stack_bit_tracking     CHOICES 0 1
        -mpls_bottom_stack_bit_mode         CHOICES fixed incr decr list
        -mpls_bottom_stack_bit_step         NUMERIC
        -mpls_bottom_stack_bit_count        NUMERIC
        -mpls_exp_bit                       REGEXP  (([0-7]\,)*[0-7])
                                            DEFAULT 0
        -mpls_exp_bit_mode                  CHOICES fixed incr decr list
                                            DEFAULT fixed
        -mpls_exp_bit_step                  RANGE   1-6
                                            DEFAULT 1
        -mpls_exp_bit_count                 RANGE   1-8
                                            DEFAULT 1
        -mpls_exp_bit_tracking              CHOICES 0 1
        -mpls_labels_mode                   CHOICES fixed incr decr
                                            DEFAULT fixed
        -mpls_labels_step                   NUMERIC
                                            DEFAULT 1
        -mpls_labels_count                  NUMERIC
                                            DEFAULT 1
        -mpls_labels_tracking               CHOICES 0 1
        -mpls_labels
        -mpls_ttl
        -mpls_ttl_mode                      CHOICES fixed incr decr
                                            DEFAULT fixed
        -mpls_ttl_step                      RANGE   0-254
                                            DEFAULT 1
        -mpls_ttl_count                     RANGE   1-256
                                            DEFAULT 1
        -mpls_ttl_tracking                  CHOICES 0 1
        -mpls_type                          CHOICES unicast multicast
        -multiple_queues                    FLAG
        -name
        -tag_filter                         ANY
        -no_write
        -num_dst_ports                      NUMERIC
        -number_of_packets_per_stream       RANGE   1-9999999999
        -number_of_packets_tx
        -override_value_list
        -pause_control_time                 RANGE   0-65535
        -pending_operations_timeout         NUMERIC
                                            DEFAULT 60
        -pgid_value
        -pgid_offset                        RANGE   4-32677
        -pkts_per_burst
        -port_handle                        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -port_handle2                       REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -pppoe_unique_acmac                 CHOICES 0 1
                                            DEFAULT 0
        -preamble_size_mode                 CHOICES auto custom
                                            DEFAULT auto
        -preamble_custom_size               NUMERIC
                                            DEFAULT 6
        -pt_handle                          
        -public_port_ip                     IP
        -pvc_count
        -pvc_count_step
        -qos_atm_clp                        CHOICES 0 1
        -qos_atm_cr                         CHOICES 0 1
        -qos_atm_efci                       CHOICES 0 1
        -qos_byte                           RANGE   0-127
        -qos_fr_cr                          CHOICES 0 1
        -qos_fr_becn                        CHOICES 0 1
        -qos_fr_de                          CHOICES 0 1
        -qos_fr_fecn                        CHOICES 0 1
        -qos_rate_mode                      CHOICES percent pps bps
        -qos_rate                           NUMERIC
        -qos_type_ixn                       CHOICES custom dscp tos ipv6
        -qos_value_ixn                      ANY
        -queue_id                           NUMERIC
        -ramp_up_percentage                 NUMERIC
        -range_per_spoke
        -rate_bps
        -rate_percent                       RANGE   0-100
        -rate_frame_gap                     RANGE   0-100
        -rate_pps
        -return_to_id
        -route_mesh                         CHOICES fully one_to_one
        -session_repeat_count               RANGE   1-8000
                                            DEFAULT 1
        -session_aware_traffic              CHOICES ppp dhcp4 dhcp6
        -session_traffic_stats              CHOICES 0 1
                                            DEFAULT 0
        -signature
        -signature_offset                   RANGE   8-64000
        -site_id
        -site_id_enable
        -site_id_step
        -skip_frame_size_validation         FLAG
        -source_filter
        -src_dest_mesh                      CHOICES fully many_to_many one_to_one none
        -stack_index                        NUMERIC
        -stream_id
        -stream_packing                     CHOICES merge_destination_ranges
                                            CHOICES one_stream_per_endpoint_pair
                                            CHOICES optimal_packing
        -table_udf_column_name
        -table_udf_column_offset
        -table_udf_column_size
        -table_udf_column_type              CHOICES hex ascii binary decimal mac
                                            CHOICES ipv4 ipv6
                                            CHOICES REGEXP ^([0-9]+[a|b|d|x].)*[0-9]+[a|b|d|x]$
        -table_udf_rows
        -test_objective_value               NUMERIC
        -track_by                           ANY
        -traffic_generator                  CHOICES ixos ixnetwork ixaccess ixnetwork_540
                                            DEFAULT ixaccess
        -traffic_generate                   CHOICES 0 1
                                            DEFAULT 1
        -transmit_mode                      CHOICES continuous random_spaced
                                            CHOICES single_pkt single_burst
                                            CHOICES multi_burst continuous_burst
                                            CHOICES return_to_id advance
                                            CHOICES return_to_id_for_count
        -tx_delay                           NUMERIC
        -tx_mode                            CHOICES advanced stream
        -udf1_mode                          CHOICES counter random value_list
                                            CHOICES range_list nested ipv4
        -udf1_offset                        NUMERIC
        -udf1_counter_type                  CHOICES 8 16 24 32
        -udf1_chain_from                    CHOICES udfNone udf1 udf2 udf3 udf4 
                                            CHOICES udf5
                                            DEFAULT udfNone
        -udf1_counter_up_down               CHOICES up down
        -udf1_counter_init_value
        -udf1_counter_repeat_count
        -udf1_counter_step
        -udf1_value_list
        -udf1_counter_mode                  CHOICES continuous count
        -udf1_inner_repeat_value            RANGE   1-16777216
        -udf1_inner_repeat_count            RANGE   1-255
        -udf1_inner_step                    NUMERIC
        -udf1_enable_cascade                CHOICES 0 1
                                            DEFAULT 0
        -udf1_cascade_type                  CHOICES none from_previous 
                                            CHOICES from_shelf
                                            DEFAULT none
        -udf1_skip_zeros_and_ones           CHOICES 0 1
                                            DEFAULT 1
        -udf1_mask_select                   HEX
                                            DEFAULT 0000
        -udf1_mask_val                      HEX
                                            DEFAULT 0000
        -udf1_skip_mask_bits                RANGE   2-8
                                            DEFAULT 8
        -udf2_mode                          CHOICES counter random value_list
                                            CHOICES range_list nested ipv4
        -udf2_offset                        NUMERIC
        -udf2_counter_type                  CHOICES 8 16 24 32
        -udf2_chain_from                    CHOICES udfNone udf1 udf2 udf3 udf4 
                                            CHOICES udf5
                                            DEFAULT udfNone
        -udf2_counter_up_down               CHOICES up down
        -udf2_counter_init_value
        -udf2_counter_repeat_count          NUMERIC
        -udf2_counter_step                  NUMERIC
        -udf2_value_list
        -udf2_counter_mode                  CHOICES continuous count
        -udf2_inner_repeat_value            RANGE   1-16777216
        -udf2_inner_repeat_count            RANGE   1-255
        -udf2_inner_step                    NUMERIC
        -udf2_enable_cascade                CHOICES 0 1
                                            DEFAULT 0
        -udf2_cascade_type                  CHOICES none from_previous 
                                            CHOICES from_shelf
                                            DEFAULT none
        -udf2_skip_zeros_and_ones           CHOICES 0 1
                                            DEFAULT 1
        -udf2_mask_select                   HEX
                                            DEFAULT 0000
        -udf2_mask_val                      HEX
                                            DEFAULT 0000
        -udf2_skip_mask_bits                RANGE   2-8
                                            DEFAULT 8
        -udf3_mode                          CHOICES counter random value_list
                                            CHOICES range_list nested ipv4
        -udf3_offset                        NUMERIC
        -udf3_counter_type                  CHOICES 8 16 24 32
        -udf3_chain_from                    CHOICES udfNone udf1 udf2 udf3 udf4 
                                            CHOICES udf5
                                            DEFAULT udfNone
        -udf3_counter_up_down               CHOICES up down
        -udf3_counter_init_value
        -udf3_counter_repeat_count          NUMERIC
        -udf3_counter_step                  NUMERIC
        -udf3_value_list
        -udf3_counter_mode                  CHOICES continuous count
        -udf3_inner_repeat_value            RANGE   1-16777216
        -udf3_inner_repeat_count            RANGE   1-255
        -udf3_inner_step                    NUMERIC
        -udf3_enable_cascade                CHOICES 0 1
                                            DEFAULT 0
        -udf3_cascade_type                  CHOICES none from_previous 
                                            CHOICES from_shelf
                                            DEFAULT none
        -udf3_skip_zeros_and_ones           CHOICES 0 1
                                            DEFAULT 1
        -udf3_mask_select                   HEX
                                            DEFAULT 0000
        -udf3_mask_val                      HEX
                                            DEFAULT 0000
        -udf3_skip_mask_bits                RANGE   2-8
                                            DEFAULT 8
        -udf4_mode                          CHOICES counter random value_list
                                            CHOICES range_list nested ipv4
        -udf4_offset                        NUMERIC
        -udf4_counter_type                  CHOICES 8 16 24 32
        -udf4_chain_from                    CHOICES udfNone udf1 udf2 udf3 udf4 
                                            CHOICES udf5
                                            DEFAULT udfNone
        -udf4_counter_up_down               CHOICES up down
        -udf4_counter_init_value
        -udf4_counter_repeat_count          NUMERIC
        -udf4_counter_step                  NUMERIC
        -udf4_value_list
        -udf4_counter_mode                  CHOICES continuous count
        -udf4_inner_repeat_value            RANGE   1-16777216
        -udf4_inner_repeat_count            RANGE   1-255
        -udf4_inner_step                    NUMERIC
        -udf4_enable_cascade                CHOICES 0 1
                                            DEFAULT 0
        -udf4_cascade_type                  CHOICES none from_previous 
                                            CHOICES from_shelf
                                            DEFAULT none
        -udf4_skip_zeros_and_ones           CHOICES 0 1
                                            DEFAULT 1
        -udf4_mask_select                   HEX
                                            DEFAULT 0000
        -udf4_mask_val                      HEX
                                            DEFAULT 0000
        -udf4_skip_mask_bits                RANGE   2-8
                                            DEFAULT 8
        -udf5_mode                          CHOICES counter random value_list
                                            CHOICES range_list nested ipv4
        -udf5_offset                        NUMERIC
        -udf5_counter_type                  CHOICES 8 16 24 32
        -udf5_chain_from                    CHOICES udfNone udf1 udf2 udf3 udf4 
                                            CHOICES udf5
                                            DEFAULT udfNone
        -udf5_counter_up_down               CHOICES up down
        -udf5_counter_init_value
        -udf5_counter_repeat_count          NUMERIC
        -udf5_counter_step                  NUMERIC
        -udf5_value_list
        -udf5_counter_mode                  CHOICES continuous count
        -udf5_inner_repeat_value            RANGE   1-16777216
        -udf5_inner_repeat_count            RANGE   1-255
        -udf5_inner_step                    NUMERIC
        -udf5_enable_cascade                CHOICES 0 1
                                            DEFAULT 0
        -udf5_cascade_type                  CHOICES none from_previous 
                                            CHOICES from_shelf
                                            DEFAULT none
        -udf5_skip_zeros_and_ones           CHOICES 0 1
                                            DEFAULT 1
        -udf5_mask_select                   HEX
                                            DEFAULT 0000
        -udf5_mask_val                      HEX
                                            DEFAULT 0000
        -udf5_skip_mask_bits                RANGE   2-8
                                            DEFAULT 8
        -use_all_ip_subnets                 CHOICES 0 1
                                            DEFAULT 0
        -use_cp_size	                    CHOICES 0 1
                                            DEFAULT 1
		-use_cp_rate	                    CHOICES 0 1
                                            DEFAULT 1
        -variable_user_rate                 CHOICES 0 1
                                            DEFAULT 0
        -vci                                RANGE   0-65535
        -vci_increment
        -vci_increment_step
        -vci_count                          RANGE   0-65535
        -vci_step                           RANGE   0-65534
        -vlan                               CHOICES enable disable
        -vlan_cfi                           CHOICES 0 1
        -vlan_cfi_count                     NUMERIC
                                            DEFAULT 1
        -vlan_cfi_mode                      CHOICES fixed incr decr
                                            DEFAULT fixed
        -vlan_cfi_step                      NUMERIC
                                            DEFAULT 1
        -vlan_cfi_tracking                  CHOICES 0 1
        -vlan_enable
        -vlan_id                            RANGE   0-4095
        -vlan_id_tracking                   CHOICES 0 1
        -vlan_id_count                      RANGE   0-4095
        -vlan_id_mode                       CHOICES fixed increment decrement 
                                            CHOICES random nested_incr 
                                            CHOICES nested_decr list
        -vlan_id_step                       NUMERIC
        -vlan_protocol_tag_id               REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4}$)
        -vlan_protocol_tag_id_count         NUMERIC
                                            DEFAULT 1
        -vlan_protocol_tag_id_mode          CHOICES fixed incr decr list
                                            DEFAULT fixed
        -vlan_protocol_tag_id_step          HEX
                                            DEFAULT 0x01
        -vlan_protocol_tag_id_tracking      CHOICES 0 1
        -vlan_user_priority_count           NUMERIC
                                            DEFAULT 1
        -vlan_user_priority_mode            CHOICES fixed incr decr list
                                            DEFAULT fixed
        -vlan_user_priority_step            RANGE   0-6
                                            DEFAULT 1
        -vlan_user_priority_tracking        CHOICES 0 1
        -vlan_user_priority                 RANGE   0-7
        -vpi                                RANGE   0-4096
        -vpi_increment
        -vpi_increment_step
        -vpi_count                          RANGE   0-4096
        -vpi_step                           RANGE   0-4095
        -voice_tos                          RANGE   0-127
        -transmit_distribution              ANY
        -frame_sequencing_mode              CHOICES rx_switched_path rx_switched_path_fixed rx_threshold advanced
        -rate_kbps
        -rate_mbps
        -rate_byteps
        -rate_kbyteps
        -rate_mbyteps
        -rate_mode                          CHOICES first_option_provided percent pps bps kbps mbps byteps kbyteps mbyteps
                                            DEFAULT first_option_provided
        -tx_delay_unit                      CHOICES bytes ns
        -custom_values                      NUMERIC
        -egress_tracking                    CHOICES none dscp ipv6TC mplsExp custom custom_by_field outer_vlan_priority outer_vlan_id_4 outer_vlan_id_6 outer_vlan_id_8 outer_vlan_id_10 outer_vlan_id_12 inner_vlan_priority inner_vlan_id_4 inner_vlan_id_6 inner_vlan_id_8 inner_vlan_id_10 inner_vlan_id_12 tos_precedence ipv6TC_bits_0_2 ipv6TC_bits_0_5 vnTag_direction_bit vnTag_pointer_bit vnTag_looped_bit
        -egress_tracking_encap              CHOICES custom ethernet LLCRoutedCLIP LLCPPPoA LLCBridgedEthernetFCS LLCBridgedEthernetNoFCS VccMuxPPPoA VccMuxIPV4Routed VccMuxBridgedEthernetFCS VccMuxBridgedEthernetNoFCS pos_ppp pos_hdlc frame_relay1490 
        -egress_custom_offset               VCMD ::ixia::validate_egress_custom_offset
        -egress_custom_width                VCMD ::ixia::validate_egress_custom_width
        -egress_custom_field_offset         ANY
        -ip_dst_mode                        CHOICES fixed increment decrement random emulation list
        -ip_dst_tracking                    CHOICES 0 1
        -ip_fragment_mode                   CHOICES fixed list
                                            DEFAULT fixed
        -ip_fragment_tracking               CHOICES 0 1
        -ip_fragment_last_mode              CHOICES fixed list
                                            DEFAULT fixed
        -ip_fragment_last_tracking          CHOICES 0 1
        -ip_fragment_offset_count           NUMERIC
                                            DEFAULT 1
        -ip_fragment_offset_mode            CHOICES fixed incr decr list
                                            DEFAULT fixed
        -ip_fragment_offset_step            RANGE   0-8190
                                            DEFAULT 1
        -ip_fragment_offset_tracking        CHOICES 0 1
        -ip_id_count                        NUMERIC
                                            DEFAULT 1
        -ip_id_mode                         CHOICES fixed incr decr list
                                            DEFAULT fixed
        -ip_id_step                         RANGE   0-65534
                                            DEFAULT 1
        -ip_id_tracking                     CHOICES 0 1
        -ip_length_override_mode            CHOICES fixed list
                                            DEFAULT fixed
        -ip_length_override_tracking        CHOICES 0 1
        -ip_protocol_count                  NUMERIC
                                            DEFAULT 1
        -ip_protocol_mode                   CHOICES fixed incr decr list
                                            DEFAULT fixed
        -ip_protocol_step                   RANGE   0-254
                                            DEFAULT 1
        -ip_protocol_tracking               CHOICES 0 1
        -ip_reserved_mode                   CHOICES fixed list
                                            DEFAULT fixed
        -ip_reserved_tracking               CHOICES 0 1
        -ip_src_tracking                    CHOICES 0 1
        -ip_throughput_mode                 CHOICES fixed list
                                            DEFAULT fixed
        -ip_throughput_tracking             CHOICES 0 1
        -ip_total_length_count              NUMERIC
                                            DEFAULT 1
        -ip_total_length_mode               CHOICES fixed incr decr list auto
                                            DEFAULT fixed
        -ip_total_length_step               RANGE   0-65534
                                            DEFAULT 1
        -ip_total_length_tracking           CHOICES 0 1
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
                                            DEFAULT fixed
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
        -ip_hdr_length_tracking             CHOICES 0 1
        -qos_value_ixn_mode            CHOICES fixed incr decr list
                                       DEFAULT fixed
        -qos_value_ixn_step            NUMERIC
                                       DEFAULT 1
        -qos_value_ixn_count           NUMERIC
                                       DEFAULT 1
        -qos_value_ixn_tracking        CHOICES 0 1
        -ip_precedence_count           NUMERIC
                                       DEFAULT 1
        -ip_precedence_mode            CHOICES fixed incr decr list
                                       DEFAULT fixed
        -ip_precedence_step            RANGE   0-6
                                       DEFAULT 1
        -ip_precedence_tracking        CHOICES 0 1
        -ip_delay_mode                 CHOICES fixed list
                                       DEFAULT fixed
        -ip_delay_tracking             CHOICES 0 1
        -ip_reliability_mode           CHOICES fixed list
                                       DEFAULT fixed
        -ip_reliability_tracking       CHOICES 0 1
        -ip_cost_mode                  CHOICES fixed list
                                       DEFAULT fixed
        -ip_cost_tracking              CHOICES 0 1
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
        -qos_byte_count                NUMERIC
                                       DEFAULT 1
        -qos_byte_mode                 CHOICES fixed incr decr list
                                       DEFAULT fixed
        -qos_byte_step                 RANGE   0-126
                                       DEFAULT 1
        -qos_byte_tracking             CHOICES 0 1
        -data_tos_count                NUMERIC
                                       DEFAULT 1
        -data_tos_mode                 CHOICES fixed incr decr list
                                       DEFAULT fixed
        -data_tos_step                 RANGE   0-126
                                       DEFAULT 1
        -data_tos_tracking             CHOICES 0 1
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
        -ipv6_dst_count                             RANGE   1-4294967295
        -ipv6_dst_mask                              RANGE   0-128
        -ipv6_dst_mode                              CHOICES fixed increment decrement list incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group
                                                    CHOICES random
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
        -ipv6_frag_more_flag_mode                   CHOICES fixed list
                                                    DEFAULT fixed    
        -ipv6_frag_more_flag_tracking               CHOICES 0 1
        -ipv6_frag_offset                           ANY
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
        -ipv6_src_count                             RANGE   1-4294967295
        -ipv6_src_mask                              RANGE   0-128
        -ipv6_src_mode                              CHOICES fixed increment decrement list incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group
                                                    CHOICES random
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
        -ipv6_pseudo_zero_number_tracking           CHOICES 0 1
        -arp_dst_hw_addr                            MAC
        -arp_dst_hw_count                           NUMERIC
        -arp_dst_hw_mode                            CHOICES fixed increment decrement list
        -arp_dst_hw_step                            MAC
        -arp_dst_hw_tracking                        CHOICES 0 1
        -arp_src_hw_addr                            MAC
        -arp_src_hw_count                           NUMERIC
        -arp_src_hw_mode                            CHOICES fixed increment decrement list
        -arp_src_hw_step                            MAC
        -arp_src_hw_tracking                        CHOICES 0 1
        -arp_operation                              CHOICES arpRequest arpReply
                                                    CHOICES rarpRequest
                                                    CHOICES rarpReply
                                                    CHOICES unknown
        -arp_operation_mode                         CHOICES fixed list
        -arp_operation_tracking                     CHOICES 0 1
        -arp_hw_type                                REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -arp_hw_type_count                          NUMERIC
        -arp_hw_type_mode                           CHOICES fixed incr decr list
        -arp_hw_type_step                           REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -arp_hw_type_tracking                       CHOICES 0 1
        -arp_protocol_type                          REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -arp_protocol_type_count                    NUMERIC
        -arp_protocol_type_mode                     CHOICES fixed incr decr list
        -arp_protocol_type_step                     REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -arp_protocol_type_tracking                 CHOICES 0 1
        -arp_hw_address_length                      REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -arp_hw_address_length_count                NUMERIC
        -arp_hw_address_length_mode                 CHOICES fixed incr decr list
        -arp_hw_address_length_step                 REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -arp_hw_address_length_tracking             CHOICES 0 1
        -arp_protocol_addr_length                   REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -arp_protocol_addr_length_count             NUMERIC
        -arp_protocol_addr_length_mode              CHOICES fixed incr decr list
        -arp_protocol_addr_length_step              REGEXP  (^[0-9a-fA-F]{1,2}$)|(^0x[0-9a-fA-F]{1,2})
        -arp_protocol_addr_length_tracking          CHOICES 0 1
        -arp_dst_protocol_addr                      IP
        -arp_dst_protocol_addr_count                NUMERIC
        -arp_dst_protocol_addr_mode                 CHOICES fixed incr decr list
        -arp_dst_protocol_addr_step                 IP
        -arp_dst_protocol_addr_tracking             CHOICES 0 1
        -arp_src_protocol_addr                      IP
        -arp_src_protocol_addr_count                NUMERIC
        -arp_src_protocol_addr_mode                 CHOICES fixed incr decr list
        -arp_src_protocol_addr_step                 IP
        -arp_src_protocol_addr_tracking             CHOICES 0 1
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
        -icmp_checksum_tracking                            CHOICES 0 1
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
        -inner_ip_dst_count                 RANGE   1-4294967295
        -inner_ip_dst_mode                  CHOICES fixed increment decrement random list
        -inner_ip_dst_step                  IPV4
        -inner_ip_dst_tracking              CHOICES 0 1
        -inner_ip_src_addr                  IPV4
        -inner_ip_src_count                 NUMERIC
        -inner_ip_src_mode                  CHOICES fixed increment decrement random list
        -inner_ip_src_step                  IPV4
        -inner_ip_src_tracking              CHOICES 0 1
        -inner_ipv6_dst_addr                IPV6
        -inner_ipv6_dst_count               RANGE   1-4294967295
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
        -inner_ipv6_frag_more_flag          FLAG
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
        -inner_ipv6_src_count               RANGE   1-4294967295
        -inner_ipv6_src_mode                CHOICES fixed increment decrement incr_host decr_host incr_network decr_network incr_intf_id decr_intf_id incr_global_top_level decr_global_top_level incr_global_next_level decr_global_next_level incr_global_site_level decr_global_site_level incr_local_site_subnet decr_local_site_subnet incr_mcast_group decr_mcast_group random list
        -inner_ipv6_src_step                IPV6
        -inner_ipv6_src_tracking            CHOICES 0 1
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
        -udp_length_tracking                CHOICES 0 1
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
        -dhcp_server_host_name
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
        -rip_rte_v2_next_hop_tracking       CHOICES 0 1
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
        -igmp_data_v3r_tracking             CHOICES 0 1
        -tcp_ack_flag                       CHOICES 0 1
        -tcp_ack_flag_mode                  CHOICES fixed list
        -tcp_ack_flag_tracking              CHOICES 0 1
        -tcp_ack_num                        RANGE   0-4294967295
        -tcp_ack_num_count                  NUMERIC
        -tcp_ack_num_mode                   CHOICES fixed incr decr list
        -tcp_ack_num_step                   RANGE   0-4294967294
        -tcp_ack_num_tracking               CHOICES 0 1
        -tcp_dst_port                       RANGE   0-65535
        -tcp_dst_port_count                 NUMERIC
        -tcp_dst_port_mode                  CHOICES fixed incr decr list
        -tcp_dst_port_step                  RANGE   0-65534
        -tcp_dst_port_tracking              CHOICES 0 1
        -tcp_fin_flag                       CHOICES 0 1
        -tcp_fin_flag_mode                  CHOICES fixed list
        -tcp_fin_flag_tracking              CHOICES 0 1
        -tcp_psh_flag                       CHOICES 0 1
        -tcp_psh_flag_mode                  CHOICES fixed list
        -tcp_psh_flag_tracking              CHOICES 0 1
        -tcp_rst_flag                       CHOICES 0 1
        -tcp_rst_flag_mode                  CHOICES fixed list
        -tcp_rst_flag_tracking              CHOICES 0 1
        -tcp_seq_num                        RANGE   0-4294967295
        -tcp_seq_num_count                  NUMERIC
        -tcp_seq_num_mode                   CHOICES fixed incr decr list
        -tcp_seq_num_step                   RANGE   0-4294967295
        -tcp_seq_num_tracking               CHOICES 0 1
        -tcp_src_port                       RANGE   0-65535
        -tcp_src_port_count                 NUMERIC
        -tcp_src_port_mode                  CHOICES fixed incr decr list
        -tcp_src_port_step                  RANGE   0-65534
        -tcp_src_port_tracking              CHOICES 0 1
        -tcp_syn_flag                       CHOICES 0 1
        -tcp_syn_flag_mode                  CHOICES fixed list
        -tcp_syn_flag_tracking              CHOICES 0 1
        -tcp_urgent_ptr                     RANGE   0-65535
        -tcp_urgent_ptr_count               NUMERIC
        -tcp_urgent_ptr_mode                CHOICES fixed incr decr list
        -tcp_urgent_ptr_step                RANGE   0-65534
        -tcp_urgent_ptr_tracking            CHOICES 0 1
        -tcp_urg_flag                       CHOICES 0 1
        -tcp_urg_flag_mode                  CHOICES fixed list
        -tcp_urg_flag_tracking              CHOICES 0 1
        -tcp_window                         RANGE   0-65535
        -tcp_window_count                   NUMERIC
        -tcp_window_mode                    CHOICES fixed incr decr list
        -tcp_window_step                    RANGE   0-65534
        -tcp_window_tracking                CHOICES 0 1
        -tcp_data_offset                    RANGE   0-15
        -tcp_data_offset_count              NUMERIC
        -tcp_data_offset_mode               CHOICES fixed incr decr list
        -tcp_data_offset_step               RANGE   0-15
        -tcp_data_offset_tracking           CHOICES 0 1
        -tcp_reserved                       RANGE   0-7
        -tcp_reserved_count                 NUMERIC
        -tcp_reserved_mode                  CHOICES fixed incr decr list
        -tcp_reserved_step                  RANGE   0-6
        -tcp_reserved_tracking              CHOICES 0 1
        -tcp_ns_flag                        CHOICES 0 1
        -tcp_ns_flag_mode                   CHOICES fixed list
        -tcp_ns_flag_tracking               CHOICES 0 1
        -tcp_cwr_flag                       CHOICES 0 1
        -tcp_cwr_flag_mode                  CHOICES fixed list
        -tcp_cwr_flag_tracking              CHOICES 0 1
        -tcp_ecn_echo_flag                  CHOICES 0 1
        -tcp_ecn_echo_flag_mode             CHOICES fixed list
        -tcp_ecn_echo_flag_tracking         CHOICES 0 1
        -tcp_checksum                       REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -tcp_checksum_count                 NUMERIC
        -tcp_checksum_mode                  CHOICES fixed incr decr list
        -tcp_checksum_step                  REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
        -tcp_checksum_tracking              CHOICES 0 1
        -skip_return_handles                CHOICES 0 1
                                            DEFAULT 0
    }
    
    set option_list "ip_src_addr ip_src_mode ip_src_count ip_dst_addr          \
            ip_dst_count ip_dst_mode arp_src_hw_addr arp_src_hw_mode           \
            arp_src_hw_count arp_dst_hw_addr arp_dst_hw_mode arp_dst_hw_count  \
            arp_operation l3_length length_mode l3_length_min                  \
            l3_length_max l3_length_step rate_percent l2_encap mac_src mac_dst \
            mac_src_mode sweep_min sweep_max sweep_step mac_dst_mode           \
            mac_src_count mac_dst_count data_pattern_mode data_pattern         \
            ethernet_type ethernet_value vlan vlan_id_mode vlan_id vlan_cfi    \
            vlan_user_priority vlan_id_count isl isl_frame_type isl_vlan_id    \
            isl_user_priority isl_bpdu isl_index l3_protocol l4_protocol       \
            pause_control_time tcp_src_port tcp_dst_port tcp_seq_num           \
            mac_src_step mac_dst_step tcp_window tcp_ack_num tcp_urgent_ptr    \
            ip_fragment_offset ip_protocol udp_src_port udp_dst_port           \
            icmp_code icmp_type icmp_id icmp_seq igmp_version igmp_type        \
            igmp_group_count igmp_max_response_time igmp_group_mode            \
            igmp_group_addr igmp_qqic igmp_qrv igmp_s_flag igmp_valid_checksum \
            rip_version rip_command ip_precedence                              \
            ip_delay ip_throughput ip_reliability ip_length_override           \
            ip_total_length ip_cost ip_id ip_fragment                          \
            ip_fragment_last ip_ttl ip_dscp ip_opt_security                    \
            ip_opt_loose_routing ip_opt_strict_routing ip_opt_timestamp        \
            ip_reserved fcs fcs_type                                           \
            enable_pgid frame_sequencing enable_data_integrity enable_dynamic_mpls_labels \
            integrity_signature integrity_signature_offset                     \
            frame_sequencing_offset rate_pps rate_bps rate_percent rate_frame_gap\
            mpls mpls_labels mpls_type number_of_packets_per_stream            \
            rate_pps rate_bps signature                                        \
            signature_offset pgid_value pgid_offset number_of_packets_tx name  \
            pkts_per_burst transmit_mode burst_loop_count inter_burst_gap      \
            inter_stream_gap tcp_urg_flag tcp_psh_flag tcp_syn_flag            \
            tcp_ack_flag tcp_rst_flag tcp_fin_flag frame_size                  \
            frame_size_min frame_size_max frame_size_step ipv6_src_addr        \
            ipv6_dst_addr ipv6_traffic_class                                   \
            ipv6_flow_label ipv6_hop_limit ip_src_step ip_dst_step loop_count  \
            return_to_id vlan_id_step dhcp_boot_filename dhcp_client_hw_addr   \
            dhcp_client_ip_addr dhcp_flags dhcp_hops dhcp_hw_len dhcp_hw_type  \
            dhcp_operation_code dhcp_option dhcp_relay_agent_ip_addr           \
            dhcp_seconds dhcp_server_host_name dhcp_server_ip_addr             \
            dhcp_transaction_id dhcp_your_ip_addr udp_checksum                 \
            udp_checksum_value"
            
    # Frame Relay options
    set fr_option_list {
        dlci_size               addressSize         value
        dlci_count_mode         counterMode         dlciCounterArray
        dlci_mask_value         maskValue           value
        dlci_mask_select        maskSelect          value
        dlci_value              dlci                value
        dlci_repeat_count       repeatCount         value
        command_response        commandResponse     flag
        fecn                    fecn                flag
        becn                    becn                flag
        discard_eligible        discardEligibleBit  flag
        dlci_extended_address0  extentionAddress0   flag
        dlci_extended_address1  extentionAddress1   flag
        dlci_extended_address2  extentionAddress2   flag
        dlci_extended_address3  extentionAddress3   flag
        dlci_core_enable        enableDlciCore      flag
        dlci_core_value         dlciCoreValue       value
    }

    set udf_list "enable_udf%d udf%d_mode udf%d_offset udf%d_counter_type  \
            udf%d_counter_up_down udf%d_counter_init_value                 \
            udf%d_counter_repeat_count udf%d_counter_step udf%d_value_list \
            udf%d_counter_mode udf%d_inner_repeat_value udf%d_chain_from   \
            udf%d_inner_repeat_count udf%d_inner_step udf%d_cascade_type   \
            udf%d_enable_cascade udf%d_skip_zeros_and_ones                 \
            udf%d_mask_select udf%d_mask_val udf%d_skip_mask_bits          "

    set gre_option_list "gre_checksum_enable gre_checksum gre_key_enable \
            gre_key gre_reserved0 gre_reserved1 gre_seq_enable           \
            gre_seq_number gre_version gre_valid_checksum_enable         "

    set inner_option_list "\
            inner_ip_src_addr inner_ip_src_mode inner_ip_src_count             \
            inner_ip_src_step inner_ip_dst_addr inner_ip_dst_mode              \
            inner_ip_dst_count inner_ip_dst_step inner_ipv6_src_addr           \
            inner_ipv6_dst_addr inner_ipv6_traffic_class inner_ipv6_flow_label \
            inner_ipv6_hop_limit inner_ipv6_frag_offset                        \
            inner_ipv6_frag_more_flag inner_ipv6_frag_id                       "

    set ipv6_extension_header_list "\
            ipv6_frag_offset ipv6_frag_more_flag ipv6_frag_id          \
            ipv6_extension_header  ipv6_hop_by_hop_options             \
            ipv6_routing_node_list ipv6_routing_res ipv6_frag_res_2bit \
            ipv6_frag_res_8bit ipv6_auth_string ipv6_auth_payload_len  \
            ipv6_auth_spi ipv6_auth_seq_num                            "

    set ipv6_mode_list "\
            ipv6_src_mode ipv6_src_count ipv6_src_step \
            ipv6_dst_mode ipv6_dst_count ipv6_dst_step \
            ipv6_src_mask ipv6_dst_mask"

    set inner_ipv6_mode_list "\
            inner_ipv6_src_mode inner_ipv6_src_count inner_ipv6_src_step \
            inner_ipv6_dst_mode inner_ipv6_dst_count inner_ipv6_dst_step \
            inner_ipv6_src_mask inner_ipv6_dst_mask"

    array set double_parse_dashed_args [list                              \
            ipv6_frag_offset        [list                                 \
            {RANGE 0-8191} {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}]       \
            ipv6_frag_more_flag    [list                                  \
            FLAG {CHOICES 0 1} {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}]   \
            ipv6_frag_id           [list                                  \
            {RANGE 0-4294967295} {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}] \
            ipv6_routing_node_list [list                                  \
            IPV6 {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}]                 \
            ipv6_routing_res       [list                                  \
            {REGEXP ^(\[0-9a-fA-F\]{2}\[.:\]{1}){3}\[0-9a-fA-F\]{2}$}     \
            {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}]                      \
            ipv6_frag_res_2bit     [list                                  \
            {RANGE 0-3} {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}]          \
            ipv6_frag_res_8bit     [list                                  \
            {RANGE 0-127} {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}]        \
            ipv6_auth_string       [list                                  \
            {REGEXP ^(\[0-9a-fA-F\]{2}\[.:\]{1})+\[0-9a-fA-F\]{2}$}       \
            {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}]                      \
            ipv6_auth_payload_len  [list                                  \
            {RANGE 0-4294967295} {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}] \
            ipv6_auth_spi          [list                                  \
            {RANGE 0-4294967295} {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}] \
            ipv6_auth_seq_num      [list                                  \
            {RANGE 0-4294967295} {REGEXP ^\[nN\]{1}\[/\]{0,1}\[aA\]{1}$}] \
            ]

    array set record_types [list        \
            mode_is_include         1   \
            mode_is_exclude         2   \
            change_to_include_mode  3   \
            change_to_exclude_mode  4   \
            allow_new_sources       5   \
            block_old_sources       6   \
            ]
            
    array set increment_mode [list                  \
            0 ipV6IncrNetwork                       \
            1 ipV6IncrNetwork                       \
            2 ipV6IncrNetwork                       \
            3 ipV6IncrNetwork                       \
            4 ipV6IncrGlobalUnicastTopLevelAggrId   \
            5 ipV6IncrInterfaceId                   \
            6 ipV6IncrSiteLocalUnicastSubnetId      \
            7 ipV6IncrMulticastGroupId              \
            ]
    
    array set decrement_mode [list                  \
            0 ipV6DecrNetwork                       \
            1 ipV6DecrNetwork                       \
            2 ipV6DecrNetwork                       \
            3 ipV6DecrNetwork                       \
            4 ipV6DecrGlobalUnicastTopLevelAggrId   \
            5 ipV6DecrInterfaceId                   \
            6 ipV6DecrSiteLocalUnicastSubnetId      \
            7 ipV6DecrMulticastGroupId              \
            ]
    
    array set dlciCounterArray [list                        \
            increment           $::frameRelayIncrement      \
            cont_increment      $::frameRelayContIncrement  \
            decrement           $::frameRelayDecrement      \
            cont_decrement      $::frameRelayContDecrement  \
            idle                $::frameRelayIdle           \
            random              $::frameRelayRandom         \
    ]
    
    set streamConfigParams [list chassis card port queue_id stream_id \
            ixaccess_emulated_stream_status protocolOffsetEnable      \
            rate_frame_gap customSet                                  ]
        
    # If traffic_generator is ixnetwork and the IxTclNetwork API is loaded
    # call ixnetwork_traffic_config
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        
        if {![regexp {(-traffic_generator)(\s+)(\w+)} $args {} {} {} traffic_generator]} {
            set traffic_generator ixaccess
        }
        
        set traffic_type "nextGen"
        switch -- $traffic_generator {
            "ixnetwork_540" {
                set traffic_type "nextGen"
            }
            "ixnetwork" {
                if {[regexp "NO" $::ixia::ixnetworkVersion]  && \
                        [info exists ::ixia::forceNextGenTraffic] &&\
                        $::ixia::forceNextGenTraffic == 1} {
                    
                    set traffic_type "nextGen"
                } else {
                    set traffic_type "legacy"
                }
            }
            default {
                set traffic_type "ixos"
                if {[is_default_param_value "traffic_generator" $args]} {
                    if {[string first "NO" $::ixia::ixnetworkVersion] > 0} {
                        set traffic_type "nextGen"
                    }
                } else {
                    if { [string first "NO" $::ixia::ixnetworkVersion] > 0 } {
                        # Using IxOS with a Network Only setting...
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                    Cannot use IxOS traffic generator with a 'Network Only' HLT setting. \
                                    Please set traffic_generator parameter to a valid value."
                        return $returnList
                    }
                }
            }
        }
        
        if {$traffic_type == "nextGen"} {
                    
            set returnList [::ixia::540trafficConfig $args]
            if {[keylget returnList status] == $::FAILURE} {
                keylset returnList log "ERROR in $procName:\
                        [keylget returnList log]"
            }
            return $returnList
        } elseif {$traffic_type == "legacy"} {
            set returnList [::ixia::ixnetwork_traffic_config $args ]
            if {[keylget returnList status] == $::FAILURE} {
                keylset returnList log "ERROR in $procName:\
                        [keylget returnList log]"
            }
            return $returnList
        } else {
            
            if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                    -mandatory_args $man_args} errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $errorMsg."
                return $returnList
            }
            
            if {![info exists ixn_traffic_version] || $ixn_traffic_version != "ixos"} {
                if {[info exists ixn_traffic_version]} {
                    if {$ixn_traffic_version == "5.30"} {
                        puts "Changing traffic generator from 'ixnetwork' (Legacy Traffic) to 'ixos'"
                    } else {
                        puts "Changing traffic generator from 'ixnetwork_540' (Next Gen Traffic) to 'ixos'"
                    }
                }
                
                set chassis_refresh_ips ""
                
                switch -- $mode {
                    "create" -
                    "reset" {
                        if {![info exists port_handle]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Port handle \
                                    is mandatory for -mode $mode."
                            return $returnList
                        }
                        
                        if {[info exists ixnetwork_rp2vp_handles_array($port_handle)]} {
                            set port_handle $ixnetwork_rp2vp_handles_array($port_handle)
                        }
                    }
                    "default" {
                        if {[info exists stream_id]} {
                            if {[regexp {(^[0-9]+/[0-9]+/[0-9]+$)} $stream_id]} {
                                puts "\nWARNING in $procName: traffic_config -mode modify is not\
                                        supported for EFM configurations done with IxNetwork/IxProtocol TCL API."
                                keylset returnList status $::SUCCESS
                                return $returnList
                            }
                        }
                        if {[info exists port_handle]} {
                            if {$port_handle == ""} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: Port handle \
                                        has \"\" value."
                                return $returnList
                            }
                            
                            if {[info exists ixnetwork_rp2vp_handles_array($port_handle)]} {
                                set port_handle $ixnetwork_rp2vp_handles_array($port_handle)
                            }
                            
                        } else {
                            # extract port_handle from stream_id
                            if {![info exists stream_id]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: Mode $mode was\
                                        selected without passing a stream_id necessary for the\
                                        modification."
                                return $returnList
                            }
                
                            if {![info exists pgid_to_stream($stream_id)]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: stream_id $stream_id\
                                        was not found among the streams configured."
                                return $returnList
                            }
                            
                            foreach {ch ca po st} [split $pgid_to_stream($stream_id) ,] {}
                            
                            set port_handle $ch/$ca/$po
                        }
                    }
                }
                
                set ch_rfrsh_id1 [lindex [split $port_handle /] 0]
                if {[chassis getFromID $ch_rfrsh_id1]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                        Could not determine chassis IP from id $ch_rfrsh_id1. $::ixErrorInfo."
                    return $returnList
                }
                
                lappend chassis_refresh_ips [chassis cget -ipAddress]
                
                if {[info exists port_handle2]} {
                    set ch_rfrsh_id2 [lindex [split $port_handle2 /] 0]
                    if {$ch_rfrsh_id2 != $ch_rfrsh_id1} {
                        if {[chassis getFromID $ch_rfrsh_id2]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                Could not determine chassis IP from id $ch_rfrsh_id2. $::ixErrorInfo."
                            return $returnList
                        }
                        
                        lappend chassis_refresh_ips [chassis cget -ipAddress]
                    }
                }
                
                foreach chassis_refresh_ip $chassis_refresh_ips {
                    debug "chassis refresh $chassis_refresh_ip"
                    if {[catch {chassis refresh $chassis_refresh_ip} err] || $err == 1} {
                        debug "Failed to refresh chassis $chassis_refresh_ip. $err. This is done if traffic_config is\
                                called with -traffic_generator ixos and a connection with ixnetwork\
                                was done."
                    }
                }
            }

            set ixn_traffic_version "ixos"
        }
    } else {
        if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                -mandatory_args $man_args} errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: $errorMsg."
            return $returnList
        }
    }
    # If traffic_generator is ixos or ixaccess continue
    if {($mode == "create" || $mode == "reset") && ![info exists port_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Port handle \
                is mandatory for -mode $mode."
        return $returnList
    }
    
    if {$mode != "create" && $mode != "reset"} {
        if {[info exists stream_id]} {
            if {[regexp {(^[0-9]+/[0-9]+/[0-9]+$)} $stream_id]} {
                puts "\nWARNING in $procName: traffic_config -mode modify is not\
                        supported for EFM configurations done with IxNetwork/IxProtocol TCL API."
                keylset returnList status $::SUCCESS
                return $returnList
            }
        }
        if {[info exists port_handle]} {
            if {$port_handle == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Port handle \
                        has \"\" value."
                return $returnList
            }
        } else {
            # extract port_handle from stream_id
            if {![info exists stream_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Mode $mode was\
                        selected without passing a stream_id necessary for the\
                        modification."
                return $returnList
            }

            if {![info exists pgid_to_stream($stream_id)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: stream_id $stream_id\
                        was not found among the streams configured."
                return $returnList
            }
            
            foreach {ch ca po st} [split $pgid_to_stream($stream_id) ,] {}
            
            set port_handle $ch/$ca/$po
        }
        
        # Clear defaults
        set params_to_clear [list enable_time_stamp]
        
        foreach param_to_clear $params_to_clear {
            if {[is_default_param_value $param_to_clear $args]} {
                catch {unset $param_to_clear}
            }
        }
    }

    regsub -all {/} $port_handle " " new

    # Set chassis card port
    set ch [lindex $new 0]
    set ca [lindex $new 1]
    set po [lindex $new 2]

    # ATM parameters validation:
    if {[port isActiveFeature $ch $ca $po portFeatureAtm] && \
            (($mode == "create") || ($mode == "modify"))} {

        # Set the default values :
        if {[info exists atm_counter_vpi_type] && \
                ($atm_counter_vpi_type == "table")} {
            if {![info exists atm_counter_vpi_data_item_list]} {
                set atm_counter_vpi_data_item_list []
            }
        }

        if {[info exists atm_counter_vci_type] && \
                ($atm_counter_vci_type == "table")} {
            if {![info exists atm_counter_vci_data_item_list]} {
                set atm_counter_vci_data_item_list []
            }
        }
        #
        if {[info exists atm_counter_vpi_type] && \
                ($atm_counter_vpi_type == "random")} {
            if {![info exists atm_counter_vpi_mask_select]} {
                set atm_counter_vpi_mask_select "0000"
            }
            if {![info exists atm_counter_vpi_mask_value]} {
                set atm_counter_vpi_mask_value "0000"
            }
        }

        if {[info exists atm_counter_vci_type] && \
                ($atm_counter_vci_type == "random")} {
            if {![info exists atm_counter_vci_mask_select]} {
                set atm_counter_vci_mask_select "0000"
            }
            if {![info exists atm_counter_vci_mask_value]} {
                set atm_counter_vci_mask_value "0000"
            }
        }
        #
        if {[info exists atm_counter_vpi_type] && \
                ($atm_counter_vpi_type == "counter")} {
            if {![info exists atm_counter_vpi_mode]} {
                set atm_counter_vpi_mode incr
            }

            if {![info exists vpi_step]} {
                set vpi_step 1
            }

            if {($atm_counter_vpi_mode == "incr") || \
                    ($atm_counter_vpi_mode == "decr")} {
                if {![info exists vpi_count]} {
                    set vpi_count 1
                }
            }
        }

        if {[info exists atm_counter_vci_type] && \
                ($atm_counter_vci_type == "counter")} {
            if {![info exists atm_counter_vci_mode]} {
                set atm_counter_vci_mode incr
            }

            if {![info exists vci_step]} {
                set vci_step 1
            }

            if {($atm_counter_vci_mode == "incr") || \
                    ($atm_counter_vci_mode == "decr")} {
                if {![info exists vci_count]} {
                    set vci_count 1
                }
            }
        }
        #
        if {[info exists atm_counter_vpi_type] && \
                (($atm_counter_vpi_type == "counter") || \
                ($atm_counter_vpi_type == "fixed"))} {
            if {![info exists vpi]} {
                set vpi 32
            }
        }

        if {[info exists atm_counter_vci_type] && \
                (($atm_counter_vci_type == "counter") || \
                ($atm_counter_vci_type == "fixed"))} {
            if {![info exists vci]} {
                set vci 32
            }
        }
        # End setting default values

        if {![info exists atm_counter_vpi_type] || \
                (($atm_counter_vpi_type == "random") || \
                ($atm_counter_vpi_type == "table"))} {
            if {[info exists vpi]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vpi_type is not random or table, \
                        -vpi is not required. Do not supply this value."
                return $returnList
            }
        }

        if {![info exists atm_counter_vci_type] || \
                (($atm_counter_vci_type == "random") || \
                ($atm_counter_vci_type == "table"))} {
            if {[info exists vci]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vci_type is not random or table, \
                        -vci is not required. Do not supply this value."
                return $returnList
            }
        }

        if {![info exists atm_header_enable_cpcs_length] || \
                (!$atm_header_enable_cpcs_length)} {
            if {[info exists atm_header_cpcs_length]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_header_enable_cpcs_length is disabled, \
                        -atm_header_cpcs_length is not required. \
                        Do not supply this value."
                return $returnList
            }
        }

        if {[info exists atm_header_enable_auto_vpi_vci] && \
                ($atm_header_enable_auto_vpi_vci)} {
            if {[info exists vpi] || [info exists vpi]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_header_enable_auto_vpi_vci is enabled, \
                        -vci and -vpi are not required.\
                        Do not supply these values."
                return $returnList
            }
        }

        if {![info exists atm_counter_vpi_type] || \
                ($atm_counter_vpi_type != "table")} {
            if {[info exists atm_counter_vpi_data_item_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vpi_type is not table, \
                        -atm_counter_vpi_data_item_list is not required. \
                        Do not supply this value."
                return $returnList
            }
        }

        if {![info exists atm_counter_vci_type] || \
                ($atm_counter_vci_type != "table")} {
            if {[info exists atm_counter_vci_data_item_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vci_type is not table, \
                        -atm_counter_vci_data_item_list is not required. \
                        Do not supply this value."
                return $returnList
            }
        }

        if {![info exists atm_counter_vpi_type] || \
                ($atm_counter_vpi_type != "random")} {
            if {[info exists atm_counter_vpi_mask_select] || \
                    [info exists atm_counter_vpi_mask_value]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vpi_type is not random, \
                        -atm_counter_vpi_mask_select and -atm_counter_vpi_mask_value \
                        are not required. Do not supply these values."
                return $returnList
            }
        }

        if {![info exists atm_counter_vci_type] || \
                ($atm_counter_vci_type != "random")} {
            if {[info exists atm_counter_vci_mask_select] || \
                    [info exists atm_counter_vci_mask_value]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vci_type is not random, \
                        -atm_counter_vci_mask_select and \
                        -atm_counter_vci_mask_value are not required. \
                        Do not supply these values."
                return $returnList
            }
        }

        if {![info exists atm_counter_vpi_type] || \
                ($atm_counter_vpi_type != "counter")} {
            if {[info exists atm_counter_vpi_mode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vpi_type is not counter, \
                        -atm_counter_vpi_mode is not required. \
                        Do not supply this value."
                return $returnList
            }
        }

        if {![info exists atm_counter_vci_type] || \
                ($atm_counter_vci_type != "counter")} {
            if {[info exists atm_counter_vci_mode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                -atm_counter_vci_type is not counter, \
                -atm_counter_vci_mode is not required. \
                Do not supply this value."
                return $returnList
            }
        }

        if {![info exists atm_counter_vpi_type] || \
                ($atm_counter_vpi_type != "counter")} {
            if {[info exists vpi_step]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vpi_type is not counter, \
                        -vpi_step is not required. \
                        Do not supply this value."
                return $returnList
            }
        }

        if {![info exists atm_counter_vci_type] || \
                ($atm_counter_vci_type != "counter")} {
            if {[info exists vci_step]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vci_type is not counter, \
                        -vci_step is not required. Do not supply this value."
                return $returnList
            }
        }

        if {![info exists atm_counter_vpi_type] || \
                ($atm_counter_vpi_type != "counter")} {
            if {[info exists vpi_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vpi_type is not counter, \
                        -vpi_count is not required. Do not supply this value."
                return $returnList
            }
        } elseif {($atm_counter_vpi_mode != "incr") && \
                    ($atm_counter_vpi_mode != "decr")} {
            if {[info exists vpi_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vpi_mode is not incr or decr, \
                        -vpi_count is not required. Do not supply this value."
                return $returnList
            }
        }

        if {![info exists atm_counter_vci_type] || \
                ($atm_counter_vci_type != "counter")} {
            if {[info exists vci_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vci_type is not counter, \
                        -vci_count is not required. Do not supply this value."
                return $returnList
            }
        } elseif {($atm_counter_vci_mode != "incr") && \
                    ($atm_counter_vci_mode != "decr")} {
            if {[info exists vci_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the \
                        -atm_counter_vci_mode is not incr or decr, \
                        -vci_count is not required. Do not supply this value."
                return $returnList
            }
        }

        if {[info exists atm_counter_vpi_data_item_list]} {
            set newItemList {}
            foreach el $atm_counter_vpi_data_item_list {
                if {([catch {mpexpr $el}]) || ([mpexpr $el < 0]) || \
                        ([mpexpr $el > 4095])} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Each element \
                            of -atm_counter_vpi_data_item_list should be an \
                            integer between 0 and 4095."
                    return $returnList
                }

                lappend newItemList [format "%04x" $el]
            }
            set atm_counter_vpi_data_item_list $newItemList
        }

        if {[info exists atm_counter_vci_data_item_list]} {
            set newItemList {}
            foreach el $atm_counter_vci_data_item_list {
                if {([catch {mpexpr $el}]) || ([mpexpr $el <= 0]) || \
                        ([mpexpr $el > 65535])} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Each element \
                            of -atm_counter_vci_data_item_list should be an \
                            integer between 0 and 65535."
                    return $returnList
                }

                lappend newItemList [format "%04x" $el]
            }
            set atm_counter_vci_data_item_list $newItemList
        }

        if {[info exists atm_counter_vpi_mask_select]} {
            if {([string length $atm_counter_vpi_mask_select] > 4) || \
                    (![string is xdigit $atm_counter_vpi_mask_select])} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        -atm_counter_vpi_mask_select should be a 16-bit \
                        mask value."
                return $returnList
            }
        }

        if {[info exists atm_counter_vci_mask_select]} {
            if {([string length $atm_counter_vci_mask_select] > 4) || \
                    (![string is xdigit $atm_counter_vci_mask_select])} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        -atm_counter_vci_mask_select should be a 16-bit \
                        mask value."
                return $returnList
            }
        }

        if {[info exists atm_counter_vpi_mask_value]} {
            if {([string length $atm_counter_vpi_mask_value] > 4) || \
                    (![string is xdigit $atm_counter_vpi_mask_value])} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        -atm_counter_vpi_mask_value should be a 16-bit value."
                return $returnList
            }
        }

        if {[info exists atm_counter_vci_mask_value]} {
            if {([string length $atm_counter_vci_mask_value] > 4) || \
                    (![string is xdigit $atm_counter_vci_mask_value])} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        -atm_counter_vci_mask_value should be a 16-bit value."
                return $returnList
            }
        }
    }
    # End of ATM validations
    
    # Frame Relay parameters validation
    set frPresent false
    foreach {hlt_name ixos_name param_type} $fr_option_list {
        if {[info exists $hlt_name]} {
            set frPresent true
            break
        }
    }
    if {$frPresent == true} {
        if {[port isActiveFeature $ch $ca $po $::portFeaturePos]} {
            set num_of_dlci_ea 0
            for {set i 0} {$i < 4} {incr i} {
                if {![info exists dlci_extended_address$i]} {
                    set dlci_extended_address$i 0
                } else {
                    incr num_of_dlci_ea
                }
            }
            # setting default value
            if {![info exists dlci_size]} {
                set dlci_size 2
            }
            if {$num_of_dlci_ea == 0} {
                set dlci_extended_address[expr $dlci_size - 1] 1
            }
            sonet get $ch $ca $po
            set header_type [sonet cget -header]
            if {$header_type != 3 && $header_type != 4} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: specified port should \
                        use a Frame Relay header."
                return $returnList
            }
            # setting array with supported ranges
            array set dlci_mask_size_array {
                2       1023
                3       65535
                4       8388607
            }
            if {[info exists dlci_mask_select]} {
                if {![regexp -- "0x" $dlci_mask_select]} {
                    set dlci_mask_select "0x$dlci_mask_select"
                }
                if {[catch {
                    set dlci_mask_select_decimal [expr $dlci_mask_select]
                }]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "dlci_mask_select has wrong value"
                    return $returnList
                }
                if {$dlci_mask_select_decimal >\
                        $dlci_mask_size_array($dlci_size)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "dlci_mask_select out of range."
                    return $returnList
                }
                set dlci_mask_select [val2Bytes $dlci_mask_select $dlci_size]
            }
            if {[info exists dlci_mask_value]} {
                if {![regexp -- "0x" $dlci_mask_value]} {
                    set dlci_mask_value "0x$dlci_mask_select"
                }
                if {[catch {
                    set dlci_mask_value_decimal [expr $dlci_mask_value]
                }]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "dlci_mask_value has wrong value."
                    return $returnList
                }
                if {$dlci_mask_value_decimal >\
                        $dlci_mask_size_array($dlci_size)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "dlci_mask_value out of range."
                    return $returnList
                }
                set dlci_mask_value [val2Bytes $dlci_mask_value $dlci_size]
            }
            if {([info exists dlci_core_enable] || [info exists dlci_core_value]) \
                && $dlci_size == 2} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: dlci_core_enable or \
                        dlci_core_value can be set when dlci_size > 2."
                return $returnList
            }
            if {[info exists dlci_value] && $dlci_size < 3 && $dlci_value > 1023} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: dlci_value should be \
                        on 10 bits (<=1023) for dlci_size 2"
                return $returnList
            }
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR on $procName: Frame Relay is valid only \
                    on POS ports."
            return $returnList
        }
    }

    foreach {d_arg} [array names double_parse_dashed_args] {
        if {[info exists $d_arg]} {
            set parse_res_final 1
            set initial_d_arg [set $d_arg]
            foreach {d_arg_value} $initial_d_arg {
                set parse_res_partial 0
                foreach {parse_type} $double_parse_dashed_args($d_arg) {
                    set parse_type [format "%s" $parse_type]
                    set parse_cmd "::ixia::parse_dashed_args    \
                            -args                               \
                            \"-$d_arg $d_arg_value\"            \
                            -mandatory_args                     \
                            \"-$d_arg $parse_type\"             "

                    set parse_res [catch {eval $parse_cmd} retValue]
                    set parse_res_partial \
                            [expr $parse_res_partial | (!$parse_res)]

                    if {$parse_res_partial} {
                        break;
                    }
                }

                set parse_res_final \
                        [expr $parse_res_final & $parse_res_partial]
            }
            set $d_arg $initial_d_arg
            if {!$parse_res_final} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        Invalid values for -$d_arg. Valid values\
                        must be of type: $double_parse_dashed_args($d_arg)."
                return $returnList
            }
        }
    }

    # The halfbw items need to be between 0.01 and 30000.00 if they exist.
    # The RANGE option only supports integers, so it could not be used.
    foreach item [list l3_gaus1_halfbw l3_gaus2_halfbw l3_gaus3_halfbw \
            l3_gaus4_halfbw] {
        if {[info exists $item]} {
            if {([set $item] < 0.01) || ([set $item] > 30000.00)} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The value for\
                        $item, [set $item], is out of range.  The valid\
                        range is 0.01 <= x <= 30000.00."
                return $returnList
            }
        }
    }

    array set cascadeTypeEnumList [list \
            none          $::udfCascadeNone         \
            from_previous $::udfCascadeFromPrevious \
            from_shelf    $::udfCascadeFromSelf     ]

    # The following section is for the composite stream section.  Should go
    # away once hardware supports it.
    # Intercept the call and check for composite stream adjustment.
    if {($mode == "create") && [info exists rate_pps] && $adjust_rate} {

        # Prevent forever loop
        regsub -- {-adjust_rate\s+[\d]+} $args {} args
        lappend args -adjust_rate 0

        # The base is the increment we check for rate calibration
        set base 2000
        set return_val {}

        # Try with one stream
        set config_info [eval ::ixia::traffic_config $args]
        if {[keylget config_info status] == $::FAILURE} {
            return $config_info
        }

        # Get the stream info
        set stream_id_info [keylget config_info stream_id]

        # Get the actual pps
        if {![info exists bidirectional]} {
            set bidirectional 0
        }

        if {$bidirectional} {
            set stream_id  [keylget config_info stream_id.$port_handle]
            set stream_id2 [keylget config_info stream_id.$port_handle2]
        } else {
            set stream_id $stream_id_info
        }

        if {[eval port isActiveFeature [split $port_handle /] portFeatureAtm]} {
            set stream_queue $stream_to_queue_map($stream_id)
            eval stream getQueue [split $port_handle /] $stream_queue $stream_id
        } else  {
            eval stream get [split $port_handle /] $stream_id
        }
        set hw_rate [stream cget -framerate]

        # If this is within the range then it is good.  If the rate is already
        # too high, we cannot do anything.
        if {[mpexpr ($rate_pps - $hw_rate) < 1 && ($hw_rate - $rate_pps) < 1] \
                || [mpexpr $rate_pps <= 2 * $base]} {
            return $config_info
        }

        if {$hw_rate < 0} {
            keylset return_val status $::FAILURE
            keylset return_val log "The port rate is already over 100%."
            return $return_val
        }

        # We need two streams
        set mod_rate $rate_pps
        set first_stream_done 0
        set burst_mode [info exists pkts_per_burst]
        set first_modify 1

        while {!$first_stream_done} {

            # Modify down the rate_pps if too high
            if {$hw_rate < $rate_pps} {
                set mod_rate $hw_rate
                set first_stream_done 1
            } else {
                set mod_rate [mpexpr $mod_rate - $base]
                if {[mpexpr $mod_rate < 0.9 * $rate_pps] \
                        && !$first_modify} {
                    keylset return_val status $::FAILURE
                    keylset return_val log "Cannot converge, is port working\
                            properly?"
                    return $return_val
                }
                set first_modify 0
            }

            if {$burst_mode} {
                set burst_size [mpexpr int($pkts_per_burst * \
                        double($mod_rate) / $rate_pps)]
                set burst_config [list -pkts_per_burst $burst_size]
            } else {
                set burst_config {}
            }

            if {!$bidirectional} {
                set modify_info [eval ::ixia::traffic_config \
                        -mode        modify       \
                        -port_handle $port_handle \
                        -stream_id   $stream_id   \
                        -rate_pps    $mod_rate    \
                        $burst_config             \
                        -adjust_rate 0            ]
                if {[keylget modify_info status] == $::FAILURE} {
                    return $modify_info
                }

                set stream_id2 ""
            } else {
                set modify_info [eval ::ixia::traffic_config \
                        -mode        modify       \
                        -port_handle $port_handle \
                        -stream_id   $stream_id   \
                        -rate_pps    $mod_rate    \
                        $burst_config             \
                        -adjust_rate 0            ]
                if {[keylget modify_info status] == $::FAILURE} {
                    return $modify_info
                }

                set modify_info [eval ::ixia::traffic_config \
                        -mode        modify        \
                        -port_handle $port_handle2 \
                        -stream_id   $stream_id2   \
                        -rate_pps    $mod_rate     \
                        $burst_config              \
                        -adjust_rate 0             ]
                if {[keylget modify_info status] == $::FAILURE} {
                    return $modify_info
                }
            }

            if {[eval port isActiveFeature [split $port_handle /] portFeatureAtm]} {
                set stream_queue $stream_to_queue_map($stream_id)
                eval stream getQueue [split $port_handle /] $stream_queue $stream_id
            } else  {
                eval stream get [split $port_handle /] $stream_id
            }
            set hw_rate [stream cget -framerate]
        }

        # Create the second stream
        set remaining_rate [mpexpr int($rate_pps - $hw_rate)]
        regsub -- {-rate_pps\s+([\.\d]+)} $args \
                "-rate_pps $remaining_rate" args
        if {$burst_mode} {
            regsub -- {-pkts_per_burst\s+([\.\d]+)} $args \
                    "-pkts_per_burst [mpexpr $pkts_per_burst - $burst_size]" \
                    args
        }

        # See if pgid_value is preset by the user
        if {![info exists pgid_value]} {
            lappend pgid_value_conf -pgid_value $stream_id $stream_id2
        } else {
            set pgid_value_conf {}
        }

        set config2_info [eval ::ixia::traffic_config $args $pgid_value_conf]
        if {[keylget config2_info status] == $::FAILURE} {
            return $config2_info
        }
        if {!$bidirectional} {
            set stream1 [keylget config_info stream_id]
            set stream2 [keylget config2_info stream_id]
            set composite_streamid($stream1) [list $stream1 $stream2]
            set composite_streamid($stream2) $stream1
            keylset return_val stream_id $stream1
        } else {
            foreach phandle [list $port_handle $port_handle2] {
                set stream1 [keylget config_info stream_id.$phandle]
                set stream2 [keylget config2_info stream_id.$phandle]
                set composite_streamid($stream1) [list $stream1 $stream2]
                set composite_streamid($stream2) $stream1
                keylset return_val stream_id.$phandle $stream1
            }
        }
        keylset return_val status $::SUCCESS
        return $return_val
    } elseif {($mode == "modify") && [info exists stream_id] && \
            [info exists composite_streamid($stream_id)] && $adjust_rate} {

        keylset return_val status $::FAILURE
        keylset return_val log "Modifying composite stream is not supported. \
                Use the -remove and -create options to get the desired result."
        return $return_val
    } elseif {($mode == "remove") && [info exists stream_id] && \
            [info exists composite_streamid($stream_id)] && $adjust_rate} {
        set return_val {}
        if {[llength $composite_streamid($stream_id)] == 1} {
            # It is the shadow stream
            keylset return_val status $::FAILURE
            keylset return_val log "The stream_id $stream_id does not exist."
            return $return_val
        }

        # Make sure we will not loop forever
        regsub -- {-adjust_rate\s+[\d]+} $args {} args
        lappend args -adjust_rate 0

        foreach stream_num $composite_streamid($stream_id) {
            regsub -- {-stream_id\s+([\d]+)} $args "-stream_id $stream_num" \
                    args
            set remove_info [eval ::ixia::traffic_config $args]
            if {[keylget remove_info status] == $::FAILURE} {
                keylset return_val status $::FAILURE
                keylset return_val log "ERROR in removing sub-stream\
                        $stream_num for composite stream $stream_id. \
                        Log: [keylget remove_info log]"
                return $return_val
            }
        }

        keylset return_val status $::SUCCESS
        return $return_val
    }

    # First determine whether the traffic config should be called for a
    # emulation function This is determined by the presence of either
    # emulation_dst_handle or emulation_src_handle. The format of the
    # emulation handle is <emulation name>/<emulation id>/chas/card/port
    set emulation none
    if {[info exists emulation_src_handle]} {
        regexp {([a-zA-Z0-9]+)/.*} $emulation_src_handle dummy emulation
    } elseif {[info exists emulation_dst_handle]} {
        regexp {([a-zA-Z]+)/.*} $emulation_dst_handle dummy emulation
    }
    switch -exact $emulation {
        IxTclAccess {
            if {$traffic_generator == "ixaccess" && $mode != "reset"} {
                return [eval ::ixia::ixaccess_traffic_config $args]
            } elseif {$traffic_generator == "ixos"} {
                set useTclHalForIxAccessStreams 1
                # we overwrite it's value because we want to continue using
                # ixos but get data from ixaccess.
            }
        }
        l2tpv3 {
            if {$mode != reset} {
                return [eval ::ixia::l2tpv3TrafficConfig $args]
            }
        }
        none -
        default {
            # Change traffic_generator to ixos. We'll just use
            # plain stream creation without PPPoX data from ixaccess
            # end points
            set useTclHalForIxAccessStreams 0
        }
    }
    # This routine should only have one value in the port_handle.  Since
    # the parser will accept multiples, we need a separate check directly
    # after parsing to stop if more than one value.  If two ports are to
    # have streams created, it will be through the use of the bidirectional
    # and port_handle2 options
    if {[llength $port_handle] > 1 && ($mode != "reset")} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The port_handle contains\
                more than one value."
        return $returnList
    }

    set max_udf 6

    # Input port list is in the format , change it to the format A B C
    regsub -all {/} $port_handle " " intf

    # Set chassis card port
    set chassis [lindex $intf 0]
    set card    [lindex $intf 1]
    set port    [lindex $intf 2]

    set edit 0
    switch -- $mode {
        create {
            set edit 1

            # Check for the bidirectional flag
            if {[info exists bidirectional] && ($bidirectional == 1) && \
                    ![info exists port_handle2]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The bidirectional\
                        flag was enabled but no port_handle2 was passed in."
                return $returnList
            } elseif {![info exists bidirectional]} {
                set bidirectional 0
            }

            if {$bidirectional == 1} {
                lappend port_handle $port_handle2
            }
        }
        modify {
            set edit 2
            # NOTE: bidirectional option is not allowed with anything other than
            # create mode.
            if {[info exists bidirectional] && ($bidirectional == 1)} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Bidirectional is\
                        not supported in conjunction with mode: modify."
                return $returnList
            } elseif {![info exists bidirectional]} {
                set bidirectional 0
            }
            # Check if user passed a stream_id
            if {![info exists stream_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Mode modify was\
                        selected without passing a stream_id necessary for the\
                        modification on port $port_handle"
                return $returnList
            }

            foreach {chassis_num card_num port_num stream_num} \
                    [split $pgid_to_stream($stream_id) ,] {}
            if {!(($chassis == $chassis_num) && ($card == $card_num) && \
                    ($port == $port_num))} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The requested\
                        stream_id: $stream_id, is not on the port handle\
                        given, $chassis,$card,$port.  It is on the port:\
                        $chassis_num,$card_num,$port_num."
                return $returnList
            } else {
                set hold_current_streamid $current_streamid
                set current_streamid $stream_id
                set stream_id $stream_num
            }
            # Check if the stream_id is valid
            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                set stream_queue $stream_to_queue_map($current_streamid)
                set retCode [stream getQueue $chassis $card $port $stream_queue \
                        $stream_id]
            } else  {
                set retCode [stream get $chassis $card $port $stream_id]
            }
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to access\
                        stream: $stream_id on port: $port_handle."
                return $returnList
            }
        }
        enable -
        remove {
            # Check if user passed a stream_id
            if {![info exists stream_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Mode $mode was\
                        selected without passing a stream_id necessary for the\
                        modification on port $port_handle"
                return $returnList
            }

            if {[info exists ::ixia::pgid_to_stream($stream_id)]} {
                foreach {chassis_num card_num port_num stream_num} \
                        [split $pgid_to_stream($stream_id) ,] {}
                if {!(($chassis == $chassis_num) && ($card == $card_num) && \
                        ($port == $port_num))} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The requested\
                            stream_id: $stream_id, is not on the port handle\
                            given, $chassis,$card,$port.  It is on the port:\
                            $chassis_num,$card_num,$port_num."
                    return $returnList
                } else {
                    set hold_current_streamid $current_streamid
                    set current_streamid $stream_id
                    set stream_id $stream_num
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The stream_id\
                        passed in, $stream_id, does not exist as a known id."
                return $returnList
            }

            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                set stream_queue $stream_to_queue_map($current_streamid)
                set retCode [stream getQueue $chassis $card $port $stream_queue \
                        $stream_id]
            } else  {
                set retCode [stream get $chassis $card $port $stream_id]
            }
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to access\
                        stream: $stream_id on port: $port_handle"
                return $returnList
            } else {
                stream config -enable [expr \
                        [string compare $mode "enable"]==0 ? $::true : $::false ]

                if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                    set stream_queue $stream_to_queue_map($current_streamid)
                    set retCode [stream setQueue $chassis $card $port \
                            $stream_queue $stream_id]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to\
                                disable stream: $stream_id on port: $port_handle"
                        return $returnList
                    }
                    set port_list [list [list $chassis $card $port]]
                    if {[ixWriteConfigToHardware port_list -noProtocolServer]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to write\
                                config to hardware on port: $port_list"
                        return $returnList
                    }
                } else  {
                    set retCode [stream set $chassis $card $port $stream_id]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to\
                                disable stream: $stream_id on port: $port_handle"
                        return $returnList
                    }
                    if {[stream write $chassis $card $port $stream_id]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to write\
                                config to hardware on port: $port_list"
                        return $returnList
                    }
                }
            }
        }
        reset {
            foreach port_item $port_handle {
                regsub -all {/} $port_item " " intf
                # Set chassis card port
                set chassis [lindex $intf 0]
                set card    [lindex $intf 1]
                set port    [lindex $intf 2]
                set retCode [updatePatternMismatchFilter [list "$chassis $card $port"] "reset"]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget retCode log]"
                    return $returnList
                }
                
                set rstStatus [::ixia::ixaccess_reset_traffic $chassis $card $port]
                if {[keylget rstStatus status] != $::SUCCESS} {
                    return $rstStatus
                }
                
                if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                    array unset atmStatsConfig
                    streamQueueList select $chassis $card $port
                    streamQueueList clear
                } else  {
                    set retCode [port reset $chassis $card $port]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to\
                                reset port: $chassis $card $port"
                        return $returnList
                    }
                }
    
                set stream_id 0
    
                foreach item [array names ::ixia::pgid_to_stream] {
                    foreach {chassis_num card_num port_num stream_num} \
                            [split $::ixia::pgid_to_stream($item) ,] {}
                    if {($chassis == $chassis_num) && ($card == $card_num) && \
                            ($port == $port_num)} {
                        catch {array unset ::ixia::pgid_to_stream $item}
                        catch {array unset ::ixia::composite_streamid $item}
                    }
                }
    
                set port_list [list [list $chassis $card $port]]
                if {[ixWriteConfigToHardware port_list -noProtocolServer]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Unable to write\
                            config to hardware on port: $port_list"
                    return $returnList
                }
            }
            if {[array names ::ixia::pgid_to_stream] == -1} {
                set current_streamid 0
            }
        }
    }

    if {$edit == 0} {
        if {($mode == "remove") || ($mode == "enable")} {
            set current_streamid $hold_current_streamid
        }
        # None of the following procedure is required, exit with success
        keylset returnList status $::SUCCESS
        return $returnList
    }

    set data [split [version cget -ixTclHALVersion] .]
    append ixTclHal_version [lindex $data 0] . [lindex $data 1]

    set stream_id_list [list]
    set port_list [format_space_port_list $port_handle]
    foreach tx_port $port_list {
        scan $tx_port "%d %d %d" chassis card port
        if {$mode == "create"} {
            # Create the streams using ixos
            # and info from ixacess end points
            if { $useTclHalForIxAccessStreams } {

                # Memorize the variable values that we're going to overwrite
                # to set them back to the initial values if traffic is
                # bidirectional.
                
                set rollBackOWParams ""
                
                set ixaccess_emulated_stream_status \
                    [::ixia::buildEmulatedIxAccessStream $args $man_args $opt_args]
                
                debug "::ixia::buildEmulatedIxAccessStream returned: \n\
                    $ixaccess_emulated_stream_status"
                if {[keylget ixaccess_emulated_stream_status status] != $::SUCCESS} {
                    return $ixaccess_emulated_stream_status
                }
                
                set overload_parameters [keylkeys ixaccess_emulated_stream_status]
                
                foreach ol_param $overload_parameters {
                    if {$ol_param == "dstMacAddr"} {
                        if {[info exists mac_dst]} {
                            append rollBackOWParams "mac_dst $mac_dst "
                        } else {
                            append rollBackOWParams "mac_dst _unset_ "
                        }
                        set mac_dst [keylget ixaccess_emulated_stream_status $ol_param]
                    }
                    if {[info exists $ol_param]} {
                        append rollBackOWParams "$ol_param [set $ol_param] "
                    } else {
                        append rollBackOWParams "$ol_param _unset_ "
                    }
                    set $ol_param [keylget ixaccess_emulated_stream_status $ol_param]
                }
            
                array unset ::ixia::emulation_handles_array
            }            
            # Get the next stream index available
            set stream_id 1
            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                if {[info exists multiple_queues] && $multiple_queues} {
                    if {![info exists port_queue_num($chassis,$card,$port)]} {
                        # Initialize queue ID
                        set port_queue_num($chassis,$card,$port) 0
                    }
                    if {![info exists queue_id]} {
                        # Increment queue ID
                        if {$port_queue_num($chassis,$card,$port) < 15} {
                            incr port_queue_num($chassis,$card,$port)
                        } else {
                            set port_queue_num($chassis,$card,$port) 1
                        }
                        # Get queue ID
                        set queue_id $port_queue_num($chassis,$card,$port)
                    } elseif { \
                            $queue_id > [expr $port_queue_num($chassis,$card,$port) + 1] && \
                            [streamQueue get $chassis $card $port $queue_id] != 0 \
                            } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: $queue_id\
                                is not a valid value of the queue_id option.\
                                The valid values are in the \[1,[expr\
                                $port_queue_num($chassis,$card,$port) + 1]\]\
                                range."
                        return $returnList
                    }
                } else {
                    if {![info exists port_queue_num($chassis,$card,$port)]} {
                        # Initialize queue ID
                        set port_queue_num($chassis,$card,$port) 1
                    }
                    # Get queue ID
                    set queue_id 1
                }
                # Create queue if necessary
                if {[streamQueue get $chassis $card $port $queue_id]} {
                    streamQueueList select $chassis $card $port
                    streamQueueList add
                    streamQueue setDefault
                    set retCode [streamQueue set $chassis $card $port $queue_id]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to\
                                set stream queue $queue_id for port:\
                                $chassis $card $port"
                        return $returnList
                    }
                    set retCode [streamQueue clear $chassis $card $port $queue_id]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to\
                                clear stream queue $queue_id for port:\
                                $chassis $card $port"
                        return $returnList
                    }
                    set pL [list [list $chassis $card $port]]
                    ixWritePortsToHardware pL
                }
                # Get stream ID
                while {[stream getQueue $chassis $card $port $queue_id \
                            $stream_id] == $::TCL_OK} {
                    incr stream_id
                }
            } else  {
                while {[stream get $chassis $card $port $stream_id] \
                            == $::TCL_OK} {
                    incr stream_id
                }
            }

            # stream_id is the actual stream number on this port.  The pgid
            # value and stream name is set by the namespace variable so that
            # we can unique ones across all ports on a per session basis.
            incr current_streamid
            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                set stream_to_queue_map($current_streamid) $queue_id
            }
            set pgid_to_stream($current_streamid) \
                    $chassis,$card,$port,$stream_id

            stream        setDefault
            
            protocolOffset setDefault
            set protocolOffsetSize 0
            if {[info exists protocolOffsetEnable]} {
                if {$protocolOffsetEnable == 1} {
                    if {[port isActiveFeature $ch $ca $po portFeatureAtm]} {
                        # If port is ATM and we have ip with protocol offset then
                        # we're using PPPoEoA and we have to add the ethernet
                        # header to the offset of the signature.
                        incr protocolOffsetSize 16
                    } else {
                        set protocolOffsetSize [expr [llength $protocolOffsetUserDefinedTag] - 2]
                    }
                    protocolOffset config -enable         $protocolOffsetEnable
                    protocolOffset config -offset         $protocolOffsetOffset
                    protocolOffset config -userDefinedTag $protocolOffsetUserDefinedTag
                } else {
                    if {![port isActiveFeature $ch $ca $po portFeatureAtm]} {
                        if {[info exists vlan] && $vlan == "enable"} {
                            set protocolOffsetSize 4
                            if {[llength $vlan_id] > 1} {
                                incr protocolOffsetSize 4
                            }
                        }
                    }
                }
            }
            
            set status [protocolOffset set $chassis $card $port]
            if { $status } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                    Failed to protocolOffset set $chassis $card $port"
            }
        }
        # Inner IP GRE header needs to be configured before the outside one
        # GRE on IPv6 or IPv4
        if {[info exists l4_protocol] && ($l4_protocol == "gre")} {
            if {![port isValidFeature $chassis $card $port portFeatureGre]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        Port $chassis $card $port does not support GRE."
                return $returnList
            }
            if {[info exists inner_protocol]} {
                set addedInnerIPv6FragmentHeader 0
                switch -- $inner_protocol {
                    ipv4 {
                        ip setDefault
                        ip config -ipProtocol  255
                    }
                    ipv6 {
                        ipV6 setDefault
                        ipV6Fragment setDefault
                        ipV6Fragment config -enableFlag $::false

                        if {[ipV6 clearAllExtensionHeaders]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Failed to ipV6 clearAllExtensionHeaders \
                                    on port $chassis $card $port"
                            return $returnList
                        }
                    }
                }

                foreach inner_single_option_list $inner_option_list {
                    if {[info exists $inner_single_option_list]} {
                        eval set inner_single_option $$inner_single_option_list
                        switch -- $inner_single_option_list {
                            inner_ip_src_addr {
                                ip config -sourceIpAddr $inner_single_option
                            }
                            inner_ip_src_mode {
                                switch -- $inner_single_option {
                                    fixed {
                                        ip config -sourceIpAddrMode ipIdle
                                    }
                                    decrement {
                                        # Special case, decrement network with no mask
                                        ip config -sourceIpAddrMode ipDecrNetwork
                                        ip config -sourceClass noClass
                                    }
                                    increment {
                                        # Special case, increment network with no mask
                                        ip config -sourceIpAddrMode ipIncrNetwork
                                        ip config -sourceClass noClass
                                    }
                                    random {
                                        ip config -sourceIpAddrMode ipRandom
                                    }
                                    default {
                                    }
                                }
                            }
                            inner_ip_src_count {
                                ip config -sourceIpAddrRepeatCount $inner_single_option
                            }
                            inner_ip_src_step {
                                # Has to be handled after this main loop
                            }
                            inner_ip_dst_addr {
                                ip config -destIpAddr $inner_single_option
                            }
                            inner_ip_dst_mode {
                                set param ""
                                switch -- $inner_single_option {
                                    fixed {
                                        ip config -destIpAddrMode ipIdle
                                    }
                                    decrement {
                                        # Special case, decrement network with no mask
                                        ip config -destIpAddrMode ipDecrNetwork
                                        ip config -destClass noClass
                                    }
                                    increment {
                                        # Special case, increment network with no mask
                                        ip config -destIpAddrMode ipIncrNetwork
                                        ip config -destClass noClass
                                    }
                                    random {
                                        ip config -destIpAddrMode ipRandom
                                    }
                                    default {
                                    }
                                }
                            }
                            inner_ip_dst_count {
                                ip config -destIpAddrRepeatCount $inner_single_option
                            }
                            inner_ip_dst_step {
                                # Has to be handled after this main loop
                            }
                            inner_ipv6_src_addr {
                                ipV6 config -sourceAddr $inner_single_option
                            }
                            inner_ipv6_dst_addr {
                                ipV6 config -destAddr $inner_single_option
                            }
                            inner_ipv6_traffic_class {
                                ipV6 config -trafficClass $inner_single_option
                            }
                            inner_ipv6_flow_label {
                                ipV6 config -flowLabel $inner_single_option
                            }
                            inner_ipv6_hop_limit {
                                ipV6 config -hopLimit $inner_single_option
                            }
                            inner_ipv6_frag_offset {
                                ipV6Fragment config -fragmentOffset $inner_single_option
                                set addedInnerIPv6FragmentHeader 1
                            }
                            inner_ipv6_frag_id {
                                ipV6Fragment config -identification $inner_single_option
                                set addedInnerIPv6FragmentHeader 1
                            }
                            inner_ipv6_frag_more_flag {
                                ipV6Fragment config -enableFlag $::true
                                set addedInnerIPv6FragmentHeader 1
                            }
                            default {}
                        }
                    }
                }
                if {$addedInnerIPv6FragmentHeader} {
                    if {[ipV6 addExtensionHeader ipV6Fragment]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                IPv6 adding fragment extension header failed."
                        return $returnList
                    }
                }
                switch -- $inner_protocol {
                    ipv4 {
                        if {[ip set $chassis $card $port]} {
                            keylset returnList log "ERROR in $procName: \
                                    Failed to ip set $chassis $card $port."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                    ipv6 {
                        if {[ipV6 set $chassis $card $port]} {
                            keylset returnList log "ERROR in $procName: \
                                    Failed to ipV6 set $chassis $card $port."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                }
                foreach inner_single_option_list $inner_ipv6_mode_list {
                    if {[info exists $inner_single_option_list]} {
                        eval set inner_single_option $$inner_single_option_list
                        switch -- $inner_single_option_list {
                            inner_ipv6_src_mode {
                                if {![info exists inner_ipv6_src_addr]} {
                                    continue
                                }
                                set ipv6_src_addr_type [getIpV6Type $inner_ipv6_src_addr]
                                set tclhal_src_mode_result [getIpV6TclHalMode $inner_single_option $ipv6_src_addr_type]
                                if {[keylget tclhal_src_mode_result status] != $::SUCCESS} {
                                    keylset returnList log "ERROR in $procName: [keylget tclhal_src_mode_result log]"
                                    keylset returnList status $::FAILURE
                                    return $returnList
                                }
                                set tclhal_src_mode [keylget tclhal_src_mode_result ipv6_mode]
                                debug "ipV6 config -sourceAddrMode $tclhal_src_mode"
                                set ipv6_supp_status [getIpV6AddressTypeSupported $tclhal_src_mode]
                                if {[keylget ipv6_supp_status status] == $::FAILURE} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: [keylget ipv6_supp_status log]"
                                    return $returnList
                                }
                                if {[lsearch [keylget ipv6_supp_status address_types] $ipv6_src_addr_type] == -1} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: mode $inner_ipv6_src_mode do not\
                                            support inner_ipv6_src_addr $inner_ipv6_src_addr."
                                    return $returnList
                                }
                                ipV6 config -sourceAddrMode $tclhal_src_mode
                                if {![info exists inner_ipv6_src_mask]} {
                                    
                                    if {[info exists inner_ipv6_src_step] && ($tclhal_src_mode \
                                            == $::ipV6DecrNetwork || $tclhal_src_mode == $::ipV6IncrNetwork)} {
                                        # We must auto detect the mask.
                                        set stepMaskList [::ixia::getStepAndMaskFromIPv6 \
                                                $inner_ipv6_src_step]
                        
                                        set inner_ipv6_src_mask [keylget stepMaskList mask]
                        
                                    } else {
                                        set mask_result [getIpV6MaskRangeFromIncrMode $tclhal_src_mode]
                                        if {[keylget mask_result status] == $::FAILURE} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in $procName: [keylget mask_result log]"
                                            return $returnList
                                        }
                                        if {[scan [keylget mask_result address_range] "%u-%u" min max] != 2} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in\
                                                    $procName: cannot get supported\
                                                    interval for current\
                                                    inner_ipv6_src_mode ($inner_ipv6_src_mode)."
                                        }
                                        debug "ipV6 config -sourceMask $min"
                                        ipV6 config -sourceMask $min
                                    }
                                }
                            }
                            inner_ipv6_src_mask {
                                ipV6 config -sourceMask $inner_single_option
                            }
                            inner_ipv6_src_count {
                                if {[info exists inner_ipv6_src_mode] && $inner_ipv6_src_mode != "fixed"} {
                                    # default ipv6_src_mode is fixed
                                    # There's no point in setting ipv6_src_count value if mode is fixed
                                    ipV6 config -sourceAddrRepeatCount $inner_single_option
                                }
                            }
                            inner_ipv6_src_step {
                                debug "inner source step"
                                if {![info exists inner_ipv6_src_mode] || $inner_ipv6_src_mode == "fixed"} {
                                    # default inner_ipv6_src_mode is fixed
                                    # There's no point in calculating step value
                                    continue 
                                }
                                if {[info exists inner_ipv6_src_mask]} {
                                    set step_status [getStepValueFromIpV6 $inner_ipv6_src_step $inner_ipv6_src_mask $tclhal_src_mode]
                                    if {[keylget step_status status] != $::SUCCESS} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: [keylget step_status log]"
                                        return $returnList
                                    }
                                    set step [keylget step_status step]
                                } else {
                                    set mask_range_result [ixia::getIpV6MaskRangeFromIncrMode $tclhal_src_mode]
                                    if {[keylget mask_range_result status] == $::FAILURE} {
                                        debug "mask_range_result=$mask_range_result"
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: [keylget mask_range_result log]"
                                        return $returnList
                                    }
                                    set mask_range [keylget mask_range_result address_range]

                                    if {[scan $mask_range "%u-%u" min max] != 2} {
                                        debug "mask_range_result=$mask_range_result"
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName:\
                                                ixia::getIpV6MaskRangeFromIncrMode returned wrong."
                                        return $returnList
                                    }
                                    set step_status [getStepValueFromIpV6 $inner_ipv6_src_step $min $tclhal_src_mode]
                                    if {[keylget step_status status] != $::SUCCESS} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: [keylget step_status log]"
                                        return $returnList
                                    }
                                    if {$inner_ipv6_src_mode == "fixed"} {
                                        set step 1
                                    } else {
                                        set step [keylget step_status step]
                                    }
                                }
                                debug "inner source step=$step"
                                if {[mpexpr $step < 1] || [mpexpr $step > 4294967295]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            cannot use an amount greater than\
                                            4,294,967,295 or smaller than 1 for\
                                            inner_ipv6_src_step. The configured step is\
                                            ${inner_ipv6_src_step}, but this step is relative\
                                            to the mask provided or to the default mask for the\
                                            specified inner_ipv6_src_addr, so the actual step is $step."
                                    return $returnList
                                }
                                ipV6 config -sourceStepSize $step
                            }
                            inner_ipv6_dst_mask {
                                ipV6 config -destMask $inner_single_option
                            }
                            inner_ipv6_dst_mode {
                                if {![info exists inner_ipv6_dst_addr]} {
                                    continue
                                }
                                set ipv6_dst_addr_type [getIpV6Type $inner_ipv6_dst_addr]
                                set tclhal_dst_mode_result [getIpV6TclHalMode $inner_single_option $ipv6_dst_addr_type]
                                if {[keylget tclhal_dst_mode_result status] != $::SUCCESS} {
                                    keylset returnList log "ERROR in $procName: [keylget tclhal_dst_mode_result log]"
                                    keylset returnList status $::FAILURE
                                    return $returnList
                                }
                                set tclhal_dst_mode [keylget tclhal_dst_mode_result ipv6_mode]
                                set ipv6_supp_status [getIpV6AddressTypeSupported $tclhal_dst_mode]
                                if {[keylget ipv6_supp_status status] == $::FAILURE} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: [keylget ipv6_supp_status log]"
                                    return $returnList
                                }
                                if {[lsearch [keylget ipv6_supp_status address_types] $ipv6_dst_addr_type] == -1} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: mode $inner_ipv6_dst_mode do not\
                                            support inner_ipv6_dst_addr $inner_ipv6_dst_addr."
                                    return $returnList
                                }
                                debug "ipV6 config -destAddrMode $tclhal_dst_mode"
                                ipV6 config -destAddrMode $tclhal_dst_mode
                                if {![info exists inner_ipv6_dst_mask]} {
                                    
                                    if {[info exists inner_ipv6_dst_step] && ($tclhal_dst_mode \
                                            == $::ipV6DecrNetwork || $tclhal_dst_mode == $::ipV6IncrNetwork)} {
                                        # We must auto detect the mask.
                                        set stepMaskList [::ixia::getStepAndMaskFromIPv6 \
                                                $inner_ipv6_dst_step]
                        
                                        set inner_ipv6_dst_mask [keylget stepMaskList mask]
                        
                                    } else {
                                        set mask_result [getIpV6MaskRangeFromIncrMode $tclhal_dst_mode]
                                        if {[keylget mask_result status] == $::FAILURE} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in $procName: [keylget mask_result log]"
                                            return $returnList
                                        }
                                        if {[scan [keylget mask_result address_range] "%u-%u" min max] != 2} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in\
                                                    $procName: cannot get supported\
                                                    interval for current\
                                                    inner_ipv6_dst_mode ($inner_ipv6_dst_mode)."
                                        }
                                        
                                        debug "ipV6 config -destMask $min"
                                        ipV6 config -destMask $min
                                    }
                                }
                            }
                            inner_ipv6_dst_count {
                                if {[info exists inner_ipv6_dst_mode] && $inner_ipv6_dst_mode != "fixed"} {
                                    # default inner_ipv6_dst_mode is fixed
                                    # There's no point in setting inner_ipv6_dst_count value if mode is fixed
                                    ipV6 config -destAddrRepeatCount $inner_single_option
                                }
                            }
                            inner_ipv6_dst_step {
                                if {![info exists inner_ipv6_dst_mode] || $inner_ipv6_dst_mode == "fixed"} {
                                    # default inner_ipv6_dst_mode is fixed
                                    # There's no point in calculating step value
                                    continue 
                                }
                                debug "inner source step"
                                if {[info exists inner_ipv6_dst_mask]} {
                                    set step_status [getStepValueFromIpV6 $inner_ipv6_dst_step $inner_ipv6_dst_mask $tclhal_dst_mode]
                                    if {[keylget step_status status] != $::SUCCESS} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: [keylget step_status log]"
                                        return $returnList
                                    }
                                    set step [keylget step_status step]
                                } else {
                                    set mask_range_result [ixia::getIpV6MaskRangeFromIncrMode $tclhal_dst_mode]
                                    if {[keylget mask_range_result status] == $::FAILURE} {
                                        debug "mask_range_result=$mask_range_result"
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: [keylget mask_range_result log]"
                                        return $returnList
                                    }
                                    set mask_range [keylget mask_range_result address_range]

                                    if {[scan $mask_range "%u-%u" min max] != 2} {
                                        debug "mask_range_result=$mask_range_result"
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName:\
                                                ixia::getIpV6MaskRangeFromIncrMode returned wrong."
                                        return $returnList
                                    }
                                    set step_status [getStepValueFromIpV6 $inner_ipv6_dst_step $min $tclhal_dst_mode]
                                    if {[keylget step_status status] != $::SUCCESS} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: [keylget step_status log]"
                                        return $returnList
                                    }
                                    if {$inner_ipv6_dst_mode == "fixed"} {
                                        set step 1
                                    } else {
                                        set step [keylget step_status step]
                                    }
                                }
                                debug "inner dest step=$step"
                                if {[mpexpr $step < 1] || [mpexpr $step > 4294967295]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            cannot use an amount greater than\
                                            4,294,967,295 or smaller than 1 for\
                                            inner_ipv6_dst_step. The configured step is\
                                            ${inner_ipv6_dst_step}, but this step is relative\
                                            to the mask provided or to the default mask for the\
                                            specified inner_ipv6_dst_addr, so the actual step is $step."
                                    return $returnList
                                }
                                ipV6 config -destStepSize $step
                            }
                            default {}
                        }
                    }
                }
                if {[info exists inner_ipv6_src_mode] || \
                        [info exists inner_ipv6_src_count] || \
                        [info exists inner_ipv6_src_step] || \
                        [info exists inner_ipv6_dst_mode] || \
                        [info exists inner_ipv6_dst_count] || \
                        [info exists inner_ipv6_dst_step]} {
                    if {[ipV6 set $chassis $card $port]} {
                        keylset returnList log "ERROR in $procName: \
                                Failed to ipV6 set $chassis $card $port \
                                (mode settings). $::ixErrorInfo"
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                }
            }
            gre setDefault
            if {[info exists inner_protocol]} {
                switch -- $inner_protocol {
                    ipv4 {
                        gre config -protocolType 0x0800
                    }
                    ipv6 {
                        gre config -protocolType 0x86DD
                    }
                    default {
                        gre config -protocolType $inner_protocol
                    }
                }
            } else  {
                gre config -protocolType 0x0800
            }
            foreach gre_single_option_list $gre_option_list {
                if {[info exists $gre_single_option_list]} {
                    eval set gre_single_option $$gre_single_option_list
                    switch -- $gre_single_option_list {
                        gre_checksum_enable {
                            gre config -enableChecksum $gre_single_option
                        }
                        gre_checksum {
                            gre config -enableChecksum true
                            gre config -checksum       $gre_single_option
                        }
                        gre_valid_checksum_enable {
                            gre config -enableValidChecksum  $gre_single_option
                        }
                        gre_key_enable {
                            gre config -enableKey $gre_single_option
                        }
                        gre_key {
                            gre config -enableKey true
                            gre config -key       $gre_single_option

                        }
                        gre_reserved0 {
                            gre config -reserved0 $gre_single_option
                        }
                        gre_reserved1 {
                            gre config -reserved1 $gre_single_option
                        }
                        gre_seq_enable {
                            gre config -enableSequenceNumber $gre_single_option
                        }
                        gre_seq_number {
                            gre config -enableSequenceNumber true
                            gre config -sequenceNumber       $gre_single_option
                        }
                        gre_version {
                            gre config -version $gre_single_option
                        }
                    }
                }
            }
            if {[gre set $chassis $card $port]} {
                keylset returnList log "ERROR in $procName: \
                        Failed to gre set $chassis $card $port."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
        
        ###########
        #  FLAGS  #
        ###########
            # hlt flag          #number of commands
        set all_flags {
            arp_flag            {1                       {{protocol cget -appName} ::Arp}}
            dhcp_flag           {1                       {{protocol cget -appName} ::Dhcp}}
            gre_flag            {1                       {{ip cget -ipProtocol}    ::ipV4ProtocolGre}}
            icmp_flag           {1                       {{ip cget -ipProtocol}    ::icmp}}
            igmp_flag           {1                       {{ip cget -ipProtocol}    ::igmp}}
            integrity_flag      {0}
            auto_detect_flag    {0}
            ipv4_flag           {1                       {{protocol cget -name}    ::ipV4}}
            ipv6_flag           {1                       {{protocol cget -name}    ::ipV6}}
            ipx_flag            {1                       {{protocol cget -name}    ::ipx}}
            isl_flag            {1                       {{protocol cget -enableISLtag} ::true}}
            mpls_flag           {1                       {{protocol cget -enableMPLS} ::true}}
            pause_control_flag  {0}
            pgid_flag           {0}
            rip_flag            {1                       {{protocol cget -appName} ::Rip}}
            tcp_flag            {1                       {{ip cget -ipProtocol} ::tcp}}
            udp_flag            {1                       {{ip cget -ipProtocol} ::udp}}
            atm_flag            {0}
            sonet_flag          {0}
        }
        
        foreach {single_flag _placeholder} $all_flags {
            set $single_flag 0
        }
        
        if {$mode == "modify"} {
            if {[info exists l4_protocol]} {
                # Remove the l4 flags because they will be modified with the l4_protocol specified at input
                set all_flags {
                    arp_flag            {1                       {{protocol cget -appName} ::Arp}}
                    integrity_flag      {0}
                    auto_detect_flag    {0}
                    ipv4_flag           {1                       {{protocol cget -name}    ::ipV4}}
                    ipv6_flag           {1                       {{protocol cget -name}    ::ipV6}}
                    ipx_flag            {1                       {{protocol cget -name}    ::ipx}}
                    isl_flag            {1                       {{protocol cget -enableISLtag} ::true}}
                    mpls_flag           {1                       {{protocol cget -enableMPLS} ::true}}
                    pause_control_flag  {0}
                    pgid_flag           {0}
                    atm_flag            {0}
                    sonet_flag          {0}
                }
            }
            
            ip             get $chassis $card $port
            ipV6           get $chassis $card $port
            vlan           get $chassis $card $port
            mpls           get $chassis $card $port
            ipV6           get $chassis $card $port
            arp            get $chassis $card $port
            pauseControl   get $chassis $card $port
            tcp            get $chassis $card $port
            udp            get $chassis $card $port
            icmp           get $chassis $card $port
            # Valid starting from IxOS 5.50
            catch {icmpV6  get $chassis $card $port}
            igmp           get $chassis $card $port
            protocolOffset get $chassis $card $port
            
            catch {autoDetectInstrumentation getRx $chassis $card $port}
            
            set protocolOffsetSize 0
            if {[protocolOffset cget -enable]} {
                set protocolOffsetSize [protocolOffset cget -offset]
            }
            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                set queue_id $stream_to_queue_map($current_streamid)
                packetGroup   getQueueTx $chassis $card $port $queue_id \
                        $stream_id
                dataIntegrity getQueueTx $chassis $card $port $queue_id \
                        $stream_id

                if {[info exists vci]} {
                    atmHeader config -vci                        $vci
                }

                if {[info exists vpi]} {
                    atmHeader config -vpi                        $vpi
                }

                if {[info exists atm_header_aal5error]} {
                    switch $atm_header_aal5error {
                        no_error {
                            atmHeader config -aal5Error 0
                        }
                        bad_crc {
                            atmHeader config -aal5Error 1
                        }
                    }
                }

                if {[info exists atm_header_cell_loss_priority]} {
                    atmHeader config -cellLossPriority \
                        $atm_header_cell_loss_priority
                }

                if {[info exists atm_header_cpcs_length]} {
                    atmHeader config -cpcsLength \
                        $atm_header_cpcs_length
                }

                if {[info exists atm_header_enable_auto_vpi_vci]} {
                    atmHeader config -enableAutoVpiVciSelection \
                        $atm_header_enable_auto_vpi_vci
                }

                if {[info exists atm_header_enable_cl]} {
                    atmHeader config -enableCL \
                        $atm_header_enable_cl
                }

                if {[info exists atm_header_enable_cpcs_length]} {
                    atmHeader config -enableCpcsLength \
                        $atm_header_enable_cpcs_length
                }

                if {[info exists atm_header_encapsulation]} {
                    switch $atm_header_encapsulation {
                        vcc_mux_ipv4_routed {
                            atmHeader config -encapsulation 101
                        }
                        vcc_mux_bridged_eth_fcs {
                            atmHeader config -encapsulation 102
                        }
                        vcc_mux_bridged_eth_no_fcs {
                            atmHeader config -encapsulation 103
                        }
                        vcc_mux_ipv6_routed {
                            atmHeader config -encapsulation 104
                        }
                        vcc_mux_mpls_routed {
                            atmHeader config -encapsulation 105
                        }
                        llc_routed_clip {
                            atmHeader config -encapsulation 106
                        }
                        llc_bridged_eth_fcs {
                            atmHeader config -encapsulation 107
                        }
                        llc_bridged_eth_no_fcs {
                            atmHeader config -encapsulation 108
                        }
                        llc_pppoa {
                            atmHeader config -encapsulation 109
                        }
                        vcc_mux_ppoa {
                            atmHeader config -encapsulation 110
                        }
                        llc_nlpid_routed {
                            atmHeader config -encapsulation 111
                        }
                    }
                }

                if {[info exists atm_header_generic_flow_ctrl]} {
                    atmHeader config -genericFlowControl \
                        $atm_header_generic_flow_ctrl
                }

                if {[info exists atm_header_hec_errors]} {
                    atmHeader config -hecErrors \
                        $atm_header_hec_errors
                }

                ### VPI:

                atmHeaderCounter setDefault

                if {[info exists atm_counter_vpi_data_item_list]} {
                    set ll {}
                    foreach el $atm_counter_vpi_data_item_list {
                        set l1 [string range $el 0 1]
                        set l2 [string range $el 2 3]
                        lappend ll "$l1 $l2"
                    }

                    atmHeaderCounter config -dataItemList $ll
                }

                if {[info exists atm_counter_vpi_mask_select]} {
                    atmHeaderCounter config -maskselect \
                        $atm_counter_vpi_mask_select
                }

                if {[info exists atm_counter_vpi_mask_value]} {
                    atmHeaderCounter config -maskval \
                        $atm_counter_vpi_mask_value
                }

                if {[info exists atm_counter_vpi_mode]} {
                    switch $atm_counter_vpi_mode {
                        incr {
                            atmHeaderCounter config -mode 0
                        }
                        cont_incr {
                            atmHeaderCounter config -mode 1
                        }
                        decr {
                            atmHeaderCounter config -mode 2
                        }
                        cont_decr {
                            atmHeaderCounter config -mode 3
                        }
                    }
                }

                if {[info exists vpi_count]} {
                    atmHeaderCounter config -repeatCount $vpi_count
                }

                if {[info exists vpi_step]} {
                    atmHeaderCounter config -step        $vpi_step
                }

                if {[info exists atm_counter_vpi_type]} {
                    switch $atm_counter_vpi_type {
                        fixed {
                            atmHeaderCounter config -type 0
                        }
                        counter {
                            atmHeaderCounter config -type 1
                        }
                        random {
                            atmHeaderCounter config -type 2
                        }
                        table {
                            atmHeaderCounter config -type 3
                        }
                    }
                }

                if {[atmHeaderCounter set atmVpi]} {
                    keylset return_val status $::FAILURE
                    keylset return_val log "ERROR in $procName when: \
                            atmHeaderCounter set atmVpi. $::ixErrorInfo"
                    return $return_val
                }

                ### VCI:
                atmHeaderCounter setDefault

                if {[info exists atm_counter_vci_data_item_list]} {
                    set ll {}
                    foreach el $atm_counter_vci_data_item_list {
                        set l1 [string range $el 0 1]
                        set l2 [string range $el 2 3]
                        lappend ll "$l1 $l2"
                    }

                    atmHeaderCounter config -dataItemList $ll
                }

                if {[info exists atm_counter_vci_mask_select]} {
                    atmHeaderCounter config -maskselect \
                        [list $atm_counter_vci_mask_select]
                }

                if {[info exists atm_counter_vci_mask_value]} {
                    atmHeaderCounter config -maskval  \
                        $atm_counter_vci_mask_value
                }

                if {[info exists atm_counter_vci_mode]} {
                    switch $atm_counter_vci_mode {
                        incr {
                            atmHeaderCounter config -mode 0
                        }
                        cont_incr {
                            atmHeaderCounter config -mode 1
                        }
                        decr {
                            atmHeaderCounter config -mode 2
                        }
                        cont_decr {
                            atmHeaderCounter config -mode 3
                        }
                    }
                }

                if {[info exists vci_count]} {
                    atmHeaderCounter config -repeatCount $vci_count
                }

                if {[info exists vci_step]} {
                    atmHeaderCounter config -step        $vci_step
                }

                if {[info exists atm_counter_vci_type]} {
                    switch $atm_counter_vci_type {
                        fixed {
                            atmHeaderCounter config -type 0
                        }
                        counter {
                            atmHeaderCounter config -type 1
                        }
                        random {
                            atmHeaderCounter config -type 2
                        }
                        table {
                            atmHeaderCounter config -type 3
                        }
                    }
                }

                if {[atmHeaderCounter set atmVci]} {
                    keylset return_val status $::FAILURE
                    keylset return_val log "ERROR in $procName when: \
                            atmHeaderCounter set atmVci. $::ixErrorInfo"
                    return $return_val
                }

                if {[atmHeader set $chassis $card $port]} {
                    keylset return_val status $::FAILURE
                    keylset return_val log "ERROR in $procName when: \
                            atmHeader set $chassis $card $port. $::ixErrorInfo"
                    return $return_val
                }

            } else  {
                packetGroup   getTx $chassis $card $port $stream_id
                debug "@@@@@@ packetGroup   getTx $chassis $card $port $stream_id"
                dataIntegrity getTx $chassis $card $port $stream_id
            }
            
            if {![info exists enable_auto_detect_instrumentation]} {
                catch {autoDetectInstrumentation getTx $chassis $card $port $stream_id}
                set enable_auto_detect_instrumentation [autoDetectInstrumentation cget -enableTxAutomaticInstrumentation]
            }
            if {[info exists enable_auto_detect_instrumentation] && $enable_auto_detect_instrumentation == 1} {
                if {![info exists signature]} {
                    set signature [autoDetectInstrumentation cget -signature]
                }
            }
            if {![info exists enable_pgid]} {
                set enable_pgid [packetGroup cget -insertSignature]
            }
            
            if {[info exists enable_pgid] && $enable_pgid == 1} {
                
                if {![info exists signature]} {
                    set signature [packetGroup cget -signature]
                }
                
                # If l4_protocol exists we have to recalculate the signature_offset and pgid_offset because
                # the offset might ovelap with the new l4_protocol header ()
                if {![info exists l4_protocol]} {
                    if {![info exists signature_offset]} {
                        set signature_offset [packetGroup cget -signatureOffset]
                    }
                    
                    if {![info exists pgid_offset]} {
                        set pgid_offset [packetGroup cget -groupIdOffset]
                    }
                }
            }
            
            if {[info exists enable_data_integrity] && $enable_data_integrity} {
                if {![info exists integrity_signature]} {
                    set integrity_signature [dataIntegrity cget -signature]
                }
                if {![info exists integrity_signature_offset]} {
                    set integrity_signature_offset [dataIntegrity cget -signatureOffset]
                }
            }
            
            foreach {single_flag flag_cmd_list} $all_flags {
                set number_of_cmds [lindex $flag_cmd_list 0]
                if {$number_of_cmds == 1} {
                    
                    set flag_cmd_list [lrange $flag_cmd_list 1 end]
                    set flag_value 0
                    
                    foreach {cmd cmd_ret_val} [lindex $flag_cmd_list 0] {}
                    set cmd_ret_val [set $cmd_ret_val]
                    if {([eval $cmd] == $cmd_ret_val)} {
                        set $single_flag 1
                    }
                }
            }
            if {[lsearch -exact $args -udp_checksum] == -1} {
                set optionName udp_checksum
                if {![string is integer $optionName]} {
                    if {[info exists $optionName]} {
                        unset $optionName
                    }
                }
            }
            set opt_args_l4_udp {
                 udp_checksum                   \
                 udp_checksum_value             \
                 udp_checksum_value_tracking    \
                 udp_dst_port                   \
                 udp_dst_port_count             \
                 udp_dst_port_mode              \
                 udp_dst_port_step              \
                 udp_dst_port_tracking          \
                 udp_src_port                   \
                 udp_src_port_count             \
                 udp_src_port_mode              \
                 udp_src_port_step              \
                 udp_src_port_tracking          \
                 udp_length                     \
                 udp_length_count               \
                 udp_length_mode                \
                 udp_length_step                \
                 udp_length_tracking            \
            }
            
            set udp_flag 0
            foreach udp_param $opt_args_l4_udp {
                if {[info exists $udp_param]} {
                    set udp_flag 1
                    break
                }
            }
            if {[info exists l4_protocol] && ($l4_protocol == "udp")} {
                set udp_flag 1
            }
            if {![info exists ip_version] && $ipv6_flag} {
                set ip_version 6
            }
        }

        if {[info exists enable_auto_detect_instrumentation]} {
            foreach adi_elem $enable_auto_detect_instrumentation {
                if {![info exists enable_pgid]} {
                    if {$adi_elem} {
                        lappend enable_pgid_temp $adi_elem
                    } else {
                        # this is the default value for enable_pgid
                        lappend enable_pgid_temp 1
                    }
                }
                if {![info exists frame_sequencing]} {
                    if {$adi_elem} {
                        lappend frame_sequencing_temp enable
                    } else {
                        # this is the default value for frame_sequencing
                        lappend frame_sequencing_temp disable
                    }
                }
                if {![info exists enable_data_integrity]} {
                    if {$adi_elem} {
                        lappend enable_data_integrity_temp $adi_elem
                    } else {
                        # this is the default value for enable_data_integrity
                        lappend enable_data_integrity_temp 0
                    }
                }
                if {![info exists enable_time_stamp]} {
                    if {$adi_elem} {
                        lappend enable_time_stamp_temp $adi_elem
                    } elseif {$mode == "create"} {
                        # this is the default value for enable_time_stamp
                        lappend enable_time_stamp_temp 1
                    }
                }
            }
            if {[info exists enable_pgid_temp]} {
                set enable_pgid $enable_pgid_temp
            }
            if {[info exists frame_sequencing_temp]} {
                set frame_sequencing $frame_sequencing_temp
            }
            if {[info exists enable_data_integrity_temp]} {
                set enable_data_integrity $enable_data_integrity_temp
            }
            if {[info exists enable_time_stamp_temp]} {
                set enable_time_stamp $enable_time_stamp_temp
            }
        }
        
        if {$mode == "create"} {
            # setup all object defaults here...
            protocol      setDefault
            ip            setDefault
            vlan          setDefault
            mpls          setDefault
            mplsLabel     setDefault
            ipV6          setDefault
            arp           setDefault
            pauseControl  setDefault
            tcp           setDefault
            udp           setDefault
            icmp          setDefault
            # Valid starting from IxOS 5.50
            catch {icmpV6        setDefault}
            igmp          setDefault
            dataIntegrity setDefault
            dhcp          setDefault

            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                set atm_flag 1
                atmHeader setDefault

                if {[info exists vci]} {
                    atmHeader config -vci $vci
                }

                if {[info exists vpi]} {
                    atmHeader config -vpi $vpi
                }

                if {[info exists atm_header_aal5error]} {
                    switch $atm_header_aal5error {
                        no_error {
                            atmHeader config -aal5Error 0
                        }
                        bad_crc {
                            atmHeader config -aal5Error 1
                        }
                    }
                }

                if {[info exists atm_header_cell_loss_priority]} {
                    atmHeader config -cellLossPriority \
                        $atm_header_cell_loss_priority
                }

                if {[info exists atm_header_cpcs_length]} {
                    atmHeader config -cpcsLength \
                        $atm_header_cpcs_length
                }

                if {[info exists atm_header_enable_auto_vpi_vci]} {
                    atmHeader config -enableAutoVpiVciSelection \
                        $atm_header_enable_auto_vpi_vci
                }

                if {[info exists atm_header_enable_cl]} {
                    atmHeader config -enableCL \
                        $atm_header_enable_cl
                }

                if {[info exists atm_header_enable_cpcs_length]} {
                    atmHeader config -enableCpcsLength \
                        $atm_header_enable_cpcs_length
                }

                if {[info exists atm_header_encapsulation]} {
                    switch $atm_header_encapsulation {
                        vcc_mux_ipv4_routed {
                            atmHeader config -encapsulation 101
                        }
                        vcc_mux_bridged_eth_fcs {
                            atmHeader config -encapsulation 102
                        }
                        vcc_mux_bridged_eth_no_fcs {
                            atmHeader config -encapsulation 103
                        }
                        vcc_mux_ipv6_routed {
                            atmHeader config -encapsulation 104
                        }
                        vcc_mux_mpls_routed {
                            atmHeader config -encapsulation 105
                        }
                        llc_routed_clip {
                            atmHeader config -encapsulation 106
                        }
                        llc_bridged_eth_fcs {
                            atmHeader config -encapsulation 107
                        }
                        llc_bridged_eth_no_fcs {
                            atmHeader config -encapsulation 108
                        }
                        llc_pppoa {
                            atmHeader config -encapsulation 109
                        }
                        vcc_mux_ppoa {
                            atmHeader config -encapsulation 110
                        }
                        llc_nlpid_routed {
                            atmHeader config -encapsulation 111
                        }
                    }
                }

                if {[info exists atm_header_generic_flow_ctrl]} {
                    atmHeader config -genericFlowControl \
                        $atm_header_generic_flow_ctrl
                }

                if {[info exists atm_header_hec_errors]} {
                    atmHeader config -hecErrors \
                        $atm_header_hec_errors
                }
            }

            if {[port isValidFeature $chassis $card $port \
                        portFeatureTableUdf]} {
                tableUdf setDefault
                tableUdf clearColumns
                tableUdf clearRows
                if {[tableUdf set $chassis $card $port]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            tableUdf set $chassis $card $port.\n\
                            $::ixErrorInfo"
                    return $returnList
                }
            }

            packetGroup   setDefault
            debug "@@@@@ packetGroup   setDefault"
            packetGroup config -signature {DE AD BE EF}
            debug "@@@@@ packetGroup config -signature {DE AD BE EF}"

            if {[ipV6 clearAllExtensionHeaders]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        ipV6 clearAllExtensionHeaders on port\
                        $chassis $card $port.\n$::ixErrorInfo"
                return $returnList
            }
        }

        # Set the ip_version if it wasn't already set by mode modify
        if {![info exists ip_version]} {
            set ip_version 4
        }
        if {[info exists l3_protocol]} {
            if {$l3_protocol == "ipv6"} {
                set ipv6_flag 1
                set ip_version 6
            }
            ip config -ipProtocol 255
        } else {
            # protects against future variable not exists errors
            set l3_protocol ""
        }

        # If udf offset is the same with frame_sequencing_offset then we will
        # use the udf required by user for frame_sequencing and set the udf
        # counter type to 32
        # NOTE: This piece of code appears to be useless but it will be left 
        # here for the time being.
        if {![info exists frame_sequencing_offset]} {
            set temp_sequencing_offset 44
        } else {
            set temp_sequencing_offset $frame_sequencing_offset
        }
        set disable_udf_for_sequencing $::false

        # do all the udf stuff first
        for {set i 1} {$i < $max_udf} {incr i} {
            ## skip the udf settings if enable_udf option does not exists
            ## or is disabled
            if {![info exists enable_udf$i]} {
                continue
            }

            switch $edit {
                1 {
                    # create, so do not get
                    udf setDefault
                    udf clearRangeList
                }
                2 {
                    # modify, so get it
                    udf get $i
                }
                default {}
            }
            set counter_type [format "udf%d_counter_type" $i]
            if {![info exists $counter_type]} {
                set $counter_type [get_default_udf_counter_type]
            }
            foreach udf_item $udf_list {
                set single_option_list [format $udf_item $i]

                if {[info exists $single_option_list]} {
                    eval set single_option $$single_option_list

                    regsub -all _*udf%d_* $udf_item "" single_option_list

                    switch -- $single_option_list {
                        enable {
                            udf config -enable $single_option
                        }
                        mode {
                            set retVal $::SUCCESS
                            switch $single_option {
                                counter {
                                    udf config -counterMode $::udfCounterMode
                                    udf config -random $::false
                                }
                                random  {
                                    udf config -counterMode $::udfRandomMode
                                    udf config -random $::true
                                }
                                value_list {
                                    if {[port isValidFeature $chassis $card\
                                       $port $::portFeatureUdfExtension1 $i]} {
                                       udf config -counterMode \
                                                         $::udfValueListMode
                                       udf config -random $::false
                                    } else {
                                       set retVal $::FAILURE
                                    }
                                }
                                nested {
                                    if {[port isValidFeature $chassis $card\
                                       $port $::portFeatureUdfExtension1 $i]} {
                                       udf config -counterMode \
                                                        $::udfNestedCounterMode
                                       udf config -random $::false
                                    } else {
                                       set retVal $::FAILURE
                                    }
                                }
                                range_list {
                                    if {[port isValidFeature $chassis $card\
                                       $port $::portFeatureUdfExtension1 $i]} {
                                       udf config -counterMode \
                                                        $::udfRangeListMode
                                       udf config -random $::false
                                    } else {
                                       set retVal $::FAILURE
                                    }
                                }
                                ipv4 {
                                    if {[port isValidFeature $chassis $card\
                                       $port $::portFeatureUdfIPv4Mode $i]} {
                                       udf config -counterMode \
                                                        $::udfIPv4Mode
                                       udf config -random $::false
                                    } else {
                                       set retVal $::FAILURE
                                    }
                                }
                                default {
                                }
                            }
                            if {$retVal == $::FAILURE} {
                              keylset returnList status $::FAILURE
                              keylset returnList log "ERROR in $procName: UDF\
                                 $i does not support $single_option mode on\
                                 port: $chassis $card $port"
                              return $returnList
                            }
                        }
                        offset {
                            udf config -offset $single_option
                            if {($temp_sequencing_offset == $single_option) && \
                                    [info exists frame_sequencing] && \
                                    ($frame_sequencing == "enable")} {
                                set disable_udf_for_sequencing $::true
                                set udf${i}_counter_type 32
                            }
                        }
                        counter_type {
                            switch $single_option {
                                8 {
                                    udf config -countertype c8
                                }
                                16 {
                                    udf config -countertype c16
                                }
                                24 {
                                    udf config -countertype c24
                                }
                                32 {
                                    udf config -countertype c32
                                }
                                default {
                                }
                            }
                        }
                        counter_up_down {
                            switch $single_option {
                                up {
                                    udf config -updown uuuu
                                }
                                down {
                                    udf config -updown dddd
                                }
                                default {
                                }
                            }
                        }
                        counter_init_value {
                            # If this is more than 1 item, it's range_list.
                            # range_list is processed at the end of this loop
                            if {[llength $single_option] > 1} {
                                continue
                            }

                            # Check if it is an IP address, otherwise has
                            # no effect on valid hex items.
                            if {[string first "." $single_option] != -1} {
                                set single_option [::ixia::ip_addr_to_num \
                                        $single_option]
                            }

                            udf config -initval [::ixia::format_hex \
                                    $single_option [set $counter_type]]
                        }
                        counter_mode {
                            switch $single_option {
                                continuous {
                                    udf config -continuousCount $::true
                                }
                                count {
                                    udf config -continuousCount $::false
                                }
                                default {
                                }
                            }
                        }
                        counter_repeat_count {
                            # If this is more than 1 item, it's range_list.
                            # range_list is processed at the end of this loop
                            if {[llength $single_option] > 1} {
                                continue
                            }
                            udf config -repeat $single_option
                        }
                        counter_step {
                            # If this is more than 1 item, it's range_list.
                            # range_list is processed at the end of this loop
                            if {[llength $single_option] > 1} {
                                continue
                            }
                            udf config -step $single_option
                        }
                        value_list {
                            # If this is more than 1 item, it's range_list.
                            # range_list is processed at the end of this loop
                            set value_list_count [llength $single_option]

                            set value_list [list]
                            for {set j 0} {$j < $value_list_count} {incr j} {
                                set value [lindex $single_option $j]
                                if {[string first 0x $value] == -1} {
                                    set value [format "0x%s" $value]
                                }
                                lappend value_list [format_hex $value \
                                        [set $counter_type]]

                            }
                            udf config -valueList $value_list
                        }
                        inner_repeat_value {
                            udf config -innerRepeat $single_option
                        }
                        inner_repeat_count {
                            udf config -innerLoop $single_option
                        }
                        inner_step {
                            udf config -innerStep $single_option
                        }
                        enable_cascade {
                            udf config -enableCascade $single_option
                        }
                        cascade_type {
                            set cascadType $cascadeTypeEnumList($single_option)
                            udf config -cascadeType $cascadType
                        }
                        skip_zeros_and_ones {
                            udf config -enableSkipZerosAndOnes $single_option
                        }
                        mask_select {
                            if {[string first 0x $single_option] == -1} {
                               set single_option [format "0x%s" $single_option]
                            }
                            set mask_select [format_hex $single_option \
                                    [set $counter_type]]
                            udf config -maskselect $mask_select
                        }
                        mask_val {
                            if {[string first 0x $single_option] == -1} {
                               set single_option [format "0x%s" $single_option]
                            }
                            set mask_val [format_hex $single_option \
                                    [set $counter_type]]
                            udf config -maskval $mask_val
                        }
                        skip_mask_bits {
                            udf config -skipMaskBits $single_option
                        }
                    }
                }
            }

            ##############################
            # Handle RangeList UDF type
            ##############################
            set udf_mode [format udf%d_mode $i]
            if {[info exists $udf_mode] && \
                                       ([set $udf_mode ] == "range_list")}\
            {
               set returnList [addUdfRangeList $i]
               if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
               }
            }

            if {$i == 5} {
                if {![port isValidFeature $chassis $card $port\
                                            $::portFeatureUdf5]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: UDF 5 is not\
                            supported on port: $chassis $card $port"
                    return $returnList
                }
            }

            # getting parameters needed for chain_from tests
            set udf_enable_array(udf$i) [udf cget -enable]
            set udf_mode_array(udf$i) [udf cget -counterMode]
            set udf_cascade_array(udf$i) [udf cget -cascadeType]
            set udf_chain_array(udf$i) [udf cget -chainFrom]
            
            if {[udf set $i]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to set\
                        UDF$i on port: $chassis $card $port for Stream\
                        $current_streamid"
                return $returnList
            }
        }
        
        # after anything was set we should update chainFrom attributes
        for {set i 1} {$i < $max_udf} {incr i} {
            catch {set chained_udf [set udf${i}_chain_from]}
            if {[info exists chained_udf] && $chained_udf != "udfNone"} {
                if {![info exists udf_enable_array($chained_udf)] || \
                    $udf_enable_array($chained_udf) == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR on $procName: $chained_udf is \
                        not enabled."
                    return $returnList
                }
                if {$udf_mode_array(udf$i) == $::udfRandomMode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR on $procName: mode random of \
                        chained UDFs not supported."
                    return $returnList
                }
                if {$udf_mode_array(udf$i) == $::udfValueListMode && \
                    [port isValidFeature $chassis $card $port $::portFeatureAtmPos]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR on $procName: chain_from not \
                        supported on ATM/POS for udf_mode value_list."
                    return $returnList
                }
                if {$udf_cascade_array(udf$i) != $::udfCascadeNone && \
                    $udf_cascade_array($chained_udf) != $::udfCascadeNone} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR on $procName: chain_udf cannot \
                        be set with cascade enables."
                    return $returnList
                }
                set udf_chain_array(udf$i) $chained_udf
                # find loops
                set hop_count 0
                set start_udf udf$i
                while {$start_udf != "udfNone" && $start_udf != 0 && \
                    $hop_count <= $max_udf} {
                    set start_udf $udf_chain_array($start_udf)
                    incr hop_count
                }
                if {$hop_count > $max_udf} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR on $procName: loop UDF found."
                    return $returnList
                }
                udf get $i
                udf config -chainFrom $chained_udf
                udf set $i
            }
        }

        # Table UDF
        set table_udf_params [list      \
                table_udf_column_name   \
                table_udf_column_type   \
                table_udf_column_size   \
                table_udf_column_offset \
                table_udf_rows          ]

        set table_udf_config_options "\
                -port_handle $chassis/$card/$port \
                -mode        create               "

        foreach {table_udf_param} $table_udf_params {
            if {[info exists $table_udf_param]} {
                append table_udf_config_options \
                        " -$table_udf_param {[set $table_udf_param]}"
            }
        }

        set table_udf_result [eval ::ixia::setTableUdf \
                $table_udf_config_options]

        if {[keylget table_udf_result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget table_udf_result log]"
            return $returnList
        }

        if {$edit == 1} {
            # set some basic additional stream defaults here
            stream config -name "Stream $current_streamid"
            if {[info exists enable_time_stamp]} {
                stream config -enableTimestamp $enable_time_stamp
            }
            if {![info exists enable_pgid]} {
                set enable_pgid 1
            }

            if {![info exists pgid_value]} {
                set pgidValueIsSetByDefault 1
                set pgid_value $current_streamid
            } else {
                set pgidValueIsSetByDefault 0
            }

            if {![info exists mac_src_mode]} {
                set mac_src_mode "fixed"
            }

            if {![info exists mac_dst_mode]} {
                set mac_dst_mode "fixed"
            }

            # set a default mac source
            if {![info exists mac_src]} {
                set mac_src [get_default_mac $chassis $card $port]
            }

            # Transmit mode
            if {![info exists transmit_mode]} {
                set transmit_mode continuous_burst
            }
        } elseif {$edit == 2} {
            # Modify mode
            if {[info exists enable_time_stamp]} {
                stream config -enableTimestamp $enable_time_stamp
            }
        }

        # Add vlans
        # Setup the paramters and parameter values
        array set vlanEnumList  [list               \
                fixed          vIdle                \
                increment      vIncrement           \
                decrement      vDecrement           \
                random         vCtrRandom           \
                nested_incr    vNestedIncrement     \
                nested_decr    vNestedDecrement     \
                ]

        array set vlanConfigList  [list  \
                vlan_id              vlanID        \
                vlan_id_mode         mode          \
                vlan_user_priority   userPriority  \
                vlan_cfi             cfi           \
                vlan_id_count        repeat        \
                vlan_id_step         step          \
                vlan_protocol_tag_id protocolTagId \
                ]
        if {[info exists vlan_protocol_tag_id]} {
            set vlan_protocol_tag_id_temp ""
            foreach vlan_protocol_tag_id_elem $vlan_protocol_tag_id {
                if {![regexp "^0x" $vlan_protocol_tag_id_elem]} {
                    lappend vlan_protocol_tag_id_temp 0x$vlan_protocol_tag_id_elem
                } else {
                    lappend vlan_protocol_tag_id_temp $vlan_protocol_tag_id_elem
                }
            }
            set vlan_protocol_tag_id $vlan_protocol_tag_id_temp
        }
        # Set the protocol value
        if {[port isValidFeature $chassis $card $port \
                    portFeatureStackedVlan]} {
            if {[info exists vlan_id]} {
                if {[llength $vlan_id] > 1} {
                    set protocolDot1q vlanStacked
                } else  {
                    set protocolDot1q vlanSingle
                }
            } elseif {[info exists vlan]}  {
                set protocolDot1q vlanSingle
            } else  {
                set protocolDot1q vlanNone
            }

            set protocolDot1q_none vlanNone
        } else  {
            set protocolDot1q $::true
            set protocolDot1q_none $::false
            if {[info exists vlan_id]} {
                if {[llength $vlan_id] > 1} {
                    foreach vlanOption [array names vlanConfigList] {
                        if {[info exists $vlanOption] } {
                            set $vlanOption [lindex [set $vlanOption] 0]
                        }
                    }
                }
            }
        }
        if {[info exists vlan]} {
            switch -- $vlan {
                enable  {
                    protocol config -enable802dot1qTag $protocolDot1q
                }
                disable {
                    protocol config -enable802dot1qTag $protocolDot1q_none
                }
                default {
                    protocol config -enable802dot1qTag $protocolDot1q_none
                }
            }
        }
        if {[info exists vlan_id] && \
                    (([info exists vlan] && ($vlan == "enable")) || \
                    (![info exists vlan]))} {

            if {[llength $vlan_id] > 1} {
                foreach vlanOption [array names vlanConfigList] {
                    if {[info exists $vlanOption] } {
                        if {[llength [set $vlanOption]] < [llength $vlan_id]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $vlanOption must have the same size as\
                                    vlan_id"
                            return $returnList
                        }
                    }
                }
            }

            # Set the list of parameters with default values
            set param_value_list [list         \
                    vlan_id_step         1     \
                    vlan_id_mode         fixed \
                    vlan_protocol_tag_id 0x8100  \
                    ]

            # Initialize non-existing parameters with default values
            foreach {param value} $param_value_list {
                if {![info exists $param]} {
                    set $param [string trim \
                            [string repeat "$value " [llength $vlan_id]]]
                }
            }

            if {[lindex $vlan_id_mode 0] == "nested_incr" || \
                    [lindex $vlan_id_mode 0] == "nested_decr"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [lindex $vlan_id_mode 0] can be set only\
                        for the second vlan from the stack."
                return $returnList
            }

            # vlan_id_mode can be set to increment, decrement, nested increment
            # or nested decrement only for the first two vlans from the stack
            if {[llength $vlan_id_mode] > 2} {
                for {set i 2} {$i < [llength $vlan_id_mode]} {incr i} {
                    if {[lindex $vlan_id_mode $i] != "fixed"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [lindex $vlan_id_mode $i] is can be set only \
                                for the first two vlans from the stack."
                        return $returnList
                    }
                }
            }

            protocol config -enable802dot1qTag $protocolDot1q
            if {[llength $vlan_id] > 1} {
                stackedVlan setDefault
                # Add vlans
                for {set i 0} {$i < [llength $vlan_id]} {incr i} {
                    vlan setDefault
                    foreach item [array names vlanConfigList] {
                        if {![catch {set $item} value] } {
                            if {[lsearch [array names vlanEnumList] \
                                        [lindex $value $i]] != -1} {
                                set value $vlanEnumList([lindex $value $i])
                            } else  {
                                set value [lindex $value $i]
                            }
                            catch {vlan config -$vlanConfigList($item) $value}
                        }
                    }
                    if {$i < 2} {
                        if {[stackedVlan setVlan [mpexpr $i + 1]]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Failed to stackedVlan setVlan\
                                    [mpexpr $i + 1]"
                            return $returnList
                        }
                    } else {
                        if {[stackedVlan addVlan]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Failed to stackedVlan setVlan\
                                    [mpexpr $i + 1]"
                            return $returnList
                        }
                    }
                }
            } else  {
                vlan setDefault
                foreach item [array names vlanConfigList] {
                    if {![catch {set $item} value] } {
                        if {[lsearch [array names vlanEnumList] \
                                    $value] != -1} {
                            set value $vlanEnumList($value)
                        }
                        catch {vlan config -$vlanConfigList($item) $value}
                    }
                }
            }
        }

        foreach single_option_list $option_list {
            if {[info exists $single_option_list]} {
                eval set single_option $$single_option_list
                switch -- $single_option_list {
                    transmit_mode {
                        switch -- $single_option {
                            single_burst {
                                stream config -dma stopStream
                            }
                            multi_burst {
                                stream config -dma stopStream
                            }
                            continuous_burst {
                                stream config -dma contBurst
                            }
                            continuous {
                                stream config -dma contPacket
                            }
                            random_spaced {
                                # Do nothing
                            }
                            single_pkt {
                                stream config -dma stopStream
                                stream config -numBursts 1
                                stream config -numFrames 1
                            }
                            return_to_id {
                                stream config -dma gotoFirst
                            }
                            return_to_id_for_count {
                                stream config -dma firstLoopCount
                            }
                            advance {
                                stream config -dma advance
                            }
                            default {
                            }
                        }
                    }
                    loop_count {
                        stream config -loopCount $single_option
                    }
                    return_to_id {
                        stream config -returnToId $single_option
                    }
                    burst_loop_count {
                        stream config -numBursts $single_option
                    }
                    inter_burst_gap {
                        stream config -gapUnit gapMilliSeconds
                        stream config -ibg     $single_option
                        stream config -enableIbg $::true

                    }
                    inter_stream_gap {
                        stream config -gapUnit gapMilliSeconds
                        stream config -isg     $single_option
                        stream config -enableIsg $::true
                    }
                    length_mode  {
                        switch -- $single_option {
                            fixed {
                                stream config -frameSizeType sizeFixed
                            }
                            increment {
                                stream config -frameSizeType sizeIncr
                            }
                            random {
                                stream config -frameSizeType sizeRandom
                                weightedRandomFramesize setDefault
                                catch {weightedRandomFramesize config -randomType randomUniform}
                                if {[weightedRandomFramesize set $chassis $card $port]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in\
                                            $procName: Random\
                                            distribution could not be set.\n\
                                            $::ixErrorInfo"
                                    return $returnList
                                }
                            }
                            auto {
                                stream config -frameSizeType sizeAuto
                            }
                            imix {
                                if {$useTclHalForIxAccessStreams} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in\
                                            $procName: Imix\
                                            is not a valid option for IxOS traffic over PPP sessions.\n\
                                            $::ixErrorInfo"
                                    return $returnList
                                }
                                stream config -frameSizeType sizeRandom
                                set retValidFeature [port isValidFeature \
                                        $chassis $card $port             \
                                        portFeatureRandomFrameSizeWeightedPair]
                                if {$retValidFeature} {
                                    weightedRandomFramesize setDefault
                                    catch {weightedRandomFramesize config \
                                                -randomType randomWeightedPair}

                                    set l3imixcount 0
                                    for {set i 1} {$i < 5} {incr i} {
                                        set l3imixsize ""
                                        set l3imixsize              \
                                                [append l3imixsize  \
                                                l3_imix $i _size    ]
                                        set l3imixratio ""
                                        set l3imixratio             \
                                                [append l3imixratio \
                                                l3_imix $i _ratio   ]

                                        if {[info exists $l3imixsize] && \
                                                    [info exists \
                                                    $l3imixratio]} {
                                            if {![string is integer [set $l3imixratio]]} {
                                                keylset returnList status $::FAILURE
                                                keylset returnList log "ERROR in\
                                                        $procName: Imix\
                                                        ratio should be an integer value."
                                                return $returnList
                                            }
                                            weightedRandomFramesize addPair \
                                                    [set $l3imixsize]       \
                                                    [set $l3imixratio]
                                            incr l3imixcount
                                        }
                                    }
                                    if {$l3imixcount == 0} {
                                        catch {weightedRandomFramesize \
                                                    config -randomType randomIMIX}
                                    }
                                    if {[weightedRandomFramesize set \
                                                $chassis $card $port]} {

                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in\
                                                $procName: Imix\
                                                options could not be set.\n\
                                                $::ixErrorInfo"
                                        return $returnList
                                    }
                                }
                            }
                            gaussian -
                            quad    {
                                stream config -frameSizeType sizeRandom
                                set retValidFeature [port isValidFeature \
                                        $chassis $card $port             \
                                        portFeatureRandomFrameSizeWeightedPair]
                                if {$retValidFeature} {
                                    weightedRandomFramesize setDefault
                                    catch {weightedRandomFramesize config \
                                                -randomType randomQuadGaussian}
                                    for {set i 1} {$i < 5} {incr i} {
                                        set l3gausscount 0
                                        set l3gausscenter ""
                                        set l3gausscenter              \
                                                [append l3gausscenter  \
                                                l3_gaus $i _avg        ]
                                        set l3gaussweight ""
                                        set l3gaussweight             \
                                                [append l3gaussweight \
                                                l3_gaus $i _weight    ]

                                        set l3gausswidth ""
                                        set l3gausswidth             \
                                                [append l3gausswidth \
                                                l3_gaus $i _halfbw   ]

                                        if {[info exists $l3gausscenter]} {
                                            weightedRandomFramesize config \
                                                    -center                \
                                                    [set $l3gausscenter]

                                            incr l3gausscount
                                        }
                                        if {[info exists $l3gausswidth]} {
                                            if {([set $l3gausswidth] < 0.01) || \
                                                    ([set $l3gausswidth] > 30000)} {

                                                keylset returnList status $::FAILURE
                                                keylset returnList log "ERROR in\
                                                        $procName: Invalid value\
                                                        [set $l3gausswidth] for\
                                                        -$l3gausswidth. Valid values\
                                                        should be in range\
                                                        0.01 - 30,000."
                                                return $returnList
                                            }
                                            weightedRandomFramesize config \
                                                    -widthAtHalf           \
                                                    [set $l3gausswidth]

                                            incr l3gausscount
                                        }
                                        if {[info exists $l3gaussweight]} {
                                            weightedRandomFramesize config \
                                                    -weight                \
                                                    [set $l3gaussweight]

                                            incr l3gausscount
                                        }
                                        if {$l3gausscount > 0} {
                                            catch {weightedRandomFramesize      \
                                                        updateQuadGaussianCurve \
                                                        $i}
                                        }
                                    }
                                    if {[weightedRandomFramesize set \
                                                $chassis $card $port]} {

                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in\
                                                $procName: Gaussian/Quad\
                                                options could not be set.\n\
                                                $::ixErrorInfo"
                                        return $returnList
                                    }
                                }
                            }
                            distribution {
                                stream config -frameSizeType sizeRandom
								set retValidFeature [port isValidFeature $chassis $card $port portFeatureRandomFrameSizeWeightedPair]
                                set retValidFeature_1 [port isValidFeature $chassis $card $port portFeatureRandomFrameSizePredefinedDistributions]
								
								if {$retValidFeature == 1 || $retValidFeature_1 == 1} {
                                    if {[info exists frame_size_distribution]} {
                                        switch -- $frame_size_distribution {
                                            cisco {
                                                catch {weightedRandomFramesize config -randomType randomCisco}
                                            }
                                            imix {
                                                catch {weightedRandomFramesize config -randomType randomIMIX}
                                            }
                                            quadmodal {
                                                catch {weightedRandomFramesize config -randomType randomRPRQuadmodal}
                                            }
                                            tolly {
                                                catch {weightedRandomFramesize config -randomType randomTolly}
                                            }
                                            trimodal {
                                                catch {weightedRandomFramesize config -randomType randomRPRTrimodal}
                                            }
                                            default {
                                            }
                                        }
                                        if {[weightedRandomFramesize set $chassis $card $port]} {
                                            keylset returnList status $::FAILURE
                                            keylset returnList log "ERROR in $procName: \
                                                    Predefined distribution options could not be set.\n\
                                                    $::ixErrorInfo"
                                            return $returnList
                                        }
                                    }
                                }
                            }
                            default {
                            }
                        }
                    }
                    frame_size {
                        stream config -framesize $single_option
                    }
                    frame_size_distribution {
                        if {!([info exists length_mode] && $length_mode == "distribution")} {
                            keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: \
                                            Parameter frame_size_distribution is valid only when -length_mode \
                                            is set to distribution."
                                    return $returnList
                        }
                    }
                    frame_size_min {
                        stream config -frameSizeMIN $single_option
                    }
                    frame_size_max {
                        stream config -frameSizeMAX $single_option
                    }
                    frame_size_step {
                        stream config -frameSizeStep $single_option
                    }
                    data_pattern_mode {
                        switch -- $single_option {
                            fixed {
                                stream config -patternType nonRepeat
                            }
                            incr_byte {
                                stream config -patternType incrByte
                            }
                            decr_byte {
                                stream config -patternType decrByte
                            }
                            random {
                                stream config -patternType patternTypeRandom
                            }
                            repeating {
                                stream config -patternType repeat
                            }
                            default {
                                stream config -patternType incrByte
                            }
                        }
                    }
                    data_pattern {
                        stream config -dataPattern userpattern
                        stream config -pattern $single_option
                    }
                    ethernet_type {
                        protocol config -ethernetType $single_option
                    }
                    ethernet_value {
                        protocol config -ethernetType ethernetII
                        stream   config -frameType    $single_option
                    }
                    isl {
                        switch -- $single_option {
                            1 {
                                protocol config -enableISLtag $::true
                                set isl_flag 1
                            }
                            0 {
                                protocol config -enableISLtag $::false
                            }
                            default {
                                protocol config -enableISLtag $::false
                            }
                        }
                    }
                    isl_frame_type  {
                        switch -- $single_option {
                            ethernet   {
                                isl config -frameType islFrameEthernet
                            }
                            atm {
                                isl config -frameType islFrameATM
                            }
                            fddi {
                                isl config -frameType islFrameFDDI
                            }
                            token_ring {
                                isl config -frameType islFrameTokenRing
                            }
                            default {
                            }
                        }
                    }
                    isl_vlan_id {
                        isl config -vlanID $single_option
                    }
                    isl_user_priority {
                        isl config -userPriority $single_option
                    }
                    isl_bpdu {
                        isl config -bpdu $single_option
                    }
                    isl_index {
                        isl config -index $single_option
                    }
                    ipv6_src_addr {
                        ipV6 config -sourceAddr $single_option
                        set ipv6_dst_addr2 $ipv6_src_addr
                    }
                    ip_src_addr {
                        if {[info exists l3_protocol] && \
                                    ($l3_protocol == "arp")} {
                            arp config -sourceProtocolAddr $ip_src_addr
                        } else  {
                            ip config -sourceIpAddr $single_option
                            set ip_dst_addr2 $ip_src_addr
                        }
                    }
                    ip_src_mode {
                        if {[info exists l3_protocol] && \
                                    ($l3_protocol == "arp")} {
                            switch -- $single_option {
                                fixed {
                                    arp config -sourceProtocolAddrMode arpIdle
                                }
                                decrement {
                                    arp config -sourceProtocolAddrMode \
                                            arpDecrement
                                }
                                increment {
                                    arp config -sourceProtocolAddrMode \
                                            arpIncrement
                                }
                                random {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in \
                                            $procName: When -l3_protocol is \
                                            arp then -ip_src_mode can be \
                                            only fixed|decrement|increment"
                                    return $returnList
                                }
                                default {
                                }
                            }
                        } else  {
                            switch -- $single_option {
                                fixed {
                                    ip config -sourceIpAddrMode ipIdle
                                }
                                decrement {
                                # Special case, decrement network with no mask
                                    ip config -sourceIpAddrMode ipDecrNetwork
                                    ip config -sourceClass noClass
                                }
                                increment {
                                # Special case, increment network with no mask
                                    ip config -sourceIpAddrMode ipIncrNetwork
                                    ip config -sourceClass noClass
                                }
                                random {
                                    ip config -sourceIpAddrMode ipRandom
                                }
                                default {
                                }
                            }
                        }
                    }
                    ip_src_count {
                        if {[info exists l3_protocol] && \
                                    ($l3_protocol == "arp")} {
                            arp config -sourceProtocolAddrRepeatCount \
                                            $single_option
                        } else  {
                            ip config -sourceIpAddrRepeatCount $single_option
                        }
                    }
                    ip_src_step {
                        # Has to be handled after this main loop
                    }
                    ip_dst_addr {
                        if {[info exists l3_protocol] && \
                                    ($l3_protocol == "arp")} {
                            arp config -destProtocolAddr $ip_dst_addr
                        } else  {
                            ip config -destIpAddr $single_option
                            set ip_src_addr2 $ip_dst_addr
                        }
                    }
                    ip_dst_mode {
                        set param ""
                        if {[info exists l3_protocol] && \
                                    ($l3_protocol == "arp")} {
                            switch -- $single_option {
                                fixed {
                                    arp config -destProtocolAddrMode ipIdle
                                }
                                decrement {
                                    arp config -destProtocolAddrMode \
                                            arpDecrement
                                }
                                increment {
                                    arp config -destProtocolAddrMode \
                                            arpIncrement
                                }
                                random {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in \
                                            $procName: When -l3_protocol is \
                                            arp then -ip_dst_mode can be \
                                            only fixed|decrement|increment"
                                    return $returnList
                                }
                                default {
                                }
                            }
                        } else  {
                            switch -- $single_option {
                                fixed {
                                    ip config -destIpAddrMode ipIdle
                                }
                                decrement {
                                    # Special case, decrement network with no mask
                                    ip config -destIpAddrMode ipDecrNetwork
                                    ip config -destClass noClass
                                }
                                increment {
                                    # Special case, increment network with no mask
                                    ip config -destIpAddrMode ipIncrNetwork
                                    ip config -destClass noClass
                                }
                                random {
                                    ip config -destIpAddrMode ipRandom
                                }
                                default {
                                }
                            }
                        }
                    }
                    ip_dst_count {
                        if {[info exists l3_protocol] && \
                                    ($l3_protocol == "arp")} {
                            arp config -destProtocolAddrRepeatCount \
                                    $single_option
                        } else  {
                            ip config -destIpAddrRepeatCount $single_option
                        }
                    }
                    ip_dst_step {
                        # Has to be handled after this main loop
                    }
                    arp_src_hw_addr {
                        set _mac [convertToIxiaMac $single_option]
                        arp config -sourceHardwareAddr [join $_mac ":"]
                    }
                    arp_src_hw_mode {
                        switch -- $single_option {
                            fixed {
                                arp config -sourceHardwareAddrMode \
                                        arpIdle
                            }
                            decrement {
                                arp config -sourceHardwareAddrMode \
                                        arpDecrement
                            }
                            increment {
                                arp config -sourceHardwareAddrMode \
                                        arpIncrement
                            }
                            default {
                            }
                        }
                    }
                    arp_src_hw_count {
                        arp config -sourceHardwareAddrRepeatCount \
                                $single_option
                    }
                    arp_dst_hw_addr {
                        set _mac [convertToIxiaMac $single_option]
                        arp config -destHardwareAddr [join $_mac ":"]
                    }
                    arp_dst_hw_mode {
                        switch -- $single_option {
                            fixed {
                                arp config -destHardwareAddrMode \
                                        arpIdle
                            }
                            decrement {
                                arp config -destHardwareAddrMode \
                                        arpDecrement
                            }
                            increment {
                                arp config -destHardwareAddrMode \
                                        arpIncrement
                            }
                            default {
                            }
                        }
                    }
                    arp_dst_hw_count {
                        arp config -destHardwareAddrRepeatCount $single_option
                    }
                    arp_operation {
                        arp config -operation $single_option
                    }
                    ipv6_dst_addr {
                        ipV6 config -destAddr $single_option
                        set ipv6_src_addr2 $ipv6_dst_addr
                    }
                    ipv6_traffic_class {
                        ipV6 config -trafficClass $single_option
                    }
                    ipv6_flow_label {
                        ipV6 config -flowLabel $single_option
                    }
                    ipv6_hop_limit {
                        ipV6 config -hopLimit $single_option
                    }
                    l3_length_step {
                        stream config -frameSizeStep $single_option
                    }
                    number_of_packets_tx {
                        stream config -numFrames $single_option
                    }
                    pkts_per_burst {
                        stream config -numFrames $single_option
                    }
                    enable_pgid {
                        set _temp_name enable_auto_detect_instrumentation
                        if {(![info exists $_temp_name]) || \
                                    ([info exists $_temp_name] && \
                                    ([set $_temp_name] == 0))} {

                            switch $single_option {
                                0 {
                                    packetGroup config -insertSignature $::false
                                    debug "@@@@@ packetGroup config -insertSignature $::false"
                                }
                                1 {
                                    packetGroup config -insertSignature $::true
                                    debug "@@@@@ packetGroup config -insertSignature $::true"
                                    if {[info exists enable_time_stamp]} {
                                        stream config -enableTimestamp $enable_time_stamp
                                    }
                                    set pgid_flag 1

                                    # Need to do some auto pushing of the signature
                                    # if the user is not setting directly and there
                                    # is a need to move for certain other setups
                                    if {![info exists signature_offset]} {
                                        set sig_offset [mpexpr 48 + \
                                                            $protocolOffsetSize]
                                        
                                        if {[info exists ipv6_src_addr] || \
                                                    [info exists ipv6_dst_addr] || \
                                                    ($l3_protocol == "ipv6")} {
                                            incr sig_offset 14
                                        }
                                    } else {
                                        debug "signature_offset = $signature_offset"
                                        if {[llength $signature_offset] > 1} {
                                            set sig_offset [lindex $signature_offset 0]
                                        } else {
                                            debug "set sig_offset $signature_offset"
                                            set sig_offset $signature_offset
                                        }
                                    }
                                    if {[info exists l4_protocol]} {
                                        if {$l4_protocol == "udp"} {
                                            incr sig_offset 8
                                        } elseif {$l4_protocol == "tcp"} {
                                            incr sig_offset 20
                                        } elseif {$l4_protocol == "gre"} {
                                            incr sig_offset 4
                                            if {[info exists inner_protocol]} {
                                                switch -- $inner_protocol {
                                                    ipv4 {
                                                        incr sig_offset 20
                                                    }
                                                    ipv6 {
                                                        incr sig_offset 40
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    # Need to adjust for IPv6 extension headers
                                    set ipv6Args ""
                                    foreach item $ipv6_extension_header_list {
                                        if {[info exists $item]} {
                                            append ipv6Args \
                                                    "-$item [list [set $item]] "
                                        }
                                    }
                                    set ipv6Incr \
                                            [eval ::ixia::ipv6ExtHdrSize $ipv6Args]
                                    incr sig_offset $ipv6Incr

                                    packetGroup config -signatureOffset $sig_offset
                                    debug "@@@@@ packetGroup config -signatureOffset $sig_offset"
                                    incr sig_offset 4
                                    if {![info exists pgid_offset]} {
                                        packetGroup config -groupIdOffset $sig_offset
                                        debug "@@@@@ packetGroup config -groupIdOffset $sig_offset"
                                    }
                                }
                                default {}
                            }
                        } elseif {[info exists $_temp_name] && [set $_temp_name]} {
                            packetGroup config -insertSignature $single_option
                            set pgid_flag 1
                        }
                    }
                    pgid_value {
                        set _temp_name enable_auto_detect_instrumentation
                        if {[llength $single_option] > 1} {
                            set pgid [lindex $single_option 0]
                        } else {
                            set pgid $single_option
                        }
                        set retCode [::ixia::format_signature_hex $pgid 4]
                        if {[keylget retCode status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    [keylget retCode log]."
                            return $returnList
                        }
                        set single_option [keylget retCode signature]
                        set single_option 0x[string map {. "" : "" " " ""} \
                                $single_option]
                        
                        packetGroup config -groupId \
                                [format "%d" $single_option]
                    }
                    signature {
                        set _temp_name enable_auto_detect_instrumentation
                        if {(![info exists $_temp_name]) || \
                                    ([info exists $_temp_name] && \
                                    ([set $_temp_name] == 0))} {
                            if {([lindex $single_option 0] != [lindex $single_option 0 0]) \
                                || ([string length [lindex $single_option 0]] > 2)} {
                                set sgnTemp [lindex $single_option 0]
                            } else {
                                set sgnTemp $single_option
                            }
                            set retCode [::ixia::format_signature_hex \
                                    $sgnTemp 4]

                            if {[keylget retCode status] == $::FAILURE} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        [keylget retCode log]."
                                return $returnList
                            }
                            set single_option [keylget retCode signature]
                            packetGroup config -signature $single_option
                            debug "@@@@@ packetGroup config -signature $single_option"
                        }
                    }
                    signature_offset {
                        set _temp_name enable_auto_detect_instrumentation
                        if {(![info exists $_temp_name]) || \
                                    ([info exists $_temp_name] && \
                                    ([set $_temp_name] == 0))} {
                            if {[llength $single_option] > 1} {
                                set single_option [lindex $single_option 0]
                            }
                            if {$single_option < 8 || $single_option > 64000} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        -signature_offset $single_option range \
                                        is 8-64000. Value out of range."
                                return $returnList
                            }
                            packetGroup config -signatureOffset $single_option
                            debug "@@@@@ packetGroup config -signatureOffset $single_option"
                            set temp_offset $single_option
                            if {![info exists pgid_offset]} {
                                packetGroup config -groupIdOffset [expr $temp_offset + 4]
                                debug "@@@@@ packetGroup config -groupIdOffset [expr $temp_offset + 4]"
                            }
                        }
                    }
                    pgid_offset {
                        packetGroup config -groupIdOffset $single_option
                        debug " * * * packetGroup config -groupIdOffset $single_option * * *"
                    }
                    l2_encap  {
                        if {[info exists mpls] && ([lindex $mpls [lsearch \
                                $l2_encap $single_option]] == "enable")} {

                            set atm_vc_mux_ethernet_ii_option \
                                        atmEncapsulationVccMuxMPLSRouted

                        } elseif {[info exists ipv6_src_addr] || \
                                [info exists ipv6_dst_addr]   || \
                                ([info exists l3_protocol] && ([lindex \
                                $l3_protocol [lsearch $l2_encap \
                                $single_option]] == "ipv6")) }  {

                            set atm_vc_mux_ethernet_ii_option \
                                    atmEncapsulationVccMuxIPV6Routed
                        } else  {
                            set atm_vc_mux_ethernet_ii_option \
                                    atmEncapsulationVccMuxIPV4Routed
                        }
                        array set atmHeaderArray [list \
                                atm_vc_mux                                  \
                                $atm_vc_mux_ethernet_ii_option              \
                                atm_vc_mux_ethernet_ii                      \
                                $atm_vc_mux_ethernet_ii_option              \
                                atm_vc_mux_802.3snap                        \
                                atmEncapsulationVccMuxBridgedEthernetFCS    \
                                atm_vc_mux_802.3snap_nofcs                  \
                                atmEncapsulationVccMuxBridgedEthernetNoFCS  \
                                atm_vc_mux_ppp                              \
                                atmEncapsulationVccMuxPPPoA                 \
                                atm_vc_mux_pppoe                            \
                                notSupported                                \
                                atm_snap                                    \
                                atmEncapsulationLLCRoutedCLIP               \
                                atm_snap_ethernet_ii                        \
                                atmEncapsulationLLCRoutedCLIP               \
                                atm_snap_802.3snap                          \
                                atmEncapsulationLLCBridgedEthernetFCS       \
                                atm_snap_802.3snap_nofcs                    \
                                atmEncapsulationLLCBridgedEthernetNoFCS     \
                                atm_snap_ppp                                \
                                atmEncapsulationLLCPPPoA                    \
                                atm_snap_pppoe                              \
                                notSupported                                ]

                        array set sonetArray [list \
                                hdlc_unicast               sonetCiscoHdlc       \
                                hdlc_broadcast             sonetCiscoHdlc       \
                                hdlc_unicast_mpls          sonetCiscoHdlc       \
                                hdlc_multicast_mpls        sonetCiscoHdlc       \
                                ppp_link                   sonetHdlcPppIp       \
                                ietf_framerelay            sonetFrameRelay2427  \
                                cisco_framerelay           sonetFrameRelayCisco ]

                        array set ethernetArray [list \
                                ethernet_ii                     ethernetII   \
                                ethernet_ii_unicast_mpls        ethernetII   \
                                ethernet_ii_multicast_mpls      ethernetII   \
                                ethernet_ii_vlan                ethernetII   \
                                ethernet_ii_vlan_unicast_mpls   ethernetII   \
                                ethernet_ii_vlan_multicast_mpls ethernetII   \
                                ethernet_ii_pppoe               notSupported \
                                ethernet_ii_vlan_pppoe          notSupported ]

                        set l2_encap_type [string range $single_option \
                                0 [mpexpr [string first _ $single_option] - 1]]

                        switch -- $l2_encap_type {
                            atm      {
                                if {![port isValidFeature $chassis $card $port  \
                                        portFeatureAtm]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: \
                                            Invalid encapsulation -l2_encap\
                                            $single_option. Port\
                                            $chassis/$card/$port is not an\
                                            ATM port."
                                    return $returnList
                                }
                                if {![port isActiveFeature $chassis $card $port \
                                            portFeatureAtm]} {
                                    if {[port get $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to port get $chassis $card $port"
                                        return $returnList
                                    }
                                    port config -portMode portAtmMode
                                    if {[port set $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to port set $chassis $card $port"
                                        return $returnList
                                    }
                                }
                                if {[info exists atmHeaderArray($single_option)]\
                                        && ($atmHeaderArray($single_option)     \
                                        != "notSupported")} {
                                    atmHeader config -encapsulation \
                                            $atmHeaderArray($single_option)
                                }
                                set atm_flag 1
                            }
                            ethernet {
                                set l2_encap_ethernet [lindex [lsort \
                                        [::ixia::portSupports        \
                                        $chassis $card $port ethernet]] end]

                                set l2_encap_wan [lindex [lsort      \
                                        [::ixia::portSupports        \
                                        $chassis $card $port lan]] end]

                                set l2_encap_port_mode [port cget -portMode]

                                if {$l2_encap_ethernet == 0} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: \
                                            Invalid encapsulation -l2_encap\
                                            $single_option. Port\
                                            $chassis/$card/$port is not an\
                                            Ethernet port."
                                    return $returnList
                                }

                                if {[lsearch {1 4} $l2_encap_port_mode] == -1} {
                                    if {[port get $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to port get $chassis $card $port"
                                        return $returnList
                                    }
                                    if {$l2_encap_ethernet <= 1000} {
                                        port config -portMode portEthernetMode
                                    } elseif {$l2_encap_lan}  {
                                        port config -portMode port10GigLanMode
                                    } else  {
                                        port config -portMode port10GigWanMode
                                    }
                                    if {[port set $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to port set $chassis $card $port"
                                        return $returnList
                                    }
                                }
                                if {[info exists ethernetArray($single_option)]\
                                        && ($ethernetArray($single_option) !=  \
                                        "notSupported")} {
                                    protocol config -ethernetType \
                                            $ethernetArray($single_option)
                                }
                                if {[lsearch [split $single_option _] vlan] != -1} {
                                    if {[info exists protocolDot1q]} {
                                        protocol config -enable802dot1qTag $protocolDot1q
                                    } else {
                                        protocol config -enable802dot1qTag vlanSingle
                                    }
                                }
                                if {[lsearch [split $single_option _] mpls] != -1} {
                                    protocol config -enableMPLS 1
                                    if {[lsearch [split $single_option _]       \
                                            unicast] != -1} {
                                        mpls config -type mplsUnicast
                                    } elseif {[lsearch [split $single_option _] \
                                            multicast] != -1} {
                                        mpls config -type mplsMulticast
                                    }
                                    set mpls_flag 1
                                }
                                set sonet_flag 1
                            }
                            default  {
                                if {![port isValidFeature $chassis $card $port  \
                                        portFeaturePos]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: \
                                            Invalid encapsulation -l2_encap\
                                            $single_option. Port\
                                            $chassis/$card/$port is not a\
                                            POS port."
                                    return $returnList
                                }
                                if {![port isActiveFeature $chassis $card $port \
                                        portFeaturePos]} {
                                    if {[port get $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to port get $chassis $card $port"
                                        return $returnList
                                    }
                                    port  config -portMode portPosMode
                                    if {[port set $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to port set $chassis $card $port"
                                        return $returnList
                                    }
                                    if {[sonet get $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to get -l2_encap\
                                                $single_option. $::ixErrorInfo"
                                        return $returnList
                                    }
                                    set intf_type [lindex [lsort -dictionary \
                                            [::ixia::portSupports            \
                                            $chassis $card $port pos]] end   ]

                                    sonet config -interfaceType   $intf_type
                                    if {[sonet set $chassis $card $port]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: \
                                                Failed to set -l2_encap\
                                                $single_option. $::ixErrorInfo"
                                        return $returnList
                                    }
                                }

                                if {[sonet get $chassis $card $port]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: \
                                            Failed to get -l2_encap\
                                            $single_option. $::ixErrorInfo"
                                    return $returnList
                                }
                                sonet config -header   \
                                        [set ::[set sonetArray($single_option)]]

                                if {[lsearch [split $single_option _] mpls] != -1} {
                                    protocol config -enableMPLS 1
                                    if {[lsearch [split $single_option _]       \
                                            unicast] != -1} {
                                        mpls config -type mplsUnicast
                                    } elseif {[lsearch [split $single_option _] \
                                            multicast] != -1} {
                                        mpls config -type mplsMulticast
                                    }
                                    set mpls_flag 1
                                }
                                if {[sonet set $chassis $card $port]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: \
                                            Failed to set -l2_encap\
                                            $single_option. $::ixErrorInfo"
                                    return $returnList
                                }
                                set sonet_flag 1
                            }
                        }
                    }
                    mac_src   {
                        stream config -sa [convertToIxiaMac $single_option]
                    }
                    mac_dst  {
                        stream config -da [convertToIxiaMac $single_option]
                    }
                    mac_src_mode      {
                        switch -- $single_option {
                            increment {
                                stream config -saRepeatCounter increment
                            }
                            decrement {
                                stream config -saRepeatCounter decrement
                            }
                            random    {
                                stream config -saRepeatCounter ctrRandom
                            }
                            emulation {
                            }
                            fixed     -
                            default   {
                                stream config -saRepeatCounter idle
                            }
                        }
                    }
                    mac_dst_mode      {
                        switch -- $single_option {
                            increment {
                                stream config -daRepeatCounter increment
                            }
                            decrement {
                                stream config -daRepeatCounter decrement
                            }
                            discovery {
                                stream config -daRepeatCounter daArp
                            }
                            random    {
                                stream config -daRepeatCounter ctrRandom
                            }
                            fixed     -
                            default   {
                                stream config -daRepeatCounter idle
                            }
                        }
                    }
                    mac_src_count     {
                        stream config -numSA $single_option
                    }
                    mac_dst_count    {
                        stream config -numDA $single_option
                    }
                    mac_src_step {
                        if {![isValidInteger $single_option]} {
                            # Convert mac address to integer
                            regsub -all {\.} $mac_src_step "" tempMac
                            regsub -all {:} $tempMac "" tempMac
                            regsub -all { } $tempMac "" tempMac
                            set left_value ""
                            set right_value ""
                            set space_mac [split $single_option .]
                            set left_value [append left_value 0x \
                                    [string range $tempMac 0 3]]
                            set right_value [append right_value 0x \
                                    [string range $tempMac 4 11]]
                            set step_value \
                                    [mpexpr ($left_value << 32) | $right_value]
                        } else {
                            set step_value $single_option
                        }
                        stream config -saStep $step_value
                    }
                    mac_dst_step {
                        if {![isValidInteger $single_option]} {
                            # Convert mac address to integer
                            regsub -all {\.} $mac_dst_step "" tempMac
                            regsub -all {:} $tempMac "" tempMac
                            regsub -all { } $tempMac "" tempMac
                            set left_value ""
                            set right_value ""
                            set left_value [append left_value 0x \
                                    [string range $tempMac 0 3]]
                            set right_value [append right_value 0x \
                                    [string range $tempMac 4 11]]
                            set step_value \
                                    [mpexpr ($left_value << 32) | $right_value]
                        } else {
                            set step_value $single_option
                        }
                        stream config -daStep $step_value
                    }
                    l3_protocol {
                        switch -- $single_option {
                            ipv4          {
                                protocol config -name ipV4
                                protocol config -appName 0
                                set ipv4_flag 1
                            }
                            ipv6          {
                                protocol config -name ipV6
                                set ipv6_flag 1
                            }
                            arp           {
                                stream config -daRepeatCounter daArp
                                protocol config -name    ipV4
                                protocol config -appName Arp
                                set arp_flag 1
                            }
                            pause_control {
                                protocol config -name pauseControl
                                protocol config -appName 0
                            }
                            ipx           {
                                protocol config -name ipx
                                protocol config -appName 0
                                set ipx_flag 1
                            }
                            none {
                                protocol config -name mac
                            }
                            default {}
                        }
                    }
                    l4_protocol {
                        if {$ip_version == 4}  {
                            set ipv4_flag 1
                            switch -- $single_option {
                                ip {
                                    ip config -ipProtocol ip
                                }
                                gre {
                                    ip config -ipProtocol 47
                                    set gre_flag 1
                                }
                                icmp {
                                    ip config -ipProtocol icmp
                                    set icmp_flag 1
                                }
                                igmp {
                                    ip config -ipProtocol igmp
                                    set igmp_flag 1
                                }
                                tcp  {
                                    ip config -ipProtocol tcp
                                    set tcp_flag 1
                                }
                                udp  {
                                    ip config -ipProtocol udp
                                    set udp_flag 1
                                }
                                rip  {
                                    protocol config -appName Rip
                                    ip config -ipProtocol udp
                                    set rip_flag 1
                                }
                                dhcp {
                                    protocol config -appName Dhcp
                                    ip config -ipProtocol udp
                                    set dhcp_flag 1

                                    # For DHCP, the frame size should be at
                                    # least 346 bytes. Will check if frame
                                    # size is big enough and replace if not
                                    set min_dhcp_frame_size 346
                                    incr min_dhcp_frame_size $protocolOffsetSize
                                    
                                    if {[info exists enable_time_stamp] && $enable_time_stamp == 1} {
                                        incr min_dhcp_frame_size 6
                                    }
                                    if {[info exists enable_data_integrity] && \
                                            $enable_data_integrity == 1} {
                                        incr min_dhcp_frame_size 6
                                    }
                                    if {[info exists frame_sequencing] && \
                                            $frame_sequencing == "enable"} {
                                        incr min_dhcp_frame_size 10
                                    } else {
                                        if {$enable_pgid == 1} {
                                            incr min_dhcp_frame_size 6
                                        }
                                    }

                                    if {[info exists l3_length]} {
                                        if { $l3_length < [expr \
                                                $min_dhcp_frame_size-18]} {
                                            set l3_length [expr \
                                                    $min_dhcp_frame_size - 18]
                                            stream config -framesize \
                                                    $min_dhcp_frame_size
                                        }
                                    } elseif {[info exists frame_size]} {
                                        if { $frame_size < \
                                                $min_dhcp_frame_size} {
                                            set frame_size $min_dhcp_frame_size
                                            stream config -framesize \
                                                    $min_dhcp_frame_size
                                        }
                                    } else {
                                        set l3_length [expr \
                                                $min_dhcp_frame_size - 18]
                                        set frame_size $min_dhcp_frame_size
                                        stream config -framesize \
                                                $min_dhcp_frame_size
                                    }

                                    # Also must reposition the Packet Group
                                    # Signature, Packet Group ID, Sequence 
                                    # Number (and, in the future, Data
                                    # Integrity Signature)
                                    set base_offset 342
                                    set extra_offset $protocolOffsetSize
                                    if {[info exists enable_auto_detect_instrumentation] && \
                                            ($enable_auto_detect_instrumentation == 1)} {
                                        dataIntegrity config -signatureOffset \
                                                $base_offset
                                        packetGroup config -signatureOffset \
                                                $base_offset
                                        if {![info exists pgid_offset]} {
                                            packetGroup config -groupIdOffset \
                                                    [expr $base_offset + 12]
                                        }
                                        packetGroup config -sequenceNumberOffset \
                                                [expr $base_offset + 16]
                                    } else {
                                        if {[info exists enable_data_integrity] && \
                                                $enable_data_integrity == 1 && \
                                                ![info exists integrity_signature_offset]} {
                                            set integrity_signature_offset \
                                                $base_offset
                                            dataIntegrity config -signatureOffset \
                                                    $integrity_signature_offset
                                            incr extra_offset 4
                                        }
                                        if {[info exists frame_sequencing] && \
                                                $frame_sequencing == "enable" && \
                                                ![info exists frame_sequencing_offset]} {
                                            set frame_sequencing_offset [expr \
                                                    $base_offset + $extra_offset]
                                            packetGroup config -sequenceNumberOffset \
                                                    $frame_sequencing_offset
                                            incr extra_offset 4
                                        }
                                        if {[info exists enable_pgid] && \
                                                ($enable_pgid == 1) && ![info exists \
                                                signature_offset]} {
                                            set signature_offset [expr \
                                                    $base_offset + $extra_offset]
                                            packetGroup config -signatureOffset \
                                                    $signature_offset
                                            
                                            debug "@@@@@ packetGroup config -signatureOffset \
                                                    $signature_offset"
                                            if {![info exists pgid_offset]} {
                                                packetGroup config -groupIdOffset \
                                                        [expr $signature_offset + 4]
                                                
                                                debug "@@@@@ packetGroup config -groupIdOffset \
                                                        [expr $signature_offset + 4]"
                                            }
                                        }
                                    }
                                }
                                ospf {
                                    ip config -ipProtocol 89
                                }
                                default {}
                            }
                        } elseif {$ip_version == 6} {
                            set ipv6_flag 1
                            switch -- $single_option {
                                gre {
                                    ip config -ipProtocol 47
                                    set gre_flag 1
                                }
                                icmp {
                                    ip config -ipProtocol icmp
                                    set icmp_flag 1
                                }
                                tcp  {
                                    ip config -ipProtocol tcp
                                    set tcp_flag 1
                                }
                                udp  {
                                    ip config -ipProtocol udp
                                    set udp_flag 1
                                }
                                default {}
                            }
                        }
                    }
                    dhcp_boot_filename {
                        dhcp config -bootFileName $single_option
                        debug "dhcp config -bootFileName $single_option"
                    }
                    dhcp_client_hw_addr {
                        if {![regexp -- "^(\[0-9\]{2,2}\[ .:\])*(\[0-9\]{2,2})$"\
                                    $dhcp_client_hw_addr]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    -dhcp_client_hw_addr parameter has wrong syntax."
                            return $returnList
                        }
                        set single_option [join $dhcp_client_hw_addr ":"]
                        regsub -all {[.|:]{1}} $single_option {} single_option
                        set lenHw [llength [split $single_option ""]]
                        if {[expr $lenHw % 2] == 1} {
                            set lenHw [expr $lenHw / 2 + 1]
                        } else  {
                            set lenHw [expr $lenHw / 2]
                        }
                        set single_option [::ixia::val2Bytes 0x$single_option \
                                $lenHw]

                        dhcp config -clientHwAddr $single_option
                        debug "dhcp config -clientHwAddr $single_option"
                    }
                    dhcp_client_ip_addr {
                        dhcp config -clientIpAddr $single_option
                        debug "dhcp config -clientIpAddr $single_option"
                    }
                    dhcp_flags {
                        if {$single_option == "no_broadcast"} {
                            dhcp config -flags dhcpNoBroadcast
                            debug "dhcp config -flags dhcpNoBroadcast"
                        } else {
                            dhcp config -flags dhcpBroadcast
                            debug "dhcp config -flags dhcpBroadcast"
                        }
                    }
                    dhcp_hops {
                        dhcp config -hops $single_option
                        debug "dhcp config -hops $single_option"
                    }
                    dhcp_hw_len {
                        dhcp config -hwLen $single_option
                        debug "dhcp config -hwLen $single_option"
                    }
                    dhcp_hw_type {
                        dhcp config -hwType $single_option
                        debug "dhcp config -hwType $single_option"
                    }
                    dhcp_operation_code {
                        if {$single_option == "reply"} {
                            dhcp config -opCode dhcpBootReply
                            debug "dhcp config -opCode dhcpBootReply"
                        } else {
                            dhcp config -opCode dhcpBootRequest
                            debug "dhcp config -opCode dhcpBootRequest"
                        }
                    }

                    dhcp_option {
                        set cmdStr "::ixia::addDhcpOptions \
                                $procName [list $dhcp_option]"

                        if {[info exists dhcp_option_data]} {
                            append cmdStr " [list $dhcp_option_data]"
                        }
                        debug "$cmdStr"
                        set retCode [eval $cmdStr]
                        if {[keylget retCode status] != $::SUCCESS} {
                            return $retCode
                        }

                        # Also must reposition the Packet Group Signature,
                        # Packet Group ID, Sequence Number (and, in the future,
                        # Data Integrity Signature)
                        set base_offset [expr 282 + [keylget retCode size]]
                        if {$base_offset <= 342} {
                            set base_offset 342
                        }
                        set extra_offset $protocolOffsetSize
                        if {[info exists enable_auto_detect_instrumentation] && \
                                ($enable_auto_detect_instrumentation == 1)} {
                            dataIntegrity config -signatureOffset \
                                    $base_offset
                            packetGroup config -signatureOffset \
                                    $base_offset
                            if {![info exists pgid_offset]} {
                                packetGroup config -groupIdOffset \
                                        [expr $base_offset + 12]
                            }
                            packetGroup config -sequenceNumberOffset \
                                    [expr $base_offset + 16]
                        } else {
                            if {[info exists enable_data_integrity] && \
                                    $enable_data_integrity == 1 && \
                                    ![info exists integrity_signature_offset]} {
                                set integrity_signature_offset \
                                    $base_offset
                                dataIntegrity config -signatureOffset \
                                        $integrity_signature_offset
                                incr extra_offset 4
                            }
                            if {[info exists frame_sequencing] && \
                                    $frame_sequencing == "enable" && \
                                    ![info exists frame_sequencing_offset]} {
                                set frame_sequencing_offset [expr \
                                        $base_offset + $extra_offset]
                                packetGroup config -sequenceNumberOffset \
                                        $frame_sequencing_offset
                                incr extra_offset 4
                            }
                            if {[info exists enable_pgid] && \
                                    ($enable_pgid == 1) && ![info exists \
                                    signature_offset]} {
                                set signature_offset [expr \
                                        $base_offset + $extra_offset]
                                packetGroup config -signatureOffset \
                                        $signature_offset
                                
                                debug "@@@@@ packetGroup config -signatureOffset \
                                        $signature_offset"
                                if {![info exists pgid_offset]} {
                                    packetGroup config -groupIdOffset \
                                            [expr $signature_offset + 4]
                                }
                                
                                debug "packetGroup config -groupIdOffset \
                                        [expr $signature_offset + 4]"
                            }
                        }
                    }
                    dhcp_relay_agent_ip_addr {
                        dhcp config -relayAgentIpAddr $single_option
                        debug "dhcp config -relayAgentIpAddr $single_option"
                    }
                    dhcp_seconds {
                        dhcp config -seconds $single_option
                        debug "dhcp config -seconds $single_option"
                    }
                    dhcp_server_host_name {
                        dhcp config -serverHostName $single_option
                        debug "dhcp config -serverHostName $single_option"
                    }
                    dhcp_server_ip_addr {
                        dhcp config -serverIpAddr $single_option
                        debug "dhcp config -serverIpAddr $single_option"
                    }
                    dhcp_transaction_id {
                        dhcp config -transactionID $single_option
                        debug "dhcp config -transactionID $single_option"
                    }
                    dhcp_your_ip_addr {
                        dhcp config -yourIpAddr $single_option
                        debug "dhcp config -yourIpAddr $single_option"
                    }
                    pause_control_time {
                        pauseControl config -pauseTime $single_option
                    }
                    tcp_src_port {
                        tcp config -sourcePort $single_option
                    }
                    tcp_dst_port {
                        tcp config -destPort $single_option
                    }
                    udp_checksum {
                        if {$single_option} {
                            udp config -checksumMode $::validChecksum
                            udp config -enableChecksum true
                            udp config -enableChecksumOverride false
                        } elseif {![info exists udp_checksum_value]} {
                            udp config -checksumMode $::invalidChecksum
                            udp config -enableChecksum false
                            udp config -enableChecksumOverride false
                        } else {
                            udp config -checksumMode $::invalidChecksum
                            udp config -enableChecksum false
                            udp config -enableChecksumOverride true
                            udp config -checksum [::ixia::val2Bytes \
                                    $udp_checksum_value 2]
                        }
                    }
                    udp_src_port {
                        udp config -sourcePort $single_option
                    }
                    udp_dst_port {
                        udp config -destPort $single_option
                    }
                    tcp_seq_num {
                        tcp config -sequenceNumber $single_option
                    }
                    tcp_window {
                        tcp config -window $single_option
                    }
                    tcp_ack_num {
                        tcp config -acknowledgementNumber $single_option
                    }
                    tcp_urgent_ptr {
                        tcp config -urgentPointer $single_option
                    }
                    tcp_urg_flag {
                        tcp config -urgentPointerValid $single_option
                    }
                    tcp_psh_flag {
                        tcp config -pushFunctionValid $single_option
                    }
                    tcp_syn_flag {
                        tcp config -synchronize $single_option
                    }
                    tcp_ack_flag {
                        tcp config -acknowledgeValid $single_option
                    }
                    tcp_rst_flag {
                        tcp config -resetConnection $single_option
                    }
                    tcp_fin_flag {
                        tcp config -finished $single_option
                    }
                    icmp_code {
                        icmp config -code $single_option
                    }
                    icmp_type {
                        if {$ip_version == 4}  {
                            icmp config -type $single_option
                        } else {
                            if {[catch {icmpV6 setType $single_option}]} {
                                icmp config -type $single_option
                            }
                        }
                    }
                    icmp_id {
                        icmp config -id $single_option
                    }
                    icmp_seq {
                        icmp config -sequence $single_option
                    }
                    igmp_version {
                        igmp config -version $single_option
                    }
                    igmp_type {
                        switch -- $single_option {
                            membership_query {
                                igmp config -type membershipQuery
                            }
                            membership_report {
                                if {$igmp_version == 1} {
                                    igmp config -type membershipReport1
                                } elseif {$igmp_version == 2} {
                                    igmp config -type membershipReport2
                                } elseif {$igmp_version == 3} {
                                    igmp config -type membershipReport3
                                }
                            }
                            leave_group {
                                igmp config -type leaveGroup
                            }
                            dvmrp {
                                igmp config -type dvmrpMessage
                            }
                            default {}
                        }
                    }
                    igmp_group_count {
                        igmp config -repeatCount $single_option
                    }
                    igmp_max_response_time {
                        igmp config -maxResponseTime $single_option
                    }
                    igmp_group_mode {
                        switch -- $single_option {
                            fixed {
                                igmp config -mode igmpIdle
                            }
                            increment {
                                igmp config -mode igmpIncrement
                            }
                            decrement {
                                igmp config -mode igmpDecrement
                            }
                            default {}
                        }
                    }
                    igmp_group_addr  {
                        set min_igmp_frame_size 42
                        if {$igmp_version == 3 && \
                                $igmp_type == "membership_query"} {
                            incr min_igmp_frame_size 4
                        }

                        if {$igmp_version != 3 || \
                                $igmp_type != "membership_report"} {
                            # for all the IGMP messages except for the
                            # IGMPv3 Membership Report
                            if {[llength $single_option] != 1} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        Only one multicast group address is \
                                        required for this type of IGMP message \
                                        (IGMPv$igmp_version $igmp_type)."
                                return $returnList
                            }
                            igmp config -groupIpAddress $single_option

                            if {$igmp_version == 3 && \
                                    $igmp_type == "membership_query" && \
                                    [info exists igmp_multicast_src]} {
                                igmp config -sourceIpAddressList \
                                        $igmp_multicast_src
                                incr min_igmp_frame_size [expr 4 * \
                                        [llength $igmp_multicast_src]]
                            }
                        } else {
                            # for the IGMPv3 Membership Report
                            igmp clearGroupRecords
                            
                            if {[llength $single_option] == 1} {
                                set single_list 1
                                foreach src $igmp_multicast_src {
                                    if {[llength $src] != 1} {
                                        set single_list 0
                                        break
                                    }
                                        
                                }
                            } else {
                                set single_list 0
                            }
                            if {$single_list} {
                                set igmp_multicast_src [list $igmp_multicast_src]
                            }

                            if {[llength $single_option] != \
                                    [llength $igmp_record_type]\
                                    || [llength $single_option] != \
                                    [llength $igmp_multicast_src]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        List sizes of group record information\
                                        are not the same."
                                return $returnList
                            }

                            set group_id 0
                            foreach multicast_group $single_option {
                                igmpGroupRecord setDefault
                                igmpGroupRecord config -multicastAddress \
                                        $multicast_group
                                igmpGroupRecord config -type $record_types([\
                                        lindex $igmp_record_type $group_id])
                                igmpGroupRecord config -sourceIpAddressList [\
                                        lindex $igmp_multicast_src $group_id]
                                igmp addGroupRecord
                                incr min_igmp_frame_size [expr 8 + 4 * \
                                        [llength [lindex \
                                        $igmp_multicast_src $group_id]]]
                                incr group_id
                            }
                        }

                        # Also must reposition the Packet Group Signature,
                        # Packet Group ID, Sequence Number (and, in the future,
                        # Data Integrity Signature)
                        set extra_offset 0
                        if {[info exists enable_auto_detect_instrumentation] && \
                                ($enable_auto_detect_instrumentation == 1)} {
                            dataIntegrity config -signatureOffset \
                                    $min_igmp_frame_size
                            packetGroup config -signatureOffset \
                                    $min_igmp_frame_size
                            if {![info exists pgid_offset]} {
                                packetGroup config -groupIdOffset \
                                        [expr $min_igmp_frame_size + 12]
                            }
                            packetGroup config -sequenceNumberOffset \
                                    [expr $min_igmp_frame_size + 16]
                        } else {
                            if {[info exists enable_data_integrity] && \
                                    $enable_data_integrity == 1 && \
                                    ![info exists integrity_signature_offset]} {
                                set integrity_signature_offset \
                                        $min_igmp_frame_size
                                dataIntegrity config -signatureOffset \
                                        $integrity_signature_offset
                                incr extra_offset 4
                            }
                            if {[info exists frame_sequencing] && \
                                    $frame_sequencing == "enable" && \
                                    ![info exists frame_sequencing_offset]} {
                                set frame_sequencing_offset [expr \
                                        $min_igmp_frame_size + $extra_offset]
                                packetGroup config -sequenceNumberOffset \
                                        $frame_sequencing_offset
                                incr extra_offset 4
                            }
                            if {[info exists enable_pgid] && \
                                    ($enable_pgid == 1) && ![info exists \
                                    signature_offset]} {
                                set signature_offset [expr \
                                        $min_igmp_frame_size + $extra_offset]
                                packetGroup config -signatureOffset \
                                        $signature_offset
                                
                                debug "@@@@@ packetGroup config -signatureOffset \
                                        $signature_offset"
                                if {![info exists pgid_offset]} {
                                    packetGroup config -groupIdOffset \
                                            [expr $signature_offset + 4]
                                }
                                
                                debug "@@@@@ packetGroup config -groupIdOffset \
                                        [expr $signature_offset + 4]"
                            }
                        }
                    }
                    igmp_qqic {
                        if {$igmp_version == 3 && \
                                $igmp_type == "membership_query"} {
                            igmp config -qqic $single_option
                        } else {
                            ixPuts "WARNING in $procName: qqic is a \
                                    valid option only for IGMPv3 Membership \
                                    Queries."
                        }
                    }
                    igmp_qrv {
                        if {$igmp_version == 3 && \
                                $igmp_type == "membership_query"} {
                            igmp config -qrv $single_option
                        } else {
                            ixPuts "WARNING in $procName: qrv is a \
                                    valid option only for IGMPv3 Membership \
                                    Queries."
                        }
                    }
                    igmp_s_flag {
                        if {$igmp_version == 3 && \
                                $igmp_type == "membership_query"} {
                            igmp config -enableS $single_option
                        } else {
                            ixPuts "WARNING in $procName: igmp_s_flag is a \
                                    valid option only for IGMPv3 Membership \
                                    Queries."
                        }
                    }
                    igmp_valid_checksum {
                        igmp config -useValidChecksum $single_option
                    }
                    rip_version {
                        rip config -version $single_option
                    }
                    rip_command {
                        switch -- $single_option {
                            request {
                                rip config -command ripRequest
                            }
                            response {
                                rip config -command ripResponse
                            }
                            trace_on {
                                rip config -command ripTraceOn
                            }
                            trace_off {
                                rip config -command ripTraceOff
                            }
                            reserved {
                                rip config -command ripReserved
                            }
                            default {}
                        }
                    }
                    ip_precedence {
                        set precedence_list "routine priority immediate \
                                flash flashOverride criticEcp\
                                internetControl networkControl"
                        ip config -qosMode ipV4ConfigTos
                        ip config -precedence \
                                [lindex $precedence_list $single_option]
                    }
                    ip_delay          {
                        ip config -qosMode ipV4ConfigTos
                        ip config -delay $single_option
                    }
                    ip_throughput     {
                        ip config -qosMode ipV4ConfigTos
                        ip config -throughput $single_option
                    }
                    ip_reliability    {
                        ip config -qosMode ipV4ConfigTos
                        ip config -reliability $single_option
                    }
                    ip_cost           {
                        ip config -qosMode ipV4ConfigTos
                        ip config -cost $single_option
                    }
                    ip_length_override {
                        ip config -lengthOverride $single_option
                    }
                    ip_total_length {
                        ip config -totalLength $single_option
                        if {![info exists ip_length_override]} {
                            ip config -lengthOverride 1
                        }
                    }
                    ip_id     {
                        ip config -identifier $single_option
                    }
                    ip_fragment       {
                        switch -- $single_option {
                            1 {
                                ip config -fragment may
                            }
                            0 {
                                ip config -fragment dont
                            }
                            default {}
                        }
                    }
                    ip_fragment_last  {
                        switch -- $single_option {
                            last -
                            1 {
                                ip config -lastFragment last
                            }
                            more -
                            0 {
                                ip config -lastFragment more
                            }
                            default {}
                        }
                    }
                    ip_fragment_offset {
                        ip config -fragmentOffset $single_option
                    }
                    ip_ttl {
                        ip config -ttl $single_option
                    }
                    ip_dscp {
                        ip config -qosMode                            ipV4ConfigDscp
                        ip config -dscpMode                           ipV4DscpCustom
                        ip config -dscpValue                          [::ixia::format_hex $single_option]
                    }
                    ip_opt_security {
                        set current_options [ip cget -options]
                        set option_type 130
                        set option_length 11
                        set new_option [format "%02x %02x" $option_type \
                                $option_length]
                        append new_option " " $single_option
                        append current_options " " $new_option
                        ip config -options $current_options
                    }
                    ip_opt_loose_routing {
                        set current_options [ip cget -options]
                        set option_type 131
                        set num_ips [llength $single_option]
                        set option_length [expr 3 + ($num_ips * 4)]
                        set option_pointer 4
                        set new_option [format "%02x %02x %02x" $option_type \
                                $option_length $option_pointer]
                        foreach ip $single_option {
                            append new_option " " \
                                    [eval format \"%02x %02x %02x %02x\" \
                                    [split $ip .]]
                        }
                        append current_options " " $new_option
                        ip config -options $current_options
                    }
                    ip_opt_strict_routing {
                        set current_options [ip cget -options]
                        set option_type 137
                        set num_ips [llength $single_option]
                        set option_length [expr 3 + ($num_ips * 4)]
                        set option_pointer 4
                        set new_option [format "%02x %02x %02x" $option_type \
                                $option_length $option_pointer]
                        foreach ip $single_option {
                            append new_option " " \
                                    [eval format \"%02x %02x %02x %02x\" \
                                    [split $ip .]]
                        }
                        append current_options " " $new_option
                        ip config -options $current_options
                    }
                    ip_opt_timestamp {
                        set current_options [ip cget -options]
                        set option_type 68
                        set option_pointer 5
                        set first ""
                        set second ""
                        foreach {first second} $single_option {}
                        if {$first == ""} {
                            # Use defaults of size 40, flag 0
                            set option_length 40
                            set option_flag 0
                        } elseif {$second == ""} {
                            # Do not have a second value, so will be using
                            # one default, figure out which one
                            if {$first > 3} {
                                # This value is for length, default flag
                                set option_length $first
                                set option_flag 0
                            } else {
                                # This value is for flag, default length
                                set option_length 40
                                set option_flag $first
                            }
                        } else {
                            # Have both values, check validity and set option
                            if {$first > 3} {
                                set option_length $first
                                set option_flag $second
                            } else {
                                set option_length $second
                                set option_flag $first
                            }
                        }

                        # Have to build on the empty space for the timestamps
                        set new_option [format "%02x %02x %02x %02x" \
                                $option_type $option_length $option_pointer \
                                $option_flag]
                        for {set ctr 5} {$ctr <= $option_length} {incr ctr} {
                            append new_option " " [format "%02x" 00]
                        }

                        append current_options " " $new_option
                        ip config -options $current_options
                    }
                    ip_reserved {
                        ip config -qosMode  ipV4ConfigTos
                        ip config -reserved $single_option
                    }
                    ip_protocol {
                        if {![info exists l4_protocol]} {
                            ip config -ipProtocol $single_option
                        }
                    }
                    fcs {
                        # Do nothing here, handled in fcs_type
                    }
                    fcs_type {
                        # Look in list for fcs option to see if it is on
                        foreach temp_list $option_list {
                            if {[info exists $temp_list]} {
                                eval set temp_item $$temp_list
                                if {$temp_list == "fcs"} {
                                    if {$temp_item} {
                                        switch -- $single_option {
                                            good {
                                                stream config -fcs good
                                            }
                                            alignment {
                                                stream config -fcs alignErr
                                            }
                                            dribble {
                                                stream config -fcs dribbleErr
                                            }
                                            bad_CRC {
                                                stream config -fcs bad
                                            }
                                            no_CRC {
                                                stream config -fcs none
                                            }
                                            default {}
                                        }
                                    }
                                }
                            }
                        }
                    }
                    rate_percent {
                        stream config -rateMode usePercentRate
                        stream config -percentPacketRate $single_option
                    }
                    rate_pps {
                        # Older versions of IxOS cannot set this directly.
                        # Therefore, it will be handled outside the loop.
                        if {$ixTclHal_version > 3.70} {
                            stream config -rateMode streamRateModeFps
                            stream config -fpsRate $single_option
                        }
                    }
                    rate_bps {
                        # Older versions of IxOS cannot set this directly.
                        # Therefore, it will be handled outside the loop.
                        if {$ixTclHal_version > 3.70} {
                            stream config -rateMode streamRateModeBps
                            stream config -bpsRate $single_option
                        }
                    }
                    rate_frame_gap {
                        stream configure -rateMode streamRateModeGap
                        debug "traffic_config: stream configure -rateMode streamRateModeGap"
                        stream configure -gapUnit gapMilliSeconds
                        debug "traffic_config: stream configure -gapUnit gapMilliSeconds"
                    }
                    number_of_packets_per_stream {
                        stream config -numFrames $single_option
                    }
                    enable_data_integrity {
                        set vm_ports_detected [expr [chassis cget -type] == 24]
                        if {$vm_ports_detected} {
                            puts "WARNING: IxVM ports detected. Data Integrity will be disabled (not supported by IxVM ports)"
                            set integrity_flag 0
                        } else {
                            set _temp_name enable_auto_detect_instrumentation
                            if {(![info exists $_temp_name]) || \
                                        ([info exists $_temp_name] && \
                                        ([set $_temp_name] == 0))} {
                                if { $single_option == 1 } {
                                    set integrity_flag 1
                                    dataIntegrity config -insertSignature 1
                                    if {![info exists integrity_signature]} {
                                        dataIntegrity config -signature "DE AD BE EF"
                                    }
                                    if {![info exists integrity_signature_offset]} {
                                        dataIntegrity config -signatureOffset 48
                                    }
                                    if {[info exists enable_time_stamp]} {
                                        dataIntegrity config -enableTimeStamp $enable_time_stamp
                                    }
                                } else {
                                    set integrity_flag 1
                                    dataIntegrity config -insertSignature 0
                                    # Default value set by setDefault will cause error
                                    # on ATM cards. This value will be ignored because
                                    # dataIntegrity signature will not be inserted
                                    if {[port isValidFeature $chassis $card $port  \
                                            portFeatureAtm]} {
                                        # Changed value from 66 to 50 because of bug BUG544606
                                        dataIntegrity config -signatureOffset 50
                                    }
                                }
                            } elseif {[info exists $_temp_name] && \
                                    [set $_temp_name] && ([package present IxTclHal] > 5.00)} {
                                dataIntegrity config -insertSignature $single_option
                                if {[info exists enable_time_stamp]} {
                                    dataIntegrity config -enableTimeStamp $enable_time_stamp
                                }
                                set integrity_flag 1
                            }
                        }
                    }
                    integrity_signature {
                        set retCode [::ixia::format_signature_hex \
                                $single_option 4]

                        if {[keylget retCode status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    [keylget retCode log]."
                            return $returnList
                        }
                        set single_option [keylget retCode signature]
                        dataIntegrity config -signature $single_option
                    }
                    integrity_signature_offset {
                        set _temp_name enable_auto_detect_instrumentation
                        if {(![info exists $_temp_name]) || \
                                ([info exists $_temp_name] && \
                                ([set $_temp_name] == 0))} {
                            dataIntegrity config -signatureOffset $single_option
                        }
                    }
                    frame_sequencing {
                        if { $single_option == "enable" } {
                            packetGroup config -insertSequenceSignature $::true
                            set pgid_flag   1
                            set enable_pgid 1
                            if {$disable_udf_for_sequencing} {
                                packetGroup config -allocateUdf $::false
                            } else {
                                udf setDefault
                                udf config -continuousCount $::true
                            }
                        } elseif {$single_option == "disable"} {
                            packetGroup config -insertSequenceSignature $::false
                        }
                    }
                    frame_sequencing_offset {
                        set _temp_name enable_auto_detect_instrumentation
                        if {(![info exists $_temp_name]) || \
                                ([info exists $_temp_name] && \
                                ([set $_temp_name] == 0))} {
                            packetGroup config -sequenceNumberOffset $single_option
                        }

                    }
                    mpls {
                        if { $single_option == "enable" } {
                            protocol config -enableMPLS $::true
                            mpls config -forceBottomOfStack $::false
                            set mpls_flag 1
                        } elseif {$single_option == "disable"} {
                            protocol config -enableMPLS $::false
                        }
                    }
                    mpls_labels {
                        set mpls_label_number 1

                        for {set j 0} {$j < [llength $mpls_labels]} {incr j} {
                            # MPLS LABEL
                            mplsLabel config -label [lindex $mpls_labels $j]

                            # MPLS TTL
                            if {[info exists mpls_ttl]} {
                                if {[llength $mpls_ttl] == \
                                        [llength $mpls_labels]} {
                                    mplsLabel config -timeToLive \
                                            [lindex $mpls_ttl $j]
                                } else {
                                    mplsLabel config -timeToLive 64
                                }
                            } else {
                                mplsLabel config -timeToLive 64
                            }

                            # MPLS EXP BIT
                            if {[info exists mpls_exp_bit]} {
                                if {[llength $mpls_exp_bit] == \
                                        [llength $mpls_labels]} {
                                    mplsLabel config -experimentalUse \
                                            [lindex $mpls_exp_bit $j]
                                }
                            }

                            # MPLS BOTTOM STACK BIT
                            if {($mpls_bottom_stack_bit == 1) && \
                                    ([mpexpr [llength $mpls_labels] - 1] == $j)} {
                                mplsLabel config -bottomOfStack $::true
                            } else {
                                mplsLabel config -bottomOfStack $::false
                            }

                            mplsLabel set $mpls_label_number
                            incr mpls_label_number
                        }
                        set number_of_mpls_labels $mpls_label_number
                    }
                    mpls_type {
                        if { $single_option == "unicast"} {
                            mpls config -type mplsUnicast
                        }
                        if { $single_option == "multicast"} {
                            mpls config -type mplsMulticast
                        }
                    }
                    name {
                        stream config -name $single_option
                    }
                    default {}
                }
            }
        }

        # Need to determine what frame size we will have.  Determine the
        # amount to add to the l3 lengths
        # Ultimately incorporate usage of the l2_encap to find initial value
        if {[port isActiveFeature $chassis $card $port portFeaturePos]} {
            set temp_frame_size 4
        } elseif {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
            set temp_frame_size 5
        } else {
            # Defaulting everything else to ethernet
            set temp_frame_size 14
        }

        # Add 4 for the CRC
        incr temp_frame_size 4

        if {[info exists vlan_id] && \
            (([info exists vlan] && ($vlan == "enable")) || \
            (![info exists vlan]))} {
            incr temp_frame_size [mpexpr 4 * [llength $vlan_id]]
        }

        if {[info exists mpls_labels]} {
            incr temp_frame_size [expr ($number_of_mpls_labels - 1) * 4]
        }

        if {[info exists ethernet_type]} {
            switch -- $ethernet_type {
                ieee8023snap {
                    incr temp_frame_size 10
                }
                ieee8022 {
                    incr temp_frame_size 3
                }
                default {
                    # Others are accounted for elsewhere
                }
            }
        }

        if {[info exists enable_auto_detect_instrumentation] && \
                    ($enable_auto_detect_instrumentation == 1)} {
            if {[info exists signature]} {
                if {[llength $signature] > 1 && \
                        ![regexp {^[0-9a-fA-F]{2}( [0-9a-fA-F]{2}){11}$} $signature] } {
                    set signature_temp $signature
                    set signature ""
                    foreach elem_sign $signature_temp {
                        set retCode [::ixia::format_signature_hex \
                                $elem_sign 12]
                        if {[keylget retCode status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    [keylget retCode log]."
                            return $returnList
                        }
                        lappend signature [keylget retCode signature]
                    }
                    set signature_temp [lindex $signature 0]
                } else {
                    set retCode [::ixia::format_signature_hex \
                            $signature 12]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]."
                        return $returnList
                    }
                    set signature [keylget retCode signature]
                    set signature_temp $signature
                }
            }
    
            if {[port isValidFeature $chassis $card $port portFeatureAutoDetectTx]} {
                autoDetectInstrumentation setDefault
                autoDetectInstrumentation config -enableTxAutomaticInstrumentation $::true
                if {[info exists signature]} {
                    autoDetectInstrumentation config -signature $signature_temp
                } else {
                    autoDetectInstrumentation config -signature \
                            "87 73 67 49 42 87 11 80 08 71 18 05"
                }
                set auto_detect_flag 1
            } elseif {!$useTclHalForIxAccessStreams} {
                # If auto detect instrumentation is enabled then the
                # framesize will pe increased with
                # 12 bytes for the signature
                # 4  bytes for pgid/data integrity
                # 4  bytes for sequence checking
    
                set enable_pgid 1
    
                packetGroup config -insertSignature $::false
                if {[info exists enable_time_stamp]} {
                    stream      config -enableTimestamp $enable_time_stamp
                }
                set pgid_flag 1
    
                set l2_sizes_list [list frame_size frame_size_min ]
                set l3_sizes_list [list l3_length l3_length_min ]
    
                set _adi_framesize ""
                foreach {size_option} $l2_sizes_list {
                    if {[info exists $size_option]} {
                        set _adi_framesize [set $size_option]
                        break;
                    }
                }
                if {$_adi_framesize == ""} {
                    foreach {size_option} $l3_sizes_list {
                        if {[info exists $size_option]} {
                            set _adi_framesize [expr [set $size_option] + \
                                    $temp_frame_size]
                            break;
                        }
                    }
                }
                if {$_adi_framesize == ""} {
                    set _adi_framesize 64
                }
    
                # signature
                incr _adi_framesize  12
                incr temp_frame_size 12
                # pgid / data integrity
                incr _adi_framesize  4
                incr temp_frame_size 4
                if {[info exists enable_data_integrity] && $enable_data_integrity} {
                    incr temp_frame_size 2
                    set _di_checking_len 2
                } else  {
                    set _di_checking_len 0
                }
    
                # sequence checking
                set _frame_seq_len 0
    
                if {[info exists frame_sequencing] && ($frame_sequencing == "enable")} {
                    incr _adi_framesize  4
                    incr temp_frame_size 4
                    incr _frame_seq_len  4
                }
    
                # for the start offset of the signature we need to deduct from the
                # packet length:
                # 4 bytes for FCS/CRC
                # 6 bytes for the timestamp
                # 2 bytes for data integrity checking
                # 12 bytes signature
                # 4 bytes pgid/data_integrity
                # 4 bytes sequencing
                set _start_offset  [expr $_adi_framesize \
                        - 4 - 6 - $_di_checking_len - 12 - 4 - $_frame_seq_len]
    
                if {[expr $_start_offset % 2] == 1} {
                    set _start_offset [expr $_start_offset - 1]
                }
    
                # For table udf <start offset> + <field size> must be less than 248
                if {$_start_offset > 232} {
                    set _start_offset 232
                }
    
                set _pgid_offset   [expr $_start_offset + 12 ]
                set _seq_offset    [expr $_start_offset + 12 + 4]
    
                if {($_start_offset > $_adi_framesize) || \
                        ($_pgid_offset > $_adi_framesize) || \
                        ($_seq_offset > $_adi_framesize)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            Invalid framesize."
                    return $returnList
    
                }
    
                if {[info exists pgid_value]} {
                    if {[llength $pgid_value] > 1} {
                        set pgid [lindex $pgid_value 0]
                    } else {
                        set pgid $pgid_value
                    }
                    set retCode [::ixia::format_signature_hex $pgid 4]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]."
                        return $returnList
                    }
                    set pgid_value_hex [keylget retCode signature]
                }
    
                array set default_option_values {
                    signature_temp       "87 73 67 49 42 87 11 80 08 71 18 05"
                    integrity_signature  "DE AD BE EF"
                }
    
                foreach {default_option} [array names default_option_values] {
                    if {![info exists $default_option]} {
                        set $default_option $default_option_values($default_option)
                    } else  {
                        set $default_option [string map {. " " : " "} \
                                [set $default_option]]
                    }
                }
    
                set _table_udf_column_name   [list "Signature Value"    "PGID Value"]
                set _table_udf_column_type   [list hex hex]
                set _table_udf_column_offset [list $_start_offset $_pgid_offset]
                set _table_udf_column_size   [list 12   4]
    
                keylset _table_udf_rows row_1 [list $signature_temp $pgid_value_hex]
                set table_udf_status [::ixia::setTableUdf \
                        -port_handle                $chassis/$card/$port      \
                        -mode                       modify                    \
                        -table_udf_column_name      $_table_udf_column_name   \
                        -table_udf_column_size      $_table_udf_column_size   \
                        -table_udf_column_type      $_table_udf_column_type   \
                        -table_udf_column_offset    $_table_udf_column_offset \
                        -table_udf_rows             $_table_udf_rows          ]
    
                if {[keylget table_udf_status status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget table_udf_status log]."
                    return $returnList
                }
    
                if {[info exists enable_data_integrity]  && $enable_data_integrity} {
                    set retCode [::ixia::format_signature_hex \
                            $integrity_signature 4]
    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]."
                        return $returnList
                    }
                    set integrity_signature [keylget retCode signature]
    
                    dataIntegrity config -insertSignature $::true
                    dataIntegrity config -signature       $integrity_signature
                    dataIntegrity config -signatureOffset $_pgid_offset
    
                    set integrity_flag 1
                }
                if {[info exists frame_sequencing]} {
                    if { $frame_sequencing == "enable" } {
                        packetGroup config -insertSequenceSignature $::false
    
                        udf setDefault
                        udf clearRangeList
                        udf config  -enable           true
                        udf config  -continuousCount  true
                        udf config  -offset           $_seq_offset
                        udf config  -counterMode      udfCounterMode
                        udf config  -chainFrom        udfNone
                        udf config  -countertype      c32
                        udf config  -updown           uuuu
                        udf config  -initval          {00 00 00 00}
                        udf config  -repeat           1
                        udf config  -cascadeType      udfCascadeNone
                        udf config  -enableCascade    false
                        udf config  -step             1
    
                        if {![port isValidFeature $chassis $card $port\
                                    $::portFeatureUdf5]} {
                            udf set 4
                            if {[info exists enable_udf4] && $enable_udf4} {
                                if {[catch {keylget returnList log} retLog]} {
                                    set retLog ""
                                }
                                keylset returnList log "${retLog}\
                                        \nWarning in $procName: Udf4\
                                        was over written by sequence checking."
                            }
                        } else  {
                            udf set 5
                            if {[info exists enable_udf5] && $enable_udf4} {
                                if {[catch {keylget returnList log} retLog]} {
                                    set retLog ""
                                }
                                keylset returnList log "${retLog}\
                                        \nWarning in $procName: Udf5\
                                        was over written by sequence checking."
                            }
                        }
                        set pgid_flag 1
                    } elseif {$frame_sequencing == "disable"} {
                        packetGroup config -insertSequenceSignature $::false
                        set pgid_flag 1
                    }
                }
            } elseif {$useTclHalForIxAccessStreams} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        Auto Detect Instrumentation is not supported for this\
                        port $chassis $card $port when configuring traffic\
                        over PPP sessions."
                return $returnList
            }
        }
        if {[info exists protocolOffsetSize] && \
                [info exists protocolOffsetEnable] && $protocolOffsetEnable} {
            incr temp_frame_size $protocolOffsetSize
        }
        if {[info exists l3_length]} {
            stream config -framesize    [expr $l3_length + $temp_frame_size]
        }
        if {[info exists l3_length_min]} {
            stream config -frameSizeMIN [expr $l3_length_min + $temp_frame_size]
        }
        if {[info exists l3_length_max]} {
            stream config -frameSizeMAX [expr $l3_length_max + $temp_frame_size]
        }

        # Set the rate if the rate_pps or rate_bps is being used and the IxOS
        # version is 3.70 or lower
        if {[info exists rate_pps] && ($ixTclHal_version <= 3.70)} {
            if {[info exists length_mode] && $length_mode != "fixed"} {
                # For random and increment, we will use the middle value
                # between min and max for our calculations.  Auto, we will have
                # to handle after we write the streams to find out the size it
                # got set to.
                if {$length_mode != "auto"} {
                    if {[info exists l3_length_min] && \
                            [info exists l3_length_max]} {
                        set framesize \
                                [mpexpr ($l3_length_min + $l3_length_max) / 2.0]
                        stream config -rateMode usePercentRate
                        stream config -percentPacketRate \
                                [calculatePercentMaxRate $chassis $card $port \
                                $rate_pps $framesize 8]
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Use of\
                                length_mode $length_mode requires that\
                                l3_length_min and l3_length_max be set also. \
                                One of them is not set."
                        return $returnList
                    }
                }
            } else {
                stream config -rateMode usePercentRate
                stream config -percentPacketRate \
                            [calculatePercentMaxRate $chassis $card $port \
                            $rate_pps [stream cget -framesize] 8]
            }
        }

        if {[info exists rate_bps] && ($ixTclHal_version <= 3.70)} {
            if {[info exists length_mode] && $length_mode != "fixed"} {
                # For random and increment, we will use the middle value
                # between min and max for our calculations.  Auto, we will have
                # to handle after we write the streams to find out the size it
                # got set to.
                if {$length_mode != "auto"} {
                    if {[info exists l3_length_min] && \
                            [info exists l3_length_max]} {
                        set framesize \
                                [mpexpr ($l3_length_min + $l3_length_max) / 2.0]
                        set ratepps [mpexpr $rate_bps / ($framesize * 8.)]
                        stream config -rateMode usePercentRate
                        stream config -percentPacketRate \
                                [calculatePercentMaxRate $chassis $card $port \
                                $ratepps $framesize 8]
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Use of\
                                length_mode $length_mode requires that\
                                l3_length_min and l3_length_max be set also. \
                                One of them is not set."
                        return $returnList
                    }
                }
            } else {
                set ratepps [mpexpr $rate_bps / ([stream cget -framesize] * 8.)]
                stream config -rateMode usePercentRate
                stream config -percentPacketRate \
                        [calculatePercentMaxRate $chassis $card $port \
                        $ratepps [stream cget -framesize] 8]
            }
        }

        # Need to set the udf offsets if the ip_src_step or ip_dst_step options
        # were used.
        #  Also the address mode must be increment or decrement
        if {[info exists ip_src_mode] && (($ip_src_mode == "increment") || \
                ($ip_src_mode == "decrement"))} {
            set srcmodeValid 1
        } else {
            set srcmodeValid 0
        }
        set ip_src_use_udf 0
        if {[info exists ip_src_step] && $srcmodeValid} {
            set ip_src_use_udf 0
            # If only one octet is being incremented and it is being incremented
            # by one, then we do not need to use a udf and can use regular
            # settings.
            if {$ip_src_step == "0.0.0.1"} {
                if {[info exists ip_src_mode] && ($ip_src_mode == "increment")} {
                    ip config -sourceIpAddrMode ipIncrHost
                } else {
                    ip config -sourceIpAddrMode ipDecrHost
                }
                ip config -sourceIpMask 0.0.0.0
            } elseif {($ip_src_step == "0.0.1.0") || \
                    ($ip_src_step == "0.1.0.0") || \
                    ($ip_src_step == "1.0.0.0")} {
                if {[info exists ip_src_mode] && ($ip_src_mode == "increment")} {
                    ip config -sourceIpAddrMode ipIncrNetwork
                } else {
                    ip config -sourceIpAddrMode ipDecrNetwork
                }
                if {($ip_src_step == "0.0.1.0")} {
                    ip config -sourceClass classC
                } elseif {($ip_src_step == "0.1.0.0")} {
                    ip config -sourceClass classB
                } elseif {($ip_src_step == "1.0.0.0")} {
                    ip config -sourceClass classA
                }
            } else {
                set ip_src_use_udf 1
                ip config -sourceIpAddrMode ipIdle

                # Have to configure a udf to handle this, will always use udf1.
                udf setDefault

                udf config -enable 1
                udf config -counterMode udfCounterMode
                udf config -random 0
                udf config -countertype c32
                if {[info exists ip_src_mode] && ($ip_src_mode == "increment")} {
                    udf config -updown uuuu
                } else {
                    udf config -updown dddd
                }
                udf config -continuousCount $::false

                # Repeat value will be the ip_src_count
                if {[info exists ip_src_count]} {
                    udf config -repeat $ip_src_count
                } else {
                    udf config -repeat 1
                }

                # Step value will be the ip_src_step
                set step_value [::ixia::ip_addr_to_num $ip_src_step]
                udf config -step $step_value

                if {[catch {udf set 1} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed\
                            to set the udf 1 for usage of the\
                            ip_src_step option."
                    return $returnList
                }
            }
        } elseif {[info exists ip_src_step] && [info exists ip_src_mode] && \
                $ip_src_mode == "random"} {
            debug "ip config -sourceIpMask $ip_src_step"
            ip config -sourceIpMask $ip_src_step
        }
                

                
        if {[info exists ip_dst_mode] && (($ip_dst_mode == "increment") || \
                ($ip_dst_mode == "decrement"))} {
            set dstmodeValid 1
        } else {
            set dstmodeValid 0
        }
        set ip_dst_use_udf 0

        if {[info exists ip_dst_step] && $dstmodeValid} {
            set ip_dst_use_udf 0
            # If only one octet is being incremented and it is being incremented
            # by one, then we do not need to use a udf and can use regular
            # settings.
            if {$ip_dst_step == "0.0.0.1"} {
                if {[info exists ip_dst_mode] && ($ip_dst_mode == "increment")} {
                    ip config -destIpAddrMode ipIncrHost
                } else {
                    ip config -destIpAddrMode ipDecrHost
                }
                ip config -destIpMask 0.0.0.0
            } elseif {($ip_dst_step == "0.0.1.0") || \
                    ($ip_dst_step == "0.1.0.0") || \
                    ($ip_dst_step == "1.0.0.0")} {
                if {[info exists ip_dst_mode] && ($ip_dst_mode == "increment")} {
                    ip config -destIpAddrMode ipIncrNetwork
                } else {
                    ip config -destIpAddrMode ipDecrNetwork
                }
                if {($ip_dst_step == "0.0.1.0")} {
                    ip config -destClass classC
                } elseif {($ip_dst_step == "0.1.0.0")} {
                    ip config -destClass classB
                } elseif {($ip_dst_step == "1.0.0.0")} {
                    ip config -destClass classA
                }
            } else {
                set ip_dst_use_udf 1
                ip config -destIpAddrMode ipIdle

                # Have to configure a udf to handle this, will always use udf2.
                udf setDefault

                udf config -enable 1
                udf config -counterMode udfCounterMode
                udf config -random 0
                udf config -countertype c32
                if {[info exists ip_dst_mode] && ($ip_dst_mode == "increment")} {
                    udf config -updown uuuu
                } else {
                    udf config -updown dddd
                }
                udf config -continuousCount $::false

                # Repeat value will be the ip_dst_count
                if {[info exists ip_dst_count]} {
                    udf config -repeat $ip_dst_count
                } else {
                    udf config -repeat 1
                }

                # Step value will be the ip_dst_step
                set step_value [::ixia::ip_addr_to_num $ip_dst_step]
                udf config -step $step_value

                if {[catch {udf set 2} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed\
                            to set the udf 2 for usage of the\
                            ip_dst_step option."
                    return $returnList
                }
            }
        } elseif {[info exists ip_dst_step] && [info exists ip_dst_mode] && \
                $ip_dst_mode == "random"} {
            debug "ip config -destIpMask $ip_dst_step"
            ip config -destIpMask $ip_dst_step
        }

        # If no Datalink is selected for an Ethernet port, default is EthernetII
        if {![info exists ethernet_type]} {
            if {[get_port_type $chassis $card $port] == "ethernet"} {
                protocol config -ethernetType ethernetII
            }
        }

        set ipV6Args [list ipv6_src_addr ipv6_dst_addr ipv6_dst_step \
                ipv6_traffic_class ipv6_flow_label ipv6_hop_limit ]

        set setIpV6 0
        foreach {ipv6_arg} $ipV6Args {
            if {[info exists $ipv6_arg]} {
                set setIpV6 1
                break
            }
        }
        set ipV4Args [list ip_src_addr ip_src_mode ip_src_count ip_src_step \
                ip_dst_addr ip_dst_mode ip_dst_count ip_dst_step \
                ip_fragment_offset ip_fragment ip_fragment_last  \
                ip_ttl ip_protocol ip_id ip_precedence ip_dscp   ]

        set setIpV4 0
        foreach {ipv4_arg} $ipV4Args {
            if {[info exists $ipv4_arg]} {
                set setIpV4 1
                break
            }
        }
        set arpArgs [list arp_src_hw_addr arp_src_hw_mode arp_src_hw_count \
                arp_dst_hw_addr arp_dst_hw_mode arp_dst_hw_count arp_operation]

        set setArp 0
        foreach {arp_arg} $arpArgs {
            if {[info exists $arp_arg]} {
                set setArp 1
                break
            }
        }
        if {[info exists l3_protocol] && ($l3_protocol != "")} {
            switch -- $l3_protocol {
                ipv4 {
                    if {[ip set $chassis $card $port]} {
                        keylset returnList log "ERROR in $procName: \
                                Failed to ip set $chassis $card $port."
                        keylset returnList status $::FAILURE
                        return $returnList
                   }
                }
                ipv6 {
                    if {[ipV6 set $chassis $card $port]} {
                        keylset returnList log "ERROR in $procName: \
                                Failed to ipV6 set $chassis $card $port."
                        keylset returnList status $::FAILURE
                        return $returnList
                   }
                }
                arp {
                    if {[arp set $chassis $card $port]} {
                        keylset returnList log "ERROR in $procName: \
                                Failed to arp set $chassis $card $port."
                        keylset returnList status $::FAILURE
                        return $returnList
                   }
                }
            }
        } elseif {$setIpV6} {
            if {[ipV6 set $chassis $card $port]} {
                keylset returnList log "ERROR in $procName: \
                        Failed to ipV6 set $chassis $card $port."
                keylset returnList status $::FAILURE
                return $returnList
            }
#            ipV6 set $chassis $card $port
        } elseif {$setIpV4} {
            if {[ip set $chassis $card $port]} {
                keylset returnList log "ERROR in $procName: \
                        Failed to ip set $chassis $card $port."
                keylset returnList status $::FAILURE
                return $returnList
            }
#            ip set $chassis $card $port
        } elseif {$setArp} {
            if {[arp set $chassis $card $port]} {
                keylset returnList log "ERROR in $procName: \
                        Failed to arp set $chassis $card $port."
                keylset returnList status $::FAILURE
                return $returnList
            }
#            arp set $chassis $card $port
        }

        set ipV6Args [list ipv6_src_mode ipv6_src_count    \
                ipv6_src_step ipv6_dst_mode ipv6_dst_count ]
        set setIpV6 0
        foreach {ipv6_arg} $ipV6Args {
            if {[info exists $ipv6_arg]} {
                set setIpV6 1
                break
            }
        }
        if {$setIpV6} {
            if {[ipV6 get $chassis $card $port]} {
                keylset returnList log "ERROR in $procName: \
                        Failed to ipV6 get $chassis $card $port \
                        (mode settings)."
                keylset returnList status $::FAILURE
                return $returnList
            }
            foreach single_option_list $ipv6_mode_list {
                if {[info exists $single_option_list]} {
                    eval set single_option $$single_option_list
                    switch -- $single_option_list {
                        ipv6_src_mode {
                            if {![info exists ipv6_src_addr]} {
                                continue
                            }
                            set ipv6_src_addr_type [getIpV6Type $ipv6_src_addr]
                            set tclhal_src_mode_result [getIpV6TclHalMode $single_option $ipv6_src_addr_type]
                            if {[keylget tclhal_src_mode_result status] != $::SUCCESS} {
                                keylset returnList log "ERROR in $procName: [keylget tclhal_src_mode_result log]"
                                keylset returnList status $::FAILURE
                                return $returnList
                            }
                            set tclhal_src_mode [keylget tclhal_src_mode_result ipv6_mode]
                            set ipv6_supp_status [getIpV6AddressTypeSupported $tclhal_src_mode]
                            if {[keylget ipv6_supp_status status] == $::FAILURE} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: [keylget ipv6_supp_status log]"
                                return $returnList
                            }
                            if {[lsearch [keylget ipv6_supp_status address_types] $ipv6_src_addr_type] == -1} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: mode $ipv6_src_mode do not\
                                        support ipv6_src_addr $ipv6_src_addr."
                                return $returnList
                            }
                            debug "ipV6 config -sourceAddrMode $tclhal_src_mode"
                            ipV6 config -sourceAddrMode $tclhal_src_mode
                            if {![info exists ipv6_src_mask]} {
                                
                                if {[info exists ipv6_src_step] && ($tclhal_src_mode \
                                        == $::ipV6DecrNetwork || $tclhal_src_mode == $::ipV6IncrNetwork)} {
                                    # We must auto detect the mask.
                                    set stepMaskList [::ixia::getStepAndMaskFromIPv6 \
                                            $ipv6_src_step]
                    
                                    set ipv6_src_mask [keylget stepMaskList mask]
                    
                                } else {
                                    set mask_result [getIpV6MaskRangeFromIncrMode $tclhal_src_mode]
                                    if {[keylget mask_result status] == $::FAILURE} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: [keylget mask_result log]"
                                        return $returnList
                                    }
                                    if {[scan [keylget mask_result address_range] "%u-%u" min max] != 2} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in\
                                                $procName: cannot get supported\
                                                interval for current\
                                                ipv6_src_mode ($ipv6_src_mode)."
                                    }
                                    debug "ipV6 config -sourceMask $min"
                                    ipV6 config -sourceMask $min
                                }
                            }
                        }
                        ipv6_src_count {
                            if {[info exists ipv6_src_mode] && $ipv6_src_mode != "fixed"} {
                                # default ipv6_src_mode is fixed
                                # There's no point in setting ipv6_src_count value if mode is fixed
                                ipV6 config -sourceAddrRepeatCount $single_option
                            }
                        }
                        ipv6_src_mask {
                            ipV6 config -sourceMask $single_option
                        }
                        ipv6_src_step {
                            if {![info exists ipv6_src_mode] || $ipv6_src_mode == "fixed"} {
                                # default ipv6_src_mode is fixed
                                # There's no point in calculating step value
                                continue 
                            }
                            if {[info exists ipv6_src_mask]} {
                                set step_status [getStepValueFromIpV6 $ipv6_src_step $ipv6_src_mask $tclhal_src_mode]
                                if {[keylget step_status status] != $::SUCCESS} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: [keylget step_status log]"
                                    return $returnList
                                }
                                set step [keylget step_status step]
                            } else {
                                set mask_range_result [ixia::getIpV6MaskRangeFromIncrMode $tclhal_src_mode]
                                if {[keylget mask_range_result status] == $::FAILURE} {
                                    debug "mask_range_result=$mask_range_result"
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: [keylget mask_range_result log]"
                                    return $returnList
                                }
                                debug "mask_range_result=$mask_range_result"
                                set mask_range [keylget mask_range_result address_range]

                                if {[scan $mask_range "%u-%u" min max] != 2} {
                                    debug "mask_range_result=$mask_range_result"
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            Invalid mask range for -ipv6_src_mode $ipv6_src_mode."
                                    return $returnList
                                }
                                debug "ipv6_dst_step: getStepValueFromIpV6 $ipv6_src_step $min $tclhal_src_mode"
                                set step_status [getStepValueFromIpV6 $ipv6_src_step $min $tclhal_src_mode]
                                if {[keylget step_status status] != $::SUCCESS} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: [keylget step_status log]"
                                    return $returnList
                                }
                                if {$ipv6_src_mode == "fixed" || $ipv6_src_mode == "emulation"} {
                                    set step 1
                                } else {
                                    set step [keylget step_status step]
                                }
                            }
                            if {[mpexpr $step < 1] || [mpexpr $step > 4294967295]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName:\
                                        cannot use an amount greater than\
                                        4,294,967,295 or smaller than 1 for\
                                        ipv6_src_step. The configured step is\
                                        ${ipv6_src_step}, but this step is relative\
                                        to the mask provided or to the default mask for the\
                                        specified ipv6_src_addr, so the actual step is $step."
                                return $returnList
                            }
                            ipV6 config -sourceStepSize $step
                        }
                        ipv6_dst_mode {
                            if {![info exists ipv6_dst_addr]} {
                                continue
                            }
                            set ipv6_dst_addr_type [getIpV6Type $ipv6_dst_addr]
                            set tclhal_dst_mode_result [getIpV6TclHalMode $single_option $ipv6_dst_addr_type]
                            if {[keylget tclhal_dst_mode_result status] != $::SUCCESS} {
                                keylset returnList log "ERROR in $procName: [keylget tclhal_dst_mode_result log]"
                                keylset returnList status $::FAILURE
                                return $returnList
                            }
                            set tclhal_dst_mode [keylget tclhal_dst_mode_result ipv6_mode]
                            set ipv6_supp_status [getIpV6AddressTypeSupported $tclhal_dst_mode]
                            if {[keylget ipv6_supp_status status] == $::FAILURE} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: [keylget ipv6_supp_status log]"
                                return $returnList
                            }
                            if {[lsearch [keylget ipv6_supp_status address_types] $ipv6_dst_addr_type] == -1} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: mode $ipv6_dst_mode do not\
                                        support ipv6_dst_addr $ipv6_dst_addr."
                                return $returnList
                            }
                            debug "ipV6 config -destAddrMode $tclhal_dst_mode"
                            ipV6 config -destAddrMode $tclhal_dst_mode
                            if {![info exists ipv6_dst_mask]} {
                                
                                if {[info exists ipv6_dst_step] && ($tclhal_dst_mode \
                                        == $::ipV6DecrNetwork || $tclhal_dst_mode == $::ipV6IncrNetwork)} {
                                    # We must auto detect the mask.
                                    set stepMaskList [::ixia::getStepAndMaskFromIPv6 \
                                            $ipv6_dst_step]
                    
                                    set ipv6_dst_mask [keylget stepMaskList mask]
                    
                                } else {
                                    
                                    set mask_result [getIpV6MaskRangeFromIncrMode $tclhal_dst_mode]
                                    
                                    if {[keylget mask_result status] == $::FAILURE} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: [keylget mask_result log]"
                                        return $returnList
                                    }
                                    
                                    if {[scan [keylget mask_result address_range] "%u-%u" min max] != 2} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in\
                                                $procName: cannot get supported\
                                                interval for current\
                                                ipv6_dst_mode ($ipv6_dst_mode)."
                                    }
                                    
                                    debug "ipV6 config -destMask $min"
                                    ipV6 config -destMask $min
                                }
                            }
                        }
                        ipv6_dst_mask {
                            ipV6 config -destMask $single_option
                        }
                        ipv6_dst_count {
                            if {[info exists ipv6_dst_mode] && $ipv6_dst_mode != "fixed"} {
                                # default ipv6_dst_mode is fixed
                                # There's no point in setting ipv6_dst_count value if mode is fixed
                                ipV6 config -destAddrRepeatCount $single_option
                            }
                        }
                        ipv6_dst_step {
                            if {![info exists ipv6_dst_mode] || $ipv6_dst_mode == "fixed"} {
                                # default ipv6_dst_mode is fixed
                                # There's no point in calculating step value
                                continue 
                            }
                            if {[info exists ipv6_dst_mask]} {
                                set step_status [getStepValueFromIpV6 $ipv6_dst_step $ipv6_dst_mask $tclhal_dst_mode]
                                if {[keylget step_status status] != $::SUCCESS} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: [keylget step_status log]"
                                    return $returnList
                                }
                                set step [keylget step_status step]
                            } else {
                                set mask_range_result [ixia::getIpV6MaskRangeFromIncrMode $tclhal_dst_mode]
                                if {[keylget mask_range_result status] == $::FAILURE} {
                                    debug "mask_range_result=$mask_range_result"
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: [keylget mask_range_result log]"
                                    return $returnList
                                }
                                set mask_range [keylget mask_range_result address_range]

                                if {[scan $mask_range "%u-%u" min max] != 2} {
                                    debug "mask_range_result=$mask_range_result"
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            ixia::getIpV6MaskRangeFromIncrMode returned wrong."
                                    return $returnList
                                }
                                debug "ipv6_dst_step: getStepValueFromIpV6 $ipv6_dst_step $min $tclhal_dst_mode"
                                set step_status [getStepValueFromIpV6 $ipv6_dst_step $min $tclhal_dst_mode]
                                if {[keylget step_status status] != $::SUCCESS} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: [keylget step_status log]"
                                    return $returnList
                                }
                                if {$ipv6_dst_mode == "fixed" || $ipv6_dst_mode == "emulation"} {
                                    set step 1
                                } else {
                                    set step [keylget step_status step]
                                }
                            }
                            if {[mpexpr $step < 1] || [mpexpr $step > 4294967295]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName:\
                                        cannot use an amount greater than\
                                        4,294,967,295 or smaller than 1 for\
                                        ipv6_dst_step. The configured step is\
                                        ${ipv6_dst_step}, but this step is relative\
                                        to the mask provided or to the default mask for the\
                                        specified ipv6_dst_addr, so the actual step is $step."
                                return $returnList
                            }
                            ipV6 config -destStepSize $step
                        }
                        default {}
                    }
                }
            }
            if {[ipV6 set $chassis $card $port]} {
                keylset returnList log "ERROR in $procName: \
                        Failed to ipV6 set $chassis $card $port \
                        (mode settings). $::ixErrorInfo"
                keylset returnList status $::FAILURE
                return $returnList
            }
        }

        ##########################################
        # SET ALL PROPERTIES ACCORDINLY TO FLAGS #
        ##########################################
        if {$atm_flag == 1} {
            ### VPI:
            atmHeaderCounter setDefault

            if {[info exists atm_counter_vpi_data_item_list]} {
                set ll {}
                foreach el $atm_counter_vpi_data_item_list {
                    set l1 [string range $el 0 1]
                    set l2 [string range $el 2 3]
                    lappend ll "$l1 $l2"
                }

                atmHeaderCounter config -dataItemList $ll
            }

            if {[info exists atm_counter_vpi_mask_select]} {
                atmHeaderCounter config -maskselect \
                    $atm_counter_vpi_mask_select
            }

            if {[info exists atm_counter_vpi_mask_value]} {
                atmHeaderCounter config -maskval \
                    $atm_counter_vpi_mask_value
            }

            if {[info exists atm_counter_vpi_mode]} {
                switch $atm_counter_vpi_mode {
                    incr {
                        atmHeaderCounter config -mode 0
                    }
                    cont_incr {
                        atmHeaderCounter config -mode 1
                    }
                    decr {
                        atmHeaderCounter config -mode 2
                    }
                    cont_decr {
                        atmHeaderCounter config -mode 3
                    }
                }
            }

            if {[info exists vpi_count]} {
                atmHeaderCounter config -repeatCount $vpi_count
            }

            if {[info exists vpi_step]} {
                atmHeaderCounter config -step        $vpi_step
            }

            if {[info exists atm_counter_vpi_type]} {
                switch $atm_counter_vpi_type {
                    fixed {
                        atmHeaderCounter config -type 0
                    }
                    counter {
                        atmHeaderCounter config -type 1
                    }
                    random {
                        atmHeaderCounter config -type 2
                    }
                    table {
                        atmHeaderCounter config -type 3
                    }
                }
            }

            if {[atmHeaderCounter set atmVpi]} {
                keylset return_val status $::FAILURE
                keylset return_val log "ERROR in $procName when: \
                        atmHeaderCounter set atmVpi. $::ixErrorInfo"
                return $return_val
            }
            ### VCI:
            atmHeaderCounter setDefault

            if {[info exists atm_counter_vci_data_item_list]} {
                set ll {}
                foreach el $atm_counter_vci_data_item_list {
                    set l1 [string range $el 0 1]
                    set l2 [string range $el 2 3]
                    lappend ll "$l1 $l2"
                }

                atmHeaderCounter config -dataItemList $ll
            }

            if {[info exists atm_counter_vci_mask_select]} {
                atmHeaderCounter config -maskselect \
                    [list $atm_counter_vci_mask_select]
            }

            if {[info exists atm_counter_vci_mask_value]} {
                atmHeaderCounter config -maskval \
                    $atm_counter_vci_mask_value
            }

            if {[info exists atm_counter_vci_mode]} {
                switch $atm_counter_vci_mode {
                    incr {
                        atmHeaderCounter config -mode 0
                    }
                    cont_incr {
                        atmHeaderCounter config -mode 1
                    }
                    decr {
                        atmHeaderCounter config -mode 2
                    }
                    cont_decr {
                        atmHeaderCounter config -mode 3
                    }
                }
            }

            if {[info exists vci_count]} {
                atmHeaderCounter config -repeatCount $vci_count
            }

            if {[info exists vci_step]} {
                atmHeaderCounter config -step        $vci_step
            }

            if {[info exists atm_counter_vci_type]} {
                switch $atm_counter_vci_type {
                    fixed {
                        atmHeaderCounter config -type 0
                    }
                    counter {
                        atmHeaderCounter config -type 1
                    }
                    random {
                        atmHeaderCounter config -type 2
                    }
                    table {
                        atmHeaderCounter config -type 3
                    }
                }
            }

            if {[atmHeaderCounter set atmVci]} {
                keylset return_val status $::FAILURE
                keylset return_val log "ERROR in $procName when: \
                        atmHeaderCounter set atmVci. $::ixErrorInfo"
                return $return_val
            }

            if {[atmHeader set $chassis $card $port]} {
                keylset return_val status $::FAILURE
                keylset return_val log "ERROR in $procName when: \
                        atmHeader set $chassis $card $port. $::ixErrorInfo"
                return $return_val
            }

        }
        if {$dhcp_flag == 1} {
            if {[dhcp set $chassis $card $port]} {
                keylset return_val status $::FAILURE
                keylset return_val log "ERROR in $procName when: \
                        dhcp set $chassis $card $port. $::ixErrorInfo"
                return $return_val
            }
        }
        if {$igmp_flag == 1} {
            if {[igmp set $chassis $card $port]} {
                keylset return_val status $::FAILURE
                keylset return_val log "ERROR in $procName when: \
                        igmp set $chassis $card $port. $::ixErrorInfo"
                return $return_val
            }
        }
        if {$rip_flag == 1}  {
            if {[rip set $chassis $card $port]} {
                keylset return_val status $::FAILURE
                keylset return_val log "ERROR in $procName when: \
                        rip set $chassis $card $port. $::ixErrorInfo"
                return $return_val
            }
        }
        if {$ipx_flag == 1}  {
            if {[ipx set $chassis $card $port]} {
                keylset return_val status $::FAILURE
                keylset return_val log "ERROR in $procName when: \
                        ipx set $chassis $card $port. $::ixErrorInfo"
                return $return_val
            }
        }
        if {$arp_flag == 1}  {
            if {[arp set $chassis $card $port]} {
                keylset return_val status $::FAILURE
                keylset return_val log "ERROR in $procName when: \
                        arp set $chassis $card $port. $::ixErrorInfo"
                return $return_val
            }
        }
        if {$isl_flag == 1} {
            if {[isl set $chassis $card $port]} {
                keylset return_val status $::FAILURE
                keylset return_val log "ERROR in $procName when: \
                        isl set $chassis $card $port. $::ixErrorInfo"
                return $return_val
            }
        }
        if {[info exists vlan_id] && ([llength $vlan_id] == 1) && \
                    (([info exists vlan] && ($vlan == "enable")) || \
                    (![info exists vlan]))} {
            vlan set $chassis $card $port
        }
        if {[info exists vlan_id] && ([llength $vlan_id] > 1) && \
                    (([info exists vlan] && ($vlan == "enable")) || \
                    (![info exists vlan]))} {
            stackedVlan set $chassis $card $port
        }
        if {$pause_control_flag == 1} {
            pauseControl set $chassis $card $port
        }

        # IPv6 Extension Headers
        # Extension Headers should be added here, before layer 4 protocols
        if {[info exists ipv6_extension_header]} {
            if {$ipv6_extension_header == "fragment"} {
                if {![info exists ipv6_frag_offset]} {
                    set ipv6_frag_offset 100
                }
                if {![info exists ipv6_frag_more_flag]} {
                    set ipv6_frag_more_flag 0
                }
            }
            set ipv6_extension_args ""
            foreach {ipv6_extension_param} $ipv6_extension_header_list {
                if {[info exists $ipv6_extension_param]} {
                    append ipv6_extension_args " -$ipv6_extension_param \
                            [list [set $ipv6_extension_param]]"
                }
            }

            if {$mode == "create"} {
                set retCode [ipV6 clearAllExtensionHeaders]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to\
                            ipV6 clearAllExtensionHeaders. \
                            Return code was: $retCode.\n$::ixErrorInfo"
                    return $returnList
                }
            }

            set retCode [eval ::ixia::addIpV6ExtensionHeaders \
                    $ipv6_extension_args]

            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ipv6_flag 1
        } else  {
            # These parameter where kept to preserve backward compatibility
            if {[info exists ipv6_frag_offset] || [info exists ipv6_frag_id] \
                    || [info exists ipv6_frag_more_flag]} {
                ipV6Fragment setDefault
                debug "ipV6Fragment setDefault"
                if {[info exists ipv6_frag_offset]} {
                    ipV6Fragment config -fragmentOffset $ipv6_frag_offset
                    debug "ipV6Fragment config -fragmentOffset $ipv6_frag_offset"
                } else {
                    ipV6Fragment config -fragmentOffset 100
                    debug "ipV6Fragment config -fragmentOffset 100"
                }
                if {[info exists ipv6_frag_id]} {
                    ipV6Fragment config -identification $ipv6_frag_id
                    debug "ipV6Fragment config -identification $ipv6_frag_id"
                }
                if {[info exists ipv6_frag_more_flag] && \
                        ($ipv6_frag_more_flag || \
                        ($ipv6_frag_more_flag == "") || \
                        ($ipv6_frag_more_flag == "1"))} {
                    ipV6Fragment config -enableFlag $::true
                    debug "ipV6Fragment config -enableFlag \$::true"
                } else {
                    ipV6Fragment config -enableFlag $::false
                    debug "ipV6Fragment config -enableFlag \$::false"
                }
                set retCode [ipV6 addExtensionHeader ipV6Fragment]
                debug "ipV6 addExtensionHeader ipV6Fragment"
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            Failed to ipV6 addExtensionHeader ipV6Fragment"
                    return $returnList
                }
                set ipv6_flag 1
            }
        }

        # ICMP on IPv6 or IPv4
        if {$icmp_flag == 1} {
            if {$ip_version == 4} {
                icmp set $chassis $card $port
            }
            if {$ip_version == 6} {
                if {[catch {set retCode [icmpV6 set $chassis $card $port]}]} {
                    icmp set $chassis $card $port
                } elseif {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            Failed to icmpV6 set $chassis $card $port, return code was $retCode. $::ixErrorInfo"
                    return $returnList
                }
                ipV6 config -nextHeader 58
            }
        }

        # TCP on IPv6 or IPv4
        if {$tcp_flag == 1}  {
            if {$ip_version == 4} {
                tcp set $chassis $card $port
            } elseif {$ip_version == 6} {
                ipV6 config -nextHeader tcp
                ipV6 addExtensionHeader tcp
                tcp set $chassis $card $port
            }
        }
        
        # UDP on IPv6
        if {$udp_flag == 1} {
            if {$ip_version == 6} {
                ipV6 config -nextHeader udp
                ipV6 addExtensionHeader udp
                udp set $chassis $card $port
            } elseif {$ip_version == 4} {
                udp set $chassis $card $port
            }
        }

        # GRE on IPv6
        if {$gre_flag == 1} {
            if {$ip_version == 6} {
                ipV6 config -nextHeader 47
                ipV6 addExtensionHeader 47
            }
        }

        # Ipv4 or IPv6
        if {$ipv4_flag} {
            if {[ip set $chassis $card $port]} {
                keylset returnList log "ERROR in $procName: \
                        Failed to ip set $chassis $card $port."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
        if {$ipv6_flag} {
            if {[ipV6 set $chassis $card $port]} {
                keylset returnList log "ERROR in $procName: \
                        Failed to ipV6 set $chassis $card $port."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }

        # MPLS
        if {$mpls_flag == 1} {
            if {[mpls set $chassis $card $port]} {
                keylset returnList log "ERROR in $procName: \
                        Failed to mpls set $chassis $card $port."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }

        if {[info exists ixaccess_emulated_stream_status] && \
                $protocolOffsetEnable == 1} {
            set __frame_size [stream cget -framesize]
            set retCode [::ixia::setPPPoXPayloadFramesize \
                        $ixaccess_emulated_stream_status $__frame_size $chassis $card $port]

            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
        
        if {$frPresent == true} {
            frameRelay setDefault
            foreach {hlt_param ixos_param type_param} $fr_option_list {
                if {[info exists $hlt_param]} {
                    switch $type_param {
                        value {
                            frameRelay config -$ixos_param [set $hlt_param]
                        }
                        flag {
                            if {[set $hlt_param] == 0} {
                                frameRelay config -$ixos_param false
                            } else {
                                frameRelay config -$ixos_param true
                            }
                        }
                        dlciCounterArray {
                            frameRelay config -counterMode $dlciCounterArray([set $hlt_param])
                        }
                    }
                }
            }
            if {[frameRelay set $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: cannot set Frame Relay\
                         options on stream."
                return $returnList
            }
        }
        
        set streamConfigCmdParams ""
        foreach localParam $streamConfigParams {
            if {[info exists $localParam]} {
                lappend streamConfigCmdParams [set $localParam]
            } else {
                lappend streamConfigCmdParams _noVal_
            }
        }

        set streamConfigStatus [eval "::ixia::setStreamConfig $streamConfigCmdParams"]
        if {[keylget streamConfigStatus status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget streamConfigStatus log]"
            return $returnList
        }
        
        # Auto detect instrumentation (this set needs to come before packetGroup and dataIntegrity)
        if {$auto_detect_flag == 1} {
            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                set retCode [autoDetectInstrumentation setQueueTx $chassis $card $port \
                        $queue_id $stream_id]
            } else {
                set retCode [autoDetectInstrumentation setTx $chassis $card $port \
                        $stream_id]
            }

            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: autoDetectInstrumentation\
                        setTx on $chassis $card $port $stream_id.\
                        \n$::ixErrorInfo"
                return $returnList
            }
        } else {
            if {[port isValidFeature $chassis $card $port portFeatureAutoDetectTx]} {
                autoDetectInstrumentation setDefault

                if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                    set retCode [autoDetectInstrumentation setQueueTx $chassis $card $port \
                            $queue_id $stream_id]
                } else {
                    set retCode [autoDetectInstrumentation setTx $chassis $card $port \
                            $stream_id]
                }

                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: autoDetectInstrumentation\
                            setTx on $chassis $card $port $stream_id.\
                            \n$::ixErrorInfo"
                    return $returnList
                }
            }
        }
        
        # If the length_mode is auto, we needed to find out the frame size
        # if using rate_pps or rate_bps
        if {[info exists length_mode] && ($length_mode == "auto")} {
            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                stream getQueue $chassis $card $port $queue_id $stream_id
            } else  {
                stream get $chassis $card $port $stream_id
            }
            set framesize [stream cget -framesize]
            if {[info exists rate_pps]} {
                stream config -rateMode usePercentRate
                stream config -percentPacketRate \
                        [calculatePercentMaxRate $chassis $card $port \
                        $rate_pps $framesize 8]
            } elseif {[info exists rate_bps]} {
                set ratepps [mpexpr $rate_bps / ($framesize * 8.)]
                stream config -rateMode usePercentRate
                stream config -percentPacketRate \
                        [calculatePercentMaxRate $chassis $card $port \
                        $ratepps $framesize 8]
            }

            set streamConfigCmdParams ""
            foreach localParam $streamConfigParams {
                if {[info exists $localParam]} {
                    lappend streamConfigCmdParams [set $localParam]
                } else {
                    lappend streamConfigCmdParams _noVal_
                }
            }

            set streamConfigStatus [eval "::ixia::setStreamConfig $streamConfigCmdParams"]
            if {[keylget streamConfigStatus status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget streamConfigStatus log]"
                return $returnList
            }
        }

        if {[info exists ip_src_step] && $ip_src_use_udf} {
            
            # assuming stream get was already performed
            set offset [get_packet_ip_offset $ip_src_addr]
            
            udf get 1

            udf config -enable 1
            udf config -offset $offset

            # Initial value will be the ip address
            if {[info exists ip_src_addr]} {
                set space_ip [split $ip_src_addr .]
                foreach {one two three four} $space_ip {}
                set init_ip [format "%02x %02x %02x %02x" $one $two $three $four]
                udf config -initval $init_ip
            } else {
                udf config -initval {00 00 00 00}
            }

            if {[udf cget -skipMaskBits] < 2} {
                udf config -skipMaskBits 8
            }

            if {[catch {udf set 1} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to set the\
                        udf 1 for usage of the ip_src_step option."
                return $returnList
            }
        }
        if {[info exists ip_dst_step] && $ip_dst_use_udf} {
            
            # assuming stream get was already performed
            set offset [get_packet_ip_offset $ip_dst_addr]

            udf get 2

            udf config -enable 1
            udf config -offset $offset

            # Initial value will be the ip address
            if {[info exists ip_dst_addr]} {
                set space_ip [split $ip_dst_addr .]
                foreach {one two three four} $space_ip {}
                set init_ip [format "%02x %02x %02x %02x" $one $two $three $four]
                udf config -initval $init_ip
            } else {
                udf config -initval {00 00 00 00}
            }

            if {[udf cget -skipMaskBits] < 2} {
                udf config -skipMaskBits 8
            }

            if {[catch {udf set 2} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to set the\
                        udf 2 for usage of the ip_dst_step option."
                return $returnList
            }
        }

        # Need to set the stream if the udfs were used for stepping
        if {[info exists ip_src_step] || [info exists ip_dst_step]} {
            set customSet "set_then_get"
            set streamConfigCmdParams ""
            foreach localParam $streamConfigParams {
                if {[info exists $localParam]} {
                    lappend streamConfigCmdParams [set $localParam]
                } else {
                    lappend streamConfigCmdParams _noVal_
                }
            }
            catch {unset customSet}
            
            set streamConfigStatus [eval "::ixia::setStreamConfig $streamConfigCmdParams"]
            if {[keylget streamConfigStatus status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget streamConfigStatus log]"
                return $returnList
            }
            
        }
        
        # Not sure if this is necessary anymore
        # Packet Group (Latency, Sequencing)
        if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
            set retCode [packetGroup setQueueTx $chassis $card $port \
                    $queue_id $stream_id]
        } else  {
            set retCode [packetGroup setTx $chassis $card $port $stream_id]
            debug "@@@@@ packetGroup setTx $chassis $card $port $stream_id"
        }

        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: packetGroup\
                    setTx on $chassis $card $port $stream_id.\
                    \n$::ixErrorInfo"
            return $returnList
        }
        # Data integrity
        if {$integrity_flag == 1} {
            set customSet "set_then_get"
            set streamConfigCmdParams ""
            foreach localParam $streamConfigParams {
                if {[info exists $localParam]} {
                    lappend streamConfigCmdParams [set $localParam]
                } else {
                    lappend streamConfigCmdParams _noVal_
                }
            }
            catch {unset customSet}
            
            set streamConfigStatus [eval "::ixia::setStreamConfig $streamConfigCmdParams"]
            if {[keylget streamConfigStatus status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget streamConfigStatus log]"
                return $returnList
            }
#             stream get $chassis $card $port $stream_id
            # This should be done after establishing stream frame size
            if {[info exists enable_auto_detect_instrumentation] && \
                    ([lindex $enable_auto_detect_instrumentation 0] == 0)} {
                set diOffset [stream cget -framesize]
                if {[info exists framesize_min]} {
                     set diOffset [stream cget -frameSizeMIN]
                }
                incr diOffset -10
                if {[info exists enable_time_stamp] && [lindex $enable_time_stamp 0]} {
                    incr diOffset -6
                }
                dataIntegrity config -signatureOffset $diOffset
            }
            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                set retCode [dataIntegrity setQueueTx $chassis $card $port \
                        $queue_id $stream_id]
            } else  {
                set retCode [dataIntegrity setTx $chassis $card $port \
                        $stream_id]
            }

            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: dataIntegrity\
                        setTx on $chassis $card $port $stream_id.\
                        \n$::ixErrorInfo"
                return $returnList
            }
        }
        
        # Packet Group (Latency, Sequencing)
        if {$pgid_flag == 1} {
            set txPgidSignature [packetGroup cget -signature]
            set txPgidSigOffset [packetGroup cget -signatureOffset]
            set txPgidOffset    [packetGroup cget -groupIdOffset]
            
            if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                set retCode [packetGroup setQueueTx $chassis $card $port \
                        $queue_id $stream_id]
            } else  {
                set retCode [packetGroup setTx $chassis $card $port $stream_id]
                debug "packetGroup setTx $chassis $card $port $stream_id"
            }
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to set the\
                        packet group configuration on port: $chassis $card $port\
                        for stream: $stream_id"
                return $returnList
            }
            
            if {[info exists useTclHalForIxAccessStreams] && $useTclHalForIxAccessStreams} {
                debug "Port_handle: $port_handle --- $chassis/$card/$port"
                if {$bidirectional == 1} {
                    set portIndex [lsearch $port_handle $chassis/$card/$port]
                    set theOtherPort [lindex $port_handle [expr [llength $port_handle] - $portIndex - 1] ]
                } elseif {[info exists port_handle2]} {
                    set theOtherPort $port_handle2
                } else {
                    set theOtherPort ""
                }
                if {($theOtherPort != "") && (![info exists tgen_offset_value($theOtherPort)] || \
                        [expr $tgen_offset_value($theOtherPort) ^ 0x7])} {
                    
                    debug "theOtherPort: $theOtherPort"
                    foreach {chT cdT ptT} [split $theOtherPort "/"] {}
                    
                    if {[packetGroup getRx $chT $cdT $ptT]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to get the\
                                packet group RX configuration on port: $chT $cdT $ptT."
                        return $returnList
                    }
                    debug "packetGroup getRx $chT $cdT $ptT"
                    
                    if {![info exists tgen_offset_value($theOtherPort)] || \
                            [expr $tgen_offset_value($theOtherPort) & 0x4] == 0} {
                        packetGroup config -signature       $txPgidSignature
                        debug "packetGroup config -signature       $txPgidSignature"
                    }
    
                    set tmpOffset [mpexpr $txPgidSigOffset + \
                            $::ixia::encapSize::offsetCorrection ]

                    if {![info exists tgen_offset_value($theOtherPort)] || \
                            [expr $tgen_offset_value($theOtherPort) & 0x2] == 0} {
                        packetGroup config -signatureOffset $tmpOffset
                        debug "packetGroup config -signatureOffset $tmpOffset"
                    }
                    
                    if {![info exists tgen_offset_value($theOtherPort)] || \
                            [expr $tgen_offset_value($theOtherPort) & 0x1] == 0} {
                        packetGroup config -groupIdOffset   [expr $tmpOffset + 4]
                        debug "packetGroup config -groupIdOffset  [expr $tmpOffset + 4]"
                    }
                    
                    ::ixia::addPortToWrite $theOtherPort
    
                    debug "packetGroup setRx $chT $cdT $ptT"
                    if {[packetGroup setRx $chT $cdT $ptT]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to set the\
                                packet group RX configuration on port: $chT $cdT $ptT."
                        return $returnList
                    }
                                       
                    ixAccessPort get $chT $cdT $ptT
                    debug "ixAccessPort get $chT $cdT $ptT"
                    ixAccessPort config -filterUpdateRequired 1
                    debug "ixAccessPort config -filterUpdateRequired 1"
                    ixAccessPort set $chT $cdT $ptT
                    debug "ixAccessPort set $chT $cdT $ptT"
                }
            }
        }
        
        # This needs to be done after auto detect instrumentation and 
        # packet group setting, starting with IxOS 5.10
        if {[info exists enable_time_stamp]} {
            stream config -enableTimestamp $enable_time_stamp
        }
        
        ###################################################################
        # Stream Behavior (-dma)                                          #
        #                                                                 #
        # *Note: If the port is in advance stream mode, the stream will   #
        #        not advance but be all "continuous" or "stop"            #
        ###################################################################
        port get $chassis $card $port
        set ix_transmit_mode [port cget -transmitMode]
        if {$mode == "create"} {
            if {$ix_transmit_mode == $::portTxPacketStreams} {
                if {![info exists transmit_mode]} {
                    stream config -dma gotoFirst
                }
    
                set streamConfigCmdParams ""
                foreach localParam $streamConfigParams {
                    if {[info exists $localParam]} {
                        lappend streamConfigCmdParams [set $localParam]
                    } else {
                        lappend streamConfigCmdParams _noVal_
                    }
                }
    
                set streamConfigStatus [eval "::ixia::setStreamConfig $streamConfigCmdParams"]
                if {[keylget streamConfigStatus status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget streamConfigStatus log]"
                    return $returnList
                }
                
                
    
                # Get/Set the previous streams to Advance
                for {set curr_stream_id 1} {$curr_stream_id < $stream_id} \
                        {incr curr_stream_id} {
                    if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
                        set retCode [stream getQueue $chassis $card $port $queue_id \
                                $curr_stream_id]
                    } else  {
                        set retCode [stream get $chassis $card $port \
                                $curr_stream_id]
                    }
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Could not get\
                                the stream: $curr_stream_id on port: $tx_port."
                        return $returnList
                    }
                    stream config -dma advance
    
                    set customSet "set_only"
                    set streamConfigCmdParams ""
    
                    foreach localParam $streamConfigParams {
                        if {[info exists $localParam]} {
                            if {$localParam == "stream_id"} {
                                lappend streamConfigCmdParams $curr_stream_id
                            } else {
                                lappend streamConfigCmdParams [set $localParam]
                            }
                        } else {
                            lappend streamConfigCmdParams _noVal_
                        }
                    }
                    catch {unset customSet}
                    
                    set streamConfigStatus [eval "::ixia::setStreamConfig $streamConfigCmdParams"]
                    if {[keylget streamConfigStatus status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget streamConfigStatus log]"
                        return $returnList
                    }
                }
            } else {
                if {([info exists transmit_mode]) && \
                            ($transmit_mode != "single_burst")      && \
                            ($transmit_mode != "single_pkt")        && \
                            ($transmit_mode != "continuous_burst")  } {
                    stream config -dma contPacket
    
                    set streamConfigCmdParams ""
                    foreach localParam $streamConfigParams {
                        if {[info exists $localParam] && $localParam != "rate_frame_gap"} {
                            lappend streamConfigCmdParams [set $localParam]
                        } else {
                            lappend streamConfigCmdParams _noVal_
                        }
                    }
    
                    lappend streamConfigCmdParams $mode
    
                    set streamConfigStatus [eval "::ixia::setStreamConfig $streamConfigCmdParams"]
                    if {[keylget streamConfigStatus status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget streamConfigStatus log]"
                        return $returnList
                    }
                }
            }
        }
        # handle the flipping of stuff for bidirectional traffic here...
        if {$bidirectional} {
            if {[info exists ip_dst_addr2]} {
                set ip_dst_addr $ip_dst_addr2
            }
            if {[info exists ipv6_dst_addr2]} {
                set ipv6_dst_addr $ipv6_dst_addr2
            }
            if {[info exists ip_src_addr2]} {
                set ip_src_addr $ip_src_addr2
            }
            if {[info exists ipv6_src_addr2]} {
                set ipv6_src_addr $ipv6_src_addr2
            }
            if {[info exists mac_src2]} {
                set mac_src $mac_src2
            } else {
                # cause then we'll just create a default one at top of loop!
                catch {unset mac_src}
            }
            if {[info exists mac_dst2]} {
                set mac_dst $mac_dst2
            }
            if {[info exists enable_auto_detect_instrumentation] && [llength $enable_auto_detect_instrumentation] > 1} {
                set enable_auto_detect_instrumentation [lindex $enable_auto_detect_instrumentation 1]
            }
            if {[info exists enable_time_stamp] && [llength $enable_time_stamp] > 1} {
                set enable_time_stamp [lindex $enable_time_stamp 1]
            }
            if {[info exists pgid_value] && [llength $pgid_value] > 1} {
                set pgid_value [lindex $pgid_value 1]
            }
            
            if {[info exists pgidValueIsSetByDefault] && $pgidValueIsSetByDefault} {
                # If pgid_value wasn't passed as parameter, we need to unset it
                # so that it would get the value of the next stream id.
                catch {unset pgid_value}
            }
            
            if {[info exists signature] && [llength $signature] > 1} {
                set signature [lindex $signature 1]
            }
            
            if {[info exists signature_offset] && [llength $signature_offset] > 1} {
                set signature_offset [lindex $signature_offset 1]
            }
            
            ###
            # Setting list of parameters to be modified for new stream
            ###
            if {$useTclHalForIxAccessStreams} {
                # Roll back initial values to avoid parameters from upstream
                # being overwritten and applied to downstream
                foreach {rbParam rbValue} $rollBackOWParams {
                    set $rbParam $rbValue
                    if {$rbValue == "_unset_"} {
                        catch {unset $rbParam}
                    }
                }
                
                set arg_switch_list [list \
                    -port_handle          -port_handle2 \
                    -emulation_src_handle -emulation_dst_handle \
                    -ip_src_addr          -ip_dst_addr \
                    -ip_src_mode          -ip_dst_mode \
                    -ip_src_count         -ip_dst_count \
                    -ip_src_step          -ip_dst_step \
                    -ipv6_src_addr        -ipv6_dst_addr \
                    -ipv6_src_mode        -ipv6_dst_mode \
                    -ipv6_src_count       -ipv6_dst_count \
                    -ipv6_src_step        -ipv6_dst_step \
                    -mac_src_step         -mac_dst_step \
                    -mac_src_count        -mac_dst_count \
                    -mac_src_mode         -mac_dst_mode \
                ]
                
                set switch_list [list \
                    ip_src_mode           ip_dst_mode \
                    ip_src_count          ip_dst_count \
                    ip_src_step           ip_dst_step \
                    mac_src_mode          mac_dst_mode \
                    mac_src_count         mac_dst_count \
                    mac_src_step          mac_dst_step \
                ]
                if {[info exists setIpV6] && $setIpV6 == 1} {
                    append switch_list " ipv6_src_mode ip_dst_mode \
                    ipv6_src_count ip_dst_count \
                    ipv6_src_step ip_dst_step"
                }

                set src_mode_pos [lsearch $args -mac_src_mode]
                if {$src_mode_pos == -1} {
                    set mac_src_mode fixed

                } else {
                    incr src_mode_pos
                    set mac_src_mode [lindex $args $src_mode_pos]

                }
                set dst_mode_pos [lsearch $args -mac_dst_mode]
                if {$dst_mode_pos == -1} {
                    set mac_dst_mode discovery
                } else {
                    incr dst_mode_pos
                    set mac_dst_mode [lindex $args $dst_mode_pos]
                }
                    
                if {[info exists mac_src2]} {
                    append arg_switch_list " -mac_src -mac_src2"
                    append switch_list " mac_src mac_src2"
                } else {
                    append arg_switch_list " -mac_src -mac_dst"
                    append switch_list " mac_src mac_dst"
                }
                
                if {[info exists mac_dst2]} {
                    append arg_switch_list " -mac_dst -mac_dst2"
                    append switch_list " mac_dst mac_dst2"
                } else {
                    append arg_switch_list " -mac_src -mac_dst"
                    append switch_list " mac_src mac_dst"
                }

                if {$mac_dst_mode == "discovery"} {
                    set mac_dst_mode fixed
                    if {[lsearch $args -mac_dst_mode] == -1} {
                        append args " -mac_dst_mode"
                        append args " tmp_value"
                    }
                    set pos [lsearch $args -mac_dst_mode]
                    set args [lreplace $args [expr $pos + 1] [expr $pos + 1] fixed]
                }
                
                if {$mac_src_mode == "fixed" || $mac_src_mode == "emulation"} {
                    set mac_src_mode discovery
                    if {[lsearch $args -mac_src_mode] == -1} {
                        append args " -mac_src_mode"
                        append args " tmp_value"
                    }
                    set pos [lsearch $args -mac_src_mode]
                    set args [lreplace $args [expr $pos + 1] [expr $pos + 1] discovery]
                }

                set args [ixia::switch_args $args $arg_switch_list]

                ixia::switch_vars $switch_list
              }            
        }

        lappend stream_id_list $current_streamid
    }

    if {$mode == "create" && [info exists useTclHalForIxAccessStreams] && \
                            $useTclHalForIxAccessStreams == 1} {
                            debug "++++++++++++==========++++++++++++"
        
        if {!$bidirectional} {
            set filter_port_h [list $port_handle]
            if {[info exists port_handle2]} {
                lappend filter_port_h $port_handle2
            }
        } else {
            set filter_port_h $port_handle
        }
        debug "$filter_port_h \n[format_space_port_list $filter_port_h]"
        if {[info exists enable_auto_detect_instrumentation]} {
            debug "updatePatternMismatchFilter \
                    [format_space_port_list $filter_port_h] {} \
                    $enable_auto_detect_instrumentation"
            set retCode [updatePatternMismatchFilter \
                    [format_space_port_list $filter_port_h] "" \
                    $enable_auto_detect_instrumentation]
        } else {
            debug "updatePatternMismatchFilter \
                    [format_space_port_list $filter_port_h]"
            set retCode [updatePatternMismatchFilter \
                    [format_space_port_list $filter_port_h]]
        }

        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget retCode log]"
            return $returnList
        }
    }

    if {($mode == "remove") || ($mode == "enable")} {
        set current_streamid $hold_current_streamid
    }
    if {$sonet_flag} {
        ::ixia::addPortToWrite $port_list ports
    } else  {
        ::ixia::addPortToWrite $port_list
    }


    if {![info exists no_write]} {
        set retCode [::ixia::writePortListConfig "no"]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
    }

    keylset returnList status $::SUCCESS

    if {$edit == 1} {
        keylset returnList stream_id [lindex $stream_id_list 0]
        if {[info exists queue_id]} {
            keylset returnList queue_id $queue_id
        }
        if {[llength $stream_id_list] > 1} {
            keyldel returnList stream_id
            set port_handle1 [lindex $port_handle 0]
            keylset returnList stream_id.$port_handle1 [lindex $stream_id_list 0]
            keylset returnList stream_id.$port_handle2 [lindex $stream_id_list 1]
        }
    }
    if {$mode == "modify"} {
        set current_streamid $hold_current_streamid
    }
    if {[info exists ::ixErrorInfo]} {
        catch {regsub {(.*)WARNINGs issued for stream Id ([0-9]+)(.*)} \
                    $::ixErrorInfo {\2} warning_stream_id}

        if {[info exists warning_stream_id]} {
            if {[lsearch $stream_id_list $warning_stream_id] != -1} {
                ixPuts $::ixErrorInfo
                keylset returnList log $::ixErrorInfo
            }
        }
    }

    return $returnList
}