##Procedure Header
# Name:
#    ::ixiangpf::get_execution_log
#
# Description:
#    this method returns the current hl execution log file path
#    The result key is "execution_log"
#
# Synopsis:
#    ::ixiangpf::get_execution_log
#
# Arguments:
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
#

proc ::ixiangpf::get_execution_log { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "get_execution_log" $notImplementedParams $mandatoryParams $fileParams $args]
}
