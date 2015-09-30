#
#
#

set _ENDPOINT_T "fcoeFwdEndpoint"
set _RANGE_T "fcoeFwdVnPortRange"
set _STUPID_NEXUS secondaryRange
set T ::ixia::hag::ixn::types
foreach x { ethernet } {
    #
    # Ixnetwork only allows abort/start/stop at the endpoint level it seems
    # so override abort/start/stop to abort/start/stop
    # our grandparent when someone asks us to abort/start/stop
    #
    set TPATH \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/$_STUPID_NEXUS/$_RANGE_T

    snit::method $TPATH \
    abort {} { $Shell abort [$self _ancestor 2] }
    
    snit::method $TPATH \
    abort_async {} { $Shell abort_async [$self _ancestor 2]}

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
     $Shell _std_vport_protocolstack_secondaryRange_cast_handle_to_parent_obj \
      $self $i_handle "*/fcoeFwdVxPort"
    }

    #
    # This override declares the (aggregate) stats for this type
    #
    snit::typemethod $TPATH \
    _aggregate_stat_decl {inst} {
        set decl {
            gen "XXX" {
                "Port Name"                 port_name
                "Sessions Initiated"        sessions_initiated
                "Sessions Succeeded"        sessions_succeeded
                "Sessions Failed"           sessions_failed
                "XXX Mismatches Detected"   dcbx_mismatches_detected
                "XXX Invalid PDU"           dcbx_invalid_pdu
            }
        }; # end set decl
        return $decl
    }

    snit::typemethod $TPATH \
    _stat_doc_decl {} {
        set decl {
            gen "XXX" {
                port_name                  "Port Bame"
                sessions_initiated         "Sessions Initiated"
                sessions_succeeded         "Sessions Succeeded"
                sessions_failed            "Sessions Failed"
                dcbx_mismatches_detected   "XXX Mismatches Detected"
                dcbx_invalid_pdu           "XXX Invalid PDU"
            }
        }; # end set decl
        return $decl
    }
}
