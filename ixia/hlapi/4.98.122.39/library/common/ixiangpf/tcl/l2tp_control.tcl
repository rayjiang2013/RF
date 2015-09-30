##Procedure Header
# Name:
#    ::ixiangpf::l2tp_control
#
# Description:
#    Start, stop or restart the l2tpox sessions and tunnels.
#
# Synopsis:
#    ::ixiangpf::l2tp_control
#        -action  CHOICES connect
#                 CHOICES disconnect
#                 CHOICES abort
#                 CHOICES abort_async
#                 CHOICES retry
#        [-handle ANY]
#
# Arguments:
#    -action
#        Action to be executed.
#        choices not supported:
#        reset- Aborts all L2TPoX sessions and resets the L2TP
#        emulation engine on the specified device. A session is
#        not notified of termination, and a Terminate Request
#        packet is not sent to the peers.
#        clear- Clears the status and statistics.
#        pause- Pauses all the sessions.
#        resume- Resumes all the sessions.
#    -handle
#        The port where the L2TPoX sessions are to be created.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status  value:$::SUCCESS | $::FAILURE
#    If status is failure, detailed information provided.
#    key:log     value:If status is failure, detailed information provided.
#
# Examples:
#    See files in the Samples/IxNetwork/L2TP subdirectory.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    Coded versus functional specification.
#    1) Clear action has not been implemented yet.
#
# See Also:
#

proc ::ixiangpf::l2tp_control { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "l2tp_control" $notImplementedParams $mandatoryParams $fileParams $args]
}
