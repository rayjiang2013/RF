#
#
#
set T ::ixia::hag::ixn::types
set x /topology

#
# Override to allow a classis hlt port_handle", which is just a chassis
# "chassisN/cardN/portN" string, to be supplied as the parent_handle
# note: the element that must be returned is a hag object
# representing the parent of the highest level ancestor auto-generated 
# by the target object ($self). it should not the immediate parent 
# of target object
#
snit::method \
${T}::$x _cast_handle_to_parent_obj {i_handle args} {
    if {$i_handle != "none"} {
        return $i_handle
    }
    set failed [catch {$Shell _create_instance "/"} root_inst]
    if $failed {
        puts stderr "ERROR\n----------\n"
        puts stderr >>>>$root_inst
        puts stderr "\n----------\n"
        return -code error $root_inst
    }
    set topology_inst [$self _get_var Parent]
    return $root_inst
}


