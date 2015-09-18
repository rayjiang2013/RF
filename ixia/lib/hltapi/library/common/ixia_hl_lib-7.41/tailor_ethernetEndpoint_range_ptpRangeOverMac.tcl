#
#
#

set _ENDPOINT_T "ethernetEndpoint"
set _RANGE_T "ptpRangeOverMac"
set T ::ixia::hag::ixn::types
eval {
    #
    # Ixnetwork only allows abort/start/stop at the endpoint level it seems
    # so override abort/start/stop to abort/start/stop
    # our grandparent when someone asks us to abort/start/stop
    #
    snit::method \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    abort {} { $Shell abort [$self _ancestor 2] }
    
    snit::method \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    abort_async {} { $Shell abort_async [$self _ancestor 2]}
    
    snit::method \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    start {} { $Shell start [$self _ancestor 2] }

    snit::method \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
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
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    _cast_handle_to_parent_obj {i_handle args} {
        array set o $args

        if {$o(-mode) == "add"} { return $i_handle } 

        if {[$i_handle _typepath_tail [$i_handle _typepath]] != "macRange"} {
            return -code error \
            "$self: Illegal parent handle $i_handle: typepath = [$i_handle _typepath]"
        } else {
            return [$i_handle _parent]
        }
    }

    #
    # This override declares the (aggregate) stats for this type
    #
    snit::typemethod \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    _aggregate_stat_decl {inst} {
        set decl {
            gen "PTP" {
                "Port Name"                              port_name
                "Sessions Initiated"                     sessions_initiated
                "Sessions Succeeded"                     sessions_succeeded
                "Sessions Failed"                        sessions_failed
                "Sessions Active"                        sessions_active
                "Initiated Sessions Rate"                initiated_sessions_rate
                "Successful Sessions Rate"               successful_sessions_rate
                "Failed Sessions Rate"                   failed_sessions_rate
                "Announce Messages Sent"                 announce_messages_sent
                "Announce Messages Received"             announce_messages_received
                "Sync Messages Sent"                     sync_messages_sent
                "Sync Messages Received"                 sync_messages_received
                "FollowUp Messages Sent"                 followup_messages_sent
                "FollowUp Messages Received"             followup_messages_received
                "DelayReq Messages Sent"                 delayreq_messages_sent
                "DelayReq Messages Received"             delayreq_messages_received
                "DelayResp Messages Sent"                delayresp_messages_sent
                "DelayResp Messages Received"            delayresp_messages_received
                "PdelayReq Messages Sent"                pdelayreq_messages_sent
                "PdelayReq Messages Received"            pdelayreq_messages_received
                "PdelayResp Messages Sent"               pdelayresp_messages_sent
                "PdelayResp Messages Received"           pdelayrest_messages_received
                "PdelayRespFollowUp Messages Sent"       pdelayrespfollowup_messages_sent
                "PdelayRespFollowUp Messages Received"   pdelayrespfollowup_messages_received
                "Signaling Messages Sent"                signaling_messages_sent
                "Signaling Messages Received"            signaling_messages_received
                "Sync Messages Received Rate"            sync_messages_received_rate
                "FollowUp Messages Received Rate"        followup_messages_received_rate
                "DelayReq Messages Received Rate"        delayreq_messages_received_rate
                "DelayResp Messages Received Rate"       delayresp_messages_received_rate
                "GPS Unit Present"                       gps_unit_present
                "GPS Synchronized"                       gps_synchronized
            }
        }; # end set decl
        return $decl
    }

    snit::typemethod \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    _stat_doc_decl {} {
        set decl {
            gen "PTP" {
                port_name                              "Port Name"
                sessions_initiated                     "Sessions Initiated"
                sessions_succeeded                     "Sessions Succeeded"
                sessions_failed                        "Sessions Failed"
                sessions_active                        "Sessions Active"
                initiated_sessions_rate                "Initiated Sessions Rate"
                successful_sessions_rate               "Successful Sessions Rate"
                failed_sessions_rate                   "Failed Sessions Rate"
                announce_messages_sent                 "Announce Messages Sent"
                announce_messages_received             "Announce Messages Received"
                sync_messages_sent                     "Sync Messages Sent"
                sync_messages_received                 "Sync Messages Received"
                followup_messages_sent                 "FollowUp Messages Sent"
                followup_messages_received             "FollowUp Messages Received"
                delayreq_messages_sent                 "DelayReq Messages Sent"
                delayreq_messages_received             "DelayReq Messages Received"
                delayresp_messages_sent                "DelayResp Messages Sent"
                delayresp_messages_received            "DelayResp Messages Received"
                pdelayreq_messages_sent                "PdelayReq Messages Sent"
                pdelayreq_messages_received            "PdelayReq Messages Received"
                pdelayresp_messages_sent               "PdelayResp Messages Sent"
                pdelayrest_messages_received           "PdelayResp Messages Received"
                pdelayrespfollowup_messages_sent       "PdelayRespFollowUp Messages Sent"
                pdelayrespfollowup_messages_received   "PdelayRespFollowUp Messages Received"
                signaling_messages_sent                "Signaling Messages Sent"
                signaling_messages_received            "Signaling Messages Received"
                sync_messages_received_rate            "Sync Messages Received Rate"
                followup_messages_received_rate        "FollowUp Messages Received Rate"
                delayreq_messages_received_rate        "DelayReq Messages Received Rate"
                delayresp_messages_received_rate       "DelayResp Messages Received Rate"
                gps_unit_present                       "GPS Unit Present"
                gps_synchronized                       "GPS Synchronized"
            }
        }; # end set decl
        return $decl
    }

}
