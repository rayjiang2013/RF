#
#
#

set _ENDPOINT_T "dcbxEndpoint"
set _RANGE_T "dcbxRange"
set T ::ixia::hag::ixn::types
foreach x { ethernet } {
    #
    # Ixnetwork only allows abort/start/stop at the endpoint level it seems
    # so override abort/start/stop to abort/start/stop
    # our grandparent when someone asks us to abort/start/stop
    #
    snit::method \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T \
    abort {} { $Shell abort [$self _ancestor 2] }
    
    snit::method \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T \
    abort_async {} { $Shell abort_async [$self _ancestor 2]}
    
    snit::method \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T \
    start {} { $Shell start [$self _ancestor 2] }

    snit::method \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T \
    stop {} { $Shell stop [$self _ancestor 2] }
    
    
    #
    # Override to allow a classis hlt port_handle", which is just a chassis
    # "chassisN/cardN/portN" string, to be supplied as the parent_handle
    # for a .../$_RANGE_T 
    # note: the element that must be returned is a hag object
    # representing the parent of the highest level ancestor auto-generated 
    # by the target object ($self). it should not the immediate parent 
    # of target object
    #
    snit::method \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T \
    _cast_handle_to_parent_obj {i_handle args} {
     $Shell _std_vport_protocolstack_range_cast_handle_to_parent_obj $self $i_handle
    }

    #
    # This override declares the (aggregate) stats for this type
    #
    snit::typemethod \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T \
    _aggregate_stat_decl {inst} {
        set decl {
            gen "DCBX" {
                "Sessions Initiated"                         sessions_initiated
                "Sessions Succeeded"                         sessions_succeeded
                "Sessions Failed"                            sessions_failed
                "DCBX Mismatches Detected"                   dcbx_mismatches_detected
                "DCBX Invalid PDU"                           dcbx_invalid_pdu
                "LLDP Tx"                                    lldp_tx
                "LLDP Rx"                                    lldp_rx
                "LLDP Age Out Count"                         lldp_age_out_count
                "LLDP Error Rx"                              lldp_error_rx
                "LLDP Unrecognized TLV Rx"                   lldp_unrecognized_tlv_rx
                "LLDP Neighbor Count"                        lldp_neighbor_count
                "DCBX Tx"                                    dcbx_tx
                "DCBX Rx"                                    dcbx_rx
                "DCBX Control TLV Tx"                        dcbx_control_tlv_tx
                "DCBX Control TLV Rx"                        dcbx_control_tlv_rx
                "DCBX Priority Groups TLV Tx"                dcbx_priority_groups_tlv_tx
                "DCBX Priority Groups TLV Rx"                dcbx_priority_groups_tlv_rx
                "DCBX PFC TLV Tx"                            dcbx_pfc_tlv_tx
                "DCBX PFC TLV Rx"                            dcbx_pfc_tlv_rx
                "DCBX FCoE TLV Tx"                           dcbx_fcoe_tlv_tx
                "DCBX FCoE TLV Rx"                           dcbx_fcoe_tlv_rx
                "DCBX FCoE Logical Link Status TLV Tx"       dcbx_fcoe_logical_link_status_tlv_tx
                "DCBX FCoE Logical Link Status TLV Rx"       dcbx_fcoe_logical_link_status_tlv_rx
                "DCBX LAN Logical Link Status TLV Tx"        dcbx_lan_logical_link_status_tlv_tx
                "DCBX LAN Logical Link Status TLV Rx"        dcbx_lan_logical_link_status_tlv_rx
                "DCBX Customized TLV Tx"                     dcbx_customized_tlv_tx
                "DCBX Customized TLV Rx"                     dcbx_customized_tlv_rx
                "Port Name"                                  port_name
                "DCBX Duplicate TLVs Received"               dcbx_duplicate_tlvs_received
                "DCBX Duplicate Apps Received"               dcbx_duplicate_apps_received
                "LLDP Port Description TLV Tx"               lldp_port_description_tlv_tx
                "LLDP Port Description TLV Rx"               lldp_port_description_tlv_rx
                "LLDP System Name TLV Tx"                    lldp_system_name_tlv_tx
                "LLDP System Name TLV Rx"                    lldp_system_name_tlv_rx
                "LLDP System Description TLV Tx"             lldp_system_description_tlv_tx
                "LLDP System Description TLV Rx"             lldp_system_description_tlv_rx
                "LLDP Management Address TLV Tx"             lldp_management_address_tlv_tx
                "LLDP Management Address TLV Rx"             lldp_management_address_tlv_rx
                "LLDP Organizationally Specific TLV Tx"      lldp_organizationally_specific_tlv_tx
                "LLDP Organizationally Specific TLV Rx"      lldp_organizationally_specific_tlv_rx
                "DCBX NIV TLV Tx"                            dcbx_niv_tlv_tx
                "DCBX NIV TLV Rx"                            dcbx_niv_tlv_rx
                "DCBX 802.1Qaz ETS Configuration TLV Tx"     dcbx_802_1qaz_ets_configuration_tlv_tx
                "DCBX 802.1Qaz ETS Configuration TLV Rx"     dcbx_802_1qaz_ets_configuration_tlv_rx
                "DCBX 802.1Qaz ETS Recommendation TLV Tx"    dcbx_802_1qaz_ets_recommendation_tlv_tx
                "DCBX 802.1Qaz ETS Recommendation TLV Rx"    dcbx_802_1qaz_ets_recommendation_tlv_rx
                "DCBX 802.1Qaz PFC TLV Tx"                   dcbx_802_1qaz_pfc_tlv_tx
                "DCBX 802.1Qaz PFC TLV Rx"                   dcbx_802_1qaz_pfc_tlv_rx
                "DCBX 802.1Qaz Application Priority TLV Tx"  dcbx_802_1qaz_application_priority_tlv_tx
                "DCBX 802.1Qaz Application Priority TLV Rx"  dcbx_802_1qaz_application_priority_tlv_rx
            }
        }; # end set decl
        return $decl
    }

    snit::typemethod \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T \
    _stat_doc_decl {} {
        set decl {
            gen "DCBX" {
                sessions_initiated                          "Sessions Initiated"
                sessions_succeeded                          "Sessions Succeeded"
                sessions_failed                             "Sessions Failed"
                dcbx_mismatches_detected                    "DCBX Mismatches Detected"
                dcbx_invalid_pdu                            "DCBX Invalid PDU"
                lldp_tx                                     "LLDP Tx"
                lldp_rx                                     "LLDP Rx"
                lldp_age_out_count                          "LLDP Age Out Count"
                lldp_error_rx                               "LLDP Error Rx"
                lldp_unrecognized_tlv_rx                    "LLDP Unrecognized TLV Rx"
                lldp_neighbor_count                         "LLDP Neighbor Count"
                dcbx_tx                                     "DCBX Tx"
                dcbx_rx                                     "DCBX Rx"
                dcbx_control_tlv_tx                         "DCBX Control TLV Tx"
                dcbx_control_tlv_rx                         "DCBX Control TLV Rx"
                dcbx_priority_groups_tlv_tx                 "DCBX Priority Groups TLV Tx"
                dcbx_priority_groups_tlv_rx                 "DCBX Priority Groups TLV Rx"
                dcbx_pfc_tlv_tx                             "DCBX PFC TLV Tx"
                dcbx_pfc_tlv_rx                             "DCBX PFC TLV Rx"
                dcbx_fcoe_tlv_tx                            "DCBX FCoE TLV Tx"
                dcbx_fcoe_tlv_rx                            "DCBX FCoE TLV Rx"
                dcbx_fcoe_logical_link_status_tlv_tx        "DCBX FCoE Logical Link Status TLV Tx"
                dcbx_fcoe_logical_link_status_tlv_rx        "DCBX FCoE Logical Link Status TLV Rx"
                dcbx_lan_logical_link_status_tlv_tx         "DCBX LAN Logical Link Status TLV Tx"
                dcbx_lan_logical_link_status_tlv_rx         "DCBX LAN Logical Link Status TLV Rx"
                dcbx_customized_tlv_tx                      "DCBX Customized TLV Tx"
                dcbx_customized_tlv_rx                      "DCBX Customized TLV Rx"
                port_name                                   "Port Name"
                dcbx_duplicate_tlvs_received                "DCBX Duplicate TLVs Received"
                dcbx_duplicate_apps_received                "DCBX Duplicate Apps Received"
                lldp_port_description_tlv_tx                "LLDP Port Description TLV Tx"
                lldp_port_description_tlv_rx                "LLDP Port Description TLV Rx"
                lldp_system_name_tlv_tx                     "LLDP System Name TLV Tx"
                lldp_system_name_tlv_rx                     "LLDP System Name TLV Rx"
                lldp_system_description_tlv_tx              "LLDP System Description TLV Tx"
                lldp_system_description_tlv_rx              "LLDP System Description TLV Rx"
                lldp_management_address_tlv_tx              "LLDP Management Address TLV Tx"
                lldp_management_address_tlv_rx              "LLDP Management Address TLV Rx"
                lldp_organizationally_specific_tlv_tx       "LLDP Organizationally Specific TLV Tx"
                lldp_organizationally_specific_tlv_rx       "LLDP Organizationally Specific TLV Rx"
                dcbx_niv_tlv_tx                             "DCBX NIV TLV Tx"
                dcbx_niv_tlv_rx                             "DCBX NIV TLV Rx"
                dcbx_802_1qaz_ets_configuration_tlv_tx      "DCBX 802.1Qaz ETS Configuration TLV Tx"
                dcbx_802_1qaz_ets_configuration_tlv_rx      "DCBX 802.1Qaz ETS Configuration TLV Rx"
                dcbx_802_1qaz_ets_recommendation_tlv_tx     "DCBX 802.1Qaz ETS Recommendation TLV Tx"
                dcbx_802_1qaz_ets_recommendation_tlv_rx     "DCBX 802.1Qaz ETS Recommendation TLV Rx"
                dcbx_802_1qaz_pfc_tlv_tx                    "DCBX 802.1Qaz PFC TLV Tx"
                dcbx_802_1qaz_pfc_tlv_rx                    "DCBX 802.1Qaz PFC TLV Rx"
                dcbx_802_1qaz_application_priority_tlv_tx   "DCBX 802.1Qaz Application Priority TLV Tx"
                dcbx_802_1qaz_application_priority_tlv_rx   "DCBX 802.1Qaz Application Priority TLV Rx"
            }
        }; # end set decl
        return $decl
    }
}
