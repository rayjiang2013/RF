
proc ::ixia::interface_config {args} {
    variable objectMaxCount
    variable executeOnTclServer
    variable ignoreLinkState
    variable ixnetworkVersion
    variable no_more_tclhal

    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::interface_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable new_ixnetwork_api
    variable ixnetwork_tcl_server
    variable ixnetwork_chassis_list
    variable ixnetwork_master_chassis_array
    variable ixnetwork_port_handles_array
    variable tgen_offset_value

    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }

    set port_rx_mode_regexp            "^( *{{0,1} *(capture_and_measure|capture|echo|packet_group|data_integrity|sequence_checking|wide_packet_group|auto_detect_instrumentation) *}{0,1} *)+$"
    set vlan_id_regexp                 "(^\[0-9\]{1,4}\(,\[0-9\]{1,4}\){0,5}$)|()"
    set vlan_id_count_regexp           "^\[0-9\]{1,4}\(,\[0-9\]{1,4}\){0,5}$"
    set vlan_id_step_regexp            "^\[0-9\]{1,4}\(,\[0-9\]{1,4}\){0,5}$"
    set addresses_per_vlan_regexp      "^\[0-9\]{1,4}\(,\[0-9\]{1,4}\){0,5}$"
    set vlan_tpid_regexp               "^0x\[0-9a-fA-F\]+(,0x\[0-9a-fA-F\]+){0,5}$"
    set vlan_user_priority_regexp      "^\[0-7\](,\[0-7\]){0,5}$"
    set vlan_user_priority_step_regexp "^\[0-7\](,\[0-7\]){0,5}$"
    set static_vlan_id_step_regexp     "(^\[0-9\]+(,\[0-9\]+)*$)|(^\[0-9\]+(:\[0-9\]+)*$)"
    set opt_args "
        -addresses_per_svlan            REGEXP $addresses_per_vlan_regexp
                                        DEFAULT 1
        -addresses_per_vci              RANGE 1-65535 
                                        DEFAULT 1
        -addresses_per_vlan             REGEXP $addresses_per_vlan_regexp
                                        DEFAULT 1
        -addresses_per_vpi              RANGE 1-65535 
                                        DEFAULT 1
        -arp                            CHOICES 0 1 
                                        DEFAULT 1
        -arp_on_linkup                  CHOICES 0 1
        -arp_req_retries
        -arp_refresh_interval           NUMERIC 
        -arp_req_timer                  RANGE 1-100
        -arp_send_req                   CHOICES 0 1
        -atm_enable_coset               CHOICES 0 1
        -atm_enable_pattern_matching    CHOICES 0 1
        -atm_encapsulation              CHOICES VccMuxIPV4Routed
                                        CHOICES VccMuxBridgedEthernetFCS
                                        CHOICES VccMuxBridgedEthernetNoFCS
                                        CHOICES VccMuxIPV6Routed
                                        CHOICES VccMuxMPLSRouted
                                        CHOICES LLCRoutedCLIP
                                        CHOICES LLCBridgedEthernetFCS
                                        CHOICES LLCBridgedEthernetNoFCS
                                        CHOICES LLCPPPoA
                                        CHOICES VccMuxPPPoA
                                        CHOICES LLCNLPIDRouted
        -atm_filler_cell                CHOICES idle unassigned
        -atm_interface_type             CHOICES uni nni
        -atm_packet_decode_mode         CHOICES frame cell
        -atm_reassembly_timeout         NUMERIC
        -autonegotiation                CHOICES 0 1
        -auto_detect_instrumentation_type CHOICES end_of_frame floating 
        -bert_configuration             ANY
        -bert_error_insertion           ANY
        -clocksource                    CHOICES internal loop external
        -connected_count                NUMERIC
        -check_gateway_exists           CHOICES 0 1
                                        DEFAULT 0
        -data_integrity                 CHOICES 0 1
        -duplex                         CHOICES half full auto
        -framing                        CHOICES sonet sdh
        -gateway                        IP
        -gateway_incr_mode              CHOICES every_subnet every_interface 
                                        DEFAULT every_subnet
        -gateway_step                   IP
        -gre_checksum_enable            CHOICES 0 1
        -gre_count                      NUMERIC
        -gre_dst_ip_addr                IP
        -gre_dst_ip_addr_step           IP
        -gre_ip_addr                    IPV4
        -gre_ip_addr_step               IPV4
        -gre_ip_prefix_length           RANGE 0-32
        -gre_ipv6_addr                  IPV6
        -gre_ipv6_addr_step             IPV6
        -gre_ipv6_prefix_length         RANGE 0-128
        -gre_key_enable                 CHOICES 0 1
        -gre_key_in                     RANGE 0-4294967295
        -gre_key_out                    RANGE 0-4294967295
        -gre_seq_enable                 CHOICES 0 1
        -check_opposite_ip_version      CHOICES 0 1
                                        DEFAULT 1
        -ignore_link                    CHOICES 0 1
        -integrity_signature
        -integrity_signature_offset     RANGE 24-64000
        -interface_handle
        -internal_ppm_adjust            ANY
        -intf_ip_addr                   IP
        -intf_ip_addr_step              IP
        -intf_mode                      CHOICES atm pos_hdlc pos_ppp ethernet
                                        CHOICES frame_relay1490 bert
                                        CHOICES multis multis_fcoe ethernet_vm
                                        CHOICES frame_relay2427 frame_relay_cisco
                                        CHOICES srp srp_cisco rpr gfp ethernet_fcoe
                                        CHOICES fc
        -intrinsic_latency_adjustment   CHOICES 0 1
        -ipv6_gateway                   IP
        -ipv6_gateway_step              IP
        -ipv6_intf_addr                 IP
        -ipv6_intf_addr_step            IP
        -ipv6_addr_mode                 CHOICES static autoconfig
        -ipv6_prefix_length
        -l23_config_type                CHOICES protocol_interface static_endpoint 
                                        DEFAULT protocol_interface
        -mode                           CHOICES config modify destroy
                                        DEFAULT config
        -mss                            RANGE 28-9460 
                                        DEFAULT 1460
        -mtu                            RANGE 68-9500
        -netmask                        IP
        -ndp_send_req                   CHOICES 0 1
        -no_write                       FLAG
        -ns_on_linkup                   CHOICES 0 1
        -op_mode                        CHOICES loopback normal monitor
                                        CHOICES sim_disconnect
        -override_existence_check       CHOICES 0 1
                                        DEFAULT 0
        -override_tracking              CHOICES 0 1
                                        DEFAULT 0
        -pcs_period                     NUMERIC
        -pcs_count                      NUMERIC
        -pcs_repeat                     NUMERIC
        -pcs_period_type                NUMERIC
        -pcs_lane                       NUMERIC
        -pcs_enabled_continuous         CHOICES 0 1
        -pcs_sync_bits                  ANY
        -pcs_marker_fields              ANY
        -pgid_128k_bin_enable           CHOICES 0 1
        -pgid_mask
        -pgid_offset                    RANGE 4-32677
        -pgid_mode                      CHOICES custom dscp ipv6TC mplsExp split 
                                        CHOICES outer_vlan_priority outer_vlan_id_4
                                        CHOICES outer_vlan_id_6 outer_vlan_id_8
                                        CHOICES outer_vlan_id_10 outer_vlan_id_12
                                        CHOICES inner_vlan_priority inner_vlan_id_4
                                        CHOICES inner_vlan_id_6 inner_vlan_id_8
                                        CHOICES inner_vlan_id_10 inner_vlan_id_12
                                        CHOICES tos_precedence ipv6TC_bits_0_2
                                        CHOICES ipv6TC_bits_0_5
        -pgid_encap                     CHOICES LLCRoutedCLIP 
                                        CHOICES LLCPPPoA
                                        CHOICES LLCBridgedEthernetFCS
                                        CHOICES LLCBridgedEthernetNoFCS 
                                        CHOICES VccMuxPPPoA 
                                        CHOICES VccMuxIPV4Routed 
                                        CHOICES VccMuxBridgedEthernetFCS
                                        CHOICES VccMuxBridgedEthernetNoFCS
        -pgid_split1_mask               ANY
        -pgid_split1_offset             NUMERIC
        -pgid_split1_offset_from        CHOICES start_of_frame
        -pgid_split2_mask               ANY
        -pgid_split2_offset             NUMERIC
        -pgid_split2_offset_from        CHOICES start_of_frame
        -pgid_split2_width              RANGE 0-4
        -pgid_split3_mask               ANY
        -pgid_split3_offset             NUMERIC
        -pgid_split3_offset_from        CHOICES start_of_frame
        -pgid_split3_width              RANGE 0-4
        -phy_mode                       CHOICES copper fiber sgmii
		-master_slave_mode				CHOICES auto master slave
        -port_rx_mode                   REGEXP $port_rx_mode_regexp
        -ppp_ipv4_address               IPV4
        -ppp_ipv4_negotiation           CHOICES 0 1
        -ppp_ipv6_negotiation           CHOICES 0 1
        -ppp_mpls_negotiation           CHOICES 0 1
        -ppp_osi_negotiation            CHOICES 0 1
        -pvc_incr_mode                  CHOICES vci vpi both 
                                        DEFAULT both
        -qinq_incr_mode                 CHOICES inner outer both 
                                        DEFAULT both
        -qos_byte_offset                RANGE 0-63
        -qos_packet_type                CHOICES ethernet ip_snap vlan custom
                                        CHOICES ip_ppp ip_cisco_hdlc ip_atm
        -qos_pattern_mask
        -qos_pattern_match
        -qos_pattern_offset             RANGE 0-65535
        -qos_stats                      CHOICES 0 1
        -router_solicitation_retries    RANGE 1-100
        -rpr_hec_seed                   CHOICES 0 1
        -rx_c2
        -rx_fcs                         CHOICES 16 32
        -rx_scrambling                  CHOICES 0 1
        -send_router_solicitation       CHOICES 0 1
        -sequence_checking              CHOICES 0 1
        -sequence_num_offset            RANGE 24-64000
        -signature
        -signature_mask
        -signature_offset               RANGE 24-64000
        -signature_start_offset         RANGE 0-64000
        -single_arp_per_gateway         CHOICES 0 1
        -single_ns_per_gateway          CHOICES 0 1
        -speed                          CHOICES ether10 ether100 ether1000
                                        CHOICES oc3 oc12 oc48 oc192 auto
                                        CHOICES ether10000wan ether10000lan
                                        CHOICES ether40000lan ether100000lan
                                        CHOICES ether10Gig ether25Gig ether40Gig ether100Gig
                                        CHOICES fc2000 fc4000 fc8000
                                        CHOICES ether100vm ether1000vm ether10000vm
                                        CHOICES ether2000vm ether3000vm ether4000vm
                                        CHOICES ether5000vm ether6000vm ether7000vm
                                        CHOICES ether8000vm ether9000vm
        -src_mac_addr
        -src_mac_addr_step              MAC
        -target_link_layer_address      CHOICES 0 1
        -transmit_clock_source          CHOICES internal bits loop external internal_ppm_adj
        -transmit_mode                  CHOICES advanced stream advanced_coarse stream_coarse flow echo
        -tx_c2
        -tx_fcs                         CHOICES 16 32
        -tx_rx_sync_stats_enable        CHOICES 0 1
        -tx_rx_sync_stats_interval      NUMERIC
        -tx_scrambling                  CHOICES 0 1
        -vci                            RANGE 32-65535
        -vci_count                      RANGE 1-65504 
                                        DEFAULT 4063
        -vci_step                       RANGE 0-65503 
                                        DEFAULT 1
        -vlan                           CHOICES 0 1
        -vlan_id                        REGEXP $vlan_id_regexp
        -vlan_id_step                   REGEXP $vlan_id_step_regexp
        -vlan_id_count                  REGEXP $vlan_id_count_regexp
        -vlan_tpid                      VCMD ::ixia::_validate_vlan_tpid
        -vlan_user_priority             REGEXP $vlan_user_priority_regexp
        -vlan_user_priority_step        REGEXP $vlan_user_priority_step_regexp
        -vlan_id_list                   REGEXP $vlan_id_regexp
        -vlan_id_mode                   CHOICES fixed increment
        -vlan_protocol_id               CHOICES 0x8100 0x88A8 0x9100 0x9200
        -vlan_id_inner                  REGEXP $vlan_id_regexp
        -vlan_id_inner_mode             CHOICES fixed increment
        -vlan_id_inner_count            VCMD ::ixia::validate_vlan_id_inner_step
        -vlan_id_inner_step             VCMD ::ixia::validate_vlan_id_inner_step
        -vpi                            RANGE 0-255
        -vpi_count                      RANGE 1-256 
                                        DEFAULT 1
        -vpi_step                       RANGE 0-255 
                                        DEFAULT 1
        -enable_flow_control            CHOICES 0 1
        -enable_ndp                     CHOICES 0 1
                                        DEFAULT 1
        -flow_control_directed_addr     ANY
        -fcoe_priority_groups           ANY
        -fcoe_support_data_center_mode  CHOICES 0 1
        -fcoe_priority_group_size       CHOICES 4 8
        -fcoe_flow_control_type         CHOICES ieee802.3x ieee802.1Qbb
        -fc_credit_starvation_value     NUMERIC
                                        DEFAULT 0
        -fc_no_rrdy_after               NUMERIC
                                        DEFAULT 100
        -fc_tx_ignore_rx_link_faults    CHOICES 0 1
        -fc_max_delay_for_random_value  RANGE 0-1000000
                                        DEFAULT 0
        -fc_tx_ignore_available_credits CHOICES 0 1
                                        DEFAULT 0
        -fc_min_delay_for_random_value  NUMERIC
                                        DEFAULT 0
        -fc_rrdy_response_delays        CHOICES credit_starvation fixed_delay no_delay random_delay
                                        DEFAULT no_delay
        -fc_fixed_delay_value           RANGE 0-20000
                                        DEFAULT 1
        -fc_force_errors                CHOICES no_errors no_rrdy no_rrdy_every
                                        DEFAULT no_erors
        -enable_data_center_shared_stats CHOICES 0 1
        -additional_fcoe_stat_1         CHOICES fcoe_invalid_delimiter
                                        CHOICES fcoe_invalid_frames
                                        CHOICES fcoe_invalid_size
                                        CHOICES fcoe_normal_size_bad_fc_crc
                                        CHOICES fcoe_normal_size_good_fc_crc
                                        CHOICES fcoe_undersize_bad_fc_crc
                                        CHOICES fcoe_undersize_good_fc_crc
                                        CHOICES fcoe_valid_frames
        -additional_fcoe_stat_2         CHOICES fcoe_invalid_delimiter
                                        CHOICES fcoe_invalid_frames
                                        CHOICES fcoe_invalid_size
                                        CHOICES fcoe_normal_size_bad_fc_crc
                                        CHOICES fcoe_normal_size_good_fc_crc
                                        CHOICES fcoe_undersize_bad_fc_crc
                                        CHOICES fcoe_undersize_good_fc_crc
                                        CHOICES fcoe_valid_frames
        -bad_blocks_number              NUMERIC
        -good_blocks_number             NUMERIC
        -loop_count_number              NUMERIC
        -type_a_ordered_sets            CHOICES local_fault remote_fault
        -type_b_ordered_sets            CHOICES local_fault remote_fault
        -loop_continuously              CHOICES 0 1
        -start_error_insertion          CHOICES 0 1
        -send_sets_mode                 CHOICES type_a_only type_b_only alternate
        -tx_gap_control_mode            CHOICES fixed average
        -tx_lanes               ANY
        -static_enable                  CHOICES 0 1
        -static_atm_header_encapsulation
        -static_atm_range_count         
        -static_vci                     
        -static_vci_increment           
        -static_vci_increment_step      
        -static_vci_step                
        -static_pvc_count               
        -static_pvc_count_step          
        -static_vpi                     
        -static_vpi_increment           
        -static_vpi_increment_step      
        -static_vpi_step                
        -static_dlci_count_mode         
        -static_dlci_repeat_count       
        -static_dlci_repeat_count_step  
        -static_dlci_value              
        -static_dlci_value_step
        -static_fr_range_count          
        -static_intf_handle             
        -static_ip_dst_addr             
        -static_ip_dst_count            
        -static_ip_dst_count_step       
        -static_ip_dst_increment        
        -static_ip_dst_increment_step   
        -static_ip_dst_prefix_len       
        -static_ip_dst_prefix_len_step  
        -static_ip_dst_range_step       
        -static_ip_range_count          
        -static_l3_protocol             
        -static_indirect                
        -static_range_per_spoke         
        -static_lan_intermediate_objref 
        -static_lan_range_count         NUMERIC
                                        DEFAULT 0
        -static_mac_dst                 
        -static_mac_dst_count           
        -static_mac_dst_count_step      
        -static_mac_dst_mode            
        -static_mac_dst_step            
        -static_site_id                 
        -static_site_id_enable          
        -static_site_id_step            
        -static_vlan_enable             
        -static_vlan_id                 REGEXP ^\[0-9\]+(:\[0-9\]+)*$
        -static_vlan_id_mode            
        -static_vlan_id_step            REGEXP $static_vlan_id_step_regexp
        -static_lan_count_per_vc        
        -static_lan_incr_per_vc_vlan_mode
        -static_lan_mac_range_mode      
        -static_lan_number_of_vcs       
        -static_lan_skip_vlan_id_zero   
        -static_lan_tpid                REGEXP ^\[0x8100|0x88a8|0x88A8|0x9100|0x9200\]+(:\[0x8100|0x88a8|0x88A8|0x9100|0x9200\]+)*$
        -static_lan_vlan_priority       REGEXP ^\[0-9\]+(:\[0-9\]+)*$
        -static_lan_vlan_stack_count    
        -static_ig_atm_encap            
        -static_ig_vlan_enable          
        -static_ig_ip_type              
        -static_ig_interface_enable_list
        -static_ig_interface_handle_list
        -static_ig_range_count          
        "

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        append opt_args "
        -pgid_split1_width          RANGE 0-12
        -clause73_autonegotiation   CHOICES 0 1
        -enable_rs_fec              CHOICES 0 1
        -enable_rs_fec_statistics   CHOICES 0 1
		-link_training				CHOICES 0 1
		-ieee_media_defaults		CHOICES 0 1
        -laser_on                   CHOICES 0 1
        -tx_ignore_rx_link_faults   CHOICES 0 1
        "
    } else {
        append opt_args "-pgid_split1_width              RANGE 0-4
            "
    }
    set general_args_list_to_multiply {
        arp_req_retries
        arp_req_timer
        arp_send_req
        arp_on_linkup
        arp_refresh_interval
        atm_enable_coset
        atm_enable_pattern_matching
        atm_encapsulation
        atm_filler_cell
        atm_interface_type
        atm_packet_decode_mode
        atm_reassembly_timeout
        autonegotiation
        auto_detect_instrumentation_type
        bert_configuration
        bert_error_insertion
        check_gateway_exists
        clocksource
        connected_count
        data_integrity
        duplex
        enable_flow_control
        framing
        gateway
        gateway_step
        gre_checksum_enable
        gre_count
        gre_dst_ip_addr_step
        gre_ip_addr_step
        gre_ip_prefix_length
        gre_ipv6_addr_step
        gre_ipv6_prefix_length
        gre_key_enable
        gre_key_in
        gre_key_out
        gre_seq_enable
        ignore_link
        clause73_autonegotiation
        laser_on
        enable_rs_fec
        enable_rs_fec_statistics
		link_training	
		ieee_media_defaults
        tx_ignore_rx_link_faults
        integrity_signature
        integrity_signature_offset
        interface_handle
        internal_ppm_adjust
        intf_ip_addr_step
        intf_mode
        ipv6_intf_addr_step
        ipv6_prefix_length
        ipv6_gateway
        ipv6_gateway_step
        mode
        mtu
        netmask
        no_write
        ns_on_linkup
        op_mode
        pcs_period
        pcs_count
        pcs_repeat
        pcs_period_type
        pcs_lane
        pcs_enabled_continuous
        pcs_sync_bits
        pcs_marker_fields
        pgid_128k_bin_enable
        pgid_mask
        pgid_offset
        pgid_mode
        pgid_split1_mask
        pgid_split1_offset
        pgid_split1_offset_from
        pgid_split1_width
        pgid_split2_mask
        pgid_split2_offset
        pgid_split2_offset_from
        pgid_split2_width
        pgid_split3_mask
        pgid_split3_offset
        pgid_split3_offset_from
        pgid_split3_width
        phy_mode
		master_slave_mode
        port_rx_mode
        ppp_ipv4_negotiation
        ppp_ipv6_negotiation
        ppp_mpls_negotiation
        ppp_osi_negotiation
        qos_byte_offset
        qos_packet_type
        qos_pattern_mask
        qos_pattern_match
        qos_pattern_offset
        qos_stats
        router_solicitation_retries
        rpr_hec_seed
        rx_c2
        rx_fcs
        rx_scrambling
        send_router_solicitation
        ndp_send_req
        sequence_checking
        sequence_num_offset
        signature
        signature_mask
        signature_offset
        signature_start_offset
        single_arp_per_gateway
        single_ns_per_gateway
        speed
        src_mac_addr_step
        target_link_layer_address
        transmit_clock_source
        transmit_mode
        tx_gap_control_mode
        tx_lanes
        tx_c2
        tx_fcs
        tx_scrambling
        vci
        vci_step
        vlan
        vlan_id
        vlan_id_step
        vlan_tpid
        vlan_user_priority
        vlan_user_priority_step
        vpi
        vpi_step
    }
    
    set args_list_to_multiply_as_null {
        gateway
        gre_dst_ip_addr
        gre_ip_addr
        gre_ipv6_addr
        intf_ip_addr
        ipv6_intf_addr
        ppp_ipv4_address
    }
    # src_mac_addr
    # HDLC, PPP to be added
    set x [lsearch $args -internal_ppm_adjust]
    if {$x>=0} {
        set ppm_val [lindex $args [expr $x+1]]
        regsub (^-) $ppm_val @ ppm_char
        regsub ($ppm_val) $args $ppm_char args
    }
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg"
        return $returnList
    }
    
    if { [info exists fc_tx_ignore_rx_link_faults] }  {
        puts "Warning! Argument fc_tx_ignore_rx_link_faults is deprecated. Please use tx_ignore_rx_link_faults instead."
        unset fc_tx_ignore_rx_link_faults
    }
    if {[info exists vlan_id_inner_mode] && $vlan_id_inner_mode == "fixed"} {
        set vlan_id_inner_step 0
    }
    if {[info exists vlan_id_mode] && $vlan_id_mode == "fixed"} {
        set vlan_id_step 0
    }

    if {[info exists vlan_protocol_id]} {
        if {[info exists vlan_id_inner]} {
            set vlan_tpid $vlan_protocol_id,0x8100
        } else {
            set vlan_tpid $vlan_protocol_id
        }
    }
    if {[info exists vlan_tpid]} {
        set vlan_tpid \
          [::ixia::_format_list -format "0x%x" -seperator "," -list $vlan_tpid]
    }
    
    # Set default values - these cannot be set through parse_dashed_args because 
    # their type does not accept DEFAULT
    array set defaults_array ""
    set default_values_list {
        connected_count          1
        intf_ip_addr_step        0.0.0.1
        ipv6_intf_addr_step      0000:0000:0000:0000:0000:0000:0000:0001
        ipv6_gateway_step        0000:0000:0000:0000:0000:0000:0000:0001
        gateway_step             0.0.0.1
        gre_count                1
        gre_ip_addr_step         0.0.0.1
        gre_ipv6_addr_step       0000:0000:0000:0000:0000:0000:0000:0001
        src_mac_addr_step        0000.0000.0001
        vlan_id_step             1
        vlan_id_inner_step       1
        vlan_user_priority_step  1
    }
    foreach {intf_cfg_param default_value} $default_values_list {
        if {![info exists $intf_cfg_param]} {
            set $intf_cfg_param $default_value
            set defaults_array($intf_cfg_param) 1
        }
    }

    if {[info exists vlan_id_list]} {
        set vlan_id $vlan_id_list
    }
    
    if {[info exists vlan_id_inner]} {
        if {[info exists vlan_id]} {
            # Multiplying the vlan_id elements
            set vlan_id [::ixia::multiply_last_list_element $vlan_id [llength $port_handle] " "]

            set addresses_per_vlan [::ixia::multiply_last_list_element $addresses_per_vlan [llength [split $vlan_id ","]] ","]
            set addresses_per_svlan [::ixia::multiply_last_list_element $addresses_per_svlan [llength [split $vlan_id_inner ","]] ","]
            
            set vlan_id_inner_step [::ixia::multiply_vlan_parameter $vlan_id_inner $vlan_id_inner_step]
            set vlan_id_step [::ixia::set_comma_separated_vlan $vlan_id_step $vlan_id_inner_step $l23_config_type]
            
            set vlan_id_aux [list]
            foreach vlan_id_el $vlan_id {
                lappend vlan_id_aux [lindex [split $vlan_id_el ","] 0]
            }
            set vlan_id $vlan_id_aux
            
            set vlan_id [::ixia::set_comma_separated_vlan $vlan_id $vlan_id_inner $l23_config_type]
            
            # vlan_id_inner_count is not valid without vlan_id_count
            if {[info exists vlan_id_count]} {
                if {[info exists vlan_id_inner_count]} {
                    set vlan_id_count "$vlan_id_count,$vlan_id_inner_count"
                }
            }
        } else {
            puts "\nWARNING: -vlan_id_inner cannot be used without the -vlan_id parameter.\
                 The -vlan_id_inner will be ignored."
            unset vlan_id_inner
        }
    }


    
    # Fix for single mac address using the format:
    # {00 00 00 00 00 00} or {0000 0000 0000}
    if {[info exists src_mac_addr]} {
        if {([string length [lindex $src_mac_addr 0]] <= 4) && \
                [lindex $src_mac_addr 0] != ""} {
            regsub -all " " $src_mac_addr "." src_mac_addr
        }
    }
    if {[info exists src_mac_addr_step]} {
        if {([string length [lindex $src_mac_addr_step 0]] <= 4) && \
                [lindex $src_mac_addr_step 0] != ""} {
            regsub -all " " $src_mac_addr_step "." src_mac_addr_step
        }
    }
    # Multiply all arguments that do not have the same length with the port_handle
    foreach general_arg_name $general_args_list_to_multiply {
        if {[info exists $general_arg_name] && ([set port_handle_diff \
                [expr [llength $port_handle] - [llength [set $general_arg_name]]]] > 0)} {
            for {set i 0} {$i < $port_handle_diff} {incr i} {
                lappend $general_arg_name [lindex [set $general_arg_name] end]
            }
        }
    }
    foreach arg_name $args_list_to_multiply_as_null {
        if {[info exists $arg_name] && ([set port_handle_diff \
                [expr [llength $port_handle] - [llength [set $arg_name]]]] > 0)} {
            for {set i 0} {$i < $port_handle_diff} {incr i} {
                lappend $arg_name {}
            }
        }
    }

    if {[info exists ndp_send_req]} {
        set send_router_solicitation $ndp_send_req
    }
    if {$arp == 0} {
        set arp_send_req 0
    }
    if {$enable_ndp == 0} {
        set send_router_solicitation 0
    }
    
    set do_set_default 1
    if {([info exists arp_send_req] && ([eval "expr \[join {$arp_send_req} \" || \"\]"] == 1)) || \
        ([info exists send_router_solicitation] && \
        ([eval "expr \[join {$send_router_solicitation} \" || \"\]"] == 1)) \
    } {
        # If at least one of these parameters exist, reset to defaults interfaces
        # If not just send the arp request
        set do_set_default 0
        set set_default_list [list intf_mode speed phy_mode clocksource mtu     \
            framing rx_fcs tx_fcs rx_scrambling tx_scrambling rx_c2 tx_c2 duplex\
            autonegotiation vlan src_mac_addr intf_ip_addr ipv6_intf_addr       \
            netmask ipv6_prefix_length gateway vpi vci atm_encapsulation        \
            atm_enable_coset atm_enable_pattern_matching atm_filler_cell        \
            atm_interface_type atm_packet_decode_mode atm_reassembly_timeout    \
            pgid_128k_bin_enable pgid_mask pgid_offset port_rx_mode             \
            ppp_ipv4_address ppp_ipv4_negotiation ppp_ipv6_negotiation          \
            ppp_mpls_negotiation ppp_osi_negotiation qos_stats qos_byte_offset  \
            qos_pattern_offset qos_pattern_match qos_pattern_mask               \
            qos_packet_type rpr_hec_seed sequence_checking sequence_num_offset  \
            data_integrity signature signature_mask signature_offset            \
            signature_start_offset integrity_signature op_mode                  \
            integrity_signature_offset transmit_mode vlan_user_priority         \
            tx_gap_control_mode tx_lanes                                                \
            gre_checksum_enable gre_dst_ip_addr gre_ip_addr                     \
            gre_ip_prefix_length gre_ipv6_addr gre_ipv6_prefix_length           \
            gre_key_enable gre_key_in gre_key_out gre_seq_enable ignore_link    \
            pgid_mode pgid_split1_mask pgid_split1_offset                       \
            pgid_split1_offset_from pgid_split1_width pgid_split2_mask          \
            pgid_split2_offset pgid_split2_offset_from pgid_split2_width        \
            pgid_split3_mask pgid_split3_offset pgid_split3_offset_from         \
            pgid_split3_width vlan_id ipv6_gateway auto_detect_instrumentation_type\
            ]
        
        foreach _param $set_default_list {
            if {[info exists $_param]} {
                set do_set_default 1
            }
        }
    }
    
    # Check if GRE parameters are present
    set gre_param_list {gre_checksum_enable gre_dst_ip_addr gre_ip_addr \
            gre_ip_prefix_length gre_ipv6_addr gre_ipv6_prefix_length \
            gre_key_enable gre_key_in gre_key_out gre_seq_enable}
    foreach gre_param $gre_param_list {
        if {[info exists $gre_param]} {
            set gre_enable 1
            break
        }
    }
 
  # BUG702413: GRE mandatory parameters for -mode modify should be only -port_handle and -interface_handle    
  # if {[info exists gre_enable]} {
  #     if {!(([info exists intf_ip_addr] || [info exists ipv6_intf_addr]) && \
  #             ([info exists gre_ip_addr] || [info exists gre_ipv6_addr]) && \
  #             [info exists gre_dst_ip_addr])} {
  #         keylset returnList status $::FAILURE
  #         keylset returnList log "ERROR in $procName: Missing mandatory \
  #                 arguments for configuring GRE tunnels. When configuring \
  #                 GRE tunnels you must provide the following parameters: \
  #                 intf_ip_addr/ipv6_intf_addr, gre_ip_addr/gre_ipv6_addr \
  #                 and gre_dst_ip_addr."
  #         return $returnList
  #     }
  # }
    
    foreach {param_name cmd_check} {intf_ip_addr isIpAddressValid \
            ipv6_ip_addr ::ipv6::isValidAddress} {
        if {[info exists $param_name]} {
            foreach param_item [set $param_name] {
                if {$param_item != "" && \
                        ([eval {$cmd_check $param_item}] == 0)} {
                    set invalid_value_found 1
                    break
                }
            }
        }
    }
    if {[info exists invalid_value_found]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Invalid IP address type. \
                For intf_ip_addr please use IPv4 addresses and for \
                ipv6_intf_addr please use IPv6 addresses."
        return $returnList
    }
        
    # if exists GRE parameters check tunnel endpoints
    if {[info exists gre_dst_ip_addr]} {
        if {![info exists intf_ip_addr] } {
            foreach {temp_gre_dst_ip_addr} $gre_dst_ip_addr {
                if {($temp_gre_dst_ip_addr != "") && [isIpAddressValid $temp_gre_dst_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When parameter\
                            gre_dst_ip_addr is an IPv4 address, then\
                            intf_ip_addr must be specified. Source and\
                            destination of a GRE tunnel must have the same\
                            IP type."
                    return $returnList
                }
            }
        }
        
        if {![info exists ipv6_intf_addr]} {
            foreach {temp_gre_dst_ip_addr} $gre_dst_ip_addr {
                if {($temp_gre_dst_ip_addr != "") && [::ipv6::isValidAddress \
                        $temp_gre_dst_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When parameter\
                            gre_dst_ip_addr is an IPv6 address, then\
                            ipv6_intf_addr must be specified. Source and\
                            destination of a GRE tunnel must have the same\
                            IP type."
                    return $returnList
                }
            }
        }
    
        if {![info exists gre_dst_ip_addr_step]} {
            foreach {temp_gre_dst_ip_addr} $gre_dst_ip_addr {
                if {$temp_gre_dst_ip_addr != ""} {
                    if {[isIpAddressValid $temp_gre_dst_ip_addr]} {
                        lappend gre_dst_ip_addr_step 0.0.0.1
                    } else {
                       lappend gre_dst_ip_addr_step 0000:0000:0000:0000:0000:0000:0000:0001
                    }
                } else {
                    lappend gre_dst_ip_addr_step {}
                }
            }
        }
    }
    # Check VLAN values
    if {[info exists vlan]} {
        set first_vlan [lindex $vlan 0]
        if {[info exists vlan_id]} {
            foreach vlan_id_group $vlan_id vlan_enable $vlan {
                if {$vlan_enable == 1 || ($vlan_enable == "" && $first_vlan == 1)} {
                    set vlan_id_list [split $vlan_id_group ,]
                    set num_vlan_id [llength $vlan_id_list]
                    foreach vlan_id_value $vlan_id_list {
                        if {$vlan_id_value < 0 || $vlan_id_value > 4095} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Invalid\
                                    parameter -vlan_id. Please provide values\
                                    between 0 and 4095."
                            return $returnList
                        }
                    }
                }
            }
        }
        if {[info exists vlan_id] && [info exists vlan_user_priority]} {
            foreach vlan_id_group $vlan_id\
                    vlan_user_priority_group $vlan_user_priority\
                    vlan_enable $vlan {
                if {$vlan_enable == 1 || ($vlan_enable == "" && $first_vlan == 1)} {
                    set vlan_user_priority_list [split $vlan_user_priority_group ,]
                    set vlan_id_list [split $vlan_id_group ,]
                    if {[llength $vlan_id_list] != [llength $vlan_user_priority_list]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: The length of\
                                vlan_id list is not same with the\
                                vlan_user_priority list."
                        return $returnList
                    }
                }
            }
        }
    }

    # Check whether the IxNetwork API is used or not
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        
        set objectCount 0
        set intf_list [format_space_port_list $port_handle]
        
        set already_destroyed    ""
        set option_index        0
        foreach interface $intf_list {
            
            if {[lsearch $already_destroyed $interface] != -1} {
                incr option_index
                continue
            } else {
                lappend already_destroyed $interface
            }
                        
            if {[info exists mode] && ($mode == "destroy" ||\
                [lindex $mode $option_index] == "destroy") \
            } {
                scan $interface "%d %d %d" chassis card port
                
                set retCode [ixNetworkClearPorts "${chassis}/${card}/${port}"]
                if {[keylget retCode status] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed deleting interface\
                            $intf_desc. [keylget retCode log]"
                    return $returnList
                }

                set retCode [rfremove_all_interfaces_from_port "${chassis}/${card}/${port}"]
                if {[keylget retCode status] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error: Deleting interface\
                            $intf_desc. [keylget retCode log]"
                    return $returnList
                }
            }
            incr option_index
        }
        
        catch {unset already_destroyed}
        
        set option_index        0
        set unique_intf_list    [list]
        set gre_able_index_list [list]
        set connected_intf_list [list]
        set routed_intf_list    [list]
        set gre_intf_list       [list]
        
        set protocols_static_endpoint_keys [list atm_endpoints fr_endpoints ip_endpoints lan_endpoints ig_endpoints]
        foreach endpoint_key $protocols_static_endpoint_keys {
            set $endpoint_key [list]
        }

        # Configure global statistics for FCoE
        set fcoe_global_stats_options [list                                         \
            additionalFcoeStat1          translate additional_fcoe_stat_1           \
            additionalFcoeStat2          translate additional_fcoe_stat_2           \
            enableDataCenterSharedStats  truth     enable_data_center_shared_stats  \
        ]
            
        array set translate_statistics_fcoe [list                       \
            fcoe_invalid_delimiter          fcoeInvalidDelimiter        \
            fcoe_invalid_frames             fcoeInvalidFrames           \
            fcoe_invalid_size               fcoeInvalidSize             \
            fcoe_normal_size_bad_fc_crc     fcoeNormalSizeBadFcCRC      \
            fcoe_normal_size_good_fc_crc    fcoeNormalSizeGoodFcCRC     \
            fcoe_undersize_bad_fc_crc       fcoeUndersizeBadFcCRC       \
            fcoe_undersize_good_fc_crc      fcoeUndersizeGoodFcCRC      \
            fcoe_valid_frames               fcoeValidFrames             \
        ]
        
        set fcoe_global_stat_args ""
        foreach {ixn_p p_type hlt_p} $fcoe_global_stats_options {
            if {[info exists $hlt_p]} {
                set hlt_p_val [set $hlt_p]
                switch -- $p_type {
                    "translate" {
                        if {![info exists translate_statistics_fcoe($hlt_p_val)]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error in $procName:\
                                    unhandled value '$hlt_p_val' for parameter '$hlt_p'."
                            return $returnList
                        }
                        set ixn_p_val $translate_statistics_fcoe($hlt_p_val)
                    }
                    "truth" {
                        set ixn_p_val $::ixia::truth($hlt_p_val)
                    }
                    default {
                        set ixn_p_val $hlt_p_val
                    }
                }
                
                lappend fcoe_global_stat_args -$ixn_p $ixn_p_val
            }
        }
        
        if {[llength $fcoe_global_stat_args] > 0} {
            set result [ixNetworkNodeSetAttr [ixNet getRoot]/statistics \
                    $fcoe_global_stat_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to configure FCoE\
                        global statistics. [keylget result log]"
                return $returnList
            }
        }
        
        # Configure global interfaces settings
        set global_interfaces_options [list                            \
            arpOnLinkup              truth     arp_on_linkup           \
            nsOnLinkup               truth     ns_on_linkup            \
            sendSingleArpPerGateway  truth     single_arp_per_gateway  \
            sendSingleNsPerGateway   truth     single_ns_per_gateway   \
        ]
        array set translate_global_interfaces ""
        set global_interfaces_args ""
        foreach {ixn_p p_type hlt_p} $global_interfaces_options {
            if {[info exists $hlt_p]} {
                set hlt_p_val [lindex [set $hlt_p] 0]
                switch -- $p_type {
                    "translate" {
                        if {![info exists translate_global_interfaces($hlt_p_val)]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error in $procName:\
                                    unhandled value '$hlt_p_val' for parameter '$hlt_p'."
                            return $returnList
                        }
                        set ixn_p_val $translate_global_interfaces($hlt_p_val)
                    }
                    "truth" {
                        set ixn_p_val $::ixia::truth($hlt_p_val)
                    }
                    default {
                        set ixn_p_val $hlt_p_val
                    }
                }
                
                lappend global_interfaces_args -$ixn_p $ixn_p_val
            }
        }
        
        if {[llength $global_interfaces_args] > 0} {
            set result [ixNetworkNodeSetAttr [ixNet getRoot]/globals/interfaces \
                    $global_interfaces_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to configure\
                        global interface settings (ARP on linkup, NS on linkup, single ARP per gateway, single NS per gateway). [keylget result log]"
                return $returnList
            }
        }
        
        ::ixia::debug "Start L1 config for ports" vports_l1_cfg_00
        catch {unset return_status}
        set l1_port_default_options {
            transmit_mode                       advanced
        }
        
        set l1_port_options1 "                                              \
                -autonegotiation                autonegotiation             \
                -duplex                         duplex                      \
                -intf_mode                      intf_mode                   \
                -phy_mode                       phy_mode                    \
				-master_slave_mode				master_slave_mode			\
                -speed                          speed                       \
                -ignore_link                    ignore_link                 \
                -clause73_autonegotiation       clause73_autonegotiation    \
                -laser_on                       laser_on                    \
                -enable_rs_fec                  enable_rs_fec               \
                -enable_rs_fec_statistics       enable_rs_fec_statistics    \
				-link_training					link_training				\
				-ieee_media_defaults			ieee_media_defaults			\
                -bad_blocks_number              bad_blocks_number           \
                -good_blocks_number             good_blocks_number          \
                -loop_count_number              loop_count_number           \
                -type_a_ordered_sets            type_a_ordered_sets         \
                -type_b_ordered_sets            type_b_ordered_sets         \
                -loop_continuously              loop_continuously           \
                -start_error_insertion          start_error_insertion       \
                -send_sets_mode                 send_sets_mode              \
                -tx_ignore_rx_link_faults       tx_ignore_rx_link_faults    \
                "
        set proc_nr 1
        IxNetworkPortL1Config
        # check if the IxNetworkPortL1Config was succesfully executed
        if {[keylget return_status status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to configure L1. [keylget return_status log]"
            return $returnList
        }
        if {![catch {keylget return_status commit_needed} keyvalcommit]} {
            if {$keyvalcommit} {
                if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to configure L1."
                    return $returnList
                }
            }
        }
        set unique_intf_list    [list]
        set option_index        0
        set l1_port_options2 "                                              \
                -autonegotiation                autonegotiation             \
                -auto_detect_instrumentation_type auto_detect_instrumentation_type \
                -atm_enable_coset               atm_enable_coset            \
                -atm_enable_pattern_matching    atm_enable_pattern_matching \
                -atm_filler_cell                atm_filler_cell             \
                -atm_interface_type             atm_interface_type          \
                -atm_reassembly_timeout         atm_reassembly_timeout      \
                -clocksource                    clocksource                 \
                -clause73_autonegotiation       clause73_autonegotiation    \
                -laser_on                       laser_on                    \
                -enable_rs_fec                  enable_rs_fec               \
                -enable_rs_fec_statistics       enable_rs_fec_statistics    \
				-link_training					link_training				\
				-ieee_media_defaults			ieee_media_defaults			\
                -bad_blocks_number              bad_blocks_number           \
                -good_blocks_number             good_blocks_number          \
                -loop_count_number              loop_count_number           \
                -type_a_ordered_sets            type_a_ordered_sets         \
                -type_b_ordered_sets            type_b_ordered_sets         \
                -loop_continuously              loop_continuously           \
                -start_error_insertion          start_error_insertion       \
                -send_sets_mode                 send_sets_mode              \
                -duplex                         duplex                      \
                -framing                        framing                     \
                -internal_ppm_adjust            internal_ppm_adjust         \
                -intf_mode                      intf_mode                   \
                -op_mode                        op_mode                     \
                -phy_mode                       phy_mode                    \
				-master_slave_mode				master_slave_mode			\
                -port_rx_mode                   port_rx_mode                \
                -rx_c2                          rx_c2                       \
                -speed                          speed                       \
                -transmit_clock_source          transmit_clock_source       \
                -tx_c2                          tx_c2                       \
                -enable_flow_control            enable_flow_control         \
                -flow_control_directed_addr     flow_control_directed_addr  \
                -fcoe_priority_groups           fcoe_priority_groups        \
                -fcoe_support_data_center_mode  fcoe_support_data_center_mode\
                -fcoe_priority_group_size       fcoe_priority_group_size    \
                -fcoe_flow_control_type         fcoe_flow_control_type      \
                -rx_fcs                         rx_fcs                      \
                -rx_scrambling                  rx_scrambling               \
                -tx_fcs                         tx_fcs                      \
                -tx_scrambling                  tx_scrambling               \
                -tx_ignore_rx_link_faults       tx_ignore_rx_link_faults    \
                "
        set proc_nr 2
        IxNetworkPortL1Config
        # check if the IxNetworkPortL1Config was succesfully executed
        if {[keylget return_status status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to configure L1. [keylget return_status log]"
            return $returnList
        }
        if {![catch {keylget return_status commit_needed} keyvalcommit]} {
            if {$keyvalcommit} {
                if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to configure L1."
                    return $returnList
                }
            }
        }
        set unique_intf_list    [list]
        set option_index        0
        if {[info exists transmit_mode] && [expr [string first "_coarse" $transmit_mode] >0] } {
            if  {[info exists intf_mode] && $intf_mode != "ethernet_vm" } {
                puts "Warning: $transmit_mode transmit_mode is specific to ethernet_vm intf_mode and is not compatible with $intf_mode intf_mode."
                unset transmit_mode
            }
            if {![info exists intf_mode]} {
                puts "Warning: $transmit_mode transmit_mode is specific to ethernet_vm intf_mode. If your card is not virtual, transmit_mode will be ignored!"
            }
        }
        set l1_port_options3 "                                              \
                -data_integrity                 data_integrity              \
                -intf_mode                      intf_mode                   \
                -port_rx_mode                   port_rx_mode                \
                -ppp_ipv4_address               ppp_ipv4_address            \
                -ppp_ipv4_negotiation           ppp_ipv4_negotiation        \
                -ppp_ipv6_negotiation           ppp_ipv6_negotiation        \
                -ppp_mpls_negotiation           ppp_mpls_negotiation        \
                -ppp_osi_negotiation            ppp_osi_negotiation         \
                -transmit_mode                  transmit_mode               \
                -tx_gap_control_mode            tx_gap_control_mode         \
                "
        set proc_nr 3
        IxNetworkPortL1Config
        # check if the IxNetworkPortL1Config was succesfully executed
        if {[keylget return_status status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to configure L1. [keylget return_status log]"
            return $returnList
        }
        if {![catch {keylget return_status commit_needed} keyvalcommit]} {
            if {$keyvalcommit} {
                if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to configure L1."
                    return $returnList
                }
            }
        }
        set unique_intf_list    [list]
        set option_index        0
        set l1_port_options4 "                                             \
                -data_integrity                 data_integrity              \
                -intf_mode                      intf_mode                   \
                -intf_type                      intf_type_list              \
                -op_mode                        op_mode                     \
                -port_rx_mode                   port_rx_mode                \
                -pgid_mode                      pgid_mode                   \
                -pgid_encap                     pgid_encap                  \
                -pgid_split1_offset             pgid_split1_offset          \
                -pgid_split1_width              pgid_split1_width           \
                "
        set proc_nr 4
        IxNetworkPortL1Config
        # check if the IxNetworkPortL1Config was succesfully executed
        if {[keylget return_status status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to configure L1. [keylget return_status log]"
            return $returnList
        }
        if {![catch {keylget return_status commit_needed} keyvalcommit]} {
            if {$keyvalcommit} {
                if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to configure L1."
                    return $returnList
                }
            }
        }
        ::ixia::debug "Done L1 config for ports" vports_l1_cfg_00
        
        set option_index        0
        set unique_intf_list    [list]
        
        foreach interface $intf_list {
            
            scan $interface "%d %d %d" chassis card port
            
            set ixnetwork_port_handle $chassis/$card/$port
            
            if {$do_set_default == 0} {
                continue
            }
            
            # Configure Rate Control Parameters
            set rate_control_parameters "                                      \
                arp_refresh_interval           arpRefreshInterval         \
                "
            foreach {hlt_var sdm_var} $rate_control_parameters {
                if {[info exists $hlt_var]} {
                    set tmpPort [::ixia::ixNetworkGetPortObjref $ixnetwork_port_handle]
                    set rateControlParams "[keylget tmpPort vport_objref]/rateControlParameters"
                    if {[ixNet exists $rateControlParams]} {
                        ixNet setAttribute $rateControlParams -$sdm_var [lindex [set $hlt_var] $option_index]
                        set commit_needed 1
                    }
                }
            }
            
            # Configure the second and third layers
            if {[info exists static_enable] && [lindex $static_enable $option_index]} {
                # If the ports are used for CPF, throw error. 
                # A single port cannot contain both CPF and legacy configuration
                # This validation is inserted here because ixiangpf calls 
                # the ixia namespacefor configuring L1 parameters.
                set global_topology_vports [ixNet getAttribute /globals/topology -vports]
                foreach port_handle_item $port_handle {
                    foreach cpf_port $global_topology_vports {   
                        if {[info exists ixnetwork_port_handles_array($port_handle_item)] &&\
                                ($::ixia::ixnetwork_port_handles_array($port_handle_item) == $cpf_port)} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to configure port $port_handle_item because\
                                    it already contains NGPF configuration."
                            return $returnList
                        }
                    }
                }
                
                ##
                # ATM static range params
                ##
                set static_atm_range_params {
                    static_atm_header_encapsulation     atm_header_encapsulation    translate
                    static_vci                          vci                         value
                    static_vci_increment                vci_increment               value
                    static_vci_increment_step           vci_increment_step          value
                    static_pvc_count                    pvc_count                   value
                    static_vpi                          vpi                         value
                    static_vpi_increment                vpi_increment               value
                    static_vpi_increment_step           vpi_increment_step          value
                    static_atm_range_count              atm_range_count             value
                    static_vpi_step                     vpi_step                    value
                    static_vci_step                     vci_step                    value
                    static_pvc_count_step               pvc_count_step              value
                }
                
                
                ##
                # FR static range params
                ##
                set static_fr_range_params {
                    static_dlci_count_mode              dlci_count_mode             value
                    static_dlci_repeat_count            dlci_repeat_count           value
                    static_dlci_value                   dlci_value                  value
                    static_dlci_repeat_count_step       dlci_repeat_count_step      value
                    static_fr_range_count               fr_range_count              value
                    static_dlci_value_step              dlci_value_step             value
                }
                
                
                ##
                # IP static range params
                ##
                set static_ip_range_params {
                    static_intf_handle                  intf_handle                 value
                    static_ip_dst_addr                  ip_dst_addr                 value
                    static_ip_dst_count                 ip_dst_count                value
                    static_ip_dst_count_step            ip_dst_count_step           value
                    static_ip_dst_increment             ip_dst_increment            value
                    static_ip_dst_increment_step        ip_dst_increment_step       value
                    static_ip_dst_prefix_len            ip_dst_prefix_len           value
                    static_ip_dst_prefix_len_step       ip_dst_prefix_len_step      value
                    static_ip_dst_range_step            ip_dst_range_step           value
                    static_ip_range_count               ip_range_count              value
                    static_l3_protocol                  l3_protocol                 value
                }
                
                
                ##
                # LAN static range params
                ##
                set static_lan_range_params {
                    static_lan_intermediate_objref      intermediate_objref         value
                    static_indirect                     indirect                    value
                    static_range_per_spoke              range_per_spoke             value
                    static_lan_range_count              lan_range_count             value
                    static_mac_dst                      mac_dst                     mac
                    static_mac_dst_count                mac_dst_count               value
                    static_mac_dst_count_step           mac_dst_count_step          value
                    static_mac_dst_mode                 mac_dst_mode                value
                    static_mac_dst_step                 mac_dst_step                value
                    static_site_id                      site_id                     value
                    static_site_id_enable               site_id_enable              value
                    static_site_id_step                 site_id_step                value
                    static_vlan_enable                  vlan_enable                 value
                    static_vlan_id                      vlan_id                     value
                    static_vlan_id_mode                 vlan_id_mode                value
                    static_vlan_id_step                 vlan_id_step                value
                    static_lan_count_per_vc             lan_count_per_vc            value
                    static_lan_incr_per_vc_vlan_mode    lan_incr_per_vc_vlan_mode   value
                    static_lan_mac_range_mode           lan_mac_range_mode          value
                    static_lan_number_of_vcs            lan_number_of_vcs           value
                    static_lan_skip_vlan_id_zero        lan_skip_vlan_id_zero       value
                    static_lan_tpid                     lan_tpid                    value
                    static_lan_vlan_priority            lan_vlan_priority           value
                    static_lan_vlan_stack_count         lan_vlan_stack_count        value
                }
                
                ##
                # Interface Group static range params
                ##
                set static_ig_range_params {
                    static_ig_atm_encap             static_ig_atm_encap                value
                    static_ig_vlan_enable           static_ig_vlan_enable              value
                    static_ig_ip_type               static_ig_ip_type                  value
                    static_ig_interface_enable_list static_ig_interface_enable_list    value
                    static_ig_interface_handle_list static_ig_interface_handle_list    value
                    static_ig_range_count           static_ig_range_count              value
                }
                
                array set translate_atm_encap {
                    LLCRoutedCLIP                   llc_routed_snap
                    LLCBridgedEthernetFCS           llc_bridged_eth_fcs
                    LLCBridgedEthernetNoFCS         llc_bridged_eth_no_fcs
                    LLCPPPoA                        llc_ppp
                    VccMuxPPPoA                     vcc_mux_ppp
                    VccMuxIPV4Routed                vcc_mux_routed
                    VccMuxBridgedEthernetFCS        vcc_mux_bridged_eth_fcs
                    VccMuxBridgedEthernetNoFCS      vcc_mux_bridged_eth_no_fcs
                }
                
                set static_params "ixNetworkStaticEndpointCfg"
                set lists {static_atm_range_params static_fr_range_params static_ip_range_params static_lan_range_params static_ig_range_params}
                foreach params_list $lists {
                    foreach {hlt_p_intf hlt_p_static_intf p_type} [set $params_list] {
                        if {[info exists $hlt_p_intf]} {
                            
                            ## If it's a single mac address make sure it doesn't have any spaces
                            #  Otherwise it will be fragmented
                            if {$p_type == "mac"} {
                                if {[isValidMacAddress [set $hlt_p_intf]]} {
                                    set $hlt_p_intf [ixNetworkFormatMac [set $hlt_p_intf]]
                                }
                            }
                            
                            if {([lindex [set $hlt_p_intf] $option_index] != {})} {
                                switch -- $p_type {
                                    translate {
                                        
                                        set tmp_encap_csv ""
                                        foreach tmp_encap [split [lindex [set $hlt_p_intf] $option_index] ,] {
                                            if {[catch {lappend tmp_encap_csv $translate_atm_encap($tmp_encap)}]} {
                                                keylset returnList status $::FAILURE
                                                keylset returnList log "Unhandled value '$tmp_encap' for parameter\
                                                        '$hlt_p_intf'"
                                                return $returnList
                                            }
                                        }
                                        
                                        lappend static_params -$hlt_p_static_intf $tmp_encap_csv
                                    }
                                    mac -
                                    value {
                                        lappend static_params -$hlt_p_static_intf [split [lindex [set $hlt_p_intf] $option_index] ,]
                                    }
                                }
                            }
                        }
                    }
                }
                
                set result [ixNetworkGetPortObjref $ixnetwork_port_handle]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not find any vport which uses the\
                            $ixnetwork_port_handle port - [keylget result log]."
                    return $returnList
                }
                set port_objref [keylget result vport_objref]
                
                lappend static_params -port_objref $port_objref
                
                set result [eval $static_params]
                if {[keylget result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to create static endpoints for port\
                            $ixnetwork_port_handle - [keylget result log]."
                    return $returnList
                }
                
                set all_protocols_static_endpoints ""
                
                foreach endpoint_key $protocols_static_endpoint_keys {
                    if {[llength [keylget result $endpoint_key]] > 0} {
                        if {[llength [set $endpoint_key]] == 0} {
                            set $endpoint_key [keylget result $endpoint_key]
                        } else {
                            append $endpoint_key " [keylget result $endpoint_key]"
                        }
                        
                        # interface_handle key should contain all references to static endpoints created
                        append all_protocols_static_endpoints " [keylget result $endpoint_key]"
                    }
                }
                
                set all_protocols_static_endpoints [string trim $all_protocols_static_endpoints]
                
            } elseif {$l23_config_type == "protocol_interface"} {
                if {[llength $mode]>1} {
                    set mode_index [lindex $mode $option_index]
                } elseif {[llength $mode]==1} {
                    set mode_index $mode
                } else {
                    # if mode is not set
                    set mode_index config
                }
                
                set intf_cfg_modify [expr {($mode_index == "modify") && [info exists interface_handle]}]
                set intf_cfg_create [expr {($mode_index == "config") || ($mode_index == "modify" && ![info exists interface_handle])}]
                
                set interface_handle_type ""
                if {$intf_cfg_modify} {
                    removeDefaultOptionVars $opt_args $args
                    
                    if {[info exists vlan_id_list]} {
                        set vlan_id $vlan_id_list
                    }     
                    set l23_config_type protocol_interface
                    # Get the interface type
                    if {[ixNet getAttr [lindex $interface_handle $option_index] -type] == "default"} {
                        set interface_handle_type "connected"
                    } elseif {[ixNet getAttr [lindex $interface_handle $option_index] -type] == "routed"} {
                        set interface_handle_type "routed"
                    } else {
                        set interface_handle_type "gre"
                    }
                } elseif {$intf_cfg_create} {
                    if {[info exists gre_enable]} {
                        if {!(([info exists intf_ip_addr] || [info exists ipv6_intf_addr]) && \
                                ([info exists gre_ip_addr] || [info exists gre_ipv6_addr]) && \
                                [info exists gre_dst_ip_addr])} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Missing mandatory \
                                    arguments for configuring GRE tunnels. When configuring \
                                    GRE tunnels you must provide the following parameters: \
                                    intf_ip_addr/ipv6_intf_addr, gre_ip_addr/gre_ipv6_addr \
                                    and gre_dst_ip_addr."
                            return $returnList
                        }
                    }
                }
                # Initialize options string
                # Create & Modify
                set ixnetwork_interface_options         " -port_handle    $chassis/$card/$port "
                set ixnetwork_interface_options_modify  " -port_handle    $chassis/$card/$port "
                if {[info exists override_existence_check]} {
                    append ixnetwork_interface_options          " -override_existence_check    $override_existence_check"
                    append ixnetwork_interface_options_modify   " -override_existence_check    $override_existence_check"
                }
                if {[info exists override_tracking]} {
                    append ixnetwork_interface_options          " -override_tracking    $override_tracking"
                    append ixnetwork_interface_options_modify   " -override_tracking    $override_tracking"
                }
                # Create or Modify Connected or Unconnected
                if {$intf_cfg_create || ($intf_cfg_modify && ($interface_handle_type == "connected" || $interface_handle_type == "routed")) } {
                     
                    # Create
                    # Skip ahead if no IP addresses are present
                    if {$intf_cfg_create} {
                        if {([info exists intf_ip_addr] && \
                                [llength $intf_ip_addr] > 1 && \
                                [lindex $intf_ip_addr $option_index] == {}) && \
                                ([info exists ipv6_intf_addr] && \
                                [llength $ipv6_intf_addr] > 1 && \
                                [lindex $ipv6_intf_addr $option_index] == {})} {
                            incr option_index
                            lappend unique_intf_list $interface
                            set unique_intf_list [lsort -unique $unique_intf_list]
                            continue
                        }
                    }
                    # Create
                    # Add multiple interface if required
                    if {$intf_cfg_create} {
                        if {[info exists connected_count]} {
                            append ixnetwork_interface_options " -count \
                                    [lindex $connected_count $option_index]"
                        }
                    }
                    
                    # Create
                    # MAC address - Set up a unique default MAC address if not specified.
                    if {(![info exists src_mac_addr] || \
                            ([info exists src_mac_addr] && \
                            [lindex $src_mac_addr $option_index] == {})) && \
                            ([info exists intf_ip_addr] || \
                            [info exists ipv6_intf_addr])} {
                        set retCode [::ixia::get_next_mac_address]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log [keylget retCode log]
                            return $returnList
                        }
                        set _mac_address [keylget retCode mac_address]
                        regsub -all " " $_mac_address ":" _mac_address
                        append ixnetwork_interface_options " -mac_address \
                                $_mac_address"
                        
                    }
                    # Create or Modify
                    # MAC address - Add the mac address if specified.
                    if {[info exists src_mac_addr] && ([lindex $src_mac_addr $option_index] != {})} {
                        # Create
                        append ixnetwork_interface_options " -mac_address \
                                [lindex $src_mac_addr $option_index]"
                        # Modify
                        append ixnetwork_interface_options_modify   " -mac_address \
                                [lindex $src_mac_addr $option_index]"
                    }
                    
                    # VLAN configuration
                    if {(([info exists vlan] && ([lindex $vlan $option_index] == 1)) && $mode_index == "config") || ($mode_index == "modify")} {
                        
                        if {[info exists vlan]} {
                            if {[lindex $vlan $option_index] != {}} {
                                # Create
                                append ixnetwork_interface_options \
                                        " -vlan_enabled \
                                        [lindex $vlan $option_index]"
                                # Modify
                                append ixnetwork_interface_options_modify \
                                        " -vlan_enabled \
                                        [lindex $vlan $option_index]"
                            }
                        }
                        
                        if {[info exists vlan_id]} {
                            if {[lindex $vlan_id $option_index] != {}} {
                                # Create
                                append ixnetwork_interface_options \
                                        " -vlan_id \
                                        [lindex $vlan_id $option_index]"
                                # Modify
                                append ixnetwork_interface_options_modify \
                                        " -vlan_id \
                                        [lindex $vlan_id $option_index]"
                            }
                        }
                        if {[info exists vlan_id_step]} {
                            if {[lindex $vlan_id_step $option_index] != {}} {
                                # Create
                                append ixnetwork_interface_options \
                                        " -vlan_id_step \
                                        [lindex $vlan_id_step $option_index]"
                                # Modify
                                append ixnetwork_interface_options_modify \
                                        " -vlan_id_step \
                                        [lindex $vlan_id_step $option_index]"
                            }
                        }
                        if {[info exists vlan_tpid]} {
                            if {[lindex $vlan_tpid $option_index] != {}} {
                                # Create
                                append ixnetwork_interface_options \
                                        " -vlan_tpid \
                                        [lindex $vlan_tpid $option_index]"
                                # Modify
                                append ixnetwork_interface_options_modify \
                                        " -vlan_tpid \
                                        [lindex $vlan_tpid $option_index]"
                            }
                        }
                        if {[info exists vlan_user_priority]} {
                            if {[lindex $vlan_user_priority $option_index] != {}} {
                                # Create
                                append ixnetwork_interface_options \
                                        " -vlan_user_priority \
                                        [lindex $vlan_user_priority $option_index]"
                                # Modify
                                append ixnetwork_interface_options_modify \
                                        " -vlan_user_priority \
                                        [lindex $vlan_user_priority $option_index]"
                            }
                        }
                        if {[info exists vlan_user_priority_step]} {
                            if {[lindex $vlan_user_priority_step $option_index] != {}} {
                                # Create
                                append ixnetwork_interface_options \
                                        " -vlan_user_priority_step \
                                        [lindex $vlan_user_priority_step $option_index]"
                                # Modify
                                append ixnetwork_interface_options_modify \
                                        " -vlan_user_priority_step \
                                        [lindex $vlan_user_priority_step $option_index]"
                            }
                        }
                    }
                    
                    # Create & Modify
                    if {$intf_cfg_create} {
                        # Create
                        set cfg_params_list {
                            atm_encapsulation    atm_encapsulation
                            vci                  atm_vci
                            vci_step             atm_vci_step
                            vpi                  atm_vpi
                            vpi_step             atm_vpi_step
                            mtu                  mtu
                            gateway              gateway_address
                            gateway_step         gateway_address_step
                            intf_ip_addr         ipv4_address
                            intf_ip_addr_step    ipv4_address_step
                            ipv6_prefix_length   ipv6_prefix_length
                            src_mac_addr_step    mac_address_step
                            check_gateway_exists check_gateway_exists
                            check_opposite_ip_version check_opposite_ip_version
                        }
                        foreach {intf_cfg_param prot_intf_cfg_param} $cfg_params_list {
                            if {[info exists $intf_cfg_param] && \
                                    ([lindex [set $intf_cfg_param] $option_index] != {} )} {
                                append ixnetwork_interface_options " -$prot_intf_cfg_param \
                                        [lindex [set $intf_cfg_param] $option_index]"
                            }
                        }
                    } else {
                        # Modify
                        set cfg_params_list {
                            atm_encapsulation           atm_encapsulation
                            vci                         atm_vci
                            vpi                         atm_vpi
                            mtu                         mtu
                            gateway                     gateway_address
                            interface_handle            prot_intf_objref
                            intf_ip_addr                ipv4_address
                            ipv6_prefix_length          ipv6_prefix_length
                            check_gateway_exists        check_gateway_exists
                            check_opposite_ip_version   check_opposite_ip_version
                        }
                        foreach {intf_cfg_param prot_intf_cfg_param} $cfg_params_list {
                            if {[info exists $intf_cfg_param] && \
                                    ([lindex [set $intf_cfg_param] $option_index] != {} )} {
                                append ixnetwork_interface_options_modify " -$prot_intf_cfg_param \
                                        [lindex [set $intf_cfg_param] $option_index]"
                            }
                        }
                    }
                    # IP configuration
                    
                    if {[info exists netmask]} {
                        if {[lindex $netmask $option_index] != {}} {
                            # Create
                            append ixnetwork_interface_options " -ipv4_prefix_length \
                                    [getIpV4MaskWidth \
                                    [lindex $netmask $option_index]]"
                            # Modify
                            append ixnetwork_interface_options_modify " -ipv4_prefix_length \
                                    [getIpV4MaskWidth \
                                    [lindex $netmask $option_index]]"
                        }
                    }
                    if {[info exists ipv6_intf_addr]} {
                        if {[lindex $ipv6_intf_addr $option_index] != {}} {
                            # Create
                            append ixnetwork_interface_options " -ipv6_address \
                                    [::ixia::expand_ipv6_addr \
                                    [lindex $ipv6_intf_addr $option_index]]"
                            # Modify
                            append ixnetwork_interface_options_modify " -ipv6_address \
                                    [::ixia::expand_ipv6_addr \
                                    [lindex $ipv6_intf_addr $option_index]]"
                        }
                    }
                    if {[info exists ipv6_intf_addr_step]} {
                        if {[lindex $ipv6_intf_addr_step $option_index] != {}} {
                            # Create
                            append ixnetwork_interface_options " -ipv6_address_step \
                                    [::ixia::expand_ipv6_addr \
                                    [lindex $ipv6_intf_addr_step $option_index]]"
                            # Modify
                             append ixnetwork_interface_options_modify " -ipv6_address_step \
                                    [::ixia::expand_ipv6_addr \
                                    [lindex $ipv6_intf_addr_step $option_index]]"
                        }
                    }
                    if {[info exists ipv6_gateway]} {
                        if {[lindex $ipv6_gateway $option_index] != {}} {
                            # Create
                            append ixnetwork_interface_options " -ipv6_gateway \
                                    [::ixia::expand_ipv6_addr \
                                    [lindex $ipv6_gateway $option_index]]"
                            # Modify
                            append ixnetwork_interface_options_modify " -ipv6_gateway \
                                    [::ixia::expand_ipv6_addr \
                                    [lindex $ipv6_gateway $option_index]]"
                        }
                    }
                    if {[info exists ipv6_gateway_step]} {
                        if {[lindex $ipv6_gateway_step $option_index] != {}} {
                            # Create
                            append ixnetwork_interface_options " -ipv6_gateway_step \
                                    [::ixia::expand_ipv6_addr \
                                    [lindex $ipv6_gateway_step $option_index]]"
                            # Modify
                            append ixnetwork_interface_options_modify " -ipv6_gateway_step \
                                    [::ixia::expand_ipv6_addr \
                                    [lindex $ipv6_gateway_step $option_index]]"
                        }
                    }
                    if {[info exists target_link_layer_address]} {
                        if {[lindex $target_link_layer_address $option_index] != {}} {
                            # Create
                            append ixnetwork_interface_options " -target_link_layer_address \
                                    [lindex $target_link_layer_address $option_index]"
                            # Modify
                            append ixnetwork_interface_options_modify " -target_link_layer_address \
                                    [lindex $target_link_layer_address $option_index]"
                        }
                    }
                    
                    if {$intf_cfg_modify} {
                        if {[info exists ipv6_gateway]} {
                            set ip_version 6
                            catch {ixNet getAttribute [lindex $interface_handle $option_index]/ipv6:1 -gateway} current_gateway
                        } elseif {[info exists gateway]} {
                            set ip_version 4
                            catch {ixNet getAttribute [lindex $interface_handle $option_index]/ipv4 -gateway} current_gateway
                        }
                        if {$interface_handle_type == "routed" && (([info exists gateway] && \
                                [lindex $gateway $option_index] != $current_gateway) || ([info exists ipv6_gateway] && \
                                [lindex $ipv6_gateway $option_index] != $current_gateway))} {
                            if {[regexp {^(::ixNet::OBJ-/vport:([0-9]+))(/interface:([0-9]+))$} \
                                    [lindex $interface_handle $option_index] -> match_vport]} {
                                set current_vport_intf [ixNet getList $match_vport interface]
                                set vport_conn_intf ""
                                set gateway_flag 0
                                foreach intf $current_vport_intf {
                                    set intf_type [ixNet getAttribute $intf -type]
                                    if {$intf_type == "default"} {
                                        if {$ip_version == 4} {
                                            if {![catch {ixNet getAttribute $intf/ipv4 -ip} intf_gateway]} {
                                                if {$intf_gateway == [lindex $gateway $option_index]} {
                                                    set gateway_flag 1
                                                    set connected_via_intf $intf
                                                    break
                                                }
                                            }
                                        } elseif {$ip_version == 6} {
                                            if {![catch {ixNet getAttribute $intf/ipv6:1 -ip} intf_gateway]} {
                                                if {[::ipv6::expandAddress $intf_gateway] == [::ipv6::expandAddress [lindex $ipv6_gateway $option_index]]} {
                                                    set gateway_flag 1
                                                    set connected_via_intf $intf
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                                if {$gateway_flag} {
                                    if {[regexp {^(::ixNet::OBJ-)(/vport:([0-9]+)/interface:([0-9]+))} $connected_via_intf -> obj intf_match]} {
                                        ixNet setAttr [lindex $interface_handle $option_index]/unconnected -connectedVia $intf_match
                                    }
                                } else {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName : the gateway for [lindex $interface_handle $option_index] is not valid."
                                    return $returnList
                                }
                            }
                        }
                    }
                }
                # Create or Modify - GRE
                if {$intf_cfg_create || ($intf_cfg_modify && ($interface_handle_type == "gre")) } {
                    # Skip ahead if no GRE interface can be added
                    if {[lsearch $gre_able_index_list $option_index] == -1} {
                        # Create
                        if {$intf_cfg_create} {
                            if {[info exists gre_count]} {
                                if {[lindex $gre_count $option_index] != {}} {
                                    append ixnetwork_interface_options " -gre_count \
                                            [lindex $gre_count $option_index]"
                                } elseif {[llength $gre_count] == 1} {
                                    append ixnetwork_interface_options " -gre_count \
                                            $gre_count"
                                }
                            }
                        }
                        
                        # Create and Modify (only if interface type is GRE)

                        if {[info exists gre_enable]} {
                            set ixnetwork_gre_options {
                                gre_ipv4_address                            gre_ip_addr             {create modify}
                                gre_ipv4_address_step                       gre_ip_addr_step        create
                                gre_ipv4_prefix_length                      gre_ip_prefix_length    {create modify}
                                gre_ipv6_address                            gre_ipv6_addr           {create modify}
                                gre_ipv6_address_step                       gre_ipv6_addr_step      create
                                gre_ipv6_prefix_length                      gre_ipv6_prefix_length  {create modify}
                                gre_dst_ip_address                          gre_dst_ip_addr         {create modify}
                                gre_dst_ip_address_outside_connected_step   gre_dst_ip_addr_step    create
                                gre_src_objref                              gre_src_objref          {create modify}
                                gre_checksum_enable                         gre_checksum_enable     {create modify}
                                gre_seq_enable                              gre_seq_enable          {create modify}
                                gre_key_enable                              gre_key_enable          {create modify}
                                gre_key_in                                  gre_key_in              {create modify}
                                gre_key_out                                 gre_key_out             {create modify}
                            }
                            foreach {hlt_opt var_name valid_mode} $ixnetwork_gre_options {
                                if {[info exists $var_name]} {
                                    if {[lindex [set $var_name] $option_index] != {}} {
                                        if {[lsearch $valid_mode create] != -1} {
                                            append ixnetwork_interface_options " -$hlt_opt \
                                                    [lindex [set $var_name] $option_index]"
                                        }
                                        if {[lsearch $valid_mode modify] != -1} {
                                            append ixnetwork_interface_options_modify   " -$hlt_opt \
                                                    [lindex [set $var_name] $option_index]"
                                        }
                                    } elseif {[llength [set $var_name]] == 1} {
                                        
                                        if {[lsearch $valid_mode create] != -1} {
                                            append ixnetwork_interface_options " -$hlt_opt \
                                                    [set $var_name]"
                                        }
                                        
                                        if {[lsearch $valid_mode modify] != -1} {
                                            append ixnetwork_interface_options_modify   " -$hlt_opt \
                                                    [set $var_name]"
                                        }
                                    }
                                }
                            }
                            if {[info exists interface_handle]} {
                                if {[lindex $interface_handle $option_index] != {}} {
                                    append ixnetwork_interface_options_modify " -prot_intf_objref [lindex $interface_handle $option_index]"
                                } elseif {([llength $interface_handle] == 1) && ($interface_handle != {})} {
                                    append ixnetwork_interface_options_modify " -prot_intf_objref $interface_handle"
                                }
                            }
                            if {[info exists gre_dst_ip_addr]} {
                                if {[lindex $gre_dst_ip_addr $option_index] != {}} {
                                    if {[isIpAddressValid [lindex $gre_dst_ip_addr $option_index] ]} {
                                        append ixnetwork_interface_options " \
                                                -gre_dst_ip_address_reset                 1       \
                                                -gre_dst_ip_address_step                  0.0.0.0 \
                                                -gre_dst_ip_address_outside_loopback_step 0.0.0.0 "
                                    } else {
                                        append ixnetwork_interface_options " \
                                                -gre_dst_ip_address_reset                 1       \
                                                -gre_dst_ip_address_step                  0000:0000:0000:0000:0000:0000:0000:0000 \
                                                -gre_dst_ip_address_outside_loopback_step 0000:0000:0000:0000:0000:0000:0000:0000 "
                                    }
                                }
                            }
                        }
                    }
                }
                
                if {$intf_cfg_create} {
                    # Create only
                    if {!([info exists intf_ip_addr] || [info exists ipv6_intf_addr] || [info exists src_mac_addr])} {
                        continue
                    }
                    
                    # If the ports are used for CPF, throw error. 
                    # A single port cannot contain both CPF and legacy configuration
                    # This validation is inserted here because ixiangpf calls 
                    # the ixia namespacefor configuring L1 parameters.
                    set global_topology_vports [ixNet getAttribute /globals/topology -vports]
                    foreach port_handle_item $port_handle {
                        foreach cpf_port $global_topology_vports {   
                            if {[info exists ixnetwork_port_handles_array($port_handle_item)] &&\
                                    ($::ixia::ixnetwork_port_handles_array($port_handle_item) == $cpf_port)} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to configure port $port_handle_item because\
                                        it already contains NGPF configuration."
                                return $returnList
                            }
                        }
                    }
        
                    # Create
                    set interface_status [eval ixNetworkProtocolIntfCfg \
                            $ixnetwork_interface_options]
                    if {[keylget interface_status status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log [keylget interface_status log]
                        return $returnList
                    }
                    set connected_interfaces [keylget interface_status connected_interfaces]
                    
                    if {[info exists interface_status] && \
                            [keylget interface_status status] == $::SUCCESS} {
                        if {[llength $connected_intf_list] > 0} {
                            append connected_intf_list \
                                    " [keylget interface_status connected_interfaces]"
                        } else {
                            append connected_intf_list \
                                    "[keylget interface_status connected_interfaces]"
                        }
                        if {[keylget interface_status routed_interfaces] != ""} {
                            if {[llength $routed_intf_list] > 0} {
                                append routed_intf_list \
                                    " [keylget interface_status routed_interfaces]"
                            } else {
                                append routed_intf_list \
                                    "[keylget interface_status routed_interfaces]"
                            }
                        }
                        if {[keylget interface_status gre_interfaces] != ""} {
                            if {[llength $gre_intf_list] > 0} {
                                append gre_intf_list \
                                        " [keylget interface_status gre_interfaces]"
                            } else {
                                append gre_intf_list \
                                        "[keylget interface_status gre_interfaces]"
                            }
                        }
                    }
                } else {
                    # Modify only
                    # Modify Connected or Routed
                    if {$interface_handle_type == "connected" || $interface_handle_type == "routed"} {
                        append ixnetwork_interface_options_modify " -intf_mode modify"
                        set interface_status [eval ixNetworkConnectedIntfCfg \
                                $ixnetwork_interface_options_modify]
                        if {[keylget interface_status status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log [keylget interface_status log]
                            return $returnList
                        }
                        if {$interface_handle_type == "connected"} {
                            if {[llength $connected_intf_list] > 0} {
                                append connected_intf_list " [keylget interface_status interface_handle]"
                            } else {
                                append connected_intf_list "[keylget interface_status interface_handle]"
                            }
                        }
                        if {$interface_handle_type == "routed"} {
                            if {[llength $routed_intf_list] > 0} {
                                append routed_intf_list    " [keylget interface_status interface_handle]"
                            } else {
                                append routed_intf_list    "[keylget interface_status interface_handle]"
                            }
                        }
                    }
                    # Modify GRE
                    if {$interface_handle_type == "gre"} {
                        set interface_status [eval ixNetworkGreIntfCfg \
                                $ixnetwork_interface_options_modify]
                        if {[keylget interface_status status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log [keylget interface_status log]
                            return $returnList
                        }
                        if {[llength $gre_intf_list] > 0} {
                            append gre_intf_list    " [keylget interface_status interface_handle]"
                        } else {
                            append gre_intf_list    "[keylget interface_status interface_handle]"
                        }
                    }
                    
                }
                
                # Commit changes made, if mode is modify
                if {$mode_index == "modify"} {
                    if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to add IP endpoint port\
                                $port_handle ($procName). $retCode."
                        return $returnList
                    }
                }
            } elseif {$l23_config_type == "static_endpoint"} {
                if {[info exists intf_ip_addr] || [info exists ipv6_intf_addr] || [info exists src_mac_addr]} {
                    set result [ixNetworkGetPortObjref $chassis/$card/$port]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not find any vport which uses the\
                                $port_handle port - [keylget result log]."
                        return $returnList
                    }
                    set port_objref [keylget result vport_objref]
                    set intf_type [ixNet getAttribute $port_objref -type]
                    if {[lindex $intf_type $option_index] == "atm"} {
                        set type "atm"
                    } else {
                        set type "ethernet"
                    }
                    
                    if {$type == "ethernet"} {
                        # Determine if we're creating an ip endpoint or an ethernet endpoint
                        set common_ip_range_params {
                            intf_ip_addr
                            intf_ip_addr_step
                            netmask
                            ipv6_intf_addr
                            ipv6_intf_addr_step
                            ipv6_prefix_length
                            gateway
                            gateway_step
                            ipv6_gateway
                            ipv6_gateway_step
                            gateway_incr_mode
                        }
                        
                        set endpoint_type ethernetEndpoint
                        foreach ip_range_param $common_ip_range_params {
                            if {[info exists $ip_range_param] &&\
                                    ![info exists defaults_array($ip_range_param)] &&\
                                    ![is_default_param_value $ip_range_param $args]} {
                                set endpoint_type "ipEndpoint"
                                break
                            }
                        }
                        
                    } else {
                        # Can't create ethernet endpoint on non-ethernet ports
                        # Assuming user wants an ip static endpoint
                        set endpoint_type "ipEndpoint"
                    }
                    
                    if {$endpoint_type == "ipEndpoint"} {
                        set result [ixNetworkGetSMPlugin $port_objref $type $endpoint_type]
                        if {[keylget result status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName : [keylget result log]"
                            return $returnList
                        }
                    } else {
                        # ethernetEndpoint is at the same level with atm and ethernet
                        set result [ixNetworkGetSMPlugin $port_objref $endpoint_type "none"]
                        if {[keylget result status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName : [keylget result log]"
                            return $returnList
                        }
                    }
                    set endpoint_objref [keylget result ret_val]
                    
                    set range_objref [ixNet add $endpoint_objref range]
                    
                    
                    if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to add range object over IP endpoint port\
                                $port_handle ($procName). $retCode."
                        return $returnList
                    }
                    set range_objref [ixNet remapIds $range_objref]
                    
                    array set ipv6_addr_mode_translate \
                    {
                        static      static
                        autoconfig  autoconf
                    }
                    if {[info exists ipv6_addr_mode]} \
                    {
                        set result [ixNetworkGetPortObjref $chassis/$card/$port]
                        if {[keylget result status] == $::FAILURE} \
                        {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Could not find any vport which uses the\
                                    $port_handle port - [keylget result log]."
                            return $returnList
                        }
                        set port_objref [keylget result vport_objref]

                        set ip_range_opts_objref "$port_objref/protocolStack/ipRangeOptions:1"
                        if {[ixNet exists $ip_range_opts_objref]} \
                        {
                            ixNetworkSetAttr $ip_range_opts_objref -ipv6AddressMode $ipv6_addr_mode_translate($ipv6_addr_mode)
                            ixNetworkCommit
                        }
                    }
                    
                    # Atm mac range
                    set ixnetwork_atm_mac_range_options ""
                    set ixnetwork_atm_mac_range_params {
                        connected_count
                        src_mac_addr
                        src_mac_addr_step
                        mtu
                        atm_encapsulation
                    }
                    
                    foreach {hlt_arg} $ixnetwork_atm_mac_range_params {
                        if {[info exists $hlt_arg] && ([lindex [set $hlt_arg] $option_index] != {})} {
                            append ixnetwork_atm_mac_range_options " -$hlt_arg \
                                    [lindex [set $hlt_arg] $option_index]"
                        }
                    }
                    if {$ixnetwork_atm_mac_range_options != ""} {
                        append ixnetwork_atm_mac_range_options " -range_objref $range_objref"
                    }
                    set retCode [eval "ixNetworkStaticEndpointAtmMacRangeCfg $ixnetwork_atm_mac_range_options"]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log [keylget retCode log]
                        return $returnList
                    }
                    
                    # Vlan range
                    set ixnetwork_vlan_range_options ""
                    set ixnetwork_vlan_range_params {
                        vlan
                        vlan_id
                        vlan_id_step
                        vlan_id_count
                        vlan_user_priority
                        qinq_incr_mode
                        addresses_per_vlan
                        addresses_per_svlan
                        vlan_tpid
                    }
                    if {$type == "ethernet"} {
                        foreach {hlt_arg} $ixnetwork_vlan_range_params {
                            if {[info exists $hlt_arg] && ([lindex [set $hlt_arg] $option_index] != {})} {
                                append ixnetwork_vlan_range_options " -$hlt_arg \
                                        [lindex [set $hlt_arg] $option_index]"
                            }
                        }
                        if {$ixnetwork_vlan_range_options != ""} {
                            append ixnetwork_vlan_range_options " -range_objref $range_objref"
                        }
                        debug "ixNetworkStaticEndpointVlanRangeCfg $ixnetwork_vlan_range_options"
                        set retCode [eval "ixNetworkStaticEndpointVlanRangeCfg $ixnetwork_vlan_range_options"]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log [keylget retCode log]
                            return $returnList
                        }
                    }
                    
                    if {$endpoint_type == "ipEndpoint"} {
                        # PVC range
                        set ixnetwork_pvc_range_options ""
                        set ixnetwork_pvc_range_params {
                            vci
                            vci_count
                            vci_step
                            addresses_per_vci
                            vpi
                            vpi_count
                            vpi_step
                            addresses_per_vpi
                            pvc_incr_mode
                        }
                        if {$type == "atm"} {
                            foreach {hlt_arg} $ixnetwork_pvc_range_params {
                                if {[info exists $hlt_arg] && ([lindex [set $hlt_arg] $option_index] != {})} {
                                    append ixnetwork_pvc_range_options " -$hlt_arg \
                                            [lindex [set $hlt_arg] $option_index]"
                                }
                            }
                            if {$ixnetwork_pvc_range_options != ""} {
                                append ixnetwork_pvc_range_options " -range_objref $range_objref"
                            }
                            set retCode [eval "ixNetworkStaticEndpointPvcRangeCfg $ixnetwork_pvc_range_options"]
                            if {[keylget retCode status] != $::SUCCESS} {
                                keylset returnList status $::FAILURE
                                keylset returnList log [keylget retCode log]
                                return $returnList
                            }
                        }
                    
                    
                        # IP range
                        set ixnetwork_ip_range_options ""
                        set ixnetwork_ip_range_params {
                            connected_count
                            intf_ip_addr
                            intf_ip_addr_step
                            netmask
                            ipv6_intf_addr
                            ipv6_intf_addr_step
                            ipv6_prefix_length
                            gateway
                            gateway_step
                            ipv6_gateway
                            ipv6_gateway_step
                            gateway_incr_mode
                            mss
                            src_mac_addr
                        }
                        foreach {hlt_arg} $ixnetwork_ip_range_params {
                            if {[info exists $hlt_arg] && ([lindex [set $hlt_arg] $option_index] != {})} {
                                append ixnetwork_ip_range_options " -$hlt_arg \
                                        [lindex [set $hlt_arg] $option_index]"
                            }
                        }
                        if {$ixnetwork_ip_range_options != ""} {
                            append ixnetwork_ip_range_options " -range_objref $range_objref"
                        }
                        set retCode [eval "ixNetworkStaticEndpointIpRangeCfg $ixnetwork_ip_range_options"]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log [keylget retCode log]
                            return $returnList
                        }
                        if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to add IP endpoint port\
                                    $chassis/$card/$port ($procName). $retCode."
                            return $returnList
                        }
                    }
                    lappend connected_intf_list $range_objref
                }
            }
            incr option_index
            lappend unique_intf_list $interface
            set unique_intf_list [lsort -unique $unique_intf_list]
        }
        
        if {[info exists commit_needed] && $commit_needed == 1} {
            if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure Rate Control Parameters."
                return $returnList
            }
        }
        
        if {[info exists arp_send_req] && ([eval "expr \[join {$arp_send_req} \" || \"\]"] == 1)} {
            # select the interfaces for the arp send request
            set arp_send_req_list    [list ]
            array set ipv4_failed_arp [list]
            if {[llength $arp_send_req] == 1} {
                foreach {intf} $intf_list {
                    if {[lsearch $arp_send_req_list $intf] == -1} {
                        lappend arp_send_req_list $intf
                    }
                }
            } else  {
                foreach {arp_item} $arp_send_req intf $intf_list {
                    if {$arp_item == 1} {
                        if {[lsearch $arp_send_req_list $intf] == -1} {
                            lappend arp_send_req_list $intf
                        }
                    }
                }
            }
            if {![info exists arp_req_retries]} {
                set arp_req_retries  2
            } else  {
                set arp_req_retries [lindex $arp_req_retries 0]
            }
            
            set portList [list]
            # Extract the version of the IxNetwork
            # if it fails, the version variable will not be set
            regexp {^(\d+.\d+)(P|N|NO|P2NO)?$} $::ixia::ixnetworkVersion {} version product]
            
            foreach arp_send_req_intf $arp_send_req_list {
                set tmpArpPrt [::ixia::ixNetworkGetPortObjref \
                        [regsub -all { } $arp_send_req_intf /]]
                set tmpArpPrt [keylget tmpArpPrt vport_objref]
                debug "ixNet getAttribute $tmpArpPrt -state"
                if {[ixNet getAttribute $tmpArpPrt -state] == "up"} {
                    if {[info exists version] && $version >= 6.30} {
                        lappend portList $tmpArpPrt;
                    }
                    #---> SEND ARP REQUEST
                    for {set iter 1} {$iter <= $arp_req_retries} {incr iter} {
                        foreach tmpArpIntf [ixNet getList $tmpArpPrt interface] {
                            if {[info exists version] && $version >= 6.30} {
                                #lappend portList $tmpArpIntf
                            } else {
                                debug "ixNet exec sendArp $tmpArpIntf"
                                ixNet exec sendArp $tmpArpIntf
                            }
                        }
                    }
                }
            }
            
            # If version IxNetwork version is greater than 6.20 and there are ports
            # which are up, we can send arp
            if {[info exists version] && $version >= 6.30 && [llength $portList] > 0} {
                debug "ixNet sendArpAll $portList"
                set commit_needed 0
                foreach tmpPort $portList {
                    set rateControlParams "$tmpPort/rateControlParameters"
                    if {[ixNet exists $rateControlParams]} {
                        ixNet setAttribute $rateControlParams -retryCount $arp_req_retries
                        set commit_needed 1
                    }
                }
                if {$commit_needed} {
                    set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    catch {unset commit_needed}
                }
                ixNet exec sendArpAll $portList
            }
            
            foreach spaced_port $arp_send_req_list {
                set slashed_port [join $spaced_port /]
                set port [::ixia::ixNetworkGetPortObjref $slashed_port]
                    if {[keylget port status] != $::SUCCESS} {
                        keylset port log "ERROR in $procName: [keylget port log]"
                        return $port
                    }
                set port [keylget port vport_objref]
                catch {unset ipv4_failed_arp($slashed_port)}
                set neighbor_list [ixNet getList $port discoveredNeighbor]
                set retry_count [expr $arp_req_retries + 1]
                foreach neighbor $neighbor_list {
                    for { set read_count 1} {$read_count <= $retry_count} {incr read_count} {
                        set neighbor_mac [ixNet getAttribute $neighbor -neighborMac]
                        if { $neighbor_mac != "00:00:00:00:00:00"} {
                            break
                        }
                        after 1000
                    }
                    if { $neighbor_mac == "00:00:00:00:00:00"} {
                            continue
                    }
                    
                    if {![catch {ixNet getAttribute $neighbor -neighborIp} nIp]} {
                        set neighbor_array($nIp) "$neighbor_mac"
                    }
                }
                set interface_list [ixNet getList $port interface]
                foreach interface $interface_list {
                    set all_good 0
                    if {[llength [ixNet getList $interface ipv4]]>0} {
                        set int_gateway_ipv4 [ixNet getAttribute $interface/ipv4 -gateway]
                        if {[info exists neighbor_array($int_gateway_ipv4)]} {
                            set all_good 1
                        }
                    }
                    if {$all_good ==0} {
                        lappend ipv4_failed_arp($slashed_port) "$interface"
                    }
                }
            }
            if {$arp_req_retries > 0} {
                foreach spaced_port $arp_send_req_list {
                    set arp_port [join $spaced_port /]
                    if {[info exists ipv4_failed_arp($arp_port)]} {
                        keylset returnList ${arp_port}.arp_ipv4_interfaces_failed \
                                $ipv4_failed_arp($arp_port)
                        keylset returnList ${arp_port}.arp_request_success $::FAILURE
                    } else {
                        keylset returnList ${arp_port}.arp_request_success $::SUCCESS
                    }
                }
            }
        }
        if {[info exists send_router_solicitation] && \
            ([eval "expr \[join {$send_router_solicitation} \" || \"\]"] == 1)} {
            array set ipv6_failed_arp [list]
            # select the interfaces for the "send router solicitation"
            set send_router_solicitation_list    [list ]
            if {[llength $send_router_solicitation] == 1} {
                foreach {intf} $intf_list {
                    if {[lsearch $send_router_solicitation_list $intf] == -1} {
                        lappend send_router_solicitation_list $intf
                    }
                }
            } else  {
                foreach {arp_item} $send_router_solicitation intf $intf_list {
                    if {$arp_item == 1} {
                        if {[lsearch $send_router_solicitation_list $intf] == -1} {
                            lappend send_router_solicitation_list $intf
                        }
                    }
                }
            }
            if {![info exists router_solicitation_retries]} {
                set router_solicitation_retries  2
            } else  {
                set router_solicitation_retries [lindex $router_solicitation_retries 0]
            }
            for {set i 0} {$i < $router_solicitation_retries} {incr i} {
                foreach arp_send_req_intf $send_router_solicitation_list {
                    set tmpArpPrt [::ixia::ixNetworkGetPortObjref \
                            [regsub -all { } $arp_send_req_intf /]]
                    set tmpArpPrt [keylget tmpArpPrt vport_objref]
                    debug "ixNet getAttribute $tmpArpPrt -state"
                    if {[ixNet getAttribute $tmpArpPrt -state] == "up"} {
                        #---> SEND ROUTER SOLICITATION
                        foreach tmpArpIntf [ixNet getList $tmpArpPrt interface] {
                            debug "ixNet exec sendNs $tmpArpIntf"
                            ixNet exec sendNs $tmpArpIntf
                            debug "ixNet exec sendRs $tmpArpIntf"
                            ixNet exec sendRs $tmpArpIntf
                        }
                        
                    }
                }
                set router_solicitation_failed 0
                foreach spaced_port $send_router_solicitation_list {
                    set slashed_port [join $spaced_port /]
                    set port [::ixia::ixNetworkGetPortObjref $slashed_port]
                        if {[keylget port status] != $::SUCCESS} {
                            keylset port log "ERROR in $procName: [keylget port log]"
                            return $port
                        }
                    set port [keylget port vport_objref]
                    catch {unset ipv6_failed_arp($slashed_port)}
                    set neighbor_list [ixNet getList $port discoveredNeighbor]
                    foreach neighbor $neighbor_list {
                        set neighbor_mac [ixNet getAttribute $neighbor -neighborMac]
                        if { $neighbor_mac == "00:00:00:00:00:00"} {
                                continue
                        }
                        if {![catch {ixNet getAttribute $neighbor -neighborIp} nIp]} {
                            set neighbor_array($nIp) "$neighbor_mac"
                        }
                    }
                    set interface_list [ixNet getList $port interface]
                    foreach interface $interface_list {
                        set all_good 0
                        if {[llength [ixNet getList $interface ipv6]]>0} {
                            set ipv6_interface_list [ixNet getList $interface ipv6]
                            foreach interface_ipv6 $ipv6_interface_list {
                                set int_gateway_ipv6 [ixNet getAttribute $interface_ipv6 -gateway]
                                if {[info exists neighbor_array($int_gateway_ipv6)]} {
                                    set all_good 1
                                }
                            }
                        }
                        if {$all_good ==0} {
                            lappend ipv6_failed_arp($slashed_port) "$interface"
                            set router_solicitation_failed 1
                        }
                    }
                }
                if {$router_solicitation_failed == 0} {
                    break
                }
                after 1000
            }
            if {$router_solicitation_retries > 0} {
                foreach spaced_port $send_router_solicitation_list {
                    set arp_port [join $spaced_port /]
                    if {[info exists ipv6_failed_arp($arp_port)]} {
                        keylset returnList ${arp_port}.arp_ipv6_interfaces_failed \
                                $ipv6_failed_arp($arp_port)
                        keylset returnList ${arp_port}.router_solicitation_success $::FAILURE
                    } else {
                        keylset returnList ${arp_port}.router_solicitation_success $::SUCCESS
                    }
                }
            }
        }
        
        if {[llength $connected_intf_list] > 1} {
            # if connected_intf_list contains multiple interfaces
            keylset returnList interface_handle $connected_intf_list
        } elseif {[llength $connected_intf_list] > 0} {
            # if connected_intf_list contains a single interface (due to BUG718466)
            keylset returnList interface_handle [lindex $connected_intf_list 0]
        }
        if {[llength $routed_intf_list] > 0} {
            keylset returnList routed_interface_handle $routed_intf_list
        }
        if {[llength $gre_intf_list] > 0} {
            keylset returnList gre_interface_handle $gre_intf_list
        }
        
        foreach endpoint_key $protocols_static_endpoint_keys {
            if {[llength [set $endpoint_key]] > 0} {
                keylset returnList $endpoint_key [set $endpoint_key]
            }
        }
        
        if {[info exists all_protocols_static_endpoints] && [llength $all_protocols_static_endpoints] > 0} {
            keylset returnList interface_handle $all_protocols_static_endpoints
        }
        
        keylset returnList status $::SUCCESS
    } else {
        if {[info exists autonegotiation] && $autonegotiation == 1 && ![info exist speed]} {
            set speed auto
        }
        # ixOs variables
        # Because qos_stats is enabled by default ...
        if {(![info exists qos_stats] || $qos_stats == 1) &&\
                ![info exists qos_packet_type]} {
            set qos_packet_type "not_specified"
        }
    
        if {[info exists mode] && ($mode == "modify")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error: The -mode option modify is not\
                    currently supported."
            return $returnList
        }
    
        set option_list [list intf_mode mode speed phy_mode clocksource op_mode \
                framing rx_fcs tx_fcs rx_scrambling tx_scrambling rx_c2         \
                tx_c2 duplex autonegotiation vlan src_mac_addr intf_ip_addr     \
                ipv6_intf_addr netmask ipv6_prefix_length gateway               \
                arp_req_timer arp_send_req atm_encapsulation atm_enable_coset   \
                atm_enable_pattern_matching atm_filler_cell atm_interface_type  \
                atm_packet_decode_mode atm_reassembly_timeout data_integrity    \
                pgid_128k_bin_enable pgid_mask pgid_offset port_rx_mode         \
                ppp_ipv4_address ppp_ipv4_negotiation ppp_ipv6_negotiation      \
                ppp_mpls_negotiation ppp_osi_negotiation qos_stats              \
                qos_byte_offset qos_pattern_offset qos_pattern_match            \
                qos_pattern_mask qos_packet_type internal_ppm_adjust            \
                intrinsic_latency_adjustment tx_rx_sync_stats_enable            \
                tx_rx_sync_stats_interval                                       \
                sequence_checking sequence_num_offset transmit_clock_source     \
                signature signature_mask signature_offset signature_start_offset\
                transmit_mode vlan_id vlan_user_priority vlan_tpid              \
                vpi vci gre_checksum_enable gre_dst_ip_addr gre_ip_addr         \
                gre_ip_prefix_length gre_ipv6_addr gre_ipv6_prefix_length       \
                gre_key_enable gre_key_in gre_key_out gre_seq_enable pgid_mode  \
                pgid_split_offset pgid_split_width pgid_split_mask ignore_link  \
                ipv6_gateway tx_lanes pcs_period pcs_count pcs_repeat           \
                pcs_period_type pcs_lane pcs_enabled_continuous pcs_sync_bits   \
                pcs_marker_fields bert_configuration bert_error_insertion            ]
    
        set intf_option_list [list \
                vlan vlan_id vlan_user_priority vlan_tpid\
                atm_encapsulation vpi vci mtu   ]
    
        set qosOptionsList [list               \
                ethernet        ::ipEthernetII \
                ip_snap         ::ip8023Snap   \
                vlan            ::vlan         \
                custom          ::custom       \
                ip_ppp          ::ipPpp        \
                ip_cisco_hdlc   ::ipCiscoHdlc  \
                ip_atm          ::ipAtm        \
                ]
        array set processed_frequency_deviation ""
        array set processed_clock_select ""
        array set qosEnumList [list ]
    
        foreach {option value_name} $qosOptionsList {
            if {[info exists $value_name]} {
                set qosEnumList($option) [set $value_name]
            }
        }
    
        # Array used to set default qos packet type based on intf_mode value
        array set QoSpacketTypeIntfModeArray {
            atm                     ip_atm
            pos_hdlc                ip_cisco_hdlc
            pos_ppp                 ip_ppp
            ethernet                ethernet
            frame_relay1490         ip_ppp
            frame_relay2427         ip_ppp
            frame_relay_cisco       ip_ppp
            srp                     ip_ppp
            srp_cisco               ip_ppp
            gfp                     custom
            rpr                     ip_ppp
            bert                    bert
        }
    
        set intf_list [format_space_port_list $port_handle]
        
        set option_index     0
        set already_destroyed ""
        set destroy_done      0
        foreach interface $intf_list {
            
            if {[lsearch $already_destroyed $interface] != -1} {
                incr option_index
                continue
            } else {
                lappend already_destroyed $interface
            }
            
            if {[info exists mode] && ($mode == "destroy" ||\
                    [lindex $mode $option_index] == "destroy")} {

                scan $interface "%d %d %d" chassis card port

                if {[interfaceTable select $chassis $card $port]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error: Selecting interfaceTable\
                            on port $chassis $card $port"
                    return $returnList
                }
                if {[interfaceTable clearAllInterfaces]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error in $procName: interfaceTable\
                            clearAllInterfaces on port $chassis $card $port"
                    return $returnList
                }
    
                set retCode [rfremove_all_interfaces_from_port "${chassis}/${card}/${port}"]
                if {[keylget retCode status] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error: Deleting interface\
                            $intf_desc. [keylget retCode log]"
                    return $returnList
                }
                
                ::ixia::addPortToWrite $intf_list ports
                
                set destroy_done      1
            }
            incr option_index
            #keylset returnList status $::SUCCESS
            #return $returnList
        }
        
        if {![info exists no_write] && $destroy_done} {
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        ::ixia::writePortListConfig failed. \
                        [keylget retCode log]"
                return $returnList
            }
        }
        
        catch {unset already_destroyed}
        
        set option_index     0
        set unique_intf_list ""
        set gre_interface_handle_list [list]
        foreach interface $intf_list {
            scan $interface "%d %d %d" chassis card port
            
            if {$do_set_default == 0} {
                break
            }
            
            ###########
            #  FLAGS  #
            ###########
            set ppp_flag            0
            set sonet_flag          0
            set pgid_flag           0
            set atm_flag            0
            set protocol_flag       0
            set auto_detect_rx_flag 0
            set qos_flag            0
            set statConfigMode      ""
    
            if {[port get $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Cannot retrieve\
                        configured settings for port $chassis/$card/$port.\
                        Please check that the port number is correct or\
                        the port is not damaged in any way.\
                        \n$::ixErrorInfo.\n$::errorInfo"
                return $returnList
            }
    
            stat            setDefault
            packetGroup     setDefault
            sonet           setDefault
            ppp             setDefault
            atmPort         setDefault
    
            # Not sure if replacing protocolServer  setDefault with
            # protocolServer  get $chassis $card $port affects other
            # configurations
            protocolServer  get $chassis $card $port
    
            set auto_detect_rx [port isValidFeature $chassis $card $port \
                    portFeatureAutoDetectRx]
    
            
            set portModeConfiguredInitial [port cget -portMode]
            
            array set portModeConfiguredMap {
                0 pos
                1 ethernet
                2 usb
                4 ethernet
                5 bert
                7 atm
                8 pos
            }
            set portModeConfigured $portModeConfiguredMap($portModeConfiguredInitial)
             
            if {![info exists speed]} {
                switch -- $portModeConfiguredInitial {
                    0 -
                    5 -
                    7 -
                    2 {
                        
                       
                        # ::portPosMode or ::portBertMode or ::portAtmMode or ::portUsbMode
                        set tmpSpeed [lindex [lsort                \
                                -dictionary  [::ixia::portSupports \
                                $chassis $card $port pos]] end     ]
                        if {$tmpSpeed != 0} {
                            set speed ""
                            for {set i 0} {$i < [llength $port_handle]} {incr i} {
                                lappend speed $tmpSpeed
                            }
                            debug "speed = $speed"
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Unable to determine speed on port\
                                    $chassis/$card/$port."
                            return $returnList
                        }
                    }
                    1 {
                        set portModeConfigured ethernet
                        # ::portEthernetMode
                        set tmpSpeedEth [::ixia::portSupports $chassis $card    \
                                    $port ethernet]
                        
                        set tmpSpeedWan [::ixia::portSupports \
                                    $chassis $card $port wan]
                        
                        if {$tmpSpeedWan != 0} {
                            set speed ""
                            for {set i 0} {$i < [llength $port_handle]} {incr i} {
                                lappend speed "ether10000wan"
                            }
                        } elseif {$tmpSpeedEth != 0} {
                            set speed ""
                            set tmpSpeed ether
                            append tmpSpeed [lindex [lsort -dictionary $tmpSpeedEth]\
                                    end]
                            
                            for {set i 0} {$i < [llength $port_handle]} {incr i} {
                                lappend speed $tmpSpeed
                            }
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Unable to determine speed on port\
                                    $chassis/$card/$port."
                            return $returnList
                        }
                    }
                    4 {
                        set portModeConfigured ethernet
                        set tmpSpeedLan [::ixia::portSupports \
                                    $chassis $card $port lan]
                        # $::port10GigLanMode
                        if {$tmpSpeedLan != 0} {
                            set speed ""
                            for {set i 0} {$i < [llength $port_handle]} {incr i} {
                                lappend speed "ether10000lan"
                            }
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Unable to determine speed on port\
                                    $chassis/$card/$port."
                            return $returnList
                        }
                    }
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Unable to determine speed on port\
                                $chassis/$card/$port does not."
                        return $returnList
                    }
                }
            }
    
            if {![info exists duplex]} {
                set duplex_value [port cget -duplex]
                if {$duplex_value} {
                    set duplex_value full
                } else {
                    set duplex_value half
                }

                for {set i 0} {$i < [llength $port_handle]} {incr i} {
                    lappend duplex $duplex_value
                }
            }
    
            # set up a unique default mac if not specified
            if {![info exists src_mac_addr_default]} {
                set src_mac_addr_default 0
            }
            if {![info exists src_mac_addr]} {
                set retCode [::ixia::get_next_mac_address]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget retCode log]
                    return $returnList
                }
                set _mac_address [keylget retCode mac_address]
                regsub -all " " $_mac_address ":" _mac_address
                lappend src_mac_addr $_mac_address
                set src_mac_addr_default 1
            } elseif {[info exists src_mac_addr] && \
                        ([llength $src_mac_addr] < [llength $intf_list])} {
                set temp_mac_addr [lindex $src_mac_addr end]
                set temp_mac_addr [::ixia::incrementMacAdd $temp_mac_addr]
                regsub -all {([0-9a-zA-Z]+) ([0-9a-zA-Z]+)} $temp_mac_addr \
                        {\1\2} temp_mac_addr
                regsub -all { } $temp_mac_addr {.} temp_mac_addr
                lappend src_mac_addr $temp_mac_addr
            }
    
            # SET PORT TYPE
            set port_type [get_port_type $chassis $card $port]
    
            # default signature
            packetGroup config -signature {DE AD BE EF}
    
            # Pre find out if there is IPv4 or IPv6 involved and mark flags
            set ipv4_interface 0
            set ipv6_interface 0
            foreach single_option_list $option_list {
                if {[info exists $single_option_list]} {
                    eval set single_option_list_eval $$single_option_list
                    set single_option [lindex $single_option_list_eval $option_index]
                    switch -- $single_option_list {
                        intf_ip_addr {
                            set ipv4_interface 1
                        }
                        ipv6_intf_addr {
                            set ipv6_interface 1
                        }
                        phy_mode {
                            # If there is a phy mode change, need to handle it first
                            if {$single_option == ""} {
                                set single_option [lindex $single_option_list_eval end]
                            }
                            if {$single_option == "copper"} {
                                port setPhyMode portPhyModeCopper $chassis $card \
                                        $port
                            } else {
                                port setPhyMode portPhyModeFiber $chassis $card $port
                            }
                        }
                        port_rx_mode {
                            if {[llength $intf_list] == 1} {
                                set single_option $port_rx_mode
                            }
                            if {[lsearch -exact $single_option data_integrity] >= 0} {
                                set data_integrity 1
                            }
                            if {[lsearch -exact $single_option sequence_checking] >= 0} {
                                set sequence_checking 1
                            }
                        }
                    }
                }
            }
    
            set pgid_flag 1
            set portReceiveMode 0
            if {[llength $connected_count] <= $option_index} {
                set connected_count_temp      [lindex $connected_count end]
            } else {
                set connected_count_temp      [lindex $connected_count $option_index]
            }
            for {set connected_counter 0} {$connected_counter < $connected_count_temp} {incr connected_counter}  {
                array set intf_create_args [list ]
                set intf_create_params [list \
                        ipV4Address        intf_ip_addr       \
                        macAddress         src_mac_addr       \
                        ipV4Gateway        gateway            \
                        ipV4MaskWidth      netmask            \
                        ipV6Address        ipv6_intf_addr     \
                        ipV6MaskWidth      ipv6_prefix_length \
                        ipV6Gateway        ipv6_gateway       \
                        vlanId             vlan_id            \
                        vlanUserPriority   vlan_user_priority \
                        ]
        
                foreach {alias single_option_list} $intf_create_params {
                    if {[info exists $single_option_list]} {
                        eval set single_option_list_eval $$single_option_list
                        if {[llength $single_option_list_eval] == 1} {
                            set single_option $single_option_list_eval
                        } else {
                            set single_option \
                                    [lindex $single_option_list_eval $option_index]
                        }
                        
                        if {$single_option != ""} {
                            switch -- $single_option_list {
                                ipv6_gateway -
                                ipv6_intf_addr {
                                    set intf_create_args(${alias}) \
                                            [::ipv6::expandAddress  $single_option ]
                                }
                                netmask {
                                    set intf_create_args(${alias}) \
                                            [getIpV4MaskWidth  $single_option  ]
                                }
                                src_mac_addr {
                                    set intf_create_args(${alias}) \
                                            [convertToIxiaMac $single_option]
                                }
                                default {
                                    set intf_create_args(${alias}) \
                                            $single_option
                                }
                            }
                        }
                    } elseif {$single_option_list == "gateway"} {
                        set intf_create_args(ipV4Gateway) "0.0.0.0"
                    } elseif {$single_option_list == "ipv6_gateway"} {
                        set intf_create_args(ipV6Gateway) [::ipv6::expandAddress  0::0]
                    }
                }
        
                array set i_v [list 1 4 2 6]
                array set i_v_rev [list 1 6 2 4]
        
                for {set i 1} {$i <= [array size i_v]} {incr i} {
                    set create_intf   create_interface_ipv$i_v($i)
                    set $create_intf  -1
                    if {[info exists intf_create_args(ipV$i_v($i)Address)] && \
                            ![info exists intf_create_args(macAddress)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Please provide -src_mac_addr option for IP address\
                                $intf_create_args(ipV$i_v($i)Address)."
                        return $returnList
                    }
                    
                    debug "info exists intf_create_args(ipV$i_v($i)Address)"
                    debug [array get intf_create_args]
                    if {[info exists intf_create_args(ipV$i_v($i)Address)]} {
                        set option_intf_exists_list \
                                "-port_handle ${chassis}/${card}/${port}           \
                                -ip_version  $i_v($i)                              \
                                -ip_address  $intf_create_args(ipV$i_v($i)Address) \
                                -mac_address $intf_create_args(macAddress)"
        
                        if {[info exists intf_create_args(ipV$i_v($i)Gateway)]} {
                            append option_intf_exists_list " -gateway_address \
                                    $intf_create_args(ipV$i_v($i)Gateway)"
                        }
                        set results_ex [eval ::ixia::interface_exists \
                                $option_intf_exists_list]
                        
                        debug "--->mircea<---- ::ixia::interface_exists \
                                $option_intf_exists_list \n\treturned---> $results_ex"
                        
                        set $create_intf 0
                        set status [keylget results_ex status]
                        switch -- $status {
                            -1 {
                                # The call to interface exists failed, fail this too.
                                keylset returnList status $::FAILURE
                                keylset returnList log "Calling ::ixia::interface_exists \
                                        failed.  Log: [keylget results_ex log]"
                                return $returnList
                            }
                            0 {
                                set $create_intf 1
                            }
                            1 {
                                set interface_description$i_v($i) \
                                        [keylget results_ex description]
        
                                # Since the interface exists, need to search thru the list
                                # and find the handle to return
                                set desc [keylget results_ex description]
                                set name [rfget_interface_handle_by_description $desc]
                                if {[llength $name] > 0} {
                                    if {[catch {keylget returnList interface_handle} \
                                                intfHandlesList]} {
                                        set intfHandlesList ""
                                    }
                                    if {[lsearch $intfHandlesList $name] == -1} {
                                        lappend intfHandlesList $name
                                    }
                                    keylset returnList interface_handle $intfHandlesList
                                }
                                
                            }
                            2 {
                                set $create_intf 1
                                set interface_description$i_v_rev($i) \
                                        [keylget results_ex description]
        
                                # Since the interface exists, need to search thru the list
                                # and find the handle to return
                                set desc [keylget results_ex description]
                                set name [rfget_interface_handle_by_description $desc]
                                if {[llength $name] > 0} {
                                    if {[catch {keylget returnList interface_handle} \
                                                intfHandlesList]} {
                                        set intfHandlesList ""
                                    }
                                    if {[lsearch $intfHandlesList $name] == -1} {
                                        lappend intfHandlesList $name
                                    }
                                    keylset returnList interface_handle $intfHandlesList
                                }
                            }
                            3 {
                                # Found the mac address on another interface on this port.
                                # Fail this because to create would mean one of them would
                                # have to be disabled, confusing for the user.
                                keylset returnList status $::FAILURE
                                keylset returnList log "Creating the protocol interface\
                                        failed on port ${chassis}/${card}/${port}. \
                                        An interface with this MAC address\
                                        ($intf_create_args(macAddress)) was\
                                        found, but the IP address was different."
                                return $returnList
                            }
                        }
                    } elseif {[info exists intf_create_args(macAddress)] && !$src_mac_addr_default} {
                        set option_intf_exists_list \
                                "-port_handle ${chassis}/${card}/${port}           \
                                -ip_version  $i_v($i)                              \
                                -mac_address $intf_create_args(macAddress)"
                        
                        set results_ex [eval ::ixia::interface_exists \
                                $option_intf_exists_list]
                        
                        debug "--->mircea2<---- ::ixia::interface_exists \
                                $option_intf_exists_list \n\treturned---> $results_ex"
                                                
                        set $create_intf 0
                        set status [keylget results_ex status]
                        switch -- $status {
                            -1 {
                                # The call to interface exists failed, fail this too.
                                keylset returnList status $::FAILURE
                                keylset returnList log "Calling ::ixia::interface_exists \
                                        failed.  Log: [keylget results_ex log]"
                                return $returnList
                            }
                            0 {
                                set $create_intf 1
                            }
                            1 {
                                set interface_description$i_v($i) \
                                        [keylget results_ex description]
        
                                # Since the interface exists, need to search thru the list
                                # and find the handle to return
                                set desc [keylget results_ex description]
                                set name [rfget_interface_handle_by_description $desc]
                                if {[llength $name] > 0} {
                                    if {[catch {keylget returnList interface_handle} \
                                                intfHandlesList]} {
                                        set intfHandlesList ""
                                    }
                                    if {[lsearch $intfHandlesList $name] == -1} {
                                        lappend intfHandlesList $name
                                    }
                                    keylset returnList interface_handle $intfHandlesList
                                }
                            }
                            2 {
                                set $create_intf 1
                                set interface_description$i_v_rev($i) \
                                        [keylget results_ex description]
        
                                # Since the interface exists, need to search thru the list
                                # and find the handle to return
                                set desc [keylget results_ex description]
                                set name [rfget_interface_handle_by_description $desc]
                                if {[llength $name] > 0} {
                                    if {[catch {keylget returnList interface_handle} \
                                                intfHandlesList]} {
                                        set intfHandlesList ""
                                    }
                                    if {[lsearch $intfHandlesList $name] == -1} {
                                        lappend intfHandlesList $name
                                    }
                                    keylset returnList interface_handle $intfHandlesList
                                }
                            }
                            3 {
                                # Found the mac address on another interface on this port.
                                # Fail this because to create would mean one of them would
                                # have to be disabled, confusing for the user.
                                keylset returnList status $::FAILURE
                                keylset returnList log "Creating the protocol interface\
                                        failed on port ${chassis}/${card}/${port}. \
                                        An interface with this MAC address\
                                        ($intf_create_args(macAddress)) was\
                                        found, but the IP address was different."
                                return $returnList
                            }
                        }
                    }
                }
                if {[info exists interface_description4]} {
                    set interface_description $interface_description4
                }
                if {[info exists interface_description6]} {
                    set interface_description $interface_description6
                }
                if {[info exists interface_description]} {
                    if {[interfaceTable select $chassis $card $port]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to interfaceTable\
                                select $chassis $card $port."
                    }
        
                    set results [::ixia::get_interface_by_description \
                            $chassis $card $port $interface_description]
        
                    if {[keylget results status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure finding interface by\
                                description on port.  Log : [keylget results log]"
                        return $returnList
                    }
                    
                    debug "create_interface_ipv4 == $create_interface_ipv4"
                    debug "create_interface_ipv6 == $create_interface_ipv6"
                    
                    if {$create_interface_ipv4 == 1} {
                        set cget_version 6
                        if {![interfaceEntry getFirstItem  $::addressTypeIpV6]} {
                            set cget_mask    [interfaceIpV6 cget -maskWidth]
                            set cget_ip_addr [::ipv6::expandAddress \
                                    [interfaceIpV6 cget -ipAddress ]]
                            set cget_ipv6_gateway [::ipv6::expandAddress \
                                    [interfaceEntry cget -ipV6Gateway ]]
                        }
                    }
                    if {$create_interface_ipv6 == 1} {
                        set cget_version 4
                        if {![interfaceEntry getFirstItem  $::addressTypeIpV4]} {
                            set cget_gateway  [interfaceIpV4  cget -gatewayIpAddress]
                            set cget_mask     [interfaceIpV4  cget -maskWidth]
                            set cget_ip_addr  [interfaceIpV4  cget -ipAddress]
        
                        }
                    }
                    if {($create_interface_ipv4 == 1) || \
                                ($create_interface_ipv6 == 1)} {
        
                        if {[interfaceEntry cget -enableVlan ] == 1} {
                            if {![info exists vlan]} {
                                set vlan 1
                            }
                        }
                    }
                } elseif {($create_interface_ipv4 == 1) || \
                            ($create_interface_ipv6 == 1)} {
        
                    if {[interfaceTable select $chassis $card $port]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to interfaceTable\
                                select $chassis $card $port."
                    }
                    interfaceEntry clearAllItems addressTypeIpV6
                    interfaceEntry clearAllItems addressTypeIpV4
                    interfaceEntry  setDefault
                    interfaceEntry config -enable $::true
                }

                for {set i 1} {$i <= [array size i_v]} {incr i} {
                    set create_intf create_interface_ipv$i_v($i)
                    debug "set create_intf [set create_interface_ipv$i_v($i)]"
                    if {[set $create_intf] == 1 && [info exists intf_create_args(ipV$i_v($i)Address)]} {
                        interfaceIpV$i_v($i)  setDefault
                        interfaceIpV$i_v($i) config -ipAddress \
                                $intf_create_args(ipV$i_v($i)Address)
        
                        if {[info exists intf_create_args(ipV$i_v($i)MaskWidth)]} {
                            interfaceIpV$i_v($i) config -maskWidth \
                                    $intf_create_args(ipV$i_v($i)MaskWidth)
                        }
                        if {[info exists intf_create_args(ipV$i_v($i)Gateway)]} {
                            if {$i_v($i) == 4} {
                                interfaceIpV$i_v($i) config -gatewayIpAddress \
                                        $intf_create_args(ipV$i_v($i)Gateway)
                            } else {
                                # IPv6 Gateway
                                interfaceEntry config -ipV6Gateway $intf_create_args(ipV$i_v($i)Gateway)
                            }                            
                        }
                        debug "interfaceEntry addItem addressTypeIpV$i_v($i)"
                        if {[interfaceEntry addItem addressTypeIpV$i_v($i)]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failure on call to\
                                    interfaceEntry addItem addressTypeIpV$i_v($i)\
                                    on port $chassis $card $port."
                            return $returnList
                        }
                    }
                }
        
        
                # Set default value for rpr_hec_seed
                if {![info exists rpr_hec_seed]} {
                    set rpr_hec_seed 0
                }
        
                # If the port configurations have already been applied there is
                # no need to make them again
                set portCfgNotApplied [expr [lsearch $unique_intf_list $interface] == -1]
                if {$portCfgNotApplied} {
                    set pcfgCode [eval ::ixia::setPortConfig]
                    if {[keylget pcfgCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: [keylget pcfgCode log]"
                        return $returnList
                    }
                }
                setIntfConfig
                # Setup QoS config
                if {[info exists qos_stats] && $qos_flag && $portCfgNotApplied} {
                    if {[qos set $chassis $card $port] != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Cannot set qos\
                                on port: $chassis $card $port.\n$::ixErrorInfo"
                        return $returnList
                    }
                }
                # Set Auto Detect Instrumentation on the RX
                if {($auto_detect_rx_flag == 1) && $portCfgNotApplied} {
                    if {[autoDetectInstrumentation setRx $chassis $card $port] != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Cannot set RX\
                                Auto Detect Instrumentation on port: \
                                $chassis $card $port"
                        return $returnList
                    }
                }
                # Set PGID on the RX
                if {($pgid_flag == 1) && $portCfgNotApplied} {
                    debug "packetGroup setRx $chassis $card $port"
                    if {[packetGroup setRx $chassis $card $port] != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Cannot set RX\
                                PGID on port: $chassis $card $port"
                        return $returnList
                    }
                    if {[info exists splitPacketGroup_command] && $splitPacketGroup_command != ""} {
                        set splitPgCmdList [split $splitPacketGroup_command ";"]
                        foreach splitPgCmd $splitPgCmdList {
                            debug "$splitPgCmd"
                            if {[catch {eval $splitPgCmd} retCode]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: $retCode"
                                return $returnList
                            }
                            if {($retCode != "") && ($retCode != 0)} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName:\
                                        Failed to $splitPgCmd. $::ixErrorInfo."
                                return $returnList
                            }
                        }
                    }
                }
                # Add INTERFACE IPv4/IPv6
                if {$create_interface_ipv4 == 1 || $create_interface_ipv6 == 1} {
                    if {![info exists interface_description]} {
                        set interface_description [::ixia::make_interface_description \
                                $chassis/$card/$port $intf_create_args(macAddress)    ]
                        set intf_create_args(mode) add
                        set intf_handle [::ixia::get_next_interface_handle]
                    } else  {
                        set intf_create_args(mode) modify
                        set intf_handle [rfget_interface_handle_by_description $interface_description]
                    }
                    set intf_create_args(intfDesc) $interface_description
        
                    if {$intf_create_args(mode)!="modify"} {
                        
                        interfaceEntry config -description $interface_description
                        interfaceEntry config -macAddress  $intf_create_args(macAddress)
                    
                        if {[interfaceTable addInterface]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Adding interface\
                                    on port: $chassis $card $port"
                            return $returnList
                        }
                    } else {
                        if {[interfaceTable setInterface $interface_description]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: On modify interface\
                                    on port: $chassis $card $port"
                            return $returnList
                        }
                    }
        
                    
                    if {[catch {keylget returnList interface_handle} \
                            intfHandlesList]} {
                        set intfHandlesList ""
                    }
                    if {[lsearch $intfHandlesList $intf_handle] == -1} {
                        lappend intfHandlesList $intf_handle
                    }
                    keylset returnList interface_handle $intfHandlesList
                    
                    if {($ipv4_interface == 1) && ($ipv6_interface == 1)} {
                        set intf_create_args(ipVersion) 4_6
                    } elseif {$ipv4_interface == 1} {
                        set intf_create_args(ipVersion) 4
                    } elseif {$ipv6_interface == 1}  {
                        set intf_create_args(ipVersion) 6
                    } else {
                        set intf_create_args(ipVersion) 0
                    }
    
                    set add_optional_args [list \
                            ip_version    intf_create_args(ipVersion)        \
                            ipv4_address  intf_create_args(ipV4Address)      \
                            ipv4_mask     intf_create_args(ipV4MaskWidth)    \
                            ipv4_gateway  intf_create_args(ipV4Gateway)      \
                            ipv6_address  intf_create_args(ipV6Address)      \
                            ipv6_mask     intf_create_args(ipV6MaskWidth)    \
                            ipv6_gateway  intf_create_args(ipV6Gateway)      \
                            vlan_id       intf_create_args(vlanId)           \
                            vlan_priority intf_create_args(vlanUserPriority) \
                            mac_address   intf_create_args(macAddress)       \
                            mode          intf_create_args(mode)             \
                            ]
        
                    set add_interface_args " -port_handle ${chassis}/${card}/${port} \
                            -description \"$intf_create_args(intfDesc)\" \
                            -ixnetwork_objref $intf_handle "
        
                    foreach {option option_value} $add_optional_args {
                        if {[info exists $option_value]} {
                            append add_interface_args " -$option [set $option_value]"
                        }
                    }
                    debug ":ixia::modify_protocol_interface_info \
                            $add_interface_args "
                    set retCode [eval ::ixia::modify_protocol_interface_info \
                            $add_interface_args ]
                    
                    if {[keylget retCode status] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to\
                                set protocol interface information. \
                                [keylget retCode log]"
                        return $returnList
                    }
                }
    
                ## GRE interface
                if {[info exists gre_dst_ip_addr] && \
                        [lindex $gre_dst_ip_addr $option_index] != {} && \
                        (([info exists gre_ip_addr] && \
                        [lindex $gre_ip_addr $option_index] != {}) || \
                        ([info exists gre_ipv6_addr] && \
                        [lindex $gre_ipv6_addr $option_index] != {}))} {
                    
                    if {[llength $gre_count] <= $option_index} {
                        set gre_count_temp      [lindex $gre_count end]
                    } else {
                        set gre_count_temp      [lindex $gre_count $option_index]
                    }
                    for {set gre_counter 0} {$gre_counter < $gre_count_temp} {incr gre_counter}  {
                    
                        catch {array unset gre_intf_create_args}
                        array set gre_intf_create_args ""
                        # Prepare the interface existance check call
                        set intf_existence "::ixia::dual_stack_interface_exists \
                                -port_handle     $chassis/$card/$port           \
                                -type            gre                            \
                                "
                        set intf_existence_args ""
                        if {[info exists gre_ip_addr] && \
                                [lindex $gre_ip_addr $option_index] != {} && \
                                (![info exists gre_ipv6_addr] || \
                                ([info exists gre_ipv6_addr] && \
                                [lindex $gre_ipv6_addr $option_index] != {}))} {
                            set ip_version 4
                        } elseif {(![info exists gre_ip_addr] || \
                                ([info exists gre_ip_addr] && \
                                [lindex $gre_ip_addr $option_index] != {})) && \
                                [info exists gre_ipv6_addr] && \
                                [lindex $gre_ipv6_addr $option_index] != {}} {
                            set ip_version 6
                        } else {
                            # Because of the check in the if at the start of this 
                            # block of code, at least one IP address will exist.
                            set ip_version 4_6
                        }
                        append intf_existence_args " -ip_version $ip_version"
                        if {[info exists gre_ip_addr] && \
                                [lindex $gre_ip_addr $option_index] != {}} {
                            append intf_existence_args " -ipv4_address   [lindex $gre_ip_addr $option_index]"
                        }
                        if {[info exists gre_ipv6_addr] && \
                                [lindex $gre_ipv6_addr $option_index] != {}} {
                            append intf_existence_args " -ipv6_address   [lindex $gre_ipv6_addr $option_index]"
                        }
                        if {[info exists gre_dst_ip_addr]} {
                            append intf_existence_args " -dst_ip_address [lindex $gre_dst_ip_addr $option_index]"
                        }
                        
                        if {[info exists intf_create_args(macAddress)]} {
                            append intf_existence_args " -mac_address    $intf_create_args(macAddress)"
                        }
                        
                        append intf_existence $intf_existence_args
    
                        set results [eval $intf_existence]
                        set status [keylget results status]
                        
                        switch -- $status {
                            -1 {
                                # The call to interface exists failed, fail this too.
                                keylset returnList status $::FAILURE
                                keylset returnList log "The call to\
                                        ::ixia::interface_exists failed -\
                                        [keylget results log]."
                                return $returnList
                            }
                            0 {
                                set gre_description \
                                        [::ixia::make_interface_description \
                                        $chassis/$card/$port \
                                        [::ixia::convertToIxiaMac \
                                        [lindex $src_mac_addr $option_index]] gre]
                                
                                set intf_handle [::ixia::get_next_interface_handle]
                                set gre_intf_create_args(mode) add
                            }
                            1 -
                            2 {
                                set gre_description [keylget results description]
                                set handle [rfget_interface_handle_by_description $gre_description]
                                if {[llength $handle] > 0} {
                                    set intf_handle $handle
                                    break
                                }

                                set gre_intf_create_args(mode) modify
                                interfaceTable delInterface $gre_description
                            }
                            3 {
                                # Found the mac address on another interface on 
                                # this port. Fail this because to create would mean 
                                # one of them would have to be disabled, confusing 
                                # for the user.
                                #keylset returnList status $::FAILURE
                                #keylset returnList log "Creating the GRE\
                                        #interface failed. An interface with this\
                                        #MAC address was found, but the IP address\
                                        #was different."
                                #return $returnList
                                
                                # Commented above code because of bug BUG554856
                                # Could not find an invalid GRE configuration
                                set gre_description \
                                        [::ixia::make_interface_description \
                                        $chassis/$card/$port \
                                        [::ixia::convertToIxiaMac \
                                        [lindex $src_mac_addr $option_index]] gre]
                                
                                set intf_handle [::ixia::get_next_interface_handle]
                                set gre_intf_create_args(mode) add
                            }
                        }
                        
                        set gre_intf_create_args(intfDesc) $gre_description

                        # Configure interface
                        set gre_params {
                            gre_checksum_enable     enableGreChecksum       flag
                            gre_description         description             value
                            gre_dst_ip_addr         greDestIpAddress        value
                            gre_key_enable          enableGreKey            flag
                            gre_key_in              greInKey                value
                            gre_key_out             greOutKey               value
                            gre_seq_enable          enableSequenceNumber    flag
                            gre_src_ip_addr         greSourceIpAddress      value 
                        }
    
                        if {[info exists gre_src_ip_addr]} {
                            unset gre_src_ip_addr
                        }
                        if [info exists ipv6_intf_addr] {
                            set gre_src_ip_addr [lindex $ipv6_intf_addr $option_index]
                        } elseif [info exists intf_ip_addr] {
                            set gre_src_ip_addr [lindex $intf_ip_addr $option_index]
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    intf_ip_addr or ipv6_intf_addr should be\
                                    specified."
                            return $returnList
                        }
                        
                        interfaceEntry setDefault
                        interfaceEntry clearAllItems addressTypeIpV4
                        interfaceEntry clearAllItems addressTypeIpV6
                        interfaceEntry config -enable true
                        foreach {hlt_param xos_param type} $gre_params {
                            if {[info exists $hlt_param]} {
                                if {$option_index < [llength [set $hlt_param]] && \
                                    $hlt_param != "gre_description"} {
                                    set value [lindex [set $hlt_param] $option_index]
                                } elseif {$hlt_param != "gre_description"} {
                                    set value [lindex [set $hlt_param] 0]
                                } else {
                                    set value [set $hlt_param]
                                }
                                if {$type == "value"} {
                                    interfaceEntry config -$xos_param $value
                                } else {
                                    if {$value == 1} {
                                        interfaceEntry config -$xos_param true
                                    } else {
                                        interfaceEntry config -$xos_param false
                                    }
                                }
                            }
                        }
                        # Handle IPv4 address
                        if {[info exists gre_ip_addr]} {
                            if {[llength $gre_ip_addr] > $option_index} {
                                set gre_ip [lindex $gre_ip_addr $option_index]
                            } else {
                                set gre_ip [lindex $gre_ip_addr end]
                            }
                            if [::isIpAddressValid $gre_ip] {
                                interfaceIpV4 setDefault
                                interfaceIpV4 config -ipAddress $gre_ip
                                set gre_intf_create_args(ipV4Address) $gre_ip
                            } else {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: invalid\
                                    value in the gre_ip_addr parameter at index\
                                    $option_index."
                                return $returnList
                            }
                            if {[info exists gre_ip_prefix_length]} {
                                if {[llength $gre_ip_prefix_length] > $option_index} {
                                    set gre_prefix [lindex $gre_ip_prefix_length $option_index]
                                } else {
                                    set gre_prefix [lindex $gre_ip_prefix_length end]
                                }
                                interfaceIpV4 config -maskWidth $gre_prefix
                                set gre_intf_create_args(ipV4MaskWidth) $gre_prefix
                            }
                            interfaceEntry addItem addressTypeIpV4
                            set gre_intf_create_args(ipVersion) 4
                        }
                        # Handle IPv6 address
                        if {[info exists gre_ipv6_addr]} {
                            if {[llength $gre_ipv6_addr] > $option_index} {
                                set gre_ip [lindex $gre_ipv6_addr $option_index]
                            } else {
                                set gre_ip [lindex $gre_ipv6_addr end]
                            }
                            if [::ipv6::isValidAddress $gre_ip] {
                                interfaceIpV6 setDefault
                                interfaceIpV6 config -ipAddress \
                                    [::ipv6::expandAddress $gre_ip]
                                
                                set gre_intf_create_args(ipV6Address) [::ipv6::expandAddress $gre_ip]
                            } else {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: invalid\
                                    value in the gre_ipv6_addr parameter at index\
                                    $option_index."
                                return $returnList
                            }
                            if {[info exists gre_ipv6_prefix_length]} {
                                if {[llength $gre_ipv6_prefix_length] > $option_index} {
                                    set gre_prefix [lindex $gre_ipv6_prefix_length $option_index]
                                } else {
                                    set gre_prefix [lindex $gre_ipv6_prefix_length end]
                                }
                                interfaceIpV6 config -maskWidth $gre_prefix
                                set gre_intf_create_args(ipV6MaskWidth) $gre_prefix
                            }
                            interfaceEntry addItem addressTypeIpV6
                            if {[info exists gre_intf_create_args(ipVersion)]} {
                                set gre_intf_create_args(ipVersion) 4_6
                            } else {
                                set gre_intf_create_args(ipVersion) 6
                            }
                        }
                        # Add interface
                        interfaceTable addInterface interfaceTypeGre
    
                        lappend gre_interface_handle_list $intf_handle
                        keylset returnList gre_interface_handle \
                                $gre_interface_handle_list
                        
                        set add_optional_args [list \
                                ip_version    gre_intf_create_args(ipVersion)        \
                                ipv4_address  gre_intf_create_args(ipV4Address)      \
                                ipv4_mask     gre_intf_create_args(ipV4MaskWidth)    \
                                ipv4_gateway  gre_intf_create_args(ipV4Gateway)      \
                                ipv6_address  gre_intf_create_args(ipV6Address)      \
                                ipv6_mask     gre_intf_create_args(ipV6MaskWidth)    \
                                mac_address       intf_create_args(macAddress)       \
                                mode          gre_intf_create_args(mode)             \
                                ]
            
                        set add_interface_args " -port_handle ${chassis}/${card}/${port} \
                                -description \"$gre_intf_create_args(intfDesc)\" \
                                -ixnetwork_objref $intf_handle -type gre "
                        
                        if {[info exists gre_dst_ip_addr]} {
                            if {[lindex $gre_dst_ip_addr $option_index] != {}} {
                                append add_interface_args " -ipv4_dst_address [lindex $gre_dst_ip_addr $option_index]"
                            } elseif {[llength $gre_dst_ip_addr] == 1} {
                                append add_interface_args " -ipv4_dst_address $gre_dst_ip_addr"
                            }
                        }
                        
                        foreach {option option_value} $add_optional_args {
                            if {[info exists $option_value]} {
                                append add_interface_args " -$option [set $option_value]"
                            }
                        }
                        debug ":ixia::modify_protocol_interface_info \
                                $add_interface_args "
                        set retCode [eval ::ixia::modify_protocol_interface_info \
                                $add_interface_args ]
                        
                        if {[keylget retCode status] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Failed to\
                                    set protocol interface information. \
                                    [keylget retCode log]"
                            return $returnList
                        }
                        
                        # Increment GRE params
                        if {[info exists gre_ip_addr] && [info exists gre_ip_addr_step]} {
                            set gre_ip_addr_temp      [lindex $gre_ip_addr $option_index]
                            set gre_ip_addr_step_temp [lindex $gre_ip_addr_step $option_index]
                            if {$gre_ip_addr_temp != "" && $gre_ip_addr_step_temp != ""} {
                                set gre_ip_addr [lreplace \
                                        $gre_ip_addr $option_index $option_index \
                                        [increment_ipv4_address_hltapi \
                                        $gre_ip_addr_temp $gre_ip_addr_step_temp]]
                            }
                        }
                        if {[info exists gre_ipv6_addr] && [info exists gre_ipv6_addr_step]} {
                            set gre_ipv6_addr_temp      [lindex $gre_ipv6_addr $option_index]
                            set gre_ipv6_addr_step_temp [lindex $gre_ipv6_addr_step $option_index]
                            if {$gre_ipv6_addr_temp != "" && $gre_ipv6_addr_step_temp != ""} {
                                set gre_ipv6_addr [lreplace \
                                        $gre_ipv6_addr $option_index $option_index \
                                        [increment_ipv6_address_hltapi \
                                        $gre_ipv6_addr_temp $gre_ipv6_addr_step_temp]]
                            }
                        }
                    }
                    if {[info exists gre_dst_ip_addr]} {
                        set gre_dst_ip_addr_temp      [lindex $gre_dst_ip_addr $option_index]
                        if {![info exists gre_dst_ip_addr_step]} {
                            if {[isIpAddressValid $gre_dst_ip_addr_temp]} {
                                set gre_dst_ip_addr_step 0.0.0.1
                            } else {
                                set gre_dst_ip_addr_step 0000:0000:0000:0000:0000:0000:0000:0001
                            }
                        } elseif {[llength $gre_dst_ip_addr_step] <= $option_index} {
                            if {[isIpAddressValid $gre_dst_ip_addr_temp]} {
                                lappend gre_dst_ip_addr_step 0.0.0.1
                            } else {
                                lappend gre_dst_ip_addr_step 0000:0000:0000:0000:0000:0000:0000:0001
                            }
                        }
                        set gre_dst_ip_addr_step_temp [lindex $gre_dst_ip_addr_step $option_index]
                        if {$gre_dst_ip_addr_temp != "" && $gre_dst_ip_addr_step_temp != ""} {
                            if {[isIpAddressValid $gre_dst_ip_addr_temp] && [isIpAddressValid $gre_dst_ip_addr_step_temp]} {
                                set gre_dst_ip_addr [lreplace \
                                        $gre_dst_ip_addr $option_index $option_index \
                                        [increment_ipv4_address_hltapi \
                                        $gre_dst_ip_addr_temp $gre_dst_ip_addr_step_temp]]
                            } else {
                                set gre_dst_ip_addr [lreplace \
                                        $gre_dst_ip_addr $option_index $option_index \
                                        [increment_ipv6_address_hltapi \
                                        $gre_dst_ip_addr_temp $gre_dst_ip_addr_step_temp]]
                            }
                        }
                    }
                }
                
    
                if {$ppp_flag == 1 && $portCfgNotApplied} {
                    if {[ppp set $chassis $card $port] != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Cannot set PPP\
                                properties on port: $chassis $card $port"
                        return $returnList
                    }
                }
        
                if {$atm_flag && $portCfgNotApplied} {
                    if {[atmPort set $chassis $card $port] != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Cannot set atmPort\
                                properties on port: $chassis $card $port"
                        return $returnList
                    }
                }
            
                if {$sonet_flag && $portCfgNotApplied} {
                    set retCode [sonet set $chassis $card $port]
                    if {$retCode == 101} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "SONET options could not be set on port\
                                $chassis $card $port. SONET is not active/supported\
                                with this configuration."
                        return $returnList
                    } elseif { $retCode != 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Cannot set SONET\
                                properties on $chassis $card $port.\n$::ixErrorInfo"
                        return $returnList
                    }
                }
        
                # Protocol Server ARP and PING
                if {[port isValidFeature $chassis $card $port portFeatureProtocolARP]} {
                    protocolServer config -enableArpResponse $::true
                    set protocol_flag 1
                }
                if {[port isValidFeature $chassis $card $port portFeatureProtocolPING]} {
                    protocolServer config -enablePingResponse $::true
                    set protocol_flag 1
                }
                if {$protocol_flag && $portCfgNotApplied} {
                    set retCode [protocolServer set $chassis $card $port]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: protocolServer set\
                                failed on $chassis $card $port.  Return code was $retCode."
                        
                        chassis getFromID $chassis
                        set retCodeVersion [telnetCmd [chassis cget -ipAddress]]
                        if {[keylget retCodeVersion status] == $::FAILURE} {
                            keylset returnList log "[keylget returnList log]\
                                    Possibly there is an IxTclProtocol/IxTclNetwork\
                                    version mismatch between chassis and client.\
                                    Trying to retrieve IxTclProtocol version for chassis.\
                                    [keylget retCodeVersion log]"
                        } else {
                            set chassis_ixTclProcol_version [keylget retCodeVersion version]
                            version get
                            set ixTclProcol_version [version cget -ixTclProtocolVersion]
                            if {[string trim $chassis_ixTclProcol_version] != [string trim $ixTclProcol_version]} {
                                keylset returnList log "[keylget returnList log]\
                                        IxTclProtocol/IxTclNetwork\
                                        version mismatch between chassis($chassis_ixTclProcol_version)\
                                        and client($ixTclProcol_version)."
                            }
                        }
                    }
                }
        
                array unset intf_create_args
        
                set unset_var_list [list \
                        interface_description4 \
                        interface_description6 \
                        interface_description  \
                        create_interface_ipv4  \
                        create_interface_ipv6  ]
        
                foreach {var_name} $unset_var_list {
                    if {[info exists $var_name]} {
                        unset $var_name
                    }
                }
                
                # Increment parameters
                if {[info exists src_mac_addr] && [info exists src_mac_addr_step] && \
                        [lindex $connected_count $option_index] > 1} {
                    set src_mac_addr_temp      [lindex $src_mac_addr $option_index]
                    set src_mac_addr_step_temp [lindex $src_mac_addr_step $option_index]
                    if {$src_mac_addr_temp != "" && $src_mac_addr_step_temp != ""} {
                        set src_mac_addr [lreplace \
                                $src_mac_addr $option_index $option_index \
                                [incr_mac_addr \
                                [join [convertToIxiaMac $src_mac_addr_temp] :] \
                                [join [convertToIxiaMac $src_mac_addr_step_temp] :]]]
                    }
                }
                if {[info exists intf_ip_addr] && [info exists intf_ip_addr_step] && \
                        [lindex $connected_count $option_index] > 1} {
                    set intf_ip_addr_temp      [lindex $intf_ip_addr $option_index]
                    set intf_ip_addr_step_temp [lindex $intf_ip_addr_step $option_index]
                    if {$intf_ip_addr_temp != "" && $intf_ip_addr_step_temp != ""} {
                        set intf_ip_addr [lreplace \
                                $intf_ip_addr $option_index $option_index \
                                [increment_ipv4_address_hltapi \
                                $intf_ip_addr_temp $intf_ip_addr_step_temp]]
                    }
                }
                if {[info exists gateway] && [info exists gateway_step] && \
                        [lindex $connected_count $option_index] > 1} {
                    set gateway_temp      [lindex $gateway $option_index]
                    set gateway_step_temp [lindex $gateway_step $option_index]
                    if {$gateway_temp != "" && $gateway_step_temp != ""} {
                        set gateway [lreplace \
                                $gateway $option_index $option_index \
                                [increment_ipv4_address_hltapi \
                                $gateway_temp $gateway_step_temp]]
                    }
                }
                if {[info exists ipv6_intf_addr] && [info exists ipv6_intf_addr_step] && \
                        [lindex $connected_count $option_index] > 1} {
                    set ipv6_intf_addr_temp      [lindex $ipv6_intf_addr $option_index]
                    set ipv6_intf_addr_step_temp [lindex $ipv6_intf_addr_step $option_index]
                    if {$ipv6_intf_addr_temp != "" && $ipv6_intf_addr_step_temp != ""} {
                        set ipv6_intf_addr [lreplace \
                                $ipv6_intf_addr $option_index $option_index \
                                [increment_ipv6_address_hltapi \
                                $ipv6_intf_addr_temp $ipv6_intf_addr_step_temp]]
                    }
                }
                
                if {[info exists ipv6_gateway] && [info exists ipv6_gateway_step] && \
                        [lindex $connected_count $option_index] > 1} {
                    set ipv6_gateway_temp      [lindex $ipv6_gateway $option_index]
                    set ipv6_gateway_step_temp [lindex $ipv6_gateway_step $option_index]
                    if {$ipv6_gateway_temp != "" && $ipv6_gateway_step_temp != ""} {
                        set ipv6_gateway [lreplace \
                                $ipv6_gateway $option_index $option_index \
                                [increment_ipv6_address_hltapi \
                                $ipv6_gateway_temp $ipv6_gateway_step_temp]]
                    }
                }
                
                if {[info exists vpi] && [info exists vpi_step] && \
                        [lindex $connected_count $option_index] > 1} {
                    set vpi_temp      [lindex $vpi $option_index]
                    set vpi_step_temp      [lindex $vpi_step $option_index]
                    if {$vpi_temp != "" && $vpi_step_temp != ""} {
                        set vpi [lreplace \
                                $vpi $option_index $option_index \
                                [expr ($vpi_temp + $vpi_step_temp) % 256]]
                    }
                }
                if {[info exists vci] && [info exists vci_step] && \
                        [lindex $connected_count $option_index] > 1} {
                    set vci_temp      [lindex $vci $option_index]
                    set vci_step_temp      [lindex $vci_step $option_index]
                    if {$vci_temp != "" && $vci_step_temp != ""} {
                        set vci [lreplace \
                                $vci $option_index $option_index \
                                [expr ($vci_temp + $vci_step_temp) % 65535]]
                        if {[lindex $vci $option_index] == 0} {
                            set vci [lreplace $vci $option_index $option_index 32]
                        }
                    }
                }
                
                if {[info exists vlan_id] && [info exists vlan_id_step] && \
                        [lindex $connected_count $option_index] > 1} {
                    set vlan_id_temp      [lindex $vlan_id $option_index]
                    set vlan_id_step_temp      [lindex $vlan_id_step $option_index]
                    if {![info exists vlan_id_mode]} {
                        set vlan_id_mode "increment"
                    }
                    if {$vlan_id_temp != "" && $vlan_id_step_temp != ""} {
                        set vlan_id [lreplace \
                                $vlan_id $option_index $option_index \
                                [protintf_svlan_csv_incr $vlan_id_temp $vlan_id_step_temp 4097 $vlan_id_mode]]
                    }
                }
                if {[info exists vlan_user_priority] && [info exists vlan_user_priority_step] && \
                        [lindex $connected_count $option_index] > 1} {
                    set vlan_user_priority_temp      [lindex $vlan_user_priority $option_index]
                    set vlan_user_priority_step_temp      [lindex $vlan_user_priority_step $option_index]
                    if {$vlan_user_priority_temp != "" && $vlan_user_priority_step_temp != ""} {
                        set vlan_user_priority [lreplace \
                                $vlan_user_priority $option_index $option_index \
                                [protintf_svlan_csv_incr $vlan_user_priority_temp $vlan_user_priority_step_temp 8]]
                    }
                }
            }; # for connected_counter in $connected_count_temp; the number of connected interfaces
            incr option_index
            lappend unique_intf_list $interface
            set unique_intf_list [lsort -unique $unique_intf_list]
        }; # end of foreach interface $intf_list - where intf_list is the list of ports
        
        
        if {$do_set_default} {
            ::ixia::addPortToWrite $intf_list ports
        }
        
        if {![info exists no_write] && $do_set_default } {
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        ::ixia::writePortListConfig failed. \
                        [keylget retCode log]"
                return $returnList
            }
        }
        
        if {([info exists send_router_solicitation] && \
                ([eval "expr \[join {$send_router_solicitation} \" || \"\]"] == 1)) || \
                ([info exists arp_send_req] && \
                ([eval "expr \[join {$arp_send_req} \" || \"\]"] == 1))} {
            
            if {[info exists arp_send_req]} {
                set send_router_solicitation $arp_send_req
            }
            # ARP expire time in IxOS is big and we should make clean first
            set port_index 0
            foreach arp_port $intf_list {
                if {[llength $send_router_solicitation] > 1} {
                    if {[lindex $send_router_solicitation $port_index] == 0} {
                        continue;
                    }
                } else {
                    if {$send_router_solicitation == 0} {
                        continue;
                    }
                }
                if {[info exists arp_send_req]} {
                    if {[llength $arp_send_req] > 1} {
                        if {[lindex $arp_send_req $port_index] == 0} {
                            continue;
                        }
                    } else {
                        if {$arp_send_req == 0} {
                            continue;
                        }
                    }
                }
                
                foreach {arp_ch arp_ca arp_po} $arp_port {}
                debug "interfaceTable select $arp_ch $arp_ca $arp_po"
                if {[interfaceTable select $arp_ch $arp_ca $arp_po]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            interfaceTable select $arp_ch $arp_ca $arp_po."
                    return $returnList
                }
                debug "interfaceTable sendArpClear"
                if {[interfaceTable sendArpClear]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            interfaceTable sendArpClear."
                    return $returnList
                }
                incr port_index
            }
            
            if {![info exists no_write]} {
                # Wait for clear arp table to finish
                ixia_sleep 5000
            }
        }
        
        # Send Router Solicitation message
        if {[info exists send_router_solicitation] && ![info exists no_write]} {
            set router_solicitation_list [list]
            if {[llength $send_router_solicitation] == 1} {
                foreach {intf} $intf_list {
                    if {[lsearch $router_solicitation_list $intf] == -1} {
                        lappend router_solicitation_list $intf
                    }
                }
            } else  {
                foreach {rs_item} $send_router_solicitation intf $intf_list {
                    if {$rs_item == 1} {
                        if {[lsearch $router_solicitation_list $intf] == -1} {
                            lappend router_solicitation_list $intf
                        }
                    }
                }
            }
            if {![info exists router_solicitation_retries]} {
                set router_solicitation_retries  2
            } else  {
                set router_solicitation_retries [lindex $router_solicitation_retries 0]
            }
            if {[llength $router_solicitation_list] == 0} {
                set router_solicitation_retries 0
            } else {
                # Wait for link stabilization; If it is down then it will be catched
                # in get_arp_table
                ixCheckLinkState router_solicitation_list
            }
            for {set it 0} {$it < $router_solicitation_retries} {incr it} {
                set ipv6_rs_status [ipv6SendRouterSolicitation\
                        $router_solicitation_list] 
                if {[keylget ipv6_rs_status status] == $::FAILURE} {
                    keylset ipv6_rs_status log "ERROR in $procName: [keylget ipv6_rs_status log]"
                    return $ipv6_rs_status
                }
                ixia_sleep 1000
                set routerSolStatus [::ixia::get_arp_table $router_solicitation_list]
                if {[keylget routerSolStatus status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget routerSolStatus log]"
                    return $returnList
                }
                set all_good 1
                foreach rs_port $router_solicitation_list {
                    catch {unset ipv6_failed_arp($rs_port)}
                    if {![catch {set ipv6_failed_arp($rs_port) \
                            [keylget routerSolStatus \
                            [join $rs_port /].arp_ipv6_interfaces_failed]} \
                            errorMsg]} {
                        set all_good 0
                    } else {
                        debug $errorMsg
                    }
                }
                if {$all_good} {
                    break
                }            
            }
            if {$router_solicitation_retries > 0} {
                foreach rs_port $router_solicitation_list {
                    if {[info exists ipv6_failed_arp($rs_port)]} {
                        keylset returnList [join $rs_port /].arp_ipv6_interfaces_failed \
                                $ipv6_failed_arp($rs_port)
                        keylset returnList [join $rs_port /].router_solicitation_success $::FAILURE
                    } else {
                        keylset returnList [join $rs_port /].router_solicitation_success $::SUCCESS
                    }
                }
            }
        }
    
        # Send ARP
        if {[info exists arp_send_req] && ![info exists no_write]} {
            set arp_send_req_list    [list ]
            if {[llength $arp_send_req] == 1 && $arp_send_req==1} {
                foreach {intf} $intf_list {
                    if {[lsearch $arp_send_req_list $intf] == -1} {
                        lappend arp_send_req_list $intf
                    }
                }
            } else  {
                foreach {arp_item} $arp_send_req intf $intf_list {
                    if {$arp_item == 1} {
                        if {[lsearch $arp_send_req_list $intf] == -1} {
                            lappend arp_send_req_list $intf
                        }
                    }
                }
            }
            if {![info exists arp_req_retries]} {
                set arp_req_retries  2
            } else  {
                set arp_req_retries [lindex $arp_req_retries 0]
            }
            
            if {[llength $arp_send_req_list] == 0} {
                set arp_req_retries 0
            } else {
                # Wait for link stabilization; If it is down then it will be catched
                # in get_arp_table
                ixCheckLinkState arp_send_req_list                
            }
            
            for {set iter 0} {$iter < $arp_req_retries} {incr iter} {
                if {[ixTransmitArpRequest arp_send_req_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error\
                            sending arp from one or more ports: \
                            $arp_send_req_list"
                    return $returnList
                }
                ixia_sleep 1000
                set arpStatus [::ixia::get_arp_table $arp_send_req_list]
                if {[keylget arpStatus status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget arpStatus log]"
                    return $returnList
                }
                set all_good 1
                foreach arp_port $arp_send_req_list {
                    catch {unset ipv4_failed_arp($arp_port)}
                    if {![catch {set ipv4_failed_arp($arp_port) \
                            [keylget arpStatus \
                            [join $arp_port /].arp_ipv4_interfaces_failed]} \
                            errorMsg]} {
                        set all_good 0
                    } else {
                        debug "$errorMsg"
                    }
                }
                if {$all_good} {
                    break
                }
            }
            
            if {$arp_req_retries > 0} {
                foreach arp_port $arp_send_req_list {
                    if {[info exists ipv4_failed_arp($arp_port)]} {
                        keylset returnList [join $arp_port /].arp_ipv4_interfaces_failed \
                                $ipv4_failed_arp($arp_port)
                        keylset returnList [join $arp_port /].arp_request_success $::FAILURE
                    } else {
                        keylset returnList [join $arp_port /].arp_request_success $::SUCCESS
                    }
                }
            }

            # Arp send should stop Packet Group Capture 
            debug "ixStartPacketGroups $intf_list"
            if {[catch {ixStartPacketGroups intf_list} errMsg]} {
                ixPuts "Warning on $procName : Could not start \
                        PGID retrieval on ports $intf_list. $errMsg"
            }
        }    
    }
    # There are portions of this above that just set to failure with a log
    # but do not return.  If one is set, then do not mark success here.
    if {[catch {keylget returnList status} err]} {
        keylset returnList status $::SUCCESS
    }

    return $returnList
}

proc ::ixia::interface_control {args} {
    keylset returnList status $::SUCCESS
    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args
    ::ixia::utrackerLog $procName $args
    set mandatory_args {
    -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }
    set opt_args "
        -action            CHOICES start_pcs_lane_error stop_pcs_lane_error
    "
   
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg"
        return $returnList
    }
    if {[info exists action]} {
        foreach port $port_handle {
            switch -- $action {
                start_pcs_lane_error {
                    foreach {ch ca po} [split $port /] {
                        if {[pcsLaneError start $ch $ca $po]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: PCS lane errors \
                                    can not be started"
                            return $returnList
                        }
                    }
                }
                stop_pcs_lane_error {
                    foreach {ch ca po} [split $port /] {
                        if {[pcsLaneError stop $ch $ca $po]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: PCS lane errors \
                                    can't be stopped"
                            return $returnList
                        }
                    }
                }
                default {}
            }
        }
    }
return $returnList
}

proc ::ixia::interface_stats { args } {
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
                \{::ixia::interface_stats $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    ::ixia::utrackerLog $procName $args

    set mandatory_args [list                           \
            -port_handle<^\[0-9\]+/\[0-9\]+/\[0-9\]+$> \
            ]

    set optional_args [list ]

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    set port_list [format_space_port_list $port_handle]

    foreach port $port_list {

        foreach {ch ca po} $port {}

        keylset returnList $ch/$ca/$po.intf_type \
                [::ixia::get_intf_type $ch $ca $po]

        keylset returnList $ch/$ca/$po.framing \
                [::ixia::get_framing $ch $ca $po]

        keylset returnList $ch/$ca/$po.card_name \
                [::ixia::get_card_name $ch $ca $po]

        keylset returnList $ch/$ca/$po.port_name \
                [::ixia::get_port_name $ch $ca $po]

        set intf_speed [::ixia::get_intf_speed $ch $ca $po]

        set intf_stats [::ixia::get_intf_stats $ch $ca $po]
        
        set pcs_lane_stats [::ixia::get_pcs_lane_stats $ch $ca $po $intf_speed]
        if {[keylget pcs_lane_stats status] != $::SUCCESS} {
            return $pcs_lane_stats
        }
        
        foreach port_k [keylkeys pcs_lane_stats] {
            if {$port_k == "status"} {
                continue
            }
            foreach phy_lane_key [keylkeys pcs_lane_stats $port_k] {
                foreach phy_lane_stat_key [keylkeys pcs_lane_stats ${port_k}.${phy_lane_key}] {
                    keylset returnList ${port_k}.${phy_lane_key}.${phy_lane_stat_key} \
                            [keylget pcs_lane_stats ${port_k}.${phy_lane_key}.${phy_lane_stat_key}]
                }
            }
        }
        
        set pcs_statistics [::ixia::get_pcs_statistics $ch $ca $po $intf_speed]
        if {[keylget pcs_statistics status] != $::SUCCESS} {
            return $pcs_statistics
        }
        
        foreach port_keyl [keylkeys pcs_statistics] {
            if {$port_keyl == "status"} {
                continue
            }
            
            foreach pcs_statistics_key [keylkeys pcs_statistics ${port_keyl}] {
                keylset returnList ${port_keyl}.${pcs_statistics_key} \
                        [keylget pcs_statistics ${port_keyl}.${pcs_statistics_key}]
            }
        }
        
        set link [keylget intf_stats link]
        
        set bert_lane_stats [::ixia::get_bert_lane_statistics $ch $ca $po $intf_speed]
        if {[keylget bert_lane_stats status] != $::SUCCESS} {
            return $bert_lane_stats
        }
        
        foreach port_k [keylkeys bert_lane_stats] {
            if {$port_k == "status"} {
                continue
            }
         
            foreach phy_lane_key [keylkeys bert_lane_stats $port_k] {
                foreach phy_lane_stat_key [keylkeys bert_lane_stats ${port_k}.${phy_lane_key}] {
                    keylset returnList ${port_k}.${phy_lane_key}.${phy_lane_stat_key} \
                            [keylget bert_lane_stats ${port_k}.${phy_lane_key}.${phy_lane_stat_key}]
                }
            }
        }
        
        keylset returnList $ch/$ca/$po.tx_frames [keylget intf_stats tx_frames]

        keylset returnList $ch/$ca/$po.rx_frames [keylget intf_stats rx_frames]

        keylset returnList $ch/$ca/$po.elapsed_time \
                [keylget intf_stats elapsed_time]

        keylset returnList $ch/$ca/$po.rx_collisions \
                [keylget intf_stats rx_collisions]

        keylset returnList $ch/$ca/$po.total_collisions \
                [keylget intf_stats total_collisions]
        switch -- $link {
            1 -
            2 -
            17 -
            42 -
            54 {
                # 1  - linkUp
                # 2  - linkLoopback
                # 17 - pppUp
                # 42 - demoMode
                # 54 - ethernetOamLoopback
                keylset returnList $ch/$ca/$po.duplex \
                        [keylget intf_stats duplex]
                keylset returnList $ch/$ca/$po.intf_speed $intf_speed
            }
            default {
                keylset returnList $ch/$ca/$po.duplex       "N/A"
                keylset returnList $ch/$ca/$po.intf_speed   "N/A"
            }
        }
        

        keylset returnList $ch/$ca/$po.fcs_errors \
                [keylget intf_stats fcs_errors]

        keylset returnList $ch/$ca/$po.late_collisions \
                [keylget intf_stats late_collisions]

        keylset returnList $ch/$ca/$po.link $link

        # Get the portCpu memory if applicable
        if {[card get $ch $ca]} {
            keylset returnList $ch/$ca/$po.portCpuMemory na
        } else {
            set cardName [card cget -typeName]

            set portMemory 0
            if {[port isValidFeature $ch $ca $po portFeatureLocalCPU] == 0} {
                foreach mem {256 1G} {
                    if {[regexp "$mem" $cardName]} {
                        set portMemory $mem
                        break
                    }
                }
            } else  {
                if {[portCpu get $ch $ca $po]} {
                    set portMemory na
                } else {
                    set portMemory [portCpu cget -memory]
                    if {$portMemory == "0"} {
                        foreach mem {256 1G} {
                            if {[regexp "$mem" $cardName]} {
                                set portMemory $mem
                                break
                            }
                        }
                    }
                }
            }
            keylset returnList $ch/$ca/$po.portCpuMemory $portMemory
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}
