#
#
#

set _ENDPOINT_T "fcoeFwdEndpoint"
set _RANGE_T "fcoeFwdVxPort"
set T ::ixia::hag::ixn::types
foreach x { ethernet } {
    #
    # Ixnetwork only allows abort/start/stop at the endpoint level it seems
    # so override abort/start/stop to abort/start/stop
    # our grandparent when someone asks us to abort/start/stop
    #
    set TPATH \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T

    snit::method $TPATH \
    abort {} { $Shell abort [$self _ancestor 2] }

    snit::method $TPATH \
    abort_async {} { $Shell abort_async [$self _ancestor 2] }

    snit::method $TPATH \
    start {} { $Shell start [$self _ancestor 2] }

    snit::method $TPATH \
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
    snit::method $TPATH \
    _cast_handle_to_parent_obj {i_handle args} {
     $Shell _std_vport_protocolstack_range_cast_handle_to_parent_obj $self $i_handle
    }

    #
    # This override declares the (aggregate) stats for this type
    #
    snit::typemethod $TPATH \
    _aggregate_stat_decl {inst} { 
        set decl {
            gen "FCoE VF_Port" {
                "Port Name"                                port_name
                "VN_Ports Registered"                      vnports_registered
                "NS Requests Rx"                           ns_requests_rx
                "NS Accepts Tx"                            ns_acceptstx
                "NS Rejects Tx"                            ns_rejects_tx
                "SCR Requests Rx"                          scr_requests_x
                "SCR Accepts Tx"                           scr_accepts_tx
                "SCR Rejects Tx"                           scr_rejects_tx
                "FLOGI Requests Rx"                        flogi_requests_rx
                "FLOGI LS_ACC Tx"                          flogi_ls_acc_tx
                "FLOGI LS_RJT Tx"                          flogi_ls_rjt_tx
                "FDISC Requests Rx"                        fdisc_requests_rx
                "FDISC LS_ACC Tx"                          fdisc_ls_acc_tx
                "FDISC LS_RJT Tx"                          fdisc_ls_rjt_tx
                "FLOGO Requests Rx"                        flogo_requests_rx
                "FLOGO LS_ACC Tx"                          flogo_ls_acc_tx
                "FLOGO LS_RJT Tx"                          flogo_ls_rjt_tx
                "PLOGI Requests Rx"                        plogi_requests_rx
                "PLOGI LS_ACC Tx"                          plogi_ls_acc_tx
                "PLOGI LS_RJT Tx"                          plogi_ls_rjt_tx
                "PLOGO Requests Rx"                        plogo_requests_rx
                "PLOGO LS_ACC Tx"                          plogo_ls_acc_tx
                "PLOGO LS_RJT Tx"                          plogo_ls_rjt_tx
                "PLOGI Requests Tx"                        plogi_requests_tx
                "PLOGI LS_ACC Rx"                          plogi_ls_acc_rx
                "PLOGI LS_RJT Rx"                          plogi_ls_rjt_rx
                "PLOGO Requests Tx"                        plogo_requests_tx
                "PLOGO LS_ACC Rx"                          plogo_ls_acc_rx
                "PLOGO LS_RJT Rx"                          plogo_ls_rjt_rx
                "Discovery Solicitations Rx"               disc_solicits_rx
                "Discovery Advertisements Tx"              disc_adverts_tx
                "VLAN Requests Rx"                         vlan_requests_rx
                "VLAN Notifications Tx"                    vlan_notifications_tx
                "Unsolicited Discovery Advertisements Tx"  unsol_disc_adverts_tx
                "ENode Keep-Alives Rx"                     enode_keep_alives_rx
                "ENode Keep-Alives Miss"                   enode_keep_alives_miss
                "Unexpected ENode Keep-Alives Rx"          unexp_enode_keep_alives_rx
                "VN_Port Keep-Alives Rx"                   vnport_keep_alives_rx
                "VN_Port Keep-Alives Miss"                 vnport_keepalives_miss
                "Unexpected VN_Port Keep-Alives Rx"        unexp_vnport_keep_alives_rx
                "Clear Virtual Links VN_Ports"             clear_vlink_vnports
                "Clear Virtual Links Tx"                   clear_vlink_tx
                "Clear Virtual Links Rx"                   clear_vlink_rx
            }
        }
        return $decl
    }

    snit::typemethod $TPATH \
    _stat_doc_decl {} {
        set decl {
            gen "FCoE VF_Port" {
                port_name                      "Port Name"
                vnports_registered             "VN_Ports Registered"
                ns_requests_rx                 "NS Requests Rx"
                ns_acceptstx                   "NS Accepts Tx"
                ns_rejects_tx                  "NS Rejects Tx"
                scr_requests_x                 "SCR Requests Rx"
                scr_accepts_tx                 "SCR Accepts Tx"
                scr_rejects_tx                 "SCR Rejects Tx"
                flogi_requests_rx              "FLOGI Requests Rx"
                flogi_ls_acc_tx                "FLOGI LS_ACC Tx"
                flogi_ls_rjt_tx                "FLOGI LS_RJT Tx"
                fdisc_requests_rx              "FDISC Requests Rx"
                fdisc_ls_acc_tx                "FDISC LS_ACC Tx"
                fdisc_ls_rjt_tx                "FDISC LS_RJT Tx"
                flogo_requests_rx              "FLOGO Requests Rx"
                flogo_ls_acc_tx                "FLOGO LS_ACC Tx"
                flogo_ls_rjt_tx                "FLOGO LS_RJT Tx"
                plogi_requests_rx              "PLOGI Requests Rx"
                plogi_ls_acc_tx                "PLOGI LS_ACC Tx"
                plogi_ls_rjt_tx                "PLOGI LS_RJT Tx"
                plogo_requests_rx              "PLOGO Requests Rx"
                plogo_ls_acc_tx                "PLOGO LS_ACC Tx"
                plogo_ls_rjt_tx                "PLOGO LS_RJT Tx"
                plogi_requests_tx              "PLOGI Requests Tx"
                plogi_ls_acc_rx                "PLOGI LS_ACC Rx"
                plogi_ls_rjt_rx                "PLOGI LS_RJT Rx"
                plogo_requests_tx              "PLOGO Requests Tx"
                plogo_ls_acc_rx                "PLOGO LS_ACC Rx"
                plogo_ls_rjt_rx                "PLOGO LS_RJT Rx"
                disc_solicits_rx               "Discovery Solicitations Rx"
                disc_adverts_tx                "Discovery Advertisements Tx"
                vlan_requests_rx               "VLAN Requests Rx"
                vlan_notifications_tx          "VLAN Notifications Tx"
                unsol_disc_adverts_tx          "Unsolicited Discovery Advertisements Tx"
                enode_keep_alives_rx           "ENode Keep-Alives Rx"
                enode_keep_alives_miss         "ENode Keep-Alives Miss"
                unexp_enode_keep_alives_rx     "Unexpected ENode Keep-Alives Rx"
                vnport_keep_alives_rx          "VN_Port Keep-Alives Rx"
                vnport_keepalives_miss         "VN_Port Keep-Alives Miss"
                unexp_vnport_keep_alives_rx    "Unexpected VN_Port Keep-Alives Rx"
                clear_vlink_vnports            "Clear Virtual Links VN_Ports"
                clear_vlink_tx                 "Clear Virtual Links Tx"
                clear_vlink_rx                 "Clear Virtual Links Rx"
            }
        }
        return $decl
    }

}; #end foreach x
