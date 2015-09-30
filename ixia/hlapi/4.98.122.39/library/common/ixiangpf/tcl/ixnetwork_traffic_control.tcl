proc ::ixiangpf::ixnetwork_traffic_control { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "ixnetwork_traffic_control" $notImplementedParams $mandatoryParams $fileParams $args]
}
