#
#
#
set _PGGROUPDATA_T "ptpOptions"
set T ::ixia::hag::ixn::types
eval {
    set TPATH ${T}::/vport/protocolStack/$_PGGROUPDATA_T
    snit::method ${TPATH} \
    _cast_handle_to_parent_obj {i_handle args} {
        $Shell _std_vport_protocolstack_options_cast_handle_to_parent_obj \
            $self $i_handle
    }
}
