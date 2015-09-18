proc ::ixia::540trafficL2Atm { args opt_args } {
    
    keylset returnList status $::SUCCESS
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
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
    
    if {[catch {ixNet getA $vport_handle/l1Config -currentType} currentType]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get port type for virtual port $vport_handle. $currentType"
        return $returnList
    }
    
    debug "===> currentType == $currentType"
    
    if {$currentType != "atm"} {
        # No need to go into config part
        return $returnList
    }
    
    array set encapsulation_map {
        vcc_mux_ipv4_routed          {::ixNet::OBJ-/traffic/protocolTemplate:"aal5"}
        vcc_mux_bridged_eth_fcs      {::ixNet::OBJ-/traffic/protocolTemplate:"aal5" ::ixNet::OBJ-/traffic/protocolTemplate:"vcMuxBridgedEthernet"}
        vcc_mux_bridged_eth_no_fcs   {::ixNet::OBJ-/traffic/protocolTemplate:"aal5" ::ixNet::OBJ-/traffic/protocolTemplate:"vcMuxBridgedEthernet"}
        vcc_mux_ipv6_routed          {::ixNet::OBJ-/traffic/protocolTemplate:"aal5"}
        vcc_mux_mpls_routed          {::ixNet::OBJ-/traffic/protocolTemplate:"aal5"}
        llc_routed_clip              {::ixNet::OBJ-/traffic/protocolTemplate:"aal5" ::ixNet::OBJ-/traffic/protocolTemplate:"llcSNAP"}
        llc_bridged_eth_fcs          {::ixNet::OBJ-/traffic/protocolTemplate:"aal5" ::ixNet::OBJ-/traffic/protocolTemplate:"llcBridgedEthernet"}
        llc_bridged_eth_no_fcs       {::ixNet::OBJ-/traffic/protocolTemplate:"aal5" ::ixNet::OBJ-/traffic/protocolTemplate:"llcBridgedEthernet"}
        llc_pppoa                    {::ixNet::OBJ-/traffic/protocolTemplate:"llcPPP"}
        vcc_mux_ppoa                 {::ixNet::OBJ-/traffic/protocolTemplate:"vcMuxPPP"}
        llc_ppp                      {::ixNet::OBJ-/traffic/protocolTemplate:"llcPPP"}
        llc_routed_snap              {::ixNet::OBJ-/traffic/protocolTemplate:"aal5" ::ixNet::OBJ-/traffic/protocolTemplate:"llcSNAP"}
        vcc_mux_ppp                  {::ixNet::OBJ-/traffic/protocolTemplate:"aal5" ::ixNet::OBJ-/traffic/protocolTemplate:"vcMuxPPP"}
        vcc_mux_routed               {::ixNet::OBJ-/traffic/protocolTemplate:"aal5"}
    }
    
    switch -- $mode {
        "create" {
            
            switch -- $handle_type {
                "traffic_item" {
                    set retrieve [540getConfigElementOrHighLevelStream $handle]
                    if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
                    set handle [keylget retrieve handle]
                }
                "config_element" {
                    # do nothing
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid handle type $handle_type for mode $mode."
                    return $returnList
                }
            }
            
            if {[info exists atm_header_encapsulation] && [catch {set protocol_template_list $encapsulation_map($atm_header_encapsulation)} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Atm encapsulation is not supported $atm_header_encapsulation.\
                        Supported encapsulations are: [array names encapsulation_map]."
                return $returnList
            }
            
            
            
            if {[info exists protocol_template_list]} {
                set remove_llcsnap 0
                if {[info exists protocol_template_list] && ![regexp {llcSNAP} $protocol_template_list]} {
                    set remove_llcsnap 1
                }
                
                # This procedure will remove the protocol templates that do not apply for this configElement
                # this is the case where multiple configElements exist on one traffic item.
                set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set protocol_template_list [keylget ret_code pt_list]
                
                set ret_code [540IxNetTrafficL2AddHeaders $handle $handle_type $protocol_template_list 1]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set stack_handles [keylget ret_code handle]
            }
            
            if {[info exists remove_llcsnap] && $remove_llcsnap} {
                set ret_code [ixNetworkEvalCmd [list ixNet getList $handle stack]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                set all_stack_handles [keylget ret_code ret_val]
                foreach tmp_stack_handle $all_stack_handles {
                    if {[string trim [ixNet getA $tmp_stack_handle -displayName]] == "LLC-SNAP"} {
                        
                        set ret_code [ixNetworkEvalCmd [list ixNet exec remove $tmp_stack_handle] "ok"]
                        if {[keylget ret_code status] != $::SUCCESS} {
                            return $ret_code
                        }
                        
                        set ret_code [ixNetworkEvalCmd [list ixNet getList $handle stack]]
                        if {[keylget ret_code status] != $::SUCCESS} {
                            return $ret_code
                        }
                        set stack_handles [keylget ret_code ret_val]
                        
                        break
                    }
                }
            }
            
            if {![info exists stack_handles]} {
                set ret_code [ixNetworkEvalCmd [list ixNet getList $handle stack]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                set stack_handles [keylget ret_code ret_val]
            }
            
            foreach tmp_stack_handle $stack_handles {
                if {[string trim [ixNet getA $tmp_stack_handle -displayName]] == "AAL5"} {
                    set aal_stack_handle $tmp_stack_handle
                    break
                }
            }
        }
        "modify" {
            switch -- $handle_type {
                "traffic_item" {
                    set retrieve [540getConfigElementOrHighLevelStream $handle]
                    if {[keylget retrieve status] != $::SUCCESS} { return $retrieve }
                    set handle [keylget retrieve handle]
                    
                    set ret_code [540IxNetFindStack $handle "::ixNet::OBJ-/traffic/protocolTemplate:\"aal5\""]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    
                    set aal_stack_handle [keylget ret_code handle]
                }
                "high_level_stream" -
                "config_element" {
                    # do nothing
                    set ret_code [540IxNetFindStack $handle "::ixNet::OBJ-/traffic/protocolTemplate:\"aal5\""]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    
                    set aal_stack_handle [keylget ret_code handle]
                }
                "stack_hls" -
                "stack_ce" {
                    if {[string trim [ixNet getAttribute $handle -displayName]] != "AAL5"} {
                        keylset returnList status $::SUCCESS
                        return $returnList
                    }
                    
                    set aal_stack_handle $handle
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid handle type $handle_type for mode $mode."
                    return $returnList
                }
            }
            
            if {$aal_stack_handle == "_none"} {
                # nothing to configure
                keylset returnList status $::SUCCESS
                return $returnList     
            }
        }
        "append_header" -
        "prepend_header" {
            if {$handle_type != "stack_hls" && $handle_type != "stack_ce"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $handle handle type $handle_type for mode $mode."
                return $returnList
            }
            
            if {![info exists atm_header_encapsulation]} {
                # atm_header encap not provided. Nothing to append/prepend/replace
                keylset returnList status $::SUCCESS
                return $returnList
            }
            
            if {[catch {set protocol_template_list $encapsulation_map($atm_header_encapsulation)} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Atm encapsulation is not supported $atm_header_encapsulation.\
                        Supported encapsulations are: [array names encapsulation_map]."
                return $returnList
            }
            
            set tmp_stack_handle $handle

            switch -- $mode {
                "append_header" {
                    set ret_code [540IxNetAppendProtocolTemplate $protocol_template_list $handle]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    
                    foreach tmp_stack_handle [keylget ret_code handle] {
                        if {[string trim [ixNet getAttribute $tmp_stack_handle -displayName]] == "AAL5"} {
                            set aal_stack_handle $tmp_stack_handle
                        }
                    }
                }
                "prepend_header" {
                    set ret_code [540IxNetPrependProtocolTemplate $protocol_template_list $handle]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        return $ret_code
                    }
                    
                    foreach tmp_stack_handle [keylget ret_code handle] {
                        if {[string trim [ixNet getAttribute $tmp_stack_handle -displayName]] == "AAL5"} {
                            set aal_stack_handle $tmp_stack_handle
                        }
                    }
                }
            }
        }
        "replace_header" {
            if {$handle_type != "stack_hls" && $handle_type != "stack_ce"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid $handle handle type $handle_type for mode $mode."
                return $returnList
            }
            
            if {![info exists atm_header_encapsulation]} {
                # atm_header encap not provided. Nothing to append/prepend/replace
                keylset returnList status $::SUCCESS
                return $returnList
            }
            
            if {[catch {set stacks_list $encapsulation_map($atm_header_encapsulation)} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Atm encapsulation is not supported $atm_header_encapsulation.\
                        Supported encapsulations are: [array names encapsulation_map]."
                return $returnList
            }
            
            set ret_code [540IxNetReplaceProtocolTemplate $stacks_list $tmp_stack_handle]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            foreach ret_handle [keylget ret_code handle] {
                if {[string trim [ixNet getAttribute $ret_handle -displayName]] == "AAL5"} {
                    set aal_stack_handle $ret_handle
                }
            }
        }
    }
    
    
    if {[info exists aal_stack_handle] && $aal_stack_handle != "_none"} {

        debug "==> aal_stack_handle == $aal_stack_handle"
        
        foreach p_type [list vpi vci] {
            set ixn_args ""
            switch -- [set atm_counter_${p_type}_type] {
                "fixed" {
                    lappend ixn_args -valueType singleValue -singleValue [set $p_type]
                }
                "counter" {
                    
                    if {[set atm_counter_${p_type}_mode] == "incr" || [set atm_counter_${p_type}_mode] == "cont_incr"} {
                        lappend ixn_args -valueType increment
                    } else {
                        lappend ixn_args -valueType decrement
                    }
                    
                    lappend ixn_args -startValue [set ${p_type}] -stepValue [set ${p_type}_step] -countValue [set ${p_type}_count]
                }
                "random" {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Choice 'random' form parameter atm_counter_${p_type}_type\
                            is not implemented."
                    return $returnList
                }
                "table" {
                    append ixn_args "-valueType valueList "
                    set tmp_list ""
                    foreach value [set atm_counter_${p_type}_data_item_list] {
                        lappend tmp_list $value
                    }
                    
                    if {[llength $tmp_list] > 0} {
                        lappend ixn_args -valueList $tmp_list
                    }
                }
            }
            
            set field $p_type

            debug "===> 540IxNetUpdateStackField $aal_stack_handle $field $ixn_args"

            set stack_update_status [540IxNetUpdateStackField $aal_stack_handle $field $ixn_args]
            if {[keylget stack_update_status status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to update field '$field' for AAL5 header. [keylget stack_update_status log]"
                return $returnList
            }
        }
    }
    
    return $returnList
}


proc ::ixia::540trafficL2Ethernet { args opt_args all_args} {
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
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
    
    if {[catch {ixNet getA $vport_handle/l1Config -currentType} currentType]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get port type for virtual port $vport_handle. $currentType"
        return $returnList
    }
    
    debug "===> currentType == $currentType"
    
    set protocol_template_list ""
        
    if {[lsearch $::ixia::ixNetworkEthernetPortTypes $currentType] < 0} {
        if {$currentType == "atm"} {
            if {[info exists atm_header_encapsulation]} {
                switch -- $atm_header_encapsulation {
                    "vcc_mux_bridged_eth_fcs" -
                    "vcc_mux_bridged_eth_no_fcs" -
                    "llc_bridged_eth_fcs" -
                    "llc_bridged_eth_no_fcs" {
                        if {$mode == "create"} {
                            
                            set over_status [540getConfigElementOrHighLevelStream $handle]
                            if {[keylget over_status status] != $::SUCCESS} { return $over_status }
                            set over_traffic_item_objref [keylget over_status handle]
                                                        
                            foreach stack [ixNet getL $over_traffic_item_objref stack] {
                                set ret_val [540IxNetStackGetType $stack]
                                if {[keylget ret_val status] != $::SUCCESS} {
                                    return $ret_val
                                }
                                
                                set stack_layer [keylget ret_val stack_layer]
                                set stack_type  [keylget ret_val stack_type]
                                
                                if {$stack_layer != "crc" && $stack_layer < 3} {
                                    set ret_code [540IxNetStackGetProtocolTemplate $stack]
                                    if {[keylget ret_code status] != $::SUCCESS} {
                                        return $ret_code
                                    }
                                    
                                    set tmp_pt_handle [keylget ret_code pt_handle]
                                    
                                    lappend protocol_template_list $tmp_pt_handle
                                    catch {unset tmp_pt_handle}
                                }
                            }
                        }
                    }
                    default {
                        return $returnList
                    }
                }
            } else {
                return $returnList
            }
            
            set use_no_fcs_version 0
            if {[info exists atm_header_encapsulation]} {
                switch -- $atm_header_encapsulation {
                    "vcc_mux_bridged_eth_no_fcs" -
                    "llc_bridged_eth_no_fcs" {
                        set use_no_fcs_version 1
                    }
                }
            }
        } else {
            # No need to go into config part
            return $returnList
        }
    }
    
    set ret_code [ixNetworkGetPortFromObj $vport_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to extract port handle from\
                $vport_handle. [keylget ret_code log]"
        return $returnList
    } 
    
    set real_port_h [keylget ret_code port_handle]
    
    if {[info exists l2_encap] && ![regexp {^ethernet} $l2_encap]} {
        # Don't configure because it's not an ethernet encap
        return $returnList
    }
    
    # pt == protocolTemplate
    
    array set encapsulation_pt_map {
        ethernet_ii                             {::ixNet::OBJ-/traffic/protocolTemplate:"ethernet"}
        ethernet_ii_unicast_mpls                {::ixNet::OBJ-/traffic/protocolTemplate:"ethernet" ::ixNet::OBJ-/traffic/protocolTemplate:"mpls"}
        ethernet_ii_multicast_mpls              {::ixNet::OBJ-/traffic/protocolTemplate:"ethernet" ::ixNet::OBJ-/traffic/protocolTemplate:"mpls"}
        ethernet_ii_vlan                        {::ixNet::OBJ-/traffic/protocolTemplate:"ethernet" ::ixNet::OBJ-/traffic/protocolTemplate:"vlan"}
        ethernet_ii_vlan_unicast_mpls           {::ixNet::OBJ-/traffic/protocolTemplate:"ethernet" ::ixNet::OBJ-/traffic/protocolTemplate:"vlan" ::ixNet::OBJ-/traffic/protocolTemplate:"mpls"}
        ethernet_ii_vlan_multicast_mpls         {::ixNet::OBJ-/traffic/protocolTemplate:"ethernet" ::ixNet::OBJ-/traffic/protocolTemplate:"vlan" ::ixNet::OBJ-/traffic/protocolTemplate:"mpls"}
    }
    
    array set hlt_ixn_field_name_map {
        eth_type_field              "Ethernet-Type"
        eth_dest_mac_field          "Destination MAC Address"
        eth_src_mac_field           "Source MAC Address"
        mpls_bst_field              "Bottom of Stack Bit"
        mpls_exp_field              "MPLS Exp"
        mpls_label_field            "Label Value"
        mpls_ttl_field              "Time To Live"
        vlan_cfi_field              "Canonical Format Indicator"
        vlan_id_field               "VLAN-ID"
        vlan_prot_id_field          "Protocol-ID"
        vlan_priority_field         "VLAN Priority"
        isl_bpdu_field              "BPDU and CDP indicator"
        isl_frame_type_field        "Frame type"
        isl_index_field             "Index"
        isl_udb_field               "User defined bits"
        isl_dest_vlan_field         "Destination VLAN"
        isl_sa_low_field            "Source address - low 24 bits"
        isl_sa_high_field           "Source address - high 24 bits"
        isl_da_field                "Destination address"
    }
    
    if {[info exists use_no_fcs_version] && $use_no_fcs_version} {
        set ethernet_protocol_template_obj ::ixNet::OBJ-/traffic/protocolTemplate:"ethernetNoFCS"
    } else {
        set ethernet_protocol_template_obj ::ixNet::OBJ-/traffic/protocolTemplate:"ethernet"
    }
    
    array set protocol_template_field_map [list                                 \
        $ethernet_protocol_template_obj                  [list                 \
                                                           eth_type_field       \
                                                           eth_dest_mac_field   \
                                                           eth_src_mac_field    \
                                                          ]                     \
        ::ixNet::OBJ-/traffic/protocolTemplate:"mpls"     [list                 \
                                                           mpls_bst_field       \
                                                           mpls_exp_field       \
                                                           mpls_label_field     \
                                                           mpls_ttl_field       \
                                                          ]                     \
        ::ixNet::OBJ-/traffic/protocolTemplate:"vlan"     [list                 \
                                                           vlan_cfi_field       \
                                                           vlan_id_field        \
                                                           vlan_prot_id_field   \
                                                           vlan_priority_field  \
                                                          ]                     \
        ::ixNet::OBJ-/traffic/protocolTemplate:"ciscoISL" [list                 \
                                                           isl_bpdu_field       \
                                                           isl_frame_type_field \
                                                           isl_index_field      \
                                                           isl_udb_field        \
                                                           isl_dest_vlan_field  \
                                                           isl_sa_low_field     \
                                                           isl_sa_high_field    \
                                                           isl_da_field         \
                                                          ]                     \
    ]
    
    array set isl_frame_type_translate {
        ethernet    0
        atm         3
        fddi        2
        token_ring  1
    }
    
    array set mac_dst_mode_translate {
        fixed               fixed
        increment           incr
        decrement           decr
        list                list
        discovery           auto
        random              rand
        repeatable_random   rpt_rand
    }
    
    array set mac_src_mode_translate {
        fixed               fixed
        increment           incr
        decrement           decr
        list                list
        random              rand
        repeatable_random   rpt_rand
    }
    
    array set vlan_id_mode_translate {
        fixed       fixed
        increment   incr
        decrement   decr
        list        list
    }
    

    #           hlt_param                       param_class               extra
    set eth_type_field {
                ethernet_value                  value_hex                 {p_format  strict}
                ethernet_value_count            count                     _none
                ethernet_value_mode             mode                      _none
                ethernet_value_step             step                      _none
                ethernet_value_tracking         tracking                  _none
    }
                
    set eth_dest_mac_field {
                mac_dst                         value_mac                 {p_format  strict}
                mac_dst_count                   count                     _none
                mac_dst_mode                    mode                      {translate mac_dst_mode_translate}
                mac_dst_mask                    mask                      _none
                mac_dst_seed                    seed                      _none
                mac_dst_step                    step                      _none
                mac_dst_tracking                tracking                  _none
    }
                
    set eth_src_mac_field {
                mac_src                         value_mac                 {p_format  strict}
                mac_src_count                   count                     _none
                mac_src_mode                    mode                      {translate mac_src_mode_translate}
                mac_src_mask                    mask                      _none
                mac_src_seed                    seed                      _none
                mac_src_step                    step                      _none
                mac_src_tracking                tracking                  _none
    }
                
    set mpls_bst_field {
                mpls_bottom_stack_bit           value                     _none
                mpls_bottom_stack_bit_mode      mode                      _none
                mpls_bottom_stack_bit_step      step                      _none
                mpls_bottom_stack_bit_count     count                     _none
                mpls_bottom_stack_bit_tracking  tracking                  _none
    }
                
    set mpls_exp_field {
                mpls_exp_bit                    value                     _none
                mpls_exp_bit_count              count                     _none
                mpls_exp_bit_mode               mode                      _none
                mpls_exp_bit_step               step                      _none
                mpls_exp_bit_tracking           tracking                  _none
    }
                
    set mpls_label_field {
                mpls_labels                     value                     _none
                mpls_labels_count               count                     _none
                mpls_labels_mode                mode                      _none
                mpls_labels_step                step                      _none
                mpls_labels_tracking            tracking                  _none
    }
                
    set mpls_ttl_field {
                mpls_ttl                        value                     _none
                mpls_ttl_count                  count                     _none
                mpls_ttl_mode                   mode                      _none
                mpls_ttl_step                   step                      _none
                mpls_ttl_tracking               tracking                  _none
    }
    
    set isl_bpdu_field {
                isl_bpdu                        value                     _none
                isl_bpdu_count                  count                     _none
                isl_bpdu_mode                   mode                      _none
                isl_bpdu_step                   step                      _none
                isl_bpdu_tracking               tracking                  _none
    }
                
    set isl_frame_type_field {
                isl_frame_type                  value_translate           {array_map isl_frame_type_translate}
                isl_frame_type_mode             mode                      _none
                isl_frame_type_tracking         tracking                  _none
    }
                
    set isl_index_field {
                isl_index                       value                     _none
                isl_index_count                 count                     _none
                isl_index_mode                  mode                      _none
                isl_index_step                  step                      _none
                isl_index_tracking              tracking                  _none
    }

    set isl_da_field {
                isl_mac_dst                     value_hex                 {p_format  strict}
                isl_mac_dst_count               count                     _none
                isl_mac_dst_mode                mode                      _none
                isl_mac_dst_step                step                      _none
                isl_mac_dst_tracking            tracking                  _none
    }
                
    set isl_sa_high_field {
                isl_mac_src_high                value_hex                 _none
                isl_mac_src_high_count          count                     _none
                isl_mac_src_high_mode           mode                      _none
                isl_mac_src_high_step           step                      _none
                isl_mac_src_high_tracking       tracking                  _none
    }
                
    set isl_sa_low_field {
                isl_mac_src_low                 value_hex                 {p_format  strict}
                isl_mac_src_low_count           count                     _none
                isl_mac_src_low_mode            mode                      _none
                isl_mac_src_low_step            step                      _none
                isl_mac_src_low_tracking        tracking                  _none
    }

    set isl_udb_field {
                isl_user_priority               value                     _none
                isl_user_priority_count         count                     _none
                isl_user_priority_mode          mode                      _none
                isl_user_priority_step          step                      _none
                isl_user_priority_tracking      tracking                  _none
    }
                
    set isl_dest_vlan_field {
                isl_vlan_id                     value                     _none
                isl_vlan_id_count               count                     _none
                isl_vlan_id_mode                mode                      _none
                isl_vlan_id_step                step                      _none
                isl_vlan_id_tracking            tracking                  _none
    }
                
    set vlan_cfi_field {
                vlan_cfi                        value                     _none
                vlan_cfi_count                  count                     _none
                vlan_cfi_mode                   mode                      _none
                vlan_cfi_step                   step                      _none
                vlan_cfi_tracking               tracking                  _none
    }
                
    set vlan_id_field {
                vlan_id                         value                     _none
                vlan_id_count                   count                     _none
                vlan_id_mode                    mode                      {translate vlan_id_mode_translate}
                vlan_id_step                    step                      _none
                vlan_id_tracking                tracking                  _none
    }
                
    set vlan_prot_id_field {
                vlan_protocol_tag_id            value_hex                 {p_format  strict}
                vlan_protocol_tag_id_count      count                     _none
                vlan_protocol_tag_id_mode       mode                      _none
                vlan_protocol_tag_id_step       step                      _none
                vlan_protocol_tag_id_tracking   tracking                  _none
    }
                
    set vlan_priority_field {
                vlan_user_priority              value                     _none
                vlan_user_priority_count        count                     _none
                vlan_user_priority_mode         mode                      _none
                vlan_user_priority_step         step                      _none
                vlan_user_priority_tracking     tracking                  _none
    }
    
    if {[info exists l2_encap] && ![info exists encapsulation_pt_map($l2_encap)]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Encapsulation $l2_encap is not supported."
        return $returnList
    }
    
    switch -- $mode {
        "create" {
            set add_eth_stack 0
            if {[info exists use_no_fcs_version]} {
                # AND ETHERNET STACK ISN'T ALREADY THERE
                if {[lindex $protocol_template_list end] != $ethernet_protocol_template_obj} {
                    set add_eth_stack 1
                }
            } else {
                foreach eth_list {eth_type_field eth_dest_mac_field eth_src_mac_field} {
                    foreach {eth_elem_name eth_elem_type eth_elem_action} [set $eth_list] {
                        if {[info exists $eth_elem_name] && ![is_default_param_value $eth_elem_name $all_args]} {
                            set add_eth_stack 1
                        }
                    }
                }
            }
            
            if {[info exists isl] && $isl == 1} {
                lappend protocol_template_list ::ixNet::OBJ-/traffic/protocolTemplate:"ciscoISL"
                lappend protocol_template_list $ethernet_protocol_template_obj
                set add_eth_stack 0
            }
            
            if {[info exists vlan] && $vlan == "enable"} {
                
                if {![info exists isl] || $isl == 0} {
                    lappend protocol_template_list $ethernet_protocol_template_obj
                    set add_eth_stack 0
                }
                
                foreach vlan_tag $vlan_id {
                    lappend protocol_template_list ::ixNet::OBJ-/traffic/protocolTemplate:"vlan"
                }
            }
            
            if {[info exists mpls] && $mpls == "enable"} {
                if {(![info exists isl] || $isl == 0) && (![info exists vlan] || $vlan == "disable")} {
                    lappend protocol_template_list $ethernet_protocol_template_obj
                    set add_eth_stack 0
                }
                
                foreach mpls_single_label $mpls_labels {
                    lappend protocol_template_list ::ixNet::OBJ-/traffic/protocolTemplate:"mpls"
                }
            }
            
            if {$add_eth_stack} {
                lappend protocol_template_list $ethernet_protocol_template_obj
                set add_eth_stack 0
            }
            
            if {$protocol_template_list != ""} {
                # This procedure will remove the protocol templates that do not apply for this configElement
                # this is the case where multiple configElements exist on one traffic item.
                set ret_code [540trafficAdjustPtList $handle $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set protocol_template_list [keylget ret_code pt_list]
                
                set ret_code [540IxNetTrafficL2AddHeaders $handle $handle_type $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                if {![info exists ethernet_value]} {
                    set ethernet_value 0x0800
                }
                
                set stack_handles [keylget ret_code handle]
            } else {
                # get the mpls stack handles
                set stack_handles ""
                if {$handle_type == "config_element"} {
                    set stack_elem_list [ixNet getL $handle stack]
                    foreach handle $stack_elem_list {
                        if {[regexp mpls $handle]} {
                            lappend stack_handles $handle
                        }
                    }
                }
            }
        }
        "modify" {
        
            # For modify mode search for the eth, vlan, mpls, isl headers and modify them
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
                
                set stacks_to_find ""
                
                if {[info exists isl] && $isl == 1} {
                    set protocol_template_list ::ixNet::OBJ-/traffic/protocolTemplate:"ciscoISL"
                }
                
                lappend protocol_template_list $ethernet_protocol_template_obj
                
                if {[info exists vlan]} {
                    foreach vlan_elem $vlan {
                        if {$vlan_elem == "enable"} {
                            lappend protocol_template_list ::ixNet::OBJ-/traffic/protocolTemplate:"vlan"
                        }
                    }
                }
                
                if {[info exists mpls]} {
                    foreach mpls_elem $mpls {
                        if {$mpls_elem == "enable"} {
                            lappend protocol_template_list ::ixNet::OBJ-/traffic/protocolTemplate:"mpls"
                        }
                    }
                }
                
                set ret_code [540IxNetFindStacksAll $ce_hls_handle $protocol_template_list]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set stack_handles ""
                set stack_index 0
                foreach tmp_pt_modify $protocol_template_list {
                    set tmp_stack_list [keylget ret_code $tmp_pt_modify]
                    
                    if {[llength $tmp_stack_list] > 0} {
                        if {[ixNet getAttribute $tmp_pt_modify -displayName] == "VLAN"} {
                            if {[info exists vlan_id] && [llength $vlan_id] > 1 && [llength $vlan_id]>=$stack_index} {
                                lappend stack_handles [lindex $tmp_stack_list $stack_index]
                                incr stack_index
                            } else {
                                if {[llength $tmp_stack_list]>1} {
                                    lappend stack_handles [lindex $tmp_stack_list $stack_index]
                                    incr stack_index
                                } else {
                                    lappend stack_handles [lindex $tmp_stack_list 0]
                                }
                            }
                        } elseif {[ixNet getAttribute $tmp_pt_modify -displayName] == "MPLS"} {
                            if {[info exists mpls_labels] && [llength $mpls_labels] > 1} {
                                set end_idx [expr [llength $mpls_labels] - 1]
                                lappend stack_handles [lrange $tmp_stack_list 0 $end_idx]
                                set stack_handles [join $stack_handles]
                            } else {
                                lappend stack_handles [lindex $tmp_stack_list 0]
                            }
                        } else {
                            lappend stack_handles [lindex $tmp_stack_list 0]
                        }
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
            
            if {[info exists isl] && $isl == 1} {
                set protocol_template_list ::ixNet::OBJ-/traffic/protocolTemplate:"ciscoISL"
            }
            
            if {[info exists l2_encap]} {
                lappend protocol_template_list $ethernet_protocol_template_obj
            }
            
            if {[info exists vlan] && $vlan == "enable"} {
                lappend protocol_template_list ::ixNet::OBJ-/traffic/protocolTemplate:"vlan"
            }
            
            if {[info exists mpls] && $mpls == "enable"} {
                lappend protocol_template_list ::ixNet::OBJ-/traffic/protocolTemplate:"mpls"
            }
            
            if {[llength $protocol_template_list] == 0} {
                # nothing to append/prepend/replace
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

    set vlan_idx 0
    set mpls_idx 0
    
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
        if {![info exists protocol_template_field_map($tmp_pt_handle)]} { continue }
        set hlt_field_list $protocol_template_field_map($tmp_pt_handle)
        
        foreach hlt_field $hlt_field_list {
            
            set field_args ""
            
            foreach {hlt_p hlt_intermediate_p extras} [set $hlt_field] {
                
                if {[info exists $hlt_p] && ![is_default_param_value $hlt_p $all_args]} {
                    
                    if {$tmp_pt_name == "MPLS" || $tmp_pt_name == "VLAN"} {
                        
                        # Doing this for mpls multiple labels or qinq vlan (which is configured\
                        # in ixnetwork with stacked mpls/vlan headers)
                        
                        debug "==> hlt_p == $hlt_p"
                        
                        if {[llength [set $hlt_p]] > 1} {
                            switch -- $tmp_pt_name {
                                "MPLS" {
                                    set hlt_p_value [lindex [set $hlt_p] $mpls_idx]
                                }
                                "VLAN" {
                                    debug "==> set hlt_p_value \[lindex [set $hlt_p] $vlan_idx\]"
                                    set hlt_p_value [lindex [set $hlt_p] $vlan_idx]
                                }
                            }
                        } elseif {$tmp_pt_name == "MPLS" && [llength [set $hlt_p]] == 1 && [llength [lindex [set $hlt_p] $mpls_idx]] > 1} {
                            set hlt_p_value [lindex [set $hlt_p] $mpls_idx]
                        } elseif {$tmp_pt_name == "VLAN" && [llength [set $hlt_p]] == 1 && [llength [lindex [set $hlt_p] $vlan_idx]] > 1} {
                            set hlt_p_value [lindex [set $hlt_p] $vlan_idx]
                        } else {
                            debug "==> set hlt_p_value [set $hlt_p]"
                            set hlt_p_value [set $hlt_p]
                        }
                        
                    } else {
                        
                        # For the rest (eth and cisco isl) there's only one header
                        
                        set hlt_p_value [set $hlt_p]
                    }
                    
                    if {$extras != "_none"} {
                        switch -- [lindex $extras 0] {
                            array_map {
                                # hlt choices array must be passed as argument to
                                # procedure 540TrafficStackFieldConfig
                                set tmp_param_array [lindex $extras 1]
                            }
                            translate {
                                # hlt choices do not match hlt_intermediate choices
                                array set tmp_local_map [array get [lindex $extras 1]]
                                if {![info exists tmp_local_map($hlt_p_value)]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Internal error in array 'tmp_local_map': '[array get tmp_local_map]'.\
                                            Array index $hlt_p_value does not exist. Error occured when attempting to configure\
                                            parameter $hlt_p."
                                    return $returnList
                                }
                                set hlt_p_value $tmp_local_map($hlt_p_value)
                                
                                catch {unset tmp_local_map}
                            }
                            p_format {
                                set tmp_strict_format [lindex $extras 1]
                            }
                            default {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Internal error in list $hlt_field.\
                                        Value at index 0 '[lindex $extras 0]' of extras '$extras'\
                                        is not handled. Error occured when attempting to configure\
                                        parameter $hlt_p."
                                return $returnList
                            }
                        }
                    }
                    
                    if {[regexp {^value} $hlt_intermediate_p]} {
                        lappend field_args -p_type $hlt_intermediate_p
                        lappend field_args -value  $hlt_p_value
                    } else {
                        lappend field_args -$hlt_intermediate_p $hlt_p_value
                    }
                }
                
                if {[info exists tmp_param_array]} {
                    lappend field_args -translate_array [array get $tmp_param_array]
                }
                
                if {[info exists tmp_strict_format]} {
                    lappend field_args -strict_format $tmp_strict_format
                }
                
                catch {unset tmp_param_array}
                catch {unset tmp_strict_format}
            }
            
            if {[llength $field_args] > 0} {
                    
                # call 540TrafficStackFieldConfig
                
                lappend field_args -stack_handle $stack_item
                lappend field_args -field_name   $hlt_ixn_field_name_map($hlt_field)
                
                set cmd "540TrafficStackFieldConfig $field_args"
                set ret_code [eval $cmd]
                if {[keylget ret_code status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not configure stack $stack_item. Field\
                            $hlt_ixn_field_name_map($hlt_field). Call to '$cmd' failed.\
                            [keylget ret_code log]."
                    return $returnList
                }
            }
        }
        
        switch -- $tmp_pt_name {
            "MPLS" {
                incr mpls_idx
            }
            "VLAN" {
                incr vlan_idx
            }
        }
        
        catch {unset tmp_param_array}
        catch {unset tmp_pt_handle}
        catch {unset tmp_pt_name}
    }

    
# -l2_encap                           CHOICES atm_vc_mux
#                                     CHOICES atm_vc_mux_ethernet_ii
#                                     CHOICES atm_vc_mux_802.3snap
#                                     CHOICES atm_snap_802.3snap_nofcs
#                                     CHOICES atm_vc_mux_ppp
#                                     CHOICES atm_vc_mux_pppoe
#                                     CHOICES atm_snap
#                                     CHOICES atm_snap_ethernet_ii
#                                     CHOICES atm_snap_802.3snap
#                                     CHOICES atm_vc_mux_802.3snap_nofcs
#                                     CHOICES atm_snap_ppp
#                                     CHOICES atm_snap_pppoe
#                                     CHOICES hdlc_unicast
#                                     CHOICES hdlc_broadcast
#                                     CHOICES hdlc_unicast_mpls
#                                     CHOICES hdlc_multicast_mpls
#                                     CHOICES ethernet_ii
#                                     CHOICES ethernet_ii_unicast_mpls
#                                     CHOICES ethernet_ii_multicast_mpls
#                                     CHOICES ethernet_ii_vlan
#                                     CHOICES ethernet_ii_vlan_unicast_mpls
#                                     CHOICES ethernet_ii_vlan_multicast_mpls
#                                     CHOICES ethernet_ii_pppoe
#                                     CHOICES ethernet_ii_vlan_pppoe
#                                     CHOICES ppp_link
#                                     CHOICES ietf_framerelay
#                                     CHOICES cisco_framerelay
# -ethernet_value                     HEX
# -ethernet_value_mode                CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -ethernet_value_step                HEX
#                                     DEFAULT 0x01
# -ethernet_value_count               NUMERIC
#                                     DEFAULT 1
# -ethernet_value_tracking            CHOICES 0 1
#                                     DEFAULT 0
# -isl                                CHOICES 0 1
# -isl_bpdu                           CHOICES 0 1
#                                     DEFAULT 0
# -isl_bpdu_mode                      CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -isl_bpdu_step                      CHOICES 0 1
#                                     DEFAULT 1
# -isl_bpdu_count                     NUMERIC
#                                     DEFAULT 1
# -isl_bpdu_tracking                  CHOICES 0 1
#                                     DEFAULT 0
# -isl_frame_type                     CHOICES ethernet atm fddi token_ring
# -isl_frame_type_mode                CHOICES fixed list
# -isl_frame_type_tracking            CHOICES 0 1
#                                     DEFAULT 0
# -isl_index                          ANY
# -isl_index_mode                     CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -isl_index_step                     NUMERIC
#                                     DEFAULT 1
# -isl_index_count                    NUMERIC
#                                     DEFAULT 1
# -isl_index_tracking                 CHOICES 0 1
#                                     DEFAULT 0
# -isl_user_priority                  RANGE   0-7
# -isl_user_priority_mode             CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -isl_user_priority_step             RANGE 0-6
#                                     DEFAULT 1
# -isl_user_priority_count            NUMERIC
#                                     DEFAULT 1
# -isl_user_priority_tracking         CHOICES 0 1
#                                     DEFAULT 0
# -isl_vlan_id                        RANGE   0-4095
# -isl_vlan_id_mode                   CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -isl_vlan_id_step                   NUMERIC
#                                     DEFAULT 1
# -isl_vlan_id_count                  NUMERIC
#                                     DEFAULT 1
# -isl_vlan_id_tracking               CHOICES 0 1
#                                     DEFAULT 0
# -isl_mac_src_high                   HEX
# -isl_mac_src_high_mode              CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -isl_mac_src_high_step              HEX
#                                     DEFAULT 0x01
# -isl_mac_src_high_count             NUMERIC
#                                     DEFAULT 1
# -isl_mac_src_high_tracking          CHOICES 0 1
#                                     DEFAULT 0
# -isl_mac_src_low                    HEX
# -isl_mac_src_low_mode               CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -isl_mac_src_low_step               HEX
#                                     DEFAULT 0x01
# -isl_mac_src_low_count              NUMERIC
#                                     DEFAULT 1
# -isl_mac_src_low_tracking           CHOICES 0 1
#                                     DEFAULT 0
# -isl_mac_dst                        ANY
# -isl_mac_dst_mode                   CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -isl_mac_dst_step                   ANY
#                                     DEFAULT 0000.0000.0001
# -isl_mac_dst_count                  NUMERIC
#                                     DEFAULT 1
# -isl_mac_dst_tracking               CHOICES 0 1
#                                     DEFAULT 0
# -mac_dst                            ANY
# -mac_dst_tracking                   CHOICES 0 1
#                                     DEFAULT 0
# -mac_dst_count                      RANGE   0-1000000
# -mac_dst_mode                       CHOICES fixed increment decrement
#                                     CHOICES discovery random list
# -mac_dst_step                       ANY
# -mac_src                            ANY
# -mac_src_tracking                   CHOICES 0 1
#                                     DEFAULT 0
# -mac_src_count                      NUMERIC
# -mac_src_mode                       CHOICES fixed increment decrement 
#                                     CHOICES random emulation list
# -mac_src_step                       ANY
# -vlan                               CHOICES enable disable
# -vlan_cfi                           CHOICES 0 1
# -vlan_cfi_count                     NUMERIC
#                                     DEFAULT 1
# -vlan_cfi_mode                      CHOICES fixed incr decr
#                                     DEFAULT fixed
# -vlan_cfi_step                      NUMERIC
#                                     DEFAULT 1
# -vlan_cfi_tracking                  CHOICES 0 1
#                                     DEFAULT 0
# -vlan_id                            RANGE   0-4095
# -vlan_id_count                      RANGE   0-4095
# -vlan_id_mode                       CHOICES fixed increment decrement 
#                                     CHOICES random nested_incr 
#                                     CHOICES nested_decr list
# -vlan_id_step                       NUMERIC
# -vlan_id_tracking                   CHOICES 0 1
#                                     DEFAULT 0
# -vlan_protocol_tag_id               REGEXP ^[0-9a-fA-F]{4}$
# -vlan_protocol_tag_id_count         NUMERIC
#                                     DEFAULT 1
# -vlan_protocol_tag_id_mode          CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -vlan_protocol_tag_id_step          HEX
#                                     DEFAULT 0x01
# -vlan_protocol_tag_id_tracking      CHOICES 0 1
#                                     DEFAULT 0
# -vlan_user_priority                 RANGE   0-7
# -vlan_user_priority_count           NUMERIC
#                                     DEFAULT 1
# -vlan_user_priority_mode            CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -vlan_user_priority_step            RANGE   0-6
#                                     DEFAULT 1
# -vlan_user_priority_tracking        CHOICES 0 1
#                                     DEFAULT 0
# -mpls                               CHOICES enable disable
# -mpls_bottom_stack_bit              CHOICES 0 1
# -mpls_bottom_stack_bit_tracking     CHOICES 0 1
#                                     DEFAULT 0
# -mpls_exp_bit                       REGEXP  (([0-7]\,)*[0-7])
#                                     DEFAULT 0
# -mpls_exp_bit_mode                  CHOICES fixed incr decr list
#                                     DEFAULT fixed
# -mpls_exp_bit_step                  RANGE   1-6
#                                     DEFAULT 1
# -mpls_exp_bit_count                 RANGE   1-8
#                                     DEFAULT 1
# -mpls_exp_bit_tracking              CHOICES 0 1
#                                     DEFAULT 0
# -mpls_labels                        NUMERIC
# -mpls_labels_mode                   CHOICES fixed incr decr
#                                     DEFAULT fixed
# -mpls_labels_step                   NUMERIC
#                                     DEFAULT 1
# -mpls_labels_count                  NUMERIC
#                                     DEFAULT 1
# -mpls_labels_tracking               CHOICES 0 1
#                                     DEFAULT 0
# -mpls_ttl                           RANGE   0-255
#                                     DEFAULT 64
# -mpls_ttl_mode                      CHOICES fixed incr decr
#                                     DEFAULT fixed
# -mpls_ttl_step                      RANGE   0-254
#                                     DEFAULT 1
# -mpls_ttl_count                     RANGE   1-256
#                                     DEFAULT 1
# -mpls_ttl_tracking                  CHOICES 0 1
#                                     DEFAULT 0
########################################
# -mac_src2
# -mac_dst2

    return $returnList
}


proc ::ixia::540trafficL2FrameRelay { args opt_args } {
    
    ###########################################
    # !!!! Procedure not implemented yet !!!! #
    ###########################################
    
    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args ""} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
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
    
    if {[catch {ixNet getA $vport_handle/l1Config -currentType} currentType]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get port type for virtual port $vport_handle. $currentType"
        return $returnList
    }
    
    debug "===> currentType == $currentType"
    
    if {$currentType != "pos"} {
        # No need to go into config part
        return $returnList
    }
    
    if {[catch {ixNet getA $vport_handle/pos -payloadType} currentPayloadType]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get payload type for virtual port $vport_handle. $currentPayloadType"
        return $returnList
    }
    
    if {$currentPayloadType != "ciscoFrameRelay" && $currentPayloadType != "frameRelay"} {
        # No need to go into config part
        return $returnList
    }
    
    set ret_code [ixNetworkGetPortFromObj $vport_handle]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Failed to extract port handle from\
                $vport_handle. [keylget ret_code log]"
        return $returnList
    } 
    
    set real_port_h [keylget ret_code port_handle]
    
    array set encapsulation_pt_map {
        frameRelay                     {::ixNet::OBJ-/traffic/protocolTemplate:"frameRelay"}
        ciscoFrameRelay                {::ixNet::OBJ-/traffic/protocolTemplate:"ciscoFrameRelay"}
    }
    
    array set hlt_ixn_field_name_map {
                                    "DLCI High Order Bits"
                                    "CR Bit"
                                    "EA0 Bit"
                                    "DLCI Low Order Bits"
                                    "FECN Bit"
                                    "BECN Bit"
                                    "DE Bit"
                                    "EA1 Bit"
                                    "Ethernet Type"
    }
    
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
    
    return $returnList
}
