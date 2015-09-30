##Procedure Header
# Name:
#    ::ixiangpf::emulation_bgp_control
#
# Description:
#    Stop, start, or restart the protocol.
#
# Synopsis:
#    ::ixiangpf::emulation_bgp_control
#        -mode                   CHOICES link_flap
#                                CHOICES restart
#                                CHOICES abort
#                                CHOICES restart_down
#                                CHOICES start
#                                CHOICES stop
#                                CHOICES statistic
#                                CHOICES break_tcp_session
#                                CHOICES resume_tcp_session
#                                CHOICES resume_keep_alive
#                                CHOICES stop_keep_alive
#        [-handle                ANY]
#x       [-notification_code     NUMERIC
#x                               DEFAULT 0]
#x       [-notification_sub_code NUMERIC
#x                               DEFAULT 0]
#n       [-link_flap_up_time     ANY]
#n       [-link_flap_down_time   ANY]
#n       [-port_handle           ANY]
#
# Arguments:
#    -mode
#        What is being done to the protocol..
#    -handle
#        The BGP session handle.
#x   -notification_code
#x       The notification code for break_tcp_session and resume_tcp_session.
#x   -notification_sub_code
#x       The notification sub code for break_tcp_session and resume_tcp_session.
#n   -link_flap_up_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -link_flap_down_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -port_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status  value:$::SUCCESS | $::FAILURE
#    On status of failure, gives detailed information.
#    key:log     value:On status of failure, gives detailed information.
#
# Examples:
#    See files starting with BGP4_ in the Samples subdirectory.  Also see some
#    of the L3VPN, MPLS, and MVPN sample files for further examples of BGP usage.
#    See the BGP examples in Appendix A, "Example APIs," for specific example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    Coded versus functional specification.
#
# See Also:
#

proc ::ixiangpf::emulation_bgp_control { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_bgp_control" $notImplementedParams $mandatoryParams $fileParams $args]
}
