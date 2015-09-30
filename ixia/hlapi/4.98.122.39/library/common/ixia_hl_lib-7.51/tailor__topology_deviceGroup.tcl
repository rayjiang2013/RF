#
#
#
set T ::ixia::hag::ixn::types
set x /topology/deviceGroup

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
        return $i_handle
}
