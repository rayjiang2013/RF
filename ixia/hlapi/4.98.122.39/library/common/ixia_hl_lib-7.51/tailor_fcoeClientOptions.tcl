#
#
#

set _PGGROUPDATA_T "fcoeClientOptions"
set T ::ixia::hag::ixn::types
eval {
    set TPATH ${T}::/vport/protocolStack/$_PGGROUPDATA_T
    #
    # Override to allow a classic hlt port_handle", which is just a chassis
    # "chassisN/cardN/portN" string, to be supplied as the parent_handle
    # for a .../$_RANGE_T 
    # note: the element that must be returned is a hag object
    # representing the parent of the highest level ancestor auto-generated 
    # by the target object ($self). it should not the immediate parent 
    # of target object
    #
    snit::method ${TPATH} \
    _cast_handle_to_parent_obj {i_handle args} {
        # If the thing passed in is a simple chassisN/cardN/portN string
        # we need to morph it into a hag object
        if {![regexp -- {^[0-9]+/[0-9]+/[0-9]+$} $i_handle]} {
            # not a port string, assume we've been passed a hag object
            return $i_handle; 
        } 
        set port_str $i_handle
        set protocol_stack_type ""; # don't include the ethernet|atm level
        set rval [$Shell _make_endpoint_ancestors_from_port_str \
           $self $port_str $protocol_stack_type]
        return $rval
    }
}
