#
#
#

set _ENDPOINT_T "ipEndpoint"
set _RANGE_T "ptpRangeOverIp"
set T ::ixia::hag::ixn::types
set TT ${T}::/vport/protocolStack/ethernet/$_ENDPOINT_T/range/$_RANGE_T
eval {
    #
    # Ixnetwork only allows abort/start/stop at the endpoint level it seems
    # so override abort/start/stop to abort/start/stop
    # our grandparent when someone asks us to abort/start/stop
    #
    snit::method ${TT} abort {} { $Shell abort [$self _ancestor 2] }
    snit::method ${TT} abort_async {} { $Shell abort_async [$self _ancestor 2]}
    snit::method ${TT} start {} { $Shell start [$self _ancestor 2] }
    snit::method ${TT} stop {} { $Shell stop [$self _ancestor 2] }
    
    #
    # Override to allow a classis hlt port_handle", which is just a chassis
    # "chassisN/cardN/portN" string, to be supplied as the parent_handle
    # for a .../$_RANGE_T 
    # note: the element that must be returned is a hag object
    # representing the parent of the highest level ancestor auto-generated 
    # by the target object ($self). it should not the immediate parent 
    # of target object
    #
    snit::method ${TT} _cast_handle_to_parent_obj {i_handle args} {
        array set o $args

        if {$o(-mode) == "add"} { 
            error "this mode should not be used"
            
            set typepath [$i_handle _typepath]
            if {![regexp "/vport/protocolStack/(ethernet|atm)/ipEndpoint/range" $typepath]} {
                error "invalid codegen handle"
            }
            return $i_handle 
        } 
        
        # assume now it's a hlt handle
        set ixn_handle [string trim $i_handle {{}}]

        set path_parts [split $ixn_handle /]
        for {set i 0} {$i < [llength $path_parts]} {incr i} {
            if {[lindex $path_parts $i] == "protocolStack"} {
                break
            }
        }
        set port_handle [join [lrange $path_parts 0 $i] /]
        set ixn_l2_handle [join [lrange $path_parts 0 [incr i]] /]
        set ixn_ipEndpoint [join [lrange $path_parts 0 [incr i]] /]
        set ixn_ipEndpoint_range [join [lrange $path_parts 0 [incr i]] /]

        set l2_flavor "ethernet"
        if {[string match "*/atm/*" [$self _typepath]]} {
            set l2_flavor "atm"
        }
        
        set l2range_inst [$Shell _create_instance "/vport/protocolStack/$l2_flavor"]
        set own_ixn_handle 0
        $l2range_inst _set_ixn_handle $ixn_l2_handle $own_ixn_handle

        # this links the parents and children
        $Shell _make_endpoint_ancestors_from_flavor_inst $self $l2range_inst

        set ip_inst [$Shell _inject_ixn_handle \
            [$l2range_inst _typepath]/ipEndpoint $ixn_ipEndpoint \
            $l2range_inst \
            [$l2range_inst _get_var Children] \
        ]
        set range_inst [$Shell _inject_ixn_handle \
            [$ip_inst _typepath]/range $ixn_ipEndpoint_range \
            $ip_inst \
            [$ip_inst _get_var Children] \
        ]

        # force add parent to ancestors in order to destroy the range
        $self _set_var Ancestors [concat [$self _get_var Ancestors] [list $range_inst]]

        return $range_inst
    }

    #
    # This override declares the (aggregate) stats for this type
    #
    snit::typemethod ${TT} _aggregate_stat_decl {inst} {
        set decl {
            gen "PTP" {
                "Port Name"                               port_name
                "Sessions Initiated"                      sessions_initiated
                "Sessions Succeeded"                      sessions_succeeded
                "Sessions Failed"                         sessions_failed
                "Sessions Active"                         sessions_active
                "Initiated Sessions Rate"                 initiated_sessions_rate
                "Successful Sessions Rate"                successful_sessions_rate
                "Failed Sessions Rate"                    failed_sessions_rate
                "Announce Messages Sent"                  announce_messages_sent
                "Announce Messages Received"              announce_messages_received
                "Sync Messages Sent"                      sync_messages_sent
                "Sync Messages Received"                  sync_messages_received
                "FollowUp Messages Sent"                  followup_messages_sent
                "FollowUp Messages Received"              followup_messages_received
                "DelayReq Messages Sent"                  delayreq_messages_sent
                "DelayReq Messages Received"              delayreq_messages_received
                "DelayResp Messages Sent"                 delayresp_messages_sent
                "DelayResp Messages Received"             delayresp_messages_received
                "PdelayReq Messages Sent"                 pdelayreq_messages_sent
                "PdelayReq Messages Received"             pdelayreq_messages_received
                "PdelayResp Messages Sent"                pdelayresp_messages_sent
                "PdelayResp Messages Received"            pdelayrest_messages_received
                "PdelayRespFollowUp Messages Sent"        pdelayrespfollowup_messages_sent
                "PdelayRespFollowUp Messages Received"    pdelayrespfollowup_messages_received
            }
        }; # end set decl
        return $decl
    }

    snit::typemethod ${TT} _stat_doc_decl {} {
        set decl {
            gen "PTP" {
                port_name                               "Port Name"
                sessions_initiated                      "Sessions Initiated"
                sessions_succeeded                      "Sessions Succeeded"
                sessions_failed                         "Sessions Failed"
                sessions_active                         "Sessions Active"
                initiated_sessions_rate                 "Initiated Sessions Rate"
                successful_sessions_rate                "Successful Sessions Rate"
                failed_sessions_rate                    "Failed Sessions Rate"
                announce_messages_sent                  "Announce Messages Sent"
                announce_messages_received              "Announce Messages Received"
                sync_messages_sent                      "Sync Messages Sent"
                sync_messages_received                  "Sync Messages Received"
                followup_messages_sent                  "FollowUp Messages Sent"
                followup_messages_received              "FollowUp Messages Received"
                delayreq_messages_sent                  "DelayReq Messages Sent"
                delayreq_messages_received              "DelayReq Messages Received"
                delayresp_messages_sent                 "DelayResp Messages Sent"
                delayresp_messages_received             "DelayResp Messages Received"
                pdelayreq_messages_sent                 "PdelayReq Messages Sent"
                pdelayreq_messages_received             "PdelayReq Messages Received"
                pdelayresp_messages_sent                "PdelayResp Messages Sent"
                pdelayrest_messages_received            "PdelayResp Messages Received"
                pdelayrespfollowup_messages_sent        "PdelayRespFollowUp Messages Sent"
                pdelayrespfollowup_messages_received    "PdelayRespFollowUp Messages Received"
            }
        }; # end set decl
        return $decl
    }
}
