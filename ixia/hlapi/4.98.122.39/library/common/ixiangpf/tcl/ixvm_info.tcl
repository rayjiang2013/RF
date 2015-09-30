##Procedure Header
# Name:
#    ::ixiangpf::ixvm_info
#
# Description:
#    This command enables user to retrive all card and port data from an IxVM virtual chassis.
#
# Synopsis:
#    ::ixiangpf::ixvm_info
#x       [-mode            CHOICES current_configuration
#x                         CHOICES discovered_appliances
#x                         DEFAULT current_configuration]
#x       -virtual_chassis  ANY
#x       [-rediscover      CHOICES 0 1]
#
# Arguments:
#x   -mode
#x   -virtual_chassis
#x       The ip or hostname of the virtual chassis. If a DNS name is provided, please make sure the name can be resolved using the dns provider from the ixnetwork_tcl_server machine.
#x   -rediscover
#x       If this argument is specified, a rediscovery will be done prior to returning discovered appliances.
#x       Valid only when mode is discovered_appliances.
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
#
# See Also:
#

proc ::ixiangpf::ixvm_info { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "ixvm_info" $notImplementedParams $mandatoryParams $fileParams $args]
}
