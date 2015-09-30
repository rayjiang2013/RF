#
#
#

set _ENDPOINT_T "fcoeClientEndpoint"
set _RANGE_T "fcoeClientFdiscRange"
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
        $Shell _std_vport_protocolstack_range_cast_handle_to_parent_obj \
            $self $i_handle
    }

    #
    # This override declares the (aggregate) stats for this type
    #
    snit::typemethod \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T \
    _aggregate_stat_decl {inst} {
        set decl {
            gen "FCoE Client" {
                "Port Name"                         port_name
                "FLOGI Tx"                          flogi_tx
                "FDISC Tx"                          fdisc_tx
                "FLOGI LS_ACC Rx"                   flogi_ls_acc_rx
                "FLOGI LS_RJT Rx"                   flogi_ls_rjt_rx
                "FDISC LS_ACC Rx"                   fdisc_ls_acc_rx
                "FDISC LS_RJT Rx"                   fdisc_ls_rjt_rx
                "F_BSY Rx"                          f_bsy_rx
                "F_RJT Rx"                          f_rjt_rx
                "FLOGO Tx"                          flogo_tx
                "PLOGI Tx"                          plogi_tx
                "PLOGI Requests Rx"                 plogi_requests_rx
                "PLOGI LS_ACC Rx"                   plogi_ls_acc_rx
                "PLOGI LS_RJT Rx"                   plogi_ls_rjt_rx
                "PLOGO Tx"                          plogo_tx
                "PLOGO Rx"                          plogo_rx
                "NS Registration Tx"                ns_registration_tx
                "NS Registration OK"                ns_registration_ok
                "NS Queries Tx"                     ns_queries_tx
                "NS Queries OK"                     ns_queries_ok
                "SCR Tx"                            scr_tx
                "SCR ACC Rx"                        scr_acc_rx
                "RSCN Rx"                           rscn_rx
                "RSCN ACC Tx"                       rscn_acc_tx
                "FIP Discovery Solicitations Tx"    fip_discovery_solicitations_tx
                "FIP Discovery Advertisements Rx"   fip_discovery_advertisements_rx
                "FIP Keep-Alives Tx"                fip_keep_alives_tx
                "FIP Clear Virtual Links Rx"        fip_clear_virtual_links_rx
                "Interfaces Up"                     interfaces_up
                "Interfaces Down"                   interfaces_down
                "Interfaces Fail"                   interfaces_fail
                "Interfaces Outstanding"            interfaces_outstanding
                "Sessions Initiated"                sessions_initiated
                "Sessions Succeeded"                sessions_succeeded
                "Sessions Failed"                   sessions_failed
            }
        }; # end set decl
        return $decl
    }

    snit::typemethod \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T \
    _stat_doc_decl {} {
        set decl {
            gen "FCoE Client" {
                port_name                          "Port Name"
                flogi_tx                           "FLOGI Tx"
                fdisc_tx                           "FDISC Tx"
                flogi_ls_acc_rx                    "FLOGI LS_ACC Rx"
                flogi_ls_rjt_rx                    "FLOGI LS_RJT Rx"
                fdisc_ls_acc_rx                    "FDISC LS_ACC Rx"
                fdisc_ls_rjt_rx                    "FDISC LS_RJT Rx"
                f_bsy_rx                           "F_BSY Rx"
                f_rjt_rx                           "F_RJT Rx"
                flogo_tx                           "FLOGO Tx"
                plogi_tx                           "PLOGI Tx"
                plogi_requests_rx                  "PLOGI Requests Rx"
                plogi_ls_acc_rx                    "PLOGI LS_ACC Rx"
                plogi_ls_rjt_rx                    "PLOGI LS_RJT Rx"
                plogo_tx                           "PLOGO Tx"
                plogo_rx                           "PLOGO Rx"
                ns_registration_tx                 "NS Registration Tx"
                ns_registration_ok                 "NS Registration OK"
                ns_queries_tx                      "NS Queries Tx"
                ns_queries_ok                      "NS Queries OK"
                scr_tx                             "SCR Tx"
                scr_acc_rx                         "SCR ACC Rx"
                rscn_rx                            "RSCN Rx"
                rscn_acc_tx                        "RSCN ACC Tx"
                fip_discovery_solicitations_tx     "FIP Discovery Solicitations Tx"
                fip_discovery_advertisements_rx    "FIP Discovery Advertisements Rx"
                fip_keep_alives_tx                 "FIP Keep-Alives Tx"
                fip_clear_virtual_links_rx         "FIP Clear Virtual Links Rx"
                interfaces_up                      "Interfaces Up"
                interfaces_down                    "Interfaces Down"
                interfaces_fail                    "Interfaces Fail"
                interfaces_outstanding             "Interfaces Outstanding"
                sessions_initiated                 "Sessions Initiated"
                sessions_succeeded                 "Sessions Succeeded"
                sessions_failed                    "Sessions Failed"
            }
        }; # end set decl
        return $decl
    }
}
