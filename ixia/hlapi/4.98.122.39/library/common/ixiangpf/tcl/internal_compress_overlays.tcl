proc ::ixiangpf::internal_compress_overlays { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "internal_compress_overlays" $notImplementedParams $mandatoryParams $fileParams $args]
}
