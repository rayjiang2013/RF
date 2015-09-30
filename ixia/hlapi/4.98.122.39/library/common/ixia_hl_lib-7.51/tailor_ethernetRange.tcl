#
# tailor_ethernetEndpoint.tcl
#

set T ::ixia::hag::ixn::types
set x ethernetEndpoint/range/macRange

#
# Ixnetwork only allows abort/start/stop at the endpoint level it seems
# so override abort/start/stop to abort/start/stop
# our grandparent when someone asks us to abort/start/stop
#
snit::method \
    ${T}::/vport/protocolStack/$x \
    abort {} { $Shell abort [$self _ancestor 2] }

snit::method \
    ${T}::/vport/protocolStack/$x \
    abort_async {} { $Shell abort_async [$self _ancestor 2]}

snit::method \
    ${T}::/vport/protocolStack/$x \
    start {} { $Shell start [$self _ancestor 2] }

snit::method \
    ${T}::/vport/protocolStack/$x \
    stop {} { $Shell stop [$self _ancestor 2] }

    
#
# Override to allow a classis hlt port_handle", which is just a chassis
# "chassisN/cardN/portN" string, to be supplied as the parent_handle
# note: the element that must be returned is a hag object
# representing the parent of the highest level ancestor auto-generated 
# by the target object ($self). it should not the immediate parent 
# of target object
#
snit::method \
${T}::/vport/protocolStack/$x \
_cast_handle_to_parent_obj {i_handle args} {
 $Shell \
 _make_protocolStack_ancestors_from_port_str $self $i_handle "ethernet"
}

