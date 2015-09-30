#
#
#

set _PGGROUPDATA_T "fcoeFwdOptions"
set T ::ixia::hag::ixn::types
eval {
    set TPATH ${T}::/vport/protocolStack/$_PGGROUPDATA_T
    # Override to allow a classic hlt port_handle", which is just a chassis
    # "chassisN/cardN/portN" string, to be supplied as the parent_handle
    # for a .../$_RANGE_T 
    # note: the element that must be returned is a hag object
    # representing the parent of the highest level ancestor auto-generated 
    # by the target object ($self). it should not the immediate parent 
    # of target object
    snit::method ${TPATH} \
    _cast_handle_to_parent_obj {i_handle args} {
        $Shell _std_vport_protocolstack_options_cast_handle_to_parent_obj \
            $self $i_handle
    }
}
