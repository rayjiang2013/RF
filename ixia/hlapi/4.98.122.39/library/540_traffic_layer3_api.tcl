proc ::ixia::540trafficL3IpV4 { args opt_args opt_args_qos opt_args_noqos all_args} {
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    if {![info exists l3_protocol] || ($l3_protocol != "ipv4" && $l3_protocol != "arp")} {
        
        set var_list_l3_ipv4 [getVarListFromArgs $opt_args]
        
        foreach var_l3_ipv4 $var_list_l3_ipv4 {
            switch -- $var_l3_ipv4 {
                "mode" -
                "handle" -
                "is_raw_item" -
                "atm_header_encapsulation" -
                "l2_encap" -
                "l3_protocol" -
                "l4_protocol" {
                }
                default {
                    if {[info exists $var_l3_ipv4] && ![is_default_param_value $var_l3_ipv4 $all_args] &&\
                            ($mode == "create" || $mode == "modify")} {
                        set l3_protocol "ipv4"
                        break
                    }
                }
            }
        }
    }
    
    if {![info exists l3_protocol]} {
        # Don't configure because it's not an ipv4 encap
        return $returnList
    }
    
    if {$l3_protocol != "ipv4"} {
        # Don't configure because it's not an ipv4 encap
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
    
    array set encapsulation_pt_map {
        ipv4                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"}
    }
    
    array set hlt_ixn_field_name_map {
        ipv4_source_address_field           "Source Address"
        ipv4_destination_address_field      "Destination Address"
        ipv4_total_length_field             "Total Length (octets)"
        ipv4_header_length                  "Header Length"
        ipv4_identification_field           "Identification"
        ipv4_flag_reserved_field            "Reserved"
        ipv4_flag_fragment_field            "Fragment"
        ipv4_flag_last_fragment_field       "Last Fragment"
        ipv4_fragment_offset_field          "Fragment offset"
        ipv4_ttl_field                      "TTL (Time to live)"
        ipv4_protocol_field                 "Protocol"
        ipv4_header_checksum_field          "Header checksum"
    }
    
    array set protocol_template_field_map [list                                             \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv4"     [list                             \
                                                           ipv4_source_address_field        \
                                                           ipv4_destination_address_field   \
                                                           ipv4_total_length_field          \
                                                           ipv4_header_length               \
                                                           ipv4_identification_field        \
                                                           ipv4_flag_reserved_field         \
                                                           ipv4_flag_fragment_field         \
                                                           ipv4_flag_last_fragment_field    \
                                                           ipv4_fragment_offset_field       \
                                                           ipv4_ttl_field                   \
                                                           ipv4_protocol_field              \
                                                           ipv4_header_checksum_field       \
                                                          ]                                 \
    ]
    
    #       hlt_param                       param_class               extra
    set ipv4_source_address_field {
            ip_src_addr                     value_ipv4                {p_format  strict}
            ip_src_count                    count                     _none
            ip_src_mode                     mode                      {translate ip_src_mode_translate}
            ip_src_step                     step                      _none
            ip_src_tracking                 tracking                  _none
    }
                
    set ipv4_flag_reserved_field {
            ip_reserved                     value                     _none
            ip_reserved_mode                mode                      _none
            ip_reserved_tracking            tracking                  _none
    }
    
    set ipv4_total_length_field {
            ip_total_length                 value                     _none
            ip_total_length_count           count                     _none
            ip_total_length_mode            mode                      {auto_if_ne ip_total_length}
            ip_total_length_step            step                      _none
            ip_total_length_tracking        tracking                  _none
    }
    
    set ipv4_header_length {
            ip_hdr_length                 value                     _none
            ip_hdr_length_count           count                     _none
            ip_hdr_length_mode            mode                      {auto_if_false ip_length_override}
            ip_hdr_length_step            step                      _none
            ip_hdr_length_tracking        tracking                  _none
    }
    
    set ipv4_header_checksum_field {
            ip_checksum                     value_int_2_hex           _none
            ip_checksum_count               count                     _none
            ip_checksum_mode                mode                      _none
            ip_checksum_step                step                      _none
            ip_checksum_tracking            tracking                  _none
    }
    
    set ipv4_ttl_field {
            ip_ttl                          value                     _none
            ip_ttl_count                    count                     _none
            ip_ttl_mode                     mode                      _none
            ip_ttl_step                     step                      _none
            ip_ttl_tracking                 tracking                  _none
    }
    
    set ipv4_flag_fragment_field {
            ip_fragment                     value                     {translate ipv4_flag_fragment_translate}
            ip_fragment_mode                mode                      _none
            ip_fragment_tracking            tracking                  _none
    }
    
    set ipv4_destination_address_field {
            ip_dst_addr                     value_ipv4                {p_format  strict}
            ip_dst_count                    count                     _none
            ip_dst_mode                     mode                      {translate ip_dst_mode_translate}
            ip_dst_step                     step                      _none
            ip_dst_tracking                 tracking                  _none
    }
    
    set ipv4_flag_last_fragment_field {
            ip_fragment_last                value_translate           {array_map fragment_last_translate}
            ip_fragment_last_mode           mode                      _none
            ip_fragment_last_tracking       tracking                  _none
    }
    
    set ipv4_identification_field {
            ip_id                           value                     _none
            ip_id_count                     count                     _none
            ip_id_mode                      mode                      _none
            ip_id_step                      step                      _none
            ip_id_tracking                  tracking                  _none
    }
    
    set ipv4_fragment_offset_field {
            ip_fragment_offset              value                     _none
            ip_fragment_offset_count        count                     _none
            ip_fragment_offset_mode         mode                      _none
            ip_fragment_offset_step         step                      _none
            ip_fragment_offset_tracking     tracking                  _none
    }
    
    set ipv4_protocol_field {
            ip_protocol                     value                     _none
            ip_protocol_count               count                     _none
            ip_protocol_mode                mode                      {auto_if_ne ip_protocol}
            ip_protocol_step                step                      _none
            ip_protocol_tracking            tracking                  _none
    }
   
    array set ip_src_mode_translate {
        fixed           fixed
        increment       incr
        decrement       decr
        random          fixed
        emulation       auto
        list            list
    }

    array set ip_dst_mode_translate {
        fixed           fixed
        increment       incr
        decrement       decr
        random          fixed
        emulation       auto
        list            list
    }
    
    array set ipv4_flag_fragment_translate {
        1       0
        0       1
    }
    
    # BUG738159, flag values are semantically inversed in ixn
    # ixn: last fragment == 0
    # hlt: last fragment == 1
    array set fragment_last_translate {
        more    1
        last    0
        0       1
        1       0
    }
     
    if {![info exists encapsulation_pt_map($l3_protocol)]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Encapsulation $l3_protocol is not supported."
        return $returnList
    }
    
    switch -- $mode {
        "create" {
        
            set protocol_template_list $encapsulation_pt_map($l3_protocol)
            
            # This procedure will remove the protocol templates that do not apply for this configElement
            # this is the case where multiple configElements exist on one traffic item.
            set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set protocol_template_list [keylget ret_code pt_list]
            
            set ret_code [540IxNetTrafficL3AddHeaders $handle $handle_type $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set stack_handles [keylget ret_code handle]

        }
        "modify" {
        
            # For modify mode search for the ipv4 headers and modify them
            # if there are any parameters for them
            
            removeDefaultOptionVars $opt_args_qos $args
            
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
                
                set protocol_template_list $encapsulation_pt_map($l3_protocol)
                
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
            
            if {![info exists l3_protocol]} {
                # l3_protocol not provided. Nothing to append/prepend/replace
                keylset returnList status $::SUCCESS
                return $returnList
            }
            
            set protocol_template_list $encapsulation_pt_map($l3_protocol)
            
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
    
    
    #################################################################################
    # This is an overview of how the parameters are configured using the 
    # mapping arrays and lists:
    # 
    # foreach stack $stack_handles {
    #     
    #     stack --> protocol_template (using proc 540IxNetStackGetProtocolTemplate)
    #     
    #     protocol_template --> hlt_field_list (using array protocol_template_field_map)
    #     
    #     foreach field $hlt_field_list {
    #         
    #         field --> list_of_params_for_field (using the lists with the same name as $field)
    #         
    #         foreach {hlt_param hlt_intermediate_param parameter_type} $list_of_params_for_field {
    #             
    #             build arg list for 540TrafficStackFieldConfig
    #             use real field name in 540TrafficStackFieldConfig (real name obtained using hlt_ixn_field_name_map)
    #         }
    #     }
    # }
    ################################################################################

    #   Header protocol template                                            header index
    array set headers_multiple_instances {
    }
    
    # The rest is standard
    
    if {![info exists stack_handles]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Variable stack_handles is missing."
        return $returnList
    }
    
    foreach stack_item $stack_handles {
        
        set ret_code [540IxNetStackGetProtocolTemplate $stack_item]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set tmp_pt_handle [keylget ret_code pt_handle]
        set tmp_pt_name   [keylget ret_code pt_name]

        if {[string trim $tmp_pt_name] == "IPv4"} {
            
            # Qos must be configured separately as it varies based on a lot of variables
            
            set qos_param_list ""
            set var_list_qos [getVarListFromArgs $opt_args_qos]
            foreach var_fs $var_list_qos {
                if {[info exists $var_fs]} {
                    set var_fs_value [set $var_fs]
                    if {[llength $var_fs_value]} {
                        lappend qos_param_list -$var_fs \{$var_fs_value\}
                    } else {
                        lappend qos_param_list -$var_fs $var_fs_value
                    }
                }
            }

            if {[llength $qos_param_list] > 0} {
                set qos_status [540IxNetStackIPv4ConfigQos $qos_param_list $opt_args_qos $stack_item]
                if {[keylget qos_status status] != $::SUCCESS} {
                    return $qos_status
                }
            }
        }
    }
    
    set ret_code [540TrafficStackGod $stack_handles]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to configure stacks $stack_handles. [keylget ret_code log]"
        return $ret_code
    }

    
    return $returnList
}


proc ::ixia::540trafficL3IpV6 { args opt_args all_args} {
    
    # !!!!!!!!!!! ipv6_dst_mask                            N/A        
    # !!!!!!!!!!! ipv6_hop_by_hop_options                            ?? Supported    Needs parsing. Cannot add options in GUI    ::ixNet::OBJ-/traffic/trafficItem:3/highLevelStream:1/stack:"IPv6 Hop-by-Hop Options Header-5"
    # !!!!!!!!!!! ipv6_routing_node_list                            ??? Supported    Appears in GUI but cannot be controled    ::ixNet::OBJ-/traffic/trafficItem:3/highLevelStream:1/stack:"IPv6 Routing Header Type 0-3"
    # !!!!!!!!!!! ipv6_src_mask                            N/A
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    set var_list_l3_ipv6 [getVarListFromArgs $opt_args]
    foreach var_l3_ipv6 $var_list_l3_ipv6 {
        switch -- $var_l3_ipv6 {
            "mode" -
            "handle" -
            "is_raw_item" -
            "atm_header_encapsulation" -
            "l2_encap" -
            "l3_protocol" -
            "l4_protocol" {
            }
            default {
                if {[info exists $var_l3_ipv6] && ![is_default_param_value $var_l3_ipv6 $all_args] &&\
                        ($mode == "create" || $mode == "modify")} {
                    set l3_protocol "ipv6"
                    break
                }
            }
        }
    }
    
    if {![info exists l3_protocol]} {
        # Don't configure because it's not an ipv6 encap
        return $returnList
    }
    
    if {$l3_protocol != "ipv6"} {
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
    
    array set encapsulation_pt_map {
        ipv6                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6"}
        none                        {}
        hop_by_hop                  {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6HopByHopOptions"}
        authentication              {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Authentication"}
        fragment                    {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Fragment"}
        encapsulation               {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Encapsulation"}
        routing                     {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6RoutingType0"}
        destination                 {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6DestinationOptions"}
        pseudo                      {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Pseudo"}
    }

# pseudo                      {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Pseudo"}        
# destination                 {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6DestinationOptions"}
    
    array set hlt_ixn_field_name_map [list\
            ipv6_destination_addr_field                    [list   0    "Destination Address"]\
            ipv6_flow_label_field                          [list   0    "Flow Label"]\
            ipv6_hop_limit_field                           [list   0    "Hop Limit"]\
            ipv6_next_header_field                         [list   0    "Next Header"]\
            ipv6_payload_length_field                      [list   0    "Payload Length"]\
            ipv6_source_addr_field                         [list   0    "Source Address"]\
            ipv6_traffic_class_field                       [list   0    "Traffic Class"]\
            ipv6_version_field                             [list   0    "Version"]\
            ipv6_auth_md5_field                            [list   0    "MD5"]\
            ipv6_auth_next_header_field                    [list   0    "Next Header"]\
            ipv6_auth_padding_field                        [list   0    "Padding"]\
            ipv6_auth_payload_length_field                 [list   0    "Payload Length (4 Octet)"]\
            ipv6_auth_reserved_field                       [list   0    "Reserved"]\
            ipv6_auth_sec_param_idx_field                  [list   0    "Security Parameter Index"]\
            ipv6_auth_seq_no_field                         [list   0    "Sequence Number"]\
            ipv6_auth_sha1_field                           [list   0    "SHA-1"]\
            ipv6_dest_opt_head_ext_length_field            [list   0    "Header Extension Length (8 octets)"]\
            ipv6_dest_opt_next_header_field                [list   0    "Next Header"]\
            ipv6_dest_opt_padding_field                    [list   0    "Padding"]\
            ipv6_encap_sec_param_idx_field                 [list   0    "Security Paramaters Index"]\
            ipv6_encap_seq_no_field                        [list   0    "Sequence Number"]\
            ipv6_fragment_frag_offset_field                [list   0    "Fragment offset (8 octets)"]\
            ipv6_fragment_id_field                         [list   0    "Identification"]\
            ipv6_fragment_more_frags_field                 [list   0    "More Fragments"]\
            ipv6_fragment_next_header_field                [list   0    "Next Header"]\
            ipv6_fragment_reserved_field                   [list   1    reserved2]\
            ipv6_fragment_reserved_field8                  [list   1    reserved1]\
            ipv6_hop_by_hop_head_ext_length_field          [list   0    "Header Extension Length (8 octets)"]\
            ipv6_hop_by_hop_next_header_field              [list   0    "Next Header"]\
            ipv6_hop_by_hop_padding_field                  [list   0    "Padding"]\
            ipv6_pseudo_dst_addr_field                     [list   0    "Destination Address"]\
            ipv6_pseudo_next_header_field                  [list   0    "Next Header"]\
            ipv6_pseudo_src_addr_field                     [list   0    "Source Address"]\
            ipv6_pseudo_up_layer_pkt_len_field             [list   0    "Upper-Layer Packet Length"]\
            ipv6_pseudo_zero_field                         [list   0    "Zero"]\
            ipv6_routing_t0_head_ext_length_field          [list   0    "Header Extension Length (8 octets)"]\
            ipv6_routing_t0_next_header_field              [list   0    "Next Header"]\
            ipv6_routing_t0_reserved_field                 [list   0    "Reserved"]\
            ipv6_routing_t0_routing_type_field             [list   0    "Routing Type"]\
            ipv6_routing_t0_segments_left_field            [list   0    "Segments Left"]\
            ipv6_hop_by_hop_ud_unrecognized_type           [list   2    options\.option\.userDefined\.type\.unrecognizedType]\
            ipv6_hop_by_hop_ud_allow_packet_change         [list   2    options\.option\.userDefined\.type\.allowPacketChange]\
            ipv6_hop_by_hop_ud_user_defined_type           [list   2    options\.option\.userDefined\.type\.userDefinedType]\
            ipv6_hop_by_hop_ud_length                      [list   2    options\.option\.userDefined\.length]\
            ipv6_hop_by_hop_ud_data                        [list   2    options\.option\.userDefined\.data]\
            ipv6_hop_by_hop_padn_type                      [list   2    options\.option\.padN\.type]\
            ipv6_hop_by_hop_padn_length                    [list   2    options\.option\.padN\.length]\
            ipv6_hop_by_hop_padn_data                      [list   2    options\.option\.padN\.data]\
            ipv6_hop_by_hop_pad1                           [list   2    options\.option\.pad1]\
    ]
            
    # Configure variable 'use_name_instead_of_displayname' to '1' if the mapping is done with the 
    # -name property of the field object instead of the -displayName (the example above uses -displayName)
    # or 2 if hlt_ixn_field_name_map contains the decision whether to use name or displayName
    set use_name_instead_of_displayname 2
            
    array set protocol_template_field_map [list                                                                      \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6"                   [list                                        \
                                                                         ipv6_destination_addr_field                 \
                                                                         ipv6_flow_label_field                       \
                                                                         ipv6_hop_limit_field                        \
                                                                         ipv6_next_header_field                      \
                                                                         ipv6_payload_length_field                   \
                                                                         ipv6_source_addr_field                      \
                                                                         ipv6_traffic_class_field                    \
                                                                         ipv6_version_field                          \
                                                                        ]                                            \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6HopByHopOptions"    [list                                        \
                                                                         ipv6_hop_by_hop_head_ext_length_field       \
                                                                         ipv6_hop_by_hop_next_header_field           \
                                                                         ipv6_hop_by_hop_padding_field               \
                                                                         ipv6_hop_by_hop_ud_unrecognized_type        \
                                                                         ipv6_hop_by_hop_ud_allow_packet_change      \
                                                                         ipv6_hop_by_hop_ud_user_defined_type        \
                                                                         ipv6_hop_by_hop_ud_length                   \
                                                                         ipv6_hop_by_hop_ud_data                     \
                                                                         ipv6_hop_by_hop_padn_type                   \
                                                                         ipv6_hop_by_hop_padn_length                 \
                                                                         ipv6_hop_by_hop_padn_data                   \
                                                                         ipv6_hop_by_hop_pad1                        \
                                                                        ]                                            \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6DestinationOptions" [list                                        \
                                                                         ipv6_dest_opt_head_ext_length_field         \
                                                                         ipv6_dest_opt_next_header_field             \
                                                                         ipv6_dest_opt_padding_field                 \
                                                                        ]                                            \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Authentication"     [list                                        \
                                                                         ipv6_auth_md5_field                         \
                                                                         ipv6_auth_next_header_field                 \
                                                                         ipv6_auth_padding_field                     \
                                                                         ipv6_auth_payload_length_field              \
                                                                         ipv6_auth_reserved_field                    \
                                                                         ipv6_auth_sec_param_idx_field               \
                                                                         ipv6_auth_seq_no_field                      \
                                                                         ipv6_auth_sha1_field                        \
                                                                        ]                                            \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Fragment"           [list                                        \
                                                                         ipv6_fragment_frag_offset_field             \
                                                                         ipv6_fragment_id_field                      \
                                                                         ipv6_fragment_more_frags_field              \
                                                                         ipv6_fragment_next_header_field             \
                                                                         ipv6_fragment_reserved_field                \
                                                                         ipv6_fragment_reserved_field8               \
                                                                        ]                                            \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Encapsulation"      [list                                        \
                                                                         ipv6_encap_sec_param_idx_field              \
                                                                         ipv6_encap_seq_no_field                     \
                                                                        ]                                            \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Pseudo"             [list                                        \
                                                                         ipv6_pseudo_dst_addr_field                  \
                                                                         ipv6_pseudo_next_header_field               \
                                                                         ipv6_pseudo_src_addr_field                  \
                                                                         ipv6_pseudo_up_layer_pkt_len_field          \
                                                                         ipv6_pseudo_zero_field                      \
                                                                        ]                                            \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6RoutingType0"       [list                                        \
                                                                         ipv6_routing_t0_head_ext_length_field       \
                                                                         ipv6_routing_t0_next_header_field           \
                                                                         ipv6_routing_t0_reserved_field              \
                                                                         ipv6_routing_t0_routing_type_field          \
                                                                         ipv6_routing_t0_segments_left_field         \
                                                                        ]                                            \
    ]
    
    array set multiple_level_fields [list                                                                            \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6HopByHopOptions"    [list                                        \
                                                                         ipv6_hop_by_hop_ud_unrecognized_type        \
                                                                         ipv6_hop_by_hop_ud_allow_packet_change      \
                                                                         ipv6_hop_by_hop_ud_user_defined_type        \
                                                                         ipv6_hop_by_hop_ud_length                   \
                                                                         ipv6_hop_by_hop_ud_data                     \
                                                                         ipv6_hop_by_hop_padn_type                   \
                                                                         ipv6_hop_by_hop_padn_length                 \
                                                                         ipv6_hop_by_hop_padn_data                   \
                                                                         ipv6_hop_by_hop_pad1                        \
                                                                        ]                                            \
    ]

    #       hlt_param                       param_class               extra
                                                                         
    set ipv6_routing_t0_head_ext_length_field {}

    set ipv6_routing_t0_next_header_field {}
    
    set ipv6_routing_t0_reserved_field {
            ipv6_routing_res                value_hex_2_int           {p_format strict}
            ipv6_routing_res_count          count                     _none
            ipv6_routing_res_mode           mode                      _none
            ipv6_routing_res_step           step                      _none
            ipv6_routing_res_tracking       tracking                  _none
    }
    
    set ipv6_routing_t0_routing_type_field {
            ipv6_routing_type               value                     _none
            ipv6_routing_type_count         count                     _none
            ipv6_routing_type_mode          mode                      _none
            ipv6_routing_type_step          step                      _none
            ipv6_routing_type_tracking      tracking                  _none
    }
    
    set ipv6_routing_t0_segments_left_field {}
    
    set ipv6_encap_sec_param_idx_field {
            ipv6_encap_spi                  value                     _none
            ipv6_encap_spi_count            count                     _none
            ipv6_encap_spi_mode             mode                      _none
            ipv6_encap_spi_step             step                      _none
            ipv6_encap_spi_tracking         tracking                  _none
    }
    
    set ipv6_encap_seq_no_field {
            ipv6_encap_seq_number           value_hex                 {p_format strict}
            ipv6_encap_seq_number_count     count                     _none
            ipv6_encap_seq_number_mode      mode                      _none
            ipv6_encap_seq_number_step      step                      _none
            ipv6_encap_seq_number_tracking  tracking                  _none
    }
    

    # destiation header options are read-only in ixn
    set ipv6_dest_opt_head_ext_length_field {
    }
    
    set ipv6_dest_opt_next_header_field {
    }
    
    set ipv6_dest_opt_padding_field {
    }
    
    set ipv6_pseudo_dst_addr_field {
            ipv6_pseudo_dst_addr            value                     {p_format  strict}
            ipv6_pseudo_dst_addr_count      count                     _none
            ipv6_pseudo_dst_addr_mode       mode                      _none
            ipv6_pseudo_dst_addr_step       step                      _none
            ipv6_pseudo_dst_addr_tracking   tracking                  _none
    }
    
    set ipv6_pseudo_next_header_field {
    }
    
    set ipv6_pseudo_src_addr_field {
            ipv6_pseudo_src_addr            value                     {p_format  strict}
            ipv6_pseudo_src_addr_count      count                     _none
            ipv6_pseudo_src_addr_mode       mode                      _none
            ipv6_pseudo_src_addr_step       step                      _none
            ipv6_pseudo_src_addr_tracking   tracking                  _none
    }
    
    set ipv6_pseudo_up_layer_pkt_len_field {
            ipv6_pseudo_uppper_layer_pkt_length             value                     _none
            ipv6_pseudo_uppper_layer_pkt_length_count       count                     _none
            ipv6_pseudo_uppper_layer_pkt_length_mode        mode                      _none
            ipv6_pseudo_uppper_layer_pkt_length_step        step                      _none
            ipv6_pseudo_uppper_layer_pkt_length_tracking    tracking                  _none
    }
    

    set ipv6_pseudo_zero_field {
            ipv6_pseudo_zero_number          value_hex                 {p_format strict}
            ipv6_pseudo_zero_number_count    count                     _none
            ipv6_pseudo_zero_number_mode     mode                      _none
            ipv6_pseudo_zero_number_step     step                      _none
            ipv6_pseudo_zero_number_tracking tracking                  _none
    }
    
    set ipv6_fragment_frag_offset_field {
            ipv6_frag_offset                value                     _none
            ipv6_frag_offset_count          count                     _none
            ipv6_frag_offset_mode           mode                      _none
            ipv6_frag_offset_step           step                      _none
            ipv6_frag_offset_tracking       tracking                  _none
    }
    
    set ipv6_fragment_id_field {
            ipv6_frag_id                    value                     _none
            ipv6_frag_id_count              count                     _none
            ipv6_frag_id_mode               mode                      _none
            ipv6_frag_id_step               step                      _none
            ipv6_frag_id_tracking           tracking                  _none
    }
    
    set ipv6_fragment_more_frags_field {
            ipv6_frag_more_flag             value                     _none
            ipv6_frag_more_flag_mode        mode                      _none
            ipv6_frag_more_flag_tracking    tracking                  _none
    }
    
    set ipv6_fragment_next_header_field {}
    
    set ipv6_fragment_reserved_field {
            ipv6_frag_res_2bit              value                     _none
            ipv6_frag_res_2bit_count        count                     _none
            ipv6_frag_res_2bit_mode         mode                      _none
            ipv6_frag_res_2bit_step         step                      _none
            ipv6_frag_res_2bit_tracking     tracking                  _none
    }
    
    set ipv6_fragment_reserved_field8 {
            ipv6_frag_res_8bit              value_int_2_hex           {p_format strict}
            ipv6_frag_res_8bit_count        count                     _none
            ipv6_frag_res_8bit_mode         mode                      _none
            ipv6_frag_res_8bit_step         step                      _none
            ipv6_frag_res_8bit_tracking     tracking                  _none
    }
    
    set deprecated_ipv6_param_list {
            ipv6_auth_string            ipv6_auth_md5sha1_string
            ipv6_auth_string_count      ipv6_auth_md5sha1_string_count
            ipv6_auth_string_mode       ipv6_auth_md5sha1_string_mode
            ipv6_auth_string_step       ipv6_auth_md5sha1_string_step
            ipv6_auth_string_tracking   ipv6_auth_md5sha1_string_tracking
        }
    
    set msg_deprecated_params ""
    set msg_good_params ""
    foreach {deprecated_ipv6_param ixn_good_param} $deprecated_ipv6_param_list {
        if {[info exists $deprecated_ipv6_param] && ![is_default_param_value $deprecated_ipv6_param $all_args]} {
            lappend msg_deprecated_params $deprecated_ipv6_param
            lappend msg_good_params $ixn_good_param
        }
    }
    
    if {[llength $msg_deprecated_params] > 0} {
        puts "\nWARNING: The following parameters are deprecated with traffic_generator\
                ixnetwork_540: $msg_deprecated_params. Please use the following parameters:\
                $msg_good_params\n."
    }
    
    
    if {[info exists ipv6_auth_type] && $ipv6_auth_type == "md5"} {
        
        array set regex_enable_list [list \
            ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Authentication" [list \
                                                    ipv6Authentication\.header\.authenticationHeader\.authentication\.md5 \
                                                    ipv6Authentication\.header\.authenticationHeader\.nextHeader \
                                                    ipv6Authentication\.header\.authenticationHeader\.payloadLength \
                                                    ipv6Authentication\.header\.authenticationHeader\.reserved \
                                                    ipv6Authentication\.header\.authenticationHeader\.sequenceNumber \
                                                    ipv6Authentication\.header\.authenticationHeader\.authenticationHeader.spi \
                                                    ipv6Authentication\.header\.authenticationHeader\.pad \
                                                ]\
        ]
        
        array set regex_disable_list {
            ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Authentication" header\.authenticationHeader\.authentication\.sha1
        }
        
        foreach ipv6_auth_md5sha1_string_param {ipv6_auth_md5sha1_string ipv6_auth_md5sha1_string_step} {
            if {[info exists $ipv6_auth_md5sha1_string_param]} {
                if {![isValidHex [set $ipv6_auth_md5sha1_string_param]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid HEX value '[set $ipv6_auth_md5sha1_string_param]' for parameter $ipv6_auth_md5sha1_string_param."
                    return $returnList
                }
                
                if {[string length [convert_string_to_hex [set $ipv6_auth_md5sha1_string_param]]] > 32} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When -ipv6_auth_type is '$ipv6_auth_type', '$ipv6_auth_md5sha1_string_param' parameter\
                            must be a valid hex no longer than 16 bytes."
                    return $returnList
                }
            }
        }
        
        set ipv6_auth_md5_field {
                ipv6_auth_md5sha1_string                value_hex                 {p_format strict}
                ipv6_auth_md5sha1_string_count          count                     _none
                ipv6_auth_md5sha1_string_mode           mode                      _none
                ipv6_auth_md5sha1_string_step           step                      _none
                ipv6_auth_md5sha1_string_tracking       tracking                  _none
        }
        
        set ipv6_auth_sha1_field ""
    } else {
        
        foreach ipv6_auth_md5sha1_string_param {ipv6_auth_md5sha1_string ipv6_auth_md5sha1_string_step} {
            if {[info exists $ipv6_auth_md5sha1_string_param]} {
                if {![isValidHex [set $ipv6_auth_md5sha1_string_param]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid HEX value '[set $ipv6_auth_md5sha1_string_param]' for parameter $ipv6_auth_md5sha1_string_param."
                    return $returnList
                }
                
                if {[string length [convert_string_to_hex [set $ipv6_auth_md5sha1_string_param]]] > 40} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When -ipv6_auth_type is '$ipv6_auth_type', '$ipv6_auth_md5sha1_string_param' parameter\
                            must be a valid hex no longer than 20 bytes."
                    return $returnList
                }
            }
        }
        
        array set regex_enable_list [list \
            ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Authentication" [list \
                                                    ipv6Authentication\.header\.authenticationHeader\.authentication\.sha1 \
                                                    ipv6Authentication\.header\.authenticationHeader\.nextHeader \
                                                    ipv6Authentication\.header\.authenticationHeader\.payloadLength \
                                                    ipv6Authentication\.header\.authenticationHeader\.reserved \
                                                    ipv6Authentication\.header\.authenticationHeader\.sequenceNumber \
                                                    ipv6Authentication\.header\.authenticationHeader\.authenticationHeader.spi \
                                                    ipv6Authentication\.header\.authenticationHeader\.pad \
                                                ]\
        ]
        
        array set regex_disable_list {
            ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Authentication" header\.authenticationHeader\.authentication\.md5
        }
        
        set ipv6_auth_sha1_field {
                ipv6_auth_md5sha1_string                value_hex                 {p_format strict}
                ipv6_auth_md5sha1_string_count          count                     _none
                ipv6_auth_md5sha1_string_mode           mode                      _none
                ipv6_auth_md5sha1_string_step           step                      _none
                ipv6_auth_md5sha1_string_tracking       tracking                  _none
        }
        
        set ipv6_auth_md5_field ""
    }
    
    set ipv6_auth_next_header_field {
            ipv6_auth_next_header           value                     _none
            ipv6_auth_next_header_count     count                     _none
            ipv6_auth_next_header_mode      mode                      _none
            ipv6_auth_next_header_step      step                      _none
            ipv6_auth_next_header_tracking  tracking                  _none
    }
    
    set ipv6_auth_padding_field {
            ipv6_auth_padding               value_hex                 {p_format strict}
            ipv6_auth_padding_count         count                     _none
            ipv6_auth_padding_mode          mode                      _none
            ipv6_auth_padding_step          step                      _none
            ipv6_auth_padding_tracking      tracking                  _none
    }
    
    set ipv6_auth_payload_length_field {
            ipv6_auth_payload_len           value                     _none
            ipv6_auth_payload_len_count     count                     _none
            ipv6_auth_payload_len_mode      mode                      _none
            ipv6_auth_payload_len_step      step                      _none
            ipv6_auth_payload_len_tracking  tracking                  _none
    }
    
    set ipv6_auth_reserved_field {
            ipv6_auth_reserved              value_hex                 {p_format strict}
            ipv6_auth_reserved_count        count                     _none
            ipv6_auth_reserved_mode         mode                      _none
            ipv6_auth_reserved_step         step                      _none
            ipv6_auth_reserved_tracking     tracking                  _none
    }
    
    set ipv6_auth_sec_param_idx_field {
            ipv6_auth_spi                   value_hex                 {p_format strict}
            ipv6_auth_spi_count             count                     _none
            ipv6_auth_spi_mode              mode                      _none
            ipv6_auth_spi_step              step                      _none
            ipv6_auth_spi_tracking          tracking                  _none
    }
    
    set ipv6_auth_seq_no_field {
            ipv6_auth_seq_num               value_hex                 {p_format strict}
            ipv6_auth_seq_num_count         count                     _none
            ipv6_auth_seq_num_mode          mode                      _none
            ipv6_auth_seq_num_step          step                      _none
            ipv6_auth_seq_num_tracking      tracking                  _none
    }
    
    set ipv6_destination_addr_field {
            ipv6_dst_addr                   value                     {p_format  strict}
            ipv6_dst_count                  count                     _none
            ipv6_dst_mode                   mode                      {translate ipv6_mode_translate}
            ipv6_dst_step                   step                      _none
            ipv6_dst_tracking               tracking                  _none
    }
    
    array set ipv6_mode_translate {
        fixed                       fixed
        increment                   incr
        decrement                   decr
        incr_host                   incr
        decr_host                   decr
        incr_network                incr
        decr_network                decr
        incr_intf_id                incr
        decr_intf_id                decr
        incr_global_top_level       incr
        decr_global_top_level       decr
        incr_global_next_level      incr
        decr_global_next_level      decr
        incr_global_site_level      incr
        decr_global_site_level      decr
        incr_local_site_subnet      incr
        decr_local_site_subnet      decr
        incr_mcast_group            incr
        decr_mcast_group            decr
        list                        list
        random                      fixed
    }
    
    if {[info exists qos_ipv6_flow_label]} {
        set ipv6_flow_label_field {
                qos_ipv6_flow_label             value                     _none
                ipv6_flow_label_count           count                     _none
                ipv6_flow_label_mode            mode                      _none
                ipv6_flow_label_step            step                      _none
                ipv6_flow_label_tracking        tracking                  _none
        }
    } else {
        set ipv6_flow_label_field {
                ipv6_flow_label                 value                     _none
                ipv6_flow_label_count           count                     _none
                ipv6_flow_label_mode            mode                      _none
                ipv6_flow_label_step            step                      _none
                ipv6_flow_label_tracking        tracking                  _none
        }
    }
    
    set ipv6_hop_limit_field {
            ipv6_hop_limit                  value                     _none
            ipv6_hop_limit_count            count                     _none
            ipv6_hop_limit_mode             mode                      _none
            ipv6_hop_limit_step             step                      _none
            ipv6_hop_limit_tracking         tracking                  _none
    }
    
    set ipv6_next_header_field {
            ipv6_next_header                value                     _none
            ipv6_next_header_count          count                     _none
            ipv6_next_header_mode           mode                      _none
            ipv6_next_header_step           step                      _none
            ipv6_next_header_tracking       tracking                  _none
    }
    # BUG761699: If the ipv6_next_header is not provided we must set the "Next Header" mode to auto
    if {![info exists ipv6_next_header]} {
        set ipv6_next_header_mode auto
    }
    
    set ipv6_payload_length_field {}
    
    set ipv6_source_addr_field {
            ipv6_src_addr                   value                     {p_format  strict}
            ipv6_src_count                  count                     _none
            ipv6_src_mode                   mode                      {translate ipv6_mode_translate}
            ipv6_src_step                   step                      _none
            ipv6_src_tracking               tracking                  _none
    }
    
    if {[info exists qos_ipv6_traffic_class]} {
        set ipv6_traffic_class_field {
                qos_ipv6_traffic_class          value                     _none
                ipv6_traffic_class_count        count                     _none
                ipv6_traffic_class_mode         mode                      _none
                ipv6_traffic_class_step         step                      _none
                ipv6_traffic_class_tracking     tracking                  _none
        }
    } else {
        set ipv6_traffic_class_field {
                ipv6_traffic_class              value                     _none
                ipv6_traffic_class_count        count                     _none
                ipv6_traffic_class_mode         mode                      _none
                ipv6_traffic_class_step         step                      _none
                ipv6_traffic_class_tracking     tracking                  _none
        }
    }
    
    set ipv6_version_field {
            ipv6_flow_version               value                     _none
            ipv6_flow_version_count         count                     _none
            ipv6_flow_version_mode          mode                      _none
            ipv6_flow_version_step          step                      _none
            ipv6_flow_version_tracking      tracking                  _none
    }
    
    set ipv6_hop_by_hop_head_ext_length_field {
    }
    
    set ipv6_hop_by_hop_next_header_field {
    }
    
    set ipv6_hop_by_hop_padding_field {
    }
    
    set ipv6_hop_by_hop_ud_unrecognized_type {
        ipv6_hop_by_hop_ud_unrecognized_type_value        value                     _none
        ipv6_hop_by_hop_ud_unrecognized_type_count        count                     _none
        ipv6_hop_by_hop_ud_unrecognized_type_mode         mode                      _none
        ipv6_hop_by_hop_ud_unrecognized_type_step         step                      _none
        iipv6_hop_by_hop_ud_unrecognized_type_tracking    tracking                  _none
    }
    
    set ipv6_hop_by_hop_ud_allow_packet_change {
        ipv6_hop_by_hop_ud_allow_packet_change_value        value                     _none
        ipv6_hop_by_hop_ud_allow_packet_change_count        count                     _none
        ipv6_hop_by_hop_ud_allow_packet_change_mode         mode                      _none
        ipv6_hop_by_hop_ud_allow_packet_change_step         step                      _none
        iipv6_hop_by_hop_ud_allow_packet_change_tracking    tracking                  _none
    }
    
    set ipv6_hop_by_hop_ud_user_defined_type {
        ipv6_hop_by_hop_ud_user_defined_type_value        value                     _none
        ipv6_hop_by_hop_ud_user_defined_type_count        count                     _none
        ipv6_hop_by_hop_ud_user_defined_type_mode         mode                      _none
        ipv6_hop_by_hop_ud_user_defined_type_step         step                      _none
        ipv6_hop_by_hop_ud_user_defined_type_tracking     tracking                  _none
    }
    
    set ipv6_hop_by_hop_ud_length {
        ipv6_hop_by_hop_ud_length_value        value                     _none
        ipv6_hop_by_hop_ud_length_count        count                     _none
        ipv6_hop_by_hop_ud_length_mode         mode                      _none
        ipv6_hop_by_hop_ud_length_step         step                      _none
        ipv6_hop_by_hop_ud_length_tracking     tracking                  _none
    }
    
    set ipv6_hop_by_hop_ud_data {
        ipv6_hop_by_hop_ud_data_value        value_hex                 _none
        ipv6_hop_by_hop_ud_data_count        count                     _none
        ipv6_hop_by_hop_ud_data_mode         mode                      _none
        ipv6_hop_by_hop_ud_data_step         step                      _none
        ipv6_hop_by_hop_ud_data_tracking     tracking                  _none
    }

#     ipv6_hop_by_hop_ud_unrecognized_type_value
#     ipv6_hop_by_hop_ud_allow_packet_change_value
#     ipv6_hop_by_hop_ud_user_defined_type_value
#     ipv6_hop_by_hop_ud_length_value
#     ipv6_hop_by_hop_ud_data_value
#     {{type user_defined} {unrecognized_type 0}              {allow_packet_change 0} {user_defined_type } {length } {data }}
#                          skip                           0         0   0               0-31                 0-255     hex
#                          discard                        1         1   1
#                          discard_icmp                   10
#                          discard_icmp_if_not_multicast  11

    set ipv6_hop_by_hop_padn_type {
        ipv6_hop_by_hop_padn_type_value        value                     _none
        ipv6_hop_by_hop_padn_type_count        count                     _none
        ipv6_hop_by_hop_padn_type_mode         mode                      _none
        ipv6_hop_by_hop_padn_type_step         step                      _none
        ipv6_hop_by_hop_padn_type_tracking     tracking                  _none
    }
    
    set ipv6_hop_by_hop_padn_length {
        ipv6_hop_by_hop_padn_length_value        value                     _none
        ipv6_hop_by_hop_padn_length_count        count                     _none
        ipv6_hop_by_hop_padn_length_mode         mode                      _none
        ipv6_hop_by_hop_padn_length_step         step                      _none
        ipv6_hop_by_hop_padn_length_tracking     tracking                  _none
    }
    
    set ipv6_hop_by_hop_padn_data {
        ipv6_hop_by_hop_padn_data_value        value_hex                 _none
        ipv6_hop_by_hop_padn_data_count        count                     _none
        ipv6_hop_by_hop_padn_data_mode         mode                      _none
        ipv6_hop_by_hop_padn_data_step         step                      _none
        ipv6_hop_by_hop_padn_data_tracking     tracking                  _none
    }
    
    set ipv6_hop_by_hop_pad1 {
        ipv6_hop_by_hop_pad1_data_value        value                     _none
        ipv6_hop_by_hop_pad1_data_count        count                     _none
        ipv6_hop_by_hop_pad1_data_mode         mode                      _none
        ipv6_hop_by_hop_pad1_data_step         step                      _none
        ipv6_hop_by_hop_pad1_data_tracking     tracking                  _none
    }
    
    #
    # Cleanup all the "N/A" elements in the parameters for extension headers
    # With hltapi ixTclHal wrapper, the extension header parameters had to have the same length with
    # ipv6_extension_header parameter. With hltapi ixnetwork wrapper the extension header parameters
    # have to have the length equal to the number of times the extension header that they configure
    # appears in parameter ipv6_extension_header.
    # The tclHal hltapi wrapper version required N/A elements where they didn't apply.
    #
    
    foreach extension_pt [array names protocol_template_field_map] {
        if {$extension_pt == "::ixNet::OBJ-/traffic/protocolTemplate:\"ipv6\""} {
            # Only do N/A strip for extension headers
            continue
        }
        
        foreach extension_pt_field $protocol_template_field_map($extension_pt) {
            foreach {extension_pt_field_hlt_p dummy0 dummy1} [set $extension_pt_field] {
                if {![info exists $extension_pt_field_hlt_p] || [llength [set $extension_pt_field_hlt_p]] < 2} {
                    continue
                }
                regsub -all {N/A} [set $extension_pt_field_hlt_p] "" $extension_pt_field_hlt_p
                set $extension_pt_field_hlt_p [string trim [set $extension_pt_field_hlt_p]]
            }
        }
    }
    
    # Before we remove the N/A values from ipv6_hop_by_hop_options we should determine the
    # number of non-N/A elements
    set ipv6_hop_by_hop_options_count 0
    set ipv6_hop_by_hop_options_stripped ""
    if {[info exists ipv6_hop_by_hop_options]} {
        foreach ipv6_hop_by_hop_option $ipv6_hop_by_hop_options {
            if {$ipv6_hop_by_hop_option != "N/A"} {
                lappend ipv6_hop_by_hop_options_stripped $ipv6_hop_by_hop_option
                incr ipv6_hop_by_hop_options_count
            }
        }
    }
    
    set ipv6_hop_by_hop_options $ipv6_hop_by_hop_options_stripped
    catch {unset ipv6_hop_by_hop_options_stripped}
    catch {unset ipv6_hop_by_hop_option}
    
    # Done N/A cleanp
    
    #
    # Transform keyed list hop_by_hop options into the ipv6_hop_by_hop* params
    #
    set unsupported_hbh_options ""
    if {[info exists ipv6_hop_by_hop_options] && [llength $ipv6_hop_by_hop_options] > 0} {
        
        foreach ipv6_hop_by_hop_option_set $ipv6_hop_by_hop_options {
            # There is one ipv6_hop_by_hop_option_set for each hop_by_hop protocol template stack
            
            set ipv6_hbh_param_list {
                ipv6_hop_by_hop_padn_type_value             
                ipv6_hop_by_hop_padn_length_value           
                ipv6_hop_by_hop_padn_data_value             
                ipv6_hop_by_hop_pad1_data_value             
                ipv6_hop_by_hop_ud_unrecognized_type_value  
                ipv6_hop_by_hop_ud_allow_packet_change_value
                ipv6_hop_by_hop_ud_user_defined_type_value  
                ipv6_hop_by_hop_ud_length_value             
                ipv6_hop_by_hop_ud_data_value               
            }
            
            
            foreach ipv6_hop_by_hop_param $ipv6_hbh_param_list {
                set ${ipv6_hop_by_hop_param}_tmp ""
            }
            
            if {[regexp -all {type} $ipv6_hop_by_hop_option_set] > 1} {
                # It's a list of hop by hop options

                foreach hbh_opt_kl $ipv6_hop_by_hop_option_set {
                    # There multiple hop by hop options in this protocol stack
                    
                    switch -- [keylget hbh_opt_kl type] {
                        pad1 {
                            lappend ipv6_hop_by_hop_pad1_data_value_tmp 0
                        }
                        padn {
                            lappend ipv6_hop_by_hop_padn_type_value_tmp 1
                                                    
                            if {![catch {keylget hbh_opt_kl length} tmp_padn_length]} {
                                lappend ipv6_hop_by_hop_padn_length_value_tmp $tmp_padn_length
                            } else {
                                lappend ipv6_hop_by_hop_padn_length_value_tmp 1
                            }
                            
                            if {![catch {keylget hbh_opt_kl value} tmp_padn_value]} {
                                lappend ipv6_hop_by_hop_padn_data_value_tmp $tmp_padn_value
                            } else {
                                lappend ipv6_hop_by_hop_padn_data_value_tmp 0
                            }
                        }
                        user_defined {
#     {{type user_defined} {unrecognized_type 0}              {allow_packet_change 0} {user_defined_type } {length } {data }}
#                          skip                           0         0   0               0-31                 0-255     hex
#                          discard                        1         1   1
#                          discard_icmp                   10
#                          discard_icmp_if_not_multicast  11
                            if {![catch {keylget hbh_opt_kl unrecognized_type} unrecognized_type]} {
                                switch -- $unrecognized_type {
                                    skip {
                                        lappend ipv6_hop_by_hop_ud_unrecognized_type_value_tmp 0
                                    }
                                    discard {
                                        lappend ipv6_hop_by_hop_ud_unrecognized_type_value_tmp 1
                                    }
                                    discard_icmp {
                                        lappend ipv6_hop_by_hop_ud_unrecognized_type_value_tmp 3
                                    }
                                    discard_icmp_if_not_multicast {
                                        lappend ipv6_hop_by_hop_ud_unrecognized_type_value_tmp 3
                                    }
                                    default {
                                        keylset returnList "Invalid value '$unrecognized_type' for option type 'user_defined' in\
                                                IPv6 Hop by Hop extension header. Known values are: skip, discard, discard_icmp, discard_icmp_if_not_multicast."
                                        keylset returnList status $::FAILURE
                                        return $returnList
                                    }
                                }
                            }
                            
                            if {![catch {keylget hbh_opt_kl allow_packet_change} allow_packet_change]} {
                                lappend ipv6_hop_by_hop_ud_allow_packet_change_value_tmp $allow_packet_change
                            }
                            
                            if {![catch {keylget hbh_opt_kl user_defined_type} user_defined_type]} {
                                lappend ipv6_hop_by_hop_ud_user_defined_type_value_tmp $user_defined_type
                            }
                            
                            if {![catch {keylget hbh_opt_kl length} length]} {
                                lappend ipv6_hop_by_hop_ud_length_value_tmp $length
                            }
                            
                            if {![catch {keylget hbh_opt_kl data} data]} {
                                lappend ipv6_hop_by_hop_ud_data_value_tmp $data
                            }
                            
                        }
                        default {
                            if {[lsearch $unsupported_hbh_options [keylget hbh_opt_kl type]] == -1} {
                                lappend unsupported_hbh_options [keylget hbh_opt_kl type]
                            }
                            continue
                        }
                    }
                }
            } else {
                # Just one hop by hop option
                switch -- [keylget ipv6_hop_by_hop_option_set type] {
                    pad1 {
                        lappend ipv6_hop_by_hop_pad1_data_value_tmp 0
                    }
                    padn {
                        lappend ipv6_hop_by_hop_padn_type_value_tmp 1
                                                
                        if {![catch {keylget ipv6_hop_by_hop_option_set length} tmp_padn_length]} {
                            lappend ipv6_hop_by_hop_padn_length_value_tmp $tmp_padn_length
                        } else {
                            lappend ipv6_hop_by_hop_padn_length_value_tmp 1
                        }
                        
                        if {![catch {keylget ipv6_hop_by_hop_option_set value} tmp_padn_value]} {
                            lappend ipv6_hop_by_hop_padn_data_value_tmp $tmp_padn_value
                        } else {
                            lappend ipv6_hop_by_hop_padn_data_value_tmp 0
                        }
                    }
                    user_defined {
                        if {![catch {keylget hbh_opt_kl unrecognized_type} unrecognized_type]} {
                            switch -- $unrecognized_type {
                                skip {
                                    lappend ipv6_hop_by_hop_ud_unrecognized_type_value_tmp 0
                                }
                                discard {
                                    lappend ipv6_hop_by_hop_ud_unrecognized_type_value_tmp 1
                                }
                                discard_icmp {
                                    lappend ipv6_hop_by_hop_ud_unrecognized_type_value_tmp 3
                                }
                                discard_icmp_if_not_multicast {
                                    lappend ipv6_hop_by_hop_ud_unrecognized_type_value_tmp 3
                                }
                                default {
                                    keylset returnList "Invalid value '$unrecognized_type' for option type 'user_defined' in\
                                            IPv6 Hop by Hop extension header. Known values are: skip, discard, discard_icmp, discard_icmp_if_not_multicast."
                                    keylset returnList status $::FAILURE
                                    return $returnList
                                }
                            }
                        }
                        
                        if {![catch {keylget hbh_opt_kl allow_packet_change} allow_packet_change]} {
                            lappend ipv6_hop_by_hop_ud_allow_packet_change_value_tmp $allow_packet_change
                        }
                        
                        if {![catch {keylget hbh_opt_kl user_defined_type} user_defined_type]} {
                            lappend ipv6_hop_by_hop_ud_user_defined_type_value_tmp $user_defined_type
                        }
                        
                        if {![catch {keylget hbh_opt_kl length} length]} {
                            lappend ipv6_hop_by_hop_ud_length_value_tmp $length
                        }
                        
                        if {![catch {keylget hbh_opt_kl data} data]} {
                            lappend ipv6_hop_by_hop_ud_data_value_tmp $data
                        }
                    }
                    default {
                        if {[lsearch $unsupported_hbh_options [keylget hbh_opt_kl type]] == -1} {
                            lappend unsupported_hbh_options [keylget hbh_opt_kl type]
                        }
                        continue
                    }
                }
            }
        }
        
        foreach ipv6_hop_by_hop_param $ipv6_hbh_param_list {
            if {[llength [set ${ipv6_hop_by_hop_param}_tmp]] > 0} {
                lappend ${ipv6_hop_by_hop_param} [set ${ipv6_hop_by_hop_param}_tmp]
            }
        }
    }
    
    if {[llength $unsupported_hbh_options] > 0} {
        puts "\nWARNING: Option types: '$unsupported_hbh_options' are not supported\
            with IxTclNetwork. They will not be included in the the Hop by Hop IPv6 extension stack."
    }

    
    # Done transforming keyed lists into regular lists
    
    if {![info exists encapsulation_pt_map($l3_protocol)]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Encapsulation $l3_protocol is not supported."
        return $returnList
    }
    
    set protocol_template_list $encapsulation_pt_map($l3_protocol)
    
    if {[info exists ipv6_extension_header]} {
        foreach single_ipv6_extension $ipv6_extension_header {
            if {![info exists encapsulation_pt_map($single_ipv6_extension)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Unexpected value '$single_ipv6_extension' for\
                        parameter -single_ipv6_extension. Known values are: [array names encapsulation_pt_map]."
                return $returnList
            }
            
            if {[llength $encapsulation_pt_map($single_ipv6_extension)] > 0} {
                
                # It can be 0 when single_ipv6_extension is 'none'. Adding protocol template that
                # is an empty string can be a source of bugs
                
                lappend protocol_template_list $encapsulation_pt_map($single_ipv6_extension)
            }
        }
    } else {
        # These parameter where kept to preserve backward compatibility
            if {[info exists ipv6_frag_offset] || [info exists ipv6_frag_id] \
                || [info exists ipv6_frag_more_flag]} {
            
            
            if {[info exists ipv6_frag_more_flag] && \
                    ($ipv6_frag_more_flag || \
                    ($ipv6_frag_more_flag == "") || \
                    ($ipv6_frag_more_flag == "1"))} {
                
                lappend protocol_template_list $encapsulation_pt_map(fragment)
            }
        }
    }
    
    switch -- $mode {
        "create" {
            
            # This procedure will remove the protocol templates that do not apply for this configElement
            # this is the case where multiple configElements exist on one traffic item.
            set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }

            set protocol_template_list [keylget ret_code pt_list]
            
            set ret_code [540IxNetTrafficL3AddHeaders $handle $handle_type $protocol_template_list]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set stack_handles [keylget ret_code handle]
        }
        "modify" {
        
            # For modify mode search for the ipv6 headers and modify them
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
            
            if {![info exists l3_protocol]} {
                # l3_protocol not provided. Nothing to append/prepend/replace
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
    
    #################################################################################
    #         This is an overview of how the parameters are configured using the 
    #         mapping arrays and lists:
    #         
    #         foreach stack $stack_handles {
    #             
    #             stack --> protocol_template (using proc 540IxNetStackGetProtocolTemplate)
    #             
    #             protocol_template --> hlt_field_list (using array protocol_template_field_map)
    #             
    #             foreach field $hlt_field_list {
    #                 
    #                 field --> list_of_params_for_field (using the lists with the same name as $field)
    #                 
    #                 foreach {hlt_param hlt_intermediate_param parameter_type} $list_of_params_for_field {
    #                     
    #                     build arg list for 540TrafficStackFieldConfig
    #                     use real field name in 540TrafficStackFieldConfig (real name obtained using hlt_ixn_field_name_map)
    #                 }
    #             }
    #         }
    ################################################################################
    
    #   Header protocol template                                            header index
    array set headers_multiple_instances {
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6HopByHopOptions"        hop_by_hop_idx
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6DestinationOptions"     ipv6_dest_opt_idx
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Authentication"         ipv6_auth_idx
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Fragment"               ipv6_fragment_idx
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Encapsulation"          ipv6_encap_idx
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6Pseudo"                 ipv6_pseudo_idx
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6RoutingType0"           ipv6_routing_t0_idx
    }
    
    foreach single_header [array names headers_multiple_instances] {
        set $headers_multiple_instances($single_header) 0
    }
    
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


proc ::ixia::540trafficL3Arp { args opt_args } {
    
    keylset returnList status $::SUCCESS
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    if {![info exists l3_protocol] || $l3_protocol != "arp"} {
        
        set set_arp 0
        set arp_args [getVarListFromArgs $opt_args]
        foreach arp_single_arg $arp_args {
            if {[regexp {^arp_} $arp_single_arg]} {
                if {[info exists $arp_single_arg]} {
                    set set_arp 1
                    break
                }
            }
        }    
        
        if {!$set_arp} {
            # We don't have any ARP configurations to do
            # Return success
            return $returnList
        } else {
            set l3_protocol "arp"
        }
    }
    
    # Insert here the parameter that allows this funciton to configure
    # For example, l3_protocol must be ipv4 in order to configure ipv4 stuff
    if {![info exists l3_protocol] || $l3_protocol != "arp"} {
        # Don't configure because it's not requested
        debug "ARP not needed"
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
        arp                        {::ixNet::OBJ-/traffic/protocolTemplate:"ethernetARP"}
    }

    # This array contains a mapping between the stack field names and an hlt firendly name
    # The hlt friendly name is not an HLT parameter name. It is used to access field names
    # without the errors that spaced names could insert.
    # Remove the two entries. They are just examples.
    
    array set hlt_ixn_field_name_map {
            arp_hardware_type_field               "Hardware Type"
            arp_protocol_type_field               "Protocol Type"
            arp_hardware_address_length_field     "Hardware Address Length"
            arp_protocol_address_length_field     "Protocol Address Length"
            arp_op_code                           "Op Code"
            arp_sender_hardware_address_field     "Sender Hardware Address"
            arp_sender_protocol_address_field     "Sender Protocol Address"
            arp_target_hardware_address_field     "Target Hardware Address"
            arp_target_protocol_address_field     "Target Protocol Address"
    }
    
    # Array that establishes what fields will be configured for each protocol template.
    # The fields associated with each protocol template are the hlt friendly names from hlt_ixn_field_name_map
    # Remove the entries, they are just an example
    array set protocol_template_field_map [list                                                                      \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ethernetARP"            [list                                        \
                                                                         arp_sender_protocol_address_field           \
                                                                         arp_sender_hardware_address_field           \
                                                                         arp_protocol_type_field                     \
                                                                         arp_hardware_type_field                     \
                                                                         arp_protocol_address_length_field           \
                                                                         arp_hardware_address_length_field           \
                                                                         arp_target_protocol_address_field           \
                                                                         arp_target_hardware_address_field           \
                                                                         arp_op_code                                 \
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
    
    
    #       hlt_param                     param_class                   extra
    set ip_src_found 0
    foreach ip_param {ip_src_addr ip_src_count ip_src_mode ip_src_step ip_src_tracking} {
        if {[info exists $ip_param]} {
            set ip_src_found 1
            break
        }
    }
    
    set ip_dst_found 0
    foreach ip_param {ip_dst_addr ip_dst_count ip_dst_mode ip_dst_step ip_dst_tracking} {
        if {[info exists $ip_param]} {
            set ip_dst_found 1
            break
        }
    }
    
    if {$ip_src_found} {
        set arp_sender_protocol_address_field {
                ip_src_addr                     value_ipv4                {p_format  strict}
                ip_src_count                    count                     _none
                ip_src_mode                     mode                      {translate ip_src_mode_translate}
                ip_src_step                     step                      _none
                ip_src_tracking                 tracking                  _none
        }
        
        array set ip_src_mode_translate {
            fixed           fixed
            increment       incr
            decrement       decr
            random          fixed
            emulation       auto
            list            list
        }
    
    } else {
        set arp_sender_protocol_address_field {
                arp_src_protocol_addr          value_ipv4                    {p_format  strict}
                arp_src_protocol_addr_count    count                         _none
                arp_src_protocol_addr_mode     mode                          _none
                arp_src_protocol_addr_step     step                          _none
                arp_src_protocol_addr_tracking tracking                      _none
        }
    }
    
    set arp_sender_hardware_address_field {
            arp_src_hw_addr               value_mac                     {p_format  strict}
            arp_src_hw_count              count                         _none
            arp_src_hw_mode               mode                          {translate hw_addr_mode_translate}
            arp_src_hw_step               step                          _none
            arp_src_hw_tracking           tracking                      _none
    }
    
    set arp_protocol_type_field {
            arp_protocol_type             value_hex                     {p_format  strict}
            arp_protocol_type_count       count                         _none
            arp_protocol_type_mode        mode                          _none
            arp_protocol_type_step        step                          _none
            arp_protocol_type_tracking    tracking                      _none
    }
    
    set arp_hardware_type_field {
            arp_hw_type                   value_hex                     {p_format  strict}
            arp_hw_type_count             count                         _none
            arp_hw_type_mode              mode                          _none
            arp_hw_type_step              step                          _none
            arp_hw_type_tracking          tracking                      _none
    }
    
    set arp_protocol_address_length_field {
            arp_protocol_addr_length           value_hex                {p_format  strict}
            arp_protocol_addr_length_count     count                    _none
            arp_protocol_addr_length_mode      mode                     _none
            arp_protocol_addr_length_step      step                     _none
            arp_protocol_addr_length_tracking  tracking                 _none
    }
    
    set arp_hardware_address_length_field {
            arp_hw_address_length           value_hex                   {p_format  strict}
            arp_hw_address_length_count     count                       _none
            arp_hw_address_length_mode      mode                        _none
            arp_hw_address_length_step      step                        _none
            arp_hw_address_length_tracking  tracking                    _none
    }
    
    if {$ip_dst_found} {
        set arp_target_protocol_address_field {
                ip_dst_addr                     value_ipv4                {p_format  strict}
                ip_dst_count                    count                     _none
                ip_dst_mode                     mode                      {translate ip_dst_mode_translate}
                ip_dst_step                     step                      _none
                ip_dst_tracking                 tracking                  _none
        }
        
        array set ip_dst_mode_translate {
            fixed           fixed
            increment       incr
            decrement       decr
            random          fixed
            emulation       auto
            list            list
        }
    } else {
        set arp_target_protocol_address_field {
                arp_dst_protocol_addr          value_ipv4                    {p_format  strict}
                arp_dst_protocol_addr_count    count                         _none
                arp_dst_protocol_addr_mode     mode                          _none
                arp_dst_protocol_addr_step     step                          _none
                arp_dst_protocol_addr_tracking tracking                      _none
        }
    }
    
    set arp_target_hardware_address_field {
            arp_dst_hw_addr               value_mac                     {p_format  strict}
            arp_dst_hw_count              count                         _none
            arp_dst_hw_mode               mode                          {translate hw_addr_mode_translate}
            arp_dst_hw_step               step                          _none
            arp_dst_hw_tracking           tracking                      _none
    }
    
    set arp_op_code {
            arp_operation                 value_translate               {array_map arp_operation_map_array}
            arp_operation_mode            mode                          _none
            arp_operation_tracking        tracking                      _none
    }
    
    array set hw_addr_mode_translate {
        fixed                       fixed
        increment                   incr
        decrement                   decr
        list                        list
    }
    
    array set arp_operation_map_array {
        unknown             0
        arpRequest          1
        arpReply            2
        rarpRequest         3
        rarpReply           4
    }
    
    # In this section you must configure the protocol templates that will be added/configured
    # based on the indicators from your example. (l3_protocol, l2_encap.... ipv6_extensions...)
    set protocol_template_list $encapsulation_pt_map($l3_protocol)
    
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
            if {![info exists l3_protocol]} {
                # l3_protocol not provided. Nothing to append/prepend/replace
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
