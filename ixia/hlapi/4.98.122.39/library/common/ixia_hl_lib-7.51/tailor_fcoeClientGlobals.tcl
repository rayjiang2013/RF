#
#
#

set _SESSIONDATA_T "fcoeClientGlobals"
set T ::ixia::hag::ixn::types
eval {
    set TPATH ${T}::/globals/protocolStack/$_SESSIONDATA_T
    #
    # Do any special initialization that should occur 
    # after the instance has been created via xxx_config create|add
    # and it's initial properties have been configured
    #
    # Wire the following in:
    #    [ixNet getRoot]/statistics -enableDataCenterSharedStats True
    #
    snit::method ${TPATH} \
    _post_construct_callback {args} {
        if {[llength $args]==1} {set args [lindex $args 0]}
        $Shell _ixn_eval ixNet setMultiAttrs \
            [ixNet getRoot]/statistics -enableDataCenterSharedStats True
        $Shell _ixn_eval ixNet commit
    }
}
