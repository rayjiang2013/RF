##Procedure Header
# Name:
#    ::ixiangpf::pppox_control
#
# Description:
#    Start, stop, or restart the PPPoX sessions.
#
# Synopsis:
#    ::ixiangpf::pppox_control
#        [-handle        ANY]
#x       -action         CHOICES abort
#x                       CHOICES abort_async
#x                       CHOICES connect
#x                       CHOICES disconnect
#x                       CHOICES reset
#x                       CHOICES reset_async
#x                       CHOICES restart_down
#x                       CHOICES send_ping
#x                       CHOICES open_ipcp
#x                       CHOICES close_ipcp
#x                       CHOICES open_ipv6cp
#x                       CHOICES close_ipv6cp
#x       [-ipv4_ping_dst ANY]
#x       [-ipv6_ping_dst ANY]
#
# Arguments:
#    -handle
#        For ixiangpf implementation, -handle argument can be a protocol or interface handle returned by pppox_config.
#        For legacy implementation, -handle argument can be a port_handle or a range handle, returned by legacy pppox_config.
#x   -action
#x       Action to be executed.
#x       Choices not supported:
#x       clear- Clears the status and statistics of the PPP sessions.
#x       Not available when IxNetwork is used for PPPoX configurations.
#x       pause- Pauses all the PPP sessions.
#x       Not available when IxNetwork is used for PPPoX configurations.
#x       resume- Resumes all the PPP sessions.
#x       Not available when IxNetwork is used for PPPoX configurations.
#x       retry- Attempts to connect PPP sessions that have previously failed to establish.
#x       Not available when IxNetwork is used for PPPoX configurations.
#x   -ipv4_ping_dst
#x       The IPv4 destination to which you want to send ping.
#x   -ipv6_ping_dst
#x       The IPv6 destination to which you want to send ping.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status  value:$::SUCCESS | $::FAILURE
#    If status is failure, detailed information provided.
#    key:log     value:If status is failure, detailed information provided.
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    Coded versus functional specification.
#    1) clear action has not been implemented yet
#
# See Also:
#

proc ::ixiangpf::pppox_control { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "pppox_control" $notImplementedParams $mandatoryParams $fileParams $args]
}
