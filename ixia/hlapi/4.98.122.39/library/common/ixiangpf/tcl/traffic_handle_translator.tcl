proc ::ixiangpf::traffic_handle_translator { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "traffic_handle_translator" $notImplementedParams $mandatoryParams $fileParams $args]
}
