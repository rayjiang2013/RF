##Procedure Header
# Name:
#    ::ixiangpf::emulation_vxlan_control
#
# Description:
#    Controls VXLAN sessions.
#
# Synopsis:
#    ::ixiangpf::emulation_vxlan_control
#        [-handle ANY]
#        [-action CHOICES start
#                 CHOICES stop
#                 CHOICES abort
#                 CHOICES abort_async
#                 CHOICES restart_down
#                 DEFAULT start]
#
# Arguments:
#    -handle
#        Allows the user to optionally select the groups to which the
#        specified action is to be applied.
#        If this parameter is not specified, then the specified action is
#        applied to all groups configured on the port specified by
#        the -port_handle command. The handle is obtained from the keyed list returned
#        in the call to emulation_vxlan_config proc.
#        The port handle parameter must have been initialized and vxlan group
#        emulation must have been configured prior to calling this function.
#    -action
#        Action to take on the specified handle.
#        The parameters specified in the emulation_vxlan_config proc
#        are used to control the bind/renew/release rates.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status  value:$::SUCCESS | $::FAILURE
#    When status is failure, contains more information
#    key:log     value:When status is failure, contains more information
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#

proc ::ixiangpf::emulation_vxlan_control { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_vxlan_control" $notImplementedParams $mandatoryParams $fileParams $args]
}
