proc ::ixia::540trafficL4Icmp { args opt_args} {
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    if {![info exists l4_protocol] || $l4_protocol != "icmp"} {
        
        set set_icmp 0
        set arp_args [getVarListFromArgs $opt_args]
        foreach icmp_single_arg $arp_args {
            if {[regexp {^icmp_} $icmp_single_arg]} {
                if {[info exists $icmp_single_arg]} {
                    set set_icmp 1
                    break
                }
            }
        }    
        
        if {!$set_icmp} {
            # We don't have any icmp configurations to do
            # Return success
            return $returnList
        } else {
            set l4_protocol "icmp"
        }
    }
    
    # Insert here the parameter that allows this funciton to configure
    # For example, l3_protocol must be ipv4 in order to configure ipv4 stuff
    if {![info exists l4_protocol] || $l4_protocol != "icmp"} {
        # Don't configure because it's not requested
        debug "ICMP not needed"
        return $returnList
    }
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "stack_hls" "stack_ce"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set handle_type [keylget ret_val value]
    
    set ti_handle [ixNetworkGetParentObjref $handle trafficItem]
    
    set ret_val [540IxNetTrafficItemGetFirstTxPort $handle]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set vport_handle [keylget ret_val value]
    
    set ret_code [ixNetworkGetPortFromObj $vport_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to extract port handle from\
                $vport_handle. [keylget ret_code log]"
        return $returnList
    } 
    
    set real_port_h [keylget ret_code port_handle]
    
    # pt == protocolTemplate
    # Insert here the stack(header) protocol templates that this procedure will configure
    # Remove the ipv6 and none entries. They are just an example.
    
    if {[info exists l3_protocol] && $l3_protocol == "ipv6"} {
        set l4_protocol "icmpv6"
    }
    
    array set encapsulation_pt_map {
        icmp                        {::ixNet::OBJ-/traffic/protocolTemplate:"icmpv2"}
        icmpv6                      {::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6"}
    }

    # This array contains a mapping between the stack field names and an hlt firendly name
    # The hlt friendly name is not an HLT parameter name. It is used to access field names
    # without the errors that spaced names could insert.
    # Remove the two entries. They are just examples.
    
    array set hlt_ixn_field_name_map {
            icmp_message_type_field                            "Message type"
            icmp_code_value_field                              "Code value"
            icmpv6_code_value_field                            "Code"
            icmp_identifier_field                              "Identifier"
            icmp_sequence_number_field                         "Sequence number"
            icmp_pkt_too_big_mtu_field                         "Maximum Transmission Unit"
            icmp_param_problem_message_pointer_field           "Pointer"
            icmp_max_response_delay_ms_field                   "Maximum response delay (milliseconds)"
            icmp_multicast_address_field                       "Multicast address"
            icmp_mc_query_v2_s_flag_field                      "Suppress router-side processing (S-flag)"
            icmp_mc_query_v2_robustness_var_field              "Querier's Robustness Variable"
            icmp_mc_query_v2_interval_code_field               "Querier's Query Interval Code"
            icmp_ndp_ram_hop_limit_field                       "Current hop limit"
            icmp_ndp_ram_m_flag_field                          "Managed address configuration (M-flag)"
            icmp_ndp_ram_o_flag_field                          "Other stateful configuration (O-flag)"
            icmp_ndp_ram_h_flag_field                          "Home Agent (H-flag)"
            icmp_ndp_ram_router_lifetime_field                 "Router lifetime"
            icmp_ndp_ram_reachable_time_field                  "Reachable time"
            icmp_ndp_ram_retransmit_timer_field                "Retransmission timer"
            icmp_ndp_nam_r_flag_field                          "Router (R-flag)"
            icmp_ndp_nam_s_flag_field                          "Neighbor solicitation (S-flag)"
            icmp_ndp_nam_o_flag_field                          "Override existing cache entry (O-flag)"
            icmp_target_addr_field                             "Target address"
            icmp_ndp_rm_dest_addr_field                        "Destination address"
            icmp_mobile_pam_m_bit_field                        "M Bit"
            icmp_mobile_pam_o_bit_field                        "O Bit"
            icmp_unused_field                                  "Unused"
            icmp_checksum_field                                "Checksum"
    }
            
            
    # Array that establishes what fields will be configured for each protocol template.
    # The fields associated with each protocol template are the hlt friendly names from hlt_ixn_field_name_map
    # Remove the entries, they are just an example
    
    if {$l4_protocol == "icmpv6"} {
        array set regex_disable_list {
            ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" \
                   {icmpv6\.icmpv6Message\.icmpv6MessegeType\.destinationUnreachableMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.packetTooBigMessage
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.timeExceededMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.parameterProblemMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.echoRequestMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.echoReplyMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.multicastListenerQueryMessageVersion1\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.multicastListenerReportMessageVersion1\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.multicastListenerDoneMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.multicastListenerQueryMessageVersion2\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.multicastListenerReportMessageVersion2\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.ndpRouterSolicitationMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.ndpRouterAdvertisementMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.ndpNeighborSolicitationMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.ndpNeighborAdvertisementMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.ndpRedirectMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.mobileDHAADRequestMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.mobileDHAADReplyMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.mobilePrefixSolicitationMessage\.
                    icmpv6\.icmpv6Message\.icmpv6MessegeType\.mobilePrefixAdvertisementMessage\.}
        }
        
        if {![info exists icmp_type]} {
            array set regex_enable_list {
                ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.destinationUnreachableMessage\.
            }
        } else {
            switch -- $icmp_type {
                2 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.packetTooBigMessage\.
                    }
                }
                3 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.timeExceededMessage\.
                    }
                }
                4 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.parameterProblemMessage\.
                    }
                }
                128 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.echoRequestMessage\.
                    }
                }
                129 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.echoReplyMessage\.
                    }
                }
                130 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.multicastListenerQueryMessageVersion1\.
                    }
                }
                131 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.multicastListenerReportMessageVersion1\.
                    }
                }
                132 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.multicastListenerDoneMessage\.
                    }
                }
                130 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.multicastListenerQueryMessageVersion2\.
                    }
                }
                143 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.multicastListenerReportMessageVersion2\.
                    }
                }
                133 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.ndpRouterSolicitationMessage\.
                    }
                }
                134 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.ndpRouterAdvertisementMessage\.
                    }
                }
                135 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.ndpNeighborSolicitationMessage\.
                    }
                }
                136 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.ndpNeighborAdvertisementMessage\.
                    }
                }
                137 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.ndpRedirectMessage\.
                    }
                }
                144 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.mobileDHAADRequestMessage\.
                    }
                }
                145 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.mobileDHAADReplyMessage\.
                    }
                }
                146 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.mobilePrefixSolicitationMessage\.
                    }
                }
                147 {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.mobilePrefixAdvertisementMessage\.
                    }
                }
                default {
                    array set regex_enable_list {
                        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6" icmpv6\.icmpv6Message\.icmpv6MessegeType\.destinationUnreachableMessage\.
                    }
                }
            }
        }
        
    }
    
    array set protocol_template_field_map [list                                                                      \
        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv2"                   [list                                      \
                                                                           icmp_message_type_field                   \
                                                                           icmp_code_value_field                     \
                                                                           icmp_identifier_field                     \
                                                                           icmp_sequence_number_field                \
                                                                           icmp_checksum_field                       \
                                                                          ]                                          \
        ::ixNet::OBJ-/traffic/protocolTemplate:"icmpv6"                   [list                                      \
                                                                           icmp_message_type_field                   \
                                                                           icmpv6_code_value_field                   \
                                                                           icmp_identifier_field                     \
                                                                           icmp_sequence_number_field                \
                                                                           icmp_pkt_too_big_mtu_field                \
                                                                           icmp_param_problem_message_pointer_field  \
                                                                           icmp_max_response_delay_ms_field          \
                                                                           icmp_multicast_address_field              \
                                                                           icmp_mc_query_v2_s_flag_field             \
                                                                           icmp_mc_query_v2_robustness_var_field     \
                                                                           icmp_mc_query_v2_interval_code_field      \
                                                                           icmp_ndp_ram_hop_limit_field              \
                                                                           icmp_ndp_ram_m_flag_field                 \
                                                                           icmp_ndp_ram_o_flag_field                 \
                                                                           icmp_ndp_ram_h_flag_field                 \
                                                                           icmp_ndp_ram_router_lifetime_field        \
                                                                           icmp_ndp_ram_reachable_time_field         \
                                                                           icmp_ndp_ram_retransmit_timer_field       \
                                                                           icmp_target_addr_field                    \
                                                                           icmp_ndp_nam_r_flag_field                 \
                                                                           icmp_ndp_nam_s_flag_field                 \
                                                                           icmp_ndp_nam_o_flag_field                 \
                                                                           icmp_ndp_rm_dest_addr_field               \
                                                                           icmp_mobile_pam_m_bit_field               \
                                                                           icmp_mobile_pam_o_bit_field               \
                                                                           icmp_unused_field                         \
                                                                          ]                                          \
    ]                                                                      


    # The following lists are the actual mappings with the HLT parameters
    #
    # A list must be created for each field from hlt_ixn_field_name_map
    #
    # The first column is the HLT parameter name
    #
    # All IxNetwork fields support a starting value, a mode (increment, decrement), a count, step etc.
    # This mapping will help build the parameter list for procedure 540TrafficStackFieldConfig
    # Procedure 540TrafficStackFieldConfig is the one that actually configures the ixnetwork field
    # based on the value/count/mode/step/tracking parameters
    #
    # The second column configures the class of parameters that the HLT parameter belongs to value/count/mode/step/tracking
    # count/mode/step/tracking will allways have this fixed values
    # Instead of 'value' there can be various forms (value_hex, value_hex_2_int, value_mac....)
    # These 'values' will be interpreted in 540TrafficStackFieldConfig and handled accordingly
    # If your parameter requires a 'value' type that is not present, add it in 540TrafficStackFieldConfig and use it
    #
    # The third column is for special cases.
    # For example: by default, if mode is 'incr' or 'decr', the value and step must be transformed to integer.
    # If this is not the case for your parameter (ip_src_addr field in ixnetwork must remain an ipv4 address even if mode is incr or decr)
    # you can pass {p_format strict}. This will cause 540TrafficStackFieldConfig procedure to preserve the ipv4 format of the parameter even if mode is incr or decr.
    #
    # Another example is the {translate _some_translation_array}. This will cause the hlt parameter value to be
    # translated to another value as specified by the mapping from _some_translation_array
    #
    # You can add new ways to use the 'extra' column
        
    #       hlt_param                                     param_class               extra
    set icmp_message_type_field {
        icmp_type                                          value                _none
        icmp_type_count                                    count                _none
        icmp_type_mode                                     mode                 _none
        icmp_type_step                                     step                 _none
        icmp_type_tracking                                 tracking             _none
    }                                                     
                                                          
    set icmp_code_value_field {                           
        icmp_code                                          value                _none
        icmp_code_count                                    count                _none
        icmp_code_mode                                     mode                 _none
        icmp_code_step                                     step                 _none
        icmp_code_tracking                                 tracking             _none
    }                                                     
    
    set icmpv6_code_value_field {                           
        icmp_code                                          value                _none
        icmp_code_count                                    count                _none
        icmp_code_mode                                     mode                 _none
        icmp_code_step                                     step                 _none
        icmp_code_tracking                                 tracking             _none
    }                          
    
    set icmp_identifier_field {                           
        icmp_id                                            value                _none
        icmp_id_count                                      count                _none
        icmp_id_mode                                       mode                 _none
        icmp_id_step                                       step                 _none
        icmp_id_tracking                                   tracking             _none
    }                                                     
                                                          
    set icmp_sequence_number_field {                      
        icmp_seq                                           value                _none
        icmp_seq_count                                     count                _none
        icmp_seq_mode                                      mode                 _none
        icmp_seq_step                                      step                 _none
        icmp_seq_tracking                                  tracking             _none
    }
    
    set icmp_param_problem_message_pointer_field {
        icmp_param_problem_message_pointer                 value                _none
        icmp_param_problem_message_pointer_count           count                _none
        icmp_param_problem_message_pointer_mode            mode                 _none
        icmp_param_problem_message_pointer_step            step                 _none
        icmp_param_problem_message_pointer_tracking        tracking             _none
    }                                                   
                                                        
    set icmp_ndp_ram_hop_limit_field {                  
        icmp_ndp_ram_hop_limit                             value                _none
        icmp_ndp_ram_hop_limit_count                       count                _none
        icmp_ndp_ram_hop_limit_mode                        mode                 _none
        icmp_ndp_ram_hop_limit_step                        step                 _none
        icmp_ndp_ram_hop_limit_tracking                    tracking             _none
    }                                                   
                                                        
    set icmp_ndp_ram_m_flag_field {                     
        icmp_ndp_ram_m_flag                                value                _none
        icmp_ndp_ram_m_flag_mode                           mode                 _none
        icmp_ndp_ram_m_flag_tracking                       tracking             _none
    }                                                   
                                                        
    set icmp_mobile_pam_m_bit_field {                   
        icmp_mobile_pam_m_bit                              value                _none
        icmp_mobile_pam_m_bit_mode                         mode                 _none
        icmp_mobile_pam_m_bit_tracking                     tracking             _none
    }                                                   
                                                        
    set icmp_ndp_nam_s_flag_field {                     
        icmp_ndp_nam_s_flag                                value                _none
        icmp_ndp_nam_s_flag_mode                           mode                 _none
        icmp_ndp_nam_s_flag_tracking                       tracking             _none
    }                                                   
                                                        
    set icmp_ndp_ram_o_flag_field {                     
        icmp_ndp_ram_o_flag                                value                _none
        icmp_ndp_ram_o_flag_mode                           mode                 _none
        icmp_ndp_ram_o_flag_tracking                       tracking             _none
    }                                                   
                                                        
    set icmp_mobile_pam_o_bit_field {                   
        icmp_mobile_pam_o_bit                              value                _none
        icmp_mobile_pam_o_bit_mode                         mode                 _none
        icmp_mobile_pam_o_bit_tracking                     tracking             _none
    }                                                   
                                                        
    set icmp_ndp_rm_dest_addr_field {                   
        icmp_ndp_rm_dest_addr                              value                _none
        icmp_ndp_rm_dest_addr_count                        count                _none
        icmp_ndp_rm_dest_addr_mode                         mode                 _none
        icmp_ndp_rm_dest_addr_step                         step                 _none
        icmp_ndp_rm_dest_addr_tracking                     tracking             _none
    }                                                   
                                                        
    set icmp_ndp_ram_retransmit_timer_field {           
        icmp_ndp_ram_retransmit_timer                      value                _none
        icmp_ndp_ram_retransmit_timer_count                count                _none
        icmp_ndp_ram_retransmit_timer_mode                 mode                 _none
        icmp_ndp_ram_retransmit_timer_step                 step                 _none
        icmp_ndp_ram_retransmit_timer_tracking             tracking             _none
    }                                                   
                                                        
    set icmp_ndp_ram_h_flag_field {                     
        icmp_ndp_ram_h_flag                                value                _none
        icmp_ndp_ram_h_flag_mode                           mode                 _none
        icmp_ndp_ram_h_flag_tracking                       tracking             _none
    }                                                   
                                                        
    set icmp_max_response_delay_ms_field {              
        icmp_max_response_delay_ms                         value                _none
        icmp_max_response_delay_ms_count                   count                _none
        icmp_max_response_delay_ms_mode                    mode                 _none
        icmp_max_response_delay_ms_step                    step                 _none
        icmp_max_response_delay_ms_tracking                tracking             _none
    }                                                   
                                                        
    set icmp_mc_query_v2_interval_code_field {          
        icmp_mc_query_v2_interval_code                     value_hex            _none
        icmp_mc_query_v2_interval_code_count               count                _none
        icmp_mc_query_v2_interval_code_mode                mode                 _none
        icmp_mc_query_v2_interval_code_step                step                 _none
        icmp_mc_query_v2_interval_code_tracking            tracking             _none
    }
    
    set icmp_multicast_address_field {
        icmp_multicast_address                             value               _none
        icmp_multicast_address_count                       count               _none
        icmp_multicast_address_mode                        mode                _none
        icmp_multicast_address_step                        step                _none
        icmp_multicast_address_tracking                    tracking            _none
    }
    
    set icmp_ndp_ram_reachable_time_field {
        icmp_ndp_ram_reachable_time                        value               _none
        icmp_ndp_ram_reachable_time_count                  count               _none
        icmp_ndp_ram_reachable_time_mode                   mode                _none
        icmp_ndp_ram_reachable_time_step                   step                _none
        icmp_ndp_ram_reachable_time_tracking               tracking            _none
    }
    
    set icmp_pkt_too_big_mtu_field {
        icmp_pkt_too_big_mtu                               value               _none
        icmp_pkt_too_big_mtu_count                         count               _none
        icmp_pkt_too_big_mtu_mode                          mode                _none
        icmp_pkt_too_big_mtu_step                          step                _none
        icmp_pkt_too_big_mtu_tracking                      tracking            _none
    }
    
    set icmp_ndp_nam_r_flag_field {
        icmp_ndp_nam_r_flag                                value               _none
        icmp_ndp_nam_r_flag_mode                           mode                _none
        icmp_ndp_nam_r_flag_tracking                       tracking            _none
    }
    
    set icmp_ndp_ram_router_lifetime_field {
        icmp_ndp_ram_router_lifetime                       value               _none
        icmp_ndp_ram_router_lifetime_count                 count               _none
        icmp_ndp_ram_router_lifetime_mode                  mode                _none
        icmp_ndp_ram_router_lifetime_step                  step                _none
        icmp_ndp_ram_router_lifetime_tracking              tracking            _none
    }
    
    set icmp_mc_query_v2_s_flag_field {
        icmp_mc_query_v2_s_flag                            value               _none
        icmp_mc_query_v2_s_flag_mode                       mode                _none
        icmp_mc_query_v2_s_flag_tracking                   tracking            _none
    }
    
    set icmp_target_addr_field {
        icmp_target_addr                                   value               _none
        icmp_target_addr_count                             count               _none
        icmp_target_addr_mode                              mode                _none
        icmp_target_addr_step                              step                _none
        icmp_target_addr_tracking                          tracking            _none
    }
    
    set icmp_mc_query_v2_robustness_var_field {
        icmp_mc_query_v2_robustness_var                    value               _none
        icmp_mc_query_v2_robustness_var_count              count               _none
        icmp_mc_query_v2_robustness_var_mode               mode                _none
        icmp_mc_query_v2_robustness_var_step               step                _none
        icmp_mc_query_v2_robustness_var_tracking           tracking            _none
    }
    
    set icmp_ndp_nam_o_flag_field {
        icmp_ndp_nam_o_flag                                value               _none
        icmp_ndp_nam_o_flag_mode                           mode                _none
        icmp_ndp_nam_o_flag_tracking                       tracking            _none
    }
    
    set icmp_unused_field {
        icmp_unused                                        value_hex           _none
        icmp_unused_count                                  count               _none
        icmp_unused_mode                                   mode                _none
        icmp_unused_step                                   step                _none
        icmp_unused_tracking                               tracking            _none
    }
    
    set icmp_checksum_field {
        icmp_checksum                                      value_hex           _none
        icmp_checksum_count                                count               _none
        icmp_checksum_mode                                 mode                _none
        icmp_checksum_step                                 step                _none
        icmp_checksum_tracking                             tracking            _none
    }
    
    # In this section you must configure the protocol templates that will be added/configured
    # based on the indicators from your example. (l3_protocol, l2_encap.... ipv6_extensions...)
    set protocol_template_list $encapsulation_pt_map($l4_protocol)    
    
    switch -- $mode {
        "create" {
            
            # This procedure will remove the protocol templates that do not apply for this configElement
            # this is the case where multiple configElements exist on one traffic item.
            set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set protocol_template_list [keylget ret_code pt_list]
            
            # Build your own procedure 540IxNetTrafficProcThatAddsHeaders and change the name of course :)
            # This procedure must take the protocol templates and add them in the packet based on some rules
            # For example, if the protocol templates are layer3
            #   1. see if the template wasn't already added
            #   2. if it wasn't find the last L3 header and add after it
            #   3. If no L3 headers present, add after last L2
            #   ... make your own particular rules
            
            set ret_code [540IxNetTrafficL4AddHeaders $handle $handle_type $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            # The procedure MUST return the list of stacks (instances of protocol templates) that were added
            set stack_handles [keylget ret_code handle]
        }
        "modify" {
        
            # For modify mode search for the headers and modify them
            # if there are any parameters for them
            
            # if the handle is a stack, no need to search known headers. Modify the stacks.
            
            switch -- $handle_type {
                "traffic_item" {
                    # Get config element
                    set retrieve [540getConfigElementOrHighLevelStream $handle]
                    if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
                    set ce_hls_handle [keylget retrieve handle]
                }
                "config_element" {
                    set ce_hls_handle $handle
                }
                "high_level_stream" {
                    set ce_hls_handle $handle
                }
                "stack_ce" -
                "stack_hls" {
                    set stack_handles $handle
                }
            }
            
            if {$handle_type == "traffic_item" || $handle_type == "config_element" || \
                    $handle_type == "high_level_stream"} {
                
                # Again, protocol_template_list must be present
                set ret_code [540IxNetFindStacksAll $ce_hls_handle $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set stack_handles ""
                foreach tmp_pt_modify $protocol_template_list {
                    set tmp_stack_list [keylget ret_code $tmp_pt_modify]
                    
                    if {[llength $tmp_stack_list] > 0} {
                        lappend stack_handles [lindex $tmp_stack_list 0]
                    }
                    
                    catch {unset tmp_stack_list}
                }
                
                catch {unset tmp_pt_modify}
            }
        }
        "append_header" -
        "prepend_header" -
        "replace_header" {
            if {$handle_type != "stack_hls" && $handle_type != "stack_ce"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $handle handle type $handle_type for mode $mode."
                return $returnList
            }
            
            # Replace _parameter_that_triggers_adding_headers with your indicators (l4_protocol for example)
            if {![info exists l4_protocol]} {
                # l4_protocol not provided. Nothing to append/prepend/replace
                keylset returnList status $::SUCCESS
                return $returnList
            }
            
            switch -- $mode {
                "append_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetAppendProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetAppendProtocolTemplate $protocol_template_list $handle"
                    }
                    
                }
                "prepend_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetPrependProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetPrependProtocolTemplate $protocol_template_list $handle"
                    }
                }
                "replace_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate $protocol_template_list $handle"
                    }
                }
            }
            
            set ret_code [eval $tmp_cmd]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $tmp_cmd. [keylget ret_code log]"
                return $returnList
            }
            
            set stack_handles [keylget ret_code handle]
        }
    }
    
    # Build the headers_multiple_instances array with the protocol templates that might be added more than once
    # For example, VLAN protocl temaplate is added more than once when QinQ
    # Add a key word that will be used as index.
    # The index will be incremented every time the template is configured
    # The index will be used to extract the value of a parameter from a list of values
    
    #   Header protocol template                                            header index
    array set headers_multiple_instances {
    }
    
    # The rest is standard
    
    if {![info exists stack_handles]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Variable stack_handles is missing."
        return $returnList
    }
    
    set ret_code [540TrafficStackGod $stack_handles]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to configure stacks $stack_handles. [keylget ret_code log]"
        return $ret_code
    }
    
    return $returnList
}


proc ::ixia::540trafficL4Gre { args opt_args opt_args_ipv6 opt_args_ipv4 opt_args_ipv4_qos opt_args_ipv4_noqos} {
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    # Insert here the parameter that allows this funciton to configure
    # For example, l3_protocol must be ipv4 in order to configure ipv4 stuff
    if {![info exists l4_protocol]} {
        # Don't configure because it's not requested
        return $returnList
    }
    
    
    if {$l4_protocol != "gre"} {
        # Don't configure because it's not gre
        return $returnList
    }
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "stack_hls" "stack_ce"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set handle_type [keylget ret_val value]
    
    set ti_handle [ixNetworkGetParentObjref $handle trafficItem]
    
    set ret_val [540IxNetTrafficItemGetFirstTxPort $handle]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set vport_handle [keylget ret_val value]
    
    set ret_code [ixNetworkGetPortFromObj $vport_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to extract port handle from\
                $vport_handle. [keylget ret_code log]"
        return $returnList
    }
    
    set real_port_h [keylget ret_code port_handle]
    
    # pt == protocolTemplate
    # Insert here the stack(header) protocol templates that this procedure will configure
    # Remove the ipv6 and none entries. They are just an example.
    array set encapsulation_pt_map {
        gre                         {::ixNet::OBJ-/traffic/protocolTemplate:"gre"}
    }

    # This array contains a mapping between the stack field names and an hlt firendly name
    # The hlt friendly name is not an HLT parameter name. It is used to access field names
    # without the errors that spaced names could insert.
    # Remove the two entries. They are just examples.
    
    array set hlt_ixn_field_name_map {
            checksum_present_field           checksum_present
            key_present_field                key_present
            sequence_present_field           sequence_present
            reserved0_field                  reserved0
            version_field                    version
            protocol_field                   protocol
            checksum_field                   checksum
            reserved2_field                  reserved2
            key_field                        key
            sequence_num_field               sequence_num
    }
    
    set use_name_instead_of_displayname 1
    
    # Array that establishes what fields will be configured for each protocol template.
    # The fields associated with each protocol template are the hlt friendly names from hlt_ixn_field_name_map
    # Remove the entries, they are just an example
    array set protocol_template_field_map [list                                                                      \
        ::ixNet::OBJ-/traffic/protocolTemplate:"gre"                    [list                                        \
                                                                         checksum_present_field                      \
                                                                         key_present_field                           \
                                                                         sequence_present_field                      \
                                                                         reserved0_field                             \
                                                                         version_field                               \
                                                                         protocol_field                              \
                                                                         checksum_field                              \
                                                                         reserved2_field                             \
                                                                         key_field                                   \
                                                                         sequence_num_field                          \
                                                                        ]                                            \
    ]

    # The following lists are the actual mappings with the HLT parameters
    #
    # A list must be created for each field from hlt_ixn_field_name_map
    #
    # The first column is the HLT parameter name
    #
    # All IxNetwork fields support a starting value, a mode (increment, decrement), a count, step etc.
    # This mapping will help build the parameter list for procedure 540TrafficStackFieldConfig
    # Procedure 540TrafficStackFieldConfig is the one that actually configures the ixnetwork field
    # based on the value/count/mode/step/tracking parameters
    #
    # The second column configures the class of parameters that the HLT parameter belongs to value/count/mode/step/tracking
    # count/mode/step/tracking will allways have this fixed values
    # Instead of 'value' there can be various forms (value_hex, value_hex_2_int, value_mac....)
    # These 'values' will be interpreted in 540TrafficStackFieldConfig and handled accordingly
    # If your parameter requires a 'value' type that is not present, add it in 540TrafficStackFieldConfig and use it
    #
    # The third column is for special cases.
    # For example: by default, if mode is 'incr' or 'decr', the value and step must be transformed to integer.
    # If this is not the case for your parameter (ip_src_addr field in ixnetwork must remain an ipv4 address even if mode is incr or decr)
    # you can pass {p_format strict}. This will cause 540TrafficStackFieldConfig procedure to preserve the ipv4 format of the parameter even if mode is incr or decr.
    #
    # Another example is the {translate _some_translation_array}. This will cause the hlt parameter value to be
    # translated to another value as specified by the mapping from _some_translation_array
    #
    # You can add new ways to use the 'extra' column

    if {[info exists inner_protocol]} {
        switch -- $inner_protocol {
            "ipv4" {
                set inner_protocol 0x0800
            }
            "ipv6" {
                set inner_protocol 0x86DD
            }
            "none" {
                set inner_protocol 0x0000
            }
            default {
                set inner_protocol 0x0800
            }
        }
    }

# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.checksumPresent-1"
# # -gre_checksum_enable                CHOICES 0 1
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.reserved1-2"
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.keyPresent-3"
# # -gre_key_enable                     CHOICES 0 1
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.sequencePresent-4"
# # -gre_seq_enable                     CHOICES 0 1
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.reserved2-5"
# # -gre_reserved0                      REGEXP  ^[0-9a-fA-F]{1,3}$
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.version-6"
# # -gre_version                        RANGE   0-7
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.protocol-7"
# # -inner_protocol                     CHOICES ipv4 ipv6
#                                       HEX
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.checksumHolder.withChecksum.checksum-8"
# # -gre_checksum                       REGEXP  ^[0-9a-fA-F]{1,4}$
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.checksumHolder.withChecksum.reserved-9"
# # -gre_reserved1                      REGEXP  ^[0-9a-fA-F]{1,4}$
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.checksumHolder.noChecksum-10"
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.keyHolder.key-11"
# # -gre_key                            REGEXP  ^[0-9a-fA-F]{1,8}$
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.keyHolder.noKey-12"
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.sequenceHolder.sequenceNum-13"
# # -gre_seq_number                     REGEXP  ^[0-9a-fA-F]{1,8}$
# 
# ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"gre-3"/field:"gre.header.sequenceHolder.noSequenceNum-14"
# 
#n -gre_valid_checksum_enable          CHOICES 0 1


    #   hlt_param                     param_class                   extra
    set key_field {
        gre_key                       value_hex                     {p_format strict}
        gre_key_step                  step                          _none
        gre_key_mode                  mode                          _none
        gre_key_count                 count                         _none
        gre_key_tracking              tracking                      _none
    }
    
    set sequence_present_field {
        gre_seq_enable                value                         _none
        gre_seq_enable_mode           mode                          _none
        gre_seq_enable_tracking       tracking                      _none
    }
    
    set key_present_field {
        gre_key_enable                value                         _none
        gre_key_enable_mode           mode                          _none
        gre_key_enable_tracking       tracking                      _none
    }
    
    set reserved2_field {
        gre_reserved1                 value_hex                     {p_format strict}
        gre_reserved1_step            step                          _none
        gre_reserved1_mode            mode                          _none
        gre_reserved1_count           count                         _none
        gre_reserved1_tracking        tracking                      _none
    }
    
    set protocol_field {
        inner_protocol                value_hex                     {p_format strict}
        inner_protocol_step           step                          _none
        inner_protocol_mode           mode                          _none
        inner_protocol_count          count                         _none
        inner_protocol_tracking       tracking                      _none
    }
    
    set version_field {
        gre_version                   value                         _none
        gre_version_step              step                          _none
        gre_version_mode              mode                          _none
        gre_version_count             count                         _none
        gre_version_tracking          tracking                      _none
    }
    
    set checksum_field {
        gre_checksum                  value_hex                     {p_format strict}
        gre_checksum_step             step                          _none
        gre_checksum_mode             mode                          _none
        gre_checksum_count            count                         _none
        gre_checksum_tracking         tracking                      _none
    }
    
    set checksum_present_field {
        gre_checksum_enable           value                         _none
        gre_checksum_enable_mode      mode                          _none
        gre_checksum_enable_tracking  tracking                      _none
    }
    
    set sequence_num_field {
        gre_seq_number                value                         _none
        gre_seq_number_step           step                          _none
        gre_seq_number_mode           mode                          _none
        gre_seq_number_count          count                         _none
        gre_seq_number_tracking       tracking                      _none
    }
    
    set reserved0_field {
        gre_reserved0                 value_hex                     {p_format strict}
        gre_reserved0_step            step                          _none
        gre_reserved0_mode            mode                          _none
        gre_reserved0_count           count                         _none
        gre_reserved0_tracking        tracking                      _none
    }

    
    
    # In this section you must configure the protocol templates that will be added/configured
    # based on the indicators from your example. (l3_protocol, l2_encap.... ipv6_extensions...)
    set protocol_template_list [list ::ixNet::OBJ-/traffic/protocolTemplate:"gre"]
    
    switch -- $mode {
        "create" {
            
            # Build your own procedure 540IxNetTrafficProcThatAddsHeaders and change the name of course :)
            # This procedure must take the protocol templates and add them in the packet based on some rules
            # For example, if the protocol templates are layer3
            #   1. see if the template wasn't already added
            #   2. if it wasn't find the last L3 header and add after it
            #   3. If no L3 headers present, add after last L2
            #   ... make your own particular rules
            
            array set regex_disable_list {
                ::ixNet::OBJ-/traffic/protocolTemplate:"gre" \
                       {gre\.header\.checksumPresent
                    	gre\.header\.reserved1
                    	gre\.header\.keyPresent
                    	gre\.header\.sequencePresent
                    	gre\.header\.reserved2
                    	gre\.header\.version
                    	gre\.header\.protocol
                    	gre\.header\.checksumHolder\.withChecksum\.checksum
                    	gre\.header\.checksumHolder\.withChecksum\.reserved
                    	gre\.header\.checksumHolder\.noChecksum
                    	gre\.header\.keyHolder\.key
                    	gre\.header\.keyHolder\.noKey
                    	gre\.header\.sequenceHolder\.sequenceNum
                    	gre\.header\.sequenceHolder\.noSequenceNum}
            }
            
            set r_enable_list {
                gre\.header\.checksumPresent
            	gre\.header\.reserved1
            	gre\.header\.keyPresent
            	gre\.header\.sequencePresent
            	gre\.header\.reserved2
            	gre\.header\.version
            	gre\.header\.protocol
          	}
            
            if {[info exists gre_checksum_enable] && $gre_checksum_enable} {
                lappend r_enable_list gre\.header\.checksumHolder\.withChecksum\.checksum
                lappend r_enable_list gre\.header\.checksumHolder\.withChecksum\.reserved
            } else {
                lappend r_enable_list gre\.header\.checksumHolder\.noChecksum
            }
            
            if {[info exists gre_key_enable] && $gre_key_enable} {
                lappend r_enable_list gre\.header\.keyHolder\.key
            } else {
                lappend r_enable_list gre\.header\.keyHolder\.noKey
            }
            
            if {[info exists gre_seq_enable] && $gre_seq_enable} {
                lappend r_enable_list gre\.header\.sequenceHolder\.sequenceNum
            } else {
                lappend r_enable_list gre\.header\.sequenceHolder\.noSequenceNum
            }
            
            array set regex_enable_list [list ::ixNet::OBJ-/traffic/protocolTemplate:"gre" $r_enable_list]
            
            # This procedure will remove the protocol templates that do not apply for this configElement
            # this is the case where multiple configElements exist on one traffic item.
            set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set protocol_template_list [keylget ret_code pt_list]
            
            # 540IxNetTrafficL3AddHeadersArp is not a mistake here. It adds generic L3 headers (and GRE is one)
            set ret_code [540IxNetTrafficL3AddHeadersArp $handle $handle_type $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            # The procedure MUST return the list of stacks (instances of protocol templates) that were added
            set stack_handles [keylget ret_code handle]
        }
        "modify" {
        
            # For modify mode search for the headers and modify them
            # if there are any parameters for them
            
            # if the handle is a stack, no need to search known headers. Modify the stacks.
            
            array set regex_disable_list {
                ::ixNet::OBJ-/traffic/protocolTemplate:"gre" \
                       {}
            }
            
            set r_enable_list {
                {gre\.header\.checksumPresent}
            	{gre\.header\.reserved1}
            	{gre\.header\.keyPresent}
            	{gre\.header\.sequencePresent}
            	{gre\.header\.reserved2}
            	{gre\.header\.version}
            	{gre\.header\.protocol}
          	}
            
            if {[info exists gre_checksum_enable]} {
                if {$gre_checksum_enable} {
                    lappend r_enable_list {gre\.header\.checksumHolder\.withChecksum\.checksum}
                    lappend r_enable_list {gre\.header\.checksumHolder\.withChecksum\.reserved}
                } else {
                    lappend r_enable_list {gre\.header\.checksumHolder\.noChecksum}
                }
            }
            
            if {[info exists gre_key_enable]} {
                if {$gre_key_enable} {
                    lappend r_enable_list {gre\.header\.keyHolder\.key}
                } else {
                    lappend r_enable_list {gre\.header\.keyHolder\.noKey}
                }
            }
            
            if {[info exists gre_seq_enable]} {
                if {$gre_seq_enable} {
                    lappend r_enable_list {gre\.header\.sequenceHolder\.sequenceNum}
                } else {
                    lappend r_enable_list {gre\.header\.sequenceHolder\.noSequenceNum}
                }
            }
            
            array set regex_enable_list [list ::ixNet::OBJ-/traffic/protocolTemplate:"gre" $r_enable_list]
            
            switch -- $handle_type {
                "traffic_item" {
                    # Get config element
                    set retrieve [540getConfigElementOrHighLevelStream $handle]
                    if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
                    set ce_hls_handle [keylget retrieve handle]
                }
                "config_element" {
                    set ce_hls_handle $handle
                }
                "high_level_stream" {
                    set ce_hls_handle $handle
                }
                "stack_ce" -
                "stack_hls" {
                    set stack_handles $handle
                }
            }
            
            if {$handle_type == "traffic_item" || $handle_type == "config_element" || \
                    $handle_type == "high_level_stream"} {
                
                # Again, protocol_template_list must be present
                set ret_code [540IxNetFindStacksAll $ce_hls_handle $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set stack_handles ""
                foreach tmp_pt_modify $protocol_template_list {
                    set tmp_stack_list [keylget ret_code $tmp_pt_modify]
                    
                    if {[llength $tmp_stack_list] > 0} {
                        lappend stack_handles [lindex $tmp_stack_list 0]
                    }
                    
                    catch {unset tmp_stack_list}
                }
                
                catch {unset tmp_pt_modify}
            }
        }
        "append_header" -
        "prepend_header" -
        "replace_header" {
            if {$handle_type != "stack_hls" && $handle_type != "stack_ce"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $handle handle type $handle_type for mode $mode."
                return $returnList
            }
            
            # Replace _parameter_that_triggers_adding_headers with your indicators (l3_protocol for example)
            if {![info exists l4_protocol] || $l4_protocol != "gre"} {
                # l4_protocol not provided. Nothing to append/prepend/replace
                keylset returnList status $::SUCCESS
                return $returnList
            }
            
            array set regex_disable_list {
                ::ixNet::OBJ-/traffic/protocolTemplate:"gre" \
                       {gre\.header\.checksumPresent
                    	gre\.header\.reserved1
                    	gre\.header\.keyPresent
                    	gre\.header\.sequencePresent
                    	gre\.header\.reserved2
                    	gre\.header\.version
                    	gre\.header\.protocol
                    	gre\.header\.checksumHolder\.withChecksum\.checksum
                    	gre\.header\.checksumHolder\.withChecksum\.reserved
                    	gre\.header\.checksumHolder\.noChecksum
                    	gre\.header\.keyHolder\.key
                    	gre\.header\.keyHolder\.noKey
                    	gre\.header\.sequenceHolder\.sequenceNum
                    	gre\.header\.sequenceHolder\.noSequenceNum}
            }
            
            set r_enable_list {
                {gre\.header\.checksumPresent}
            	{gre\.header\.reserved1}
            	{gre\.header\.keyPresent}
            	{gre\.header\.sequencePresent}
            	{gre\.header\.reserved2}
            	{gre\.header\.version}
            	{gre\.header\.protocol}
          	}
            
            if {[info exists gre_checksum_enable] && $gre_checksum_enable} {
                lappend r_enable_list {gre\.header\.checksumHolder\.withChecksum\.checksum}
                lappend r_enable_list {gre\.header\.checksumHolder\.withChecksum\.reserved}
            } else {
                lappend r_enable_list {gre\.header\.checksumHolder\.noChecksum}
            }
            
            if {[info exists gre_key_enable] && $gre_key_enable} {
                lappend r_enable_list {gre\.header\.keyHolder\.key}
            } else {
                lappend r_enable_list {gre\.header\.keyHolder\.noKey}
            }
            
            if {[info exists gre_seq_enable] && $gre_seq_enable} {
                lappend r_enable_list {gre\.header\.sequenceHolder\.sequenceNum}
            } else {
                lappend r_enable_list {gre\.header\.sequenceHolder\.noSequenceNum}
            }
            
            array set regex_enable_list [list ::ixNet::OBJ-/traffic/protocolTemplate:"gre" $r_enable_list]
            
            switch -- $mode {
                "append_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetAppendProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetAppendProtocolTemplate $protocol_template_list $handle"
                    }
                    
                }
                "prepend_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetPrependProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetPrependProtocolTemplate $protocol_template_list $handle"
                    }
                }
                "replace_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate $protocol_template_list $handle"
                    }
                }
            }
            
            set ret_code [eval $tmp_cmd]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $tmp_cmd. [keylget ret_code log]"
                return $returnList
            }
            
            set stack_handles [keylget ret_code handle]
        }
    }
    
    # Build the headers_multiple_instances array with the protocol templates that might be added more than once
    # For example, VLAN protocl temaplate is added more than once when QinQ
    # Add a key word that will be used as index.
    # The index will be incremented every time the template is configured
    # The index will be used to extract the value of a parameter from a list of values
    
    #   Header protocol template                                            header index
    array set headers_multiple_instances {
    }
    
    # The rest is standard
    
    if {![info exists stack_handles]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Variable stack_handles is missing."
        return $returnList
    }
    
    set ret_code [540TrafficStackGod $stack_handles]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to configure stacks $stack_handles. [keylget ret_code log]"
        return $ret_code
    }
    
    
    switch -- $mode {
        "append_header" -
        "prepend_header" -
        "replace_header" -
        "create" {
            
            if {![info exists inner_protocol] || ($inner_protocol!= "none" && $inner_protocol != 0x0000)} {

                # So far we added only the GRE header
                # Must add ipv4 or ipv6 header
                # Translate inner_* params to ipv[4|6] params and call the ipv4 or ipv6 procs

                if {![info exists inner_protocol] || $inner_protocol == "ipv4" || $inner_protocol == "0x0800"} {
                    
                    array set ipvX_param_mapping {
                        inner_ip_dst_addr                  ip_dst_addr
                        inner_ip_dst_count                 ip_dst_count
                        inner_ip_dst_mode                  ip_dst_mode
                        inner_ip_dst_step                  ip_dst_step
                        inner_ip_dst_tracking              ip_dst_tracking
                        inner_ip_src_addr                  ip_src_addr
                        inner_ip_src_count                 ip_src_count
                        inner_ip_src_mode                  ip_src_mode
                        inner_ip_src_step                  ip_src_step
                        inner_ip_src_tracking              ip_src_tracking
                    }
                    
                    set ip_config_proc "540trafficL3IpV4"
                    
                    set local_l3_proto "ipv4"
                    
                } else {
                    
                    array set ipvX_param_mapping {
                        inner_ipv6_dst_addr                ipv6_dst_addr
                        inner_ipv6_dst_count               ipv6_dst_count
                        inner_ipv6_dst_mode                ipv6_dst_mode
                        inner_ipv6_dst_step                ipv6_dst_step
                        inner_ipv6_dst_tracking            ipv6_dst_tracking
                        inner_ipv6_flow_label              ipv6_flow_label
                        inner_ipv6_flow_label_count        ipv6_flow_label_count
                        inner_ipv6_flow_label_mode         ipv6_flow_label_mode
                        inner_ipv6_flow_label_step         ipv6_flow_label_step
                        inner_ipv6_flow_label_tracking     ipv6_flow_label_tracking
                        inner_ipv6_frag_id                 ipv6_frag_id
                        inner_ipv6_frag_id_mode            ipv6_frag_id_mode
                        inner_ipv6_frag_id_step            ipv6_frag_id_step
                        inner_ipv6_frag_id_count           ipv6_frag_id_count
                        inner_ipv6_frag_id_tracking        ipv6_frag_id_tracking
                        inner_ipv6_frag_more_flag          ipv6_frag_more_flag
                        inner_ipv6_frag_more_flag_mode     ipv6_frag_more_flag_mode
                        inner_ipv6_frag_more_flag_tracking ipv6_frag_more_flag_tracking
                        inner_ipv6_frag_offset             ipv6_frag_offset
                        inner_ipv6_frag_offset_count       ipv6_frag_offset_count
                        inner_ipv6_frag_offset_mode        ipv6_frag_offset_mode
                        inner_ipv6_frag_offset_step        ipv6_frag_offset_step
                        inner_ipv6_frag_offset_tracking    ipv6_frag_offset_tracking
                        inner_ipv6_hop_limit               ipv6_hop_limit
                        inner_ipv6_hop_limit_count         ipv6_hop_limit_count
                        inner_ipv6_hop_limit_mode          ipv6_hop_limit_mode
                        inner_ipv6_hop_limit_step          ipv6_hop_limit_step
                        inner_ipv6_hop_limit_tracking      ipv6_hop_limit_tracking
                        inner_ipv6_traffic_class           ipv6_traffic_class
                        inner_ipv6_traffic_class_count     ipv6_traffic_class_count
                        inner_ipv6_traffic_class_mode      ipv6_traffic_class_mode
                        inner_ipv6_traffic_class_step      ipv6_traffic_class_step
                        inner_ipv6_traffic_class_tracking  ipv6_traffic_class_tracking
                        inner_ipv6_src_addr                ipv6_src_addr
                        inner_ipv6_src_count               ipv6_src_count
                        inner_ipv6_src_mode                ipv6_src_mode
                        inner_ipv6_src_step                ipv6_src_step
                        inner_ipv6_src_tracking            ipv6_src_tracking
                    }
                    
                    set ip_config_proc "540trafficL3IpV6"
                    set local_l3_proto "ipv6"
                }
            
                set args ""
                

                foreach param_ipvx [array names ipvX_param_mapping] {
                    if {![info exists $param_ipvx]} {
                        continue
                    }
                    
                    set param_ipvx_val [set $param_ipvx]
                    
                    lappend args -$ipvX_param_mapping($param_ipvx) $param_ipvx_val
                }
                

                if {[llength $args] > 0} {
                    lappend args -mode "append_header" -handle [lindex $stack_handles 0] \
                            -l3_protocol $local_l3_proto
                    
                    
                    if {$local_l3_proto == "ipv4"} {
                        set _cmd {$ip_config_proc $args $opt_args_ipv4 $opt_args_ipv4_qos $opt_args_ipv4_noqos $args}
                    } else {
                        set _cmd {$ip_config_proc $args $opt_args_ipv6 $args}
                    }
                    
                    debug "_cmd == $_cmd"
                    if {[catch {eval $_cmd} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error on '$ip_config_proc $args'. $err"
                        return $returnList
                    }
                    
                    if {[keylget err status] != $::SUCCESS} {
                        return $err
                    }
                }
            }
        }
        "modify" {
            
            if {[llength $stack_handles] > 0} {
                set gre_next_stack [540IxNetStackGetNext [lindex $stack_handles 0]]
                if {[keylget gre_next_stack status] != $::SUCCESS} {
                    return $gre_next_stack
                }
                
                set gre_next_stack [keylget gre_next_stack handle]
                
                if {$gre_next_stack != [ixNet getNull]} {
                    
                    set ret_val [540IxNetStackGetType $gre_next_stack]
                    if {[keylget ret_val status] != $::SUCCESS} {
                        return $ret_val
                    }
                    
                    set gre_next_stack_type  [keylget ret_val stack_type]
                    set gre_next_stack_type [string trim $gre_next_stack_type]
                    
                    if {($gre_next_stack_type == "IPv4") || ($gre_next_stack_type == "IPv6")} {

                        # So far we added only the GRE header
                        # Must add ipv4 or ipv6 header
                        # Translate inner_* params to ipv[4|6] params and call the ipv4 or ipv6 procs
                        if {$gre_next_stack_type == "IPv4"} {
                            
                            array set ipvX_param_mapping {
                                inner_ip_dst_addr                  ip_dst_addr
                                inner_ip_dst_count                 ip_dst_count
                                inner_ip_dst_mode                  ip_dst_mode
                                inner_ip_dst_step                  ip_dst_step
                                inner_ip_dst_tracking              ip_dst_tracking
                                inner_ip_src_addr                  ip_src_addr
                                inner_ip_src_count                 ip_src_count
                                inner_ip_src_mode                  ip_src_mode
                                inner_ip_src_step                  ip_src_step
                                inner_ip_src_tracking              ip_src_tracking
                            }
                            
                            set ip_config_proc "540trafficL3IpV4"
                            
                            set local_l3_proto "ipv4"
                            
                        } else {
                            
                            array set ipvX_param_mapping {
                                inner_ipv6_dst_addr                ipv6_dst_addr
                                inner_ipv6_dst_count               ipv6_dst_count
                                inner_ipv6_dst_mode                ipv6_dst_mode
                                inner_ipv6_dst_step                ipv6_dst_step
                                inner_ipv6_dst_tracking            ipv6_dst_tracking
                                inner_ipv6_flow_label              ipv6_flow_label
                                inner_ipv6_flow_label_count        ipv6_flow_label_count
                                inner_ipv6_flow_label_mode         ipv6_flow_label_mode
                                inner_ipv6_flow_label_step         ipv6_flow_label_step
                                inner_ipv6_flow_label_tracking     ipv6_flow_label_tracking
                                inner_ipv6_frag_id                 ipv6_frag_id
                                inner_ipv6_frag_id_mode            ipv6_frag_id_mode
                                inner_ipv6_frag_id_step            ipv6_frag_id_step
                                inner_ipv6_frag_id_count           ipv6_frag_id_count
                                inner_ipv6_frag_id_tracking        ipv6_frag_id_tracking
                                inner_ipv6_frag_more_flag          ipv6_frag_more_flag
                                inner_ipv6_frag_more_flag_mode     ipv6_frag_more_flag_mode
                                inner_ipv6_frag_more_flag_tracking ipv6_frag_more_flag_tracking
                                inner_ipv6_frag_offset             ipv6_frag_offset
                                inner_ipv6_frag_offset_count       ipv6_frag_offset_count
                                inner_ipv6_frag_offset_mode        ipv6_frag_offset_mode
                                inner_ipv6_frag_offset_step        ipv6_frag_offset_step
                                inner_ipv6_frag_offset_tracking    ipv6_frag_offset_tracking
                                inner_ipv6_hop_limit               ipv6_hop_limit
                                inner_ipv6_hop_limit_count         ipv6_hop_limit_count
                                inner_ipv6_hop_limit_mode          ipv6_hop_limit_mode
                                inner_ipv6_hop_limit_step          ipv6_hop_limit_step
                                inner_ipv6_hop_limit_tracking      ipv6_hop_limit_tracking
                                inner_ipv6_traffic_class           ipv6_traffic_class
                                inner_ipv6_traffic_class_count     ipv6_traffic_class_count
                                inner_ipv6_traffic_class_mode      ipv6_traffic_class_mode
                                inner_ipv6_traffic_class_step      ipv6_traffic_class_step
                                inner_ipv6_traffic_class_tracking  ipv6_traffic_class_tracking
                                inner_ipv6_src_addr                ipv6_src_addr
                                inner_ipv6_src_count               ipv6_src_count
                                inner_ipv6_src_mode                ipv6_src_mode
                                inner_ipv6_src_step                ipv6_src_step
                                inner_ipv6_src_tracking            ipv6_src_tracking
                            }
                            
                            set ip_config_proc "540trafficL3IpV6"
                            set local_l3_proto "ipv6"
                        }
                    
                        set args ""
                
                        foreach param_ipvx [array names ipvX_param_mapping] {
                            if {![info exists $param_ipvx]} {
                                continue
                            }
                            
                            set param_ipvx_val [set $param_ipvx]
                            
                            lappend args -$ipvX_param_mapping($param_ipvx) $param_ipvx_val
                        }
                        
                        if {[llength $args] > 0} {
                            lappend args -mode modify -handle $gre_next_stack \
                                    -l3_protocol $local_l3_proto
                            
                            if {$local_l3_proto == "ipv4"} {
                                set _cmd {$ip_config_proc $args $opt_args_ipv4 $opt_args_ipv4_qos $opt_args_ipv4_noqos $args}
                            } else {
                                set _cmd {$ip_config_proc $args $opt_args_ipv6 $args}
                            }
                            
                            if {[catch {eval $_cmd} err]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Internal error on '$ip_config_proc $args' -  $err"
                                return $returnList
                            }
                            
                            if {[keylget err status] != $::SUCCESS} {
                                return $err
                            }
                        }
                    }
                }
            }
        }
    }
    
    return $returnList
}



proc ::ixia::540trafficL4Udp { args opt_args } {
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    # Insert here the parameter that allows this funciton to configure
    # For example, l3_protocol must be ipv4 in order to configure ipv4 stuff
    if {![info exists l4_protocol]} {
        # Don't configure because it's not requested
        return $returnList
    }
    
    
    if {$l4_protocol != "udp"} {
        if {$mode == "create"} {
            if {$l4_protocol != "dhcp" && $l4_protocol != "rip"} {
                # Don't configure because it's not udp encap
                return $returnList
            }
        } else {
            # Don't configure because it's not udp encap
            return $returnList
        }
    }
    
    if {$l4_protocol != "udp"} {
        set l4_protocol "udp"
    }
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "stack_hls" "stack_ce"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set handle_type [keylget ret_val value]
    
    set ti_handle [ixNetworkGetParentObjref $handle trafficItem]
    
    set ret_val [540IxNetTrafficItemGetFirstTxPort $handle]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set vport_handle [keylget ret_val value]
    
    set ret_code [ixNetworkGetPortFromObj $vport_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to extract port handle from\
                $vport_handle. [keylget ret_code log]"
        return $returnList
    } 
    
    set real_port_h [keylget ret_code port_handle]
    
    # pt == protocolTemplate
    # Insert here the stack(header) protocol templates that this procedure will configure
    # Remove the ipv6 and none entries. They are just an example.
    array set encapsulation_pt_map {
        udp                         {::ixNet::OBJ-/traffic/protocolTemplate:"udp"}
    }

    # This array contains a mapping between the stack field names and an hlt firendly name
    # The hlt friendly name is not an HLT parameter name. It is used to access field names
    # without the errors that spaced names could insert.
    # Remove the two entries. They are just examples.
    
    array set hlt_ixn_field_name_map {
            udp_src_port_field             udp.header.srcPort-1
            udp_dst_port_field             udp.header.dstPort-2
            udp_length_field               udp.header.length-3
            udp_checksum_field             udp.header.checksum-4
    }
    
    set use_name_instead_of_displayname 3
    
    # Array that establishes what fields will be configured for each protocol template.
    # The fields associated with each protocol template are the hlt friendly names from hlt_ixn_field_name_map
    # Remove the entries, they are just an example
    array set protocol_template_field_map [list                                                                   \
        ::ixNet::OBJ-/traffic/protocolTemplate:"udp"                   [list                                      \
                                                                         udp_src_port_field                       \
                                                                         udp_dst_port_field                       \
                                                                         udp_length_field                         \
                                                                         udp_checksum_field                       \
                                                                       ]                                          \
    ]
                                                                          
    # The following lists are the actual mappings with the HLT parameters
    #
    # A list must be created for each field from hlt_ixn_field_name_map
    #
    # The first column is the HLT parameter name
    #
    # All IxNetwork fields support a starting value, a mode (increment, decrement), a count, step etc.
    # This mapping will help build the parameter list for procedure 540TrafficStackFieldConfig
    # Procedure 540TrafficStackFieldConfig is the one that actually configures the ixnetwork field
    # based on the value/count/mode/step/tracking parameters
    #
    # The second column configures the class of parameters that the HLT parameter belongs to value/count/mode/step/tracking
    # count/mode/step/tracking will allways have this fixed values
    # Instead of 'value' there can be various forms (value_hex, value_hex_2_int, value_mac....)
    # These 'values' will be interpreted in 540TrafficStackFieldConfig and handled accordingly
    # If your parameter requires a 'value' type that is not present, add it in 540TrafficStackFieldConfig and use it
    #
    # The third column is for special cases.
    # For example: by default, if mode is 'incr' or 'decr', the value and step must be transformed to integer.
    # If this is not the case for your parameter (ip_src_addr field in ixnetwork must remain an ipv4 address even if mode is incr or decr)
    # you can pass {p_format strict}. This will cause 540TrafficStackFieldConfig procedure to preserve the ipv4 format of the parameter even if mode is incr or decr.
    #
    # Another example is the {translate _some_translation_array}. This will cause the hlt parameter value to be
    # translated to another value as specified by the mapping from _some_translation_array
    #
    # You can add new ways to use the 'extra' column

    
    #       hlt_param                       param_class               extra
    set udp_src_port_field {
            udp_src_port                    value                     _none
            udp_src_port_count              count                     _none
            udp_src_port_mode               mode                      _none
            udp_src_port_step               step                      _none
            udp_src_port_tracking           tracking                  _none
    }
    
    set udp_dst_port_field {
            udp_dst_port                    value                     _none
            udp_dst_port_count              count                     _none
            udp_dst_port_mode               mode                      _none
            udp_dst_port_step               step                      _none
            udp_dst_port_tracking           tracking                  _none
    }
    
    set udp_length_field {
            udp_length                      value                     _none
            udp_length_count                count                     _none
            udp_length_mode                 mode                      _none
            udp_length_step                 step                      _none
            udp_length_tracking             tracking                  _none
    }
    
    if {[info exists udp_checksum] && $udp_checksum == 0} {
        if {![info exists udp_checksum_value]} {
            set udp_checksum_value 0
        } 
        set udp_checksum_mode "fixed"
    } else {
        set udp_checksum_mode "auto"
    }
    set udp_checksum_field {
            udp_checksum_value              value_hex                 {p_format strict}
            udp_checksum_mode               mode                      _none
            udp_checksum_value_tracking     tracking                  _none
    }
    
    # In this section you must configure the protocol templates that will be added/configured
    # based on the indicators from your example. (l3_protocol, l2_encap.... ipv6_extensions...)
    set protocol_template_list $encapsulation_pt_map($l4_protocol)
    
    switch -- $mode {
        "create" {
            
            # This procedure will remove the protocol templates that do not apply for this configElement
            # this is the case where multiple configElements exist on one traffic item.
            set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set protocol_template_list [keylget ret_code pt_list]
            
            # Build your own procedure 540IxNetTrafficProcThatAddsHeaders and change the name of course :)
            # This procedure must take the protocol templates and add them in the packet based on some rules
            # For example, if the protocol templates are layer3
            #   1. see if the template wasn't already added
            #   2. if it wasn't find the last L3 header and add after it
            #   3. If no L3 headers present, add after last L2
            #   ... make your own particular rules
            
            set ret_code [540IxNetTrafficL4AddHeaders $handle $handle_type $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            # The procedure MUST return the list of stacks (instances of protocol templates) that were added
            set stack_handles [keylget ret_code handle]
        }
        "modify" {
        
            # For modify mode search for the headers and modify them
            # if there are any parameters for them
            
            # if the handle is a stack, no need to search known headers. Modify the stacks.
            
            switch -- $handle_type {
                "traffic_item" {
                    # Get config element
                    set retrieve [540getConfigElementOrHighLevelStream $handle]
                    if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
                    set ce_hls_handle [keylget retrieve handle]
                }
                "config_element" {
                    set ce_hls_handle $handle
                }
                "high_level_stream" {
                    set ce_hls_handle $handle
                }
                "stack_ce" -
                "stack_hls" {
                    set stack_handles $handle
                }
            }
            
            if {$handle_type == "traffic_item" || $handle_type == "config_element" || \
                    $handle_type == "high_level_stream"} {
                
                # Again, protocol_template_list must be present
                set ret_code [540IxNetFindStacksAll $ce_hls_handle $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set stack_handles ""
                foreach tmp_pt_modify $protocol_template_list {
                    set tmp_stack_list [keylget ret_code $tmp_pt_modify]
                    
                    if {[llength $tmp_stack_list] > 0} {
                        lappend stack_handles [lindex $tmp_stack_list 0]
                    }
                    
                    catch {unset tmp_stack_list}
                }
                
                catch {unset tmp_pt_modify}
            }
        }
        "append_header" -
        "prepend_header" -
        "replace_header" {
            if {$handle_type != "stack_hls" && $handle_type != "stack_ce"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $handle handle type $handle_type for mode $mode."
                return $returnList
            }
            
            switch -- $mode {
                "append_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetAppendProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetAppendProtocolTemplate $protocol_template_list $handle"
                    }
                    
                }
                "prepend_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetPrependProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetPrependProtocolTemplate $protocol_template_list $handle"
                    }
                }
                "replace_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate $protocol_template_list $handle"
                    }
                }
            }
            
            set ret_code [eval $tmp_cmd]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $tmp_cmd. [keylget ret_code log]"
                return $returnList
            }
            
            set stack_handles [keylget ret_code handle]
        }
    }
    
    # Build the headers_multiple_instances array with the protocol templates that might be added more than once
    # For example, VLAN protocl temaplate is added more than once when QinQ
    # Add a key word that will be used as index.
    # The index will be incremented every time the template is configured
    # The index will be used to extract the value of a parameter from a list of values
    
    #   Header protocol template                                            header index
    array set headers_multiple_instances {
    }
    
    # The rest is standard
    
    if {![info exists stack_handles]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Variable stack_handles is missing."
        return $returnList
    }
    
    set ret_code [540TrafficStackGod $stack_handles]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to configure stacks $stack_handles. [keylget ret_code log]"
        return $ret_code
    }
    
    return $returnList
}


proc ::ixia::540trafficL4Dhcp { args opt_args} {
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    # Insert here the parameter that allows this funciton to configure
    # For example, l3_protocol must be ipv4 in order to configure ipv4 stuff
    if {![info exists l4_protocol]} {
        # Don't configure because it's not requested
        return $returnList
    }
    
    
    if {$l4_protocol != "dhcp"} {
        # Don't configure because it's not an ipv6 encap
        return $returnList
    }
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "stack_hls" "stack_ce"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    if {[info exists dhcp_server_host_name] && $dhcp_server_host_name == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error: -dhcp_server_host_name parameter cannot be empty"
        return $returnList
    }
    
    set handle_type [keylget ret_val value]
    
    set ti_handle [ixNetworkGetParentObjref $handle trafficItem]
    
    set ret_val [540IxNetTrafficItemGetFirstTxPort $handle]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set vport_handle [keylget ret_val value]
    
    set ret_code [ixNetworkGetPortFromObj $vport_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to extract port handle from\
                $vport_handle. [keylget ret_code log]"
        return $returnList
    } 
    
    set real_port_h [keylget ret_code port_handle]
    
    # pt == protocolTemplate
    # Insert here the stack(header) protocol templates that this procedure will configure
    # Remove the ipv6 and none entries. They are just an example.
    array set encapsulation_pt_map {
        dhcp                        {::ixNet::OBJ-/traffic/protocolTemplate:"dhcp"}
    }

    # This array contains a mapping between the stack field names and an hlt firendly name
    # The hlt friendly name is not an HLT parameter name. It is used to access field names
    # without the errors that spaced names could insert.
    # Remove the two entries. They are just examples.
    
    array set hlt_ixn_field_name_map {
            message_op_code_field                   op
            hardware_type_field                     htype
            hardware_address_length_field           hlen
            hops_field                              hops
            transaction_id_field                    xid
            seconds_elapsed_field                   secs
            broadcast_flag_field                    bflag
            client_ip_address_field                 ciaddr
            your_ip_address_field                   yiaddr
            server_ip_address_field                 siaddr
            relay_agent_ip_address_field            giaddr
            client_hardware_address_field           chaddr
            optional_server_hostname_field          sname
            boot_file_name_field                    file
            magic_cookie_field                      magic_cookie
    }
    
    set use_name_instead_of_displayname 1
    
    # Array that establishes what fields will be configured for each protocol template.
    # The fields associated with each protocol template are the hlt friendly names from hlt_ixn_field_name_map
    # Remove the entries, they are just an example
    array set protocol_template_field_map [list                                                                  \
        ::ixNet::OBJ-/traffic/protocolTemplate:"dhcp"                   [list                                    \
                                                                         message_op_code_field                   \
                                                                         hardware_type_field                     \
                                                                         hardware_address_length_field           \
                                                                         hops_field                              \
                                                                         transaction_id_field                    \
                                                                         seconds_elapsed_field                   \
                                                                         broadcast_flag_field                    \
                                                                         client_ip_address_field                 \
                                                                         your_ip_address_field                   \
                                                                         server_ip_address_field                 \
                                                                         relay_agent_ip_address_field            \
                                                                         client_hardware_address_field           \
                                                                         optional_server_hostname_field          \
                                                                         boot_file_name_field                    \
                                                                         magic_cookie_field                      \
                                                                        ]                                        \
    ]

    # The following lists are the actual mappings with the HLT parameters
    #
    # A list must be created for each field from hlt_ixn_field_name_map
    #
    # The first column is the HLT parameter name
    #
    # All IxNetwork fields support a starting value, a mode (increment, decrement), a count, step etc.
    # This mapping will help build the parameter list for procedure 540TrafficStackFieldConfig
    # Procedure 540TrafficStackFieldConfig is the one that actually configures the ixnetwork field
    # based on the value/count/mode/step/tracking parameters
    #
    # The second column configures the class of parameters that the HLT parameter belongs to value/count/mode/step/tracking
    # count/mode/step/tracking will allways have this fixed values
    # Instead of 'value' there can be various forms (value_hex, value_hex_2_int, value_mac....)
    # These 'values' will be interpreted in 540TrafficStackFieldConfig and handled accordingly
    # If your parameter requires a 'value' type that is not present, add it in 540TrafficStackFieldConfig and use it
    #
    # The third column is for special cases.
    # For example: by default, if mode is 'incr' or 'decr', the value and step must be transformed to integer.
    # If this is not the case for your parameter (ip_src_addr field in ixnetwork must remain an ipv4 address even if mode is incr or decr)
    # you can pass {p_format strict}. This will cause 540TrafficStackFieldConfig procedure to preserve the ipv4 format of the parameter even if mode is incr or decr.
    #
    # Another example is the {translate _some_translation_array}. This will cause the hlt parameter value to be
    # translated to another value as specified by the mapping from _some_translation_array
    #
    # You can add new ways to use the 'extra' column
    
    #       hlt_param                       param_class               extra
    set message_op_code_field {
        dhcp_operation_code                 value_translate              {array_map message_op_code_field_map}
        dhcp_operation_code_mode            mode                          _none
        dhcp_operation_code_tracking        tracking                      _none
    }
    
    array set message_op_code_field_map {
        reply       2
        request     1
    }
    
    set hardware_type_field {
        dhcp_hw_type                        value                         _none
        dhcp_hw_type_count                  count                         _none
        dhcp_hw_type_mode                   mode                          _none
        dhcp_hw_type_step                   step                          _none
        dhcp_hw_type_tracking               tracking                      _none
    }
    
    set hardware_address_length_field {
        dhcp_hw_len                         value                         _none
        dhcp_hw_len_count                   count                         _none
        dhcp_hw_len_mode                    mode                          _none
        dhcp_hw_len_step                    step                          _none
        dhcp_hw_len_tracking                tracking                      _none
    }
    
    set hops_field {
        dhcp_hops                           value                         _none
        dhcp_hops_count                     count                         _none
        dhcp_hops_mode                      mode                          _none
        dhcp_hops_step                      step                          _none
        dhcp_hops_tracking                  tracking                      _none
    }
    
    set transaction_id_field {
        dhcp_transaction_id                 value                         _none
        dhcp_transaction_id_count           count                         _none
        dhcp_transaction_id_mode            mode                          _none
        dhcp_transaction_id_step            step                          _none
        dhcp_transaction_id_tracking        tracking                      _none
    }
    
    set seconds_elapsed_field {
        dhcp_seconds                        value                         _none
        dhcp_seconds_count                  count                         _none
        dhcp_seconds_mode                   mode                          _none
        dhcp_seconds_step                   step                          _none
        dhcp_seconds_tracking               tracking                      _none
    }
    
    set broadcast_flag_field {
        dhcp_flags                          value                         {translate broadcast_flag_field_map}
        dhcp_flags_mode                     mode                          _none
        dhcp_flags_tracking                 tracking                      _none
    }
    
    array set broadcast_flag_field_map {
        broadcast       32768
        no_broadcast    0
    }
    
    set client_ip_address_field {
        dhcp_client_ip_addr                 value_ipv4                    {p_format strict}
        dhcp_client_ip_addr_count           count                         _none
        dhcp_client_ip_addr_mode            mode                          _none
        dhcp_client_ip_addr_step            step                          _none
        dhcp_client_ip_addr_tracking        tracking                      _none
    }
    
    set your_ip_address_field {
        dhcp_your_ip_addr                   value_ipv4                    {p_format strict}
        dhcp_your_ip_addr_count             count                         _none
        dhcp_your_ip_addr_mode              mode                          _none
        dhcp_your_ip_addr_step              step                          _none
        dhcp_your_ip_addr_tracking          tracking                      _none
    }
    
    set server_ip_address_field {
        dhcp_server_ip_addr                 value_ipv4                    {p_format strict}
        dhcp_server_ip_addr_count           count                         _none
        dhcp_server_ip_addr_mode            mode                          _none
        dhcp_server_ip_addr_step            step                          _none
        dhcp_server_ip_addr_tracking        tracking                      _none
    }
    
    set relay_agent_ip_address_field {
        dhcp_relay_agent_ip_addr            value_ipv4                    {p_format strict}
        dhcp_relay_agent_ip_addr_count      count                         _none
        dhcp_relay_agent_ip_addr_mode       mode                          _none
        dhcp_relay_agent_ip_addr_step       step                          _none
        dhcp_relay_agent_ip_addr_tracking   tracking                      _none
    }
    
    set client_hardware_address_field {
        dhcp_client_hw_addr                 value_hex                     {p_format strict}
        dhcp_client_hw_addr_count           count                         _none
        dhcp_client_hw_addr_mode            mode                          _none
        dhcp_client_hw_addr_step            step                          _none
        dhcp_client_hw_addr_tracking        tracking                      _none
    }
    
    if {[info exists dhcp_server_host_name]} {
        set dhcp_server_host_name_mode "fixed"
    }
    
    set optional_server_hostname_field {
        dhcp_server_host_name               value_string_to_ascii_hex     {p_format strict}
        dhcp_server_host_name_mode          mode                          _none
        dhcp_server_host_name_tracking      tracking                      _none
    }
    
    if {[info exists dhcp_boot_filename]} {
        set dhcp_boot_filename_mode "fixed"
    }
    
    set boot_file_name_field {
        dhcp_boot_filename                  value_string_to_ascii_hex     {p_format strict}
        dhcp_boot_filename_mode             mode                          _none
        dhcp_boot_filename_tracking         tracking                      _none
    }
    
    set magic_cookie_field {
        dhcp_magic_cookie                   value_hex                     {p_format strict}
        dhcp_magic_cookie_count             count                         _none
        dhcp_magic_cookie_mode              mode                          _none
        dhcp_magic_cookie_step              step                          _none
        dhcp_magic_cookie_tracking          tracking                      _none
    }
    
    # In this section you must configure the protocol templates that will be added/configured
    # based on the indicators from your example. (l3_protocol, l2_encap.... ipv6_extensions...)
    set protocol_template_list $encapsulation_pt_map($l4_protocol)    
    
    switch -- $mode {
        "create" {
            
            # This procedure will remove the protocol templates that do not apply for this configElement
            # this is the case where multiple configElements exist on one traffic item.
            set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set protocol_template_list [keylget ret_code pt_list]
            
            # Build your own procedure 540IxNetTrafficProcThatAddsHeaders and change the name of course :)
            # This procedure must take the protocol templates and add them in the packet based on some rules
            # For example, if the protocol templates are layer3
            #   1. see if the template wasn't already added
            #   2. if it wasn't find the last L3 header and add after it
            #   3. If no L3 headers present, add after last L2
            #   ... make your own particular rules
            
            set ret_code [540IxNetTrafficL4AddHeaders $handle $handle_type $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            # The procedure MUST return the list of stacks (instances of protocol templates) that were added
            set stack_handles [keylget ret_code handle]
        }
        "modify" {
        
            # For modify mode search for the headers and modify them
            # if there are any parameters for them
            
            # if the handle is a stack, no need to search known headers. Modify the stacks.
            
            switch -- $handle_type {
                "traffic_item" {
                    # Get config element
                    set retrieve [540getConfigElementOrHighLevelStream $handle]
                    if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
                    set ce_hls_handle [keylget retrieve handle]
                }
                "config_element" {
                    set ce_hls_handle $handle
                }
                "high_level_stream" {
                    set ce_hls_handle $handle
                }
                "stack_ce" -
                "stack_hls" {
                    set stack_handles $handle
                }
            }
            
            if {$handle_type == "traffic_item" || $handle_type == "config_element" || \
                    $handle_type == "high_level_stream"} {
                
                # Again, protocol_template_list must be present
                set ret_code [540IxNetFindStacksAll $ce_hls_handle $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set stack_handles ""
                foreach tmp_pt_modify $protocol_template_list {
                    set tmp_stack_list [keylget ret_code $tmp_pt_modify]
                    
                    if {[llength $tmp_stack_list] > 0} {
                        lappend stack_handles [lindex $tmp_stack_list 0]
                    }
                    
                    catch {unset tmp_stack_list}
                }
                
                catch {unset tmp_pt_modify}
            }
        }
        "append_header" -
        "prepend_header" -
        "replace_header" {
            if {$handle_type != "stack_hls" && $handle_type != "stack_ce"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $handle handle type $handle_type for mode $mode."
                return $returnList
            }
            
            switch -- $mode {
                "append_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetAppendProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetAppendProtocolTemplate $protocol_template_list $handle"
                    }
                    
                }
                "prepend_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetPrependProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetPrependProtocolTemplate $protocol_template_list $handle"
                    }
                }
                "replace_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate $protocol_template_list $handle"
                    }
                }
            }
            
            set ret_code [eval $tmp_cmd]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $tmp_cmd. [keylget ret_code log]"
                return $returnList
            }
            
            set stack_handles [keylget ret_code handle]
        }
    }
    
    # Build the headers_multiple_instances array with the protocol templates that might be added more than once
    # For example, VLAN protocl temaplate is added more than once when QinQ
    # Add a key word that will be used as index.
    # The index will be incremented every time the template is configured
    # The index will be used to extract the value of a parameter from a list of values
    
    #   Header protocol template                                            header index
    array set headers_multiple_instances {
    }
    
    # The rest is standard
    
    if {![info exists stack_handles]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Variable stack_handles is missing."
        return $returnList
    }
    
    set ret_code [540TrafficStackGod $stack_handles]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to configure stacks $stack_handles. [keylget ret_code log]"
        return $ret_code
    }
    
    return $returnList
}


proc ::ixia::540trafficL4Rip { args opt_args} {
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    # Insert here the parameter that allows this funciton to configure
    # For example, l3_protocol must be ipv4 in order to configure ipv4 stuff
    if {![info exists l4_protocol]} {
        # Don't configure because it's not requested
        return $returnList
    }
    
    
    if {$l4_protocol != "rip"} {
        # Don't configure because it's not a rip stack
        return $returnList
    }
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "stack_hls" "stack_ce"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set handle_type [keylget ret_val value]
    
    set ti_handle [ixNetworkGetParentObjref $handle trafficItem]
    
    set ret_val [540IxNetTrafficItemGetFirstTxPort $handle]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set vport_handle [keylget ret_val value]
    
    set ret_code [ixNetworkGetPortFromObj $vport_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to extract port handle from\
                $vport_handle. [keylget ret_code log]"
        return $returnList
    } 
    
    set real_port_h [keylget ret_code port_handle]
    
#     -rip_version                        CHOICES 1 2
    
    if {[info exists rip_version] && $rip_version == 1} {
        set l4_protocol "ripv1"
    } else {
        set l4_protocol "ripv2"
    }
    
    # pt == protocolTemplate
    # Insert here the stack(header) protocol templates that this procedure will configure
    # Remove the ipv6 and none entries. They are just an example.
    array set encapsulation_pt_map {
        ripv1                        {::ixNet::OBJ-/traffic/protocolTemplate:"rip1"}
        ripv2                        {::ixNet::OBJ-/traffic/protocolTemplate:"rip2"}
    }

    # This array contains a mapping between the stack field names and an hlt firendly name
    # The hlt friendly name is not an HLT parameter name. It is used to access field names
    # without the errors that spaced names could insert.
    # Remove the two entries. They are just examples.
    
    array set hlt_ixn_field_name_map [list \
           rip_command_field              [list 0 "Command"]        \
           rip_rte_afi_field              [list 1 afi]              \
           rip_unused1_v1_field           [list 0 "Unused1"]        \
           rip_rte_unused2_v1_field       [list 0 "Unused2"]        \
           rip_rte_ipv4_addr_field        [list 0 "IPv4 address"]   \
           rip_rte_unused3_v1_field       [list 0 "Unused3"]        \
           rip_rte_unused4_v1_field       [list 0 "Unused4"]        \
           rip_rte_metric_field           [list 0 "Metric"]         \
           rip_unused_v2_field            [list 0 "Unused"]         \
           rip_rte_route_tag_v2_field     [list 0 "Route tag"]      \
           rip_rte_subnet_mask_v2_field   [list 0 "Subnet mask"]    \
           rip_rte_next_hop_v2_field      [list 0 "Next hop"]       \
    ]
    
    
    
    # Configure variable 'use_name_instead_of_displayname' to '1' if the mapping is done with the 
    # -name property of the field object instead of the -displayName (the example above uses -displayName)
    # or 2 if hlt_ixn_field_name_map contains the decision whether to use name or displayName
    set use_name_instead_of_displayname 2
    
    # Array that establishes what fields will be configured for each protocol template.
    # The fields associated with each protocol template are the hlt friendly names from hlt_ixn_field_name_map
    # Remove the entries, they are just an example
    array set protocol_template_field_map [list                                                         \
        ::ixNet::OBJ-/traffic/protocolTemplate:"rip1"                   [list                           \
                                                                         rip_command_field              \
                                                                         rip_unused1_v1_field           \
                                                                         rip_rte_afi_field              \
                                                                         rip_rte_unused2_v1_field       \
                                                                         rip_rte_ipv4_addr_field        \
                                                                         rip_rte_unused3_v1_field       \
                                                                         rip_rte_unused4_v1_field       \
                                                                         rip_rte_metric_field           \
                                                                        ]                               \
        ::ixNet::OBJ-/traffic/protocolTemplate:"rip2"                   [list                           \
                                                                         rip_command_field              \
                                                                         rip_unused_v2_field            \
                                                                         rip_rte_afi_field              \
                                                                         rip_rte_ipv4_addr_field        \
                                                                         rip_rte_metric_field           \
                                                                         rip_rte_route_tag_v2_field     \
                                                                         rip_rte_subnet_mask_v2_field   \
                                                                         rip_rte_next_hop_v2_field      \
                                                                        ]                               \
    ]

    array set multiple_level_fields [list                                                               \
        ::ixNet::OBJ-/traffic/protocolTemplate:"rip1"                   [list                           \
                                                                         rip_rte_afi_field              \
                                                                         rip_rte_unused2_v1_field       \
                                                                         rip_rte_ipv4_addr_field        \
                                                                         rip_rte_unused3_v1_field       \
                                                                         rip_rte_unused4_v1_field       \
                                                                         rip_rte_metric_field           \
                                                                        ]                               \
        ::ixNet::OBJ-/traffic/protocolTemplate:"rip2"                   [list                           \
                                                                         rip_rte_afi_field              \
                                                                         rip_rte_ipv4_addr_field        \
                                                                         rip_rte_metric_field           \
                                                                         rip_rte_route_tag_v2_field     \
                                                                         rip_rte_subnet_mask_v2_field   \
                                                                         rip_rte_next_hop_v2_field      \
                                                                        ]                               \
    ]
    
    # The following lists are the actual mappings with the HLT parameters
    #
    # A list must be created for each field from hlt_ixn_field_name_map
    #
    # The first column is the HLT parameter name
    #
    # All IxNetwork fields support a starting value, a mode (increment, decrement), a count, step etc.
    # This mapping will help build the parameter list for procedure 540TrafficStackFieldConfig
    # Procedure 540TrafficStackFieldConfig is the one that actually configures the ixnetwork field
    # based on the value/count/mode/step/tracking parameters
    #
    # The second column configures the class of parameters that the HLT parameter belongs to value/count/mode/step/tracking
    # count/mode/step/tracking will allways have this fixed values
    # Instead of 'value' there can be various forms (value_hex, value_hex_2_int, value_mac....)
    # These 'values' will be interpreted in 540TrafficStackFieldConfig and handled accordingly
    # If your parameter requires a 'value' type that is not present, add it in 540TrafficStackFieldConfig and use it
    #
    # The third column is for special cases.
    # For example: by default, if mode is 'incr' or 'decr', the value and step must be transformed to integer.
    # If this is not the case for your parameter (ip_src_addr field in ixnetwork must remain an ipv4 address even if mode is incr or decr)
    # you can pass {p_format strict}. This will cause 540TrafficStackFieldConfig procedure to preserve the ipv4 format of the parameter even if mode is incr or decr.
    #
    # Another example is the {translate _some_translation_array}. This will cause the hlt parameter value to be
    # translated to another value as specified by the mapping from _some_translation_array
    #
    # You can add new ways to use the 'extra' column

    #       hlt_param                 param_class             extra
    set rip_command_field {
        rip_command                   value                   {translate rip_command_map}
        rip_command_mode              mode                    _none
        rip_command_tracking          tracking                _none
    }
    
    array set rip_command_map {
        request         1
        response        2
        trace_on        3
        trace_off       4
        reserved        5
    }
    
    set rip_rte_afi_field {
        rip_rte_addr_family_id            value_hex                     {p_format strict}
        rip_rte_addr_family_id_count      count                         _none
        rip_rte_addr_family_id_mode       mode                          _none
        rip_rte_addr_family_id_step       step                          _none
        rip_rte_addr_family_id_tracking   tracking                      _none
    }
    
    set rip_unused1_v1_field {
        rip_unused                    value                         _none
        rip_unused_count              count                         _none
        rip_unused_mode               mode                          _none
        rip_unused_step               step                          _none
        rip_unused_tracking           tracking                      _none
    }
    
    set rip_rte_unused2_v1_field {
        rip_rte_v1_unused2            value                         _none
        rip_rte_v1_unused2_count      count                         _none
        rip_rte_v1_unused2_mode       mode                          _none
        rip_rte_v1_unused2_step       step                          _none
        rip_rte_v1_unused2_tracking   tracking                      _none
    }
    
    set rip_rte_ipv4_addr_field {
        rip_rte_ipv4_addr             value_ipv4                    {p_format strict}
        rip_rte_ipv4_addr_count       count                         _none
        rip_rte_ipv4_addr_mode        mode                          _none
        rip_rte_ipv4_addr_step        step                          _none
        rip_rte_ipv4_addr_tracking    tracking                      _none
    }
    
    set rip_rte_unused3_v1_field {
        rip_rte_v1_unused3            value                         _none
        rip_rte_v1_unused3_count      count                         _none
        rip_rte_v1_unused3_mode       mode                          _none
        rip_rte_v1_unused3_step       step                          _none
        rip_rte_v1_unused3_tracking   tracking                      _none
    }
    
    set rip_rte_unused4_v1_field {
        rip_rte_v1_unused4            value                         _none
        rip_rte_v1_unused4_count      count                         _none
        rip_rte_v1_unused4_mode       mode                          _none
        rip_rte_v1_unused4_step       step                          _none
        rip_rte_v1_unused4_tracking   tracking                      _none
    }
    
    set rip_rte_metric_field {
        rip_rte_metric                value                         _none
        rip_rte_metric_count          count                         _none
        rip_rte_metric_mode           mode                          _none
        rip_rte_metric_step           step                          _none
        rip_rte_metric_tracking       tracking                      _none
    }
    
    set rip_unused_v2_field {
        rip_unused                    value                         _none
        rip_unused_count              count                         _none
        rip_unused_mode               mode                          _none
        rip_unused_step               step                          _none
        rip_unused_tracking           tracking                      _none
    }
    
    set rip_rte_route_tag_v2_field {
        rip_rte_v2_route_tag          value                         _none
        rip_rte_v2_route_tag_count    count                         _none
        rip_rte_v2_route_tag_mode     mode                          _none
        rip_rte_v2_route_tag_step     step                          _none
        rip_rte_v2_route_tag_tracking tracking                      _none
    }
    
    set rip_rte_subnet_mask_v2_field {
        rip_rte_v2_subnet_mask                 value_ipv4           {p_format strict}
        rip_rte_v2_subnet_mask_count           count                _none
        rip_rte_v2_subnet_mask_mode            mode                 _none
        rip_rte_v2_subnet_mask_step            step                 _none
        rip_rte_v2_subnet_mask_tracking        tracking             _none
    }
    
    set rip_rte_next_hop_v2_field {
        rip_rte_v2_next_hop           value_ipv4                    {p_format strict}
        rip_rte_v2_next_hop_count     count                         _none
        rip_rte_v2_next_hop_mode      mode                          _none
        rip_rte_v2_next_hop_step      step                          _none
        rip_rte_v2_next_hop_tracking  tracking                      _none
    }
    
    # In this section you must configure the protocol templates that will be added/configured
    # based on the indicators from your example. (l3_protocol, l2_encap.... ipv6_extensions...)
    set protocol_template_list $encapsulation_pt_map($l4_protocol)
    
    switch -- $mode {
        "create" {
            
            # This procedure will remove the protocol templates that do not apply for this configElement
            # this is the case where multiple configElements exist on one traffic item.
            set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set protocol_template_list [keylget ret_code pt_list]
            
            # Build your own procedure 540IxNetTrafficProcThatAddsHeaders and change the name of course :)
            # This procedure must take the protocol templates and add them in the packet based on some rules
            # For example, if the protocol templates are layer3
            #   1. see if the template wasn't already added
            #   2. if it wasn't find the last L3 header and add after it
            #   3. If no L3 headers present, add after last L2
            #   ... make your own particular rules
            
            set ret_code [540IxNetTrafficL4AddHeaders $handle $handle_type $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            # The procedure MUST return the list of stacks (instances of protocol templates) that were added
            set stack_handles [keylget ret_code handle]
        }
        "modify" {
        
            # For modify mode search for the headers and modify them
            # if there are any parameters for them
            
            # if the handle is a stack, no need to search known headers. Modify the stacks.
            
            switch -- $handle_type {
                "traffic_item" {
                    # Get config element
                    set retrieve [540getConfigElementOrHighLevelStream $handle]
                    if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
                    set ce_hls_handle [keylget retrieve handle]
                }
                "config_element" {
                    set ce_hls_handle $handle
                }
                "high_level_stream" {
                    set ce_hls_handle $handle
                }
                "stack_ce" -
                "stack_hls" {
                    set stack_handles $handle
                }
            }
            
            if {$handle_type == "traffic_item" || $handle_type == "config_element" || \
                    $handle_type == "high_level_stream"} {
                
                # Again, protocol_template_list must be present
                set ret_code [540IxNetFindStacksAll $ce_hls_handle $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set stack_handles ""
                foreach tmp_pt_modify $protocol_template_list {
                    set tmp_stack_list [keylget ret_code $tmp_pt_modify]
                    
                    if {[llength $tmp_stack_list] > 0} {
                        lappend stack_handles [lindex $tmp_stack_list 0]
                    }
                    
                    catch {unset tmp_stack_list}
                }
                
                catch {unset tmp_pt_modify}
            }
        }
        "append_header" -
        "prepend_header" -
        "replace_header" {
            if {$handle_type != "stack_hls" && $handle_type != "stack_ce"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $handle handle type $handle_type for mode $mode."
                return $returnList
            }
            
            switch -- $mode {
                "append_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetAppendProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetAppendProtocolTemplate $protocol_template_list $handle"
                    }
                    
                }
                "prepend_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetPrependProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetPrependProtocolTemplate $protocol_template_list $handle"
                    }
                }
                "replace_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate $protocol_template_list $handle"
                    }
                }
            }
            
            set ret_code [eval $tmp_cmd]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $tmp_cmd. [keylget ret_code log]"
                return $returnList
            }
            
            set stack_handles [keylget ret_code handle]
        }
    }
    
    # Build the headers_multiple_instances array with the protocol templates that might be added more than once
    # For example, VLAN protocl temaplate is added more than once when QinQ
    # Add a key word that will be used as index.
    # The index will be incremented every time the template is configured
    # The index will be used to extract the value of a parameter from a list of values
    
    #   Header protocol template                                            header index
    array set headers_multiple_instances {
    }
    
    # The optional arrays 'regex_disable_list', 'regex_disable_list' are used to configure the
    # -activeFieldChoice property of the fields that match the regexp expression
    # The 'regex_enable_list' array serves as an additional criteria to configure fields. If this 
    # array exists, the fields that do not match any of the regexp expressions will not be configured 
    # even if a mapping exists in hlt_ixn_field_name_map.
    # Useful to control fields that are controled with dropdown lists in the GUI. For example
    # the QOS field for IPv4 supports 'RAW' 'TOS' and 'Diff-Serv'. To select TOS using TCL API
    # the objects that configure TOS must be set to -activeFieldChoice 'true' and the fields that
    # configure RAW and Diff-Serv must be set to -activeFieldChoice 'false'.
    
    # The rest is standard
    
    if {![info exists stack_handles]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Variable stack_handles is missing."
        return $returnList
    }
    
    set ret_code [540TrafficStackGod $stack_handles]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to configure stacks $stack_handles. [keylget ret_code log]"
        return $ret_code
    }
    
    return $returnList
}


proc ::ixia::540trafficL4Igmp { args opt_args} {
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    # Insert here the parameter that allows this funciton to configure
    # For example, l3_protocol must be ipv4 in order to configure ipv4 stuff
    if {![info exists l4_protocol]} {
        # Don't configure because it's not requested
        return $returnList
    }
    
    
    if {$l4_protocol != "igmp"} {
        # Don't configure because it's not an ipv6 encap
        return $returnList
    }
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "stack_hls" "stack_ce"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set handle_type [keylget ret_val value]
    
    set ti_handle [ixNetworkGetParentObjref $handle trafficItem]
    
    set ret_val [540IxNetTrafficItemGetFirstTxPort $handle]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set vport_handle [keylget ret_val value]
    
    set ret_code [ixNetworkGetPortFromObj $vport_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to extract port handle from\
                $vport_handle. [keylget ret_code log]"
        return $returnList
    } 
    
    set real_port_h [keylget ret_code port_handle]
    
    # pt == protocolTemplate
    # Insert here the stack(header) protocol templates that this procedure will configure
    # Remove the ipv6 and none entries. They are just an example.
    array set encapsulation_pt_map {
        igmpv1                        {::ixNet::OBJ-/traffic/protocolTemplate:"igmpv1"}
        igmpv2                        {::ixNet::OBJ-/traffic/protocolTemplate:"igmpv2"}
        igmpv3q                       {::ixNet::OBJ-/traffic/protocolTemplate:"igmpv3MembershipQuery"}
        igmpv3r                       {::ixNet::OBJ-/traffic/protocolTemplate:"igmpv3MembershipReport"}
    }
    
    # This array contains a mapping between the stack field names and an hlt firendly name
    # The hlt friendly name is not an HLT parameter name. It is used to access field names
    # without the errors that spaced names could insert.
    # Remove the two entries. They are just examples.
    
    array set hlt_ixn_field_name_map {
            igmp_v1_msg_type_field                  type1
            igmp_v1_unused_field                    unused
            igmp_v1_checksum_field                  checksum
            igmp_v1_group_addr_field                group_address
            igmp_v2_msg_type_field                  type2
            igmp_v2_max_resp_time_field             max_resp_time
            igmp_v2_checksum_field                  checksum
            igmp_v2_group_addr_field                group_address
            igmp_v3q_msg_type_field                 type3mq
            igmp_v3q_max_resp_code_field            max_resp_code
            igmp_v3q_checksum_field                 checksum
            igmp_v3q_group_addr_field               group_address
            igmp_v3q_resv_field                     resv
            igmp_v3q_s_flag_field                   S
            igmp_v3q_qrv_field                      QRV
            igmp_v3q_qqic_field                     QQIC
            igmp_v3q_multicast_src_field            multicast_source
            igmp_v3r_msg_type_field                 type3mr
            igmp_v3r_resv1_field                    rsvd8
            igmp_v3r_checksum_field                 checksum
            igmp_v3r_resv2_field                    rsvd16
            igmp_v3r_record_type                    record_type
            igmp_v3r_aux_data_len                   aux_data_len
            igmp_v3r_multicast_address_field        group_source
            igmp_v3r_group_source_field             multicast_address
            igmp_v3r_length_field                   length
            igmp_v3r_data_field                     data
    }

    # Configure variable 'use_name_instead_of_displayname' to '1' if the mapping is done with the 
    # -name property of the field object instead of the -displayName (the example above uses -displayName)
    set use_name_instead_of_displayname 1 
    
    # Array that establishes what fields will be configured for each protocol template.
    # The fields associated with each protocol template are the hlt friendly names from hlt_ixn_field_name_map
    # Remove the entries, they are just an example
    array set protocol_template_field_map [list                                                               \
        {::ixNet::OBJ-/traffic/protocolTemplate:"igmpv1"}                [list                                 \
                                                                         igmp_v1_msg_type_field               \
                                                                         igmp_v1_unused_field                 \
                                                                         igmp_v1_checksum_field               \
                                                                         igmp_v1_group_addr_field             \
                                                                        ]                                     \
        {::ixNet::OBJ-/traffic/protocolTemplate:"igmpv2"}                [list                                 \
                                                                         igmp_v2_msg_type_field               \
                                                                         igmp_v2_max_resp_time_field          \
                                                                         igmp_v2_checksum_field               \
                                                                         igmp_v2_group_addr_field             \
                                                                        ]                                     \
        ::ixNet::OBJ-/traffic/protocolTemplate:"igmpv3MembershipReport" [list                                 \
                                                                         igmp_v3r_msg_type_field              \
                                                                         igmp_v3r_resv1_field                 \
                                                                         igmp_v3r_checksum_field              \
                                                                         igmp_v3r_resv2_field                 \
                                                                         igmp_v3r_record_type                 \
                                                                         igmp_v3r_aux_data_len                \
                                                                         igmp_v3r_group_source_field          \
                                                                         igmp_v3r_multicast_address_field     \
                                                                         igmp_v3r_length_field                \
                                                                         igmp_v3r_data_field                  \
                                                                        ]                                     \
        ::ixNet::OBJ-/traffic/protocolTemplate:"igmpv3MembershipQuery"  [list                                 \
                                                                         igmp_v3q_msg_type_field              \
                                                                         igmp_v3q_max_resp_code_field         \
                                                                         igmp_v3q_checksum_field              \
                                                                         igmp_v3q_group_addr_field            \
                                                                         igmp_v3q_resv_field                  \
                                                                         igmp_v3q_s_flag_field                \
                                                                         igmp_v3q_qrv_field                   \
                                                                         igmp_v3q_qqic_field                  \
                                                                         igmp_v3q_multicast_src_field         \
                                                                        ]                                     \
    ]
    
    
    # Some fields support multiple instances withing a stack.
    # For example, for 5 route table entrys there are 5 sets of route table entry fields
    # The 'multi level fields' are configured using lists (1 element for each level) 
    # Use the multiple_level_fields to specify which fields will be subject to this behavior.
    
    array set multiple_level_fields [list                                                               \
        ::ixNet::OBJ-/traffic/protocolTemplate:"igmpv3MembershipReport" [list                                 \
                                                                         igmp_v3r_record_type                 \
                                                                         igmp_v3r_aux_data_len                \
                                                                         igmp_v3r_multicast_address_field     \
                                                                         igmp_v3r_group_source_field          \
                                                                         igmp_v3r_length_field                \
                                                                         igmp_v3r_data_field                  \
                                                                        ]                                     \
        ::ixNet::OBJ-/traffic/protocolTemplate:"igmpv3MembershipQuery"  [list                                 \
                                                                         igmp_v3q_multicast_src_field         \
                                                                        ]                                     \
    ]
    
    array set multiple_level_fields_depth {
        igmp_v3r_multicast_address_field    1
    }
    
    array set multiple_level_fields_ro_counter {
        igmp_v3r_multicast_address_field    num_sources2
    }
    
    # The following lists are the actual mappings with the HLT parameters
    #
    # A list must be created for each field from hlt_ixn_field_name_map
    #
    # The first column is the HLT parameter name
    #
    # All IxNetwork fields support a starting value, a mode (increment, decrement), a count, step etc.
    # This mapping will help build the parameter list for procedure 540TrafficStackFieldConfig
    # Procedure 540TrafficStackFieldConfig is the one that actually configures the ixnetwork field
    # based on the value/count/mode/step/tracking parameters
    #
    # The second column configures the class of parameters that the HLT parameter belongs to value/count/mode/step/tracking
    # count/mode/step/tracking will allways have this fixed values
    # Instead of 'value' there can be various forms (value_hex, value_hex_2_int, value_mac....)
    # These 'values' will be interpreted in 540TrafficStackFieldConfig and handled accordingly
    # If your parameter requires a 'value' type that is not present, add it in 540TrafficStackFieldConfig and use it
    #
    # The third column is for special cases.
    # For example: by default, if mode is 'incr' or 'decr', the value and step must be transformed to integer.
    # If this is not the case for your parameter (ip_src_addr field in ixnetwork must remain an ipv4 address even if mode is incr or decr)
    # you can pass {p_format strict}. This will cause 540TrafficStackFieldConfig procedure to preserve the ipv4 format of the parameter even if mode is incr or decr.
    #
    # Another example is the {translate _some_translation_array}. This will cause the hlt parameter value to be
    # translated to another value as specified by the mapping from _some_translation_array
    #
    # You can add new ways to use the 'extra' column

    #       hlt_param                 param_class                   extra
    set igmp_v1_msg_type_field {
        igmp_type                        value                         _none
        igmp_msg_type_tracking        tracking                      _none
    }
    
    set igmp_v1_unused_field {
        igmp_unused                   value_hex                     {p_format strict}
        igmp_unused_count             count                         _none
        igmp_unused_mode              mode                          _none
        igmp_unused_step              step                          _none
        igmp_unused_tracking          tracking                      _none
    }
    
    set igmp_v1_checksum_field {
        igmp_checksum                 value_hex                     {multiple_cond {auto_if_false igmp_valid_checksum} {p_format strict}}
        igmp_checksum_count           count                         _none
        igmp_checksum_mode            mode                          _none
        igmp_checksum_step            step                          _none
        igmp_checksum_tracking        tracking                      _none
    }
    
    set igmp_v1_group_addr_field {
        igmp_group_addr               value_ipv4                    {p_format strict}
        igmp_group_count              count                         _none
        igmp_group_mode               mode                          {translate igmp_group_mode_map}
        igmp_group_step               step                          _none
        igmp_group_tracking           tracking                      _none
    }
    
    array set igmp_group_mode_map {
        fixed       fixed
        increment   incr
        decrement   decr
        list        list
    }
    
    set igmp_v2_msg_type_field {
        igmp_type                        value                         _none
        igmp_msg_type_tracking        tracking                      _none
    }
    
    set igmp_v2_max_resp_time_field {
        igmp_max_response_time            value                     _none
        igmp_max_response_time_count      count                     _none
        igmp_max_response_time_mode       mode                      _none
        igmp_max_response_time_step       step                      _none
        igmp_max_response_time_tracking   tracking                  _none
    }
    
    set igmp_v2_checksum_field {
        igmp_checksum                 value_hex                     {multiple_cond {auto_if_false igmp_valid_checksum} {p_format strict}}
        igmp_checksum_count           count                         _none
        igmp_checksum_mode            mode                          _none
        igmp_checksum_step            step                          _none
        igmp_checksum_tracking        tracking                      _none
    }
    
    set igmp_v2_group_addr_field {
        igmp_group_addr               value_ipv4                    {p_format strict}
        igmp_group_count              count                         _none
        igmp_group_mode               mode                          {translate igmp_group_mode_map}
        igmp_group_step               step                          _none
        igmp_group_tracking           tracking                      _none
    }
    
    set igmp_v3q_msg_type_field {
        igmp_type                        value_int_2_hex               {p_format strict}
        igmp_msg_type_tracking        tracking                      _none
    }
    
    set igmp_v3q_max_resp_code_field {
        igmp_max_response_time            value                     _none
        igmp_max_response_time_count      count                     _none
        igmp_max_response_time_mode       mode                      _none
        igmp_max_response_time_step       step                      _none
        igmp_max_response_time_tracking   tracking                  _none
    }
    
    set igmp_v3q_checksum_field {
        igmp_checksum                 value_hex                     {multiple_cond {auto_if_false igmp_valid_checksum} {p_format strict}}
        igmp_checksum_count           count                         _none
        igmp_checksum_mode            mode                          _none
        igmp_checksum_step            step                          _none
        igmp_checksum_tracking        tracking                      _none
    }
    
    set igmp_v3q_group_addr_field {
        igmp_group_addr               value_ipv4                    {p_format strict}
        igmp_group_count              count                         _none
        igmp_group_mode               mode                          {translate igmp_group_mode_map}
        igmp_group_step               step                          _none
        igmp_group_tracking           tracking                      _none
    }
    
    set igmp_v3q_resv_field {
        igmp_reserved_v3q             value_int_2_hex               {p_format strict}
        igmp_reserved_v3q_count       count                         _none
        igmp_reserved_v3q_mode        mode                          _none
        igmp_reserved_v3q_step        step                          _none
        igmp_reserved_v3q_tracking    tracking                      _none
    }
    
    set igmp_v3q_s_flag_field {
        igmp_s_flag                   value                         _none
        igmp_s_flag_mode              mode                          _none
        igmp_s_flag_tracking          tracking                      _none
    }
    
    set igmp_v3q_qrv_field {
        igmp_qrv                      value                         _none
        igmp_qrv_count                count                         _none
        igmp_qrv_mode                 mode                          _none
        igmp_qrv_step                 step                          _none
        igmp_qrv_tracking             tracking                      _none
    }
    
    set igmp_v3q_qqic_field {
        igmp_qqic                     value_int_2_hex               {p_format strict}
        igmp_qqic_count               count                         _none
        igmp_qqic_mode                mode                          _none
        igmp_qqic_step                step                          _none
        igmp_qqic_tracking            tracking                      _none
    }
    
    set igmp_v3q_multicast_src_field {
        igmp_multicast_src            value_ipv4                    {p_format strict}
        igmp_multicast_src_count      count                         _none
        igmp_multicast_src_mode       mode                          _none
        igmp_multicast_src_step       step                          _none
        igmp_multicast_src_tracking   tracking                      _none
    }
    
    set igmp_v3r_msg_type_field {
        igmp_type                        value_int_2_hex               {p_format strict}
        igmp_msg_type_tracking        tracking                      _none
    }
    
    set igmp_v3r_resv1_field {
        igmp_reserved_v3r1            value_int_2_hex               {p_format strict}
        igmp_reserved_v3r1_count      count                         _none
        igmp_reserved_v3r1_mode       mode                          _none
        igmp_reserved_v3r1_step       step                          _none
        igmp_reserved_v3r1_tracking   tracking                      _none
    }
    
    set igmp_v3r_checksum_field {
        igmp_checksum                 value_hex                     {multiple_cond {auto_if_false igmp_valid_checksum} {p_format strict}}
        igmp_checksum_count           count                         _none
        igmp_checksum_mode            mode                          _none
        igmp_checksum_step            step                          _none
        igmp_checksum_tracking        tracking                      _none
    }
    
    set igmp_v3r_resv2_field {
        igmp_reserved_v3r2            value_int_2_hex               {p_format strict}
        igmp_reserved_v3r2_count      count                         _none
        igmp_reserved_v3r2_mode       mode                          _none
        igmp_reserved_v3r2_step       step                          _none
        igmp_reserved_v3r2_tracking   tracking                      _none
    }
    
    set igmp_v3r_record_type {
        igmp_record_type              value                         {translate igmp_record_type_map}
        igmp_record_type_mode         mode                          _none
        igmp_record_type_tracking     tracking                      _none
    }
    
    array set igmp_record_type_map {
        mode_is_include               1
        mode_is_exclude               2
        change_to_include_mode        3
        change_to_exclude_mode        4
        allow_new_sources             5
        block_old_sources             6
    }
    
    set igmp_v3r_aux_data_len {
        igmp_aux_data_length          value                         _none
        igmp_aux_data_length_count    count                         _none
        igmp_aux_data_length_mode     mode                          _none
        igmp_aux_data_length_step     step                          _none
        igmp_aux_data_length_tracking tracking                      _none
    }
    
    set igmp_v3r_multicast_address_field {
        igmp_multicast_src            value                         {p_format strict}
        igmp_multicast_src_count      count                         _none
        igmp_multicast_src_mode       mode                          _none
        igmp_multicast_src_step       step                          _none
        igmp_multicast_src_tracking   tracking                      _none
    }
    
    set igmp_v3r_group_source_field {
        igmp_group_addr               value_ipv4                    {p_format strict}
        igmp_group_count              count                         _none
        igmp_group_mode               mode                          {translate igmp_group_mode_map}
        igmp_group_step               step                          _none
        igmp_group_tracking           tracking                      _none
    }
    
    set igmp_v3r_length_field {
        igmp_length_v3r               value                         _none
        igmp_length_v3r_count         count                         _none
        igmp_length_v3r_mode          mode                          _none
        igmp_length_v3r_step          step                          _none
        igmp_length_v3r_tracking      tracking                      _none
    }
    
    set igmp_v3r_data_field {
        igmp_data_v3r                 value_hex                     {p_format strict}
        igmp_data_v3r_count           count                         _none
        igmp_data_v3r_mode            mode                          _none
        igmp_data_v3r_step            step                          _none
        igmp_data_v3r_tracking        tracking                      _none
    }
    
    
    if {![info exists igmp_version]} {
        set igmp_version 2
    }
    
    switch -- $igmp_version {
        1 {
            if {![info exists igmp_type]} {
                set igmp_type 1 ;# Membership query
            } else {
                switch -- $igmp_type {
                    "membership_query" {
                        set igmp_type 1
                    }
                    "membership_report" {
                        set igmp_type 2
                    }
                    "leave_group" {
                        set igmp_type 1
                    }
                    "dvmrp" {
                        set igmp_type 1
                    }
                    default {
                        if {$igmp_type > 15} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Value out of bounds: '$igmp_type' for\
                                    parameter '-igmp_type' when IGMP version is 1.\
                                    Valid range is 1-15."
                            return $returnList
                        }
                    }
                }
            }
            
            set l4_protocol "igmpv1"
        }
        2 {
            if {![info exists igmp_type]} {
                set igmp_type 17 ;# Membership query
            } else {
                switch -- $igmp_type {
                    "membership_query" {
                        set igmp_type 17
                    }
                    "membership_report" {
                        set igmp_type 22
                    }
                    "leave_group" {
                        set igmp_type 23
                    }
                    "dvmrp" {
                        set igmp_type 17
                    }
                    default {
                        if {$igmp_type > 255} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Value out of bounds: '$igmp_type' for\
                                    parameter '-igmp_type' when IGMP version is 2.\
                                    Valid range is 1-255."
                            return $returnList
                        }
                    }
                }
            }
            
            set l4_protocol "igmpv2"
        }
        3 {
            if {[info exists igmp_msg_type]} {
                if {$igmp_msg_type == "query"} {
                    set l4_protocol "igmpv3q"
                    if {![info exists igmp_type]} {
                        set igmp_type 17
                    }
                } else {
                    set l4_protocol "igmpv3r"
                    if {![info exists igmp_type]} {
                        # These are hex values (for v1 and v2 they were integers)
                        set igmp_type 34
                    }
                }
            } else {
                if {![info exists igmp_type]} {
                    
                    set igmp_type 17
                    set l4_protocol "igmpv3q"
                    
                } else {
                    
                    switch -- $igmp_type {
                        "membership_query" {
                            set igmp_type 17
                            set l4_protocol "igmpv3q"
                        }
                        "membership_report" {
                            set igmp_type 34
                            set l4_protocol "igmpv3r"
                        }
                        "leave_group" {
                            set igmp_type 23
                            set l4_protocol "igmpv3q"
                        }
                        "dvmrp" {
                            set igmp_type 17
                            set l4_protocol "igmpv3q"
                        }
                        default {
                            if {$igmp_type > 255} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Value out of bounds: '$igmp_type' for\
                                        parameter '-igmp_type' when IGMP version is 3.\
                                        Valid range is 1-255."
                                return $returnList
                            }
                        }
                    }
                }
            }
            
            switch -- $igmp_type {
                "membership_query" {
                    set igmp_type 17
                }
                "membership_report" {
                    set igmp_type 34
                }
                "leave_group" {
                    set igmp_type 23
                }
                "dvmrp" {
                    set igmp_type 17
                }
                default {
                    if {$igmp_type > 255} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Value out of bounds: '$igmp_type' for\
                                parameter '-igmp_type' when IGMP version is 3.\
                                Valid range is 1-255."
                        return $returnList
                    }
                }
            }
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Unexpected value '$igmp_version' for parameter\
                    '-igmp_version'. Known values are '1', '2', '3'."
            return $returnList
        }
    }
    
    # In this section you must configure the protocol templates that will be added/configured
    # based on the indicators from your example. (l3_protocol, l2_encap.... ipv6_extensions...)
    set protocol_template_list [list $encapsulation_pt_map($l4_protocol)]
    
    switch -- $mode {
        "create" {
            
            # This procedure will remove the protocol templates that do not apply for this configElement
            # this is the case where multiple configElements exist on one traffic item.
            set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set protocol_template_list [keylget ret_code pt_list]
            
            # Build your own procedure 540IxNetTrafficProcThatAddsHeaders and change the name of course :)
            # This procedure must take the protocol templates and add them in the packet based on some rules
            # For example, if the protocol templates are layer3
            #   1. see if the template wasn't already added
            #   2. if it wasn't find the last L3 header and add after it
            #   3. If no L3 headers present, add after last L2
            #   ... make your own particular rules
            
            set ret_code [540IxNetTrafficL4AddHeaders $handle $handle_type $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            # The procedure MUST return the list of stacks (instances of protocol templates) that were added
            set stack_handles [keylget ret_code handle]
        }
        "modify" {
        
            # For modify mode search for the headers and modify them
            # if there are any parameters for them
            
            # if the handle is a stack, no need to search known headers. Modify the stacks.
            
            switch -- $handle_type {
                "traffic_item" {
                    # Get config element
                    set retrieve [540getConfigElementOrHighLevelStream $handle]
                    if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
                    set ce_hls_handle [keylget retrieve handle]
                }
                "config_element" {
                    set ce_hls_handle $handle
                }
                "high_level_stream" {
                    set ce_hls_handle $handle
                }
                "stack_ce" -
                "stack_hls" {
                    set stack_handles $handle
                }
            }
            
            if {$handle_type == "traffic_item" || $handle_type == "config_element" || \
                    $handle_type == "high_level_stream"} {
                
                # Again, protocol_template_list must be present
                set ret_code [540IxNetFindStacksAll $ce_hls_handle $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set stack_handles ""
                foreach tmp_pt_modify $protocol_template_list {
                    set tmp_stack_list [keylget ret_code $tmp_pt_modify]
                    
                    if {[llength $tmp_stack_list] > 0} {
                        lappend stack_handles [lindex $tmp_stack_list 0]
                    }
                    
                    catch {unset tmp_stack_list}
                }
                
                catch {unset tmp_pt_modify}
            }
        }
        "append_header" -
        "prepend_header" -
        "replace_header" {
            if {$handle_type != "stack_hls" && $handle_type != "stack_ce"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $handle handle type $handle_type for mode $mode."
                return $returnList
            }
            
            set new_protocol_template_list ""
            foreach pt $protocol_template_list {
                lappend new_protocol_template_list [regsub -all { } $pt {\ }]
            }
            
            switch -- $mode {
                "append_header" {

                    if {[llength $new_protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetAppendProtocolTemplate \{$new_protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetAppendProtocolTemplate $new_protocol_template_list $handle"
                    }
                    
                }
                "prepend_header" {
                    if {[llength $new_protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetPrependProtocolTemplate \{$new_protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetPrependProtocolTemplate $new_protocol_template_list $handle"
                    }
                }
                "replace_header" {
                    if {[llength $new_protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate \{$new_protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate $new_protocol_template_list $handle"
                    }
                }
            }
            
            set ret_code [eval $tmp_cmd]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $tmp_cmd. [keylget ret_code log]"
                return $returnList
            }
            
            set stack_handles [keylget ret_code handle]
        }
    }
    
    # Build the headers_multiple_instances array with the protocol templates that might be added more than once
    # For example, VLAN protocl template is added more than once when QinQ
    # Add a key word that will be used as index.
    # The index will be incremented every time the template is configured
    # The index will be used to extract the value of a parameter from a list of values
    
    #   Header protocol template                                            header index
    array set headers_multiple_instances {
    }
    
    # The rest is standard
    
    if {![info exists stack_handles]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Variable stack_handles is missing."
        return $returnList
    }
    
    set ret_code [540TrafficStackGod $stack_handles]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to configure stacks $stack_handles. [keylget ret_code log]"
        return $ret_code
    }
    
    return $returnList
}


proc ::ixia::540trafficL4Tcp { args opt_args} {
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    # Insert here the parameter that allows this funciton to configure
    # For example, l3_protocol must be ipv4 in order to configure ipv4 stuff
    if {![info exists l4_protocol]} {
        # Don't configure because it's not requested
        return $returnList
    }
    
    
    if {$l4_protocol != "tcp"} {
        # Don't configure because it's not a tcp encap
        return $returnList
    }
    
    set ret_val [540IxNetValidateObject $handle [list "traffic_item" "config_element" "high_level_stream" "stack_hls" "stack_ce"]]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set handle_type [keylget ret_val value]
    
    set ti_handle [ixNetworkGetParentObjref $handle trafficItem]
    
    set ret_val [540IxNetTrafficItemGetFirstTxPort $handle]
    if {[keylget ret_val status] != $::SUCCESS} {
        return $ret_val
    }
    
    set vport_handle [keylget ret_val value]
    
    set ret_code [ixNetworkGetPortFromObj $vport_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to extract port handle from\
                $vport_handle. [keylget ret_code log]"
        return $returnList
    } 
    
    set real_port_h [keylget ret_code port_handle]
    
    # pt == protocolTemplate
    # Insert here the stack(header) protocol templates that this procedure will configure
    # Remove the ipv6 and none entries. They are just an example.
    array set encapsulation_pt_map {
        tcp                        {::ixNet::OBJ-/traffic/protocolTemplate:"tcp"}
    }

    # This array contains a mapping between the stack field names and an hlt firendly name
    # The hlt friendly name is not an HLT parameter name. It is used to access field names
    # without the errors that spaced names could insert.
    # Remove the two entries. They are just examples.
    
   
    array set hlt_ixn_field_name_map {
        tcp_src_prt_field                   tcp_src_prt
        tcp_dst_prt_field                   tcp_dst_prt
        tcp_seq_num_field                   seq_num
        tcp_ack_num_field                   ack_num
        tcp_data_offset_field               data_offset
        tcp_reserved_field                  reserved
        tcp_n_bit_field                     n_bit
        tcp_c_bit_field                     c_bit
        tcp_e_bit_field                     e_bit
        tcp_u_bit_field                     u_bit
        tcp_a_bit_field                     a_bit
        tcp_p_bit_field                     p_bit
        tcp_r_bit_field                     r_bit
        tcp_s_bit_field                     s_bit
        tcp_f_bit_field                     f_bit
        tcp_window_field                    tcp_window
        tcp_checksum_field                  tcp_checksum
        tcp_urgent_ptr_field                urgent_ptr
    }       
            
    # Configure variable 'use_name_instead_of_displayname' to '1' if the mapping is done with the 
    # -name property of the field object instead of the -displayName (the example above uses -displayName)
    set use_name_instead_of_displayname 1
            
    # Array that establishes what fields will be configured for each protocol template.
    # The fields associated with each protocol template are the hlt friendly names from hlt_ixn_field_name_map
    # Remove the entries, they are just an example
    array set protocol_template_field_map [list                                                                  \
        ::ixNet::OBJ-/traffic/protocolTemplate:"tcp"                    [list                                    \
                                                                         tcp_src_prt_field                       \
                                                                         tcp_dst_prt_field                       \
                                                                         tcp_seq_num_field                       \
                                                                         tcp_ack_num_field                       \
                                                                         tcp_data_offset_field                   \
                                                                         tcp_reserved_field                      \
                                                                         tcp_n_bit_field                         \
                                                                         tcp_c_bit_field                         \
                                                                         tcp_e_bit_field                         \
                                                                         tcp_u_bit_field                         \
                                                                         tcp_a_bit_field                         \
                                                                         tcp_p_bit_field                         \
                                                                         tcp_r_bit_field                         \
                                                                         tcp_s_bit_field                         \
                                                                         tcp_f_bit_field                         \
                                                                         tcp_window_field                        \
                                                                         tcp_checksum_field                      \
                                                                         tcp_urgent_ptr_field                    \
                                                                        ]                                        \
    ]


    # The following lists are the actual mappings with the HLT parameters
    #
    # A list must be created for each field from hlt_ixn_field_name_map
    #
    # The first column is the HLT parameter name
    #
    # All IxNetwork fields support a starting value, a mode (increment, decrement), a count, step etc.
    # This mapping will help build the parameter list for procedure 540TrafficStackFieldConfig
    # Procedure 540TrafficStackFieldConfig is the one that actually configures the ixnetwork field
    # based on the value/count/mode/step/tracking parameters
    #
    # The second column configures the class of parameters that the HLT parameter belongs to value/count/mode/step/tracking
    # count/mode/step/tracking will allways have this fixed values
    # Instead of 'value' there can be various forms (value_hex, value_hex_2_int, value_mac....)
    # These 'values' will be interpreted in 540TrafficStackFieldConfig and handled accordingly
    # If your parameter requires a 'value' type that is not present, add it in 540TrafficStackFieldConfig and use it
    #
    # The third column is for special cases.
    # For example: by default, if mode is 'incr' or 'decr', the value and step must be transformed to integer.
    # If this is not the case for your parameter (ip_src_addr field in ixnetwork must remain an ipv4 address even if mode is incr or decr)
    # you can pass {p_format strict}. This will cause 540TrafficStackFieldConfig procedure to preserve the ipv4 format of the parameter even if mode is incr or decr.
    #
    # Another example is the {translate _some_translation_array}. This will cause the hlt parameter value to be
    # translated to another value as specified by the mapping from _some_translation_array
    #
    # You can add new ways to use the 'extra' column

#     tcp_src_prt               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.srcPort-1"
#     tcp_dst_prt               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.dstPort-2"
#     seq_num               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.sequenceNumber-3"
#     ack_num               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.acknowledgementNumber-4"
#     data_offset               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.dataOffset-5"
#     reserved               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.reserved-6"
#     n_bit               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.ecn.nsBit-7"
#     c_bit               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.ecn.cwrBit-8"
#     e_bit               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.ecn.ecnEchoBit-9"
#     u_bit               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.urgBit-10"
#     a_bit               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.ackBit-11"
#     p_bit               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.pshBit-12"
#     r_bit               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.rstBit-13"
#     s_bit               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.synBit-14"
#     f_bit               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.finBit-15"
#     tcp_window               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.window-16"
#     tcp_checksum               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.checksum-17"
#     urgent_ptr               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.urgentPtr-18"
#     
#     TCP-Source-Port               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.srcPort-1"
#     TCP-Dest-Port               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.dstPort-2"
#     Sequence Number               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.sequenceNumber-3"
#     Acknowledgement Number               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.acknowledgementNumber-4"
#     Data Offset               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.dataOffset-5"
#     Reserved               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.reserved-6"
#     NS               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.ecn.nsBit-7"
#     CWR               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.ecn.cwrBit-8"
#     ECN-Echo               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.ecn.ecnEchoBit-9"
#     URG               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.urgBit-10"
#     ACK               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.ackBit-11"
#     PSH               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.pshBit-12"
#     RST               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.rstBit-13"
#     SYN               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.synBit-14"
#     FIN               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.controlBits.finBit-15"
#     Window               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.window-16"
#     TCP-Checksum               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.checksum-17"
#     Urgent Pointer               ::ixNet::OBJ-/traffic/trafficItem:1/configElement:1/stack:"tcp-4"/field:"tcp.header.urgentPtr-18"
 


# -tcp_ack_flag                       CHOICES 0 1
# -tcp_ack_flag_mode               CHOICES fixed incr decr list
# -tcp_ack_flag_tracking           CHOICES 0 1
# -tcp_ack_num                        RANGE   0-4294967295
# -tcp_ack_num_count             NUMERIC
# -tcp_ack_num_mode              CHOICES fixed incr decr list
# -tcp_ack_num_step              RANGE   0-4294967294
# -tcp_ack_num_tracking          CHOICES 0 1
# -tcp_dst_port                       RANGE   0-65535
# -tcp_dst_port_count            NUMERIC
# -tcp_dst_port_mode             CHOICES fixed incr decr list
# -tcp_dst_port_step             RANGE   0-65534
# -tcp_dst_port_tracking         CHOICES 0 1
# -tcp_fin_flag                       CHOICES 0 1
# -tcp_fin_flag_mode               CHOICES fixed incr decr list
# -tcp_fin_flag_tracking           CHOICES 0 1
# -tcp_psh_flag                       CHOICES 0 1
# -tcp_psh_flag_mode               CHOICES fixed incr decr list
# -tcp_psh_flag_tracking           CHOICES 0 1
# -tcp_rst_flag                       CHOICES 0 1
# -tcp_rst_flag_mode               CHOICES fixed incr decr list
# -tcp_rst_flag_tracking           CHOICES 0 1
# -tcp_seq_num                        RANGE   0-4294967295
# -tcp_seq_num_count             NUMERIC
# -tcp_seq_num_mode              CHOICES fixed incr decr list
# -tcp_seq_num_step              RANGE   0-65534
# -tcp_seq_num_tracking          CHOICES 0 1
# -tcp_src_port                       RANGE   0-65535
# -tcp_src_port_count            NUMERIC
# -tcp_src_port_mode             CHOICES fixed incr decr list
# -tcp_src_port_step             RANGE   0-65534
# -tcp_src_port_tracking         CHOICES 0 1
# -tcp_syn_flag                       CHOICES 0 1
# -tcp_syn_flag_mode               CHOICES fixed incr decr list
# -tcp_syn_flag_tracking           CHOICES 0 1
# -tcp_urgent_ptr                     RANGE   0-65535
# -tcp_urgent_ptr_count               NUMERIC
# -tcp_urgent_ptr_mode                CHOICES fixed incr decr list
# -tcp_urgent_ptr_step                RANGE   0-65534
# -tcp_urgent_ptr_tracking         CHOICES 0 1
# -tcp_urg_flag                       CHOICES 0 1
# -tcp_urg_flag_mode               CHOICES fixed incr decr list
# -tcp_urg_flag_tracking           CHOICES 0 1
# -tcp_window                         RANGE   0-65535
# -tcp_window_count               NUMERIC
# -tcp_window_mode                CHOICES fixed incr decr list
# -tcp_window_step                RANGE   0-65534
# -tcp_window_tracking         CHOICES 0 1
# -tcp_data_offset                    RANGE  0-15
# -tcp_data_offset_count         NUMERIC
# -tcp_data_offset_mode          CHOICES fixed incr decr list
# -tcp_data_offset_step          RANGE  0-15
# -tcp_data_offset_tracking      CHOICES 0 1
# -tcp_reserved                       RANGE  0-7
# -tcp_reserved_count            NUMERIC
# -tcp_reserved_mode             CHOICES fixed incr decr list
# -tcp_reserved_step             RANGE  0-6
# -tcp_reserved_tracking         CHOICES 0 1
# -tcp_ns_flag                        CHOICES 0 1
# -tcp_ns_flag_flag_mode              CHOICES fixed incr decr list
# -tcp_ns_flag_flag_tracking          CHOICES 0 1
# -tcp_cwr_flag                       CHOICES 0 1
# -tcp_cwr_flag_mode               CHOICES fixed incr decr list
# -tcp_cwr_flag_tracking           CHOICES 0 1
# -tcp_ecn_echo_flag                  CHOICES 0 1
# -tcp_ecn_echo_flag_mode               CHOICES fixed incr decr list
# -tcp_ecn_echo_flag_tracking           CHOICES 0 1
# -tcp_checksum                       REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
# -tcp_checksum_count            NUMERIC
# -tcp_checksum_mode             CHOICES fixed incr decr list
# -tcp_checksum_step             REGEXP  (^[0-9a-fA-F]{1,4}$)|(^0x[0-9a-fA-F]{1,4})
# -tcp_checksum_tracking         CHOICES 0 1

    #   hlt_param                     param_class                   extra
    set tcp_src_prt_field {
        tcp_src_port                  value                         _none
        tcp_src_port_count            count                         _none
        tcp_src_port_mode             mode                          _none
        tcp_src_port_step             step                          _none
        tcp_src_port_tracking         tracking                      _none
    }
    
    set tcp_dst_prt_field {
        tcp_dst_port                  value                         _none
        tcp_dst_port_count            count                         _none
        tcp_dst_port_mode             mode                          _none
        tcp_dst_port_step             step                          _none
        tcp_dst_port_tracking         tracking                      _none
    }
    
    set tcp_seq_num_field {
        tcp_seq_num                   value_int_2_hex               {p_format strict}
        tcp_seq_num_count             count                         _none
        tcp_seq_num_mode              mode                          _none
        tcp_seq_num_step              step                          _none
        tcp_seq_num_tracking          tracking                      _none
    }
    
    set tcp_ack_num_field {
        tcp_ack_num                   value_int_2_hex               {p_format strict}
        tcp_ack_num_count             count                         _none
        tcp_ack_num_mode              mode                          _none
        tcp_ack_num_step              step                          _none
        tcp_ack_num_tracking          tracking                      _none
    }
    
    set tcp_data_offset_field {
        tcp_data_offset               value                         _none
        tcp_data_offset_count         count                         _none
        tcp_data_offset_mode          mode                          _none
        tcp_data_offset_step          step                          _none
        tcp_data_offset_tracking      tracking                      _none
    }
    
    set tcp_reserved_field {
        tcp_reserved                  value                         _none
        tcp_reserved_count            count                         _none
        tcp_reserved_mode             mode                          _none
        tcp_reserved_step             step                          _none
        tcp_reserved_tracking         tracking                      _none
    }
    
    set tcp_n_bit_field {
        tcp_ns_flag                   value                         _none
        tcp_ns_flag_mode              mode                          _none
        tcp_ns_flag_tracking          tracking                      _none
    }
    
    set tcp_c_bit_field {
        tcp_cwr_flag                  value                         _none
        tcp_cwr_flag_mode             mode                          _none
        tcp_cwr_flag_tracking         tracking                      _none
    }
    
    set tcp_e_bit_field {
        tcp_ecn_echo_flag             value                         _none
        tcp_ecn_echo_flag_mode        mode                          _none
        tcp_ecn_echo_flag_tracking    tracking                      _none
    }
    
    set tcp_u_bit_field {
        tcp_urg_flag                  value                         _none
        tcp_urg_flag_mode             mode                          _none
        tcp_urg_flag_tracking         tracking                      _none
    }
    
    set tcp_a_bit_field {
        tcp_ack_flag                  value                         _none
        tcp_ack_flag_mode             mode                          _none
        tcp_ack_flag_tracking         tracking                      _none
    }
    
    set tcp_p_bit_field {
        tcp_psh_flag                  value                         _none
        tcp_psh_flag_mode             mode                          _none
        tcp_psh_flag_tracking         tracking                      _none
    }
    
    set tcp_r_bit_field {
        tcp_rst_flag                  value                         _none
        tcp_rst_flag_mode             mode                          _none
        tcp_rst_flag_tracking         tracking                      _none
    }
    
    set tcp_s_bit_field {
        tcp_syn_flag                  value                         _none
        tcp_syn_flag_mode             mode                          _none
        tcp_syn_flag_tracking         tracking                      _none
    }
    
    set tcp_f_bit_field {
        tcp_fin_flag                  value                         _none
        tcp_fin_flag_mode             mode                          _none
        tcp_fin_flag_tracking         tracking                      _none
    }
    
    set tcp_window_field {
        tcp_window                    value_int_2_hex               {p_format strict}
        tcp_window_count              count                         _none
        tcp_window_mode               mode                          _none
        tcp_window_step               step                          _none
        tcp_window_tracking           tracking                      _none
    }
    
    set tcp_checksum_field {
        tcp_checksum                  value_hex                     {p_format strict}
        tcp_checksum_count            count                         _none
        tcp_checksum_mode             mode                          _none
        tcp_checksum_step             step                          _none
        tcp_checksum_tracking         tracking                      _none
    }
    
    set tcp_urgent_ptr_field {
        tcp_urgent_ptr                value_int_2_hex               {p_format strict}
        tcp_urgent_ptr_count          count                         _none
        tcp_urgent_ptr_mode           mode                          _none
        tcp_urgent_ptr_step           step                          _none
        tcp_urgent_ptr_tracking       tracking                      _none
    }
    
    # In this section you must configure the protocol templates that will be added/configured
    # based on the indicators from your example. (l3_protocol, l2_encap.... ipv6_extensions...)
    set protocol_template_list $encapsulation_pt_map($l4_protocol)    
    
    switch -- $mode {
        "create" {
            
            # This procedure will remove the protocol templates that do not apply for this configElement
            # this is the case where multiple configElements exist on one traffic item.
            set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set protocol_template_list [keylget ret_code pt_list]
            
            # Build your own procedure 540IxNetTrafficProcThatAddsHeaders and change the name of course :)
            # This procedure must take the protocol templates and add them in the packet based on some rules
            # For example, if the protocol templates are layer3
            #   1. see if the template wasn't already added
            #   2. if it wasn't find the last L3 header and add after it
            #   3. If no L3 headers present, add after last L2
            #   ... make your own particular rules
            
            set ret_code [540IxNetTrafficL4AddHeaders $handle $handle_type $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            # The procedure MUST return the list of stacks (instances of protocol templates) that were added
            set stack_handles [keylget ret_code handle]
        }
        "modify" {
        
            # For modify mode search for the headers and modify them
            # if there are any parameters for them
            
            # if the handle is a stack, no need to search known headers. Modify the stacks.
            
            switch -- $handle_type {
                "traffic_item" {
                    # Get config element
                    set retrieve [540getConfigElementOrHighLevelStream $handle]
                    if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
                    set ce_hls_handle [keylget retrieve handle]
                }
                "config_element" {
                    set ce_hls_handle $handle
                }
                "high_level_stream" {
                    set ce_hls_handle $handle
                }
                "stack_ce" -
                "stack_hls" {
                    set stack_handles $handle
                }
            }
            
            if {$handle_type == "traffic_item" || $handle_type == "config_element" || \
                    $handle_type == "high_level_stream"} {
                
                # Again, protocol_template_list must be present
                set ret_code [540IxNetFindStacksAll $ce_hls_handle $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set stack_handles ""
                foreach tmp_pt_modify $protocol_template_list {
                    set tmp_stack_list [keylget ret_code $tmp_pt_modify]
                    
                    if {[llength $tmp_stack_list] > 0} {
                        lappend stack_handles [lindex $tmp_stack_list 0]
                    }
                    
                    catch {unset tmp_stack_list}
                }
                
                catch {unset tmp_pt_modify}
            }
        }
        "append_header" -
        "prepend_header" -
        "replace_header" {
            if {$handle_type != "stack_hls" && $handle_type != "stack_ce"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $handle handle type $handle_type for mode $mode."
                return $returnList
            }
            
            switch -- $mode {
                "append_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetAppendProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetAppendProtocolTemplate $protocol_template_list $handle"
                    }
                    
                }
                "prepend_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetPrependProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetPrependProtocolTemplate $protocol_template_list $handle"
                    }
                }
                "replace_header" {
                    if {[llength $protocol_template_list] > 1} {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate \{$protocol_template_list\} $handle"
                    } else {
                        set tmp_cmd "540IxNetReplaceProtocolTemplate $protocol_template_list $handle"
                    }
                }
            }
            
            set ret_code [eval $tmp_cmd]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $tmp_cmd. [keylget ret_code log]"
                return $returnList
            }
            
            set stack_handles [keylget ret_code handle]
        }
    }
    
    # Build the headers_multiple_instances array with the protocol templates that might be added more than once
    # For example, VLAN protocl temaplate is added more than once when QinQ
    # Add a key word that will be used as index.
    # The index will be incremented every time the template is configured
    # The index will be used to extract the value of a parameter from a list of values
    
    #   Header protocol template                                            header index
    array set headers_multiple_instances {
    }
    
    # The rest is standard
    
    if {![info exists stack_handles]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Variable stack_handles is missing."
        return $returnList
    }
    
    set ret_code [540TrafficStackGod $stack_handles]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to configure stacks $stack_handles. [keylget ret_code log]"
        return $ret_code
    }
    
    return $returnList
}
