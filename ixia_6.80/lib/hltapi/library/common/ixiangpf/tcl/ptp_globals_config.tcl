##Procedure Header
# Name:
#    ::ixiangpf::ptp_globals_config
#
# Description:
#    Not supported in ixiangpf namespace.
#
# Synopsis:
#    ::ixiangpf::ptp_globals_config
#        -mode             CHOICES create add modify delete
#        -parent_handle    ANY
#        [-handle          ANY]
#        [-style           ANY]
#        [-max_outstanding RANGE 1-10000
#                          DEFAULT 20]
#        [-setup_rate      RANGE 1-20000
#                          DEFAULT 5]
#        [-teardown_rate   RANGE 1-20000
#                          DEFAULT 5]
#
# Arguments:
#    -mode
#        Not supported in ixiangpf namespace.
#    -parent_handle
#        Not supported in ixiangpf namespace.
#    -handle
#        Not supported in ixiangpf namespace.
#    -style
#        Not supported in ixiangpf namespace.
#    -max_outstanding
#        Not supported in ixiangpf namespace.
#    -setup_rate
#        Not supported in ixiangpf namespace.
#    -teardown_rate
#        Not supported in ixiangpf namespace.
#
# Return Values:
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
#    External documentation on Tclx keyed lists
#

proc ::ixiangpf::ptp_globals_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "ptp_globals_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
