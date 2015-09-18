proc ::ixiangpf::multivalue_subset_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "multivalue_subset_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
