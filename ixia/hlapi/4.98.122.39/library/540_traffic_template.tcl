proc ::ixia::540trafficTemplate { args opt_args} {
    
    debug "args == $args"
    debug "opt_args == $opt_args"

    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    # Insert here the parameter that allows this funciton to configure
    # For example, l3_protocol must be ipv4 in order to configure ipv4 stuff
    if {![info exists _some_parameter_]} {
        # Don't configure because it's not requested
        return $returnList
    }
    
    
    if {$_some_parameter_ != "_expected_value_"} {
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
        ipv6                        {::ixNet::OBJ-/traffic/protocolTemplate:"ipv6"}
        none                        {}
    }

    # This array contains a mapping between the stack field names and an hlt firendly name
    # The hlt friendly name is not an HLT parameter name. It is used to access field names
    # without the errors that spaced names could insert.
    # Remove the two entries. They are just examples.
    
    array set hlt_ixn_field_name_map {
            ipv6_destination_addr_field             "Destination Address"
            ipv6_flow_label_field                   "Flow Label"
    }
    
    # Configure variable 'use_name_instead_of_displayname' to '1' if the mapping is done with the 
    # -name property of the field object instead of the -displayName (the example above uses -displayName)
    # or 2 if hlt_ixn_field_name_map contains the decision whether to use name or displayName
    set use_name_instead_of_displayname 1
    
    # Array that establishes what fields will be configured for each protocol template.
    # The fields associated with each protocol template are the hlt friendly names from hlt_ixn_field_name_map
    # Remove the entries, they are just an example
    array set protocol_template_field_map [list                                                                      \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6"                   [list                                        \
                                                                         ipv6_destination_addr_field                 \
                                                                         ipv6_flow_label_field                       \
                                                                        ]                                            \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6HopByHopOptions"    [list                                        \
                                                                         ipv6_hop_by_hop_head_ext_length_field       \
                                                                         ipv6_hop_by_hop_next_header_field           \
                                                                        ]                                            \
    ]
    
    
    # Some fields support multiple instances withing a stack.
    # For example, for 5 route table entrys there are 5 sets of route table entry fields
    # The 'multi level fields' are configured using lists (1 element for each level) 
    # Use the multiple_level_fields to specify which fields will be subject to this behavior.
    
    array set multiple_level_fields [list                                                               \
        ::ixNet::OBJ-/traffic/protocolTemplate:"rip1"                   [list                           \
                                                                         rip_rte_unused2_v1_field       \
                                                                         rip_rte_ipv4_addr_field        \
                                                                         rip_rte_unused3_v1_field       \
                                                                         rip_rte_unused4_v1_field       \
                                                                         rip_rte_metric_field           \
                                                                        ]                               \
        ::ixNet::OBJ-/traffic/protocolTemplate:"rip2"                   [list                           \
                                                                         rip_rte_ipv4_addr_field        \
                                                                         rip_rte_metric_field           \
                                                                         rip_rte_route_tag_v2_field     \
                                                                         rip_rte_subnet_mask_v2_field   \
                                                                         rip_rte_next_hop_v2_field      \
                                                                        ]                               \
    ]
    
    # If a parameter is a list of lists like in the example below, we need to configure 
    # imbricated multi level fields.
    # Use this array to specify which fields need this type of configuration.
    # Also you must pass multiple_level_fields_ro_counter array
    # It specifies which is the read only field that specifies how many inner multi level fields
    # per outer level field (see igmpv3 membership report messages as an example)
     
#     -igmp_multicast_src {                   \
#             {                                   \
#                 21.0.0.1                        \
#                 21.0.0.2                        \
#                 21.0.0.11                       \
#                 21.0.0.14                       \
#             }                                   \
#             {                                   \
#                 22.0.0.71                       \
#                 22.0.0.32                       \
#                 22.0.0.13                       \
#                 22.0.0.54                       \
#                 22.0.0.5                        \
#             }                                   \
#             {                                   \
#                 23.0.0.11                       \
#             }                                   \
#             {                                   \
#                 24.0.0.1                        \
#                 24.0.0.12                       \
#                 24.0.0.3                        \
#             }                                   \
#             {                                   \
#                 25.0.0.1                        \
#                 25.0.0.51                       \
#             }                                   \
#             {                                   \
#                 26.0.0.62                       \
#                 26.0.0.63                       \
#             }                                   \
#         }   }
    
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
        
    #       hlt_param                       param_class               extra
    set ipv4_source_address_field {
            ip_src_addr                     value_ipv4                {p_format  strict}
            ip_src_count                    count                     _none
            ip_src_mode                     mode                      {translate ip_src_mode_translate}
            ip_src_step                     step                      _none
            ip_src_tracking                 tracking                  _none
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
    }
    
    # In this section you must configure the protocol templates that will be added/configured
    # based on the indicators from your example. (l3_protocol, l2_encap.... ipv6_extensions...)
    set protocol_template_list $list_of_pt_that_will_be_configured    
    
    switch -- $mode {
        "create" {
            
            # Build your own procedure 540IxNetTrafficProcThatAddsHeaders and change the name of course :)
            # This procedure must take the protocol templates and add them in the packet based on some rules
            # For example, if the protocol templates are layer3
            #   1. see if the template wasn't already added
            #   2. if it wasn't find the last L3 header and add after it
            #   3. If no L3 headers present, add after last L2
            #   ... make your own particular rules
            
            set ret_code [540IxNetTrafficProcThatAddsHeaders $handle $handle_type $protocol_template_list]
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
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6HopByHopOptions"        hop_by_hop_idx
        ::ixNet::OBJ-/traffic/protocolTemplate:"ipv6DestinationOptions"     ipv6_dest_opt_idx
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
    
    array set regex_enable_list {
        ::ixNet::OBJ-/traffic/protocolTemplate:"gre" \
            {gre\.header\.checksumPresent
        	 gre\.header\.reserved1}
  	}
  	
  	array set regex_disable_list {
        ::ixNet::OBJ-/traffic/protocolTemplate:"gre" \
               {gre\.header\.checksumPresent
            	gre\.header\.reserved1
            	gre\.header\.keyPresent
            	gre\.header\.sequencePresent}
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